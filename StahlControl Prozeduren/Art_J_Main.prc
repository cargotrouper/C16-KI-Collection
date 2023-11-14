@A+
//==== Business-Control ==================================================
//
//  Prozedur    Art_J_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.03.2009  TM  Adress- und Anschriftsnr als Pflichtfelder definiert
//  14.01.2010  AI  Umbuchungen eingebaut
//  15.02.2011  AI  neue Chargen
//  04.04.2022  AH  ERX
//  13.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(opt aName : alpha; opt aChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusCharge()
//    SUB AusCharge2()
//    SUB AusArtikel2()
//    SUB AusZustand2();
//    SUB AusLagerplatz2()
//    SUB AusAdresse2()
//    SUB AusAnschrift2()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Lagerjournal'
  cFile :     253
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Art_J'
  cZList :    $ZL.Art.Journal
  cKey :      1
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  $clmArt.J.Menge->wpcaption # Translate('Menge')+' '+Art.MEH;

  if ("Art.ChargenführungYN"=n) then begin
    $lb.Zustand->wpvisible # false;
    $Lb.J.Zustand->wpvisible # false;
    $Lb.J.ZustandText->wpvisible # false;
    $lbArt.J.Ziel.Zustand->wpvisible # false;
    $edArt.J.Ziel.Zustand->wpvisible # false;
    $bt.Zustand2->wpvisible # false;
    $Lb.J.ZustandText2->wpvisible # false;
    $lbArt.J.Charge.Extern->wpvisible # false;
    $lb.J.Charge->wpvisible # false;
  end;


Lib_Guicom2:Underline($edArt.J.Charge);
Lib_Guicom2:Underline($edArt.J.Ziel.Artikelnr);
Lib_Guicom2:Underline($edArt.J.Ziel.Charge);
Lib_Guicom2:Underline($edArt.J.Ziel.Zustand);
Lib_Guicom2:Underline($edArt.J.Ziel.Adressnr);
Lib_Guicom2:Underline($edArt.J.Ziel.Anschrift);

  SetStdAusFeld('edArt.J.Charge'            ,'Charge');
  SetStdAusFeld('edArt.J.Ziel.Charge'       ,'ZielCharge');
  SetStdAusFeld('edArt.J.Ziel.Artikelnr'    ,'ZielArtikel');
  SetStdAusFeld('edArt.J.Ziel.Zustand'      ,'ZielZustand');
  SetStdAusFeld('edArt.J.Ziel.Lagrplatz'    ,'ZielLagerplatz');
  SetStdAusFeld('edArt.J.Ziel.Adressnr'     ,'ZielAdresse');
  SetStdAusFeld('edArt.J.Ziel.Anschrift'    ,'ZielAnschrift');

  App_Main:EvtInit(aEvt);
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
  Lib_GuiCom:Pflichtfeld($edArt.J.Menge);
  Lib_GuiCom:Pflichtfeld($edArt.J.Datum);
  Lib_GuiCom:Pflichtfeld($edArt.J.Ziel.Adressnr);
  Lib_GuiCom:Pflichtfeld($edArt.J.Ziel.Anschrift);
  Lib_GuiCom:Pflichtfeld($edArt.J.Ziel.EKPreisW1);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx     : int;
  vX      : int;
  vA,vB   : alpha;
  vBuf250 : int;
  vBuf252 : int;
end;
begin

  if (aName='') then begin
    if (mode=c_modeView) then begin
      $Lb.J.Artikelnr->wpcaption # Art.Nummer;
      $Lb.J.ArtStichwort->wpcaption # Art.Stichwort;
      $Lb.J.MEH->wpcaption # Art.MEH;
    end;
