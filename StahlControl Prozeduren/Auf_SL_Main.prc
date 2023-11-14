@A+
//==== Business-Control ==================================================
//
//  Prozedur    Auf_SL_Main
//                  OHNE E_R_G
//  Info
//
//
//  02.12.2004  AI  Erstellung der Prozedur
//  14.11.2014  AH  Überarbeitet
//  22.01.2015  AH  Erweiterung um Skizzen
//  07.04.2015  AH  Menü "Material zuornden"
//  18.05.2015  AH  Artikeltyp SET
//  20.05.2015  AH  AFX "Auf.SL.RecSave.Post"
//  04.04.2022  AH  ERX
//  15.07.2022  HA  Qucik Jump
//
//  Subprozeduren
//    SUB MaxWerte()
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB ZieheArtikel()
//    SUB Skizzendaten();
//    SUB BerechneAus(aTyp : alpha);
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusMatzMat()
//    SUB AusMatzArtC()
//    SUB AusArtikelnummer()
//    SUB AusEKPreis()
//    SUB AusReservierung()
//    SUB RefreshMode(opt aNoRefresh : logic; opt aChanged : logic,);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_aktionen
@I:Def_BAG

define begin
  cTitle :    'Stückliste'
  cFile :     409
  cMenuName : 'Auf.SL.Bearbeiten'
  cPrefix :   'Auf_SL'
  cZList :    'ZL.Auf.Stueckliste'
  cKey :      1
end;

declare BerechneAus(aTyp : alpha);
declare RefreshIfm(opt aName : alpha; opt aChanged : logic)

//========================================================================
//  MaxWerte
//========================================================================
sub MaxWerte();
local begin
  Erx       : int;
  vTodoStk  : int;
  vStk      : int;
  vBuf409   : int;
  vB,vL     : float;
end;
begin

  vBuf409 # RekSave(409);

  vB  # Auf.P.Breite;
  vL  # "Auf.P.Länge";
  if (vL=0.0) then vL # vB;

  vTodoStk # "Auf.P.Stückzahl";
  Erx # RecLink(409,401,15,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (vB<>0.0) and (vL<>0.0) then begin
      vStk # cnvif(Trn(Auf.SL.Breite / Auf.P.Breite));
      vStk # vStk * cnvif(Trn("Auf.SL.Länge" / vL));
      vTodoStk # vTodoStk - (vStk * "Auf.SL.Stückzahl");
    end;
    Erx # RecLink(409,401,15,_recNext);
  END;
  RekRestore(vBuf409);

  // diesen Satz errechnen...
  if (vB<>0.0) and (vL<>0.0) then begin
    vStk # cnvif(Trn(Auf.SL.Breite / vB));
    vStk # vStk * cnvif(Trn("Auf.SL.Länge" / vL));
  end;
  if (vStk<>0) then
    "Auf.SL.Stückzahl" # vToDoStk / vStk;
  if ("Auf.SL.Stückzahl" * vStk < vTodoStk) then "Auf.SL.Stückzahl" # "Auf.SL.Stückzahl" + 1;

  Berechneaus('STK');
end;


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
  gZLList   # winsearch(aEvt:Obj,cZList);
  gKey      # cKey;

  RekLink(250,401,2,_recfirst);   // Pos-Artikel holen
  if (Art.Typ=c_Art_SET) then begin
    $edAuf.SL.Artikelnummer->wpcustom # '';
    $bt.Artikel->wpcustom             # '';
  end;

Lib_Guicom2:Underline($edAuf.SL.Artikelnummer);
Lib_Guicom2:Underline($edAuf.SL.Skizzennummer);

  SetStdAusFeld('edAuf.SL.Artikelnummer' ,'Artikel');
  SetStdAusFeld('edAuf.SL.MEH.EK'        ,'EKMEH');
  SetStdAusFeld('edAuf.SL.PreisW1.EK'    ,'EKPreis');
  SetStdAusFeld('edAuf.SL.Skizzennummer' ,'Skizze');

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
  //Lib_GuiCom:Pflichtfeld($);
end;


