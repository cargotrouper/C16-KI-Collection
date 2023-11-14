@A+
//===== Business-Control =================================================
//
//  Prozedur  Lys_Data
//                    OHNE E_R_G
//  Info
//
//
//  02.07.2012  AI  Erstellung der Prozedur
//  26.02.2016  AH  "CopyToMatAnalyse1"
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub Anlegen() : logic
//    sub CopyToMat() : logic
//    sub VorbelegenVonMatAnalyse()
//
//    sub Wert2vor1(aWert1 : float; aWert2    : float) : float;
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//  Anlegen
//
//========================================================================
sub Anlegen() : logic
local begin
  Erx : int;
end;
begin

  Lys.K.AnalyseNr # Lib_Nummern:ReadNummer('Analysen');
  if (Lys.K.AnalyseNr<>0) then
    Lib_Nummern:SaveNummer()
  else begin
    Error(902001,'Analyse|'+LockedBy);     // ST 2009-02-03
    RETURN false;
  end;

  Lys.AnalyseNr # Lys.K.AnalyseNr;
  Lys.Version # 1;

  Lys.K.Anlage.Datum  # Today;
  Lys.K.Anlage.Zeit   # Now;
  Lys.K.Anlage.User   # gUserName;

  Lys.Anlage.Datum  # Today;
  Lys.Anlage.Zeit   # Now;
  Lys.Anlage.User   # gUserName;

  Erx # RekInsert(230,0,'MAN');
  if (Erx<>_rOk) then begin
    Error(001000+Erx,'');
    RETURN False;
  end;

  Erx # RekInsert(231,0,'MAN');
  if (Erx<>_rOk) then begin
//    Error(001000+Erx,''); 26.02.2020
    Error(001204,'('+Translate('Nr.')+aint(Lys.Analysenr)+')');
    RETURN False;
  end;


  RETURN true;
end;


//========================================================================
//  CopyToMat
//
//========================================================================
sub CopyToMat() : logic
begin

  Mat.Streckgrenze2     # Lys.Streckgrenze;
  Mat.StreckgrenzeB2    # Lys.Streckgrenze2;
  Mat.Zugfestigkeit2    # Lys.Zugfestigkeit;
  Mat.ZugfestigkeitB2   # Lys.Zugfestigkeit2;
  Mat.DehnungA2         # Lys.DehnungA;
  Mat.DehnungB2         # Lys.DehnungB;
  Mat.DehnungC2         # Lys.DehnungC;
  Mat.RP02_V2           # Lys.RP02_1;
  Mat.RP02_B2           # Lys.RP02_2;
  Mat.RP10_V2           # Lys.RP10_1;
  Mat.RP10_B2           # Lys.RP10_2
  "Mat.Körnung2"        # "Lys.Körnung";
  "Mat.KörnungB2"       # "Lys.Körnung2";
  "Mat.HärteA2"         # "Lys.Härte1";
  "Mat.HärteB2"         # "Lys.Härte2";
  Mat.RauigkeitA2       # Lys.RauigkeitA1;
  Mat.RauigkeitB2       # Lys.RauigkeitA2;
  Mat.RauigkeitC2       # Lys.RauigkeitB1;
  Mat.RauigkeitD2       # Lys.RauigkeitB2;

  Mat.Chemie.C2         # Lys.Chemie.C;
  Mat.Chemie.Si2        # Lys.Chemie.Si;
  Mat.Chemie.Mn2        # Lys.Chemie.Mn;
  Mat.Chemie.P2         # Lys.Chemie.P;
  Mat.Chemie.S2         # Lys.Chemie.S;
  Mat.Chemie.Al2        # Lys.Chemie.Al;
  Mat.Chemie.Cr2        # Lys.Chemie.Cr;
  Mat.Chemie.V2         # Lys.Chemie.V;
  Mat.Chemie.Nb2        # Lys.Chemie.Nb;
  Mat.Chemie.Ti2        # Lys.Chemie.Ti;
  Mat.Chemie.N2         # Lys.Chemie.N;
  Mat.Chemie.Cu2        # Lys.Chemie.Cu;
  Mat.Chemie.Ni2        # Lys.Chemie.Ni;
  Mat.Chemie.Mo2        # Lys.Chemie.Mo;
  Mat.Chemie.B2         # Lys.Chemie.B;
  Mat.Chemie.Frei1.2    # Lys.Chemie.Frei1;
  Mat.Mech.Sonstiges2   # Lys.Mech.Sonstiges;
