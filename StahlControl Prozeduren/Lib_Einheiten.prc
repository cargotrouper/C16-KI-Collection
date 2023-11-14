@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Einheiten
//                OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  02.07.2012  AI  Parameterauswahl als SPLASH ohne Rahmen
//  01.08.2012  AI  Popup: beim Preistyp ¥-EK auswählbar (Projekt 1326/271)
//  08.10.2013  AH  Neu: CheckMEH
//  15.10.2013  AH  "WandleMEH" rundet nach Settings
//  16.10.2013  AH  Popup: VORGANGSTYP-EK eingebaut
//  23.10.2013  AH  MEH "cbm"
//  15.05.2014  AH  Neu: TransferMengen
//  27.11.2014  AH  "WanldeMEH" hat für LfdM Fallbackroutine
//  06.05.2015  AH  "WanldeMEH" nimmt bei MatMix auch Artikeldaten
//  21.07.2015  AH  "WanldeMEH" kann Bedarf 540
//  28.07.2015  AH  Arbeitsgang Schaelen
//  10.12.2015  AH  Bugfix: "TransferMengen" hat VWa für DFAKT nicht beachtet
//  17.03.2016  AH  neue Einheit: BA-Status
//  01.06.2016  AH  "CheckMEH" mit VAR
//  01.08.2016  AH  "TransferMengen" setzt für VSB die Rechnungsmenge richtig laut Verwiegungsart
//  29.06.2017  AH  "WandleMEH" kann QM/M auch wenn keine Länge angegeben ist
//  17.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  19.11.2019  AH  "WandleMEH" kann Stk aus "Einzellängen in Gesamtlänge" errechnen
//  27.07.2021  AH  ERX
//  2022-11-02  AH  "PopUp" akzeptiert Prozedur zum Extend
//  2023-08-21  ST  "todo-Meldung" bei Mengenumrechnung z.B. KG -> L  ausgebaut;
//
//  Subprozeduren
//    SUB GanzDiv
//    SUB _OpenPopUp
//    SUB Popup
//    SUB CheckMEH
//    SUB WandleMEH
//    SUB PreisProT
//    SUB LaengenKonv
//    SUB TranslateMEH
//    SUB TransferMengen
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen


//========================================================================
//  GanzDiv
//
//========================================================================
sub GanzDiv(aA : float; aB : float) : int;
local begin
  vX  : int;
  vY  : float;
end;
begin
  if (aB=0.0) then RETURN 0;

  // ST 2015-08-04
  vY # Rnd(aA / aB,6);
  vX # cnvif(Trn(vY));
  if (Fract(vY)>0.0) then Inc(vX);

  /* Alte Version
    vX # cnvif(Trn(aA / aB));
    if (Fract(aA / aB)>0.0) then Inc(vX);
  */
  RETURN vX;
end;




//========================================================================
//  _SaveBuffers
//
//========================================================================
Sub _saveBuffers(
  var aBuf  : int[];
  aMin  : int;
  aMax  : int;
)
local begin
  vI  : int;
end;
begin
  FOR vI # aMin
  LOOP inc (vI)
  WHILE (vI<=aMax) do begin
    if (FileInfo(vI,_Fileexists)>0) then begin
      aBuf[vI] # Reksave(vI);
    end;
  END;
end;


//========================================================================
//  _RestoerBuffers
//
//========================================================================
Sub _RestoreBuffers(
  var aBuf  : int[];
  aMin  : int;
  aMax  : int;
)
local begin
  vI  : int;
end;
begin
  FOR vI # aMin
  LOOP inc (vI)
  WHILE (vI<=aMax) do begin
    if (aBuf[vI]<>0) then begin
      RekRestore(aBuf[vI]);
    end;
  END;
end;


//========================================================================
//  _OpenPopUp
//
//========================================================================
sub _OpenPopUp(
  aObj          : int;
  aName         : alpha;
  aYY           : int;
  aNoPara2      : logic;
  var aHdl2     : int;
  opt aNoSplash : logic;
  opt aXX       : int;
  opt aClmWid   : int) : int;
local begin
  vX,vY : int;
  vXX   : int;
  vHdl  : int;
  vTmp  : int;
end;
begin
  if (aObj<>0) then begin
    Lib_GuiCom:GetAbsolutXY(aObj, var vX, var vY);
    vXX # aObj->wpAreaRight - aObj->wpAreaLeft;
  end
  else begin
    vX  # 500;
    vY  # 200;
    vXX # 200;
  end;
  if (vXX<80) then vXX # 80;
  if (vXX<aXX) then vXX # aXX;

//debug(aObj->wpname+'X:'+aint(vX)+' '+aint(vXX));
  vHdl # WinOpen('Prg.Para.Auswahl',_WinOpenDialog);

  if (aNoSplash=false) then
    vHdl->wpStyleFrame # _WinWndFrameSplash;

  Lib_GuiCom:SetWindowArea(vHdl,vX,vY,vXX,aYY);
  vHdl->wpCaption # aName+' '+translate('wählen')+'...';
  aHdl2 # vHdl->WinSearch('DL.ParaAuswahl');

  if (aClmWid<>0) then begin
    vTmp # aHdl2->WinSearch('Parameter');
    if (vTMP<>0) then begin
      vTMP->wpClmStretch # false;
      vTMP->wpClmWidth # aClmWid;
      vTmp # aHdl2->WinSearch('Parameter2');
      if (vTMP<>0) then begin
        vTMP->wpClmStretch # true;
      end;;
    end;
  end;
  if (aNoPara2=false) then begin
    vTmp # aHdl2->WinSearch('Parameter2');
    if (vTmp<>0) then vTmp->wpVisible # false;
  end;
  aHdl2->wparearight # aHdl2->wparealeft + vXX;
  aHdl2->wpareabottom # aHdl2->wpareaTop + aYY - 20;

  RETURN vHdl;
end;


//========================================================================
//  PopUp
//        Popup eine Auswahlliste auf und übernimmt ggf. den Inhalt
//========================================================================
sub Popup(
  aTyp      : alpha;
  aObj      : int;
  aFile     : int;
  aTds      : int;
  aPos      : int;
  opt aExtendProc : alpha;
  ) : alpha;
local begin
  vA        : alpha;
  vB        : alpha;
  vHdl      : int;
  vHdl2     : int;
  vType     : int;
  vAtemp    : alpha;
  vI        : int;
  vTmp      : int;
  vBuf      : int[1000];
end;
begin
/**
  if (aObj<>0) then begin
    Lib_GuiCom:GetAbsolutXY(aObj, var vX, var vY);
    vXX # aObj->wpAreaRight - aObj->wpAreaLeft;
    vYY # aObj->wpAreaBottom - aObj->wpAreatop;
  end
  else begin
    vX  # 500;
    vY  # 200;
    vXX # 100;
    vYY # 100;
  end;
***
  if (gMDI<>0) then begin
    vX # vX + gMDI->wpAreaLeft;
    vY # vY + gMDI->wpAreaTop;
  end;
  if (gFrmMain<>0) then begin
    vX # vX + gFrmMain->wpAreaLeft;
    vY # vY + gFrmMain->wpAreaTop;
  end;
***/


  gSelected # 0;
  case StrCnv(aTyp,_StrUpper) of

    'BAG-STATUS' : begin
      vHdl # _OpenPopUp(aObj, Translate('Status'), 100, n, var vHdl2);
      vHdl2->WinLstDatLineAdd(c_BagStatus_Offen);
