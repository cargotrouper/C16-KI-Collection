@A+
//@I:Var_Sys
@I:Com_Word.Define
@I:Def_Global

//******************************************************************
//*
//                    OHNE E_R_G
//* Dieses Prozedur beinhaltet Funktionen um Daten an Excel zu
//* senden, damit diese dort tabelarisch und in einem Diagramm
//* angezeigt werden.
//*
//*  TableTitle()
//*  TableLine()
//*
//******************************************************************

define begin
  sSpace                : StrChar(32)
  sTab                  : StrChar(9)
  sCR                   : StrChar(13)
  sLF                   : StrChar(10)
  sCRLF                 : sCR + sLF
end;

//*******************************************************************
//*
//* Farbigen Tabellen-Titel einfügen
//*
//*******************************************************************

sub TableTitle
begin
  com_Word:TabsClear();
  com_Word:Align(wdAlignParagraphCenter);
  com_Word:TableCellColorBkg(wdDarkBlue);
  com_Word:FontColorIndex(wdWhite);
  com_Word:TypeText('Pos');
  com_Word:MoveRight(wdCell);

  com_Word:TabsClear();
  com_Word:Align(wdAlignParagraphCenter);
  com_Word:TableCellColorBkg(wdDarkBlue);
  com_Word:FontColorIndex(wdWhite);
  com_Word:TypeText('Stück');
  com_Word:MoveRight(wdCell);

  com_Word:Align(wdAlignParagraphLeft);
  com_Word:TableCellColorBkg(wdDarkBlue);
  com_Word:FontColorIndex(wdWhite);
  com_Word:TypeText('Bezeichnung');
end;

//*****************************************************************
//*
//* Tabellen Zeile mit Seitenumbruch ausgeben
//*
//*****************************************************************

sub TableLine()

local begin
  tPageBefore : int;
  tPageAfter  : int;
end;
begin
  tPageBefore # com_Word:Information(wdActiveEndPageNumber);
  com_Word:MoveRight(wdCell);
  tPageAfter # com_Word:Information(wdActiveEndPageNumber);

  // Seitenumbruch stattgefunden ?
  if (tPageBefore <> tPageAfter) then TableTitle();

  com_Word:TableCellColorBkg(wdWhite);
  com_Word:FontColorIndex(wdBlack);
  com_Word:Align(wdAlignParagraphLeft);
  com_Word:TabsAdd(1.5,wdAlignTabDecimal);
  com_Word:TypeText(CnvAI(1234));
  com_Word:MoveRight(wdCell);

  com_Word:TableCellColorBkg(wdWhite);
  com_Word:FontColorIndex(wdBlack);
  com_Word:Align(wdAlignParagraphLeft);
  com_Word:TabsAdd(1.5,wdAlignTabDecimal);
  com_Word:TypeText(CnvAI(1234));
  com_Word:MoveRight(wdCell);

  com_Word:TableCellColorBkg(wdWhite);
  com_Word:FontColorIndex(wdBlack);
  com_Word:Align(wdAlignParagraphLeft);
  com_Word:TypeText('tralala',1);
  com_Word:FontSize(9);
  com_Word:TypeText('Artikel : AUP.aArtID');

  tPageAfter # com_Word:Information(wdActiveEndPageNumber);

  // Seitenumbruch stattgefunden ?
  if (tPageBefore != tPageAfter) then begin
    com_Word:MoveLeft(wdCell,2);
    com_Word:PageBreak();
    com_Word:MoveDown(wdLine);
    com_Word:MoveRight(wdCell);
    com_Word:MoveLeft(wdCell);
    TableTitle();
    TableLine();
  end;
end;


// ******************************************************************
// * main - Hauptprozedur                                           *
// ******************************************************************
MAIN
local begin
  tErg          : int;
  tPath         : alpha;
  tPicture      : alpha;
  tDocFile      : alpha;
  tHdl          : int;
  tHdlB         : int;

  vI            : int;
end;
begin
  // Abfrage ob Firmenlogo als externe Datei vorhanden ist
  // Wenn nicht, Firmenlogo aus der Datenbank exportieren
