@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Lpl_Eti
//                    OHNE E_R_G
//  Info        Druckt ein Barcode-Etikett Lagerplaetze aus
//
//
//  17.04.2008  MS  Aenderung auf Lagerplatz
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//
//    MAIN (opt aFilename : alpha(4096))
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
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  // Datenspezifische Variablen
  vErg,i          : int;
  vHdl            : int;       // Descriptor für Textfelder d. Ausgabe Elementes
  vPrt            : int;        // Descriptor für Ausgabe Elemende
  vHeader         : int;
  vFooter         : int;
  vAnzahl         : int;
  vID             : int;
end;
begin


// ------ Druck vorbereiten ----------------------------------------------------------------
  if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_EtikettA5querAufA4Hoch') < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  form_RandOben   # 0.0;
  form_RandUnten  # 0;

  RecRead(844,1,0);

  GV.Alpha.01 # 'Code39N'+StrCnv(Lpl.Lagerplatz,_StrUpper);

  vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.Lagerplatz');
  Lib_Print:LfPrint(vPrt);

  //Lib_Print:FrmJobClose(true)
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

end;



//========================================================================