//      vHdl2->WinLstDatLineAdd(c_BagStatus_Fertig);
      vHdl2->WinLstDatLineAdd(c_BagStatus_Anfrage);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'BAG-EINSATZ' : begin

      WinEvtProcessSet(_WinEvtAll,false);
      WinEvtProcessSet(_WinEvtKeyItem,true);
      WinEvtProcessSet(_WinEvtMouseItem,true);

      vHdl # _OpenPopUp(aObj, Translate('Einsatztyp'), 160, y, var vHdl2);
      vHdl2 # vHdl->WinSearch('DL.ParaAuswahl');
      vTMP # vHdl2->WinSearch('Parameter2');
      if (vTMP<>0) then vTMP->wpVisible # false;
      vHdl2->wparearight # vHdl2->wparealeft + 200;
      vHdl2->wpareabottom # vHdl2->wpareaTop + 160-24;
      if (BAG.VorlageYN=false) then begin
        vHdl2->WinLstDatLineAdd(Translate('Material'));
        vHdl2->WinLstCellSet('200',2);
      end;
      vHdl2->WinLstDatLineAdd(Translate('Weiterbearbeitung'));
      vHdl2->WinLstCellSet('703',2);
      vHdl2->WinLstDatLineAdd(Translate('theor.Material'));
      vHdl2->WinLstCellSet('1200',2);
      vHdl2->WinLstDatLineAdd(Translate('Artikel'));
      vHdl2->WinLstCellSet('250',2);
      vHdl2->WinLstDatLineAdd(Translate('Beistellungsartikel'));
      vHdl2->WinLstCellSet('249',2);
      if (BAG.VorlageYN=false) then begin
        vHdl2->WinLstDatLineAdd(Translate('VSB-Material'));
        vHdl2->WinLstCellSet('506',2);
      end;
      vHdl2->wpcurrentint # 1;
DbgControl(_DbgEnter | _DbgEnterSub | _DbgLeave);
DbgTrace('---------------------- START');
//debugx('zz' + Aint(Bag.IO.nummer)+' '+gmdi->wpname);   // gut

      _SaveBuffers(var vBuf, 700, 799);
      vHdl->windialogrun(0,gMdi);
      _restoreBuffers(var vBuf, 700, 799);

//debugx('A' + Aint(Bag.IO.nummer));  // schlecht

      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then begin
          vHdl2->WinLstCellGet(vB,2,gSelected);
          flddef(aFile,aTds,aPos,cnvia(vB));
        end;
        aObj->wpcaption # vA;
      end;
//debugx('B' + Aint(Bag.IO.nummer));
DbgControl(_DbgEnterOff);
DbgTrace('---------------------- ENDE');
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);

WinEvtProcessSet(_WinEvtAll,true);

    end;


    'SPRACHE' : begin
      vHdl # _OpenPopUp(aObj, Translate('Sprache'), 150, n, var vHdl2);
      vHdl2->WinLstDatLineAdd(Set.Sprache1.Kurz);
      vHdl2->WinLstDatLineAdd(Set.Sprache2.Kurz);
      vHdl2->WinLstDatLineAdd(Set.Sprache3.Kurz);
      vHdl2->WinLstDatLineAdd(Set.Sprache4.Kurz);
      vHdl2->WinLstDatLineAdd(Set.Sprache5.Kurz);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
//        Ein.Sprache # vA;
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'ABMESSUNGSEH' : begin
      vHdl # _OpenPopUp(aObj, Translate('Einheit'), 100, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('m');
      vHdl2->WinLstDatLineAdd('mm');
      vHdl2->WinLstDatLineAdd('inch');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
//x       Ein.AbmessungsEH # vA;
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'GEWICHTSEH' : begin
      vHdl # _OpenPopUp(aObj, Translate('Einheit'), 100, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('kg');
      vHdl2->WinLstDatLineAdd('lbs');
      vHdl2->WinLstDatLineAdd('t');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
//        xin.GewichtsEH # vA;
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'AUFPREISEH' : begin
      vHdl # _OpenPopUp(aObj, Translate('Einheit'), 100, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('%');
      vHdl2->WinLstDatLineAdd('cbm');
      vHdl2->WinLstDatLineAdd('h');
      vHdl2->WinLstDatLineAdd('kg');
      vHdl2->WinLstDatLineAdd('l');
      vHdl2->WinLstDatLineAdd('m');
      vHdl2->WinLstDatLineAdd('min');
      vHdl2->WinLstDatLineAdd('mm');
      vHdl2->WinLstDatLineAdd('qm');
      vHdl2->WinLstDatLineAdd('Stk');
      vHdl2->WinLstDatLineAdd('t');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
