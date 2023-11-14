@A+
//===== Business-Control =================================================
//
//  Prozedur  test+2
//
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_global
@I:Def_Aktionen
@I:Struct_PartSel
@I:Def_Kontakte
@I:C16_SysSOAPInc
@I:Def_BAG

define begin
  cSatzEnde   : Strchar(13)+Strchar(10)
//  cCRLF       : Strchar(13)+Strchar(10)
  cTrans      : '"'
  Write(a)    : begin vOut # Lib_Strings:Strings_Dos2Win(a,n);  FsiWrite(aFile,vOut); end
  mytodo(a,b) : WinDialogBox(0,a,b,0,0,0);
  mydebug(a)  : lib_debug:dbg_Debug(a)
  c_EXCEL_CSV_CONVERTER : gFsiClientPath + '\dlls\ExcelToCSVConverter.exe'

  XML_NodeA(a,b,c)    : Lib_XML:NewNode(a,b,c)
  XML_NodeI(a,b,c)    : Lib_XML:NewNode(a,b, cnvai(c,_FmtNumNoGroup))
  XML_NodeF(a,b,c)    : Lib_XML:NewNode(a,b, cnvaF(c,_FmtNumNoGroup|_FmtNumPoint,0,2))
  XML_NodeB(a,b,c)    : Lib_XML:NewNodeB(a,b,c)
  XML_NodeD(a,b,c)    : Lib_XML:NewNodeD(a,b,c)
  XML_NodeT(a,b,c)    : Lib_XML:NewNode(a,b, cnvat(c,_FmtTimeSeconds))
end;

local begin
  gX  : int[5];
  gA  : alpha[5]
end;

declare TestOutlook();
declare TestSel();
declare CopyBA(aVon : int; aNr : int)
declare ProcsMitErg()
//========================================================================
//========================================================================
sub _Test(
  aT1 : alpha;
  aT2 : alpha;
  aT3 : alpha;
  aT4 : alpha;
  a1  : float;
  a2  : float;
  a3  : float;
  a4  : float);
begin
  aT2 # '   '+aT2;
  aT3 # '   '+aT3;
  aT4 # '   '+aT4;
  debug(aT1+cnvaf(a1,0,0,2,8)+aT2+cnvaf(a2,0,0,2,8)+aT3+cnvaf(a3,0,0,2,8)+aT4+cnvaf(a4,0,0,2,8));
end;

//========================================================================
sub afxtest(aPara : alpha) : int
begin
debugx('set RETURN -105; Result 555');
  AfxRes # 555;
  RETURN -105;
end;


//========================================================================
// call Test+2:CheckPrinter
//========================================================================
sub CheckPrinter() : logic;
local begin
  vHdl : int;
end;
begin
debugx('Start');
  vHdl # PrtDeviceOpen('Microsoft Print to PDF', _PrtDeviceSystem);
//  vHdl # PrtDeviceOpen('\\WW\RW2', _PrtDeviceSystem);
  if (vHdl > 0) then begin
debugx('GUT!');
PrtDeviceclose(vHdl);
    //PrtJobClose(vHdl, _PrtJobCancel);
    RETURN true;
  end;
debugx('Schlecht');
  RETURN false;
end;


//========================================================================
MAIN ()
local begin
  Erx   : int;
  vBig  : bigint;
  vDat  : date;
  vWB   : int;
  vI,vJ,vK : int;
  vHdl  : int;
  vHdl2 : int;
  vOpt  : int;
  vA,vB : alpha(1000);
  vRect : rect;
  vF    : float;
  vOK   : logic;
  vObj  : int;

  vMaxTds : int;
  aDatei  : int;
  vTds    : int;
  vMaxFld : int;
  vFld    : int;
  vSize   : int;


  vSOAP         : int;
  vSOAPBody     : int;
  vSOAPElement  : int;
  vErr          : int;
  VRes          : alpha;
  vErg          : int;
  vTxt          : int;

  vDir2     : int;
  vSubDir2  : int;
  vDatei2   : int;
  vDir1     : int;
  vSubDir1  : int;
  vDatei1   : int;
  vDirName  : alpha;
  vFileName : alpha;
  v903 : int;

  vMoment : caltime;
  vBuf    : int;
  vStoDir : int;
  vStoObj : alpha;
  vCmd    : handle;
  vDoc    : int;
  vRoot   : int;
  vNode   : int;
  vNode2  : int;
  vErrA   : alpha(1000);
  vName   : alpha(1000);
  vName2  : alpha(1000);
  vDia    : int;
  vMsg    : int;
  vFile   : int;
  vFile2  : int;
  vMem    : handle;

  vTim    : time;
  vDatei  : int;
end;
begin
//Todo(Userinfo(_Usercurrent));
//Todo(Userinfo(_UserName));
//Todo(Userinfo(_UserSysName));
//Todo(Userinfo(_UserSysNameIP));
//todo(aint(usr_data:COuntThisUserThisPc()));
//RETURN;
/***
TRANSON;
  RecRead(100,1,_RecFirst|_recLock);
  Rekreplace(100);

  TRANSON;
    RecRead(101,1,_RecFirst|_recLock);
    Rekreplace(101);
    RecRead(101,1,_RecNext|_recLock);
    Rekreplace(101);
    RecRead(101,1,_RecNext|_recLock);
    Rekreplace(101);
  TRANSOFF;

  TRANSON;
    RecRead(102,1,_RecFirst|_recLock);
    Rekreplace(102);
    RecRead(102,1,_RecNext|_recLock);
    Rekreplace(102);
  TRANSBRK;

  TRANSON;
    RecRead(103,1,_RecFirst|_recLock);
    Rekreplace(103);
    RecRead(103,1,_RecNext|_recLock);
    Rekreplace(103);
    RecRead(103,1,_RecNext|_recLock);
    Rekreplace(103);

    TRANSON;
      RecRead(104,1,_RecFirst|_recLock);
      Rekreplace(104);
      RecRead(104,1,_RecNext|_recLock);
      Rekreplace(104);
      RecRead(104,1,_RecNext|_recLock);
      Rekreplace(104);
    TRANSBRK;

    TRANSON;
      RecRead(105,1,_RecFirst|_recLock);
      Rekreplace(105);
      RecRead(105,1,_RecNext|_recLock);
      Rekreplace(105);
      RecRead(105,1,_RecNext|_recLock);
      Rekreplace(105);
    TRANSOFF;

  TRANSOFF;
TRANSOFF;
RETURN;
***/
/***
vTxt # TextOpen(20);
TextAddLine(vTxt,'START');    // 1
TextAddLine(vTxt,'<AAA>');      // 2
TextAddLine(vTxt,'<BBB>');
TextAddLine(vTxt,'<CCC>');
TextAddLine(vTxt,'hahaha');
TextAddLine(vTxt,'<\CCC>');
TextAddLine(vTxt,'<\BBB>');
TextAddLine(vTxt,'</AAA>');
//TextWrite(vTxt,'d:\debug\debug2.txt',_textExtern);
textSearch(vTxt, 1, 1, _TextSearchCI, '<\','</',99);

  REPEAT
    vI # TextSearch(vTXT, 1, 1, _TextSearchtoken, '<AAA');
//debugx('found '+aint(vI));
    if (vI=0) then BREAK;
/*
    FOR vA # TextLineRead(vTXT, vI, _TextLineDelete)
    LOOP vA # TextLineRead(vTXT, vI, _TextLineDelete)
    WHILE ((vA=*'</CCC*')=false) and (vI<=TextInfo(vTXT,_TextLines)) do begin
debugx('del'+aint(vI)+' '+vA);
*/
    WHILE ((TextLineRead(vTXT, vI, _TextLineDelete)=*'</BBB*')=false) and (vI<=TextInfo(vTXT,_TextLines)) do begin
    END;
  UNTIL (vI=0);


TextAddLine(vTxt,'ENDE');
TextWrite(vTxt,'d:\debug\debug2.txt',_textExtern);
  TextClose(vTxt);
RETURN;
***/
//C16_Plugin:Test();

RecBufClear(705);
BAG.AF.Nummer         # 1;
BAG.AF.Position       # 1;
BAG.AF.Fertigung      # 1;
BAG.AF.Fertigmeldung  # 1;
BAG.AF.Seite          # 'X';
BAG.AF.Lfdnr          # 1;
BAG.AF.Bemerkung      # 'doof';
RekInsert(705);
BAG.AF.Nummer         # 2;
BAG.AF.Position       # 1;
BAG.AF.Fertigung      # 1;
BAG.AF.Fertigmeldung  # 1;
BAG.AF.Seite          # 'X';
BAG.AF.Lfdnr          # 1;
BAG.AF.Bemerkung      # 'test2';
RekInsert(705);

// 2 wird 1
BAG.FM.Nummer         # 1;
BAG.FM.Fertigmeldung  # 1;


// mach PLATZ
vBuf # Reksave(705);
BAG.AF.Nummer        # BAG.FM.Nummer;
BAG.AF.Fertigmeldung # BAG.FM.Fertigmeldung;
erx # RecRead(705,1,0);
if (erx=_rOK) then begin
  RekDelete(705);
