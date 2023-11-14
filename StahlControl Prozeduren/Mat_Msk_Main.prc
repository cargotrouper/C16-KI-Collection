@A+
//==== Business-Control ==================================================
//
//  Prozedur    Mat_Msk_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2008  AI  Erstellung der Prozedur
//  06.05.2011  TM  neue Auswahlmethode 1326/75
//  13.03.2012  AI  Materialstatus wird auf gepserrtWEBetrieb gesetzt
//  10.09.2015  AH  "Eigenmaterial"-Haken
//  30.10.2015  ST  Stückzahlberechnung hinzugefügt
//  17.10.2016  ST  AFX "Mat.WE.Auswahl.Lieferant" hinzugefügt
//  21.11.2018  ST  Anpassung Etikettensetting
//  28.11.2018  AH  AFX "Mat.Msk.Init.Pre"
//  21.01.2019  AH  AFX "Mat.WE.RecSave.Post"
//  27.07.2021  AH  ERX
//  31.03.2023  DB  Adr.Nummer zu Set.eigeneAdressnr geändert, um nur Lagerorte für die eigene Adresse anzuzeigen
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusEinzelObfOben()
//    SUB AusEinzelObfUnten()
//    SUB AusSpediteur()
//    SUB AusPositionen()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int): logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
  cTitle :    'Material'
  cFile :     200
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Mat_Msk'
  cZList :    0
  cKey :      1
end;

declare Auswahl(aBereich : alpha)

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

  SetStdAusFeld('edMat.Warengruppe'     ,'Warengruppe');
  SetStdAusFeld('edMat.Guete'           ,'Guete');
  SetStdAusFeld('edMat.Guetenstufe'     ,'Guetenstufe');
  SetStdAusFeld('edMat.Verwiegungsart'  ,'Verwiegungsart');
  SetStdAusFeld('edMat.Lieferant'       ,'Lieferant');
  SetStdAusFeld('edMat.Lageranschrift'  ,'Lageranschrift');
  SetStdAusFeld('edMat.Lagerplatz'      ,'Lagerplatz');
  SetStdAusFeld('edMat.AF.Oben'         ,'AF.Oben');
  SetStdAusFeld('edMat.AF.Unten'        ,'AF.Unten');

  RunAFX('Mat.Msk.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  if (RunAFX('Mat.WE.Pflicht','')>=0) then begin
    Lib_GuiCom:Pflichtfeld($edMat.Eingangsdatum);
    Lib_GuiCom:Pflichtfeld($edMat.Lieferant);
    Lib_GuiCom:Pflichtfeld($edMat.Warengruppe);
    Lib_GuiCom:Pflichtfeld($edMat.Guete);
    Lib_GuiCom:Pflichtfeld($edMat.Lageranschrift);
    Lib_GuiCom:Pflichtfeld($edMat.Bestand.Stk);
    Lib_GuiCom:Pflichtfeld($edMat.Gewicht.Netto);
    Lib_GuiCom:Pflichtfeld($edMat.Gewicht.Brutto);
    Lib_GuiCom:Pflichtfeld($edMat.Verwiegungsart);
  end;

  //Lib_GuiCom:Pflichtfeld($);
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
  vTmp  : int;
end;
begin

  // RecInit?
  if ($NB.Main->wpcustom='') then begin
    $NB.Main->wpcustom # 'x';
    Call('Mat_Msk_Main:RecInit');
  end;

  $RL.AFOben->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
  $RL.AFUnten->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);

  if (aName='edMat.Guete') and ($edMat.Guete->wpchanged) then begin
    MQu_Data:Autokorrektur(var "Mat.Güte");
    Mat.Werkstoffnr # MQU.Werkstoffnr;
    $edMat.Guete->Winupdate();
  end;
  if (aName='') or (aName='edMat.Lieferant') then begin

    Erx # RecLink(100,200,4,0);
    if (Erx<=_rLocked) and (Mat.Lieferant<>0) then begin
      $Lb.Lieferant2->wpcaption # Adr.Stichwort;
      Mat.LieferStichwort # Adr.Stichwort;
    end
    else begin
      Mat.LieferStichwort # '';
      Mat.Lieferant # 0;
      $Lb.Lieferant2->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edMat.Warengruppe') then begin
    Mat.Dichte # 0.0;
    Erx # RecLink(819,200,1,0);
    if (Erx<=_rLocked) then begin
      $Lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1;
      Mat.Dichte # Wgr_Data:GetDichte(Wgr.Nummer, 200);
    end
    else begin
      $Lb.Warengruppe->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edMat.Lageradresse') or (aName='edMat.Lageranschrift') then begin
    Erx # RecLink(101,200,6,0);
    if (Erx<=_rLocked) and (Mat.Lageradresse<>0) then begin
      $Lb.Lagerort2->wpcaption # Adr.A.Stichwort
      Mat.LagerStichwort # Adr.A.Stichwort;
    end
    else begin
      Mat.LagerStichwort # '';
      Mat.Lageradresse # 0;
      Mat.Lageranschrift # 0;
      $Lb.Lagerort2->wpcaption # '';
    end;
  end;

  if (aName='') or (aName='edMat.Verwiegungsart') then begin
    Erx # RecLink(818,200,10,0);
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VwA.NettoYN # y;
    end;
    $Lb.Verwiegungsart->wpcaption # VwA.Bezeichnung.L1
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin

//  RecBufclear(200); 22.10.2020 AH, macht der Aufrufer schon und kann so etwas vorbelegen!

  // Focus setzen auf Feld:
  $edMat.Lieferant->WinFocusSet(true);

  Mat.Nummer          # myTmpNummer;
  Mat.Status          # c_Status_EKgesperrtBetrieb;
  Mat.Lageradresse    # Set.eigeneAdressnr;
  Mat.Lageranschrift  # 1;
  Mat.Eingangsdatum   # today;
//  Mat.MEH             # 't';
// 07.02.2017 AH
  Mat.MEH             # 'kg';

  // Ankerfunktion?
  RunAFX('Mat.WE.RecInit','');

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx   : int;
  vNr   : int;
  vPos  : word;
  vAFX  : int;
  vHdl  : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  vAFX # RunAFX('Mat.WE.RecSave','');

  if (vAFX<0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end
  else begin

    if (Mat.Eingangsdatum=0.0.0) then begin
      Msg(001200,Translate('Eingangsdatum'),0,0,0);
      $edMat.Eingangsdatum->WinFocusSet(true);
      RETURN false;
    end;

    If (Mat.Lieferant=0) then begin
      Msg(001200,Translate('Lieferant'),0,0,0);
      $edMat.Lieferant->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(100,200,4,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Lieferant'),0,0,0);
      $edMat.Lieferant->WinFocusSet(true);
      RETURN false;
    end;

    If (Mat.Warengruppe=0) then begin
      Msg(001200,Translate('Warengruppe'),0,0,0);
      $edMat.Warengruppe->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(819,200,1,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Warengruppe'),0,0,0);
      $edMat.Warengruppe->WinFocusSet(true);
      RETURN false;
    end;

    If ("Mat.Güte"='') then begin
      Msg(001200,Translate('Güte'),0,0,0);
      $edMat.Guete->WinFocusSet(true);
      RETURN false;
    end;

    If (Mat.Lageradresse=0) then begin
      Msg(001200,Translate('Lagerort'),0,0,0);
      $edMat.Lageranschrift->WinFocusSet(true);
      RETURN false;
    end;
    Erx # RecLink(101,200,6,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Lagerort'),0,0,0);
      $edMat.Lageranschrift->WinFocusSet(true);
      RETURN false;
    end;

    if (Mat.Verwiegungsart=0) then begin
      Msg(001200,Translate('Verwiegungsart'),0,0,0);
      $edMat.Verwiegungsart->WinFocusSet(true);
      RETURN false;
    end;
    if (Mat.Verwiegungsart<>0) then begin
      Erx # RecLink(818,200,10,0);
      If (Erx>_rLocked) then begin
        Msg(001201,Translate('Verwiegungsart'),0,0,0);
        $edMat.Verwiegungsart->WinFocusSet(true);
        RETURN false;
      end;
    end;

    If (Mat.Bestand.Stk=0) then begin
      Msg(001200,Translate('Stückzahl'),0,0,0);
      $edMat.Bestand.Stk->WinFocusSet(true);
      RETURN false;
    end;
    If (Mat.Gewicht.Brutto=0.0) or (Mat.Gewicht.Netto=0.0) then begin
      Msg(001200,Translate('Gewicht'),0,0,0);
      $edMat.Gewicht.Brutto->WinFocusSet(true);
      RETURN false;
    end;

  end;


  // Nummernvergabe
  vNr # Lib_Nummern:ReadNummer('Material');
  if (vNr<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;

  TRANSON;

  // Ausführungen kopieren
  WHILE (RecLink(201,200,11,_RecFirst)=_rOk) do begin
    RecRead(201,1,_recLock);
    Mat.AF.Nummer # vNr;
    Erx # RekReplace(201,_recUnlock,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;
  END;

  Mat.Nummer    # vNr;
  Mat.Ursprung  # vNr;

  if (Mat.EigenmaterialYN) then "Mat.Übernahmedatum" # Mat.Eingangsdatum;

  Mat_Data:SetStatus(c_Status_EKgesperrtBetrieb);

  Erx # Mat_Data:Insert(_RecUnlock,'MAN', Mat.Eingangsdatum);
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN False;
  end;

  TRANSOFF;

  RunAFX('Mat.RecSave.Post','');

  // Etikettendruck?

  vHdl # varInfo(WindowBonus);


  // ST 2018-11-21: Das Setting "Set.MAt.WE.Etikett" existiert nicht mehr
  Set.Mat.WE.Etikett # Set.Ein.WE.Etikett;

  if (Set.Mat.WE.Etikett<>0) then begin
    if (Set.Mat.WE.Etikett=999) then
      Mat_Etikett:Etikett(0,y,1)
    else
      Mat_Etikett:Etikett(Set.Mat.WE.Etikett,y,1)
  end
  else begin
    if (Set.Ein.WE.Etikett<>0) then
      Mat_Etikett:Etikett(Set.Ein.WE.Etikett,y,1)
  end;

  if (RunAFX('Mat.WE.RecSave.Post','')<0) then begin
    if (AfxRes<>_rOK) then RETURN false;
  end;

  VarInstance(WindowBonus,vHdl);


  Mode # c_modeCancel;  // sofort alles beenden!
  gSelected # 1;

  RETURN true;  // Speichern erfolgreich

end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
local begin
  Erx : int;
end;
begin

  // ALLE Positionen verwerfen
  if (Mode=c_ModeNew) then begin
    // Ausführungen kopieren
    WHILE (RecLink(201,200,11,_RecFirst)=_rOk) do begin
      Erx # RekDelete(201,0,'MAN');
    END;
  end;

  gSelected # 0;
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
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
local begin
  Erx : int;
end;
begin

  if (aEvt:obj->wpname='edMat.AF.Oben') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','200|1');
  if (aEvt:obj->wpname='edMat.AF.Unten') and (aEvt:Obj->wpchanged) then
    RunAFX('Obf.Changed','200|2');


  if (aEvt:Obj->wpname='edLfs.Spediteurnr') and ($edLfs.Spediteurnr->wpchanged) then begin
    Erx # RecLink(100,440,6,_RecFirst);
    if (Erx=_rOK) then
      Lfs.Spediteur # Adr.Stichwort
    else
      Lfs.Spediteur # ''
    $edLfs.Spediteur->Winupdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->wpname='edMat.Lieferant') and (aEvt:Obj->wpchanged) then begin
    RunAFX('Mat.WE.Auswahl.Lieferant','');
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
  Erx     : int;
  vA      : alpha;
  vFilter : int;
  vQ      : alpha(4000);
  vTmp    : int;
  vHdl    : int;
end;
begin

  case aBereich of
   'Warengruppe' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '=', 200);
      Lib_Sel:QInt(var vQ, '"Wgr.Dateinummer"', '=', 209, 'OR');
      Lib_Sel:QRecList(0, vQ);

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Guete'          : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Mat.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Guetenstufe'          : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VWa.Verwaltung',here+':AusVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferant'      : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusLieferant');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lageranschrift' : begin
      RecLink(100,200,5,0);
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusLageranschrift');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      // 31-03-2023 DB Adr.Nummer zu Set.eigeneAdressnr geändert, um nur Lagerorte für die eigene Adresse anzuzeigen
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Set.eigeneAdressnr);
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


    'Lagerplatz'   : begin
      RecBufClear(844);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusLagerplatz');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Oben'        : begin
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      vTmp # RecLinkInfo(201,200,11,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfOben');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFOben');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
      gZLList->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '1';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AF.Unten'       : begin
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      vTmp # RecLinkInfo(201,200,11,_Reccount,vFilter);
      RecFilterDestroy(vFilter);
      if (vTmp=0) and ("Set.Wie.Obj.!autoF9"=false) then begin
        RecBufClear(841);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusEinzelObfUnten');
        Lib_GuiCom:RunChildWindow(gMDI);
        RETURN;
      end;
      RecBufClear(201);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFUnten');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vFilter # RecFilterCreate(201,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
      gZLlist->wpDbFilter # vFilter;
      vTmp # winsearch(gMDI, 'NB.Main');
      vTmp->wpcustom # '2';
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusEinzelObfOben
//
//========================================================================
sub AusEinzelObfOben()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(201);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFOben');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(201,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, '1');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '1';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusEinzelObfUnten
//
//========================================================================
sub AusEinzelObfUnten()
local begin
  vFilter : int;
  vTmp    : int;