//        xin.GewichtsEH # vA;
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'DATUMSTYP' : begin
      vHdl # _OpenPopUp(aObj, Translate('Datumstyp'), 100, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('DA');
      vHdl2->WinLstDatLineAdd('KW');
      vHdl2->WinLstDatLineAdd('MO');
      vHdl2->WinLstDatLineAdd('QU');
      vHdl2->WinLstDatLineAdd('SE');
      vHdl2->WinLstDatLineAdd('JA');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'MEH' : begin
      vHdl # _OpenPopUp(aObj, Translate('Einheit wählen'), 150, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('cbm');
      vHdl2->WinLstDatLineAdd('h');
      vHdl2->WinLstDatLineAdd('kg');
      vHdl2->WinLstDatLineAdd('l');
      vHdl2->WinLstDatLineAdd('m');
      vHdl2->WinLstDatLineAdd('min');
      vHdl2->WinLstDatLineAdd('mm');
      vHdl2->WinLstDatLineAdd('qm');
      vHdl2->WinLstDatLineAdd('Stk');
      vHdl2->WinLstDatLineAdd('t');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'MEH-TRANSPORT' : begin
      vHdl # _OpenPopUp(aObj, Translate('Einheit'), 150, n, var vHdl2);
      vHdl2->WinLstDatLineAdd('kg');
      vHdl2->WinLstDatLineAdd('pauschal');
      vHdl2->WinLstDatLineAdd('m');
      vHdl2->WinLstDatLineAdd('mm');
      vHdl2->WinLstDatLineAdd('Stk');
      vHdl2->WinLstDatLineAdd('t');
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
//        xin.GewichtsEH # vA;
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'ARTIKELTYP' : begin
      vHdl # _OpenPopUp(aObj, Translate('Artikeltyp'), 150, n, var vHdl2);
      vHdl2->WinLstDatLineAdd(c_art_HDL);
      vHdl2->WinLstDatLineAdd(c_art_PRD);
      vHdl2->WinLstDatLineAdd(c_art_BGR);
      vHdl2->WinLstDatLineAdd(c_art_EXP);
      vHdl2->WinLstDatLineAdd(c_art_CUT);
      vHdl2->WinLstDatLineAdd(c_art_SET);
      vHdl2->WinLstDatLineAdd(c_art_VPG);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        if (aObj<>0) then aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      if (aObj<>0) then begin
        aObj->WinUpdate(_WinUpdFld2Obj);
        aObj->winFocusSet(true);
      end;
    end;


    'PREISTYP' : begin
      vHdl # _OpenPopUp(aObj, Translate('Preistyp'), 100, n, var vHdl2);
      if (aExtendProc<>'') then Call(aExtendProc, vHdl2);
      vHdl2->WinLstDatLineAdd('EK');
      vHdl2->WinLstDatLineAdd('INVEK');
      vHdl2->WinLstDatLineAdd('K-EK');
      vHdl2->WinLstDatLineAdd('VK');
      vHdl2->WinLstDatLineAdd('Ø-EK');  // 01.08.2012 AI Projekt 1326/271
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'VORGANGSTYP' : begin
      vHdl # _OpenPopUp(aObj, Translate('Vorgangstyp'), 180, n, var vHdl2, n, 100);
      vHdl2->WinLstDatLineAdd(c_AUF);
      vHdl2->WinLstDatLineAdd(c_ANG);
      vHdl2->WinLstDatLineAdd(c_REKOR);
      vHdl2->WinLstDatLineAdd(c_GUT);
      vHdl2->WinLstDatLineAdd(c_BOGUT);
      vHdl2->WinLstDatLineAdd(c_BEL_KD);
      vHdl2->WinLstDatLineAdd(c_BEL_LF);
      vHdl2->WinLstDatLineAdd(c_VORLAGEAUF);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then Flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'VORGANGSTYP-EK' : begin
      vHdl # _OpenPopUp(aObj, Translate('Vorgangstyp'), 180, n, var vHdl2, n, 100);
      vHdl2->WinLstDatLineAdd(c_Bestellung);
      vHdl2->WinLstDatLineAdd(c_Anfrage);
      vHdl2->WinLstDatLineAdd(c_VorlageAuf);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then Flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'BAAKTION' : begin
      vHdl # _OpenPopUp(aObj, Translate('Arbeitstyp'), 150, n, var vHdl2);
      vHdl2->WinLstDatLineAdd(c_BAG_Abcoil);
      vHdl2->WinLstDatLineAdd(c_BAG_AbLaeng);
      vHdl2->WinLstDatLineAdd(c_BAG_ARTPRD);
      vHdl2->WinLstDatLineAdd(c_BAG_Bereit);
      vHdl2->WinLstDatLineAdd(c_BAG_Check);
      vHdl2->WinLstDatLineAdd(c_BAG_Divers);
      vHdl2->WinLstDatLineAdd(c_BAG_FAHR);
      vHdl2->WinLstDatLineAdd(c_BAG_GLUEHEN);
      vHdl2->WinLstDatLineAdd(c_BAG_KANT);
      vHdl2->WinLstDatLineAdd(c_BAG_MATPRD);
      vHdl2->WinLstDatLineAdd(c_BAG_MESSEN);
      vHdl2->WinLstDatLineAdd(c_BAG_OBF);
      vHdl2->WinLstDatLineAdd(c_BAG_PACK);
      vHdl2->WinLstDatLineAdd(c_BAG_PAKET);
      vHdl2->WinLstDatLineAdd(c_BAG_QTEIL);
      vHdl2->WinLstDatLineAdd(c_BAG_SAEGEN);
      vHdl2->WinLstDatLineAdd(c_BAG_SCHAEL);
      vHdl2->WinLstDatLineAdd(c_BAG_SPALT);
      vHdl2->WinLstDatLineAdd(c_BAG_SPLIT);
      vHdl2->WinLstDatLineAdd(c_BAG_SPULEN);
      vHdl2->WinLstDatLineAdd(c_BAG_SPALTSPULEN);
      vHdl2->WinLstDatLineAdd(c_BAG_TAFEL);
      vHdl2->WinLstDatLineAdd(c_BAG_UMLAGER);
      vHdl2->WinLstDatLineAdd(c_BAG_VERSAND);
      vHdl2->WinLstDatLineAdd(c_BAG_VSB);
      vHdl2->WinLstDatLineAdd(c_BAG_WALZ);
      vHdl2->WinLstDatLineAdd(c_BAG_WalzSpulen);
      vHdl2->WinLstDatLineAdd(c_BAG_Custom);
      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        vHdl2->WinLstCellGet(vA,1,gSelected);
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      aObj->WinUpdate(_WinUpdFld2Obj);
      aObj->winFocusSet(true);
    end;


    'ZAHLUNGSART' :  begin
todo('OBSOLETE !');
    RETURN '';
      vHdl # _OpenPopUp(aObj, Translate('Zahlungsart'), 150, n, var vHdl2, aObj=0);
      vHdl2->WinLstDatLineAdd(Translate('Bar'),1);
      vHdl2->WinLstDatLineAdd(Translate('Check'),2);
      vHdl2->WinLstDatLineAdd(Translate('Überweisung'),3);

      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);
      if (gSelected<>0) then begin
        if (aObj<>0) then begin
          aObj->wpcaptionint # gSelected;
        end;
        vA # aint(gSelected);
      end;
      vHdl->WinClose();
      gSelected # 0;
      if (aObj<>0) then begin
        aObj->WinUpdate(_WinUpdFld2Obj);
        aObj->winFocusSet(true);
      end;
    end;


    'TERMINTYP' : begin
      vHdl # _OpenPopUp(aObj, Translate('Termintyp'), 100, n, var vHdl2, n, 300);

      // Auswahlliste füllen
      vi # 0;
      REPEAT
        vi # vi + 1;
        vA # Call('Lib_Termine:GetTypeName',cnvaI(vi), true);
        if (vA<>'') then vHdl2->WinLstDatLineAdd(vA);
      UNTIL (vA='');

      vHdl2->wpcurrentint # 1;
      vHdl->windialogrun(0,gMdi);

      if (gSelected<>0) then begin
        vA # Call('Lib_Termine:GetTypeKrzl',cnvai(gSelected));
        if (aFile<>0) then flddef(aFile,aTds,aPos,vA);
        if (aObj<>0) then aObj->wpcaption # vA;
      end;
      vHdl->WinClose();
      gSelected # 0;
      if (aObj<>0) then begin
        aObj->WinUpdate(_WinUpdFld2Obj);
        aObj->winFocusSet(true);
      end;
    end;

  end;

  RETURN vA;
end;


//========================================================================
//  CheckMEH
//
//========================================================================
sub CheckMEH(var aMEH : alpha) : logic;
local begin
  vMEH  : alpha;
end;
begin

  vMEH # StrCnv(aMEH, _StrUpper);
  if (vMEH='STK') then      aMEH # 'Stk';
  if (vMEH='M') then        aMEH # 'm';
  if (vMEH='ROLLE') then    aMEH # 'Rolle';
  if (vMEH='KG') then       aMEH # 'kg';
  if (vMEH='T') then        aMEH # 't';
  if (vMEH='H') then        aMEH # 'h';
  if (vMEH='PAUSCHAL') then aMEH # 'pauschal';
  if (vMEH='MM') then       aMEH # 'mm';
  if (vMEH='QM') then       aMEH # 'qm';
  if (vMEH='L') then        aMEH # 'l';
  if (vMEH='CBM') then      aMEH # 'cbm';
  if (vMEH='ROLLE') then    aMEH # 'Rolle';

  RETURN (aMEH='Stk') or (aMEH='m') or (aMEH='Rolle') or
        (aMEH='kg') or (aMEH='t') or (aMEH='h') or (aMEH='pauschal') or
        (aMEH='mm') or (aMEH='qm') or (aMEH='l') or (aMEH='cbm');

