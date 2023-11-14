@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_SWe_Löschlst
//                        OHNE E_R_G
//  Info
//    Gibt eine Löschliste aus
//
//
//  28.05.2008  ST  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB Print(aTyp : alpha);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin

  cPosKopf1 : 10.0     // "LÖSCHLISTE"
  cPosKopf2 : 70.0     // Lieferant
  cPosKopf3 : 110.0    // Erzeuger
  cPosKopf4 : 150.0    // Ursprungsland
  cPosKopf5 : 180.0    // Seite


  /*
          Coilnr    Charge    Dicke   Stück   RID
                    Güte      Breite  Gewicht RAD     BC
      */

  cPosL   : 0.9
  cPos1   : cPosL   // Coilnummer
  cPos2   : 50.0    // Charge/Güte
  cPos3   : 80.0    // dicke/breite
  cPos4   : 110.0   // Stück
  cPos5   : 140.0   // rid rad
  cPos6   : 140.0   // Barcode

  cPosR  : 200.0       // Rechtes Ende der Liste

end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
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
begin
  aAdr      # 0;
  aSprache  # 'D';
  RETURN CnvAI(SWE.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  Print(aTyp : alpha)
//
//========================================================================
sub Print(aTyp : alpha);
local begin
  vText : alpha;
end;
begin

  case aTyp of

    'Coil' : begin
      /*
          Coilnr    Charge    Dicke   Stück   RID
                    Güte      Breite  Gewicht RAD     BC
      */
      PL_Drawbox(0.0, 210.0,_WinColblack, 0.25);
      pls_FontSize  # 5;
      Pl_Print(' ' ,cPos1);
      PL_PrintLine;

      pls_FontSize  # 9;
      Pl_Print('Coilnummer' ,cPos1);
      Pl_Print('Charge'     ,cPos2);
      Pl_Print('Dicke'      ,cPos3);
      Pl_Print('Stück'      ,cPos4);
      Pl_Print('RID'        ,cPos5);
      PL_PrintLine;


      pls_FontSize  # 16;
      Pl_Print(SWe.P.Coilnummer,                          cPos1);
      Pl_Print(SWe.P.Chargennummer,                       cPos2);
      Pl_Print(ANum(SWe.P.Dicke,Set.Stellen.Dicke),       cPos3);
      Pl_Print(AInt("SWe.P.Stückzahl"),                   cPos4);
      Pl_PrintF_L(SWe.P.RID, Set.Stellen.Radien,            cPos5);
      PL_PrintLine;

      pls_FontSize  # 8;
      Pl_Print(' ' ,cPos1);
      PL_PrintLine;

      pls_FontSize  # 8;
      Pl_Print('Güte'       ,cPos2);
      Pl_Print('Breite'     ,cPos3);
      Pl_Print('Gewicht'    ,cPos4);
      Pl_Print('RAD'        ,cPos5);
      PL_PrintLine;

      pls_FontSize  # 16;
      Pl_Print("SWe.P.Güte",                                cPos2);
      Pl_Print(ANum(SWe.P.Breite,Set.Stellen.Breite),       cPos3);
      Pl_Print(ANum(SWe.P.Gewicht,Set.Stellen.Gewicht),     cPos4);
      Pl_PrintF_L(SWe.P.RAD, Set.Stellen.Radien,            cPos5);
      PL_PrintLine;

      // SWE-Nummer als Barcode
      vText # 'SWE'+
              StrAdj(CnvAi(SWe.P.Nummer,_FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll) + '/' +
              StrAdj(CnvAi(SWe.P.Position,_FmtNumNoZero | _FmtNumNoGroup,0,8),_strAll);
      lib_PrintLine:BarCode_C39('Code39N'+vText,cPos6,45.0,7.0);

      pls_FontSize  # 21;
      Pl_Print(' ' ,cPos1);
      PL_PrintLine;
    end;

  end;

end


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vTxtName  : alpha;
  vText     : alpha(250);
  vText2    : alpha(250);
end;
begin

  Pls_FontSize # 10;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('LÖSCHLISTE ' + AInt(SWe.Nummer),cPosKopf1);
  PL_Print(SWe.LieferantenSW,cPosKopf2);
  if (RecLink(100,620,4,0) > _rLocked) then
    RecBufClear(100);
  PL_Print(Adr.Stichwort,cPosKopf3);
  PL_Print(SWe.Ursprungsland,cPosKopf4);
  PL_Print('Seite:'+AInt(aSeite),cPosKopf5);
  PL_PrintLine;
  Pls_FontSize # 0;

end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  vFirst              : logic;
  vText               : alpha(250);

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPL                 : int;
  vNummer             : int;        // Dokumentennummer
  vTxtHdl             : int;
  vVpg                : logic[100]; // Merker für Verpackungen
  i                   : int;        // für FOR-Schleife

  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vFlag2      : int;        // Datensatzlese option
  vSelName    : alpha;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------
  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,n,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Form_Doksprache # 'D';
  //form_RandOben # 0.0;      // Rand oben setzen
  Form_RandOben   # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0));
  Form_RandUnten # 0;      // Rand unten setzen
  Lib_Print:Print_Seitenkopf();

  vFlag # _RecFirst;
  WHILE (RecLink(621,620,1,vFlag) <= _rLocked) DO BEGIN
    if (SWe.P.AvisYN) then
      Print('Coil');

    vFlag # _RecNext;
  END;


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();
end;

//========================================================================