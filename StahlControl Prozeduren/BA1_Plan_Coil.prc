@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Plan_Coil
//                    OHNE E_R_G
//  Info
//
//
//  04.08.2020  AH  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//  2022-12-19  AH  neue BA-MEH-Logik
//
//  Subprozeduren
//    SUB Start();
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
  cTitle      : 'BA-Planung'
  cMenuName   : ''
  cDialog     : 'BA1.Planung.Coil'
  cDlAuftrag  : 'dl.Auftrag'
  cDlMaterial : 'dl.Material'

  cMDI          : gMdiPara

  cClmAufRecId    : 1
  cClmAufSort     : 2
  cClmAufNr       : 3
  cClmAufTermin   : 4
  cClmAufArtikel  : 5
  cClmAufKunde    : 6
  cClmAufGuete    : 7
  cClmAufAbm      : 8
  cClmAufGewicht  : 9

  cClmMatRecId    : 1
  cClmMatSort     : 2
  cClmMatNr       : 3
  cClmMatArtikel  : 4
  cClmMatGuete    : 5
  cClmMatAbm      : 6
  cClmMatGewicht  : 7

  MyDat(a) : cnvai(dateyear(a)-100,_FmtNumLeadZero,0,2)+'.'+cnvai(DateMonth(a),_FmtNumLeadZero,0,2)+'.'+cnvai(DateDay(a),_FmtNumLeadZero,0,2)
end;

declare StartInner();
declare _AddMonat(aGew  : float; aDat  : date)
declare _SetAddSumLfd(aBoxNr : int; aGew : float; aSet : logic);
declare _NachRek(aDatei : int; aFirst701 : int; aDL : int; aIstPlan : logic) : logic
declare _NachDl(aDatei : int; aDL :int; aIstPlan : logic);
declare _200NachDl(aDL :int);
declare _Recalc(aDL : int; aDat  : date; aTim  : time)
declare _Ueberschriften(aDate : date);

//========================================================================
// Start
//  Call SFX_Planung_Walzen:Start
//========================================================================
sub Start();
local begin
end;
begin
  gSelected # 1;
  StartInner();
end;


//========================================================================
//========================================================================
sub GetDate(aText : alpha) : date;
local begin
  vDat  : date;
end;
begin
  try begin
    ErrTryCatch(_ErrCnv,y);
    vDat # Cnvda(aText);
  end;
  if (ErrGet() != _ErrOk) then RETURN 0.0.0;

  RETURN vDat;
end;


//========================================================================
sub ErzeugeEinstufigenBA(aAktion : alpha) : logic
local begin
  Erx   : int;
  vBAG  : int;
  vDL   : int;
  vI    : int;
  vA    : alpha;
  vID   : int;
end;
begin
//Lib_Debug:Startbluemode();

  TRANSON;

  // BA-Kopf anlegen *************************
  vBAG # BA1_Subs:CreateBAG();
  if (vBAG=0) then begin
    TRANSBRK;
    Msg(700011,'',0,0,0);
    RETURN false;
  end;

  // Position anlegen ************************
  if (BA1_P_Data:Erzeuge702(1, aAktion, 0,0)=false) then begin
    TRANSBRK;
    Msg(702041,'',0,0,0);
    RETURN false;
  end;


  // Input anlegen ***************************
  vDL # Winsearch(cMDI, cDlMaterial);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vA,   cClmMatRecId, vI);
    vID # cnvia(Str_token(vA,'|',2));
    Erx # RecRead(200,0,_recId, vID);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      WinLstCellGet(vDL, vA,    cClmMatNr   , vI);
      Msg(99,'Material '+vA+' macht Probleme!',0,0,0);
      RETURN false;
    end;

    if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer)=false) then begin
      TRANSBRK;
      Error(701031, AInt(Mat.Nummer));
      RETURN false;
    end;
