@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lys_Msk_Main
//                    OHNE E_R_G
//  Info
//
//
//  17.01.2018  AH  Erstellung der Prozedur
//  20.12.2018  AH  "CheckVorgaben" mit aTxt
//  14.03.2019  AH  "CheckVorgaben" prüft nur einen Wert, wenn kein 2. vergeben und färbt beide Felder dann gleich
//  17.07.2020  AH  "CZ" als 2 Werte
//  18.11.2020  AH  Fix für Checks bei nicht Erwieterteranalyse
//  17.11.2021  AH  CheckAnalyse kann auch Vorabe-Labels befüllen (QS bei LZM)
//  2023-06-19  ST  Neu: Anker "Lys.Msk.Init.Pre" + "Lys.Msk.Init"
//
//  Subprozeduren
//    SUB Start(aReturnProc : alpha; aEdit : logic; aVorgang : alpha);
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic;
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cTitle :    'Analyse'
  cFile :     231
  cPrefix :   'Lys_Msk'
  cZList :    0
  cKey :      1
end;

declare Auswahl(aBereich : alpha)
declare CheckVorgaben(aName : alpha; aVorgabe : int; opt aTxt : int) : logic;

//========================================================================
//========================================================================
Sub Start(
  aReturnProc   : alpha;
  aEdit         : logic;
  aVorgang      : alpha;
  aGuete        : alpha;
  aGuetenstufe  : alpha;  // 04.02.2021
  aDicke        : float);
local begin
  vMode : alpha;
  vBuf  : int;
  vBuf2 : int;
  vHdl  : int;