debugx('DEL erx : '+aint(erx));
end;
RekRestore(vBuf);

Erx # RecRead(705,1,_recSingleLock);
debugx('LOCK erx : '+aint(erx));
if (Erx=_rOK) then begin
  BAG.AF.Nummer        # BAG.FM.Nummer;
  BAG.AF.Fertigmeldung # BAG.FM.Fertigmeldung;
  Erx # RekReplace(705,_recUnlock,'MAN');
debugx('replace : '+aint(erx));
end;
if (erx<>_rOK) then begin
  todo('ERROR A');
  RETURN;
end;
RecRead(705,1,_recunlock);

RETURN;
//Msg(99,abool(_Sys->spTerminalSession)+' : '+aint(_sys->spTerminalSessionID),0,0,0);
  CopyBA(10, 100);
  CopyBA(10, 101);
//WindialogBox(gFrmMain,cPrgName,'vA',1,_WinDialogAlwaysOnTop,1);
RETURN;
    RecBufClear(981);
    TeM.A.Datei           # 800;
    TeM.A.Start.Datum     # today;
    TeM.A.Start.Zeit      # now;
    TeM.A.EventErzeugtYN  # n;
    Erx # RecRead(981,3,0);

//debug('Read Erx : '+aint(Tem.A.Nummer)+' '+TeM.A.Code+' am '+cnvad(tem.a.start.datum)+':'+cnvat(tem.a.start.zeit));

    WHILE (Erx<=_rNoKey) do begin
      if (TeM.A.Datei<>800) or (TeM.A.Start.Datum=0.0.0) or
        (TeM.A.Start.Datum>today) or (TeM.A.EventErzeugtYN=y) or
        ((TeM.A.Start.Datum=today) and (TeM.A.Start.Zeit>now)) then BREAK;

//debug('msg:'+TeM.A.Code+' am '+cnvad(tem.a.start.datum)+':'+cnvat(tem.a.start.zeit));

      if (TeM.A.Code='') then begin
        Erx # RecRead(981,3,_recNext);
        CYCLE;
      end;
if (TeM.A.Nummer<586) then begin
        Erx # RecRead(981,3,_recNext);
        CYCLE;
end;

debugx('JOB: ALARM starten');
      RecRead(981,1,_recLock);
      TeM.A.EventErzeugtYN # y;
      Erx # RekReplace(981,0,'AUTO');
      if (Erx<>_rOK) then begin
        Erx # RecRead(981,3,_recNext);
        CYCLE;
      end;

      Erx # RecLink(980,981,1,_recFirst);   // Termin holen

      // interner Notifier...
      //Lib_Notifier:NewEvent( TeM.A.Code, '980', 'AKT '+AInt(TeM.Nummer)+' '+TeM.Bezeichnung, TEm.nummer );
      if (TeM.A.Datei=800) and (TEM.A.Nummer<>0) and (TeM.A.Nummer<>MyTmpnummer) then begin
        // 12.11.2014 AH
        if (Lib_Termine:GetBasisTyp(TeM.Typ)<>'WOF') then begin
          Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Typ+' '+TeM.Bezeichnung, TeM.Nummer ,today, now, 0);
        end
        else begin
          // 26.05.2020 AH: nur wenn Frist und Dauer eingetragen sind:
          if (Tem.Ende.Bis.Datum<>0.0.0) and (Tem.Ende.Bis.Datum<>Tem.Start.Von.Datum) then
            Lib_Notifier:NewEvent(TeM.A.Code, '980', strCut(TeM.Bezeichnung,1,55) + ' '+Lib_Berechnungen:KurzDatum_Aus_Datum(Tem.Ende.Bis.Datum), TeM.Nummer ,today, now, 0);
          else
            Lib_Notifier:NewEvent(TeM.A.Code, '980', TeM.Bezeichnung, TeM.Nummer ,today, now, 0);
        end;
      end;


      TeM.A.EventErzeugtYN # n;
      Erx # RecRead(981,3,0);
END;
return;


//Alle200AnUrsprung();
//Anh_data:CmdTwain_Settings('');
vTim # now;
//Todo(Userinfo(_UserCurrent)+'_'+cnvat(vTim, _FmtTimeNoMinutes)+'_'+cnvat(vTim, _FmtTimeNoHOurs)+'_'+cnvat(vtim, _FmtTimeNoMinutes|_FmtTimeNoHOurs|_FmtTimeSeconds));
//Todo(Userinfo(_UserCurrent)+'_'+cnvai(vTim->vpHours)+'_'+cnvai(vTim->vpMinutes)+'_'+cnvai(vTim->vpSeconds));
FOR Erx # RecREad(916,1,_recFirst)
LOOP Erx # RecREad(916,1,_recNext)
WHILE (Erx<=_rLocked) do begin
//  vBig # ((cnvid(Anh.Anlage.Datum)-cnvid(1.1.2000))*24\b*60\b*1000\b)+cnvbi(cnvit(Anh.Anlage.Zeit));
//debug(cnvad(Anh.Anlage.DAtum) + ' : '+cnvab(vBig));
//debug('KEY916');
REcRead(916,1,_RecLock);
Anh.ID # 0;
RecReplacE(916,_recunlock);
END;

RETURN;

vA # 'AH';
Dlg_Standard:Standard('an wen',var vA);
vTxt # TextOpen(20);

TextAddLine(vTxt, '<html xmlns:v="urn:schemas-microsoft-com:vml"');
TextAddLine(vTxt, 'xmlns:o="urn:schemas-microsoft-com:office:office"');
TextAddLine(vTxt, 'xmlns:w="urn:schemas-microsoft-com:office:word"');
TextAddLine(vTxt, 'xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"');
TextAddLine(vTxt, 'xmlns="http://www.w3.org/TR/REC-html40">');
TextAddLine(vTxt, '<head>');
TextAddLine(vTxt, '<meta http-equiv=Content-Type content="text/html; charset=windows-1252">');
TextAddLine(vTxt, '<meta name=ProgId content=Word.Document>');
TextAddLine(vTxt, '<meta name=Generator content="Microsoft Word 15">');
TextAddLine(vTxt, '<meta name=Originator content="Microsoft Word 15">');
TextAddLine(vTxt, '<link rel=File-List href="Unbenannt-Dateien/filelist.xml">');
TextAddLine(vTxt, '<link rel=Edit-Time-Data href="Unbenannt-Dateien/editdata.mso">');
TextAddLine(vTxt, '<link rel=themeData href="Unbenannt-Dateien/themedata.thmx">');
TextAddLine(vTxt, '<link rel=colorSchemeMapping href="Unbenannt-Dateien/colorschememapping.xml">');
TextAddLine(vTxt, '<style>');
TextAddLine(vTxt, '</style>');
TextAddLine(vTxt, '</head>');
TextAddLine(vTxt, '<body lang=DE link="#0563C1" vlink="#954F72" style=''tab-interval:35.4pt''>');
TextAddLine(vTxt, '<div class=WordSection1>');
TextAddLine(vTxt, '<p class=MsoNormal><a href="http://www.stahl-control.de/">BINDERLINK</a><o:p></o:p></p>');
TextAddLine(vTxt, '</div>');
TextAddLine(vTxt, '</body>');
TextAddLine(vTxt, '</html>');

Lib_Sync_Outlook:NeuerTermin(vA, 18.7.2019, 12:00, 90.0, 'Testding', 'Tu da was wichtiges!', 0,0, '', '', 'X123', vTxt);
TextClose(vTxt);

//testoutlook();
RETURN;


RETURN;

  // Converter vorhanden?
  if (Lib_FileIO:FileExists(c_EXCEL_CSV_CONVERTER) = false) then begin
    Msg(99,Translate('Excelkonverter nicht gefunden!'),_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  // Datei auswählen
  vName # 'D:';
  if (gUsername='AH') then vName # 'd:\debug\MusterListe2.xls';
  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, vName, 'XLSX-Dateien|*.xlsx;*.xls');
  if (vName='') then RETURN;

  // Datei Konvertieren
  vDia # WinOpen('Dlg.Pause',_WinOpenDialog);
  vMsg # Winsearch(vDia,'Label1');
  vMsg->wpcaption # 'Konvert: ' + vName;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenterScreen);//, gFrmMain);


  vName2 # FsiSplitName(vName, _FsiNamePN);
//  vName2 # FsiSplitName(vName, _FsiNameP)+'Convert';

  Erx # SysExecute(c_EXCEL_CSV_CONVERTER,'"'+vName + '" "' + vName2+'"',_ExecWait | _ExecHidden);
  Winclose(vDia);
  if (Erx < 0) then begin
    Msg(99,Translate('Konvertierung fehlgeschlagen!'),_WinIcoError,_WinDialogOk,0);
    RETURN;
  end;

  vName2 # vName2 + '.1.csv';    // 1. Sheet nehmen

RETURN;