/*
    if (Art.J.Anlage.User<>'') then
      $lb.Anlage->wpcaption # Translate('am')+' '+cnvad(Art.J.Anlage.Datum)+' '+Translate('um')+' '+cnvat(Art.J.Anlage.Zeit,_FmtTimeSeconds)+' '+translate('durch')+' '+Art.J.Anlage.User
    else
      $lb.Anlage->wpcaption # '';
*/
    $Lb.J.Charge->wpcaption       # Art.J.Charge.Extern;
    $Lb.J.Lieferschein->wpcaption # '';
    $lb.J.Bemerkung->wpcaption    # '';
    if ("Art.J.Trägertyp"='WE') then begin
      Ein.E.Nummer      # "Art.J.Trägernummer1";
      Ein.E.Position    # "Art.J.Trägernummer2";
      Ein.E.Eingangsnr  # "Art.J.Trägernummer3";
      Erx # RecRead(506,1,0);
      if (Erx=_rOK) then begin
        $lb.J.Lieferschein->wpcaption   # Ein.E.Lieferscheinnr;
        $lb.J.Bemerkung->wpcaption      # Ein.E.Bemerkung;
      end;
    end;
  end;

/*
  if (aName='') or (aName='edArt.J.Adressnr') or (aName='edArt.J.Anschriftnr') then begin
    Erx # RecLink(101,253,3,0);   // Anschrift holen
    if (Erx=_rOK) then
      $Lb.J.AdrStichwort->wpcaption # Adr.A.Stichwort
    else
      $Lb.J.AdrStichwort->wpcaption # '';
  end;
*/
  if (aName='') then begin
    Erx # RecLink(100,253,4,_RecFirst);   // Adresse holen
    if (Erx>_rLocked) then Recbufclear(100);
    Erx # RecLink(101,253,3,_RecFirst);   // Anschrift holen
    if (Erx>_rLocked) then Recbufclear(101);
    $Lb.J.Lagerort->wpcaption         # Adr.Stichwort;
    $Lb.J.Lageranschrift->wpcaption   # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
    $Lb.J.Lageradresse->wpcaption     # AInt(Art.J.Adressnr);
    $Lb.J.Lageranschr->wpcaption      # AINt(Art.J.Anschriftnr);
    $Lb.J.Lagerplatz->wpcaption       # Art.J.Lagerplatz;

    vBuf252 # RecBufCreate(252);
    Erx # RecLink(vBuf252,253,2,_Recfirst);   // Start-Charge holen
    if (Erx>_rLocked) then RecbufClear(vBuf252);

    Erx # RecLink(856,vBuf252,9,_recFirst);   // Zustand holen
    if (vBuf252->Art.C.Zustand<>0) then begin
      $Lb.J.Zustand->wpcaption      # aint(vBuf252->Art.C.Zustand);
      $lb.J.ZustandText->wpcaption  # Art.ZSt.Name;
      end
    else begin
      $Lb.J.Zustand->wpcaption      # '';
      $lb.J.ZustandText->wpcaption  # '';
    end;
    RecBufDestroy(vBuf252);
  end;

  if (aName='') or (aName='edArt.J.Ziel.Adressnr') or
    (aName='edArt.J.Ziel.Anschrift') then begin
    Erx # RecLink(100,253,8,_RecFirst);   // ZielAdresse holen
    if (Erx>_rLocked) then Recbufclear(100);
    Erx # RecLink(101,253,7,_RecFirst);   // ZielAnschrift holen
    if (Erx>_rLocked) then Recbufclear(101);
    $Lb.J.Lagerort2->wpcaption       # Adr.Stichwort;
    $Lb.J.Lageranschrift2->wpcaption # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
  end;

  if (aName='') or (aName='edArt.J.Ziel.Zustand') then begin
    Erx # RecLink(856,253,9,_recFirst);   // Zustand holen
    if (Art.J.Ziel.Zustand<>0) then begin
      $lb.J.ZustandText2->wpcaption  # Art.ZSt.Name;
      end
    else begin
      $lb.J.ZustandText2->wpcaption  # '';
    end;
  end;


  if (aName='') or (aName='edArt.J.Ziel.Artikelnr') then begin
    vBuf250 # RecBufCreate(250);
    Erx # RecLink(vBuf250, 253,5,_recFirst);    // Zielartikel holen
    if (Erx<=_rLocked) then begin
      $lb.J.WAE->wpcaption # "Set.Hauswährung.Kurz"+' / '+aint(vBuf250->Art.PEH)+' '+vBuf250->Art.MEH;
    end
    else begin
      $lb.J.WAE->wpcaption # '';
    end;
    RecBufDestroy(vBuf250);
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    gTmp # gMdi->winsearch(aName);
    if (gTmp<>0) then
     gTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

  $Lb.J.Artikelnr->wpcaption      # Art.Nummer;
  $Lb.J.ArtStichwort->wpcaption   # Art.Stichwort;
  $Lb.J.MEH->wpcaption            # Art.MEH;

  $edArt.J.Charge->wpreadonly       # y;