end;
begin

  vMode # Mode;

  // DIN holen?
  MQU_Data:Read(aGuete, aGuetenstufe, y, aDicke);

  if (Mode=c_ModeView) then Lib_MoreBufs:ReadAll(gFile);
  vBuf # Lib_MoreBufs:GetBuf(231, '');

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, Lib_GuiCom:GetAlternativeName('Lys.Maske2'), aReturnProc);

  vHdl # WinSearch(gMDI, 'lb.Traeger');
  if (vHdl<>0) then
    vHdl->wpCaption # aVorgang;

  // gleich in Neuanlage....
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Mode # vMode;

  //Lib_GuiCom:SetMaskState(Mode = c_ModeNew or Mode = c_ModeEdit);
  Lib_GuiCom:SetMaskState(aEdit);
  w_CopyToBuf # vBuf;

  Lib_GuiCom:RunChildWindow(gMDI);
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
  gMenuName # 'STD.MoreBuf';
  gPrefix   # cPrefix;

  if (Set.Chemie.Titel.1<>'') then begin
    $lbLys.Chemie.Frei1->wpcaption # Set.Chemie.Titel.1;
  end;


  RunAFX('Lys.Msk.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('Lys.Msk.Init',aint(aEvt:Obj));
 
end;


//========================================================================
//  CheckAnalyse
//
//========================================================================
sub CheckAnalyse(
  aTxt          : int;
  aFeld         : alpha;
  aObj          : int;
  aName         : alpha;
  aO1           : int;
  aO2           : int;
  aVorgabe      : int;
  opt aLbObj    : int;
  ) : logic;
local begin
  vVon, vBis  : float;
  vName       : alpha;
  vA          : alpha;
  vName1      : alpha;
  vName2      : alpha;
  vWert1      : float;
  vWert2      : float;
  vOK         : logic;
  vIstFloat   : logic;
  vRes        : logic;
  vCol        : int;
end;
begin

  if (aVorgabe=-1) then begin
  //  todo('aOB=0 bei '+aFeld+' / '+aName);
    RETURN true;
  end;

  if (aO1<>0) then begin
    vName1  # aO1->wpname;
    vIstFloat # WinInfo(aO1,_Wintype)=_WinTypeFloatEdit;
    if (vIstFloat) then vWert1  # aO1->wpCaptionFloat;
  end;
  if (aO2<>0) then begin
    vName2  # aO2->wpname;
    if (vIstFloat) then vWert2  # aO2->wpCaptionFloat;
  end;

  vOK # (aFeld='');
  if (aO1<>0) then
    vOK # vOK or ((aFeld=vName1) and (aO1->wpchanged));
  if (aO2<>0) then
   vOK # vOK or ((aFeld=vName2) and (aO2->wpchanged));

  if (vOK=false) then RETURN true;

  vA # MQU_Data:BildeVorgabe(aName, aVorgabe, 'x', 0.0, var vVon, var vBis, true);  // Vorgaben-Buffer bereits geladen!
  if (aLbObj<>0) then aLbObj->wpcaption # vA;
//vVon # 10.0;
//vBis # 11.0;
//vA # 'Helptip '+aName;

  // Tooltip...
  if (vA<>'') and (aObj<>0) then begin
    aObj->wpColBkg # _WinColLightCyan;
    aObj->wpHelpTip # vA;
  end;
  if (aO1<>0) then
    aO1->wpHelpTip # vA;
  if (aO2<>0) then
    aO2->wpHelpTip # vA;

//*** PRÜFUNG
  vRes # true;
  if (vIstFloat) then begin
    vCol # _WinColLightRed;
    if ((vWert1 < vVon) and (vVon<>0.0)) or ((vWert1>vBis) and (vBis<>0.0)) then begin
      if (aO1<>0) then begin
        aO1->wpColBkg # vCol;
        vRes # false;
      end;
    end
    else begin
      if (aO1<>0) then begin
        if (aO1->wpReadOnly) then
          vCol # c_ColInactive
        else
          vCol # _WinColWindow;
        aO1->wpColBkg # vCol;
      end;
    end;

    // 14.03.2019 AH: wenn NUR 1. Wert gefüllt, dann 2.Wert gleich färben:
    if (vWert2=0.0) then begin
      if (aO2<>0) then
        aO2->wpColBkg # vCol;
    end
    else begin
      if ((vWert2 < vVon) and (vVon<>0.0)) or ((vWert2>vBis) and (vBis<>0.0)) then begin
        if (aO2<>0) then aO2->wpColBkg # _WinColLightRed;
      end
      else begin
        if (aO2<>0) then begin
          if (aO2->wpReadOnly) then
            aO2->wpColBkg # c_ColInactive
          else
            aO2->wpColBkg # _WinColWindow;
        end;
      end;
    end;

  end;

  // 20.12.2018
  if (vRes=false) and (aTxt<>0) then TextAddLine(aTxt, aName);
  
  RETURN vRes;
end;


//========================================================================
//  CheckVorgaben
//========================================================================
sub CheckVorgaben(
  aName       : alpha;
  aVorgabe    : int;
  opt aTxt    : int) : logic;
local begin
  vMyVorgabe  : logic;
  vOK         : logic;
end;
begin

  if (aVorgabe=401) then begin
    if (Set.LyseErweitertYN) then begin
      aVorgabe    # RecBufCreate(231);
      vMyVorgabe  # true;
      if (Lib_MoreBufs:ReadMoreBuf(401, aVorgabe, '')) then begin
      end;
    end;
  end
  else  if (aVorgabe=501) then begin
    if (Set.LyseErweitertYN) then begin
//debugx('hole zu KEY501');
//      vBuf # Lib_MoreBufs:GetBuf(231, '');
      aVorgabe    # RecBufCreate(231);
      vMyVorgabe  # true;
      if (Lib_MoreBufs:ReadMoreBuf(501, aVorgabe, '')) then begin
//debugx('FOUND!');
      end;
    end;
  end;
  
  vOK # true;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.StreckgrenzeTyp,'Streckgrenze', $edLys.Streckgrenze, $edLys.Streckgrenze2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Streckgrenze,'Streckgrenze', $edLys.Streckgrenze, $edLys.Streckgrenze2, aVorgabe, $lb.Vor.Streckgrenze) and vOK;

  vOK # CheckAnalyse(aTxt, aName, $lbLys.Zugfestigkeit,'Zugfestigkeit', $edLys.Zugfestigkeit, $edLys.Zugfestigkeit2, aVorgabe, $lb.Vor.Zugfestigkeit) and vOK;
  if ($lb.Vor.DehnungA<>0) then // 17.11.2021 QS bei LZM
    vOK # CheckAnalyse(aTxt, aName, $lbLys.DehnungA,'DehnungA',$edLys.DehnungA, 0, aVorgabe, $lb.Vor.DehnungA) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.DehnungA,'DehnungB',$edLys.DehnungB, $edLys.DehnungC, aVorgabe, $lb.Vor.DehnungB) and vOK;
 
  vOK # CheckAnalyse(aTxt, aName, $lbLys.StreckgrenzeQTyp,'StreckgrenzeQ', $edLys.StreckgrenzeQ1, $edLys.StreckgrenzeQ2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.ZugfestigkeitQ,'ZugfestigkeitQ', $edLys.ZugfestigkeitQ1, $edLys.ZugfestigkeitQ2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.DehnungQA,'DehnungBQ',$edLys.DehnungQB, $edLys.DehnungQC, aVorgabe) and vOK;
 
  vOK # CheckAnalyse(aTxt, aName, $lbLys.HaerteTyp,'Haerte',$edLys.Hrte, $edLys.Hrte2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Haerte,'Haerte',$edLys.Hrte, $edLys.Hrte2, aVorgabe, $lb.Vor.Haerte) and vOK;
 
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Mech.Sonstiges, 'Sonstiges',$edLys.Mech.Sonstiges, 0, aVorgabe) and vOK;
  // seit 20.09.2018 AH:
  vOK # CheckAnalyse(aTxt, aName, $lbLys.SGVerhaeltnis1, 'SGVerhaeltnis', $edLys.SGVerhaeltnis1, $edLys.SGVerhaeltnis2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.RauigkeitATyp, 'RauigkeitA', $edLys.RauigkeitA1, $edLys.RauigkeitA2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.RauigkeitA1, 'RauigkeitA', $edLys.RauigkeitA1, $edLys.RauigkeitA2, aVorgabe, $lb.Vor.RauigkeitA) and vOK;

  vOK # CheckAnalyse(aTxt, aName, $lbLys.RauigkeitBTyp, 'RauigkeitB', $edLys.RauigkeitB1, $edLys.RauigkeitB2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.RauigkeitB1, 'RauigkeitB', $edLys.RauigkeitB1, $edLys.RauigkeitB2, aVorgabe, $lb.Vor.RauigkeitB) and vOK;

  vOK # CheckAnalyse(aTxt, aName, $lbLys.RauigkeitCTyp, 'RauigkeitC', $edLys.RauigkeitC1, $edLys.RauigkeitC2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.CG1, 'Mech_CG', $edLys.CG1, $edLys.CG2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.FA1, 'Mech_FA', $edLys.FA1, $edLys.FA2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.PA1, 'Mech_PA', $edLys.PA1, $edLys.PA2, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.CN1, 'Mech_CN', $edLys.CN1, $edLys.CN2, aVorgabe) and vOK;
  //vOK # CheckAnalyse(aTxt, aName, $lbLys.CZ1, 'Mech_CZ', $edLys.CZ1, $edLys.CZ2, aVorgabe) and vOK;

  vOK # CheckAnalyse(aTxt, aName, $lbLys.CZ1, 'Mech_CZ1', $edLys.CZ1,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, 0, 'Mech_CZ2', $edLys.CZ2,0, aVorgabe) and vOK;
 
  vOK # CheckAnalyse(aTxt, aName, $lbLys.ZE1, 'Mech_ZE', $edLys.ZE1, $edLys.ZE2, aVorgabe) and vOK;
  
  vOK # CheckAnalyse(aTxt, aName, $lbLys.DehnungsgrenzeA, 'DEHNGRENZEA', $edLys.DehnungsgrenzeA, $edLys.RP02_2, aVorgabe, $lb.Vor.DehngrenzeA) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.DehnungsgrenzeB, 'DEHNGRENZEB', $edLys.DehnungsgrenzeB, $edLys.RP10_2, aVorgabe, $lb.Vor.DehngrenzeB) and vOK;
  
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Koernung, 'Koernung', $edLys.Koernung, $edLys.Koernung2, aVorgabe, $lb.Vor.Koernung) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.HC, 'Mech_HC', $edLys.HC,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.SS, 'Mech_SS', $edLys.SS,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.OA, 'Mech_OA', $edLys.OA,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.OS, 'Mech_OS', $edLys.OS,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.OG, 'Mech_OG', $edLys.OG,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Parallelitaet, 'Parallel', $edLys.Parallelitaet,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Planlage, 'Planlage', $edLys.Planlage,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Ebenheit, 'Ebenheit', $edLys.Ebenheit,0, aVorgabe) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Saebeligkeit, 'Saebel', $edLys.Saebeligkeit,0, aVorgabe) and vOK;
/**
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.DehngrenzeA,'DehngrenzeA',Ein.E.RP02_1, Ein.E.RP02_2);
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.DehngrenzeB,'DehngrenzeB',Ein.E.RP10_1, Ein.E.RP10_2);
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.Koernung,'Koernung',"Ein.E.Körnung", "Ein.E.Körnung2");
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.RauigkeitA,'RauigkeitA',"Ein.E.RauigkeitA1","Ein.E.RauigkeitA2");
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.RauigkeitB,'RauigkeitB',"Ein.E.RauigkeitB1","Ein.E.RauigkeitB2");
  vOK #   Lys_Data:CheckAnalyse($lb.Vor.Haerte,'Haerte',"Ein.E.Härte1", "Ein.E.Härte2");
***/
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.C,'C'         ,$edLys.Chemie.C,     0, aVorgabe, $lb.Vor.Chemie.C) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Si,'Si'       ,$edLys.Chemie.Si,    0, aVorgabe, $lb.Vor.Chemie.Si) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Mn,'Mn'       ,$edLys.Chemie.Mn,    0, aVorgabe, $lb.Vor.Chemie.Mn) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.P,'P'         ,$edLys.Chemie.P,     0, aVorgabe, $lb.Vor.Chemie.P) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.S,'S'         ,$edLys.Chemie.S,     0, aVorgabe, $lb.Vor.Chemie.S) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Al,'Al'       ,$edLys.Chemie.Al,    0, aVorgabe, $lb.Vor.Chemie.Al) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Cr,'Cr'       ,$edLys.Chemie.Cr,    0, aVorgabe, $lb.Vor.Chemie.Cr) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.V,'V'         ,$edLys.Chemie.V,     0, aVorgabe, $lb.Vor.Chemie.V) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Nb,'Nb'       ,$edLys.Chemie.Nb,    0, aVorgabe, $lb.Vor.Chemie.Nb) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Ti,'Ti'       ,$edLys.Chemie.Ti,    0, aVorgabe, $lb.Vor.Chemie.Ti) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.N,'N'         ,$edLys.Chemie.N,     0, aVorgabe, $lb.Vor.Chemie.N) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Cu,'Cu'       ,$edLys.Chemie.Cu,    0, aVorgabe, $lb.Vor.Chemie.Cu) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Ni,'Ni'       ,$edLys.Chemie.Ni,    0, aVorgabe, $lb.Vor.Chemie.Ni) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Mo,'Mo'       ,$edLys.Chemie.Mo,    0, aVorgabe, $lb.Vor.Chemie.Mo) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.B,'B'         ,$edLys.Chemie.B,     0, aVorgabe, $lb.Vor.Chemie.B) and vOK;
  vOK # CheckAnalyse(aTxt, aName, $lbLys.Chemie.Frei1,'Frei1' ,$edLys.Chemie.Frei1, 0, aVorgabe, $lb.Vor.Chemie.Frei1) and vOK;
  
  if (vMyVorgabe) then
    RecbufClear(aVorgabe);
    
  RETURN vOK;
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.PEH);
  Lib_GuiCom:Pflichtfeld($edLfs.Kosten.MEH);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
