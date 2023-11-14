@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_Adr_BesuchsB
//                      OHNE E_R_G
//  Info
//    Formular: Adressen / Kundenakte
//
//  16.05.2013  TM  Erstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName (var aSprache : alpha; var aAdresse : int) : alpha;
//    sub SeitenKopf (aSeite : int);
//    sub PrintForm ();
//
//    MAIN (opt aFilename : alpha(4096))
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0     :  10.0   // Standardeinzug links
  cPos1     : cPos0 + 85.0
  cPos2     : cPos1 + 85.0
  cPosCR    : 190.0
  cPosPic   :  85.0   // Logoposition X

  cRTFName  : 'Besuchsbericht.rtf'
  cPfad     : '..\Vorlagen\'
end;

local begin
  vTopMargin          : float;
  vPos                : int;
end;

declare PrintMain(opt aFilename : alpha(4096))

//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName (var aSprache : alpha; var aAdresse : int) : alpha;
begin
  aSprache # ''
  aAdresse # Adr.V.AdressNr;

  RETURN CnvAI(Adr.V.Adressnr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8) + '/' + CnvAI(Adr.V.lfdNr, _fmtNumNoGroup | _fmtNumLeadZero, 0, 4);
end;


//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  Erx           : int;
  vName         : alpha(4000);
  vTxtName      : alpha(4000);
  vFile         : int;
  vMax          : int;
  vA            : alpha(4000);
  vTxtHdlTmpRTF : int;
  vTxtHdlName   : alpha(4000);
  vI            : int;
end;
begin

  case (aTyp) of

    'RTF' : begin

      vTxtHdlTmpRTF # TextOpen(160);    // RTFtextpuffer

      vTxtHdlName # '~TMP.ADR.' + UserInfo(_UserCurrent);

      // vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

      vName # cPfad + cRTFName;
      if(vName <> '') then begin

        vFile # FSIOpen(vName, _FsiStdRead|_FsiPure);
        if (vFile<=0) then begin
          Msg(99,'Datei nicht lesbar: '+vName,0,0,0);
          RETURN;
        end;

        vMax # FsiSize(vFile);
        vPos # FsiSeek(vFile);
        vI # 1;

        Erx # FSIRead(vFile,vA,250);
        //schreiben in puffer
        TextLineWrite(vTxtHdlTmpRTF,vI,vA,_TextLineInsert|_TextNoLineFeed);
        inc(vI);

        WHILE (Erx >0) DO BEGIN
          Erx # FSIRead(vFile,vA,250);
          TextLineWrite(vTxtHdlTmpRTF,vI,vA,_TextLineInsert|_TextNoLineFeed);
          inc(vI);
          //schreiben in puffer
        END;

        TxtWrite(vTxtHdlTmpRTF,vTxtHdlName, _TextUnlock);    // Temporären Text sichern
        FSIClose(vFile);

        if (TextInfo(vTxtHdlTmpRTF,_TextLines) > 0) then
          Lib_Print:Print_Textbaustein(vTxtHdlName,cPos0,cPosCR);

        TextClose(vTxtHdlTmpRTF);

        //TxtDelete(vTxtHdlName,0);
      end;

      // Beispiel - interner AuftragsposText
      // if (Auf.P.TextNr1 = 400) then // anderer Positionstext
      // vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      // if (Auf.P.TextNr1 = 0) and (Auf.P.TextNr2 != 0) then   // Standardtext
      //   vTxtName # '~837.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
      // if (Auf.P.TextNr1 = 401) then // Individuell
      //   vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      // if (vTxtName != '') then begin
      //   if (vTxtName <> vTxt) then begin
      //     Lib_Print:Print_Text(vTxtName,1,cPos2,cPos10+5.0);  // drucken
      //     vTxt # vTxtName;
      //     PL_PrintLine;
      //   end;
      // end;
      Lib_Print:Print_Text(vTxtName,1, cPos0);
    end;

  end; // case

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
local begin
end;
begin
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf (aSeite : int);
local begin
  vText : alpha;