//vA # 'SELECT Sum(Bestand_Gew), Warengruppe, Dicke FROM SYNC_Entwicklung.dbo.Material WHERE (Kommission != '') GROUP BY Warengruppe, Dicke ORDER BY Warengruppe, Dicke';
/*
  vA # 'CREATE VIEW Freies_Mat2 AS SELECT Warengruppe, Dicke, SUM(Bestand_Gew) AS Expr1 FROM dbo.Material WHERE (Kommission = '''') GROUP BY Warengruppe, Dicke';
  vCmd # gOdbcCON->OdbcExecuteDirect(vA);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
todo('FAIL');
    RETURN;
  end;
  vCmd->OdbcClose();
todo('OK');
*/
Erl.Rechnungsnr # 70000021
RecRead(450,1,0);

debug('ERLOES '+aint(Erl.Rechnungsnr));
_Test('NE','ST','BR','KO',Erl.NettoW1, Erl.SteuerW1, Erl.BruttoW1, Erl.KorrekturW1);

FOR Erx # RecLink(451,450,1,_RecFirst)
LOOP Erx # RecLink(451,450,1,_Recnext)
WHILE (Erx<=_rLocked) do begin
  debug('Konto '+Erl.K.Bemerkung);
  _Test('EK','LO','VK','KO',Erl.K.EKPReisSummeW1, Erl.K.InterneKostW1, Erl.K.BetragW1, Erl.K.KorrekturW1);
  if (Erl.K.Bemerkung='Grundpreis') then begin
    FOR Erx # Reclink(404,451,7,_recFirst)
    LOOP Erx # Reclink(404,451,7,_recNext)
    WHILE (Erx<=_rLocked) do begin
      debug('Aktion');
      _Test('EK','LO','VK','KO',Auf.A.EKPreisSummeW1, Auf.A.InterneKostW1, Auf.A.RechPreisW1, Auf.A.RechKorrektW1);
      if (Auf.A.Materialnr<>0) then begin
        Erx # Mat_Data:Read(Auf.A.materialnr);
        if (Erx>=200) then begin
          debug('Material');
          _Test('EK','LO','VK','KO',Mat.EK.Preis * Mat.Bestand.Gew / 1000.0, Mat.Kosten * Mat.Bestand.Gew / 1000.0 , Mat.VK.Preis * Mat.Bestand.Gew / 1000.0, Mat.VK.Korrektur * Mat.Bestand.Gew  / 1000.0);
//          _Test('EK','LO','VK','KO',Mat.EK.Preis, Mat.Kosten , Mat.VK.Preis, Mat.VK.Korrektur);
        end;
      end;
    END;
  end;

END;


Sta.EigenYN   # true;
Sta.Typ       # 'VK';
Sta.Re.Nummer # Erl.Rechnungsnr;
Erx # RecRead(899,2,0);
debug('STATISTIK '+aint(Sta.Re.nummer));
WHILE (Erx<_rNoRec) and (Sta.Re.Nummer = Erl.Rechnungsnr) do begin
  _test('EK','LO','VK','KO',Sta.Betrag.EK, Sta.Lohnkosten, Sta.Betrag.VK + Sta.Aufpreis.VK, Sta.Korrektur.VK);
  Erx # RecRead(899,2,_recNext);
END;

RETURN;



//vA # 'SELECT Sum(Bestand_Gew), Warengruppe, Dicke FROM SYNC_Entwicklung.dbo.Material WHERE (Kommission != '') GROUP BY Warengruppe, Dicke ORDER BY Warengruppe, Dicke';
/*
  vA # 'CREATE VIEW Freies_Mat2 AS SELECT Warengruppe, Dicke, SUM(Bestand_Gew) AS Expr1 FROM dbo.Material WHERE (Kommission = '''') GROUP BY Warengruppe, Dicke';
  vCmd # gOdbcCON->OdbcExecuteDirect(vA);
  if (vCmd=_ErrOdbcError) or (vCmd=_ErrOdbcFunctionFailed) then begin
todo('FAIL');
    RETURN;
  end;
  vCmd->OdbcClose();
todo('OK');
*/
  vA # 'perogjrpig ergpi erpgi jergpjer gpo er gpo jer gp ijeg oietrhg oetrihg orteüihg retoigh erqtigjqepijgeqigjertpgigj etroijertoigeorgrigj erpoigrpoierpgerigjerigjpioergj ergjergj erig jerpigj perg Erx Erx er !!!' +
  'perogjrpig ergpi erpgi jergpjer gpo er gpo jer gp ijeg oietrhg oetrihg orteüihg retoigh erqtigjqepijgeqigjertpgigj etroijertoigeorgrigj erpoigrpoierpgerigjerigjpioergj ergjergj erig jerpigj perg Erx Erx er !!!';
msg(99,va,0,0,0);
RETURN;


  FOR vERG # RecRead(100,1, _RecFirst)
  LOOP vERG # RecRead(100,1, _RecNext)
  WHILE (vERG = _rOk) do begin
    RecRead(100,1,_recLock);
    Adr.KundenFibuNr      # cnvai(Adr._KundenBuchNr, _FmtNumNogroup | _FmtNumNoZero);
    Adr.LieferantFibuNr   # cnvai(Adr._LieferantBuchNr, _FmtNumNogroup | _FmtNumNoZero);
    Adr._KundenBuchNr     # 0;
    Adr._LieferantBuchNr  # 0;
    RecReplace(100,0);
  END;


RETURN;
  // Vorlauf...
  FOR vERG # RecRead(200,1, _RecFirst)
  LOOP vERG # RecRead(200,1, _RecNext)
  WHILE (vERG = _rOk) do begin
  END;

debugstamp('Start');
TRANSON

  FOR vERG # RecRead(200,1, _RecFirst)
  LOOP vERG # RecRead(200,1, _RecNext)
  WHILE (vERG = _rOk) do begin
    RecRead(200,1,_recLock);
    RekReplace(200);
/*
    RecRead(200,1, _RecNext);
    RecRead(200,1,_recLock);
    RekReplace(200);

    RecRead(200,1, _RecNext);
    RecRead(200,1,_recLock);
    RekReplace(200);
*/
  END;
TRANSOFF;
debugstamp('Ende');

RETURN;


  FOR vERG # RecRead(701,1, _RecFirst)
  LOOP vERG # RecRead(701,1, _RecNext)
  WHILE (vERG = _rOk) do begin

    if (BAG.IO.NachBAG=0) then CYCLE;

    Erx # RecLink(702,701,4,_recFirst);   // Nach Pos holen
    if (BAG.P.Aktion='VSB') then CYCLE;

    if (BAG.IO.Materialnr<>0) and
      (BAG.IO.Materialnr=BAG.IO.MaterialRstNr) then
    debugx('KEY701   '+BAG.P.Aktion);
  END;


RETURN;

  vTxt # TextOpen(16);

  Erx # TextRead(vTxt,'~837.',_TextNoContents);
  vA # TextInfoAlpha(vTxt,_TextName);
  WHILE (vA>'~837.') and (vA<='~837.99999999') and (Erx<4) do begin

    TextClear(vTxt);
    Erx # TextRead(vTxt,vA,0);
    vJ # TextInfo(vTxt, _TextLines);
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vJ) do begin
      vB # TextLineread(vTxt, vI, 0);
      TextLineWrite(vTxt, vI, vB, 0);
    END;
    TextDelete(vA,0);
    TextWrite(vTxt, vA, 0);

    Erx # TextRead(vTxt,vA,_TextNoContents | _TextNext);
    vA # TextInfoAlpha(vTxt,_TextName);
  END;

  TextClose(vTxt);
RETURN;


Tem.E.ID # 485;
RecRead(989,1,0);
FOR vI # 1
LOOP inc(vI);
WHILE (vI<60) do begin
  TeM.E.ID # Lib_Nummern:ReadNummer( 'Meldungen' );
  Lib_Nummern:SaveNummer();
  RekInsert(989);
END;

Tem.E.ID # 483;
RecRead(989,1,0);
FOR vI # 1
LOOP inc(vI);
WHILE (vI<60) do begin
  TeM.E.ID # Lib_Nummern:ReadNummer( 'Meldungen' );
  Lib_Nummern:SaveNummer();
  RekInsert(989);
END;


RETURN;

  ClipboardWrite('');
  App_Update_Data:Todo('super 1');
  App_Update_Data:Todo('super 2');
  App_Update_Data:Todo('super 3');
  if (ClipBoardRead()<>'') then begin
todo(Clipboardread());
  end;

RETURN;


  vBuf # TextOpen(20);
  TextAddLine(vBuf,'Eins');
  TextAddLine(vBuf,'Zwei');
  TextAddLine(vBuf,'Drei');
  vErr # Lib_SMTP:Mail.Send(_MailSmtpTls, 'ex2010', 25, 'bcs2010\ah','xxx', 'ah@Stahl-control.de', 'Alex', 'ah@stahl-control.de', 'ich selber', 'Betreff!', vBuf,0);
  TextClose(vBuf);
