@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_DOK_Eti
//                          OHNE E_R_G
//  Info        Druckt ein Barcode-Etikett für DMS (wie ArcFlow) aus
//
//
//  04.12.2007  AI  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//
//  MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(0 ,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  vNummer     : int;        // Dokumentennummer

  vHdl        : int;        // Elementdescriptor

  vHeader     : int;
  vFooter     : int;

  vFlag       : int;        // Datensatzlese option
  vPrt        : int;        // Printelementdeskriptor

end;
begin
  // Header und Footer EINMALIG vorher laden
  vHeader # PrtFormOpen(_PrtTypePrintForm,'');
  vFooter # PrtFormOpen(_PrtTypePrintForm,'');

  // Job Öffnen + Page srstellen
//  Lib_Print:FrmJobOpen('tmp'+AInt(gUserID),vHeader , vFooter,
//    n,n,n,'Eti88x35');
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter, n,n,n,'Eti508x254') < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  form_RandOben   # 0.0;
  form_RandUnten  # 0;

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(form_Dokname);

  vPrt # PrtFormOpen(_PrtTypePrintForm, 'FRM.STD.Etikett.Dok2');
//  vHdl # vPrt->winsearch('tx.Text');
//  vHdl->wpCaption # GV.Alpha.02;
  vHdl # vPrt->winsearch('PrtBarcode0');
  vHdl->wpCaption # 'Code39N'+GV.Alpha.01;

  // Etikett drucken
  Lib_Print:LFPrint(vPrt);

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================