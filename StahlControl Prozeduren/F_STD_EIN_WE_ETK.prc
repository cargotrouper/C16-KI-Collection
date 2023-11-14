@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_EIN_WE_ETK
//                          OHNE E_R_G
//  Info
//    Druckt ein Eingangsetikett
//
//
//  02.09.2004  ST Erstellung der Prozedur
//  03.11.2004  ST Lesen der Projektnummer hinzugefügt
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
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
  RETURN CnvAI(Ein.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
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
  // Datenspezifische Variablen
  vErg,i            : int;
  vHdl            : int;       // Descriptor für Textfelder d. Ausgabe Elementes
  vPrt            : int;        // Descriptor für Ausgabe Elemende
  vHeader         : int;
  vFooter         : int;
  vNummer         : int;
  vMenge          : int;
  vAnzahl         : int;
  vBuf200         : int;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------


  // Mengenabfrage
  RecBufClear(999);
  vBuf200 # RekSave(200);
  Dlg_Standard:Anzahl('Menge',var vMenge);
  RekRestore(vBuf200);


  // Etikettenanzahlabfrage
  RecRead(912,1,0);         // Formulare lesen
                            // Anzahl = Anzahl der Kopien
  RecBufClear(999);
  vBuf200 # RekSave(200);
  Dlg_Standard:Anzahl('Anzahl Etk',var vAnzahl,Frm.Kopien);
  RekRestore(vBuf200);


  // Eingegbene Menge wieder an ETK übergeben
  Gv.Int.01 # vMenge;

  // Artikel lesen
  Art.Nummer # Ein.E.Artikelnr;
  RecRead(250,1,0);

  // Projekt lesen
  If (Ein.P.Projektnummer <> 0) then begin
    Prj.Nummer # Ein.P.Projektnummer;
    RecRead(120,1,0);
  end else
    RecBufClear(120);

  // Start des Druckecs
  for i # 0 loop inc(i) while(i < vAnzahl) do begin

    vNummer # 0;
    if (Lib_Print:FrmJobOpen(y,vHeader , vFooter, y,y,y,_PrtDocDinA5) < 0) then begin
      RETURN;
    end;

    Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

    vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.FGM.EingangsEtk');
    Lib_Print:LfPrint(vPrt);

    //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
    Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  end;


end;


//========================================================================