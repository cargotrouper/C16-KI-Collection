@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_J_WE_Main
//                  OHNE E_R_G
//  Info
//
//
//  29.03.2005  AI  Erstellung der Prozedur
//  21.06.2012  AI  Vorbelegung ggf. mit Lageranschrift 99
//  16.10.2013  AH  Anfragenx
//  24.06.2014  AH  Fix: automatische Bestellung wird sofort gelöscht
//  01.08.2014  ST  RecSave: Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB BerechneAus(aTyp : alpha);
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusPreis()
//    SUB AusLieferant()
//    SUB AusLageradresse()
//    SUB AusLageranschrift()
//    SUB AusLagerplatz()
//    SUB AusZustand()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Wareneingang'
  cFile :     506
//  cMenuName : 'Art.J.WE.Bearbeiten'
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Art_J_WE'
  cZList :    0
  cKey :      1
end;

declare RefreshMode(opt aNoRefresh : logic);

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  RecBufClear(500);
  RecBufClear(501);
  RecBufClear(506);


//  Lib_GuiCom:AuswahlEnable($edWE.Lieferant);
  SetStdAusFeld('edWE.Lieferant'          ,'Lieferant');
  SetStdAusFeld('edEin.E.Lageradresse'    ,'Lageradresse');
  SetStdAusFeld('edEin.E.Lageranschrift'  ,'Lageranschrift');
  SetStdAusFeld('edEin.E.Lagerplatz'      ,'Lagerplatz');
  SetStdAusFeld('edEin.E.Art.Zustand'     ,'Zustand');
  SetStdAusFeld('edWE.MEH'                ,'MEH');
  SetStdAusFeld('edWE.Preis'              ,'Preis');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
// BerechneAus
//
//========================================================================
sub BerechneAus(aTyp : alpha);
begin

  if (aTyp='ABM') or (aTyp='STK') then begin
    if (Art.MEH='kg') and ("Art.GewichtProm"<>0.0) and ("Ein.E.Länge"<>0.0) and ("Ein.E.Stückzahl"<>0) then begin
      Ein.E.Gewicht # "Ein.E.Länge" * "Art.GewichtProm" / 1000.0 * cnvfi("Ein.E.Stückzahl");
    end;

    if (Art.MEH='Stk') and ("Art.GewichtProStk"<>0.0) and ("Ein.E.Stückzahl"<>0) then begin
      Ein.E.GEwicht # "Art.GewichtProStk" * cnvfi("Ein.E.Stückzahl");
    end;

    if (Art.MEH='m') and ("Ein.E.Länge"<>0.0) and ("Ein.E.Stückzahl"<>0) then begin
      Ein.E.Menge # "Ein.E.Länge" * cnvfi("Ein.E.Stückzahl") / 1000.0;
      if (Ein.E.Gewicht=0.0) and ("Art.GewichtProm"<>0.0) then begin
        Ein.E.Gewicht # "Ein.E.Länge" * "Art.GewichtProm" / 1000.0 * cnvfi("Ein.E.Stückzahl");
      end;
    end;
  end;

  if (aTyp='MENGE') then begin
    if (Art.MEH='m') and ("Ein.E.Länge"<>0.0) and ("Ein.E.Stückzahl"=0) then begin
      "Ein.E.Stückzahl" # cnvif(Ein.E.Menge*1000.0 / "Ein.E.Länge");
    end;
    if (Art.MEH='m') and (Ein.E.Gewicht=0.0) and ("Art.GewichtProm"<>0.0) then begin
      Ein.E.Gewicht # (Ein.E.Menge * "Art.GewichtProm");
    end;
  end;

  if (aTyp='KG') then begin
    if (Art.MEH='m') or (Art.MEH='Stk') then begin
      if ("Art.GewichtProm"<>0.0) and ("Ein.E.Länge"<>0.0) and ("Ein.E.Stückzahl"=0) then begin
        "Ein.E.Stückzahl" # cnvif(Ein.E.Gewicht / "Art.GewichtProm" / "Ein.E.Länge");
        end
      else if ("Art.GewichtProm"<>0.0) and ("Ein.E.Stückzahl"<>0) then begin
          Ein.E.Menge # Ein.E.Gewicht / "Art.GewichtProm";
        end;
    end;

    if (Art.MEH='Stk') then begin
      if ("Art.GewichtProStk"<>0.0) and (Ein.E.Gewicht<>0.0) then begin
        "Ein.E.Stückzahl" # cnvif(Ein.E.Gewicht / "Art.GewichtProStk");
      end;
    end;

  end;

  if (Art.MEH='Stk') then Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  if (Art.MEH='kg') then Ein.E.Menge # Ein.E.Gewicht;
  if (Art.MEH='t') then Ein.E.Menge # Rnd(Ein.E.Gewicht / 1000.0, Set.Stellen.Gewicht);
  $edEin.E.Menge->winupdate(_WinUpdFld2Obj);

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edWE.Lieferant);
  Lib_GuiCom:Pflichtfeld($edEin.E.Menge);
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageradresse);
  Lib_GuiCom:Pflichtfeld($edEin.E.Lageranschrift);
  Lib_GuiCom:Pflichtfeld($edEin.E.Eingang_Datum);

  if (StrCnv(Ein.E.MEH,_Strupper)<>'STK') and (strCnv(Ein.E.MEH,_Strupper)<>'KG') or
    (StrCnv(Ein.E.MEH,_Strupper)<>'T') then
    Lib_GuiCom:Pflichtfeld($edEin.E.Menge);

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx   : int;
  vHdl  : int;
