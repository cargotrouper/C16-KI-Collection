@A+
//==== Business-Control ==================================================
//
//  Prozedur    GPl_Main
//                      OHNE E_R_G
//  Info
//
//
//  24.05.2007  AI  Erstellung der Prozedur
//  25.08.2014  AH  Bugfix: Materialselektion für Zugfestigkeit
//  18.05.2020  ST  Customfelder und Init,DataLst, RefreshIfm Anker hinzugefügt
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha; optaChanged : logic)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusSelAuftrag();
//    SUB AusAuftrag();
//    SUB AusSelMaterial();
//    SUB AusMaterial();
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged(aEvt : event; aRect : rect;	aClientSize : point; aFlags : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cTitle      : 'Grobplanung'
  cFile       : 600
  cMenuName   : 'GPl.Bearbeiten'
  cPrefix     : 'GPl'
  cZList      : $ZL.GPl
  cZListMat   : $ZL.GPL.P.Mat
  cZListAuf   : $ZL.GPL.P.Auf
  cKey        : 1
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
  gZLList   # cZList;
  gKey      # cKey;


  if (Set.Mech.Dehnung.Wie=1) then
    $edGPl.Auf.DehnungA2->wpcustom # '_N';
  if (Set.Mech.Dehnung.Wie=2) then
    $edGPl.Auf.DehnungB2->wpcustom # '_N';


  Lib_GuiCom:RecallList(cZListMat);
  Lib_GuiCom:RecallList(cZListAuf);


  RunAFX('Gpl.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Gpl.Init',aint(aEvt:Obj));
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
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
  opt aChanged : logic;
)
local begin
  vTmp  : int;
end;
begin

  GV.Int.01   # GPl.Nummer;
  GV.Ints.01  # 200;
  GV.Ints.02  # 401;

  cZListMat->WinUpdate(_WinUpdOn, _WinLstFromFirst);// _WinLstRecFromRecId|_WinLstRecDoSelect);
  cZListAuf->WinUpdate(_WinUpdOn, _WinLstFromFirst);// _WinLstRecFromRecId|_WinLstRecDoSelect);
  if (Mode=c_ModeNew) then begin
    cZListMat->wpdisabled # y;
    cZListAuf->wpdisabled # y;
    $bt.Ins.Mat->wpdisabled   # y;
    $bt.Ins.Auf->wpdisabled   # y;
    $bt.Del.Mat->wpdisabled   # y;
    $bt.Del.Auf->wpdisabled   # y;
    end
  else begin
    cZListMat->wpdisabled # n;
    cZListAuf->wpdisabled # n;
    $bt.Ins.Mat->wpdisabled   # n;
    $bt.Ins.Auf->wpdisabled   # n;
    $bt.Del.Mat->wpdisabled   # n;
    $bt.Del.Auf->wpdisabled   # n;
    $edGPl.Sum.Mat.Stk->winupdate(_WinUpdFld2Obj);
    $edGPl.Sum.Mat.Gewicht->winupdate(_WinUpdFld2Obj);
    $edGPl.Sum.Auf.Stk->winupdate(_WinUpdFld2Obj);
    $edGPl.Sum.Auf.Gewicht->winupdate(_WinUpdFld2Obj);
  end;

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
  
  
  RunAFX('Gpl.RefreshIfm.Post',aName);
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);

  if (Mode=c_ModeNew) then begin
    GPl.Auf.Dicke.bis     # 999999.00;
    Gpl.Auf.Breite.bis    # 999999.00;
    "GPl.Auf.Länge.Bis"   # 999999.00;
    GPl.Auf.WGr.Bis       # 9999;

    GPl.Auf.Streckgrenz2  # 9999.0;
    GPl.Auf.Zugfestig2    # 9999.0;
    GPl.Auf.DehnungA2     # 9999.0;
    GPl.Auf.DehnungB2     # 9999.0;
    GPl.Auf.DehngrenzeA2  # 9999.0;
    GPl.Auf.DehngrenzeB2  # 9999.0;
    "GPl.Auf.Körnung2"    # 9999.0;
    "GPl.Auf.Härte2"      # 9999.0;
    GPl.Auf.RauigkeitA2   # 9999.0;
    GPl.Auf.RauigkeitB2   # 9999.0;
    GPl.Auf.Chemie.C2     # 9999.0;
    GPl.Auf.Chemie.Si2    # 9999.0;
    GPl.Auf.Chemie.Mn2    # 9999.0;
    GPl.Auf.Chemie.P2     # 9999.0;
    GPl.Auf.Chemie.S2     # 9999.0;
    GPl.Auf.Chemie.Al2    # 9999.0;
    GPl.Auf.Chemie.Cr2    # 9999.0;
    GPl.Auf.Chemie.V2     # 9999.0;
    GPl.Auf.Chemie.Nb2    # 9999.0;
    GPl.Auf.Chemie.Ti2    # 9999.0;
    GPl.Auf.Chemie.N2     # 9999.0;
    GPl.Auf.Chemie.Cu2    # 9999.0;
    GPl.Auf.Chemie.Ni2    # 9999.0;
    GPl.Auf.Chemie.Mo2    # 9999.0;
    GPl.Auf.Chemie.B2     # 9999.0;
    GPl.Auf.Chemie.Frei2  # 9999.0;
  end;

  // Focus setzen auf Feld:
  $edGPl.Bezeichnung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin

    GPl.Nummer # Lib_Nummern:ReadNummer('Grobplanung');
    if (GPl.Nummer<>0) then Lib_Nummern:SaveNummer()
    else RETURN false;

    GPl.Anlage.Datum  # Today;
    GPl.Anlage.Zeit   # Now;
    GPl.Anlage.User   # gUserName;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

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
//  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
//    RekDelete(gFile,0,'MAN');
//  end;
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
  vA    : alpha;
