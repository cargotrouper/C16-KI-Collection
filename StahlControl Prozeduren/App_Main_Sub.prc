@A+
//===== Business-Control =================================================
//
//  Prozedur  App_Main_Sub
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  05.10.2011  AI  Workaround für c_modeBald+c_ModeEdit Zeile 195
//  02.03.2012  AI  BUG: bei Neuanlage in Selektionsreclists (z.B: Projektpositionen) versprang
//                  der Buffer danach
//  02.08.2012  AI  Alle Notebookwechsel haben nun ein _WinFlagnoFocusset (wegne Problem beim Auto-F9 im BA-Einsatz)
//  14.08.2012  AI  Neu: StartVerwaltung
//  20.02.2014  AH  bei RecDel anderes Listen refresh
//  11.06.2014  AH  BugFix
//  25.06.2014  AH  Winclose hat immer führendes Winsleep (Walkaround z.b. für schnells LFS.Maske speicehrn und Rausklicken)
//  22.09.2014  AH  Bugfix List->View mit Selektion
//  27.01.2015  AH  Edit2 und New2 springen beim beenden in die ZL.Erfassung
//  18.02.2015  AH  Bugfix: Blättern in View ohne Edit-Knopf geht wieder
//  04.03.2015  AH  Bugfix: Dialoge ohne "DUMMYNEW" klappen
//  12.10.2015  ST  Bugfix: sub ModeCommend prüft ob Notebook vorhanden ist, bevor Notebookpage gesetzt wird
//  19.01.2018  AH  MoreBufs
//  05.03.2019  AH  "List-New" verspringt mit w_NoList nicht den Buffer
//  04.02.2020  AH  Neu: Menüsuche
//  20.05.2020  AH  Neu: Prev/NextPage
//  06.09.2021  AH  ERX
//  31.05.2022  AH  Neu: w_BaldPage
//  2022-07-04  AH  Edit prüft auf SingleLock und verhindert mehrere Sperren der gleichen Datei
//  02.08.2022  ST  Edit: Sub ModeCommand: Refresh der Zgr. nach Speicherung, wenn Selektion aktiv 2430/1
//  2023-01-26  AH  Neu: Neuanalge aus der List2 kann Vorbelegen
//
//  Subprozeduren
//  SUB ModeCommand(aSwitch : alpha; opt aPageName : alpha)
//  SUB StopModeNew();
//  SUB RebuildFavoriten ()
//  sub NextPage(aNB  : int)
//  sub PrevPage(aNB  : int)
//  sub JumperEvtFocusInit (aEvt : event; aFocusObject : int) : logic
//
//========================================================================
@I:Def_Global

//@define cDebugmode

define begin
  cDebugString  : aint(Ein.E.Eingangsnr)+'/'+aint(prj.p.position)
end;

//========================================================================
sub ModeCommand(
  aSwitch       : alpha;
  opt aPageName   : alpha);
local begin
  vHdl      : int;
  vHdl2     : int;
  vFlag     : int;
  vFlag2    : int;
  vOK       : logic;
  vNoRef    : logic;
  vMDI      : int;
  vEvt      : event;
  vObj      : int;
  vNoClose  : logic;
  vMode     : alpha;
  vLeer     : logic;
  vBuf      : int;
  vTmp      : int;
  vI        : int;
  vMsg      : int;
  Erx       : int;
  vBehalten : logic;
  vVorlageID  : int;
end;
begin
@ifdef cDebugMode
debug('start in '+w_name+'/'+gMDI->wpname+' SWITCH: '+aSwitch+'   '+cDebugString);
@endif
  
  vNoRef # n;
  if (StrCut(aSwitch,StrLen(aSwitch),1)='X') then begin
    vNoClose # y;
    aSwitch # StrCut(aSwitch,1,StrLen(aSwitch)-1);
  end;

  if (aSwitch='List-RecNext') then begin
    vFlag   # _recNext;
    vFlag2  # _RecNext;
    aSwitch # 'List-Rec';
  end;
  if (aSwitch='List-RecPrev') then begin
    vFlag   # _recPrev;
    vFlag2  # _RecPrev;
    aSwitch # 'List-Rec';
  end;
  if (aSwitch='List-RecFirst') then begin
    vFlag   # _recFirst;
    vFlag2  # _RecNext;
    aSwitch # 'List-Rec';
  end;
  if (aSwitch='List-RecLast') then begin
    vFlag   # _recLast;
    vFlag2  # _RecPrev;
    aSwitch # 'List-Rec';
  end;

  // ---------------------------------------------------------------------
//debug(aSwitch);
  case aSwitch of
    'List-Cancel' : begin
      Mode # c_ModeCancel;
      if (vNoClose=n) then begin
        Winsleep(1);
        gMdi->winclose();
      end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
      RETURN;
    end;

    'List-Rec' : if (gZLList<>0) then begin
      gZLList->WinFocusSet(false);
      if (gZLList->wpDbLinkFileNo=0) then begin
        if (gZLList->wpDbSelection<>0) then begin
          if (w_SelKeyProc<>'') then begin
          call(w_SelKeyProc);
          Erx # RecRead(gFile,gZLList->wpDbSelection, vFlag);
          if (gZLList->wpDbRecBuf(gFile)<>0) then RecBufCopy(gFile, gZLList->wpDbRecBuf(gFile));
            RefreshList(gZLList, _WinLstRecFromBuffer | _WinLstRecDoSelect);
          end
          else begin
            Erx # RecRead(gFile,gZLList->wpDbSelection, vFlag);
            // 23.03.2012 AI: Auf->Adrauswahl->RecFirst TESTEN
            // 11.06.2014 AH: DEAKTIVIERT weil sonst bei ViewMode + RecPrev/Next das EvtLstDataInit immer wieder gestartet wird?!? (z.B: REk.P.Verwaltung)
            // 15.03.2019 AH: AKTIVIERT weil BA-Verwaltung sonst nicht POS1/ENDE macht
            RefreshList(gZLList, _WinLstRecFromRecId | _WinLstRecDoSelect);
          end;
        end
        else begin // keine Sel
          Erx # RecRead(gFile,gKey, vFlag, gZLList->wpDbFilter);
          if (erx<=_rLocked) then begin
            if (gFile=200) then begin
              vOk # n;
              WHILE (vOK=n) and (erx<=_rLocked) do begin
                vOK # Mat_Main:EvtLstRecControl();
                if (vOK=n) then begin
                  Erx # RecRead(gFile,gkey, vFlag2,gZLList->wpDbFilter);
                end;
              END;
            end
            else if (gFile=800) then begin
              vOk # n;
              WHILE (vOK=n) and (erx<=_rLocked) do begin
                vOK # Usr_Main:EvtLstRecControl();
                if (vOK=n) then begin
                  Erx # RecRead(gFile,gkey, vFlag2,gZLList->wpDbFilter);
                end;
              END;
            end;
          end;
        end;

      end
      else begin
        RecLink(gZLList->wpDbLinkFileNo,gZLList->wpDbFileNo,gZLList->wpdbkeyno, vFlag,gZLList->wpDbFilter);
      end;

      $ed.Suche->wpcaption # '';
      if (Mode=c_ModeView) then
        gMdi->winupdate(_WinUpdFld2Obj);

// wegen Mat.A.Selektion DEAKTIVIERT / Mat.Komission ändern testen !
      if (gZLList<>0) then begin
        if (gZLList->wpDbLinkFileNo=0) and (gZLList->wpDbSelection=0) then begin
          if ((Mode=c_ModeList) or (Mode=c_ModeedList)) then begin

//gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
// 26.10.2010 sonst komisch bei Material RECLAST:
gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
//if (gFile=204) then debug('c: '+cnvai(mat.a.materialnr)+'/'+cnvai(mat.a.aktion));
//        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
//if (gFile=204) then debug('d: '+cnvai(mat.a.materialnr)+'/'+cnvai(mat.a.aktion));
          end;
        end;
      end;

      App_Main:RefreshMode(); // Buttons & Menues anpassen
    end; // List-Rec


    'List-View' : begin
      if (gZLList<>0) and (w_NoList=n) then begin
        if (gZLList->wpDbLinkFileNo<>0) then begin
        // 22.09.2014 AH wegen BA-Fergigung F9 bei VPG und da "Hauptdaten"
//          Erx # RecLink(gZLList->wpDbLinkFileNo, gZLList->wpDbFileNo, gZLList->wpdbkeyno, _Rectest);
          Erx # RecRead(gZLList->wpDbLinkFileNo ,0,_recid,gZLList->wpDbRecId);
        end
        else begin
          Erx # RecRead(gFile,0,_recid,gZLList->wpDbRecId);
        end;
      end
      else begin
        Erx # RecRead(gFile,0,_recid,gZLList->wpDbRecId);
      end;
      gMdi->winupdate(_WinUpdFld2Obj);
      vHdl # gMdi->winsearch('NB.Main');
      if (Erx<=_rLocked) then begin
        Mode # c_ModeView;
        if (vHdl <> 0) then begin
          if (vHdl->wpcurrent<>aPageName) then begin
            vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
          end;
        end;
//debugx('');
//        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end
      else begin
        if (vHdl <> 0) then begin   // 2022-06-23 AH
          vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
        end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
        RETURN;
      end;
    end; // List-View


    'List-Edit' : begin
      if (PtD_Main:IsInUse(gFile)) then begin
        Msg(1050,'',0,0,0);
        RETURN;
      end;

      Erx # _rNorec;
      if (gZLList->wpdbrecid<>0) then begin
        if (w_NoList) then Erx # _rOK   // 05.03.2019 AH
        else Erx # RecRead(gFile,0,_RecSingleLock | _RecId, gZLList->wpdbrecid);
      end;
// 07.03.2018 AH: Wenn kein Satz in der RecList ausgewählt, auch kein Edit!!!
// sonst Problem: Buf701 gefüllt, aber in Combomaske in leerem Input F6 möglich
// 04.04.2019 AH: einkommentiert, da Problem z.B. SSW wenn BA-Pos mit bald+edit aufgehen soll
      else if (RecInfo(gFile,_RecId)<>0) then begin
        Erx # RecRead(gFile,1,_RecSingleLock);
        if (Erx>_rlocked) then begin
          RecBufClear(gFile);   // 20.02.2017 AH für mehrfach F6 bei leerer BA-Pos in Combomaske
          RETURN;
        end;
      end;
      if (Erx>_rlocked) then begin // RETURN; 07.03.2018
        RecBufClear(gFile);   // 20.02.2017 AH für mehrfach F6 bei leerer BA-Pos in Combomaske
        RETURN;
      end;


      if (1=1) then begin
        if (Erx=_rOk) then begin
          Mode # c_ModeEdit;
          Lib_GuiCom:SetMaskState(true);
  //        App_Main:RefreshMode(); // Buttons & Menues anpassen
          Erx # RecRead(gFile,1,_RecLock);
          PtD_Main:Memorize(gFile);

// diese scheisse killt den Inahlt des aktuellen Felded...
          vHdl # gMdi->winsearch('NB.Main');
          vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
// Workaround....
vHdl # Winfocusget();
if (vHdl<>0) then begin
  Erx # RecRead(gFile,1,_RecLock);
end;
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecInit',_strupper));
          App_Main:RefreshMode(); // Buttons & Menues anpassen
if (vHdl<>0) then begin
  vI # Wininfo(vHdl,_WinType);
  if (vI=_WinTypeBigIntEdit) or (vI=_WinTypeDateEdit) or (vI=_WinTypeDecimalEdit) or
    (vI=_WinTypeEdit) or (vI=_WinTypeFloatEdit) or (vI=_WinTypeIntEdit) or
    (vI=_WinTypeRtfEdit) or (vI=_WinTypeTextEdit) or (vI=_WinTypeTimeEdit) then
    vHDL->wprange # Rangemake(0,-1);
end;

        end
        else begin
          Msg(001000+Erx,'',0,0,0);
        end;
      end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
      RETURN;
    end;  // List-Edit


    'List-New' : begin
      Mode # c_ModeNew;

      if (w_NoClrList=n) then RecBufClear(gFile);
      if (gFile=401) then RecBufClear(400);
      if (gFile=501) then RecBufClear(500);
//      Lib_GuiCom:SetMaskState(true);
      gMdi->winupdate(_WinUpdFld2Obj);
//      App_Main:RefreshMode(); // Buttons & Menues anpassen

      vHdl # gMdi->winsearch('NB.Main');
      if (gFile=401) or (gFile=501) then begin
        // 17.05.2016 AH:
        if (w_appendNr=0) then
          vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Kopf';
      end
      else begin
        if ($NB.Page1->wpdisabled) then $NB.Page1->wpdisabled # n;
        vMode # Mode;
        vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
        Mode  # vMode;
      end;

      vHdl2 # gMdi->winsearch('DUMMYNEW');
      if (vHdl2<>0) then vHdl2->winfocusset(false);

      Lib_GuiCom:SetMaskState(true);

      if (w_NoClrList=n) then RecBufClear(gFile);
      if (gFile=401) then RecBufClear(400);
      if (gFile=501) then RecBufClear(500);

      // FOKUSOBJEKT LÖSCHEN?!??!?!?!!
      vTmp # winfocusget();
      if (vTmp=10) then begin
        case (WinInfo(vTmp,_Wintype)) of
          _WinTypeEdit      : vTmp->wpcaption       # '';
          _WinTypeIntEdit   : vTmp->wpcaptionint    # 0;
          _WinTypeDateEdit  : vTmp->wpcaptiondate   # 0.0.0000;
          _WinTypeFloatEdit : vTmp->wpcaptionfloat  # 0.0;
          _WinTypeTimeEdit  : vTmp->wpcaptiontime   # 0:0;
        end;
      end;

      if (gPrefix<>'') then Call(gPrefix+'_Main:RecInit');
      App_Main:RefreshMode(); // Buttons & Menues anpassen
      gMdi->winupdate(_WinUpdFld2Obj);

    end;  // List-New
/***
    vHdl # WinFocusGet();
    if (vHdl<>0) then begin
      vTmp # WinInfo(vHdl,_WinType);
      case vTmp of
        _WintypeEdit :  vHdl->wpcaption # '';
        _WintypeFloatEdit :  vHdl->wpcaptionFloat # 0.0;
        _WintypeIntEdit :  vHdl->wpcaptionInt # 0;
        _WintypeDateEdit :  vHdl->wpcaptionDate # 0.0.0;
        _WintypeTimeEdit :  vHdl->wpCaptionTime # 0:0;
        _WinTypeCheckbox : vHdl->wpCheckState # _WinStateChkUnchecked;
        _WinTypeRadioButton : vHdl->wpcheckState # _WinStateChkUnchecked;
      end;
    end;
***/

    'List-Del' : begin
      if (RecRead(gFile,0,0,gZLList->wpdbrecid)=_rOK) then begin
        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecDel',_strupper));
          Mode # c_ModeList;
        end;
        if (gPrefix='') or (ErrGet() =_ErrNoProcInfo) or (ErrGet()=_ErrNoSub) then begin
          Msg(001999,gPrefix+'_Main:RecDel',0,0,0);
        end;

