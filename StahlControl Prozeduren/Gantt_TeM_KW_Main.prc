@A+
//===== Business-Control =================================================
//
//  Prozedur    Gantt_TeM_KW_Main
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  04.12.2014  ST  Anpassung Ankeranzeige 1326/394; Lesen der Daten über Key anstatt Code + Bugfixes
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB KillAllInGantt(aGantt : int)
//    SUB GehtUserAn(aUser : alpha) : logic;
//    SUB BuildHeader();
//    SUB Refresh();
//    SUB PutInGantt(aGantt : int; aName : alpha; aStart : int; aLen : int; aFarbeFg : int; aFarbeBg : int; aText : alpha; aTip : alpha);
//    SUB BuildIntervalls();
//    SUB Auswahl(aBereich : alpha)
//    SUB AusUser()
//    SUB AusAdresse()
//    SUB AusPartner()
//    SUB AusProjekt()
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB AusTermin()
//    SUB AusTerminNeu()
//    SUB EvtIvlDropItem(aEvt : event; aHdlTarget : int; aHdlIvl : int; aDropType : int; aRect : rect) : logic
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtTerm(aEvt : event) : logic
//    SUB EvtTimer(aEvt : event; aTimerId : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

define begin
  cDialog  : $Gantt.TeM.Woche
  cTitle :    'Abteilungen'
  cMenuName : 'Gantt.TeM.Woche'
  cPrefix : 'Gantt_TeM_KW'

end;

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin

  Mode # c_modeEdit;

  if (w_Child=0) then begin
    // Datei spezifische Vorgaben
    gTitle  # Translate(cTitle);
    gFrmMain->wpMenuname # cMenuName;    // Menü setzen
    gMenu   # gFrmMain->WinInfo(_WinMenu);
    gPrefix # cPrefix;
    Mode    # c_ModeOther;
    gMdi    # cDialog;
  end;
  Call('App_Main:EvtMdiActivate',aEvt);

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
begin
  if (aMenuItem->wpname='Mnu.GanttCancel') then cDialog->Winclose();
end;


//========================================================================
//  KillAllinGantt
//
//========================================================================
sub KillAllInGantt(aGantt        : int)
local begin
  vObject       : int;   // Intervall-Deskriptor
  vTemp         : int;   // Zwischenspeicher
  vType         : int;
end;
begin
  // Intervalle "unsichtbar" entfernen.
//  aGantt->wpAutoUpdate # false;

  vObject # aGantt->WinInfo(_WinFirst, 1);

  WHILE (vObject != 0) do begin
    vType # Wininfo(vObject,_wintype);
    if ((vType = _WinTypeInterval) or
      (vType = _WinTypeIvlBox  ) or
      (vType = _WinTypeIvlLine )) then begin
      vTemp # vObject->WinInfo(_WinNext, 1);
      vObject->WinGanttIvlRemove();
    end
    else begin
      vTemp # vObject->WinInfo(_WinNext, 1);
    end;
    vObject # vTemp;
  END;

  // GanttGraph neu zeichnen.
//  aGantt->wpAutoUpdate # true;
end;


//========================================================================
//  GehtUserAn
//
//========================================================================
sub GehtUserAn(aUser : alpha) : logic;
local begin
  Erx : int;
end;
begin
  if (TeM.Anlage.User=aUser) then RETURN true;

  Erx # RecLink(981,980,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (TeM.A.Datei=800) and (TeM.A.Code=gUserName) then RETURN true;
    Erx # RecLink(981,980,1,_recNext);
  END;

  RETURN false;
end;


//========================================================================
//  BuildHeader
//
//========================================================================
sub BuildHeader();
local begin
  vDat  : date;
  vKW   : word;
  vJahr : word;
end;
begin
  vDat  # $ed.Datum->wpcaptiondate;
  Lib_Berechnungen:KW_aus_Datum(vDat, var vKW, var vJahr);
  Lib_Berechnungen:Mo_von_KW(vKW, vJahr, VAR vDat)
  $ed.Datum->wpcaptiondate # vDat;

  $Tag1->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.1->wpcustom # cnvad(vDat);
  $bt.Day1->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag2->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.2->wpcustom # cnvad(vDat);
  $bt.Day2->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag3->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.3->wpcustom # cnvad(vDat);
  $bt.Day3->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag4->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.4->wpcustom # cnvad(vDat);
  $bt.Day4->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag5->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.5->wpcustom # cnvad(vDat);
  $bt.Day5->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag6->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.6->wpcustom # cnvad(vDat);
  $bt.Day6->wpcaption # Lib_Berechnungen:Tag_aus_Datum(vdat)+strchar(13)+cnvad(vDat,_FmtInternal);

  vDat->vmDayModify(1);
  $Tag7->wpscalalabels # Lib_Berechnungen:Tag_aus_Datum(vDat)+' '+cnvai(vDat->vpday)+'.'+cnvai(vDat->vpmonth);
  $GG.7->wpcustom # cnvad(vDat);
