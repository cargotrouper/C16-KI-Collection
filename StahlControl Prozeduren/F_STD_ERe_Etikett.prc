@A+
//===== Business-Control =================================================
//
//  Prozedur    F_ERe_Adr_Etikett
//                            OHNE E_R_G
//  Info        Druckt ein Etikett zu einer Adresse
//
//
//  05.07.2011  MS  Aenderung auf ERe Barcode Etikett
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB NachGVAlphas(aInhalt1 : alpha; aZ : int);
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
  aAdr      # Adr.Nummer;
  aSprache  # '';
end;


//========================================================================
//  NachGVAlphas
//
//========================================================================
sub NachGVAlphas(
  aInhalt1  : alpha;
  aZ        : int);
begin
  FldDef(999, 1, aZ,aInhalt1);
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
end;
begin
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

  vMFile,vMID     : int;
  vItem           : handle;
  vPos            : int;
end;
begin


    // ------ Druck vorbereiten ----------------------------------------------------------------

    // Markierte Positionen in Selektion rein, um nach Position zu sortieren
    vItem # gMarkList->CteRead(_CteFirst);
    if(vItem > 0) then begin
      FOR vItem # gMarkList->CteRead(_CteFirst);
      LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
        if (vMFile = 560) then
          RecRead(560, 0, _RecId, vMID);

        GV.Alpha.01 # 'ER' + StrAdj(cnvAI(ERe.Nummer,_FmtNumNoGroup | _FmtNumNoZero),_StrAll);
        GV.Alpha.02 # 'Code39N' + GV.Alpha.01;

        if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_Etikett29x90', 'FALSE') < 0) then begin
          RETURN;
        end;

        Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
        form_RandOben   # 0.0;
        form_RandUnten  # 0;

        vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.ERe');
        Lib_Print:LfPrint(vPrt);
        // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
        Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
      END;
    end
    else begin
      if (Mode=c_ModeList) then
        RecRead(560, 0, _recLock, gZLList->wpdbrecid);

      GV.Alpha.01 # 'ER' + StrAdj(cnvAI(ERe.Nummer,_FmtNumNoGroup | _FmtNumNoZero),_StrAll);
      GV.Alpha.02 # 'Code39N' + GV.Alpha.01;

      if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_Etikett29x90', 'FALSE') < 0) then begin
        RETURN;
      end;

      Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
      form_RandOben   # 0.0;
      form_RandUnten  # 0;

      vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.ERe');
      Lib_Print:LfPrint(vPrt);
      //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
      Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
    end;
end;



//========================================================================