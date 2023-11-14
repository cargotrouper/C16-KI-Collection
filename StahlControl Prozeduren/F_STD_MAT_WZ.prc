@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_MAT_WZ
//                    OHNE E_R_G
//  Info
//    Druckt ein Materialzeugnis
//
//
//  22.10.2007  AI  Erstellung der Prozedur
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

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0   // Bez.
  cPos2a  :  50.0   // Werte
  cPos2b  :  77.0
  cPos2c  :  70.0   // Dimensions Toleranzen
  cPos2d  :  80.0
  cPos2f  :  55.0   //Stückzahl
  cPos2g  :  60.0
  cPos3   :  90.0   // Menge1
  cPos3a  :  90.0
  cPos3b  :  92.0
  cPos3c  : 105.0
  cPos4   : 110.0   // Menge2
  cPos4a  : 110.0
  cPos4b  : 112.0
  cPos5   : 143.0   // Einzelpreis
  cPos5a  : 130.0
  cPos5b  : 143.0
  cPos5c  : 144.0
  cPos6   : 165.0   // Rabatt
  cPos7   : 182.0   // Gesamt

  cPos8   : 161.0   // Gesamt
  cPos9   : 182.0   // Gesamt

  //Material
  cPosM1  : 10.0
  cPosM1a : cPosM1  + 40.0
  cPosM2  : cPosM1a + 20.0
  cPosM2a : cPosM2  + 30.0
  cPosM3  : cPosM2a + 30.0
  cPosM3a : cPosM3  + 40.0

  //Chemie
  cPosC1  : 10.0            // 10
  cPosC1a : cPosC1  + 20.0  // 30
  cPosC2  : cPosC1a + 20.0  // 50
  cPosC2a : cPosC2  + 20.0  // 70
  cPosC3  : cPosC2a + 20.0  // 90
  cPosC3a : cPosC3  + 20.0  //110
  cPosC4  : cPosC3a + 20.0  //130
  cPosC4a : cPosC4  + 20.0  //150

  //Mechanisch
  cPosMe1  : 10.0
  cPosMe1a : cPosMe1  + 40.0
  cPosMe1b : cPosMe1a +  1.0
  cPosMe1c : cPosMe1b + 10.0
  cPosMe2  : cPosMe1b + 30.0
  cPosMe2a : cPosMe2  + 40.0
  cPosMe2b : cPosMe2a  + 1.0

  cPoMe3   : cPosMe2a + 20.0
  cPosMe3a : cPosMe3  + 20.0
  cPosMe4  : cPosMe3a + 20.0
  cPosMe4a : cPosMe4  + 20.0


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
  vZeile          : int;
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
  Erx     : int;
  vBuf100 : int;
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
  RecLink(401,200,16,_recFirst); // Auf.Pos holen
  RecLink(100,401,4,_recFirst);  // Kunde holen
  RecLink(400,401,3,_recFirst);  // Kopf holen

  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;

  vBesteller # '';
  if ((Auf.Best.Bearbeiter <> '') AND (StrLen(Auf.Best.Bearbeiter) > 4)) then begin
    if (StrCut(Auf.Best.Bearbeiter,1,1) = '#') then begin
      vBesteller # StrCut(Auf.Best.Bearbeiter,4,StrLen(Auf.Best.Bearbeiter)-4);
    end;
  end;

  if (Mat.Kommission<>'') then begin

    Pls_fontSize # 6
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print(Adr.A.Anrede   , cPos0);
    Pls_fontSize # 9;
    PL_Print('Bestellnummer:',cPosKopf1);
    PL_Print(Auf.Best.Nummer,cPosKopf2);
    PL_PrintLine;

    PL_Print(Adr.A.Name     , cPos0);
    Pls_fontSize # 9;
    PL_Print('Bestelldatum:',cPosKopf1);
    PL_PrintD_L(Auf.Best.Datum,cPosKopf2);
    PL_PrintLine;

    PL_Print(Adr.A.Zusatz   , cPos0);
    Pls_fontSize # 9;
    PL_Print('Ihre Kundennr.:',cPosKopf1);
    PL_PrintI_L(Auf.Kundennr,cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print("Adr.A.Straße" , cPos0);
    Pls_fontSize # 9;
    PL_Print('Unsere Lf.Nr.:',cPosKopf1);
    PL_Print(Adr.VK.Referenznr,cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print(Adr.A.Plz+' '+Adr.A.Ort, cPos0);
    Pls_fontSize # 9;
    PL_Print('Auftragsnummer:',cPosKopf1);
    PL_PrintI_L(Auf.Nummer,cPosKopf2);
    PL_PrintLine;

    PL_Print('Datum:',cPosKopf1);
    PL_PrintD_L(today,cPosKopf2);
    PL_PrintLine;

    PL_PrintLine;

    end
  else begin
    Pls_fontSize # 6;
    pls_Fontattr # _WinFontAttrU;
    PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;

    pls_Fontattr # 0;
    Pls_fontSize # 10;
    PL_Print('' , cPos0);
    Pls_fontSize # 9;
    PL_Print('',cPosKopf1);
    PL_Print('',cPosKopf2);
    PL_PrintLine;

    PL_Print(''     , cPos0);
    Pls_fontSize # 9;
    PL_Print('',cPosKopf1);
    PL_Print('',cPosKopf2);
    PL_PrintLine;

    PL_Print(''   , cPos0);
    Pls_fontSize # 9;
    PL_Print('',cPosKopf1);
    PL_Print('',cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print('' , cPos0);
    Pls_fontSize # 9;
    PL_Print('',cPosKopf1);
    PL_Print('',cPosKopf2);
    PL_PrintLine;

    Pls_fontSize # 10;
    PL_Print('', cPos0);
    Pls_fontSize # 9;
    PL_Print('',cPosKopf1);
    PL_Print('',cPosKopf2);
    PL_PrintLine;

    PL_Print('Datum:',cPosKopf1);
    PL_PrintD_L(today,cPosKopf2);
    PL_PrintLine;

    PL_PrintLine;
  end;

  Pls_FontSize # 10;
  Pls_Fontattr # _WinFontAttrBold;

    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    PL_PrintLine;
    Pl_Print('Auszug aus der Prüfbescheinigung nach DIN EN 10204/3.1b'/*+' '+CnvAi(Auf.P.Nummer)  */,cPos0 );

  PL_PrintLine;

  Pls_FontSize # 9;
  Pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Prüfung zu folgendem Material:',cPos0);
    PL_PrintLine;
  end;

end;


//========================================================================
//  HoleWert
//
//========================================================================
sub HoleWert(aFeld : int) : float;
local begin
  vX  : float;
end;
begin


  vX # FldFloat(200, 4, aFeld + 1);
  if (vX <> 0.0) then
    RETURN vX;

  vX # FldFloat(231,1,( (aFeld+1) / 2) + 3);
  if (vX <> 0.0) then
    RETURN vX;

  vX # FldFloat(200,4,aFeld);

  RETURN vX;
end;

//========================================================================
//  HoleAlphaWert
//
//========================================================================
sub HoleAlphaWert(aFeld : int) : alpha;
local begin
  vY  : alpha;
end;
begin


  vY # FldAlpha(200,4,aFeld + 1);
  if (vY<>'') then RETURN vY;

  vY # FldAlpha(231,1,( (aFeld+1) / 2) + 3);
  if (vY<>'') then RETURN vY;

  vY # FldAlpha(200,4,aFeld);
  RETURN vY;

end;

//========================================================================
//  DruckElePos
//
//========================================================================
sub DruckElePos(aName : alpha; aNr : float; aPos : int);
begin
  case aPos of

     1 : begin
      PL_Print(aName, 10.0, 20.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 20.0, 35.0, 1);
      end;

     2 : begin
      PL_Print(aName, 45.0, 55.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 55.0, 70.0, 1);
      end;

     3 : begin
      PL_Print(aName, 80.0, 90.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 90.0, 105.0, 1);
      end;

     4 : begin
      PL_Print(aName, 115.0, 125.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 125.0, 140.0, 1);
      end;


     5 : begin
      PL_Print(aName, 10.0, 20.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 20.0, 35.0, 2);
      end;

     6 : begin
      PL_Print(aName, 45.0, 55.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 55.0, 70.0, 2);
      end;

     7 : begin
      PL_Print(aName, 80.0, 90.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 90.0, 105.0, 2);
      end;

     8 : begin
      PL_Print(aName, 115.0, 125.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 125.0, 140.0, 2);
      end;


     9 : begin
      PL_Print(aName, 10.0, 20.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 20.0, 35.0, 3);
      end;

    10 : begin
      PL_Print(aName, 45.0, 55.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 55.0, 70.0, 3);
      end;

    11 : begin
      PL_Print(aName, 80.0, 90.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 90.0, 105.0, 3);
      end;

    12 : begin
      PL_Print(aName, 115.0, 125.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 125.0, 140.0, 3);
      end;


    13 : begin
      PL_Print(aName, 10.0, 20.0, 4);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 20.0, 35.0, 4);
      end;

    14 : begin
      PL_Print(aName, 45.0, 55.0, 4);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 55.0, 70.0, 4);
      end;

    15 : begin
      PL_Print(aName, 80.0, 90.0, 4);
      PL_Print(cnvAF(aNr,_FmtNone,0,3), 90.0, 105.0, 4);
      end;

  end // case



end;


//========================================================================
//  DruckMePos
//
//========================================================================
/*
sub DruckMePos(aName : alpha; aNr : float; aPos : int; aName2 : alpha);
begin
  case aPos of

     1 : begin
      PL_Print(aName, 10.0, 40.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 40.0, 55.0, 1);
      PL_Print(aName2, 55.0, 70.0, 1);
      end;

     2 : begin
      PL_Print(aName, 75.0, 105.0, 1);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 105.0, 120.0, 1);
      PL_Print(aName2, 120.0, 135.0, 1);
      end;

     3 : begin
      PL_Print(aName, 10.0, 40.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 40.0, 55.0, 2);
      PL_Print(aName2, 55.0, 70.0, 2);
      end;

     4 : begin
      PL_Print(aName, 75.0, 105.0, 2);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 105.0, 120.0, 2);
      PL_Print(aName2, 120.0, 135.0, 2);
      end;

     5 : begin
      PL_Print(aName, 10.0, 40.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 40.0, 55.0, 3);
      PL_Print(aName2, 55.0, 70.0, 3);
      end;

     6 : begin
      PL_Print(aName, 75.0, 105.0, 3);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 105.0, 120.0, 3);
      PL_Print(aName2, 120.0, 135.0, 3);
      end;

     7 : begin
      PL_Print(aName, 10.0, 40.0, 4);
      PL_Print(cnvAF(aNr,_FmtNone,0,1), 40.0, 55.0, 4);
      PL_Print(aName2, 55.0, 70.0, 4);
      end;

  end // case


end;
*/
//========================================================================
//  DruckMePos
//
//========================================================================

sub DruckMePos(aName : alpha; aString : alpha; aPos : int; aName2 : alpha);
begin
  case aPos of

     1 : begin
      PL_Print(aName, 10.0, 40.0, 1);
      PL_Print(aString, 40.0, 55.0, 1);
      PL_Print(aName2, 55.0, 70.0, 1);
      vZeile # 1;
      end;

     2 : begin
      PL_Print(aName, 75.0, 105.0, 1);
      PL_Print(aString, 105.0, 120.0, 1);
      PL_Print(aName2, 120.0, 135.0, 1);
      vZeile # 1;
      end;

     3 : begin
      PL_Print(aName, 10.0, 40.0, 2);
      PL_Print(aString, 40.0, 55.0, 2);
      PL_Print(aName2, 55.0, 70.0, 2);
      vZeile # 2;
      end;

     4 : begin
      PL_Print(aName, 75.0, 105.0, 2);
      PL_Print(aString, 105.0, 120.0, 2);
      PL_Print(aName2, 120.0, 135.0, 2);
      vZeile # 2;
      end;

     5 : begin
      PL_Print(aName, 10.0, 40.0, 3);
      PL_Print(aString, 40.0, 55.0, 3);
      PL_Print(aName2, 55.0, 70.0, 3);
      vZeile # 3;
      end;

     6 : begin
      PL_Print(aName, 75.0, 105.0, 3);
      PL_Print(aString, 105.0, 120.0, 3);
      PL_Print(aName2, 120.0, 135.0, 3);
      vZeile # 3;
      end;

     7 : begin
      PL_Print(aName, 10.0, 40.0, 4);
      PL_Print(aString, 40.0, 55.0, 4);
      PL_Print(aName2, 55.0, 70.0, 4);
      vZeile # 4;
      end;

  end // case
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
vY   : alpha;
end;

begin
case aTyp of

  'Ch' : begin
    Pls_FontSize # 9;
    Pls_Fontattr # 0;
    pls_Inverted # n;

    vPos # 0;


    vX # HoleWert(15); // C
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('C:', vX, vPos);
    end;


    vX # HoleWert(17); // Si
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Si:', vX, vPos);
    end;


    vX # HoleWert(19); // Mn
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Mn:', vX, vPos);
    end;


    vX # HoleWert(21); // P
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('P:', vX, vPos);
    end;


    vX # HoleWert(23); // S
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('S:', vX, vPos);
    end;


    vX # HoleWert(25); // Al
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Al:', vX, vPos);
    end;


    vX # HoleWert(27); // Cr
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Cr:', vX, vPos);
    end;


    vX # HoleWert(29); // V
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('V:', vX, vPos);
    end;


    vX # HoleWert(31); // Nb
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Nb:', vX, vPos);
    end;


    vX # HoleWert(33); // Ti
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Ti:', vX, vPos);
    end;


    vX # HoleWert(35); // N
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('N:', vX, vPos);
    end;


    vX # HoleWert(37); // Cu
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Cu:', vX, vPos);
    end;


    vX # HoleWert(39); // Ni
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Ni:', vX, vPos);
    end;


    vX # HoleWert(41); // Mo
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('Mo:', vX, vPos);
    end;


    vX # HoleWert(43); // B
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckElePos('B:', vX, vPos);
    end;

    PL_PrintLine;
  end; // chemie


  'ChKopf' : begin
    pls_Inverted  # y;
    pls_FontSize  # 10;

    PL_Print('Chemische Analyse in %',cPos1);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;

  end; // chemie kopf

  'Me' : begin
    Pls_FontSize # 9;
    Pls_Fontattr # 0;
    pls_Inverted # n;

    vPos # 0;
    // cnvAF(vX,_FmtNone,0,1)
    // Streckgrenze
    vX # HoleWert(1);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Streckgr.(ReH):', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Zugfestigkeit
    vX # HoleWert(3);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Zugfest.(Rm):', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Dehnung
    vX  # HoleWert(5);
    vX2 # HoleWert(7);
    if (vX <> 0.0) and (vX2 <> 0.0)  then begin
      vPos # vPos + 1;
      DruckMePos('Dehnung:', cnvAF(vX,_FmtNone,0,1), vPos, '/ ' + cnvAF(vX2,_FmtNone,0,1));
    end;

    // Dehnungsgrenze 0,2
    vX # HoleWert(9);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Rp 0,2:', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Dehnungsgrenze 10
    vX # HoleWert(11);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Rp 10:', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Krönung
    vX # HoleWert(13);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      if ("Set.Mech.Titel.Körn" <> '') then DruckMePos("Set.Mech.Titel.Körn" + ':', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²')
      else DruckMePos('Körnung:', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Härte
    vX # HoleWert(45);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      if ("Set.Mech.Titel.Härte" <> '') then DruckMePos("Set.Mech.Titel.Härte" + ':', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²')
      else DruckMePos('Härte:', cnvAF(vX,_FmtNone,0,1), vPos, 'N/mm²');
    end;

    // Sonstiges
    vY # HoleAlphaWert(49);
    if (vY <> '') then begin
      if ("Set.Mech.Titel.Sonst" <> '') then begin
        PL_Print("Set.Mech.Titel.Sonst" + ':',10.0,40.0,vZeile+1);
        PL_Print(vY, 40.0,cPos9,vZeile+1);
      end
      else begin
        PL_Print('Sonstiges:', 10.0,40.0,vZeile+1);
        PL_Print(vY, 40.0,cPos9,vZeile+1);
      end;
    end;

    PL_PrintLine;

  end; // mechanisch

  'MeKopf' : begin
    pls_Inverted  # y;
    pls_FontSize  # 10;

    PL_Print('Mechanische Werte',cPos1);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;

  end; // mechanische kopf

  'Mat' : begin
    Pls_FontSize # 9;
    Pls_Fontattr # 0;

    //Dicke - Chargennummer - Gewicht
    PL_PrintLine;
    PL_Print('Dicke mm:', cPosM1);
    PL_PrintF(Mat.Dicke,Set.Stellen.Dicke, cPosM1a);
    PL_Print('Chargennummer:', cPosM2);
    PL_Print(Mat.Chargennummer, cPosM2a);
    PL_Print('Gewicht kg:', cPosM3);
    PL_Print_R(ANum(Mat.Bestand.Gew,Set.Stellen.Gewicht), cPosM3a);
    PL_PrintLine;

    //Breite - Qualität - Stückzahl
    PL_Print('Breite mm:', cPosM1);
    PL_PrintF(Mat.Breite,Set.Stellen.Breite, cPosM1a);
    PL_Print('Qualität:', cPosM2);
    PL_Print("Mat.Güte", cPosM2a);
    PL_Print('Stückzahl:', cPosM3);
    PL_Print_R(AInt(Mat.Bestand.Stk), cPosM3a);
    PL_PrintLine;

    //Länge - Ring Nummer
    PL_Print('Länge mm:', cPosM1);
    PL_PrintF("Mat.Länge","Set.Stellen.Länge" , cPosM1a);
    PL_Print('Ring-Nr.:', cPosM2);
    PL_Print(AInt(Mat.Nummer), cPosM2a);
    PL_PrintLine;

    PL_PrintLine;
  end; // Mat


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
//  Lib_Print:FrmJobOpen(AInt(vNummer),vHeader , vFooter,y,y,n);
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);

  // ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();
  vAdresse    # Adr.Nummer;

  // ------- POSITION --------------------------------------------------------------------------

  PRINT('Mat');

  PRINT('MeKopf');
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

  // gedruckte Zeile vorbelegen
  vZeile # 0;
  PRINT('Me');

  PL_PrintLine;

  PRINT('ChKopf');
  PRINT('Ch');



  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';
  PRINT('FUSS');


// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschau
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vPLHeader<>0) then PL_Destroy(vPLHeader)
  else if (vHeader<>0) then vHeader->PrtFormClose();
  if (vPLFooter<>0) then PL_Destroy(vPLFooter)
  else if (vFooter<>0) then vFooter->PrtFormClose();

end;



//========================================================================