end;
begin

  pls_FontName # 'Calibri';

  vText # StrAdj('SC-ADR'+ CnvAi(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),_strAll);
  lib_PrintLine:BarCode_C39('Code39N'+vText,cPos0,60.0,7.0);
  PL_PrintLine;

  if (aSeite=1) then begin // ERSTE SEITE: Ausführlicher Kopf
    pls_FontSize # 13;
    PL_Print(vText, cPos0);
    PL_PrintLine;

//    Lib_PrintLine:PrintPic(80.0,165.0,30.0,'*' + vPfad + 'Logo_.jpg');

    pls_FontAttr # _WinFontAttrBold|_WinFontAttrUnderLine;
    pls_FontSize # 26;
    PL_Print('Besuchsbericht', cPos0);
    PL_PrintLine;

    //Lib_PrintLine:PrintPic(0.0,50.0,26.0,'*bilder\Logo_TSCRBT.jpg');
    pls_FontAttr # _WinFontAttrNormal;
    pls_FontSize # 13;
    PL_PrintLine;
    // Lib_Print:Print_LinieEinzeln(cPos0, cPosCR);

    pls_FontAttr # _WinFontAttrBold;
    PL_Print('Firma:', cPos0);
    PL_Print('Datum:', cPos1);
    pls_FontAttr # _WinFontAttrNormal;
    PL_PrintLine;

    PL_Print(Adr.Anrede, cPos0);
    PL_Print(cnvAD(TODAY), cPos1);
    PL_PrintLine;

    PL_Print(Adr.Name, cPos0);
    pls_FontAttr # _WinFontAttrBold;
    PL_Print('Kundennummer:', cPos1);
    pls_FontAttr # _WinFontAttrNormal;
    PL_PrintLine;

    PL_Print(Adr.Zusatz, cPos0);
    PL_Print(cnvai(Adr.Kundennr,_FmtNumNoGroup), cPos1);
    PL_PrintLine;

    PL_Print("Adr.Straße", cPos0);
    pls_FontAttr # _WinFontAttrBold;
    PL_Print('Telefon:', cPos1);
    pls_FontAttr # _WinFontAttrNormal;
    PL_PrintLine;

    PL_Print(Adr.PLZ + ' ' + Adr.Ort, cPos0);
    PL_Print(Adr.Telefon1, cPos1);
    PL_PrintLine;

    pls_FontAttr # _WinFontAttrBold;
    PL_Print('Ansprechpartner:', cPos0);
    PL_Print('Telefax:', cPos1);
    pls_FontAttr # _WinFontAttrNormal;
    PL_PrintLine;

    PL_Print('_________________', cPos0);
    PL_Print(Adr.Telefax, cPos1);
    PL_PrintLine;

    Lib_Print:Print_LinieEinzeln(cPos0, cPosCR);

  end else begin // FOLGESEITEN: nur Kundennummer als Barcode
    pls_FontSize # 13;
//    vText # StrAdj('SC-ADR'+ CnvAi(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),_strAll);
//    lib_PrintLine:BarCode_C39('Code39N'+vText,cPos0,45.0,7.0);
//    PL_PrintLine;
    PL_Print(vText, cPos0);
    PL_PrintLine;
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(cPos0, cPosCR);

  end;

end;



//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx           : int;
  vPrintLine    : int;
end;
begin

  Erx # RecRead(100, 1, 0); // aktuelle Adr. lesen
  if(Erx > _rLocked) then
    RecBufClear(100);


  PL_Create(vPrintLine);

  if (  Lib_Print:FrmJobOpen(true, 0, 0, false, true, false) < 0) then begin
  if (vPrintline <> 0) then PL_Destroy(vPrintline);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  Form_RandOben  # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0));
  Form_RandUnten # cnvIF(rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0)));

  vTopMargin    # form_RandOben;

  Lib_Print:Print_Seitenkopf();

  print('RTF');

  Form_Mode # '';

  /* Druck beenden */
  Usr.Username # UserInfo(_userName, CnvIA(UserInfo(_userCurrent)));
  RecRead(800, 1, 0);
//  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  if (vPrintLine != 0) then
    PL_Destroy(vPrintLine);

end;

//=========================================================================
//=========================================================================