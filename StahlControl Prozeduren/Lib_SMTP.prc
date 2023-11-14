@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_SMTP
//                OHNE E_R_G
//  Info
//
//
//  05.05.2015  AH  Erstellung der Prozedur
//  2023-06-01  AH  OAUTH implementiert
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//
//
//========================================================================
sub Mail.Send(
  aType                 : int;
  aHostName             : alpha;        // Servername
  aHostPort             : word;         // Serverport
  aUserName             : alpha;        // Benutzername
  aUserPass             : alpha;        // Benutzerkennwort
  aFromAddr             : alpha;        // Absenderadresse
  aFromName             : alpha;        // Absendername
  aToAddr               : alpha;        // Empfängeradresse
  aToName               : alpha;        // Empfängername
  aSubject              : alpha(1024);  // Betreff
  aTextPlain            : handle;       // Text (Plain)
  opt aTextHTML         : handle;       // Text (HTML)
  opt aAttachDL         : handle;       // DL ODER CTELIST
  opt aBCC              : alpha(4000);
  opt aCC               : alpha(4000)
): int;                                 // Fehler
local begin
  vErr                  : int;
  vMail                 : handle;
  vI                    : int;
  vFilename             : alpha(4000);
end;
begin
//debugx(ausername+' > '+aUserpass);
  REPEAT

    // E-Mail öffnen
    vMail # MailOpen(aType, aHostName, aHostPort, 0, aUserName, aUserPass);
    // E-Mail geöffnet
    if (vMail > 0) then begin
      ErrSet(_ErrOK);

      try begin
        // Absender einstellen
        vMail->MailData(_SMTPFrom, aFromAddr, aFromName);
        // Empfänger einstellen
        vMail->MailData(_SMTPTo, aToAddr, aToName);
        if (aBCC<>'') then
          vMail->MailData(_SmtpBCC, aBCC, aToName);
        if (aCC<>'') then
          vMail->MailData(_SmtpCC, aCC, aToName);
        
        // Betreff einstellen
        vMail->MailData(_SMTPSubject, aSubject);

        // Text einstellen
        if (aTextPlain<>0) then
          vMail->MailData(_MailBuffer | _MimeTE_8B, CnvAI(aTextPlain, _FmtInternal));

        if (aTextHTML != 0) then
          // HTML-Text einstellen
          vMail->MailData(_MailBuffer | _MimeTE_8B | _MIMETextHTML, CnvAI(aTextHTML, _FmtInternal));

          if (aAttachDL<>0) then begin
            if (HdlInfo(aAttachDL,_HdlType)<>_HdlCteList) then begin
              FOR vI # 1 // Anhang aus Data-List loopen
              LOOP inc(vI)
              WHILE (vI <= WinLstDatLineInfo(aAttachDL, _WinLstDatInfoCount)) do begin
                WinLstCellGet(aAttachDL, vFilename, 2, vI);    // Zeile lesen
                vMail->MailData(_MailFile | _MimeApp, vFilename);
              END;
            end
            else begin
              FOR vI # CteRead(aAttachDL, _CteFirst)
              LOOP vI # CteRead(aAttachDL, _CteNext, vI)
              WHILE (vI<>0) do begin
                vFilename # vI->spName;
                vMail->MailData(_MailFile | _MimeApp, vFilename);
              END;
            end;
          end;


      end;

      // Fehler ermitteln
      vErr # ErrGet();

      // Kein Fehler aufgetreten
      if (vErr = _ErrOK) then begin
        // E-Mail senden und schließen
        vErr # vMail->MailClose(_SMTPSendNow);
      end
      // Fehler aufgetreten
      else begin
        // E-Mail schließen
        vMail->MailClose(_SMTPDiscard);
      end;
    end
    else begin
      // E-Mail nicht geöffnet
      vErr # vMail;
    end;

  UNTIL (true);

  RETURN(vErr);

end;