//  $edArt.J.Ziel.Charge->wpreadonly  # y;

  Art.J.ArtikelNr     # Art.Nummer;
//  Art.J.Adressnr      # Art.C.Adressnr;
//  Art.J.AnschriftNr   # Art.C.Anschriftnr;
//  Art.J.Charge        # Art.C.Charge.Intern;
  Art.J.Datum         # Today;
  $edArt.J.Charge->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx       : int;
  vOk       : logic;
  vStk      : int;
  vBuf250   : int;
  vBuf253   : int;
  vNr       : int;
  vFilter   : int;
  vvArt     : alpha;
  vVCharge  : alpha;
  vVZust    : int;
  vVLP      : alpha;
end;
begin

  // logische Prüfung
  if ((Art.SeriennummerYN) and (Art.J.Menge<>1.0) and (Art.J.Menge<>-1.0)) then begin
      Msg(253001,gTitle,0,0,0);
      RETURN False;
  end;

  // Chargenprüfung
  if (Art.SeriennummerYN) then begin
    RecBufClear(252);
    Art.C.ArtikelNr     # Art.J.ArtikelNr;
    Art.C.Charge.Intern # Art.J.Charge;
    vOk # Art_Data:ReadCharge();
    if (((Art.C.Bestand<>0.0) and (Art.C.Bestand<>1.0) and (Art.C.Bestand<>-1.0)) or
      (Art.C.Bestand*Art.J.Menge<>-1.0)) or
      (vOk=n) then begin
      Msg(253002,gTitle,0,0,0);
      RETURN False;
    end;
  end;


  // Adress- und Anschriftsprüfung
  If (Art.J.Adressnr=0) then begin
    Msg(001200,Translate('Adresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(100,253,4,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Adresse'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;

  If (Art.J.Anschriftnr=0) then begin
    Msg(001200,Translate('Anschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(101,253,3,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Anschrift'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;


  // Start-Charge prüfen
  if (Art.J.Charge='') then begin
    Msg(001200,Translate('Charge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(252,253,2,_Recfirst);   // Start-Charge holen
  if (Erx>_rLocked) then begin
    Msg(001201,Translate('Charge'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edArt.J.Charge->WinFocusSet(true);
    RETURN false;
  end;

  // Umbuchung -------------
  if ($cb.Umbuchung->wpCheckState=_WinStateChkChecked) then begin
    if (Art.J.Ziel.Artikelnr='') then begin
      Msg(001201,Translate('Artikel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Artikelnr->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(250,253,5,_rectest);   // Zielartikel prüfen
    if (Erx>_rLocked) then begin
      Msg(001201,Translate('Artikel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Artikelnr->WinFocusSet(true);
      RETURN false;
    end;

    if (Art.J.Ziel.Zustand<>0) then begin
      Erx # RecLink(856,253,9,_recFirst);   // ZielZustand holen
      if (Erx>_rLocked) then begin
        Msg(001201,Translate('Zustand'),0,0,0);
        $NB.Main->wpcurrent # 'NB.Page1';
        $edArt.J.Ziel.Zustand->WinFocusSet(true);
        RETURN false;
      end;
    end;

    If (Art.J.Ziel.Adressnr=0) then begin
      Msg(001200,Translate('Adresse'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Adressnr->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(100,253,8,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Adresse'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Adressnr->WinFocusSet(true);
      RETURN false;
    end;

    If (Art.J.Ziel.Anschrift=0) then begin
      Msg(001200,Translate('Anschrift'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Anschrift->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(101,253,7,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Anschrift'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Anschrift->WinFocusSet(true);
      RETURN false;
    end;

    If (Art.J.Ziel.EKPreisW1=0.0) then begin
      Msg(001200,Translate('EK-Preis'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.EKPreisW1->WinFocusSet(true);
      RETURN false;
    end;

    if (Art.J.Artikelnr=Art.J.Ziel.ARtikelnr) and (Art.J.Charge=Art.J.Ziel.Charge) and
      (Art.J.Adressnr=Art.J.Ziel.Adressnr) and (Art.J.Anschriftnr=Art.J.Ziel.Anschrift) then begin
      Msg(253003,'',0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edArt.J.Ziel.Charge->WinFocusSet(true);
      RETURN false;
    end;
  end;  // Umbuchung


  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  // NEUANLAGE
  else begin

    // Nummernvergabe...

    // letzten Datensatz dieses Tages suchen...
    vBuf253 # RekSave(253);
    vFilter # RecFilterCreate(253,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Art.J.Artikelnr);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, Art.J.Charge);
    vFilter->RecFilterAdd(3,_FltAND,_FltEq, Art.J.Datum);
    Erx # RecRead(253,1,_recLast);
    RecFilterDestroy(vFilter);
    if (Erx>_rMultiKey) then vNr # 1
    else vNr # Art.J.lfdNr + 1;
    RekRestore(vBuf253);
    Art.J.LfdNr # vNr;
    REPEAT
      Erx # RecRead(253,1,_Rectest);
      if (Erx<_rLocked) then begin
        Art.J.lfdNr # Art.J.lfdNr + 1;
      end;
    UNTIL (Erx>_rLocked);


    // Start-Daten merken
    vVZust    # Art.C.Zustand;
    vVLP      # Art.C.Lagerplatz;
    vvCharge  # Art.C.Charge.Intern;
    vvArt     # Art.C.Artikelnr;

    vBuf253 # RekSave(253);
    // Chargenbuchung
    RecBufClear(252);
    Art.C.ArtikelNr     # Art.J.ArtikelNr;
    Art.C.Adressnr      # Art.J.Adressnr;
    Art.C.AnschriftNr   # Art.J.Anschriftnr;
    Art.C.Charge.Intern # Art.J.Charge;
    Art.C.Zustand       # vvZust;
    Art.C.Lagerplatz    # vvLP;
    Art.C.Dicke         # Art.Dicke;
    Art.C.Breite        # Art.Breite;
    "Art.C.Länge"       # "Art.Länge";
    vStk # cnvif(Lib_einheiten:WandleMEH(252,0,0.0, Art.J.Menge, Art.MEH, 'Stk'));

    TRANSON;
    "Art.J.Stückzahl"     # vStk;
    vOK # Art_Data:Bewegung(0.0, 0.0);
    if (vOK=false) then begin
      TRANSBRK;
      RekRestore(vBuf253);
      Msg(001000+1,gTitle,0,0,0);
      RETURN False;
    end;
/***
    RecRead(253,1,_recLock);
    Art.J.Ziel.Artikelnr    # vBuf253->Art.J.Ziel.Artikelnr;
    Art.J.Ziel.Charge       # vBuf253->Art.J.Ziel.Charge;
    Art.J.Ziel.Adressnr     # vBuf253->Art.J.Ziel.Adressnr;
    Art.J.Ziel.Anschrift    # vBuf253->Art.J.Ziel.Anschrift;
    Art.J.Ziel.Zustand      # vBuf253->Art.J.Ziel.Zustand;
    Art.J.Ziel.Lagrplatz    # vBuf253->Art.J.Ziel.Lagrplatz;
    Art.J.Ziel.EKPreisW1    # vBuf253->Art.J.Ziel.EKPreisW1;
    RekReplace(253,_recUnlock,'MAN');
***/

    vBuf250 # RekSave(250);
    // Gegenbuchugn anlegen...
    if ($cb.Umbuchung->wpCheckState=_WinStateChkChecked) then begin
//      Art.J.Artikelnr       # vBuf253->Art.J.Ziel.Artikelnr;
//      Art.J.Charge          # vBuf253->Art.J.Ziel.Charge;
      Erx # RecLink(250,vBuf253,5,_recFirst);   // Zielartikel holen
      Erx # RecLink(252,vBuf253,2,_Recfirst);   // Start-Charge holen
      Art.C.ArtikelNr     # vBuf253->Art.J.Ziel.ArtikelNr;
      Art.C.Adressnr      # vBuf253->Art.J.Ziel.Adressnr;
      Art.C.AnschriftNr   # vBuf253->Art.J.Ziel.Anschrift;
      Art.C.Charge.Intern # '';//Art.J.Charge;
      Art.C.Zustand       # vBuf253->Art.J.Ziel.Zustand;
      Art.C.Lagerplatz    # vbuf253->Art.J.Ziel.Lagrplatz;
      vStk # cnvif(Lib_einheiten:WandleMEH(252,0,0.0, -Art.J.Menge, Art.MEH, 'Stk'));

      "Art.J.Stückzahl"     # - "Art.J.Stückzahl";
      Art.J.Menge           # - Art.J.Menge;
      vOK # Art_Data:Bewegung(Art.J.Ziel.EKPreisW1, 0.0);
      if (vOK=false) then begin
        TRANSBRK;
        RekRestore(vBuf253);
        REkRestore(vbuf250);
        Msg(001000+1,gTitle,0,0,0);
        RETURN False;
      end;


      // in 2. Buchung Daten nachtragen
      RecRead(253,1,_recLock);
      Art.J.Ziel.Charge       # vvCharge;///vBuf253->Art.J.Charge;
      Art.J.Ziel.Zustand      # vvZust;
      Art.J.Ziel.Lagrplatz    # vvLP;
      Art.J.Ziel.Artikelnr    # vvArt;
      RekReplace(253,_recUnlock,'MAN');


      // in 1. Buchung Daten nachtragen
      RecBufCopy(vBuf253,253);
      RecRead(253,1,_recLock);
      Art.J.Ziel.Charge # Art.C.Charge.Intern;
      RekReplace(253,_recUnlock,'MAN');
    end;

    RecBufDestroy(vBuf253);
    RekRestore(vbuf250);
  end;

  TRANSOFF;

  RETURN true;  // Speichern erfolgreich
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
begin

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
  Erx     : int;
  vA      : alpha;
  vQ      : alpha(4000);
  vQ2     : alpha(4000);
  vHdl    : int;
  vBuf250 : int;
end;

begin

  case aBereich of

    'Charge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge');

      // Echte Charge auswählen?

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
//      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      //Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gZLList->wpdbkeyno);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielCharge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN

      Erx # RecLink(250, 253,5,_recFirst);    // Zielartikel holen
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusCharge2');
      Erx # RecLink(250, 253,1,_recFirst);    // Startartikel holen

      vBuf250 # RecBufCreate(250);
      Erx # RecLink(vBuf250, 253,5,_recFirst);    // Zielartikel holen
      // Echte Charge auswählen?
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', vBuf250->Art.Nummer);
//      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      //Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gZLList->wpdbkeyno);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      RecBufDestroy(vBuf250);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielArtikel' : begin
      vQ # Art.MEH;
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikel2');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # 'Art.Nummer>'''' AND NOT(Art.GesperrtYN) AND (Art.Meh='''+vQ+''')';
      vQ # vQ + ' AND LinkCount(WGR) > 0 ';
      Lib_Sel:QVonBisI(var vQ2, 'Wgr.Dateinummer'  , WGr_Data:WertArtikel(), WGr_data:WertArtikelBis());
      vHdl # SelCreate(250, gZLList->wpdbkeyno);
      vHdl->SelAddLink('',819, 250, 10, 'WGR');
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      Erx # vHdl->SelDefQuery('WGR', vQ2);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielLagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusLagerplatz2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielZustand' : begin
      RecBufClear(856);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.ZSt.Verwaltung',here+':AusZustand2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielAdresse'   : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ZielAnschrift' : begin
      Erx # RecLink(100,253,8,_recFirst);   // Zieladresse holen
      if (Erx<=_rLocked) then begin
        RecBufClear(101);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung','Art_J_Main:AusAnschrift2');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
    end;

  end;

end;


//========================================================================
//  AusCharge
//
//========================================================================
sub AusCharge()
begin
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Charge      # Art.C.Charge.Intern;
    Art.J.Adressnr    # Art.C.Adressnr;
    Art.J.Anschriftnr # Art.C.Anschriftnr;
    Art.J.Lagerplatz  # Art.C.Lagerplatz;
    Art.J.Ziel.EKPreisW1 # Art.C.EKDurchschnitt;
    $edArt.J.Ziel.EKPreisW1->winupdate();
    $edArt.J.Charge->winupdate();

    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);

    Refreshifm();
    $edArt.J.Menge->Winfocusset(false);
    end
  else begin
    $edArt.J.Charge->Winfocusset(false);
  end;

end;


//========================================================================
//  AusCharge2
//
//========================================================================
sub AusCharge2()
begin
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Ziel.Charge     # Art.C.Charge.Intern;
    Art.J.Ziel.Zustand    # Art.C.Zustand;
    Art.J.Ziel.Lagrplatz  # Art.C.Lagerplatz;
    Art.J.Ziel.Adressnr   # Art.C.Adressnr;
    Art.J.Ziel.Anschrift  # Art.C.Anschriftnr;

    $edArt.J.Ziel.Artikelnr->winupdate();
    $edArt.J.Ziel.Charge->winupdate();
    $edArt.J.Ziel.Zustand->winupdate();
    $edArt.J.Ziel.Adressnr->winupdate();
    $edArt.J.Ziel.Anschrift->winupdate();
    $edArt.J.Ziel.Lagrplatz->winupdate();
    $edArt.J.Ziel.EKPreisW1->winupdate();

    Lib_GuiCom:Disable($edArt.J.Ziel.Artikelnr);
    Lib_GuiCom:Disable($bt.Artikel2);
    Lib_GuiCom:Disable($edArt.J.Ziel.Adressnr);
    Lib_GuiCom:Disable($bt.Adresse2);
    Lib_GuiCom:Disable($edArt.J.Ziel.Anschrift);
    Lib_GuiCom:Disable($bt.Anschrift2);
    Lib_GuiCom:Disable($edArt.J.Ziel.EKPreisW1);
    Lib_GuiCom:Disable($edArt.J.Ziel.Lagrplatz);
    Lib_GuiCom:Disable($bt.Lagerplatz2);
    Lib_GuiCom:Disable($edArt.J.Ziel.Zustand);
    Lib_GuiCom:Disable($bt.Zustand2);

    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);

    RefreshIfM();
  end;

  $edArt.J.Ziel.Charge->Winfocusset(false);
end;


//========================================================================
//  AusArtikel2
//
//========================================================================
sub AusArtikel2()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Ziel.Artikelnr # Art.Nummer;
    gTMP # Winsearch(gMDi, 'Lb.J.Artikelnr');
    Art.Nummer # gTMP->wpcaption;
    RecRead(250,1,0);
    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  RefreshIfm('edArt.J.Ziel.Artikelnr',y);
  // Focus setzen:
  $edArt.J.Ziel.Artikelnr->Winfocusset(false);
end;


//========================================================================
//  AusZustand2
//
//========================================================================
sub AusZustand2();
begin
  if (gSelected<>0) then begin
    RecRead(856,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Ziel.Zustand # Art.Zst.Nummer;

    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  $edArt.J.Ziel.Zustand->Winfocusset(false);
  RefreshIfm();//'edEin.E.Art.Zustand',y);
end;


//========================================================================
//  AusLagerplatz2
//
//========================================================================
sub AusLagerplatz2()
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    Art.J.Ziel.Lagrplatz # Lpl.Lagerplatz;
    // Feldübernahme
    gSelected # 0;
    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edArt.J.Ziel.Lagrplatz->Winfocusset(false);
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusAdresse2
//
//========================================================================
sub AusAdresse2()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Ziel.AdressNr   # Adr.Nummer;
    Art.J.Ziel.Anschrift  # 1;
    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm();
  // Focus setzen:
  $edArt.J.Ziel.Adressnr->Winfocusset(false);
end;


//========================================================================
//  AusAnschrift2
//
//========================================================================
sub AusAnschrift2()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Art.J.Ziel.AdressNr   # Adr.A.AdressNr;
    Art.J.Ziel.Anschrift  # Adr.A.Nummer;
    gTMP # WinFocusget();   // LastFocus-Feld refreshen
    if (gTMP<>0) then gTMP->Winupdate(_WinUpdFld2Obj);
  end;
  Refreshifm();
  // Focus setzen:
  $edArt.J.Ziel.Anschrift->Winfocusset(false);
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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # true;//(vHdl->wpDisabled) or (Rechte[Rgt_Art_J_Loeschen]=n);

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
  vHdl : int;
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
    'bt.Charge'       :   Auswahl('Charge');

    'bt.Artikel2'     :   Auswahl('ZielArtikel');
    'bt.Zustand2'     :   Auswahl('ZielZustand');
    'bt.Charge2'      :   Auswahl('ZielCharge');
    'bt.Adresse2'     :   Auswahl('ZielAdresse');
    'bt.Anschrift2'   :   Auswahl('ZielAnschrift');
    'bt.Lagerplatz2'  :   Auswahl('ZielLagerplatz');
  end;

end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpname='cb.Umbuchung') then begin
    if ($cb.Umbuchung->wpCheckState=_WinStateChkChecked) then begin
      Lib_GuiCom:Enable($edArt.J.Ziel.Artikelnr);
      Lib_GuiCom:Enable($bt.Artikel2);
      Art.J.Ziel.Artikelnr  # Art.J.Artikelnr;
      $edArt.J.Ziel.Artikelnr->winupdate();
//      Lib_GuiCom:Enable($edArt.J.Ziel.Charge);
      Lib_GuiCom:Enable($bt.Charge2);
      //Art.J.Ziel.Charge     # Art.J.Charge;
      $edArt.J.Ziel.Charge->winupdate();
      Lib_GuiCom:Enable($edArt.J.Ziel.Adressnr);
      Lib_GuiCom:Enable($bt.Adresse2);
      Lib_GuiCom:Enable($edArt.J.Ziel.Anschrift);
      Lib_GuiCom:Enable($bt.Anschrift2);
      Lib_GuiCom:Enable($edArt.J.Ziel.EKPreisW1);
      Lib_GuiCom:Enable($edArt.J.Ziel.Lagrplatz);
      Lib_GuiCom:Enable($bt.Lagerplatz2);
      Lib_GuiCom:Enable($edArt.J.Ziel.Zustand);
      Lib_GuiCom:Enable($bt.Zustand2);
      $lb.J.WAE->wpcaption # "Set.Hauswährung.Kurz"+' / '+aint(Art.PEH)+' '+Art.MEH;
//      $edArt.J.Ziel.Charge->wpreadonly  # y;
      Pflichtfelder();
      end
    else begin
      Art.J.Ziel.Artikelnr  # '';
      Art.J.Ziel.Charge     # '';
      Art.J.Ziel.Adressnr   # 0;
      Art.J.Ziel.Anschrift  # 0;
      Art.J.Ziel.EKPreisW1  # 0.0;
      Art.J.Ziel.Zustand    # 0;
      Art.J.Ziel.Lagrplatz  # '';
      $lb.J.WAE->wpcaption    # '';
      $edArt.J.Ziel.Artikelnr->winupdate();
      $edArt.J.Ziel.Charge->winupdate();
      $edArt.J.Ziel.Zustand->winupdate();
      $edArt.J.Ziel.Adressnr->winupdate();
      $edArt.J.Ziel.Anschrift->winupdate();
      $edArt.J.Ziel.Lagrplatz->winupdate();
      $edArt.J.Ziel.EKPreisW1->winupdate();
      $Lb.J.ZustandText2->wpcaption     # '';
      $Lb.J.Lagerort2->wpcaption        # '';
      $Lb.J.Lageranschrift2->wpcaption  # '';

      Lib_GuiCom:Disable($edArt.J.Ziel.Artikelnr);
      Lib_GuiCom:Disable($bt.Artikel2);
//      Lib_GuiCom:Disable($edArt.J.Ziel.Charge);
      Lib_GuiCom:Disable($bt.Charge2);
      Lib_GuiCom:Disable($edArt.J.Ziel.Adressnr);
      Lib_GuiCom:Disable($bt.Adresse2);
      Lib_GuiCom:Disable($edArt.J.Ziel.Anschrift);
      Lib_GuiCom:Disable($bt.Anschrift2);
      Lib_GuiCom:Disable($edArt.J.Ziel.EKPreisW1);
      Lib_GuiCom:Disable($edArt.J.Ziel.Lagrplatz);
      Lib_GuiCom:Disable($bt.Lagerplatz2);
      Lib_GuiCom:Disable($edArt.J.Ziel.Zustand);
      Lib_GuiCom:Disable($bt.Zustand2);
    end;
  end;
  RETURN(true);
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

  // Ziel-Anschrift...
  if (RecLink(101,253,7,0)>_rLockeD) then RecBufClear(101);
  GV.Alpha.01 # Adr.A.Stichwort;

  // Anschrift...
  if (RecLink(101,253,3,0)>_rLockeD) then RecBufClear(101);

  if (aMark=n) then begin
    if (Art.J.InventurYN) then
      Lib_GuiCom:ZLColorLine(gZLList,_WinColLightBlue);
  end;

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
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;



//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ    :  alpha(1000);
end
begin

  if ((aName =^ 'edArt.J.Charge') AND (aBuf->Art.J.Charge<>'')) then begin
    RekLink(252,253,2,2);   // int Charge holen
    Lib_Guicom2:JumpToWindow('Art.C.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.J.Ziel.Artikelnr') AND (aBuf->Art.J.Ziel.Artikelnr<>'')) then begin
    RekLink(250,253,1,0);   // int Artikel Nr. holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edArt.J.Ziel.Charge') AND (aBuf->Art.J.Ziel.Charge<>'')) then begin
    RekLink(252,253,6,2);   // int Charge holen
    Lib_Guicom2:JumpToWindow('Art.C.Verwaltung');
    RETURN;
  end;
  if ((aName =^ 'edArt.J.Ziel.Zustand') AND (aBuf->Art.J.Ziel.Zustand<>0)) then begin
    RekLink(856,253,9,0);   // Zustand holen
    Lib_Guicom2:JumpToWindow('Art.ZSt.Verwaltung');
    RETURN;
  end;
  if ((aName =^ 'edArt.J.Ziel.Adressnr') AND (aBuf->Art.J.Ziel.Adressnr<>0)) then begin
    RekLink(100,253,8,0);   // Lager ort holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;
  if ((aName =^ 'edArt.J.Ziel.Anschrift') AND (aBuf->Art.J.Ziel.Anschrift<>0)) then begin
    RecLink(101,253,7,2);
    Adr.A.Adressnr # Art.J.Ziel.Adressnr;
    Adr.A.Nummer # Art.J.Ziel.Anschrift;
    RecRead(101,1,0);
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Art.J.Ziel.Adressnr);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung',vQ);
    RETURN;
  end;
  if ((aName =^ 'edArt.J.Ziel.Lagrplatz') AND (aBuf->Art.J.Ziel.Lagrplatz<>'')) then begin
    LPl.Lagerplatz # Art.J.Ziel.Lagrplatz;
    RecRead(844,1,0)
    Lib_Guicom2:JumpToWindow('LPl.Verwaltung');
    RETURN;
  end;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================