//    vInputID # BAG.IO.ID;
  END;


  // Fertigungen anlegen *********************
  vDL # Winsearch(cMDI, cDlAuftrag);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vA,   cClmAufRecId, vI);
    vID # cnvia(Str_token(vA,'|',2));
    Erx # RecRead(401,0,_recId, vID);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      WinLstCellGet(vDL, vA,    cClmAufNr   , vI);
      Msg(99,'Auftrag '+vA+' macht Probleme!',0,0,0);
      RETURN false;
    end;

    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # vI;
    BAG.F.AutomatischYN     # n;
    BAG.F.MEH               # Auf.P.MEH.Einsatz;  //  2022-12-19  AH BA1_P_Data:ErmittleMEH();
    BAG.F.Warengruppe       # Mat.Warengruppe;

    BAG.F.Kommission        # AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
    BAG.F.Artikelnummer     # Auf.P.Artikelnr;
    "BAG.F.Stückzahl"       # 1;
    BAG.F.Gewicht           # Auf.P.Gewicht;
    BAG.F.Breite            # Auf.P.Breite;
//    BAG.F.Bemerkung         # aBem1;
   "BAG.F.KostenträgerYN"  # Y;
    BAG.F.Streifenanzahl      # "BAG.F.Stückzahl";

    if (BAG.F.Artikelnummer<>'') then begin
      Erx # RekLink(250,703,13,_recfirst);   // Artikel holen
      if (Erx<=_rLocked) then BAG.F.Warengruppe # Art.Warengruppe;
    end;

    if ("BAG.F.Stückzahl"=0) and (BAG.F.Gewicht=0.0) then CYCLE;

    if (BAG.F.MEH='m') then
      BAG.F.Menge # Rnd(cnvfi("BAG.F.Stückzahl") * "BAG.F.Länge" / 1000.0, Set.Stellen.Menge)

    BAG.F.Anlage.Datum  # Today;
    BAG.F.Anlage.Zeit   # Now;
    BAG.F.Anlage.User   # gUserName;
    Erx # BA1_F_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      Msg(703008,'',0,0,0);
      RETURN false;
    end;

    if (BA1_F_Data:UpdateOutput(703,n)=false) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN false;
    end;

    // VSBs anlegen ****************************
    if (BA1_P_Data:AutoVSB()=false) then begin
      TRANSBRK;
      Msg(702007,'',0,0,0);
      RETURN false;
    end;

  END;

  TRANSOFF;
  Msg(999998,'',0,0,0);

  BA1_Subs:ShowAufBAG(vBAG, 0);//vList);

  RETURN true;
end;

//========================================================================
//  ErzeugeLautVorlageMerge
//
//========================================================================
sub ErzeugeLautVorlageMerge() : logic
local begin
  Erx       : int;
  vDL       : int;
  vI        : int;
  vID       : int;
  vA        : alpha;

  vBAG      : int;
  vFirst    : logic;
  vFirstIO  : int;
  vLastPos  : int;
  vLastIO   : int;
  vLastVpg  : int;
  vOK       : logic;
end;
begin
//Lib_Debug:Startbluemode();

  TRANSON;

  vFirst # true;

  // zunächst Aufträge importieren ************************************
  vDL # Winsearch(cMDI, cDlAuftrag);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vA,   cClmAufRecId, vI);
    vID # cnvia(Str_token(vA,'|',2));
    Erx # RecRead(401,0,_recId, vID);
    if (Erx>_rLocked) or (Auf.P.VorlageBAG=0) then begin
      TRANSBRK;
      WinLstCellGet(vDL, vA,    cClmAufNr   , vI);
      Msg(99,'Auftrag '+vA+' macht Probleme!',0,0,0);
      RETURN false;
    end;

    if (vFirst) then begin
      vFirst # false;
      vBAG # BA1_Lohn_Subs:ErzeugeBAausVorlage(Auf.P.VorlageBAG, Auf.P.Nummer, Auf.P.Position, 0.0);  // +2sec
      if (vBAG=0) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(999999,'',0,0,0);
        RETURN false;
      end;