if (vErr<>0) then begin
WinDialogBox(0,
      'E-Mail senden',
      'Beim Senden der E-Mail ist ein Fehler aufgetreten: ' + CnvAI(vErr, _FmtInternal),
      _WinIcoError,
      _WinDialogOK,
      1
    );
end;

//  Dlg_PDFPreview:ShowPDF('E:\Bestand_Komplett.pdf', '', '',0,1);
//  Dlg_PDFPreview:ShowPDF('E:\nur51cm.pdf', '', '',0,1);

RETURN;

  vStoDir # StoDirOpen( 0, 'Menu' );
  FOR  vStoObj # vStoDir->StoDirRead( _stoFirst );
  LOOP vStoObj # vStoDir->StoDirRead( _stoNext, vStoObj );
  WHILE ( vStoObj != '' ) DO BEGIN
    gFrmMain->wpMenuName # vStoObj;
    vHdl # gFrmMain->WinInfo( _winMenu );
    if ( vHdl = 0 ) then begin
//debug( '[Menu|Skip] ' + vStoObj );
      CYCLE;
    end;
    vHdl # Winsearch(vHdl,'Mnu.Daten.Export');
    if (vHdl<>0) then debug('EXPORT bei '+vStoObj);
//debug( '[Menu|Opening] ' + vStoObj + ' (' + CnvAI( vHdl ) + ')' );
//debug( '[Menu|Closing] ' + vStoObj );
  END;
  vStoDir->StoClose();

RETURN;

    FOR vErg # RecRead(202,1,_recFirst)
    LOOP vErg # RecRead(202,1,_recNext)
    WHILE (vErg<=_rLocked) do begin
      if (Mat.B.Bemerkung=c_Akt_SPLIT) then begin
        if (("Mat.B.Stückzahl"<0) or (Mat.B.Gewicht<0.0)) and (Mat.B.Menge>0.0) then begin
          RecRead(202,1,_reCLock);
debugx(aint(mat.b.materialnr));
          Mat.B.Menge # - Mat.B.Menge;
          RecReplace(202,_recunlock);
        end;
      end;
    END;
RETURN;


  FOR Erx # RecRead(451,1,_recFirst)
  LOOP Erx # RecRead(451,1,_recnext)
  WHILE (Erx<=_rLocked) do begin

    if (Erl.K.AuftragsPos<>0) then begin
      Erx # Auf_Data:read(Erl.K.Auftragsnr, Erl.K.Auftragspos, y);
      if (Erx<400) then begin
        todox(aint(Erl.K.Auftragsnr)+'/'+aint(Erl.K.Auftragspos));
        RETURN;
      end;
      if (Auf.P.Artikelnr<>'') or ("Auf.P.Güte"<>'') then begin
        RecRead(451,1,_recLock);
        Erl.K.ARtikelnummer # Auf.P.Artikelnr;
        "ERl.K.Güte"        # "Auf.P.Güte";
        RecReplace(451,_recunlock);
      end;
    end;
  END;

RETURN;

  vHdl # Lib_HTTP:Connect('217.7.213.23',8080);
  if (vHdl < 0) then begin
todox('nix');
    RETURN;
  end;
  vHdl->SckClose();

lib_HTTP:DownloadFile('http://217.7.213.23/update/test.txt','c:\xxx.txt', 8080);

todox('ok');

RETURN;


  FOR Erx # RecRead(981,1,_recFirst)
  LOOP Erx # RecRead(981,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Tem.A.Key='') then begin
      if (Tem.A.Datei=800) then CYCLE;

      vI # -1;
      vJ # -1;
      vA # StrCut(Tem.A.Code, 3,100);

      vI # cnvia(Str_Token(vA,'/',1));
      case Tem.A.Datei of
        102,401,122,501,702 : vJ # cnvia(Str_Token(vA,'/',2));
      end;

      if (vI<>-1) then begin
        RecRead(981,1,_recLock);
        Tem.A.Key # CnvAI(vI) + StrChar(255,1);
        if (vJ<>-1) then
          Tem.A.Key # Tem.A.Key + CnvAI(vJ) + StrChar(255,1);
        RecReplace(981,0);
      end;
    end;
  END;

RETURN;


RecRead(100,1,_recfirst);
RecRead(200,1,_recfirst);

vI # 100;
debug(aint(vI)+' : '+aint(HdlInfo(vI, _hdlexists)));
debug(Lib_Rec:MakeKey(vI));

vI # RekSave(200);
debug(aint(vI)+' : '+aint(HdlInfo(vI, _hdlexists)));
debug(Lib_Rec:MakeKey(vI));


RETURN;


Lib_Sync_Outlook:NeueAufgabe('halliHallo', 'wenn du das lesen kannst, melde dich bei mir :-)', 'TM');

RETURN;


  vErr # DbaConnect(3, 'DOK', '192.168.0.2', 'INMETDOK 5.7', 'USER', 'dokuser', '');
  if (verr<>_errOk) then begin
    todox('ERROR '+aint(vErr));
    RETURN;
  end;

debug('start copy...');

  vDir1   # BinDirOpen(0,'Dokumente', 0);
  vDir2   # BinDirOpen(0, 'Dokumente', _BinCreate | _BinDba3);

  // alle Objekte zu diesem Verzeichnis ermitteln
  vDirName # BinDirRead(vDir1,_BinFirst | _BinDirectory);
  WHILE (vDirName != '') do begin

    vSubDir2 # BinDirOpen(vDir2, vDirName, _BinCreate | _BinDba3);

    vSubDir1 # BinDirOpen(vDir1, vDirName);

    vFilename # BinDirRead(vSubDir1,_BinFirst);
    WHILE (vFilename != '') do begin

//debug('copy:'+vDirName+'\'+vFilename);
      vDatei1 # BinOpen(vSubDir1, vFilename, 0);
      vErr # vDatei1->BinExport('C:\TEST.JOB');
if (verr<>_ErrOK) then debugx('Error :' +aint(verr));

      vDatei2 # BinOpen(vSubDir2, vFilename, _BinCreate | _BinLock | _BinDba3);
      vErr    # vDatei2->BinImport('C:\TEST.JOB', 4);
//      vErr    # BinCopy(vDatei1, vDatei2);
if (verr<>_ErrOK) then debugx('Error :' +aint(verr));
      BinClose(vDatei1);
      BinClose(vDatei2);

      vFileName # BinDirRead(vSubDir1, _BinNext, vFileName);
    END;
    BinClose(vSubDir1);
    BinClose(vSubDir2);

    vDirName # BinDirRead(vDir1, _BinNext | _BinDirectory, vDirName);
  END;

  BinClose(vDir1);
  BinClose(vDir2);

  DbaDisconnect(3);

RETURN;


  if (DbaConnect(_dba3,'akt_','TCP:192.168.0.2','zzz_Alex','SU','VIB','')<>_Rok) then begin
    TODO('XLINK-Fehler!');
    RETURN;
  end;

todo('X');

  DbaDisconnect(_Dba3);

RETURN;


Set.DruckVS.imHGrund # y;

  vHdl # Lib_Progress:Init('Test vor APPOFF', 100);
  FOR vI # 1 loop inc(vI) while (vI<100) do begin
    vHdl->Lib_Progress:Step();
    Winsleep(50);
  END;
  vHdl->Lib_Progress:Term();

debugx('vor appoff:'+aint(winfocusget() ));
  APPOFF();
debugx('nach appoff:'+aint(winfocusget() ));

  vHdl # Lib_Progress:Init('Test nach APPOFF', 100);
debugx(aint(winfocusget() ));
  FOR vI # 1 loop inc(vI) while (vI<100) do begin
    vHdl->Lib_Progress:Step();
    Winsleep(50);
  END;
  vHdl->Lib_Progress:Term();
debugx(aint(winfocusget() ));
/***
  vHdl2  # WinOpen('Dlg.Standard',_WinOpenDialog);
  if (winfocusget()=0) and (Set.DruckVS.imHGrund) then begin
    vOpt # _WinDialogcreatehidden | _WinDialogMaximized | _WinDialogNoActivate;
debugx('starte hinten');
  end
  else begin
    vOpt # _WinDialogcreatehidden | _WinDialogMaximized;
debugx('starte VORNE');
  end;
  if (gFrmMain<>0) then
    WinDialogRun(vHdl2, vOpt, gFrmMain)
  else
    WinDialogRun(vHdl2, vOpt);
  Winclose(vHdl2);
***/

debugx('vor appon:'+aint(winfocusget() ));
  APPON();
debugx('nach appoff:'+aint(winfocusget() ));

  vHdl # Lib_Progress:Init('Test nach APPON', 100);
  FOR vI # 1 loop inc(vI) while (vI<100) do begin
    vHdl->Lib_Progress:Step();
    Winsleep(50);
  END;
  vHdl->Lib_Progress:Term();

debugx('ende:'+aint(winfocusget() ));