//========================================================================
//  ZieheArtikel();
//========================================================================
sub ZieheArtikel()
begin
//  RekLink(250,401,2,_recfirst);   // Artikel holen
  RekLink(250,409,3,_recfirst);   // Artikel holen
  Art.SL.Artikelnr      # ARt.Nummer;
  Auf.SL.MEH            # Art.MEH;//Auf.P.MEH.Einsatz;
  if (Art_P_Data:FindePreis('Ø-EK', 0, 0.0, '', 1)=false) then
    Art_P_Data:FindePreis('EK', 0, 0.0, '', 1);
//    Art_P_Data:FindePreis('L-EK', Adr.Nummer, 0.0, '', 1);
  Auf.SL.MEH.EK         # Art.P.MEH;
  Auf.SL.PEH.EK         # Art.P.PEH;
  Auf.SL.PreisW1.EK     # Art.P.PreisW1;
  Auf.SL.Dicke          # Art.Dicke;
  Auf.SL.Breite         # Art.Breite;
  "Auf.SL.Länge"        # "Art.Länge";
end;


//========================================================================
//  Skizzendaten
//
//========================================================================
sub Skizzendaten();
local begin
  vZ : int;
  vA : alpha;
  vX : int;
  vUmfang : float;
  vA3,vA4,vA5 : alpha;
end;
begin
  // SPEZI
  gMDI->wpdisabled # y;
  FOR vX # 1 loop inc(vX) WHILE (vX<=Skz.Anzahl.Variablen) do begin
    vA # StrChar(64+vX);
    Dlg_Standard:Anzahl(Translate('Variable')+' '+vA,var vZ,0,300,200);
    vUmfang # vUmfang + cnvfi(vZ);
    case (vX%3) of
      0 : if (vA5='') then
            vA5 # vA + '='+cnvai(vZ)
          else
            vA5 # vA5 +',  '+ vA + '='+cnvai(vZ);
      1 : if (vA3='') then
            vA3 # vA + '='+cnvai(vZ)
          else
            vA3 # vA3 +',  '+ vA + '='+cnvai(vZ);
      2 : if (vA4='') then
            vA4 # vA + '='+cnvai(vZ)
          else
            vA4 # vA4 +',  '+ vA + '='+cnvai(vZ);
    end;
  END;

  gMDI->wpdisabled # n;

  $edAuf.SL.Skizzennummer->Winfocusset(false);
  Auf.SL.VpgText4 # vA3;
  Auf.SL.VpgText5 # vA4;
  Auf.SL.VpgText6 # vA5;
  $edAuf.SL.VpgText4->winupdate(_WinUpdFld2Obj);
  $edAuf.SL.VpgText5->winupdate(_WinUpdFld2Obj);
  $edAuf.SL.VpgText6->winupdate(_WinUpdFld2Obj);

  "Auf.SL.Länge" # vUmfang;// * cnvfi("Prj.SL.Stückzahl");
  $edAuf.SL.Laenge->winupdate(_WinUpdFld2Obj);

  Refreshifm('edAuf.SL.Laenge', true);
end;


//========================================================================
// BerechneAus
//
//========================================================================
sub BerechneAus(aTyp : alpha);
local begin
  Erx : int;
end;
begin
  Erx # RekLink(250,409,3,_recFirst);   // Artikel holen

  if (aTyp='ABM') or (aTyp='STK') then begin
    if (Auf.SL.Gewicht=0.0) then begin
      Auf.SL.Gewicht # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', 'kg');
      if (Auf.SL.MEH='Stk') or (Auf.SL.MEH='t') or (Auf.SL.MEH='kg') then
        Auf.SL.Menge   # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', Auf.SL.MEH);
    end;
  end;

  if (aTyp='MENGE') then begin
    if ("Auf.SL.Stückzahl"=0) then begin
      "Auf.SL.Stückzahl"  # cnvif(Lib_Einheiten:WandleMEH(409, 0, 0.0, Auf.SL.Menge, Auf.SL.MEH, 'Stk'));
    end;
    if (Auf.SL.Gewicht=0.0) then begin
      Auf.SL.Gewicht      # Lib_Einheiten:WandleMEH(409, 0, 0.0, Auf.SL.Menge, Auf.SL.MEH, 'kg');
    end;
  end;

  if (aTyp='GEW') then begin
    if ("Auf.SL.Stückzahl"=0) then begin
      "Auf.SL.Stückzahl"  # cnvif(Lib_Einheiten:WandleMEH(409, 0, Auf.SL.Gewicht, 0.0, '', 'Stk'));
      if (Auf.SL.MEH='Stk') or (Auf.SL.MEH='t') or (Auf.SL.MEH='kg') then
        Auf.SL.Menge        # Lib_Einheiten:WandleMEH(409, 0, Auf.SL.Gewicht, 0.0, '', Auf.SL.MEH);
    end;
  end;