//      RecRead(700,1,_recLock);
//      BAG.Bemerkung # 'zu GPl.'+aint(GPl.Nummer);
//      RekReplace(700);
      // theo Input suchen...
      FOR Erx # RecLink(701,700,3,_recFirst)
      LOOP Erx # RecLink(701,700,3,_recnext)
      WHILE (Erx<=_rLocked) do begin
        if (BAG.IO.Materialtyp=1200) then begin
          vFirstIO # BAG.IO.ID;
          BREAK;
        end;
      END;
    end
    else begin
      vBAG # BA1_Lohn_Subs:ErzeugeBAausVorlage(Auf.P.VorlageBAG, Auf.P.Nummer, Auf.P.Position, 0.0, vBAG, vLastPos, vLastIO, vLastVpg); // +2sec
      if (vBAG=0) then begin
        TRANSBRK;
        ErrorOutput;
        Msg(999999,'',0,0,0);
        RETURN false;
      end;
      if (BA1_P_Data:Merge(vBAG, 1, vLastPos+1)=false) then begin
        TRANSBRK;
        Erroroutput;
        Msg(99,'Merge Fehler!',0,0,0);
        RETURN false;
      end;
    end;
    Erx # RecLink(701,700,3,_recLast);
    vLastIO  # BAG.IO.ID;
    Erx # RecLink(702,700,1,_recLast);
    vLastPos # BAG.P.Position;
    Erx # RecLink(704,700,2,_recLast);
    vLastVpg # BAG.Vpg.Verpackung;

  END;


  vFirst # true;
      // jetzt Material importieren ***************************
  vDL # Winsearch(cMDI, cDlMaterial);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(vDL, vA,   cClmMatRecId, vI);
    vID # cnvia(Str_token(vA,'|',2));
    Erx # RecRead(200,0,_recId, vID);
    if (Erx>_rLocked) then begin
      TRANSBRK;
      WinLstCellGet(vDL, vA,    cClmMatNr   , vI);
      Msg(99,'Material '+vA+' macht Probleme!',0,0,0);
      RETURN false;
    end;

    BAG.IO.ID # vFirstIO;
    Erx # RecRead(701,1,0);
    Erx # RecLink(702,701,4,_recFirst); // nachPos holen
    if (vFirst) then begin
      vFirst # false;
      vOK # BA1_IO_I_Data:TheorieWirdEcht(BAG.IO.ID, Mat.Nummer);
    end
    else begin
      vOK # BA1_IO_Data:EinsatzRein(BAG.P.Nummer, 1, Mat.Nummer);
      if (vOK) then begin
        vOK # BA1_IO_I_Data:KlonenVon(vFirstIO, true);
      end;
    end;
    if (vOK=false) then begin
      TRANSBRK;
      Msg(999999,'Fehler '+thisLine,0,0,0);
      RETURN false;
    end;
  END;

  TRANSOFF;

  Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================
//========================================================================
sub AuswahlMat()
local begin
  vHdl      : int;
end;
begin
  vHdl # Winsearch(cMDI, 'lb.Artikel');

  Mat_Mark_Sel:DefaultSelection();
  "Sel.Art.von.ArtNr"   # vHdl->wpcaption;
  "Sel.Art.bis.ArtNr"   # vHdl->wpcaption;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Material',here+':AusSelMaterial');
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//========================================================================
sub AuswahlAuf()
local begin
  vHdl      : int;
end;
begin
  vHdl # Winsearch(cMDI, 'lb.Artikel');

  Auf_P_Mark_Sel:DefaultSelection();
  "Sel.Auf.Artikelnr"   # vHdl->wpcaption;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Auftrag',here+':AusSelAuftrag');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// StartInner
//
//========================================================================
sub StartInner();
local begin
end;
begin

  if (gSelected=0) then RETURN;
  gSelected # 0;
  if (cMDI<>0) then RETURN;

  // Dialog starten...
  cMDI # Lib_GuiCom:OpenMdi(gFrmMain, cDialog, _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(cMDI->wpcustom));

  // Anzeigen
  cMDI->WinUpdate(_WinUpdOn);
  cMDI->Winfocusset(true);
end;


//========================================================================
//========================================================================
sub _AddMonat(
  aGew  : float;
  aDat  : date;)