end;
begin

  if (aName='') or (aName='edWE.Lieferant') then begin
    Erx # RecLink(100,506,3,_recFirst);   // Lieferant holen,
    if (Erx<=_rLocked) and (Ein.E.Lieferantennr>0) then begin
      $lb.Lieferant->wpcaption # Adr.Stichwort;
      if ($edWE.Lieferant->wpchanged) then begin
        if (Art_P_Data:FindePreis('EK', Adr.Nummer, 0.0, '', 1)) then begin
          $edWE.PEH->wpcaptionint       # Art.P.PEH;
          $edWE.MEH->wpcaption          # Art.P.MEH;
          $edWE.Preis->wpcaptionfloat   # Art.P.PreisW1;
        end;
        if ($edEin.E.Lageradresse->wpcaptionint=0) then begin
          aName # '';
        end;
      end;
      end
    else begin
      $lb.Lieferant->wpcaption # ''
    end;
  end;

  if (aName='') or (aName='edEin.E.Lageradresse') then begin
    Erx # RecLink(100,506,6,_recFirst);   // Lagerandresse holen
    if (Erx<=_rLocked) then
      $lb.Adresse->wpcaption # Adr.Stichwort
    else
      $lb.Adresse->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Lageranschrift') then begin
    Erx # RecLink(101,506,7,_recFirst);   // Lageranschrift holen
    if (Erx<=_rLocked) then
      $lb.Anschrift->wpcaption # Adr.A.Stichwort
    else
      $lb.Anschrift->wpcaption # '';
  end;

  if (aName='') or (aName='edEin.E.Art.Zustand') then begin
    Erx # RecLink(856,506,17,_recFirst);   // Zustand holen
    if (Erx<=_rLocked) then
      $lb.Zustand->wpcaption # Art.ZSt.Name
    else
      $lb.Zustand->wpcaption # '';
  end;

  // veränderte Felder in Objekte schreiben

  if (aName='') then begin
  end;

  if (aName<>'') then begin
    vHdl # gMdi->winsearch(aName);
    if (vHdl<>0) then
     vHdl->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx : int;
