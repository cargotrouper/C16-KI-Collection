@A+
//==== Business-Control ==================================================
//
//  Prozedur    App_Betrieb
//                  OHNE E_R_G
//  Info
//
//
//  20.07.2007  ST  Erstellung de Prozedur
//  23.07.2009  TM  Projekt 1133/128 Umlagerung über Button, Zeile 358ff.
//  28.07.2010  MS  Lib_GuiCom:GetAlternativeName fuer MdiÚs gesetzt
//  19.08.2010  ST  Ankerfunktion für Nettoverwiegung hinzugefügt
//  13.12.2010  AI  LFS-Erfassung nun mit Kopfdaten
//  01.03.2012  ST  Lieferscheinerfassung per VLDAW hinzugefügt
//  01.03.2012  ST  Bundverpackung hinzugefügt
//  21.01.2013  AI  AusLFSMaske verbucht nichts mehr (alles schon in der LFS_Maske)
//  15.03.2013  ST  Bei BAG + POS Eingaben auch "-" als Eingabetrennung anstatt "/" ermöglicht
//  28.05.2013  ST  Zeiterfassung hinzugefügt
//  09.02.2015  AH  neue Menüs: Sperre + TheorieFM
//  15.03.2016  ST  Neue Prüfung für Eingabe bei BAG FM
//  29.03.2016  ST  AFX für Betriebsauftragszeiten hinzugefügt
//  01.07.2016  AH  "TransCheck"
//  28.02.2019  ST  AFX "Betrieb.AusLfsMaske" hinzugefügt
//  21.10.2019  AH  Wareneingang kann auch nur auf Bestellkopfnr. passieren
//  26.10.2021  ST  AFX "Betrieb.BagVWStorno" hinzugefügt
//  04.04.2022  AH  ERX
//  2022-09-28  AH  Artikelverwaltung
//
//  Subprozeduren
//    SIB TransCheck();
//    SUB Auswahl(aBereich : alpha)
//    SUB AusLFSPositionen();
//    SUB AusLFSMaske();
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic;
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic
//    SUB RightCheck()
//    SUB Etikettendruck()
//    SUB BagZVerwaltung()
//    SUB _BaHatNur1Position() : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Bag

declare BagZVerwaltung()
declare _BaHatNur1Position() : logic


//========================================================================
// transCheck();
//========================================================================
sub Transcheck(aQuit : logic);
begin

//  if (TransActive) then begin
//    WHILE (TransActive) do
  if (TransCount>0) then begin
    WHILE (TransCount>0) do
      TRANSOFF;
    Msg(001104,'',0,0,0);

    if (aQuit) then begin
      gMDI->Winclose();
      $Appframe.Betrieb->Winclose();
    end;
    gMDI->Winclose();
  end;
end;


//========================================================================
//  WEaufBestellpos
//========================================================================
sub WEaufBestellpos();
begin
  RekLink(819,501,1,_RecFirst);     // Warengruppe holen
  if (Wgr_Data:IstMat() or Wgr_Data:IstMix()) then begin
//        if (Ein.P.Wgr.Dateinr=c_Wgr_Material) or (Ein.P.Wgr.Dateinr=c_Wgr_artMatMix) then begin
    RecBufClear(506);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Mat.Verwaltung','',y);
    Lib_GuiCom:RunChildWindow(gMDI);
  end
  else begin
    RecBufClear(506);
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.E.Verwaltung','',y);
    Lib_GuiCom:RunChildWindow(gMDI);
  end;
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
  vA,vB   : alpha;
  vHdl    : int;
  vGroup  : alpha;
  vOK     : logic;
  vBA     : int;
  vPos    : int;
  vMat    : int;
  vGew    : float;
  vQ      : alpha(4000);
end;

