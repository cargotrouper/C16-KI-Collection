@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Print
//                      OHNE E_R_G
//  Info
//    Enthält Funktionen zum Formular- / Listendruck
//
//
//  02.05.2006  AI  Erstellung der Prozedur
//  31.01.2011  AI  Textbaustein wird immer gedruckt, auch wenn leer
//  22.06.2012  AI  APPON/OFF eingebaut + Druckerauswahl poppt aus gFrmMain aus
//  11.07.2012  MS  FrmJobClosePDF um aJobHidden erweitert, unterdrueckt den Druckfortschrittsbalken
//  01.08.2012  AI  "FrmJobClose" kann Ausgabedateinamen verarbeiten und erzeugt PDF oder TIF
//  12.09.2012  MS  Print_TextByKeyWords hinzugefuegt
//  22.10.2012  TM  Print_TextByKeyWords: Abbruch wenn kein Text vorhanden
//  06.11.2012  ST  "Print_Textbaustein" setzt Rechte Max Koordinate, falls nicht angegeben wurde
//  05.12.2012  AI  NEU: FFifNoSpace
//  07.12.2012  AI  Bakgrounc wird InHouse aus "..\" geholt
//  24.04.2013  ST  Splashscreen sichert jetzt das WindowBonus Objekt selbstständig
//  27.05.2013  ST  Print_TextByKeyWordsStyle hinzugefügt
//  10.08.2013  AH  Neu: PDFcreator
//  05.11.2013  AH  Neu: Set.DruckVS.ImHGrund
//  18.11.2013  AH  "Print_Background" nutzt absoulten Hauptpath und nicht relativ
//  05.02.2014  AH  "Print_Background": Pfad nun entweder Abosult oder relativ (Doppelpukt entscheidet)
//  07.05.2014  AH  Neu: Druckerauswahl
//  04.03.2015  ST  Neu: Druckerauswahl für Vorschau ohne Druckerangabe kann abgebrochen werden
//  14.04.2016  ST  "Print_TextAbsolut" optionaler FontName hinzugefügt
//  15.08.2016  ST  Aufruf "ShowPDF" als Form oder Report erweitert
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  08.06.2020  ST  Zoomfaktor für Betriebsuser => auf Komplette 1. Seite anzeigen
//  27.07.2021  AH  ERX
//
//
//  Subprozeduren
//    SUB FrmJobOpen(aNummer : alpha; aHeader : int; aFooter : Int; aUseStdHead : logic; aUseStdFoot : logic; optaLandscape : logic; optaPaperSize : alpha; opt aBackground : alpha) : int

//    SUB PrintFaxEMailCode();
//    SUB FrmJobCloseTif(aVorschau : logic; aFileName : alpha; opt aTifMode : int; opt aNoSave : logic;; opt aArcFrage : logic ) : logic
//    SUB FrmJobClosePDF(aVorschau : logic; aFileName : alpha; opt aNoSave : logic; opt aArcFrage : logic; opt aTitel : alpha(500); opt aJobHidden  : logic;) : logic
//    SUB FrmJobClose(aVorschau : logic; opt aNoSave : logic; opt aArcFrage : logic) : logic

//    SUB FrmPrintDialog(aName : alpha; optlandscape : logic);
//    SUB FrmPageOpen() : int
//    SUB FrmPageClose() : int
//    SUB EvtPrtFrameClose( aEvt : event ) : logic
//    SUB FrmJobCancel() : int
//    SUB FrmGetLang() : alpha;
//    SUB FFifNoSpace(aElement : int)
//    SUB LfPrint(aElement : int; optaNoUnload : logic)
//    SUB Print_Seitenkopf(optaElement : int)
//    SUB Print_Betreff(optaBetreff : alpha);
//    SUB Print_FF;
//    SUB Print_LinieEinzeln(opt aX : float; opt aXX : float; opt aY : int; opt aIX : int; opt aIXX : int)
//    SUB Print_LinieDoppelt(optaX : float; optaXX : float)
//    SUB Print_LinieVEinzeln(aX  : float; aYY : float;)
//    SUB Print_LinieVBis(aX  : float;aY  : float)
//    SUB Print_Spacer(optaHeight : float; optaUnit : alpha)
//    SUB Print_Textzeile(aText : alpha(250))
//    SUB Print_Custom(aFrmElem : alpha)
//    SUB Print_Seitenende(aElement : int)
//    SUB Print_TextOnPos(aText : alpha; aPos : float; aUnit : alpha; optaBold : logic; optaItal : logic; optaStroke : logic)
//    SUB _FillPrtRtf(aHdlPrtRtf : int; aRange : range) : range
//    SUB Print_Textbaustein(aText : alpha; opt aX : float; opt aXX : float)
//    SUB Print_Background()
//    SUB Print_PDF(aFileName : alpha(250))
//    SUB Print_Text(aName : alpha; opt aLang : int; opt aX : float; opt aXX : float);
//    SUB Print_TextBuffer(aTxtHdl : int; opt aX : float; opt aXX : float);
//    SUB Print_TextAbsolut(aText : alpha; aX : float; aY : float; opt aFontSize  : int;)
//    SUB Print_TextByKeyWords(aTxtName : alpha; aKeyWordBegin : alpha(4000); aKeyWordEnd : alpha(4000); aVonPos : float; aBisPos : float; opt aBadWordBegin : alpha(4000); opt aBadWordEnd  : alpha(4000);  opt aPrintAllgemeinenText : logic);
//    sub Print_TextByKeyWordsStyle(aTxtName : alpha;aLangnr : int;aKeyWordBegin : alpha(4000);aKeyWordEnd : alpha(4000);opt aPrintAllgemeinenText : logic;opt aBadWordBegin : alpha(4000);opt aBadWordEnd : alpha(4000);)
//========================================================================
@I:Def_Global

declare Print_Betreff(opt aBetreff  : alpha)
declare Print_Spacer(opt aHeight : float; opt aUnit : alpha)
declare Print_LinieEinzeln(opt aX  : float;opt aXX : float; opt aY : int; opt aIX : int; opt aIXX : int)
declare Print_Seitenkopf(opt aElement : int;)
declare Print_Seitenende(aElement : int);
declare FrmPageOpen(): int;
declare FrmPageClose(): int
declare Print_Background()
declare Print_TextAbsolut(aText : alpha(1000); aX : float; aY : float; opt aFontSize  : int; opt aFontAttr  : int; opt aFontName : alpha)

define begin
  cMarginBottom : 0
  cFaxDebug     : ''//'938640'
  cEMailDebug   : ''//'st@stahl-control.de'
end

local begin
  vNoAutoFF     : logic;
end;


//===================================================================================
//  Druckerauswahl
//
//===================================================================================
sub Druckerauswahl(
  var aName   : alpha;
  var aKopien : word) : logic;;
local begin
  vPrinter    : int;
  vLastFoc    : int;
  vHdl        : int;
  vOK         : logic;
end;
begin
  if (gUserGroup = 'SOA_SERVER') then
    RETURN false;


  vPrinter # PrtDeviceOpen();
  if (vPrinter<=0) then RETURN false;
  if (aKopien<=0) then aKopien # 1;
  vPrinter->ppcopies # aKopien;
  vLastFoc # Winfocusget();

  vHdl # WinOpen(_WinComPrint,0,vPrinter);
  vOK # (WinDialogRun(vHDL,0,gFrmMain)=_WinIdOK);
  aName   # vPrinter->ppNamePrinter;
  aKopien # vPrinter->ppcopies;
  Winclose(vHDL);
  WinFocusset(gFRMMain);
  if (vLastFoc<>0) then Winfocusset(vLastFoc);

  RETURN vOK;
end;


//===================================================================================
//  FrmJobOpen
//  - legt einen Druckjob mit übergebenen Namen in dem Druckordener der Settings an
//===================================================================================
Sub FrmJobOpen(
  aFormular       : logic;
  aHeader         : int;
  aFooter         : Int;
  aUseStdHead     : logic;
  aUseStdFoot     : logic;
  opt aLandscape  : logic;
  opt aPaperSize  : alpha;
  opt aBackground : alpha(250);   // "TRUE" oder "FALSE" oder Filenamen
): int
local begin
  Erx       : int;
  vAusgabe  : alpha;
  vA        : alpha;
  vPrinter  : int;
  vPrt      : int;
  vX        : int;
  vSplash   : int;
  vBuf      : int;
  vVersuche : int;
  vHdl      : int;
  v800      : int;

  vWinBonus : int;
  vLastFoc  : int;
  vPath     : alpha(1000);
end;
begin

  // Satz speichern, falls Dialogfenster alles verspringen...
  if (gFile<>0) then vBuf # RekSave(gFile);

  if (VarInfo(class_Form)=0) then VarAllocate(class_Form);
  FOR vX # 1 loop inc(vX) while (vX<=20) do begin
    Form_VLine[vX]:x # -1;
    Form_VLine[vX]:y # -1;
  END;

  // standardmässig KEINE Sprache=Deutsch
  Form_Lang     # '';
  Form_DokName  # '';

  if (aPaperSize = '') and (aLandscape=n) then
    aPaperSize # 'DinA4';
  if (aPaperSize = '') and (aLandscape=y) then
    aPaperSize # 'DinA4quer';

  vPath # Set.DruckerPfad;
  if (vPath='') then begin
    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
    vPath # _Sys->spPathTemp+'StahlControl\Druck\';
  end;


  form_Background # '';
  Form_isForm     # aFormular;
  // Unterscheiden ob Listenformat oder Formular:
  if (aFormular=false) then begin    // LISTENFORMAT **************************************
    if (gUsergroup='JOB-SERVER') OR (gUsergroup='SOA_SERVER') then LastPrinter # Frm.Drucker;
    if (gUsergroup='JOB-SERVER') OR (gUsergroup='SOA_SERVER') then begin
      RecBufClear(912);
      Frm.Drucker # LastPrinter;
      Frm.DirektdruckYN # y;
      Frm.Ausgabeart    # 'P';

      vVersuche # 0;
      REPEAT
        vPrinter # PrtDeviceOpen(Frm.Drucker,_PrtDeviceSystem);
        if (vPrinter<=0) then winsleep(500);
        inc(vVersuche);
      UNTIL (vPrinter>0) or (vVersuche>10);
      if (vPrinter<=0) then begin
        vVersuche # 0;
        REPEAT
          vPrinter # PrtDeviceOpen();
          if (vPrinter<=0) then winsleep(500);
          inc(vVersuche);
        UNTIL (vPrinter>0) or (vVersuche>10);
      end;
      vVersuche # 0;

      REPEAT
// mypreview       form_Job # PrtJobOpen(aPaperSize,'',_PrtJobOpenWrite | _PrtJobOpenTemp, _PrtTypePrintDoc);
        form_Job # PrtJobOpen(aPapersize, vPath + 'tmp'+AInt(gUserID) +'.Job',_PrtJobOpenWrite | _PrtJobOpenEmbedImages ,_PrtTypePrintDoc);

        if (form_Job=0) then winsleep(500);
        inc(vVersuche);
      UNTIL (Form_Job<>0) or (vVersuche>10);
    end
    else begin
// mypreview      form_Job # PrtJobOpen(aPaperSize,'',_PrtJobOpenWrite | _PrtJobOpenTemp, _PrtTypePrintDoc);


      // pdfCREATOR
      if (Set.PDF.Creator<>'') and (Set.PDF.CreatorPAth<>'') then begin
        gPDFName                # aint(gUserid);
        Frm.Drucker             # Set.PDF.Creator;
      end;

      form_Job # PrtJobOpen(aPapersize, vPath + 'tmp'+AInt(gUserID) +'.Job',_PrtJobOpenWrite | _PrtJobOpenEmbedImages ,_PrtTypePrintDoc);

      if (gPDFName<>'') or
        ((aPaperSize<>'DinA4') and (aPaperSize<>'DinA4quer') and (Frm.Drucker<>'')) then begin
        vPrinter # PrtDeviceOpen(Frm.Drucker,_PrtDeviceSystem);
        end
      else begin
        vPrinter # PrtDeviceOpen();
      end;
      RecBufClear(912);
    end;
    if (Form_Job=0) then msg(99,'DRUCKJOB KANN NICHT GESTARTET WERDEN',_WinIcoError,_WinDialogOk,1);

  end

  else begin                   // FORMULAR ******************

    // VORSCHAU??
    //if ("Frm.DirektdruckYN"=n) and
    if (LastPrinter<>'') and (Frm.Drucker='') then Frm.Drucker # LastPrinter;

    if (Frm.Drucker='') then begin
