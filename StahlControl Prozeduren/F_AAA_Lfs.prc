@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_LFS
//                        OHNE E_R_G
//  Info
//    Druckt eineb LFS
//
//
//  20.11.2012  AI  Erstellung der Prozedur
//  04.07.2013  TM  ArcFlow DokumentenBarcode eingefügt - nur Seite 1
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB HoleEmpfaenger();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================
@I:Def_Global
@I:Def_Form
@I:Def_BAG

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elKopfText          : int;
  elFussText          : int;

  elUeberschrift      : int;

  elPosText             : int;

  elPosMat1           : int;
  elPosMat2           : int;

  elPosArt1           : int;
  elPosArt2           : int;

  elEnde              : int;
  elSumme             : int;
  elLeerzeile         : int;

  // Variablen
  gSpediAdr           : int;
  gStartAS            : int;
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
  vBuf100 : int;
end
begin
  vBuf100 # RekSave(100);
  RecLink(100,440,2,_recFirst);    // Zieladresse lesen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;
  RekRestore(vBuf100);
  RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  HoleEmpfaenger
//
//========================================================================
sub HoleEmpfaenger();
local begin
vflag   : int;
end;
begin
  // Daten aus Auftrag holen
  if (Scr.B.2.FixID1=0) then begin

    if (Scr.B.2.anKuLfYN) then RETURN;

    if (Scr.B.2.anPartnerYN) and (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      RecLink(100,440,2,_recFirst);  // Lieferadr. holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      RecLink(101,440,3,_recFirst);   // Lieferanschrift holen
      form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then RETURN;

    end // Daten aus Auf.

  else begin  // FIXE DATEN !!!

    if (Scr.B.2.anKuLfYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Kunde/Lieferant holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anPartnerYN) then begin
     RETURN;
    end;

    if (Scr.B.2.anLiefAdrYN) then begin
      // fixe Adresse testen...
      if (RecLink(100,921,1,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(100,921,1,_recFirst);   // Lieferort holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anLiefAnsYN) then begin
      // fixe Adresse testen...
      if (RecLink(101,921,2,_recFirst | _RecTest)>_rLocked) then RETURN;
      RecLink(101,921,2,_recfirst);   // Anschrift holen
      RecLink(100,101,1,_recFirsT);   // Lieferadresse holen
      RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
      Adr.A.Telefon   # Adr.P.Telefon;
      Adr.A.Telefax   # Adr.P.Telefax;
      Adr.A.eMail     # Adr.P.eMail;
      Form_FaxNummer  # Adr.A.Telefax;
      Form_EMA        # Adr.A.EMail;
      RETURN;
    end;

    if (Scr.B.2.anVerbrauYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anReEmpfYN) then begin
       RETURN;
    end;

    if (Scr.B.2.anVertretYN) then begin
        RETURN;
    end;

    if (Scr.B.2.anVerbandYN) then begin
      RETURN;
    end;

    if (Scr.B.2.anLagerortYN) then begin;
      RETURN;
    end;

  end;

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vBarc : alpha;
end;
begin

  // SCRIPTLOGIK
  if (Scr.B.Nummer<>0) then HoleEmpfaenger();

  // ERSTE SEITE??
  if (aSeite=1) then begin
    form_Ele_Lfs:elErsteSeite(var elErsteSeite, gSpediAdr, gStartAS);
//    form_Elemente:elKopfText(var elKopfText,'~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8));
    end
  else begin
    form_Ele_Lfs:elFolgeSeite(var elFolgeSeite, gSpediAdr, gStartAS);
  end;


  if (Form_Mode='POS') then begin
    form_Ele_Lfs:elUeberschrift(var elUeberschrift);
  end;

  // ArcFlow DokumentenBarcode auf erster Seite
  if (aSeite =1) then begin
    vBarc # 'Code39NSC-LFSA' + CnvAI(Lfs.Nummer,_FmtNumLeadZero|_FmtNumNoGroup,0,8);
    Lib_PrintLine:Barcode_C39Absolut(vBarc,129.0,60.0,70.0,81.0);
  end;

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
  vTxtName      : alpha;
  vTxtNameLast  : alpha;
  vPosCount     : int;
  vGesamtStk    : int;
  vGesamtGewN   : float;
  vGesamtGewB   : float;
  vGesamtM      : float;
  vGesamtMEH    : alpha;
end;
begin

  Erx # RekLink(101,440,3,_recFirst);       // Lieferanschrift holen
  Erx # RekLink(812,101,2,_recFirst);       // Land holen
  if ("Lnd.kürzel"='D') or ("Lnd.kürzel"='DE') then RecbufClear(812);

  Erx # RekLink(100,440,1,_recFirst);       // Kunde lesen
  if (Lfs.Spediteurnr<>0) then begin
    if (Lfs.Spediteurnr<>Adr.A.Adressnr) and (Lfs.Spediteurnr<>Adr.Nummer) then begin
      gSpediAdr # RecBufCreate(100);
      Erx # RekLink(gSpediAdr,440,6,_recFirst); // Spediteur lesen
    end;
  end;
  Erx # RekLink(441,440,4,_RecFirst);         // Erste Position lesen, um an die MEH zu kommen
  Erx # RekLink(441,440,4,_RecFirst);         // Erste Position lesen, um an die MEH zu kommen

  // Material --------------------------------------------------------------------
  if (Lfs.P.Materialtyp = c_IO_VSB) or (Lfs.P.Materialtyp = c_IO_MAT) then begin

    // Materialkarte lesen
    Mat_Data:Read(Lfs.P.Materialnr);      // Material holen
    RekLink(819,200,1,_recFirst);         // Warengruppe holen
    RecbufClear(250);
    RecbufClear(252);
    Erx # RekLinkB(gStartAS,200, 6, _recfirst); // Lageraschrift holen

    end // Material
  else if (Lfs.P.Materialtyp = c_IO_Art) then begin
  // Artikel ---------------------------------------------------------------------

    Erx # RekLink(250,441,3,_RecFirst);   // Artikel holen
    RekLink(819,250,10,_recFirst);        // Warengruppe holen
    RecbufClear(200);
    RekLink(252,441,14,_recFirst);        // Artikelcharge holen

    Erx # RekLinkB(gStartAS,252, 3, _recfirst); // Lageraschrift holen

  end;  // Artikel


  RecBufClear(700);
  RecBufClear(702);
  if (Lfs.ZuBA.Nummer<>0) then begin
    Erx # RekLink(702,440,7,_recFirst);     // BA-Position holen
  end;

  Usr.Username # Lfs.Anlage.User;
  Erx # RecRead(800, 1, 0); // Benutzer holen
  if (Erx > _rLocked) then RecBufClear(800);


  if (Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
      RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  form_Elemente:elSeitenFuss(var elSeitenFuss, false);

// ------- KOPFDATEN -----------------------------------------------------------------------
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;
  Lib_Print:Print_Seitenkopf();

// ------- POSITIONEN --------------------------------------------------------------------------
  form_Ele_Lfs:elUeberschrift(var elUeberschrift);
  Form_Mode # 'POS';


  FOR Erx # RekLink(441,440,4,_RecFirst)
  LOOP Erx # RekLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin


    RekLink(818,441,2,_recFirst);           // Verwiegungsart holen
    RecbufClear(400);
    RecbufClear(401);
    if (Lfs.P.Auftragsnr<>0) then begin     // ggf. Auftrag holen
      Auf_Data:Read(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, y);
    end;

    // Position ok und ausgeben.....
    Inc(vPosCount);


    // Positionstext ausgeben
/*
    vTxtName # '';
    if (Auf.P.TextNr1=400) then // anderer Positionstext
      vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (Auf.P.TextNr1=0) and (Auf.P.TextNr2 != 0) then   // Standardtext
      vTxtName # '~837.'+CnvAI(Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
    if (Auf.P.TextNr1=401) then // Individuell
      vTxtName # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    if (vTxtName != '') and (vTxtNameLast<>vTxtName) then begin
      form_Elemente:elPosText(var elPosText, vTxtName);
      vTxtNameLast # vTxtName;
    end;
*/


    // Material --------------------------------------------------------------------
    if (Lfs.P.Materialtyp = c_IO_VSB) or (Lfs.P.Materialtyp = c_IO_MAT) then begin

      // Materialkarte lesen
      Mat_Data:Read(Lfs.P.Materialnr);      // Material holen
      RekLink(819,200,1,_recFirst);         // Warengruppe holen
      RecbufClear(250);
      RecbufClear(252);

      form_Ele_Lfs:elPosMat1(var elPosMat1);
      vGesamtStk  # vGesamtStk   + "Lfs.P.Stück";
      vGesamtGewN # vGesamtGewN + "Lfs.P.Gewicht.Netto";
      vGesamtGewB # vGesamtGewB + "Lfs.P.Gewicht.Brutto"
      if (vGesamtMEH='') then vGesamtMEH # Lfs.P.MEH;
      if (vGesamtMEH=Lfs.P.MEH) then
        vGesamtM  # vGesamtM + Lfs.P.Menge;
      form_Ele_Lfs:elPosMat2(var elPosMat2);

      end // Material
    else if (Lfs.P.Materialtyp = c_IO_Art) then begin
    // Artikel ---------------------------------------------------------------------

      Erx # RekLink(250,441,3,_RecFirst);   // Artikel holen
      RekLink(819,250,10,_recFirst);        // Warengruppe holen
      RecbufClear(200);
      RekLink(252,441,14,_recFirst);        // Artikelcharge holen

      form_Ele_Lfs:elPosArt1(var elPosArt1);
      vGesamtStk  # vGesamtStk   + "Lfs.P.Stück";
      vGesamtGewN # vGesamtGewN + "Lfs.P.Gewicht.Netto";
      vGesamtGewB # vGesamtGewB + "Lfs.P.Gewicht.Brutto"
      if (vGesamtMEH='') then vGesamtMEH # Lfs.P.MEH;
      if (vGesamtMEH=Lfs.P.MEH) then
        vGesamtM  # vGesamtM + Lfs.P.Menge;
      form_Ele_Lfs:elPosArt2(var elPosArt2);

    end;  // Artikel

    // Leerzeile zwischen den Positionen
    form_Elemente:elLeerzeile(var elLeerzeile);

  END; // WHILE: Positionen ************************************************

  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  // Summe vorbelegen
  "Lfs.P.Stück"         # vGesamtStk;
  Lfs.P.Gewicht.Netto   # vGesamtGewN;
  Lfs.P.Gewicht.Brutto  # vGesamtGewB;
  Lfs.P.MEH             # vGesamtMEH;
  Lfs.P.Menge           # vGesamtM;
  Lfs.P.Position        # vPosCOunt;
  form_Ele_Lfs:elSumme(var elSumme);

//  form_Elemente:elFussText(var elFussText,'~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8));
  form_Elemente:elFussText(var elFussText, '~440.'+CnvAI(LFs.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001');

  form_Ele_Lfs:elEnde(var elEnde, gSpediAdr, gStartAS);

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (gSpediAdr<>0) then RecBufDestroy(gSpediAdr);
  if (gStartAS<>0) then RecBufDestroy(gStartAS);

  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );
  FreeElement(var elSeitenFuss        );

  FreeElement(var elKopfText          );
  FreeElement(var elFussText          );

  FreeElement(var elUeberschrift      );

  FreeElement(var elPosText           );

  FreeElement(var elPosMat1           );
  FreeElement(var elPosMat2           );

  FreeElement(var elPosArt1           );
  FreeElement(var elPosArt2           );

  FreeElement(var elSumme             );
  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile           );
end;


//=======================================================================