end;


//========================================================================
//  WandleMEH
//            Wandelt die Mengen in eine Ziel-MEH um
//========================================================================
sub WandleMEH(
  aDatei      : int;
  aStk        : int;
  aGewicht    : float;
  aMenge      : float;
  aMEH        : alpha;
  aZielMEH    : alpha;      // Ziel MEH
  ) : float;
local begin
  Erx         : int;
  vAusArtikel : logic;
  vAusCharge  : logic;
  vAusMat     : logic;
  vLfdm       : float;
  vQM         : float;
  vCBM        : float;
  vTheoGew    : float;
  vTheoStk    : int;
  vTheoLfdM   : float;
  vX          : float;
  vArtMEH     : alpha;
  vD,vB,vL    : float;
  vKgProM     : float;
end;
begin

  // 2023-01-09 AH : Proj. 2429/1111
  if (aMEH=aZielMEH) then begin
    if (aMenge<>0.0) then RETURN aMenge;
    if (aStk=0) and (aGewicht=0.0) then RETURN 0.0;
  end;

  // 2022-11-16 AH
  if (aMenge=0.0) then aMEH # '';

  if (aDatei=252) and (Art.C.Artikelnr='') then aDatei # 250;

//if (aDatei=501) then begin
//debug('KEY250');
//debug(cnvai(aDatei)+' Wandle : '+aMEH+'  ->  '+aZielMEH);
//debug(aint(aStk)+'Stk   '+anum(aGewicht,0)+'kg   '+aNum(aMenge,0)+aMEH);
//end;


  if (aZielMEH='') then RETURN 0.0;
  aMEH # StrCnv(aMEH,_StrUpper);
  aZielMEH # StrCnv(aZielMEH,_StrUpper);


  if (aMEH='KG') and (aGewicht=0.0) then aGewicht # aMenge;
  if (aMEH='T') and (aGewicht=0.0) then aGewicht # aMenge / 1000.0;
  if (aMEH='STK') and (aStk=0) then aStk # CnvIf(aMenge);
  if (aMEH='M') then begin
    vLfdM   # aMenge;
    aMEH    # 'MM';
    aMenge  # aMenge * 1000.0;
  end;
  if (aMEH='MM') then begin
    vLfdm   # Rnd(aMenge / 1000.0, set.Stellen.Menge);
  end;


  vArtMEH # StrCnv(Art.MEH,_Strupper);

  case aDatei of

    200 : begin       // Material
//debugx(aint(mat.nummer));
      vD # Mat.Dicke;
      vB # Mat.Breite;
      vL # "Mat.Länge";

      // 27.11.2014
      if (vL=0.0) then begin
        if (Mat.Strukturnr<>'') and (aGewicht<>0.0) then begin
          Erx # RekLink(250,200,26,_RecFirst); // Artikel holen
          if (Erx<=_rLocked) and (Art.RotativYN) and (Art.GewichtProM<>0.0) then begin
            if (vLfdm=0.0) then vlfdm # aGewicht / Art.GewichtProM;
            vL # vLfdM * 1000.0;
            if (aStk<>0) then
              vL # vL / cnvfi(aStk);
          end;
        end;
      end;
      if (vL=0.0) then
        vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(Mat.Bestand.Gew, Mat.Bestand.Stk, Mat.Dicke, Mat.Breite, Wgr_Data:GetDichte(Mat.Warengruppe, 200), "Wgr.TränenKgProQM");
      vAusMat # y;
