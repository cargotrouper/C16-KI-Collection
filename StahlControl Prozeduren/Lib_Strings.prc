@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Strings
//                      OHNE E_R_G
//  Info
//
//
//  16.05.2003  ML  Erstellung der Prozedur
//  19.07.2007  ST  sub Strings_GetStringCnt(...)  hinzugefügt
//  06.02.2012  AI  UDach rausgenommen, da es mit dem Ö kollidiert
//  30.05.2012  PW  Strings_ReplaceEachToken
//  19.09.2012  ST  Date..,Num..., IntForSort hinzugefügt
//  30.11.2012  AI  DOS2XML blendet die ausländischen Zeichen (Dänisch, Ungarisch) aus und ersetzt sie durch ein ?
//  12.03.2013  ST  TimeStamp hinzugefügt
//  22.09.2014  AH  BugFix "DOS2XML" macht €-Konvertierung "später" und damit richtig
//  28.06.2019  AH  DOS<>WIN für µ und ð
//  25.04.2022  DS  Strings_Token_Last(), Strings_Token_Last_Complement()
//  06.05.2022  AH  Alphas auf 8000+
//  2022-08-29  DS  Strings_UTF82C16 (z.B. für aus Json gelesene spValueAlphas)
//  2022-12-15  ST  WIN->DOS für Ø
//  2023-03-06  DS  TimestampFullYear hinzugefügt
//  2023-03-09  DS  TimestampFullYearFilename hinzugefügt
//  2023-03-10  DS  Strings_C162UTF8 einkommentiert und angepasst
//  2023-04-19  ST  Neu: sub DateFromYMD(aDateString : alpha) : date
//
//  Subprozeduren
//    SUB Strings_Count(aString : alpha(8096); aBegrenzer : alpha(250)) : int
//    SUB Strings_Token(aString : alpha(8096); aBegrenzer : alpha(250); aNummer : int) : alpha
//    SUB Strings_Token_Last(aString : alpha(8096); aBegrenzer : alpha(250)) : alpha
//    SUB Strings_Token_Last_Complement(aString : alpha(8096); aBegrenzer : alpha(250)) : alpha;
//    SUB Strings_PosNum(aString : alpha(8096); aSuchString : alpha(250); aNummer : int) : int
//    SUB Strings_ReplaceAll(aString : alpha(8096); aSuchString : alpha(250); aErsetzString : alpha(250)) : alpha;
//    SUB Strings_ReplaceEachToken(aString : alpha(8096); aTokens : alpha(250); opt aReplacement : alpha(250)) : alpha
//    SUB Strings_DOS2WIN(aText : alpha(8096); optaCSV : logic) : alpha;
//    SUB Strings_WIN2DOS(aText : alpha(8096)) : alpha;
//    SUB Strings_DOS2XML(aText : alpha(8096) : alpha
//    SUB Strings_XML2DOS(aText : alpha(8096) : alpha
//    SUB Strings_UTF82C16(aText : alpha(8192)) : alpha
//    SUB Strings_C162UTF8(aText : alpha(8192)) : alpha
//    ??????? AH 18.12.2015 SUB Strings_GetStringCnt(aText : alpha(8096); aSearch : alpha(8096)) : int;
//    SUB Strings_Reverse(aText : alpha) : alpha
//    SUB GetVonBis(aText : alpha; aVon : alpha; aBis : alpha) : alpha
//    SUB CutVonBis(var aText : alpha; aVon : alpha; aBis : alpha) : alpha
//    SUB StartsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
//    SUB EndsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
//    SUB Append(var aString : alpha; aInsertString : alpha; opt aSeparator : alpha; opt aInsertIfEmpty : logic;);
//    SUB AlphaToInt(aAlpha : alpha) : int;
//    SUB DateForSort(aDate : date) : alpha
//    SUB NumForSort(aFloat : float; opt aNachKomma : int) : alpha
//    SUB IntForSort(aInt : int; ) : alpha
//
//    SUB RTFSaveHTML(aWinRTF : handle; aText : handle)
//    SUB Timestamp(opt aDate : date; opt aTime : time) : alpha
//    SUB TimestampFullYearMs(opt aDate : date; opt aTime : time) : alpha
//    SUB TimestampFullYear(opt aDate : date; opt aTime : time) : alpha
//    SUB TimestampFullYearFilename(opt aDate : date; opt aTime : time) : alpha
//
//=======================================================================
define begin
 mop : lib_debug:Dbg_debug(cnvai(StrLen(aText)))
 debug(a) : lib_debug:Dbg_debug(a)
end;

Declare Strings_Token
(
  aString     : alpha(8096);
  aBegrenzer  : alpha(250);
  aNummer : int
) : alpha

declare Strings_PosNum
(
  aString     : alpha(8096);
  aSuchString : alpha(250);
  aNummer     : int;
) : int


//========================================================================
//========================================================================
sub AllAscii(atext : alpha(8096)) : alpha
local begin
  vA  : alpha(8096);
  vI  : int;
  vJ  : int;
end;
begin
  FOR vI # 1 loop inc(vI) while (vI<=StrLen(aText)) do begin
    vJ # strTochar(aText, vI);
    vA # Strcut(vA + cnvai(vJ)+',',1,8096);
  END;
  RETURN vA;
end;

//========================================================================
// Strings_Count
//              Zählt das vorkommen eines Strings in einem anderen
//========================================================================
sub Strings_Count
(
  aString     : alpha(8096);
  aBegrenzer  : alpha(250);
) : int;
local begin
  vI    : int;
  vPos  : int;
end;
begin
  REPEAT
    if (vPos<>0) then vPos # vPos + StrLen(aBegrenzer);
    vPos # StrFind(aString, aBegrenzer, vPos);
    vI # vI + 1;
  UNTIL (vPos=0);

  RETURN vI - 1;
end;


//========================================================================
// Strings_Token
//              Zerlegt einen String anhand eines Trennstrings in Teile
//========================================================================
sub Strings_Token
(
  aString     : alpha(8096);
  aBegrenzer  : alpha(250);
  aNummer : int
) : alpha
local begin
  vAnfang,vEnde : int;
  vStart        : int;
  vOffset       : int;
  vToken        : alpha(8096);
end;
begin
  vOffset # StrLen(aBegrenzer);
  vEnde   # Strings_PosNum(aString, aBegrenzer, aNummer);

  if (aNummer = 1) then begin
    vAnfang # 1;
    vStart  # 1;
  end else begin
    vAnfang # Strings_PosNum(aString, aBegrenzer, aNummer-1);
    vStart  # vAnfang + vOffset;
  end;
  if (vAnfang > 0) then begin
    if (vEnde = 0) then vEnde # StrLen(aString) + 1;
    vToken # StrCut(aString, vStart, vEnde-vStart);
  end;

  RETURN vToken;

end;


