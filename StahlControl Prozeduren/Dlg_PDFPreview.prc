@A+
//===== Business-Control =================================================
//
//  Prozedur  Dlg_PDFPreview
//                  OHNE E_R_G
//  Info
//
//
//  26.03.2013  AI  Erstellung der Prozedur
//  10.02.2014  AH  Querformat PDFs rotieren über vW>vH
//  27.02.2015  ST  Zu Druckendens PDF Objekt interpretiert Text als Curves Projekt 1512/23
//  25.03.2015  ST  Druckerauswahl/Seiteneingrenzung (z.B. Seite 4-6) hinzugefügt Projekt 1373/16
//  12.05.2015  AH  EMail-Funktion : Fiename als neues Argument
//  10.06.2015  AH  Papierformat wird besser beachtet
//  29.06.2015  ST  Button zum Kopieren der Faxnummer hinzugefügt
//  29.03.2016  ST  Seitennavi +- nur im Bereich der vorhanden Seiten möglich nicht mehr z.B. 9/1
//  03.07.2017  AH  BugFix: Varfree(Class_Form) nur wenn selber auch instanziert hat!
//  21.12.2017  ST  BugFix: Bei Druck auf CAB Drucker keine Dokumentendrehung anhand der Abmessung
//  05.06.2018  ST  BugFix: Bei Druck auf SATO (ähnlich CAB) Drucker keine Dokumentendrehung anhand der Abmessung
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  21.03.2019  ST  Afx "Dlg_PDFPreview.ShowPDF" hinzugefügt Projekt 1962/3
//  17.06.2020  AH  "Print" und "DirektDruck" nutzen beide "_PrintInner"
//  27.01.2022  AH  AutoSchließen per Setting
//  09.06.2022  DS  In ShowPDF() Länge von Argument aPath erhöht
//  22.06.2022  ST  Fehlermeldung bei falschen Papierformaten
//  28.06.2022  TM  Übersteuerung Papierformat für CAB Squix-Drucker, muss immer CUSTOM sein. Prj. 2151/220
//  02.09.2022  ST  Customwege für LZM nur bei Installname "LZM"
//
//  Subprozeduren
//    SUB ShowPDF(aPath : alpha; aName : alpha; aPrinter : int; aKopien : int; aEMA : alpha(1000); aFAX : alpha(1000); opt aName : alpha);
//    SUB _PrintInner(opt aPath  : alpha(4000); opt aKopien : int; opt aPrinter : alpha(4000); opt aDev : int; opt aSchacht : alpha(4000)) : logic;
//    SUB Print(opt aDev : int) : logic;
//    SUB Outlook(opt aEMA : alpha(500);opt aSubject : alphA) : logic;
//    SUB EMAIL(opt aEMA : alpha(500); opt aSubject : alphA) : logic;
//    SUB FAX(opt aFAX : alpha(500); opt aSubject : alpha) : logic;

//    SUB UpdateZoom();

//    SUB RefreshIfm();
//    SUB EvtInit(aEvt : event) : logic;
//    SUB EvtCreated(aEvt : event) : logic;
//    SUB EvtPosChanged(aEvt : event; aRect : rect; aClientSize : point; aFlags : int) : logic;
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic;
//    SUB EvtClose(aEvt : event) : logic;
//
//    SUB DirekterDruck(aPath : alpha(4000); aKopien : int; aPrinter : alpha(4000); aDev : int; aSchacht : alpha(4000)) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cView     : $DocView1
  cZoomStep : 25
end;

//========================================================================
//  ShowPDF
//
//========================================================================
sub ShowPDF(
  aPath     : alpha(1024);
  aIstForm  : logic;
  aEMA      : alpha(4000);
  aFAX      : alpha(1000);
  aPrinter  : int;
  aKopien   : int;
  opt aName : alpha(1000)
  ) : logic;
local begin
  vName : alpha(1000);
  //vEMA  : alpha(1000);
  //vFAX  : alpha(1000);

  vWait : int;
  vHdl  : int;
  vHdl2 : int;
  vPDF  : int;
  vA    : alpha(1000);
  vPage : int;
  vRot  : int;
  vH    : float;
  vW    : float;
  vOpt  : int;
  
  vPara    : alpha(4000);
end;
begin
  vPara # aPath                   + '|' +
          Aint(CnvIL(aIstForm))   + '|' +
          aEMA                    + '|' +
          aFAX                    + '|' +
          Aint(aPrinter)          + '|' +
          Aint(aKopien)           + '|' +
          aName;
  if (RunAFX('PrintPreview.ShowPDF',vPara)<0) then
    RETURN (AfxRes = _rOK);
 

  REPEAT
    vPDF # PdfOpen(aPath);
    if (vPDF<0) then begin
      inc(vWait);
      if (vWait>20) then RETURN false;
      Winsleep(500);
    end;
  UNTIL (vPDF>0);

  vName # vPDF->spPdfTitle;
  if (aName<>'') then vName # aName;
  //vA    # vPDF->spPdfKeywords;
  //vEMA  # Str_Token(vA,'|',1);
  //vFAX  # Str_Token(vA,'|',2);
  if (PdfPageOpen(vPdf ,1)=0) then begin
    vRot # vPdf->spPdfPageRotation;
    PdfPageClose(vPdf, _PdfPageCloseCancel);
  end;
  vW # vPdf->spPdfPageWidth;
  vH # vPdf->spPdfPageHeight;
  PDFClose(vPDF);


  vHdl # WinOpen('Frame.PDFPreview',_WinOpenDialog);
  // pjp.preview
  vHdl2 # Winsearch(vHdl,'DocView1');
  vHdl2->wpFileName # '*'+aPath;
  vHdl2->wpcustom  # aint(aPrinter)
  if (aFAX<>'') then begin
    vHdl2 # Winsearch(vHdl,'lb.FAX2');
    vHdl2->wpvisible # true;
    vHdl2 # Winsearch(vHdl,'lb.FAX');
    vHdl2->wpvisible # true;
    vHdl2->wpcaption # aFax;
  end;
  if (aEMA<>'') then begin
    vHdl2 # Winsearch(vHdl,'lb.EMA2');
    vHdl2->wpvisible # true;
    vHdl2 # Winsearch(vHdl,'lb.EMA');
    vHdl2->wpvisible # true;
    vHdl2->wpcaption # aEMA;
  end;
  vHdl2 # Winsearch(vHdl,'lb.SUBJECT');
  vHdl2->wpcaption # vName;
  vHdl2 # Winsearch(vHdl,'lb.Rotation');
  vHdl2->wpcaption # aint(vRot);
  vHdl2 # Winsearch(vHdl,'lb.Height');
  vHdl2->wpcaption # anum(vH,3);
  vHdl2 # Winsearch(vHdl,'lb.width');
  vHdl2->wpcaption # anum(vW,3);
  vHdl2 # Winsearch(vHdl,'ieKOPIEN');
  vHdl2->wpcaptionint # aKopien;
  vHdl->wpcaption # Translate('Druckvorschau')+' '+vName;

  vHdl2 # Winsearch(vHdl,'bt.FAX');
  if (Rechte[Rgt_Print_FAX]=false) then Lib_GuiCOm:Disable(vHdl2);
  if (Set.FAX.Printer<>'') or (Set.FAX.OutPutProc<>'') then
    vHdl2->wpvisible # true;

  vHdl2 # Winsearch(vHdl,'bt.EMAIL');
  if (Rechte[Rgt_Print_EMAIL]=false) then Lib_GuiCOm:Disable(vHdl2);
  if (Set.EMAIL.Printer<>'') or (Set.EMAIL.OutPutProc<>'') then
    vHdl2->wpvisible # true;

  vHdl2 # Winsearch(vHdl,'bt.PDF');
  if (Rechte[Rgt_Print_PDF]=false) then Lib_GuiCOm:Disable(vHdl2);

  vHdl2 # Winsearch(vHdl,'bt.OUTLOOK');
  if (Rechte[Rgt_Print_Outlook]=false) then Lib_GuiCOm:Disable(vHdl2);

  vHdl2 # Winsearch(vHdl,'bt.PRINT.CHOOSE');
  if (Rechte[Rgt_Print_Druckerwechsel]=false) then Lib_GuiCOm:Disable(vHdl2);


  vHdl2 # Winsearch(vHdl,'lb.FormYN');
  if (aIstForm) then
    vHdl2->wpcaption # 'true';
  else
    vHdl2->wpcaption # 'false';

  //Probleme, wenn Druckauswahldialog genutz wird, dann APPOFF und hier APPON
  if (winfocusget()=0) and (Set.DruckVS.imHGrund) then
    vOpt # _WinDialogcreatehidden | _WinDialogMaximized | _WinDialogNoActivate
  else
    vOpt # _WinDialogcreatehidden | _WinDialogMaximized;

  if (gFrmMain<>0) then
    WinDialogRun(vHdl, vOpt, gFrmMain)
  else
    WinDialogRun(vHdl, vOpt);

  WinClose(vHDL);

  RETURN true;