// mypreview      Frm.Drucker # Prg_Para_Main:ParaAuswahl('Drucker','','',0,Frm.Drucker);

      // ST 2015-03-04: Druckerauswahl kann abgebrochen werden
      if (Druckerauswahl(var Frm.Drucker, var Frm.Kopien) = false) then begin
        // Satz ggf. wiederherstellen...
        if (vBuf<>0) then RekRestore(vBuf);
        RETURN -1;
      end;
/*
      vPrinter # PrtDeviceOpen();
      if (Frm.Kopien<=0) then Frm.Kopien # 1;
      vPrinter->ppcopies # Frm.Kopien;
vLastFoc # Winfocusget();
      vHdl # WinOpen(_WinComPrint,0,vPrinter);
      if (WinDialogRun(vHDL,0,gFrmMain)=_WinIdCancel) then begin
      end;
      Frm.Drucker # vPrinter->ppNamePrinter;
      Frm.Kopien  # vPrinter->ppcopies;
      Winclose(vHDL);

      WinFocusset(gFRMMain);
//      gFrmMain->WinUpdate(_WinUpdActivate);//abc
      if (vLastFoc<>0) then Winfocusset(vLastFoc);
//debugx('set '+gTMP->wpname);
//gTMP # winfocusget();
//if (gTMP<>0) then debugx('bin wieder da');
*/
      LastPrinter # Frm.Drucker;
    end;

    vAusgabe # '';
    if (StrFind(StrCnv(Frm.Drucker,_strupper),'PDF',0)<>0) or (Frm.Ausgabeart='E') then
      vAusgabe # 'PDF'
    else if (StrFind(StrCnv(Frm.Drucker,_strupper),'FAX',0)<>0) or (Frm.Ausgabeart='F') then
      vAusgabe # 'FAX';
    if (Frm.AusgabeArt='X') then vAusgabe # 'X';

    if ("Frm.DirektdruckYN") then begin
       if (vAusgabe='X') then Frm.Ausgabeart # 'P';
       end
    else if ("Frm.DirektdruckYN"=n) then begin