/***
      if (aZielMEH='MM') or (aZielMEH='M') then begin
        RekLink(819,200,1,_recFirst);           // Warengruppe holen
        if (Wgr.Materialtyp=c_WGRTyp_Stab) or
          (Wgr.Materialtyp=c_WGRTyp_Rohr) or
          (Wgr.Materialtyp=c_WGRTyp_Profil) then begin
          if (Mat.Strukturnr<>'') and (Wgr.Dateinummer=c_Wgr_ArtMatMix) then begin
            RekLink(250, 200, 26, _recFirst);   // Artikel holen
            vKgProM # Art.GewichtProM;
          end;
//debugx(anum(aGewicht,2)+' kg   L'+anum("mat.länge",3)+'  stk:'+aint(mat.bestand.Stk));
          // A) über Anzahl * Länge
          if (vLfdm=0.0) then vlfdm # vL /1000.0 * cnvfi(aStk);
//debugx('lfdm:'+anum(vLfdm,2));
          // klappt nicht? dann B) über Artikel berechnen
          if (vLfdM=0.0) then
            DivOrNull(vLfdM, aGewicht, vKgProM, Set.Stellen.Menge);
//debugx('lfdm:'+anum(vLfdm,2));
          // klappt nicht? dann C) per Dichte
          if (vLfdM=0.0) then begin
            if (Wgr.Materialtyp=c_WGRTyp_Stab) or
              (Wgr.Materialtyp=c_WGRTyp_Rohr)then begin
              vX # Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD(1, "Mat.Länge", Wgr_Data:GetDichte(Mat.Warengruppe, "Mat.Güte", Art.Nummer), Mat.RAD-(2.0*Mat.RID), Mat.RAD);
              DivOrNull(vX, aGewicht, vX, 3);   // "Anzahl" errechnen
              if (vLfdm=0.0) then vLfdM # "Mat.Länge" * vX / 1000.0;
//debugx('lfdm:'+anum(vLfdm,2));
            end;
          end;
        end;
//if (vLfdm<>0.0) then debug('------------------------');
        if (vLfdM<>0.0) then RETURN vLfdM;
      end;
***/

    end;

    250 : begin       // Artikel
      vD # Art.Dicke;
      vB # Art.Breite;
      vL # "Art.Länge";
      vKgProM # Art.GewichtProM;
      vAusArtikel # y;
      vAusCharge  # n;
    end;

    252 : begin       // Artikel-Chargen
      vD # "Art.C.Dicke";
      vB # Art.C.Breite;
      vL # "Art.C.Länge";
      vAusArtikel # n;
      vAusCharge  # y;
    end;

    401 : begin       // Auftragsposition
      vD # Auf.P.Dicke;
      vB # Auf.P.Breite;
      vL # "Auf.P.Länge";
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) and (Auf.P.ArtikelNr<>'') then begin
        Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr) or Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin

        // 29.06.2017 AH: Länge errechnen, wenn nur D,B und Gewicht vorgegeben
        if (vL=0.0) and (vD<>0.0) and (vB<>0.0) and (aGewicht<>0.0) then begin
          Erx # RecLink(819,401,1,0);   // Warengruppe holen
          vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(aGewicht, 1, vD, vB, Wgr_Data:GetDichte(Wgr.Nummer, 401), "Wgr.TränenKgProQM");
        end;

        vAusMat # y;
        if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) and (Auf.P.Artikelnr<>'') then begin
          Erx # RekLink(250,401,2,_RecFirst); // Artikel holen
          if (Erx<=_rLocked) then begin
            vKgProM     # Art.GewichtProM;
            vAusArtikel # y;  // 06.05.2015
          end;
        end;
      end;
    end;

    403 : begin       // Auftragsaufpreise
    end;

    404 : begin       // Auftragsaktionen
      vD # Auf.A.Dicke;
      vB # Auf.A.Breite;
      vL # "Auf.A.Länge";
      if (Wgr_Data:IstArt(Auf.P.Wgr.Dateinr)) then begin
        vAusArtikel # n;
        vAusCharge  # y;
      end;
      if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then begin
        vAusMat # y;
      end;
    end;

    405 : begin       // Kalkulation
    end;

    409 : begin       // Auftragsstückliste
      if (Wgr_Data:IstArt()) or (Wgr_Data:IstMix()) and
        (Auf.P.ARtikelnR<>'') then begin
        Erx # RekLink(250,409,3,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      vD # Auf.SL.Dicke;
      vB # Auf.SL.Breite;
      vL # "Auf.SL.Länge";
    end;

    411 : begin       // Auftragsposition
      vD # "Auf~P.Dicke";
      vB # "Auf~P.Breite";
      vL # "Auf~P.Länge";
      if (Wgr_Data:IstArt("Auf~P.Wgr.Dateinr")) and ("Auf~P.ArtikelNr"<>'') then begin
        Erx # RekLink(250,411,2,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      if (Wgr_Data:IstMat("Auf~P.Wgr.Dateinr")) or (Wgr_Data:IstMix("Auf~P.Wgr.Dateinr")) then begin
        vAusMat # y;
      end;
    end;

    501 : begin       // Einkaufsposition
      vD # Ein.P.Dicke;
      vB # Ein.P.Breite;
      vL # "Ein.P.Länge";
      if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) and (Ein.P.ArtikelNr<>'') then begin
        Erx # RecLink(250,501,2,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin

        // 29.06.2017 AH: Länge errechnen, wenn nur D,B und Gewicht vorgegeben
        if (vL=0.0) and (vD<>0.0) and (vB<>0.0) and (aGewicht<>0.0) then begin
          Erx # RecLink(819,501,1,0);   // Warengruppe holen
          vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(aGewicht, 1, vD, vB, Wgr_Data:GetDichte(Wgr.Nummer, 501), "Wgr.TränenKgProQM");
        end;

        vAusMat # y;
        if (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr) and (Ein.P.ARtikelnr<>'')) then begin
          Erx # RekLink(250,501,2,_RecFirst); // Artikel holen
          if (Erx<=_rLocked) then begin
            vKgProM     # Art.GewichtProM;
            vAusArtikel # y;  // 06.05.2015
          end;
        end;
      end;
    end;
    503 : begin       // Einkaufsaufpreise
    end;
    504 : begin       // Einkaufsaktionen
    end;
    505 : begin       // Einkaufskalkulation
    end;

    506 : begin       // Wareneingang
      vD # Ein.E.Dicke;
      vB # Ein.E.Breite;
      vL # "Ein.E.Länge";
      if (Wgr_Data:IstArt(Ein.P.Wgr.Dateinr)) and (Ein.P.ArtikelNr<>'') then begin
        Erx # RecLink(250,506,5,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr)) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
        vAusMat # y;
        if (vL=0.0) then
          vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(Ein.E.Gewicht, "ein.e.Stückzahl", Ein.E.Dicke, Ein.E.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 506), "Wgr.TränenKgProQM");
        // 23.03.2022 AH, HWN
        if (vL=0.0) and (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr)) then begin
          Erx # RecLink(250,506,5,_RecFirst); // Artikel holen
          vAusArtikel # Y;
          vAusCharge  # n;
          vKgProM     # Art.GewichtProM;
        end;
      end;
    end;


    511 : begin       // Einkaufsposition-Ablage
      vD # "Ein~P.Dicke";
      vB # "Ein~P.Breite";
      vL # "Ein~P.Länge";
      if (Wgr_Data:IstArt("Ein~P.Wgr.Dateinr")) and (Ein.P.ArtikelNr<>'') then begin
        Erx # RecLink(250,511,2,_RecFirst); // Artikel holen
        vAusArtikel # Y;
        vAusCharge  # n;
        vKgProM     # Art.GewichtProM;
      end;
      if (Wgr_Data:IstMat("Ein~P.Wgr.Dateinr")) or (Wgr_Data:IstMix("Ein~P.Wgr.Dateinr")) then begin
        vAusMat # y;
      end;
    end;

    540 : begin       // Bedarf
      // ohne Artikel geht nichts!
      if (Bdf.Artikelnr='') then RETURN 0.0;

      Erx # RecLink(250,540,7,_RecFirst); // Artikel holen
      if (Erx>_rLocked) then RETURN 0.0;

      vD # Art.Dicke;
      vB # Art.Breite;
      vL # "Art.Länge";
      vAusArtikel # Y;
      vAusCharge  # n;
      vKgProM     # Art.GewichtProM;
    end;

    701 : begin       // BA-Input
      Erx # RecLink(819,701,7,0); // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      vD # BAG.IO.Dicke;
      vB # BAG.IO.Breite;
      vL # "BAG.IO.Länge";

      // 27.11.2014
      if (vL=0.0) then begin
        if (BAG.IO.Artikelnr<>'') and (aGewicht<>0.0) then begin
          Erx # RekLink(250,701,8,_RecFirst); // Artikel holen
          if (Erx<=_rLocked) and (Art.RotativYN) and (Art.GewichtProM<>0.0) then begin
            if (vLfdm=0.0) then vlfdm # aGewicht / Art.GewichtProM;
            vL # vLfdM * 1000.0;
            if (aStk<>0) then
              vL # vL / cnvfi(aStk);
          end;
        end;
      end;
      if (vL=0.0) then
        vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM")
      vAusMat # y;
    end;

    703 : begin       // BA-Fertigung   2022-12-20  AH
      Erx # RecLink(819,703,5,0); // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      vD # BAG.F.Dicke;
      vB # BAG.F.Breite;
      vL # "BAG.F.Länge";

      if (vL=0.0) then begin
        if (BAG.F.Artikelnummer<>'') and (aGewicht<>0.0) then begin
          Erx # RekLink(250,703,13,_RecFirst); // Artikel holen
          if (Erx<=_rLocked) and (Art.RotativYN) and (Art.GewichtProM<>0.0) then begin
            if (vLfdm=0.0) then vlfdm # aGewicht / Art.GewichtProM;
            vL # vLfdM * 1000.0;
            if (aStk<>0) then
              vL # vL / cnvfi(aStk);
          end;
        end;
      end;
      if (vL=0.0) then
        vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.F.Gewicht, "BAG.F.Stückzahl", BAG.F.Dicke, BAG.F.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 703), "Wgr.TränenKgProQM")
      vAusMat # y;
    end;

    707 : begin       // BA-Fertigung/FErtigmeldung
      Erx # RecLink(819,703,5,0); // Warengruppe holen
      if (Erx>_rLocked) then RecBufClear(819);
      vD # BAG.F.Dicke;
      if (vD=0.0) then vD # BAG.IO.Dicke;
      vB # BAG.F.Breite;
      if (vB=0.0) then vB # BAG.IO.Breite;
      vL # "BAG.F.Länge";
      if (vL=0.0) then vL # "BAG.IO.Länge";
      if ("BAG.F.Länge"=0.0) then begin
        vL # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", vD, vB, Wgr_Data:GetDichte(Wgr.Nummer, 707), "Wgr.TränenKgProQM")
      end;
      vAusMat # y;
    end;

    otherwise begin
      TODO('MEH-Wandlung für Datei'+cnvai(aDatei));
      RETURN 0.0;
    end;
  end;


  if (vLfdM=0.0) then
    vlfdm # vL /1000.0 * cnvfi(aStk);
  if (vQM=0.0) then
    vQM   # vL  /1000.0 * vB /1000.0 * cnvfi(aStk);
