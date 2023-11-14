@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_List
//                  OHNE E_R_G
//  Info        Routinen für die Ausgabe von Listen als Druck oder XML
//              Sollten per DEF_LIST angesteurt werden
//
//
//  28.02.2007  AI  Erstellung der Prozedur
//  17.07.2008  PW  XML Schreibrechte, Fehlerbehandlung
//  06.01.2010  HB  Kursic/Italic eingebaut
//  01.06.2012  AI  PDF-Ausgabe möglich
//  06.06.2012  AI  Listenname als PDF-Titel
//  06.02.2014  AH  Excel-Export kappt Floats bei 999999999999.0
//  2023-05-10  AH  Andere Combolines möglich
//
//  Subprozeduren
//  sub _Init(aLandscape : logic) : logic;
//  sub _Term() : logic;
//  sub _StartLine(opt aFormat : int);
//  sub _Term() : logic;
//  sub _EndLine();
//  sub _Write(aNr : int; aText : alpha; aRight : logic; opt aFormat : Int; opt aXX : float);
//  sub _WriteTitel();
//  SUB _ZahlF(aZahl : float; aStellen : int) : alpha;
//
//========================================================================
@I:Def_Global
//@I:Lib_Print
@I:Def_PrintLine
@I:Def_List

//========================================================================
//  _Init
//
//========================================================================
//========================================================================
sub _Init(
  aLandscape      : logic;
  opt aComboName  : alpha) : logic;   //  2023-05-10  AH
local begin
  vHdl    : int;
  vSplash : int;
  vName   : alpha;
  vI      : int;
  vTmp    : int;
end;
begin
  if (Varinfo(Class_List)=0) then RETURN false;

  List_Comboname # aComboName;    // 2023-05-10 AH
  
  // Splash-Screen laden
  if (false) and (gUsergroup<>'PROGRAMMIERER') then begin
    vSplash # WinOpen('Frame.Printing',_WinOpenDialog);
    // Splash-Screen anpassen
    vTmp # Winsearch(vSplash,'lb.printstatus');
    vTmp -> wpCaption # 'Liste wird aufgebaut...';
    // Splash-Screen anzeigen
    vSplash -> WinDialogRun(
      _WinDialogAsync |
      _WinDialogCenter,
      gMdi);
  end;

  // XML
  if (List_XML=y) then begin
    FsiDelete(list_filename);

    // Grundlegende XML Datenen übernehmen (Styles...)
    vHdl # TextOpen(10);
    TextRead(vHdl, 'XML.Table.Start', 0);
    TxtWrite(vHdl,list_filename ,_TextExtern);
    vHdl->TextClose();

    // Worksheet-Kopf schreiben
    list_FileHdl # FSIOpen(List_Filename,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);

    if (list_FileHdl<=0) then begin
      List_XML # n
      Msg(910005,List_Filename,0,0,0);
    end
    else begin
      vName # StrCnv(Lfm.Name,_StrUmlaut);
      FsiWrite(list_FileHdl, '<Worksheet ss:Name="'+StrCut(StrCnv(vName,_StrLetter),1,31)+'">'+cCRLF);
      FsiWrite(list_FileHdl, '<Table>'+cCRLF);

      FOR vI # 1 loop inc (vI) while (vI<99) do
//        FsiWrite(List_FileHdl,'<Column ss:Index="'+cnvai(vI)+'" ss:AutoFitWidth="1"/>'+cCRLF);
        FsiWrite(List_FileHdl,'<Column ss:Index="'+cnvai(vI)+'" ss:AutoFitWidth="1" ss:Width="100.00"/>'+cCRLF);

      // 1. Seitenkopf erzeugen
      Call(Lfm.Prozedur+':Seitenkopf', 1);
    end;
  end;

  _App->wpWaitcursor # true;
  APPOFF();

  // Druck
  if (List_XML=n) then begin
    // Printline erzeugen
    PL_Create(list_PL);

    if (aLandscape) then
      vHdl # PrtFormOpen(_PrtTypePrintForm,'LST.UnterschriftQ')
    else
      vHdl # PrtFormOpen(_PrtTypePrintForm,'LST.Unterschrift');
    // Job Öffnen + Page srstellen
//    Lib_Print:FrmJobOpen('',0,vHDL,n,n,aLandscape);
    Lib_Print:FrmJobOpen(n,0,vHDL,n,n,aLandscape);

    form_randOben   # rnd(Lib_Einheiten:LaengenKonv('mm','LE', 10.0));
    form_randUnten  # 0;

    // Dokumentendialog initialisieren
    Lib_Print:FrmPrintDialog(Lfm.Name,aLandscape);

    pls_FontSize # 9;

    // Seitenkopf drucken
    Lib_Print:Print_Seitenkopf(0);
  end;

  RETURN true;