end;


//========================================================================
// _PrintInner
//        entweder vorhandes PDF drucken (aPath gefüllt) oder sonst aus Vorschau
//========================================================================
sub _PrintInner(
  opt aPath     : alpha(4000);    // bei Direktdruck gibt es schon ein PDF
  opt aKopien   : int;
  opt aPrinter  : alpha(4000);
  opt aDev      : int;
  opt aSchacht  : alpha(4000);
) : logic;
local begin
  vPath               : alpha(1000);
  vB                  : alpha(1000);
  vDir                : int;
  vDatei              : int;
  vErr                : int;
  vPrtJob             : int;
  vDok                : int;
  vOK                 : logic;
  vI                  : int;

  
  vSchachtMsg         : alpha(1000);
  vSchachtCntMsg      : alpha(1000);
  vPaperWidthMsg      : alpha(1000);
  vPaperHeightMsg     : alpha(1000);
  vAnkerPara          : alpha(1000);
  vCounter            : int;
  vPrtBinId           : int;
  vBinCount           : int;
  vPrtBinName         : alpha(1000);
  vHeaderMsg          : alpha(1000);
  vPrintDevice        : int;
  
  vJob                : alpha(1000);
  vDev                : int;
  vPdfHdl             : int;
  vDlg                : int;
  vName               : alpha;
  vLocal              : logic;

  vPrt                : int;
  vRect               : rect;

  vRot                : int;
  vH                  : float;
  vW                  : float;
  vPapierH            : float;
  vPapierW            : float;
  vPapFormat          : alpha;
  vX,vY               : float;
  vDoc                : int;
  vPrinterList        : int;
  vPrinter            : int;
  

  vPageFrom           : int;
  vPageTo             : int;
  vPageCnt            : int;

  vBound              : point;
  vPages              : int;
  vOffsetX            : float;
  vPagi               : logic;
  vMyClassForm        : logic;

  visCAB              : logic;
  vPDF                : int;
  
  vAnkerParameter     : alpha(1000);
  Erx                 : int;
end;
begin


  //2023-08-01 MR Anker um die innerPrint auszuhebeln. Folgendes CodeSnippet kann dabei zum als alternative
  //              Druckroutine genutzt werden:
  //--------------------------------------------------------------------------------------------------------------
      //Device anlegen & konfigurieren
      //vDev # PrtDeviceOpen(aPrinter,_PrtDeviceSystem);
      //vDev->ppcopies  # 1;
      ////vDev->ppCollate # _PrtCollateOn;
      //
      ////Druckjob öffnen
      //vTest    # PrtJobOpen('STD_Etikett2x2', '', _PrtJobOpenWrite | _PrtJobOpenTemp)
      ////DruckJob schreiben
      //vRot   # vTest->PrtJobWrite(_PrtJobPageStart);
      //
      ////Print Dokument in PdfForm containern
      //vPrt  # PrtFormOpen(_PrtTypePrintForm,'PdfForm');
      //vPdfHdl  # PrtSearch(vPrt,'PrtPdf0');
      //vPdfHdl->ppFileName # vJob;
      //vTest->PrtJobWrite(_PrtJobPageBreak);
      //vRot->PrtAdd(vPrt,_PrtAddTop);
      //vPrt->PrtFormClose();
      //
      ////Drucken...
      //Erx # vTest->PrtJobClose(_PrtJobPrint, vDev);
      //Return true;
  //--------------------------------------------------------------------------------------------------------------
  
//  vAnkerParameter # strcut(aPath + '|' + aint(aKopien) + '|' + aPrinter + '|' + aint(aDev) + '|' + aSchacht,1,1000);
//  if (RunAFX('Print.Inner', vAnkerParameter ) = 0) then
//    RETURN true;
//  else RETURN false;

  
  vName # ''

