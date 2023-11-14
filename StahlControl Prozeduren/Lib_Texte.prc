@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Texte
//                          OHNE E_R_G
//  Info
//
//
//  16.05.2004  AI  Erstellung der Prozedur
//  18.06.2010  AI  Korrektur bei _Zeile2Text
//  06.03.2015  ST  sub RtfTextHatLesbarenText(...)  hinzugefügt
//  14.04.2015  ST  Lesen und Speichern von Lang5texten erkennt weiche Zeilenumbrüche
//  22.04.2015  AH  "Rtf2Txt" für win8
//  18.11.2015  AH  "ReadFormMem", "WriteToMem", "SaveMemToText"
//  12.05.2016  AH  PtdSync
//  08.06.2016  AH  BugFix PtdSync
//  23.06.2016  AH  ESC ESC ESC / StrChar(27) als Seperator für 5er Texte
//  01.12.2017  AH  "Append"
//  23.02.2018  AH  Codepage für Türksich beim Textwandeln
//  01.03.2019  AH  "WRiteToMem" mit Anzahl als Result
//  19.10.2020  AH  "MemReplace"
//  10.12.2020  ST  Bugfix: "Txt2Rtf" Jepsen
//  05.05.2021  AH  "FindLine"
//  27.07.2021  AH  ERX
//  20.10.2021  ST  "Equals" hinzugefügt
//  25.03.2022  DS  "SaveMemToTextbuffer" hinzugefügt
//  2022-06-27  AH  "DelAllAehnlich", "CopyAllAehnlich"
//
//  Subprozeduren
//    SUB Text_Delete(aName   : alpha;aFlags  : int) : int;
//    SUB Text_Rename(aName   : alpha;aName2  : alpha;aFlags  : int) : int;
//    SUB Text_Copy(aName   : alpha;aName2  : alpha;aFlags  : int) : int;
//    SUB Text_Create(aName   : alpha;aFlags  : int) : int;
//    SUB Text_Write(aBuf    : int;aName   : alpha;aFlags  : int) : int;
//
//    SUB DelAllAehnlich
//    SUB CopyAllAehnlich
//    SUB TxtLoad5Buf(aName : Alpha; aTxtHdl_L1 : int; aTxtHdl_L2 : int; aTxtHdl_L3 : int; aTxtHdl_L4 : int; aTxtHdl_L5 : int) : logic;
//    SUB TxtLoadLangBuf(aName : Alpha; aTxtHdl_L1 : int; aLang : alpha;) : logic;
//    SUB TxtSave5Buf(aName : Alpha; aTxtHdl_L1 : int; aTxtHdl_L2 : int; aTxtHdl_L3 : int; aTxtHdl_L4 : int; aTxtHdl_L5 : int)
//    SUB Txt2Rtf(aBufAscii : int; aBufRtf : int; opt aFont : aFontName; opt aFontSize : int; opt aFontAttr : int);
//    SUB TxtDelRange(aVon : alpha; aBis : alpha);
//    SUB _Zeile2Txt(aText     : alphA(1000)  aBufAscii : int);
//    SUB Rtf2Txt(aBufRtf   : int; aBufAscii : int)
//    sub GetTextName ( aFile : word; aNum1 : int; opt aNum2 : int; opt aTyp : alpha ) : alpha
//    SUB RtfTextHatLesbarenText(aTextname : alpha) : logic
//
//    SUB ReadFromMem(aText : handle; aMem : handle; aPos : int; aLen : int; opt aLine : int) : int;
//    SUB WriteToMem(aText : handle; aMem  : handle) : int;
//    SUB SaveMemToText(aMem : handle; aName : alpha)
//    SUB SaveMemToTextbuffer(aMemoryObject : handle) : handle
//    SUB RtfTextSave(aEditObj : int; aName : alpha);
//    SUB RtfTextRead(aEditObj : int; aName : alpha);
//    SUB Append(aTo : Int; aFrom : int)
//    SUB MemReplace(var aMem  : handle;  aVon      : alpha;  aNach     : alpha);
//    SUB FindLine(aTxt : int; aWas : alpha; var aText : alpha; var aZ    : int) : logic
//    SUB Equals(aTxtBuf1 : int; aTxtBuf2) : logic
//
//========================================================================
@I:Def_Global

define begin
  cFont       : 'Verdana'
  cPtdSync    : Set.SQL.SoaYN
  cPtdDirekt  : false   // false=> über SCOPE lösen
end

//========================================================================
//  Text_Delete
//
//========================================================================
SUB Text_Delete(
  aName   : alpha(4096);
  aFlags  : int) : int;
local begin
  vErg  : int;
end;
begin
  vErg # TextDelete(aName, aFlags);

  if (StrCut(aName,1,4)='INI.') then RETURN vErg;

  if (vErg<>_rOK) or (aFlags&_TextProc<>0) or (aFlags&_TextExtern<>0) or (aFlags&_TextClipboard<>0) then RETURN vErg;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_Sync:DeleteText(aName);
    RETURN vErg;
  end
  if (gScopeActual<>0) then begin
    Lib_Rec:_ScopeText('TD',aName);
  end
  else begin
//    StampDB();
    Lib_Odbc:DeleteText(aName);
  end;

  RETURN vErg;
end;


//========================================================================
//  Text_Rename
//
//========================================================================
SUB Text_Rename(
  aName   : alpha(4096);
  aName2  : alpha;
  aFlags  : int) : int;
local begin
  vErg  : int;
end;
begin
  vErg # TextRename(aName, aName2, aFlags);


  if (StrCut(aName,1,4)='INI.') then RETURN vErg;

  if (vErg<>_rOK) or (aFlags&_TextProc<>0) or (aFlags&_TextExtern<>0) or (aFlags&_TextClipboard<>0) then RETURN vErg;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_Sync:RenameText(aName, aName2);
    RETURN vErg;
  end
  if (gScopeActual<>0) then begin
    Lib_Rec:_ScopeText('TR',aName, aName2);
  end
  else begin
//    StampDB();
    Lib_Odbc:RenameText(aName, aName2);
  end;

  RETURN vErg;
end;


//========================================================================
//  Text_Copy
//
//========================================================================
SUB Text_Copy(
  aName   : alpha(4096);
  aName2  : alpha(4096);
  aFlags  : int) : int;
local begin
  vErg  : int;
end;
begin
  vErg # TextCopy(aName, aName2, aFlags);

  if (StrCut(aName,1,4)='INI.') then RETURN vErg;

  if (vErg<>_rOK) or (aFlags&_TextProc<>0) or (aFlags&_TextExtern<>0) or (aFlags&_TextClipboard<>0) then RETURN vErg;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_Sync:InsertText(aName, aName2);
    RETURN vErg;
  end
  if (gScopeActual<>0) then begin
    Lib_Rec:_ScopeText('TCO',aName, aName2);
  end
  else begin