//      if (Frm.Ausgabeart<>'F') and (Frm.Ausgabeart<>'P') and (Frm.Ausgabeart<>'E') then begin
        // eher fax...
      if (vAusgabe='FAX') then begin
        Frm.AusgabeArt # 'F';
        if (Frm.FAX.mitBildYN=n) and (Set.FAX.Bilddatei<>'') and (aBackground='') then
          // Logo mit ausdrucken?
          if (Msg(912003,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then
            Frm.FAX.mitBildYN # y;
        end
      // eher email/pdf...
      else if (vAusgabe='PDF') then begin
        Frm.AusgabeArt # 'E';
        if (Frm.EMAIL.mitBildYN=n) and (Set.EMAIL.Bilddatei<>'') and (aBackground='') then
          // Logo mit ausdrucken?
          if (Msg(912004,'',_WinIcoQuestion,_WinDialogYesNo,vX)=_WinIdYes) then
            Frm.EMAIL.mitBildYN # y;
        end
      else if (vAusgabe='X') then begin
        Frm.Ausgabeart # 'P';
        end
      // also doch Druck...
      else begin
        Frm.Ausgabeart # 'P';
        if (Frm.Druck.mitBildYN=n) and (Set.Druck.Bilddatei<>'') and (aBackground='') then
          // Logo mit ausdrucken?
          if (Msg(912006,'',_WinIcoQuestion,_WinDialogYesNo,vX)=_WinIdYes) then
            Frm.Druck.mitBildYN # y;
      end;
    end;

    if (aBackground='FALSE') then begin
      Frm.FAX.mitBildYN   # n;
      Frm.EMAIL.mitBildYN # n;
      Frm.Druck.mitBildYN # n;
    end;

    // Splash-Screen laden
    if (gUsergroup<>'PROGRAMMIERER') and (gUsergroup<>'MC9090') and
      (gUsergroup<>'JOB-SERVER') and (gUsergroup<>'SOA_SERVER') then begin
      vSplash # WinOpen('Frame.Printing',_WinOpenDialog);
      // Splash-Screen anpassen
      gTMP # Winsearch(vSplash,'lb.printstatus');

      // Fensterdaten sichern
      vWinBonus # Varinfo(WindowBonus);
      gTMP-> wpCustom  # Aint(vWinBonus);

      gTMP -> wpCaption # 'Druck wird aufgebaut...';
      // Splash-Screen anzeigen
      try begin
        ErrTryIgnore(_ErrValueInvalid);
        vSplash -> WinDialogRun(_WinDialogAsync | _WinDialogNoActivate | _WinDialogCenter, gMdi);
      end;
    end;

    if (vPrinter=0) and (Frm.Drucker<>'') then
      vPrinter # PrtDeviceOpen(Frm.Drucker,_PrtDeviceSystem);
    if (vPrinter<=0) then
      vPrinter # PrtDeviceOpen();
//    vPrinter->ppBinSourceName # 'Tray 1';
//debug('SETPRINTER:'+aint(vPrinter));
    // FAX:
    if (Frm.Ausgabeart<>'') then Form_OutType # Frm.Ausgabeart;
    if (Frm.Ausgabeart='F') then begin
      Form_OutType # 'F';
      if (aBackground='TRUE') or (Frm.FAX.mitBildYN) then form_Background # Set.FAX.Bilddatei;
    end;
    // DRUCK:
    if (Frm.Ausgabeart='P') then begin
      Form_OutType # 'P';
      if (aBackground='TRUE') or (Frm.Druck.mitBildYN) then form_Background # Set.Druck.Bilddatei;
    end;
    // EMAIL:
    if (Frm.Ausgabeart='E') then begin
      Form_OutType # 'E';
      if (aBackground='TRUE') or (Frm.EMail.mitBildYN) then form_Background # Set.EMail.Bilddatei;
    end;
    if (aBackground <> 'TRUE') and (aBackground <> 'FALSE') and (aBackground <> '') then form_Background # aBackground;

    // 07.12.2012 AI: InHouse? Anderen Bilderornder wählen!
    if (DbaLicense(_DbaSrvLicense)='CD152667MN/H') and (Strcut(Form_Background,2,1)<>':') then
      Form_Background # '..\'+Form_Background;


    form_Job # PrtJobOpen(aPapersize, vPath + 'tmp'+AInt(gUserID) +'.Job',_PrtJobOpenWrite | _PrtJobOpenEmbedImages ,_PrtTypePrintDoc);

//        Dlg_PrintPreview:ShowJob('*'+vPath, form_Betreff, form_Printer, frm.kopien, form_EMA, form_faxNummer)
//        Dlg_PrintPreview:ShowJob('*'+vPath, Lfm.Name, 0, 1, form_EMA, form_faxNummer);
//debug('set:'+gtmp->ppname);
// mypreview   form_Job # PrtJobOpen(aPapersize, Set.Druckerpfad + aJobName +'.Job',_PrtJobOpenWrite,_PrtTypePrintDoc);
  end;  // Formular


  // pdfCREATOR
  if (gPDFname<>'') then begin
    vHDL # PrtInfo(Form_job, _PrtDoc);
    vHDL->ppname # gPdfName;
    FSIDelete(Set.PDF.CreatorPath+gPDFname+'.pdf');
  end;



  // 15.03.2010 MS Zoom laut Uservorgaben
  v800 # RecBufCreate(800);
  v800->Usr.Username # gUsername;
  Erx # RecRead(v800, 1, 0);
  if (Erx > _rLocked) then RecBufClear(v800);
  if (form_Job != 0) then begin
    Erx # form_Job->PrtInfo(_prtDoc);
    if (Erx > 0) then begin

      if (gUsergroup = 'BETRIEB') then  // ST 2020-06-08 Projekt 2023/6
        Erx->ppPageZoom # _WinPageZoomPage;
      else begin
        if (v800->Usr.Zoomfaktor != 0) then
            Erx->ppZoomFactor # v800->Usr.Zoomfaktor;
        else
          Erx->ppZoomFactor # 100; // default
      end;
      
    end;
  end;
  RecBufDestroy(v800);


  // Satz ggf. wiederherstellen...
  if (vBuf<>0) then RekRestore(vBuf);

  _App->wpWaitcursor # true;

  APPOFF();
  if (gTAPI<>0) then Lib_Tapi:TapiTerm();

  Form_Page # FrmPageOpen();

  form_Header     # aHeader;
  form_Footer     # aFooter;
  form_Landscape  # aLandscape;
  form_printer    # vPrinter;
  form_useStdHead # aUseStdHead;
  form_useStdFoot # aUseStdFoot;

  if (form_OutType='') then form_RandOben # 0.0;
  if (form_OutType='F') then begin
    form_randOben   # rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.FAX.Rand.Oben)));
    form_randUnten  # cnvif(rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.FAX.Rand.Unten))));
    end
  else if (form_OutType='E') then begin
    form_randOben   # rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.EMail.Rand.Oben)));
    form_randUnten  # cnvif(rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.EMail.Rand.Unten))));
    end
  else begin
    form_randOben   # rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.Druck.Rand.Oben)));
    form_randUnten  # cnvif(rnd(Lib_Einheiten:LaengenKonv('mm','LE', cnvfi(Set.Druck.Rand.Unten))));
  end;



/***
  // FAX *****************************************************************
  if (Form_OutType='F') then begin
    if (cFaxDebug<>'') then form_faxnummer # cFaxDebug;
    if (Frm.FAX.Code='') then begin
      Frm.FAX.Code # '@@AN %@%@@ @@BETREFF %B%@@';
    end;
    Dlg_standard:standard(Translate('Nummer'),var form_faxnummer);
    vA # Frm.FAX.Code;
    REPEAT
      vX # strfind(vA,'%@%',0);
      if (vX<>0) then begin
        if (Form_FaxNummer<>'') then begin
          if (strcut(form_faxNummer,1,1)='+') then
            form_faxNummer # '00'+StrCut(form_FaxNummer,2,100);
        end;
        vA # StrCut(vA,1,vX-1)+Form_FaxNummer+StrCut(vA,vX+3,999);
      end;
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%B%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Form_Betreff+StrCut(vA,vX+3,999);
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%TODAY%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Cnvad(today,_FmtDateLongYear)+StrCut(vA,vX+7,999);
    UNTIL (vX=0);
    Lib_Print:Print_TextAbsolut(vA,0.0,1.0);
  end;
****/

  RETURN form_Job;
end;


//===================================================================================
//  PrintFaxEMailCode
//
//===================================================================================
Sub PrintFaxEmailCode();
local begin
  vA    : alpha(1000);
  vX    : int;
  vCode : alpha(500);
end;
begin
  vCode # '';
//  vCode # 'orig34ithoirh efgoihegoie gioüe güoig oütg tgrog üggühewü hgüoig üwth ig ighüoghegioheü üghe eg ewg ewg e';
//  vCode # vCode + vCode + vCode;
// FAX *****************************************************************
// mypreview  if (Form_OutType='F') then begin
//              0        1         2         3         4         5
//              12345678901234567890123456789012345678901234567890
//frm.fax.code # 'F_B_X_CODE                                        ';
//frm.EMA.code # 'E_M_A_I_L_CODE                                    ';

  if (Form_faxnummer<>'') then begin
    if (cFaxDebug<>'') then form_faxnummer # cFaxDebug;
    if (Frm.FAX.Code='') then begin
      Frm.FAX.Code # '@@AN %@%@@ @@BETREFF %B%@@';
    end;
    if (StrCut(form_Faxnummer,1,1)='!') then begin
      form_faxnummer # StrDel(form_Faxnummer,1,1);
      end
    else begin
      if (Form_OutType='F') then begin
        _app->wpWaitCursor # false;
        APPON();
        Dlg_standard:standard(Translate('Nummer'),var form_faxnummer);
        _app->wpWaitCursor # true;
        APPOFF();
      end;
    end;
    vA # Frm.FAX.Code;
    REPEAT
      vX # strfind(vA,'%@%',0);
      if (vX<>0) then begin
        if (Form_FaxNummer<>'') then begin
          if (strcut(form_faxNummer,1,1)='+') then
            form_faxNummer # '00'+StrCut(form_FaxNummer,2,100);
        end;
        vA # StrCut(vA,1,vX-1)+Form_FaxNummer+StrCut(vA,vX+3,999);
      end;
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%B%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Form_Betreff+StrCut(vA,vX+3,999);
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%TODAY%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Cnvad(today,_FmtDateLongYear)+StrCut(vA,vX+7,999);
    UNTIL (vX=0);

    vCode # vCode + vA;
  end;

  // EMAIL ***************************************************************
  // @@aa EMA@@
  // @@ed BETREFF@@
//  if (Form_OutType='E') then begin
  if (Form_EMA<>'') then begin
    if (cEMailDebug<>'') then form_EMA # cEMailDebug;

    if (Frm.EMA.Code='') then begin
      Frm.EMA.Code # '@@aa %@%@@ @@ed %B%@@';
    end;
    vA # Frm.EMA.Code;
    REPEAT
      vX # strfind(vA,'%@%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Form_EMA+StrCut(vA,vX+3,999);
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%B%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Form_Betreff+StrCut(vA,vX+3,999);
    UNTIL (vX=0);
    REPEAT
      vX # strfind(vA,'%TODAY%',0);
      if (vX<>0) then
        vA # StrCut(vA,1,vX-1)+Cnvad(today,_FmtDateLongYear)+StrCut(vA,vX+7,999);
    UNTIL (vX=0);

    vCode # vCode +' ' +vA;
  end;


  if (vCode<>'') then
    Print_TextAbsolut(vCode, Max(1.0, SET.FAX.Coord.X), Max(1.0,SET.FAX.Coord.Y), -1);

end;


//===================================================================================
//  FrmJobCloseTif
//  - schließt den Druckjob und speichert eine PDF mit Namen aFileName
//===================================================================================
Sub FrmJobCloseTif(
  aVorschau     : logic;
  aFileName     : alpha;
  opt aTifMode  : int;
  opt aNoSave   : logic;
  opt aArcFrage : logic;
) : logic;
local begin
  vDev      : int;
  vInstanz  : int;
  vX        : int;
  vA        : alpha(1000);
  vHdl      : int;
  vSplash   : int;
  vArc      : logic;

  vWinBonus : int;
end;
begin

  Lib_Form:UnloadSubStyleDef();
  Lib_Form:UnloadStyleDef();

  _app->wpWaitCursor # false;
  APPON();
  if (form_Job = 0) then begin
    Lib_Tapi:TAPIInitialize();
    RETURN n;
  end;
/*
  vInstanz # VarInfo(Windowbonus);
*/
  vSplash  # $Frame.Printing;

  if(aTifMode = 0) then
    aTifMode # _TifModeColor;

  Print_Background();

  if (vSplash != 0) then begin
    gTMP # Winsearch(vSplash, 'lb.printstatus');
    gTMP->wpCaption # 'Druckvorschau wird angezeigt...';
  end;

  form_Job->ppTifFileName        # aFileName;
  form_Job->ppTifMode            # aTifMode;
  form_Job ->PrtJobClose(_prtJobTif);
  // Aktuellen User holen
  Usr.Username      # gUsername;
  RecRead( 800, 1, 0 );


  vArc # Frm.SpeichernYN;
  if (aNoSave) then vArc # n;

  if (vSplash != 0) then begin
    // Fensterzusatz daten extrahieren
    vHdl # Winsearch(vSplash,'lb.printstatus');
    vWinBonus # CnvIA(vHdl->wpCustom);

    vSplash->WinClose();
    vSplash # 0;

    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

  if (aArcFrage) then begin
    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
  end;

  // Archivieren
  if (vArc=false) then
    Lib_Dokumente:KillJOB()
  else
    Lib_Dokumente:ImportJOB(Frm.Bereich,Frm.Name,Form_DokName,Form_DokSprache, form_FaxNummer, form_EMA);


  if (VarInfo(class_Form) != 0) then
    VarFree(class_Form);

/*
  VarInstance(Windowbonus, vInstanz);
*/
  Lib_Tapi:TAPIInitialize();

  RETURN vArc;
end;


//===================================================================================
//  FrmJobClosePDF
//  - schließt den Druckjob und speichert eine PDF mit Namen aFileName
//===================================================================================
Sub FrmJobClosePDF(
  aVorschau       : logic;
  aFileName       : alpha(4000);
  opt aNoSave     : logic;
  opt aArcFrage   : logic;
  opt aTitel      : alpha(500);
  opt aJobHidden  : logic;
) : logic;
local begin
  vDev      : int;
  vInstanz  : int;
  vX        : int;
  vA        : alpha(1000);
  vHdl      : int;
  vSplash   : int;
  vArc      : logic;
  vWinBonus : int;
end;
begin

  Lib_Form:UnloadSubStyleDef();
  Lib_Form:UnloadStyleDef();

  _app->wpWaitCursor # false;
  APPON();
  if (form_Job = 0) then begin
    Lib_Tapi:TAPIInitialize();
    RETURN false;
  end;

//  vInstanz # VarInfo(Windowbonus);
  vSplash  # $Frame.Printing;

  Print_Background();

  if (vSplash != 0) then begin
    gTMP # Winsearch(vSplash, 'lb.printstatus');
    gTMP->wpCaption # 'Druckvorschau wird angezeigt...';
  end;

  form_Job->ppPDFFileName        # aFileName;
  form_Job->ppPDFTitle           # aTitel;
  form_Job->ppPDFAuthor          # 'Stahl-Control';
  form_Job->ppPDFCreator         # 'Stahl-Control';
  form_Job->ppPDFRestriction     # _pdfDenyNone;
  form_Job->ppPDFImageResolution # 150;
  form_Job->ppPDFJPEGQuality     # 100;
  form_Job->ppPDFCompression     # _pdfCompressionJPGMax;

  if(aJobHidden = true) then // Anzeige des Fortschrittsbalkens unterbinden
    form_Job ->PrtJobClose(_prtJobPDF | _PrtJobHidden);
  else
    form_Job ->PrtJobClose(_prtJobPDF);
  // Aktuellen User holen
  Usr.Username      # gUsername;
  RecRead( 800, 1, 0 );

  vArc # Frm.SpeichernYN;
  if (aNoSave) then vArc # n;

  if (vSplash != 0) then begin
    // Fensterzusatz daten extrahieren
    vHdl # Winsearch(vSplash,'lb.printstatus');
    vWinBonus # CnvIA(vHdl->wpCustom);

    vSplash->WinClose();
    vSplash # 0;

    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

  // NEU 02.05.2017 TM
  if (aVorschau and aFilename !='') then begin
    Dlg_PDFPreview:ShowPDF(aFilename, true,Dok.EMail,Dok.FAX,0,1, gPDFTitel);
    if (form_isForm=false) then FSIDelete(Set.PDF.CreatorPath+gPDFname+'.pdf');
  end;

  if (aArcFrage) then begin
    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
  end;

  // Archivieren
  if (vArc=false) then begin
    Lib_Dokumente:KillJOB();
  end
  else begin
    //2023-04-02 AH für BCS
    if (set.Installname=^'BCS') and (STrFind(aFilename,'.PDF',_StrCaseIgnore)>0) then begin
      Lib_Dokumente:ImportPDF(afIlename, frm.Bereich,Frm.Name,Form_DokName,Form_DokSprache, form_FaxNummer, form_EMA,TRUE);
    end
    else begin
      Lib_Dokumente:ImportJOB(Frm.Bereich,Frm.Name,Form_DokName,Form_DokSprache, form_FaxNummer, form_EMA);
    end;

  end;

  if (VarInfo(class_Form) != 0) then
    VarFree(class_Form);

/*
  VarInstance(Windowbonus, vInstanz);
*/
  Lib_Tapi:TAPIInitialize();

  RETURN vArc;
end;


//===================================================================================
//  FrmJobClose
//  - schließt den Druckjob und aktiviert den Druck (N) oder zeigt die Vorschau an (Y)
//===================================================================================
Sub FrmJobClose(
  aVorschau     : logic;
  opt aNoSave   : logic;
  opt aArcFrage : logic;
  opt aFilename : alpha(4096)
) : logic;
local begin
  Erx       : int;
  vDev      : int;
  vInstanz  : int;
  vX        : int;
  vHdl      : int;
  vSplash   : int;
  vZoomFact : int;
  vPath     : alpha;
  vArc      : logic;
  vWinBonus : int;
end;
begin

  Lib_Form:UnloadSubStyleDef();
  Lib_Form:UnloadStyleDef();

  // 01.08.2012 AI
  if (aFilename<>'') then begin
    aFilename # StrCnv(aFilename, _strupper);
    if (FsiSplitName(aFilename, _FsiNameE)='PDF') then
      // PDF
      RETURN FrmJobClosePdf(aVorschau, aFilename, aNoSave, aArcFrage, Frm.Name+' '+form_dokname, n)
    else if (FsiSplitName(aFilename, _FsiNameE)='TIF') or (FsiSplitName(aFilename, _FsiNameE)='TIFF') then
      RETURN FrmJobCloseTif(aVorschau, aFilename, 0, aNoSave, aArcFrage);
  end;


  APPON();
  _App->wpWaitcursor # false;
  if (Winfocusget()<>0) then begin  //Probleme, wenn Druckauswahldialog genutz wird, dann APPOFF und hier APPON
    if (Set.DruckVS.ImHGrund=false) then begin
      gFrmMain->WinUpdate(_WinUpdActivate);
      gFrmMain->winfocusset(true);
    end;
  end;

  if (form_Job=0) then begin
    Lib_Tapi:TAPIInitialize();
    RETURN false;
  end;

  vInstanz # VarInfo(Windowbonus);
  // Hintergrundbild "hinterlegen"
  Print_Background();

  if (Form_Betreff='') then
    form_Betreff # Frm.Name;

//  PrintFaxEMailCode();  wird im Seitenkopf gedruckt

  FrmPageClose();

  // POST-Script?
/*
  if (StrFind(Scr.Name,'.POST',1,_StrCaseIgnore)>0) then begin
    vHdl # form_Job->PrtInfo(_PrtFrame);
    if (vHdl<>0) then begin
      // Toolbar auf der linken Seite anzeigen
      Erx # vHdl->PrtSearch('PpvTbnPrint');
      if (Erx<>0) then begin
        Erx->wpVisible # false;
      end;
    end;
  end;
*/


  // Splash-Screen anpassen
//  vSplash # Winsearch(gMDI, 'Frame.Printing');
  vSplash # $Frame.Printing;
  if (vSplash<>0) then begin
    gTMP # Winsearch(vSplash,'lb.printstatus');
    gTMP -> wpCaption # 'Druckvorschau wird angezeigt...';
  end;

  if (gUserGroup='JOB-SERVER') or (gUserGroup='SOA_SERVER') or (gUsergroup='MC9090') then aVorschau # n;


  // pdfCREATOR --------------------------------------------------------------
  if (gPDFname<>'') then begin

    // close PDFcreator
    if (form_Printer<>0) then begin
      vDev # form_printer;
      if (Frm.Schacht<>'') then vDev->ppbinsource # cnvia(Frm.Schacht);
      end
    else begin
      vDev # PrtDeviceOpen();    // std.Drucker laden
    end;
    if (Frm.Kopien<=0) then Frm.Kopien # 1;
    if (vDev>0) then vDev->ppcopies # Frm.Kopien;

    // Job ausgeben
    if (vDev=0) then todo('KEIN PRINTER (699) !!!');
    if (form_Job=0) then todo('KEIN JOB (700) !!!')
    else
      form_Job -> PrtJobClose(_PrtJobPrint,vDev);
    if (vDev<>0) then vDev->PrtDeviceclose();

    vX # 0;
    WHILE (Lib_FileIO:FileExists(Set.PDF.CreatorPath+gPDFname+'.pdf')=false) and (vX<20) do begin
      Winsleep(500);
      inc(vX);
    END;
    if (Lib_FileIO:FileExists(Set.PDF.CreatorPath+gPDFname+'.pdf')) then begin
  //    Lib_FileIO:FsiCopy(cPDFCPath+form_pdfname+'.pdf', 'c:\debug\'+form_betreff+'.pdf' ,y);
  //    form_pdfName # 'C:\debug\'+form_betreff+'.pdf';
  //  end;
  //    aVorschau # y;
      if (gPDFTitel='') then gPDFTitel # Form_Betreff;

      if (aVorschau) then begin
        Dlg_PDFPreview:ShowPDF(Set.PDF.CreatorPath+gPDFname+'.pdf', true,Dok.EMail,Dok.FAX,0,1, gPDFTitel);
        if (form_isForm=false) then FSIDelete(Set.PDF.CreatorPath+gPDFname+'.pdf');
      end;
  //    else
  //      Dlg_PDFPreview:DirekterDruck(cPDFCPath+form_pdfname+'.pdf', Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);
    end;

  end
  else begin  // KEIN PDFCreator -----------------------------------------------------------------

    if (aVorschau) then begin

      // Vorschau immer auf das gesamte Applikationsfesnter legen...
      gTMP # form_Job->PrtInfo(_PrtFrame);
      if (gTMP <> 0) then begin
        /* 15.03.2010 auskommentiert da nicht benoetigt
        // Vorschau-Zoomstufe Änderungsevent [11.03.2010/PW]
        Erx # gTMP->PrtSearch( 'PpvEdZoomFactor' );
        Erx->WinEvtProcNameSet( _winEvtChanged, 'Lib_Print:EvtZoomFactorChanged' );
        */
        gTMP->WinEvtProcNameSet( _winEvtClose, 'Lib_Print:EvtPrtFrameClose' );
      end;

      if (Frm.Schacht<>'') then
        Form_printer->ppbinsource # cnvia(Frm.Schacht);

      // Aktuellen User holen
      Usr.Username      # gUsername;
      RecRead( 800, 1, 0 );

      // Vorschau anzeigen...
      if (StrFind(Set.Module,'P',0)>0) or (gUsername='DRUCKTEST') then begin
        Erx # form_Job -> PrtJobClose();//_PrtJobXml);
        vPath # Set.Druckerpfad;
        if (vPath='') then begin
          FsiPathCreate(_Sys->spPathTemp+'StahlControl');
          FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
          vPath # _Sys->spPathTemp+'StahlControl\Druck\';
        end;

        vPath   # vPath+'tmp'+AInt(gUserID)+'.Job';
        if (form_Betreff<>'') then  // Formular...
          Dlg_PrintPreview:ShowJob('*'+vPath, form_Betreff, form_Printer, frm.kopien, form_EMA, form_faxNummer)
        else  // Liste...
          Dlg_PrintPreview:ShowJob('*'+vPath, Lfm.Name, 0, 1, form_EMA, form_faxNummer);
        end

      else begin  // internal Job-Preview

        if (HdlInfo(Form_Printer, _HdlExists) <> 0) then // MS 07.03.2012
          Erx # form_Job -> PrtJobClose(_PrtJobPreview, Form_Printer)
        else
          Erx # form_Job -> PrtJobClose(_PrtJobPreview);

      end;

      /* 15.03.2010 Zoomfaktor soll immer aus den fest definierten Usereinstellungen geholt werden
                    diesen werden auch nur durch einen Benutzer in der User-Maske geaendert
      // Vorschau-Zoomstufe speichern [11.03.2010/PW]
      vZoomFact    # Usr.Zoomfaktor;
      Usr.Username # gUsername;
      RecRead( 800, 1, 0 );
      if ( Usr.Zoomfaktor != vZoomFact ) then begin
        if ( RecRead( 800, 1, _recLock ) = _rOk ) then begin
          Usr.Zoomfaktor # vZoomFact;
          RekReplace( 800, _recUnlock );
        end
        else
          Usr.Zoomfaktor # vZoomFact;
      end;
      */
      end
    else begin  // DIREKTDRUCK
      if (form_Printer<>0) then begin
        vDev # form_printer;
        if (Frm.Schacht<>'') then vDev->ppbinsource # cnvia(Frm.Schacht);
        end
      else begin
        vDev # PrtDeviceOpen();    // std.Drucker laden
      end;
      if (Frm.Kopien<=0) then Frm.Kopien # 1;
      if (vDev>0) then vDev->ppcopies # Frm.Kopien;

      // Job ausgeben
      if (vDev=0) then todo('KEIN PRINTER (699) !!!');
      if (form_Job=0) then todo('KEIN JOB (700) !!!')
      else
        form_Job -> PrtJobClose(_PrtJobPrint,vDev);
      if (vDev<>0) then vDev->PrtDeviceclose();
    end;

  end;  // kein PDFCreator


  vArc # Frm.SpeichernYN;
  if (aNoSave) then vArc # n;

  if (vSplash != 0) then begin
    // Fensterzusatz daten extrahieren
    vHdl # Winsearch(vSplash,'lb.printstatus');
    vWinBonus # CnvIA(vHdl->wpCustom);

    vSplash->WinClose();
    vSplash # 0;

    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;

  if (aArcFrage) then begin
    if (Msg(912008,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdyes) then vArc # y;
  end;

  // Archivieren
  if (vArc=false) then begin
    if (gPDFname='') then
      Lib_Dokumente:KillJOB();
    end
  else begin
    if (gPDFname='') then
      Lib_Dokumente:ImportJOB(Frm.Bereich,Frm.Name,Form_DokName,Form_DokSprache, form_FaxNummer, form_EMA)
    else
      Lib_Dokumente:ImportPDF(Set.PDF.CreatorPath+gPDFname+'.pdf', Frm.Bereich, Frm.Name, Form_DokName, Form_DokSprache, form_FaxNummer, form_EMA, true);
  end;

  if (VarInfo(class_Form)<>0) then VarFree(class_Form);

/*
  VarInstance(windowbonus, vInstanz);
*/

  Lib_Tapi:TAPIInitialize();

  RETURN vArc;
end;


//===================================================================================
//  EvtPrtFrameClose
//
//===================================================================================
sub EvtPrtFrameClose( aEvt : event ) : logic
local begin
  Erx : int;
  vI  : int;
end;
begin

   Erx # aEvt:Obj->PrtSearch( 'PpvEdZoomFactor' );
   vI # Erx->wpCaptionInt;
    Usr.Username # gUsername;
    RecRead( 800, 1, 0 );
    if ( Usr.Zoomfaktor != vI ) then begin
      if ( RecRead( 800, 1, _recLock ) = _rOk ) then begin
        Usr.Zoomfaktor # vI;
        RekReplace( 800, _recUnlock,'AUTO' );
      end
      else
        Usr.Zoomfaktor # vI;
    end;

   RETURN true;
end;


//===================================================================================
//  FrmJobCancel
//  - Bricht einen Druckjob ab
//===================================================================================
Sub FrmJobCancel() : int;
local begin
  Erx       : int;
  vInstanz  : int;
  vSplash   : int;
  vHdl      : int;
  vWinBonus : int;
end;
begin
  Lib_Form:UnloadSubStyleDef();
  Lib_Form:UnloadStyleDef();

  _App->wpWaitcursor # false;
  APPON();
  Lib_Tapi:TAPIInitialize();

  if (form_Job=0) then RETURN 0;
  vInstanz # VarInfo(Windowbonus);

  FrmPageClose();
  Erx # form_Job -> PrtJobClose(_PrtJobCancel);//,Form_Printer)
  // Aktuellen User holen
  Usr.Username      # gUsername;
  RecRead( 800, 1, 0 );

  if (VarInfo(class_Form)<>0) then VarFree(class_Form);
  VarInstance(windowbonus, vInstanz);

  // Splash-Screen anpassen
//  vSplash # Winsearch(gFrmMain,'Frame.Printing');
  vSplash # $Frame.Printing;
  if (vSplash != 0) then begin
    // Fensterzusatz daten extrahieren
    vHdl # Winsearch(vSplash,'lb.printstatus');
    vWinBonus # CnvIA(vHdl->wpCustom);

    vSplash->WinClose();
    vSplash # 0;

    // Fensterdaten Restore
    VarInstance(WindowBonus,vWinBonus);
  end;
  //gFrmMain->winfocusset(false);
  //if (gMDI<>0) then gMDI->Winfocusset(false);
  RETURN 0;
end;


//===================================================================================
//  FrmPrintDialog
//  - Initialisiert die Vorschau
//  !! ACHTUNG !! muss immer aufgerufen werden um das Sprachhandling zu ermöglichen
//                Direktdruck wird bei FrmJobClose eingestellt
//===================================================================================
Sub FrmPrintDialog(
  aName           : alpha;
  opt landscape   : logic;
);
local begin
  vPrtJob   : int;
  vPrtFrame : int;
  vPrtDoc   : int;
  vPrtPage  : int;
end;
begin

  if (form_Job <> 0) then begin

    // Preview-Dialog initialisieren
    vPrtFrame # form_Job->PrtInfo(_PrtFrame);
    if (vPrtFrame > 0) then begin
      vPrtFrame->wpCaption # aName + ' ' + Translate('drucken...');
      vPrtFrame->wpArea    # RectMake(20,20,WinInfo(0,_WinScreenWidth)-40,WinInfo(0,_WinScreenHeight)-60);
      vPrtFrame->WinUpdate(_WinUpdState,_WinDialogMaximized);
    end;

    // PrintDocument ermitteln
    vPrtDoc # form_Job->PrtInfo(_PrtDoc);
    if (vPrtDoc > 0) then begin
      //vPrtDoc->ppZoomFactor  # 100;
      vPrtDoc->ppRuler # _PrtRulerNone;
      if (landscape) then begin
       vPrtDoc->ppOrientation # _PrtOrientlandscape;
      end else begin
        vPrtDoc->ppOrientation # _PrtOrientPortrait;
      end;

      // pdfCREATOR
      if (gPDFName<>'') then begin
        vPrtDoc->ppName   # gPDFName
        gPDFTitel         # aName;
        end
      else begin
        vPrtDoc->ppName   # aName;
      end;
    end;

  end;

end;


//===================================================================================
//  FrmPageOpen
//  - Öffnet eine Seite und gibt den Seitendescriptor zurück
//===================================================================================
Sub FrmPageOpen(): int
begin
  if (form_Job <> 0) then
    RETURN form_Job->PrtJobWrite(_PrtJobPageStart);
end;


//===================================================================================
//  FrmPageClose
//  - Schließt die Seite
//===================================================================================
Sub FrmPageClose(): int
begin
  if (form_Job <> 0) then
    RETURN form_Job->PrtJobWrite(_PrtJobPageEnd);
end;


//========================================================================
//  FFIfNoSpace
//
//========================================================================
Sub FFifNoSpace(
  aElement      : int)
local begin
  vPagePosP   : point;
  vPageMaxP   : point;
  vLine       : int;
  vFussLen    : int;
  vMaxLen     : int;
  vPos        : int;
  vStdFooter  : int;
  vHdl        : int;
  vFont       : Font;
end;
begin

  If (form_Job = 0) or (aElement = 0) then RETURN;

  vPagePosP  # form_Page->ppBoundAdd;
  vPageMaxP  # form_Page->ppBoundMax;

  vFussLen # 0;
  // Seitenfuss drucken
  if (form_useStdFoot) then begin
    vLine       # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.Einzeln');
    vStdFooter  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seitenende');
    if (Set.Druck.Std.FontSz<>0) then begin
      vHdl # vStdFooter->winsearch('ptlText');
      vFont # vHdl->ppFont;
      vFont:size  # Set.Druck.Std.FontSz;
      vHdl->ppFont # vFont;
    end;
    vFussLen    # vLine->ppFormHeight + vStdFooter->ppFormHeight;
    end;
    if (form_Footer <> 0) then begin
      vFussLen # vFussLen + form_Footer->ppFormHeight;
    end;
  if (vLine<>0) then vLine -> PrtFormClose();
  if (vStdFooter<>0) then vStdFooter -> PrtFormClose();
  vFussLen # vFussLen + form_RandUnten + Form_FooterH;

  vMaxLen   # vPageMaxP:y;
  vPos      # vPagePosP:y;
  // genug Platz?
  If (vNoAutoFF=false) and (vPos + (aElement->ppFormHeight) + vFussLen > vMaxLen) then begin
    // passt NICHT auf Seite!!! -> Neue Seite
    if (form_useStdFoot) then Print_LinieEinzeln();
    Print_Seitenende(form_footer);

    // Hintergrundbild "hinterlegen"
    Print_Background();

    form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);

    Print_Seitenkopf(form_Header);

    if (form_useStdHead) then Print_LinieEinzeln();
  end;
end;


//========================================================================
//  LfPrint
//  - Überprüft die Seitenlänge und druckt falls die Seite voll ist bzw.
//    wird, eine neue Seite mit Kopf und das übergebene Element.
//  - Sollte immer als "druckende Funktion" bei Datenelemten aufgerufen
//    werden z.B. bei Positionsdaten, aber nicht bei Seitenköpfen
//========================================================================
Sub LfPrint(
  aElement      : int;
  opt aNoUnload : logic;
)
begin

  // ggf. Seitenwechsel
  FFifNoSpace(aElement);

  form_Page->PrtAdd(aElement, _PrtAddTop);
  if (aNoUnload=n) then aElement->PrtFormClose();

end;


//========================================================================
//  Print_Seitenkopf
//  - Druck den Seitenkopf aus
//========================================================================
Sub Print_Seitenkopf(
  opt aElement : int;
)
local begin
  vHdl      : int;
  vSeite    : int;
  vPLBackup : int;
  vPLNew    : int;
  aSeite    : int;
end;
begin
  If (form_Job = 0) then RETURN;

//  if (Varname(aElement)<>'') then aElement # Class_PrintLine->pls_Hdl;

/***
  // KEIN FAX??
  if (form_OutType<>'F') then begin
//    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Kopf');
    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Druckarea');
/
    vHdl  # PrtSearch(vPrt,'PrtPicture1');
    if (form_OutType<>'') then begin
      if (vHdl<>0) then vHdl->wpCaption # '*'+Set.FAX.Bilddatei;
      if (form_OutType='1') then form_OutType # '';
      end
    else begin
      if (vHdl<>0) then vHdl->wpCaption # '';
    end;
/
    form_Page->PrtAdd(vPrt,0, 0, 0);
    vPrt->PrtFormClose();
    end
  else begin
    // Für Faxkopf Platz machen
    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seite.Fax');
    //if (vHdl<>0) then vHdl->wpCaption # '*'+Set.FAX.Bilddatei;
    // Weil das Bild die gesamte Seite umfassen kann (Fuss UND Kopf)
    // steht in der Customvariable die gewünschte Höhe
    Print_Spacer(CnvFA(vPrt->wpCustom), 'mm');
    vPrt->PrtFormClose();
  end;
****/

//  Print_Spacer(form_RandOben, 'mm');
  Print_Spacer(form_RandOben, 'LE');

  vPLBackup # VarInfo(class_Printline);
  vPLNew # Lib_PrintLine:Create();
  vSeite # form_Job->prtinfo(_PrtJobPageCount)+1;

  if (Frm.Prozedur<>'') then
    Call(Frm.Prozedur+':Seitenkopf', vSeite)
  else if (Lfm.Prozedur<>'') then
    Call(Lfm.Prozedur+':Seitenkopf', vSeite);
  Lib_PrintLine:Destroy(vPLNew);
  if (vPLBackup<>0) then VarInstance(class_Printline, vPLBackup);


  if (vSeite=1) then PrintFaxEmailCode();

  if (aElement <> 0) then begin
    vHdl  # PrtSearch(aElement,'ptSeite');
    if (vHdl<>0) then vHdl->wpCaption # Translate('Seite')+' '+ CnvAi(vSeite);

    Print_Betreff();

    // Element drucken
    form_Page->PrtAdd(aElement,0);
  end;

end;


//========================================================================
//  Print_Betreff
//  - Druck das Standard Betreffselement mit übergebenem Betreff
//
//========================================================================
Sub Print_Betreff(
  opt aBetreff  : alpha;
);
local begin
  vHdl  : int;
  vPrt  : int;
end;begin
  If (form_Job = 0) then RETURN;

  if (aBetreff = '') then begin
    if (form_Betreff = '') then RETURN;
    aBetreff # form_Betreff;
  end
  else
    form_Betreff # aBetreff;

  // Übergebenen Betreff als GROßSCHRIFT formatieren
  StrCnv(aBetreff,_StrUpper);

  // Element anmelden und mit gelesenen Daten füllen
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Betreff');

  vHdl  # PrtSearch(vPrt,'ptBetreff');
  vHdl->wpCaption # aBetreff;

  vHdl  # PrtSearch(vPrt,'ptDatum');
  vHdl->wpCaption # CnvAd(SysDate());

  vHdl  # PrtSearch(vPrt,'ptSeite');
  vHdl->wpCaption # Translate('Seite')+' '+ CnvAi(form_Job->prtinfo(_PrtJobPageCount)+1);

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt,0);
  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_FF
//  - Bricht die Seite sofort um
//========================================================================
Sub Print_FF;
begin
  if (form_useStdFoot) then Print_LinieEinzeln();

  Print_Seitenende(form_footer);

  // Hintergrundbild "hinterlegen"
  Print_Background();

  form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);

  Print_Seitenkopf(form_Header);

  if (form_useStdHead) then Print_LinieEinzeln();