end;

begin

  case aBereich of
    //'...' : begin
    //  RecBufClear(xxx);         // ZIELBUFFER LEEREN
    //  gMDI # Lib_GuiCom:AddChildWindow(gMDI, xxx.Verwaltung',here+':Aus...');
    //  ggf. VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
    //  Lib_GuiCom:RunChildWindow(gMDI);
    //end;
  end;

end;


//========================================================================
//  AusSelAuftrag
//
//========================================================================
sub AusSelAuftrag()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vQ2   : alpha(4000);
  vQ3   : alpha(4000);
  vSel  : int;
end;
begin


  RecRead(600,1,_RecLock);
  GPl.Auf.WGr.Von         # Sel.Auf.Von.WGr;
  GPl.Auf.WGr.bis         # Sel.Auf.bis.WGr;
  "GPl.Auf.Güte"          # "Sel.Auf.Güte";
  //"Sel.Auf.Gütenstufe"    # "GPl.Auf.gütestufe";
  GPl.Auf.Dicke.Von       # Sel.Auf.von.Dicke;
  GPl.Auf.Dicke.Bis       # Sel.Auf.bis.Dicke;
  GPl.Auf.Breite.Von      # Sel.Auf.von.Breite;
  GPl.Auf.Breite.bis      # Sel.Auf.bis.Breite;
  "GPl.Auf.Länge.Von"     # "Sel.Auf.von.Länge";
  "GPl.Auf.Länge.bis"     # "Sel.Auf.bis.Länge";
  RekReplace(600,_recunlock,'AUTO');


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  // BESTAND-Selektion öffnen
  // Selektionsquery für 401
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Auf.P.Nummer', '<', 1000000000);
  if (Sel.Auf.von.Nummer != 0) or (Sel.Auf.bis.Nummer != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer);
  if (Sel.Auf.von.ZTermin != 0.0.0) or (Sel.Auf.bis.ZTermin != 01.01.2010) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin);
  if (Sel.Auf.von.WTermin != 0.0.0) or (Sel.Auf.bis.WTermin != 1.1.2010) then
    Lib_Sel:QVonBisD(var vQ, 'Auf.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin);
  if (Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt(var vQ, 'Auf.P.Kundennr', '=', Sel.Auf.Kundennr);
  if ("Sel.Auf.Güte" != '') then
    Lib_Sel:QAlpha(var vQ, '"Auf.P.Güte"', '=*', "Sel.Auf.Güte");
  if (Sel.Auf.von.Dicke != 0.0) or (Sel.Auf.bis.Dicke != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke);
  if (Sel.Auf.von.Breite != 0.0) or (Sel.Auf.bis.Breite != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite);
  if ("Sel.Auf.von.Länge" != 0.0) or ("Sel.Auf.bis.Länge" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Auf.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge");
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.Wgr != 0) or (Sel.Auf.bis.Wgr != 9999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr);
  if (Sel.Auf.von.Projekt != 0) or (Sel.Auf.bis.Projekt != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt);
  if (Sel.Auf.Artikelnr != '') then
    Lib_Sel:QAlpha(var vQ, 'Auf.P.Artikelnr', '=', Sel.Auf.Artikelnr);
  if (Sel.Auf.von.RID != 0.0) or (Sel.Auf.bis.RID != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.RID', Sel.Auf.von.RID, Sel.Auf.bis.RID);
  if (Sel.Auf.von.RAD != 0.0) or (Sel.Auf.bis.RAD != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Auf.P.RID', Sel.Auf.von.RAD, Sel.Auf.bis.RAD);

  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ((Auf.P.Zugfestigkeit1 <= Sel.Mat.bis.Zugfest AND Auf.P.Zugfestigkeit2 >= Sel.Mat.von.Zugfest) '+
            ' OR  (Auf.P.Zugfestigkeit1 = 0.0 AND Auf.P.Zugfestigkeit2 = 0.0)) '

  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 400
  Lib_Sel:QAlpha(var vQ2, 'Auf.Vorgangstyp', '=', c_AUF);
  if (Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha(var vQ2, 'Auf.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit);
  if (Sel.Auf.Vertreternr != 0) then
    Lib_Sel:QInt(var vQ2, 'Auf.Vertreter', '=', Sel.Auf.Vertreternr);
  if (Sel.Auf.von.Datum != 0.0.0) or (Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ2, 'Auf.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum);

  // Rahmen/Abruf/Normal?
  if (Sel.Auf.RahmenYN<>y) or (Sel.Auf.AbrufYN<>y) or (Sel.Auf.NormalYN<>y) then begin
    if (vQ2<>'') then vQ2 # vQ2 + ' AND ';
    if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N AND Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N AND Auf.AbrufYN=Y'
    else if (Sel.Auf.RahmenYN=n) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=Y) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=N';
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + 'Auf.LiefervertragYN=Y AND Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=n) and (Sel.Auf.NormalYN=y) then
      vQ2 # vQ2 + 'Auf.AbrufYN=N'
    else if (Sel.Auf.RahmenYN=y) and (Sel.Auf.AbrufYN=y) and (Sel.Auf.NormalYN=n) then
      vQ2 # vQ2 + '(Auf.LiefervertragYN=Y OR Auf.AbrufYN=Y)'
    else
      vQ2 # 'Auf.AbrufYN<>Auf.AbrufYN';
  end;

  // 15.10.2009 MS Berechnungsmarker hinzugefuegt
  if((Sel.Auf.BerechenbYN = true) and ("Sel.Auf.!BerechenbYN" = false))
  or ((Sel.Auf.BerechenbYN = false) and ("Sel.Auf.!BerechenbYN" = true)) then begin
    if(Sel.Auf.BerechenbYN = true) and ("Sel.Auf.!BerechenbYN" = false) then
      Lib_Sel:QAlpha(var vQ2, 'Auf.P.Aktionsmarker', '=', '$');
    else if (Sel.Auf.BerechenbYN = false) and ("Sel.Auf.!BerechenbYN" = true) then
      Lib_Sel:QAlpha(var vQ2, 'Auf.P.Aktionsmarker', '!=', '$');
  end;

  // Selektionsquery für 402
  vQ3 # '';
  if (Sel.Auf.ObfNr != 0) or (Sel.Auf.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ3, 'Auf.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2);

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate(401, gKey);
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  vSel->SelAddLink('', 402, 401, 11, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf', vQ2);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ3);
  if (Erx != 0) then Lib_Sel:QError(vSel);

  // speichern, starten und Name merken...
  W_SelName # Lib_Sel:SaveRun(var vSel, 0,n );
  // Liste selektieren...
  gZLList->wpDbSelection # vSel;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusAuftrag
//
//========================================================================
sub AusAuftrag()
begin
  if (gSelected<>0) then begin
//    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    GPl_P_List:InsertMarkAuf();
    cZListAuf->WinUpdate(_WinUpdOn, _WinLstFromFirst);
    cZListMat->WinUpdate(_WinUpdOn, _WinLstFromFirst);
//    Ein.P.Kommission # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
  end;
  // Focus auf Editfeld setzen:
  gMdi->WinUpdate(_WinUpdFld2Obj);
end;



//========================================================================
//  AusSelMaterial
//
//========================================================================
sub AusSelMaterial()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vQ1   : alpha(4000);
  vSel  : int;
end;
begin
  RecBufClear(200);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  // BESTAND-Selektion
  vQ  # '';
  vQ1 # '';

  if ("Sel.Mat.von.Dicke"  != 0.0) or ("Sel.Mat.bis.Dicke"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Dicke"',         "Sel.Mat.von.Dicke", "Sel.Mat.bis.Dicke");
  if ("Sel.Mat.von.Breite" != 0.0) or ("Sel.Mat.bis.Breite" != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Breite"',        "Sel.Mat.von.Breite", "Sel.Mat.bis.Breite");
  if ("Sel.Mat.von.Länge"  != 0.0) or ("Sel.Mat.bis.Länge"  != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, '"Mat.Länge"',         "Sel.Mat.von.Länge", "Sel.Mat.bis.Länge");
  if ("Sel.Mat.von.ÜDatum" != 0.0.0) or ("Sel.Mat.bis.ÜDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Übernahmedatum"', "Sel.Mat.von.ÜDatum", "Sel.Mat.bis.ÜDatum");
  if ("Sel.Mat.von.EDatum" != 0.0.0) or ("Sel.Mat.bis.EDatum" != today) then
    Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', "Sel.Mat.von.EDatum", "Sel.Mat.bis.EDatum");
  if ("Sel.Mat.von.ADatum" != 0.0.0) or ("Sel.Mat.bis.ADatum" != today) then
      Lib_Sel:QVonBisD(var vQ, '"Mat.Ausgangsdatum"', "Sel.Mat.von.ADatum", "Sel.Mat.bis.ADatum");
  if ("Sel.Mat.von.Status" != 0) or ("Sel.Mat.bis.Status" != 999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Status"',        "Sel.Mat.von.Status", "Sel.Mat.bis.Status");
  if ("Sel.Mat.von.WGr"    != 0) or ("Sel.Mat.bis.WGr"    != 9999) then
    Lib_Sel:QVonBisI(var vQ, '"Mat.Warengruppe"',   "Sel.Mat.von.WGr",    "Sel.Mat.bis.WGr");
  if ("Sel.Art.von.ArtNr"  != '') or ("Sel.Art.bis.ArtNr"  != 'zzzzz') then
    Lib_Sel:QVonBisA(var vQ, '"Mat.Strukturnr"',    "Sel.Art.von.ArtNr",  "Sel.Art.bis.ArtNr");
  if (!"Sel.Mat.mit.gelöscht") then
    Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');

  if ("Sel.Mat.Güte" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat.Güte"', '=*', "Sel.Mat.Güte");
  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ, '"Mat.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");
  if (Sel.Mat.Strukturnr != '') then
    Lib_Sel:QAlpha(var vQ, 'Mat.Strukturnr', '=', Sel.Mat.Strukturnr);
  if (Sel.Mat.Lieferant != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', Sel.Mat.Lieferant);
  if (Sel.Mat.Lagerort != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagertExtern) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '<>', Set.eigeneAdressnr);
  if (Sel.Mat.LagerAnschri != 0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri);
  if (Sel.Mat.von.RID != 0.0) or (Sel.Mat.bis.RID != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Mat.RID', Sel.Mat.von.RID, Sel.Mat.bis.RID);
  if (Sel.Mat.von.RAD != 0.0) or (Sel.Mat.bis.RAD != 999999.00) then
    Lib_Sel:QVonBisF(var vQ, 'Mat.RID', Sel.Mat.von.RAD, Sel.Mat.bis.RAD);

  if (Sel.Mat.ObfNr != 0) then
    vQ # vQ + ' AND LinkCount(Ausf) > 0';

  if ("Sel.Mat.EigenYN") AND (!"Sel.Mat.!EigenYN") then
    vQ # vQ + ' AND Mat.EigenmaterialYN';
  else if (!"Sel.Mat.EigenYN") AND ("Sel.Mat.!EigenYN") then
    vQ # vQ + ' AND !Mat.EigenmaterialYN';

  if ("Sel.Mat.BestelltYN") and (!"Sel.Mat.!BestelltYN") then
    vQ # vQ + ' AND Mat.Bestellt.Gew > 0';
  else if (!"Sel.Mat.BestelltYN") and ("Sel.Mat.!BestelltYN") then
    vQ # vQ + ' AND Mat.Bestellt.Gew = 0';

  if ("Sel.Mat.ReservYN") and (!"Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND Mat.Reserviert.Gew > 0';
  else if (!"Sel.Mat.ReservYN") and ("Sel.Mat.!ReservYN") then
    vQ # vQ + ' AND Mat.Reserviert.Gew = 0';

  if ("Sel.Mat.KommissionYN") and (!"Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Auftragsnr > 0';
    end
  else if (!"Sel.Mat.KommissionYN") and ("Sel.Mat.!KommissioYN") then begin
    if (vQ<>'') then vQ # vQ + ' AND ';
    vQ # vQ + 'Mat.Auftragsnr = 0';
  end;

  vQ # '(' + vQ + ') AND (Mat.Zugfestigkeit1 = 0 OR (Mat.Zugfestigkeit1 between[' + CnvAF(Sel.Mat.von.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ',' + CnvAF(Sel.Mat.bis.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + '])';
  vQ # vQ + ' AND (Mat.Zugfestigkeit1 between[' + CnvAF(Sel.Mat.von.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ',' + CnvAF(Sel.Mat.bis.Zugfest, _fmtNumNoGroup | _fmtNumPoint) + ']) )';

  if (Sel.Mat.ObfNr != 0) or (Sel.Mat.ObfNr2 != 999) then
    Lib_Sel:QVonBisI(var vQ1, 'Mat.Af.ObfNr', Sel.Mat.ObfNr, Sel.Mat.ObfNr2);

  vSel # SelCreate(200, gKey);
  if (vQ1<>'') then
    vSel->SelAddLink('', 201, 200, 11, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  if (vQ1<>'') then begin
    Erx # vSel->SelDefQuery('Ausf', vQ1);
    if (Erx <> 0) then Lib_Sel:QError(vSel);
  end;

  // speichern, starten und Name merken...
  W_SelName # Lib_Sel:SaveRun(var vSel, 0,n );
  // Liste selektieren...
  gZLList->wpDbSelection # vSel;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusMaterial
//
//========================================================================
sub AusMaterial()
begin
  if (gSelected<>0) then begin
//    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    GPl_P_List:InsertMarkMat();
    cZListAuf->WinUpdate(_WinUpdOn, _WinLstFromFirst);
    cZListMat->WinUpdate(_WinUpdOn, _WinLstFromFirst);
//    Ein.P.Kommission # AInt(Auf.P.Nummer) + '/' + AInt(Auf.P.Position);
  end;
  // Focus auf Editfeld setzen:
  gMdi->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);


  // Kopfrefresh...
  if (mode<>c_modeview) then begin
    // Button & Menßs sperren
    vHdl # gMdi->WinSearch('New');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_GPl_Anlegen]=n);
    vHdl # gMenu->WinSearch('Mnu.New');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_GPl_Anlegen]=n);

    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_GPl_Aendern]=n);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_GPl_Aendern]=n);

    vHdl # gMdi->WinSearch('Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_GPl_Loeschen]=n);
    vHdl # gMenu->WinSearch('Mnu.Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # y;//(vHdl->wpDisabled) or (Rechte[Rgt_GPl_Loeschen]=n);

    if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();
    RETURN;
  end;


  // Positionerefresh...
  if (mode=c_modeview) then begin
    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # ("GPL.P.Löschmarker"<>'');
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # ("GPL.P.Löschmarker"<>'');

    if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();
    RETURN;
  end;

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

    'Druck.Planung' : begin
      Lib_Dokumente:Printform(600,'Grobplanung',true);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,GPl.Anlage.Datum, GPl.Anlage.Zeit, GPl.Anlage.User);
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


  end; // case

end;


//========================================================================
//  EvtMouseItem
//
//========================================================================
sub EvtMouseItem(
  aEvt      : event; // Ereignis
  aButton   : int;   // Maustaste
  aHitTest  : int;   // Hittest-Code
  aItem     : int;   // Spalte oder Gantt-Intervall
  aID       : int;   // RecID bei RecList / Zeile bei GanttGraph
) : logic
local begin
  Erx : int;
end;
begin

  if (aID <> 0 AND aItem <> 0 AND
    aButton & (_WinMouseLeft | _WinMouseDouble) =
    (_WinMouseLeft | _WinMouseDouble)) then begin

    if (aItem->wpcustom<>'_SKIP') then RETURN Lib_RecList2:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);

    RecRead(601,0,_recId, aID);

    if (aEvt:obj=cZListMat) then begin
      if (Rechte[Rgt_Material]=False) then RETURN true;

      Mat.Nummer    # GPL.P.ID1;
      Erx # RecRead(200,1,0);
      if (Erx<=_rLocked) then begin
        Lib_GuiCom:RePos(var gMDIMat, 'Mat.Verwaltung', RecInfo(200,_recId),y);
      end;
    end;


    if (aEvt:obj=cZListAuf) then begin
//todo('hops auf');
      // Fenster bereits offen??
      if (Rechte[Rgt_Auftrag]=False) then RETURN true;

      Auf.P.Nummer    # GPL.P.ID1;
      Auf.P.Position  # GPL.P.ID2;
      Erx # RecRead(401,1,0);
      if (Erx<=_rLocked) then begin
        Lib_GuiCom:RePos(var gMDIauf, 'Auf.P.Verwaltung', RecInfo(401,_recId),y);
      end;
/*****
      if (gMDIAuf<>0) then begin
        VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
        if (Mode<>c_ModeList) and (Mode<>c_modeView) then begin
          VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
          RETURN false;
        end;
        vHdl # gZLList->wpDbSelection;
        if (w_SelName<>'') and (vHdl<>0) then begin
          gZLList->wpautoupdate # false;
          gZLList->wpdbselection # 0;
          SelClose(vHdl);
          SelDelete(gFile,w_selName);
        end;
      end;
debug('hops:'+aInt(gpl.p.id1)+'/'+aint(gpl.p.id2));
      Auf.P.Nummer    # GPL.P.ID1;
      Auf.P.Position  # GPL.P.ID2;
      Erx # RecRead(401,1,0);
      if (Erx<=_rLocked) then begin

        vRecID # RecInfo(401,_recID);

        if (gMDIAuf=0) then begin
          gMDIAuf # Lib_GuiCom:OpenMdi(gFrmMain, 'Auf.P.Verwaltung', _WinAddHidden);
          vNew # y;
        end;

        VarInstance(WindowBonus,cnvIA(gMDIAuf->wpcustom));
        w_Command   # 'REPOS';
        w_Cmd_Para  # aInt(vRecId);
        vList # gZLList;
        mode # c_modeBald+c_ModeView
        vHdl # Winsearch(gMDIAuf,'NB.Main');
        if (vNew) then begin
          gMDIAuf->WinUpdate(_WinUpdOn);
          end
        else begin
          vHdl->WinFocusSet(true);
          RecRead(401,0,_recId, vRecID);
          vList->Winupdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
          gMDIAuf->WinFocusSet(true);
        end;
      end;
****/

    end;
  end;

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  Erx : int;
end;
begin

  if (Mode<>c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of

    'bt.Ins.Mat'  : begin

      if (GPl_P_List:InsertMarkMat()=0) then begin

        RecBufClear(998);
        Sel.Mat.von.Wgr       # GPl.Auf.WGr.von;
        Sel.Mat.bis.WGr       # GPl.Auf.WGr.bis;
        "Sel.Mat.Gütenstufe"  # "GPl.Auf.GütenStufe";
        "Sel.Mat.Güte"        # "GPl.Auf.Güte";
        Sel.Mat.bis.Status    # c_status_bisFrei;
        Sel.Mat.von.Dicke     # GPl.Auf.Dicke.Von;
        Sel.Mat.bis.Dicke     # GPl.Auf.Dicke.bis;
        Sel.Mat.von.Breite    # GPl.Auf.Breite.Von;
        Sel.Mat.bis.Breite    # GPl.Auf.Breite.bis;
        "Sel.Mat.von.Länge"   # "GPl.Auf.Länge.von";
        "Sel.Mat.bis.Länge"   # "GPl.Auf.Länge.bis";
        "Sel.Mat.bis.ÜDatum"  # today;
        "Sel.Mat.bis.EDatum"  # today;
        "Sel.Mat.bis.ADatum"  # today;
        "Sel.von.Datum"       # 0.0.0;
        "Sel.Mat.EigenYN"     # y;
        "Sel.Mat.ReservYN"    # y;
        "Sel.Mat.BestelltYN"  # y;
        "Sel.Mat.!EigenYN"    # y;
        "Sel.Mat.!ReservYN"   # y;
        "Sel.Mat.!BestelltYN" # y;
        "Sel.Mat.KommissionYN" # y;
        "Sel.Mat.!KommissioYN" # y;
        Sel.Mat.von.Obfzusat  # 'zzzzz';
        "Sel.Mat.bis.ZugFest" # 9999.0;
        "Sel.Art.bis.ArtNr"   # 'zzzzz';
        "Sel.Mat.Mit.Gelöscht" # N;

//        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Material','Mat_Mark_Sel:AusSel');
        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Material',here+':AusSelMaterial');
        Lib_GuiCom:RunChildWindow(gMDI);

        RETURN true;
      end;
      RefreshIfm();
      RETURN true;
    end;


    'bt.Ins.Auf'  : begin
      if (GPl_P_List:InsertMarkAuf()=0) then begin

        RecBufClear(998);
        Sel.Auf.ObfNr2          # 999;
        Sel.Auf.bis.Nummer      # 99999999;
        Sel.Auf.bis.Datum       # today;
        Sel.Auf.bis.WTermin     # DateMake(31,12,DateYear(today)+1);
        Sel.Auf.bis.AufArt      # 9999;

        Sel.Auf.Von.WGr         # GPl.Auf.WGr.Von;
        Sel.Auf.bis.WGr         # GPl.Auf.WGr.bis;
        "Sel.Auf.Güte"          # "GPl.Auf.güte";
        "Sel.Auf.Gütenstufe"    # "GPl.Auf.gütenstufe"; // Gütenstufe [22.10.2009/PW]

        Sel.Auf.bis.DruckDat   # DateMake(31,12,DateYear(today)+1);
        Sel.Auf.bis.LiefDat    # DateMake(31,12,DateYear(today)+1);
        Sel.Auf.bis.ZTermin    # DateMake(31,12,DateYear(today)+1);
        Sel.Auf.bis.Projekt    # 99999999;
        Sel.Auf.bis.Kostenst   # 99999999;

        Sel.Auf.von.Dicke      # GPl.Auf.Dicke.Von;
        Sel.Auf.bis.Dicke      # GPl.Auf.Dicke.Bis;
        Sel.Auf.von.Breite     # GPl.Auf.Breite.Von;
        Sel.Auf.bis.Breite     # GPl.Auf.Breite.bis;
        "Sel.Auf.von.Länge"    # "GPl.Auf.Länge.Von";
        "Sel.Auf.bis.Länge"    # "GPl.Auf.Länge.bis";

        Sel.Auf.von.Obfzusat   # 'zzzzz';
        "Sel.Mat.bis.Zugfest"  # 9999.0;
        Sel.Auf.RahmenYN       # n;
        Sel.Auf.AbrufYN        # y;
        Sel.Auf.NormalYN       # y;
        Sel.Auf.BerechenbYN    # y;
        "Sel.Auf.!BerechenbYN" # y;

        gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Auftrag',here+':AusSelAuftrag');
        Lib_GuiCom:RunChildWindow(gMDI);

        RETURN true;
      end;
      RefreshIfm();
      RETURN true;
    end;


    'bt.Del.Mat'  : begin
      Erx # RecRead(601,0,_recid,cZListMat->wpdbRecID);
      if (Erx<=_rLocked) then begin
        GPl_P_List:RecDel();
        RefreshIfm();
        RETURN true;
      end;
    end;


    'bt.Del.Auf'  : begin
      Erx # RecRead(601,0,_recid,cZListAuf->wpdbRecID);
      if (Erx<=_rLocked) then begin
        GPl_P_List:RecDel();
        RefreshIfm();
        RETURN true;
      end;
    end;

  end;  // case


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
//  Refreshmode();

  // Sonderfunktion:
  if (aMark) then begin
    if (RunAFX('Gpl.EvtLstDataInit','y')<0) then RETURN;
  end
  else begin
    if (RunAFX('Gpl.EvtLstDataInit','n')<0) then RETURN;
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
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin

  Lib_GuiCom:RememberList(cZListMat);
  Lib_GuiCom:RememberList(cZListAuf);
  RETURN true;
end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
  vRect2    : rect;
  vI        : int;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin

    vRect           # gZLList->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28;
    gZLList->wparea # vRect;

    vRect           # $GroupSplit1->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    Vi              # aRect:bottom-aRect:Top-28;
    vRect:bottom    # vI;
    $GroupSplit1->wparea # vRect;

/***
    vRect           # $GroupSplit1->wpArea;
    vRect:right     # aRect:right-aRect:left-4;
    Vi              # aRect:bottom-aRect:Top-28;
    vRect:bottom    # vI;
    $GroupSplit1->wparea # vRect;

    vRect           # cZListAuf->wpArea;
    vRect2          # $gt.Auftrag->wparea;
    vRect:right     # aRect:right-aRect:left-4;
//    vRect:bottom    # (vI + 22 - aRect:Top ) / 2;
    vRect:Bottom    # vRect2:bottom - vRect2:top;
    cZListAuf->wparea # vRect;

    vRect           # cZListMat->wpArea;
    vRect2          # $gt.Material->wparea;
    vRect:right     # aRect:right-aRect:left-4;
//    vRect:bottom    # (vI + 22 - aRect:Top ) / 2;
    vRect:Bottom    # vRect2:bottom - vRect2:top;
    cZListMat->wparea # vRect;
***/

  end;

	RETURN (true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================