//    StampDB();
    Lib_Odbc:InsertText(aName, aName2);
  end;

  RETURN vErg;
end;


//========================================================================
//  Text_Create
//
//========================================================================
SUB Text_Create(
  aName   : alpha(4096);
  aFlags  : int) : int;
local begin
  vErg  : int;
end;
begin
  vErg # TextCreate(aName, aFlags);


  if (StrCut(aName,1,4)='INI.') then RETURN vErg;

  if (vErg<>_rOK) or (aFlags&_TextProc<>0) or (aFlags&_TextExtern<>0) or (aFlags&_TextClipboard<>0) then RETURN vErg;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_Sync:CreateText(aName);
    RETURN vErg;
  end
  if (gScopeActual<>0) then begin
    Lib_Rec:_ScopeText('TCR',aName);
  end
  else begin
//    StampDB();
    Lib_Odbc:CreateText(aName);
  end;

  RETURN vErg;
end;


//========================================================================
//  Text_Write
//
//========================================================================
SUB Text_Write(
  aBuf    : int;
  aName   : alpha(4096);
  aFlags  : int) : int;
local begin
  vErg  : int;
end;
begin

  vErg # TextWrite(aBuf, aName, aFlags);

  if (StrCut(aName,1,4)='INI.') then RETURN vErg;

  if (vErg<>_rOK) or (aFlags&_TextProc<>0) or (aFlags&_TextExtern<>0) or (aFlags&_TextClipboard<>0) then RETURN vErg;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_Sync:InsertText(aName);
    RETURN vErg;
  end
  if (gScopeActual<>0) then begin
    Lib_Rec:_ScopeText('TI',aName);
  end
  else begin
//    StampDB();
    Lib_Odbc:InsertText(aName);
  end;

  // AFX
  if (vErg=_rOK) then RunAFX('Text.Write.Post',aName+'|'+aint(aFlags));

  RETURN vErg;
end;


//========================================================================
//  2022-06-27  AH
//        löscht alle Texte die einem Namen ähneln (Wildcard am ENDE wird angefügt)
//        z.B. "~401.12345678." für alle mit beliebiger Endung ".K" ".F" usw.
//========================================================================
sub DelAllAehnlich(aName : alpha)
local begin
  Erx   : int;
  vName : alpha;
  vAlt  : alpha;
  vTxt  : int;
end;
begin
  vTxt # TextOpen(160);
  vName # aName;
  aName # aName + '*';
  Erx # TextRead(vTxt,vName,0);
  vName # vTxt -> TextInfoAlpha(_TextName);
  Erx # TextRead(vTxt,vName,0);
  vName # vTxt -> TextInfoAlpha(_TextName);
  WHILE (Erx<=_rNoKey) and (vName=*aName) do begin
    vAlt # vName;
    Erx   # TextRead(vTxt,vName,_textNext);
    vName # vTxt -> TextInfoAlpha(_TextName);
    TxtDelete(vAlt,0);
//debugx('del '+vAlt);
  END;
  TextClose(vTxt);
end;


//========================================================================
//  2022-06-27  AH
//        kopiert alle Texte die einem Namen entsprechen, wobei ein Wildcard angefügt wird
//        z.B. "~401.12345678.", 14, "~401.87654321."
//========================================================================
sub CopyAllAehnlich(
  aName   : alpha;
  aSepPos : int;
  aNew    : alpha;)
local begin
  Erx   : int;
  vName : alpha;
  vNew  : alpha;
  vAlt  : alpha;
  vTxt  : int;
end;
begin
  vTxt # TextOpen(160);
  vName # aName;
  aName # aName + '*';
  Erx # TextRead(vTxt,vName,0);
  vName # vTxt -> TextInfoAlpha(_TextName);
  Erx # TextRead(vTxt,vName,0);
  vName # vTxt -> TextInfoAlpha(_TextName);
  WHILE (Erx<=_rNoKey) and (vName=*aName) do begin
    vAlt # vName;
    vNew # vAlt;
    vNew # aNew + StrCut(vAlt,aSepPos,100);    // 12345678.xxx soll 1234.xxx
    Erx   # TextRead(vTxt,vName,_textNext);
    vName # vTxt -> TextInfoAlpha(_TextName);
//debugx('copy '+vAlt+' -> '+vNew);
    TxtCopy(vAlt,vNew,0);
  END;
  TextClose(vTxt);
end;


//========================================================================
// TxtLoad5Buf
//
//========================================================================
sub TxtLoad5Buf(
  aName     : Alpha(4096);
  aTxtHdl_L1 : int;
  aTxtHdl_L2 : int;
  aTxtHdl_L3 : int;
  aTxtHdl_L4 : int;
  aTxtHdl_L5 : int;
) : logic;
local begin
  vTxtHdl_All       : int;
  vTxtHdl           : int;         // Handle des Textes
  i,j               : int;
  inserted_lines    : int;         // Zeilenzähler des kompletten Textes
  vAlpha1           : alpha(255);
  vSaved            : int;
  vOK               : logic;
  vOpt              : int;
  vSeperator        : alpha;