end;


//========================================================================
//  Print_LinieEinzeln
//  - Druck eine Trennlinie aus
//========================================================================
Sub Print_LinieEinzeln(
  opt aX    : float;
  opt aXX   : float;
  opt aY    : int;
  opt aIX   : int;
  opt aIXX  : int;
)
local begin
  vHdl      : int;
  vPrt      : int;
  vPagePosP : point;
  vPos      : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.Einzeln');

  if (aX<>0.0) or (aXX<>0.0) or (aIX<>0) or (aIXX<>0) then begin
    vHdl # Winsearch(vPrt,'PrtDivider0');
    vHdl->pparealeft  # PrtUnitLog(aX,_PrtUnitMillimetres) + aIX
    vHdl->pparearight # PrtUnitLog(aXX,_PrtUnitMillimetres) + aIXX;
  end;

//  vPagePosP  # form_Page->ppBoundAdd;
//  vPos      # vPagePosP:y;
  // Element drucken und schließen
  if (aY<>0) then
    form_Page->PrtAdd(vPrt, _PrtAddTop, aY);
  else
    form_Page->PrtAdd(vPrt, _PrtAddTop);

  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_LinieDoppelt
//  - Druck eine Trennlinie aus
//========================================================================
Sub Print_LinieDoppelt(
  opt aX  : float;
  opt aXX : float;
)
local begin
  vHdl  : int;
  vPrt  : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.Doppelt');

  if (aX<>0.0) or (aXX<>0.0) then begin
    vHdl # Winsearch(vPrt,'PrtDivider0');
    vHdl->pparealeft  # PrtUnitLog(aX,_PrtUnitMillimetres);
    vHdl->pparearight # PrtUnitLog(aXX,_PrtUnitMillimetres);
    vHdl # Winsearch(vPrt,'PrtDivider1');
    vHdl->pparealeft  # PrtUnitLog(aX,_PrtUnitMillimetres);
    vHdl->pparearight # PrtUnitLog(aXX,_PrtUnitMillimetres);
  end;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt, _PrtAddTop);
  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_LinieVEinzeln
