@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_PRJ_StkLst
//                      OHNE E_R_G
//  Info
//
//
//  07.04.2003  FR  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global

//========================================================================
//  GetDokName
//
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(Prj.SL.Nummer ,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx         : int;
  vNummer     : int;        // Dokumentennummer
  vHdl        : int;        // Elementdescriptor

  vHeader     : int;
  vFooter     : int;

  vFlag       : int;        // Datensatzlese option
  vPrt        : int;        // Printelementdeskriptor

  vLfn        : int;
end;
begin
  // Kein Betreff drucken, sicherheitshalber Gv.A.20 leeren
  Gv.Alpha.20 # '';
  // Header und Footer EINMALIG vorher laden
  vHeader # PrtFormOpen(_PrtTypePrintForm,'FRM.PRJ.MitBild.Kopf');
  vFooter # PrtFormOpen(_PrtTypePrintForm,'');

  // Kein Betreff drucken, sicherheitshalber Gv.A.20 leeren
  Gv.Alpha.20 # '';
  // Job Öffnen + Page srstellen
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,y) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(form_Dokname);

  // Adresse lesen
  RecLink(100,120,1,_RecFirst);

  // Seitenkopf drucken
  Lib_Print:Print_Seitenkopf(vHeader);

  vLfn # 1;

  // Positionen drucken
  Erx # RecLink(121,120,3,_RecFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN

    vPrt # PrtFormOpen(_PrtTypePrintForm,'FRM.PRJ.MitBild.Pos');

    // Laufende Nummer eintragen
    vHdl # PrtSearch(vPrt,'PrtLfn');
    vHdl->wpCaption # Prj.SL.Referenznr;

    // Skizze holen
    Erx # RecLink(829,121,4,_RecFirst);

    if (Erx <= _rLocked) then begin
      vHdl # PrtSearch(vPrt,'PrtSkizze');
      vHdl->wpCaption # '*' + Skz.Dateiname;
    end;

    // Gesamtlänge berechnen
    vHdl # PrtSearch(vPrt,'PrtGesamtlänge');
    vHdl->wpCaption # CnvAF(CnvFI("Prj.SL.Stückzahl") * "Prj.SL.Länge");

    // Durchmesser aus Artikeldatei lesen

    Erx # RecLink(250,121,2,_RecFirst);

    if (Erx <= _rLocked) then begin
      vHdl # PrtSearch(vPrt,'PrtDurchmesser');
      vHdl->wpCaption # CnvAF(Art.Aussendmesser);
    end;

    Lib_Print:LfPrint(vPrt);

    vLfn # vLfn + 1;
    Erx # RecLink(121,120,3,_RecNext);
  END;

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================