//========================================================================
// 2022-04-25  DS                                               2298/35
// Liefert das letzte Token nach einem Begrenzer, ohne dass
// erforderlich ist zu wissen, wie viele Tokens es insgesamt gibt.
//========================================================================
sub Strings_Token_Last
(
  aString     : alpha(8096);
  aBegrenzer  : alpha(250);  // case-sensitive!
) : alpha;
local begin
  vCount : int;
  vToken : alpha(8096);
end;
begin

  vCount # Lib_Strings:Strings_Count(aString, aBegrenzer);
  if vCount = 0 then
  begin
    vToken # '';
  end
  else
  begin
    vToken # Lib_Strings:Strings_Token(aString, aBegrenzer, vCount+1);
  end
  
  return vToken;

end;


//========================================================================
// 2022-04-25  DS                                               2298/35
// Liefert den komplementären Text zum Ergebnis von Strings_Token_Last().
// Beispiel:
//   vText # 'ein_text_getrennt_durch_underscores';
//   vA # Strings_Token_Last_Complement(vText, '_');
//   vB # Lib_Strings:Strings_Token_Last(vText, '_');
// dann gelten:
//   vA = 'ein_text_getrennt_durch_'  // also inkl. des Begrenzers
//   vB = 'underscores'
//========================================================================
sub Strings_Token_Last_Complement
(
  aString     : alpha(8096);
  aBegrenzer  : alpha(250);  // case-sensitive!
) : alpha;
local begin
  vPos : int;
  vLast : int;
  vComplement : alpha(8096);
end;
begin
  
  // init
  vPos # 0;  // aktuelle Suchposition
  vLast # StrLen(aString)+1;  // zeigt am Ende auf ersten Buchstaben des letzten Token
  
  REPEAT
    if (vPos<>0) then
    begin
      vPos # vPos + StrLen(aBegrenzer);
      vLast # vPos;
    end
    vPos # StrFind(aString, aBegrenzer, vPos);
  UNTIL (vPos=0);
  
  vComplement # StrCut(aString, 1, vLast-1)

  RETURN vComplement;
end;


//========================================================================
// Strings_PosNum
//                Liefert die n-te Position eines Suchstrings
//========================================================================
Sub Strings_PosNum
(
  aString     : alpha(8096);
  aSuchString : alpha(250);
  aNummer     : int;
) : int
local begin
  vAbsPos : int;
  vRelPos : int;
end;
begin
  vRelPos # StrFind(aString, aSuchString, 1);
  WHILE (vRelPos>0) and (aNummer > 0) do begin
    aNummer # aNummer - 1;
    aString # StrCut(aString,vRelPos+1, StrLen(aString)-vRelPos);
    vAbsPos # vAbsPos + vRelPos;
    vRelPos # StrFind(aString, aSuchString,1)
  END;
  if (aNummer > 0) then vAbsPos # 0;

  Return vAbsPos;
end;


//========================================================================
// Strings_ReplaceAll
//                    Ersetzt JEDES vorkommen eines Suchstrings durch einen anderen
//========================================================================
sub Strings_ReplaceAll
(
  aString     : alpha(8096);
  aSuchString : alpha(250);
  aErsetzString : alpha(250);
) : alpha;
local begin
  vX  : int;
  vL  : int;
  vL2 : int;
end;
begin
//if StrtoChar(aSuchString, 1)=150 then lib_debug:Dbg_debug('X'+cnvai(strtochar(aErsetzString,2)));
  vL  # StrLen( aSuchstring );
  vL2 # StrLen( aErsetzString ) - vL + 1;
  FOR  vX # StrFind( aString, aSuchString, 0 );
  LOOP vX # StrFind( aString, aSuchString, vX + vL2 );
  WHILE ( vX > 0 ) do begin
    aString # StrDel( aString, vX, vL );
    aString # StrIns( aString, aErsetzString, vX );
//if (vX+vL2>StrLen(aString)) then BREAK;
  END;
  RETURN aString;
end;


//=========================================================================
// Strings_ReplaceEachToken
//        Ersetzt jedes der Zeichen in der Token-Liste durch den
//        angegebenen Ersetzungsstring. Hilfreich zum Entfernen vieler
//        nicht-erlaubter/ungültiger Zeichen.
//=========================================================================
sub Strings_ReplaceEachToken
(
  aString : alpha(8096);
  aTokens : alpha(250);
  opt aReplacement : alpha(250)
) : alpha
local begin
  vI : int;
  vToken : alpha;
end
begin
  FOR  vI # 1;
  LOOP vI # vI + 1;
  WHILE ( vI <= StrLen( aTokens ) ) DO BEGIN
    vToken # StrCut( aTokens, vI, 1 );
    aString # Strings_ReplaceAll( aString, vToken, aReplacement );
  END;
  RETURN aString;
end;


//========================================================================
// Strings_DOS2WIN
//            ersetzt Umlaufe von DOS (C16) nach Windows
//========================================================================
Sub Strings_DOS2WIN(aText : alpha(8096); opt aCSV : logic) : alpha;
begin
  aText # Strings_ReplaceAll(aText, 'ä', strchar(228));
  aText # Strings_ReplaceAll(aText, 'ö', strchar(246));
  aText # Strings_ReplaceAll(aText, 'ü', strchar(252));
  aText # Strings_ReplaceAll(aText, 'Ä', strchar(196));
  aText # Strings_ReplaceAll(aText, 'Ö', strchar(214));
  aText # Strings_ReplaceAll(aText, 'Ü', strchar(220));
  aText # Strings_ReplaceAll(aText, 'ß', strchar(223));
  aText # Strings_ReplaceAll(aText, '±', strchar(177));
  aText # Strings_ReplaceAll(aText, '±', strchar(177));
  aText # Strings_ReplaceAll(aText, '²', strchar(178));
  aText # Strings_ReplaceAll(aText, '³', strchar(179));
  aText # Strings_ReplaceAll(aText, 'Ø', strchar(216));

  aText # Strings_ReplaceAll(aText, 'µ', strchar(181));
  aText # Strings_ReplaceAll(aText, 'ð', strchar(176));
  

  if (aCSV) then begin
    aText # Strings_ReplaceAll(aText, '"', strchar(254));
    aText # Strings_ReplaceAll(aText, strchar(254), '""');
  end;

  RETURN aText;
end;


//========================================================================
// Strings_WIN2DOS
//            ersetzt Umlaufe von Windows nach DOS (C16)
//========================================================================
Sub Strings_WIN2DOS(aText : alpha(8096)) : alpha;
begin
  aText # Strings_ReplaceAll(aText,  strchar(228), 'ä');
  aText # Strings_ReplaceAll(aText,  strchar(246), 'ö');
  aText # Strings_ReplaceAll(aText,  strchar(252), 'ü');
  aText # Strings_ReplaceAll(aText,  strchar(196), 'Ä');
  aText # Strings_ReplaceAll(aText,  strchar(214), 'Ö');
  aText # Strings_ReplaceAll(aText,  strchar(220), 'Ü');
  aText # Strings_ReplaceAll(aText,  strchar(223), 'ß');

  aText # Strings_ReplaceAll(aText, strchar(181), 'µ');
  aText # Strings_ReplaceAll(aText, strchar(176), 'ð');
  aText # Strings_ReplaceAll(aText, strchar(216), 'Ø');
  
  RETURN aText;