//  - Druck eine VERTIKALE Trennlinie aus
//  Das muss UNTER der Position passieren, da sonst der Cursor tiefer wandert
//========================================================================
Sub Print_LinieVEinzeln(
  aX  : float;
  aYY : float;
)
local begin
  vHdl  : int;
  vPrt  : int;
  vUsed : point;
  vY    : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.V.Einzeln');

  vUsed # form_Page->ppBoundAdd;
  vY # vUsed:y - PrtUnitLog(aYY,_PrtUnitMillimetres);

  vHdl # Winsearch(vPrt,'PrtDivider0');
  vHdl->ppareaBottom  # PrtUnitLog(aYY,_PrtUnitMillimetres);

  vUsed # form_Page->ppBoundAdd;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt,_PrtAddTop, vY, PrtUnitLog(aX,_PrtUnitMillimetres));

  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_LinieVBis
//  - Druck eine VERTIKALE Trennlinie aus
//  Das muss UNTER der Position passieren, da sonst der Cursor tiefer wandert
//========================================================================
Sub Print_LinieVBis(
  aX  : float;
  aY  : float;
)
local begin
  vHdl  : int;
  vPrt  : int;
  vUsed : point;
  vY    : int;
  vH    : float;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.V.Einzeln');

  vUsed # form_Page->ppBoundAdd;
  vH # PrtUnit(vUsed:Y, _PrtUnitMillimetres) - aY;
  vY # vUsed:y - PrtUnitLog(vH,_PrtUnitMillimetres);

  vHdl # Winsearch(vPrt,'PrtDivider0');
  vHdl->ppareaBottom  # PrtUnitLog(vH,_PrtUnitMillimetres);

  vUsed # form_Page->ppBoundAdd;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt,_PrtAddTop, vY, PrtUnitLog(aX,_PrtUnitMillimetres));

  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_Spacer
//  - Druck eine leerzeile (1 cm) aus
//    oder eine Leerzeil mit Höhe aHeight
//========================================================================
Sub Print_Spacer(
  opt aHeight  : float;        // Position mit Einheit [aUnit]
  opt aUnit : alpha;        // Einheit der Eingabe (z.b 'cm', 'pp' etc.)
)
local begin
  vPrt : int;
end;
begin
  If (form_Job = 0) then RETURN;
  if (aHeight = 0.0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.SPACER_1cm');

  if (aHeight <> 0.0) then begin

    if (aUnit = '') then
      aUnit # 'mm';

    // Höhe verändern (Einheiten umrechnen)
    vPrt->ppFormHeight # CnvIF(rnd(Lib_Einheiten:LaengenKonv(aUnit,'LE',aHeight)));
  end;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt,0);
  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_TextZeile
//  - Druck eine Textzeile mit übergebenem Text aus
//========================================================================
Sub Print_Textzeile(
  aText : alpha(250);
)
local begin
  vHdl  : int;
  vPrt  : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Textzeile');

  vHdl  # PrtSearch(vPrt,'ptText');
  vHdl->wpCaption # Translate(aText);

  // Element drucken und schließen
  LfPrint(vPrt);
end;



//========================================================================
//  Print_Custom
//  - Druck das übergebene Druckelement aus, Mit Längencheck
//========================================================================
Sub Print_Custom(
  aFrmElem      : alpha;
)
local begin
  vHdl  : int;
  vPrt  : int;
  vLang : alpha;
end;
begin
  If (form_Job = 0) or (aFrmElem = '') then RETURN;

  vLang # form_lang;//FrmGetLang();
  if (vLang = 'D' or vlang = '') then vLang # '' else
    vLang # '.' + vLang;

  // Element anmelden
  try begin
    vPrt  # PrtFormOpen(_PrtTypePrintForm,aFrmElem + vLang);
  end;

  // Element drucken und schließen
  LfPrint(vPrt);
end;


//========================================================================
//  Print_Seitenende
//  - Druck eine Textzeile mit übergebenem Text aus
//========================================================================
Sub Print_Seitenende(
  aElement : int;
)
local begin
  vHdl      : int;
  vPrt      : int;
  vLang     : alpha;
  vPLBackup : int;
  vPLNew    : int;
  vFont     : font;
  vP        : point;