//aDev # -2;  // ZUM DEBUGGE: C16 INTERNE VORSCHAU

  if (aPath='') then begin            // aus Vorschau?
    vJob    # cView->wpFilename;
    vName   # $lb.SUBJECT->wpcaption;
    aKopien # $ieKOPIEN->wpcaptionint;
  end
  else begin                          // aus Direktdruck?
    vJob # '*'+aPath;
  end;

  if (aKopien=0) then aKopien # 1;

  // PDF-Infos auslesen
  if (aPath<>'') then begin
    vPDF # PdfOpen(aPath);
    if (vPDF<0) then RETURN false;
    vName # vPDF->spPdfTitle;
    if (PdfPageOpen(vPdf ,1)=0) then begin
      vRot # vPdf->spPdfPageRotation;
      PdfPageClose(vPdf, _PdfPageCloseCancel);
    end;
    vW # vPdf->spPdfPageWidth;
    vH # vPdf->spPdfPageHeight;
    PDFClose(vPDF);
  end
  else begin
    vRot  # cnvia($lb.Rotation->wpcaption);
    vW    # cnvfa($lb.Width->wpcaption);
    vH    # cnvfa($lb.Height->wpcaption);
  end;
  


  vDev # aDev;
  if (vDev<=0) and (aPrinter<>'') then begin
    vDev # PrtDeviceOpen(aPrinter,_PrtDeviceSystem);
    vLocal # y;
  end;

  // aDev = -1 = STANDARD
  // kein Printerdevice angegeben? -> dann jetzt abfragen...
  if (vDev<=0) then begin
    vDev # PrtDeviceOpen();
    vDev->ppcopies  # aKOPIEN;
    vDev->ppCollate # _PrtCollateOn;

    if (aDev=0) then begin
      vDlg # WinOpen(_WinComPrint,0,vDev);

      if (aPath='') then begin
        // von/bis Seite
        vDlg->wpMinInt    # 1;
        vDlg->wpMaxint    # cView->wpPagecount;
        vDlg->wppageFrom  # 1;
        vDlg->wppageTo    # vDlg->wpMaxInt;
      end;

  //    vDlg->wpflags   # _WinComPrintPageRange;
      if (WinDialogRun(vDlg)=_WinIdCancel) then begin
        Winclose(vDlg);
        PrtDeviceclose(vDev);
        RETURN false;
      end;

      vPageFrom # vDlg->wppageFrom;
      vPageTo   # vDlg->wppageTo;
      if (vDLG<>0) then WinClose(vDlg);
      vDlg # 0;
    end;
    vLocal # y;
  end
  else begin
    vDev->ppcopies # aKOPIEN;
    vDev->ppCollate # _PrtCollateON;
    if (aSchacht<>'') then
      vDev->ppbinsource # cnvia(aSchacht);
  end;

  if (vDev<=0) then begin
Msg(99,'FEHLER!',0,0,0);
    RETURN false;
  end;

  
  // ST 2017-12-21: Bei CAB Druckern für Etikettendruck nichts drehen
  visCAB # ((StrFind(vDev->ppNamePrinter,'CAB',1) > 0) OR (StrFind(vDev->ppNamePrinter,'SATO',1) > 0) OR
           (StrFind(vDev->ppNamePrinter,'TSC',1) > 0) OR (StrFind(vDev->ppNamePrinter,'NOROT',1) > 0));
  
  if (Set.Installname = 'LZM') then begin
    if  (StrFind(vDev->ppNamePrinter,'Squix',1) > 0) then
      vIsCAB # true;
  end;
  
    
  if (visCAB = false) then begin
    if (vW>vH) then begin
      vX # vW;
      vW # vH;
      vH # vX;
      vRot # vRot + 90;
    end
    else if (vRot=90) or (vRot=270) then begin
      vX # vW;
      vW # vH;
      vH # vX;
    end;
  end;


  // Job starten...
//Lib_Print:FrmJobOpen(y,0,0,n,n,n,'DinA4OhneRand', 'FALSE');
  if (VarInfo(class_Form)=0) then begin
    VarAllocate(class_Form);
    vMyClassForm # true;
  end;
  Form_isForm # true;

//debugx(aint(vRot)+'º '+aNum(vW,2)+'/'+anum(vH,2));
  if (Abs(vW - 210.0) < 2.0) and (Abs(vH - 297.0) < 2.0) then begin
//debugx('Dina4');
    vPapFormat # _PrtDocDina4;
  end
  else if (Abs(vW - 148.3) < 4.0) and (Abs(vH - 210.0) < 2.0) then begin
//debugx('Dina5');
    vPapFormat # _PrtDocDina5;
  end
  else if (Abs(vW - 210.0) < 2.0) and (vH > 400.0) then begin // DinA4 paginiert
//debugx('Dina4 paginieren');
    vPapFormat  # _PrtDocDina4;
    vPagi       # true;
  end
  else begin
    vPapFormat # 'CUSTOM';
  end;

  if (Set.Installname = 'LZM') then begin
    if (Str_Contains(Frm.Style,'Etikett')) then
      vPapFormat # 'CUSTOM';
  end;
  
  
  if (vPapFormat<='CUSTOM') then
    form_Job    # PrtJobOpen('DinA4OhneRand', '', _PrtJobOpenWrite | _PrtJobOpenTemp)
  else
    form_Job    # PrtJobOpen(vPapFormat, '', _PrtJobOpenWrite | _PrtJobOpenTemp);

  // Doc anpassen...
  vDoc # PrtInfo(Form_job, _PrtDoc);
// 2023-07-27 AH HIER PPNAME ÄNDERN

  if (vW>1000.0) then vW # 1000.0;
  if (vH>1000.0) then vH # 1000.0;
  // wenn Client aälter als 5.7.10i dann nur 22inch Größe
  vI # DbaInfo(_DbaClnRelMaj)*1000+(DbaInfo(_DbaClnRelMin)*100)+(DbaInfo(_DbaClnRelrev));
  if (vI<5710) or ((vI=5710) and (StrChar(DbaInfo(_DbaClnRelSub))<'i'))then begin
    if (vW>540.0) then vW # 540.0;
    if (vH>540.0) then vH # 540.0;
  end;

  if (vPapFormat='CUSTOM') then begin
    vDoc->ppPageWidth   # PrtUnitLog(vW,_PrtUnitMillimetres);
    vDoc->ppPageHeight  # PrtUnitLog(vH,_PrtUnitMillimetres);
  end;

  vPapierW # PrtUnit(vDoc->PpPageWidth, _PrtUnitMillimetres);
  vPapierH # PrtUnit(vDoc->PpPageHeight, _PrtUnitMillimetres);

  if (vRot=90) or (vRot=180) then begin
    vDoc->ppOrientation # _PrtOrientLandscape;
    vX # vW;
    vW # vH;
    vH # vX;
  end
  else begin
    vDoc->ppOrientation # _PrtOrientPortrait;
  end;
  // Der ECHTE Druck soll nur DinA4 = 210 x 297mm sein