/*
  Auf.SL.Gewicht # Rnd(Auf.SL.Gewicht,Set.Stellen.Gewicht);
  if (Art.MEH='Stk') then Auf.SL.Menge # cnvfi("Auf.SL.Stückzahl");
  if (Art.MEH='kg') then Auf.SL.Menge # Rnd(Auf.SL.Gewicht ,Set.STellen.Menge);
//todo(aTyp+' '+cnvaf(auf.sl.menge)+ '  '+cnvaf(auf.sl.gewicht));
*/
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
  Erx   : int;
  vTmp  : int;
end;
begin

  if (WGr.Nummer<>Auf.P.Warengruppe) then RekLink(819,401,1,_recfirst);   // Warengruppe holen
  if (Auf.SL.MEH<>'Stk') and (Auf.SL.MEH<>'t') and (Auf.SL.MEH<>'kg') then begin
    $lbAuf.SL.Menge->wpvisible # true;
    $edAuf.SL.Menge->wpvisible # true;
    $lb.MEH->wpvisible # true;
  end
  else begin
    $lbAuf.SL.Menge->wpvisible # false;
    $edAuf.SL.Menge->wpvisible # false;
    $lb.MEH->wpvisible # false;
  end;
  
  if (aName='') or
    ((aName='edAuf.SL.Artikelnummer') and ($edAuf.SL.Artikelnummer->wpchanged)) then begin

    if ($edAuf.SL.Artikelnummer->wpchanged) then begin

      Auf.SL.Menge        # 0.0;
      "Auf.SL.Stückzahl"  # 0;
      Auf.SL.Gewicht      # 0.0;

      ZieheArtikel();

      $edAuf.SL.MEH.EK->winupdate(_WinUpdFld2Obj);
      $edAuf.SL.PEH.EK->winupdate(_WinUpdFld2Obj);
      $edAuf.SL.Preisw1.EK->winupdate(_WinUpdFld2Obj);
      $edAuf.SL.Dicke->winupdate(_WinUpdFld2Obj);
      $edAuf.SL.Breite->winupdate(_WinUpdFld2Obj);
      $edAuf.SL.Laenge->winupdate(_WinUpdFld2Obj);
    end;
    Erx # RekLink(250,409,3,_recFirst);   // Artikel holen
    if (Art.MEH<>'qm') and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) then begin
      Auf.SL.Breite # 0.0;
      Lib_GuiCom:Disable($edAuf.SL.Breite);
    end
    else begin
      if (Mode<>c_ModeView) then Lib_GuiCom:Enable($edAuf.SL.Breite);
    end;
    $lb.ArtikelSW->wpcaption # Art.Stichwort;
  end;

  if (aName='edAuf.SL.Laenge') and ((aChanged) or ($edAuf.Sl.Laenge->wpchanged)) then begin
    if (Auf.SL.Gewicht=0.0) then
      Auf.SL.Gewicht # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', 'kg');
    Auf.SL.Menge   # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', Auf.SL.MEH);

    $edAuf.SL.Gewicht->winupdate(_WinUpdFld2Obj);
//    $lb.Menge->wpcaption # ANum(Auf.SL.Menge,2);
//    $lb.Menge->Winupdate();
    $edAuf.SL.Menge->Winupdate(_WinUpdFld2Obj);
    RETURN;
  end;