end;
begin

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  CheckVorgaben(aName, 0);

  // einfärben der Pflichtfelder
  Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
begin
  RETURN true;  // Speichern erfolgreich
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  gSelected # 0;
  RETURN true;
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

  // Auswahlfelder einfärben
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
//  EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;
  RETURN(true);
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
  end;

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
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Positionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (mode=c_ModeEdit);

  vHdl # gMenu->WinSearch('Mnu.Druck.VLDAW');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_VLDAW]=n);

  vHdl # gMenu->WinSearch('Mnu.Druck.LFS');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Lfs_Druck_LFS]=n);

  vHdl # gMenu->WinSearch('Mnu.Verbuchen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht<>0.0.0) or
                      (Rechte[Rgt_Lfs_Verbuchen]=n);

  vHdl # gMenu->WinSearch('Mnu.Stornieren');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode=c_ModeNew) or (Mode=c_ModeEdit) or
                      (Lfs.Datum.Verbucht=0.0.0) or
                      (Rechte[Rgt_Lfs_Stornieren]=n);


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
  end;

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vBuf  : int;
end;
begin

  if (w_CopyToBuf<>0) then begin
    vBuf # gMDI->wpDbRecBuf(231);
    if (vBuf<>0) then
      RecBufCopy(vBuf, w_CopyToBuf);
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================