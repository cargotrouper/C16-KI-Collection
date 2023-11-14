@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_XML
//                OHNE E_R_G
//  Info
//
//
//  08.04.2008  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    ...
//    ...
//
//========================================================================
@I:Def_Global

global Struct_XML begin
  s_XML_ID        : int;
  s_XML_Parent    : int;
  s_XML_Name      : alpha;
  s_XML_Content   : alpha(1000);
  s_XML_HasChild  : logic;
  s_XML_Column    : int;
  s_XML_Depth     : int;
end;

local begin
  gErg        : int;
  gDIA        : int;
  gProg       : int;
  gTxt        : int;
  gMaxZ       : int;
  gZ          : int;
  gS          : int;

  gID         : int;
  gPar        : int;
  gDepth      : int;
  gTagCount   : int;
  gContCount  : int;
  gList       : int;

  gItem     : int;

  gI        : int;
  gColumn   : int;
  gValue    : alpha(4000);
  gElement  : alpha;

end;
define begin
  cEOF      : '[-EOF-]'
  cEOL      : StrChar(13)+StrChar(10)

end;

declare DebugBindingPrint( var aMapping : int[]; aRowCnt : int;  );
declare DebugBindingSet(  var aMapping : int[];   aRowCnt : int;  );
declare arraySet(aY : int; aX : int; var aMapping : int[]; aVal : int) : int;

//========================================================================
//  W_Create
//
//========================================================================
sub w_Create(
  aName : alpha(1000) ) : int;
local begin
  vFile : int
end;
begin

  // File erzeugen...
  vFile # FSIOpen(aName, _FsiAcsRW | _FsiCreate | _FsiTruncate);
  if (vFile<=0) then RETURN vFile;

  // Kopf schreiben...
  FSiWrite(vFile, '<?xml version="1.0" encoding="utf-8"?>'+cEOL);

  RETURN vFile;
end;


//========================================================================
//  W_Close
//
//========================================================================
sub w_Close(aFile  : int) : logic;
begin
  FSIClose(aFile);
  RETURN true;
end;


//========================================================================
//  W_ELOpen
//
//========================================================================
sub w_ELOpen(
  aFile   : int;
  var aD  : int;
  aName   : alpha) : logic;
begin
  aName # Lib_Strings:Strings_DOS2XML(aName);

  if (aD>0) then
    FSiWrite(aFile, StrChar(32,aD)+'<'+aName+'>'+cEOL)
  else
    FSiWrite(aFile, '<'+aName+'>'+cEOL)
  aD # aD + 2;

  RETURN true;
end;


//========================================================================
//  W_ELClose
//
//========================================================================
sub w_ELClose(
  aFile   : int;
  var aD  : int;
  aName   : alpha) : logic;
begin
  aName # Lib_Strings:Strings_DOS2XML(aName);

  if (aD<=0) then RETURN false;
  aD # aD - 2;
  if (aD>0) then
    FSiWrite(aFile, StrChar(32,aD)+'</'+aName+'>'+cEOL)
  else
    FSiWrite(aFile, '</'+aName+'>'+cEOL);

  RETURN true;
end;


//========================================================================
//  W_Set
//
//========================================================================
sub W_Set(
  aFile : int;
  aD    : int;
  aName : alpha;
  aCont : alpha) : logic;
local begin
  vA  : alpha(1000);
end;
begin
  aName # Lib_Strings:Strings_DOS2XML(aName);
  aCont # Lib_Strings:Strings_DOS2XML(aCont);

  if (aD>0) then vA # StrChar(32,aD);
  vA # vA + '<'+aName+'>' + aCont + '</'+aName+'>' + cEOL;
  FSiWrite(aFile, vA);

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================


//========================================================================
//  OpenNewTag
//
//========================================================================
sub OpenNewTag(
  aList     : int;
  aName     : alpha) : logic;
begin

  if (gID<>0) then begin
    if (s_XML_HasChild=n) then begin
      s_XML_HasChild # y;
      s_XML_Depth # s_XML_Depth + 1;
    end;
  end;
  gDepth # 0;
  if (gID<>0) then begin
    gPar    # s_XML_ID;
    gDepth  # s_XML_Depth;// + 1;
  end;
  gID # VarAllocate(struct_XML);
  gTagCount # gTagCount + 1;
  s_XML_ID      # gID;
  s_XML_Parent  # gPar;
  s_XML_Name    # aName;
  s_XML_Depth   # gDepth;
  //s_XML_Content # aContent;
  // in Liste aufnehmen...
  gItem # CteOpen(_cteitem);
  if (gItem<=0) then RETURN false;
  gItem->spID # gID;
  aList->CteInsert(gItem);
  RETURN true;