//  if (vDruckW>210.0) then vDruckW # 210.0;
//  if (vDruckH>297.0) then vDruckH # 297.0;
//debugx('w/h: '+anum(vW,0)+'/'+anum(vH,0));

  form_page   # form_Job->PrtJobWrite(_PrtJobPageStart);

  vPrt  # PrtFormOpen(_PrtTypePrintForm,'PdfForm');
  vPdfHdl  # PrtSearch(vPrt,'PrtPdf0');
  if (vPdfHdl<>0) then begin
    vPdfHdl->ppautosize  # true;
    vPdfHdl->ppPrintMode # _PrtPrintModeTextAsCurves;    // ST 2015-02-27: Projekt 1512/23

    vPdfHdl->ppFileName # vJob;
    vPageCnt # 0;
    FOR vI # 1 loop inc(vI) while (vI<=vPdfHdl->ppPagecount) do begin

      if (vPageFrom <> 0) AND (vPageTo <> 0) then begin
        if (vI < vPageFrom) OR (vI > vPageTo) then
          CYCLE;
      end;

      vOffSetX # 0.0;
      REPEAT
        vBound   # Form_Page->ppBoundMax;
        vBound:x # PrtUnitLog(vW,_PrtUnitMillimetres);
        vBound:y # PrtUnitLog(vH,_PrtUnitMillimetres);

        vRect # vPdfHdl->pparea;
        vRect:top     # 0;
        vRect:left    # PrtUnitLog(-vOffSetX,_PrtUnitMillimetres);
        vRect:right   # PrtUnitLog(vW-vOffsetX,_PrtUnitMillimetres);
        vRect:Bottom  # PrtUnitLog(vH,_PrtUnitMillimetres);
        vPdfHdl->ppArea # vRect;

        if (vRot=90) or (vRot=180) then
          vOffsetX # vOffSetX + vPapierH
        else
          vOffsetX # vOffSetX + vPapierW;

        if (vPageCnt>0) then
          form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);
        inc(vPageCnt);

        Form_Page->ppAreaMarginleft   # 0;
        Form_Page->ppAreaMarginTop    # 0;
        Form_Page->ppAreaMarginRight  # 0;
        Form_Page->ppAreaMarginBottom # 0;
        vPdfHdl->ppcurrentint # vI;

        form_Page->PrtAdd(vPrt,_PrtAddTop);
      UNTIL (vOffsetX>=vW) or (vPagi=false);

    END;
  end;

  vPrt->PrtFormClose();

  // Job ausgeben
  if (aDev=-2) then begin
    Erx # form_Job->PrtJobClose(_PrtJobPreview);
    if (Erx < 0) then begin
      MsgErr(912009,'Vorschau konnte nicht gestartet werden');
    end;
    
  end
  else begin
    Erx # form_Job->PrtJobClose(_PrtJobPrint,vDev);
    if (Erx <> _ErrOK) then begin
  
      if (Erx = _ErrPrtPaperFormat) then begin
        // ST 2022-06-22
        //2023-06-12 MR Ergänzung
        // TODO: Hier sinnige Hilfe zu Papierformaten generieren:
        // a) Wie heißt der eingestellte Drucker? Möglicherweise hilft es den Drucker einmal zu entfernen und dann nochmal als Druckername = NOROT einzurichten
        // b) Was soll gedruckt werden  -> Abmessungen aus Dokument, Ausrichtung, etc.
        // c) Was kann der angewählte Drucker? Hier kann man als Test den Druck in SC ausführen hierzu muss evt im Zusatztext des Formulars n;y;Druckername;@AH@MR@ hinterlegen
        // d) Bei manchen Druckern kann es vorkommen, dass das DruckDokument exakt die Größe haben muss wie in den Druckereinstellungen hinterlegt
        MsgErr(912009,'Papierformat für den gewählten Drucker ungültig.');
        
       //2023-08-01 MR Zur besseren Fehleranalyse des eingesetzten Druckers
       vHeaderMsg # strchar(13)+ strchar(13) +'Infos zu (' + aPrinter + ')' + strchar(13) + '------------------------------------'  + strchar(13)  + strchar(13);
      // Alle Drucker ermitteln
      vPrinterList # _App->ppPrinterList(_PrtListRefresh);
      vPrinterList # _App->ppPrinterList;

      if (vPrinterList > 0) then begin
        FOR   vPrinter # vPrinterList->PrtInfo(_PrtFirst);
        LOOP  vPrinter # vPrinter    ->PrtInfo(_PrtNext);
        WHILE (vPrinter > 0) DO BEGIN
          vName # vPrinter->ppName;
          //debugx(vName);
          vPrintDevice # PrtDeviceOpen(vName, _PrtDeviceSystem);
          vBinCount # vPrintDevice ->PrtInfo(_PrtInfoBinCount);
          //debugx('Anzahl Schaechte: '+ cnvai(vBinCount) + strchar(13));
          //debugx('Paper Width: '+ cnvai(vPrintDevice ->PrtInfo(_PrtInfoPaperWidth)) + strchar(13));
          //debugx('Paper Height: '+ cnvai(vPrintDevice ->PrtInfo(_PrtInfoPaperWidth))+ strchar(13));

          if(vName = aPrinter) then begin
            vSchachtMsg # 'Schacht (Id,Name): ';
            vPaperHeightMsg # 'Paper Height: '+ cnvai(vPrintDevice ->PrtInfo(_PrtInfoPaperHeight)) + strchar(13);
            vPaperWidthMsg # 'Paper Width: '+ cnvai(vPrintDevice ->PrtInfo(_PrtInfoPaperWidth)) + strchar(13);
            vSchachtCntMsg # 'Anzahl Schaechte: '+ cnvai(vBinCount) + strchar(13);
            FOR  vCounter # 1;
            LOOP Inc(vCounter);
            WHILE (vCounter <= vBinCount)DO BEGIN


              vPrtBinId   # vPrintDevice->PrtInfo(_PrtInfoBinId, vCounter);
              vPrtBinName # vPrintDevice->PrtInfoStr(_PrtInfoBinName, vCounter);

              vSchachtMsg # vSchachtMsg + cnvai(vPrtBinId) + ','  + vPrtBinName + '|  ';
              //debugx(vSchachtMsg)

            END
            vSchachtMsg # vSchachtMsg + strchar(13);
          end

          vPrintDevice->PrtDeviceClose();
        END
      end
      MsgErr(912009,vHeaderMsg +  vPaperWidthMsg + vPaperHeightMsg + vSchachtCntMsg + vSchachtMsg);
    end else
      MsgErr(912009,'Fehlercode: ' + Aint(Erx));

  end;
    
end;
  
  
  if (vDev<>0) and (vLocal) then begin
    PrtDeviceClose(vDev);
  end;

  vDev # 0;
  if (vMyClassForm) then VarFree(class_Form);

  RETURN true;
end;


//========================================================================
//  Print
//      aus Vorschau
//========================================================================
sub Print(
  opt aDev  : int) : logic;
local begin
  vPath     : alpha(1000);
  vB        : alpha(1000);
  vDir      : int;
  vDatei    : int;
  vErr      : int;
  vPrtJob   : int;
  vDok      : int;
  vOK       : logic;
  vI        : int;

  vJob      : alpha(1000);
  vDev      : int;
  vPdfHdl   : int;
  vDlg      : int;
  vName     : alpha;
  vLocal    : logic;

  vPrt      : int;
  vRect     : rect;

  vRot      : int;
  vH        : float;
  vW        : float;
  vPapierH  : float;
  vPapierW  : float;
  vPapFormat  : alpha;
  vX,vY     : float;
  vDoc      : int;

  vPageFrom : int;
  vPageTo   : int;
  vPageCnt  : int;

  vBound    : point;
  vPages    : int;
  vOffsetX  : float;
  vPagi     : logic;
  vMyClassForm  : logic;

  visCAB    : logic;
end;
begin

  RETURN _PrintInner('',0,'',aDev);