RETURN;


  //try begin

    // Initialisierung: SOAP-Client-Instanz anlegen
    vSOAP # C16_SysSOAP:Init(
      // Serveradresse
      'http://localhost:5001/AI/Report',
      // Namensraum
      'http://tempuri.org/'
      //,_SOAP.Version1.2
      //'http://www.w3.org/2003/05/soap-envelope/'
    );
    if (vSoap<0) then vRes # '72';

    // Anfragekörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RqsBody();
    vErg # vSOAPBody;
    if (vErg<0) then if (vRes='') then vRes # '80: '+aint(vErg);

  // Wert hinzufügen
//    vSOAPBody->C16_SysSOAP:ValueAddString('name', 'AUFBEST');
//    vSOAPBody->C16_SysSOAP:ValueAddString('outputPath', 'byC16');

    vSOAPBody->C16_SysSOAP:ValueAddString('sessionId', '00000000-0000-0000-0000-000000000000');
    vSOAPBody->C16_SysSOAP:ValueAddString('name', 'AUFBEST');
    vSOAPBody->C16_SysSOAP:ValueAddString('outputPath', 'c16');
    vSOAPBody->C16_SysSOAP:ValueAddString('paraObjectString', '');

    // Anfrage versenden und Antwort empfangen
//    vErg # vSOAP->C16_SysSOAP:Request('TestC16','"http://tempuri.org/IReportService/TestC16"');
    vErg # vSOAP->C16_SysSOAP:Request('StartReportToPDF','"http://tempuri.org/IReportService/StartReportToPDF"');
    if (vErg<0) then if (vRes='') then vRes # '92: '+aint(vErg);

//vRes # 'nixgut';

    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();

//    vSOAPBody->C16_SysSOAP:ValueGetString('TestC16Result', var vA);
    vSOAPBody->C16_SysSOAP:ValueGetString('StartReportToPDFResult', var vA);
mytodo(vA,vA);

    // Element ermitteln
//    vSOAPElement # vSOAPBody->C16_SysSOAP:ElementGet('TestCall_1Resultxx');
//    if (vSOAPElement > 0) then begin
      // Werte ermitteln
//      vSOAPElement->C16_SysSOAP:ValueGetString('TestCall_1Result', var vA);
//    end;
  //end;

  // Fehler ermitteln
  vErr # ErrGet();
  // Kein Fehler aufgetreten
  if (vErr <> _ErrOK) then begin
    mytodo('SOAP','Error:'+vRes);//ErrMapText(WinInfo(0,_WinErrorCode),'DE',_ErrMapSys));
  end;

  // Terminierung: SOAP-Client-Instanz freigeben
  if (vSOAP > 0) then begin
    vSOAP->C16_SysSOAP:Term();
    mytodo('SOAP','ende');
  end;


RETURN;



debugx('connect...');
if (DbaConnect(_Dba3,
               'BackUp-',
               'TCP:192.168.0.2',
               'Jordan 5.5',
               'SU',
               'VIB',
               '') = _ErrOK) then begin
debugx('bin drin');
  RecRead(3100,1,_recFirst);
  vI # FldInt(3100,1,1);
//  FldDefByName('BackUp-Kd.Name','test');
  DbaDisconnect(_Dba3);
end;
debug('ende '+aint(vI));

RETURN;

  MAt.Nummer # 70203;
  RecRead(200,1,0);
  RecRead(200,1,_recForceLock);
  RecRead(200,1,_recUnlock);
  RETURN;

/**
  aDatei # 401;

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      vSize # vSize + (StrLen(FldName(aDatei,vTds,vFld)));
      case FldInfo(aDatei, vTds, vFld, _FldType) of
        _TypeAlpha  : vSize # vSize + FldInfo(aDatei, vTds, vFld, _FldLen);
        _TypeDate   : vSize # vSize + 10;
        _Typeword   : vSize # vSize + 5;
        _typeint    : vSize # vSize + 11;
        _Typefloat  : vSize # vSize + 12;
        _typelogic  : vSize # vSize + 1;
        _TypeTime   : vSize # vSize + 8;
otherwise TODO('X');
      end;
    END;
  END;

todo('size:'+aint(vSize));
RETURN;
***/

RecRead(103,1,_recFirst);
lib_ODBC:Update(103);
RETURN;

Msg(99,'Script done!',0,0,0);

RETURN;

Lib_ODBC:DeleteAll(821);
Todo('del all');

FOR Erx # RecRead(821,1,_reCfirst)
LOOP Erx # RecRead(821,1,_recNext)
WHILE (Erx<=_rLocked) do begin
//Abt.Bezeichnung # 'x'+aint(abt.nummer);
//Lib_ODBC:Update(821);
END;
Abt.Nummer # 2;
//Lib_ODBC:Delete(821);
RETURN;



TRANSON;      // 1
recread(821,1,_RecFirst|_RecLock);
rekreplace(821,1,'MAN');

  TRANSON;    // 2
Abt.Nummer # 444;
Abt.bezeichnung # 'NEU';
rekinsert(821,_recunlock,'MAN');
    TRANSON;  // 3
    TRANSBRK; // free3
  TRANSOFF;   // -2

  TRANSON;    // 3
    TRANSON;  // 4
    TRANSOFF; // -4
  TRANSBRK;   // free3 + free4

Abt.Nummer # 444;
Abt.bezeichnung # 'NEU';
//rekdelete(821,_recunlock,'MAN');

TRANSOFF;     // -1
RETURN;


  RecRead(100,1,_recFirst);
  Adr.Stichwort # 'BCS';
  RecReplace(100,_recunlock);
  debug('Start: '+Adr.stichwort);

  TRANSON;
  RecRead(100,1,_reclock);
  Adr.Stichwort # '111';
  RekReplace(100,_recunlock,'AUTO');

  RecRead(100,1,_recFirst);
  debug('A: '+Adr.stichwort);

    TRANSON;
    RecRead(100,1,_reclock);
    Adr.Stichwort # '222';
    RekReplace(100,_recunlock,'AUTO');

/***/  TRANSBRK;
    RecRead(100,1,_recFirst);
    debug('B: '+Adr.stichwort);

    TRANSON;
    RecRead(100,1,_reclock);
    Adr.Stichwort # '333';
    RekReplace(100,_recunlock,'AUTO');

/***/  TRANSBRK;
    RecRead(100,1,_recFirst);
    debug('C: '+Adr.stichwort);


    TRANSON;
    RecRead(100,1,_reclock);
    Adr.Stichwort # '444';
    RekReplace(100,_recunlock,'AUTO');

    RecRead(100,1,_recFirst);
    debug('D: '+Adr.stichwort);

      TRANSON;
      RecRead(100,1,_reclock);
      Adr.Stichwort # '555';
      RekReplace(100,_recunlock,'AUTO');

      TRANSOFF;
      RecRead(100,1,_recFirst);
      debug('E: '+Adr.stichwort);

    TRANSOFF;
    RecRead(100,1,_recFirst);
    debug('F: '+Adr.stichwort);

  TRANSOFF;
  RecRead(100,1,_recFirst);
  debug('G: '+Adr.stichwort);

  RETURN;
end;


//========================================================================
//========================================================================

//========================================================================
sub Mat_VKPreis_Repair();
// call test+2:mat_VKPReis_repair
local begin
  Erx   : int;
  vX  : float;
end;
begin

  Erx # RecRead(200,1,_recFirst);
  WHILE (Erx<=_rLockeD) do begin
    if (Mat.VK.Rechnr<>0) then begin
      Erx # RecLink(404,200,24,_recFirst);    // Auf-Aktioneliste loopen
      WHILE (Erx<=_rLocked) do begin
        if (Auf.A.Rechnungsnr=Mat.VK.Rechnr) then begin
          vX # Auf.A.RechPreisW1;
          if (Mat.Bestand.Gew<>0.0) then
            vX # Rnd(vX / Mat.Bestand.Gew * 1000.0,2);
          if (vX<>Mat.VK.Preis) then begin
            RecRead(200,1,_RecLock);
//debug('Set Mat'+aint(mat.nummeR)+' von '+anum(Mat.VK.PReis,2)+' auf '+anum(vX,2));
            Mat.VK.Preis # VX;
            RecReplace(200,_recUnlock);
          end;
        end;
        Erx # RecLink(404,200,24,_recNext);
      END;
    end;

    Erx # RecRead(200,1,_recNext);
  END;


  Erx # RecRead(210,1,_recFirst);
  WHILE (Erx<=_rLockeD) do begin
    RecBufCopy(210,200);
    if ("Mat~VK.Rechnr"<>0) then begin
      Erx # RecLink(404,200,24,_recFirst);    // Auf-Aktioneliste loopen
      WHILE (Erx<=_rLocked) do begin
        if (Auf.A.Rechnungsnr="Mat~VK.Rechnr") then begin
          vX # Auf.A.RechPreisW1;
          if ("Mat~Bestand.Gew"<>0.0) then
            vX # Rnd(vX / "Mat~Bestand.Gew" *1000.0,2);
          if (vX<>"Mat~VK.Preis") then begin
            RecRead(210,1,_RecLock);