local begin
  vHdl    : int;
  vM, vM2 : int;
  vF      : float;
end
begin
  vHdl # WinSearch(cMDI, 'lb.Monat');
  vM # cnvia(vHdl->wpCustom);
  vM2 # aDat->vpMonth + ((aDat->vpYear)*12);
  if (vM<>vM2) then RETURN;

  vHdl # WinSearch(cMDI, 'lb.SummeMonat');
  vF # cnvfa(vHdl->wpCaption);
  vF # vF + aGew;
  vHdl->wpCaption # anum(vF,0);
end;


//========================================================================
//========================================================================
sub _AddSum(
  aObj        : int;
  aGew        : float;
  opt aReset  : logic;
)
local begin
  vHdl    : int;
  vF      : float;
  vM      : int;
  vI      : int;
end;
begin

//  vHdl  # WinSearch(vBox, 'lb.SummeKG');
  vHdl # aObj;
  vF    # cnvfa(vHdl->wpcaption) + aGew;
  if (aReset) then begin
    vF # 0.0;
  end;
  vHdl->wpCaption # anum(vF,0);

end;


//========================================================================
//========================================================================
sub Nimm401() : logic
local begin
  vHdl      : int;
  vDL       : int;
  vKey      : alpha;
  vZeile    : int;
  vSort     : alpha;
  vA        : alpha;
  vGew      : float;
end;
begin
  vDL # Winsearch(cMDI, cDlAuftrag);
  if (vDL=0) then RETURN false;

  vHdl # Winsearch(cMDI, 'lb.Artikel');
  if (vHdl<>0) and (vHdl->wpcaption='') then vHdl->wpcaption # Auf.P.Artikelnr;

  vKey # '401|'+aint(RecInfo(401,_recId));
  vDL->WinLstDatLineAdd(vKey); // NEUE ZEILE

  vZeile # _WinLstDatLineLast;
//  vSort # cnvai(Mat.Nummer, _FmtNumNoGroup|_FmtNumLeadZero,0,10)+cnvai(BAG.P.Nummer, _FmtNumNoGroup|_FmtNumLeadZero,0,10)+cnvai(BAG.P.Position, _FmtNumNoGroup|_FmtNumLeadZero,0,5);
  vDL->winLstCellSet(vSort                                                      ,cClmAufSort      ,vZeile);
  vDL->winLstCellSet(aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position)                ,cClmAufNr        ,vZeile);
  vDL->winLstCellSet(aint(Auf.P.Termin1W.Zahl)+'/'+aint(Auf.P.Termin1W.Jahr)    ,cClmAufTermin    ,vZeile);
//  vA # cnvai(Auf.P.TerminZ.Jahr,_FmtNumLeadZero|_FmtNumNoGroup,0,4)+'|'+cnvai(Auf.P.TerminZ.Zahl,_FmtNumLeadZero|_FmtNumNoGroup,0,3);
//  vDL->winLstCellSet(vA                                                         ,cClmAufTermin    ,vZeile, _WinLstDatModeSortInfo);

  vDL->winLstCellSet(Auf.P.Artikelnr                                            ,cClmAufArtikel   ,vZeile);
  vDL->winLstCellSet(Auf.P.KundenSW                                             ,cClmAufKunde     ,vZeile);
  vDL->winLstCellSet("Auf.P.Güte"                                               ,cClmAufGuete     ,vZeile);
  vA # anum(Auf.P.Dicke,Set.Stellen.Dicke)+' x '+anum(Auf.P.Breite,Set.Stellen.Breite);
  vDL->winLstCellSet(vA                                                       ,cClmAufAbm       ,vZeile);
//  vA # cnvaf(Auf.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12)+'|'+cnvaf(Auf.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,3,12)+cnvaf("Auf.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,3,12);
//  vDL->winLstCellSet(vA                                                       ,cClmAufAbm       ,vZeile, _WinLstDatModeSortInfo);
  vGew # Auf.P.Prd.Rest.Gew;
  vDL->winLstCellSet(vGew                                                       ,cClmAufGewicht      ,vZeile)

  _AddSum($lb.AufSumKG, vGew);