end;


//========================================================================
//  CopyToMatAnalyse1
//
//========================================================================
sub CopyToMatAnalyse1() : logic
begin

  Mat.Streckgrenze1     # Lys.Streckgrenze;
  Mat.StreckgrenzeB1    # Lys.Streckgrenze2;
  Mat.Zugfestigkeit1    # Lys.Zugfestigkeit;
  Mat.ZugfestigkeitB1   # Lys.Zugfestigkeit2;
  Mat.DehnungA1         # Lys.DehnungA;
  Mat.DehnungB1         # Lys.DehnungB;
  Mat.DehnungC1         # Lys.DehnungC;
  Mat.RP02_V1           # Lys.RP02_1;
  Mat.RP02_B1           # Lys.RP02_2;
  Mat.RP10_V1           # Lys.RP10_1;
  Mat.RP10_B1           # Lys.RP10_2
  "Mat.Körnung1"        # "Lys.Körnung";
  "Mat.KörnungB1"       # "Lys.Körnung2";
  "Mat.HärteA1"         # "Lys.Härte1";
  "Mat.HärteB1"         # "Lys.Härte2";
  Mat.RauigkeitA1       # Lys.RauigkeitA1;
  Mat.RauigkeitB1       # Lys.RauigkeitA2;
  Mat.RauigkeitC1       # Lys.RauigkeitB1;
  Mat.RauigkeitD1       # Lys.RauigkeitB2;

  Mat.Chemie.C1         # Lys.Chemie.C;
  Mat.Chemie.Si1        # Lys.Chemie.Si;
  Mat.Chemie.Mn1        # Lys.Chemie.Mn;
  Mat.Chemie.P1         # Lys.Chemie.P;
  Mat.Chemie.S1         # Lys.Chemie.S;
  Mat.Chemie.Al1        # Lys.Chemie.Al;
  Mat.Chemie.Cr1        # Lys.Chemie.Cr;
  Mat.Chemie.V1         # Lys.Chemie.V;
  Mat.Chemie.Nb1        # Lys.Chemie.Nb;
  Mat.Chemie.Ti1        # Lys.Chemie.Ti;
  Mat.Chemie.N1         # Lys.Chemie.N;
  Mat.Chemie.Cu1        # Lys.Chemie.Cu;
  Mat.Chemie.Ni1        # Lys.Chemie.Ni;
  Mat.Chemie.Mo1        # Lys.Chemie.Mo;
  Mat.Chemie.B1         # Lys.Chemie.B;
  Mat.Chemie.Frei1.1    # Lys.Chemie.Frei1;
  Mat.Mech.Sonstiges1   # Lys.Mech.Sonstiges;
end;


//========================================================================
//  CALL Lys_data:Lauf_V2118
//========================================================================
sub Lauf_V2118
local begin
  Erx : int;
end;
begin

  FOR Erx # RecRead(230,1,_recFirst)
  LOOP Erx # RecRead(230,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lys.K.Lieferant=0) and (Lys.K.Kundennr=0) then CYCLE;
    RecRead(230,1,_RecLock);
    if (Lys.K.Lieferant<>0) then begin
      Erx # RecLink(100,230,2,0);   // Lieferant holen
      if (Erx<=_rLocked) and (Lys.K.Lieferant<>0) then
        Lys.K.LieferantenSW # Adr.Stichwort;
    end;
    if (Lys.K.Kundennr<>0) then begin
      RekLink(100,230,4,_recFirst); // Kunde holen
      if (Erx<=_rLocked) and (Lys.K.Lieferant<>0) then
        Lys.K.KundenSW # Adr.Stichwort;
    end;
    RekReplace(230);
  END;

  MSg(999998,'',0,0,0);
end;


//========================================================================
//  Wert2vor1
//
//========================================================================
sub Wert2vor1(
  aWert1    : float;
  aWert2    : float) : float;
begin
  if (aWert2<>0.0) then RETURN aWert2

  RETURN aWert1;
end;