end;


//========================================================================
//  Refresh
//
//========================================================================
sub Refresh();
local begin
  vText : alpha;
  vOK : logic;
end;
begin

  $lb.TeP.Typ->wpcaption # Lib_Termine:GetTypeName(TeM.Typ);

  if (TeM.Start.Von.Datum<>0.0.0) then begin
    $lb.TeP.Startdatum->wpcaption # Cnvad(TeM.Start.Von.Datum,_FmtInternal);
    $lb.TeP.Startzeit->wpcaption # CnvAt(TeM.Start.Von.Zeit);
    end
  else begin
    $lb.TeP.Startdatum->wpcaption # '';
    $lb.TeP.Startzeit->wpcaption # '';
  end;
  if (TeM.Ende.Von.Datum<>0.0.0) then begin
    $lb.TeP.Enddatum->wpcaption # Cnvad(TeM.Ende.Von.Datum,_FmtInternal);
    $lb.TeP.Endzeit->wpcaption # CnvAt(TeM.Ende.Von.Zeit);
    end
  else begin
    $lb.TeP.Enddatum->wpcaption # '';
    $lb.TeP.Endzeit->wpcaption # '';
  end;

  vOk # y;
  if (TeM.PrivatYN) then begin
    vOk # GehtUserAn(gUsername);
  end;
  if (vOK=n) then begin
    TeM.Bemerkung # Translate('<PRIVAT>');
    TeM.Bezeichnung # TeM.Bemerkung;
  end;

  $lb.TeP.Text->wpcaption # TeM.Bemerkung;
  $lb.TeP.Bezeichnung->wpcaption # TeM.Bezeichnung;

  RecbufClear(981);
//  $rl.Anker->winupdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  $rl.Anker->winupdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect);

  cDialog->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  PutInGantt
//
//========================================================================
sub PutInGantt(
  aGantt    : int;
  aName     : alpha;
  aStart    : int;
  aLen      : int;
  aFarbeFg  : int;
  aFarbeBg  : int;
  aText     : alpha(4000);
  aTip      : alpha;
);
local begin
  vVal    : int;
  vX      : int;
  vStyle  : int;
end;
begin
  vStyle # _winStyleIvlRound;
  aStart # aStart / 30;

  // angefangene Halbstunden als ganze ansehen
  if (aLen % 30<>0) then aLen   # (aLen / 30) + 1
  else aLen # (aLen / 30);

  // 6 Stunden zurückrechnen
  aStart # aStart - 11;
  if (aStart<0) then begin
    aStart  # 0;
    vStyle # vStyle | _WinStyleIvlOpenStart;
  end;
  if (aStart>26) then       aStart  # 26;
  if (aLen<1) then          aLen    # 1;
  if (aStart+aLen>26) then begin
    aLen    # 26 - aStart + 1;
    vStyle # vStyle | _WinStyleIvlOpenEnd;
  end;

  vX # 0;
  vVal # aGantt->WinGanttIvlAdd(aStart,vX,aLen,aName,aText);
  WHILE (vVal=0) do begin
    vX # vX + 1;
    if (vX>aGantt->wpCellCOuntVert) then aGantt->wpcellcountVert # vX;
    vVal # aGantt->WinGanttIvlAdd(aStart,vX,aLen,aName,aText);
  END;

  vVal->wpHelptip # aTip;
  vVal->wpColFg   # aFarbeFg;
  vVal->wpColBkg  # aFarbeBg;
  vVal->wpStyleIvl # vStyle;
end;


//========================================================================
//  BuildIntervalls
//
//========================================================================
sub BuildIntervalls();
local begin
  Erx       : int;
  vNr       : int;
  vUser     : Alpha;
  vOK       : logic;
  vVal      : int;
  vDat      : date;
  vKW       : int;
  vDay      : int;
  vJahr     : int;
  vDatMo    : date;
  vDatSo    : date;
  vGantt    : int;
  vX        : int;
  vLen      : int;
  vFarbeBg  : int;
  vFarbeFg  : int;
  vText     : alpha(4000);
  vName     : alpha(4000);