//debugx(anum(vQM,0)+'qm');

  if (vCBM=0.0) then
    vCBM  # vL /1000.0 * vB /1000.0 * vD / 1000.0 * cnvfi(aStk);
  if (vlfdm=0.0) and (aMEH='MM') then vlfdm # aMenge / 1000.0;
  if (vQM=0.0) and (aMEH='QM') then vQM # aMenge;
  if (vCBM=0.0) and (aMEH='CBM') then vCBM # aMenge;

  // 27.11.2014:
  if (vLfdM=0.0) and (aMEH='m') then vLfdM # aMenge;
  if (vLfdM=0.0) and (aGewicht<>0.0) and (vKgProM<>0.0) then
    vlfdm # aGewicht / vKgProM;
  vTheoLfdM # vlfdM;
//debugx(anum(vkgProm,2)+'kg/m   '+anum(vLfdM,0)+'m');

//if (gusername='DEBUG') then begin
//  debugx(aint(aStk)+'stk '+anum(vLfdm,0)+'m '+anum(vKgProM,0)+'kgm '+anum(vtheogew,0)+'kg ');
//end;

  // aus Art.Chargendatei errechnen
  if (vAusCharge) then begin
    vTheoGew  # "Art.GewichtProStk" * cnvfi(aStk);
    if (vArtMEH='QM') then begin
      vX # "Art.Länge"  /1000.0 * Art.Breite /1000.0 * cnvfi(aStk);
      if (vX<>0.0) and (vQM<>0.0) then
        vTheoGew # vTheoGew / vX * vQM;
    end
    else if (vArtMEH='M') or (vArtMEH='MM') then begin
      if ("Art.Länge"<>0.0) and (vL<>0.0) then
        vTheoGew # vTheoGew / "Art.Länge" * vL;
    end;
    if (Art.RotativYN) and (vTheoGew=0.0) and (vArtMEH='M') and ("Art.GewichtProm"<>0.0) then
      vTheoGew # rnd(vlfdM * "Art.GewichtProm",2);
    if (vTheoGew=0.0) then
      vTheoGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(aStk, vD, vB, vL, Art.SpezGewicht, 0.0);
  end;


  // aus Artikeldatei errechnen
  if (vAusArtikel) or (vAuscharge) then begin
//    ((vAusCharge) and (vTheoGew=0.0)) then begin
    if (Art.RotativYN) and (vTheoGew=0.0) and ("Art.GewichtProm"<>0.0) then vTheoGew # rnd(vlfdM * "Art.GewichtProm",2);
    if (vTheoGew=0.0) then vTheoGew # (Cnvfi(aStk) * "Art.GewichtProStk");
    if (vTheoGew=0.0) then vTheoGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(aStk, vD, vB, vL, Art.SpezGewicht, 0.0);
    if (vTheoStk=0) then begin
      if (aGewicht<>0.0) and ("Art.GewichtProStk"<>0.0) then begin
        vTheoStk # GanzDiv(aGewicht , "Art.GewichtProStk");
      end
      else if (Art.RotativYN) and (vLfdm<>0.0) and (vL<>0.0) then begin // 19.11.2019 : Auf.MEH=m , Auf.L<>Art.L, wie oft brauchet man Auf.L für Auf.Menge?
        vTheoStk # GanzDiv(vlfdM*1000.0 , vL);
      end
      else if (vTheoGew<>0.0) and ("Art.GewichtProStk"<>0.0) then begin
        vTheoStk # GanzDiv(vTheoGew , "Art.GewichtProStk");
      end;
    end;

// 27.11.2014   vlfdm # vL /1000.0 * cnvfi(aStk);
    vQM   # vL  /1000.0 * vB /1000.0 * cnvfi(aStk);
    vCBM  # vL  /1000.0 * vB /1000.0 * vD /1000.0 * cnvfi(aStk);
    if (vlfdm=0.0) and (aMEH='MM') then vlfdm # aMenge / 1000.0;
    if (vQM=0.0) and (aMEH='QM') then vQM # aMenge;
    if (vCBM=0.0) and (aMEH='CBM') then vCBM # aMenge;

    if (vTheoStk<>0) then begin
      if (ARt.RotativYN) and (vTheoGew=0.0) and ("Art.GewichtProm"<>0.0) then vTheoGew # rnd(vlfdM * "Art.GewichtProm",2);
      if (vTheoGew=0.0) then vTheoGew # (Cnvfi(vTheoStk) * "Art.GewichtProStk");
      if (vTheoGew=0.0) then vTheoGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(vTheoStk, vD, vB, vL, Art.SpezGewicht, 0.0);
      if (vlfdM=0.0) then vlfdm # vL /1000.0 * cnvfi(vTheoStk);
      if (vQM=0.0) then vQM   # vL  /1000.0 * vB /1000.0 * cnvfi(vTheoStk);
      if (vCBM=0.0) then vCBM # vL  /1000.0 * vB /1000.0 * vD /1000.0 * cnvfi(vTheoStk);
    end;

  end;  // Artikel


  // Aus Material errechnen
  if (vAusMat) then begin
    if (vLfdM=0.0) then vlfdm # vL /1000.0 * cnvfi(aStk);
    if (vLfdM=0.0) then vlfdM # vTheoLfdM;
    vQM   # vL /1000.0 * vB /1000.0 * cnvfi(aStk);
    vCBM  # vL /1000.0 * vB /1000.0 * vD /1000.0 * cnvfi(aStk);
  end;

  // bisher kein Gewicht? -> dann errechnetes nehmen...
  if (vTheoGew=0.0) and (vkgProM<>0.0) then vTheoGew # vLfdM * vKgProm; // 08.01.2015

  if (aGewicht=0.0) then aGewicht # vTheoGew;
  if (aStk=0) then aStk # vTheoStk;

//debugx('lfdm:'+anum(vLFDM,0));
  // Rückgabe **********************************************
  if (aZielMEH=aMEH) then     RETURN aMenge;
  if (aZielMEH='PAAR') then   RETURN CnvFI(aStk / 2);
  if (aZielMEH='KT') then     RETURN CnvFI(aStk);
  if (aZielMEH='GEB') then    RETURN CnvFI(aStk);
  if (aZielMEH='ROLLE') then  RETURN CnvFI(aStk);
  if (aZielMEH='STK') then    RETURN CnvFI(aStk);

  // 15.10.2013 AH ALLE RND:
  if (aZielMEH='KG') then     RETURN Rnd(aGewicht, Set.Stellen.Gewicht);
  if (aZielMEH='T') then      RETURN Rnd(aGewicht / 1000.0, Set.Stellen.Menge);
  if (aZielMEH='MM') and (aMEH='M') then   RETURN Rnd(aMenge * 1000.0, Set.Stellen.Menge);
  if (aZielMEH='M') and (aMEH='MM') then   RETURN Rnd(aMenge / 1000.0, Set.Stellen.Menge);
  if (aZielMEH='MM') then       RETURN Rnd(vlfdM * 1000.0, Set.Stellen.Menge);
  if (aZielMEH='M') then        RETURN Rnd(vlfdM, Set.Stellen.Menge);
  if (aZielMEH='QM') then       RETURN Rnd(vQM, Set.Stellen.Menge);
  if (aZielMEH='CBM') then      RETURN Rnd(vCBM, Set.Stellen.Menge);

  // ST 2023-08-21 Meldung ausgebaut, der Fehler auch in Zugriffslisten auftauchen kann
  //TODO('MEH Wandlung dieser Vorgaben : '+aMEH+' nach '+aZielMEH);
  RETURN 0.0;