end;


//========================================================================
// _Term
//
//========================================================================
sub _Term() : logic;
local begin
  vSel    : int;
  vSplash : int;
end;
begin

  _App->wpWaitcursor # false;
  APPON();

  if (Varinfo(Class_List)=0) then RETURN false;

  // Drucken........................................................
  if (List_XML=n) then begin
    // letzte Seite & Job schließen, ggf. mit Vorschau
    Form_Footer->PrtFormClose();
    Form_Footer # 0;

    if (List_PDFPath='') then
      Lib_Print:FrmJobClose((gUserGroup<>'JOB-SERVER') and ((gUsername=*^'SOA*')=false) , y)
    else
      // APPLE
      Lib_Print:FrmJobClosePDF(n, List_PDFPath, n,n, Lfm.Name);

    // Objekte entladen
    if (List_PL<>0) then PL_Destroy(list_PL);
    end

  else begin // XML..................................................
    // Alle Tags schliessen
    FsiWrite(list_FileHdl, '</Table>'+cCRLF);
    FsiWrite(list_FileHdl, '</Worksheet>'+cCRLF);
    FsiWrite(list_FileHdl, '</Workbook>'+cCRLF);
    FsiClose(list_FileHdl);

    // Splash-Screen anpassen
    vSplash # $Frame.Printing;
    if (vSplash<>0) then begin
      vSplash->WinClose();
    end;
  end;
/*
debug('re1');
  if (list_MDI<>0) then begin
    VarInstance(WindowBonus,cnvIA(list_MDI->wpcustom));
    if (w_SelName<>'') then begin   // temp. Sleketionen entfernen
debug('xx'+w_Name+'  '+w_selName);
//      SelDelete(gFile,w_selName);
      vSel # SelOpen();
      ERG # SelRead(vSel, gFile,_SelLock, w_SelName);
debug('ERG');
//      if (gKey<>0) then SelInfo(vSel,_SelSort,gKey);
      SelRun(vSel,_SelDisplay|_SelWait);
      gZLList->wpDbSelection # vSel;
    end;
  end;
*/
  // wenn XML, dann Erfolgsmedlung
  if (list_XML) and (gUserGroup<>'JOB-SERVER') and ((gUsername=*^'SOA*')=false) then begin
    Msg(910003,List_Filename,0,0,0);
  end;

  // Struktur freigeben
  Lfm_Ausgabe:Cleanup();
  
  APPON();

  RETURN true;
end;


//========================================================================
//  _StartLine
//            neue Zeile starten
//========================================================================
sub _StartLine(opt aFormat : int);
begin

  // Drucken .......................................................
  if (list_XML=n) then begin

    if (aFormat & _LF_Bold<>0) then begin
      aFormat # aFormat - _LF_Bold;
//      pls_FontAttr # pls_FontAttr |  _WinFontAttrBold;
      List_LineFormat # List_LineFormat | _LF_Bold;
    end;
    if (aFormat & _LF_Italic<>0) then begin
      aFormat # aFormat - _LF_Italic;
//      pls_FontAttr # pls_FontAttr |  _WinFontAttrItalic;
      List_LineFormat # List_LineFormat | _LF_Italic;
    end;

    if (aFormat=_LF_Underline) then begin
      List_LineFormat # List_LineFormat | _LF_Underline;
    end;

    if (aFormat=_LF_Overline) then begin
      List_LineFormat # List_LineFormat | _LF_Overline;
    end;

    end
  else begin    // XML ...............................................

    List_lineformat # aFormat;
    if (aFormat=_LF_Underline) then begin
      FsiWrite(list_FileHdl, '<Row ss:Height="13.5" ss:StyleID="UL">'+cCRLF);
      end
    else if (aFormat=_LF_Overline) then begin
      FsiWrite(list_FileHdl, '<Row ss:Height="13.5" ss:StyleID="OL">'+cCRLF);
      end
    else begin
      FsiWrite(list_FileHdl, '<Row>'+cCRLF);
    end;

  end;

end;


//========================================================================
//  _EndLine
//          Zeile beenden und ausgeben
//========================================================================
sub _EndLine();
begin


  // Drucken .......................................................
  if (list_XML=n) then begin
    if (list_LineFormat & _LF_OverLine<>0) then begin
      if (Form_Landscape) then
        Lib_Print:Print_LinieEinzeln(0.0,350.0)
      else
        Lib_Print:Print_LinieEinzeln(0.0,195.0);
      List_LineFormat # List_LineFormat - _LF_Overline
    end;

    PL_PrintLine;

    if (list_LineFormat & _LF_Underline<>0) then begin
      if (Form_Landscape) then
        Lib_Print:Print_LinieEinzeln(0.0,350.0)
      else
        Lib_Print:Print_LinieEinzeln(0.0,195.0);
      List_LineFormat # List_LineFormat - _LF_Underline;
    end;
    List_LineFormat # 0;
    end
  else begin    // XML ...............................................

    FsiWrite(list_FileHdl, '</Row>'+cCRLF);

  end;