end;
begin
  vNr # TeM.Nummer;

  vUser # $ed.User->wpcaption;
  if (vUser='<alle>') then vUser # '';

  $GG.1->wpAutoUpdate # n;
  $GG.2->wpAutoUpdate # n;
  $GG.3->wpAutoUpdate # n;
  $GG.4->wpAutoUpdate # n;
  $GG.5->wpAutoUpdate # n;
  $GG.6->wpAutoUpdate # n;
  $GG.7->wpAutoUpdate # n;
  KillallInGantt($GG.1);
  KillallInGantt($GG.2);
  KillallInGantt($GG.3);
  KillallInGantt($GG.4);
  KillallInGantt($GG.5);
  KillallInGantt($GG.6);
  KillallInGantt($GG.7);


  // Anfang-Ende bestimmen
  vDatMo # $ed.Datum->wpcaptiondate;
  vDatSo # $ed.Datum->wpcaptiondate;
  vDatSo->vmDayModify(6);


  Erx # RecRead(980,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    vOk # y;
    if (Tem.Start.von.Datum<vDatMo) or (Tem.Start.von.Datum>vDatSo) or (TeM.SichtbarPlanerYN=n) then
      vOk # n;

    if (vOK=y) and (vUser<>'') then begin
      if (GehtUserAn(vUser)=n) then vOk # n;
    end;

    if (vOK=n) then begin
      Erx # RecRead(980,1,_recNext);
      CYCLE;
    end;

    vDay # DateDayOfWeek(TeM.Start.von.Datum);
    case vDay of
      1 : vGantt # $GG.1;
      2 : vGantt # $GG.2;
      3 : vGantt # $GG.3;
      4 : vGantt # $GG.4;
      5 : vGantt # $GG.5;
      6 : vGantt # $GG.6;
      7 : vGantt # $GG.7;
    end;

    vX    # cnvIt(TeM.Start.von.Zeit)/1000/60;
    vLen # Cnvif(TeM.Dauer);

    vFarbeFg # RGB(255,255,255);
    vFarbeBg # RGB(250,250,250);
    case (Lib_Termine:GetBasisTyp(TeM.Typ)) of
      'DSK' : begin
        Erx # RecRead(980,1,_recNext);
        CYCLE;
      end;
      
      'TEX' : begin
          vFarbeBg # RGB(255,110,110);  // Termin extern
          vFarbeFg # RGB(0,0,0);
      end;

      'TIN' : begin
          vFarbeBg # RGB(255,150,0);  // Termin intern
          vFarbeFg # RGB(0,0,0);
      end;

      'BSP' : begin
        vFarbeBg # RGB(250,250,100);  // Besprechung
        vFarbeFg # RGB(0,0,0);
      end;

      'AFG' : begin
        vFarbeBg # RGB(150,150,250);  // Aufgabe
        vFarbeFg # RGB(0,0,0);
      end;

      'WVL' : begin
        vFarbeBg # RGB(250,180,250);  // Wiedervorlage
        vFarbeFg # RGB(0,0,0);
      end;

      'TEL','BRF','FAX','EMA', 'SMS' : begin
        vFarbeBg # RGB(100,250,100);  // SMS
        vFarbeFg # RGB(0,0,0);
      end;

      'GSV' : begin
        vFarbeBg # RGB(100,200,200);  // Geschenkversand
        vFarbeFg # RGB(0,0,0);
      end;

      'URL' : begin
        vFarbeBg # RGB(170,170,170);  // Urlaub
        vFarbeFg # RGB(0,0,0);
      end;
    end;

    //vText # Lib_Termine:GetTypeName(TeM.Typ);
    vText # '';
    Erx # RecLink(981,980,1,_RecFirst);
    WHILE (Erx<=_rLocked) do begin
      if (vText<>'') then vText # vText + ', ';

      case (TeM.A.Datei) of
        100 : begin
          Adr.Nummer # TeM.A.ID1;
          RecRead(100,1,0);
          vText # vText + Adr.Stichwort;
        end;

        102 : begin
          Adr.P.Adressnr  # TeM.A.ID1;
          Adr.P.Nummer    # TeM.A.ID2;
          RecRead(102,1,0);
          vText # vText + Adr.P.Stichwort;
        end;

        120 : begin
          Prj.Nummer # TeM.A.ID1;
          RecRead(120,1,0);
          vText # vText + Prj.Stichwort;
        end;

        otherwise begin
          vText # vText + TeM.A.Code;
        end;

      end;


      Erx # RecLink(981,980,1,_RecNext);
    END;

    vName # Cnvai(Tem.Nummer);
    vOk # y;
    if (Tem.PrivatYN) then begin
      vOk # n;
      if (GehtUseran(gUserName)) then vOK # y;
    end;
    if (vOK) then
      PutInGantt(vGantt,vName,vX,vLen,vFarbeFg,vFarbeBg,vText, Tem.Bezeichnung)
    else
      PutInGantt(vGantt,vName,vX,vLen,vFarbeFg,vFarbeBg,vText, '<PRIVAT>');

    Erx # RecRead(980,1,_recNext);
  END;


  $GG.1->wpAutoUpdate # y;
  $GG.2->wpAutoUpdate # y;
  $GG.3->wpAutoUpdate # y;
  $GG.4->wpAutoUpdate # y;
  $GG.5->wpAutoUpdate # y;
  $GG.6->wpAutoUpdate # y;
  $GG.7->wpAutoUpdate # y;

  TeM.Nummer # vNr;
  Erx # RecRead(980,1,0);
  If (Erx>_rLockeD) then RecBufClear(980);
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
begin

  case aBereich of

    'Adresse' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Partner' : begin
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung',here+':AusPartner');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'Projekte' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjekt');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'User' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusUser');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


   'Auftrag' : begin
      RecBufClear(401);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Bestellung' : begin
      RecBufClear(501);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBestellung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Projektpos' : begin
      RecBufClear(120);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusProjektPos1');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    'BAG_P' : begin
      RecBufClear(700);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.Verwaltung',here+':AusBAG_P');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    
    'Material' : begin
      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusMaterial');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusUser
//
//========================================================================
sub AusUser()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;

//    TeM_A_Data:New(1,'MAN');
    TeM_A_Data:Anker(800, 'MAN', true);
/***
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Code    # Usr.Username;
    TeM.A.Datei   # 800;
    TeM.A.lfdNr   # 1;
    REPEAT
      Erx # TeM_A_Data:Insert(0,'MAN');
      if (erx<>_rOK) then inc(TeM.A.lfdNr);
    UNTIl (Erx=_rOK);
    Usr.Username # gUsername;
    RecRead(800,1,0);
***/
  end;
  Usr_data:RecReadThisUser();
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    gSelected # 0;

    TeM_A_Data:Anker(100, 'MAN', true);

  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
end;


//========================================================================
//  AusPartner
//
//========================================================================
sub AusPartner()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(102,0,_RecId,gSelected);
    gSelected # 0;
    TeM_A_Data:Anker(102, 'MAN', true);
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusAdresse
//
//========================================================================
sub AusMaterial()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;

    TeM_A_Data:Anker(200, 'MAN', true);

  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
end;


//========================================================================
//  AusProjekt
//
//========================================================================
sub AusProjekt()
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  Lib_GuiCom:SetWindowState(cDialog,true);
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;
//    TeM_A_Data:New(120,'MAN');
    TeM_A_Data:Anker(120, 'MAN', true);