//========================================================================
//  2023-05-31  AH
//
//========================================================================
sub Mail.OAuth.Send(
  aType                 : int;
  aHostName             : alpha;        // Servername
  aHostPort             : word;         // Serverport
  aUserName             : alpha;        // Benutzername

  aTenantID             : alpha;
  aClientID             : alpha;

  aFromAddr             : alpha;        // Absenderadresse
  aFromName             : alpha;        // Absendername
  aToAddr               : alpha;        // Empfängeradresse
  aToName               : alpha;        // Empfängername
  aSubject              : alpha(1024);  // Betreff
  aTextPlain            : handle;       // Text (Plain)
  opt aTextHTML         : handle;       // Text (HTML)
  opt aAttachDL         : handle;       // DL ODER CTELIST
  opt aBCC              : alpha(4000);
  opt aCC               : alpha(4000)
): int;                                 // Fehler
local begin
  vErr                  : int;
  vMail                 : handle;
  vI                    : int;
  vFilename             : alpha(4000);
  vTokenCache           : alpha(4000);
  vPlatform             : alpha;
end;
begin
//debugx(ausername+' > '+aUserpass);

  // Identify platform.
  case (_Sys->spPlatform) of
    _PfmAPI : vPlatform # 'API';
    _PfmClient4 : vPlatform # 'Standard Client';
    _PfmClient5 : vPlatform # 'Advanced Client';
    _PfmSOA : vPlatform # 'SOA';
    otherwise begin
      vPlatform # CnvAI(_Sys->spPlatform);
    end;
  end;
  // Generate platform string:
  vPlatform # 'C16_SMTPV3_'+vPlatform + ' ' + CnvAI(_Sys->spProcessArchitecture) + '-bit'
  // Generate token cache path:
  //vTokenCache # SysGetEnv('TEMP')+vPlatform; //'c:\debug\' + vPlatform;
  vTokenCache # SysGetEnv('ProgramData')+'\'+vPlatform; //'c:\debug\' + vPlatform;

  REPEAT
    // E-Mail öffnen
//    vMail # MailOpen(aType, aHostName, aHostPort, 0, aUserName, aUserPass);
      vMail # MailOpen(aType, aHostName, aHostPort, 10, aUserName, '', aTenantID, aClientID, vTokenCache);

    // E-Mail geöffnet
    if (vMail > 0) then begin
      ErrSet(_ErrOK);

      try begin
        // Absender einstellen
        vMail->MailData(_SMTPFrom, aFromAddr, aFromName);
        // Empfänger einstellen
        vMail->MailData(_SMTPTo, aToAddr, aToName);
        if (aBCC<>'') then
          vMail->MailData(_SmtpBCC, aBCC, aToName);
        if (aCC<>'') then
          vMail->MailData(_SmtpCC, aCC, aToName);
        
        // Betreff einstellen
        vMail->MailData(_SMTPSubject, aSubject);

        // Text einstellen
        if (aTextPlain<>0) then
          vMail->MailData(_MailBuffer | _MimeTE_8B, CnvAI(aTextPlain, _FmtInternal));

        if (aTextHTML != 0) then
          // HTML-Text einstellen
          vMail->MailData(_MailBuffer | _MimeTE_8B | _MIMETextHTML, CnvAI(aTextHTML, _FmtInternal));

        if (aAttachDL<>0) then begin
          if (HdlInfo(aAttachDL,_HdlType)<>_HdlCteList) then begin
            FOR vI # 1 // Anhang aus Data-List loopen
            LOOP inc(vI)
            WHILE (vI <= WinLstDatLineInfo(aAttachDL, _WinLstDatInfoCount)) do begin
              WinLstCellGet(aAttachDL, vFilename, 2, vI);    // Zeile lesen
              vMail->MailData(_MailFile | _MimeApp, vFilename);
            END;
          end
          else begin
            FOR vI # CteRead(aAttachDL, _CteFirst)
            LOOP vI # CteRead(aAttachDL, _CteNext, vI)
            WHILE (vI<>0) do begin
              vFilename # vI->spName;
              vMail->MailData(_MailFile | _MimeApp, vFilename);
            END;
          end;
        end;
      end;

      // Fehler ermitteln
      vErr # ErrGet();

      // Kein Fehler aufgetreten
      if (vErr = _ErrOK) then begin
        // E-Mail senden und schließen
        vErr # vMail->MailClose(_SMTPSendNow);
      end
      // Fehler aufgetreten
      else begin
        // E-Mail schließen
        vMail->MailClose(_SMTPDiscard);
      end;
    end
    else begin
      // E-Mail nicht geöffnet
      vErr # vMail;
    end;

  UNTIL (true);

  RETURN(vErr);