end;


//========================================================================
//  GetData
//
//========================================================================
sub GetData(
  aZ1 : int;
  aS1 : int;
  aZ2 : int;
  aS2 : int) : alpha;
local begin
  vA  : alpha(4000);
  vB  : alpha(4000);
end;
begin
  if (aZ1>aZ2) then RETURN '';
  if (aZ1=aZ2) and (aS1>=aS2) then RETURN '';

  // nur 1 Zeile...
  if (aZ1=aZ2) then begin
    vA # TextLineRead(gTxt, aZ1, 0);
    vA # StrCut(vA, aS1, aS2-aS1);
    RETURN vA;
  end;

  // mehrere Zeilen...
  // ...xxx
  vA # TextLineRead(gTxt, aZ1, 0);
  vB # StrCut(vA , aS1 , 1000);
//debug('M1:'+vB);

  aZ1 # aZ1 + 1;
  // xxxxxx
  WHILE (aZ1<aZ2) do begin
    vA # TextLineRead(gTxt, aZ1, 0);
    vB # vB + TextLineRead(gTxt, aZ1, 0);
//debug('M2:'+vA);
    aZ1 # aZ1 + 1;
  END;

  // xxx...
  if (aS2>1) then begin
    vA # TextLineRead(gTxt, aZ2, 0);
    vA # StrCut(vA , 1 , aS2-1);
//debug('M3:'+vA);
    vB # vB + vA;
  end;

  RETURN vB;
end;


//========================================================================
//  Read
//
//========================================================================
sub Read(aToken : alpha(10)) : alpha
local begin
  vA    : alpha(4000);
  vZ,vS : int;
end;
begin

  vZ # gZ;
  vS # gS;

  // Zeile suchen...
  vZ # TextSearch(gTxt, gZ, gS, _TextSearchCi, aToken );
  if (vZ=0) then RETURN cEOF;
  if (vZ>gZ) then vS # 1;

  // Zeile holen
  vA # TextLineRead(gTxt, vZ, 0);
  // Spalte suchen...
  vS # StrFind(vA, aToken, vS, _StrCaseIgnore);
  vS # vS;
//debug('scan:'+va+'   for   '+aToken);
//debug('start:'+cnvai(gZ)+'/'+cnvai(gS));
//debug('found:'+cnvai(vZ)+'/'+cnvai(vS));
  // Inhalt zwischen gZ,gS - vZ,vS
  vA # GetData(gZ,gS, vZ,vS);
//debug('got:'+va);
  gZ # vZ;
  gS # vS  + StrLen(aToken);

  // ab Start-Tag
  if (gDia<>0) then begin
    gProg->wpProgressPos # gZ;
    //vBreak # gDia->WinDialogResult() = _WinIdCancel;
  end;

  vA # StrAdj(vA, _StrBegin);
  vA # StrAdj(vA, _StrEnd);
  // remove CR
  //    vA # Str_ReplaceAll(vA,Strchar(13),'');
  // remove TAB
  //    vA # Str_ReplaceAll(vA,Strchar(9),'');

  vA # Lib_Strings:Strings_XML2DOS(vA);

  RETURN vA;
end;


//========================================================================
//  Import
//
//========================================================================
sub Import(
  aList : int;
  aName : alpha(1000)) : alpha
local begin
  vError  : alpha;
  vBreak  : logic;

  vHdl    : int;
  vA      : alpha(4000);
  vB      : alpha(4000);
  vC      : alpha(4000);
  vMode   : alpha;

  vI      : int;
  vX      : int;