/***
    // Feldübernahme
    RecBufClear(981);
    TeM.A.Nummer  # TeM.Nummer;
    TeM.A.Datei   # 120;
    TeM.A.ID1     # Prj.Nummer;
    TeM.A.lfdNr   # 1;
    REPEAT
      Erx # TeM_A_Data:Insert(0,'MAN');
      if (erx<>_rOK) then inc(TeM.A.lfdNr);
    UNTIl (Erx=_rOK);
***/
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  AusProjektPos1
//
//========================================================================
sub AusProjektPos1()
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin
  // Zugriffliste wieder aktivieren
  // gesamtes Fenster aktivieren
  if (gSelected<>0) then begin
    RecRead(120,0,_RecId,gSelected);
    gSelected # 0;

    RecBufClear(122);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.P.Verwaltung',here+':AusProjektPos2');

    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

    vQ # '';
    Lib_Sel:QInt(var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
    vHdl # SelCreate(122, 1);
    Erx # vHdl->SelDefQuery('', vQ);
    if (Erx <> 0) then Lib_Sel:QError(vHdl);
    // speichern, starten und Name merken...
    w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
    // Liste selektieren...
    gZLList->wpDbSelection # vHdl;

    Lib_GuiCom:RunChildWindow(gMDI);
    RETURN;

  end;
  $rl.Tem2.anker->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
end;


//========================================================================
//  AusProjektPos2
//
//========================================================================
sub AusProjektPos2()
begin
  if (gSelected<>0) then begin
    RecRead(122,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(122, 'MAN');
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
  // RefreshIfm('edxxx.xxxxxxx');
end;


//========================================================================
//  Ausauftrag
//
//========================================================================
sub AusAuftrag()
begin
  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(401, 'MAN');
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
end;


//========================================================================
//  AusBestellung
//
//========================================================================
sub AusBestellung()
begin
  if (gSelected<>0) then begin
    RecRead(501,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    TeM_A_Data:Anker(501, 'MAN');
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();
  // ggf. Labels refreshen
end;



//========================================================================
//  ChoosePos
//
//========================================================================
sub ChoosePos() : int;
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin
  vHdl # WinOpen('BA1.P.Auswahl',_WinOpenDialog);

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.Nummer)+' '+BAG.Bemerkung;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Arbeitsgang wählen:');

  vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  WinClose(vHdl);
  if (gSelected=0) then RETURN 0;
  RecRead(702,0,_RecId,gSelected);
  gSelected # 0;

  RETURN BAG.P.Position;
end;


//========================================================================
//  AusBAG_P
//
//========================================================================
sub AusBAG_P()
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(700,0,_RecId,gSelected);
    gSelected # 0;

    // Position wählen
    vPos # ChoosePos();

    BAG.P.Nummer # BAG.Nummer;
    BAG.P.Position # BAG.P.Position;
    Erx # RecRead(702, 1, 0); // BAG.Pos lesen
    if(Erx > _rLocked) then
      RecBufClear(702);

    TeM_A_Data:Anker(702, 'MAN', true);
  end;
  BuildIntervalls();
  Refresh();
  // Focus auf Editfeld setzen:
  $bt.TeP.Refresh->Winfocusset();


end;



//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  Erx   : int;
  vRect : rect;
  vVal  : int;
  vDat : date;
  vTmp : int;
end;
begin

  case aEvt:obj->wpname of
/*    'bt.left' : begin
      $GG.2->WinGanttLineAdd(1,_winColLightMagenta);
      vRect:top     # 10;
      vRect:bottom  # 10-1;
      vRect:right   # 100;
      vRect:bottom  # 10;
      $GG.3->WinGanttBoxAdd(RectMake(1,1,10,2),RGB(170,0,0),'Wartung');
  $GG.1->winupdate();
    end;

    'bt.right' : begin
      $GG.1->wpCellofsHorz # $GG.1->wpCellofsHorz + 1;
      $GG.1->wpCellActiveHorz # 14;
  $GG.1->winupdate();
    end;
*/
    'bt.Anker.New' : begin
      vTmp # WinDialog('TeM.Anker.Auswahl',_WinDialogCenter,gMDI);
      IF !(vTmp = _WinIdClose) and (gSelected<>0) then begin
        cDIalog->winfocusset(true);
        vTmp # gSelected;
        gSelected # 0;

        // Liste je nach Auswahl aufrufen
        // Zu verankernde Position auswählen
        CASE (vTmp) OF
            100 : Auswahl('Adresse');
            102 : Auswahl('Partner');
            120 : Auswahl('Projekte');
            122 : Auswahl('Projektpos');
            401 : Auswahl('Auftrag');
            501 : Auswahl('Bestellung');
            800 : Auswahl('User');
            200 : Auswahl('Material');
            702 : Auswahl('BAG_P');
        END;
        RETURN true;
      end;
    end;


    'bt.Anker.Del' : begin
      Erx # RecRead(981,0,0,$rl.anker->wpdbRecId);
      if (Erx=_rOk) then begin
        TeM_A_Data:Delete(0,'MAN');

        Buildintervalls();
        Refresh();
        $bt.TeP.Refresh->Winfocusset();
      end;
    end;


    'bt.KW.Next' : begin
      vDat # $ed.Datum->wpcaptionDate;
      vDat->vmDayModify(7);
      $ed.Datum->wpcaptiondate # vDat;
      BuildHeader();
      Buildintervalls();
      RecBufClear(980);
      Refresh();
    end;


    'bt.KW.Prev' : begin
      vDat # $ed.Datum->wpcaptionDate;
      vDat->vmDayModify(-7);
      $ed.Datum->wpcaptiondate # vDat;
      BuildHeader();
      Buildintervalls();
      RecBufClear(980);
      Refresh();
    end;


    'bt.TeP.Refresh' : begin
      BuildHeader();
      Buildintervalls();
      RecBufClear(980);
      Refresh();
    end;

  end;


end;


//========================================================================
//  EvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  Erx : int;
  vNr : int;
end;
begin

  if (aHit<>_WinHitIvl) and (aHit<>_WinHitGanttView) then begin
    $bt.TeP.Refresh->Winfocusset();
    RETURN true;
  end;

  if (aHit=_WinHitIvl) and (aItem>100) then begin
    TeM.Nummer # Cnvia(aItem->wpName);
    Erx # RecRead(980,1,0);
    $rl.Anker->winupdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;

  if (aButton & _WinMouseDouble>0) then begin

    // Editieren???
    if (aHit=_WinHitIvl) and (Rechte[Rgt_TeM_Aendern]) then begin

      if (TeM.PrivatYN) then begin
        if (GehtUserAn(gUsername)=n) then begin
          $bt.TeP.Refresh->Winfocusset();
          RETURN true;
        end;
      end;

      RecRead(980,1,_RecLock);
      PtD_Main:Memorize(980);

      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.Maske',Here+':AusTermin');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_Modeedit;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain,_WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);
    end;


    // Neuanlage???
    if (aHit=_WinHitGanttView) and (Rechte[Rgt_Tem_Anlegen]) then begin
      RecBufClear(980);
      Tem2_Main:RecInit();

      // Add MYSELF
//      TeM_A_Data:New(1,'MAN');
      TeM_A_Data:Anker(800, 'MAN', true);

      TeM.Start.Von.Datum # Cnvda(aEvt:Obj->wpcustom);
      TeM.Start.Von.Zeit  # Cnvti(((aItem+11)*30)*60*1000);
      TeM.Ende.Von.Datum # Cnvda(aEvt:Obj->wpcustom);
      TeM.Ende.Von.Zeit  # Cnvti(((aItem+11)*30)*60*1000);
      TeM.SichtbarPlanerYN # y;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'TeM.Maske',here+':AusTerminNeu');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      Lib_GuiCom:RunChildWindow(gMDI,gFrmMain, _WinAddHidden);
      gMdi->WinUpdate(_WinUpdOn);

    end;
  end;

  Refresh();

  //$bt.TeP.Refresh->Winfocusset();
  RETURN true;
end;


//========================================================================
//  AusTermin
//
//========================================================================
sub AusTermin()
begin
//  Lib_GuiCom:SetWindowState(cDialog,true);
  BuildIntervalls();
  Refresh();
  $bt.TeP.Refresh->Winfocusset();
end;


//========================================================================
//  AusTerminNeu
//
//========================================================================
sub AusTerminNeu()
begin
/***
  if (TeM.Nummer<>0) then begin
    RecBufClear(981);
    TeM.A.Nummer      # TeM.Nummer;
    TeM.A.Berichtsnr  # 0;
    TeM.A.Code        # gUserName;
    TeM_A_Data:Insert(0,'MAN');
  end;
***/
  BuildIntervalls();
  Refresh();
  $bt.TeP.Refresh->Winfocusset();
end;


//========================================================================
//  EvtIvlDropItem
//                Intervall fallen lassen
//========================================================================
sub EvtIvlDropItem
(
  aEvt           : event;    // Ereignis
  aHdlTarget     : int;      // Ziel-Objekt (GanttGraph)
  aHdlIvl        : int;      // Deskriptor des Intervalls
  aDropType      : int;      // Drop-Ereignis
  aRect          : rect;     // verändertes Intervall-Rechteck
) : logic
local begin
  vX : int;
  vText : alpha;
  vLen : int;
  vVal : int;
  vStart : int;
  vStart2 : int;
  vFarbeFg : int;
  vFarbeBg : int;
  vTip : alpha;
  vName : alpha;
  vName2 : alpha;
  vResult : logic;
  vZeile : int;
  vHdl : int;
  vObj : int;
  vTmp : int;
  vArea : rect;
  vOk : logic;
end;
begin

  Case (aDropType) of

    // unterbinde das Verändern der Größe durch Ziehen
    // an der linken Intervall-Seite.
    _WinIvlDropSizeLeft : begin
      $bt.TeP.Refresh->Winfocusset();
      RETURN (false);
    end;

    // erlaube das Verändern der Größe durch Ziehen an
    // der rechten Intervall-Seite, wenn das resultierende
    // Intervall maximal fünf Zellen umfaßt.
     _WinIvlDropSizeRight : begin
      $bt.TeP.Refresh->Winfocusset();
      RETURN false;
    end;

    _WinIvldropcopy : begin
      $bt.TeP.Refresh->Winfocusset();
      RETURN false;
    end;

    _WinIvlDropMove : begin

      vResult   # y;

      vName     # aHdlIvl->wpName;
      vStart    # aRect:left;
      vLen      # (aHdlIvl->wparea:right)-(aHdlIvl->wparea:left)+1;
      vArea     # aHdlIvl->wpArea;
      vZeile    # vArea:top;
      vText     # aHdlIvl->wpcaption;
      vTip      # aHdlIvl->wpHelptip;
      vFarbeFg  # aHdlIvl->wpColFg;
      vFarbeBg  # aHdlIvl->wpColBkg;

/******
      // Überschneidungen? dann erweitern...
      if (aEvt:ID=_WinEvtIvlDropItemOverlap) then begin
        vX # 0;
        vVal # aHdlTarget->WinGanttIvlAdd(vStart,vX,vLen,vName,vText);
        WHILE (vVal=0) do begin
          vX # vX + 1;
          if (vX>aHdlTarget->wpCellCountVert) then aHdlTarget->wpcellcountVert # vX;
          vVal # aHdlTarget->WinGanttIvlAdd(vStart,vX,vLen,vName,vText);
        END;
        vVal->wpHelptip # vTip;
        vVal->wpColFg   # vFarbeFg;
        vVal->wpColBkg  # vFarbeBg;

        // aus dem alten Gantt entfernen
        aHdlIvl->WinGanttIvlRemove();
        vResult # false;
        end
      else begin
        // aus dem alten Gantt entfernen
        aHdlIvl->WinGanttIvlRemove();
        vResult # false;

        vX # aRect:top;
        vVal # aHdlTarget->WinGanttIvlAdd(vStart,vX,vLen,vName,vText);
        vVal->wpHelptip # vTip;
        vVal->wpColFg   # vFarbeFg;
        vVal->wpColBkg  # vFarbeBg;
      end;




      // alten Gantt reorganisieren
      vHdl # aEvt:obj;
      vObj # vHdl->WinInfo(_WinFirst, 1, _WinTypeInterval);
      WHILE (vObj<>0) do begin
        vTmp # vObj->WinInfo(_WinNext, 1, _WinTypeInterval);
        vArea #  vObj->wparea;
        if (vArea:top>vZeile) then vObj->wpcustom # 'REDO';
        vObj # vTmp;
      END;


      vHdl # aEvt:obj;
      vObj # vHdl->WinInfo(_WinFirst, 1, _WinTypeInterval);
      WHILE (vObj<>0) do begin
        vTmp # vObj->WinInfo(_WinNext, 1, _WinTypeInterval);
        vArea #  vObj->wparea;

        if (vObj->wpcustom='REDO') then begin
          vName2    # vObj->wpname;
          vStart2   # vArea:left;
          vLen      # vArea:right - vArea:left + 1;
          vText     # vObj->wpcaption;
          vTip      # vObj->wpHelptip;
          vFarbeFg  # vObj->wpColFg;
          vFarbeBg  # vObj->wpColBkg;
          vObj->WinGanttIvlRemove();
//vHdl->winupdate(_WinGntRefresh); syssleep(1000);
//debug('mache:'+vText);
  vX # 0;
  vVal # vHdl->WinGanttIvlAdd(vStart2,vX,vLen,vName2,vText);
  WHILE (vVal=0) do begin
//debug(vHdl->wpname+' add '+cnvai(vX));
    vX # vX + 1;
    if (vX>vHdl->wpCellCOuntVert) then vHdl->wpcellcountVert # vX;
    vVal # vHdl->WinGanttIvlAdd(vStart2,vX,vLen,vName2,vText);
  END;
if (vVal<>0) then begin
  vVal->wpHelptip # vTip;
  vVal->wpColFg   # vFarbeFg;
  vVal->wpColBkg  # vFarbeBg;
end;
        end;


        vObj # vTmp;
      END;
****/

      // Termin in der DB änpassen
      RecBufClear(980);
      TeM.Nummer # Cnvia(vName);
      RecRead(980,1,_recLock);
      TeM.Start.Von.Datum # Cnvda(aHdlTarget->wpcustom);
      TeM.Start.Von.Zeit  # Cnvti(((vStart+11)*30)*60*1000);

      vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
      vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000) + cnvif(TeM.Dauer);

      TeM.Ende.Von.Datum  # CnvdI( (vTmp / 1440) + cnvid(1.1.2000));
      TeM.Ende.Von.Zeit   # cnvti( (vTmp % 1440) * 60000);
      RekReplace(980,_recUnlock,'MAN')

      Buildintervalls();
      Refresh();

      $bt.TeP.Refresh->Winfocusset();
      RETURN vResult;
    end;

  end;

/***
  // aktualisere bestehenden Datensatz in der Datenbank
  if (aDropType != _WinIvlDropCopy and aHdlIvl <> 0) begin
    IVL.iID # aHdlIvl->wpID;
    if (RecRead(IVL.D.Intervall, 1, _RecLock) = _rOk) begin
      IVL.iPosX # aRect:left;
      IVL.iPosY # aRect:top;
      IVL.iLen  # aRect:right - aRect:left + 1;
      RekReplace(IVL.D.Intervall, _RecUnlock,'AUTO');
    end,
  end;
***/

  Refresh();

  $bt.TeP.Refresh->Winfocusset();
  RETURN (true);
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  vA  : alpha;
end;
begin

  if (aEvt:obj->wpname='DL.User') then begin
    WinLstCellGet($DL.User,vA,1,aRecId);
    $ed.user->wpcaption # vA;
    $ed.User->WinFocusSet(true);

    BuildIntervalls();
    Refresh();
  end;

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
/*
  if (aEvt:Obj->wpname='ed.Datum') and ($ed.Datum->wpcaptiondate<>0.0.0) then begin
    BuildHeader();
    BuildIntervals();
    RecBufClear(980);
    Refresh();
  end;
*/
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
local begin

  vTyp  : alpha;
  vData : alpha;
end;
begin


// ST 2014-12-04: Alte Version über ID1 und 2
/*
  case (TeM.A.Datei) of
    100 : begin
      Adr.Nummer # TeM.A.ID1;
      RecRead(100,1,0);
      Gv.Alpha.01 # Adr.Stichwort;
    end;

    102 : begin
      Adr.P.Adressnr  # TeM.A.ID1;
      Adr.P.Nummer    # TeM.A.ID2;
      RecRead(102,1,0);
      Gv.Alpha.01 # Adr.P.Stichwort;
    end;

    120 : begin
      Prj.Nummer # TeM.A.ID1;
      RecRead(120,1,0);
      Gv.Alpha.01 # Prj.Stichwort;
    end;

    800 : begin
      Gv.Alpha.01 # TeM.A.Code;
    end;

    otherwise begin
      Gv.Alpha.01 # TeM.A.Code;
    end;

  end;
*/
  // ST 2014-12-04: Neue Version über Key
  Tem_A_Data:Code2Text(var vTyp, var vData);
  Gv.Alpha.01  # StrAdj(vTyp + ' ' + vData,_StrBegin | _StrEnd);


end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin
  WinSearchPath(aEvt:Obj);
  aEvt:Obj->wpcustom # cnvai(VarInfo(WindowBonus));

  $DL.User->WinLstDatLineRemove(_WinLstDatLineAll);
  $DL.User->WinLstDatLineAdd('<alle>');
  Erx # RecRead(800,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (gUsergroup<>'JOB-SERVER') and
      (Usr.Username<>'LIZENZ') and (Usr.Username<>'BETRIEB') and
      (Usr.Username<>'SUPERUSER') then begin
      $DL.User->WinLstDatLineAdd(Usr.Username);
    end;
    Erx # RecRead(800,1,_recNext);
  END;
  $ed.User->wpcaption # '<alle>';
  $ed.Datum->wpcaptiondate # today;
//  $PL.Sort->WinLstCellSet(CnvAI(Prg.Key.Key),2,_WinLstDatLineLast);

  Usr_data:RecReadThisUser();

  BuildHeader();
  BuildIntervalls();
  RecBufClear(980);
  Refresh();

  Erx # SysTimerCreate(1000,-1,cDialog);
  $Hdl.Timer->wpcustom # cnvai(Erx);

  RETURN true;
end;


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm
(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx : int;
end;
begin
  Erx # cnvia($Hdl.Timer->wpcustom);
  if (Erx<>0) then Erx->SysTimerClose();
  App_Main:EvtTerm(aEvt);
end;


//========================================================================
//  EvtTimer
//
//========================================================================
sub EvtTimer (
  aEvt : event;
  aTimerId : int;
) : logic
local begin
  Erx : int;
  vNr : int;
end;
begin

  if (gMdi<>cDialog) then RETURN true;

  gMdi->wpcaption  # Translate('Terminplaner') + '          aktuelle Zeit: ' + cnvat(now,_fmttimeseconds)+'          letztes Update: '+$lb.lastUpdate->wpcustom;

  Erx # WinFocusGet();
  if (Erx=0) then RETURN true;

  Erx # Erx->Wininfo(_winType);
  if (Erx=_WinTypeInterval) or
  (Erx=_WinTypeGanttGraph) or
  (Erx=_WinTypeGanttView) then RETURN true;


  $lb.lastUpdate->wpcustom # cnvat(now,_fmttimeseconds);
  gMdi->wpcaption  # Translate('Terminplaner') + '          aktuelle Zeit: ' + cnvat(now,_fmttimeseconds)+'          letztes Update: '+$lb.lastUpdate->wpcustom;

  vNr # TeM.Nummer;
//  BuildIntervalls();
  // aktuellen Termin nochmal holen
  if (TeM.Nummer<>0) then begin
    Erx # RecRead(980,1,0);
    if (Erx>_rLocked) then RecBufclear(980);
  end;
  Refresh();

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

  if (aEvt:obj->wpname='ed.Datum') and ($ed.Datum->wpchanged) then begin
    BuildHeader();
    BuildIntervalls();
    RecBufClear(980);
    Refresh();
  end;

  RETURN true;
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