/*
  tPicture # App_Cmn:FilePathAdd(gFsiClientPath,sComWordLogoName);
  if (!App_Cmn:FileExists(tPicture))
    App_Cmn:ExportPic('Briefkopf',sComWordLogoName);

   // Prüfen ob Export des Firmenlogos erfolgreich
   if (!App_Cmn:FileExists(tPicture))
   {
     App_Cmn:MsgBox(sModeAuk,'Bild '+tPicture+' nicht vorhanden!',
             _WinIcoError, _WinDialogOk, 0);
     return;
   }
*/
  // Überprüfen, ob das Verzeichniss existiert
/*
  if (KFG.aABPath != '' and !App_Cmn:FileExists(KFG.aABPath, true))
  {
    App_Cmn:MsgBox(sModeAuk,'Das Verzeichnis '+KFG.aABPath+' ist nicht vorhanden!',
           _WinIcoError, _WinDialogOk, 0);
    return;
  }
*/
  // Ausgabepfad ermitteln
  tPath # 'c:\';

  // Dateiname mit Pfad für Word-Dokument setzen
  tDocFile # tPath+'xxx.doc';
  tPicture # 'z:\c16_clnt.47\bilder\bc.bmp';

  if (com_Word:CreateDoc(y)) then begin
    // Kopfzeile für erste Seite definieren
    com_Word:SetFirstHeader(2.54,1.0,10.0,tPicture);

    // Fußzeile für erste Seite definieren
    com_Word:FooterFirstBegin();
    com_Word:TypeText('agag'+ ' BLZ: 234234 Kto: 234234234 ', 1);
    com_Word:TypeText('Sitz: 234234, - sdfwfwf', 1);
    com_Word:TypeText('Tel: 13123123   FAX: 243234  eMail: wfwf');
    com_Word:FooterEnd();

    // Anschriftsfeld definieren
    com_Word:SetAddressBegin(2.54,4.7,8.7,4.0,
                            'aaaaa','bbbbb','ccccc');
    com_Word:TypeText('adafwef',2);
    com_Word:TypeText('KND.aStrasse',2);
    com_Word:TypeText('KND.aLkz++KND.aPlz++KND.aOrt',1);
    com_Word:SetAddressEnd();

    // Datum rechtsbündig setzen
    com_Word:FontName('Arial',11);
    com_Word:Align(wdAlignParagraphRight);
    com_Word:TypeText('KFG.aOrt' + ', den '+CnvAD(SysDate(),_FmtDateLongYear),1);
    com_Word:Align(wdAlignParagraphLeft);
    com_Word:TypeText('',2);

    // 2 Betreffzeilen
    com_Word:FontBold(true);
    com_Word:TypeText('Auftragsbestätigung/',1);
    com_Word:FontBold(true);
    com_Word:TypeText('Lieferschein Nr. '+CnvAI(4444),1);
    com_Word:TypeText('',2);

    // Tabelle definieren
    com_Word:TableBegin(2,3);

    // Breite der Tabellenspalten setzen
    com_Word:TableColumnWidth(1, 2.0);
    com_Word:TableColumnWidth(2, 2.0);
    com_Word:TableColumnWidth(3,12.0);

    // Titelzeile ausgeben
    TableTitle();

    // Auftragspositionen ausgeben REPEAT
    FOR vI # 1 loop inc(vI) while (vI < 99) do
      TableLine();

    // Tabelle abschließen
    com_Word:TableEnd();

    com_Word:TypeText(sCR+sCR+'Vielen Dank für Ihren Auftrag.',2);
    com_Word:TypeText('Mit freundlichen Grüßen',2);
    com_Word:FontName('Tahoma');
    com_Word:FontBold(true);
    com_Word:TypeText('KFG.aFirmenBez', 1);
    com_Word:FontBold(false);
    com_Word:FontName('Arial');
    com_Word:TypeText('Auftragsabwicklung');

    com_Word:VisibleSet(y);

    // Datei Sichern
//    com_Word:SaveAs(tDocFile,true);

    if (com_Word:IsOK()) then begin
      WinDialogBox(0,'', 'Gespeichert unter: "' + tPath + 'AB' + CnvAI(434) + '.doc"',
                      _WinIcoInformation, _WinDialogOK, 0);
    end;

    // Com Schließen
    com_Word:Close();
  end;
end;