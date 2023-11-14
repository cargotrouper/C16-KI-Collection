@A+
//==== Business-Control ==================================================
//
//  Prozedur    L_Rso_WartungenDerKW
//                    OHNE E_R_G
//  Info
//
//
//  05.11.2003  AI  Erstellung der Prozedur
//
//
//========================================================================

@I:Def_Global

main

  local begin
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

  vKW         : word;
  vJahr       : word;
end;
begin
  vKW # 44;
  vJahr # 1900+dateyear(SysDate());
  if (Dlg_Standard:KWJahr('Wartungen für KW:',var vKW, var vJahr)=n) then RETURN;

  // Vorgaben
  vFile     # 160;
  vKey      # 1;
  vName     # 'FÄLLIGE WARTUNGEN FÜR KW:'+AInt(vKW)+'/'+AInt(vJahr);
  vQuer     # false;
  vMyPos    # 'Lst.Rso.WartungenDerKWPos';
  vMyKopf   # 'Lst.Rso.WartungenDerKWKopf';
  vMyFuss   # '';//'Lst.Rso.Grp.InventarFuss';

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
    if (vLabel <> 0) then vLabel->wpCaption # AInt(vseite);

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

      WHILE (RecRead(165,1,vFlags)<=_rLocked) do begin
        vFlags # _RecNext;

        if (Rso.IHA.WartungYN=n) then CYCLE;
        if (Rso.IHA.TerminJahr>vJahr) then CYCLE;
        if (Rso.IHA.TerminJahr=vJahr) and
          (Rso.IHA.TerminKW>vKW) then CYCLE;

        // Objekte der PrintForm hinzufügen
        // gegebenenfalls automatischen Seitenvorschub erzeugen
        vForm # PrtFormOpen(_PrtTypePrintForm,vMyPos);
        vAddSize # vPage->ppBoundAdd;
        vMaxSize # vPage->ppBoundMax;
        If (vAddSize:y + vForm->ppFormHeight > vMaxSize:y) then begin
          vForm->prtformclose();
          vSeite # vSeite + 1;
          vPage # vJob->PrtJobWrite(_PrtJobPageBreak)
          vLabel # vKopf->PrtSearch('lb.SeiteNr');
          if (vLabel <> 0) then vLabel->wpCaption # AInt(vSeite);

          vPage->PrtAdd(vKopf,0);

          if (vMyKopf<>'') then begin
            vForm # PrtFormOpen(_PrtTypePrintForm,vMyKopf);
            vPage->PrtAdd(vform,0);
            vForm->prtformclose();
          end;

          vForm # PrtFormOpen(_PrtTypePrintForm,vMyPos);
        end;

        RecLink(823,165,2,0); // Meldung holen
        Rso.Nummer #Rso.IHA.Ressource;
        Rso.Gruppe # Rso.IHA.Gruppe;
        Recread(160,1,0);     // Resource holen
        vPage->PrtAdd(vForm,_PrtAddPageBreak)
        vForm->prtformclose();
      END;

      vKopf->prtformclose();

      if (vMyFuss<>'') then begin
        vForm # PrtFormOpen(_PrtTypePrintForm,vMyFuss);
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
//========================================================================