// 20.02.2014 für einfaches Löschen z.b. in Listenformaten 910:
// sanut Problem aber bei z.B. OPs löschen, wenn nach Datum*Stichwort und gleiche Sätze gelöscht werden
//gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect);
//  statt     gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
// laut VS:
gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect | _WinLstPosSelected);


// 21.1.2013        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer | _WinLstRecDoSelect); // Filter ok
//        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);  // Filter kaputt
//        gZLList->WinUpdate(_WinUpdOn, _WinLstFromSelected | _WinLstRecDoSelect); // Filter ok
//        gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstPosSelected);  // Filter kaputt
//gZLList->WinUpdate(_WinUpdOn,_WinLstFromSelected | _WinLstPosSelected | _WinLstRecDoSelect);

        App_Main:RefreshMode(); // Buttons & Menues anpassen
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
        $NB.List->WinFocusSet(false);
        vNoRef # y;         // NEU 11.1.2011
      end;
    end;  // Liste-Del

    // -------------------------------------------------------------------

    'View-List' : begin
      Mode # c_ModeList;
      WinEvtProcessSet(_WinEvtPageSelect,n);
      vHdl # gMdi->winsearch('NB.Main');
      vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
      WinEvtProcessSet(_WinEvtPageSelect,y);
//      gZLList->WinUpdate(_WinUpdOn, _WinLstRecDoSelect);
      App_Main:RefreshMode(); // Buttons & Menues anpassen
//      $NB.List->WinFocusSet(false);
    end; // View-List


    'View-Cancel' : begin
      if (gZLList=0) or (w_NoList) then begin   // falls keine ZList, dann schliessen
        Mode # c_ModeCancel;
        if (gFile<>0) then RecBufClear(gFile);
        if (vNoClose=n) then begin
          Winsleep(1);
          gMdi->winclose();
        end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
        RETURN;
      end;

      Mode # c_ModeList;
      WinEvtProcessSet(_WinEvtPageSelect,n);
//      vHdl->WinUpdate(_WinUpdOff);
      vHdl # gMdi->winsearch('NB.Main');
      vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
      WinEvtProcessSet(_WinEvtPageSelect,y);

      // 02.08.2012 AI:
      gZLlist->winfocusset(true);

//      vTmp # gMdi->winsearch('NB.List');
//      if (vTmp<>0) then vTmp->WinFocusSet(false);
      App_Main:RefreshMode(); // Buttons & Menues anpassen
//      vHdl->WinUpdate(_WinUpdOn);
//      vNoRef # y;
    end;  // View-Cancel


    'View-Edit' : begin
      if (PtD_Main:IsInUse(gFile)) then begin
        Msg(1050,'',0,0,0);
        RETURN;
      end;

      Erx # RecRead(gFile,1,_RecTest);
      if (Erx<=_rLocked) then begin
        Erx # RecRead(gFile,1,_RecSingleLock);
        if (Erx=_rOk) then begin
          Mode # c_ModeEdit;
          Lib_GuiCom:SetMaskState(true);
//          App_Main:RefreshMode(); // Buttons & Menues anpassen
          PtD_Main:Memorize(gFile);
          vHdl # gMdi->winsearch('NB.Main');
          vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecInit',_strupper));
          App_Main:RefreshMode(); // Buttons & Menues anpassen
        end
        else begin
          Msg(001000+Erx,gTitle,0,0,0);
        end;
      end;
    end;  // View-Edit


    'View-New' : begin
      // Buffer ggf. leeren
      if (w_NoClrList=n) then RecBufClear(gFile);
      if (gFile=401) then RecBufClear(400);
      if (gFile=501) then RecBufClear(500);

      gMdi->winupdate(_WinUpdFld2Obj);
      vHdl # gMdi->winsearch('NB.Main');
      vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
      Mode # c_ModeNew;
      Lib_GuiCom:SetMaskState(true);

      // Buffer ggf. leeren
      if (w_NoClrList=n) then RecBufClear(gFile);
      if (gFile=401) then RecBufClear(400);
      if (gFile=501) then RecBufClear(500);

      if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecInit',_strupper));
      App_Main:RefreshMode(); // Buttons & Menues anpassen
    end;  // View-New

    'View-Del' : begin
      try begin
        ErrTryIgnore(_rlocked,_rNoRec);
        ErrTryCatch(_ErrNoProcInfo,y);
        ErrTryCatch(_ErrNoSub,y);
        if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecDel',_strupper));
      end;
      if (gPrefix='') or (ErrGet() =_ErrNoProcInfo) or (ErrGet()=_ErrNoSub) then begin
        Msg(001999,gPrefix+'_Main:RecDel',0,0,0);
      end;
      App_Main:RefreshMode(); // Buttons & Menues anpassen
    end;

    // -------------------------------------------------------------------

    'New-Cancel' : begin
      if (w_CopyToBuf<>0) then begin
        Mode # c_ModeCancel;
        gMdi->winclose();
        RETURN;
      end;

      vObj # WinFocusget();
      if (gZLList=0) or (w_NoList) then begin   // falls keine ZList, dann schliessen
        //Eingabe verwerfen?
        vMode # Mode;
        mode # c_modeCancel;
        vMsg # Msg(000002,'',_WinIcoQuestion,_WinDialogYesNo,2)
        Mode # vMode;
        if (vMsg=_WinIdYes) then begin
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          Mode # c_ModeCancel;
          if (gFile<>0) then RecBufClear(gFile);
          if (vNoClose=n) or (w_Command='X') then begin
            Winsleep(1);
            gMdi->winclose();
          end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end
        else begin  // weitermachen...
          mode # vMode;
// 18.09.2012 AI         mode # c_modeCancel;
          if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;
      end
      else begin
        //Eingabe verwerfen?
        vMode # Mode;
        Mode # c_modeCancel;
        vMsg # Msg(000002,'',_WinIcoQuestion,_WinDialogYesNo,2);
        Mode # vMode;
        if (vMsg=_WinIdYes) then begin
          vMdi # gMdi;
          try begin
            ErrTryIgnore(_rlocked,_rNoRec);
            ErrTryCatch(_ErrNoProcInfo,y);
            ErrTryCatch(_ErrNoSub,y);
            if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
          end;

          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          if (vMdi=gMDI) then begin
            Mode # c_ModeCancel;
            Lib_GuiCom:SetMaskState(false);
            vHdl # gMdi->winsearch('NB.List');
            if (vHdl<>0) then vHdl->wpdisabled # false;
            vHdl # gMdi->winsearch('NB.Main');
            if (vHdl<>0) then vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
            Mode # c_ModeNew;
          end;

          if (gZLlist<>0) then begin
            if (gZLList->wpDbLinkFileNo<>0) then begin
              Erx # RecLink(gZLList->wpDbLinkFileNo,gZLList->wpDbFileNo,gZLList->wpdbkeyno,_RecFirst);
            end
            else begin
              if (gZLList->wpDbSelection<>0) then
                Erx # RecRead(gFile,gZLList->wpDbSelection, _recFirst)
              else
                Erx # RecRead(gFile,1,_RecFirst);
            end;
            if (Mode=c_ModeNew) then Mode # c_ModeList;   // 2022-11-09 AH
            if (erx=_rNoRec) then begin
              RecBufClear(gFile);
              if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RefreshIfm',_strupper));
            end;
            // 02.08.2012 AI:
            gZLlist->winfocusset(true);
          end;
          if (Mode=c_ModeNew) then Mode # c_ModeList;

          vNoRef # y;
          App_Main:RefreshMode(); // Buttons & Menues anpassen
        end
        else begin // weitermachen...
          if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;
      end;
    end;  // New-Cancel


    'New-Save' : begin
      if (gZLList=0) or (w_NoList) then begin   // falls keine ZList, dann schliessen
        if (gPrefix<>'') then begin
          vObj # WinFocusget();     // händisch das FocusTerm starten
          vEvt:obj # vObj;

          try begin
            ErrTryIgnore(_rlocked,_rNoRec);
            ErrTryCatch(_ErrNoProcInfo,y);
            ErrTryCatch(_ErrNoSub,y);
            vTmp # winInfo(vObj, _Wintype);
            if (vTmp<>_WinTypeButton) then
              Call(gPrefix+'_Main:EvtFocusTerm',vEvt,vObj);
          end;
          vOk # Call(strcnv(gPrefix+'_Main:RecSave',_strupper));
        end;

        if (w_CopyToBuf<>0) then begin
          Mode # c_ModeCancel;
          gMdi->winclose();
          RETURN;
        end;

        if (vOk=y) then begin
          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          if (gZLList<>0) then
            if (gZLList->wpDbSelection<>0) then
              SelRecInsert(gZLList->wpDbSelection,gfile);
          Mode # c_ModeCancel;
          if (gFile<>0) then RecBufClear(gFile);
          if (vNoClose=n) or (w_Command='X') then begin