end;


//========================================================================
//  _Write
//          Eine Zelle füllen
//========================================================================
sub _Write(
  aNr         : int;
  aText       : alpha(300);
  aRight      : logic;
  opt aFormat : Int;
  opt aXX     : float);
local begin
  vAttr     : int;
  vStyle    : alpha;
  vStyle2   : alpha;
  vType     : alpha;
  vBold     : logic;
  vFormula  : alpha;
  vF        : float;
end;
begin

  // Drucken .....................................................
  if (list_XML=n) then begin
    vAttr # pls_FontAttr;

    aFormat # aFormat | List_Lineformat;
    if (aFormat & _LF_Bold <>0 ) then begin
      aFormat # aFormat - _LF_Bold;
      pls_FontAttr # pls_FontAttr | _WinFontAttrBold;
    end;
    if (aFormat & _LF_Italic <>0 ) then begin
      aFormat # aFormat - _LF_Italic;
      pls_FontAttr # pls_FontAttr | _WinFontAttrItalic;
    end;

    if (List_FontSize=0) then
      pls_FontSize # 9
    else
      pls_FontSize # List_FontSize;

    if (aRight) then
      PL_Print_R(aText, list_Spacing[aNr+1]-aXX, list_Spacing[aNr])
    else
      PL_Print(aText, list_Spacing[aNr]+aXX, list_Spacing[aNr+1]);

    pls_FontSize # 9;
    pls_FontAttr # vAttr;
    end

  else begin    // XML ...............................................
    // Formel extrahieren [22.12.2009/PW]
    if ( aFormat & _LF_Formula = _LF_Formula ) then begin
      aFormat  # aFormat ^ _LF_Formula; // Formula Flag entfernen
      vFormula # ' ss:Formula="' + aText + '"';
      aText    # ''
    end;

    // Zellenformat mit Zeilenformat verbinden...
    aFormat # aFormat | List_LineFormat;
    if (aFormat & (_LF_Bold + _LF_Underline)=(_LF_Bold + _LF_Underline)) then
      vStyle2 # 'UL+B'
    else if (aFormat & (_LF_Bold + _LF_Overline)=(_LF_Bold + _LF_Overline)) then
      vStyle2 # 'OL+B'
    else if (aFormat & _LF_Overline=_LF_Overline) then
      vStyle2 # 'OL'
    else if (aFormat & _LF_Underline=_LF_Underline) then
      vStyle2 # 'UL'
    else if (aFormat & _LF_Bold=_LF_Bold) then
      vStyle2 # 'B'

    // Datentyp bestimmen...
    aFormat # aFormat & (_LF_String + _LF_Int + _LF_Wae + _LF_Num + _LF_NUM0 +_LF_Num3 + _LF_Date);
    case aFormat of

      _LF_String : begin
        vStyle  # '';
        vType   # 'String';
        end;

      _LF_WAE    : begin
        vStyle  # 'c16_wae';
        vType   # 'Number';
        aText # Str_ReplaceAll(aText,'.','');
        aText # Str_ReplaceAll(aText,',','.');
        end;

      _LF_Date   : begin
        vStyle  # 'c16_date';
        vType   # 'DateTime';
        end;

      _LF_INT    : begin
        vStyle  # '';
        vType   # 'Number';
        aText # Str_ReplaceAll(aText,'.','');
        aText # Str_ReplaceAll(aText,',','.');
        end;

      _LF_NUM    : begin
        vStyle  # 'c16_num';
        vType   # 'Number';
        vF # cnvfa(aText);
        if (vF<-999999999999.0) then aText # CnvAF( -999999999999.0, _fmtNumNoGroup);
        else if (vF>999999999999.0) then aText # CnvAF( 999999999999.0, _fmtNumNoGroup);
        aText # Str_ReplaceAll(aText,'.','');
        aText # Str_ReplaceAll(aText,',','.');
      end;

      _LF_NUM0    : begin
        vStyle  # 'c16_num0';
        vType   # 'Number';
        vF # cnvfa(aText);
        if (vF<-999999999999.0) then aText # CnvAF( -999999999999.0, _fmtNumNoGroup);
        else if (vF>999999999999.0) then aText # CnvAF( 999999999999.0, _fmtNumNoGroup);
        aText # Str_ReplaceAll(aText,'.','');
        aText # Str_ReplaceAll(aText,',','.');
        end;

      _LF_NUM3   : begin
        vStyle  # 'c16_num3';
        vType   # 'Number';
        vF # cnvfa(aText);
        if (vF<-999999999999.0) then aText # CnvAF( -999999999999.0, _fmtNumNoGroup);
        else if (vF>999999999999.0) then aText # CnvAF( 999999999999.0, _fmtNumNoGroup);
        aText # Str_ReplaceAll(aText,'.','');
        aText # Str_ReplaceAll(aText,',','.');
        end;
    end;


    if (vStyle2<>'') then begin
      if (vStyle<>'') then vStyle # vStyle+ '+'+vStyle2
      else vStyle # vStyle2;
    end;

    if (vStyle<>'') then vStyle # ' ss:StyleID="'+vStyle+'"';

    // Zelleninhalt schreiben...
    FsiWrite(list_FileHdl, '<Cell ss:Index="'+cnvai(aNr)+'"'+vStyle+vFormula+'>');
    FsiWrite(list_FileHdl, '<Data ss:Type="'+vType+'">');
    aText # Lib_Strings:Strings_DOS2XML(aText);
    FsiWrite(list_FileHdl, aText);
    FsiWrite(list_FileHdl, '</Data>');
    FsiWrite(list_FileHdl, '</Cell>'+cCRLF);

  end;  // XML