end;



//========================================================================
//  WandleMEH
//            Wandelt die Mengen in eine Ziel-MEH um
//========================================================================
sub WandleMEH2(
  aDatei      : int;
  aStk        : int;
  aGewicht    : float;
  aMenge      : float;
  aMEH        : alpha;
  aMenge2     : float;
  aMEH2       : alpha;
  aZielMEH    : alpha
  ) : float;
begin
  aMEH  # StrCnv(aMEH,_StrUpper);
  aMEH2 # StrCnv(aMEH2,_StrUpper);
  aZielMEH # StrCnv(aZielMEH,_StrUpper);

  if (aZielMEH='KG') and (aGewicht<>0.0) then
    RETURN Rnd(aGewicht, Set.Stellen.Gewicht);

  if (aZielMEH='T') and (aGewicht<>0.0) then
    RETURN Rnd(aGewicht / 1000.0, Set.Stellen.Menge);

  if (aZielMEH=aMEH) and (aMenge<>0.0) then begin
    RETURN aMenge;
  end;
  if (aZielMEH=aMEH2) and (aMenge2<>0.0) then begin
    RETURN aMenge2;
  end;

  RETURN WandleMEH(aDatei, aStk, aGewicht, aMenge, aMEH, aZielMEH);
end;


//========================================================================
//  PreisProT
//
//========================================================================
sub PreisProT(
  aPreis    : float;
  aPEH      : int;
  aMEH      : alpha;
  aStk      : int;
  aGewicht  : float;
  aMenge    : float;
  aMEH2     : alpha;
  aD        : float;
  aB        : float;
  aL        : float;
  opt aGuete  : alpha;
  opt aArt    : alpha;
  ) : float;

local begin
  vBasis    : float;
  vPreis    : float;
end;
begin

  // 2022-11-16 AH
  if (aMenge=0.0) then aMEH2 # '';

  // 09.01.2015
  if (aPEH=0) then aPEH # 1;
  if (aMEH2=aMEH) then begin
    vBasis # Rnd(aPreis * aMenge / cnvfi(aPEH),2);  // Gesamtwert
    DivOrNull(vPreis, vBasis, (aGewicht / 1000.0), 2);
//debugx(anum(aMenge,0)+aMEH2+' * '+anum(aPreis,2)+' = '+anum(vBasis,2)+'/t');
    RETURN vPreis;
  end;

  aPreis # aPreis / cnvfi(aPEH);

  // keine Länge angegeben -> theor.errechnen
  if (aL=0.0) then begin
    aL # Lib_Berechnungen:L_aus_KgStkDBDichte2(aGewicht, aStk, aD, aB, Wgr_Data:GetDichte(Wgr.Nummer, 0, aGuete, aArt), "Wgr.TränenKgProQM");
  end;

  case aMEH of

    'kg'  :   vPreis # aPreis * 1000.0;


    't'   :   vPreis # aPreis;


    'Stk' : begin
      if (aStk<>0) then begin
        vBasis # aGewicht / Cnvfi(aStk);
        if (vBasis*aPreis<>0.0) then
          vPreis # 1000.0 / vBasis * aPreis;
      end;
    end;


    'qm' : begin
      vBasis # aB * aL / 1000000.0 * cnvfi(aStk);
      if (aGewicht*aPreis<>0.0) then
        vPreis # vBasis / aGewicht * 1000.0 * aPreis;
    end;


    'm' : begin
//      vBasis # aL / 1000.0 * cnvfi(aStk);
//      vPreis # vBasis / aGewicht * aPreis * 1000.0;
      if (aStk<>0) then begin
        vBasis  # aGewicht / cnvfi(aStk);
        if (vBasis<>0.0) then
          vPreis  # (aL * aPreis) / vBasis;// / 1000.0;
      end;
    end;


    'mm' : begin
      vBasis # aL * cnvfi(aStk);
      if (aGewicht*aPreis<>0.0) then
        vPreis # vBasis / aGewicht * aPreis;
    end;

  end;  // case

  RETURN rnd(vPreis,2);
end;


//========================================================================

//========================================================================
//  Konvertierung von Längeneinheiten, unterstützt:
//  km, m, dm, cm, mm, inch, point, twips, logische Einheiten
//========================================================================
sub LaengenKonv(
  aEingabe : alpha;
  aAusgabe : alpha;
  aWert    : float;
) : float;
begin

  aEingabe # StrCnv(aEingabe,_StrLower);
  aAusgabe # StrCnv(aAusgabe,_StrLower);

  if (aEingabe=aAusgabe) then RETURN(aWert);

  // Umrechnung (falls metrische Einheit) in mm

  if (aEingabe = 'km') then begin
    if (aAusgabe = 'km') then return(aWert);
    aEingabe # 'm'
    aWert    # aWert * 1000.00;
  end;

  if (aEingabe = 'm') then begin
    if (aAusgabe = 'm') then return(aWert);
    aEingabe # 'dm'
    aWert    # aWert * 10.00;
  end;

  if (aEingabe = 'dm') then begin
    if (aAusgabe = 'dm') then return(aWert);
    aEingabe # 'cm'
    aWert    # aWert * 10.00;
  end;

  if (aEingabe = 'cm') then begin
    if (aAusgabe = 'cm') then return(aWert);
    aEingabe # 'mm'
    aWert    # aWert * 10.00;
  end;

  CASE aEingabe OF
    'mm'   :
      begin
        CASE aAusgabe OF
          'mm'         : return(aWert);
          'inch'       : return(aWert * (1.00/254.00));
          'pp','point' : return(aWert * (75.00/254.00));
          'twips'      : return(aWert * (1440.00/254.00));

          'le','logische einheit' : return(aWert * (1440.00/254.00) * 100.00 * 10.00);
        END;
      end;
    'inch' :
      begin
        CASE aAusgabe OF
          'mm'         : return(aWert * 254.00);
          'inch'       : return(aWert);
          'pp','point' : return(aWert * 72.00);
          'twips'      : return(aWert * 1440.00);

          'le','logische einheit' : return(aWert * 1440.00 * 100.00);
        END;
      end;

   'pp','point' :
      begin
        CASE aAusgabe OF
          'mm'         : return(aWert * (254.00/72.00));
          'inch'       : return(aWert * (1.00/72.00));
          'pp','point' : return(aWert);
          'twips'      : return(aWert * (1440.00/72.00));

          'le','logische einheit' : return(aWert * (1440.00/72.00) * 100.00);
        END;
      end;

    'twips'  :
      begin
        CASE aAusgabe OF
          'mm'         : return(aWert * (254.00/1440.00));
          'inch'       : return(aWert * (1.00/1440.00));
          'pp','point' : return(aWert * (72.00/1440.00));
          'twips'      : return(aWert);

          'le','logische einheit' : return(aWert * 100.00);
        END;
      end;

     OTHERWISE
      begin

      end;
  END