//            Winsleep(1);
            gMdi->winclose();
          end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;

      end
      else begin

        vOk # y;
        vMdi # gMdi;

        // NEU: 20.07.2009...
        vObj # WinFocusget();     // händisch das FocusTerm starten
        vEvt:obj # vObj;
        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          vTmp # winInfo(vObj, _Wintype);
          if (vTmp<>_WinTypeButton) then
            Call(gPrefix+'_Main:EvtFocusTerm',vEvt,vObj);
        end;

        if (gPrefix<>'') then vOk # Call(strcnv(gPrefix+'_Main:RecSave',_strupper));
        if (vOk=y) then begin
          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          if (gZLList<>0) then
            if (gZLList->wpDbSelection<>0) then
              SelRecInsert(gZLList->wpDbSelection,gfile);

//          if (Mode=c_ModeNew) then Mode # c_ModeList;
//          if (gMdi=vMdi) then begin   10.05.2022 AH z.B. BSC->ERe-Erfassung
          if (Mode=c_ModeNew) then begin
            Mode # c_ModeList;
            Lib_GuiCom:SetMaskState(false);
            vHdl # gMdi->winsearch('NB.List');
            if (vHdl<>0) then vHdl->wpdisabled # false;
            vHdl # gMdi->winsearch('NB.Main');
            if (vHdl<>0) then vHdl->wpCurrent # 'NB.List';  // FOCUS auch SETZEN !!!
          end;

          if (w_Command='X') then   // Fenster dirket schließen?
            gMdi->winclose()
          else
            App_Main:RefreshMode(); // Buttons & Menues anpassen
        end
        else begin  // Saven falsch!
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;
      end;

    end; // New-Save

    // -------------------------------------------------------------------

    'Edit-Cancel' : begin
      if (w_CopyToBuf<>0) then begin
        Mode # c_ModeCancel;
        gMdi->winclose();
        RETURN;
      end;

      vObj # WinFocusget();

      if (gZLList=0) or (w_NoList) then begin   // falls keine ZList, dann schliessen
        //Änderungen verwerfen?

        vMode # Mode;
        Mode # c_ModeCancel;
        vMsg # Msg(000003,'',_WinIcoQuestion,_WinDialogYesNo,2);
        Mode # vMode;
        if (vMsg=_WinIdYes) then begin
          if (gFile<>0) then if (ProtokollBuffer[gFile]<>0) then PtD_Main:Forget(gFile);
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          vOK # (Mode=c_ModeClose);
          Mode # c_ModeView;
          Lib_GuiCom:SetMaskState(false);
          App_Main:RefreshMode(); // Buttons & Menues anpassen
          vHdl # gMdi->winsearch('NB.Main');
          vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
          if (gFile>0) and (gFile<1000) then
            RecRead(gFile,1,_RecUnLock);
          gMdi->winupdate(_WinUpdFld2Obj);
          if (vOK) then begin   // sofort schließen?    10.05.2021 AH
            Mode # c_ModeCancel;
            gMdi->winclose();
            RETURN;
          end;
          
        end
        else begin  // weitermachen..
          if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;

      end
      else begin
        //Änderungen verwerfen?
        vMode # Mode;
        Mode # c_ModeCancel;
        vMsg # Msg(000003,'',_WinIcoQuestion,_WinDialogYesNo,2);
        Mode # vMode;
        if (vMsg =_WinIdYes) then begin
          try begin
            ErrTryIgnore(_rlocked,_rNoRec);
            ErrTryCatch(_ErrNoProcInfo,y);
            ErrTryCatch(_ErrNoSub,y);
            if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
          end;
          w_BinKopieVonDatei  # 0;
          w_BinKopieVonRecID  # 0;
          Mode # c_ModeView;
          Lib_GuiCom:SetMaskState(false);