/**** 17.06.2020 AH : alles über "_PrintInner"
//aDev # -2;  //debug
  vJob  # cView->wpFilename;
  vName # $lb.SUBJECT->wpcaption;

  // aDev = -1 = STANDARD
  // kein Printerdevice angegeben? -> dann jetzt abfragen...
  if (aDev<=0) then begin
    vDev # PrtDeviceOpen();
    vDev->ppcopies  # $ieKOPIEN->wpcaptionint;
    vDev->ppCollate # _PrtCollateOn;

    if (aDev=0) then begin
      vDlg # WinOpen(_WinComPrint,0,vDev);

      // von/bis Seite
      vDlg->wpMinInt    # 1;
      vDlg->wpMaxint    # cView->wpPagecount;
      vDlg->wppageFrom  # 1;
      vDlg->wppageTo    # vDlg->wpMaxInt;


  //    vDlg->wpflags   # _WinComPrintPageRange;
      if (WinDialogRun(vDlg)=_WinIdCancel) then begin
        Winclose(vDlg);
        PrtDeviceclose(vDev);
        RETURN false;
      end;

      vPageFrom # vDlg->wppageFrom;
      vPageTo   # vDlg->wppageTo;
    end;

    vLocal # y;

  end
  else begin
    aDev->ppcopies # $ieKOPIEN->wpcaptionint;
    aDev->ppCollate # _PrtCollateON;
    vDev # aDev;
  end;


//  vDev # PrtDeviceOpen(vPrinter,_PrtDeviceSystem);
  if (vDev<=0) then begin
    if (vDLG<>0) then WinClose(vDlg);
Msg(99,'FEHLER!',0,0,0);
    RETURN false;
  end;


  vRot  # cnvia($lb.Rotation->wpcaption);
  vW    # cnvfa($lb.Width->wpcaption);
  vH    # cnvfa($lb.Height->wpcaption);


  // ST 2017-12-21: Bei CAB Druckern für Etikettendruck nichts drehen
  visCAB # (StrFind(vDev->ppNamePrinter,'CAB',1) > 0) OR (StrFind(vDev->ppNamePrinter,'SATO',1) > 0);
  if (visCAB = false) then begin
    if (vW>vH) then begin
      vX # vW;
      vW # vH;
      vH # vX;
      vRot # vRot + 90;
    end
    else if (vRot=90) or (vRot=270) then begin
      vX # vW;
      vW # vH;
      vH # vX;
    end;
  end;


  // Job starten...
//Lib_Print:FrmJobOpen(y,0,0,n,n,n,'DinA4OhneRand', 'FALSE');
  if (VarInfo(class_Form)=0) then begin
    VarAllocate(class_Form);
    vMyClassForm # true;
  end;
  Form_isForm # true;

//debugx(aint(vRot)+'º '+aNum(vW,2)+'/'+anum(vH,2));
  if (Abs(vW - 210.0) < 2.0) and (Abs(vH - 297.0) < 2.0) then begin
//debugx('Dina4');
    vPapFormat # _PrtDocDina4;
  end
  else if (Abs(vW - 148.3) < 4.0) and (Abs(vH - 210.0) < 2.0) then begin
//debugx('Dina5');
    vPapFormat # _PrtDocDina5;
  end
  else if (Abs(vW - 210.0) < 2.0) and (vH > 400.0) then begin // DinA4 paginiert
//debugx('Dina4 paginieren');
    vPapFormat  # _PrtDocDina4;
    vPagi       # true;
  end
  else begin
    vPapFormat # 'CUSTOM';
  end;

  
  if (vPapFormat<='CUSTOM') then
    form_Job    # PrtJobOpen('DinA4OhneRand', '', _PrtJobOpenWrite | _PrtJobOpenTemp)
  else
    form_Job    # PrtJobOpen(vPapFormat, '', _PrtJobOpenWrite | _PrtJobOpenTemp);



  // Doc anpassen bei Vorschaudruck...
  vDoc # PrtInfo(Form_job, _PrtDoc);

  if (vW>1000.0) then vW # 1000.0;
  if (vH>1000.0) then vH # 1000.0;
  // wenn Client aälter als 5.7.10i dann nur 22inch Größe
  vI # DbaInfo(_DbaClnRelMaj)*1000+(DbaInfo(_DbaClnRelMin)*100)+(DbaInfo(_DbaClnRelrev));
  if (vI<5710) or ((vI=5710) and (StrChar(DbaInfo(_DbaClnRelSub))<'i'))then begin
    if (vW>540.0) then vW # 540.0;
    if (vH>540.0) then vH # 540.0;
  end;

  if (vPapFormat='CUSTOM') then begin
    vDoc->ppPageWidth   # PrtUnitLog(vW,_PrtUnitMillimetres);
    vDoc->ppPageHeight  # PrtUnitLog(vH,_PrtUnitMillimetres);
  end;

  vPapierW # PrtUnit(vDoc->PpPageWidth, _PrtUnitMillimetres);
  vPapierH # PrtUnit(vDoc->PpPageHeight, _PrtUnitMillimetres);

  if (vRot=90) or (vRot=180) then begin
    vDoc->ppOrientation # _PrtOrientLandscape;
    vX # vW;
    vW # vH;
    vH # vX;
  end
  else begin
    vDoc->ppOrientation # _PrtOrientPortrait;
  end;
  // Der ECHTE Druck soll nur DinA4 = 210 x 297mm sein
//  if (vDruckW>210.0) then vDruckW # 210.0;
//  if (vDruckH>297.0) then vDruckH # 297.0;

//debugx('w/h: '+anum(vW,0)+'/'+anum(vH,0));

  form_page   # form_Job->PrtJobWrite(_PrtJobPageStart);


  vPrt  # PrtFormOpen(_PrtTypePrintForm,'PdfForm');
  vPdfHdl  # PrtSearch(vPrt,'PrtPdf0');
  if (vPdfHdl<>0) then begin

    vPdfHdl->ppautosize  # true;
    vPdfHdl->ppPrintMode # _PrtPrintModeTextAsCurves;    // ST 2015-02-27: Projekt 1512/23

    vPdfHdl->ppFileName # vJob;
    vPageCnt # 0;
    FOR vI # 1 loop inc(vI) while (vI<=vPdfHdl->ppPagecount) do begin

      if (vPageFrom <> 0) AND (vPageTo <> 0) then begin
        if (vI < vPageFrom) OR (vI > vPageTo) then
          CYCLE;
      end;

      vOffSetX # 0.0;
      REPEAT
        vBound   # Form_Page->ppBoundMax;
        vBound:x # PrtUnitLog(vW,_PrtUnitMillimetres);
        vBound:y # PrtUnitLog(vH,_PrtUnitMillimetres);

        vRect # vPdfHdl->pparea;
        vRect:top     # 0;
        vRect:left    # PrtUnitLog(-vOffSetX,_PrtUnitMillimetres);
        vRect:right   # PrtUnitLog(vW-vOffsetX,_PrtUnitMillimetres);
        vRect:Bottom  # PrtUnitLog(vH,_PrtUnitMillimetres);
        vPdfHdl->ppArea # vRect;

        if (vRot=90) or (vRot=180) then
          vOffsetX # vOffSetX + vPapierH
        else
          vOffsetX # vOffSetX + vPapierW;
    //&&    UNTIL (vOffsetX>=vW);
    //    vPdfHdl->ppAreaRight       # vBound:x;
    //    vPdfHdl->ppAreaBottom      # vBound:y;

        if (vPageCnt>0) then
          form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);
        inc(vPageCnt);

        Form_Page->ppAreaMarginleft   # 0;
        Form_Page->ppAreaMarginTop    # 0;
        Form_Page->ppAreaMarginRight  # 0;
        Form_Page->ppAreaMarginBottom # 0;
        vPdfHdl->ppcurrentint # vI;

        form_Page->PrtAdd(vPrt,_PrtAddTop);
      UNTIL (vOffsetX>=vW) or (vPagi=false);

    END;
  end;

  vPrt->PrtFormClose();


//Form_Job->PrtJobWrite(_PrtJobPageEnd);
//Erx # Form_job->PrtJobClose(_PrtJobPreview);
//Debugx('ERG');

  // Job ausgeben
  if (aDev=-2) then begin
    form_Job -> PrtJobClose(_PrtJobPreview);
  end
  else begin
    form_Job -> PrtJobClose(_PrtJobPrint,vDev);
  end;


  if (vDev<>0) and (vLocal) then begin
    PrtDeviceClose(vDev);
  end;

  vDev # 0;
  if (vMyClassForm) then VarFree(class_Form);

  RETURN true;
***/
end;