end;



//========================================================================
//========================================================================
sub Win.RTFSaveHTML(
  aWinRTF               : handle;       // RTFEdit
  aText                 : handle;       // Text
)
local begin
    vLineCounter        : int;
    vBreak              : logic;
    vRangeSave          : range;
    vPosCount           : int;
    vPosCounter         : int;
    vChar               : alpha(   1);
    vCharPrev           : alpha(   1);
    vLine               : alpha(4096);
    vSpan               : logic;
    vDiv                : logic;
    vFontNameDefault    : alpha;
    vFontName           : alpha;
    vFontNamePrev       : alpha;
    vFontSizeDefault    : int;
    vFontSize           : int;
    vFontSizePrev       : int;
    vColorForeDefault   : int;
    vColorFore          : int;
    vColorForePrev      : int;
    vColorBackDefault   : int;
    vColorBack          : int;
    vColorBackPrev      : int;
    vEffect             : int;
    vEffectPrev         : int;
    vAlignDefault       : int;
    vAlign              : int;
    vAlignPrev          : int;
    vAlignText          : alpha;
end
begin
  vLineCounter # aText->TextInfo(_TextLines);

  //tBreakChar # StrChar(13) + StrChar(10);

  // Standardschriftart ermitteln
  vFontNameDefault # aWinRTF->wpFontName(_WinEditDefault);
  // Standardschriftgröße ermitteln
  vFontSizeDefault # aWinRTF->wpFontSize(_WinEditDefault);

  // Standardausrichtung ermitteln
  vAlignDefault # aWinRTF->wpRTFAlign(_WinEditDefault);

  // Standardvordergrundfarbe ermitteln
  vColorForeDefault # aWinRTF->wpColFg(_WinEditDefault);
  // Standardhintergrundfarbe ermitteln
  vColorBackDefault # aWinRTF->wpColBkg(_WinEditDefault);

  // Standardformatierungsanfang definieren
  vLine # '<div style="';

  vLine # vLine + 'font-family:''' + vFontNameDefault + ''';';
  vLine # vLine + 'font-size:' + CnvAI(vFontSizeDefault, _FmtInternal) + 'pt;';
  vLine # vLine + 'color:#' + CnvAI(((vColorForeDefault & 0x00FF0000) >> 16) | (vColorForeDefault & 0x0000FF00) | ((vColorForeDefault & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
  vLine # vLine + 'background-color:#' + CnvAI(((vColorBackDefault & 0x00FF0000) >> 16) | (vColorBackDefault & 0x0000FF00) | ((vColorBackDefault & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';

  case (vAlignDefault) of
    _WinRtfAlignLeft    : vAlignText # 'left';
    _WinRtfAlignCenter  : vAlignText # 'center';
    _WinRtfAlignRight   : vAlignText # 'right';
    _WinRtfAlignJustify : vAlignText # 'justify';
    otherwise             vAlignText # '';
  end;

  if (vAlignText != '') then begin
    vLine # vLine + 'text-align:' + vAlignText + ';';
  end;

  vLine # vLine + '">';

  // Standardformatierungsanfang schreiben
  inc (vLineCounter);
  aText->TextLineWrite(vLineCounter, vLine, _TextLineInsert);
  vBreak # true;
  vLine # '';

  vFontNamePrev # vFontNameDefault;
  vFontSizePrev # vFontSizeDefault;

  vColorForePrev # vColorForeDefault;
  vColorBackPrev # vColorBackDefault;

  vAlignPrev # vAlignDefault;

  // Markierten Bereich sichern
  vRangeSave # aWinRTF->wpRange;

  aWinRTF->WinUpdate(_WinUpdOff | _WinUpdScrollPos);

  // Zeichenanzahl ermitteln
  aWinRTF->wpRange # RangeMake(0, -1);
  vPosCount # aWinRTF->wpRange:max;

  // Zeichen verarbeiten
  FOR   vPosCounter # 1;
  LOOP  inc (vPosCounter);
  WHILE (vPosCounter <= vPosCount) do begin
    // Zeichen markieren
    aWinRTF->wpRange # RangeMake(vPosCounter - 1, vPosCounter);

    // Schriftart ermitteln
    vFontName # aWinRTF->wpFontName(_WinEditMark);
    // Schriftgröße ermitteln
    vFontSize # aWinRTF->wpFontSize(_WinEditMark);

    // Effekte ermitteln
    vEffect # aWinRTF->wpRTFEffect(_WinEditMark);

    // Ausrichtung ermitteln
    vAlign # aWinRTF->wpRTFAlign(_WinEditMark);

    // Vordergrundfarbe ermitteln
    vColorFore # aWinRTF->wpColFg(_WinEditMark);
    if (vColorFore = 0 or vColorFore = _WinColUndefined) then begin
      vColorFore # vColorForeDefault;
    end;

    // Hintergrundfarbe ermitteln
    vColorBack # aWinRTF->wpColBkg(_WinEditMark);
    if (vColorBack = 0 or vColorBack = _WinColUndefined) then begin
      vColorBack # vColorBackDefault;
    end;

    // DIV-Tag:
    // Ausrichtung gewechselt
    if (vAlign != vAlignPrev) then begin
      // Zeile schreiben
      WHILE (vLine != '') do begin
        inc (vLineCounter);
        aText->TextLineWrite(vLineCounter, StrCut(vLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
        vLine # StrDel(vLine, 1, 250);
      END;

      // DIV-Tag geöffnet
      if (vDiv) then begin
        // Kein Zeilenumbruch geschrieben
        if (!vBreak) then begin
          // Zeilenumbruch schreiben
          inc (vLineCounter);
          aText->TextLineWrite(vLineCounter, '', _TextLineInsert);
          vBreak # true;
        end;

        // DIV-Tag schließen
        inc (vLineCounter);
        aText->TextLineWrite(vLineCounter, '</div>', _TextLineInsert);
        vBreak # true;

        vDiv # false;
      end;

      vAlignPrev # vAlign;

      // Ausrichtung abweichend von Standard
      if (vAlign != vAlignDefault) then begin
        // Kein Zeilenumbruch geschrieben
        if (!vBreak) then begin
          // Zeilenumbruch schreiben
          inc (vLineCounter);
          aText->TextLineWrite(vLineCounter, '', _TextLineInsert);
          vBreak # true;
        end;

        // Ausrichtung schreiben
        vLine # '<div style="'

        case (vAlign) of
          _WinRtfAlignLeft    : vAlignText # 'left';
          _WinRtfAlignCenter  : vAlignText # 'center';
          _WinRtfAlignRight   : vAlignText # 'right';
          _WinRtfAlignJustify : vAlignText # 'justify';
          otherwise             vAlignText # '';
        end;

        if (vAlignText != '') then begin
          vLine # vLine + 'text-align:' + vAlignText + ';';
        end;

        vLine # vLine + '">';

        inc (vLineCounter);
        aText->TextLineWrite(vLineCounter, vLine, _TextLineInsert);
        vBreak # true;
        vLine # '';

        vDiv # true;
      end;
    end;

    // SPAN-Tag:
    // Schriftart oder
    // Schriftgröße oder
    // Vordergrundfarbe oder
    // Hintergrundfarbe gewechselt
    if (vFontName != vFontNamePrev or
       vFontSize != vFontSizePrev or
       vColorFore != vColorForePrev or
       vColorBack != vColorBackPrev
    ) then begin
      // SPAN-Tag geöffnet
      if (vSpan) then begin
        // SPAN-Tag schließen
        vLine # vLine + '</span>';
        vSpan # false;
      end;

      vFontNamePrev # vFontName;
      vFontSizePrev # vFontSize;
      vColorForePrev # vColorFore;
      vColorBackPrev # vColorBack;

      // Schriftart oder
      // Schriftgröße oder
      // Vordergrundfarbe oder
      // Hintergrundfarbe abweichend von Standard
      if (vFontName != vFontNameDefault or
         vFontSize != vFontSizeDefault or
         vColorFore != vColorForeDefault or
         vColorBack != vColorBackDefault
      ) then begin
        vLine # vLine + '<span style="';

        // Schriftart abweichend
        if (vFontName != vFontNameDefault) then begin
          // Schriftart schreiben
          vLine # vLine + 'font-family:''' + vFontName + ''';';
        end;

        // Schriftgröße abweichend
        if (vFontSize != vFontSizeDefault) then begin
          // Schriftgröße schreiben
          vLine # vLine + 'font-size:' + CnvAI(vFontSize, _FmtInternal) + 'pt;';
        end;

        // Vordergrundfarbe abweichend
        if (vColorFore != vColorForeDefault) then begin
          // Vordergrundfarbe schreiben
          vLine # vLine + 'color:#' + CnvAI(((vColorFore & 0x00FF0000) >> 16) | (vColorFore & 0x0000FF00) | ((vColorFore & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
        end;

        // Hintergrundfarbe abweichend
        if (vColorBack != vColorBackDefault) then begin
          // Hintergrundfarbe schreiben
          vLine # vLine + 'background-color:#' + CnvAI(((vColorBack & 0x00FF0000) >> 16) | (vColorBack & 0x0000FF00) | ((vColorBack & 0x000000FF) << 16), _FmtNumHex | _FmtNumLeadZero, 0, 6) + ';';
        end;

        vLine # vLine + '">';

        vBreak # false;

        vSpan # true;
      end;
    end;

    // B-, I- oder U-Tag
    // Effekte gewechselt
    if (vEffect != vEffectPrev) then begin
      // fett
      if (vEffect & _WinRtfEffectBold != vEffectPrev & _WinRtfEffectBold) then begin
        // fett Anfang
        if (vEffect & _WinRtfEffectBold != 0) then begin
          vLine # vLine + '<b>';
        end
        // fett Ende
        else begin
          vLine # vLine + '</b>';
        end;
        vBreak # false;
      end;

      // kursiv
      if (vEffect & _WinRtfEffectItalic != vEffectPrev & _WinRtfEffectItalic) then begin
        // kursiv Anfang
        if (vEffect & _WinRtfEffectItalic != 0) then begin
          vLine # vLine + '<i>';
        end
        // kursiv Ende
        else begin
          vLine # vLine + '</i>';
        end;

        vBreak # false;
      end;

      // unterstrichen
      if (vEffect & _WinRtfEffectUnderline != vEffectPrev & _WinRtfEffectUnderline) then begin
        // unterstrichen Anfang
        if (vEffect & _WinRtfEffectUnderline != 0) then begin
          vLine # vLine + '<u>';
        end
        // unterstrichen Ende
        else begin
          vLine # vLine + '</u>';
        end;

        vBreak # false;
      end;

      vEffectPrev # vEffect;
    end;

    // Zeichen ermitteln
    vChar # aWinRTF->wpCaption;

    // kein Zeichen (Ende)
    if (vChar = '') then begin
      // SPAN-Tag geöffnet
      if (vSpan) then begin
        // SPAN-Tag schließen
        vLine # vLine + '</span>';
        vBreak # false;
      end;

      // DIV-Tag geöffnet
      if (vDiv) then begin
        // Zeile schreiben
        WHILE (vLine != '') do begin
          inc (vLineCounter);
          aText->TextLineWrite(vLineCounter, StrCut(vLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
          vLine # StrDel(vLine, 1, 250);
        END;

        // Kein Zeilenumbruch geschrieben
        if (!vBreak) then begin
          // Zeilenumbruch schreiben
          inc (vLineCounter);
          aText->TextLineWrite(vLineCounter, '', _TextLineInsert);
          vBreak # true;
        end;

        // DIV-Tag schließen
        inc (vLineCounter);
        aText->TextLineWrite(vLineCounter, '</div>', _TextLineInsert);
        vBreak # true;
      end;

      // Zeile schreiben
      WHILE (vLine != '') do begin
        inc (vLineCounter);
        aText->TextLineWrite(vLineCounter, StrCut(vLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
        vLine # StrDel(vLine, 1, 250);
      END;
    end
    else begin
      vBreak # false;

      case (vChar) of
        // Zeilenumbruch
        StrChar(13) : begin
            // Zeile schreiben
            WHILE (vLine != '') do begin
              inc (vLineCounter);
              aText->TextLineWrite(vLineCounter, StrCut(vLine, 1, 250), _TextLineInsert | _TextNoLineFeed);
              vLine # StrDel(vLine, 1, 250);
            END;

            // Zeilenumbruch schreiben
            inc (vLineCounter);
            aText->TextLineWrite(vLineCounter, '<br/>', _TextLineInsert);
            vBreak # true;
          end;
        // Tabulator
        StrChar( 9) : vLine # vLine + '<span style="white-space:pre">&#9;</span>';
        // Leerzeichen
        ' '         : begin
            if (vCharPrev = ' ' or vCharPrev = StrChar(13)) then begin
              vLine # vLine + '&nbsp;';
            end
            else begin
              vLine # vLine + vChar;
            end;
          end;
        // HTML-Markup
        '"'         : vLine # vLine + '&quot;';
        '&'         : vLine # vLine + '&amp;';
        '<'         : vLine # vLine + '&lt;';
        '>'         : vLine # vLine + '&gt;';
        // Sonstige Zeichen
        otherwise     vLine # vLine + vChar;
      end;
    end;

    vCharPrev # vChar;
  end;

  // Kein Zeilenumbruch geschrieben
  if (!vBreak) then begin
    // Zeilenumbruch schreiben
    inc (vLineCounter);
    aText->TextLineWrite(vLineCounter, '', _TextLineInsert);
  end;

  // Standardformatierungsende schreiben
  inc (vLineCounter);
  aText->TextLineWrite(vLineCounter, '</div>', _TextLineInsert);

  // Markierten Bereich wiederherstellen
  aWinRTF->wpRange # vRangeSave;

  aWinRTF->WinUpdate(_WinUpdOn | _WinUpdScrollPos);
end;


//========================================================================
//========================================================================
sub ConvertRTF2HTML(
  aRTFObj     : int;
  aTextSource : int;
);
begin
  // RTF-Text in HTML-Text konvertieren
  Win.RTFSaveHTML(aRTFObj, aTextSource);

  // HTML-Anfang schreiben
  aTextSource->TextLineWrite(1, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">', _TextLineInsert);
  aTextSource->TextLineWrite(2, '<HTML>', _TextLineInsert);
  aTextSource->TextLineWrite(3, '<BODY>', _TextLineInsert);

  // HTML-Ende schreiben
  aTextSource->TextLineWrite(aTextSource->TextInfo(_TextLines) + 1, '</BODY>', _TextLineInsert);
  aTextSource->TextLineWrite(aTextSource->TextInfo(_TextLines) + 1, '</HTML>', _TextLineInsert);

end;


//========================================================================
//========================================================================
Sub SendPDF(
  aEMA      : alpha(1000);
  aSubject  : alpha(1000);
  aPath     : alpha(4000)
);
begin
Call(Set.EMail.OutputProc, aEMA, aSubject);
end;



/***
sub _SendMail(aLfs : int; aAttachment : alpha) : int
local begin
  vHdl        : int;
  vSMTP       : alpha;
  vSMTPAcc    : alpha;
  vSMTPPW     : alpha;
  vSendEMA    : alpha;
  vSMTPPort   : int;
  vSendName   : alpha;
  vRecEMA     : alpha;
  vRecName    : alpha;
end
begin
  vSMTP       # 'lenny.edv-knott.de'
  vSMTPAcc    # 'notification@edvknott.de'
  vSMTPPW     # 'dd6ac0e3'
  vSendEMA    # 'info@neumann-spaltband.de'
  vSMTPPort   # 587

  if (DbaLicense(_DbaSrvLicense)<>'CD152667MN/H') then begin
    // Lizenz NEUMANN
    vSendName   # 'Stahl Control'
    vRecEMA     # 'bandeingang@wiederholt.com'    // Nach echtstart
    vRecName    # 'bandeingang@wiederholt.com'
  end else begin
  // Lizenz BCS zum Testen
    vSMTPPort   # 25
    vSendName   # 'Stahl Control'
    vRecEMA     # 'st@stahl-control.de'
    vRecName    # 'st@stahl-control.de'
  end;

  // Mail definieren und versenden
  vHdl # Mailopen(_MailSmtp, vSMTP, vSMTPPort,0, vSMTPAcc, vSMTPPW);
  MailData(vHdl, _SmtpFrom, vSendEMA, vSendName);
  MailData(vHdl, _SmtpTo  , vRecEMA,  vRecNAme);
  MailData(vHdl, _SmtpSubject,'NSH LFS '+CnvAI(aLfs));
  MailData(vHdl,_MailLine,'automatisch aus Stahl-Control');
  MailData(vHDl,_MailFile|_MimeApp,aAttachment);
  RETURN MailClose(vHdl,_SmtpSendnow);

end;

***/
//========================================================================