end;


//========================================================================
//  _WriteTitel
//              Listenkopf erzeugen (Datum, Seite...)
//========================================================================
sub _WriteTitel();
local begin
  vAttr : int;
  vA    : alpha;
end;
begin

  // Drucken .....................................................
  if (list_XML=n) then begin
    _StartLine();
    vAttr # pls_FontAttr;

    pls_FontSize # 20
    PL_Print(Lfm.Name, 0.0);

    pls_FontSize # 9;

    if (form_Landscape=n) then begin
      PL_Print('Datum:'     ,150.0);
      PL_Print(Cnvad(today) ,165.0);
      PL_Print('Seite:'     ,150.0,165.0,2)
      PL_Print(cnvai(form_Job->prtinfo(_PrtJobPageCount)+1), 165.0, 190.0,2);
      end
    else begin
      PL_Print('Datum:'     , 90.0+150.0);
      PL_Print(Cnvad(today) , 90.0+165.0);
      PL_Print('Seite:'     , 90.0+150.0, 90.0+165.0,2)
      PL_Print(cnvai(form_Job->prtinfo(_PrtJobPageCount)+1), 90.0+165.0, 90.0+190.0,2);
    end;
//Print(aName : alpha(1000); aX : float; optaXX : float; optaZeile : int);

    pls_FontAttr # vAttr;
    _EndLine();

//    pls_FontSize # 5;
//    PL_Print('(Liste: '+cnvai(Lfm.Nummer)+')'     ,0.0, 50.0,2);
    Lib_Print:Print_TextAbsolut('(Liste: '+cnvai(Lfm.Nummer)+')', 0.0, 2.8, 7);
    end

  else begin    // XML ...............................................

    FsiWrite(list_FileHdl, '<Row ss:StyleID="Mainheader">'+cCRLF);
    vA # Lib_Strings:Strings_DOS2XML(Lfm.Name);
    FsiWrite(list_FileHdl, '<Cell><Data ss:Type="String">'+vA+'</Data></Cell>'+cCRLF);
    FsiWrite(list_FileHdl, '</Row>'+cCRLF);

    FsiWrite(list_FileHdl, '<Row>'+cCRLF);
    FsiWrite(list_FileHdl, '<Cell><Data ss:Type="String">('+cnvai(Lfm.Nummer)+')</Data></Cell>'+cCRLF);
    FsiWrite(list_FileHdl, '</Row>'+cCRLF);

    FsiWrite(list_FileHdl, '<Row>'+cCRLF);
    FsiWrite(list_FileHdl, '<Cell><Data ss:Type="String">Datum '+Cnvad(today)+'</Data></Cell>'+cCRLF);
    FsiWrite(list_FileHdl, '</Row>'+cCRLF);
    FsiWrite(list_FileHdl, '<Row>'+cCRLF);
    FsiWrite(list_FileHdl, '</Row>'+cCRLF);

  end;

end;


//========================================================================
//  _ZahlF
//              wandelt einen Float in Alpha um
//========================================================================
sub _ZahlF(aZahl : float; aStellen : int) : alpha;
begin
  if (List_xml) then RETURN ANum(aZahl,aStellen)
  RETURN cnvaF(aZahl,0,0,aStellen);
end;


//========================================================================