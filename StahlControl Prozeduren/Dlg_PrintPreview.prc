@A+
//===== Business-Control =================================================
//
//  Prozedur  Dlg_PrintPreview
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  02.02.2012  AI  Drucksortierung IMMER AN
//  18.10.2012  ST  Kompiliert für Recherchezwecke Projekt 1357/88
//  14.11.2014  AH  BLOG drucken auch erstmal über Druckerpfad
//  16.01.2015  AH  neuer AFX: "PrintPreview.Outlook"
//  20.05.2015  AH  Printerdevice wird in "bt.Print" gespeichert
//  21.03.2019  ST  Afx "Dlg_PDFPreview.ShowJob" hinzugefügt Projekt 1962/3
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB ShowJob(aPath : alpha; aName : alpha; aPrinter : int; aKopien : int; aEMA : alpha(1000); aFAX : alpha(1000));
//    SUB Print(opt aDev : int) : logic;
//    SUB SavePDF(aFilename : alpha(1000); aDirekt : logic;) : logic;
//    SUB Outlook(opt aEMA : alpha(500);opt aSubject : alphA) : logic;
//    SUB EMAIL(opt aEMA : alpha(500); opt aSubject : alphA) : logic;
//    SUB FAX(opt aFAX : alpha(500); opt aSubject : alpha) : logic;

//    SUB RefreshIfm();
//    SUB EvtInit(aEvt : event) : logic;
//    SUB EvtCreated(aEvt : event) : logic;
//    SUB EvtPosChanged(aEvt : event; aRect : rect; aClientSize : point; aFlags : int) : logic;
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int) : logic;
//    SUB EvtClicked(aEvt : event) : logic;
//    SUB EvtClose(aEvt : event) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cZoomStep : 25
end;

//========================================================================
//  ShowJob
//
//========================================================================
sub ShowJob(
  aPath     : alpha;
  aName     : alpha;
  aPrinter  : int;
  aKopien   : int;
  aEMA      : alpha(1000);
  aFAX      : alpha(1000));
local begin
  vHdl  : int;
  vHdl2 : int;
  vOpt  : int;
  vPAra : alpha(4000);
end;
begin
//debugx('');
//debugx(aint(VarInfo(Class_List)));

  vPara # aPath                   + '|' +
          aName                   + '|' +
          Aint(aPrinter)          + '|' +
          Aint(aKopien)           + '|' +
          aEMA                    + '|' +
          aFAX;
  
  if (RunAFX('PrintPreview.ShowJob',vPara)<0) then
    RETURN;
    
  
  vHdl # WinOpen('Frame.PrintPreview',_WinOpenDialog);

  vHdl2 # Winsearch(vHdl,'pjp.Preview');
  vHdl2->wpcaption # aPath;
  vHdl2 # Winsearch(vHdl,'bt.Print'); // 20.05.2015 wegen Kudellmudell mit "->ArcFlow"
  vHdl2->wpcustom  # aint(aPrinter);
  vHdl2 # Winsearch(vHdl,'lb.FAX');
  vHdl2->wpcaption # aFax;
  vHdl2 # Winsearch(vHdl,'lb.SUBJECT');
  vHdl2->wpcaption # aName;
  vHdl2 # Winsearch(vHdl,'lb.EMA');
  vHdl2->wpcaption # aEMA;
  vHdl2 # Winsearch(vHdl,'ieKOPIEN');
  vHdl2->wpcaptionint # aKopien;
  vHdl->wpcaption # Translate('Druckvorschau')+' '+aName;

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
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(
  opt aDev  : int) : logic;
local begin
  vPath       : alpha(1000);
  vB          : alpha(1000);
  vDir        : int;
  vDatei      : int;
  vErr        : int;
  vPrtJob     : int;
  vDok        : int;
  vOK         : logic;
  vI          : int;

  vJob        : alpha(1000);
  vDev        : int;
  vHdl        : int;
  vDlg        : int;
  vName       : alpha;
  vLocal      : logic;
  vDBACOnnect : int;
end;
begin

  if (RunAFX('PrintPreview.Print', Aint(aDev)) <> 0) then begin
    RETURN (AfxRes=_rOk);
  end;


  vJob # $pjp.Preview->wpcaption;
  vName # $lb.SUBJECT->wpcaption;


  // kein Printerdevice angegeben? -> dann jetzt abfragen...
  if (aDev=0) then begin
    vDev # PrtDeviceOpen();
    vDev->ppcopies # $ieKOPIEN->wpcaptionint;
    vDev->ppCollate # _PrtCollateOn;

    vDlg # WinOpen(_WinComPrint,0,vDev);

    // von/bis Seite
    vDlg->wpMinInt    # 1;
    vDlg->wpMaxint    # $pjp.Preview->wpmaxint;
    vDlg->wppageFrom  # 1;
    vDlg->wppageTo    # vDlg->wpMaxint;