//========================================================================
//  SavePDF
//
//========================================================================
sub SavePDF(
  aFilename : alpha(1000);
  aDirekt   : logic;
) : logic;
local begin
  vPath   : alpha(1000);
  vB      : alpha(1000);
  vDir    : int;
  vDatei  : int;
  vErr    : int;
  vPrtJob : int;
  vDok    : int;
  vOK     : logic;
  vI      : int;

  vJob      : alpha(1000);
  vHdl      : int;
  vName     : alpha;
  vWin      : int;
end;
begin

  // per Prozedur ausgeben...
  if (Set.PDF.OutputProc<>'') then begin
    Call(Set.PDF.OutputProc, aFilename, aDirekt);
    RETURN true;
  end;


  vWin # $Frame.PDFPreview;
  vJob # StrCut(cView->wpFilename,2,1000);
  vName # $lb.SUBJECT->wpcaption;
  vName # Lib_Strings:Strings_ReplaceAll(vName,'/','_');

  // kein Filename angegeben? -> dann jetzt abfragen...
  if (aDirekt=false) then begin
//    aFilename # Lib_FileIO:FileIO(_WinComFileSave, vWin, '', 'PDF-Dateien|*.pdf', vName+'.pdf');
    aFilename # Lib_FileIO:FileIO(_WinComFileSave, vWin, '', '*.*', vName+'.pdf');
    if (aFilename='') then RETURN false;
  end;

  // KOPIEREN
  Lib_FileIO:FSICopy(vJob, aFilename, false);

  RETURN true;

end;


//========================================================================
//  Outlook
//
//========================================================================
sub Outlook(
  opt aEMA        : alpha(500);
  opt aSubject    : alphA;
) : logic;
local begin
  vPath     : alpha(1000);
end;
begin

  if (aEMA='') then aEMA # $lb.EMA->wpcaption;
  if (aSubject='') then aSubject # $lb.SUBJECT->wpcaption;

  // AFX
  if (RunAFX('Print.Outlook',aEMA+'|'+aSubject)<>0) then RETURN true;

  vPath # Set.Druckerpfad;
//  If (vPath = '') then vPath # 'c:\';
  //vPath   # vPath+aint(gUserID)+'_tmp.pdf';
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+aSubject+'.pdf';
  vPath   # Lib_Strings:Strings_ReplaceAll(vPath,'/','_');

  SavePDF(vPath,y);
  Lib_COM:MailAttachement(aEMA, aSubject, vPath);
  FSIDelete(vPath);
end;


//========================================================================
//  EMail
//
//========================================================================
sub EMAIL(
  opt aEMA        : alpha(500);
  opt aSubject    : alphA;
) : logic;
local begin
  vPath     : alpha(1000);
  vDev      : int;
end;
begin
  if (aEMA='') then aEMA # $lb.EMA->wpcaption;
  if (aSubject='') then aSubject # $lb.SUBJECT->wpcaption;


  // direkter Druck...
  if (Set.EMail.Printer<>'') then begin
    vDev # PrtDeviceOpen(Set.EMail.Printer,_PrtDeviceSystem);
    if (vDev<=0) then RETURN false;
    Print(vDev);
    PrtDeviceClose(vDev);
    RETURN true;
  end;

  vPath # Set.Druckerpfad;
//  If (vPath = '') then vPath # 'c:\';
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+aSubject+'.pdf';
  vPath   # Lib_Strings:Strings_ReplaceAll(vPath,'/','_');

  SavePDF(vPath,y);

  // per Prozedur ausgeben...
  Call(Set.EMail.OutputProc, aEMA, aSubject, vPath);  // 12.05.2015 : mit vPath

  FsiDelete(vPath);
end;


//========================================================================
//  FAX
//
//========================================================================
sub FAX(
  opt aFAX      : alpha(500);
  opt aSubject  : alphA;
) : logic;
local begin
  vPath     : alpha(1000);
  vDev      : int;
end;
begin
  if (aFAX='') then aFAX # $lb.FAX->wpcaption;
  if (aSubject='') then aSubject # $lb.SUBJECT->wpcaption;

  // direkter Druck...
  if (Set.FAX.Printer<>'') then begin
    vDev # PrtDeviceOpen(Set.FAX.Printer,_PrtDeviceSystem);
    if (vDev<=0) then RETURN false;
    Print(vDev);
    PrtDeviceClose(vDev);
    RETURN true;
  end;

  // per Prozedur ausgeben...
  Call(Set.FAX.OutputProc, aFAX, aSubject);

end;


//========================================================================
//  UpdateZoom
//========================================================================
sub UpdateZoom();
local begin
  vPW : float;
  vZ  : float;
  vSW : int;
  vX  : float;
  vI  : int;
  vQ  : float;
end;
begin

  // 420.16mm = 1606p = 3.82

  if (cView->wpPageZoom=_WinPageZoomUser) then begin
    vSW # cView->wpArearight - cView->wpAreaLeft - 20;
    vPW # cnvfa($lb.Width->wpcaption);
  //  if (vPjp->wpPageZoom    # _WinPageZoomUser;
    vZ # cnvfi(cView->wpZoomFactor);

    vX # vPW * (vZ/100.0);

    if (vX<>0.0) then
      vQ # cnvfi(vSW) / vX;
    vI # cnvif(vQ*100.0) div 390;
    if (vI<=0) then vI # 1;
  end
  else if (cView->wpPageZoom=_WinPageZoomPageAll) then begin
    vI # 1;
  end
  else if (cView->wpPageZoom=_WinPageZoomPageWidthAll) then begin
    vI # 5;
  end;


  cView->wpPageNumClm # vI;

//  $lb.PAGE->wpcaption         # cnvai(vSW)+'   '+cnvaf(vX);
//  $bt.PRINT->wpcaption        # cnvaf(vQ);
//  $bt.PRINT.CHOOSE->wpcaption # cnvaI(vI);
//  $bt.PDF->wpcaption          # cnvaf(vQ);
end;


//========================================================================
//  RefreshIfm
//
//========================================================================
sub RefreshIfm();
begin
  $lb.Page->wpcaption # Translate('Seite')+' '+aint(cView->wpcurrentint)+' / '+aint(cView->wpPagecount);
