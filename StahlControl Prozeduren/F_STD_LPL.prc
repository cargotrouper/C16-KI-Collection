@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_LPL
//                        OHNE E_R_G
//  Info
//    Druckt ein Formular Lagerplaetze mit Barcode
//
//
//  14.04.2008  MS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB MaterialDruck();
//    SUB DruckElePos(aName : alpha; aNr : int; aPos : int)
//    SUB DruckMePos(aName : alpha; aNr : float; aPos : int);
//    SUB HoleWert(aFeld : int) : float;
//    SUB HoleEmpfaenger();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_PrintLine
@I:Def_BAG

define begin
  ABBRUCH(a,b)    : begin TRANSBRK; Msg(a,CnvAI(b),0,0,0); RETURN false; end;
  ADD_VERP(a,b)   : begin if (vVerp <> '') then vVerp # vVerp + ', ' + a + StrAdj(b,_StrBegin | _StrEnd); else vVerp # vVerp + a + StrAdj(b,_StrBegin | _StrEnd); end;

  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   //
  cPos2   :  20.0   //
  cPos3   :  80.0   //
  cPos4   : 110.0   //
  cPos5   : 143.0   //
  cPos6   : 165.0   //
  cPos7   : 182.0   //
  cPos8   : 161.0   //
  cPos9   : 182.0   //


  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  cPosKopf3 : 35.0  // Feld Lieferanschrift

  cPosFuss1 : 10.0
  cPosFuss2 : 53.0  // Felder Lieferung, Warenempfänger,...
end;

local begin
  vZeilenZahl     : int;
  vCoord          : float;
  vSumStk         : int;
  vSumGewichtN    : float;
  vSumGewichtB    : float;
  vSumBreite      : float;
  vSumLaenge      : float;

  vCount          : int;
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
  aSprache  # '';
  //RETURN CnvAI(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
  RETURN Lpl.Lagerplatz; // Dokumentennummer
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
  Pls_fontSize # 23;
  pls_Fontattr # _WinFontAttrBold;
  PL_Print('Lagerplätze',cPos0);
  PL_PrintLine;
  PL_PrintLine;

  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
  end;
end;



//========================================================================
//  Print
//
//========================================================================
sub Print(aTyp : alpha);

local begin
vPos : int;
vX   : float;
vX2  : float;
end;

begin
case aTyp of
  'Lagerplatz' : begin
    Pls_FontSize # 12;
    PL_Print(Lpl.Lagerplatz,cPos3);
    if(vCount % 2 = 1) then
      Lib_PrintLine:BarCode_C39('Code39N' + StrCnv(Lpl.Lagerplatz, _StrUpper) , cPos1, 45.0, 15.0);
    else
      Lib_PrintLine:BarCode_C39('Code39N' + StrCnv(Lpl.Lagerplatz, _StrUpper) , cPos5, 45.0, 15.0);
    PL_PrintLine;
  end;
end; // case


end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx                 : int;
  // Datenspezifische Variablen
  vAdresse            : int;      // Nummer des Empfängers
  vAnschrift          : int;      // Anschrift des Empfängers
  vTxtName            : alpha;

  // Druckspezifische Variablen
  vHeader             : int;
  vFooter             : int;
  vPLHeader           : int;
  vPLFooter           : int;
  vPL                 : int;

  vFlag               : int;        // Datensatzlese option
  vTxtHdl             : int;
  vA                  : alpha;
end;
begin

  // ------ Druck vorbereiten ----------------------------------------------------------------
  // universelle PrintLine generieren
  PL_Create(vPL);

  // Job Öffnen + Page generieren
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter, false, false, false) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  form_randOben    # rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0));
  form_randUnten   # cnvIF(rnd(Lib_Einheiten:LaengenKonv('mm', 'LE', 10.0)));


  // ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();
  vAdresse    # Adr.Nummer;

  // ------- POSITION --------------------------------------------------------------------------
  vCount # 1;
  FOR Erx # RecRead(844, 1, _recFirst);
  LOOP Erx # RecRead(844, 1 ,_recNext);
  WHILE (Erx <= _rLocked ) DO BEGIN
    Print('Lagerplatz');
    PL_PrintLine;

    vCount # vCount + 1;
  END;

  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  PRINT('FUSS');


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;



//========================================================================