@A+
//==== Business-Control ==================================================
//
//  Prozedur    ERe_Data
//                  OHNE E_R_G
//  Info
//    Generiert für die markierten Eingangsrechnungen Zahlungen und
//    Zahlungsausgänge
//
//
//  28.10.2003  ST  Erstellung der Prozedur
//  06.01.2010  AI  EKK korrigiert wird gefüllt bei RealeKosten
//  28.09.2010  AI  Lieferanten-Erlöse legen Storno-Eingangrechnung an
//  17.04.2012  AI  ZahlGenerate: Projekt1108/39 Zahldatum eingebbar
//  10.05.2012  AI  ADD:Zahlungsavis drucken nach Zahlungserzeugung (Prj 1347/80)
//  26.06.2012  AI  Projekt 1301/40: Zahlungsdatum nicht Vorbelegen
//  08.10.2012  AI  Zahlungsarten eingebaut
//  29.11.2012  AI  NEU: Sofortiger Scheckdruck
//  28.01.2013  AI  "Zahlgnerate": bereits gezahlte ERE überspringen
//  03.04.2013  AI  RND
//  10.04.2013  AI  MatMEH
//  22.04.2013  AI  Mengen für EKK aus Bestandsbuch
//  25.06.2013  AH  Neu: EKK.Zuordnung.Datum
//  20.08.2013  AH  Bugfix: RealeKosten vererben EK-Peis
//  04.04.2014  AH  BugFix: RealeKosten holt Anfangsmengen aus dem WE und NICHT aus dem Bestandsbuch, da dort auch Korrekturen im WE drin wären
//  23.03.2016  AH  "RealeKostenVererben" unterstützt Lohn-BAG
//  15.08.2016  AH  Erlöskorrektur beachten
//  02.02.2017  AH  Bug: Lohn-Eingangsrechnungen mit mehreren EKK
//  10.03.2017  AH  Edit: "RealeKostenVererben" benutzt "SetUndVererbeEkPreis"
//  17.03.2017  AH  Edit: "RealeKostenVererben" OHNE TRANSAKTION
//  28.04.2017  AH  Edit: "RealeKostenVererben" schreibt nur DELTA in Mat.Bestandsbuch
//  03.05.2017  AH  Edit: "RealeKostenVererben" schreibt KEINE Mat.Bestandsbuch mehr - dh. EK ist VON ANFANG AN anders
//  11.02.2019  AH  Edit: "RealeKostenVererben" schreibt Delta in Auf.Aktion, wenn Mat. noch nicht fakturiert ist
//  06.06.2019  AH  Edit: bei Wareneingangsrechnungen ist Wertstellungsdatum immer kleines Eingangsdatum der EKK
//  30.07.2019  AH  Edit: RealeKosten Korrekturbuchungen werden gemacht, Differenz zu EKK_Preis bzw. (NEU) EKK_Korrektur existieren
//  13.03.2020  AH  "ParseDiffText" nach "Erl_Data" transferiert
//  21.12.2021  AH  ERX
//  21.02.2022  AH  MatAktionen für EKK
//  2022-08-08  AH  AFX "ERe.Data.RealKosten.Vbk.K.Loop"
//  2023-01-16  AH  Einkaufs-Rückstellungen können gegen EKK aufgelöst werden samt Korrektur
//  2023-03-17  AH  EK-Rückstellungen HWN
//  2023-03-27  AH  "RealekostenVererben" hat falsche Mat.MEH benutzt
//  2023-05-19  AH  Aufpreise werden nicht doppelt gerechnet  Proj. 2478/35
//
//  Subprozeduren
//    SUB SumMarkiert() : float;
//    SUB ZahlGenerate()
//    SUB EKK_Zuordnen(aPos : int) : logic;
//    SUB ExistiertSchon() : logic;
//    sub _GetMengenAnhandEingang(var aStk : int; var aGew : float; var aMenge : float; var aMEH : alpha);
//    SUB RealeKostenVererben();
//    SUB FixRealeKosten
//
//========================================================================
@I:Lib_Nummern
@I:Def_Global
@I:Def_aktionen
@I:Def_Rights

define begin
//  Proto(a) : if (gUsername='AH') or (gUsername='TK') then debugx(a);
//  Proto(a) : begin end;
end;

//========================================================================
//  Scannen
//
//========================================================================
sub Scannen() : logic;
local begin
end;
begin
  // DMS

  RETURN true;
end;

//========================================================================
//  SumMarkiert
//
//========================================================================
sub SumMarkiert() : float;
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vX      : float;
end;
begin
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile=560) then begin
      RecRead(560,0,_RecId,vMID);
      vX # vX + ERe.BruttoW1;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RETURN vX;
end;


//========================================================================
//  ZahlGenerate
//
//========================================================================
sub ZahlGenerate()
LOCAL begin
  vHdl        : int;        // Handlingdescriptor
  vHdl2       : int;        // Handlingdescriptor
  tText       : alpha;      // Zahlartentext
  vZahlart    : int;        // Nummer der Zahlungsart

  vMarked     : int;        // Descriptor für den Marierungsbaum
  vMarkedItem : int;        // Descriptor für markierten Eintrag

  vEReTree    : int;        // Descriptor für die Sortierungsliste
  vEReSortKey : alpha;      // "Sortierungsschlüssel" der Liste
  vEReItem    : int;        // Descriptor für eine Eingangsrechnung

  vLieferant  : int;        // Lieferantenwechselmerker
  vRecId      : int;        // Descrpitor für RecId Übergeabe zwischen RamSortElement und 560

  vBetragSum   : float;     // Summen für Ausgangszahlungen
  vBetragW1Sum : float;
  vZAuNr       : int;
  vErr         : int;

  vMFile        : Int;
  vMID          : Int;
  vBuf560       : int;
  vDat          : date;
  vZauList      : int;
  vItem         : int;
  vGezahlt      : int;