begin
  case aBereich of

    'Etikettendruck' : begin
      if ( !Rechte[Rgt_Betrieb_EtkDruck] ) then
        RETURN;

      // Materialauswahl
      RecBufClear(200);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':Etikettendruck');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Waage.Netto' : begin
      if !(Rechte[Rgt_Betrieb_Waage_Netto]) then
        RETURN;

      // Ankerfunktion fuer Waage einbinden
      if (RunAFX('BAG.Waage.Coilverwiegung','')<=0) then RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup='BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin
        Dlg_Standard:Standard(translate('Materialnummer'),var vA);
      end;

      if (vA='') then RETURN;


      Mat.Nummer # cnvia(vA);
      Erx # RecRead(200,1,0);   // Material holen
      if (Erx>_rLocked) then begin
        Msg(020001,vA,0,0,0);
        RETURN;
      end;

      RecBufClear(701);
      if ("Mat.Löschmarker"='*') then begin
        Erx # RecLink(701,200,29,_RecFirst);    // BA-Input holen
        if (Erx>_rLocked) then begin
          Msg(99,'Diese Karte ist bereits gelöscht!',_WinIcoError,_WinDialogOk,0);
          RETURN;
        end;
        if (BAG.IO.Ist.Out.Menge<>0.0) then begin
          TRANSBRK;
          Msg(99,'Diese Karte wurde bereits fertiggemeldet!',_WinIcoError,_WinDialogOk,0);
          RETURN;
        end;

        Mat.Nummer # BAG.IO.MaterialrstNr;
        RecRead(200,1,0);
      end;


      Erx # RecLink(818,200,10,_recFirsT);  // Verwiegungsart holen
      if (Erx>_rLocked) or (VWA.NettoYN) then begin
        Msg(020002,vA,0,0,0);
        RETURN;
      end;


      if (Dlg_Standard:Menge(Translate('Gewicht netto'), var vGew, Mat.Gewicht.Netto)=falsE) then
        RETURN;

      TRANSON;

      // Karte ändern
      RecRead(200,1,_recLock);
      Mat.Gewicht.Netto # vGew;
      Rekreplace(200,_RecUnlock,'AUTO');

      // ggf. BA-Input anpassen...
      if (BAG.IO.Nummer<>0) then begin
        RecRead(701,1,_RecLock);
        if (BAG.IO.Ist.In.GewN=BAG.IO.Plan.In.GewN) then begin
          BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
        end;
        if (BAG.IO.Ist.In.GewN=BAG.IO.Plan.Out.GewN) then begin
          BAG.IO.Plan.Out.GewN   # Mat.Gewicht.Netto;
        end;
        BAG.IO.Ist.In.GewN   # Mat.Gewicht.Netto;
        RekReplace(701,_RecUnlock,'AUTO');
      end;

      TRANSOFF;

      Msg(999998,'',0,0,0);
    end;


    'Lageruebersicht': begin
      if !(Rechte[Rgt_Betrieb_Material]) then
        RETURN;

      if (gMdiMat = 0) then begin
        gFrmMain->wpDisabled # true;
        gMdiMat # Lib_GuiCom:OpenMdi(gFrmMain, 'Mat.Verwaltung', _WinAddHidden);
        gMdiMat->WinUpdate(_WinUpdOn);
        gFrmMain->wpDisabled # false;
