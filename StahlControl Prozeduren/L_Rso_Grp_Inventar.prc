@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Rso_Grp_Inventar
//                    OHNE E_R_G
//  Info
//
//  2022-06-28  AH  ERX

/*****************************************************************/
/*                                                               */
/*  Drucken von Listen - automatischer Seitenumbruch             */
/*                                                               */
/*****************************************************************/

/*****************************************************************/
/*                                                               */
/*  main - Durchführen des Druckjobs                             */
/*                                                               */
/*****************************************************************/
//
//  Subprozeduren
//    SUB AusGruppe()
//================================================================
@I:Def_Global

main
begin
  RecBufClear(822);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Grp.Verwaltung','L_Rso_Grp_Inventar:AusGruppe');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
local begin
  Erx       : int;
  vSeite    : int;
  vJob      : int;          // Job-Deskriptor
  vFrame    : int;          // Preview-Dialog Deskriptor
  vDoc      : int;          // PrintDocument Deskriptor
  vKopf     : int;

  vForm     : int;          // PrintForm Handle

  vMyFuss   : Alpha;
  vMyKopf   : Alpha;
  vMyPos    : Alpha;        // zu Druckendes Element

  vLabel    : int;
  vQuer     : logic;
  vPage     : int;          // Page-Deskriptor
  vFlags    : int;          // Datensatz Leseflags
  vDevice   : int;          // Drucker-Device
  vFont     : font;
  vFile     : int;          // Datei
  vKey      : int;          // Schlüssel
  vName     : alpha;        // Name der Liste
  vAddSize  : point;
  vMaxSize  : point;
  vSum1     : float;
end;
begin
  // Zugriffliste wieder aktivieren
  gZlList->wpdisabled # false;
  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(cDialog,true);
  Mode # c_modeList;
  if (gSelected<>0) then begin
    RecRead(822,0,_RecId,gSelected);
    // Feldübernahme
    gSelected # 0;
  end;

  // Vorgaben
  vFile     # 160;
  vKey      # 1;
  vName     # 'INVENTARVERZEICHNIS:'+AInt(Rso.Grp.Nummer)+' '+Rso.Grp.Bezeichnung//;Translate('testme');
  vQuer     # false;
  vMyPos    # 'Lst.Rso.Grp.InventarPos';
  vMyKopf   # 'Lst.Rso.Grp.InventarKopf';
  vMyFuss   # 'Lst.Rso.Grp.InventarFuss';

  vSeite    # 1;
  // Temporären Druckjob öffnen (PrintDocument DinA4, leer)
  vJob # PrtJobOpen(_PrtDocDinA4,'',_PrtJobOpenWrite | _PrtJobOpenTemp, _PrtTypePrintDoc);
  if (vJob > 0) then begin

    // Preview-Dialog initialisieren
    vFrame # vJob->PrtInfo(_PrtFrame);
    if (vFrame > 0) then begin
      vFrame->wpCaption # vName + ' ' + Translate('drucken...');
      vFrame->wpArea    # RectMake(20,20,WinInfo(0,_WinScreenWidth)-40,WinInfo(0,_WinScreenHeight)-60);
      vFrame->WinUpdate(_WinUpdState,_WinDialogMaximized);
    end;

    // PrintDocument ermitteln
    vDoc # vJob->PrtInfo(_PrtDoc);
    if (vDoc > 0) then begin
      vDoc->ppZoomFactor  # 100;
      vDoc->ppRuler # _PrtRulerNone;
      If vquer then vDoc->ppOrientation # _PrtOrientLandscape
      else          vDoc->ppOrientation # _PrtOrientPortrait;
      vDoc->ppName        # vName;
    end;

    // PrintForm laden (nur einmal!)
    vKopf # PrtFormOpen(_PrtTypePrintForm,'LST.Ueberschrift');
    vLabel # vKopf->PrtSearch('lb.Ueberschrift');
    If (vLabel <> 0) then vLabel->wpCaption # vName
    vLabel # vKopf->PrtSearch('lb.SeiteNr');
    if (vLabel <> 0) then vLabel->wpCaption # CnvAI(vseite);

    // vForm # PrtFormOpen(_PrtTypePrintForm,vMyPos);
    // Erste Seite ankündigen
    vPage # vJob->PrtJobWrite(_PrtJobPageStart);
    if (vPage > 0) then begin

      vPage->wpColFg # _WinColBlack;

      // Erster Datensatz
      vFlags # _RecFirst;

      vPage->PrtAdd(vKopf,0);

      if (vMyKopf<>'') then begin
        vForm # PrtFormOpen(_PrtTypePrintForm,vMyKopf);
        vPage->PrtAdd(vform,0);
        vForm->prtformclose();
      end;

      // Alle Einträge der Datei lesen
      WHILE (RecRead(vFile,vKey,vFlags) < _rNoRec) DO BEGIN
        // Nächster Datensatz
        vFlags # _RecNext;

        // Objekte der PrintForm hinzufügen
        // gegebenenfalls automatischen Seitenvorschub erzeugen
        if (Rso.Gruppe<>Rso.Grp.Nummer) then CYCLE;

        vForm # PrtFormOpen(_PrtTypePrintForm,vMyPos);
        vAddSize # vPage->ppBoundAdd;
        vMaxSize # vPage->ppBoundMax;
        If (vAddSize:y + vForm->ppFormHeight > vMaxSize:y) then begin
          vForm->prtformclose();
          vSeite # vSeite + 1;
          vPage # vJob->PrtJobWrite(_PrtJobPageBreak)
          vLabel # vKopf->PrtSearch('lb.SeiteNr');
          if (vLabel <> 0) then vLabel->wpCaption # CnvAI(vSeite);

          vPage->PrtAdd(vKopf,0);

          if (vMyKopf<>'') then begin
            vForm # PrtFormOpen(_PrtTypePrintForm,vMyKopf);
            vPage->PrtAdd(vform,0);
            vForm->prtformclose();
          end;

          vForm # PrtFormOpen(_PrtTypePrintForm,vMyPos);
        end;

        Erx # RecLink(100,160,4,0);   // Hersteller holen
        if (Erx>_rlocked) then RecbufClear(100);

        vPage->PrtAdd(vForm,_PrtAddPageBreak)
        vForm->prtformclose();

        vSum1 # vSum1 + Rso.LeistungKWatt;
      END;

      vKopf->prtformclose();

      if (vMyFuss<>'') then begin
        vForm # PrtFormOpen(_PrtTypePrintForm,vMyFuss);
        vLabel # vForm->PrtSearch('lb.Sum1');
        vLabel->wpcaption # ANum(vSum1,2);
        vPage->PrtAdd(vform,0);
        vForm->prtformclose();
      end;

      // Letzte Seite geschrieben
      vJob->PrtJobWrite(_PrtJobPageEnd);

    end;

    // Druckjob schliessen und Preview anzeigen
    vJob->PrtJobClose(_PrtJobPreview);

  end; // (vJob > 0)


end;   // main