//    vDlg->wpflags   # _WinComPrintPageRange;

    if (WinDialogRun(vDlg)=_WinIdCancel) then begin
      Winclose(vDlg);
      PrtDeviceclose(vDev);
      RETURN false;
    end;
    //vPrinter # vDev->ppNameDriver;
    //vPrinter # vDev->ppNamePrinter;
//    tPpvDlg->wpPageFrom # vHDL->wpMinInt;
//    tPpvDlg->wpPageTo   # vHDL->wpMaxInt;
//    x
//    Winclose(vHDL);
    if (vDev<>aDev) then begin
      vLocal # y;
    end;
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


  // BLOB -> dann extern auslagern...
  if (StrCut(vJob,1,3)='>3\') then begin

    if (gDBAConnect=0) then
      vDBAConnect # RunAFX('XLINK.CONNECT.DOKCA1','');
    if (vDBAConnect<0) then RETURN false;

    vPath # Set.Druckerpfad;
    if (vPath='') then begin
      FsiPathCreate(_Sys->spPathTemp+'StahlControl');
      FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
      vPath # _Sys->spPathTemp+'StahlControl\Druck\';
    end;

    vPath   # vPath+aint(gUserID)+'_tmp.job';
    vI # Lib_Strings:Strings_Count(vJob,'\');
    vI # Lib_Strings:Strings_PosNum(vJob,'\',vI);
    vB # StrCut(vJob,4,vI-4);
    vDir    # BinDirOpen(0,vB,_BinCreate | _bindba3);
    vB # StrCut(vJob,vI+1,100);
    vDatei  # BinOpen(vDir,vB, _bindba3);
    vErr # vDatei->BinExport(vPath);
    vDir->BinClose();
    vDatei->BinClose();

    if (vDBAConnect<>0) then begin
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        DbaDisconnect(3);
      end;
    end;

  end
  // interner JOB? -> dann extern auslagern...
  else if (StrCut(vJob,1,3)='>0\') then begin
    vPath # Set.Druckerpfad;
    if (vPath='') then begin
      FsiPathCreate(_Sys->spPathTemp+'StahlControl');
      FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
      vPath # _Sys->spPathTemp+'StahlControl\Druck\';
    end;

    vPath   # vPath+aint(gUserID)+'_tmp.job';
    vI # Lib_Strings:Strings_Count(vJob,'\');
    vI # Lib_Strings:Strings_PosNum(vJob,'\',vI);
    vB # StrCut(vJob,4,vI-4);
    vDir    # BinDirOpen(0,vB,_BinCreate);
    vB # StrCut(vJob,vI+1,100);
    vDatei  # BinOpen(vDir,vB,0);
    vErr # vDatei->BinExport(vPath);
    vDir->BinClose();
    vDatei->BinClose();
    end
  else if (StrCut(vJob,1,1)='*') then begin
    // bereits externe daten
    vPath # StrCut(vJob,2,1000);
    end
  else
    RETURN false;

  // DRUCKJOB öffnen und externes File importieren...
  vPrtJob # PrtJobOpen('',vPath,_PrtJobOpenRead);
  //vPrtJob # PrtJobOpen('',vJob,_PrtJobOpenRead);  geht leider nicht
  if (vPrtJob > 0) then begin
    if (vDev<>0) then begin

      if (vDLG<>0) then begin
        vHDL # vPrtJob->Winsearch('PpvComPrint');
        if (vHDL>0) then begin
          vHDL->wpMinInt   # vDlg->wpMinInt;
          vHDL->wpMaxInt   # vDlg->wpMaxInt;
          vHDL->wpPageFrom # vDlg->wppageFrom;
          vHDL->wppageTo   # vDlg->wppageTo;
          vHDL->wpFlags    # vDlg->wpFlags;
        end;
      end;

      vOK # vPrtJob->PrtJobClose(_PrtJobPrint, vDev) = _ErrOK;
//      vOK # vPrtJob->PrtJobClose(_PrtJobPreview) = _ErrOK;
      if (vLocal) then
        PrtDeviceClose(vDev);
      end
    else begin
      vOK # vPrtJob->PrtJobClose(_PrtJobPreview) = _ErrOK;
    end;

    if (vDlg<>0) then WinClose(vDlg);
    // ggf. temp. Auslagerungsdatei löschen...
    if (vDatei<>0) then FSIDelete(vPath);
    RETURN vOK;
  end;

  if (vDlg<>0) then WinClose(vDlg);

  // ggf. temp. Auslagerungsdatei löschen...
  if (vDatei<>0) then FSIDelete(vPath);
  RETURN false;

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
  vPath       : alpha(1000);
  vB          : alpha(1000);
  vDir        : int;
  vDatei      : int;
  vErr        : int;
  vPrtJob     : int;
  vDok        : int;
  vOK         : logic;
  vI          : int;
  vJob        : alpha(1000);
  vHdl        : int;
  vName       : alpha;
  vWin        : int;
  vDBACOnnect : int;
end;
begin


  // per Prozedur ausgeben...
  if (Set.PDF.OutputProc<>'') then begin
    Call(Set.PDF.OutputProc, aFilename, aDirekt);
    RETURN true;
  end;


  vWin # $Frame.PrintPreview;
  vJob # $pjp.Preview->wpcaption;
  vName # $lb.SUBJECT->wpcaption;

  // kein Filename angegeben? -> dann jetzt abfragen...
  if (aDirekt=false) then begin
    aFilename # Lib_FileIO:FileIO(_WinComFileSave, vWin, '', 'PDF-Dateien|*.pdf', vName+'.pdf');
    if (aFilename='') then RETURN false;
  end;

  // BLOB -> dann extern auslagern...
  if (StrCut(vJob,1,3)='>3\') then begin

    if (gDBAConnect=0) then
      vDBAConnect # RunAFX('XLINK.CONNECT.DOKCA1','');
    if (vDBAConnect<0) then RETURN false;

    vPath # Set.Druckerpfad;
    if (vPath='') then begin
      FsiPathCreate(_Sys->spPathTemp+'StahlControl');
      FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
      vPath # _Sys->spPathTemp+'StahlControl\Druck\';
    end;

    vPath   # vPath+aint(gUserID)+'_tmp.job';
    vI # Lib_Strings:Strings_Count(vJob,'\');
    vI # Lib_Strings:Strings_PosNum(vJob,'\',vI);
    vB # StrCut(vJob,4,vI-4);
    vDir    # BinDirOpen(0,vB,_BinCreate | _binDBA3);
    vB # StrCut(vJob,vI+1,100);
    vDatei  # BinOpen(vDir,vB, _BinDBA3);
    vErr # vDatei->BinExport(vPath);
    vDir->BinClose();
    vDatei->BinClose();

    if (vDBAConnect<>0) then begin
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        DbaDisconnect(3);
      end;
    end;

  end
  // interner JOB? -> dann extern auslagern...
  else if (StrCut(vJob,1,3)='>0\') then begin
    vPath # Set.Druckerpfad;
    if (vPath='') then begin
      FsiPathCreate(_Sys->spPathTemp+'StahlControl');
      FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
      vPath # _Sys->spPathTemp+'StahlControl\Druck\';
    end;

    vPath   # vPath+aint(gUserID)+'_tmp.job';
    vI # Lib_Strings:Strings_Count(vJob,'\');
    vI # Lib_Strings:Strings_PosNum(vJob,'\',vI);
    vB # StrCut(vJob,4,vI-4);
    vDir    # BinDirOpen(0,vB,_BinCreate);
    vB # StrCut(vJob,vI+1,100);
    vDatei  # BinOpen(vDir,vB,0);
    vErr # vDatei->BinExport(vPath);
    vDir->BinClose();
    vDatei->BinClose();
    end
  else if (StrCut(vJob,1,1)='*') then begin
    // bereits externe DATEI...
    vPath # StrCut(vJob,2,1000);
    end
  else
    RETURN false;


  // DRUCKJOB öffnen und externes File importieren...
  vPrtJob # PrtJobOpen('',vPath,_PrtJobOpenRead);
  if (vPrtJob > 0) then begin
    vPrtJob->ppPDFFileName        # aFileName;
    vPrtJob->ppPDFTitle           # vName;
    vPrtJob->ppPDFAuthor          # 'Stahl-Control';
    vPrtJob->ppPDFCreator         # 'Stahl-Control';
    vPrtJob->ppPDFRestriction     # _pdfDenyNone;
    vPrtJob->ppPDFImageResolution # 150;
    vPrtJob->ppPDFJPEGQuality     # 100;
    vPrtJob->ppPDFCompression     # _pdfCompressionJPGMax;

//    vPrtJob->ppPDFCompression     # _PdfCompressionNone;

    vOK # vPrtJob->PrtJobClose(_PrtJobPDF) = _ErrOK;
    // ggf. temp. Auslagerungsdatei löschen...
    if (vDatei<>0) then FSIDelete(vPath);
    RETURN vOK;
  end;

  // ggf. temp. Auslagerungsdatei löschen...
  if (vDatei<>0) then FSIDelete(vPath);
  RETURN false;
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
  if (RunAFX('PrintPreview.Outlook','')<>0) then RETURN true;

  if (aEMA='') then aEMA # $lb.EMA->wpcaption;
  if (aSubject='') then aSubject # $lb.SUBJECT->wpcaption;

  vPath # Set.Druckerpfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;

  vPath   # vPath+aSubject+'.pdf';


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

  // per Prozedur ausgeben...
  Call(Set.EMail.OutputProc, aEMA, aSubject);
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
//  RefreshIfm
//
//========================================================================
sub RefreshIfm();
begin
  $lb.Page->wpcaption # Translate('Seite')+' '+aint($pjp.Preview->wpcurrentint)+' / '+aint($pjp.Preview->wpmaxint);
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
  $pjp.Preview->ppPrtDevice   # PrtDeviceOpen('',_PrtDeviceSystem);
  $Pjp.Preview->ppPageZoom    # _WinPageZoomUser;
  $Pjp.Preview->ppZoomFactor  # 100;
  $Pjp.Preview->ppruler       # _PrtRulerNone;
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

  vHdl # Winsearch(aEvt:obj,'pjp.Preview');
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

  Refreshifm();
  RETURN(true);
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

    vRect           # $pjp.Preview->wparea;
    vRect:right     # aRect:right-aRect:left-4-4-10;
    vRect:bottom    # aRect:bottom-aRect:Top-28-35-5;
    $pjp.Preview->wparea # vRect;

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

    Lib_GuiCom:ObjSetPos($lb.EMA,       0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.EMA2,      0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.FAX,       0,705-vYY);
    Lib_GuiCom:ObjSetPos($lb.FAX2,      0,705-vYY);

    Lib_GuiCom:ObjSetPos($bt.CopyFaxNo, 0,705-vYY);


    $pjp.Preview->wpvisible # true;

    aEvt:OBj->wpautoupdate # true;
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
  vpjp # $pjp.Preview;

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
    vI # vPjp->wpmaxint;
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
  vPjp  : int;
  vI    : int;
end;
begin

  vpjp # $pjp.Preview;

  case aEvt:Obj->wpname of

    'bt.CopyFaxNo'  : begin
        ClipBoardWrite($lb.FAX->wpCaption);
    end;

    'bt.ZOOMWIDTH'  : vPjp->wpPageZoom # _WinPageZoomPageWidthAll;


    'bt.ZOOMHEIGHT' : vPjp->wpPageZoom # _WinPageZoomPageAll;


    'bt.ZOOMIN'     : begin
      vI # vPjp->wpZoomFactor;
      if (vI<(500-cZoomStep)) then begin
        vPjp->wpPageZoom    # _WinPageZoomUser;
        vI # vI + cZoomStep;
        vPjp->wpZoomFactor  # vI;
      end;
    end;
    'bt.ZOOMOUT'    : begin
      vI # vPjp->wpZoomFactor;
      if (vI>=(25+cZoomStep)) then begin
        vPjp->wpPageZoom    # _WinPageZoomUser;
        vI # vI - cZoomStep;
        vPjp->wpZoomFactor  # vI;
      end;
    end;


    'bt.PAGEPREV'   : begin
      vI # vpjp->wpcurrentint;
      Dec(vI);
      vPjp->wpcurrentint # vI;
    end;

    'bt.PAGENEXT'   : begin
      vI # vpjp->wpcurrentint;
      Inc(vI);
      vPjp->wpcurrentint # vI;
    end;

    'bt.PAGEFIRST'  : begin
      vI # 1;
      vPjp->wpcurrentint # vI;
    end;

    'bt.PAGELAST'   : begin
      vI # vPjp->wpmaxint;
      vPjp->wpcurrentint # vI;
    end;


    'bt.PRINT'        : begin
//      Print(Cnvia($pjp.Preview->wpcustom));
      Print(cnvia($bt.Print->wpcustom)); // 20.05.2015 wegen Kudellmudell mit "->ArcFlow"
    end;


    'bt.PRINT.CHOOSE' : begin
      Print();
    end;


    'bt.OUTLOOK'      : begin
      Outlook();
    end;


    'bt.PDF'          : begin
      SavePDF('',n);
    end;


    'bt.EMAIL'        : begin
      EMAIL();
    end;


    'bt.FAX'          : begin
      FAX();
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
//  vDev # Cnvia($pjp.Preview->wpcustom);
  vDev # Cnvia($bt.Print->wpcustom); // 20.05.2015 wegen Kudellmudell mit "->ArcFlow"
  if (vDev<>0) then PrtDeviceClose(vDev);
  vDev # $pjp.Preview->ppPrtDevice;
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