//debug('Set Mat'+aint("mat~nummeR")+' von '+anum("Mat~VK.PReis",2)+' auf '+anum(vX,2));
            "Mat~VK.Preis" # VX;
            RecReplace(210,_recUnlock);
          end;
        end;
        Erx # RecLink(404,200,24,_recNext);
      END;
    end;

    Erx # RecRead(210,1,_recNext);
  END;

end;


//========================================================================
sub Mat_Datum_Erzeugt();
local begin
  Erx : int;
end;
begin
  Erx # RecRead(200,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if (MAt.Datum.Erzeugt=0.0.0) then begin
      Erx # RecRead(200,1,_recLock);
      Mat.Datum.Erzeugt # Mat.Eingangsdatum;
      if (Mat.Datum.Erzeugt=0.0.0) then Mat.Datum.Erzeugt # Mat.Anlage.Datum;
      RecReplace(200,_recUnlock);
    end;
    Erx # RecRead(200,1,_recNext);
  END;

  Erx # RecRead(210,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    if ("MAt~Datum.Erzeugt"=0.0.0) then begin
      Erx # RecRead(210,1,_recLock);
      "Mat~Datum.Erzeugt" # "Mat~Eingangsdatum";
      if ("Mat~Datum.Erzeugt"=0.0.0) then "Mat~Datum.Erzeugt" # "Mat~Anlage.Datum";
      RecReplace(210,_recUnlock);
    end;
    Erx # RecRead(210,1,_recNext);
  END;
end;


//========================================================================
sub ding();
begin
  debug('ding:'+ gA[1]+ '  '+cnvai(gX[1]));
end;


//========================================================================
sub asdasd();
local begin
  Erx       : int;
  vHdl      : int;
  vOK       : logic;
  vName     : alpha;
  vText     : alpha(1000);
  vLines    : int;
  vLine     : int;
  vTextAdj  : alpha(1000);
end;
begin

  vHdl # TextOpen( 0 );
  FOR  Erx # vHdl->TextRead( '',   _textFirst | _textProc );
  LOOP Erx # vHdl->TextRead( vName, _textNext | _textProc );
  WHILE ( Erx < _rLocked ) DO BEGIN
    vName  # vHdl->TextInfoAlpha( _textName );
    vLines # vHdl->TextInfo( _textLines );

//    debug( '[Procedure|Opening] ' + vName + ' (' + CnvAI( vLines ) + ')' );
    debug( '' + vName + ' (' + CnvAI( vLines ) + ')' );

    FOR  vLine # 1;
    LOOP vLine # vLine + 1;
    WHILE ( vLine <= vLines ) DO BEGIN
      vText    # vHdl->TextLineRead( vLine, 0 );
      vTextAdj # StrAdj( StrCnv( vText, _strLower ), _strAll );
      if (StrFind( vTextAdj, 'replace', 1 ) > 0 ) and
//      if (StrFind( vTextAdj, 'recreplace', 1 ) > 0 ) and
        (StrFind( vTextAdj, '_reclock', 1 ) = 0 ) and
        (StrFind( vTextAdj, '_recunlock', 1 ) = 0 ) then begin
debug('FOUND : '+cnvai(vLine)+'   :   '+vText);
      end;
    END;

//    debug( '[Procedure|Closing] ' + vName + ' (' + CnvAI( vLines ) + ')' );
  END;
  vHdl->TextClose();

end;



//========================================================================
//========================================================================
//========================================================================
//========================================================================

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Ergebnis anzeigen: TreeNode in TreeView                        +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub DisplayNode(
  aCtrl                 : handle;       // Oberlächenobjekt: TreeView
  aItem                 : handle;       // Element: TreeNode
  aNode                 : handle;       // CteNode
  opt aDynamic          : logic;
) : handle;                               // Oberlächenobjekt: TreeNode
local begin
  vNode               : handle;
  vNodeStyle          : int;
  vCaption            : alpha(4096);
  vItem               : handle;
end
begin
  // Unterscheidung über Knotentyp
  case (aNode->spID) of
    _XmlNodeElement : begin
      vNodeStyle # _WinNodeFolder;

      vCaption # aNode->spName;

      // Attributknoten iterieren
      for  vNode # aNode->CteRead(_CteFirst | _CteAttribList)
      loop vNode # aNode->CteRead(_CteNext  | _CteAttribList, vNode)
      WHILE (vNode > 0) do begin
        vCaption # vCaption + ' ' + vNode->spName + '=' + '"' + vNode->spValueAlpha + '"';
      END;

//      vCaption # '<' + vCaption + '>';
    end;

    _XmlNodeComment : begin
      vNodeStyle # _WinNodeGreenBall;
      vCaption # aNode->spValueAlpha;
    end;

    _XmlNodeText : begin
      vNodeStyle # _WinNodeDoc;
      vCaption # aNode->spValueAlpha;
    end;

    otherwise begin
      vNodeStyle # _WinNodeRedBall;
      vCaption # aNode->spName + '=' + '"' + aNode->spValueAlpha + '"';
    end;
  end;  // ...case

  // Knoten hinzufügen
  vItem # aItem->WinTreeNodeAdd('', StrCnv(vCaption, _StrFromUTF8));
  if (vItem > 0) then begin
    vItem->wpID          # aNode;
    vItem->wpNodeStyle   # vNodeStyle;
    vItem->wpNodeDynamic # aDynamic and aNode->spChildCount > 0;
  end;

  RETURN(vItem);
end;


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// + Ergebnis anzeigen: TreeView                                    +
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub DisplayTree
(
  aCtrl                 : handle;       // Oberflächenobjekt: TreeView
  aItem                 : handle;       // Element: TreeNode
  aNode                 : handle;       // CteNode
  opt aDynamic          : logic;        // Dynamisch
) : logic;                                // Untergeordnete Elemente vorhanden
local begin
  vUpdate             : logic;
  vNode               : handle;
  vItem               : handle;
  vChild              : logic;
end;
begin
  if (aItem = 0) then begin
    aItem # aCtrl;
  end;

  vUpdate # aCtrl->wpAutoUpdate;

  if (vUpdate) then begin
    aCtrl->WinUpdate(_WinUpdOff);
  end;

  // Baum leeren
  aItem->WinTreeNodeRemove(true);

  // Kindknoten iterieren
  FOR  vNode # aNode->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # aNode->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) do begin
    // Ergebnis anzeigen: TreeNode in TreeView
    vItem # aCtrl->DisplayNode(aItem, vNode, aDynamic);
    if (vItem > 0 and !aDynamic) then begin
      vChild # true;
      // rekursiv
      vItem->wpNodeExpanded # aCtrl->DisplayTree(vItem, vNode);
    end;
  ENd;

  if (vUpdate) then begin
    aCtrl->WinUpdate(_WinUpdOn);
  end;

  if (aItem = aCtrl) then begin
    // Ersten Knoten auswählen
    aCtrl->wpCurrentInt # aCtrl->WinInfo(_WinFirst);
  end;

  RETURN(vChild);
end;


// ******************************************************************
// *  ALLE KNOTEN DES BAUMES ÖFFNEN ODER SCHLIESSEN                 *
// ******************************************************************
SUB NodeExpandAll (
  aNode         : int;
  aNodeExpanded : logic;
)
local begin
  vNode : int;
end
begin
  // kein gültiger Knoten-Deskriptor
  if (aNode <= 0) then RETURN

  // wenn TreeView, AutUpdate deaktivieren
  else if (aNode->WinInfo(_WinType) = _WinTypeTreeView) then begin
    if ($chkAutoUpdate->wpCheckState = _WinStateChkUnChecked) then
      aNode->wpAutoUpdate # FALSE;
  end

  // wenn TreeNode, dann diese öffnen oder schließen.
  else if (aNode->WinInfo(_WinType) = _WinTypeTreeNode) then
    aNode->wpNodeExpanded # aNodeExpanded;

  // kein gültiges Objekt
  else RETURN;

  // rekursiv alle Kind-Objekte iterieren
  vNode # aNode->WinInfo(_WinFirst);
  WHILE(vNode > 0) do begin
    // rekursiver Aufruf dieser Funktion
    NodeExpandAll(vNode,aNodeExpanded);
    vNode # vNode->WinInfo(_WinNext);
  END;

  // Änderungen sichtbar machen
  if (aNode->WinInfo(_WinType) = _WinTypeTreeView) then begin
    if ($chkAutoUpdate->wpCheckState = _WinStateChkUnChecked) then
      aNode->wpAutoUpdate # TRUE;
  end;
end;


//========================================================================
//
//========================================================================
sub XSAVE();
local begin
  vDoc    : handle;
  vRoot   : handle;
  vParent : handle;