end;


//========================================================================
//========================================================================
sub Nimm200() : logic
local begin
  vHdl      : int;
  vDL       : int;
  vKey      : alpha;
  vZeile    : int;
  vSort     : alpha;
  vA        : alpha;
  vGew      : float;
end;
begin
  vHdl # Winsearch(cMDI, 'lb.Artikel');
  if (vHdl<>0) and (vHdl->wpcaption='') then vHdl->wpcaption # Mat.Strukturnr;

  vDL # Winsearch(cMDI, cdlMaterial);
  if (vDL=0) then RETURN false;

  vKey # '200|'+aint(RecInfo(200,_recId));
  vDL->WinLstDatLineAdd(vKey); // NEUE ZEILE

  vZeile # _WinLstDatLineLast;
//  vSort # cnvai(Mat.Nummer, _FmtNumNoGroup|_FmtNumLeadZero,0,10)+cnvai(BAG.P.Nummer, _FmtNumNoGroup|_FmtNumLeadZero,0,10)+cnvai(BAG.P.Position, _FmtNumNoGroup|_FmtNumLeadZero,0,5);
  vDL->winLstCellSet(vSort                                                      ,cClmMatSort      ,vZeile);
  vDL->winLstCellSet(Mat.Nummer                                                 ,cClmMatNr        ,vZeile);

  vDL->winLstCellSet(Mat.Strukturnr                                             ,cClmMatArtikel   ,vZeile);
  vDL->winLstCellSet("Mat.Güte"                                                 ,cClmMatGuete     ,vZeile);
  vA # anum(Mat.Dicke,Set.Stellen.Dicke)+' x '+anum(Mat.Breite,Set.Stellen.Breite);
  vDL->winLstCellSet(vA                                                         ,cClmMatAbm       ,vZeile);
  vGew # Mat.Bestand.Gew;
  vDL->winLstCellSet(vGew                                                       ,cClmMatGewicht      ,vZeile)

  _AddSum($lb.MatSumKG, vGew);

end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel(
  aDL : int;
  aID : int;
)
local begin
  vGew  : float;
end;
begin

//  if (Msg(99,'Soll der gewählte Einträge wieder in den Pool gesetzt werden?',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;
  if (aDL->wpname=cDLAuftrag) then begin
    WinLstCellGet(aDL, vGew, cClmAufGewicht, aID);
    _AddSum($lb.AufSumKG, -vGew);
  end;
  if (aDL->wpname=cDLMaterial) then begin
    WinLstCellGet(aDL, vGew, cClmMatGewicht, aID);
    _AddSum($lb.MatSumKG, -vGew);
  end;

  WinLstDatLineRemove(aDL, aID);
end;


//========================================================================
sub _PlausiFaerben(
  aObj        : int;
  aOK         : logic;
  opt aForce  : logic)
begin
  if (aObj=0) then RETURN;
  if (aForce=false) then
    if (aObj->wpCheckState<>_WinStateChkChecked) then RETURN;

  if (aOK) then aObj->wpColBkg # _wincolparent
  else aObj->wpColBkg # _wincollightred;
end;


//========================================================================
sub PlausiCheck() : logic
local begin
  vRtf  : int;
  vTxt  : int;
  vOK   : logic;
end;
begin
  vTxt # TextOpen(20);
  vRtf # TextOpen(20);

  vOK # $bt.Plausi->wpImageTile=_winimgok;
  vOK # !vOK;

  TextAddLine(vTxt, '\fs28KEINE KONKRETEN PRÜFUNGEN DEFINIERT!!!\fs22');
  if (vOK) then
    TextAddLine(vTxt, '\cf3\fs28 So wäre es, wenn alles klappen würde!\cf1')
  else
    TextAddLine(vTxt, '\cf2\fs28 Das ist ein böser Fehler!\cf1');