//========================================================================
//========================================================================
sub VorbelegenVonMatAnalyse()
begin
  Lys.K.Datum           # today;
  Lys.K.Chargennummer   # Mat.Chargennummer;
  Lys.K.Lieferant       # Mat.Lieferant;
  Lys.K.Coilnummer      # Mat.Coilnummer;
  Lys.Streckgrenze      # Wert2vor1(Mat.Streckgrenze1     ,Mat.Streckgrenze2);
  Lys.Zugfestigkeit     # Wert2vor1(Mat.Zugfestigkeit1    ,Mat.Zugfestigkeit2);
  Lys.DehnungA          # Wert2vor1(Mat.DehnungA1         ,Mat.DehnungA2);
  Lys.RP02_1            # Wert2vor1(Mat.RP02_V1           ,Mat.RP02_V2);
  Lys.RP10_1            # Wert2vor1(Mat.RP10_V1           ,Mat.RP10_V2);
  "Lys.Körnung"         # Wert2vor1("Mat.Körnung1"        ,"Mat.Körnung2");
  "Lys.Härte1"          # Wert2vor1("Mat.HärteA1"         ,"Mat.HärteA2");
  Lys.RauigkeitA1       # Wert2vor1(Mat.RauigkeitA1       ,Mat.RauigkeitA2);
  Lys.RauigkeitB1       # Wert2vor1(Mat.RauigkeitC1       ,Mat.RauigkeitC2);

  Lys.Streckgrenze2     # Wert2vor1(Mat.StreckgrenzeB1     ,Mat.StreckgrenzeB2);
  Lys.Zugfestigkeit2    # Wert2vor1(Mat.ZugfestigkeitB1    ,Mat.ZugfestigkeitB2);
  Lys.DehnungB          # Wert2vor1(Mat.DehnungB1         ,Mat.DehnungB2);
  Lys.DehnungC          # Wert2vor1(Mat.DehnungC1         ,Mat.DehnungC2);
  Lys.RP02_2            # Wert2vor1(Mat.RP02_B1           ,Mat.RP02_B2);
  Lys.RP10_2            # Wert2vor1(Mat.RP10_B1           ,Mat.RP10_B2);
  "Lys.Körnung2"         # Wert2vor1("Mat.KörnungB1"      ,"Mat.KörnungB2");
  "Lys.Härte2"          # Wert2vor1("Mat.HärteB1"         ,"Mat.HärteB2");
  Lys.RauigkeitA2       # Wert2vor1(Mat.RauigkeitB1       ,Mat.RauigkeitB2);
  Lys.RauigkeitB2       # Wert2vor1(Mat.RauigkeitD1       ,Mat.RauigkeitD2);

  Lys.Chemie.C          # Wert2vor1(Mat.Chemie.C1      ,Mat.Chemie.C2);
  Lys.Chemie.Si         # Wert2vor1(Mat.Chemie.Si1     ,Mat.Chemie.Si2);
  Lys.Chemie.Mn         # Wert2vor1(Mat.Chemie.Mn1     ,Mat.Chemie.Mn2);
  Lys.Chemie.P          # Wert2vor1(Mat.Chemie.P1      ,Mat.Chemie.P2);
  Lys.Chemie.S          # Wert2vor1(Mat.Chemie.S1      ,Mat.Chemie.S2);
  Lys.Chemie.Al         # Wert2vor1(Mat.Chemie.Al1     ,Mat.Chemie.Al2);
  Lys.Chemie.Cr         # Wert2vor1(Mat.Chemie.Cr1     ,Mat.Chemie.Cr2);
  Lys.Chemie.V          # Wert2vor1(Mat.Chemie.V1      ,Mat.Chemie.V2);
  Lys.Chemie.Nb         # Wert2vor1(Mat.Chemie.Nb1     ,Mat.Chemie.Nb2);
  Lys.Chemie.Ti         # Wert2vor1(Mat.Chemie.Ti1     ,Mat.Chemie.Ti2);
  Lys.Chemie.N          # Wert2vor1(Mat.Chemie.N1      ,Mat.Chemie.N2);
  Lys.Chemie.Cu         # Wert2vor1(Mat.Chemie.Cu1     ,Mat.Chemie.Cu2);
  Lys.Chemie.Ni         # Wert2vor1(Mat.Chemie.Ni1     ,Mat.Chemie.Ni2);
  Lys.Chemie.Mo         # Wert2vor1(Mat.Chemie.Mo1     ,Mat.Chemie.Mo2);
  Lys.Chemie.B          # Wert2vor1(Mat.Chemie.B1      ,Mat.Chemie.B2);
  Lys.Chemie.Frei1      # Wert2vor1(Mat.Chemie.Frei1.1 ,Mat.Chemie.Frei1.2);
end;

//========================================================================