end;


//========================================================================
// Strings_DOS2XML
//            ersetzt Umlaufe von DOS (C16) nach XML
//========================================================================
Sub Strings_DOS2XML(aText : alpha(8096)) : alpha;
local begin
  vI,vJ : int;
  vA    : alpha(1);
  vB    : alpha(5);
  vRes  : alpha(8096);
end;
begin
// UMABU 02.12.2020 AH wegen JEPSEN
/****/
//debug(aText);
//debug('start:'+allascii(aText));
  FOR vI # 1 loop inc(vI) while (vI<=StrLen(aText)) do begin
    vA # StrCut(aText,vI,1);
    if (vA<>'<') and (vA<>'>') and (vA>=' ') and (vA<='z') then begin   // 15.07.2021 AH, Fix für <>
      vRes # StrCut(vRes + vA,1,8096);
      CYCLE;
    end;
    vJ # strTochar(vA,1);
// fr c3 bd deck

    case vA of
// SIEHE https://www.utf8-zeichentabelle.de/unicode-utf8-table.pl?number=1024&htmlent=1
      'Š' : vB # strchar(0xc5)+strchar(0xa0);
      'ì' : vB # strchar(0xc3)+strchar(0xbd);

      'ä' : vB # strchar(195)+strchar(164);
      'ö' : vB # strchar(195)+strchar(182);
      'ü' : vB # strchar(195)+strchar(188);
      'Ä' : vB # strchar(195)+strchar(132);
      'Ö' : vB # strchar(195)+strchar(150);
      'Ü' : vB # strchar(195)+strchar(156);
      'ß' : vB # strchar(195)+strchar(159);
      'µ' : vB # strchar(194)+strchar(181);
      '&' : vB # StrChar(254)+'amp;';
      '<' : vB # '&lt;';
      '>' : vB # '&gt;';
      'Ì' : vB # strchar(195)+strchar(204);
      'Í' : vB # strchar(195)+strchar(205);
      'Î' : vB # strchar(195)+strchar(206);
      'Ù' : vB # strchar(195)+strchar(217);
      'ì' : vB # strchar(195)+strchar(198); // strchar(236); fix
      'í' : vB # strchar(195)+strchar(237);
      'î' : vB # strchar(195)+strchar(238);
      'è' : vB # strchar(195)+strchar(232);
      'é' : vB # strchar(195)+strchar(233);
      'ê' : vB # strchar(195)+strchar(234);
      '€' : vB # strchar(226)+strchar(130)+strchar(172);
      'È' : vB # strchar(195)+strchar(200);
      'É' : vB # strchar(195)+strchar(201);
      'Ê' : vB # strchar(195)+strchar(202);
      'Ò' : vB # strchar(195)+strchar(210);
      'Ó' : vB # strchar(195)+strchar(211);
      'Ô' : vB # strchar(195)+strchar(212);
      'ò' : vB # strchar(195)+strchar(242);
      'ó' : vB # strchar(195)+strchar(243);
      'ô' : vB # strchar(195)+strchar(244);
      'Ú' : vB # strchar(195)+strchar(218);
      'Û' : vB # strchar(195)+strchar(219);
      'ù' : vB # strchar(195)+strchar(249);
      'ú' : vB # strchar(195)+strchar(250);
      '²' : vB # strchar(0xc2)+strchar(0xb2);
      '³' : vB # strchar(0xc2)+strchar(0xb3);
      '´' : vB # strchar(195)+strchar(180);
      otherwise begin
        case vJ of
          160   : vB # strchar(195)+strchar(161);
          216   : vB # strchar(195)+strchar(129);
          196   : vB # strchar(195)+strchar(160);
          254   : vB # '&';
          255   : vB # strchar(32);
          otherwise begin
            vB # '?';
Lib_Debug:Dbg_Debug('error bei:'+adr.stichwort+'    Zeichen:'+vA+'   ascii:'+cnvai(vJ)+'   text:'+aText+'  '+allascii(aText));
          end;
        end;
      end;
    end;
    vRes # StrCut(vRes + vB,1,8096);
    
  END;
//debug('RES:'+allascii(vRes));

  RETURN vRes;
/***/

//Královopolská KRÁLOVOPOLSKÁ
//Feijò, no. 813 São Paulo -SP
//Körvas·t sor  110 Hradist'skà  98
//  aText # Strings_ReplaceAll(aText, 'á', 'xxx');
//  aText # Strings_ReplaceAll(aText, 'Á', 'xxx');
//  aText # Strings_ReplaceAll(aText, 'ò', 'xxx');
//  aText # Strings_ReplaceAll(aText, 'ã', 'xxx');
//  aText # Strings_ReplaceAll(aText, '·', 'xxx');
//  aText # Strings_ReplaceAll(aText, 'à', 'xxx');
//Lib_Debug:dbg_Debug('>>>'+aText+'<<<');

  aText # Strings_ReplaceAll(aText, 'ä', strchar(195)+strchar(164));
  aText # Strings_ReplaceAll(aText, 'ö', strchar(195)+strchar(182));
  aText # Strings_ReplaceAll(aText, 'ü', strchar(195)+strchar(188));
  aText # Strings_ReplaceAll(aText, 'Ä', strchar(195)+strchar(132));
  aText # Strings_ReplaceAll(aText, 'Ö', strchar(195)+strchar(150));
  aText # Strings_ReplaceAll(aText, 'Ü', strchar(195)+strchar(156));
  aText # Strings_ReplaceAll(aText, 'ß', strchar(195)+strchar(159));