//  TextAddLine(vTxt, '\cf2 KgMM-Vorgabe kritisch!!!\cf1\fs22');
//  TextAddLine(vTxt, 'Anzahl\tab Einsatz\tab \tab Streifen\tab \tab \tab Fertig');

  Lib_Texte:Txt2Rtf(vTxt, vRTF, 'Calibre', 15, 0, (TextInfo(vRTF,_textLines)>0));
  Dlg_Standard:TooltipRTF(vRTF,'Plausibilitätspürfung');
  TextClose(vRtf);
  TextClose(vTxt);

  if (vOK) then
    $bt.Plausi->wpImageTile # _WinImgOk;
  else
    $bt.Plausi->wpImageTile # _winimgCancel;

  _PlausiFaerben($cbBreite, vOk);
  _PlausiFaerben($cbChemie, vOk);
  _PlausiFaerben($cbMechanik, vOk);
  _PlausiFaerben($cbXXX, vOk);

  RETURN vOK;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit (
  aEvt      : event;
): logic
local begin
  vPar  : int;
  vHdl  : int;
  vHdl2 : int;
end;
begin
  gTitle        # Translate( cTitle );
  gMenuName     # cMenuName;
  gMenuEvtProc  # here+':EvtMenuCommand';
  Mode          # c_modeEdList;

//  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'1');
//  Lib_GuiCom:RecallList(cDLPool, cTitle);     // Usersettings holen
//  Lib_GuiCom:RecallList(vHdl, cTitle);
//  vHDl # Winsearch(aEvt:Obj, cDlPlanname+'2');
//  Lib_GuiCom:RecallList(vHdl, cTitle, cDlPlanname+'1');

  App_Main:EvtInit( aEvt );
end;


//========================================================================
// EvtClose
//              Schliessen eines Fensters
//========================================================================
sub EvtClose (
  aEvt            : event;
) : logic
local begin
  vHdl        : int;
end;
begin

  vHDl # Winsearch(cMDI, cDlAuftrag);
  Lib_GuiCom:RememberList(vHdl, cTitle);
  vHDl # Winsearch(cMDI, cDlMaterial);
  Lib_GuiCom:RememberList(vHdl, cTitle);
  Lib_GuiCom:RememberWindow(aEvt:obj);
  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtFocusTerm(
  aEvt                  : event;        // Ereignis
  aFocusObject          : handle;       // Objekt, das den Fokus bekommt
) : logic;
begin
  if (aEvt:Obj->wpName='edDatum') and ($edDatum->wpchanged) then begin

    WinLayer(_WinLayerStart, gFrmMain, 20000, 'Berechne...', _WinLayerDarken);
    _AddSum(1,0.0,y);
    _AddSum(2,0.0,y);
    WinLayer(_WinLayerEnd);

  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin

  if (Wininfo(aEvt:Obj, _wintype)=_WinTypeCheckbox) then begin
    _PlausiFaerben(aEvt:Obj, (aEvt:Obj->wpCheckState=_WinStateChkUnChecked), true)
//    if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then aEvt:Obj->wpColBkg # _wincollightRed
//    else aEvt:Obj->wpColBkg # _WinColParent;
  end;

  RETURN(true);
end;


//========================================================================
//  EvtMenuCommand
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtMenuCommand (
  aEvt            : event;
  aMenuItem       : int;
) : logic
begin
  RETURN Lib_Datalist:EvtMenuCommand( aEvt, aMenuItem );
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit (
  aEvt            : event;
  aId             : int;
) : logic
local begin
  vA    : alpha;
  vCol  : int;
  vI    : int;
end;
begin
  RETURN Lib_DataList:EvtLstDatainit(aEvt, aID);
/***
  vCol # _WinColParent;

  WinLstCellGet(aEvt:Obj, vA, cClmGewicht, aId);
  if (vA=cSieheOben) then
    vCol # _WinColLightGray;

  // 11.06.2019 AH: bereits abgerufen ? -> GRÜN färben
  WinLstCellGet(aEvt:Obj, vA, cClmRecId, aID);
  vI # cnvia(StrCut(vA,5,10));
  if (Cus_Data:Read(200,vI, cCustAbgerufen) <= _rLocked) then begin
    vCol # _WinColLightGreen;
  end;

  Lib_GuiCom:ZLColorLine(aEvt:Obj, vCol);
***/
end;