end;
begin

  If (form_Job = 0) then RETURN;

  // keine weiteren Zeilenumbrüche im Fuss
  vNoAutoFF # true;

  if (aElement <> 0) then begin
    // Element drucken
    form_Page->PrtAdd(aElement,0);
  end;


  // LISTENDRUCK???
  if (Frm.Prozedur='') then begin
  end;


  // 22.11.2012 AI: Sietenfuss an den unteren Rand schieben
  if (Form_FooterH<>0) then begin
    // Seitenende nach unten schieben
    vP # Form_Page->ppBoundAdd;
    vP:y # form_Page->ppBoundMax:y - (form_RandUnten + Form_FooterH);// - 10000;
    Form_Page->ppBOundAdd # vP;
  end;


  // kein Standardfuss? (oder Liste!)
  if (form_useStdFoot=n) then begin

    // ggf. neue PrintLine um aktuelle Zeile nicht zu vergessen für nächste Seite!
    if (VarInfo(Class_PrintLine)>0) then begin
      vPLBackup # VarInfo(class_Printline);
      vPLNew    # Lib_PrintLine:Create();
    end;
    TRY begin
      if (Frm.Prozedur<>'') then
        Call(Frm.Prozedur+':SeitenFuss', form_Job->prtinfo(_PrtJobPageCount)+1)
      else if (Lfm.Prozedur<>'') then
        Call(Lfm.Prozedur+':SeitenFuss', form_Job->prtinfo(_PrtJobPageCount)+1);
    end;

    // PL-Restore
    if (vPLBackup<>0) then begin
      Lib_PrintLine:Destroy(vPLNew);
      VarInstance(class_Printline, vPLBackup);
    end;

    // Zeilenumbrüche wieder aktivieren
    vNoAutoFF # false;

    RETURN;
  end;

  vLang # form_Lang;//FrmGetLang();
  if (vLang = 'D') or (vLang='') then vLang # '' else
    vLang # '.' + vLang;

  // Element anmelden
  try begin
    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seitenende' + vLang);
    if (Set.Druck.Std.FontSz<>0) then begin
      vHdl # vPrt->winsearch('ptlText');
      vFont # vHdl->ppFont;
      vFont:size  # Set.Druck.Std.FontSz;
      vHdl->ppFont # vFont;
    end;
  end;

  // Element drucken und schließen
  if (ErrGet() = _ErrOk) then begin
    form_Page->PrtAdd(vPrt, _PrtAddtop);
    if (Frm.Prozedur<>'') then begin
      vPLBackup # VarInfo(class_Printline);
      vPLNew # Lib_PrintLine:Create();
      TRY begin
        if (Frm.Prozedur<>'') then
          Call(Frm.Prozedur+':SeitenFuss', form_Job->prtinfo(_PrtJobPageCount)+1)
        else if (Lfm.Prozedur<>'') then
          Call(Lfm.Prozedur+':SeitenFuss', form_Job->prtinfo(_PrtJobPageCount)+1);
      end;
      Lib_PrintLine:Destroy(vPLNew);
      if (vPLBackup<>0) then VarInstance(class_Printline, vPLBackup);
    end;

    vPrt->PrtFormClose();
  end;

  // Zeilenumbrüche wieder aktivieren
  vNoAutoFF # false;
end;


//========================================================================
//  Print_TextOnPos
//  - Wie Print_TextZeile, jedoch mit linksseitiger Einrückung (aPos)
//  - Unterstützt die gleichen Einheiten wie die Funktion
//    Lib_Berechnungen:LaengenKonv
//========================================================================
Sub Print_TextOnPos(
  aText : alpha;        // Zu druckender Text
  aPos  : float;        // Position mit Einheit [aUnit]
  aUnit : alpha;        // Einheit der Eingabe (z.b 'cm', 'pp' etc.)
  opt aBold   : logic;  // optional: Fettdruck
  opt aItal   : logic;  // optional: Kursivdruck
  opt aStroke : logic;  // optional: Unterstreichen
)
local begin
  vTemp     : float;
  vFont     : font;
  vHdl  : int;
  vPrt  : int;
end;
begin
  If (form_Job = 0) then RETURN;

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Textzeile');

  vHdl  # PrtSearch(vPrt,'ptText');

  // Umrechnen in Einheit
  vHdl->wpAreaLeft # CnvIF(rnd(Lib_Einheiten:LaengenKonv(aUnit,'LE',aPos)));
  vHdl->wpCaption # Translate(aText);

  vFont # vHdl->wpFont;

  if (aBold = true) then
    vFont:Attributes # vFont:Attributes | _WinFontAttrBold;
  if (aItal = true) then
    vFont:Attributes # vFont:Attributes | _WinFontAttrItalic;
  if (aStroke = true) then
    vFont:Attributes # vFont:Attributes | _WinFontAttrUnderline;

  vHdl->wpFont # vFont;

  // Element drucken und schließen
  LfPrint(vPrt);
end;


//========================================================================
//  _FillPrtRTF
//========================================================================
sub _FillPrtRtf(
  aHdlPrtRtf : int;   // Deskriptor des PrtRtf-Objektes
  aRange     : range; // Bereich der zugewiesen werden soll
) : range             // Bereich der dargestellt werden kann
local begin
  vRange : range;
end
begin
  // gesamten Bereich zuweisen und Bereich neu berechnen
  aHdlPrtRtf->ppRange(_RtfRangeUpdate) # aRange;

  // Bereich der zugewiesen werden konnte
  vRange # aHdlPrtRtf->ppRange;

//debug('Fill:'+cnvai(vRange:min)+' - '+cnvai(vRange:Max)+'      MaxInt: '+cnvai(aHdlPrtRTF->wpMaxInt));

  // erste Zeile ist leer??
  if (vRange:min + vRange:max = 0) then begin
    vRange # RangeMake(0,0);
    RETURN(vRange);
  end;

  // Konnte bis zum Ende des Textes gedruckt werden?
// Org:  if ((tRange:max = aHdlPrtRtf->wpMaxInt) OR (tRange:max <= tRange:min))
// AI:   if ((vRange:max+1 >= aHdlPrtRtf->wpMaxInt) OR (vRange:max <= vRange:min)) then begin
  if ((vRange:max+1 >= aHdlPrtRtf->wpMaxInt) OR (vRange:max <= vRange:min)) then begin
    // Das Range-Maximum mit -1 belegen
    vRange # RangeMake(aRange:min,-1);
  end;
  RETURN(vRange);

end;


//========================================================================
//  Print_Textbausetein
//
//========================================================================
Sub Print_Textbaustein(
  aText         : alpha;
  opt aX        : float;
  opt aXX       : float;
  opt aIX       : int;
  opt aIXX      : int;
)
local begin
  vElement  : alpha;
  vPagePosP   : point;
  vPageMaxP   : point;
  vLine       : int;
  vFussLen    : int;
  vLS         : logic;
  vMaxLen     : int;
  vPos        : int;
  vFAXKopf    : alpha;

  vRtf        : int;
  vForm       : int;
  vGesamt     : int;
  vStart      : int;
  vEnde       : int;

  vPagePrintArea : point;     // Größe der Seite
  vTextPart      : range;     // Textbereich

  vStdFooter  : int;
  vHdl        : int;
  vFont       : font;
  vDummy      : int;

  vMaxX       : float;      // Maximaler Rechter Abstand
end;

begin

//RETURN; // ALLES MIST RTF-Fehler !!!

  If (Form_Job = 0) then RETURN;

  vElement # 'xFRM.RtfText';

  vFussLen # 0;
  // Seitenfuss drucken
  if (form_useStdFoot) then begin
    vLine       # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.Einzeln');
    vStdFooter  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seitenende');
    if (Set.Druck.Std.FontSz<>0) then begin
      vHdl # vStdFooter->winsearch('ptlText');
      vFont # vHdl->ppFont;
      vFont:size  # Set.Druck.Std.FontSz;
      vHdl->ppFont # vFont;
    end;
    vFussLen    # vLine->ppFormHeight + vStdFooter->ppFormHeight;
  end;
  if (form_Footer <> 0) then begin
    vFussLen # vFussLen + form_Footer->ppFormHeight;
  end;
  if (vLine<>0) then vLine -> PrtFormClose();
  if (vStdFooter<>0) then vStdFooter -> PrtFormClose();
  vFussLen # vFussLen + form_RandUnten + Form_FooterH;

  // Druckjob erzeugen
  // PrintForm laden
  vForm # PrtFormOpen(_PrtTypePrintForm,vElement);
  // Deskriptor des PrtRtf-Objekts ermitteln
  vRTF # vForm->WinSearch('PrtRtfText');
  vRTF->ppAreaLeft # PrtUnitLog(aX, _PrtUnitMillimetres) + aIX;

  // Quelle des Textes und Name des Textes setzen
  vRtf->ppStreamSource  # _WinStreamNameText;
  vRtf->ppFileName      # aText;
  vRtf->ppPrtDevice     # Form_Printer;

  // Zur Verfügung stehenden Bereich auf der Seite ermitteln und Textbereich anpassen
  vPagePrintArea # Form_Page->ppBoundMax;

  // ST 2012-11-06: Bugfix Standardformulare(A4 Hochkant)
  if (aIXX=0) then begin
    vMaxX # aX + 150.0;
    if (aXX <= 0.0) then
      aXX # vMaxX;
  end;

  vRTF->ppAreaRight   # PrtUnitLog(aXX, _PrtUnitMillimetres) + aIXX;
//  vRTF->ppAreaRight   # aIXX;//PrtUnitLog(120.0, _PrtUnitMillimetres);

//debug('seitenmax:'+cnvai(vPagePrintArea:y));
//debug('aktpos:'+cnvai(form_Page->ppBoundAdd:y));
//debug('fusslen:'+cnvai(vFusslen))
  vRTF->ppAreaBottom  # (vPagePrintArea:y) - (form_Page->ppBoundAdd:y) - vFussLen -cMarginBottom;
//debug('RTF bottom:'+cnvai(vRTF->ppAreaBottom));

  // Bereich der in einem PrtRtf-Objekt gedruckt werden kann setzen und ermitteln
  vTextPart # _FillPrtRtf(vRTF,RangeMake(0,-1));

  // überhaupt irgendwas zu drucken??
//  if (vTextPart:Min<>0) or (vTextPart:Max<>0) then begin
  if (1=1) then begin // 31.01.2011 AI

    vRTF->ppAutoSize    # true;
  //  vForm->ppFormHeight # 1; // Textbereich verkleinern
    vRTF->ppAutoSize    # false; // 15.01.2008

    // Textbereich drucken
    form_Page->PrtAdd(vForm);

    WHILE (vTextPart:max != -1) do begin

      if (form_useStdFoot) then Print_LinieEinzeln();
      Print_Seitenende(form_footer);

      // Hintergrundbild "hinterlegen"
      Print_Background();

      // Solange der gesamte Text noch nicht gedruckt wurde:
      // Seitenumbruch hinzufügen
      form_Page # form_Job->PrtJobWrite(_PrtJobPageBreak);
      Print_Seitenkopf(form_Header);

      if (form_useStdHead) then Print_LinieEinzeln();

      // nächsten Bereich setzen und ermitteln
      // Zur Verfügung stehenden Bereich auf der Seite ermitteln und Textbereich anpassen
      vPagePrintArea # Form_Page->ppBoundMax;
      vRTF->ppAreaRight   # PrtUnitLog(aXX, _PrtUnitMillimetres) + aIXX;
      vRTF->ppAreaBottom  # (vPagePrintArea:y) - (form_Page->ppBoundAdd:y) - cMarginBottom - vFussLen;

      // Bereich der in einem PrtRtf-Objekt gedruckt werden kann setzen und ermitteln
      // wenn RTF gerade so eben NICHT passte, nochmal von Vorne anfangen...
      if (vTextPart:max = 0) then
        vTextPart # _FillPrtRtf(vRTF,RangeMake(0,-1))
      else
        vTextPart # _FillPrtRtf(vRTF,RangeMake(vTextPart:max+1,-1));

      vRTF->ppAutoSize # true;
  //    vForm->ppFormHeight # 1; // Textbereich verkleinern
      vRTF->ppAutoSize    # false; // 15.01.2008

      // Textbereich drucken
      form_Page->PrtAdd(vForm);
    END;
  end;

  // PrintForm entladen, Druckvorschau anzeigen, Druckdevice schließen
  vForm->PrtFormClose();
end;