//  aText # Strings_ReplaceAll(aText, '€', strchar(226)+strchar(130)+strchar(172)); gegen 'é'

  aText # Strings_ReplaceAll(aText, 'µ', strchar(194)+strchar(181));

  aText # Strings_ReplaceAll(aText, '&', StrChar(254)+'amp;');
  aText # Strings_ReplaceAll(aText, StrChar(254), '&');
  aText # Strings_ReplaceAll(aText, '<', '&lt;');
  aText # Strings_ReplaceAll(aText, '>', '&gt;');

  aText # Strings_ReplaceAll(aText, 'Ì', strchar(195)+strchar(204));
  aText # Strings_ReplaceAll(aText, 'Í', strchar(195)+strchar(205));
  aText # Strings_ReplaceAll(aText, 'Î', strchar(195)+strchar(206));

  aText # Strings_ReplaceAll(aText, 'Ù', strchar(195)+strchar(217));
  
  aText # Strings_ReplaceAll(aText, 'ì', strchar(195)+strchar(236));
  aText # Strings_ReplaceAll(aText, 'í', strchar(195)+strchar(237));
  aText # Strings_ReplaceAll(aText, 'î', strchar(195)+strchar(238));


  aText # Strings_ReplaceAll(aText, 'è', strchar(195)+strchar(232));
  aText # Strings_ReplaceAll(aText, 'é', strchar(195)+strchar(233));  // gegen €
  aText # Strings_ReplaceAll(aText, 'ê', strchar(195)+strchar(234));
  aText # Strings_ReplaceAll(aText, '€', strchar(226)+strchar(130)+strchar(172)); // darum € erst hier

  aText # Strings_ReplaceAll(aText, 'È', strchar(195)+strchar(200));
  aText # Strings_ReplaceAll(aText, 'É', strchar(195)+strchar(201));
  aText # Strings_ReplaceAll(aText, 'Ê', strchar(195)+strchar(202));

  aText # Strings_ReplaceAll(aText, 'Ò', strchar(195)+strchar(210));
  aText # Strings_ReplaceAll(aText, 'Ó', strchar(195)+strchar(211));
  aText # Strings_ReplaceAll(aText, 'Ô', strchar(195)+strchar(212));

  aText # Strings_ReplaceAll(aText, 'ò', strchar(195)+strchar(242));
  aText # Strings_ReplaceAll(aText, 'ó', strchar(195)+strchar(243));
  aText # Strings_ReplaceAll(aText, 'ô', strchar(195)+strchar(244));

//  aText # Strings_ReplaceAll(aText, 'Ù', strchar(195)+strchar(217)); 02.12.2020 weiter oben, da das mit 195+236 kollidiert

  aText # Strings_ReplaceAll(aText, 'Ú', strchar(195)+strchar(218));
  aText # Strings_ReplaceAll(aText, 'Û', strchar(195)+strchar(219));

  aText # Strings_ReplaceAll(aText, 'ù', strchar(195)+strchar(249));
  aText # Strings_ReplaceAll(aText, 'ú', strchar(195)+strchar(250));
//  aText # Strings_ReplaceAll(aText, 'û', strchar(195)+strchar(251));    // knallt gegen Ö

  aText # Strings_ReplaceAll(aText, '²', strchar(0xc2)+strchar(0xb2));    // 04.08.2016   ; 194+178
  aText # Strings_ReplaceAll(aText, '³', strchar(0xc2)+strchar(0xb3));    // 194+179


  aText # Strings_ReplaceAll(aText,strchar(255), strchar(32));            // 24.10.2013 AH

  aText # Strings_ReplaceAll(aText, '´', strchar(195)+strchar(180));


  FOR vI # 1 loop inc(vI) while (vI<=StrLen(aText)) do begin
    vA # StrCut(aText,vI,1);
    if (vA>=' ') and (vA<='z') then CYCLE;

//    vJ # strTochar(aText, vI);
vJ # strTochar(vA,1);
    if (vJ=254) then CYCLE;
    if (vJ=195 or vJ=194 or vJ=193 or vJ=197) then begin
      inc(vI);
      CYCLE;
    end;
    if (vJ=226) then begin  // €
      vI # vI + 2;
      CYCLE;
    end;
//Lib_Debug:Dbg_Debug('error bei:'+adr.stichwort+'    Zeichen:'+vA+'   ascii:'+cnvai(strtochar(vA,1))+'   text:'+aText);
Lib_Debug:Dbg_Debug('error bei:'+adr.stichwort+'    Zeichen:'+vA+'   ascii:'+cnvai(vJ)+'   text:'+aText+'  '+allascii(aText));
    aText # StrDel(aText,vI,1);
    aText # StrIns(aText,'?',vI);
  END;

//debug('RESULTAT:'+aText);
  RETURN aText;
end;


//========================================================================
// Strings_XML2DOS
//            ersetzt Umlaufe von XML nach DOS (C16)
//========================================================================
Sub Strings_XML2DOS(aText : alpha(8096)) : alpha;
begin
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(164),'ä');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(182),'ö');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(188),'ü');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(132),'Ä');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(150),'Ö');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(156),'Ü');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(159),'ß');
  aText # Strings_ReplaceAll(aText, strchar(226)+strchar(130)+strchar(172), '€');

  aText # Strings_ReplaceAll(aText, strchar(194)+strchar(181),'µ');

  aText # Strings_ReplaceAll(aText, '&amp;', '&');
  aText # Strings_ReplaceAll(aText, '&lt;', '<');
  aText # Strings_ReplaceAll(aText, '&gt;', '>');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(204), 'Ì');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(205), 'Í');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(206), 'Î');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(236), 'ì');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(237), 'í');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(238), 'î');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(232), 'è');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(233), 'é');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(234), 'ê');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(200), 'È');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(201), 'É');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(202), 'Ê');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(210), 'Ò');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(211), 'Ó');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(212), 'Ô');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(242), 'ò');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(243), 'ó');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(244), 'ô');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(217), 'Ù');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(218), 'Ú');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(219), 'Û');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(249), 'ù');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(250), 'ú');
  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(251), 'û');

  aText # Strings_ReplaceAll(aText, strchar(195)+strchar(180), '´');

  aText # Strings_ReplaceAll(aText, strchar(0xc2)+strchar(0xb2), '²');      // 04.08.2016
  aText # Strings_ReplaceAll(aText, strchar(0xc2)+strchar(0xb3), '³');


  RETURN aText;
end;



/*
========================================================================
2022-08-29  DS                                               2707/4

Nimmt UTF8 strings entgegen (z.B. aus Json gelesene spValueAlphas)
und konvertiert sie so, dass C16 die Umlaute etc. versteht.
========================================================================
*/
sub Strings_UTF82C16
(
  aText : alpha(8192);  // UTF8 String
) : alpha               // C16-kompatibler String
begin

  /* Anmerkung:
  ja, die folgende Konversion ist komplett unintuitiv und sieht
  sogar sinnlos bis schädlich aus.
  DS hat diesen Trick von Herrn Schramm von Vectorsoft bekommen und sieht
  darüber hinweg, weil es trotzdem und als einzige Lösung problemlos
  zu funktionieren scheint...
  */
  return StrCnv(StrCnv(aText, _StrToANSI), _StrFromUTF8);
  
  /* Anmerkung 2:
  https://www.vectorsoft.de/blog/2011/09/der-zeichensatz-in-conzept-16/
  wirft etwas Licht ins Dunkel. Der Schlüssel scheint der folgende Kommentar zu sein:
  "Andrej (vectorsoft) sagt:
  13. Oktober 2011 um 9:51 Uhr
  @David
  Bei der Zuweisung an "wpCaption" findet immer eine Wandlung von CONZEPT 16-Zeichensatz
  in den Windows-Zeichensatz statt (das ist für die Bildschirmanzeige notwendig) – dadurch
  wird ein UTF-8-String aber unbrauchbar.
  Um diesen Effekt auszuschalten, verwenden wir die "Umkehroperation", also Windows nach
  C16 (_StrFromAnsi). Beide Operationen heben sich gegenseitig auf, und in der angezeigeten
  Caption steht der Unicode-String."
  
  Das ändert zwar nichts daran, dass solche Gußgrate abgeschliffen werden sollten,
  bevor man etwas an externe Entwickler rausgibt, aber man versteht zumindest etwas besser,
  warum es so umständlich ist (aber nicht warum es so gelassen/exposed wird).
  */
  