/**
  if (Mode=c_modeEdit) or (Mode=c_ModeNew) then begin
    if (aName='edAuf.SL.Stckzahl') or
     (aName='edAuf.SL.Laenge') or
     (aName='edAuf.SL.Breite') then begin

      Auf.SL.Gewicht # "Art.GewichtProStk" * Cnvfi("Auf.SL.Stückzahl");
      if ("Auf.SL.Länge"<>0.0) and ("Art.Länge"<>0.0) then
        Auf.SL.Gewicht # Auf.SL.Gewicht / "Art.Länge" * "Auf.SL.Länge";
      if ("Auf.SL.Breite"<>0.0) and ("Art.Breite"<>0.0) then
        Auf.SL.Gewicht # Auf.SL.Gewicht / "Art.Breite" * "Auf.SL.Breite";

    Art_data:BerechneFelder(var "Auf.SL.Stückzahl", var Auf.SL.Gewicht, var Auf.SL.Menge, Auf.P.MEH.Einsatz);

    end;
    $lb.Gewicht->wpcaption # cnvaf(Auf.SL.Gewicht);
  end;
***/

//  $clmAuf.SL.Menge->wpcaption # Translate('Gesamt')+' '+Art.MEH;
//  $clmGv.Num.01   ->wpcaption # Translate('Unverplant')+' '+Art.MEH;
  $lb.MEH->wpcaption # Auf.SL.MEH;
/*
  if (Art.MEH='qm') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge"*Auf.SL.Breite / 1000000.0;
  end
  else
  if (Art.MEH='mm') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge";
  end
  else
  if (Art.MEH='m') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge" / 1000.0;
  end;
  if (Art.MEH='kg') then begin
    Auf.SL.Menge # Auf.SL.Gewicht;
  end;
  if (Art.MEH='t') then begin
    Auf.SL.Menge # Auf.SL.Gewicht / 1000.0;
  end;
*/

  if (aName='') or
    ((aName='edAuf.SL.Skizzennummer') and ($edAuf.SL.Skizzennummer->wpchanged)) then begin
    Erx # RecLink(829,409,6,_recFirst);          // Skizze holen
    if (Erx<>_rOK) then begin
      $Picture2->wpcaption # '';
    end
    else begin
      $Picture2->wpcaption # '*'+Skz.Dateiname;
      $Picture2->Winupdate();
    end;
  end;