end;
begin

  Ein.E.Dicke           # Art.Dicke;
  Ein.E.Breite          # Art.Breite;
  "Ein.E.Länge"         # "Art.Länge";
  Ein.E.Eingang_Datum   # today;
  Ein.E.MEH             # Art.MEH;
  $edWE.PEH->wpcaptionint       # Art.PEH;
  $edWE.MEH->wpcaption          # Art.MEH;
  $Lb.MEH->wpcaption            # Art.MEH;

  if (Art_P_Data:FindePreis('EK', 0, 0.0, '', 1)) then begin
    $edWE.PEH->wpcaptionint       # Art.P.PEH;
    $edWE.MEH->wpcaption          # Art.P.MEH;
    $edWE.Preis->wpcaptionfloat   # Art.P.PreisW1;
    end
  else if (Art_P_Data:FindePreis('L-EK', 0, 0.0, '', 1)) then begin
    $edWE.PEH->wpcaptionint       # Art.P.PEH;
    $edWE.MEH->wpcaption          # Art.P.MEH;
    $edWE.Preis->wpcaptionfloat   # Art.P.PreisW1;
  end;


  Ein.E.Lageradresse    # Set.eigeneAdressnr;
  Ein.E.Lageranschrift  # 99;
  Erx # RecLink(101, 506, 7, _recFirst);  // Lieferanschrift testen
  if (Erx>_rLocked) then
    Ein.E.Lageranschrift  # 1;
  Refreshifm('edWE.Lageradresse');

  if (StrCnv(Ein.E.MEH,_Strupper)='STK') or (StrCnv(Ein.E.MEH,_Strupper)='KG') or
    (StrCnv(Ein.E.MEH,_Strupper)='T') or (Mode=c_ModeEdit) then
    Lib_GuiCom:Disable($edEin.E.Menge)
  else
    Lib_GuiCom:Enable($edEin.E.Menge);

  // Focus setzen auf Feld:
  $cb.Erstbestand->WinFocusSet(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vErg      : int;
  vNr       : int;
  vOK       : logic;
  vPreisArt : float;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If ($edWE.Lieferant->wpcaptionint=0) then begin
    Msg(001200,Translate('Lieferant'),0,0,0);
    $edWE.Lieferant->WinFocusSet(true);
    RETURN false;
  end;
  Adr.Lieferantennr # $edWE.Lieferant->wpcaptionint;
  Erx # RecRead(100,3,0);
  if (Erx>_rMultikey) then begin
    Msg(001201,Translate('Lieferant'),0,0,0);
    $edWE.Lieferant->WinFocusSet(true);
    RETURN false;
  end;

  if (Ein.E.Eingang_Datum = 0.0.0) then begin
    Msg(001200,Translate('Eingangsdatum'),0,0,0);
    $edEin.E.Eingang_Datum->WinFocusSet(true);
    RETURN false;
  end;
  if (Lib_Faktura:Abschlusstest(Ein.E.Eingang_Datum) = false) then begin
    Msg(001400 ,Translate('Eingangsdatum') + '|'+ CnvAd(Ein.E.Eingang_Datum),0,0,0);
    $edEin.E.Eingang_Datum->WinFocusSet(true);
    RETURN false;
  end;




  // Adress- und Anschriftsprüfung
  If (Ein.E.Lageradresse=0) then begin
    Msg(001200,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(100,506,6,0);   // Lageradresse holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageradresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageradresse->WinFocusSet(true);
    RETURN false;
  end;
  If (Ein.E.Lageranschrift=0) then begin
    Msg(001200,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;

  Erx # RecLink(101,506,7,0);   // Lageranschrift holen
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Lageranschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Lageranschrift->WinFocusSet(true);
    RETURN false;
  end;
  if (Ein.E.Art.Zustand<>0) then begin
    Erx # RecLink(856,506,17,_recFirst);  // Zustand holen
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Zustand'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edEin.E.Art.Zustand->WinFocusSet(true);
      RETURN false;
    end;
  end;


  if ("Ein.E.Stückzahl"<0) then begin
    Msg(001205,Translate('Stückzahl'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Stueckzahl->WinFocusSet(true);
    RETURN false;
  end
  if (Ein.E.Gewicht<0.0) then begin
    Msg(001205,Translate('Gewicht'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Gewicht->WinFocusSet(true);
    RETURN false;
  end;
  if (Ein.E.Menge<=0.0) then begin
    if (Ein.E.Menge=0.0) then
      Msg(001200,Translate('Menge'),0,0,0);
    else
      Msg(001205,Translate('Menge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edEin.E.Menge->WinFocusSet(true);
    RETURN false;
  end;



  // ERSTEBESTANDSBUCHUNG ??? -----------------------------------------------
  if ($cb.Erstbestand->wpCheckState=_WinStateChkChecked) then begin

    RecBufClear(252);
    Art.C.Charge.Intern # Ein.E.Charge;
    Art.C.ArtikelNr     # Ein.E.ArtikelNr;
    Art.C.Lieferantennr # Ein.E.Lieferantennr;
    Art.C.AdressNr      # Ein.E.Lageradresse;
    Art.C.AnschriftNr   # Ein.E.Lageranschrift;
    Art.C.Zustand       # Ein.E.Art.Zustand;
    Art.C.Dicke         # Ein.E.Dicke;
    Art.C.Breite        # Ein.E.Breite;
    "Art.C.Länge"       # "Ein.E.Länge";
    Art.C.RID           # Ein.E.RID;
    Art.C.RAD           # Ein.E.RAD;
    Art.C.Lagerplatz    # Ein.E.Lagerplatz;
    Art.C.Charge.Extern # Ein.E.Chargennummer;
    Art.C.Bezeichnung   # Ein.E.Bemerkung;
    Art.C.Bestellnummer # '';

    RecBufClear(253);
    Art.J.Datum           # Ein.E.Eingang_Datum;
    Art.J.Bemerkung       # '';
    "Art.J.Stückzahl"     # "Ein.E.Stückzahl";
    Art.J.Menge           # Ein.E.Menge;
    "Art.J.Trägertyp"     # 'WE';
    "Art.J.Trägernummer1" # Ein.E.Nummer;
    "Art.J.Trägernummer2" # Ein.E.Position;
    "Art.J.Trägernummer3" # Ein.E.Eingangsnr;
    vPreisArt             # $edWE.Preis->wpcaptionfloat;
    TRANSON;
    // Buchen...
    Erx # RecLink(100,506,3,_recFirst);   // Lieferant holen
    vOK # Art_Data:Bewegung(rnd(vPreisArt,2), 0.0, Adr.Nummer);
    if (vOK=false) then begin
      TRANSBRK;
      ErrorOutput;
      RETURN false;
    end;

    TRANSOFF;

    Mode # c_modeCancel;  // sofort alles beenden!

    Msg(999998,'',0,0,0); // Erfolg

    RETURN true;
  end;


  // echter Wareneingang ---------------------------------------------------
  RecLink(819,250,10,_recFirst);  // Warengruppe holen

  TRANSON;

  // Nummernvergabe
  vNr # Lib_Nummern:ReadNummer('Einkauf-WE');    // Nummer lesen
  Lib_Nummern:SaveNummer();                         // Nummernkreis aktuallisiern

  Erx # RecLink(100,506,3,_recFirst);   // Lieferant holen

  // Bestellkopf vorbelegen
  RecBufClear(500);
  Ein.Vorgangstyp     # c_Bestellung;
  Ein.Nummer          # vNr;
  Ein.Datum           # today;
  Ein.Lieferantennr   # Adr.Lieferantennr;
  Ein.LieferantenSW   # Adr.Stichwort;
  Ein.Lieferadresse   # Adr.A.Adressnr;
  Ein.Lieferanschrift # Adr.A.Nummer;
//  Ein.Rechnungsempf   # Adr.Lieferantennr;
  Ein.Sachbearbeiter  # gUsername;
  "Ein.Währung"       # 1;
  "Ein.Währungskurs"  # 1.0;
  Ein.AbmessungsEH    # 'mm';
  Ein.GewichtsEH      # 'kg';
  Ein.Sprache         # Adr.Sprache;
  "Ein.Löschmarker"   # '*';
  Ein.Eingangsmarker  # '!';

  Ein.Anlage.Datum  # Today;
  Ein.Anlage.Zeit   # Now;
  Ein.Anlage.User   # gUserName;

  Erx # RekInsert(500,0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Bestellposition vorbelegen
  RecBufClear(501);
  Ein.P.Nummer          # Ein.Nummer;
  Ein.P.Position        # 1;
  Ein.P.Lieferantennr   # Ein.Lieferantennr;
  Ein.P.LieferantenSW   # Ein.LieferantenSW;

  Ein.P.Warengruppe     # Art.Warengruppe;
  Ein.P.Wgr.Dateinr     # Wgr.Dateinummer;
  Ein.P.ArtikelNr       # Art.Nummer;
  Ein.P.ArtikelSW       # Art.Stichwort;
  Ein.P.Sachnummer      # Art.Sachnummer;
  Ein.P.Katalognr       # Art.Katalognr;
  Ein.P.Dicke           # Ein.E.Dicke;
  Ein.P.Breite          # Ein.E.Breite;
  "Ein.P.Länge"         # "Ein.E.Länge";
  "Ein.P.Stückzahl"     # "Ein.E.Stückzahl";
  Ein.P.Gewicht         # Ein.E.Gewicht;
  Ein.P.MEH.Wunsch      # Art.MEH;
  Ein.P.MEH             # Art.MEH;
  Ein.P.Menge           # Ein.E.Menge;
  Ein.P.Menge.Wunsch    # Ein.P.Menge;

  Ein.P.MEH.Preis       # $edWE.MEH->wpcaption;
  Ein.P.PEH             # $edWE.PEH->wpcaptionint;
  Ein.P.Grundpreis      # $edWE.Preis->wpcaptionfloat;
  Ein.P.Einzelpreis     # Ein.P.Grundpreis;
  Ein.P.Gesamtpreis     # Ein.P.Grundpreis;
  Ein.P.Termin1Wunsch   # today;
  Ein.P.Termin1W.Art    # 'DA';

  Ein.P.Anlage.Datum  # Today;
  Ein.P.Anlage.Zeit   # Now;
  Ein.P.Anlage.User   # gUserName;

  Erx # Ein_Data:PosInsert(0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Wareneingang vorbelegen
  //RecBufClear(506);
  Ein.E.Nummer          # Ein.P.Nummer;
  Ein.E.Position        # Ein.P.Position;
  Ein.E.Eingangsnr      # 1;
  Ein.E.Lieferantennr   # Ein.P.Lieferantennr;
  Ein.E.Warengruppe     # Ein.P.Warengruppe;
  Ein.E.EingangYN       # y;
  //Ein.E.Eingang_Datum   # $edWE.Eingang_Datum->wpcaptiondate;
  //Ein.E.Preis           # $edWE.Preis->wpcaptionfloat;
  Ein.E.PreisW1         # Ein.E.Preis;
  "Ein.E.Währung"       # "Ein.Währung";
  //Ein.E.Bemerkung       # $edWE.Bemerkung->wpcaption;
  //Ein.E.Lieferscheinnr  # $edWE.Lieferscheinnr->wpcaption;
  Ein.E.Lageradresse    # Ein.Lieferadresse;
  Ein.E.Lageranschrift  # Ein.Lieferanschrift;
  //Ein.E.Lagerplatz      # $edWE.Lagerplatz->wpcaption;
  Ein.E.Menge           # Ein.P.Menge;
  "Ein.E.Stückzahl"     # "Ein.P.Stückzahl";
  Ein.E.Gewicht         # Ein.P.Gewicht;
  Ein.E.MEH             # Ein.P.MEH;
  Ein.E.Artikelnr       # Ein.P.Artikelnr;
  //Ein.E.Chargennummer   # $edWE.Charge->wpcaption;
  Ein.E.Dicke           # Ein.P.Dicke;
  Ein.E.Breite          # Ein.P.Breite;
  "Ein.E.Länge"         # "Ein.P.Länge";

  Ein.E.Anlage.Datum  # Today;
  Ein.E.Anlage.Zeit   # Now;
  Ein.E.Anlage.User   # gUserName;
  Erx # RekInsert(506,0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Vorgang buchen
  if (Ein_E_Data:Verbuchen(y)=false) then begin
    TRANSBRK;
    Msg(506001,'',0,0,0);
    RETURN false;
  end;
  // Bestellung sofort löschen
  Ein_P_Subs:ToggleLoeschmarker(n);

  TRANSOFF;

  Mode # c_modeCancel;  // sofort alles beenden!

  Msg(999998,'',0,0,0); // Erfolg

  RETURN true;
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  tLinkFlag : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    RekDelete(gFile,0,'MAN');
  end;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vFocus : alpha;
end;
begin
  vFocus # aEvt:Obj->wpname;
//debug('Foc:'+vFocus);
//if (vFocus='DUMMYNEW') then RETURN true;

  // Auswahlfelder aktivieren
  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
begin

  if (aEvt:Obj->wpname='edEin.E.Dicke') and ($edEin.E.Dicke->wpchanged) then begin
    BerechneAus('ABM');
  end;

  if (aEvt:Obj->wpname='edEin.E.Breite') and ($edEin.E.Breite->wpchanged) then begin
    BerechneAus('ABM');
  end;

  if (aEvt:Obj->wpname='edEin.E.Lnge') and ($edEin.E.Lnge->wpchanged) then begin
    BerechneAus('ABM');
  end;

  if (aEvt:Obj->wpname='edEin.E.Stueckzahl') and ($edEin.E.Stueckzahl->wpchanged) then begin
    BerechneAus('STK');
  end;

  if (aEvt:Obj->wpname='edEin.E.Gewicht') and ($edEin.E.Gewicht->wpchanged) then begin
    BerechneAus('KG');
  end;

  if (aEvt:Obj->wpname='edEin.E.Menge') and ($edEin.E.Menge->wpchanged) then begin
    BerechneAus('MENGE');
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx   : int;
  vA    : alpha;
  vHdl  : int;
  vHdl2 : int;
  vi    : int;
  vText : alpha;
  vSelected : int;
  vQ    : alpha;
end;

begin

  case aBereich of

    'Zustand' : begin
      RecBufClear(856);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Zst.Verwaltung',here+':AusZustand');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Preis': begin
      RecBufClear(254);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung',here+':AusPreis');
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'MEH' : begin
      Lib_Einheiten:Popup('MEH',$edWE.MEH,0,0,0);
    end;


    'Lieferant' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_Sel:QRecList(0,'Adr.LieferantenNr > 0');  // hier Selektion: nur Lieferanten

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageradresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLageradresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      Adr.Nummer  # Ein.E.Lageradresse;
      Erx # RecRead(100,1,0);

      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift');
      
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
    end;


    'Lagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LpL.Verwaltung',here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;  // ...case

end;


//========================================================================
//  AusPreis
//
//========================================================================
sub AusPreis()
local begin
  vHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    $edWE.PEH->wpcaptionint       # Art.P.PEH;
    $edWE.MEH->wpcaption          # Art.P.MEH;
    $edWE.Preis->wpcaptionfloat   # Art.P.PreisW1;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;

  // Focus auf Editfeld setzen:
  $edWE.Preis->Winfocusset(true);
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  vHdl : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    ein.E.Lieferantennr # Adr.Lieferantennr;
    $lb.Lieferant->wpcaption # Adr.Stichwort;
    if (Art_P_Data:FindePreis('EK', Adr.Nummer, 0.0, '', 1)) then begin
      $edWE.PEH->wpcaptionint       # Art.P.PEH;
      $edWE.MEH->wpcaption          # Art.P.MEH;
      $edWE.Preis->wpcaptionfloat   # Art.P.PreisW1;
    end
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;

  Refreshifm('edWE.Lageradresse');
  // Focus auf Editfeld setzen:
  $edWE.Lieferant->Winfocusset(true);
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    Ein.E.Lagerplatz # Lpl.Lagerplatz;
    // Feldübernahme
    gSelected # 0;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Lagerplatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusLageradresse
//
//========================================================================
sub AusLageradresse()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Lageradresse # Adr.Nummer;
    Ein.E.Lageranschrift # 1;
    $edEin.E.Lageradresse->winupdate(_WinUpdFld2Obj);
    $edEin.E.Lageranschrift->winupdate(_WinUpdFld2Obj);
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm('');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Lageradresse    # Adr.A.Adressnr;
    Ein.E.Lageranschrift  # Adr.A.Nummer;
    $edEin.E.Lageradresse->winupdate(_WinUpdFld2Obj);
    $edEin.E.Lageranschrift->winupdate(_WinUpdFld2Obj);
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm('');
end;


//========================================================================
//  AusZustand
//
//========================================================================
sub AusZustand()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(856,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Ein.E.Art.Zustand # Art.Zst.Nummer;
    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edEin.E.Art.Zustand->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx',y);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;


  vHdl # gMdi->WinSearch('Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('RecPrev');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('RecNext');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMdi->WinSearch('Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;


  // Menüleiste setzen
  vHdl # gMenu->WinSearch('Mnu.Save');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMenu->WinSearch('Mnu.Cancel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # n;

  vHdl # gMenu->WinSearch('Mnu.Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecPrev');
  if (vHdl <> 0) then
    vHdl->wpdisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecNext');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecLast');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.RecFirst');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

//  vHdl # gMenu->WinSearch('Mnu.Auswahl');
//  if (vHdl <> 0) then
//    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.NextPage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.PrevPage');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Info');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Mnu.Info');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Listen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

  vHdl # gMenu->WinSearch('Druck');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

//  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then
  RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vHdl      : int;
  vMode     : alpha;
  vParent   : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of
  end; // case

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.MEH'          :   Auswahl('MEH');
    'bt.Preis'        :   Auswahl('Preis');
    'bt.Lieferant'    :   Auswahl('Lieferant');
    'bt.Adresse'      :   Auswahl('Lageradresse');
    'bt.Anschrift'    :   Auswahl('Lageranschrift');
    'bt.Lagerplatz'   :   Auswahl('Lagerplatz');
    'bt.Zustand'      :   Auswahl('Zustand');
  end;

end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin
  RETURN true;
end;


//========================================================================
// EvtChanged
//            Feldveränderungen
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cb.Erstbestand') then begin
    if ($cb.Erstbestand->wpCheckState=_WinStateChkChecked) then begin
      RecLink(100,903,1,_recFirst);   // eigene Adresse holen
      Ein.E.Lieferantennr # Adr.Lieferantennr;
      $lb.Lieferant->wpcaption # Adr.Stichwort;
      $edWE.PEH->wpcaptionint       # Art.PEH;
      $edWE.MEH->wpcaption          # Art.MEH;
      $Lb.MEH->wpcaption            # Art.MEH;
      $edWE.Lieferant->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Disable($edWE.Lieferant);
      Lib_GuiCom:Disable($bt.Lieferant);
      Lib_GuiCom:Disable($edWE.PEH);
      Lib_GuiCom:Disable($edWE.MEH);
      Lib_GuiCom:Disable($bt.MEH);
    end
    else begin
      Ein.E.Lieferantennr # 0;
      $lb.Lieferant->wpcaption # '';
      $edWE.Lieferant->winupdate(_WinUpdFld2Obj);
      Lib_GuiCom:Enable($edWE.Lieferant);
      Lib_GuiCom:Enable($bt.Lieferant);
      Lib_GuiCom:Enable($edWE.PEH);
      Lib_GuiCom:Enable($edWE.MEH);
      Lib_GuiCom:Enable($bt.MEH);
    end;
  end;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  return true;
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================