end;
begin

  // Textpuffer erstellen...
  gTxt # TextOpen(500);
  gErg # TextRead(gTxt, aName ,_TextExtern|_TextOEM);
  If (gErg<>_rOK) then begin
    gTxt->TextClose();
    RETURN 'File not found!';
  end;

  gMaxZ # TextInfo( gTxt, _textLines);

  gDia # WinOpen('Dlg.Progress',_WinOpenDialog);
  if (gDia != 0) then begin
    vHdl # Winsearch(gDia,'Label1');
    vHdl->wpcaption # Translate('Importiere XML-File...')+' '+aName;
    gProg # Winsearch(gDia,'Progress');
    gProg->wpProgressPos # 0;
    gProg->wpProgressMax # gMaxZ;
    gDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);
  end;


  gZ # 1;
  gS # 1;

  // START *****************************************************************
  // <?xml version="1.0" encoding="utf-8"?>
  // suchen: <?
  vA # Read('<?');
  // suchen: ?>
  vA # Read('?>');
  if (StrFind(StrCnv(vA,_StrUpper),'XML VERSION=',_StrCaseIgnore)=0) then begin
    gTxt->TextClose();
    if (gDia<>0) then gDia->WinClose();
    RETURN 'No XML-file!';
  end;
  if (StrFind(StrCnv(vA,_strUpper),'XML VERSION="1.0"',_StrCaseIgnore)=0) then begin
    gTxt->TextClose();
    if (gDia<>0) then gDia->WinClose();
    RETURN 'Only XML version 1.0 is supported!';
  end;
  if (StrFind(StrCnv(vA,_StrUpper) ,'ENCODING=',_StrCaseIgnore)<>0) then begin
    if (StrFind(StrCnv(vA,_StrUpper),'ENCODING="UTF-8"',_StrCaseIgnore)=0) then begin
      gTxt->TextClose();
      if (gDia<>0) then gDia->WinClose();
      RETURN 'Only UTF-8 encoding is supported!';
    end;
  end;

  // Lsite für alle Tags öffnen...
  //gList # CteOpen(_CteList);

  gTagCount   # 0;
  gContCount  # 0;
  gID         # 0;

  // PARSE *****************************************************************
  vMode # 'START';
  vA    # '';
  REPEAT

    vA # Read('<');
    if (vA=cEOF) then BREAK;

    // Inhalt???
    if (vA<>'') then begin
      vMode # 'CONTENT';
      gContCount # gContCount + 1;
      s_XML_Content # vA;
//debug('INHALT:'+vA);
    end;


    vA # Read('>');
    if (vA=cEOF) then BREAK;
    if (vA='') then CYCLE;


    vX # Lib_Strings:Strings_Count(vA,' ')+1;
    FOR vI # 1 Loop inc(vI) WHILE (vI<=vX) do begin
      vB # Str_token(vA,' ',vI);

      // COMMENT ----------------------------------------------------------
      if (StrCut(vB,1,1)='!') then begin
        CYCLE;
        end

      // TAG-START+ENDE ---------------------------------------------------
      else if (StrCut(vB,StrLen(vB),1)='/') then begin
        vB # StrCut(vB,1,StrLen(vB)-1);
        vMode # 'OPEN';
        if (OpenNewTag(aList,vB)=false) then begin
          vBreak # y;
          vError # 'out of memory!';
          BREAK;
        end;
        vMode # 'CLOSE';
        if (gTagCount<=0) then begin
          vBreak # y;
          vError # 'too much tags closed!';
          BREAK;
        end;
        gTagCount # gTagCount - 1;

        if (s_XML_Parent<>0) then begin
          VarInstance(struct_XML, s_XML_Parent);
        end;
        gContCount # 0;
        CYCLE;

        end

      // TAG-ENDE ---------------------------------------------------------
      else if (StrCut(vB,1,1)='/') then begin

        vMode # 'CLOSE';
        if (gTagCount<=0) then begin
          vBreak # y;
          vError # 'too much tags closed!';
          BREAK;
        end;
        gTagCount # gTagCount - 1;

        if (s_XML_Parent<>0) then begin
          VarInstance(struct_XML, s_XML_Parent);
        end;
        gContCount # 0;
        CYCLE;
        end

      // TAG-START --------------------------------------------------------
      else if (vI=1) then begin

        vMode # 'OPEN';
        if (OpenNewTag(aList,vB)=false) then begin
          vBreak # y;
          vError # 'out of memory!';
          BREAK;
        end;
  //debug('TAG started:'+vB+' '+cnvai(vID));

        end

      // VALUE ------------------------------------------------------------
      else begin
//debug('ATTRIB:'+vB);
        if (Lib_Strings:Strings_Count(vB,'=')=1) then begin
          vC # Str_token(vB,'=',1);
          if (OpenNewTag(aList,vC)=false) then begin
            vBreak # y;
            vError # 'out of memory!';
            BREAK;
          end;

          vC # Str_token(vB,'=',2);
          vC # Str_ReplaceAll(vC,'""',StrChar(254));
          vC # Str_ReplaceAll(vC,'"','');
          vC # Str_ReplaceAll(vC,StrChar(254),'"');
          s_XML_Content # vC;
          gTagCount # gTagCount - 1;
          if (s_XML_Parent<>0) then begin
            VarInstance(struct_XML, s_XML_Parent);
          end;
        end;

      end;

    END;

  UNTIL (vBreak=true) or (gZ >= gMaxZ) or (vA=cEOF);

  gTxt->TextClose();
  if (gDia<>0) then gDia->WinClose();

  // Aufräumen...
  //CteClear(gList,y);
  //CteClose(gList);
  RETURN vError;