//  $lb.Menge->wpcaption # ANum(Auf.SL.Menge,2);
//  $lb.Menge->Winupdate();

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
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
  // Felder Disablen durch:

  Erx # RekLink(250,409,3,_recFirst);   // ARtikel holen
  if (Erx>_rLocked) then RecBufClear(250);
  if (Art.MEH<>'qm') and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false) then begin
    Auf.SL.Breite # 0.0;
    Lib_GuiCom:Disable($edAuf.SL.Breite);
  end
  else begin
    Lib_GuiCom:Enable($edAuf.SL.Breite);
  end;
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    Auf.SL.Nummer         # Auf.P.Nummer;
    Auf.SL.Position       # Auf.P.Position;
    Auf.SL.lfdNr          # 1;
    Auf.SL.ArtikelNr      # Auf.P.Artikelnr;
    ZieheArtikel();
    $edAuf.SL.MEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.PEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Preisw1.EK->winupdate(_WinUpdFld2Obj);

    Maxwerte();
  end;

  // Focus setzen auf Feld:
  RekLink(250,401,2,_recfirst);   // Pos-Artikel holen
  if (Art.Typ=c_Art_SET) then $edAuf.SL.Artikelnummer->WinFocusSet(true)
  else $edAuf.SL.Dicke->WinFocusSet(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vMenge  : float;
  vTmp    : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  Erx # RekLink(250,409,3,_recFirst);   // ARtikel holen
/*
  if (Erx>_rLocked) then RecBufClear(250);
  if (Art.MEH='kg') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge"*Auf.SL.Breite*Auf.SL.Dicke*Art.SpezGewicht / 1000000.0;
  end
  else
  if (Art.MEH='qm') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge"*Auf.SL.Breite / 1000000.0;
  end
  else
  if (Art.MEH='mm') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge";
  end
  else
  if (Art.MEH='m') then begin
    Auf.SL.Menge # CnvFI("Auf.SL.Stückzahl")*"Auf.SL.Länge" / 1000.0;
  end;
*/
  if (Auf.SL.Menge<=0.0) or (Auf.SL.MEH='') then begin
    Msg(001200,Translate('Menge'),0,0,0);
    vTmp # gMdi->Winsearch('NB.Main');
    vTmp->wpcurrent # 'NB.Kopf';
    $edAuf.SL.Stckzahl->WinFocusSet(true);
    RETURN false;
  end;

//  if (Auf.SL.MEH.='Stk') or (Auf.SL.MEH='t') or (Auf.SL.MEH='kg') then begin
  vMenge # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", Auf.SL.Gewicht, Auf.SL.Menge, Auf.SL.MEH, Auf.SL.MEH.EK);
//  end;
  Auf.SL.Gesamtwert.EK # 0.0;
  if (Auf.SL.PEH.EK<>0) then
    Auf.SL.Gesamtwert.EK # vMenge * Auf.SL.PreisW1.EK / cnvfi(Auf.SL.PEH.EK);

  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    ERx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin

//    Auf.SL.Rest.Menge   # Auf.SL.Menge;
//    "Auf.SL.Rest.Stück" # "Auf.SL.Stückzahl";
//    Auf.SL.Rest.Gewicht # Auf.SL.Gewicht;

    Auf.SL.lfdNr # 1;
    WHILE (RecRead(409,1,_RecTest)<=_rLocked) do
      Auf.SL.lfdNr # Auf.SL.lfdNR + 1;

    Auf.SL.Anlage.Datum  # Today;
    Auf.Sl.Anlage.Zeit   # Now;
    Auf.SL.Anlage.User   # gUserName;

    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (Auf.SL.Nummer<1000000000) then
      Auf_SL_Data:Reservieren(n);

  end;

  if (RunAFX('Auf.SL.RecSave.Post','')<>0) then
    RETURN (AfxRes=_rOK);

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
    if (Auf.SL.Nummer<1000000000) then
      Auf_SL_Data:Reservieren(y);

    RekDelete(gFile,0,'MAN');
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
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

  if (aEvt:Obj->wpname='edAuf.SL.Breite') and ($edAuf.SL.Breite->wpchanged) then begin
    BerechneAus('ABM');
  end;
  if (aEvt:Obj->wpname='edAuf.SL.Laenge') and ($edAuf.SL.Laenge->wpchanged) then begin
    BerechneAus('ABM');
  end;
  if (aEvt:Obj->wpname='edAuf.SL.Stckzahl') and ($edAuf.SL.Stckzahl->wpchanged) then begin
    BerechneAus('STK');
    $edAuf.SL.Gewicht->winupdate(_WinUpdFld2Obj);
  end;
  if (aEvt:Obj->wpname='edAuf.SL.Gewicht') and ($edAuf.SL.Gewicht->wpchanged) then begin
    BerechneAus('GEW');
    $edAuf.SL.Stckzahl->winupdate(_WinUpdFld2Obj);
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
  vHdl  : int;
  vQ    : alpha(4000);
end;
begin

  case aBereich of

    'Matz.Mat' : begin
      RecLink(400,401,3,_recFirst);   // Kopf holen
      if ("Auf.P.Löschmarker"='*') or (Auf.Vorgangstyp<>c_AUF) or
        ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)=false) and (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)=false)) then begin
        Msg(200400,'',0,0,0);
        RETURN;
      end;

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMatzMat' ,n,n, '401');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Sel.Mat.von.Status # c_Status_Frei;
      Sel.Mat.bis.Status # c_Status_bisFrei;

      vQ # '';
      Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');
      // 13.01.2015
      if (Wgr_data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr', '=', Auf.P.Artikelnr);
      end;
      Lib_Sel:QVonBisI(var vQ, 'Mat.Status', Sel.Mat.von.Status, Sel.Mat.bis.Status);
      vQ # '(' + vQ +') OR (Mat.Auftragsnr=Auf.P.Nummer)';
      Lib_Sel:QRecList(0,vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Matz.ArtC' : begin
      if (Auf.SL.ArtikelNr='') then RETURN;

      Erx # RecLink(250,409,3,_RecFirst); // Artikel holen
      if (Erx>_rlockeD) then RETURN;

      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusMatzArtC');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
      Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
      Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
      Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
      vHdl # SelCreate(252, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Skizze' : begin
      RecBufClear(829);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Skz.Verwaltung',here+':AusSkizze');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKMEH' : begin
      Lib_Einheiten:Popup('MEH',$edAuf.SL.MEH.EK,409,1,15);
    end;


    'Artikel' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusArtikelnummer');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      gKey # 1;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKPreis' : begin
      if (Auf.SL.ArtikelNr='') then RETURN;
      Erx # RekLink(250,409,3,_RecFirst); // Artikel holen
      RecBufClear(254);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.P.Verwaltung',here+':AusEKPreis');
      Art_P_Main:Selektieren(gMDI, Art.Nummer, 0);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  AusMatzMat
//
//========================================================================
sub AusMatzMat()
local begin
  vStk      : int;
  vProzent  : float;
  vMenge    : float;
  vHdl      : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;

    if (Auf_Data:MatzMat(n,n,0,0.0,0.0,0.0,Auf.SL.LfdNr)=false) then begin
      ErrorOutput;
    end;
    vHdl # winsearch(gMDI,cZList);
    vHdl->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
    Auswahl('Matz.Mat');
  end;

  // Focus auf Editfeld setzen:
  // ggf. Labels refreshen
end;


//========================================================================
//  AusMatzArtC
//
//========================================================================
sub AusMatzArtC()
begin
  if (gSelected<>0) then begin
    RecRead(252,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
    Auf_Data_Buchen:MatzArt(Art.C.Artikelnr, Art.C.Adressnr,Art.C.Anschriftnr,Art.C.Charge.Intern,y,y,0.0,0,0.0); // mit SL
  end;
  // ggf. Labels refreshen
end;


//========================================================================
//  AusArtikelnummer
//
//========================================================================
sub AusArtikelnummer()
begin
  if (gSelected<>0) then begin
    RecRead(250,0,_RecId,gSelected);
    gSelected # 0;
    // Feld∑bernahme
    Auf.SL.Artikelnr      # Art.Nummer;
    Auf.SL.Menge          # 0.0;
    "Auf.SL.Stückzahl"    # 0;
    Auf.SL.Gewicht        # 0.0;
    Auf.SL.MEH            # Art.MEH;

    ZieheArtikel();

    $edAuf.SL.MEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.PEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Preisw1.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Dicke->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Breite->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Laenge->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAuf.SL.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusEKPreis
//
//========================================================================
sub AusEKPreis()
begin
  if (gSelected<>0) then begin
    RecRead(254,0,_RecId,gSelected);
    gSelected # 0;
    // Feld∑bernahme
    Auf.SL.MEH.EK         # Art.P.MEH;
    Auf.SL.PEH.EK         # Art.P.PEH;
    Auf.SL.PreisW1.EK     # Art.P.PreisW1;
    $edAuf.SL.MEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.PEH.EK->winupdate(_WinUpdFld2Obj);
    $edAuf.SL.Preisw1.EK->winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edAuf.SL.PreisW1.EK->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusReservierung
//
//========================================================================
sub AusReservierung()
begin

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  gSelected # 0;

  // Focus auf Editfeld setzen:
  // $edAuf.SL.Artikelnummer->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusSkizze
//
//========================================================================
sub AusSkizze()
local begin
  vHdl  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(829,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Auf.SL.Skizzennummer # Skz.Nummer;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
    //   Focus auf Editfeld setzen:
    $edAuf.SL.Skizzennummer->Winfocusset(false);

    $Picture2->wpcaption # '*'+Skz.Dateiname;
    $Picture2->Winupdate();
    Skizzendaten();
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
  vTmp        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Auf_SL_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (w_Auswahlmode) or (Rechte[Rgt_Auf_SL_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Auf_SL_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Matz');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Auf_MATZ]=n) or
                    (Auf.Vorgangstyp<>c_AUF) or
                    (Auf.LiefervertragYN = true) or
                    ((Mode<>c_ModeView) and (Mode<>c_ModeList) and (Mode<>c_ModeNew2));

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Auf_Excel_Import]=false;

  vTmp # RecLinkInfo(409,401,15,_reccount)
  vHdl # gMenu->WinSearch('Mnu.Reservierung');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vTmp=0) or (Mode=c_ModeNew) or (Mode=c_ModeEdit) or (Auf.P.Nummer>1000000000);


  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

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
  Erx   : int;
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Matz' : begin
      if (Auf.SL.lfdNr=0) then RETURN true;
      Erx # RecLink(819,401,1,0);   // Warengruppe holen

      if ((Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr))) then begin
        Auswahl('Matz.Mat')
      end;

      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
        Erx # RecLink(250,409,3,_RecFirst); // Artikel holen
        if (Erx<=_rLocked) then begin
          RecBufClear(252);
          Art.C.ArtikelNr     # Auf.P.ArtikelNr;
          Art_Data:ReadCharge();
        end
        else begin
          RETURN false;
        end;

        Auswahl('Matz.ArtC');
      end;
    end;


    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edAuf.SL.Gewicht') then begin
        Auf.SL.Gewicht # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', 'kg');
        Auf.SL.Menge   # Lib_Einheiten:WandleMEH(409, "Auf.SL.Stückzahl", 0.0, 0.0, '', Auf.SL.MEH);
        $edAuf.SL.Gewicht->winupdate(_WinUpdFld2Obj);
//        $lb.Menge->wpcaption # ANum(Auf.SL.Menge,2);
//        $lb.Menge->Winupdate();
        $edAuf.SL.Menge->Winupdate(_WinUpdFld2Obj);
      end;
    end;


    'Mnu.Druck.SL.Etikett' : begin
      Lib_Dokumente:PrintForm(409,'Stuecklistenetikett',false);
    end;


    'Mnu.Reservierung' : begin
/***1910
      Erx # RecLink(250,409,3,_recFirst);   // Artikel holen
      if (Erx>_rlocked) then RETURN true;

      // mehre Chargen vorhanden?
      if (RecLinkInfo(252,250,4,_recCount)=1) then begin
        Auf_Data_Buchen:MatzArt(Art.Nummer, 0,0,'',y,y);
      end
      else begin
        RecBufClear(404);
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.SL.RV.Verwaltung','Auf_SL_Main:AusReservierung');
        Lib_GuiCom:RunChildWindow(gMDI);
      end;
***/
    end;

    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile);
    end;

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
    'bt.Artikel' :    Auswahl('Artikel');
    'bt.EKMEH' :      Auswahl('EKMEH');
    'bt.EKPreis' :    Auswahl('EKPreis');
    'bt.Skizze'  :    Auswahl('Skizze');
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
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin

  GV.Num.01 # Auf.SL.Menge - Auf.SL.Prd.Plan - Auf.SL.Prd.VSB - Auf.SL.Prd.LFS;//- Auf.SL.Prd.VSAuf
  if (Gv.Num.01<>0.0) then
    $clmGV.Num.01->WpclmColBkg # _WinCollightred

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
sub EvtClose
(
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
begin

  if ((aName =^ 'edAuf.SL.Artikelnummer') AND (aBuf->Auf.SL.ArtikelNr<>'')) then begin
    RekLink(250,409,3,0);   // Artikelnummer holen
    Lib_Guicom2:JumpToWindow('Art.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAuf.SL.Skizzennummer') AND (aBuf->Auf.SL.Skizzennummer<>0)) then begin
    RekLink(829,409,6,0);   // Skizze holen
    Lib_Guicom2:JumpToWindow('Skz.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================