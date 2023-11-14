@A+
//===== Business-Control =================================================
//
//  Prozedur  C16_Datenstruktur
//                    OHNE E_R_G
//  Info
//
//
//  06.10.2020  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================

define begin
  TextAddLine(a,b): TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
  AInt(a)         : CnvAI(a,_FmtNumNoGroup)
  Msg(a)          : WindialogBox(0,'Datenstrukturanalyse',a,0,0,0)
  Suche(a,b,c)    : TextSearch(a, b, 1,_TextSearchCI,c)
  Debug(a)        : TextLineWrite(aDiffTxt,TextInfo(aDiffTxt,_TextLines)+1,a,_TextLineInsert)
end;

//========================================================================
sub GetFldInfo(
  aDatei  : int;
  aTds    : int;
  aFld    : int;
//  var aL  : int
) : alpha
local begin
  vL  : int;
end;
begin

  case FldInfo(aDatei,aTds,aFld,_FldType) of
    _TypeAlpha  : begin
      vL   # FldInfo(aDatei,aTds,aFld,_FldLen);
      RETURN 'string|'+aint(vL);
      end;
    _typeWord   : RETURN 'int';   // war int16
    _typeInt    : RETURN 'int';
    _typeFloat  : RETURN 'double'; // float??
    _typeLogic  : RETURN 'bool';
    _typeDate   : RETURN 'DateTime';
    _typeTime   : RETURN 'DateTime';
    _typeBigInt : RETURN 'BigInt';
  end;

  RETURN '';
end;


//========================================================================
//
//========================================================================
Sub CreateText() : int
local begin
  vTxt    : int;
  vDatei  : int;
  vTds    : int;
  vFld    : int;
  vName   : alpha;
  vMaxTds : int;
  vMaxFld : int;
  vMaxKey : int;
  vTyp    : alpha;
  vKey    : int;
  vI, vJ  : int;
  vI2,vJ2 : int;
end
begin
  vTxt # TextOpen(20);
  
  FOR vDatei # 1
  LOOP inc(vDatei)
  WHILE (vDatei<=999) do begin
    if (FileInfo(vDatei,_FileExists)=0) then CYCLE;
if (vDatei<>100) then CYCLE;
    vName # Filename(vDatei);
    TextAddLine(vTxt, '<FILE>'+aint(vDatei)+'|'+vName+'|');
    
    // Teildatensätze --------------------------------------
    vMaxTds # Fileinfo(vDatei, _FileSbrCount);
    FOR vTds # 1
    LOOP inc(vTds)
    WHILE (vTds<=vMaxTds) do begin
      vName # Sbrname(vDatei, vTds);
      TextAddLine(vTxt, '  <TDS>'+vName+'|');
      // Felder --------------------------------------
      vMaxFld # SbrInfo(vDatei,vTds,_SbrFldCount);
      FOR vFld # 1
      LOOP inc(vFld)
      WHILE (vFld<=vMaxFld) do begin
        vName # Fldname(vDatei, vTds, vFld);
        vTyp # GetFldInfo(vDatei, vTds, vFld);
        if (vTyp='') then begin
          Msg('Unbekannter typ bei :'+aint(vDatei)+'/'+aint(vTds)+'/'+aint(vFld));
          BREAK;
        end;

        TextAddLine(vTxt,'      <F>'+vName+'|'+vTyp+'|')
      END;
      TextAddLine(vTxt, '  </TDS>');
    END;
    
    // Schlüssel -------------------------------------
    vMaxKey # Fileinfo(vDatei, _FileKeyCount);
    FOR vKey # 1
    LOOP inc(vKey)
    WHILE (vKey<=vMaxKey) do begin
      vName # Keyname(vDatei, vKey);
      TextAddLine(vTxt, '  <KEY>'+vName+'|');
      vMaxFld # KeyInfo(vDatei, vKey, _KeyFldCount);
      FOR vFld # 1
      LOOP inc(vFld)
      WHILE (vFld<=vMaxFld) do begin
        vI   # KeyFldInfo(vDatei, vKey, vFld, _KeyFldSbrNumber);
        vJ   # KeyFldInfo(vDatei, vKey, vFld,_KeyFldNumber);
        vName # FldName(vDatei, vI, vJ);
        vTyp # GetFldInfo(vDatei, vI, vJ);
        if (vTyp='') then begin
          Msg('Unbekannter typ bei :'+aint(vDatei)+'/'+aint(vI)+'/'+aint(vJ));
          BREAK;
        end;
        vName # vName + '|'+vTyp;
        if (vTyp=*'string*') then begin
          vI2 # KeyFldInfo(vDatei, vKey, vFld, _KeyFldAttributes);
          vJ2 # KeyFldInfo(vDatei, vKey, vFld, _KeyFldMaxLen);
          vName # vName + '|'+aint(vI2)+'|'+aint(vJ2);
        end;
        TextAddLine(vTxt, '      <F>'+vName+'|');
      END;
      TextAddLine(vTxt, '  </KEY>');
    END;
    
    // Links -----------------------------------------
    vMaxKey # Fileinfo(vDatei, _FileLinkCount);
    FOR vKey # 1
    LOOP inc(vKey)
    WHILE (vKey<=vMaxKey) do begin
      vI # Linkinfo(vDatei, vKey, _LinkDestFileNumber);
      vJ # Linkinfo(vDatei, vKey, _LinkDestKeyNumber);
      vName # Linkname(vDatei, vKey);
      TextAddLine(vTxt, '  <LINK>'+vName+'|'+aint(vI)+'|'+aint(vJ)+'|');
      vMaxFld # LinkInfo(vDatei, vKey, _LinkFldCount);
      FOR vFld # 1
      LOOP inc(vFld)
      WHILE (vFld<=vMaxFld) do begin
        vI2 # LinkFldInfo(vDatei, vKey, vFld, _LinkFldSbrNumber);
        vJ2 # LinkFldInfo(vDatei, vKey, vFld, _LinkFldNumber);
        vName # Fldname(vDatei, vI2, vJ2);
        vTyp # GetFldInfo(vDatei, vI2, vJ2);
        if (vTyp='') then begin
          Msg('Unbekannter typ bei :'+aint(vDatei)+'/'+aint(vI2)+'/'+aint(vJ2));
          BREAK;
        end;
        vName # vName + '|'+vTyp;
        if (vTyp=*'string*') then begin
          vI2 # KeyFldInfo(vDatei, vKey, vFld, _KeyFldAttributes);
          vJ2 # KeyFldInfo(vDatei, vKey, vFld, _KeyFldMaxLen);
          vName # vName + '|'+aint(vI2)+'|'+aint(vJ2);
        end;
        TextAddLine(vTxt, '      <F>'+vName+'|');
      END;
      TextAddLine(vTxt, '  </LINK>');
    END;
    
    TextAddLine(vTxt, '</FILE>');
  END;
  
  RETURN vTxt;
  //TextClose(vTxt);