end;



//========================================================================
//  FillDL
//
//========================================================================
sub FillDL(
  aDL   : int;
  aList : int);
local begin
  vError  : alpha;
  vBreak  : logic;

  vHdl    : int;
  vA      : alpha(4000);
  vB      : alpha(4000);
  vC      : alpha(4000);
  vMode   : alpha;

  vI      : int;
  vX      : int;
end;
begin

  // OUTPUT *****************************************************************
  //gDIA # WinOpen('Dlg.XML',_WinOpenDialog);
  //gProg # Winsearch(gDIA,'DL.XML');
  vI # 1;
  vX # 0;

  gItem # aList->cteread(_CteFirst);
  WHILE (gItem<>0) do begin
    VarInstance(struct_XML, gItem->spID);

//    if (s_XML_HasChild=n) then begin
      vA # StrCnv(s_XML_Name,_strLetter);
      vX # Winsearch(aDL, vA);
      if (vX=0) then begin
        vX # Winsearch(aDL, 'col'+cnvai(vI));
        vI # vI + 1;
      end;
      if (vX<>0) then begin
        vX->wpname    # vA;
        vX->wpCaption # s_XML_Name;
        vX->wpVisible # y;
        gDepth # 30+255 - (s_XML_Depth * 30);
        vX->wpClmColBkg # ((((gDepth<<8)+ gDepth)<<8)+ gDepth);
        if (vX->wpcustom='') then vX->wpcustom # cnvai(vI-1);
        s_XML_Column # cnvia(vX->wpcustom);
        vX->wpClmWidth # 80;
        if (strlen(s_XML_Name)>8) then
          vX->wpClmWidth # StrLen(s_XML_Name) * 10;
      end;
//    end

    if (s_XML_HasChild) then begin
      aDL->WinLstDatLineAdd('');//s_XML_Name);
      aDL->WinLstCellSet(s_XML_Name,s_XML_Column,_WinLstDatLineLast);
//      $Col1->wpFontAttr # _winFontAttrB;
      if (vX<>0) then vX->wpFontAttr # _winFontAttrB;
      end
    else begin
      if (s_XML_Column<>0) then begin
        aDL->WinLstCellSet(s_XML_Content, s_XML_Column,_WinLstDatLineLast);
      end;
    end;

    gItem # aList->cteread(_CteNext, gItem);
  END;


  //gDia->WinDialogRun(_WinDialogCenter);
  //gDia->winclose();

  // Aufräumen...
  //CteClear(gList,y);
  //CteClose(gList);
  //RETURN vError;

end;



//========================================================================
//  GetField
//
//========================================================================
sub GetField(aName : alpha; aY : int) : alpha;
local begin
  vHDL      : int;
  vCOL      : int;
  vA        : alpha;
  vX        : int;
end;
begin
  aName # StrCnv(aName,_strLetter);

  vHDL # $DL.XML;
  vCol # Winsearch(vHDL, aName);
  if (vCol<>0) then begin
    vX # cnvia(vCol->wpcustom);
    vHDL->WinLstCellGet(vA,vX,aY);
  end;

  RETURN vA;//vHDL->wpcustom;
end;


sub GetFieldD(aName : alpha; aY : int) : date;
local begin
  vA        : alpha;
end;
begin
  vA # GetField(aName, aY);
  if (vA='') then RETURN 0.0.0;
  RETURN cnvda(vA);
end;


sub GetFieldT(aName : alpha; aY : int) : time;
local begin
  vA        : alpha;
end;
begin
  vA # GetField(aName, aY);
  if (vA='') then RETURN 0:0;
  RETURN cnvta(vA);
end;


sub GetFieldB(aName : alpha; aY : int) : logic;
local begin
  vA        : alpha;
end;
begin
  vA # GetField(aName, aY);
  if (vA='Y') or (vA='y') or (vA='1') or (vA='J') or (vA='j') then RETURN true;
  RETURN false;
end;






//========================================================================
//lib_debug:InitDebug();
//debug('Start...');
//  WindialogBox(gFrmMain,'XML', Import('c:\test3.xml') ,0,0,0);




//========================================================================