//          vHdl # gMdi->winsearch('NB.Main');
//          vHdl->wpCurrentx # 'NB.Page1';
          RecRead(gFile,1,_RecUnLock);
          gMdi->winupdate(_WinUpdFld2Obj);
          App_Main:RefreshMode(); // Buttons & Menues anpassen
          PtD_Main:Forget(gFile);
        end
        else begin // weitermachen...
          if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;
      end;
    end;  // Edit-Cancel


    'Edit-Save' : begin
      vMdi # gMdi;
      vOk # y;
      if (gPrefix<>'') then begin
        vObj # WinFocusget();     // händisch das FocusTerm starten
        vEvt:obj # vObj;

        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          vTmp # winInfo(vObj, _Wintype);
          if (vTmp<>_WinTypeButton) then
            Call(gPrefix+'_Main:EvtFocusTerm',vEvt,vObj);
        end;

        if (w_CopyToBuf<>0) then begin
          Mode # c_ModeCancel;
          vMdi->winclose();
          RETURN;
        end;

        vOk # Call(gPrefix+'_Main:RecSave');
      end;
      if (vOk=y) then begin
        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        if (gZLList=0) or (w_NoList) then begin   // falls keine ZList, dann schliessen
          Mode # c_ModeCancel;
          if (gFile<>0) then RecBufClear(gFile);
          if (vNoClose=n) then begin
            Winsleep(1);
            gMdi->winclose();
          end;
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
          RETURN;
        end;
        //RekReplace(gFile,_recUnlock,'MAN');
        //PtD_Main:Compare(gFile);
        if (Mode=c_ModeEdit) then Mode # c_ModeView;
        if (gMdi=vMdi) then begin
          Lib_GuiCom:SetMaskState(false);
          vHdl # gMdi->winsearch('NB.Main');
          if (vHdl<>0) then vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
        end;
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end
      else begin  // Saven falsch!
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
        RETURN;
      end;
    end;  // Edit-Save

    // -------------------------------------------------------------------

    'List2-Cancel' : begin

      if (Msg(000004,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
        try begin
            ErrTryIgnore(_rlocked,_rNoRec);
            ErrTryCatch(_ErrNoProcInfo,y);
            ErrTryCatch(_ErrNoSub,y);
            if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
        end;
        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        if (gZLList->wpDbLinkFileNo<>0) then begin
          Erx # RecLink(gZLList->wpDbLinkFileNo,gZLList->wpDbFileNo,gZLList->wpdbkeyno,_RecFirst);
        end
        else begin

/*
begin
debug('Start::::::::::::::');
debug('Auf.Nummer '+ Aint(Auf.Nummer));
debug('Auf.P.Nummer '+ Aint(Auf.P.Nummer));
          if (gfile = 401) then begin
            Erx # RecRead(400,1,_RecTest);
            if (Erx <> _rOK) then
              Erx # RecRead(400,1,_RecFirst);

          end;
debug('Auf.Nummer '+ Aint(Auf.Nummer));
debug('Auf.P.Nummer '+ Aint(Auf.P.Nummer));
debug(':::::::::::Ende');
end;
*/
          Erx # RecRead(gFile,1,_RecFirst);

        end;
        if (erx=_rNoRec) then begin
          RecBufClear(gFile);
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RefreshIfm',_strupper));
        end;
        Mode # c_ModeList;
        Lib_GuiCom:SetMaskState(false);
        vHdl # gMdi->winsearch('NB.List');
        vHdl->wpdisabled # false;
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # true;
        vHdl->wpvisible # false;
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end;
    end;  // List2-Cancel


    'List2-Save' : begin
      vOk # y;
      if (gPrefix<>'') then vOk # Call(strcnv(gPrefix+'_Main:RecSave',_strupper));
      if (vOk=y) then begin
        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        Mode # c_ModeList;
        Lib_GuiCom:SetMaskState(false);
        vHdl # gMdi->winsearch('NB.List');
        if (vHdl<>0) then vHdl->wpdisabled # false;
        vHdl # gMdi->winsearch('NB.Main');
        if (vHdl<>0) then vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # true;
        vHdl->wpvisible # false;
        if (gZLList<>0) then gZLList->winfocusset(true);    // 12.11.2014
        App_Main:RefreshMode(); // Buttons & Menues anpassen

        // ST 2022-08-02 2430/1
        if (w_SelName <> '') then
          App_Main:Refresh();

      end;
    end;  // List2-Save


    'List2-New' : begin
      Mode # c_ModeNew2;
// 2023-01-26 AH
      if ($ZL.Erfassung->wpdbRecId<>0) and
      (RecRead($ZL.Erfassung->wpDbLinkFileNo,0,0,$ZL.Erfassung->wpdbRecId)=_rOK) then begin
        if (Msg(000020,'',_WinIcoQuestion,_Windialogyesno,2)=_winidyes) then begin
          vBehalten # true;
          vVorlageID  # RecInfo($ZL.Erfassung->wpDbLinkFileNo, _recId);
        end;
      end;

      RecBufClear(gFile);
      Lib_GuiCom:SetMaskState(true);
      gMdi->winupdate(_WinUpdFld2Obj);

      vHdl # gMdi->winsearch('NB.Main');
      vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
      RecBufClear(gFile);
      if (gPrefix<>'') then begin
        w_AppendNr # vVorlageID;
        Call(strcnv(gPrefix+'_Main:RecInit',_strupper), vBehalten);
        w_AppendNr # 0;   // 2023-06-05 AH
      end;
      Call(strcnv(gPrefix+'_Main:RefreshIfm',_strupper));
      gMdi->winupdate(_WinUpdFld2Obj);
      App_Main:RefreshMode(); // Buttons & Menues anpassen
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
      RETURN;
    end; // List2-New


    'List2-Edit' : begin
      if (RecLinkInfo($ZL.Erfassung->wpDbLinkFileNo,$ZL.Erfassung->wpDbFileNo,$ZL.Erfassung->wpdbkeyno,_RecCount)=0) then begin
        Mode # c_ModeEdit2;
        Lib_GuiCom:SetMaskState(true);
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # true;
        vHdl->wpvisible # false;

        if (gPrefix<>'') then Call(gPrefix+'_Main:RecInit');
        Call(gPrefix+'_Main:RefreshIfm');
        Mode # c_ModeNew;

        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end
      else begin
        Erx # RecRead(gFile,1,_RecTest);
        if (Erx>=_rLocked) then begin
          Msg(001000+Erx,gTitle,0,0,0);
        end
        else begin
          Erx # RecRead(gFile,1,_RecLock);
          if (Erx=_rOk) then begin
            Mode # c_ModeEdit2;
            Lib_GuiCom:SetMaskState(true);
            vHdl # gMdi->winsearch('NB.Main');
            vHdl->wpCurrent(_WinFlagnoFocusset) # aPageName;
            vHdl # gMdi->winsearch('NB.Erfassung');
            vHdl->wpdisabled # true;
            vHdl->wpvisible # false;

            if (gPrefix<>'') then Call(gPrefix+'_Main:RecInit');
            Call(gPrefix+'_Main:RefreshIfm');

            App_Main:RefreshMode(); // Buttons & Menues anpassen
          end
          else begin
            Msg(001000+Erx,gTitle,0,0,0);
          end;
        end;
      end;
    end; // List2-Edit


    'List2-Del' : begin
      if (RecRead($ZL.Erfassung->wpDbLinkFileNo,0,0,$ZL.Erfassung->wpdbRecId)=_rOK) then begin
        if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecDel',_strupper));
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end;
    end;  // List2-Del

    // -------------------------------------------------------------------

    'New2-Cancel' : begin
      if (w_CopyToBuf<>0) then begin
        Mode # c_ModeCancel;
        gMdi->winclose();
        RETURN;
      end;

      //Eingabe verwerfen?
      // Posten wird abgebrochen
      vObj # WinFocusget();
      vMode # Mode;
      Mode # c_ModeCancel;
      vMsg # Msg(000002,'',_WinIcoQuestion,_WinDialogYesNo,2);
      Mode # vMode;
      if (vMsg =_WinIdYes) then begin
        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RecCleanup',_strupper));
        end;
        // kein satz? Dann wieder in Liste
/**1212**
        if (RecLink($ZL.Erfassung->wpDbLinkFileNo,$ZL.Erfassung->wpDbFileNo,$ZL.Erfassung->wpdbkeyno,_RecFirst)=_rNoRec) then begin
          Mode # c_ModeList;
          Lib_GuiCom:SetMaskState(false);
          vHdl # gMdi->winsearch('NB.List');
          vHdl->wpdisabled # false;
          vHdl # gMdi->winsearch('NB.Main');
          vHdl->wpCurrentx # 'NB.List';
          vHdl # gMdi->winsearch('NB.Erfassung');
          vHdl->wpdisabled # true;
          vHdl->wpvisible # false;
        end
        else begin
**1212**/
        if (RecLink($ZL.Erfassung->wpDbLinkFileNo,$ZL.Erfassung->wpDbFileNo,$ZL.Erfassung->wpdbkeyno,_RecFirst)=_rNoRec) then begin
          RecBufClear($ZL.Erfassung->wpDbLinkFileNo);
          vLeer # y;
        end;

        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        Mode # c_ModeList2;
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # false;
        vHdl->wpvisible # true;
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Erfassung';
        if (vLeer) then RecBufClear($ZL.Erfassung->wpDbLinkFileNo);
        $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstFromFirst | _WinLstRecDoSelect);
        $ZL.Erfassung->Winfocusset(true);
        //$ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
//end;
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end
      else begin  // weitermachen...
        if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
        RETURN;
      end;
    end;  // New2-Cancel


    'New2-Save' : begin
      vOk # y;
      if (gPrefix<>'') then begin
        vObj # WinFocusget();     // händisch das FocusTerm starten
        vEvt:obj # vObj;

        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          vTmp # winInfo(vObj, _Wintype);
          if (vTmp<>_WinTypeButton) then
            Call(gPrefix+'_Main:EvtFocusTerm',vEvt,vObj);
        end;

        vOk # Call(strcnv(gPrefix+'_Main:RecSave',_strupper));
      end;

      if (w_CopyToBuf<>0) then begin
        Mode # c_ModeCancel;
        gMdi->winclose();
        RETURN;
      end;

      if (vOk=y) then begin
        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        Mode # c_ModeList2;
        Lib_GuiCom:SetMaskState(false);
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # false;
        vHdl->wpvisible # true;
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Erfassung';
        $ZL.Erfassung->WinUpdate(_WinUpdOn, _WinLstRecFromRecId | _WinLstRecDoSelect);
        $ZL.Erfassung->Winfocusset(true);
      end;
      App_Main:RefreshMode(); // Buttons & Menues anpassen
    end;  // New2-Save

    // -------------------------------------------------------------------

    'Edit2-Cancel' : begin
      if (w_CopyToBuf<>0) then begin
        Mode # c_ModeCancel;
        gMdi->winclose();
        RETURN;
      end;

      //Änderungen verwerfen?
      vObj # WinFocusget();
      vMode # Mode;
      Mode # c_ModeCancel;
      vMsg # Msg(000003,'',_WinIcoQuestion,_WinDialogYesNo,2);
      Mode # vMode;
      if (vMsg =_WinIdYes) then begin
        Mode # c_ModeList2;
        Lib_GuiCom:SetMaskState(false);
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # false;
        vHdl->wpvisible # true;
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Erfassung';
        RecRead(gFile,1,_RecUnLock);
        $ZL.Erfassung->Winfocusset(true);
  //       PtD_Main:Forget(gFile);
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end
      else begin  // weitermachen...
        if (vObj<>0) then vObj->winfocusset(false);
@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif
        RETURN;
      end;
    end; // Edit2-Cancel

    'Edit2-Save' : begin
      vMdi # gMDI;
      vOk # y;
      if (gPrefix<>'') then begin
        vObj # WinFocusget();     // händisch das FocusTerm starten
        vEvt:obj # vObj;

        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          vTmp # winInfo(vObj, _Wintype);
          if (vTmp<>_WinTypeButton) then
            Call(gPrefix+'_Main:EvtFocusTerm',vEvt,vObj);
        end;

        if (w_CopyToBuf<>0) then begin
          Mode # c_ModeCancel;
          vMdi->winclose();
          RETURN;
        end;

        vOk # Call(strcnv(gPrefix+'_Main:RecSave',_strupper));
      end;
      if (vOk=y) then begin
        w_BinKopieVonDatei  # 0;
        w_BinKopieVonRecID  # 0;
        //RekReplace(gFile,_recUnlock,'MAN');
        //PtD_Main:Compare(gFile);
        Mode # c_ModeList2;
        Lib_GuiCom:SetMaskState(false);
        vHdl # gMdi->winsearch('NB.Erfassung');
        vHdl->wpdisabled # false;
        vHdl->wpvisible # true;
        vHdl # gMdi->winsearch('NB.Main');
        vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.Erfassung';
        $ZL.Erfassung->Winfocusset(true);
        App_Main:RefreshMode(); // Buttons & Menues anpassen
      end;
    end; // Edit2-Save

    // -------------------------------------------------------------------
    otherwise begin
      TODO('SWITCH  : '+aSwitch);
    end;

  end; // CASE

                                   // Zugriffliste neu positionieren
  if (Mode=c_ModeList) and (vNoRef=n) then begin
    if (gZLList<>0) then begin
      if (w_SelKeyProc<>'') then begin
        call(w_SelKeyProc);
        RefreshList(gZLList, _WinLstRecFromBuffer | _WinLstRecDoSelect);
      end
      else begin
        RefreshList(gZLList, _WinLstRecFromRecId | _WinLstRecDoSelect);
      end;
    end;
  end;

//  App_Main:RefreshMode();                  // Buttons & Menues anpassen

  if (Mode=c_ModeView) then begin // Wieder auf "Edit" focusieren
    vTmp # gMdi->winsearch('Edit');
    if (vTMP<>0) then
      if (vTmp->wpdisabled) then
        if (gMdi->winsearch('EditErsatz')<>0) then
          vTmp # gMdi->winsearch('EditErsatz');
    if (vTmp<>0) then vTmp->WinFocusSet(true);
  end;

//  gMdi->winupdate(_WinUpdFld2Obj);

@ifdef cDebugMode
debug('Ende SWITCH:'+aSwitch+' L:'+aint(__LINE__)+'  '+cDebugString);
@endif

end;


//========================================================================
//  StopModeNew
//
//========================================================================
sub StopModeNew();
local begin
  vHdl  : handle;
  erx   : int;
end;
begin

  // von ModeNew nach ModeList...
  Mode # c_ModeCancel;
  Lib_GuiCom:SetMaskState(false);
  vHdl # gMdi->winsearch('NB.List');
  if (vHdl<>0) then vHdl->wpdisabled # false;
  vHdl # gMdi->winsearch('NB.Main');
  if (vHdl<>0) then vHdl->wpCurrent(_WinFlagnoFocusset) # 'NB.List';
  Mode # c_ModeNew;

  if (gZLlist<>0) then begin
    if (gZLList->wpDbLinkFileNo<>0) then begin
      Erx # RecLink(gZLList->wpDbLinkFileNo,gZLList->wpDbFileNo,gZLList->wpdbkeyno,_RecFirst);
    end
    else begin
      Erx # RecRead(gFile,1,_RecFirst);
    end;
    if (erx=_rNoRec) then begin
      RecBufClear(gFile);
      if (gPrefix<>'') then Call(strcnv(gPrefix+'_Main:RefreshIfm',_strupper));
    end;
  end;
  if (Mode=c_ModeNew) then Mode # c_ModeList;
  App_Main:RefreshMode(); // Buttons & Menues anpassen

end;


//=========================================================================
// RebuildHauptmenue
//        Hauptmenü neu aufbauen
//=========================================================================
sub RebuildFavoriten ()
local begin
  vMenu    : handle;
  vItem    : handle;
  vDefault : handle;
  Erx       : int;
end;
begin
  vMenu # $TV.Hauptmenue->WinSearch( 'Favoriten' );

  // Favoritenmenü anlegen oder leeren
  if ( vMenu = 0 ) then begin
    vMenu # $TV.Hauptmenue->WinTreeNodeAdd( 'Favoriten', Translate( 'Favoriten' ) );
    vMenu->WinPropSet( _winPropNodeStyle, _winNodeFolder );
  end
  else
    vMenu->WinTreeNodeRemove( true );

  // Favoritenmenü aufbauen
  Usr.Fav.Username # gUsername;
  FOR  Erx # RecRead( 803, 1, _recFirst );
  LOOP Erx # RecRead( 803, 1, _recNext );
  WHILE ( Erx != _rNoRec ) DO BEGIN
    if ( Usr.Fav.Username != gUsername ) then
      CYCLE;

    vItem # vMenu->WinTreeNodeAdd( Usr.Fav.Name, Usr.Fav.Caption );
    if ( StrCut( Usr.Fav.Name, 1, 3 ) = 'sfx' ) then
      vItem->WinPropSet( _winPropNodeStyle, _winNodeBlueBall );
    else
      vItem->WinPropSet( _winPropNodeStyle, _winNodeBlueBook );
    vItem->WinPropSet( _winPropCustom, Usr.Fav.Custom );
  END;

  vMenu->WinPropSet( _winPropNodeExpanded, true );

  // Defaultknoten ermitteln & Fokus aktivieren
  Usr.Username # gUsername;
  if ( RecRead( 800, 1, _rNoLock ) < _rNoKey ) then begin
    Lib_GuiCom:Tree_find_default( $TV.Hauptmenue, Usr.Tree.Default, true );
  end;
end;


//========================================================================
//  StartVerwaltung
//
//========================================================================
sub StartVerwaltung(
  aDialog       : alpha;
  aRecht        : int;
  var aMdiVar   : int;
  aRecId        : int;
  aView         : logic;
  opt aNoList   : logic;
  opt aSel      : int;
  opt aSelname  : alpha;
  opt aSelMakerProc : alpha;
  opt aViewPage : alpha) : logic;
local begin
  vHdl        : int;
  vNew        : logic;
  vSchonAktiv : logic;
  vEvt        : event;
end;
begin
//debugx(aint(aRecID)+abool(aView));
  if (Rechte[aRecht]=false) then RETURN false;

  // bereits offen?
  if ( aMDIVar <> 0 ) then begin
    vSchonAktiv # (gMDI=aMDIVar);
    // komisches Fenster? -> ENDE
    if ( aMDIVar->wpName != Lib_GuiCom:GetAlternativeName(aDialog)) then RETURN false;

    VarInstance( WindowBonus, CnvIA( aMDIVar->wpCustom ) );

    // komischer Modus? -> ENDE
    if ( Mode <> c_ModeList ) and ( Mode <> c_ModeView ) then begin
      if (gMDI<>0) then VarInstance( WindowBonus, CnvIA( gMDI->wpCustom ) );
      RETURN false;
    end;

    // Kind aktiv? -> ENDE
    if ( w_Child<>0) then RETURN false;

    if (aRecID<>0) then begin
      // Eventuelle Selektion entfernen
      vHdl # gZLList->wpDbSelection;
      if (vHdl != 0 ) then begin
        if ( w_SelName != '') then begin
          gZLList->wpAutoUpdate  # false;
          gZLList->wpDbSelection # 0
          SelClose( vHdl );
          SelDelete( gFile, w_selName );
        end;
        if ( w_Sel2Name != '') then begin
          SelDelete( gFile, w_sel2Name );
        end;
      end;
    end;
  end;

  // Neu öffnen?
  if ( aMDIVar = 0 ) then begin
    aMDIVar # Lib_GuiCom:OpenMdi( gFrmMain, aDialog, _winAddHidden );
    vNew    # true;
  end;

  VarInstance( WindowBonus, CnvIA(aMDIVar->wpCustom ) );

  if (aRecId<>0) then begin
    if (aView) then begin
      Mode       # c_ModeBald + c_ModeView;
      w_BaldPage # aViewPage;
    end
    else begin
      Mode       # c_ModeBald + c_ModeList;
    end;
    w_Command  # 'REPOS';
    if (vNew) then w_Command  # 'NEWREPOS';
    w_Cmd_Para # aInt( aRecId );
  end;
  
  w_NoList # aNoList;   // 22.04.2021 AH

  if (aSelMakerProc<>'') then Call(aSelMakerProc);

  // 18.05.2021 AH
  if (aSel<>0) then begin
    gZLList->wpDbSelection # aSel;
    w_SelName # aSelName;
  end;

  if ( vNew ) then begin
    aMDIVar->WinUpdate( _winUpdOn )
    aMDIVar->WinFocusSet( true );
  end
  else begin
    Lib_guiCom:ReOpenMDI(aMDIVar);
    VarInstance( WindowBonus, CnvIA( aMDIVar->wpCustom ) );
    if (vSchonAktiv) then begin
      vEvt:Obj # gMdi;
      App_Main:EvtMdiActivate(vEvt);
    end;
  end;

  RETURN true;
end;


//========================================================================
sub _BuildSuchMenuName(aHdl : int) : alpha
local begin
  vHdl  : int;
  vA    : alpha(1000);
end
begin
  vHdl # wininfo(aHdl, _Winparent);
  WHILE (vHdl<>0) do begin
    if (vHdl->wpname='TV.Hauptmenue') then BREAK;
    vA # vHdl->wpCaption+'->'+vA;
    vHdl # wininfo(vHdl, _Winparent);
  END;
  vA # vA + aHdl->wpCaption;
  RETURN vA;
end;


//========================================================================
sub SuchMenuEvtLstSelect(
  aEvt                  : event;        // Ereignis
  aID                   : bigint;       // Record-ID des Datensatzes oder Zeilennummer
) : logic;
local begin
  vEvt  : event;
  vItem : int;
  vTV   : int;
  vEd   : int;
end;
begin
  vEd # Winsearch(gMdiMenu, 'SuchMenuEdit');
  vEd->wpcaption # '';

  vTV # Winsearch(gMdiMenu, 'TV.Hauptmenue');
//  WinFocusSet(vTV);
  
  vEvt:obj # vTV;
  WinLstCellGet(aEvt:obj, vItem, 2, aID);
//debugx(aint(aID));
  App_Main:EvtMouseItem(vEvt,_WinMouseDouble,0, vItem, 0); //4=item

  RETURN(true);
end;


//=========================================================================
sub SuchMenuEvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vDL           : int;
  vA,vB         : alpha(200);
  vTV           : int;
  vNodeFound    : int;
  vNodeRef      : int;
  vNodeCurrent  : int;
  vFirst        : logic;
  vHdl          : int;
end;
begin

  vTV # Winsearch(gMdiMenu, 'TV.Hauptmenue');

  vDL # Winsearch(aEvt:obj, 'DataListPopup1');
  if (vDl<>0) then begin
    vA # aEvt:Obj->wpCaption;
    vDl->wpMaxLines # 5;// + StrLen(vA);
    vDl->winupdate(_WinupdSort|_WinupdOn);
    WinLstDatLineRemove(vDL,_WinLstDatLineAll);
    if (StrLen(vA)<=2) then begin
      WinLstDatLineAdd(vDL, '');
      WinLstDatLineAdd(vDL, '');
      WinLstDatLineAdd(vDL, '');
      WinLstDatLineAdd(vDL, '');
      WinLstDatLineAdd(vDL, '');
    end
    else begin
      vNodeCurrent # vTV;
      FOR begin
        vFirst # true;
        vNodeFound # vNodeCurrent->WinTreeNodeSearch('*'+vA+'*', _WinTreeNodeSearchCaption | _WinTreeNodeSearchCI | _WinTreeNodeSearchLike | _WinTreeNodeSearchChildrenOnly | _WinTreeNodeSearchNoSelect);
        vNodeRef # vNodeFound;
        end
      LOOP vNodeFound # vNodeCurrent->WinTreeNodeSearch('*'+vA+'*', _WinTreeNodeSearchCaption | _WinTreeNodeSearchCI | _WinTreeNodeSearchLike | _WinTreeNodeSearchChildrenOnly | _WinTreeNodeSearchNoSelect, vNodeFound);
      WHILE (vNodeFound > 0 and (vNodeFound != vNodeRef or vFirst)) do begin
        vFirst # false;
        if (Wininfo(vNodeFound,_Winfirst)>0) then CYCLE;  // keine Zwischenmenüs!
        
        vB # _BuildSuchMenuName(vNodeFound);
        WinLstDatLineAdd(vDL, vB);
        WinLstCellSet(vDL, vNodeFound, 2, _WinlstDatLineLast);
      END;
    end;
  end;
  
  RETURN(true);
end;


//=========================================================================
//  IsPageActive
//      prüft, ob eine Notebook-Page per PageUp/PageDown angesprungen werden kann
//=========================================================================
sub IsPageActive(aName : alpha) : logic
local begin
  vRet  : logic;
end;
begin
  if (gPrefix='') then RETURN true;
  
  vRet # true;
  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    vRet # Call(gPrefix+'_Main:IsPageActive', aName);
  end;
  
  RETURN vRet;
end;


//=========================================================================
//  NextPage
//    eine NotebookPage WEITER
//=========================================================================
sub NextPage(aNB  : int)
local begin
  vCur  : int;
  vPage : int;
  vTmp  : int;
  vI    : int;
end;
begin
  if (aNB=0) then RETURN;
  aNB->wpOrderPass # _WinOrderShow;

  vCur # Winsearch(aNB, aNB->wpCurrent);
  if (vCur=0) then RETURN;
  
  // nächste AKTIVE Seite suchen...
/***/
  FOR vPage # WinInfo(vCur, _winnext, 1, _WintypeNotebookPage)
  LOOP vPage # WinInfo(vPage, _winnext, 1, _WintypeNotebookPage)
  WHILE (vPage<>0) do begin
    if (vPage->wpvisible) and (vPage->wpDisabled=false) and (IsPageActive(vPage->wpname)) then BREAK;
  END;
/***
  vI # cnvia(vCur->wpName) + 1;
  vPage # Winsearch(aNB, 'NB.Page'+aint(vI));
  // deaktivierte überspringen!
  WHILE (vPage<>0) and ((vPage->wpvisible=false) or (vPage->wpDisabled)) do begin
    inc(vI);
    vPage # Winsearch(aNB, 'NB.Page'+aint(vI));
  END;
***/

  // KEINE weitere Seite?
  if (vPage=0) then begin

    // -> ZUR 1. Wechseln mit Name "NB.Page*"
    FOR vPage # WinInfo(aNB, _winFirst, 1, _WintypeNotebookPage)
    LOOP vPage # WinInfo(vPage, _winNext, 1, _WintypeNotebookPage)
    WHILE (vPage<>0) do begin
      // nur AKTIVE...
      if (vPage->wpvisible=false) or (vPage->wpDisabled) or (IsPageActive(vPage->wpname)=false) then CYCLE;

      if (StrCut(vPage->wpname,1,7)=^'NB.PAGE') then BREAK;
    END;
  end;
  
  if (vPage<>0) then begin
    aNB->wpCurrent # vPage->wpname;
  end;
  
  if (Mode=c_ModeView) then begin
    vTmp # gMdi->winsearch('Edit');
    if (vtmp->wpdisabled) then
      if (gMdi->winsearch('EditErsatz')<>0) then
        vTmp # gMdi->winsearch('EditErsatz');
    vTmp->WinFocusSet(false);
  end;
  
  RETURN; // OK
end;


//=========================================================================
//  PrevPage
//    eine NotebookPage VOR
//=========================================================================
sub PrevPage(aNB : int)
local begin
  vCur  : int;
  vPage : int;
  vTmp  : int;
  vI    : int;
end;
begin
  if (aNB=0) then RETURN;
  aNB->wpOrderPass # _WinOrderShow;

  vCur # Winsearch(aNB, aNB->wpCurrent);
  if (vCur=0) then RETURN;
  
  // vorherige AKTIVE Seite suchen...
/***/
  FOR vPage # WinInfo(vCur, _winprev, 1, _WintypeNotebookPage)
  LOOP vPage # WinInfo(vPage, _winprev, 1, _WintypeNotebookPage)
  WHILE (vPage<>0) do begin
// 26.05.2020 AH    if ((StrCut(vPage->wpname,1,7)=^'NB.PAGE')=false) then CYCLE;
    if (vPage->wpvisible) and (vPage->wpDisabled=false) and (IsPageActive(vPage->wpname)) then BREAK;
  END;
/***
  vI # cnvia(vCur->wpName) - 1;
  vPage # Winsearch(aNB, 'NB.Page'+aint(vI));
  // deaktivierte überspringen!
  WHILE (vI>1) and (vPage<>0) and ((vPage->wpvisible=false) or (vPage->wpDisabled)) do begin
    dec(vI);
    vPage # Winsearch(aNB, 'NB.Page'+aint(vI));
  END;
***/
  // KEINE vorherige Seite?
  if (vPage=0) then begin
    // -> ZUR LETZEN Wechseln mit Name "NB.Page*"
    FOR vPage # WinInfo(aNB, _winLast, 1, _WintypeNotebookPage)
    LOOP vPage # WinInfo(vPage, _winPrev, 1, _WintypeNotebookPage)
    WHILE (vPage<>0) do begin

      // nur AKTIVE...
      if (vPage->wpvisible=false) or (vPage->wpDisabled) or (IsPageActive(vPage->wpname)=false) then CYCLE;

      if (StrCut(vPage->wpname,1,7)=^'NB.PAGE') then BREAK;
    END;
  end;
  if (vPage<>0) then begin
    aNB->wpCurrent # vPage->wpname;
  end;

  if (Mode=c_ModeView) then begin
    vTmp # gMdi->winsearch('Edit');
    if (vtmp->wpdisabled) then
      if (gMdi->winsearch('EditErsatz')<>0) then
        vTmp # gMdi->winsearch('EditErsatz');
    vTmp->WinFocusSet(false);
  end;
  
  RETURN; // OK
end;


//=========================================================================
//  JumperEvtFocusInit
//      speziell für "Jumper" von NotebookPage zu NoteBookPage
//=========================================================================
sub JumperEvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vPage : alpha;
  vHdl  : int;
  vTyp  : int;
end;
begin
//debug('JUMP '+aEvt:obj->wpcustom);
//if (aFocusObject<>0) then begin
//debug('von '+aFocusObject->wpname);
//  if (aFocusObject->wpname='jumpfix') then RETURN true;
//end;

  if (mode=c_ModeView) then RETURN true;
  
  vPage # Str_Token(aEvt:Obj->wpcustom, '|',1 );
  if (vPage='') then RETURN false;
  vHdl # Winsearch(gMDI, Str_Token(aEvt:Obj->wpcustom, '|',2));
  if (vHdl=0) then RETURN false;

  if (aFocusObject<>0) then aFocusObject->winfocusset(false);

  WHILE (vHdl<>0) do begin
    vTyp # Wininfo(vHdl,_Wintype);
//debug('typ='+aint(vtyp)+' '+vHdl->wpname);
    if (vTyp=_wintypeedit) or (vTyp=_wintypeintedit) or (vTyp=_wintypefloatedit) or
      (vTyp=_wintypeDateedit) or (vTyp=_wintypetextedit) or (vTyp=_wintypetimeedit) or (vTyp=_WinTypeCheckbox) or
      (vTyp=_WinTypeCheckbox) or (vTyp=_WinTypeButton) or (vTyp=_WinTypeRtfEdit) or (vTyp=_WinTypeColorButton) or
       (vTyp=_WinTypeRadioButton) then begin
       if (vHdl->wpdisabled=false) and (vHdl->wpReadonly=false) then BREAK;
    end;
   
//debugx(vHdl->wpname+' ist diSS');
    vHdl # WIninfo(vHdl, _winnext);
  END;

  if (vHdl<>0) then begin
//debug('foc '+(vHdl->wpName));
    $NB.Main->wpcurrent(_WinFlagnoFocusSet) # vPage;
    vHdl->WinFocusSet(false);
  end;
  
  RETURN true;

end;


//=========================================================================
//=========================================================================
//=========================================================================