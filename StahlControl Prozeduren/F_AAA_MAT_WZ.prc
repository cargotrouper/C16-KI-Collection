@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_MAT_WZ
//                    OHNE E_R_G
//  Info
//    Druckt ein Materialzeugnis
//
//
//  08.11.2012  AI  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_Form

define begin
//  cPrint    : F_AAA
//  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
end;

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elTabelle1US        : int;
  elTabelle2US        : int;
  elTabelle1          : int;
  elTabelle2          : int;

  elEnde              : int;
  elLeerzeile         : int;
end;


//========================================================================
//========================================================================
sub CopyAnalyse(
  var aWert1Von : float;
  var aWert1Bis : float;
  aWert2Von     : float;
  aWert2Bis     : float;
  aWert3Von     : float;
  aWert3Bis     : float);
begin

  if (aWert3Von<>0.0) or (aWert3Bis<>0.0) then begin
    aWert1Von # aWert3Von;
    aWert1Bis # aWert3Bis;
    RETURN;
  end;
  if (aWert2Von<>0.0) or (aWert2Bis<>0.0) then begin
    aWert1Von # aWert2Von;
    aWert1Bis # aWert2Bis;
    RETURN;
  end;

end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
local begin
  Erx       : int;
  vBuf100   : int;
end;
begin
  vBuf100 # RekSave(100);
  Erx # RecLink(401,200,16,_recFirst);    // Auftragspos. holen
  if (Erx>_rLocked) then begin
    aAdr      # 0;
    aSprache  # '';
    end
  else begin
    RecLink(400,401,3,_recFirst);         // Auftragskopf holen
    RecLink(100,401,4,_recFirst);         // Kunde holen
    aAdr      # Adr.Nummer;
    aSprache  # Auf.Sprache;
  end;

  RekRestore(vBuf100);
  RETURN CnvAI(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin

//Mat->Auf.Pos -> ggf.Kopf + Kunde
//  RecLink(401,200,16,_recFirst); // Auf.Pos holen
//  RecLink(100,401,4,_recFirst);  // Kunde holen
//  RecLink(400,401,3,_recFirst);  // Kopf holen
//  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
//  form_FaxNummer  # Adr.A.Telefax;
//  Form_EMA        # Adr.A.EMail;


  // ERSTE SEITE??
  if (aSeite=1) then begin
    Form_Ele_Mat:elMatWZErsteSeite(var elErsteSeite);
  end;
//  else begin
//    Form_Ele_Mat:elMatWZFolgeSeite(var elFolgeSeite);
//  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  // Datenspezifische Variablen
  vAnschrift          : int;      // Anschrift des Empfängers
  vTxtName            : alpha;

  vTxtHdl             : int;
  vA                  : alpha;
  vCount              : int;
  vItem               : int;
end;
begin

  if (gFormParaHdl=0) then RETURN;

  // ------ Druck vorbereiten ----------------------------------------------------------------

  // Job Öffnen + Page generieren
  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  Form_Elemente:elSeitenFuss(var elSeitenFuss, false);

  FOR vItem # CteRead(gFormParaHdl,_ctefirst)
  LOOP vItem # CteRead(gFormParaHdl,_ctenext, vItem)
  WHILE (vItem<>0) do begin

    RecBufClear(400);
    RecBufClear(401);
    RecbufClear(100);
    RecbufClear(101);
    RecbufClear(812);

    // Material holen
    Mat_Data:Read(vItem->spId);

    if (Strcut(vItem->spname,1,3)='LFS') then begin
      Lfs.Nummer      # cnvia(Str_Token(vItem->spname,'|',2));
      Erx # RecRead(440,1,0);
      if (Erx>_rlocked) then CYCLE;
      Lfs.P.Nummer    # Lfs.Nummer;
      Lfs.P.Position  # cnvia(Str_Token(vItem->spname,'|',3));
      Erx # RecRead(441,1,0);
      if (Erx>_rlocked) then CYCLE;
      Mat.Bestand.Stk     # Cnvia(Str_Token(vItem->spcustom,'|',1));
      Mat.Bestand.Gew     # Cnvfa(Str_Token(vItem->spcustom,'|',2));
      Mat.Gewicht.Netto   # Cnvfa(Str_Token(vItem->spcustom,'|',3));
      Mat.Gewicht.Brutto  # Cnvfa(Str_Token(vItem->spcustom,'|',4));
      end
    else begin
      RecBufClear(440);
      RecBufClear(441);
    end;


    // DIN holen
    MQu_data:Read("Mat.Güte", "Mat.Gütenstufe",true, Mat.Dicke);


    // Auftrag holen
    If (Mat.Auftragsnr<>0) then begin
      if (Auf_Data:Read(Mat.Auftragsnr, Mat.Auftragspos, y)>=400) then begin
        Erx # RekLink(100,400,1,_recFirst);       // Kunde holen
        Erx # RekLink(101,100,12,_recFirst);      // Hauptanschrift holen
        Erx # RekLink(812,101,2,_recFirst);       // Land holen
        if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then
          RecbufClear(812);
        form_FaxNummer  # Adr.A.Telefax;
        Form_EMA        # Adr.A.EMail;
      end;
    end;


    // ------- KOPFDATEN -----------------------------------------------------------------------
    inc(vCount);
    if (vCount>1) then begin
      Lib_Print:Print_FF();
      Form_Ele_Mat:elMatWZErsteSeite(var elErsteSeite);
      end
    else begin
      Lib_Print:Print_Seitenkopf();
    end;


    // ------- POSITION --------------------------------------------------------------------------
    if (Mat.Analysenummer <> 0) then begin
      Erx # RecLink(230,200, 21, _RecFirst);    // Analysekopf holen
      if (Erx<=_rLocked) then begin
        Erx # RecLink(231,230, 1,_RecLast)      // letzte Messung holen
        if (Erx>_rLocked) then begin
          RecBufClear(230)
          RecBufClear(231)
        end;
        end
      else begin
        RecBufClear(230)
        RecBufClear(231)
      end;
      end
    else begin
      RecBufClear(230)
      RecBufClear(231)
    end;


    CopyAnalyse(var Mat.Streckgrenze1,  var Mat.Streckgrenze2,    Lys.Streckgrenze,   Lys.Streckgrenze2,  Mat.Streckgrenze2,  Mat.StreckgrenzeB2);
    CopyAnalyse(var Mat.Zugfestigkeit1, var Mat.Zugfestigkeit2,   Lys.Zugfestigkeit,  Lys.Zugfestigkeit2, Mat.Zugfestigkeit2, Mat.ZugfestigkeitB2);
    CopyAnalyse(var Mat.DehnungA1,      var Mat.DehnungC1,        Lys.DehnungA,       Lys.DehnungB,       Mat.DehnungA2,      Mat.DehnungB2);
    CopyAnalyse(var Mat.RP02_V1,        var Mat.RP02_B1,          Lys.RP02_1,         Lys.RP02_2,         Mat.RP02_V2,        Mat.RP02_B2);
    CopyAnalyse(var Mat.RP10_V1,        var Mat.RP10_B1,          Lys.RP10_1,         Lys.RP10_2,         Mat.RP10_V2,        Mat.RP10_B2);
    CopyAnalyse(var "Mat.Körnung1",     var "Mat.KörnungB1",      "Lys.körnung",      "Lys.Körnung2",     "Mat.Körnung2",     "Mat.KörnungB2");
    CopyAnalyse(var "Mat.HärteA1",      var "Mat.HärteB1",        "Lys.Härte1",       "Lys.Härte2",       "Mat.HärteA2",      "Mat.HärteB2");

    CopyAnalyse(var Mat.Chemie.C1,      var Mat.Chemie.C1,        Lys.Chemie.C,       Lys.Chemie.C,       Mat.Chemie.C2,      Mat.Chemie.C2);
    CopyAnalyse(var Mat.Chemie.Si1,     var Mat.Chemie.Si1,       Lys.Chemie.Si,      Lys.Chemie.Si,      Mat.Chemie.Si2,     Mat.Chemie.Si2);
    CopyAnalyse(var Mat.Chemie.Mn1,     var Mat.Chemie.Mn1,       Lys.Chemie.Mn,      Lys.Chemie.Mn,      Mat.Chemie.Mn2,     Mat.Chemie.Mn2);
    CopyAnalyse(var Mat.Chemie.P1,      var Mat.Chemie.P1,        Lys.Chemie.P,       Lys.Chemie.P,       Mat.Chemie.P2,      Mat.Chemie.P2);

    CopyAnalyse(var Mat.Chemie.S1,      var Mat.Chemie.S1,        Lys.Chemie.S,       Lys.Chemie.S,       Mat.Chemie.S2,      Mat.Chemie.S2);
    CopyAnalyse(var Mat.Chemie.Al1,     var Mat.Chemie.Al1,       Lys.Chemie.Al,      Lys.Chemie.Al,      Mat.Chemie.Al2,     Mat.Chemie.Al2);
    CopyAnalyse(var Mat.Chemie.Cr1,     var Mat.Chemie.Cr1,       Lys.Chemie.Cr,      Lys.Chemie.Cr,      Mat.Chemie.Cr2,     Mat.Chemie.Cr2);
    CopyAnalyse(var Mat.Chemie.V1,      var Mat.Chemie.V1,        Lys.Chemie.V,       Lys.Chemie.V,       Mat.Chemie.V2,      Mat.Chemie.V2);

    CopyAnalyse(var Mat.Chemie.Nb1,     var Mat.Chemie.Nb1,       Lys.Chemie.Nb,      Lys.Chemie.Nb,      Mat.Chemie.Nb2,     Mat.Chemie.Nb2);
    CopyAnalyse(var Mat.Chemie.Ti1,     var Mat.Chemie.Ti1,       Lys.Chemie.Ti,      Lys.Chemie.Ti,      Mat.Chemie.Ti2,     Mat.Chemie.Ti2);
    CopyAnalyse(var Mat.Chemie.N1,      var Mat.Chemie.N1,        Lys.Chemie.N,       Lys.Chemie.N,       Mat.Chemie.N2,      Mat.Chemie.N2);
    CopyAnalyse(var Mat.Chemie.Cu1,     var Mat.Chemie.Cu1,       Lys.Chemie.Cu,      Lys.Chemie.Cu,      Mat.Chemie.Cu2,     Mat.Chemie.Cu2);

    CopyAnalyse(var Mat.Chemie.Ni1,     var Mat.Chemie.Ni1,       Lys.Chemie.Ni,      Lys.Chemie.Ni,      Mat.Chemie.Ni2,     Mat.Chemie.Ni2);
    CopyAnalyse(var Mat.Chemie.Mo1,     var Mat.Chemie.Mo1,       Lys.Chemie.Mo,      Lys.Chemie.Mo,      Mat.Chemie.Mo2,     Mat.Chemie.Mo2);
    CopyAnalyse(var Mat.Chemie.B1,      var Mat.Chemie.B1,        Lys.Chemie.B,       Lys.Chemie.B,       Mat.Chemie.B2,      Mat.Chemie.B2);
    CopyAnalyse(var Mat.Chemie.Frei1.1, var Mat.Chemie.Frei1.1,   Lys.Chemie.Frei1,   Lys.Chemie.Frei1,   Mat.Chemie.Frei1.2, Mat.Chemie.Frei1.2);

    Form_Ele_Mat:elMatWZTabelleUS(var elTabelle1US, 'Tab1');
    Form_Ele_Mat:elMatWZTabelle(var elTabelle1, 'Tab1', 'SPALTE6');

    Form_Ele_Mat:elMatWZTabelleUS(var elTabelle2US, 'Tab2');
    Form_Ele_Mat:elMatWZTabelle(var elTabelle2, 'Tab2', 'SPALTE6');


    // ------- FUßDATEN --------------------------------------------------------------------------
    Form_Mode # 'FUSS';

    Form_Ele_Mat:elMatWZEnde(var elEnde);

  // -------- Druck beenden ----------------------------------------------------------------

    // Objekte entladen
    FreeElement(var elErsteSeite        );
    FreeElement(var elFolgeSeite        );

    FreeElement(var elTabelle1US        );
    FreeElement(var elTabelle2US        );
    FreeElement(var elTabelle1          );
    FreeElement(var elTabelle2          );

    FreeElement(var elEnde              );

  END;  // nächste Karte

  FreeElement(var elLeerzeile         );
  FreeElement(var elSeitenFuss        );

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

end;



//========================================================================