end;


//========================================================================
//========================================================================
sub CompareFld(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
end;
begin
//debug('FLD S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2)+' bis '+aint(aE2));    // 1-396  1
//RETURN;

  vZ1 # aZ1;
  vZ2 # aZ2;

  FOR vZ1 # Suche(aSollTxt, vZ1, '<F>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<F>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),4,100);
    if (vZ2=0) or (vZ2>aE2) then begin
      TextAddLine(aDiffTxt, aPath + ' FLD fehlt: '+vName);
    end;
  END;

  aZ1 # aE1;
  aZ2 # aE2;
end;


//========================================================================
//========================================================================
sub CompareKeyFld(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
end;
begin
//debug('FLD S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2)+' bis '+aint(aE2));    // 1-396  1
//RETURN;

  vZ1 # aZ1;
  vZ2 # aZ2;

  FOR vZ1 # Suche(aSollTxt, vZ1, '<F>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<F>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),4,100);
    if (vZ2=0) or (vZ2>aE2) then begin
      TextAddLine(aDiffTxt, aPath + ' => KEYFLD fehlt: '+vName);
    end;
  END;

  aZ1 # aE1;
  aZ2 # aE2;
end;


//========================================================================
//========================================================================
sub CompareLinkFld(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
end;
begin
//debug('FLD S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2)+' bis '+aint(aE2));    // 1-396  1
//RETURN;

  vZ1 # aZ1;
  vZ2 # aZ2;

  FOR vZ1 # Suche(aSollTxt, vZ1, '<F>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<F>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),4,100);
    if (vZ2=0) or (vZ2>aE2) then begin
      TextAddLine(aDiffTxt, aPath + ' => LINKFLD fehlt: '+vName);
    end;
  END;

  aZ1 # aE1;
  aZ2 # aE2;
end;


//========================================================================
//========================================================================
sub CompareTds(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
  vE1, vE2  : int;
end;
begin
//debug('S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2));    // 1-396  1
//RETURN;
  vZ1 # aZ1;
  vZ2 # aZ2;
  
  FOR vZ1 # Suche(aSollTxt, vZ1, '<TDS>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<TDS>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vE1 # Suche(aSollTxt, vZ1, '</TDS>');
    if (vE1=0) then RETURN;
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
    vE2 # Suche(aIstTxt, vZ2, '</TDS>');
    if (vE2=0) then vE2 # 999999999;
    
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),6,100);
    if (vZ2=0) or (vZ2>vE2) then begin
      TextAddLine(aDiffTxt, aPath + ' => TDS fehlt: '+vName);
    end
    else begin
      CompareFld(aPath+vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);
      aZ2 # vE2;
//debug('fldret '+aint(vZ1)+' / '+aint(vZ2));
    end;
  END;

  aZ1 # vE1;

end;


//========================================================================
//========================================================================
sub CompareKey(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
  vE1, vE2  : int;
end;
begin
debug('S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2)+' bis '+aint(aE2));
//RETURN;
  vZ1 # aZ1;
  vZ2 # aZ2;
  
  FOR vZ1 # Suche(aSollTxt, vZ1, '<KEY>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<KEY>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vE1 # Suche(aSollTxt, vZ1, '</KEY>');
    if (vE1=0) then RETURN;
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
    vE2 # Suche(aIstTxt, vZ2, '</KEY>');
    if (vE2=0) then vE2 # 999999999;
    
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),6,100);
    if (vZ2=0) or (vZ2>vE2) then begin
      TextAddLine(aDiffTxt, aPath + ' => KEY fehlt: '+vName);
    end
    else begin
      CompareKeyFld(aPath+'KEY '+vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);
      aZ2 # vE2;
//debug('fldret '+aint(vZ1)+' / '+aint(vZ2));
    end;
  END;

  aZ1 # vE1;

end;


//========================================================================
//========================================================================
sub CompareLink(
  aPath     : alpha;
  aSollTxt  : int;            // =1
  aIstTxt   : int;            // =2
  aE1       : int;
  aE2       : int;
  aDiffTxt  : int;
  var aZ1   : int;
  var aZ2   : int;
  )
local begin
  vZ1, vZ2  : int;
  vA        : alpha(1000);
  vName     : alpha(1000);
  vE1, vE2  : int;
end;
begin
debug('S:'+aint(aZ1)+' bis '+aint(aE1)+'   I:'+aint(aZ2)+' bis '+aint(aE2));
//RETURN;
  vZ1 # aZ1;
  vZ2 # aZ2;
  
  FOR vZ1 # Suche(aSollTxt, vZ1, '<LINK>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<LINK>')
  WHILE (vZ1>0) and (vZ1<aE1) do begin
    vE1 # Suche(aSollTxt, vZ1, '</LINK>');
    if (vE1=0) then RETURN;
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
    vE2 # Suche(aIstTxt, vZ2, '</LINK>');
    if (vE2=0) then vE2 # 999999999;
    
//debug('suche '+vA+' = '+aint(vZ2));
    vName # Strcut(StrAdj(vA,_StrBegin),7,100);
    if (vZ2=0) or (vZ2>vE2) then begin
      TextAddLine(aDiffTxt, aPath + ' => LINK fehlt: '+vName);
    end
    else begin
      CompareLinkFld(aPath+'LINK '+vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);
      aZ2 # vE2;
//debug('fldret '+aint(vZ1)+' / '+aint(vZ2));
    end;
  END;

  aZ1 # vE1;

end;


//========================================================================
sub CompareFile(
  aSollTxt  : int;          // =1
  aIstTxt   : int;          // =2
  aDiffTxt  : int;
  )
local begin
  vZ1,vZ2   : int;
  vA        : alpha;
  vName     : alpha;
  vE1,vE2   : int;
end;
begin

  vZ1 # 1;
  vZ2 # 1;
  FOR vZ1 # Suche(aSollTxt, vZ1, '<FILE>')
  LOOP vZ1 # Suche(aSollTxt, vZ1+1, '<FILE>')
  WHILE (vZ1>0) do begin
    vE1 # Suche(aSollTxt, vZ1, '</FILE>');
    if (vE1=0) then RETURN;
    vA # TextLineRead(aSolltxt, vZ1, 0);

    vZ2 # Suche(aIstTxt, vZ2, vA);
    vE2 # Suche(aIstTxt, vZ2, '</FILE>');
    if (vE2=0) then vE2 # 999999999;

    vName # StrCut(vA, 7,100);
//debug('suche '+vA+' = '+aint(vZ2));
    if (vZ2=0) then begin
      TextAddLine(aDiffTxt, 'Datei fehlt: '+vName);
    end
    else begin
      CompareTds(vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);
//debug('tdsret '+aint(vZ1)+' / '+aint(vZ2));
      CompareKey(vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);

      CompareLink(vName, aSollTxt, aIstTxt, vE1, vE2, aDiffTxt, var vZ1, var vZ2);
    end;
  END;

end;


//========================================================================
//  call C16_Datenstruktur
//========================================================================
main
local begin
  vSollTxt  : int;
  vIstTxt   : int;
  vDiffTxt  : int;

  vRtf      : int;
end;
begin
//  vIstTxt # CreateText();
//  TextWrite(vIstTxt, '', _TextClipboard);
//  TextClose(vIstTxt);
//  RETURN;
    
  vIstTxt # Textopen(20);
  TextRead(vIstTxt, '!!!IST', 0);

  vSollTxt # Textopen(20);
//  TextRead(vSollTxt, '', _TextClipboard);

  TextRead(vSollTxt, '!!!SOLL', 0);
  
  vDiffTxt # TextOpen(20);
  CompareFile(vSollTxt, vIstTxt, vDiffTxt);
  
  TextWrite(vDiffTxt, '', _TextClipboard);
/***
  vRtf # TextOpen(20);
  Lib_Texte:Txt2Rtf(vDiffTxt, vRTF, 'Calibre', 15, 0, (TextInfo(vRTF,_textLines)>0));
  Dlg_Standard:TooltipRTF(vRTF,'Datenstrukturänderungen');
  TextClose(vRtf);
  TextClose(vDiffTxt);
***/

  TextClose(vSollTxt);
  
  TextClose(vIstTxt);
end;

//========================================================================
//========================================================================
//========================================================================