end;


//========================================================================
//  EvtInit
//
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  // einen STD-Drucker laden für RTF-Anzeige...
  cView->ppPrtDevice   # PrtDeviceOpen('',_PrtDeviceSystem);
  cView->ppPageZoom    # _WinPageZoomUser;
  cView->ppZoomFactor  # 100;
  cView->ppruler       # _PrtRulerNone;

  RETURN(true);
end;


//========================================================================
//  EvtCreated
//
//========================================================================
sub EvtCreated(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  RefreshIfm();

  vHdl # Winsearch(aEvt:obj,'$jp.Preview');
//  if (vHdl=0) then vHdl # Winsearch(aEvt:obj,'DocView1');
  if (vHdl<>0) then begin
    // external?? -> DISCONNECT
    if (Strcut(vHdl->wpcaption,1,2)='>3') then begin
      if (gDBAConnect=0) then begin
        try begin
          ErrTryIgnore(_ErrValueInvalid);
          DbaDisconnect(3);
        end;
      end;
    end;
  end;

end;


//========================================================================
//  EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
  aEvt                 : event;    // Ereignis
  aRect                : rect;     // Größe des Fensters
  aClientSize          : point;    // Größe des Client-Bereichs
  aFlags               : int;      // Aktion
) : logic;
local begin
  vRect   : rect;
  vXX     : int;
  vYY     : int;
end;
begin

  if (aFlags & _WinPosSized != 0) then begin
//debug(aint(aRect:Top)+'    '+aint(aRect:Bottom))
    aEvt:OBj->wpautoupdate # false;

    vXX # 1024-(aRect:right-aRect:Left);
    vYY # 768-(aRect:Bottom-aRect:Top);

    vRect           # $DocView1->wparea;
    vRect:right     # aRect:right-aRect:left-4-4-10;
    vRect:bottom    # aRect:bottom-aRect:Top-28-35-5;
    $DocView1->wparea # vRect;

    Lib_GuiCom:ObjSetPos($lbKOPIEN, 0,705-vYY);
    Lib_GuiCom:ObjSetPos($ieKOPIEN,  0,705-vYY);

    Lib_GuiCom:ObjSetPos($bt.PAGEFIRST, 0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.PAGENEXT,  0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.PAGEPREV,  0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.PAGELAST,  0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.PAGE,      0,705-vYY);

    Lib_GuiCom:ObjSetPos($bt.ZOOMIN,    0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.ZOOMOUT,   0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.ZOOMWIDTH, 0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.ZOOMHEIGHT,0,705-vYY);
    Lib_GuiCom:ObjSetPos($bt.COPYFAXNO,0,705-vYY);


    Lib_GuiCom:ObjSetPos($lb.EMA,       0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.EMA2,      0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.FAX,       0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.FAX2,      0,705-vYY);

    cView->wpvisible # true;

    aEvt:OBj->wpautoupdate # true;

    UpdateZoom();
  end;

  RETURN(true);
end;


//========================================================================
//  EvtKeyItem
//
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
local begin
  vPjp  : int;
  vI    : int;
end;
begin

  vpjp # cView;

  if (aKey=_WinKeyPageDown) then begin
    vI # vpjp->wpcurrentint;
    inc(vI);
    vPjp->wpcurrentint # vI;
    Refreshifm();
  end;
  if (aKey=_WinKeyPageup) then begin
    vI # vpjp->wpcurrentint;
    Dec(vI);
    vPjp->wpcurrentint # vI;
    Refreshifm();
  end;
  if (aKey=_WinKeyhome) then begin
    vI # 1;
    vPjp->wpcurrentint # vI;
    Refreshifm();
  end;
  if (aKey=_WinKeyEnd) then begin
    vI # vPjp->wpPagecount;
    vPjp->wpcurrentint # vI;
    Refreshifm();
  end;

  RETURN(true);
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vPjp    : int;
  vI      : int;
  vFrame  : int;
end;
begin

  vpjp # cView;
  vFrame # Wininfo(aEvt:Obj, _Winframe);
  
  case aEvt:Obj->wpname of

    'bt.ZOOMWIDTH'  : begin
      vPjp->wpPageZoom # _WinPageZoomPageWidthAll;
      UpdateZoom();
      end;


    'bt.ZOOMHEIGHT' : begin
      vPjp->wpPageZoom # _WinPageZoomPageAll;
      UpdateZoom();
      end;


    'bt.ZOOMIN'     : begin
      vI # vPjp->wpZoomFactor;
      if (vI<(500-cZoomStep)) then begin
        vPjp->wpPageZoom    # _WinPageZoomUser;
        vI # vI + cZoomStep;
        vPjp->wpZoomFactor  # vI;
      end;
      UpdateZoom();
    end;
    'bt.ZOOMOUT'    : begin
      vI # vPjp->wpZoomFactor;
      if (vI>=(25+cZoomStep)) then begin
        vPjp->wpPageZoom    # _WinPageZoomUser;
        vI # vI - cZoomStep;
        vPjp->wpZoomFactor  # vI;
      end;
      UpdateZoom();
    end;


    'bt.PAGEPREV'   : begin
      vI # vpjp->wpcurrentint;
      if (vI > 1) then begin
        Dec(vI);
        vPjp->wpcurrentint # vI;
      end;
    end;

    'bt.PAGENEXT'   : begin
      vI # vpjp->wpcurrentint;
      if (vI < vPjp->wpPageCount) then begin
        Inc(vI);
        vPjp->wpcurrentint # vI;
      end;
    end;

    'bt.PAGEFIRST'  : begin
      vI # 1;
      vPjp->wpcurrentint # vI;
    end;

    'bt.PAGELAST'   : begin
      vI # vPjp->wpPageCount;
      vPjp->wpcurrentint # vI;
    end;


    'bt.PRINT'        : begin
      Print(Cnvia(cView->wpcustom));
      if (Set.DruckVS.ClosePrt) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;


    'bt.PRINT.CHOOSE' : begin
      Print();
      if (Set.DruckVS.ClosePrt) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;


    'bt.OUTLOOK'      : begin
      Outlook();
      if (Set.DruckVS.CloseOut) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;


    'bt.PDF'          : begin
      SavePDF('',n);
      if (Set.DruckVS.ClosePDF) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;


    'bt.EMAIL'        : begin
      EMAIL();
      if (Set.DruckVS.CloseEMA) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;


    'bt.FAX'          : begin
      FAX();
      if (Set.DruckVS.CloseFAX) then begin
        Winclose(vFrame);
        RETURN true;
      end;
    end;

    'bt.COPYFAXNO'  : begin
      ClipBoardWrite($lb.FAX->wpCaption);
    end;


  end;

  RefreshIfm();

  RETURN(true);
end;