/**** VECTORSOFT
    // Zur Verfügung stehenden Bereich auf der Seite ermitteln und Textbereich anpassen
    tPagePrintArea # tHdlPage->ppBoundMax;
    tHdlPrtRtf->ppAreaRight # tPagePrintArea:x;
    tHdlPrtRtf->ppAreaBottom # tPagePrintArea:y;

    // Bereich der in einem PrtRtf-Objekt gedruckt werden kann setzen und ermitteln
    tTextPart # FillPrtRtf(tHdlPrtRtf,RangeMake(0,-1));

    // Textbereich drucken
    tHdlPage->PrtAdd(tHdlPrintForm);
    while (tTextPart:max != -1)
    {
      // Solange der gesamte Text noch nicht gedruckt wurde:
      // Seitenumbruch hinzufügen
      tHdlPage # tHdlPrintJob->PrtJobWrite(_PrtJobPageBreak);
      // nächsten Bereich setzen und ermitteln
      tTextPart # FillPrtRtf(tHdlPrtRtf,RangeMake(tTextPart:max+1,-1));
      // Textbereich drucken
      tHdlPage->PrtAdd(tHdlPrintForm);
    }

    // letzte Seite abschließen
    tHdlPrintJob->PrtJobWrite(_PrtJobPageEnd);
    // PrintForm entladen, Druckvorschau anzeigen, Druckdevice schließen
    tHdlPrintForm->PrtFormClose();
****/


//========================================================================
//  Print_Background
//
//========================================================================
Sub Print_Background()
local begin
  vHdl  : int;
  vPrt  : int;
  vP    : point;
  vX    : int;
end;
begin

  if (form_OutType='') then RETURN;

  if (form_OutType='-F') or (form_OutType='F') or (form_OutType='E') then begin
    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seite.Fax');
    end
  else begin
    vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.Seite.Druck');
  end;

  vP # Form_Page->ppBoundMax;
  vX # vP:x;
  vPrt->ppFormwidth # vX;//PrtUnitLog(vX,_PrtUnitMillimetres);

  vHdl  # PrtSearch(vPrt,'PrtPicture0');
  if (vHdl<>0) and (form_Background<>'') then begin
    vHdl->ppAreaRight # vX;
  vHdl->ppPicturemode # _WinPictCenter;   // 14.03.2021 <<<<<<<<<< FIX

    // 18.11.2013 AH
//    vHdl->wpCaption # '*' + form_Background;


    // 05.02.2014 AH Abosult oder relativ
    if (StrFind(form_Background,':',0)>0) or (StrCut(Form_Background,1,2)='\\') then
      vHdl->wpCaption # '*' + form_Background
    else
      vHdl->wpCaption # '*' + gFsiClientPath+'\'+form_Background;


//    vHdl->wpCaption # '*' + Set.FAX.Bilddatei;
  end;

  form_Page->PrtAdd(vPrt,0, 0, 0);
  vPrt->PrtFormClose();

end;


//========================================================================
//  Print_PDF
//
//========================================================================
Sub Print_Pdf(aFileName : alpha(250))
local begin
  vPrt  : int;
  vHdl  : int;
  vI    : int;
end;
begin
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'PdfForm');

  vHdl  # PrtSearch(vPrt,'PrtPdf0');
  if (vHdl<>0) then begin
    vHdl->ppFileName # aFileName;
    for vI # 1 loop inc(vI) while (vI<=vHdl->ppPagecount) do begin
      vHdl->ppcurrentint # vI;
      form_Page->PrtAdd(vPrt,_PrtAddPageBreak, 0, -PrtUnitLog(0.5,_PrtUnitCentimetres));
    end;
  end;

  vPrt->PrtFormClose();
end;


//========================================================================
//  Print_Text
//
//========================================================================
sub Print_Text(
  aName     : alpha;
  opt aLang : int;
  opt aX    : float;
  opt aXX   : float;
  opt aIX   : int;
  opt aIXX  : int;
);
local begin
  vTxtHdlTmp1         : int;
  vTxtHdlTmp2         : int;
  vTxtHdlTmp3         : int;
  vTxtHdlTmp4         : int;
  vTxtHdlTmp5         : int;
  vTxtHdlTmpRTF       : int;
  vTxtHdlName         : alpha;

  vFontName           : alpha;
  vFontSize           : int;
  vFontAttr           : int;

  vTxtHdl             : int;
  vI                  : int;
end;
begin

  // ggf. Font aus PrintLine übernehmen
  if (VarInfo(class_Printline)<>0) then begin
    vFontName # pls_FontName;
    vFontsize # pls_FontSize;
    vFontAttr # pls_FontAttr;
  end;

  vTxtHdlTmp1   # TextOpen(160);    // Ascitextpuffer
  vTxtHdlTmp2   # TextOpen(160);    // Ascitextpuffer
  vTxtHdlTmp3   # TextOpen(160);    // Ascitextpuffer
  vTxtHdlTmp4   # TextOpen(160);    // Ascitextpuffer
  vTxtHdlTmp5   # TextOpen(160);    // Ascitextpuffer
  vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
  Lib_Texte:TxtLoad5Buf(aName,vTxtHdlTmp1,vTxtHdlTmp2,vTxtHdlTmp3,vTxtHdlTmp4,vTxtHdlTmp5);

/***
  // NEU wegen RTF-Fehler
  case aLang of
    2 : vTxtHdl # vTxtHdlTmp2;
    3 : vTxtHdl # vTxtHdlTmp3;
    4 : vTxtHdl # vTxtHdlTmp4;
    5 : vTxtHdl # vTxtHdlTmp5;
    otherwise   vTxtHdl # vTxtHdlTmp1;
  end;
  FOR vI # 1 LOOP inc(vI) WHILE (vI<=TextInfo(vTxtHdl,_TextLines)) do begin
    Lib_PrintLine:Print(vTxtHdl->TextLineRead(vI,0) , aX, aXX);
    Lib_PrintLine:PrintLine();
  END;
***/
/*** ALT über RTF*/
  case aLang of
    2 : Lib_Texte:Txt2Rtf(vTxtHdlTmp2,vTxtHdlTmpRTF, vFontName, vFontSize, vFontAttr);
    3 : Lib_Texte:Txt2Rtf(vTxtHdlTmp3,vTxtHdlTmpRTF, vFontname, vFontSize, vFontAttr);
    4 : Lib_Texte:Txt2Rtf(vTxtHdlTmp4,vTxtHdlTmpRTF, vFontname, vFontSize, vFontAttr);
    5 : Lib_Texte:Txt2Rtf(vTxtHdlTmp5,vTxtHdlTmpRTF, vFontname, vFontSize, vFontAttr);
    otherwise Lib_Texte:Txt2Rtf(vTxtHdlTmp1,vTxtHdlTmpRTF, vFontname, vFontSize, vFontAttr);
  end;
  vTxtHdlName # '~TMP.RTF.' + UserInfo(_UserCurrent);
  TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
  if (TextInfo(vTxtHdlTmp1,_TextLines) > 0) then
    Print_Textbaustein(vTxtHdlName,aX, aXX, aIX, aIXX);
/***/

  TextClose(vTxtHdlTmpRTF);
  TextClose(vTxtHdlTmp1);
  TxtDelete(vTxtHdlName,0);
end;


//========================================================================
//  Print_TextBuffer
//
//========================================================================
sub Print_TextBuffer(
  aTxtHdl : int;
  opt aX  : float;
  opt aXX : Float;
);
local begin
  vTxtHdlTmpRTF       : int;
  vTxtHdlName         : alpha;
  vI                  : int;
end;
begin

  // NEU
  FOR vI # 1 LOOP inc(vI) WHILE (vI<=TextInfo(aTxtHdl,_TextLines)) do begin
    Lib_PrintLine:Print(aTxtHdl->TextLineRead(vI,0) , aX, aXX);
    Lib_PrintLine:PrintLine();
  END;

/* ALT
  vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer
  Lib_Texte:Txt2Rtf(aTxtHdl,vTxtHdlTmpRTF);
  vTxtHdlName # '~TMP.RTF.' + UserInfo(_UserCurrent);
  TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
  if (TextInfo(aTxtHdl,_TextLines) > 0) then
    Print_Textbaustein(vTxtHdlName,aX, aXX);
  TextClose(vTxtHdlTmpRTF);
  TxtDelete(vTxtHdlName,0);
*/
end;


//===================================================================================
//  Print_TextAbsolut
//      druckt einen Text an eine Koordinate OHNE auf Seitenlänge zu achten
//===================================================================================
Sub Print_TextAbsolut(
   aText          : alpha(1000);
   aX             : float;
   aY             : float;
   opt aFontSize  : int;
   opt aFontAttr  : int;
   opt aFontName  : alpha;
)
local begin
  vX        : int;
  vY        : int;
  vHdl      : int;
  vPrt      : int;
  vFont     : font;
  vRect     : rect;
end;
begin
  If (form_Job = 0) then RETURN;

  aX # aX - 1.0;
  aY # aY - 1.0;

  // Adresse an Position aAdrX/aAdrY drucken
  vX # CnvIF(Lib_Einheiten:LaengenKonv('cm','LE',aX));
  vY # CnvIF(Lib_Einheiten:LaengenKonv('cm','LE',aY));


  vPrt # PrtFormOpen(_PrtTypePrintForm, 'xFRM.STD.Textzeile');
  vHdl # PrtSearch(vPrt,'ptText');

  if (aFontSize>0) then begin
    vFont # vHdl->ppFont;
    vFont:size  # aFontSize*10;
    vHdl->ppFont # vFont;
  end;

  if (aFontSize<0) then begin
    vRect # vHdl->ppArea;
    vRect:left # 0;
    vHdl->ppArea # vRect;
//    vHdl->ppZOrder # 100;
    vFont # vHdl->ppFont;
    vFont:size  # 5;
    vHdl->ppFont      # vFont;
    vHdl->ppColFg     # _wincolWhite;
    vHdl->ppvertical  # true;

//    vFont:name # 'Invisible.ttf';
//    vFont:name # 'c:\aaa';
//vFont:name # 'wingdingsxx';
//vFont:attributes # _WinFontAttrItalic;
  end;

  vhdl->ppwordbreak   # false;
  vHdl->ppCaption     # Translate(aText);
  vHdl->ppautosize    # y;


  if (aFontAttr<>0) then begin
    vFont # vHdl->ppFont;
    vFont:Attributes # aFontAttr;
    vHdl->ppFont # vFont;
  end;

  if (aFontName <> '') then begin
    vFont # vHdl->ppFont;
    vFont:Name # aFontName;
    vHdl->ppFont # vFont;
  end;

  form_Page->PrtAdd(vPrt, _PrtAddTop, vY, vX);

  vPrt->PrtFormClose();
end;


//===================================================================================
//  Print_LinieAbsolut
//      druckt eine Linie an eine Koordinate
//===================================================================================
Sub Print_LinieAbsolut(
   aX             : float;
   aXX            : float;
   aY             : float;
)
local begin
  vHdl  : int;
  vPrt  : int;
  vX    : int;
  vXX   : int;
  vY    : int;
end;
begin
  If (form_Job = 0) then RETURN;

  aX # aX - 1.0;
  aXX # aXX - 1.0;
  aY # aY - 1.0;

  // Adresse an Position aAdrX/aAdrY drucken
  vX  # CnvIF(Lib_Einheiten:LaengenKonv('cm','LE',aX));
  vXX # CnvIF(Lib_Einheiten:LaengenKonv('cm','LE',aXX));
  vY  # CnvIF(Lib_Einheiten:LaengenKonv('cm','LE',aY));

  // Element anmelden
  vPrt  # PrtFormOpen(_PrtTypePrintForm,'xFRM.STD.Linie.Einzeln');

  if (vX<>0) or (vXX<>0) then begin
    vHdl # Winsearch(vPrt,'PrtDivider0');
    vHdl->pparealeft  # vX;
    vHdl->pparearight # vXX;
  end;

  // Element drucken und schließen
  form_Page->PrtAdd(vPrt, _PrtAddTop, vY, vX);
  vPrt->PrtFormClose();
end;


//===================================================================================
//  GetDefaultPrinter
//      Liefert den Namen des Std. Druckers
//===================================================================================
sub GetDefaultPrinter() : alpha;
local begin
  vHdl  : int;
  vName : alpha;
end;
begin
  vHdl # PrtDeviceOpen();
  vName # vHdl->ppNamePrinter;
  PrtDeviceClose(vHdl);

  RETURN vName;
end;


