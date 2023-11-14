@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_LFS_WZ_E
//                      OHNE E_R_G
//  Info
//    Druckt ein Materialzeugnis für Lieferschein
//
//
//  22.10.2007  AI  Erstellung der Prozedur
//  25.08.2009  MS  Anpassung auf ENGLISCH
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
end;
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
  Erx         : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin


//Mat->Auf.Pos -> ggf.Kopf + Kunde
  Erx # RecLink(100,401,4,_recFirst);  // Kunde holen
  if(Erx > _rLocked) then
    RecBufClear(100);

  Erx # RecLink(400,401,3,_recFirst);  // Kopf holen
  if(Erx > _rLocked) then
    RecBufClear(400);

  Erx # RecLink(100,440,2,_recFirst);    // Zieladresse lesen
  if(Erx > _rLocked) then
    RecBufClear(100);

  Erx # RecLink(101,440,3,_recFirst);    // Zielanschrift lesen
  if(Erx > _rLocked) then
    RecBufClear(101);

  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  Pls_fontSize # 6
  pls_Fontattr # _WinFontAttrU;
  PL_Print(Set.Absenderzeile, cPos0); PL_PrintLine;
  PL_PrintLine;
  pls_Fontattr # 0;
  Pls_fontSize # 10;
  PL_Print(Adr.A.Anrede   , cPos0); PL_PrintLine;
  PL_Print(Adr.A.Name     , cPos0); PL_PrintLine;

  PL_Print(Adr.A.Zusatz   , cPos0);
  Pls_fontSize # 9;
  PL_Print('Unsere Knd.Nr.:',cPosKopf1);
  PL_Print(Adr.VK.Referenznr,cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print("Adr.A.Straße" , cPos0);
  Pls_fontSize # 9;
  PL_Print('Sachbearbeiter:',cPosKopf1);
  PL_Print(Usr_Data:Sachbearbeiter(gUsername),cPosKopf2);
  PL_PrintLine;

  Pls_fontSize # 10;
  PL_Print(StrAdj(Adr.A.LKZ + ' ' + Adr.A.PLZ + ' ' + Adr.A.Ort,_StrBegin), cPos0);
  Pls_fontSize # 9;
  PL_Print('Date:',cPosKopf1);
  PL_Print(cnvad(today),cPosKopf2);
  PL_PrintLine;
  pl_PrintLine;
  PL_PrintLine;
  PL_PrintLine;

  Pls_FontSize # 10;
  Pls_Fontattr # _WinFontAttrBold;

  PL_PrintLine;
  PL_PrintLine;
  PL_PrintLine;
  PL_Print('Inspection certificate 3.1 according to EN 10204:2004', cPos0);


  PL_PrintLine;

  Pls_FontSize # 9;
  Pls_Fontattr # 0;


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

    PL_PrintLine;
    PL_Print('Prüfung zu folgendem Material:',cPos0);
    PL_PrintLine;
    Pl_Print('Works-No.:'+'   '+Lfs.P.Kommission,cPos0);
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


  vX # FldFloat(200,4,aFeld + 1);
  if (vX<>0.0) then RETURN vX;

  vX # FldFloat(231,1,((aFeld+1) / 2) + 3);
  if (vX<>0.0) then RETURN vX;

  vX # FldFloat(200,4,aFeld);
  RETURN vX;

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
      PL_Print(cnvAF(aNr, 3), 20.0, 35.0, 1);
      end;

     2 : begin
      PL_Print(aName, 45.0, 55.0, 1);
      PL_Print(cnvAF(aNr, 3), 55.0, 70.0, 1);
      end;

     3 : begin
      PL_Print(aName, 80.0, 90.0, 1);
      PL_Print(cnvAF(aNr, 3), 90.0, 105.0, 1);
      end;

     4 : begin
      PL_Print(aName, 115.0, 125.0, 1);
      PL_Print(cnvAF(aNr, 3), 125.0, 140.0, 1);
      end;


     5 : begin
      PL_Print(aName, 10.0, 20.0, 2);
      PL_Print(cnvAF(aNr, 3), 20.0, 35.0, 2);
      end;

     6 : begin
      PL_Print(aName, 45.0, 55.0, 2);
      PL_Print(cnvAF(aNr, 3), 55.0, 70.0, 2);
      end;

     7 : begin
      PL_Print(aName, 80.0, 90.0, 2);
      PL_Print(cnvAF(aNr, 3), 90.0, 105.0, 2);
      end;

     8 : begin
      PL_Print(aName, 115.0, 125.0, 2);
      PL_Print(cnvAF(aNr, 3), 125.0, 140.0, 2);
      end;


     9 : begin
      PL_Print(aName, 10.0, 20.0, 3);
      PL_Print(cnvAF(aNr, 3), 20.0, 35.0, 3);
      end;

    10 : begin
      PL_Print(aName, 45.0, 55.0, 3);
      PL_Print(cnvAF(aNr, 3), 55.0, 70.0, 3);
      end;

    11 : begin
      PL_Print(aName, 80.0, 90.0, 3);
      PL_Print(cnvAF(aNr, 3), 90.0, 105.0, 3);
      end;

    12 : begin
      PL_Print(aName, 115.0, 125.0, 3);
      PL_Print(cnvAF(aNr, 3), 125.0, 140.0, 3);
      end;


    13 : begin
      PL_Print(aName, 10.0, 20.0, 4);
      PL_Print(cnvAF(aNr, 3), 20.0, 35.0, 4);
      end;

    14 : begin
      PL_Print(aName, 45.0, 55.0, 4);
      PL_Print(cnvAF(aNr, 3), 55.0, 70.0, 4);
      end;

    15 : begin
      PL_Print(aName, 80.0, 90.0, 4);
      PL_Print(cnvAF(aNr, 3), 90.0, 105.0, 4);
      end;

  end // case



end;


//========================================================================
//  DruckMePos
//
//========================================================================
sub DruckMePos(aName : alpha; aNr : float; aPos : int; aName2 : alpha);
begin
  case aPos of

     1 : begin
      PL_Print(aName, 10.0, 40.0, 1);
      PL_Print(cnvAF(aNr, 3), 40.0, 55.0, 1);
      PL_Print(aName2, 55.0, 70.0, 1);
      end;

     2 : begin
      PL_Print(aName, 75.0, 105.0, 1);
      PL_Print(cnvAF(aNr, 3), 105.0, 120.0, 1);
      PL_Print(aName2, 120.0, 135.0, 1);
      end;

     3 : begin
      PL_Print(aName, 10.0, 40.0, 2);
      PL_Print(cnvAF(aNr, 3), 40.0, 55.0, 2);
      PL_Print(aName2, 55.0, 70.0, 2);
      end;

     4 : begin
      PL_Print(aName, 75.0, 105.0, 2);
      PL_Print(cnvAF(aNr, 3), 105.0, 120.0, 2);
      PL_Print(aName2, 120.0, 135.0, 2);
      end;

     5 : begin
      PL_Print(aName, 10.0, 40.0, 3);
      PL_Print(cnvAF(aNr, 3), 40.0, 55.0, 3);
      PL_Print(aName2, 55.0, 70.0, 3);
      end;

     6 : begin
      PL_Print(aName, 75.0, 105.0, 3);
      PL_Print(cnvAF(aNr, 3), 105.0, 120.0, 3);
      PL_Print(aName2, 120.0, 135.0, 3);
      end;

     7 : begin
      PL_Print(aName, 10.0, 40.0, 4);
      PL_Print(cnvAF(aNr, 3), 40.0, 55.0, 4);
      PL_Print(aName2, 55.0, 70.0, 4);
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

    PL_Print('Analysis %',cPos1);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;

  end; // chemie kopf

  'Me' : begin
    Pls_FontSize # 9;
    Pls_Fontattr # 0;
    pls_Inverted # n;

    vPos # 0;

    // Streckgrenze
    vX # HoleWert(1);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Streckgr.(ReH):', vX, vPos, 'N/mm²');
    end;

    // Zugfestigkeit
    vX # HoleWert(3);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Zugfest.(Rm):', vX, vPos, 'N/mm²');
    end;

    // Dehnung
    vX  # HoleWert(5);
    vX2 # HoleWert(7);
    if (vX <> 0.0) and (vX2 <> 0.0)  then begin
      vPos # vPos + 1;
      DruckMePos('Dehnung:', vX, vPos, '/ ' + cnvAF(vX2, 2));
    end;

    // Dehnungsgrenze 0,2
    vX # HoleWert(9);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Rp 0,2:', vX, vPos, 'N/mm²');
    end;

    // Dehnungsgrenze 10
    vX # HoleWert(11);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Rp 10:', vX, vPos, 'N/mm²');
    end;

    // Krönung
    vX # HoleWert(13);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Körnung:', vX, vPos, 'N/mm²');
    end;

    // Härte
    vX # HoleWert(45);
    if (vX <> 0.0) then begin
      vPos # vPos + 1;
      DruckMePos('Härte:', vX, vPos, 'N/mm²');
    end;

    PL_PrintLine;

  end; // mechanisch

  'MeKopf' : begin
    pls_Inverted  # y;
    pls_FontSize  # 10;

    PL_Print('Mechanical Charakteristics, Tensile Test',cPos1);
    PL_Drawbox(cPos0-1.0,cPos9+1.0,_WinColblack, 5.0);
    PL_PrintLine;

  end; // mechanische kopf

  'Mat' : begin
    Pls_FontSize # 9;
    Pls_Fontattr # 0;

    //Dicke - Chargennummer - Gewicht
    PL_PrintLine;
    PL_Print('Thickness mm:', cPosM1);
    PL_PrintF(Mat.Dicke,Set.Stellen.Dicke, cPosM1a);
    PL_Print('Chargeno.:', cPosM2);
    PL_Print(Mat.Chargennummer, cPosM2a);
    PL_Print('Shipping weight (kg):', cPosM3);
    PL_PrintF(Mat.Bestand.Gew,Set.Stellen.Gewicht, cPosM3a);
    PL_PrintLine;

    //Breite - Qualität - Stückzahl
    PL_Print('Width mm:', cPosM1);
    PL_PrintF(Mat.Breite,Set.Stellen.Breite, cPosM1a);
    PL_Print('Grade:', cPosM2);
    PL_Print("Mat.Güte", cPosM2a);
    PL_Print('Number pieces:', cPosM3);
    PL_Print_R(AInt(Mat.Bestand.Stk), cPosM3a);
    PL_PrintLine;

    //Länge - Ring Nummer
    PL_Print('Length mm:', cPosM1);
    PL_PrintF("Mat.Länge","Set.Stellen.Länge" , cPosM1a);
    PL_Print('Ring-No.:', cPosM2);
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
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,y,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Form_Lang # 'E'; // Sprache setzen

  // ------- KOPFDATEN -----------------------------------------------------------------------
  Lib_Print:Print_Seitenkopf();
  vAdresse    # Adr.Nummer;

  // ------- POSITION --------------------------------------------------------------------------

  PRINT('Mat');

  PRINT('MeKopf');
  RecBufClear(230);
  RecBufClear(231);
  if (Mat.Analysenummer <> 0) then begin
    if (RecLink(230, 200, 21, _recFirst) <= _rLocked) then begin // Analysenkopf
      RecLink(231, 230, 1, _recLast); // letzte Messung
    end;
  end;

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