end



/*
========================================================================
2022-08-30  DS                                               2707/4

Nimmt C16 strings entgegen (z.B. aus Feldern oder aus String-Literalen im
Code) und konvertiert sie zu UTF8, so dass sie z.B. in UTF8 Textdateien
geschrieben werden können (wie z.B. die Log .csv Dateien)

WICHTIG:
Zum Schreiben von JSON Dateien bitte nicht diese Funktion verwenden, denn
für diesen Fall gibt es stattdessen eine einfachere Komplettlösung in Form
von
                                         !!!!!!!!!!!!
  Lib_Json:SaveJSON(aCte, vTempFileName, _CharsetUTF8)

so dass die Json-Speicherungs-Methode selbst alles UTF8 kodiert.
========================================================================
*/
sub Strings_C162UTF8
(
  aText : alpha(8192);  // C16-kompatibler String
) : alpha               // UTF8 String
begin

  // Anmerkungen: siehe dazu auch Anmerkung in Strings_UTF82C16
  
  // '"Fun" Fact': Es klappt nicht mit
  // return StrCnv(StrCnv(aText, _StrToUTF8), _StrFromANSI);
  // (also der direkten Umkehrfunktion von Strings_UTF82C16), sondern um C16 Strings
  // in UTF8 zu konvertieren, muss _StrFromOEM statt _StrFromANSI verwendet werden.
  return StrCnv(StrCnv(aText, _StrToUTF8), _StrFromOEM);
  
end



//========================================================================
// Strings_DOS2RTF
//            ersetzt Sonderzeichen von DOS (C16) nach RTF
//========================================================================
Sub Strings_DOS2RTF(aText : alpha(8096)) : alpha;
begin
  aText # Strings_ReplaceAll(aText, '\', '\\');
  aText # Strings_ReplaceAll(aText, '{', '\{');
  aText # Strings_ReplaceAll(aText, '}', '\}');
  RETURN aText;
end;


//========================================================================
// Strings_StringCnt
//            ermittelt die Vorkommenisse von b in a und gibt diese zurück
//========================================================================
/***
Sub Strings_GetStringCnt
(
  aText   : alpha(8096);
  aSearch : alpha(8096)
) : int;
local begin
  vPos : int;
  vCnt : int;
end;
begin

  vPos # 1;
  WHILE (vPos > 0) DO BEGIN
    vPos # StrFind(aText,aSearch,vPos);
    if (vPos > 0) then begin
      inc(vCnt);
      inc(vPos);
    end;
  END;


  RETURN vCnt;

end;
***/

//========================================================================
// Reverse
//            kehrt einen String um
//========================================================================
Sub Reverse
(
  aText   : alpha(80);
) : alpha;
local begin
  vRetStr : alpha;
  vCnt : int;
  i : int;
end;
begin

  vCnt # StrLen(aText);

  FOR i # vCnt
  LOOP dec(i)
  WHILE (i > 0) DO
    vRetStr # vRetStr + StrCut(atext,i,1);

  RETURN vRetStr;

end;


//========================================================================
//  GetVonBis(
//========================================================================
SUB GetVonBis(
  aText : alpha(8096);
  aVon  : alpha;
  aBis  : alpha) : alpha;
local begin
  vI,vJ : int;
end;
begin
  vI # StrFind(aText, aVon , 1);
  if (vI=0) then RETURN '';
  vJ # StrFind(aText, aBis , vI+1);
  if (vJ=0) then RETURN '';
  RETURN StrCut(aText, vI+StrLen(aVon), vJ-vI-StrLen(aVon));
end;


//========================================================================
//  CutVonBis(
//========================================================================
SUB CutVonBis(
  var aText : alpha;
  aVon      : alpha;
  aBis      : alpha) : alpha;
local begin
  vI,vJ     : int;
  vA        : alpha(8000);
end;
begin
  vI # StrFind(aText, aVon , 1);
  if (vI=0) then RETURN '';
  vJ # StrFind(aText, aBis , vI+1);
  if (vJ=0) then RETURN '';
  vA # StrCut(aText, vI+StrLen(aVon), vJ-vI-StrLen(aVon));
  aText # strdel(aText, vI, vJ-vI+StrLen(aBis));
  RETURN vA;
end;



//========================================================================
//  SUB StartsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
//                                        ST 2022-03-22
//  Prüft eine Zeichenkette auf einen Beginn
//========================================================================
SUB StartsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
local begin
  vTmp : alpha;
end;
begin
  vTmp  # StrCut(aText,1,StrLen(aSearch));
  RETURN (vTmp = aSearch);
end;

//========================================================================
//  SUB EndsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
//                                        ST 2022-03-22
//  Prüft eine Zeichenkette auf ein bestimmtes Ende
//========================================================================
SUB EndsWith(aText : alpha(8000); aSearch   : alpha; ) : logic;
local begin
  vLenSearch  : int;
  vTmp        : alpha;
end;
begin
  vLenSearch # StrLen(aSearch);
  vTmp       # StrCut(aText,StrLen(aText)+1-vLenSearch,vLenSearch);
  RETURN (vTmp = aSearch);
end;



//========================================================================
//  Append  MS 17.03.2010
//    erweitert eine Zeichenkette, falls angegeben mit einem Separator
//========================================================================
sub Append
(
  var aString : alpha;              // zu erweiternde Zeichenkette
      aInsertString : alpha(8096);  // Inhalt der angehangen werden soll
  opt aSeparator : alpha;           // Seperator
  opt aInsertIfEmpty : logic;       // falls Separator trotz leeren Inhalts gedruckt werden soll
);
begin
  if(aInsertString = '') and (aInsertIfEmpty = false) then
    RETURN;

  if(aString = '') then begin
    aString # aInsertString;
  end
  else if(aString <> '') then begin
    if(aSeparator <> '') then
     aString # aString + aSeparator;

    aString # aString + aInsertString;
  end;
end;