end;
begin
  // Create document node
  vDoc # CteOpen(_CteNode);

  vDoc->spID # _XmlNodeDocument;

  // insert comment
  vDoc->CteInsertNode('', _XmlNodeComment, 'List of cities');

  // insert root
  vRoot # vDoc->CteInsertNode('Cities', _XmlNodeElement, NULL);

  // insert element
  vParent # vRoot->CteInsertNode('City', _XmlNodeElement, NULL);

  // attributes to element
  vParent->CteInsertNode('state', _XmlNodeAttribute, 'Hessen', _CteAttrib);
  vParent->CteInsertNode('name', _XmlNodeAttribute, 'Frankfurt', _CteAttrib);
  vParent->CteInsertNode('population', _XmlNodeAttribute, '650000', _CteAttrib);

  // insert element
  vParent # vRoot->CteInsertNode('City', _XmlNodeElement, NULL);

  // attributes to element
  vParent->CteInsertNode('state', _XmlNodeAttribute, 'Hessen', _CteAttrib);
  vParent->CteInsertNode('name', _XmlNodeAttribute, 'Darmstadt', _CteAttrib);
  vParent->CteInsertNode('population', _XmlNodeAttribute, '200000', _CteAttrib);

  vDoc->XmlSave('c:\citylist.txt');

  vDoc->CteClear(true);
  vDoc->CteClose();

end;

//========================================================================
//
//========================================================================
sub XLOAD();
local begin
  Erx     : int;
  vHdl    : int;
  vTV     : handle;
  vFirst  : handle;
  vNode   : Handle;
end
begin
  vNode # CteOpen(_CteNode);

//  Erx # vNode->XmlLoad('c:\citylist.txt',0,0,'',0);
//  Erx # vNode->XmlLoad('c:\xml\export\bag_241_1.xml',0,0,'',0);
  Erx # vNode->XmlLoad('c:\AAAA.XML',0,0,'',0);

  vHdl  # WinOpen('aaa',_WinOpenDialog);
  vTV   # Winsearch(vHdl,'TreeView1');

  vFirst  # vTV->WinTreeNodeAdd('erster','lalal');
  Displaytree(vTV, vFirst, vNode, false);//true);
  NodeExpandAll(vFirst,false);
  WinDialogrun(vHdl);
  vHdl->winclose();

  vNode->CteClear(true);
  CteClose(vNode);
end;

//========================================================================
sub EvtFSIMonitor(
  aEvt                 : event;    // Ereignis
  aAction              : int;      // Dateioperation
  aFileName            : alpha;    // Dateiname
  aFileAttrib          : int;      // Dateiattribute
  aFileSize            : bigint;   // Dateigröße
  aFileCT              : caltime;  // Datum-/Uhrzeit der Änderung
  aFileNameOld         : alpha;    // Alter Dateiname beim Umbenennen
) : logic;
begin
  Todo(aFilename);
end;



sub C16toCSharp(aText : alpha) : alpha;
local begin
  vI    : int;
end;
begin
  aText # Str_ReplaceAll(aText, '$', 'Dollar');
  aText # Str_ReplaceAll(aText, '%', 'Prozent');
  aText # Str_ReplaceAll(aText, '\', 'Pro');
  aText # Str_ReplaceAll(aText, 'Username', 'Superhorst');
  aText # Str_ReplaceAll(aText, 'User', 'Superhorst');
  aText # Str_ReplaceAll(aText, 'Superhorst', 'Username');

  aText # Str_ReplaceAll(aText, 'ä', 'ae');
  aText # Str_ReplaceAll(aText, 'ö', 'oe');
  aText # Str_ReplaceAll(aText, 'ü', 'ue');
  aText # Str_ReplaceAll(aText, 'Ä', 'Ae');
  aText # Str_ReplaceAll(aText, 'Ö', 'Oe');
  aText # Str_ReplaceAll(aText, 'Ü', 'Ue');
  aText # Str_ReplaceAll(aText, 'ß', 'ss');//strchar(195)+strchar(159));
  aText # Str_ReplaceAll(aText, '', strchar(226)+strchar(130)+strchar(172));

  aText # Str_ReplaceAll(aText, 'µ', strchar(194)+strchar(181));

  aText # Str_ReplaceAll(aText, '&', StrChar(254)+'amp;');
  aText # Str_ReplaceAll(aText, StrChar(254), '&');
  aText # Str_ReplaceAll(aText, '<', '&lt;');
  aText # Str_ReplaceAll(aText, '>', '&gt;');

  aText # Str_ReplaceAll(aText, 'õ', strchar(195)+strchar(204));
  aText # Str_ReplaceAll(aText, 'Õ', strchar(195)+strchar(205));
  aText # Str_ReplaceAll(aText, 'þ', strchar(195)+strchar(206));

  aText # Str_ReplaceAll(aText, 'ì', strchar(195)+strchar(236));
  aText # Str_ReplaceAll(aText, 'í', strchar(195)+strchar(237));
  aText # Str_ReplaceAll(aText, 'î', strchar(195)+strchar(238));

//  vI # StrFind(aText,'.',0);
//  if (vI=0) then RETURN aText;
//  aText # StrCut(aText,vI+1,20);

  aText # Str_ReplaceAll(aText, '.', '_');

  RETURN aText;
end;


//========================================================================
//  BuildScript
//
//========================================================================
sub BuildScript(
  aDatei  : int;
  aName   : alpha;
  aPrefix : alpha;
  aFile   : int) : logic;
local begin
  vName   :   alpha;
  vTyp    :   alpha;

  vMaxTds :   int;
  vMaxFld :   int;
  vTds    :   int;
  vFld    :   int;
  vFirst  :   logic;
  vHdl    :   int;

  vOut    :   alpha(254);
  vX      :   int;
  vA      :   alpha(254);
end;
begin

  vMaxTds # FileInfo(aDatei,_FileSbrCount);