//          "GV.Fil.Mat.gelöscht" # y;
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_guiCom:ReOpenMDI(gMDIMat);
      end;
    end;


    'Artikel': begin
      if !(Rechte[Rgt_Betrieb_Artikel]) then
        RETURN;

      if (gMdiArt = 0) then begin
        gFrmMain->wpDisabled # true;
        gMdiArt # Lib_GuiCom:OpenMdi(gFrmMain, 'Art.Verwaltung', _WinAddHidden);
        gMdiArt->WinUpdate(_WinUpdOn);
        gFrmMain->wpDisabled # false;
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_guiCom:ReOpenMDI(gMDIArt);
      end;
    end;


    'Bag': begin
      if !(Rechte[Rgt_BAG]) then
        RETURN;

      if (gMdiBAG = 0) then begin
        gFrmMain->wpDisabled # true;
        gMdiBAG # Lib_GuiCom:OpenMdi(gFrmMain, 'BA1.Verwaltung', _WinAddHidden);
        gMdiBAG->WinUpdate(_WinUpdOn);
        gFrmMain->wpDisabled # false;
        $NB.Main->WinFocusSet(true);
      end
      else begin
        Lib_guiCom:ReOpenMDI(gMDIBAG);
      end;
    end;

    
    'BagAbschluss' : begin
      if !(Rechte[Rgt_Betrieb_Abschliessen]) then
        RETURN;

      // Ankerfunktion  einbinden
      if (RunAFX('BAG.Abschluss','')<0) then RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup='BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin
        Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA);
      end;

      if (vA='') then RETURN;
      vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

      RecBufClear(702);
      RecBufClear(707);

      vB # Str_Token(vA,'/',1);
      BAG.Nummer # cnvia(vB);
      Erx # RecRead(700,1,0);     // BA holen
      if (Erx<>_rOK) then begin
        Msg(700002,cnvai(cnvia(vB)),0,0,0);
        RETURN;
      end;
      vB # Str_Token(vA,'/',2);
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vB);
      if (BAG.P.Nummer<>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
          RETURN;
        end;
      end;

      BA1_Fertigmelden:AbschlussPos(BAG.P.nummer, BAG.P.Position, today, now)
      ErrorOutput;
    end;  // BA-Asbschluss


    'BagTheoFertigmeldung': begin
      if !(Rechte[Rgt_Betrieb_Fertigmelden]) then
        RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup = 'BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin

        Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA);
      end;

      if (vA='') then RETURN;
      vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

      RecBufClear(702);
      RecBufClear(707);

      vB # Str_Token(vA,'/',1);
      BAG.Nummer # cnvia(vB);
      Erx # RecRead(700,1,0);     // BA holen
      if (Erx<>_rOK) then begin
        Msg(700002,cnvai(cnvia(vB)),0,0,0);
        RETURN;
      end;
      vB # Str_Token(vA,'/',2);
      if (vB='') then vB # '1';
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vB);
      if (BAG.P.Nummer<>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
          RETURN;
        end;
      end;

      RecBufClear(707);
      BAG.FM.Nummer   # BAG.Nummer;
      BAG.FM.Position # BAG.P.Position;
      BA1_Fertigmelden:FMTheorie(BAG.FM.Nummer, BAG.FM.Position);
      ErrorOutput;    // Entstandene Fehler am Ende ausgeben
    end;


    'BagFertigmeldung': begin

      if !(Rechte[Rgt_Betrieb_Fertigmelden]) then
        RETURN;

      // Ankerfunktion  einbinden
      if (RunAFX('BAG.Fertigmelden','')<0) then RETURN;


      UserInfo(_UserCurrent);
      if (gUsergroup = 'BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin

        Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA);
      end;

      if (vA='') then RETURN;
      vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

      RecBufClear(702);
      RecBufClear(707);

      vB # Str_Token(vA,'/',1);
      BAG.Nummer # cnvia(vB);
      Erx # RecRead(700,1,0);     // BA holen
      if (Erx<>_rOK) then begin
        Msg(700002,cnvai(cnvia(vB)),0,0,0);
        RETURN;
      end;
      vB # Str_Token(vA,'/',2);
      if (vB='') then begin
        // vB # '1'; // Alte Version

        // ST 2016-03-15 Projekt 1609/2 Arens
        // Neue Version: Prüfen ob der Betriebsauftrag nur eine Position hat, dann ok, ansonsten nicht io
        if (_BaHatNur1Position()) then
          vB # '1';
        else begin
          Msg(700014,cnvai(cnvia(vA)),0,0,0);
          RETURN;

        end;

      end;
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vB);
      if (BAG.P.Nummer<>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
          RETURN;
        end;
      end;
      BAG.FM.Nummer   # BAG.Nummer;
      BAG.FM.Position # BAG.P.Position;
      BA1_Fertigmelden:FMKopf();
      ErrorOutput;
    end;


    'BagVWSperre': begin
      if !(Rechte[Rgt_Betrieb_VW_Storno]) then
        RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup='BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin
        Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA);
      end;

      if (vA='') then RETURN;
      vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

      RecBufClear(702);
      RecBufClear(707);

      vB # Str_Token(vA,'/',1);
      BAG.Nummer # cnvia(vB);
      Erx # RecRead(700,1,0);     // BA holen
      if (Erx<>_rOK) then begin
        Msg(700002,cnvai(cnvia(vB)),0,0,0);
        RETURN;
      end;
      vB # Str_Token(vA,'/',2);
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vB);
      if (BAG.P.Nummer<>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
          RETURN;
        end;
      end;

      vA # '';
      if (Dlg_Standard:Standard_Small(Translate('Materialnummer'),var vA)=false) then RETURN;
      vMat # cnvia(vA);

      vOk # n;
      Erx # RecLink(707,702,5,_recFirst);   // Verwiegungen loopen
      WHILE (Erx<=_rLocked) and (vOK=false) do begin
        if (BAG.FM.Materialnr=vMat) then begin
          VOK # y;
          BREAK;
        end;
        Erx # RecLink(707,702,5,_recNext);
      END;
      if (vOK=false) then begin
         Msg(99,'Diese Materialnr. wurde nicht auf diesem BA verwogen!',_WinIcoError,_WinDialogOk,0);
         RETURN;
       end;

      if (BAG.FM.Status<>1) then begin
         Msg(99,'Diese Verwiegung wurde bereits storniert!',_WinIcoError,_WinDialogOk,0);
         RETURN;
      end;

      Erx # RecLink(701,707,5,_recFirst);   // BAG-Output holen
      if (Erx<=_rOK) then begin
        if (Msg(707014,'',_WinIcoQuestion,_WinDialogYesNo,2)=_winidno) then RETURN;
        if (BA1_FM_Data:SetSperre()<>true) then begin
          ErrorOutput;
          RETURN;
        end;
        ErrorOutput;
        Msg(999998,'',0,0,0);
      end;

    end;


    'BagVWStorno': begin
      if !(Rechte[Rgt_Betrieb_VW_Storno]) then
        RETURN;

      // Ankerfunktion fuer Waage einbinden
      if (RunAFX('Betrieb.BagVWStorno','')<0) then RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup='BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin
        Dlg_Standard:Standard(translate('Betriebsauftrag'),var vA);
      end;

      if (vA='') then RETURN;
      vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

      RecBufClear(702);
      RecBufClear(707);

      vB # Str_Token(vA,'/',1);
      BAG.Nummer # cnvia(vB);
      Erx # RecRead(700,1,0);     // BA holen
      if (Erx<>_rOK) then begin
        Msg(700002,cnvai(cnvia(vB)),0,0,0);
        RETURN;
      end;
      vB # Str_Token(vA,'/',2);
      BAG.P.Nummer    # BAG.Nummer;
      BAG.P.Position  # cnvia(vB);
      if (BAG.P.Nummer<>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
          RETURN;
        end;
      end;

      vA # '';
      if (Dlg_Standard:Standard_Small(Translate('Materialnummer'),var vA)=false) then RETURN;
      vMat # cnvia(vA);

      vOk # n;
      Erx # RecLink(707,702,5,_recFirst);   // Verwiegungen loopen
      WHILE (Erx<=_rLocked) and (vOK=false) do begin
        if (BAG.FM.Materialnr=vMat) then begin
          VOK # y;
          BREAK;
        end;
        Erx # RecLink(707,702,5,_recNext);
      END;
      if (vOK=false) then begin
         Msg(99,'Diese Materialnr. wurde nicht auf diesem BA verwogen!',_WinIcoError,_WinDialogOk,0);
         RETURN;
       end;

      if (BAG.FM.Status<>1) then begin
         Msg(99,'Diese Verwiegung wurde bereits storniert!',_WinIcoError,_WinDialogOk,0);
         RETURN;
      end;

      if (BA1_FM_Data:Entfernen()=false) then begin
        Error(707004,'');
        ErrorOutput;
        RETURN;
      end;

      Msg(999998,'',0,0,0);
    end;


    'Wareneingang'  : begin
      if !(Rechte[Rgt_Betrieb_Wareneing]) then
        RETURN;

      // Ankerfunktion fuer Waage einbinden
      if (RunAFX('Betrieb.Wareneingang','')<0) then RETURN;

      UserInfo(_UserCurrent);
      if (gUsergroup = 'BETRIEB_TS') then begin
        // Tastatur...
        vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
        if (vHdl != 0) then begin
          vHdl->WinDialogRun(_WinDialogCenter);
          vHdl->WinClose();
        end;
        vA # g_sSelected;
        g_sSelected # '';
      end
      else begin
        Dlg_Standard:Standard(translate('Bestellung'),var vA);
      end;

      if (vA='') then RETURN;
      vA # StrCnv(vA,_strUpper);

      // SAMMELWARENEINGANG ???
      if (StrFind(vA,'SWE',1)>0) then begin
        vB # Str_Token(vA,'/',1);
        SWE.P.Nummer      # cnvia(vB);
        vB # Str_Token(vA,'/',2);
        SWE.P.Position    # cnvia(vB);
        SWe.P.Eingangsnr  # 1;
        Erx # RecRead(621,1,0);             // SWE-Position holen
        if (Erx<>_rOK) then begin
          Msg(504107,vA,0,0,0);
          RETURN;
        end;
        Erx # RecLink(620,621,1,_recFirst); // Kopf holen
        if (Erx<>_rOK) then begin
          Msg(504107,vA,0,0,0);
          RETURN;
        end;

        RecBufClear(621);         // ZIELBUFFER LEEREN
        gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'SWe.P.Verwaltung','',Y);
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        //Mode # c_modeNew + c_modebald;
        Lib_GuiCom:RunChildWindow(gMDI);

      end // SWE
      else begin

        if (Lib_Strings:Strings_Count(vA,'/')=0) then begin
          if (Lib_Berechnungen:Int1AusAlpha(vA,var Ein.Nummer)=false) then RETURN;
          Erx # RecRead(500,1,0);   // Kopf holen
          if (Erx<>_rOK) then begin
            Msg(504107,vA,0,0,0);
            RETURN;
          end;
          if (RecLinkInfo(501,500,9,_RecCount)=1) then begin
            Erx # RecLink(501,500,9,_RecCount);   // die EINE Positon holen
          end
          else begin
            gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ein.P.Verwaltung',here+':AusBestellpos');
            VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
            vQ # '';
            Lib_Sel:QInt(var vQ, 'Ein.P.Nummer', '=', Ein.Nummer);
            Lib_Sel:QRecList(0, vQ);
            Lib_GuiCom:RunChildWindow(gMDI);
            RETURN;
          end;
        end
        else begin
          // NORMALE BESTELLUNG...
          if (Lib_Berechnungen:Int2AusAlpha(vA,var Ein.P.Nummer, var Ein.P.Position)=false) then RETURN;
          Erx # RecRead(501,1,0);         // BestellugsPosition holen
          if (Erx<>_rOK) then begin
            Msg(504107,vA,0,0,0);
            RETURN;
          end;
          Erx # RecLink(500,501,3,_recFirst); // Kopf holen
          if (Erx<>_rOK) then begin
            Msg(504107,vA,0,0,0);
            RETURN;
          end;
        end

        WEaufBestellpos();

      end;

    end;


    'WE.Mat'  : begin
      if !(Rechte[Rgt_Betrieb_Wareneing]) then
        RETURN;

      RecBufClear(200);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dlg.Wareneingang.Mat','');
      // gleich in Neuanlage....
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Mode # c_ModeNew;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferschein': begin
      if !(Rechte[Rgt_Betrieb_Liefersch]) then
        RETURN;

      RecBufClear(440);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.Verwaltung','', true);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LFS.Erfassung': begin
      if !(Rechte[Rgt_Betrieb_LFS_Erfassung]) then
        RETURN;

      // LFS-Kopf vorbelegen...
      RecBufClear(440);
      Lfs.Nummer          # myTmpNummer;
      Lfs.Anlage.Datum    # today;
      Lfs.Kosten.PEH      # 1000;
      Lfs.Kosten.MEH      # 'kg';
      Lfs.Lieferdatum     # today;
      vPos                # 1;

      RecBufClear(441);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.P.BM.Verwaltung',Here+':AusLFSPositionen',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LFS.ErfassungVLDAW' : begin
      if !(Rechte[Rgt_Betrieb_LFS_ErfassungVLDAW]) then
        RETURN;

      // LFS-Kopf vorbelegen...
      RecBufClear(440);
      RecBufClear(441);

      Lfs_P_BM_Main:LfsBetriebVLDAW();
    end;


    'Umlagern': begin
      if !(Rechte[Rgt_Betrieb_Umlagern]) then
        RETURN;

      Msg(844012 ,'',_WinIcoInformation,_WinDialogOk,1);
      if (Mat_Subs:UmlagernScanner()) then
        // alles IO
        Msg(844013 ,'',_WinIcoInformation,_WinDialogOk,1);
      else
        // Fehler
        Msg(844014 ,'',_WinIcoInformation,_WinDialogOk,1);
    end;


    'Pak.Material' :  begin

      if !(Rechte[Rgt_Betrieb_Pak_Material]) then
        RETURN;

      Pak_Main:BMVerpacken();
    end;



    'Beenden': begin
      vGroup # gUsergroup;
      if (vGroup='') then vGroup # gUsername;

      if (vGroup = 'MC9090') then begin
        //$Frame.MC9090->Winclose();
        gFrmMain->winClose();
        vA # lib_Strings:Strings_Win2Dos(SysGetEnv('SESSIONNAME'));
        if (StrFind(vA, 'RDP',1)>0) then
          SysExecute('shutdown.exe','-l',_ExecMinimized);
        App_Extras:HardLogout();
//        VarFree(Windowbonus);
//        WinHalt();
      end;

      Lib_GuiCom:RememberWindow(gMDI);

      if (vGroup= 'BETRIEB_TS') OR
         (vGroup = 'BETRIEB') then begin
        gMDI->Winclose();
        $Appframe.Betrieb->Winclose();
//        WinHalt();
      end;

      gMDI->Winclose();
      RETURN;
    end;


    'Tastaturtest': begin
      // Maske auf
      vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
      if (vHdl != 0) then begin
        vHdl->WinDialogRun(_WinDialogCenter);
        vHdl->WinClose();
        if (g_sSelected <> '') then
          todo('Rückgabe: ' + g_sSelected);

        g_sSelected # '';

      end;
    end;


    'TastaturtestNum': begin
      // Maske auf
      vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur.Num'),_WinOpenDialog);
      if (vHdl != 0) then begin
        vHdl->WinDialogRun(_WinDialogCenter);
        vHdl->WinClose();
        if (g_sSelected <> '') then
          todo('Rückgabe: ' + g_sSelected);

        g_sSelected # '';

      end;
    end;


    'BA_Einsatz_Raus' :  begin
      if (Dlg_Standard:Standard_Small(Translate('Einsatz-ID'),var vA)=true) then begin
        vOK # BA1_IO_Data:einsatzRaus(vA);
        if (vOK) then Msg(999998,'',0,0,0)
        else Msg(99,'Einsatz nicht entfernbar!',_WinIcoError,_WinDialogOk,0);
      end;
    end;


    'BA_Einsatz_Rein' :  begin
      if (Dlg_Standard:Standard_Small(Translate('Betriebsauftrag'),var vA)=true) then begin

        if (Lib_Strings:Strings_Count(vA,'/')<>1) then begin
          Msg(700002,vA,0,0,0);
          RETURN;
        end;
        vBA   # Cnvia(Str_Token(vA,'/',1));
        vPos  # Cnvia(Str_Token(vA,'/',2));

        BAG.P.Nummer    # vBA;
        BAG.P.Position  # vPos;
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (Erx<>_rOK) then begin
          Msg(700002,vA,0,0,0);
          RETURN;
        end;

        if (Dlg_Standard:Standard_Small(Translate('Materialnummer'),var vA)=true) then begin
          vOk # BA1_IO_Data:einsatzRein(vBA, vPos, cnvia(vA));
          if (vOK) then Msg(999998,'',0,0,0)
          else Msg(99,'Material nicht einfügbar!',_WinIcoError,_WinDialogOk,0);
        end;
      end;
    end;

  end;

end;


//========================================================================
//  AusBestellpos
//========================================================================
sub AusBestellpos();
begin
  if (gSelected=0) then RETURN;
  RecRead(501,0,_RecId,gSelected);
  gSelected # 0;

  WEaufBestellPos();
end;


//========================================================================
//  AusLFSPositionen
//
//========================================================================
sub AusLFSPositionen();
begin
  gSelected # 0;

  // keine Positionen?
  if (RecLinkInfo(441,440,4,_recCount)=0) then RETURN;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lfs.Maske',here+':AusLFSMaske');
  // gleich in Neuanlage....
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Mode # c_ModeNew;
//  w_Command # '->POS';
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN;

end;


//========================================================================
//  AusLFSMaske
//
//========================================================================
sub AusLFSMaske();
local begin
  Erx : int;
end;
begin
  if (gSelected=0) then RETURN;

  gSelected # 0;
/*** 21.01.2013 AI
  // keine Positionen?
  if (RecLinkInfo(441,440,4,_recCount)=0) then RETURN;

  REPEAT
    Erx # Msg(19999,'Lieferschein so speichern?',_WinIcoQuestion, _WinDialogYesNoCancel,3);
  UNTIL (Erx<>_WinIdCancel);

  if (Erx=_WinIdNo) then begin
    // Cleanup...
    WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do
      RekDelete(441,0,'MAN');
    RETURN;
  end;

  // LFS verbuchen...
  if (Lfs_Data:SaveLFS()=false) then begin
    ErrorOutput;
    RETURN;
  end;
***/
/*
  // Drucken + Verbuchen?
  if (Msg(440003,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIdYes) then begin
*/

  if (RunAFX('Betrieb.AusLfsMaske','')<>0) then RETURN;

  Lfs.Nummer # Lfs.P.Nummer;      // Position hat Lieferscheinnummer im Puffer
  Erx # RecRead(440,1,0);
  if (Erx = _rOK) then begin

    if (Lfs_Data:Druck_LFS()) then begin
      Lfs_Data:Verbuchen(Lfs.Nummer, today, now);
    end;

    ErrorOutput;
  end;
/*
  end;
*/
end;


//========================================================================
//  EvtFocusInit
//
//========================================================================
sub EvtFocusInit(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus zuvor hatte
) : logic;
begin
  aEvt:Obj->wpcolBkg # _WinColLightYellow
  aEvt:Obj->wpStyleButton # _WinStyleButtonTBar;
  return(true);
end;


//========================================================================
//  EvtFocusTerm
//
//========================================================================
sub EvtFocusTerm(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus bekommt
) : logic;
begin
  aEvt:Obj->wpcolBkg # _WinColParent;
  aEvt:Obj->wpStyleButton # _WinStyleButtonNormal;
  return(true);
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
  vA    : alpha;
  vB    : alpha;
  vOK   : logic;
  vBA   : int;
  vPos  : int;
end;
begin

  Crit_Prozedur:Manage();

  // 01.07.2016 AH:
  TransCheck((gUserGroup= 'BETRIEB_TS') OR (gUserGroup = 'BETRIEB'));

  case (aEvt:Obj->wpName) of
    'bt.Page1' : begin
      gSelected # 1;
      gFrmMain->winclose();
    end;
    'bt.Page2' : begin
      gSelected # 2;
      gFrmMain->winclose();
    end;
    'bt.Page3' : begin
      gSelected # 3;
      gFrmMain->winclose();
    end;
    'bt.Page4' : begin
      gSelected # 4;
      gFrmMain->winclose();
    end;

    'bt.Bag' :                Auswahl('Bag');
    'bt.Etikettendruck' :     Auswahl('Etikettendruck');
    'bt.Waage.Netto'    :     Auswahl('Waage.Netto');
    'bt.Lageruebersicht' :    Auswahl('Lageruebersicht');
    'bt.Artikel'         :    Auswahl('Artikel');
    'bt.BagFm' :              Auswahl('BagFertigmeldung');
    'bt.BagTheoFm' :          Auswahl('BagTheoFertigmeldung');
    'bt.BagVWStorno' :        Auswahl('BagVWStorno');
    'bt.BagVWSperre' :        Auswahl('BagVWSperre');
    'bt.BagAbschluss' :       Auswahl('BagAbschluss');
    'bt.Wareneingang' :       Auswahl('Wareneingang');
    'bt.WE.Mat'       :       Auswahl('WE.Mat');
    'bt.Lieferschein' :       Auswahl('Lieferschein');
    'bt.LFS.Erfassung':       Auswahl('LFS.Erfassung');
    'bt.LFS.ErfassungVLDAW':  Auswahl('LFS.ErfassungVLDAW');
    'bt.BagZeiten'    :       BagZVerwaltung();
    'bt.Umlagern' :           Auswahl('Umlagern');
    'bt.Ende' :               Auswahl('Beenden');

    'bt.Tastatur' :           Auswahl('Tastaturtest');
    'bt.TastaturNum' :        Auswahl('TastaturtestNum');

    'bt.Ressourcenplanung' :  App_Betrieb_RsoPlan:Start();

    'bt.Scanner_LFS' :                MC9090_Subs:LFS();
    'bt.Scanner_BA_BiS' :             MC9090_Subs:BA_BIS();
    'bt.Scanner_BA_Einsatz_Check' :   MC9090_Subs:BA_Input_Check();
    'bt.Scanner_BA_Abschluss' :       MC9090_Subs:BA_Abschluss();
    'bt.Scanner_BA_FM' :              MC9090_Subs:BA_FM();
    'bt.Scanner_Mat_Inventur' :       MC9090_Subs:Mat_Inventur();

    'bt.BA_Einsatz_Raus' : Auswahl( 'BA_Einsatz_Raus' );
    'bt.BA_Einsatz_Rein' : Auswahl( 'BA_Einsatz_Rein' );

    'bt.Pak.Material' : Auswahl( 'Pak.Material' );

    'bt.Scanner_Umlagern' : Begin
      // Materialnummer eingeben oder scannen

      If (Dlg_Standard:Standard_Small(Translate('Materialnummer'),var vA)=true) then begin
        Mat.Nummer # Cnvia(vA);
        Erx # RecRead(200,1,0);

        If (Erx <> _rOK) then Begin
          // Msg
          Msg(844016 ,vA,_WinIcoError,_WinDialogOk,1);
          RETURN(False);
        End
        else begin
          debug('OK MAT');
        End;

        // Neuen Lagerplatz eingeben oder scannen
        If (Dlg_Standard:Standard_Small(Translate('Lagerplatz'),var vA)=true) then Begin
          LPL.Lagerplatz # vA;
          Erx # RecRead(844,1,0);
          If (Erx <> _rOK) then Begin

            // Msg
            Msg(844017 ,vA,_WinIcoError,_WinDialogOk,1);
            RETURN(False);

          End
          else Begin

            Erx # RecRead(200,1,0);
             PtD_Main:Memorize(200);

            if (RecRead(200,1,0 | _RecLock) = _rOK) then begin
              // Lagerplatz ersetzen
              Mat.Lagerplatz # Lpl.Lagerplatz;
              RekReplace(200,_RecUnlock,'AUTO');

              If (Erx = _rOK) then begin
                Msg(844013 ,vA,_WinIcoInformation,_WinDialogOk,1);
              End
              else begin
                Msg(844016 ,vA,_WinIcoError,_WinDialogOk,1);
                RETURN(False);
              End;
            end;
          End;
        End;//
      End; //
    End; //

  end;  // ..case

end;


//========================================================================
// RightCheck()
//          Überprüft die Rechte
//========================================================================
sub RightCheck()
local begin
  vHdl : handle;
end
begin

  // Ressourcenplanung
  if !(Rechte[Rgt_Betrieb_Ressourcen]) then begin
    vHdl # gMDI->WinSearch('bt.Ressourcenplanung');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch('Mnu.BM.RsoPlan');
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // Waage-Netto
  if !(Rechte[Rgt_Betrieb_Waage_Netto]) then begin
    vHdl # gMDI->WinSearch('bt.Waage.Netto');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch('Mnu.BM.WaageNetto');
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // Etikettendruck
  if !(Rechte[Rgt_Betrieb_EtkDruck]) then begin
    vHdl # gMDI->WinSearch('bt.Etikettendruck');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Etikettendruck' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // Lagerübersicht
  if !(Rechte[Rgt_Betrieb_Material]) then begin
    vHdl # gMDI->WinSearch('bt.Lageruebersicht');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Lageruebersicht' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;
  if !(Rechte[Rgt_Betrieb_Artikel]) then begin
    vHdl # gMDI->WinSearch('bt.Artikel');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Artikel' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // BA Fertigmelden
  if !(Rechte[Rgt_Betrieb_Fertigmelden]) then begin
    vHdl # gMDI->WinSearch('bt.BagFm');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.BagFm' );
    if ( vHdl != 0 ) then  vHdl->wpDisabled # true;
  end;

  if !(Rechte[Rgt_Betrieb_BA_Edit]) then begin
    vHdl # gMenu->WinSearch( 'Mnu.BM.BA_Einsatz_Raus' );
    if ( vHdl != 0 ) then  vHdl->wpDisabled # true;
    vHdl # gMenu->WinSearch( 'Mnu.BM.BA_Einsatz_Rein' );
    if ( vHdl != 0 ) then  vHdl->wpDisabled # true;
  end;

  // BA VW Storno
  if !(Rechte[Rgt_Betrieb_VW_Storno]) then begin
    vHdl # gMDI->WinSearch('bt.BagVWStorno');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.BagVWStorno' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // BA Abschluss
  if !(Rechte[Rgt_Betrieb_Abschliessen]) then begin
    vHdl # gMDI->WinSearch('bt.BagAbschluss');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.BagAbschluss' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;


  // BA Zeitenverwaltung
  if !(Rechte[Rgt_Betrieb_Zeiten]) then begin
    vHdl # gMDI->WinSearch('bt.BagZeiten');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.BagZeiten' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;


  // Wareneingang
  if !(Rechte[Rgt_Betrieb_Wareneing]) then begin
    vHdl # gMDI->WinSearch('bt.Wareneingang');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Wareneingang' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // Wareneingang Material
  if !(Rechte[Rgt_Betrieb_Wareneing]) then begin
    vHdl # gMDI->WinSearch('bt.WE.Mat');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.WE.Mat' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;

  // Lieferschschein
  if !(Rechte[Rgt_Betrieb_Liefersch]) then begin
    vHdl # gMDI->WinSearch('bt.Lieferschein');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Lieferschein' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;
  if !(Rechte[Rgt_Betrieb_LFS_Erfassung]) then begin
    vHdl # gMDI->WinSearch('bt.LFS.Erfassung');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.LFS.Erfassung' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;
  if !(Rechte[Rgt_Betrieb_LFS_ErfassungVLDAW]) then begin
    vHdl # gMDI->WinSearch('bt.LFS.ErfassungVLDAW');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.LFS.ErfassungVLDAW' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;


  // Material Verpacken
  if !(Rechte[Rgt_Betrieb_Pak_Material]) then begin
    vHdl # gMDI->WinSearch('bt.Pak.Material');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Pak.Material' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;



  // Umlagern
  if !(Rechte[Rgt_Betrieb_Umlagern]) then begin
    vHdl # gMDI->WinSearch('bt.Umlagern');
    if (vHdl<>0) then Lib_GuiCom:Disable(vHdl);
    vHdl # gMenu->WinSearch( 'Mnu.BM.Umlagern' );
    if ( vHdl != 0 ) then vHdl->wpDisabled # true;
  end;
end;


//========================================================================
// Etikettendruck()
//          Lässt den Benutzer Etiketten drucken
//========================================================================
sub Etikettendruck()
begin

  if (gSelected<>0) then begin
    RecRead(200,0,_RecId,gSelected);
    gSelected # 0;
    Mat_Etikett:Etikett();      // Druck
  end;

end;


//========================================================================
// sub BagZVerwaltung()
//          Startet die Betriebsauftragzeitenverwaltung
//========================================================================
sub BagZVerwaltung()
local  begin
  Erx     : int;
  vHdl    : int;
  vA,vB   : alpha;
  vOK     : logic;
end
begin

  if !(Rechte[Rgt_Betrieb_Zeiten]) then
    RETURN;

  if (RunAFX('Betrieb.BetriebsauftragZeiten','')<0) then RETURN;

  UserInfo(_UserCurrent);

  if (gUsergroup='BETRIEB_TS') then begin
    // Tastatur...
    vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
    if (vHdl != 0) then begin
      vHdl->WinDialogRun(_WinDialogCenter);
      vHdl->WinClose();
    end;
    vA # g_sSelected;
    g_sSelected # '';
  end
  else begin
    Dlg_Standard:Standard(translate('Betriebsauftrag/Pos.'),var vA);
  end;

  if (vA='') then RETURN;
  vA # Str_ReplaceAll(vA,'-','/');  // ST  2013-03-15: Auch "-" als Eingabetrenner erlauben

  RecBufClear(702);
  RecBufClear(707);

  vB # Str_Token(vA,'/',1);
  BAG.Nummer # cnvia(vB);
  Erx # RecRead(700,1,0);     // BA holen
  if (Erx<>_rOK) then begin
    Msg(700002,cnvai(cnvia(vB)),0,0,0);
    RETURN;
  end;
  vB # Str_Token(vA,'/',2);
  BAG.P.Nummer    # BAG.Nummer;
  BAG.P.Position  # cnvia(vB);
  if (BAG.P.Nummer<>0) then begin
    Erx # RecRead(702,1,0);   // BA-Position holen
    if (Erx<>_rOK) then begin
      Msg(700003,cnvai(Bag.Nummer)+'/'+cnvai(cnvia(vB)),0,0,0);
      RETURN;
    end;
  end;

  // Zeitverwaltung aufrufen
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.Z.Verwaltung','',y);
  Lib_GuiCom:RunChildWindow(gMDI);

  ErrorOutput;
end;


//========================================================================
// sub BagZVerwaltung()
//          Startet die Betriebsauftragzeitenverwaltung
//========================================================================
sub _BaHatNur1Position() : logic
local begin
  vPosCnt : int;
  Erx     : int;
end
begin
  vPosCnt # RecLinkInfo(702,700,1,_RecCount);
  if (vPosCnt = 1) then
    RETURN true;

  vPosCnt # 0;
  FOR   Erx # RecLink(702,700,1,_RecFirst)
  LOOP  Erx # RecLink(702,700,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    if (BAG.P.Typ.VSBYN = false) then
      vPosCnt # vPosCnt + 1;
  END;

  if (vPosCnt > 1) then
    RETURN false;
  else
    RETURN true;

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================