end;
begin


  // Markierungen testen auf "in Ordnung"...
  vMarked # gMarkList->CteRead(_CteFirst);
  WHILE (vMarked > 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

    if (vMFile=560) then begin
      RecRead(560,0,_RecId,vMID);
      if (ERe.inOrdnung=n) then begin
        Msg(560008,cnvai(ERe.Nummer),0,0,0);
        RETURN;
      end;
      if (ERe.Zahlungen<>0.0) then inc(vGezahlt);
    end;

    vMarked # gMarkList->CteRead(_CteNext,vMarked);
  END;


  if (vGezahlt>0) then begin
    Msg(560015,aint(vGezahlt),0,0,0);
  end;

  // Aktion wirklich durchführen?
  if (Msg(560004,'',1,2,1)<>_WinIdOk) then RETURN;


// 08.10.2012 AI   vZahlArt # cnvia(Lib_Einheiten:Popup('Zahlungsart',0,0,0,0));

  RecBufClear(852);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ZhA.Verwaltung',here+':ZahlGenerate_AusZA');
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN;

end;

/***
  // Zahlungsart abfragen
  vHdl # WinOpen('Prg.Para.Auswahl',_WinOpenDialog);
  vHdl->wpAreaLeft    # gMdi->wpAreaLeft+200;
  vHdl->wpAreaTop     # gMdi->wpAreaTop+120;
  vHdl->wpAreaRight   # vHdl->wpAreaLeft + 200;
  vHdl->wpAreabottom  # vHdl->wpAreaTop + 130;
  vHdl->wpCaption     # 'Zahlungsart wählen...';
  vHdl2 # vHdl->WinSearch('DL.ParaAuswahl');
  // Auswahlliste füllen
  tText # Translate('Bar');
  vHdl2->WinLstDatLineAdd(tText,1);
  tText # Translate('Check');
  vHdl2->WinLstDatLineAdd(tText,2);
  tText # Translate('Überweisung');
  vHdl2->WinLstDatLineAdd(tText,3);
  vHdl->windialogrun();
  if (gSelected<>0) then
    vHdl2->WinLstCellGet(vZahlart,2,gSelected);
  vHdl->WinClose();
  vZahlart # gSelected;        // Auswahl sichern
  gSelected # 0;
***/


//========================================================================
//  ZahlGenerate_AusZA
//
//========================================================================
sub ZahlGenerate_AusZA()
local begin
  vHdl        : int;        // Handlingdescriptor
  vHdl2       : int;        // Handlingdescriptor
  tText       : alpha;      // Zahlartentext
  vZahlart    : int;        // Nummer der Zahlungsart

  vMarked     : int;        // Descriptor für den Marierungsbaum
  vMarkedItem : int;        // Descriptor für markierten Eintrag

  vEReTree    : int;        // Descriptor für die Sortierungsliste
  vEReSortKey : alpha;      // "Sortierungsschlüssel" der Liste
  vEReItem    : int;        // Descriptor für eine Eingangsrechnung

  vLieferant  : int;        // Lieferantenwechselmerker
  vRecId      : int;        // Descrpitor für RecId Übergeabe zwischen RamSortElement und 560

  vBetragSum   : float;     // Summen für Ausgangszahlungen
  vBetragW1Sum : float;
  vZAuNr       : int;
  vErr         : int;

  vMFile        : Int;
  vMID          : Int;
  vBuf560       : int;
  vDat          : date;
  vZauList      : int;
  vItem         : int;
  Erx           : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(852,0,_RecId,gSelected);
    // Feldübernahme
    vZahlARt # ZHA.Nummer;
    gSelected # 0;
  end;

  if (vZahlart = 0) then RETURN;

  // 26.06.2012 AI Projekt 1301/40 OHNE Vorbelegung
//  REPEAT
  if (Dlg_Standard:Datum(Translate('Zahldatum'),var vDat)=false) then RETURN;
//  UNTIL (vDat<>0.0.0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vErr # 0;

  vEReTree # CteOpen(_CteTreeCI);
  If (vEReTree = 0) then RETURN;

  /* Markierungen sortiert in eigene Liste schreiben */
  vMarked # gMarkList->CteRead(_CteFirst)
  WHILE (vMarked <> 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

    if (vMFile=560) then begin
      RecRead(560,0,_RecId,vMID);
      // 28.1.2013 AI : gezahlte überspringen
      if (Ere.Zahlungen<>0.0) then begin
        vMarked # gMarkList->CteRead(_CteNext,vMarked);
        CYCLE;
      end;

      // gelesenen Eintrag in eigene Liste übergeben
      vEReSortKey # CnvAi(ERe.Lieferant, _FmtNumNoGroup | _FmtNumLeadZero,0,10);
      Sort_ItemAdd(vEReTree,vEReSortKey,560,vMID);
    end;
    vMarked # gMarkList->CteRead(_CteNext,vMarked)

    if (vMFile=560) then Lib_Mark:MarkAdd(560, n, y);
  END;

  // Durchlaufen und löschen
//    FOR   vEReItem # Sort_ItemFirst(vEReTree)
//    loop  vEReItem # Sort_ItemNext(vEReTree,vEReItem)
//    WHILE (vEReItem != 0) do begin
//    END;
  // --------------------------------------------------

  // -------------------------------------------------------------
  // Zahlungen für jede Eingangsrechnung erstellen und Summierte
  // Beträge als Zahlungsausgang schreiben
  // -------------------------------------------------------------
  // ZAunummer für die erstn ersten Kunden lesen


  TRANSON;

  vZauNr      # 0;
  vLieferant  # 0;
  vEReItem # Sort_ItemFirst(vEReTree);
  WHILE (vEReItem != 0) DO BEGIN
    vRecId # vEReItem->spId;
    RecRead(560,0,_RecId,vRecID);

    if (vZauNr=0) then begin
      vZauNr # ReadNummer('Zahlungsausgang');        // Nummer lesen
      SaveNummer();                                  // Nummernkreis aktuallisiern
    end;

    vLieferant # ERe.Lieferant;
    // Lieferantendaten bereitstellen
    if (RecLink(100,560,5,0) > _rLocked) then
      RecBufClear(100);

    // -------------------------------
    // Zahlung schreiben
    // -------------------------------
    RecBufClear(561);
    ERe.Z.Nummer          # ERe.Nummer;
    ERe.Z.Zahlungsnr      # vZauNr;
    ERe.Z.Bemerkung       # Translate('automatisch');

    // mit Skonto??
    if (today<=ERe.Skontodatum) then begin
      ERe.Z.Betrag          # ERe.Brutto - ERe.Skonto;
      ERe.Z.BetragW1        # ERe.BruttoW1 - ERe.SkontoW1;
      ERe.Z.Skontobetrag    # ERe.Skonto;
      ERe.Z.SkontobetragW1  # ERe.SkontoW1;
      /*ERe.Z.Rest__SkontoYN    # TRUE;*/
    end
    else begin
      ERe.Z.Betrag          # ERe.Brutto;
      ERe.Z.BetragW1        # ERe.BruttoW1;
      ERe.Z.Skontobetrag    # 0.0;
      ERe.Z.SkontobetragW1  # 0.0;
      /*ERe.Z.Rest__SkontoYN    # false;*/
    end;

    Erx # RekInsert(561,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      vErr # 1;
      BREAK;
    end;

    // Zahlung an Eingangsrechnung buchen
    IF (RecRead(560,1,_RecLock) = _rOk) then begin
      ERe.Zahlungen   # Rnd(ERe.Zahlungen   + ERe.Z.Betrag + ERe.Z.Skontobetrag,2);
      ERe.ZahlungenW1 # Rnd(ERe.ZahlungenW1 + ERe.Z.BetragW1 + ERe.Z.SkontobetragW1,2);
      ERe.Rest        # Rnd(ERe.Brutto - ERe.Zahlungen,2);
      ERe.RestW1      # Rnd(ERe.BruttoW1 - ERe.ZahlungenW1,2);
      "ERe.Löschmarker" # '*';
      Erx # RekReplace(560,_RecUnlock,'AUTO');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        vErr # 1;
        BREAK;
      end;

    end;


    // -------------------------------

    // Für Ausgangszahlung summieren
    vBetragSum        # vBetragSum    + ERe.Z.Betrag;
    vBetragW1Sum      # vBetragW1Sum  + ERe.Z.BetragW1;



    vBuf560 # RekSave(560);
    // nächste Pos lesen
    vEReItem # vERetree->CteRead(_CteNext,vEReItem);
    If (vEReItem <> 0) then begin
      vRecId # vEReItem->spId;
      RecRead(560,0,_RecId,vRecID);
    end;

  // -------------------------------
  // Zahlungsausgang schreiben
  // -------------------------------
    If (vLieferant <> ERe.Lieferant) OR (vEReItem= 0) then begin
      RecBufClear(565);

      ZAu.Nummer # vZauNr;

      ZAu.Lieferant       # vBuf560->ERe.Lieferant;
      ZAu.LieferStichwort # Adr.Stichwort;
      ZAu.Zahlungsart     # vZahlart;
      "ZAu.Währung"       # vBuf560->"ERe.Währung";
      "ZAu.Währungskurs"  # vBuf560->"ERe.Währungskurs";
      ZAu.Betrag          # vBetragSum;
      ZAu.BetragW1        # vBetragW1Sum;
      ZAu.Zugeordnet      # vBetragSum;
      ZAu.ZugeordnetW1    # vBetragW1Sum;
      ZAu.Zahldatum       # vDat;

      vBetragSum          # 0.0;
      vBetragW1Sum        # 0.0;

      Erx # RekInsert(565,0,'MAN');
      if (Erx<>_rOk) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        vErr # 1;
        BREAK;
      end;

      // ZAU mekren
      if (vZauList=0) then
        vZauList # CteOpen(_cteList);
      CteInsertItem(vZauList, aint(Zau.Nummer), Zau.nummer,'', _CteFirst);

      vZauNr # 0;
    end;
    RecBufdestroy(vBuf560);
    vBuf560 # 0;

    // -------------------------------

  END;  // while

  if (vErr=0) then TRANSOFF;
  if (vZauList=0) then begin
    Refreshlist(gZLList, _WinLstFromFirst);
    RETURN;
  end;

  // Löschen der Liste
  Sort_KillList(vEReTree);

  if (vErr = 0) then begin
    Msg(560005,'Eingangsrechnungen',0,0,0);

    // ggf. Zahlungsavis sofort drucken...
    if (Rechte[Rgt_ZAu_Druck_Avis]) and (Set.ZAu.Druck.Avis<>'') then begin
      if (Set.ZAu.Druck.Avis='S') then vErr # 1;
      else
        if (Msg(565004,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes) then vErr # 1;
    end;

    if (vErr=1) then begin
      FOR vItem # cteRead(vZauList,_CteFirst);
      LOOP vItem # cteRead(vZauList,_CteNext, vItem)
      WHILE (vItem>0) do begin
        APPOFF();
        ZAu.Nummer # vItem->spid;
        RecRead(565,1,0);
        Lib_Dokumente:Printform(565,'Zahlungsavis',false);
        APPON();
      END
    end;


    // ggf. Scheck sofort drucken...
    vErr # 0;
    if (Rechte[Rgt_ZAu_Druck_Scheck]) and (Set.ZAu.Druck.Scheck<>'') then begin
      if (Set.ZAu.Druck.Scheck='S') then vErr # 1;
      else
        if (Msg(565005,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes) then vErr # 1;
    end;

    if (vErr=1) then begin
      FOR vItem # cteRead(vZauList,_CteFirst);
      LOOP vItem # cteRead(vZauList,_CteNext, vItem)
      WHILE (vItem>0) do begin
        APPOFF();
        ZAu.Nummer # vItem->spid;
        RecRead(565,1,0);
        Lib_Dokumente:Printform(565,'Scheck',false);
        APPON();
      END
    end;

  end;

  if (vZauList<>0) then begin
    CteClear(vZauList,y);
    CteClose(vZauList);
  end;
/*
debug(cnvai(gMdi));
debug(gMdi->wpname);
debug(cnvai(gZLList));
debug(gzLList->wpname);
*/
//  if (Mode=c_ModeList) then
  Refreshlist(gZLList, _WinLstFromFirst);

end;


//========================================================================
//  EKK_Zuordnen
//
//========================================================================
sub EKK_Zuordnen(aPos : int) : logic;
local begin
  Erx : int;
end;
begin

  if (EKK.EingangsReNr<>0) then RETURN false;

  RecRead(555,1, _RecLock);
  EKK.EingangsReNr    # ERe.Nummer;
  EKK.EingangsrePos   # aPos;
  EKK.Zuordnung.Datum # today;
  EKK.Zuordnung.Zeit  # now;
  EKK.Zuordnung.User  # gUsername;

  // 2023-01-24 AH
  EKK.Lieferant       # ERe.Lieferant;
  EKK.LieferStichwort # ERe.LieferStichwort;

  Erx # Rekreplace(555,_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;
  // Wareneingang?
  if (EKK.Datei=506) then begin
    Erx # RecLink(506,555,2,_RecFirst);
    if (Erx>_rOK) then RecBufClear(506);

    // ggf. Aufpreise aus der Bestellung übernehmen...
    if (Ein.E.Nummer<>0) then begin
      Erx # RecLink(501,506,1,_recFirst);   // Position holen
      if (Erx<>_rOK) then begin
        Erx # RecLink(511,506,11,_recFirst);   // Positionsablage holen
        if (Erx<>_rOK) then RecBufClear(511);
        RecBufCopy(511,501);
      end;

      if (Ein.P.Nummer<>0) then begin
        Erx # RecLink(503,501,7,_recFirst);   // Aufpreise loopen
        WHILE (Erx<=_rLocked) do begin
          // soll explizit ausgegeben werden?
          if (Ein.Z.MatAktionYN) and ("Ein.Z.Schlüssel"<>'') then begin
            RecBufClear(551);
            Vbk.K.Nummer        # ERe.Nummer;
            Vbk.K.EingangsrePos # aPos;
            "Vbk.K.Schlüssel"   # "Ein.Z.Schlüssel";
            Erx # RecRead(551,2,_RecTest);
            // Konto existiert bisher nicht? -> Neu anlegen...
            if (Erx>_rMultikey) then begin
              Vbk.K.Bezeichnung # Ein.Z.Bezeichnung;
              Erx # RekInsert(551,0,'AUTO');
            end;
          end;
          Erx # RecLink(503,501,7,_recNext);
        END;
      end;
    end;

    // Materialeingang?
    if (Ein.E.Materialnr<>0) then begin
      Erx # RecLink(200,506,8,_recFirst);
      if (Erx=_rOK) then begin
        RecRead(200,1,_recLock);
        Mat.EK.RechNr     # ERe.Nummer;
        Mat.EK.RechDatum  # ERe.RechnungsDatum;
        Mat_data:Replace(_RecUnlock,'AUTO');
      end
      else begin
        Erx # RecLink(210,506,9,_recFirst);
        if (Erx=_rOK) then begin
          RecRead(210,1,_recLock);
          "Mat~EK.RechNr"     # ERe.Nummer;
          "Mat~EK.RechDatum"  # ERe.RechnungsDatum;
          Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO');
        end;
      end;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  ExistiertSchon
//
//========================================================================
sub ExistiertSchon() : logic;
local begin
  Erx     : int;
  vRecBuf : int;
  vResult : logic;
  vTmp    : alpha;
end
begin
  if (Set.ERe.PruefRefTyp='I') then RETURN false;

  // Aktuellen Puffer Sichern
  vRecBuf # RecBufCreate(560);
  RecBufCopy(560,vRecBuf);

  vResult # false;

  // Nach Gleicher Rechnungsnummer suchen
  ERe.Rechnungsnr # vRecBuf->ERe.Rechnungsnr;
  vTmp # ERe.Rechnungsnr;

  Erx # RecRead(560,4,0);
  WHILE (Erx < _rNoKey) AND (ERe.Rechnungsnr = vTmp) DO BEGIN

    // Ist auch der Lieferant identisch, dann ist die aktuelle Eingangsrechnung doppelt erfasst
    // MS 12 08 08 und darf nicht die selbe Eingangsrechnungsnummer haben
    if (ERe.Lieferant = vRecBuf->ERe.Lieferant) and (ERe.Nummer <> vRecBuf->ERe.Nummer) then begin
      vResult # true;
      break;
    end;

    Erx # RecRead(560,4,_RecNext);
  END;


  // vorherigen Puffer wieder zurückschreiben
  RecBufCopy(vRecBuf,560);
  RecBufDestroy(vRecBuf);

  // Ergebnis zurückgeben
  RETURN vResult;

end;


//========================================================================
//  _GetMengenAnhandEingang(
//
//========================================================================
sub _GetMengenAnhandEingang(
  var aStk    : int;
  var aGew    : float;
  var aMenge  : float;
  var aMEH    : alpha);
local begin
  Erx   : int;
  v506  : int;
end;
begin
  aStk    # 0;
  aGew    # 0.0;
  aMenge  # 0.0;
  aMEH    # '';
  if (EKK.Materialnummer=0) then RETURN;

  v506 # RecBufCreate(506);
  v506->Ein.E.Materialnr # EKK.Materialnummer;
  Erx # RecRead(v506,2,0);    // WE anhand Mat.nr. lesen
  if (Erx<=_rMultikey) then begin
    aStk    # v506->"Ein.E.Stückzahl";
    aGew    # v506->Ein.E.Gewicht;
    aMenge  # v506->Ein.E.Menge;
    aMEH    # v506->Ein.E.MEH;
  end;
  RecBufDestroy(v506);
  
end;

/**
//========================================================================
//  _GetMengenAnhandBestandsbuch(
//
//========================================================================
sub _GetMengenAnhandBestandsbuch(
  var aStk    : int;
  var aGew    : float;
  var aMenge  : float;
  var aMEH    : alpha);
begin

  aStk    # 0;
  aGew    # 0.0;
  aMenge  # 0.0;
  aMEH    # '';
  Erx # RecLink(200,555,8,_recFirst);
  if (Erx>_rLocked) then begin
    Erx # RecLink(210,555,9,_recFirst);
    if (Erx>_rLocked) then RETURN;
    RecBufCopy(210,200);
  end;

  FOR Erx # RecLink(202, 200, 12, _recFirst); // Bestandsbuch mit einrechnen...
  LOOP Erx # RecLink(202, 200, 12, _recNext);
  WHILE (Erx<=_rLocked) DO BEGIN
    Mat.Bestand.Gew     # Mat.Bestand.Gew - Mat.B.Gewicht;
    Mat.Bestand.Stk     # Mat.Bestand.Stk - "Mat.B.Stückzahl";
    Mat.Bestand.Menge   # Mat.Bestand.Menge - Mat.B.Menge;
//    Mat.EK.Preis        # Mat.EK.Preis - Mat.B.PreisW1;
//    Mat.EK.PreisProMEH  # Mat.EK.PreisProMEH - Mat.B.PreisW1ProMEH;
  END;

  aGew    # Mat.Bestand.Gew;
  aMenge  # Mat.Bestand.Menge;
  aStk    # Mat.Bestand.Stk;
  aMEH    # Mat.MEH;

  RETURN;
end;
**/


//========================================================================
//  RealaKostenVererben
//
//========================================================================
sub RealeKostenVererben() : logic;
local begin
  vGesGew   : float;
  vGesMenge : float;
  vPreis    : float;
  vPreis2   : float;
  vDatei    : int;
  vBuf555   : int;
  vPos      : int;
  vdPreis   : float;
  vdPreisPM : float;
  vStk      : int;
  vGew      : float;
  vMenge    : float;
  vMEH      : alpha;
  vDiffTxt  : int;
  vDiffTxt2 : int;
  vI        : int;
  vA, vB    : alpha;
  vDiff     : float;
  v555      : int;
  vDia      : int;
  vBaPosDic : int;
  vOK       : logic;
  vWertDat  : date;
  vEkkVorher  : float;
  Erx         : int;
  vBasis      : float;
  vBasisPro   : float;
end
begin

  // Konten vorhanden?
  if (RecLinkInfo(551,560,3,_recCount)=0) or (ERe.KontiertBetragW1=0.0) then RETURN true;

  // EKK vorhanden?
  if (RecLinkInfo(555,560,4,_recCount)=0) or (ERe.Kontroll.Gewicht=0.0) then RETURN true;

  Erx # RecLink(550,560,2,_recFirsT); // Verbindlichkeit holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(100,550,4,_recFirsT); // Lieferant holen
  if (Erx>_rLocked) then RecBufClear(100);

  // EKKs loopen
  FOR Erx # RecLink(555,560,4,_recFirst)  // EKKs loopen...
  LOOP Erx # RecLink(555,560,4,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (RecLinkInfo(551,555,10,_recCount)=0) then begin
      Error(560017,'');
      RETURN false;
    end;
  END;


  // 17.03.2017 AH  TRANSON;
  vDiffTxt  # TextOpen(20);   // für BA
  vDiffTxt2 # TextOpen(20);   // für EK

  vWertDat # ERe.WertstellungsDat;

  // EKKs loopen
  FOR Erx # RecLink(555,560,4,_recFirst)  // EKKs loopen...
  LOOP Erx # RecLink(555,560,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // 23.03.2016 AH:
    // Lohnbetriebsauftrag...
    if (EKK.Datei=702) then begin

      // GESAMTGEWICHT der Rechnungspositon etmitteln...
      vGesGew    # 0.0;
      vBuf555 # RekSave(555);
      vPos # EKK.EingangsrePos;
      RecBufClear(555);
      EKK.Eingangsrenr    # ERe.Nummer;
      EKK.EingangsrePos   # vPos;
      EKK.Zuordnung.Datum # today;
      EKK.Zuordnung.Zeit  # now;
      EKK.Zuordnung.User  # gUsername;

      // EKKs loopen und Gesamtgewichte DIESER Position addieren...
      Erx # RecRead(555,2,0);
      WHILE (Erx<=_rMultikey) and (EKK.Eingangsrenr=ERe.Nummer) and (EKK.EingangsrePos=vPos) do begin
        vGesGew   # vGesGew + EKK.Gewicht;
        Erx # RecRead(555,2,_recNext);
      END;
      RekRestore(vBuf555);

//if (Msg(99,'Falsch machen?',_WinIcoQuestion,_WinDialogYesNo,2)=_Winidyes) then begin
//  vGesGew   # EKK.Gewicht;
//end;


      // 02.02.2017 AH : ANTEILSMÄSSIG rechnen, falls mehrere Sammelrechnung
      // GESAMTKOSTEN der Rechnungspos. ermitteln...
      if (RecLinkInfo(551,555,10,_recCount)=0) then begin
        vPreis  # ERe.NettoW1;
        vPreis2 # ERe.Netto;
      end
      else begin
        vPreis  # 0.0;
        vPreis2 # 0.0;
        FOR Erx # RecLink(551,555,10,_recFirst) // Konten loopen
        LOOP Erx # RecLink(551,555,10,_recNext)
        WHILE (Erx<=_rLocked) do begin
          vPreis  # vPreis + VBK.K.BetragW1;
          vPreis2 # vPreis2 + VBK.K.Betrag;
        END;
      end;
      
      // 2023-01-24 AH
      if ("EKK.Währung"<>"Ere.Währung") then begin
        if ("EKK.Währung"=1) then
          vPreis2 # vPreis
        else
          Lib_Berechnungen:Waehrung_Umrechnen(vPreis2, "ERe.Währung", var vPreis2, "EKK.Währung");
      end;

      // EKK korrigieren...
      RecRead(555,1,_RecLock);
      EKK.KorrigiertW1 # vPreis / vGesGew * EKK.Gewicht;
      EKK.Korrigiert   # vPreis2 / vGesGew * EKK.Gewicht;
      RekReplace(555,_recUnlock,'AUTO');

      BAG.Nummer # EKK.ID1;
      Erx # RecRead(700,1,0);         // BAG-Kopf holen
      if (Erx<=_rLocked) then begin
        BAG.P.Nummer    # EKK.ID1;
        BAG.P.Position  # EKK.ID2;
        Erx # RecRead(702,1,0);       // BAG-Position holen
        if (Erx<=_rLocked) then begin
          Erx # RecRead(702,1,_recLock);
          BAG.P.Kosten.Pro # 0.0;
          BAG.P.Kosten.Fix # EKK.Korrigiert;
          RekReplace(702);

          // 24.03.2017 AH:
          BA1_Subs:BuildPosNachfolger(var vBaPosDic);

/***
          v555 # RekSave(555);
          BA1_Subs:ReCalcKosten(n,n, vDiffTxt);
          RekRestore(v555);
          if (Set.ERe.DB_Korrektur) then begin
            vDia # Lib_Progress:Init(Translate('Verbuche Differenzen')+'...',-1);
            erl_data:ParseDiffText(vDiffTxt, false, 'ERE');
            Lib_Progress:Term(vDia);
          end;
          TextClose(vDiffTxt);
***/
        end;
      end;

//      TRANSOFF;
//      RETURN true;
      CYCLE;
    end;    // LOHN


    // 21.02.2022 AH:
    // MatAkt
    if (EKK.Datei=204) or
      ((EKK.Datei=505) and (EKK.Materialnummer<>0)) then begin    // 2023-01-16 AH
      vDatei # Mat_Data:Read(EKK.Materialnummer);
      
      // GESAMTGEWICHT der Rechnungspositon etmitteln...
      vGesGew    # 0.0;
      vBuf555 # RekSave(555);
      vPos # EKK.EingangsrePos;
      RecBufClear(555);
      EKK.Eingangsrenr    # ERe.Nummer;
      EKK.EingangsrePos   # vPos;
      EKK.Zuordnung.Datum # today;
      EKK.Zuordnung.Zeit  # now;
      EKK.Zuordnung.User  # gUsername;

      // EKKs loopen und Gesamtgewichte DIESER Position addieren...
      Erx # RecRead(555,2,0);
      WHILE (Erx<=_rMultikey) and (EKK.Eingangsrenr=ERe.Nummer) and (EKK.EingangsrePos=vPos) do begin
        vGesGew   # vGesGew + EKK.Gewicht;
        Erx # RecRead(555,2,_recNext);
      END;
      RekRestore(vBuf555);

      // GESAMTKOSTEN der Rechnungspos. ermitteln...
      if (RecLinkInfo(551,555,10,_recCount)=0) then begin
        vPreis  # ERe.NettoW1;
        vPreis2 # ERe.Netto;
      end
      else begin
        vPreis  # 0.0;
        vPreis2 # 0.0;
        FOR Erx # RecLink(551,555,10,_recFirst) // Konten loopen
        LOOP Erx # RecLink(551,555,10,_recNext)
        WHILE (Erx<=_rLocked) do begin
          vPreis  # vPreis + VBK.K.BetragW1;
          vPreis2 # vPreis2 + VBK.K.Betrag;
        END;
      end;
//debugx(anum(vPreis,2)+' /'+anum(vGesGew,0)+' * '+anum(EKK.gewicht,0));
      // EKK korrigieren...
      RecRead(555,1,_RecLock);
      if ("EKK.Währung"<>"Ere.Währung") then begin
        if ("EKK.Währung"=1) then
          vPreis2 # vPreis
        else
          Lib_Berechnungen:Waehrung_Umrechnen(vPreis2, "ERe.Währung", var vPreis2, "EKK.Währung");
      end;
      if (vGesGew<>0.0) then begin
        EKK.KorrigiertW1 # vPreis / vGesGew * EKK.Gewicht;
        EKK.Korrigiert   # vPreis2 / vGesGew * EKK.Gewicht;
      end;
      RekReplace(555,_recUnlock,'AUTO');

      RecbufClear(204);
      if ((EKK.Datei=505) and (EKK.Materialnummer<>0)) then begin    // 2023-01-16 AH
        vWertDat # min(EKK.Datum, vWertDat);
        Mat.A.Materialnr  # EKK.Materialnummer;
        Mat.A.Aktionstyp  # c_Akt_Kalk;
        Mat.A.Aktionsnr   # EKK.ID1;
        Mat.A.Aktionspos  # EKK.ID2;
        Mat.A.Aktionspos2 # EKK.ID3;
        Mat.A.Aktionspos3 # EKK.ID4;
        Erx # RecRead(204,4,0);
        if (Erx<=_rMultikey) then begin
          RecRead(204,1,_recLock);
          // 2023-03-15 AH Kalkulationen sind BASISKOSTEN
          vdPreis   # Mat.A.Kosten2W1;
          vdPreisPM # Mat.A.Kosten2W1proMe;
          if (EKK.Gewicht<>0.0) then
            Mat.A.Kosten2W1        # EKK.KorrigiertW1 / EKK.Gewicht * 1000.0;
          Mat.A.Kosten2W1prome  # 0.0;
          if (EKK.Menge<>0.0) then
            Mat.A.Kosten2W1prome  # EKK.KorrigiertW1 / EKK.Menge;
          Erx # RekReplace(204);
          vdPreis   # Mat.A.Kosten2W1 - vdPreis;
          vdPreisPM # Mat.A.Kosten2W1proMe - vdPreisPM;
//debugx('change :'+anum(vdPreis,2));
          if (erx<>_rOK) or (Mat_Data:SetUndVererbeEkPreis(vDatei, vWertDat, Mat.EK.Preis + vdPreis, Mat.EK.PreisProMEH + vdPreisPM, Mat.MEH, vDiffTxt2)=false) then begin
            RETURN false;
          end;
        end;
//debugx(c_akt_kalk+' KEY204 '+aint(erx));
      end
      else begin
        Mat.A.Materialnr  # EKK.ID1;
        Mat.A.Aktion      # EKK.ID2;
        Erx # RecRead(204,1,0);
        if (Erx<=_rMultikey) then begin
          RecRead(204,1,_recLock);
          // 2023-01-16 AH : auch Pro MEH berechnen...
          if (EKK.Gewicht<>0.0) then
            Mat.A.KostenW1        # EKK.KorrigiertW1 / EKK.Gewicht * 1000.0;
          Mat.A.KostenW1promeh  # 0.0;
          if (EKK.Menge<>0.0) then
            Mat.A.KostenW1promeh  # EKK.KorrigiertW1 / EKK.Menge;
          RekReplace(204);
        end;
        if (vDatei=200) then begin
          if (Mat_A_Data:Vererben()) then begin
          end
        end
        else begin
          if (Mat_A_Abl_Data:Abl_Vererben()) then begin
          end
        end;
      end;

      CYCLE;
    end;    // MatAkt


    // ab hier NUR für WE-Material
    if (EKK.Datei<>506) or (EKK.Materialnummer=0) then CYCLE;

    vWertDat # min(EKK.Datum, vWertDat);

    // GESAMTGEWICHT der Rechnungspositon etmitteln...
    vGesGew    # 0.0;
    vGesMenge  # 0.0;
    vBuf555 # RekSave(555);
    vPos # EKK.EingangsrePos;
    RecBufClear(555);
    EKK.Eingangsrenr    # ERe.Nummer;
    EKK.EingangsrePos   # vPos;
    EKK.Zuordnung.Datum # today;
    EKK.Zuordnung.Zeit  # now;
    EKK.Zuordnung.User  # gUsername;

    // EKKs loopen und Gesamtgewichte DIESER Position addieren...
    Erx # RecRead(555,2,0);
    WHILE (Erx<=_rMultikey) and (EKK.Eingangsrenr=ERe.Nummer) and (EKK.EingangsrePos=vPos) do begin
//      if (EKK.Materialnummer<>0) then _GetMengenAnhandBestandsbuch(var vStk, var vGew, var vMenge, var vMEH);
      if (EKK.Materialnummer<>0) then _GetMengenAnhandEingang(var vStk, var vGew, var vMenge, var vMEH);
      vGesGew   # vGesGew + vGew;//EKK.Gewicht;
      vGesMenge # vGesMenge + vMenge;//EKK.Menge;
      Erx # RecRead(555,2,_recNext);
    END;
    RekRestore(vBuf555);
//debugx('gesamt '+anum(vGesGew,0)+'kg laut EKK');
    // keine Mengen? -> nächste EKK
    if (vGesMenge=0.0) and (vGesGew=0.0) then CYCLE;


//    _GetMengenAnhandBestandsbuch(var vStk, var vGew, var vMenge, var vMEH);
    _GetMengenAnhandEingang(var vStk, var vGew, var vMenge, var vMEH);
    // Material holen...
    vDatei # 200;
    Erx # RecLink(200,555,8,_recFirst);
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,555,9,_recFirst);
      if (Erx>_rLocked) then begin
//        TRANSBRK;
        RETURN false;
      end;
      RecBufCopy(210,200);
      vDatei # 210;
    end;

//debugx('KEY200 '+anum(vGew,0)+'kg laut WE');
    // 2023-03-27 AH MEH korregieren:
    if (Mat.MEH=vMEH) then begin
    end
    else if (Mat.MEH='kg') then begin
      vMenge  # vGew;
      vMEH    # Mat.MEH;
    end
    else if (Mat.MEH='t') then begin
      vMenge  # vGew / 1000.0;
      vMEH    # Mat.MEH;
    end
    else if (Mat.MEH='Stk') then begin
      vMenge  # cnvfi(vStk);
      vMEH    # Mat.MEH;
    end
    else begin
      vMenge # Lib_Einheiten:WandleMEH(200, vStk, vGew, vMenge, vMEH, Mat.MEH);
      vMEH    # Mat.MEH;
    end;


    // bisherige Aufpreis-Aktionen löschen...
    Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Mat.A.Aktionstyp=c_Akt_Aufpreis) or (Mat.A.Aktionstyp=c_Akt_ERAP) then begin
        Erx # RekDelete(204,0,'AUTO');
        if (erx<>_rOK) then begin
//          TRANSBRK;
          RETURN false;
        end;
        Erx # RecLink(204,200,14,_recFirst);
        CYCLE;
      end;

      Erx # RecLink(204,200,14,_recNext);
    END;



    // GESAMTKOSTEN der Rechnungspos. ermitteln...
    if (RecLinkInfo(551,555,10,_recCount)=0) then begin
      vPreis  # ERe.NettoW1;
      vPreis2 # ERe.Netto;
    end
    else begin
      vPreis  # 0.0;
      vPreis2 # 0.0;
      FOR Erx # RecLink(551,555,10,_recFirst) // Konten loopen
      LOOP Erx # RecLink(551,555,10,_recNext)
      WHILE (Erx<=_rLocked) do begin

// 2023-05-19 AH
//        vPreis  # vPreis + VBK.K.BetragW1;
//        vPreis2 # vPreis2 + VBK.K.Betrag;

// 06.06.2019 AH: Sicherer so:
//        if ("Vbk.K.Schlüssel"<>'') then begin
        if (StrCut("Vbk.K.Schlüssel",1,1)='#') and (StrCut("Vbk.K.Schlüssel",5,1)='.') and (StrCut("Vbk.K.Schlüssel",9,1)='.') then begin
          RecBufClear(204);
          Mat.A.Aktionstyp    # c_Akt_ERAP;
          Mat.A.Aktionsnr     # Vbk.K.Nummer;
          Mat.A.Aktionspos    # Vbk.K.EingangsRepos;
          Mat.A.Aktionspos2   # 0;
          Mat.A.Aktionspos3   # 0;
          Mat.A.Aktionsmat    # Mat.Nummer;
          Mat.A.Aktionsdatum  # Mat.Eingangsdatum;
          if (Mat.A.Aktionsdatum=0.0.0) then
            Mat.A.Aktionsdatum  # Mat.Datum.Erzeugt;
          Mat.A.Adressnr      # Adr.Nummer;
          Mat.A.Bemerkung     # StrCut(VbK.K.Bezeichnung,1,32);

          if (vGew<>0.0) and (vGesGew<>0.0) then
            Mat.A.Kosten2W1 # Rnd(VbK.K.BetragW1 / vGesGew * 1000.0,2)

          if (vMenge<>0.0) and (vGesMenge<>0.0) then
            Mat.A.Kosten2W1ProME # Rnd(VbK.K.BetragW1 / vGesMenge,2)
          Mat_A_Data:Insert(0,'AUTO');
        end
        else begin
          // 2023-05-19 AH  Aufpreise werden nicht doppelt gerechnet  Proj. 2478/35
          vPreis  # vPreis + VBK.K.BetragW1;
          vPreis2 # vPreis2 + VBK.K.Betrag;
        end;

        // 2022-08-08 AH
        if (RunAFX('ERe.Data.RealKosten.Vbk.K.Loop',anum(vGesGew,2))<>0) then begin
          if (AfxRes=_rDeadlock) then RETURN false;
        end;

      END;
//debugx('Preis '+anum(vPreis,2)+'EUR laut Kontierung');
    end;

    vEkkVorher # EKK.PreisW1;
    if (EKK.KorrigiertW1<>0.0) then vEkkVorher # EKK.KorrigiertW1;

  // 2023-01-24 AH
    if ("EKK.Währung"<>"Ere.Währung") then begin
      if ("EKK.Währung"=1) then
        vPreis2 # vPreis
      else
        Lib_Berechnungen:Waehrung_Umrechnen(vPreis2, "ERe.Währung", var vPreis2, "EKK.Währung");
    end;


// EKK korrigieren...
   if (vGesGew<>0.0) then begin
     RecRead(555,1,_RecLock);
     EKK.KorrigiertW1 # vPreis / vGesGew * vGew;//EKK.Gewicht;
//debugx('Korrektur = '+anum(EKK.KorrigiertW1,2)+'EUR');
      EKK.Korrigiert   # vPreis2 / vGesGew * vGew;//EKK.Gewicht;
    //Wae_Umrechnen(vPreis, 1, var EKK.Korrigiertt; varaWert2 : float; aWae2 : int) : logic;
      RekReplace(555,_recUnlock,'AUTO');
  end;
  
//vDiff   # EKK.KorrigiertW1 - EKK.PreisW1; 30.07.2019
    vDiff # EKK.KorrigiertW1 - vEkkVorher;
    if (vDiff=0.0) then CYCLE;
//debugx('diff:'+anum(vDiff,2));
    // MatPreis errechnen
    DivOrNull(vdPreis, EKK.KorrigiertW1, vGew * 1000.0, 2);
    DivOrNull(vdPreisPM, EKK.KorrigiertW1, vMenge, 2);
    // 2023-03-15 AH
    if (Set.Installname<>'VBS') then begin
      Mat_Data:GetBasisKosten(vDatei, var vBasis, var vBasisPro);
      vdPreis   # vdPreis + vBasis;
      vdPreisPM # vdPreisPM + vBasisPro;
    end;
    if (Mat_Data:SetUndVererbeEkPreis(vDatei, vWertDat, vdPreis, vdPreisPM, Mat.MEH, vDiffTxt2)=false) then begin
//      TRANSBRK;
      RETURN false;
    end;

    // 03.05.2017 AH: NEIN !!!
    // 28.04.2017 nur DELTA protokollieren:
    //DivOrNull(vdPreis, vDiff, vGew * 1000.0, 2);
    //DivOrNull(vdPreisPM, vDiff, vMenge, 2);
    //Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);

/****
    // Gesamtpreis in Material schreiben...
    if (vDatei=200) then begin
      RecRead(200,1,_recLock);
      vdPreis   # Mat.EK.Preis;
      vdPreisPM # Mat.EK.PreisProMEH;
//todo('Preis:'+anum(vPreis,2)+' Menge:'+anum(vMenge,2));
      DivOrNull(Mat.EK.Preis, vPreis, vGesGew * 1000.0,2);
      DivOrNull(Mat.EK.PreisProMEH, vPreis, vMenge,2);
      vDiff # Rnd((Mat.EK.Preis * Mat.Bestand.Gew / 1000.0) - (vdPreis * Mat.Bestand.Gew / 1000.0),2)
      if (vDiffTxt2<>0) and (vDiff<>0.0) and (Mat.VK.RechNr<>0) then begin
        TextAddLine(vDiffTxt2, aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr));
      end;
//      vdPreis   # Mat.EK.Preis - vdPreis;
//      vdPreisPM # Mat.EK.PreisProMEH - vdPreisPM;
      Erx # Mat_Data:Replace(_RecUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
//      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), today, 'ERE', ERe.Nummer, 0,0,0, y);
      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);
    end
    else begin
todo('ABLAGE');
      RecRead(210,1,_recLock);
      vdPreis   # "Mat~EK.Preis";
      vdPreisPM # "Mat~EK.PreisProMEH";
      DivOrNull("Mat~EK.Preis", vPreis, vGesGew * 1000.0,2);
      DivOrNull("Mat~EK.PreisProMEH", vPreis, vGesMenge,2);
      vDiff # Rnd((Mat.EK.Preis * "Mat~Bestand.Gew" / 1000.0) - (vdPreis * "Mat~Bestand.Gew" / 1000.0),2)
      if (vDiffTxt2<>0) and (vDiff<>0.0) and ("Mat~VK.RechNr"<>0) then begin
        TextAddLine(vDiffTxt2, aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));
      end;
      vdPreis   # "Mat~EK.Preis" - vdPreis;
      vdPreisPM # "Mat~EK.PreisProMEH" - vdPreisPM;
      Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
//      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), today, 'ERE', ERe.Nummer, 0,0,0, y);
Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);
    end;

    // 20.08.2013 AH
    if (Mat_A_Data:Vererben('EKPREIS', vDatei, vDiffTxt2)=false) then begin
      TRANSBRK;
      RETURN false;
    end;
***/



  END;  // EKKs loopen

  // 24.03.2017 AH KORREKTURBUCHUNGEN ---------------------------------------
  if (vBaPosDic<>0) then begin
    vOK # BA1_Subs:ReCalcKosten(n,n, vDiffTxt, vBaPosDic);
    Lib_Dict:Close(var vBaPosDic);
    if (vOK=false) then begin
      TextClose(vDiffTxt);
      TextClose(vDiffTxt2);
      RETURN false;
    end;
  end;

  if (Set.ERe.DB_Korrektur) then begin
    vDia # Lib_Progress:Init(Translate('Verbuche Differenzen')+'...',-1);
    Erl_data:ParseDiffText(vDiffTxt, false, 'ERE');
    Erl_data:ParseDiffText(vDiffTxt2, true, 'ERE');
    Lib_Progress:Term(vDia);
  end;
  TextClose(vDiffTxt);
  TextClose(vDiffTxt2);


//  TRANSOFF;

  RETURN true;

end;


//========================================================================
//  RealaKostenVererbenMatAkt
//      21.12.2021 AH: 2190/179
//========================================================================
sub TODO_RealeKostenVererbenMatAkt() : logic;
local begin
  vGesGew   : float;
  vGesMenge : float;
  vPreis    : float;
  vPreis2   : float;
  vDatei    : int;
  vBuf555   : int;
  vPos      : int;
  vdPreis   : float;
  vdPreisPM : float;
  vStk      : int;
  vGew      : float;
  vMenge    : float;
  vMEH      : alpha;
  vDiffTxt  : int;
  vDiffTxt2 : int;
  vI        : int;
  vA, vB    : alpha;
  vDiff     : float;
  v555      : int;
  vDia      : int;
  vBaPosDic : int;
  vOK       : logic;
  vWertDat  : date;
  vEkkVorher  : float;
  Erx         : int;
end
begin

  // Konten vorhanden?
  if (RecLinkInfo(551,560,3,_recCount)=0) or (ERe.KontiertBetragW1=0.0) then RETURN true;

  // MatAkt vorhanden?
  if (RecLinkInfo(204,560,10,_recCount)=0) then RETURN true;

  Erx # RecLink(550,560,2,_recFirsT); // Verbindlichkeit holen
  if (Erx>_rLocked) then RETURN false;

  Erx # RecLink(100,550,4,_recFirsT); // Lieferant holen
  if (Erx>_rLocked) then RecBufClear(100);

  // MatAkts loopen
  FOR Erx # RecLink(204,560,10,_recFirst)  // MatAkts loopen...
  LOOP Erx # RecLink(204,560,10,_recNext)
  WHILE (Erx<=_rLocked) do begin
    RecBufClear(551);
    Vbk.K.Nummer        # Mat.A.EK.Rechnr;
    Vbk.K.EingangsrePos # Mat.A.Aktionspos;
    Erx # RecRead(551,2,0);
    if (Erx>_rMultikey) then begin
      Error(560017,'');
      RETURN false;
    end;
  END;

  vDiffTxt  # TextOpen(20);   // für BA
  vDiffTxt2 # TextOpen(20);   // für EK

  vWertDat # ERe.WertstellungsDat;

  // MatAkts loopen
  FOR Erx # RecLink(204,560,10,_recFirst)  // MatAkts loopen...
  LOOP Erx # RecLink(204,560,10,_recNext)
  WHILE (Erx<=_rLocked) do begin
    // GESAMTGEWICHT der Rechnungspositon etmitteln...
    vGesGew    # 0.0;
    vGesMenge  # 0.0;
    vBuf555 # RekSave(555);
    vPos # EKK.EingangsrePos;
    RecBufClear(555);
    EKK.Eingangsrenr    # ERe.Nummer;
    EKK.EingangsrePos   # vPos;
    EKK.Zuordnung.Datum # today;
    EKK.Zuordnung.Zeit  # now;
    EKK.Zuordnung.User  # gUsername;

    // EKKs loopen und Gesamtgewichte DIESER Position addieren...
    Erx # RecRead(555,2,0);
    WHILE (Erx<=_rMultikey) and (EKK.Eingangsrenr=ERe.Nummer) and (EKK.EingangsrePos=vPos) do begin
//      if (EKK.Materialnummer<>0) then _GetMengenAnhandBestandsbuch(var vStk, var vGew, var vMenge, var vMEH);
      if (EKK.Materialnummer<>0) then _GetMengenAnhandEingang(var vStk, var vGew, var vMenge, var vMEH);
      vGesGew   # vGesGew + vGew;//EKK.Gewicht;
      vGesMenge # vGesMenge + vMenge;//EKK.Menge;
      Erx # RecRead(555,2,_recNext);
    END;
    RekRestore(vBuf555);
//debugx('gesamt '+anum(vGesGew,0)+'kg laut EKK');
    // keine Mengen? -> nächste EKK
    if (vGesMenge=0.0) and (vGesGew=0.0) then CYCLE;


//    _GetMengenAnhandBestandsbuch(var vStk, var vGew, var vMenge, var vMEH);
    _GetMengenAnhandEingang(var vStk, var vGew, var vMenge, var vMEH);
    // Material holen...
    vDatei # 200;
    Erx # RecLink(200,555,8,_recFirst);
    if (Erx>_rLocked) then begin
      Erx # RecLink(210,555,9,_recFirst);
      if (Erx>_rLocked) then begin
//        TRANSBRK;
        RETURN false;
      end;
      RecBufCopy(210,200);
      vDatei # 210;
    end;

//debugx('KEY200 '+anum(vGew,0)+'kg laut WE');

    // bisherige Aufpreis-Aktionen löschen...
    Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Mat.A.Aktionstyp=c_Akt_Aufpreis) or (Mat.A.Aktionstyp=c_Akt_ERAP) then begin
        Erx # RekDelete(204,0,'AUTO');
        if (erx<>_rOK) then begin
//          TRANSBRK;
          RETURN false;
        end;
        Erx # RecLink(204,200,14,_recFirst);
        CYCLE;
      end;

      Erx # RecLink(204,200,14,_recNext);
    END;



    // GESAMTKOSTEN der Rechnungspos. ermitteln...
    if (RecLinkInfo(551,555,10,_recCount)=0) then begin
      vPreis  # ERe.NettoW1;
      vPreis2 # ERe.Netto;
    end
    else begin
      vPreis  # 0.0;
      vPreis2 # 0.0;
      FOR Erx # RecLink(551,555,10,_recFirst) // Konten loopen
      LOOP Erx # RecLink(551,555,10,_recNext)
      WHILE (Erx<=_rLocked) do begin

        vPreis  # vPreis + VBK.K.BetragW1;
        vPreis2 # vPreis2 + VBK.K.Betrag;

// 06.06.2019 AH: Sicherer so:
//        if ("Vbk.K.Schlüssel"<>'') then begin
        if (StrCut("Vbk.K.Schlüssel",1,1)='#') and (StrCut("Vbk.K.Schlüssel",5,1)='.') and (StrCut("Vbk.K.Schlüssel",9,1)='.') then begin
          RecBufClear(204);
          Mat.A.Aktionstyp    # c_Akt_ERAP;
          Mat.A.Aktionsnr     # Vbk.K.Nummer;
          Mat.A.Aktionspos    # Vbk.K.EingangsRepos;
          Mat.A.Aktionspos2   # 0;
          Mat.A.Aktionspos3   # 0;
          Mat.A.Aktionsmat    # Mat.Nummer;
          Mat.A.Aktionsdatum  # Mat.Eingangsdatum;
          if (Mat.A.Aktionsdatum=0.0.0) then
            Mat.A.Aktionsdatum  # Mat.Datum.Erzeugt;
          Mat.A.Adressnr      # Adr.Nummer;
          Mat.A.Bemerkung     # StrCut(VbK.K.Bezeichnung,1,32);

          if (vGew<>0.0) and (vGesGew<>0.0) then
            Mat.A.Kosten2W1 # Rnd(VbK.K.BetragW1 / vGesGew * 1000.0,2)

          if (vMenge<>0.0) and (vGesMenge<>0.0) then
            Mat.A.Kosten2W1ProME # Rnd(VbK.K.BetragW1 / vGesMenge,2)
          Mat_A_Data:Insert(0,'AUTO');
        end;

      END;
//debugx('Preis '+anum(vPreis,2)+'EUR laut Kontierung');
    end;

    vEkkVorher # EKK.PreisW1;
    if (EKK.KorrigiertW1<>0.0) then vEkkVorher # EKK.KorrigiertW1;

// EKK korrigieren...
    RecRead(555,1,_RecLock);
    EKK.KorrigiertW1 # vPreis / vGesGew * vGew;//EKK.Gewicht;
//debugx('Korrektur = '+anum(EKK.KorrigiertW1,2)+'EUR');
    EKK.Korrigiert   # vPreis2 / vGesGew * vGew;//EKK.Gewicht;
    //Wae_Umrechnen(vPreis, 1, var EKK.Korrigiertt; varaWert2 : float; aWae2 : int) : logic;
    RekReplace(555,_recUnlock,'AUTO');

//vDiff   # EKK.KorrigiertW1 - EKK.PreisW1; 30.07.2019
    vDiff # EKK.KorrigiertW1 - vEkkVorher;
    if (vDiff=0.0) then CYCLE;
    
//DivOrNull(vdPreis, vDiff, vGew, 2);
//DivOrNull(vdPreisPM, vDiff, vMenge, 2);
DivOrNull(vdPreis, EKK.KorrigiertW1, vGew * 1000.0, 2);
DivOrNull(vdPreisPM, EKK.KorrigiertW1, vMenge, 2);
//if (vdPreis=0.0) and (vdPreisPM=0.0) then CYCLE;

    if (Mat_Data:SetUndVererbeEkPreis(vDatei, vWertDat, vdPreis, vdPreisPM, Mat.MEH, vDiffTxt2)=false) then begin
//      TRANSBRK;
      RETURN false;
    end;

    // 03.05.2017 AH: NEIN !!!
    // 28.04.2017 nur DELTA protokollieren:
    //DivOrNull(vdPreis, vDiff, vGew * 1000.0, 2);
    //DivOrNull(vdPreisPM, vDiff, vMenge, 2);
    //Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);

/****
    // Gesamtpreis in Material schreiben...
    if (vDatei=200) then begin
      RecRead(200,1,_recLock);
      vdPreis   # Mat.EK.Preis;
      vdPreisPM # Mat.EK.PreisProMEH;
//todo('Preis:'+anum(vPreis,2)+' Menge:'+anum(vMenge,2));
      DivOrNull(Mat.EK.Preis, vPreis, vGesGew * 1000.0,2);
      DivOrNull(Mat.EK.PreisProMEH, vPreis, vMenge,2);
      vDiff # Rnd((Mat.EK.Preis * Mat.Bestand.Gew / 1000.0) - (vdPreis * Mat.Bestand.Gew / 1000.0),2)
      if (vDiffTxt2<>0) and (vDiff<>0.0) and (Mat.VK.RechNr<>0) then begin
        TextAddLine(vDiffTxt2, aint(Mat.Nummer)+'|'+anum(vDiff,2)+'|'+aint(Mat.VK.RechNr));
      end;
//      vdPreis   # Mat.EK.Preis - vdPreis;
//      vdPreisPM # Mat.EK.PreisProMEH - vdPreisPM;
      Erx # Mat_Data:Replace(_RecUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
//      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), today, 'ERE', ERe.Nummer, 0,0,0, y);
      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);
    end
    else begin
todo('ABLAGE');
      RecRead(210,1,_recLock);
      vdPreis   # "Mat~EK.Preis";
      vdPreisPM # "Mat~EK.PreisProMEH";
      DivOrNull("Mat~EK.Preis", vPreis, vGesGew * 1000.0,2);
      DivOrNull("Mat~EK.PreisProMEH", vPreis, vGesMenge,2);
      vDiff # Rnd((Mat.EK.Preis * "Mat~Bestand.Gew" / 1000.0) - (vdPreis * "Mat~Bestand.Gew" / 1000.0),2)
      if (vDiffTxt2<>0) and (vDiff<>0.0) and ("Mat~VK.RechNr"<>0) then begin
        TextAddLine(vDiffTxt2, aint("Mat~Nummer")+'|'+anum(vDiff,2)+'|'+aint("Mat~VK.RechNr"));
      end;
      vdPreis   # "Mat~EK.Preis" - vdPreis;
      vdPreisPM # "Mat~EK.PreisProMEH" - vdPreisPM;
      Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
//      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), today, 'ERE', ERe.Nummer, 0,0,0, y);
Mat_Data:Bestandsbuch(0, 0.0, 0.0, vdPreis, vdPreisPM, Translate('Eingangsrechnung'), ERe.WertstellungsDat, 'ERE', ERe.Nummer, 0,0,0, y);
    end;

    // 20.08.2013 AH
    if (Mat_A_Data:Vererben('EKPREIS', vDatei, vDiffTxt2)=false) then begin
      TRANSBRK;
      RETURN false;
    end;
***/



  END;  // EKKs loopen

  // 24.03.2017 AH KORREKTURBUCHUNGEN ---------------------------------------
  if (vBaPosDic<>0) then begin
    vOK # BA1_Subs:ReCalcKosten(n,n, vDiffTxt, vBaPosDic);
    Lib_Dict:Close(var vBaPosDic);
    if (vOK=false) then begin
      TextClose(vDiffTxt);
      TextClose(vDiffTxt2);
      RETURN false;
    end;
  end;

  if (Set.ERe.DB_Korrektur) then begin
    vDia # Lib_Progress:Init(Translate('Verbuche Differenzen')+'...',-1);
    Erl_data:ParseDiffText(vDiffTxt, false, 'ERE');
    Erl_data:ParseDiffText(vDiffTxt2, true, 'ERE');
    Lib_Progress:Term(vDia);
  end;
  TextClose(vDiffTxt);
  TextClose(vDiffTxt2);


//  TRANSOFF;

  RETURN true;

end;


//========================================================================
//  MatKosten
//========================================================================
Sub MatKosten(
  aEreNr  : int;
  aWert   : float;
  aDat    : date;
  aNeu    : logic) : logic;
local begin
  vDatei    : int;
  vDiffTxt  : int;
  vOK       : logic;
  vSumKG    : float;
  vToPreis  : float;
  Erx       : int;
end;
begin

  // bei Lieferantenvorgängen, werden die Kosten über die MATZ im Auftrag bei FAKTURA gerechnet !!!
  if (Ere.Rechnungstyp=c_Erl_Gut) or
    (Ere.Rechnungstyp=c_Erl_StornoGut) or
    (Ere.Rechnungstyp=c_Erl_Bel_LF) or
    (Ere.Rechnungstyp=c_Erl_StornoBel_LF) then RETURN true;
  // hier also eigentlich nur "normale" Eingangsrechnungen über SOnderkosten (also z.B. keine Wareneingang. der schon über EKK läuft)


  // Von Verbindlichkeiten ausgheen...
  Vbk.Nummer # Ere.Nummer;


  // Gesamtgewicht summieren...
  FOR Erx # RecLink(204,550,7, _RecFirst)   // Mataktionen loopen
  LOOP Erx # RecLink(204,550,7, _RecNext);
  WHILE (Erx<=_rLocked) do begin
//proto('addiere Mat.Aktion : KEY204')
    vSumKG # vSumKG + Mat_B_Data:GewichtZumDatum(Mat.A.Materialnr, aDat);
  END;
//Proto(cnvad(aDat)+' sumkg:'+anum(vSumKg,0));

  if (vSumKG=0.0) then begin
//Proto('PANIK : KEIN GEWICHT !!!');
    RETURN true;
  end;
  vToPreis # Rnd(aWert / vSumKg * 1000.0,2);
  if (vToPreis=0.0) then begin
//Proto('PANIK : KEIN TONNEPREIS !!!');
    RETURN true;
  end;

  // Verbuchen....
  TRANSON;

  vDiffTxt # TextOpen(20);

  FOR Erx # RecLink(204,550,7, _RecFirst)   // Mataktionen loopen
  LOOP Erx # RecLink(204,550,7, _RecNext);
  WHILE (Erx<=_rLocked) do begin
    vDatei # Mat_Data:Read(Mat.A.Materialnr)
    if (vDatei<200) then begin
      TextClose(vDiffTxt);
      TRANSBRK;
      RETURN false;
    end;

    RecRead(204,1,_recLock);
    if (aNeu) then
      Mat.A.KostenW1      # vToPreis
    else
      Mat.A.KostenW1      # 0.0;
    Mat.A.Aktionsdatum    # aDat;
    RekReplace(204)

    if (vDatei=200) then
      vOK # Mat_A_Data:Vererben('', 200, vDiffTxt)
    else
      vOK # Mat_A_Data:Vererben('', 210, vDiffTxt);
    if (vOK=false) then begin
      TextClose(vDiffTxt);
      TRANSOFF;
      RETURN false;
    end;

  END;

//TextWrite(vDiffTxt, 'E:\debug \debug.txt', _TextExtern);
  Erl_Data:ParseDiffText(vDiffTxt, FALSE, 'GUBE');   // NICHT als EK, sondern Kosten

  TextClose(vDiffTxt);

  TRANSOFF;

  RETURN true;
end;


//========================================================================
// Call ERe_Data:FixSammelLohnRechnung
//========================================================================
Sub FixSammelLohnRechnung()
local begin
  vTyp  : int;
  Erx   : int;
end;
begin

  TRANSON;

  FOR Erx # Recread(560,1,_RecFirst)
  LOOP Erx # Recread(560,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (Ere.InOrdnung=false) then CYCLE;

    if (RecLinkInfo(555,560,4,_recCount)<=1) then CYCLE;
debugx('Repariere KEY560');

    vTyp # 0;
    // EKKs loopen
    FOR Erx # RecLink(555,560,4,_recFirst)  // EKKs loopen...
    LOOP Erx # RecLink(555,560,4,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (vTyp=0) then vTyp # EKK.Datei
      else if (vTyp<>EKK.Datei) then begin
        TRANSBRK;
        Msg(99,'MISCHUNG VON LOHN UND MATERIAL IN '+aint(Ere.Nummer),0,0,0);
        RETURN;
      end;

      if (EKK.Datei=702) then begin
        if (EKK.EingangsrePos<>1) then begin
debugx('fixe Posnr. in KEY555');
          RecRead(555,1,_recLock);
          EKK.EingangsrePos # 1;
          RekReplace(555);
        end;
      end;
    END;

    // Lohnbetriebsauftrag...
    if (vTyp=702) then begin
      if (ERe_Data:RealeKostenVererben()=false) then begin
        TRANSBRK; // 17.11.2016
        ErrorOutput;
        Msg(99,aint(Ere.Nummer),0,0,0);
        RETURN;
      end;
    end;

  END;

  TRANSOFF;

  Msg(999998,'',0,0,0);

end;



/*========================================================================
2023-03-27  AH
  call ERE_data:FixRealeKosten
========================================================================*/
sub FixRealeKosten()
local begin
  Erx : int;
end;
begin
  TRANSON;
  
  // EREs loopen
  FOR Erx # RecRead(560,1,_recFirst)
  LOOP Erx # RecRead(560,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (ERe.InOrdnung=false) then CYCLE;

    Erx # RecLink(555,560,4,_recFirst)  // EKKs loopen...
    if (Erx>_rLocked) then CYCLE;
    
    if (EKK.Materialnummer=0) then CYCLE;
//debugx('KEY560');
    if (ERe_Data:RealeKostenVererben()=false) then begin
      TRANSBRK;
      ErrorOutput;
      Msg(560011,'',0,0,0);
      RETURN;
    end;

  END;
    
  TRANSOFF;

  Msg(999998,'',0,0,0);
  
end;

//========================================================================