end;


//========================================================================
//  TranslateMEH
//
//========================================================================
sub TranslateMEH(aMEH : alpha; aLang : int) : alpha;
begin

  case StrCnv(aMEH,_StrUpper) of
//    'qm'  :
    'STK' : RETURN 'pcs.'
  end
  RETURN aMEH;

end;


//========================================================================
//  TransferMengen
//    übergibt Mengenfelder von einer Datei an eine andere mit ggf. Uumrechnungen
//========================================================================
SUB TransferMengen(
  aCode   : alpha) : logic;   // z.B. 200>441VLDAW
local begin
  Erx : int;
end;
begin

//debugx(aCode);

  case aCode of

    '200>404,VSB' : begin                               // VSB-Karte in Auftragskation melden
      "Auf.A.Stückzahl"   # Mat.Bestand.Stk;

//  01.08.2016  AH  Rechnungsmenge richtig laut Verwiegungsart setzen...
      begin
//      Auf.A.Gewicht       # Mat.Bestand.Gew;
      Auf.A.Gewicht       # Mat.Gewicht.Brutto;
      if (Auf.A.Gewicht=0.0) then
        Auf.A.Gewicht       # Mat.Bestand.Gew;

      Auf.A.Nettogewicht  # Mat.Gewicht.Netto;
      if (Auf.A.Nettogewicht=0.0) then
        Auf.A.Nettogewicht  # Auf.A.Gewicht;

      // Umrechnen in Berechnungseinheit
      if (Auf.A.MEH.Preis='kg') or (Auf.A.MEH.Preis='t') then begin
        if (Auf.P.Verwiegungsart<>VWa.nummer) then begin
          Erx # Reklink(818,401,9,_RecFirst);
          if (Erx>_rLockeD) then VwA.NettoYN # y;
        end;
        if (VwA.NettoYN) then Auf.A.Menge.Preis # Auf.A.Nettogewicht
        else Auf.A.Menge.Preis # Auf.A.Gewicht;
        if (Auf.A.MEH.Preis='t') then
          Auf.A.Menge.Preis # Rnd(Auf.A.Menge.Preis / 1000.0, Set.Stellen.Menge);
      end
      else
        Auf.A.Menge.Preis   # WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Menge, Mat.MEH, Auf.A.MEH.Preis);


      // Umrechnen in Auftragseinheit...
      if (Auf.A.MEH='kg') or (Auf.A.MEH='t') then begin
        if (Auf.P.Verwiegungsart<>VWa.nummer) then begin
          Erx # Reklink(818,401,9,_RecFirst);
          if (Erx>_rLockeD) then VwA.NettoYN # y;
        end;
        if (VwA.NettoYN) then Auf.A.Menge # Auf.A.Nettogewicht
        else Auf.A.Menge # Auf.A.Gewicht;
        if (Auf.A.MEH='t') then
          Auf.A.Menge # Rnd(Auf.A.Menge / 1000.0, Set.Stellen.Menge);
      end
      else
        Auf.A.Menge         # WandleMEH(200, "Mat.Bestand.Stk", "Mat.Bestand.Gew", "Mat.Bestand.Menge", Mat.MEH, Auf.A.MEH);
      end;
    end;


    '200>404,DFAKT' : begin
      // bereits vorher gesetzt:
      // "Auf.A.Stückzahl"     # aStk;
      // Auf.A.Gewicht         # aGewBrutto;
      // Auf.A.Nettogewicht    # aGewNetto;
      // Auf.A.Menge.Preis     # aMenge;
      if (Auf.A.MEH='Stk') then
        Auf.A.Menge # cnvfi("Auf.A.Stückzahl");
      else if (Auf.A.MEH='kg') then begin
        // 10.12.2015 AH: Verwiegungsart beachten
        if (VWa.NettoYN) then Auf.A.Menge # Auf.A.Nettogewicht
        else Auf.A.Menge # Auf.A.Gewicht;
      end
      else if (Auf.A.MEH='t') then begin
        // 10.12.2015 AH: Verwiegungsart beachten
        if (VWa.NettoYN) then  Auf.A.Menge # Rnd(Auf.A.Nettogewicht / 1000.0, Set.Stellen.Menge)
        else Auf.A.Menge # Rnd(Auf.A.Gewicht / 1000.0, Set.Stellen.Menge);
      end
      else if (Auf.A.MEH=Auf.A.MEH.Preis) then
        Auf.A.Menge         # Auf.A.Menge.Preis
      else if (Auf.A.MEH=Mat.MEH) then begin
        // Dreisatz über Mat.MEH...
        Auf.A.Menge # Rnd(Lib_Berechnungen:Dreisatz(cnvfi("Auf.A.Stückzahl"), cnvfi(Mat.Bestand.Stk), Mat.Bestand.Menge), Set.Stellen.Menge);
      end
      else begin
        // Errechnen über Formel...
        Auf.A.Menge         # WandleMEH(200, "Mat.Bestand.Stk", "Mat.Bestand.Gew", Auf.A.Menge.Preis, Auf.A.MEH.Preis, Auf.A.MEH);
        if (Auf.A.Menge=0.0) then RETURN false;
      end;
    end;


    // regulärer Ausdruck für Suche: Lfs\.P\.MEH\.Einsatz.*\#.*\'kg\'
    '200>441,VLDAW' : begin                             // Material in VLDAW
      "Lfs.P.Stück"         # Mat.Bestand.Stk;
      Lfs.P.Gewicht.Brutto  # Mat.Gewicht.Brutto;
      Lfs.P.Gewicht.Netto   # Mat.Gewicht.Netto;
      Lfs.P.Menge.Einsatz   # WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Netto, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH.Einsatz);
      if (Lfs.P.MEH='kg') or (Lfs.P.MEH='t') then begin
        // AI 02.12.2011: war ...WandleMEH(404,...
        if (VWa.NettoYN) then
          Lfs.P.Menge         # WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Netto, 0.0, '', Lfs.P.MEH)
        else
          Lfs.P.Menge         # WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, 0.0, '', Lfs.P.MEH);
      end
      else begin
        // 15.10.2013 AH
        if (Mat.MEH<>'') and (Mat.MEH<>'kg') then
          Lfs.P.Menge           # WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Mat.Bestand.Menge, Mat.MEH, Lfs.P.MEH)
        else
          Lfs.P.Menge           # WandleMEH(200, "Lfs.P.Stück", Lfs.P.Gewicht.Brutto, Lfs.P.Menge.Einsatz, Lfs.P.MEH.Einsatz, Lfs.P.MEH);
      end;
      if ("Lfs.P.Stück"<0) then           "Lfs.P.Stück" # 0;
      if (Lfs.P.Gewicht.Netto<0.0) then   Lfs.P.Gewicht.Netto # 0.0;
      if (Lfs.P.Gewicht.Brutto<0.0) then  Lfs.P.Gewicht.Brutto # 0.0;
      if (Lfs.P.Menge<0.0) then           Lfs.P.Menge # 0.0;
      if (Lfs.P.Menge.Einsatz<0.0) then   Lfs.P.Menge.Einsatz # 0.0;
    end;

    otherwise RETURN false;
  end;


  RETURN true;
end;


//========================================================================