end;
begin
  if (gSelected<>0) then begin

    RecBufClear(201);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.AF.Verwaltung',here+':AusAFUnten');
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    vFilter # RecFilterCreate(201,1);
    vFilter->RecFilterAdd(1,_FltAND,_FltEq, Mat.Nummer);
    vFilter->RecFilterAdd(2,_FltAND,_FltEq, '2');
    gZLList->wpDbFilter # vFilter;
    vTmp # winsearch(gMDI, 'NB.Main');
    vTmp->wpcustom # '2';

    Mode # c_modeBald + c_modeNew;
    w_Command   # 'SETOBF:';
    w_cmd_para  # aint(gSelected);
    gSelected   # 0;

    Lib_GuiCom:RunChildWindow(gMDI);

    RETURN;
  end;
end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edMat.Warengruppe->Winfocusset(false);
  RefreshIfm('edMat.Warengruppe');
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Mat.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Mat.Güte" # "MQu.Güte1"
    else
      "Mat.Güte" # "MQu.Güte2";
    Mat.Werkstoffnr # MQu.Werkstoffnr;
    gSelected # 0;
  end;
  // Focus setzen:
  $edMat.Guete->Winfocusset(false);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Mat.Gütenstufe" # MQu.S.Stufe;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  // Focus auf Editfeld setzen:
  $edMat.Guetenstufe->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusAFOben
//
//========================================================================
sub AusAFOben()
local begin
  vA    : alpha;
end;
begin
  gSelected # 0;

  vA # Obf_Data:BildeAFString(200,'1');
  if (vA<>"Mat.AusführungOben") then RunAFX('Obf.Changed','200|1');
  "Mat.AusführungOben" # vA;

  // Focus auf Editfeld setzen:
  $edMat.AF.Oben->Winfocusset(true);
end;


//========================================================================
//  AusAFUnten
//
//========================================================================
sub AusAFUnten()
local begin
  vA    : alpha;
end;
begin
  gSelected # 0;

  vA # Obf_Data:BildeAFString(200,'2');
  if (vA<>"Mat.AusführungUnten") then RunAFX('Obf.Changed','200|2');
  "Mat.AusführungUnten" # vA;

  // Focus auf Editfeld setzen:
  $edMat.AF.Unten->Winfocusset(true);
end;


//========================================================================
//  AusLieferant
//
//========================================================================
sub AusLieferant()
local begin
  Erx : int;
end;
begin

  if (gSelected<>0) then begin
    Erx # RecRead(100, 0, _recId, gSelected);
    // Feldübernahme
    Mat.Lieferant # Adr.Lieferantennr;
    Mat.LieferStichwort # Adr.Stichwort;
    gSelected # 0;
  end;
  // Focus setzen:
  $edMat.Lieferant->Winfocusset(false);
  RunAFX('Mat.WE.Auswahl.Lieferant','');

  RefreshIfm('edMat.Lieferant');