//========================================================================
//  Print_TextByKeyWords
//    Druckt einen Text nach bestimmten "Schluesselwoertern"
//  Bsp.:
//    Print_TextByKeyWords(vTxtName, '$$RE', 'RE$$', cPosCL, cPosCR, '$$AB;$$LFS', 'AB$$;LFS$$', true); // Rechnungstext
//    Print_TextByKeyWords(vTxtName, '$$AB', 'AB$$', cPosCL, cPosCR, '$$RE;$$LFS', 'RE$$;LFS$$', true); // Auftragsbestaetigungs Text
//    Print_TextByKeyWords(vTxtName, '$$LFS', 'LFS$$', cPosCL, cPosCR, '$$AB;$$RE', 'AB$$;RE$$', true); // Lieferschein Text

//========================================================================
sub Print_TextByKeyWords
(
  aTxtName                  : alpha;
  aKeyWordBegin             : alpha(4000);
  aKeyWordEnd               : alpha(4000);
  aVonPos                   : float;
  aBisPos                   : float;
  opt aBadWordBegin         : alpha(4000);
  opt aBadWordEnd           : alpha(4000);
  opt aPrintAllgemeinenText : logic
);
local begin
  Erx                       : int;
  vTxtName                  : alpha;
  vHdl                      : int;
  vHdl2                     : int;
  vX, vI                    : int;
  vCount                    : int;
  vTokenCount               : int;
  vTextZeile, vText2Print   : alpha(4000);
  vFound                    : logic;
  vKeyWordBegin             : alpha(4000);
  vKeyWordEnd               : alpha(4000);
  vBadWordBegin             : alpha(4000);
  vBadWordEnd               : alpha(4000);
end;
begin
  vFound # false;
  vText2Print # '';
  vX # 0;
  vI # 0;

  vTxtName # aTxtName;
  if(vTxtName <> '') then begin
    vHdl # TextOpen(10);
    vHdl2 # TextOpen(10); // nur "gewuenschter Text"
    Erx # TextRead(vHdl, vTxtName, 0);

    if (Erx > _rLocked) then RETURN;

    vCount      # 1; // Zeilen bei ggf. nur gewuenschten Text
    vTokenCount # 1;
    vKeyWordBegin # Str_Token(aKeyWordBegin, ';', vTokenCount);
    vKeyWordEnd # Str_Token(aKeyWordEnd, ';', vTokenCount);
    WHILE(vKeyWordBegin <> '') and (vKeyWordEnd <> '') DO BEGIN
      vX # TextSearch(vHdl, 1, 1, 0, vKeyWordBegin);
      if (vX <> 0) then begin  //  Text fuer gewuenschten Bereich Markierung entfernen
        vI # vX;
        WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
          vTextZeile # TextLineRead(vHdl, vI, 0);
          if((StrFind(vTextZeile, vKeyWordBegin, 1) > 0) or (vFound = true)) then begin    // Schluesselwort suchen was den Text einleitet
            if(vFound = false) then begin
              vText2Print # Str_ReplaceAll(vTextZeile, vKeyWordBegin, '');
              vFound # true;
              TextLineRead(vHdl, vI,_TextLineDelete);
              if(vText2Print <> '') then begin
                TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
                if(aPrintAllgemeinenText = false) then
                  TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
              end;
              //vI # vI + 1;
              CYCLE;
            end
            else if((StrFind(vTextZeile, vKeyWordEnd, 1) > 0)) then begin                       // Schluesselwort suchen was den Text "abschließt"
              vText2Print # Str_ReplaceAll(vTextZeile, vKeyWordEnd, '');
              TextLineRead(vHdl, vI,_TextLineDelete);
              TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
              if(aPrintAllgemeinenText = false) then begin
                TextLineRead(vHdl2, vCount,_TextLineDelete);
                TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
              end;
              BREAK; // zu druckender Text zuende
            end
            else if(aPrintAllgemeinenText = false) then begin
              vText2Print # vTextZeile;
              TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
            end;

            vI     # vI + 1;
            vCount # vCount + 1;
          end;
        END;
      end; // ########### Text fuer gewuenschten Bereich Markierung entfernen ########

      vTokenCount # vTokenCount + 1;
      vKeyWordBegin # Str_Token(aKeyWordBegin, ';', vTokenCount);
      vKeyWordEnd # Str_Token(aKeyWordEnd, ';', vTokenCount);
      vFound  # false;
    END;

    if(aPrintAllgemeinenText = true) then begin
      vTokenCount # 1;
      vBadWordBegin # Str_Token(aBadWordBegin, ';', vTokenCount);
      vBadWordEnd # Str_Token(aBadWordEnd, ';', vTokenCount);
      WHILE(vBadWordBegin <> '') and (vBadWordEnd <> '') DO BEGIN // nicht gewuenschten Text entfernen
        vX # TextSearch(vHdl, 1, 1, 0, vBadWordBegin);
        if (vX <> 0) then begin
          vI # vX;
          WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
            vTextZeile # TextLineRead(vHdl, vI, 0);
            if((StrFind(vTextZeile, vBadWordEnd, 1) > 0) /*and ((StrFind(vTextZeile, vBadWordBegin, 1) = 0))*/) then begin   // Schluesselwort suchen was den Text "abschließt"
              TextLineRead(vHdl, vI,_TextLineDelete);
              BREAK; // zu druckender Text zuende
            end;
            TextLineRead(vHdl, vI,_TextLineDelete);
          END;
        end;
        // ###############nicht gewuenschten Text entfernen########################
        vTokenCount # vTokenCount + 1;
        vBadWordBegin # Str_Token(aBadWordBegin, ';', vTokenCount);
        vBadWordEnd # Str_Token(aBadWordEnd, ';', vTokenCount);
      END;
    end;

    if(TextInfo(vHdl, _TextLines) > 0) and (aPrintAllgemeinenText = true) then begin // Gewuenschten Text drucken
      TxtWrite(vHdl, MyTmpText, 0);
      Print_Text(MyTmpText, 1, aVonPos, aBisPos);  // drucken
      TxtDelete(MyTmpText,0);
    end
    else if(TextInfo(vHdl2, _TextLines) > 0) then begin
      TxtWrite(vHdl2, MyTmpText, 0);
      Print_Text(MyTmpText, 1, aVonPos, aBisPos);  // drucken
      TxtDelete(MyTmpText,0);
    end;

    TextClose(vHdl);
    TextClose(vHdl2);
  end;
end;



//========================================================================
//  Print_TextByKeyWordsStyle
//    Druckt einen Text nach bestimmten "Schluesselwoertern"
//========================================================================
sub Print_TextByKeyWordsStyle
(
  aTxtName                  : alpha;
  aLangnr                   : int;
  aKeyWordBegin             : alpha(4000);
  aKeyWordEnd               : alpha(4000);
  opt aPrintAllgemeinenText : logic;
  opt aBadWordBegin         : alpha(4000);
  opt aBadWordEnd           : alpha(4000);
);
local begin
  Erx                       : int;
  vTxtName                  : alpha;
  vHdl                      : int;
  vHdl2                     : int;
  vX, vI                    : int;
  vCount                    : int;
  vTokenCount               : int;
  vTextZeile, vText2Print   : alpha(4000);
  vFound                    : logic;
  vKeyWordBegin             : alpha(4000);
  vKeyWordEnd               : alpha(4000);
  vBadWordBegin             : alpha(4000);
  vBadWordEnd               : alpha(4000);
end;
begin
  vFound # false;
  vText2Print # '';
  vX # 0;
  vI # 0;

  vTxtName # aTxtName;
  if(vTxtName <> '') then begin
    vHdl # TextOpen(10);
    vHdl2 # TextOpen(10); // nur "gewuenschter Text"
    Erx # TextRead(vHdl, vTxtName, 0);

    if (Erx > _rLocked) then RETURN;

    vCount      # 1; // Zeilen bei ggf. nur gewuenschten Text
    vTokenCount # 1;
    vKeyWordBegin # Str_Token(aKeyWordBegin, ';', vTokenCount);
    vKeyWordEnd # Str_Token(aKeyWordEnd, ';', vTokenCount);
    WHILE(vKeyWordBegin <> '') and (vKeyWordEnd <> '') DO BEGIN
      vX # TextSearch(vHdl, 1, 1, 0, vKeyWordBegin);
      if (vX <> 0) then begin  //  Text fuer gewuenschten Bereich Markierung entfernen
        vI # vX;
        WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
          vTextZeile # TextLineRead(vHdl, vI, 0);
          if((StrFind(vTextZeile, vKeyWordBegin, 1) > 0) or (vFound = true)) then begin    // Schluesselwort suchen was den Text einleitet
            if(vFound = false) then begin
              vText2Print # Str_ReplaceAll(vTextZeile, vKeyWordBegin, '');
              vFound # true;
              TextLineRead(vHdl, vI,_TextLineDelete);
              if(vText2Print <> '') then begin
                TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
                if(aPrintAllgemeinenText = false) then
                  TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
              end;
              //vI # vI + 1;
              CYCLE;
            end
            else if((StrFind(vTextZeile, vKeyWordEnd, 1) > 0)) then begin                       // Schluesselwort suchen was den Text "abschließt"
              vText2Print # Str_ReplaceAll(vTextZeile, vKeyWordEnd, '');
              TextLineRead(vHdl, vI,_TextLineDelete);
              TextLineWrite(vHdl, vI, vText2Print,_TextLineInsert);
              if(aPrintAllgemeinenText = false) then begin
                TextLineRead(vHdl2, vCount,_TextLineDelete);
                TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
              end;
              BREAK; // zu druckender Text zuende
            end
            else if(aPrintAllgemeinenText = false) then begin
              vText2Print # vTextZeile;
              TextLineWrite(vHdl2, vCount, vText2Print,_TextLineInsert);
            end;

            vI     # vI + 1;
            vCount # vCount + 1;
          end;
        END;
      end; // ########### Text fuer gewuenschten Bereich Markierung entfernen ########

      vTokenCount # vTokenCount + 1;
      vKeyWordBegin # Str_Token(aKeyWordBegin, ';', vTokenCount);
      vKeyWordEnd # Str_Token(aKeyWordEnd, ';', vTokenCount);
      vFound  # false;
    END;

    if(aPrintAllgemeinenText = true) then begin
      vTokenCount # 1;
      vBadWordBegin # Str_Token(aBadWordBegin, ';', vTokenCount);
      vBadWordEnd # Str_Token(aBadWordEnd, ';', vTokenCount);
      WHILE(vBadWordBegin <> '') and (vBadWordEnd <> '') DO BEGIN // nicht gewuenschten Text entfernen
        vX # TextSearch(vHdl, 1, 1, 0, vBadWordBegin);
        if (vX <> 0) then begin
          vI # vX;
          WHILE (TextInfo(vHdl, _TextLines) >= vI) DO BEGIN
            vTextZeile # TextLineRead(vHdl, vI, 0);
            if((StrFind(vTextZeile, vBadWordEnd, 1) > 0) /*and ((StrFind(vTextZeile, vBadWordBegin, 1) = 0))*/) then begin   // Schluesselwort suchen was den Text "abschließt"
              TextLineRead(vHdl, vI,_TextLineDelete);
              BREAK; // zu druckender Text zuende
            end;
            TextLineRead(vHdl, vI,_TextLineDelete);
          END;
        end;
        // ###############nicht gewuenschten Text entfernen########################
        vTokenCount # vTokenCount + 1;
        vBadWordBegin # Str_Token(aBadWordBegin, ';', vTokenCount);
        vBadWordEnd # Str_Token(aBadWordEnd, ';', vTokenCount);
      END;
    end;

    if(TextInfo(vHdl, _TextLines) > 0) and (aPrintAllgemeinenText = true) then begin // Gewuenschten Text drucken
      TxtWrite(vHdl, MyTmpText, 0);
      Lib_Form:PrintText(MyTmpText, aLangnr);  // drucken
      TxtDelete(MyTmpText,0);
    end
    else if(TextInfo(vHdl2, _TextLines) > 0) then begin
      TxtWrite(vHdl2, MyTmpText, 0);
      Lib_Form:PrintText(MyTmpText, aLangnr);  // drucken
      TxtDelete(MyTmpText,0);
    end;

    TextClose(vHdl);
    TextClose(vHdl2);
  end;
end;


//========================================================================
//========================================================================