end
begin
  if (aTxtHdl_L1<>0) then TextClear(aTxtHdl_L1);
  if (aTxtHdl_L2<>0) then TextClear(aTxtHdl_L2);
  if (aTxtHdl_L3<>0) then TextClear(aTxtHdl_L3);
  if (aTxtHdl_L4<>0) then TextClear(aTxtHdl_L4);
  if (aTxtHdl_L5<>0) then TextClear(aTxtHdl_L5);

  vTxtHdl_all # TextOpen(160);
  if (TextRead(vTxtHdl_all,aName,0)<=_rLocked) then begin

    // 23.06.2016
    vSeperator # StrChar(254,3);
    if (TextSearch(vTxtHdl_all, 1, 1, 0, StrChar(27,3))>0) then
      vSeperator # StrChar(27,3);


    vOK # y;
    inserted_lines # 0;
    j # 1;
    FOR  i # 1
    LOOP i # i + 1
    WHILE (i <= TextInfo(vTxtHdl_all,_TextLines)) DO BEGIN

      IF (StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0) <> 0) then begin
        vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
        vAlpha1 # StrCut(vAlpha1,StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0)+3,1);
        j # CnvIa(vAlpha1);
      end
      else begin

        vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
        if (StrLen(vAlpha1)=250) then
          vOpt # _TextNoLinefeed
        else
          vOpt # 0;

        case j of
          1 :  if (aTxtHdl_L1<>0) then TextLineWrite(aTxtHdl_L1,TextInfo(aTxtHdl_L1,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
          2 :  if (aTxtHdl_L2<>0) then TextLineWrite(aTxtHdl_L2,TextInfo(aTxtHdl_L2,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
          3 :  if (aTxtHdl_L3<>0) then TextLineWrite(aTxtHdl_L3,TextInfo(aTxtHdl_L3,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
          4 :  if (aTxtHdl_L4<>0) then TextLineWrite(aTxtHdl_L4,TextInfo(aTxtHdl_L4,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
          5 :  if (aTxtHdl_L5<>0) then TextLineWrite(aTxtHdl_L5,TextInfo(aTxtHdl_L5,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
        end;
      end;
    END;
  end
  else begin
    vOK # n;
  end;
  TextClose(vTxtHdl_All);

  RETURN vOK;
end;


//========================================================================
// TxtLoadLangBuf
//
//========================================================================
sub TxtLoadLangBuf(
  aName       : Alpha;
  aTxtHdl_L1  : int;
  aLang       : alpha;
) : logic;
local begin
  vTxtHdl_All       : int;
  vTxtHdl           : int;          // Handle des Textes
  i,j               : int;
  inserted_lines    : int;         // Zeilenzähler des kompletten Textes
  vAlpha1           : alpha(255);
  vSaved            : int;
  vOK               : logic;
  vLangIndex        : int;
  vOpt              : int;
  vSeperator        : alpha;
end
begin
  if (aTxtHdl_L1<>0) then TextClear(aTxtHdl_L1);


  // Prüfen welche Sprache gelesen werden soll
  if (aLang = Set.Sprache5.Kurz) then
    vLangIndex # 5
  else
  if (aLang = Set.Sprache4.Kurz) then
    vLangIndex # 4
  else
  if (aLang = Set.Sprache3.Kurz) then
    vLangIndex # 3
  else
  if (aLang = Set.Sprache2.Kurz) then
    vLangIndex # 2
  else
    vLangIndex # 1;          /* Keine Angabe = Standardsprache */


  vTxtHdl_all # TextOpen(160);
  if (TextRead(vTxtHdl_all,aName,0)<=_rLocked) then begin

    // 23.06.2016
    vSeperator # StrChar(254,3);
    if (TextSearch(vTxtHdl_all, 1, 1, 0, StrChar(27,3))>0) then
      vSeperator # StrChar(27,3);

    vOK # y;
    inserted_lines # 0;
    j # 1;
    FOR  i # 1
    LOOP i # i + 1
    WHILE (i <= TextInfo(vTxtHdl_all,_TextLines)) DO BEGIN

      IF (StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0) <> 0) then begin
        vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
        vAlpha1 # StrCut(vAlpha1,StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0)+3,1);
        j # CnvIa(vAlpha1);
      end
      else begin
        if (aTxtHdl_L1<>0) AND (j = vLangIndex) then begin
          vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
          //if (StrLen(vAlpha1)=250) then
          if (TextInfo(vTxtHdl_all,_TextNoLinefeed) = 1) then
            vOpt # _TextNoLinefeed
          else
            vOpt # 0;
          TextLineWrite(aTxtHdl_L1,TextInfo(aTxtHdl_L1,_TextLines)+1, vAlpha1,_TextLineInsert | vOpt);
        end;
      end;

    END;
  end
  else begin
    vOK # n;
  end;
  TextClose(vTxtHdl_All);

  RETURN vOK;
end;


//========================================================================
// TxtSave5Buf
//
//========================================================================
sub TxtSave5Buf(
  aName     : Alpha;
  aTxtHdl_L1 : int;
  aTxtHdl_L2 : int;
  aTxtHdl_L3 : int;
  aTxtHdl_L4 : int;
  aTxtHdl_L5 : int;
)
local begin
  vTxtHdl_all            : int;         // Textpuffer für alle Sprachen
  vTxtHdl                : int;          // Handle des Textes
  i,j                    : int;
  inserted_lines         : int;         // Zeilenzähler des kompletten Textes
  txt_length             : int;

  vA                    : alpha(260);
  vOpt                  : int;
end
begin

  vTxtHdl_all # TextOpen(160);

  inserted_lines # 0;
  // ---------------------------
  // Sprachen eintragen
  // ---------------------------
  FOR  j # 1
  LOOP j # j + 1
  WHILE (j <= 5) DO BEGIN

    //TextLineWrite(vTxtHdl_All,TextInfo(vTxtHdl_all,_TextLines)+1,StrChar(254,3) + CnvAi(j),_TextLineInsert | _TextNoLineFeed);
// 23.06.2016    TextLineWrite(vTxtHdl_All,TextInfo(vTxtHdl_all,_TextLines)+1,StrChar(254,3) + CnvAi(j),_TextLineInsert);
TextLineWrite(vTxtHdl_All,TextInfo(vTxtHdl_all,_TextLines)+1,StrChar(27,3) + CnvAi(j),_TextLineInsert);
    inserted_lines # inserted_lines + 1;

    // zum schreibenden Text lesen
    case j of
      1 :  vTxtHdl # aTxtHdl_L1;
      2 :  vTxtHdl # aTxtHdl_L2;
      3 :  vTxtHdl # aTxtHdl_L3;
      4 :  vTxtHdl # aTxtHdl_L4;
      5 :  vTxtHdl # aTxtHdl_L5;
    end;

    if (vTxtHdl<>0) then begin
      txt_length # TextInfo(vTxtHdl,_TextLines);
      FOR  i # 1
      LOOP i # i + 1
      WHILE (i <= txt_length) DO BEGIN
        inserted_lines # inserted_lines + 1;

        vA # TextLineRead(vTxtHdl,i,0);
        if (TextInfo(vTxtHdl,_TextNoLinefeed) = 1) then
          vOpt # _TextNoLinefeed
        else  // = 0
          vOpt # 0;


        TextLineWrite(vTxtHdl_all,inserted_lines,vA,_TextLineInsert | vOpt);
      END;
    end;

  END;

  // ---------------------------------------
  // Alle Sprachen in einen Text schreiben
  // ---------------------------------------
  TxtWrite(vTxtHdl_all,aName, _TextUnlock);

  TextClose(vTxtHdl_All);

END;


//========================================================================
// Line2buf
//
//========================================================================
sub Line2Buf(
  aBufRTF     : int;
  vA          : alpha(250);
  var vZ      : int)
begin

  vA # Str_ReplaceAll(vA, 'Ö','\'+strchar(39)+'d6');
  vA # Str_ReplaceAll(vA, 'ö','\'+strchar(39)+'f6');
  vA # Str_ReplaceAll(vA, 'Ä','\'+strchar(39)+'c4');
  vA # Str_ReplaceAll(vA, 'ä','\'+strchar(39)+'e4');
  vA # Str_ReplaceAll(vA, 'Ü','\'+strchar(39)+'dc');
  vA # Str_ReplaceAll(vA, 'ü','\'+strchar(39)+'fc');
  vA # Str_ReplaceAll(vA, 'ß','\'+strchar(39)+'df');
  vA # Str_ReplaceAll(vA, strchar(9),'\tab ');
  vA # Str_ReplaceAll(vA, strchar(31),'');
  vA # Str_ReplaceAll(vA, strchar(255),'\par');
//    if (vL<250) then
//      vA # vA + '\par';
//debugx(aint(vZ+aOffset));
  TextLineWrite(aBufRtf,vZ,vA,_TextLineInsert);
  inc(vZ);
end;


//========================================================================
// Txt2Rtf
//      wandelt einen normalen ASCII-Textbuffer in ein RTF Textbuffer um
//========================================================================
sub Txt2Rtf(
  aBufAscii     : int;
  aBufRtf       : int;
  opt aFont     : alpha;
  opt aFontSize : int;
  opt aFontAttr : int;
  opt aAppend   : logic);
local begin
  vX          : int;
  vZ          : int;
  vA,vB,vC    : alpha(4096);
  vEndeLeer   : int;
  vL          : int;
  vAttribut   : alpha;
  vOffset     : int;
end;
begin

//if (auf.p.position=1) then begin
//  Textread(aBufRtf,'!!!',0);
//  RETURN;
//end;

/***
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Verdana;}}
{\colortbl ;\red0\green0\blue0;}
{\*\generator Msftedit 5.41.15.1507;}\viewkind4\uc1\pard\cf1\lang1031\f0\fs16 alles deutsch\par
2\par
3\par
4\par
x\par
}
***/
  if (aFont='') then     aFont # cFont
  if (aFontSize=0) then  aFontSize # 10;
  if (aFontAttr=0) then  aFontAttr # 0;

  if (aAppend=false) then begin
    TextClear(aBufRtf);
  end
  else begin
    vZ # TextInfo(aBufRtf, _TextLines);
    if (vZ<>0) then begin
      // letzte '\par}' entfernen...
      vA # TextLineRead(aBufRtf, vZ, 0);
      if (StrCut(vA, StrLen(vA)-4,5)='\par}') then begin
        vA # StrCut(vA, 1, StrLen(vA) - 5);
        TextLineWrite(aBufRtf, vZ, vA, 0);
      end;
    end;
  end;

  if (aFontAttr & _WinFontAttrBold<>0) then vAttribut # vAttribut +'\b ';        //bold
  if (aFontAttr & _WinFontAttrUnderline<>0) then vAttribut # vAttribut +'\ul ';  //underline
  if (aFontAttr & _WinFontAttrItalic<>0) then vAttribut # vAttribut +'\i '       //kursiv

  // kein Text da?
  if (TextInfo(aBufAscii,_TextLines)=0) then RETURN;

/** Test für leere RTF
  TextLineWrite(aBufRtf,1,'{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Arial;}}',_TextLineInsert);
  TextLineWrite(aBufRtf,2,'{\*\generator Msftedit 5.41.15.1515;}\viewkind4\uc1\pard\lang1031\fs20\par',_TextLineInsert);
  TextLineWrite(aBufRtf,3,'}',_TextLineInsert);
RETURN;
**/
/**
  TextLineWrite(aBufRtf,1,'{\rtf1\ansi\ansicpg1252\deff0',_TextLineInsert);
  TextLineWrite(aBufRtf,2,'{\fonttbl',_TextLineInsert);
  TextLineWrite(aBufRtf,3,'{\f0\fnil\fcharset0 '+aFont+';}}',_TextLineInsert);
  TextLineWrite(aBufRtf,4,'{\colortbl ;\red0\green0\blue0;}',_TextLineInsert);
  TextLineWrite(aBufRtf,5,'\viewkind4\uc1\pard\cf1\lang1031\fs'+cnvai(aFontSize*2),_TextLineInsert);
***/
  vOffset # TextInfo(aBufRTF, _textLines);
  if (aAppend=false) then begin
    TextLineWrite(aBufRtf,1,'{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 '+aFont+';}}',_TextLineInsert);
    TextLineWrite(aBufRtf,2,'{\colortbl ;\red0\green0\blue0;\red255\green0\blue0;\red0\green155\blue0;}',_TextLineInsert);
    vOffset # 2;
  end
  else begin
  end;

//  TextLineWrite(aBufRtf,3,'{\*\bla;}\viewkind4\uc1\pard\cf1\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+vA+'',_TextLineInsert);

  vZ # 1 + vOffset;
  FOR vX # 1;
  LOOP inc(vX)
  WHILE (vX<=TextInfo(aBufAscii,_TextLines)) do begin

    vA # vAttribut + TextLineRead(aBufAscii,vX,0);
    vA # Str_ReplaceAll(vA, '{', '\{');
    vA # Str_ReplaceAll(vA, '}', '\}');
    vL # StrLen(vA);

    // ist diese Zeile voll? NEIN, dann Umbruch
    if (vL<250) then begin
      vA # vA + StrChar(255);
    end
      // Zeilie ist voll, ist dann die NÄCHSTE gefüllt?
    else if (vL=250) and (vX<TextInfo(aBufAscii,_TextLines)) then begin
      vC # TextLineRead(aBufAscii,vX+1,0);
      vC # Str_ReplaceAll(vC, '{', '\{');
      vC # Str_ReplaceAll(vC, '}', '\}');
      // nächste Zeile leer = UMBRUCH
      if (StrLen(vC)=0) then
        vA # vA + StrChar(255);
    end;

    REPEAT  // in 80er Blöcke teilen

      vB # StrCut(vA,1,80);

      if (vZ<>3) then begin
        Line2Buf(aBufRtf, vB, var vZ);
      end
      else begin  // erste (=3) Zeile
// ZEILENABSTAND per sl"-xxx" einstellbar
//                                  \viewkind4\uc1\pard\sl-260\slmult0\lang1031\f0\fs24 AAAAAA\par
        //Line2Buf(aBufRtf, '{\*\bla;}\viewkind4\uc1\pard\sl-170\slmult0\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+vB+'', var vZ);
        //Line2Buf(aBufRtf, '{\*\bla;}\viewkind4\uc1\pard\sl-230\slmult0\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+vB+'', var vZ);
        Line2Buf(aBufRtf, '{\*\bla;}\viewkind4\uc1\pard\cf1\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+vB+'', var vZ);
      end;

      vA # StrCut(vA,81,200);
    UNTIL (vA='');

  END;

  // KNACKPUNKT :
  vA # TextLineRead(aBufRtf, vZ-1, 0);
//TextLineWrite(aBufRtf,vZ-1,vA+'\par}',0);    // Funktionert nicht mehr bei Jepsen
  TextLineWrite(aBufRtf,vZ-1,vA+'\par\par}',0);  // <-- So funkltioniert es bei Jepsen  ST 2020-12-10 2100/23


//TxtWrite(aBufRTF, '!!!X!!!',0);
//todo('savetext');

//  TextLineWrite(aBufRtf,vZ,'}',_TextLineInsert);
//  TextLineWrite(aBufRtf,vZ,'\par',_TextLineInsert); vZ # vZ + 1;
//  TextLineWrite(aBufRtf,vZ,'\par}',_TextLineInsert);

//TxtWrite(aBufRtf, 'c:\xxx'+aint(SysTics())+'.txt', _TextExtern);
RETURN;



  vZ # 2+1;
  FOR vX # 1; LOOP inc(vX) WHILE (vX<=TextInfo(aBufAscii,_TextLines)) do begin
    vA # TextLineRead(aBufAscii,vX,0);
    vL # StrLen(vA);

    vA # Str_ReplaceAll(vA, 'Ö','\'+strchar(39)+'d6');
    vA # Str_ReplaceAll(vA, 'ö','\'+strchar(39)+'f6');
    vA # Str_ReplaceAll(vA, 'Ä','\'+strchar(39)+'c4');
    vA # Str_ReplaceAll(vA, 'ä','\'+strchar(39)+'e4');
    vA # Str_ReplaceAll(vA, 'Ü','\'+strchar(39)+'dc');
    vA # Str_ReplaceAll(vA, 'ü','\'+strchar(39)+'fc');
    vA # Str_ReplaceAll(vA, 'ß','\'+strchar(39)+'df');
    vA # Str_ReplaceAll(vA, strchar(31),'');
    if (vL<250) then
      vA # vA + '\par';

    REPEAT  // auf 250 Zeichen gruppieren

      vB # StrCut(vA,1,250);

      if (vB='\par') then Inc(vEndeLeer)
      else vEndeLeer # 0;

      if (vZ>3) then begin
        TextLineWrite(aBufRtf,vZ,vB,_TextLineInsert);
      end
      else begin  // erste Zeile
//debug('NEUE ERSTE:');
        if (StrLen(vB)<200) then begin
//debug('small');
          TextLineWrite(aBufRtf,vZ,'{\*\bla;}\viewkind4\uc1\pard\cf1\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+vB+'',_TextLineInsert)
        end
        else begin
//debug('BIG');
          TextLineWrite(aBufRtf,vZ,'{\*\bla;}\viewkind4\uc1\pard\cf1\lang1031\f0\fs'+cnvai(aFontSize*2)+' '+StrCut(vB,1,199)+'',_TextLineInsert | _TextNoLinefeed);
          vZ # vZ + 1;
          TextLineWrite(aBufRtf,vZ,StrCut(vB,200,50),_TextLineInsert);
        end;
      end;


      inc(vZ);
      vA # StrCut(vA,251,4000);
    UNTIL (vA='');
  END;

  // am Ende MUSS ein "\par" stehen, sonst eins anlegen

//  if (vEndeLeer=0) then begin
//    TextLineWrite(aBufRtf,vZ,'\par',_TextLineInsert);
//    inc(vZ);
//  end;

//  TextLineWrite(aBufRtf,vZ,' \par}',_TextLineInsert); // SPACER !!!!
  TextLineWrite(aBufRtf,vZ,'}',_TextLineInsert);
//  vA # TextLineRead(aBufRtf,vZ-1,0);
//  vA # vA + ')';
//  TextLineWrite(aBufRtf,vZ-1, vA ,0);
//TxtWrite(aBufRtf, 'c:\xxx'+cnvai(auf.p.position)+'.txt', _TextExtern);
end;


//========================================================================
// TxtDelRange
//
//========================================================================
sub TxtDelRange(aVon : alpha; aBis : alpha);
local begin
  vBuf : int;
  vName : alpha;
end;
begin
  vBuf # TextOpen(1);

  WHILE (TextRead(vBuf,aVon,0 | _TextNoContents)<>_rNoRec) do begin
    vName # TextInfoAlpha(vBuf,_TextName);
    if (vName<aVon) or (vName>aBis) then BREAK;
    TxtDelete(vName,0);
  END;

  TextClose(vBuf);
end;


//========================================================================
// _Zeile2Txt
//
//========================================================================
sub _Zeile2Txt(
  aText     : alphA(4000);
  aBufAscii : int);
local begin
  vL  : int;
  vC  : alphA(4096);
end;
begin
  vL # StrLen(aText);
  if (vL > 250) then begin
    repeat
      vC # StrCut(aText,1,250);
      TextLineWrite(aBufAscii,TextInfo(aBufAscii, _TextLines)+1,vC,_TextLineInsert);
//debug('Part:');
//debug(vC);
      aText # StrCut(aText,251,vL-250);
      vL # StrLen(aText);
    until (vL = 0);
  end
  else begin
    TextLineWrite(aBufAscii,TextInfo(aBufAscii, _TextLines)+1,aText,_TextLineInsert);
//    TextLineWrite(aBufAscii,aZ,aText,_TextLineInsert);
//debug('Part:');
//debug(vC);
  end;

end;


//========================================================================
// Rtf2Txt
//      wandelt einen RTF Textbuffer in ein normalen ASCII-Textbuffer um
//========================================================================
sub Rtf2Txt(
  aBufRtf   : int;
  aBufAscii : int;
)
local begin
  vX        : int;
  xvZ        : int;
  vI1,vI2   : int;
  vA,vB,vC  : alpha(4096);
  vEndeLeer : int;
  vL        : int;
  vLFamEnde : logic;
  vRest     : alpha(1000);
end;
begin
  TextClear(aBufAscii);
  // kein Text da?
  if (TextInfo(aBufRtf,_TextLines)=0) then RETURN;
/*
{\rtf1\ansi\ansicpg1252\deff0{\fonttbl{\f0\fnil\fcharset0 Arial;}}
{\*\generator Msftedit 5.41.15.1515;}\viewkind4\uc1\pard\lang1031\fs20 /par ok\par
\\par bug\par
! ok\par
^ ok\par
" ok\par
\'a7 ok\par
$ ok\par
% ok\par
& ok\par
/ ok\par
( ok\par
) ok\par
= ok\par
? ok\par
\'b4 ok\par
\\ bug\par
\} bug\par
] ok\par
[ ok\par
\{ ok\par
\'b3 ok\par
\'b2 ok\par
^ ok\par
\'b0 ok\par
< ok\par
> ok\par
| ok\par
// ok\par
\\\\ bug\par
# ok\par
* ok\par
'' ok\par
'  ok\par
- ok\par
_ ok\par
}
*/

//  vZ # 1;
  FOR vX # 2; LOOP inc(vX) WHILE (vX<=TextInfo(aBufRtf,_TextLines)) do begin
    vA # vRest + TextLineRead(aBufRtf,vX,0);

//    vI1 # Strfind(vA, 'viewkind4\uc1\pard\lang1031',1);
    vI1 # Strfind(vA, 'viewkind4\uc1',1); // Win8
    if (vI1 > 1) then begin
      vI2 # Strfind(vA, ' ',vI1,1);
      if (vI2>0) then
        vB # StrCut(vA, vI2+1, 250)
      else
        vB # '';
    end
    else begin
      vB # vA;
    end;


    // ;{KOMMENTAR} finden
    vI1 # StrFind(vB,';{',0);
    WHILE (vI1>0) do begin
      vI2 # StrFind(vB,';}',vI1);
      if (vI2<>0) then vB # StrDel(vB, vI1, vI2-vI1+1)
      else BREAK;
      if (StrLen(vB)=0) then BREAK;
      vI1 # StrFind(vB,';{',0);
    END;
    if (vI1<>0) and (StrLen(vB)=0) then begin
      CYCLE;
    end;

    // {HYPERLINK""} finden
    vI1 # StrFind(vB,'{HYPERLINK "',0);
    WHILE (vI1>0) do begin
      vI2 # StrFind(vB,'"}',vI1);
      if (vI2<>0) then vB # StrDel(vB, vI1, vI2-vI1+1)
      else BREAK;
      if (StrLen(vB)=0) then BREAK;
      vI1 # StrFind(vB,'{HYPERLINK "',0);
    END;

    vB # Str_ReplaceAll(vB,'\{',                 '{');
    vB # Str_ReplaceAll(vB,'\}',                 '}');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'d6', 'Ö');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'f6', 'ö');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'c4', 'Ä');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'e4', 'ä');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'dc', 'Ü');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'fc', 'ü');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'df', 'ß');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'a7', '§');    // Ab hier neu ST
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'b4', '´');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'b3', '³');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'b2', '²');
    vB # Str_ReplaceAll(vB,'\'+strchar(39)+'b0', '°');

    vB # Str_ReplaceAll(vB, strchar(31),'');
    vB # Str_ReplaceAll(vB,'\\', StrChar(255));
    vLFamEnde #  StrCut(vB,StrLen(vB)-3,4)='\par';
    vB # Str_ReplaceAll(vB,'\pard', '');    // win8
    vB # Str_ReplaceAll(vB,'\par', '');

    // {} finden
/*
    vI1 # StrFind(vB,'{',0);
    WHILE (vI1>0) do begin
      vI2 # StrFind(vB,'}',vI1);
      if (vI2<>0) then vB # StrDel(vB, vI1, vI2-vI1+1)
      else BREAK;
      if (StrLen(vB)=0) then BREAK;
      vI1 # StrFind(vB,'{',0);
    END;
    if (vI1<>0) and (StrLen(vB)=0) then begin
      CYCLE;
    end;
*/
    // Backslash finden
    vI1 # StrFind(vB,'\',0);
    WHILE (vI1>0) do begin
      vI2 # StrFind(vB,' ',vI1);
      if (vI2<>0) then begin
        vB # StrDel(vB, vI1, vI2-vI1+1)
      end
      else begin
        vB # StrDel(vB, vI1, 200);
        BREAK;
      end;
      vI1 # StrFind(vB,'\',vI1);
    END;

    vB # Str_ReplaceAll(vB,StrChar(255),                 '\');
//    vB # Str_ReplaceAll(vB,'\\',                 '\');
    vB # Str_ReplaceAll(vB,'{', '');
    vB # Str_ReplaceAll(vB,'}', '');


    if (vLFamEnde=n) then begin
//debug('rest:');
      vRest # vB;
      CYCLE;
    end;
    vRest # '';
//debug('zeile :'+aint(vZ));
    _Zeile2Txt(vB, aBufAscii);
//    inc(vZ);
  END;  // FOR

  if (vRest<>'') then begin
//debug('LETZTE ZEILE:'+vRest);
    _Zeile2Txt(vRest, aBufAscii);
  end;


//TxtWrite(aBufAscii, '!!!X!!!',0);
//todo('savetext');

end;


//=========================================================================
sub GetTextNamePacked(
  aFile   : word;
  aNum1   : int;      // max 99.999.999
  aNum2   : word;     // max 9.999
  aNum3   : word;     // max 9.999
  aTyp    : alpha ) : alpha
local begin
  vName   : alpha;
  vBig    : Bigint;
end;
begin

  vName # '~'+aint(aFile);
  vBig # cnvib(aNum1);
  vBig # vBig *10000\b;
  vBig # vBig + cnvib(aNum2);
  vBig # vBig *10000\b;
  vBig # vBig + cnvib(aNum3);
  vName # vName + '.' + cnvab(vBig, _FmtNumHex) + '.' + aTyp;

  RETURN vName;
end;


//=========================================================================
// GetTextName
//        Konstruiert den Textnamen anhand des Formats der jeweiligen Datei
//        und den angegebenen Parametern.
//=========================================================================
sub GetTextName (
  aFile     : word;
  aNum1     : int;
  opt aNum2 : int;
  opt aTyp  : alpha;
  opt aNum3 : int;
) : alpha
local begin
  vName : alpha;
end;
begin
  if (aNum3>0) then RETURN GetTextNamePacked(aFile, aNum1, aNum2, aNum3, aTyp);

  case aFile of
    // Projektposition
    122 : begin // Format: ( 122, Prj.P.Nummer, Prj.P.Position, '1' )
      //       12345678901234567890
      // norm: ~122.99999999.9999.9999.x
      // pack: ~122.2386F26C0FFFF.1
      vName # '~122';
      vName # vName + '.' + CnvAI( aNum1, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ); // Projektnummer
      vName # vName + '.' + CnvAI( aNum2, _fmtNumLeadZero | _fmtNumNoGroup, 0, 4 ); // Projektposition
      vName # vName + '.' + aTyp; // Texttyp (1: Beschreibung, 2: Interne Informationen)
    end;
  end;

  RETURN vName;
end;


//=========================================================================
// sub RtfTextHatLesbarenText(aTextname : alpha) : logic
//    Ermittelt ob der Übergebene RTF für den Menschen lesbaren
//    Text enthält
//=========================================================================
sub RtfTextHatLesbarenText(aTextname : alpha) : logic
local begin
  Erx       : int;
  vBufRtf   : int;
  vBufAscii : int;

  vTestline : alpha(250);
  i : int;
  vLineCnt : int;
  vOk : logic;
end
begin
  vOK # false;

  vBufRtf   # TextOpen(16);
  Erx # TextRead(vBufRtf,aTextname,0);
  if (Erx = _rOK) then begin

    // RTF Parsen und im Asciitext nach gefüllten Zeilen suchen
    vBufAscii # TextOpen(16);
    TextCLear(vBufAscii);
    Lib_Texte:Rtf2Txt(vBufRtf, vBufAscii);
    vLineCnt # TextInfo(vBufAscii,_TextLines);

    FOR   i # 1
    LOOP  inc(i)
    WHILE i <= vLineCnt DO BEGIN
      vTestline # TextLineRead(vBufAscii,i,0);
      if ((StrAdj(StrCnv(vTestLine,_StrLetter),_StrAll) <> '')) then begin
        vOk # true;
        BREAK;
      end;
    END;
    TextClose(vBufAscii);
  end;
  TextClose(vBufRtf);


  RETURN vOK;
end;


//========================================================================
// ReadFromMem
//    Text aus Memory laden (aus der CodeLib: "HTTPClient.Text.SaveMem"
//========================================================================
sub ReadFromMem(
  aText                 : handle;       // Text
  aMem                  : handle;       // Speicherblock
  aPos                  : int;          // Position
  aLen                  : int;          // Länge
  opt aLine             : int;          // Zeile
) : int;
local begin
  vLen                : int;
  vLenL               : int;
  vPosB               : int;
  vPosE               : int;
  vStr                : alpha(250);
  vStrBrk             : alpha(2);
  vLenBrk             : int;
  vBrk                : logic;
end;
begin
  if (aLen < 0) then begin
    case (aLen) of
      _MemDataLen : vLen # aMem->spLen;         // 256
      _MemObjSize : vLen # aMem->spSize;
      otherwise     vLen # 0;
    end;
  end
  else begin
    vLen # aLen;
  end;

  if (aLine = 0) then
    aLine # aText->TextInfo(_TextLines) + 1;

  vStrBrk # StrChar(13);
  vLenBrk # StrLen(vStrBrk);                      // =1

  vPosB # aPos;                                   // =1
  WHILE (vPosB < vLen) do begin                   // 1<256
    vLenL # Min(vLen - vPosB + 1, 250 + vLenBrk); // 256-1+1,250+1=251
    vPosE # aMem->MemFindStr(vPosB, vLenL, vStrBrk);  //1,1,X  = 0
    if (vPosE > 0) then begin
      vBrk # TRUE;
      if (gCodepage=1254) then
        vStr # aMem->MemReadStr(vPosB, vPosE -vPosB, _CharsetC16_1254)  // TÜRKISCH
      else
        vStr # aMem->MemReadStr(vPosB, vPosE -vPosB, _CharsetC16_1252);
      vPosB # vPosE + vLenBrk;
    end
    else begin
      vBrk # FALSE;
//AHTEST      if (vPosB+vLenL<vLen) then vBrk # true;
      vLenL # Min(vLenL, 250);
      if (gCodepage=1254) then
        vStr # aMem->MemReadStr(vPosB, vLenL, _CharsetC16_1254)   // TÜRKISCH
      else
        vStr # aMem->MemReadStr(vPosB, vLenL, _CharsetC16_1252);
      inc(vPosB, vLenL);
    end;

    aText->TextLineWrite(aLine, vStr, _TextLineInsert | _TextNoLineFeed * CnvIL(!vBrk));
//debugx('addline:'+vStr+'|'+abool(vBrk));
    inc(aLine);
  end;
end;


//========================================================================
// WriteToMem
//    Textbuffer in Memory schreiben
//========================================================================
sub WriteToMem(
  aText : handle;
  aMem  : handle;
  opt aLF : alpha) : int;
local begin
  vMax  : int;
  vI    : int;
  vA    : alpha(255);
  vCont : logic;
  vLen  : int;
  vLFLen  : int;
end;
begin
  if (aLF='') then aLF # StrChar(13);
  vLFLEn # StrLen(aLF);

  vMax  # TextInfo(aText, _TextLines);

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    vA    # TextLineRead(aText, vI, 0);
    vCont # (TextInfo(aText, _TextNoLineFeed)=1)
    vLen # vLen + Strlen(vA);
    aMem->MemWriteStr(_MemAppend, vA, _CharsetC16_1252);  // WIE TÜRKISCH ???
//    aMem->MemWriteStr(_MemAppend, vA);
    if (!vCont) then begin
      aMem->MemWriteStr(_MemAppend, aLF);
      vLen # vLen + vLFLen;
    end;
  END;

  RETURN vLen;
end;


//========================================================================
// SaveMemToText
//========================================================================
sub SaveMemToText(aMem : handle; aName : alpha)
local begin
  vTxt  : int;
end;
begin
  vTxt # TextOpen(16);
  ReadFromMem(vTxt, aMem, 1, _MemDataLen);
  TextWrite(vTxt, aName, 0);
  TextClose(vTxt);
end;


//========================================================================
// SaveMemToTextbuffer
//========================================================================
sub SaveMemToTextbuffer
(
  aMemoryObject : handle
) : handle  // auf Textpuffer
local begin
  vTxtbuf  : int;
end;
begin
  vTxtbuf # TextOpen(16);
  Lib_Texte:ReadFromMem(vTxtbuf, aMemoryObject, 1, _MemDataLen);
  return vTxtbuf;
end;


//========================================================================
//  RepairTexte
//        fixt die CRLF in Vorgabetexten
//========================================================================
sub RepairTexte();
local begin
  Erx   : int;
  vTxt  : int;
  vA,vB : alpha(4000);
  vJ,vI : int;
end;
begin
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
end;


//========================================================================
// RtfTextSave
//              Text abspeichern
//========================================================================
sub RtfTextSave(
  aEditObj  : int;
  aName     : alpha;
)
local begin
  vTxtHdl             : int;          // Handle des Textes
end
begin
  // Text laden
  vTxtHdl # aEditObj->wpdbTextBuf;
  if (vTxtHdl=0) then RETURN;
  aEditObj->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);

  // Text speichern
  TxtWrite(vTxtHdl,aName, _TextUnlock);
END;


//========================================================================
// RtfTextRead
//              Text einlesen
//========================================================================
sub RtfTextRead(
  aEditObj  : int;
  aName     : alpha;
)
local begin
  vTxtHdl             : int;          // Handle des Textes
end
begin

  // Text laden
  vTxtHdl # aEditObj->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    aEditObj->wpdbTextBuf # vTxtHdl;
  end;

  if (TextRead(vTxtHdl,aName, _TextUnlock)>_rLocked) then
    TextClear(vTxtHdl);

  aEditObj->WinRtfLoad(_WinStreamBufText,0,vTxtHdl);
end;


//========================================================================
//  Append
//========================================================================
sub Append(
  aTo   : Int;
  aFrom : int)
local begin
  vI    : int;
  vMax  : int;
  vA    : alpha(300);
  vOpt  : int;
end;
begin
  vMax # TextInfo(aFrom, _TextLines);

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    vA # TextLineRead(aFrom, vI, 0);
    if (TextInfo(aFrom,_TextNoLinefeed) = 1) then
      vOpt # _TextNoLinefeed
    else
      vOpt # 0;
    TextLineWrite(aTo,TextInfo(aTo,_TextLines)+1, vA,_TextLineInsert | vOpt);
  END;

end;


//========================================================================
//========================================================================
sub MemReplace(
  var aMem  : handle;
  aVon      : alpha;
  aNach     : alpha);
local begin
  vStrLen1  : int;
  vStrLen2  : int;
  vMem      : handle;
  vMax      : int;
  vPos      : int;
  vPos2     : int;
  vLastPos  : int;
end;
begin
//debug('abcdefgabc');
  vStrLen1 # strlen(aVon);
  vStrLen2 # strlen(aNach);
  vMem # MemAllocate(_MemAutoSize);

  // 1234567890     ersetze B mit xxx
  // abcdefgabc

  vMax      # aMem->splen;
  vPos      # 1;
  vPos2     # 1;
  vLastPos  # vPos;
  WHILE (vLastPos<vMax) do begin
    vPos # aMem->MemFindStr(vLastPos, vMax-vLastPos+1, aVon);
//debugx(aVon+' found@ '+aint(vPos));
    if (vPos=0) then BREAK;
    // linken Teil nehmen...
    if (vPos>vLastpos) then begin
//debugx('move ab '+aint(vLastPos)+'+'+aint(vPos-vLastPos)+' nach '+aint(vPos2));
      MemCopy(aMem, vLastPos, vPos-vLastPos, vPos2, vMem);
      vPos2 # vPos2 + (vPos-vLastPos);
    end;
//debugx(aNach+' @ '+aint(vPos2));
    MemWriteStr(vMem, vPos2, aNach);
    vPos2 # vPos2 + vStrLen2;
    vLastPos # vPos + vStrLen1;
//debugx('NEXT last='+aint(vLastPos)+'  pos2='+aint(vPos));
  END;
  // letzten Rest nehmen
  if (vLastPos<=vMax) then
    MemCopy(aMem, vLastPos, vMax-vLastPos+1, vPos2, vMem);
    
  aMem->Memfree();
  aMem # vMem;
end;

  
//========================================================================
//  FindLine
//      sucht einen Zeileninhalt
//========================================================================
SUB FindLine(
  aTxt      : int;
  aWas      : alpha;
  var aText : alpha;
  var aZ    : int) : logic
begin
  if (aZ=0) then aZ # 1;
  
  aText # '';
  aZ # TextSearch(aTxt, aZ, 1, _TextSearchCI, aWas);
  if (aZ<=0) then RETURN false;
  aText # TextLineread(aTxt, aZ, 0);
  RETURN true;
end;
  
//========================================================================
//  sub Equals(aTxtBuf1 : int; aTxtBuf2 : int) : logic  ST 2021-10-21
//  Überbrüft zwei Textpuffer auf Gleichheit
//========================================================================
sub Equals(aTxtBufA : int; aTxtBufB : int) : logic
local begin
  vLinesA  : int;
  vLinesB  : int;
  
  vSizeA   : int;
  vSizeB   : int;
  
  vLine     : int;
  vLines    : int;
  vLineA    : alpha(250);
  vLineB    : alpha(250);
end
begin
  vLinesA  # TextInfo(aTxtBufA,_TextLines);
  vLinesB  # TextInfo(aTxtBufB,_TextLines);
  vSizeA   # TextInfo(aTxtBufA,_TextSize);
  vSizeB   # TextInfo(aTxtBufB,_TextSize);
  
  if (vLinesA <> vLinesB) then
    RETURN false;
      
  // Bei nichtgespeicherten Texten, z.B. während Auftragseingabe etc., gibt es noch keine Größe
  if (vSizeA <> 0) AND (vSizeB <> 0) AND (vSizeA <> vSizeB) then
    RETURN false;
   
  vLines # TextInfo(aTxtBufA,_TextLines);
  FOR   vLine # 1
  LOOP  inc(vLine)
  WHILE vLine <= vLines DO BEGIN
    vLineA  # TextLineRead(aTxtBufA,vLine,0);
    vLineB  # TextLineRead(aTxtBufB,vLine,0);
    if (vLineA <> vLineB) then
      RETURN false;
  END;
 
  RETURN true;
end;


/*========================================================================
2023-05-02  AH
            ersetzt Umlaufe von WINDOWS nach DOS (C16)
========================================================================*/
Sub Mem_WIN2DOS(
  var aMem : handle)
begin

  Lib_Texte:MemReplace(var aMem, 'ú', '"'); // 132
  Lib_Texte:MemReplace(var aMem, 'Ä', '"'); // 147

  Lib_Texte:MemReplace(var aMem, strchar(150), '-');    // -

  Lib_Texte:MemReplace(var aMem, strchar(228), 'ä');
  Lib_Texte:MemReplace(var aMem, strchar(246), 'ö');
  Lib_Texte:MemReplace(var aMem, strchar(252), 'ü');
  Lib_Texte:MemReplace(var aMem, strchar(196), 'Ä');
  Lib_Texte:MemReplace(var aMem, strchar(214), 'Ö');
  Lib_Texte:MemReplace(var aMem, strchar(220), 'Ü');
  Lib_Texte:MemReplace(var aMem, strchar(223), 'ß');
  Lib_Texte:MemReplace(var aMem, strchar(177), '±');
  Lib_Texte:MemReplace(var aMem, strchar(178), '²');
  Lib_Texte:MemReplace(var aMem, strchar(179), '¸');
  Lib_Texte:MemReplace(var aMem, strchar(216), 'Ù');
  Lib_Texte:MemReplace(var aMem, strchar(181), 'µ');
  Lib_Texte:MemReplace(var aMem, strchar(176), 'þ');
end;


//========================================================================
MAIN
local begin
  vA  : alpha(100);
end;
begin
  Lib_Debug:InitDebug();
  vA # '~401.00100834';
//  DelAllAehnlich(vA);
  //    12345678901234567890
  vA # '~401.00100834.001';
//  CopyAllAehnlich(vA, 18, '~401.12345678.001');
end;

//========================================================================
//========================================================================
//========================================================================