//========================================================================
//
//========================================================================
sub EvtLstSelect (
  aEvt            : event;
  aRecID          : int;
) : logic
begin
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked (
  aEvt            : event
) : logic
local begin
end;
begin

  case ( aEvt:obj->wpName ) of
    'bt.Plausi'       : PlausiCheck();
    'bt.DoIt.Merge'   : ErzeugeLautVorlageMerge();
    'bt.DoIt.Spalten' : ErzeugeEinstufigenBA(c_BAG_Spalt);
    'bt.DoIt.Tafeln'  : ErzeugeEinstufigenBA(c_BAG_Abcoil);
    'bt.Material'     : AuswahlMat();
    'bt.Auftrag'      : AuswahlAuf();
  end;

end;


//========================================================================
//  EvtLstEditCommit
//
//========================================================================
sub EvtLstEditCommit (
  aEvt            : event;
  aColumn         : int;
  aKey            : int;
  aFocusObject    : int;
) : logic
local begin
end;
begin
  RETURN Lib_Datalist:EvtLstEditCommit(aEvt, aColumn, aKey, aFocusObject);
end;


//========================================================================
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Maustaste
  aHitTest              : int;          // Hittest-Code
  aItem                 : handle;       // Spalte oder Gantt-Intervall
  aID                   : bigint;       // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
end;
begin
  RETURN Lib_Datalist:EvtMouseItem(aEvt, aButton, aHitTest, aItem, aID);
end;


//========================================================================
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;        // Ereignis
  aKey                  : int;          // Taste
  aID                   : bigint;       // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
begin

  // DELETE
  if ( aKey = _WinKeyDelete) then begin
    RecDel(aEvt:Obj, aID);
  end;

  // EDIT nur in Planung...
  if (aKey = _WinKeyTab) or ( aKey = _winKeyReturn ) then begin
//    if (aEvt:Obj<>cDLPool) then
      RETURN Lib_DataList:EvtKeyItem(aEvt, aKey, aID);
  end;

  RETURN true;
end;


//========================================================================
//  EvtDrop
//========================================================================
sub EvtDrop(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aDataPlace           : handle;   // DropPlace-Objekt
  aEffect              : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
  aMouseBtn            : int;      // Verwendete Maustasten
) : logic;
local begin
  vA          : alpha;
  vFile       : int;
  vKey        : alpha;

  vData       : int;
  vItem       : int;
  vLine       : int;
  vPlace      : int;
  vVon, vNach : int;
  vMin        : int;
  vI          : int;
  vRunter     : logic;
  vPre,vPost  : int;
  vDL1, vDL2  : int;
  vMat        : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)=false) or
    (aDataObject->wpcustom='') then RETURN false;

  vA    # StrFmt(aDataObject->wpName,30,_strend);
  vFile # Cnvia(StrCut(vA,1,3));
  vKey  # StrCut(vA,5,100);

  if (vFile=200) then begin
    Mat.Nummer # cnvia(vKey);
    RecRead(200,1,0);
    Nimm200();
  end
  else if (vFile=401) then begin
    if (Lib_Berechnungen:Int2AusAlpha(vKey, var Auf.P.Nummer, var Auf.P.Position)) then begin
      Nimm401();
    end;
  end;

RETURN true;