//========================================================================
//  AlphaToInt  MS 08.11.2010
//    wandelt eine Zeichenkette in einen Integerwert um
//    sollte die Umwandlung nicht moeglich sein, wird der
//    Fehler abgefangen und eine 0 zurueckgegeben
//========================================================================
sub AlphaToInt(aAlpha : alpha) : int;
local begin
  vInt : int;
end;
begin
  vInt # 0;

  ErrTryCatch(_ErrCnv, true);
  try begin
    //ErrTryIgnore(_ErrCnv);
    vInt # cnvIA(aAlpha);
  end;

  if(ErrGet() = _ErrOK) then begin
    vInt # cnvIA(aAlpha);
  end;

  RETURN vInt;
end;


//========================================================================
//  sub DateForSort(aDate : date) : alpha                  ST 19.09.2012
//    Wandelt ein Datum in ein sortierbaren String
//========================================================================
sub DateForSort(aDate : date) : alpha
begin
  return cnvai(dateyear(aDate)+1900,_fmtNumNoGroup)+'.'+
         cnvai(datemonth(aDate),_fmtNumNoGroup|_fmtNumLeadZero,0,2)+'.'+
         cnvai(dateday(aDate),_fmtNumNoGroup|_fmtNumLeadZero,0,2);
end;


//========================================================================
//  sub NumForSort(aFloat : float; opt aNachKomma : int) : alpha
//    Wandelt einen Float in einen sortierbaren String      ST 19.09.2012
//========================================================================
sub NumForSort(aFloat : float) : alpha
local begin
  vTmp : bigint;
end;
begin
  vTmp # CnvBF(aFloat * 1000.0) + 10000000000\b;
  return CnvAB(vTmp,_FmtNumLeadZero|_fmtNumNoGroup,0,12);
end;


//========================================================================
//  sub IntForSort(aInt : int; ) : alpha                  ST 19.09.2012
//    Wandelt einen Integer in einen sortierbaren String
//========================================================================
sub IntForSort(aInt : int) : alpha
local begin
  vTmp : bigint;
end;
begin
  vTmp # CnvBI(aInt) + 10000000000\b;
  return CnvAB(vTmp,_FmtNumLeadZero|_fmtNumNoGroup,0,12);
end;


//========================================================================
//  RtfSaveHTML
//
//========================================================================
sub RTFSaveHTML(
  aWinRTF               : handle;       // RTFEdit
  aText                 : handle;       // Text
)
local begin
    tLineCounter        : int;
    tBreak              : logic;
    tRangeSave          : range;
    tPosCount           : int;
    tPosCounter         : int;
    tChar               : alpha(   1);
    tCharPrev           : alpha(   1);
    tLine               : alpha(8096);
    tSpan               : logic;
    tDiv                : logic;
    tFontNameDefault    : alpha;
    tFontName           : alpha;
    tFontNamePrev       : alpha;
    tFontSizeDefault    : int;
    tFontSize           : int;
    tFontSizePrev       : int;
    tColorForeDefault   : int;
    tColorFore          : int;
    tColorForePrev      : int;
    tColorBackDefault   : int;
    tColorBack          : int;
    tColorBackPrev      : int;
    tEffect             : int;
    tEffectPrev         : int;
    tAlignDefault       : int;
    tAlign              : int;
    tAlignPrev          : int;
    tAlignText          : alpha;