//========================================================================
//  EvtClose
//
//========================================================================
sub EvtClose(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vDev  : int;
end;
begin
  vDev # Cnvia(cView->wpcustom);
  if (vDev<>0) then PrtDeviceClose(vDev);
  vDev # cView->ppPrtDevice;
  if (vDev<>0) then PrtDeviceClose(vDev);
  RETURN(true);
end;


/***** GOTOMAXX PDFMAILER
Empfänger-Mail:
'@@aa'+EMAIL+'@@'
PDF?Name:
'@@fn'+NAME+'@@'
Betreff:
'@@ed'++BETREFF+'@@'
Ausgabedialog deaktivieren:
'@@od0@@
AlsMailversenden:
'@@ml@@'
Dokument drucken erlaubt:
'@@srP@@'
Speichern erlauben:
'@@sv@@'
Dokumentenkennwort setzen'
'@@su'+PW++'@@'
*****/


//========================================================================
//  DirekterDruck
//========================================================================
sub DirekterDruck(
  aPath     : alpha(4000);
  aKopien   : int;
  aPrinter  : alpha(4000);
  aDev      : int;
  aSchacht  : alpha(4000);
  ) : logic;
local begin
  vPDF      : int;
  vName     : alpha(1000);

  vRot      : int;
  vH        : float;
  vW        : float;
  vX        : float;
  vDev      : int;
  vDlg      : int;
  vLocal    : logic;
  vDoc      : int;
  vPrt      : int;
  vHdl      : int;
  vRect     : rect;
  vI        : int;
  vPath     : alpha(1000);
  vMyClassForm : logic;
  visCAB   : logic;
end;
begin

  RETURN _PrintInner(aPath, aKopien, aPrinter, aDev, aSchacht);

/**** 17.06.2020 AH : alles über "_PrintInner"
//aDev # -2;
  if (aKopien=0) then aKopien # 1;

  // PDF-Infos auslesen
//debug('pdf 1 '+aPath);
  vPDF # PdfOpen(aPath);
//debug('fehler:'+aint(vPDF));
  if (vPDF<0) then RETURN false;
//debug('pdf 2');

  vName # vPDF->spPdfTitle;
  if (PdfPageOpen(vPdf ,1)=0) then begin
    vRot # vPdf->spPdfPageRotation;
    PdfPageClose(vPdf, _PdfPageCloseCancel);
  end;
  vW # vPdf->spPdfPageWidth;
  vH # vPdf->spPdfPageHeight;
  PDFClose(vPDF);

  // aDev = -1 = STANDARD
  // kein Printerdevice angegeben? -> dann jetzt abfragen...
  vDev # aDev;
  if (vDev<=0) and (aPrinter<>'') then begin
    vDev # PrtDeviceOpen(aPrinter,_PrtDeviceSystem);
    vLocal # y;
  end;
  if (vDev<=0) then begin

    vDev # PrtDeviceOpen();
    vDev->ppcopies  # aKOPIEN;
    vDev->ppCollate # _PrtCollateOn;

    if (aDev=0) then begin
      vDlg # WinOpen(_WinComPrint,0,vDev);

      // von/bis Seite
//      vDlg->wpMinInt    # 1;
//      vDlg->wpMaxint    # cView->wpPagecount;
//      vDlg->wppageFrom  # 1;
//      vDlg->wppageTo    # vDlg->wpMaxInt;

      if (WinDialogRun(vDlg)=_WinIdCancel) then begin
        Winclose(vDlg);
        PrtDeviceclose(vDev);
        RETURN false;
      end;
    end;

    vLocal # y;
  end
  else begin
    vDev->ppcopies  # aKOPIEN;
    vDev->ppCollate # _PrtCollateON;
    if (aSchacht<>'') then
      vDev->ppbinsource # cnvia(aSchacht);
  end;

//  vDev # PrtDeviceOpen(vPrinter,_PrtDeviceSystem);
  if (vDev<=0) then begin
    if (vDLG<>0) then WinClose(vDlg);
Msg(99,'FEHLER!',0,0,0);
    RETURN false;
  end;


  // ST 2017-12-21: Bei CAB Druckern für Etikettendruck nichts drehen
  visCAB # (StrFind(vDev->ppNamePrinter,'CAB',1) > 0) OR (StrFind(vDev->ppNamePrinter,'SATO',1) > 0);
  if (visCAB = false) then begin
    if (vW>vH) then begin
      vX # vW;
      vW # vH;
      vH # vX;
      vRot # vRot + 90;
    end
    else if (vRot=90) or (vRot=270) then begin
      vX # vW;
      vW # vH;
      vH # vX;
    end;
  end;


  // Job starten...
  if (VarInfo(class_Form)=0) then begin
    VarAllocate(class_Form);
    vMyClassForm # true;
  end;
  Form_isForm # true;
  
  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;
  form_Job    # PrtJobOpen(_PrtDocDinA4, vPath + 'tmp'+AInt(gUserID) +'.Job',_PrtJobOpenWrite | _PrtJobOpenEmbedImages ,_PrtTypePrintDoc);

  // Doc anpassen beim DD...
  vDoc # PrtInfo(Form_job, _PrtDoc);
  if (vW>550.0) then vW # 550.0;
  vDoc->ppPageWidth   # PrtUnitLog(vW,_PrtUnitMillimetres);
  vDoc->ppPageHeight  # PrtUnitLog(vH,_PrtUnitMillimetres);
  if (vRot=90) or (vRot=180) then
    vDoc->ppOrientation # _PrtOrientLandscape
  else
    vDoc->ppOrientation # _PrtOrientPortrait;

  form_page   # form_Job->PrtJobWrite(_PrtJobPageStart);

  vPrt  # PrtFormOpen(_PrtTypePrintForm,'PdfForm');
  vHdl  # PrtSearch(vPrt,'PrtPdf0');
  if (vHdl<>0) then begin

    vRect # vHdl->pparea;
    vRect:top     # 0;
    vRect:left    # 0;
    vRect:right   # PrtUnitLog(vW,_PrtUnitMillimetres); // 21
    vRect:Bottom  # PrtUnitLog(vH,_PrtUnitMillimetres); // 29.7
    vHdl->pparea  # vRect;
    vHdl->ppautosize  # true;

    vHdl->ppPrintMode # _PrtPrintModeTextAsCurves;    // ST 2015-02-27: Projekt 1512/23
    vHdl->ppFileName # '*'+aPath;
    for vI # 1 loop inc(vI) while (vI<=vHdl->ppPagecount) do begin
      if (vI>1) then form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);
      Form_Page->ppMarginleft   # 0;
      Form_Page->ppMarginTop    # 0;
      Form_Page->ppMarginRight  # 0;
      Form_Page->ppMarginBottom # 0;
      vHdl->ppcurrentint # vI;
      form_Page->PrtAdd(vPrt,_PrtAddTop);
    end;
  end;
  vPrt->PrtFormClose();

  // Job ausgeben
  if (aDev=-2) then begin
    form_Job -> PrtJobClose(_PrtJobPreview);
  end
  else begin
    form_Job -> PrtJobClose(_PrtJobPrint,vDev);
  end;
  if (vDev<>0) and (vLocal) then begin
    PrtDeviceClose(vDev);
  end;

  vDev # 0;
  if (vMyClassForm) then VarFree(class_Form);

  RETURN true;
***/
end;

//========================================================================