/***
    [DBTable("Adressen")]
    [DBIndex("IX_Nummer","Nummer, Stichwort")]
    [DBIndex("IX_Name", "Name")]
    [DBIndex("IX_Sontwirgendwie", "Name, Stichwort, Nummer")]
    public class Adresse : DBRecord
    {
        [DBnotNull]
        public int Nummer { get; set; }
        public string Stichwort { get; set; }
        [DBMaxLen(40)]
        public string Name { get; set; }
        [DBMaxLen(40)]
        public string Ort { get; set; }
        [DBMaxLen(40)]
        public string Strasse { get; set; }
***/

  vName # Filename(aDatei);
  if (StrFind(StrCnv(vName,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
    vName # StrCut(vName, StrLen(aPrefix)+1, 50);
  end;
  vName # C16toCSharp(vName);

  /* Dateinamen schreiben */
  Write(cSatzEnde);
  Write('[DBAutoSync]'+cSatzEnde);
  Write('[DBTableName("'+vName+'")]'+cSatzEnde);
  Write('public class '+aName+' : DBRecord'+cSatzEnde);
  Write('{'+cSatzEnde);
  //Write('RecID BIGINT PRIMARY KEY NOT NULL'+


  /* Überschrift schreiben */
  vFirst # y;
  FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
    vMaxFld # SbrInfo(aDatei,vTds,_SbrFldCount);
    FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
      //if (vFirst=n) then Write(cFeldEnde);
      vFirst # n;

      vA # FldName(aDatei,vTds,vFld);
      if (StrFind(StrCnv(vA,_StrUpper),StrCnv(aPrefix,_StrUpper),0)=1) then begin
        vA # StrCut(vA, StrLen(aPrefix)+1, 50);
        end
      else begin
        Debug('bitte prüfen:'+aint(aDatei)+' '+vA);
      end;
      if (StrFind(vA,'Anlage.Zeit',0)>0) or
          (StrFind(vA,'Anlage.User',0)>0) or
          (StrFind(vA,'Anlage.Datum',0)>0) or
          (StrFind(vA,'Änderung.Zeit',0)>0) or
          (StrFind(vA,'Änderung.User',0)>0) or
          (StrFind(vA,'Änderung.Datum',0)>0) or
          (StrFind(vA,'Lösch.Zeit',0)>0) or
          (StrFind(vA,'Lösch.Grund',0)>0) or
          (StrFind(vA,'Lösch.User',0)>0) or
          (StrFind(vA,'Lösch.Datum',0)>0) then begin
        CYCLE;
      end;

      case FldInfo(aDatei,vTds,vFld,_FldType) of
        _TypeAlpha  : begin
          Write('[DBMaxLen('+cnvai(FldInfo(aDatei,vTds,vFld,_FldLen))+')]'+cSatzEnde);
          vTyp # 'string';
          end;
        _TypeDate   : vTyp # 'DateTime';
        _Typeword   : vTyp # 'Int16';
        _typeint    : vTyp # 'int';
        _Typefloat  : vTyp # 'double'; // float??
        _typelogic  : vTyp # 'byte';
        _TypeTime   : vTyp # 'DateTime';
        otherwise vTyp # 'ERROR';
      end;

      vA # C16toCSharp(vA);
      Write('public '+vTyp+' '+vA+' {get; set; }'+cSatzEnde);
    END;
  END;

  Write('}  // '+vName+cSatzEnde);
  Write(cSatzEnde);

  RETURN true;

end;


//========================================================================
//========================================================================
sub TestOutlook()
local begin
    tComApp               : handle;
    tComNameSpace         : handle;
    tComDefaultFolder     : handle;
    tComAppointment       : handle;
    tComAppointmentList   : handle;

    tItemCount            : int;
    tLoop                 : int;
    tStart                : caltime;
    tEnd                  : caltime;
    tSubject              : alpha(1000);
end
begin
  // COM-Schnittstelle / OutlookApplikation starten(Outlook startet unsichtbar)
  tComApp # 0;
  tComApp # ComOpen('Outlook.Application', _ComAppCreate);

  // NameSpace-Objekt des Typs 'MAPI'
  tComNameSpace # tComApp->ComCall('GetNameSpace', 'MAPI');

  // Default Folder öffnen (Indexwert 9 steht für Kalender)
  tComDefaultFolder # tComNameSpace->ComCall('GetDefaultFolder', 9);

  // Kalendereinträge
  tComAppointmentList # tComDefaultFolder->ComCall('Items');

  // Anzahl der Termine ermitteln
  tItemCount # tComAppointmentList->cpiCount;

  if (tItemCount != 0) then begin
      // Alle Termine auslesen
      for   tLoop # 1;
      loop  inc(tLoop);
      while (tLoop <= tItemCount) do begin
        // Einzelnen Termin ermitteln
        tComAppointment # tComDefaultFolder->ComCall('Items',tLoop);

        // Verschiedene Informationen zum Termin ermitteln
        // Startzeitpunkt
        tStart # tComAppointment->cpcStart;
        // Endzeitpunkt
        tEnd # tComAppointment->cpcEnd;
        // Betreff
        tSubject # tComAppointment->cpaSubject;
        //...etc
debugx(cnvad(tStart->vpDate)+' '+cnvat(tStart->vpTime)+' :'+tSubject);
      end
    end
   else begin
     WinDialogBox(0, 'HINWEIS',
                   'Es sind keine Einträge im Outlook-Kalender vorhanden',
                   _WinIcoError, _WinDialogOk, 0);
   end;

  if (tComApp > 0) then begin
    // Mit dieser Outlook-Methode wird die Applikation geschlossen
//    tComApp->ComCall('Quit');

    // und der Deskriptor des COM-Objektes freigeben
    tComApp->ComClose();
  end
  
end;


//========================================================================
sub _BuildName(aHdl : int) : alpha
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
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aID                   : bigint;       // Record-ID des Datensatzes oder Zeilennummer
) : logic;
local begin
  vEvt  : event;
  vItem : int;
  vTV   : int;
end;
begin
  vTV # Winsearch(gMdiMenu, 'TV.Hauptmenue');
  vEvt:obj # vTV;
  WinLstCellGet(aEvt:obj, vItem, 2, aID);
  App_Main:EvtMouseItem(vEvt,_WinMouseDouble,0, vItem, 0); //4=item

  RETURN(true);
end;


//========================================================================
sub EvtChanged(
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
        vB # _BuildName(vNodeFound);
        WinLstDatLineAdd(vDL, vB);
        WinLstCellSet(vDL, vNodeFound, 2, _WinlstDatLineLast);
      END;
/*
      WinLstDatLineAdd(vDL, 'kfdobfb', _WinlstDatLineLast)
      WinLstDatLineAdd(vDL, '2k333fdobfb', _WinlstDatLineLast)
      WinLstDatLineAdd(vDL, '3k333fdobfb', _WinlstDatLineLast)
      WinLstDatLineAdd(vDL, '4k333fdobfb', _WinlstDatLineLast)
      WinLstDatLineAdd(vDL, '5k333fdobfb', _WinlstDatLineLast)*/
    end;
  end;
  
  RETURN(true);
end;




//========================================================================
sub KillBA(aNr : int);
local begin
  Erx : int;
end;
begin
  BAG.Nummer # aNr;
  Erx # RecRead(700,1,0);
  if (Erx<>_rOK) then RETURN;

  // IOs loopen
  WHILE (RecLink(701,700,3,_recFirst)=_rOK) do begin
    BA1_IO_Data:Delete(0,'');
  END;

  // Fert. loopen
  WHILE (RecLink(703,700,6,_recFirst)=_rOK) do begin
    BA1_F_DatA:Delete(true);
  END;
 
  // Pos. loopen
  WHILE (RecLink(702,700,1,_recFirst)=_rOK) do begin
    BA1_P_Data:Delete(false);
  END;

  // Kopf löschen
  RekDelete(700);
  
end;


//========================================================================
sub CopyBA(
  aVon  : int;
  aNr   : int);
local begin
  Erx : int;
end;
begin

  KillBA(aNr);

  BAG.Nummer # aVon;
  Erx # RecRead(700,1,0);
  if (Erx<>_rOK) then RETURN;

  // Pos. loopen
  FOR Erx # RecLink(702,700,1,_recFirst)
  LOOP Erx # RecLink(702,700,1,_recnext)
  WHILE (Erx<=_rLocked) do begin
    BAG.P.Nummer # aNr;
    RekInsert(702);
    BAG.P.Nummer # BAG.Nummer;
  END;

  // Fert. loopen
  FOR Erx # RecLink(703,700,6,_recFirst)
  LOOP Erx # RecLink(703,700,6,_recnext)
  WHILE (Erx<=_rLocked) do begin
    BAG.F.Nummer # aNr;
    RekInsert(703);
    BAG.F.Nummer # BAG.Nummer;
  END;

  // IOs loopen
  FOR Erx # RecLink(701,700,3,_recFirst)
  LOOP Erx # RecLink(701,700,3,_recnext)
  WHILE (Erx<=_rLocked) do begin
    BAG.IO.Nummer # aNr;
    if (BAG.IO.VonBAG=BAG.Nummer) then BAG.IO.VonBAG # aNr;
    if (BAG.IO.NachBAG=BAG.Nummer) then BAG.IO.NachBAG # aNr;
    RekInsert(701);
    BAG.IO.Nummer # BAG.Nummer;
  END;

  // Kopf kopieren
  BAG.Nummer    # aNr;
  BAG.VorlageYN # n;
  RekInsert(700);
end;

//========================================================================
//========================================================================
sub Transaction1
begin
  //DtaBegin();
  TransOn;
  
  Wgr.Nummer # 9000;  // 9999       VS:20002
  RecRead(819,1,_RecLock);      //  VS:Artikel
  RecReplace(819,_RecUnlock);
  WinDialogBox(0,__PROC__,'USER1 RecReplace ' + CnvAI(ErrGet()),0,0,0);
  
  ErrTryCatch(_ErrDeadLock,false);
  try
  begin
    Adr.Nummer # 9998;
    RecInsert(100,0);  // VS:Kunde
    WinDialogBox(0,__PROC__,'USER1 RecInsert '  + CnvAI(ErrGet()),0,0,0);
  end;
    
  if (ErrGet() = _ErrDeadLock) then
    WinDialogBox(0,__PROC__,'USER1 Deadlock aufgetreten',0,0,0);
   
  //DtaCommit();
  TransOff;
end;

//========================================================================
//  call test+2:User1
//========================================================================
sub USER1()
begin
//  _Sys->spOptions # _DeadLockRTE;
  Adr.Nummer # 9998;
  RecDelete(100,0);
  Transaction1();
end;

//========================================================================
//========================================================================
sub Transaction2
begin
  //DtaBegin();
  TransON;

  Adr.Nummer # 9999;
  RecInsert(100,0);
  WinDialogBox(0,__PROC__,'USER2 RecInsert ' + Cnvai(ErrGet()),0,0,0);

  WGr.Nummer # 9999;        // VS: 20003, Artikel
  RecRead(819,1,_Reclock);
  WinDialogBox(0,__PROC__,'USER2 RecRead '  + Cnvai(ErrGet()),0,0,0);
  
  RecReplace(819,_RecUnlock);
  WinDialogBox(0,__PROC__,'USER2 RecReplace ' + Cnvai(ErrGet()),0,0,0);
    
  //DtaCommit();
  Transoff;
end;

//========================================================================
//  call test+2:User2
//========================================================================
sub USER2()
begin
  Adr.Nummer # 9999;
  RecDelete(100,0);
  Transaction2();
end;


//========================================================================
//   Call test+2:ProcsMitErg
//========================================================================
sub ProcsMitErg()
local begin
  Erx   : int;
  vTxt  : int;
  vProc : alpha;
end;
begin
  debug('SFX Funktionen OHNE "OHNE E_R_G"');
  vTxt # TextOpen(16);
  Erx # vTxt -> TextRead('SFX', _TextProc);
  vProc # vTxt -> TextInfoAlpha(_TextName);

  FOR Erx # vTxt -> TextRead(vProc, _TextProc);
  LOOP Erx # vTxt -> TextRead(vProc, _TextNext | _TextProc);
  WHILE(Erx <= _rNoKey) DO BEGIN
    vProc # vTxt -> TextInfoAlpha(_TextName);
    if (StrCnv(vProc,_StrUpper)>'SFY') then BREAK;
    if (TextSearch(vTxt,1,1,_TextSearchCI,'OHNE E_R_')=0) then begin
debug(vProc);
    end;
  END;
  vTxt -> TextClose();
end;


//========================================================================
//========================================================================