/***
  if (aDataObject->wpFormatEnum(_WinDropDataUser)<>true) then RETURN false;
  if (aDataObject->wpname<>cModulname) then RETURN false;

  vDL1 # cnvia(aDataObject->wpcustom);
  vDL2 # aEvt:Obj;

  // Start-Ziel gleich? -> Dann nix
  if (vDL1=vDL2) then RETURN true;

  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;

  vLine   # aDataPlace->wpArgInt(0);
  vPlace  # aDataPlace->wpDropPlace;

  // Einfügeposition.
  case vPlace of
    _WinDropPlaceAppend   : begin
    inc(vLine);//vA # 'NACH';//  inc(vLine);
    end;
  end;
  if (vData=0) then RETURN false;

// if (vPlace=_WinDropPlaceThis)   => Maus AUF einem Eintrag
  vDL1->winupdate(_winupdoff);
  if (vDL1<>vDL2) then
    vDL2->winupdate(_winupdoff);

  vMin # 32000;
  FOR vItem # vData->CteRead(_CteFirst)
  LOOP vItem # vData->CteRead(_CteNext, vItem)
  WHILE (vItem<>0) do begin

    vVon  # vItem->spid;
    vNach # vLine;
//debugx(aint(vVon)+' nach '+aint(vNach));
    if (vDL1=vDL2) then begin
      if (vVon=vNach) then CYCLE;
      vRunter # vVon<vNach;
      if (vRunter) then begin
//          if (vPlace=_WinDropPlaceThis) then
        vVon  # vVon - vPre;
        vNach # vNach - 1;              // wegen REMOVE
      end
      else begin
        vNach # vNach + vPost;
      end;
      if (vNach=0) then CYCLE;
    end
    else begin  // Pool <-> Plan oder Plan <-> Pool oder Plan <-> Plan
      vVon # vVon - vPre;
    end;

    WinLstCellGet(vDL1, vMat , cClmMat, vVon);
    if (vMat=0) then CYCLE;

    _Move(vDL1, vDL2, vMat);
  END;

  vDL1->WinUpdate(_WinUpdOn, _WinLstFromTop);
  vDL1->WinUpdate(_WinUpdSort);
  if (vDL1<>vDL2) then begin
    vDL2->WinUpdate(_WinUpdOn, _WinLstFromTop);
    vDL2->WinUpdate(_WinUpdSort);
  end;

  RETURN(true);
***/
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
  Lib_Mark:Reset(200)

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
//========================================================================
sub AusMaterial()
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vPos    : int;
  vCount  : Int;
end;
begin
  vCount # 0;

  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>200) then CYCLE;
    inc(vCount);
    RecRead(vMFile,0,_RecId,vMID);    // Satz holen

    Nimm200();
  END;

  Lib_Mark:Reset(200)
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

  Lib_Mark:Reset(401);
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
//========================================================================
sub AusAuftrag()
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vPos    : int;
  vCount  : Int;
end;
begin
  vCount # 0;

  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>401) then CYCLE;
    inc(vCount);
    RecRead(vMFile,0,_RecId,vMID);    // Satz holen

    Nimm401();
  END;

  Lib_Mark:Reset(401)
end;


//==============================================================================================================================================
//========================================================================
sub MatInfo(
  aDatei  : int;
  aRecId  : int;
  aTitel  : alpha)
local begin
  vMDI  : int;
  vBuf  : int;
  vBuf2 : int;
end;
begin
  vBuf # RecBufDefault(aDatei);
  RecRead(aDatei, 0, _RecId, aRecID);

  vMDI # Lib_GuiCom:OpenMdi(gFrmMain, 'Mat.Info', _WinAddHidden);
  VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
  gTitle # aTitel;
  vMDI->wpcaption # gTitle;

  // Anzeigen
  vMDI->WinUpdate(_WinUpdOn);
  vMDI->Winfocusset(true);

  RecBufCopy(vBuf, aDatei);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub InfoEvtInit (
  aEvt      : event;
): logic
local begin
  vBuf      : int;
  vBuf2     : int;
end;
begin
//  vBuf  # RecBufDefault(200);
//  vBuf2 # aEvt:Obj->wpdbRecBuf(200);
//debugx('ist '+aint(Mat.Nummer));
//  RecBufCopy(vBuf2, 200);
//debugx('wird '+aint(Mat.Nummer));

//  gTitle        # Translate('Material')+' '+aint(Mat.Nummer);
//  gTitle        # aEvt:obj->wpname+' '+aint(Mat.Nummer);
  gMenuName     #'';//'cMenuName;
  gMenuEvtProc  # '';//here+':EvtMenuCommand';
  Mode          # c_ModeView;
  App_Main:EvtInit( aEvt );
end;

//========================================================================
//========================================================================