end
begin
  tLineCounter # aText->TextInfo(_TextLines);

  //tBreakChar # StrChar(13) + StrChar(10);

  // Standardschriftart ermitteln
  tFontNameDefault # aWinRTF->wpFontName(_WinEditDefault);
  // Standardschriftgröße ermitteln
  tFontSizeDefault # aWinRTF->wpFontSize(_WinEditDefault);

  // Standardausrichtung ermitteln
  tAlignDefault # aWinRTF->wpRTFAlign(_WinEditDefault);

  // Standardvordergrundfarbe ermitteln
  tColorForeDefault # aWinRTF->wpColFg(_WinEditDefault);
  // Standardhintergrundfarbe ermitteln
  tColorBackDefault # aWinRTF->wpColBkg(_WinEditDefault);

  tColorForeDefault # _WinColBlack;
  tColorBackDefault # _WinColWhite;

  // Standardformatierungsanfang definieren
  tLine # '<div style="';

  tLine # tLine + 'font-family:''' + tFontNameDefault + ''';';
  tLine # tLine + 'font-size:' + CnvAI(tFontSizeDefault, _FmtInternal) + 'pt;';
  tLine # tLine + 'color:#' + CnvAI(((tColorForeDefault & 0x00FF0000) >> 16) | (tColorForeDefault & 0x0000FF00) | ((tColorForeDefault & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
  tLine # tLine + 'background-color:#' + CnvAI(((tColorBackDefault & 0x00FF0000) >> 16) | (tColorBackDefault & 0x0000FF00) | ((tColorBackDefault & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';

  case (tAlignDefault) of
    _WinRtfAlignLeft    : tAlignText # 'left';
    _WinRtfAlignCenter  : tAlignText # 'center';
    _WinRtfAlignRight   : tAlignText # 'right';
    _WinRtfAlignJustify : tAlignText # 'justify';
    otherwise           tAlignText # '';
  end;

  if (tAlignText != '') then begin
    tLine # tLine + 'text-align:' + tAlignText + ';';
  end;

  tLine # tLine + '">';

  // Standardformatierungsanfang schreiben
  inc (tLineCounter);
  aText->TextLineWrite(tLineCounter, tLine, _TextLineInsert);
  tBreak # true;
  tLine # '';

  tFontNamePrev # tFontNameDefault;
  tFontSizePrev # tFontSizeDefault;

  tColorForePrev # tColorForeDefault;
  tColorBackPrev # tColorBackDefault;

  tAlignPrev # tAlignDefault;

  // Markierten Bereich sichern
  tRangeSave # aWinRTF->wpRange;

  aWinRTF->WinUpdate(_WinUpdOff | _WinUpdScrollPos);

  // Zeichenanzahl ermitteln
  aWinRTF->wpRange # RangeMake(0, -1);
  tPosCount # aWinRTF->wpRange:max;

  // Zeichen verarbeiten
  for   tPosCounter # 1;
  loop  inc (tPosCounter);
  while (tPosCounter <= tPosCount) do begin
    // Zeichen markieren
    aWinRTF->wpRange # RangeMake(tPosCounter - 1, tPosCounter);

    // Schriftart ermitteln
    tFontName # aWinRTF->wpFontName(_WinEditMark);
    // Schriftgröße ermitteln
    tFontSize # aWinRTF->wpFontSize(_WinEditMark);

    // Effekte ermitteln
    tEffect # aWinRTF->wpRTFEffect(_WinEditMark);

    // Ausrichtung ermitteln
    tAlign # aWinRTF->wpRTFAlign(_WinEditMark);

    // Vordergrundfarbe ermitteln
    tColorFore # aWinRTF->wpColFg(_WinEditMark);
    if (tColorFore = 0 or tColorFore = _WinColUndefined) then begin
      tColorFore # tColorForeDefault;
    end;

    // Hintergrundfarbe ermitteln
    tColorBack # aWinRTF->wpColBkg(_WinEditMark);
    if (tColorBack = 0 or tColorBack = _WinColUndefined) then begin
      tColorBack # tColorBackDefault;
    end;

    // DIV-Tag:
    // Ausrichtung gewechselt
    if (tAlign != tAlignPrev) then begin
      // Zeile schreiben
      while (tLine != '') do begin
        inc (tLineCounter);
        aText->TextLineWrite(tLineCounter, StrCut(tLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
        tLine # StrDel(tLine, 1, 250);
      end;

      // DIV-Tag geöffnet
      if (tDiv) then begin
        // Kein Zeilenumbruch geschrieben
        if (!tBreak) then begin
          // Zeilenumbruch schreiben
          inc (tLineCounter);
          aText->TextLineWrite(tLineCounter, '', _TextLineInsert);
          tBreak # true;
        end;

        // DIV-Tag schließen
        inc (tLineCounter);
        aText->TextLineWrite(tLineCounter, '</div>', _TextLineInsert);
        tBreak # true;

        tDiv # false;
      end;

      tAlignPrev # tAlign;

      // Ausrichtung abweichend von Standard
      if (tAlign != tAlignDefault) then begin
        // Kein Zeilenumbruch geschrieben
        if (!tBreak) then begin
          // Zeilenumbruch schreiben
          inc (tLineCounter);
          aText->TextLineWrite(tLineCounter, '', _TextLineInsert);
          tBreak # true;
        end;

        // Ausrichtung schreiben
        tLine # '<div style="'

        case (tAlign) of
          _WinRtfAlignLeft    : tAlignText # 'left';
          _WinRtfAlignCenter  : tAlignText # 'center';
          _WinRtfAlignRight   : tAlignText # 'right';
          _WinRtfAlignJustify : tAlignText # 'justify';
          otherwise           tAlignText # '';
        end;

        if (tAlignText != '') then begin
          tLine # tLine + 'text-align:' + tAlignText + ';';
        end;

        tLine # tLine + '">';

        inc (tLineCounter);
        aText->TextLineWrite(tLineCounter, tLine, _TextLineInsert);
        tBreak # true;
        tLine # '';

        tDiv # true;
      end;
    end;

    // SPAN-Tag:
    // Schriftart oder
    // Schriftgröße oder
    // Vordergrundfarbe oder
    // Hintergrundfarbe gewechselt
    if (tFontName != tFontNamePrev or
       tFontSize != tFontSizePrev or
       tColorFore != tColorForePrev or
       tColorBack != tColorBackPrev) then begin
      // SPAN-Tag geöffnet
      if (tSpan) then begin
        // SPAN-Tag schließen
        tLine # tLine + '</span>';
        tSpan # false;
      end;

      tFontNamePrev # tFontName;
      tFontSizePrev # tFontSize;
      tColorForePrev # tColorFore;
      tColorBackPrev # tColorBack;

      // Schriftart oder
      // Schriftgröße oder
      // Vordergrundfarbe oder
      // Hintergrundfarbe abweichend von Standard
      if (tFontName != tFontNameDefault or
         tFontSize != tFontSizeDefault or
         tColorFore != tColorForeDefault or
         tColorBack != tColorBackDefault) then begin
        tLine # tLine + '<span style="';

        // Schriftart abweichend
        if (tFontName != tFontNameDefault) then begin
          // Schriftart schreiben
          tLine # tLine + 'font-family:''' + tFontName + ''';';
        end;

        // Schriftgröße abweichend
        if (tFontSize != tFontSizeDefault) then begin
          // Schriftgröße schreiben
          tLine # tLine + 'font-size:' + CnvAI(tFontSize, _FmtInternal) + 'pt;';
        end;

        // Vordergrundfarbe abweichend
        if (tColorFore != tColorForeDefault) then begin
          // Vordergrundfarbe schreiben
          tLine # tLine + 'color:#' + CnvAI(((tColorFore & 0x00FF0000) >> 16) | (tColorFore & 0x0000FF00) | ((tColorFore & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
        end;

        // Hintergrundfarbe abweichend
        if (tColorBack != tColorBackDefault) then begin
          // Hintergrundfarbe schreiben
          tLine # tLine + 'background-color:#' + CnvAI(((tColorBack & 0x00FF0000) >> 16) | (tColorBack & 0x0000FF00) | ((tColorBack & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
        end;

        tLine # tLine + '">';

        tBreak # false;

        tSpan # true;
      end;
    end;

    // B-, I- oder U-Tag
    // Effekte gewechselt
    if (tEffect != tEffectPrev) then begin
      // fett
      if (tEffect & _WinRtfEffectBold != tEffectPrev & _WinRtfEffectBold) then begin
        // fett Anfang
        if (tEffect & _WinRtfEffectBold != 0) then begin
          tLine # tLine + '<b>';
          end
        // fett Ende
        else begin
          tLine # tLine + '</b>';
        end;

        tBreak # false;
      end;

      // kursiv
      if (tEffect & _WinRtfEffectItalic != tEffectPrev & _WinRtfEffectItalic) then begin
        // kursiv Anfang
        if (tEffect & _WinRtfEffectItalic != 0) then begin
          tLine # tLine + '<i>';
        end
        // kursiv Ende
        else begin
          tLine # tLine + '</i>';
        end;

        tBreak # false;
      end;

      // unterstrichen
      if (tEffect & _WinRtfEffectUnderline != tEffectPrev & _WinRtfEffectUnderline) then begin
        // unterstrichen Anfang
        if (tEffect & _WinRtfEffectUnderline != 0) then begin
          tLine # tLine + '<u>';
        end
        // unterstrichen Ende
        else begin
          tLine # tLine + '</u>';
        end;

        tBreak # false;
      end;

      tEffectPrev # tEffect;
    end;

    // Zeichen ermitteln
    tChar # aWinRTF->wpCaption;

    // kein Zeichen (Ende)
    if (tChar = '') then begin
      // SPAN-Tag geöffnet
      if (tSpan) then begin
        // SPAN-Tag schließen
        tLine # tLine + '</span>';

        tBreak # false;
      end;

      // DIV-Tag geöffnet
      if (tDiv) then begin
        // Zeile schreiben
        while (tLine != '') do begin
          inc (tLineCounter);
          aText->TextLineWrite(tLineCounter, StrCut(tLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
          tLine # StrDel(tLine, 1, 250);
        END;

        // Kein Zeilenumbruch geschrieben
        if (!tBreak) then begin
          // Zeilenumbruch schreiben
          inc (tLineCounter);
          aText->TextLineWrite(tLineCounter, '', _TextLineInsert);
          tBreak # true;
        end;

        // DIV-Tag schließen
        inc (tLineCounter);
        aText->TextLineWrite(tLineCounter, '</div>', _TextLineInsert);
        tBreak # true;
      end;

      // Zeile schreiben
      while (tLine != '') do begin
        inc (tLineCounter);
        aText->TextLineWrite(tLineCounter, StrCut(tLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
        tLine # StrDel(tLine, 1, 250);
      END;
    end
    else begin
      tBreak # false;

      case (tChar) of
        // Zeilenumbruch
        StrChar(13) : begin
          // Zeile schreiben
          while (tLine != '') do begin
            inc (tLineCounter);
            aText->TextLineWrite(tLineCounter, StrCut(tLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
            tLine # StrDel(tLine, 1, 250);
          end;

          // Zeilenumbruch schreiben
          inc (tLineCounter);
          aText->TextLineWrite(tLineCounter, '<br/>', _TextLineInsert);
          tBreak # true;
        end;

        // Tabulator
        StrChar( 9) : tLine # tLine + '<span style="white-space:pre">&#9;</span>';

        // Leerzeichen
        ' '         : begin
          if (tCharPrev = ' ' or tCharPrev = StrChar(13)) then begin
            tLine # tLine + '&nbsp;';
          end
          else begin
            tLine # tLine + tChar;
          end;
        end;

        // HTML-Markup
        '"'         : tLine # tLine + '&quot;';
        '&'         : tLine # tLine + '&amp;';
        '<'         : tLine # tLine + '&lt;';
        '>'         : tLine # tLine + '&gt;';
        // Sonstige Zeichen
        otherwise     tLine # tLine + tChar;
      end;
    end;

    tCharPrev # tChar;
  end;

  // Kein Zeilenumbruch geschrieben
  if (!tBreak) then begin
    // Zeilenumbruch schreiben
    inc (tLineCounter);
    aText->TextLineWrite(tLineCounter, '', _TextLineInsert);
  end;

  // Standardformatierungsende schreiben
  inc (tLineCounter);
  aText->TextLineWrite(tLineCounter, '</div>', _TextLineInsert);

  // Markierten Bereich wiederherstellen
  aWinRTF->wpRange # tRangeSave;

  aWinRTF->WinUpdate(_WinUpdOn | _WinUpdScrollPos);
end;

//========================================================================
//  sub Timestamp(opt aDate : date; opt aTime : time) : alpha ST 12.02.2013
//    Gibt einen Timestap ohne Sonderzeichen zurück
//========================================================================
sub Timestamp(opt aDate : date; opt aTime : time) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  if (aDate = 0.0.0) then
    vDate # SysDate();
  else
    vDate # aDate;

  if (aTime = 0:0:0) then
    vTime # Systime(_TimeSec | _TimeServer);
  else
    vTime # aTime;

  vA #  cnvai(vDate->vpYear - 2000, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2);

  RETURN vA;
end;


//========================================================================
//  sub TimestampYear(opt aDate : date; opt aTime : time) : alpha ST 30.07.2013
//    Gibt einen Timestap ohne Sonderzeichen zurück, inkl. kompletter Jahresangabe
//========================================================================
sub TimestampFullYearMs(opt aDate : date; opt aTime : time) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  if (aDate = 0.0.0) then
    vDate # SysDate();
  else
    vDate # aDate;

  if (aTime = 0:0:0) then
    vTime # Systime(_TimeSec | _TimeServer);
  else
    vTime # aTime;

  vA #  cnvai(vDate->vpYear, _Fmtnumleadzero | _FmtNumNoGroup)+
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2)+
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2)+
        cnvai(vTime->vpMilliseconds, _Fmtnumleadzero,0,3);

  RETURN vA;
end;



/*
========================================================================
2023-03-06  DS                                               2407/6

Gibt einen Timestap mit Sonderzeichen zurück, inkl. kompletter Jahresangabe
bis zu Sekunden.

Also im klassischen Format YYYY-MM-DD hh:mm:ss
========================================================================
*/
sub TimestampFullYear(opt aDate : date; opt aTime : time) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  if (aDate = 0.0.0) then
    vDate # SysDate();
  else
    vDate # aDate;

  if (aTime = 0:0:0) then
    vTime # Systime(_TimeSec | _TimeServer);
  else
    vTime # aTime;

  vA #  cnvai(vDate->vpYear, _Fmtnumleadzero | _FmtNumNoGroup) + '-' +
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2) + '-' +
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2) + ' ' +
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2) + ':' +
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2) + ':' +
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2)

  RETURN vA;
end;



/*
========================================================================
2023-03-06  DS                                               2407/6

Gibt einen Dateinamen-freundlichen Timestap, inkl. kompletter Jahresangabe
bis zu Sekunden.

Format YYYY-MM-DD_hh-mm-ss
========================================================================
*/
sub TimestampFullYearFilename(opt aDate : date; opt aTime : time) : alpha
local begin
  vA,vB,vC  : alpha;
  vDate     : date;
  vTime     : time;
end;
begin
  if (aDate = 0.0.0) then
    vDate # SysDate();
  else
    vDate # aDate;

  if (aTime = 0:0:0) then
    vTime # Systime(_TimeSec | _TimeServer);
  else
    vTime # aTime;

  vA #  cnvai(vDate->vpYear, _Fmtnumleadzero | _FmtNumNoGroup) + '-' +
        cnvai(vDate->vpMonth, _Fmtnumleadzero,0,2) + '-' +
        cnvai(vDate->vpday, _Fmtnumleadzero,0,2) + '_' +
        cnvai(vTime->vpHours, _Fmtnumleadzero,0,2) + '-' +
        cnvai(vTime->vpMinutes, _Fmtnumleadzero,0,2) + '-' +
        cnvai(vTime->vpSeconds, _Fmtnumleadzero,0,2)

  RETURN vA;
end;


//========================================================================
//  sub DateFromYMD(aDateString : alpha) : date
//
//========================================================================
sub DateFromYMD(aDateString : alpha) : date
local begin
  vRet      : caltime;
  vDelim    : alpha;
end;
begin
  if (StrAdj(aDateString,_StrAll) = '') then
    RETURN 0.0.0;
    
      
  // GGf. TimeStamp abschneiden
  aDateString # Strings_Token(aDateString,' ',1);
    
  vDelim      # '-';
  aDateString #   Strings_ReplaceEachToken(aDateString,'-/_.',vDelim);

  
  
  vRet->vpYear  # CnvIa(Strings_Token(aDateString,vDelim,1));
  vRet->vpMonth # CnvIa(Strings_Token(aDateString,vDelim,2));
  vRet->vpDay   # CnvIa(Strings_Token(aDateString,vDelim,3));

  RETURN vRet->vpDate;
end;



//========================================================================
//========================================================================
//========================================================================