end;


//========================================================================
//  AusLageranschrift
//
//========================================================================
sub AusLageranschrift()
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lageradresse # Adr.A.Adressnr;
    Mat.Lageranschrift # Adr.A.Nummer;
    Mat.LagerStichwort # Adr.A.Stichwort;
    gSelected # 0;
  end;
  // Focus setzen:
  $edMat.Lageranschrift->Winfocusset(false);
  RefreshIfm('edMat.Lageranschrift');
end;


//========================================================================
//  AusLagerplatz
//
//========================================================================
sub AusLagerplatz()
begin
  if (gSelected<>0) then begin
    RecRead(844,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Lagerplatz # Lpl.Lagerplatz;
    gSelected # 0;
  end;
  // Focus setzen:
  $edMat.Lagerplatz->Winfocusset(false);
  RefreshIfm('edMat.Lagerplatz');
end;


//========================================================================
//  AusVerwiegungsart
//
//========================================================================
sub AusVerwiegungsart()
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    // Feldübernahme
    Mat.Verwiegungsart # VwA.Nummer;
    gSelected # 0;
  end;

  // Focus setzen:
  $edMat.Verwiegungsart->Winfocusset(false);
  RefreshIfm('edMat.Verwiegungsart');
end;



//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Mat_Loeschen]=n);

  if (Mode<>c_ModeOther) and (aNoRefresh=n) then RefreshIfm();

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
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Ktx.Errechnen' : begin
      if (aEvt:Obj->wpname='edMat.Bestand.Stk') then begin
        Mat.Bestand.Stk # Lib_Berechnungen:STK_aus_KgDBLWgrArt(Mat.Gewicht.Netto, Mat.Dicke, Mat.Breite, "Mat.länge", Mat.Warengruppe, "Mat.Güte", Mat.Strukturnr);
        $edMat.Bestand.Stk->winupdate(_WinUpdFld2Obj);
      end;
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
    'bt.Warengruppe'      :   Auswahl('Warengruppe');
    'bt.Guete'            :   Auswahl('Guete');
    'bt.Guetenstufe'      :   Auswahl('Guetenstufe');
    'bt.Verwiegungsart'   :   Auswahl('Verwiegungsart');
    'bt.Lieferant'        :   Auswahl('Lieferant');
    'bt.Lageranschrift'   :   Auswahl('Lageranschrift');
    'bt.Lagerplatz'       :   Auswahl('Lagerplatz');
    'bt.AFOben'           :   Auswahl('AF.Oben');
    'bt.AFUnten'          :   Auswahl('AF.Unten');
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
//  Refreshmode(y);
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
//========================================================================
//========================================================================
//========================================================================
