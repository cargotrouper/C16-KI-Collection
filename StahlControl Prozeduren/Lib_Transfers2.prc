@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Transfers2
//                    OHNE E_R_G
//  Info
//
//
//  08.03.2017  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  Guid(a)       : '{'+Lib_ODBC:GUID(a, RecInfo(a, _RecID),false)+'}'
  Datum(a)      : Lib_Transfers:SQLTimeStamp(a, 0:0  ,y)
  Zeit(a)       : Lib_Transfers:SQLTimeStamp(0.0.0,a ,n)
  Timestamp(a,b) : Lib_Transfers:SQLTimeStamp(a, b, n)
  Bool(a)       : Lib_Transfers:Bool(a)
end;

//========================================================================
//========================================================================
//========================================================================
// AUTOMATISCHER PROZEDURTEXT:
// -------------------------------------------------
sub EX100()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0100'
     +cnvai(RecInfo(100,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("Adr.Anlage.Datum");
  GV.Int64.01 # RecInfo(100, _recModified);
  GV.Alpha.03 # Bool("Adr.SperrKundeYN");
  GV.Alpha.04 # Bool("Adr.SperrLieferantYN");
  if "Adr.Vertr1.Prov">0.0 then "Adr.Vertr1.Prov" # Min("Adr.Vertr1.Prov", 100000000000.0)
  else "Adr.Vertr1.Prov" # Max("Adr.Vertr1.Prov", -100000000000.0);
  if "Adr.Vertr2.Prov">0.0 then "Adr.Vertr2.Prov" # Min("Adr.Vertr2.Prov", 100000000000.0)
  else "Adr.Vertr2.Prov" # Max("Adr.Vertr2.Prov", -100000000000.0);
  GV.Alpha.05 # Datum("Adr.EK.ZertifikatBis");
  GV.Alpha.06 # Bool("Adr.VK.SammelReYN");
  GV.Alpha.07 # Bool("Adr.VK.EigentumVBYN");
  GV.Alpha.08 # Datum("Adr.VK.EigentumVBDat");
  GV.Alpha.09 # Bool("Adr.BonusEmpfängerYN");
  if "Adr.BonusProz">0.0 then "Adr.BonusProz" # Min("Adr.BonusProz", 100000000000.0)
  else "Adr.BonusProz" # Max("Adr.BonusProz", -100000000000.0);
  GV.Alpha.10 # Datum("Adr.Fibudatum.Kd");
  GV.Alpha.11 # Datum("Adr.Fibudatum.Lf");
  if "Adr.Fin.Vzg.Offset">0.0 then "Adr.Fin.Vzg.Offset" # Min("Adr.Fin.Vzg.Offset", 100000000000.0)
  else "Adr.Fin.Vzg.Offset" # Max("Adr.Fin.Vzg.Offset", -100000000000.0);
  GV.Alpha.12 # Datum("Adr.Fin.letzterAufAm");
  GV.Alpha.13 # Datum("Adr.Fin.letzteReAm");
  if "Adr.Fin.SummeOP">0.0 then "Adr.Fin.SummeOP" # Min("Adr.Fin.SummeOP", 100000000000.0)
  else "Adr.Fin.SummeOP" # Max("Adr.Fin.SummeOP", -100000000000.0);
  if "Adr.Fin.SummeAB">0.0 then "Adr.Fin.SummeAB" # Min("Adr.Fin.SummeAB", 100000000000.0)
  else "Adr.Fin.SummeAB" # Max("Adr.Fin.SummeAB", -100000000000.0);
  if "Adr.Fin.SummeABBere">0.0 then "Adr.Fin.SummeABBere" # Min("Adr.Fin.SummeABBere", 100000000000.0)
  else "Adr.Fin.SummeABBere" # Max("Adr.Fin.SummeABBere", -100000000000.0);
  if "Adr.Fin.SummeLFS">0.0 then "Adr.Fin.SummeLFS" # Min("Adr.Fin.SummeLFS", 100000000000.0)
  else "Adr.Fin.SummeLFS" # Max("Adr.Fin.SummeLFS", -100000000000.0);
  if "Adr.Fin.SummeRes">0.0 then "Adr.Fin.SummeRes" # Min("Adr.Fin.SummeRes", 100000000000.0)
  else "Adr.Fin.SummeRes" # Max("Adr.Fin.SummeRes", -100000000000.0);
  GV.Alpha.14 # Datum("Adr.Fin.Refreshdatum");
  if "Adr.Fin.SummePlan">0.0 then "Adr.Fin.SummePlan" # Min("Adr.Fin.SummePlan", 100000000000.0)
  else "Adr.Fin.SummePlan" # Max("Adr.Fin.SummePlan", -100000000000.0);
  if "Adr.Fin.SummeOP.Ext">0.0 then "Adr.Fin.SummeOP.Ext" # Min("Adr.Fin.SummeOP.Ext", 100000000000.0)
  else "Adr.Fin.SummeOP.Ext" # Max("Adr.Fin.SummeOP.Ext", -100000000000.0);
  if "Adr.Fin.SummeOPB">0.0 then "Adr.Fin.SummeOPB" # Min("Adr.Fin.SummeOPB", 100000000000.0)
  else "Adr.Fin.SummeOPB" # Max("Adr.Fin.SummeOPB", -100000000000.0);
  if "Adr.Fin.SummeOPB.Ext">0.0 then "Adr.Fin.SummeOPB.Ext" # Min("Adr.Fin.SummeOPB.Ext", 100000000000.0)
  else "Adr.Fin.SummeOPB.Ext" # Max("Adr.Fin.SummeOPB.Ext", -100000000000.0);
  if "Adr.Fin.SummeAB.LV">0.0 then "Adr.Fin.SummeAB.LV" # Min("Adr.Fin.SummeAB.LV", 100000000000.0)
  else "Adr.Fin.SummeAB.LV" # Max("Adr.Fin.SummeAB.LV", -100000000000.0);
  if "Adr.Fin.SummeEkBest">0.0 then "Adr.Fin.SummeEkBest" # Min("Adr.Fin.SummeEkBest", 100000000000.0)
  else "Adr.Fin.SummeEkBest" # Max("Adr.Fin.SummeEkBest", -100000000000.0);
end;

// -------------------------------------------------
sub EX101()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0101'
     +cnvai(RecInfo(101,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(101, _recModified);
  if "Adr.A.EntfernungKm">0.0 then "Adr.A.EntfernungKm" # Min("Adr.A.EntfernungKm", 100000000000.0)
  else "Adr.A.EntfernungKm" # Max("Adr.A.EntfernungKm", -100000000000.0);
  if "Adr.A.LagergeldTTag">0.0 then "Adr.A.LagergeldTTag" # Min("Adr.A.LagergeldTTag", 100000000000.0)
  else "Adr.A.LagergeldTTag" # Max("Adr.A.LagergeldTTag", -100000000000.0);
end;

// -------------------------------------------------
sub EX102()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0102'
     +cnvai(RecInfo(102,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(102, _recModified);
  GV.Alpha.02 # Datum("Adr.P.Geburtsdatum");
  GV.Alpha.03 # Bool("Adr.P.PrivGeschenkYN");
  GV.Alpha.04 # Datum("Adr.P.Partner.GebTag");
  GV.Alpha.05 # Datum("Adr.P.Hochzeitstag");
  GV.Alpha.06 # Datum("Adr.P.Kind1.GebTag");
  GV.Alpha.07 # Datum("Adr.P.Kind2.GebTag");
  GV.Alpha.08 # Datum("Adr.P.Kind3.GebTag");
  GV.Alpha.09 # Datum("Adr.P.Kind4.GebTag");
end;

// -------------------------------------------------
sub EX103()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0103'
     +cnvai(RecInfo(103,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(103, _recModified);
  if "Adr.K.VersichertFW">0.0 then "Adr.K.VersichertFW" # Min("Adr.K.VersichertFW", 100000000000.0)
  else "Adr.K.VersichertFW" # Max("Adr.K.VersichertFW", -100000000000.0);
  if "Adr.K.VersichertW1">0.0 then "Adr.K.VersichertW1" # Min("Adr.K.VersichertW1", 100000000000.0)
  else "Adr.K.VersichertW1" # Max("Adr.K.VersichertW1", -100000000000.0);
  if "Adr.K.KurzLimitFW">0.0 then "Adr.K.KurzLimitFW" # Min("Adr.K.KurzLimitFW", 100000000000.0)
  else "Adr.K.KurzLimitFW" # Max("Adr.K.KurzLimitFW", -100000000000.0);
  if "Adr.K.KurzLimitW1">0.0 then "Adr.K.KurzLimitW1" # Min("Adr.K.KurzLimitW1", 100000000000.0)
  else "Adr.K.KurzLimitW1" # Max("Adr.K.KurzLimitW1", -100000000000.0);
  GV.Alpha.02 # Datum("Adr.K.KurzLimit.Dat");
  if "Adr.K.InternLimit">0.0 then "Adr.K.InternLimit" # Min("Adr.K.InternLimit", 100000000000.0)
  else "Adr.K.InternLimit" # Max("Adr.K.InternLimit", -100000000000.0);
  if "Adr.K.InternKurz">0.0 then "Adr.K.InternKurz" # Min("Adr.K.InternKurz", 100000000000.0)
  else "Adr.K.InternKurz" # Max("Adr.K.InternKurz", -100000000000.0);
  GV.Alpha.03 # Datum("Adr.K.InternKurz.Dat");
  GV.Alpha.04 # Datum("Adr.K.Refreshdatum");
  if "Adr.K.SummeOP">0.0 then "Adr.K.SummeOP" # Min("Adr.K.SummeOP", 100000000000.0)
  else "Adr.K.SummeOP" # Max("Adr.K.SummeOP", -100000000000.0);
  if "Adr.K.SummeAB">0.0 then "Adr.K.SummeAB" # Min("Adr.K.SummeAB", 100000000000.0)
  else "Adr.K.SummeAB" # Max("Adr.K.SummeAB", -100000000000.0);
  if "Adr.K.SummeABBere">0.0 then "Adr.K.SummeABBere" # Min("Adr.K.SummeABBere", 100000000000.0)
  else "Adr.K.SummeABBere" # Max("Adr.K.SummeABBere", -100000000000.0);
  if "Adr.K.SummeLFS">0.0 then "Adr.K.SummeLFS" # Min("Adr.K.SummeLFS", 100000000000.0)
  else "Adr.K.SummeLFS" # Max("Adr.K.SummeLFS", -100000000000.0);
  if "Adr.K.SummeRes">0.0 then "Adr.K.SummeRes" # Min("Adr.K.SummeRes", 100000000000.0)
  else "Adr.K.SummeRes" # Max("Adr.K.SummeRes", -100000000000.0);
  if "Adr.K.SummePlan">0.0 then "Adr.K.SummePlan" # Min("Adr.K.SummePlan", 100000000000.0)
  else "Adr.K.SummePlan" # Max("Adr.K.SummePlan", -100000000000.0);
  if "Adr.K.SummeEkBest">0.0 then "Adr.K.SummeEkBest" # Min("Adr.K.SummeEkBest", 100000000000.0)
  else "Adr.K.SummeEkBest" # Max("Adr.K.SummeEkBest", -100000000000.0);
end;

// -------------------------------------------------
sub EX105()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0105'
     +cnvai(RecInfo(105,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(105, _recModified);
  if "Adr.V.PreisW1">0.0 then "Adr.V.PreisW1" # Min("Adr.V.PreisW1", 100000000000.0)
  else "Adr.V.PreisW1" # Max("Adr.V.PreisW1", -100000000000.0);
  GV.Alpha.02 # Bool("Adr.V.EinkaufYN");
  GV.Alpha.03 # Bool("Adr.V.VerkaufYN");
  GV.Alpha.04 # Datum("Adr.V.Datum.Bis");
  GV.Alpha.05 # Datum("Adr.V.Datum.Von");
  if "Adr.V.Dicke">0.0 then "Adr.V.Dicke" # Min("Adr.V.Dicke", 100000000000.0)
  else "Adr.V.Dicke" # Max("Adr.V.Dicke", -100000000000.0);
  if "Adr.V.Breite">0.0 then "Adr.V.Breite" # Min("Adr.V.Breite", 100000000000.0)
  else "Adr.V.Breite" # Max("Adr.V.Breite", -100000000000.0);
  if "Adr.V.Länge">0.0 then "Adr.V.Länge" # Min("Adr.V.Länge", 100000000000.0)
  else "Adr.V.Länge" # Max("Adr.V.Länge", -100000000000.0);
  if "Adr.V.RID">0.0 then "Adr.V.RID" # Min("Adr.V.RID", 100000000000.0)
  else "Adr.V.RID" # Max("Adr.V.RID", -100000000000.0);
  if "Adr.V.RIDmax">0.0 then "Adr.V.RIDmax" # Min("Adr.V.RIDmax", 100000000000.0)
  else "Adr.V.RIDmax" # Max("Adr.V.RIDmax", -100000000000.0);
  if "Adr.V.RAD">0.0 then "Adr.V.RAD" # Min("Adr.V.RAD", 100000000000.0)
  else "Adr.V.RAD" # Max("Adr.V.RAD", -100000000000.0);
  if "Adr.V.RADmax">0.0 then "Adr.V.RADmax" # Min("Adr.V.RADmax", 100000000000.0)
  else "Adr.V.RADmax" # Max("Adr.V.RADmax", -100000000000.0);
  GV.Alpha.06 # Bool("Adr.V.StehendYN");
  GV.Alpha.07 # Bool("Adr.V.LiegendYN");
  if "Adr.V.Nettoabzug">0.0 then "Adr.V.Nettoabzug" # Min("Adr.V.Nettoabzug", 100000000000.0)
  else "Adr.V.Nettoabzug" # Max("Adr.V.Nettoabzug", -100000000000.0);
  if "Adr.V.Stapelhöhe">0.0 then "Adr.V.Stapelhöhe" # Min("Adr.V.Stapelhöhe", 100000000000.0)
  else "Adr.V.Stapelhöhe" # Max("Adr.V.Stapelhöhe", -100000000000.0);
  if "Adr.V.StapelhAbzug">0.0 then "Adr.V.StapelhAbzug" # Min("Adr.V.StapelhAbzug", 100000000000.0)
  else "Adr.V.StapelhAbzug" # Max("Adr.V.StapelhAbzug", -100000000000.0);
  if "Adr.V.RingKgVon">0.0 then "Adr.V.RingKgVon" # Min("Adr.V.RingKgVon", 100000000000.0)
  else "Adr.V.RingKgVon" # Max("Adr.V.RingKgVon", -100000000000.0);
  if "Adr.V.RingKgBis">0.0 then "Adr.V.RingKgBis" # Min("Adr.V.RingKgBis", 100000000000.0)
  else "Adr.V.RingKgBis" # Max("Adr.V.RingKgBis", -100000000000.0);
  if "Adr.V.KgmmVon">0.0 then "Adr.V.KgmmVon" # Min("Adr.V.KgmmVon", 100000000000.0)
  else "Adr.V.KgmmVon" # Max("Adr.V.KgmmVon", -100000000000.0);
  if "Adr.V.KgmmBis">0.0 then "Adr.V.KgmmBis" # Min("Adr.V.KgmmBis", 100000000000.0)
  else "Adr.V.KgmmBis" # Max("Adr.V.KgmmBis", -100000000000.0);
  if "Adr.V.VEkgMax">0.0 then "Adr.V.VEkgMax" # Min("Adr.V.VEkgMax", 100000000000.0)
  else "Adr.V.VEkgMax" # Max("Adr.V.VEkgMax", -100000000000.0);
  if "Adr.V.RechtwinkMax">0.0 then "Adr.V.RechtwinkMax" # Min("Adr.V.RechtwinkMax", 100000000000.0)
  else "Adr.V.RechtwinkMax" # Max("Adr.V.RechtwinkMax", -100000000000.0);
  if "Adr.V.EbenheitMax">0.0 then "Adr.V.EbenheitMax" # Min("Adr.V.EbenheitMax", 100000000000.0)
  else "Adr.V.EbenheitMax" # Max("Adr.V.EbenheitMax", -100000000000.0);
  if "Adr.V.SäbeligkeitMax">0.0 then "Adr.V.SäbeligkeitMax" # Min("Adr.V.SäbeligkeitMax", 100000000000.0)
  else "Adr.V.SäbeligkeitMax" # Max("Adr.V.SäbeligkeitMax", -100000000000.0);
  if "Adr.V.SäbelProM">0.0 then "Adr.V.SäbelProM" # Min("Adr.V.SäbelProM", 100000000000.0)
  else "Adr.V.SäbelProM" # Max("Adr.V.SäbelProM", -100000000000.0);
  GV.Alpha.08 # Bool("Adr.V.MitLfEYN");
  if "Adr.V.Streckgrenze1">0.0 then "Adr.V.Streckgrenze1" # Min("Adr.V.Streckgrenze1", 100000000000.0)
  else "Adr.V.Streckgrenze1" # Max("Adr.V.Streckgrenze1", -100000000000.0);
  if "Adr.V.Streckgrenze2">0.0 then "Adr.V.Streckgrenze2" # Min("Adr.V.Streckgrenze2", 100000000000.0)
  else "Adr.V.Streckgrenze2" # Max("Adr.V.Streckgrenze2", -100000000000.0);
  if "Adr.V.Zugfestigkeit1">0.0 then "Adr.V.Zugfestigkeit1" # Min("Adr.V.Zugfestigkeit1", 100000000000.0)
  else "Adr.V.Zugfestigkeit1" # Max("Adr.V.Zugfestigkeit1", -100000000000.0);
  if "Adr.V.Zugfestigkeit2">0.0 then "Adr.V.Zugfestigkeit2" # Min("Adr.V.Zugfestigkeit2", 100000000000.0)
  else "Adr.V.Zugfestigkeit2" # Max("Adr.V.Zugfestigkeit2", -100000000000.0);
  if "Adr.V.DehnungA1">0.0 then "Adr.V.DehnungA1" # Min("Adr.V.DehnungA1", 100000000000.0)
  else "Adr.V.DehnungA1" # Max("Adr.V.DehnungA1", -100000000000.0);
  if "Adr.V.DehnungA2">0.0 then "Adr.V.DehnungA2" # Min("Adr.V.DehnungA2", 100000000000.0)
  else "Adr.V.DehnungA2" # Max("Adr.V.DehnungA2", -100000000000.0);
  if "Adr.V.DehnungB1">0.0 then "Adr.V.DehnungB1" # Min("Adr.V.DehnungB1", 100000000000.0)
  else "Adr.V.DehnungB1" # Max("Adr.V.DehnungB1", -100000000000.0);
  if "Adr.V.DehnungB2">0.0 then "Adr.V.DehnungB2" # Min("Adr.V.DehnungB2", 100000000000.0)
  else "Adr.V.DehnungB2" # Max("Adr.V.DehnungB2", -100000000000.0);
  if "Adr.V.DehngrenzeA1">0.0 then "Adr.V.DehngrenzeA1" # Min("Adr.V.DehngrenzeA1", 100000000000.0)
  else "Adr.V.DehngrenzeA1" # Max("Adr.V.DehngrenzeA1", -100000000000.0);
  if "Adr.V.DehngrenzeA2">0.0 then "Adr.V.DehngrenzeA2" # Min("Adr.V.DehngrenzeA2", 100000000000.0)
  else "Adr.V.DehngrenzeA2" # Max("Adr.V.DehngrenzeA2", -100000000000.0);
  if "Adr.V.DehngrenzeB1">0.0 then "Adr.V.DehngrenzeB1" # Min("Adr.V.DehngrenzeB1", 100000000000.0)
  else "Adr.V.DehngrenzeB1" # Max("Adr.V.DehngrenzeB1", -100000000000.0);
  if "Adr.V.DehngrenzeB2">0.0 then "Adr.V.DehngrenzeB2" # Min("Adr.V.DehngrenzeB2", 100000000000.0)
  else "Adr.V.DehngrenzeB2" # Max("Adr.V.DehngrenzeB2", -100000000000.0);
  if "Adr.V.Körnung1">0.0 then "Adr.V.Körnung1" # Min("Adr.V.Körnung1", 100000000000.0)
  else "Adr.V.Körnung1" # Max("Adr.V.Körnung1", -100000000000.0);
  if "Adr.V.Körnung2">0.0 then "Adr.V.Körnung2" # Min("Adr.V.Körnung2", 100000000000.0)
  else "Adr.V.Körnung2" # Max("Adr.V.Körnung2", -100000000000.0);
  if "Adr.V.Chemie.C1">0.0 then "Adr.V.Chemie.C1" # Min("Adr.V.Chemie.C1", 100000000000.0)
  else "Adr.V.Chemie.C1" # Max("Adr.V.Chemie.C1", -100000000000.0);
  if "Adr.V.Chemie.C2">0.0 then "Adr.V.Chemie.C2" # Min("Adr.V.Chemie.C2", 100000000000.0)
  else "Adr.V.Chemie.C2" # Max("Adr.V.Chemie.C2", -100000000000.0);
  if "Adr.V.Chemie.Si1">0.0 then "Adr.V.Chemie.Si1" # Min("Adr.V.Chemie.Si1", 100000000000.0)
  else "Adr.V.Chemie.Si1" # Max("Adr.V.Chemie.Si1", -100000000000.0);
  if "Adr.V.Chemie.Si2">0.0 then "Adr.V.Chemie.Si2" # Min("Adr.V.Chemie.Si2", 100000000000.0)
  else "Adr.V.Chemie.Si2" # Max("Adr.V.Chemie.Si2", -100000000000.0);
  if "Adr.V.Chemie.Mn1">0.0 then "Adr.V.Chemie.Mn1" # Min("Adr.V.Chemie.Mn1", 100000000000.0)
  else "Adr.V.Chemie.Mn1" # Max("Adr.V.Chemie.Mn1", -100000000000.0);
  if "Adr.V.Chemie.Mn2">0.0 then "Adr.V.Chemie.Mn2" # Min("Adr.V.Chemie.Mn2", 100000000000.0)
  else "Adr.V.Chemie.Mn2" # Max("Adr.V.Chemie.Mn2", -100000000000.0);
  if "Adr.V.Chemie.P1">0.0 then "Adr.V.Chemie.P1" # Min("Adr.V.Chemie.P1", 100000000000.0)
  else "Adr.V.Chemie.P1" # Max("Adr.V.Chemie.P1", -100000000000.0);
  if "Adr.V.Chemie.P2">0.0 then "Adr.V.Chemie.P2" # Min("Adr.V.Chemie.P2", 100000000000.0)
  else "Adr.V.Chemie.P2" # Max("Adr.V.Chemie.P2", -100000000000.0);
  if "Adr.V.Chemie.S1">0.0 then "Adr.V.Chemie.S1" # Min("Adr.V.Chemie.S1", 100000000000.0)
  else "Adr.V.Chemie.S1" # Max("Adr.V.Chemie.S1", -100000000000.0);
  if "Adr.V.Chemie.S2">0.0 then "Adr.V.Chemie.S2" # Min("Adr.V.Chemie.S2", 100000000000.0)
  else "Adr.V.Chemie.S2" # Max("Adr.V.Chemie.S2", -100000000000.0);
  if "Adr.V.Chemie.Al1">0.0 then "Adr.V.Chemie.Al1" # Min("Adr.V.Chemie.Al1", 100000000000.0)
  else "Adr.V.Chemie.Al1" # Max("Adr.V.Chemie.Al1", -100000000000.0);
  if "Adr.V.Chemie.Al2">0.0 then "Adr.V.Chemie.Al2" # Min("Adr.V.Chemie.Al2", 100000000000.0)
  else "Adr.V.Chemie.Al2" # Max("Adr.V.Chemie.Al2", -100000000000.0);
  if "Adr.V.Chemie.Cr1">0.0 then "Adr.V.Chemie.Cr1" # Min("Adr.V.Chemie.Cr1", 100000000000.0)
  else "Adr.V.Chemie.Cr1" # Max("Adr.V.Chemie.Cr1", -100000000000.0);
  if "Adr.V.Chemie.Cr2">0.0 then "Adr.V.Chemie.Cr2" # Min("Adr.V.Chemie.Cr2", 100000000000.0)
  else "Adr.V.Chemie.Cr2" # Max("Adr.V.Chemie.Cr2", -100000000000.0);
  if "Adr.V.Chemie.V1">0.0 then "Adr.V.Chemie.V1" # Min("Adr.V.Chemie.V1", 100000000000.0)
  else "Adr.V.Chemie.V1" # Max("Adr.V.Chemie.V1", -100000000000.0);
  if "Adr.V.Chemie.V2">0.0 then "Adr.V.Chemie.V2" # Min("Adr.V.Chemie.V2", 100000000000.0)
  else "Adr.V.Chemie.V2" # Max("Adr.V.Chemie.V2", -100000000000.0);
  if "Adr.V.Chemie.Nb1">0.0 then "Adr.V.Chemie.Nb1" # Min("Adr.V.Chemie.Nb1", 100000000000.0)
  else "Adr.V.Chemie.Nb1" # Max("Adr.V.Chemie.Nb1", -100000000000.0);
  if "Adr.V.Chemie.Nb2">0.0 then "Adr.V.Chemie.Nb2" # Min("Adr.V.Chemie.Nb2", 100000000000.0)
  else "Adr.V.Chemie.Nb2" # Max("Adr.V.Chemie.Nb2", -100000000000.0);
  if "Adr.V.Chemie.Ti1">0.0 then "Adr.V.Chemie.Ti1" # Min("Adr.V.Chemie.Ti1", 100000000000.0)
  else "Adr.V.Chemie.Ti1" # Max("Adr.V.Chemie.Ti1", -100000000000.0);
  if "Adr.V.Chemie.Ti2">0.0 then "Adr.V.Chemie.Ti2" # Min("Adr.V.Chemie.Ti2", 100000000000.0)
  else "Adr.V.Chemie.Ti2" # Max("Adr.V.Chemie.Ti2", -100000000000.0);
  if "Adr.V.Chemie.N1">0.0 then "Adr.V.Chemie.N1" # Min("Adr.V.Chemie.N1", 100000000000.0)
  else "Adr.V.Chemie.N1" # Max("Adr.V.Chemie.N1", -100000000000.0);
  if "Adr.V.Chemie.N2">0.0 then "Adr.V.Chemie.N2" # Min("Adr.V.Chemie.N2", 100000000000.0)
  else "Adr.V.Chemie.N2" # Max("Adr.V.Chemie.N2", -100000000000.0);
  if "Adr.V.Chemie.Cu1">0.0 then "Adr.V.Chemie.Cu1" # Min("Adr.V.Chemie.Cu1", 100000000000.0)
  else "Adr.V.Chemie.Cu1" # Max("Adr.V.Chemie.Cu1", -100000000000.0);
  if "Adr.V.Chemie.Cu2">0.0 then "Adr.V.Chemie.Cu2" # Min("Adr.V.Chemie.Cu2", 100000000000.0)
  else "Adr.V.Chemie.Cu2" # Max("Adr.V.Chemie.Cu2", -100000000000.0);
  if "Adr.V.Chemie.Ni1">0.0 then "Adr.V.Chemie.Ni1" # Min("Adr.V.Chemie.Ni1", 100000000000.0)
  else "Adr.V.Chemie.Ni1" # Max("Adr.V.Chemie.Ni1", -100000000000.0);
  if "Adr.V.Chemie.Ni2">0.0 then "Adr.V.Chemie.Ni2" # Min("Adr.V.Chemie.Ni2", 100000000000.0)
  else "Adr.V.Chemie.Ni2" # Max("Adr.V.Chemie.Ni2", -100000000000.0);
  if "Adr.V.Chemie.Mo1">0.0 then "Adr.V.Chemie.Mo1" # Min("Adr.V.Chemie.Mo1", 100000000000.0)
  else "Adr.V.Chemie.Mo1" # Max("Adr.V.Chemie.Mo1", -100000000000.0);
  if "Adr.V.Chemie.Mo2">0.0 then "Adr.V.Chemie.Mo2" # Min("Adr.V.Chemie.Mo2", 100000000000.0)
  else "Adr.V.Chemie.Mo2" # Max("Adr.V.Chemie.Mo2", -100000000000.0);
  if "Adr.V.Chemie.B1">0.0 then "Adr.V.Chemie.B1" # Min("Adr.V.Chemie.B1", 100000000000.0)
  else "Adr.V.Chemie.B1" # Max("Adr.V.Chemie.B1", -100000000000.0);
  if "Adr.V.Chemie.B2">0.0 then "Adr.V.Chemie.B2" # Min("Adr.V.Chemie.B2", 100000000000.0)
  else "Adr.V.Chemie.B2" # Max("Adr.V.Chemie.B2", -100000000000.0);
  if "Adr.V.Härte1">0.0 then "Adr.V.Härte1" # Min("Adr.V.Härte1", 100000000000.0)
  else "Adr.V.Härte1" # Max("Adr.V.Härte1", -100000000000.0);
  if "Adr.V.Härte2">0.0 then "Adr.V.Härte2" # Min("Adr.V.Härte2", 100000000000.0)
  else "Adr.V.Härte2" # Max("Adr.V.Härte2", -100000000000.0);
  if "Adr.V.Chemie.Frei1.1">0.0 then "Adr.V.Chemie.Frei1.1" # Min("Adr.V.Chemie.Frei1.1", 100000000000.0)
  else "Adr.V.Chemie.Frei1.1" # Max("Adr.V.Chemie.Frei1.1", -100000000000.0);
  if "Adr.V.Chemie.Frei1.2">0.0 then "Adr.V.Chemie.Frei1.2" # Min("Adr.V.Chemie.Frei1.2", 100000000000.0)
  else "Adr.V.Chemie.Frei1.2" # Max("Adr.V.Chemie.Frei1.2", -100000000000.0);
  if "Adr.V.RauigkeitA1">0.0 then "Adr.V.RauigkeitA1" # Min("Adr.V.RauigkeitA1", 100000000000.0)
  else "Adr.V.RauigkeitA1" # Max("Adr.V.RauigkeitA1", -100000000000.0);
  if "Adr.V.RauigkeitA2">0.0 then "Adr.V.RauigkeitA2" # Min("Adr.V.RauigkeitA2", 100000000000.0)
  else "Adr.V.RauigkeitA2" # Max("Adr.V.RauigkeitA2", -100000000000.0);
  if "Adr.V.RauigkeitB1">0.0 then "Adr.V.RauigkeitB1" # Min("Adr.V.RauigkeitB1", 100000000000.0)
  else "Adr.V.RauigkeitB1" # Max("Adr.V.RauigkeitB1", -100000000000.0);
  if "Adr.V.RauigkeitB2">0.0 then "Adr.V.RauigkeitB2" # Min("Adr.V.RauigkeitB2", 100000000000.0)
  else "Adr.V.RauigkeitB2" # Max("Adr.V.RauigkeitB2", -100000000000.0);
end;

// -------------------------------------------------
sub EX106()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0106'
     +cnvai(RecInfo(106,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(106, _recModified);
end;

// -------------------------------------------------
sub EX107()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0107'
     +cnvai(RecInfo(107,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(107, _recModified);
end;

// -------------------------------------------------
sub EX120()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0120'
     +cnvai(RecInfo(120,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("Prj.Anlage.Datum");
  GV.Int64.01 # RecInfo(120, _recModified);
  GV.Alpha.03 # Datum("Prj.Termin.Start");
  GV.Alpha.04 # Datum("Prj.Termin.Ende");
  GV.Alpha.05 # Datum("Prj.Wtg.LetztesDatum");
  GV.Alpha.06 # Bool("Prj.AustauschYN");
  GV.Alpha.07 # Bool("Prj.VorlageYN");
  if "Prj.Cust.Wert1">0.0 then "Prj.Cust.Wert1" # Min("Prj.Cust.Wert1", 100000000000.0)
  else "Prj.Cust.Wert1" # Max("Prj.Cust.Wert1", -100000000000.0);
  if "Prj.Cust.Wert2">0.0 then "Prj.Cust.Wert2" # Min("Prj.Cust.Wert2", 100000000000.0)
  else "Prj.Cust.Wert2" # Max("Prj.Cust.Wert2", -100000000000.0);
  if "Prj.Cust.Wert3">0.0 then "Prj.Cust.Wert3" # Min("Prj.Cust.Wert3", 100000000000.0)
  else "Prj.Cust.Wert3" # Max("Prj.Cust.Wert3", -100000000000.0);
  if "Prj.Cust.Wert4">0.0 then "Prj.Cust.Wert4" # Min("Prj.Cust.Wert4", 100000000000.0)
  else "Prj.Cust.Wert4" # Max("Prj.Cust.Wert4", -100000000000.0);
  if "Prj.Cust.Wert5">0.0 then "Prj.Cust.Wert5" # Min("Prj.Cust.Wert5", 100000000000.0)
  else "Prj.Cust.Wert5" # Max("Prj.Cust.Wert5", -100000000000.0);
  if "Prj.Cust.Wert6">0.0 then "Prj.Cust.Wert6" # Min("Prj.Cust.Wert6", 100000000000.0)
  else "Prj.Cust.Wert6" # Max("Prj.Cust.Wert6", -100000000000.0);
end;

// -------------------------------------------------
sub EX122()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0122'
     +cnvai(RecInfo(122,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("Prj.P.Anlage.Datum");
  GV.Int64.01 # RecInfo(122, _recModified);
  if "Prj.P.Dauer">0.0 then "Prj.P.Dauer" # Min("Prj.P.Dauer", 100000000000.0)
  else "Prj.P.Dauer" # Max("Prj.P.Dauer", -100000000000.0);
  if "Prj.P.Dauer.Intern">0.0 then "Prj.P.Dauer.Intern" # Min("Prj.P.Dauer.Intern", 100000000000.0)
  else "Prj.P.Dauer.Intern" # Max("Prj.P.Dauer.Intern", -100000000000.0);
  if "Prj.P.Dauer.Extern">0.0 then "Prj.P.Dauer.Extern" # Min("Prj.P.Dauer.Extern", 100000000000.0)
  else "Prj.P.Dauer.Extern" # Max("Prj.P.Dauer.Extern", -100000000000.0);
  if "Prj.P.Dauer.Angebot">0.0 then "Prj.P.Dauer.Angebot" # Min("Prj.P.Dauer.Angebot", 100000000000.0)
  else "Prj.P.Dauer.Angebot" # Max("Prj.P.Dauer.Angebot", -100000000000.0);
  GV.Alpha.03 # Datum("Prj.P.Datum.Start");
  GV.Alpha.04 # Datum("Prj.P.Datum.Ende");
  if "Prj.P.ZusKosten">0.0 then "Prj.P.ZusKosten" # Min("Prj.P.ZusKosten", 100000000000.0)
  else "Prj.P.ZusKosten" # Max("Prj.P.ZusKosten", -100000000000.0);
  if "Prj.P.ZusKosten.Plan">0.0 then "Prj.P.ZusKosten.Plan" # Min("Prj.P.ZusKosten.Plan", 100000000000.0)
  else "Prj.P.ZusKosten.Plan" # Max("Prj.P.ZusKosten.Plan", -100000000000.0);
  GV.Alpha.05 # Datum("Prj.P.PrioritätDatum");
  GV.Alpha.06 # Datum("Prj.P.Status.Datum");
  GV.Alpha.07 # Zeit("Prj.P.Status.Zeit");
  if "Prj.P.Cust.Num01">0.0 then "Prj.P.Cust.Num01" # Min("Prj.P.Cust.Num01", 100000000000.0)
  else "Prj.P.Cust.Num01" # Max("Prj.P.Cust.Num01", -100000000000.0);
  if "Prj.P.Cust.Num02">0.0 then "Prj.P.Cust.Num02" # Min("Prj.P.Cust.Num02", 100000000000.0)
  else "Prj.P.Cust.Num02" # Max("Prj.P.Cust.Num02", -100000000000.0);
end;

// -------------------------------------------------
sub EX123()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0123'
     +cnvai(RecInfo(123,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(123, _recModified);
  GV.Alpha.02 # Datum("Prj.Z.Start.Datum");
  GV.Alpha.03 # Zeit("Prj.Z.Start.Zeit");
  GV.Alpha.04 # Datum("Prj.Z.End.Datum");
  GV.Alpha.05 # Zeit("Prj.Z.End.Zeit");
  if "Prj.Z.Dauer">0.0 then "Prj.Z.Dauer" # Min("Prj.Z.Dauer", 100000000000.0)
  else "Prj.Z.Dauer" # Max("Prj.Z.Dauer", -100000000000.0);
  if "Prj.Z.Dauer.Plan">0.0 then "Prj.Z.Dauer.Plan" # Min("Prj.Z.Dauer.Plan", 100000000000.0)
  else "Prj.Z.Dauer.Plan" # Max("Prj.Z.Dauer.Plan", -100000000000.0);
  if "Prj.Z.ZusKosten">0.0 then "Prj.Z.ZusKosten" # Min("Prj.Z.ZusKosten", 100000000000.0)
  else "Prj.Z.ZusKosten" # Max("Prj.Z.ZusKosten", -100000000000.0);
  if "Prj.Z.ZusKosten.Plan">0.0 then "Prj.Z.ZusKosten.Plan" # Min("Prj.Z.ZusKosten.Plan", 100000000000.0)
  else "Prj.Z.ZusKosten.Plan" # Max("Prj.Z.ZusKosten.Plan", -100000000000.0);
end;

// -------------------------------------------------
sub EX160()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0160'
     +cnvai(RecInfo(160,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(160, _recModified);
  if "Rso.PreisProH">0.0 then "Rso.PreisProH" # Min("Rso.PreisProH", 100000000000.0)
  else "Rso.PreisProH" # Max("Rso.PreisProH", -100000000000.0);
  if "Rso.PreisProAusfallH">0.0 then "Rso.PreisProAusfallH" # Min("Rso.PreisProAusfallH", 100000000000.0)
  else "Rso.PreisProAusfallH" # Max("Rso.PreisProAusfallH", -100000000000.0);
  if "Rso.MengeProH">0.0 then "Rso.MengeProH" # Min("Rso.MengeProH", 100000000000.0)
  else "Rso.MengeProH" # Max("Rso.MengeProH", -100000000000.0);
  GV.Alpha.02 # Bool("Rso.autoLaufzeitYN");
  if "Rso.LeistungKWatt">0.0 then "Rso.LeistungKWatt" # Min("Rso.LeistungKWatt", 100000000000.0)
  else "Rso.LeistungKWatt" # Max("Rso.LeistungKWatt", -100000000000.0);
  if "Rso.CO2ProT">0.0 then "Rso.CO2ProT" # Min("Rso.CO2ProT", 100000000000.0)
  else "Rso.CO2ProT" # Max("Rso.CO2ProT", -100000000000.0);
  if "Rso.t_Rüstbasis">0.0 then "Rso.t_Rüstbasis" # Min("Rso.t_Rüstbasis", 100000000000.0)
  else "Rso.t_Rüstbasis" # Max("Rso.t_Rüstbasis", -100000000000.0);
  if "Rso.t_RüstJeInputStk">0.0 then "Rso.t_RüstJeInputStk" # Min("Rso.t_RüstJeInputStk", 100000000000.0)
  else "Rso.t_RüstJeInputStk" # Max("Rso.t_RüstJeInputStk", -100000000000.0);
  if "Rso.t_RüstJeInputLfd">0.0 then "Rso.t_RüstJeInputLfd" # Min("Rso.t_RüstJeInputLfd", 100000000000.0)
  else "Rso.t_RüstJeInputLfd" # Max("Rso.t_RüstJeInputLfd", -100000000000.0);
  if "Rso.t_Prodbasis">0.0 then "Rso.t_Prodbasis" # Min("Rso.t_Prodbasis", 100000000000.0)
  else "Rso.t_Prodbasis" # Max("Rso.t_Prodbasis", -100000000000.0);
  if "Rso.t_ProdJeOutStk">0.0 then "Rso.t_ProdJeOutStk" # Min("Rso.t_ProdJeOutStk", 100000000000.0)
  else "Rso.t_ProdJeOutStk" # Max("Rso.t_ProdJeOutStk", -100000000000.0);
  if "Rso.t_ProdJeOutLfd">0.0 then "Rso.t_ProdJeOutLfd" # Min("Rso.t_ProdJeOutLfd", 100000000000.0)
  else "Rso.t_ProdJeOutLfd" # Max("Rso.t_ProdJeOutLfd", -100000000000.0);
  if "Rso.t_Absetzbasis">0.0 then "Rso.t_Absetzbasis" # Min("Rso.t_Absetzbasis", 100000000000.0)
  else "Rso.t_Absetzbasis" # Max("Rso.t_Absetzbasis", -100000000000.0);
  if "Rso.t_AbsetzJeInpStk">0.0 then "Rso.t_AbsetzJeInpStk" # Min("Rso.t_AbsetzJeInpStk", 100000000000.0)
  else "Rso.t_AbsetzJeInpStk" # Max("Rso.t_AbsetzJeInpStk", -100000000000.0);
  if "Rso.t_AbsetzJeInpLfd">0.0 then "Rso.t_AbsetzJeInpLfd" # Min("Rso.t_AbsetzJeInpLfd", 100000000000.0)
  else "Rso.t_AbsetzJeInpLfd" # Max("Rso.t_AbsetzJeInpLfd", -100000000000.0);
  if "Rso.t_AbsetzJeOutVPE">0.0 then "Rso.t_AbsetzJeOutVPE" # Min("Rso.t_AbsetzJeOutVPE", 100000000000.0)
  else "Rso.t_AbsetzJeOutVPE" # Max("Rso.t_AbsetzJeOutVPE", -100000000000.0);
  if "Rso.t_AbsetzJeOutStk">0.0 then "Rso.t_AbsetzJeOutStk" # Min("Rso.t_AbsetzJeOutStk", 100000000000.0)
  else "Rso.t_AbsetzJeOutStk" # Max("Rso.t_AbsetzJeOutStk", -100000000000.0);
  if "Rso.t_AbsetzJeOutLfd">0.0 then "Rso.t_AbsetzJeOutLfd" # Min("Rso.t_AbsetzJeOutLfd", 100000000000.0)
  else "Rso.t_AbsetzJeOutLfd" # Max("Rso.t_AbsetzJeOutLfd", -100000000000.0);
  if "Rso.t_Messerbau">0.0 then "Rso.t_Messerbau" # Min("Rso.t_Messerbau", 100000000000.0)
  else "Rso.t_Messerbau" # Max("Rso.t_Messerbau", -100000000000.0);
  if "Rso.t_Längenänderung">0.0 then "Rso.t_Längenänderung" # Min("Rso.t_Längenänderung", 100000000000.0)
  else "Rso.t_Längenänderung" # Max("Rso.t_Längenänderung", -100000000000.0);
  if "Rso.Proz_Besäumen">0.0 then "Rso.Proz_Besäumen" # Min("Rso.Proz_Besäumen", 100000000000.0)
  else "Rso.Proz_Besäumen" # Max("Rso.Proz_Besäumen", -100000000000.0);
end;

// -------------------------------------------------
sub EX163()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0163'
     +cnvai(RecInfo(163,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(163, _recModified);
  GV.Alpha.02 # Datum("Rso.Kal.Datum");
end;

// -------------------------------------------------
sub EX165()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0165'
     +cnvai(RecInfo(165,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(165, _recModified);
  GV.Alpha.02 # Bool("Rso.IHA.WartungYN");
  GV.Alpha.03 # Datum("Rso.IHA.Termin");
  GV.Alpha.04 # Datum("Rso.IHA.DatumEnde");
  if "Rso.IHA.Zeit.Ausfall">0.0 then "Rso.IHA.Zeit.Ausfall" # Min("Rso.IHA.Zeit.Ausfall", 100000000000.0)
  else "Rso.IHA.Zeit.Ausfall" # Max("Rso.IHA.Zeit.Ausfall", -100000000000.0);
  if "Rso.IHA.Zeit.Repara">0.0 then "Rso.IHA.Zeit.Repara" # Min("Rso.IHA.Zeit.Repara", 100000000000.0)
  else "Rso.IHA.Zeit.Repara" # Max("Rso.IHA.Zeit.Repara", -100000000000.0);
end;

// -------------------------------------------------
sub EX166()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0166'
     +cnvai(RecInfo(166,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(166, _recModified);
  GV.Alpha.02 # Bool("Rso.Urs.WartungYN");
end;

// -------------------------------------------------
sub EX167()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0167'
     +cnvai(RecInfo(167,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(167, _recModified);
  GV.Alpha.02 # Bool("Rso.Maß.WartungYN");
end;

// -------------------------------------------------
sub EX170()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0170'
     +cnvai(RecInfo(170,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(170, _recModified);
  if "Rso.R.Menge">0.0 then "Rso.R.Menge" # Min("Rso.R.Menge", 100000000000.0)
  else "Rso.R.Menge" # Max("Rso.R.Menge", -100000000000.0);
  GV.Alpha.02 # Datum("Rso.R.MinDat.Start");
  GV.Alpha.03 # Zeit("Rso.R.MinZeit.Start");
  GV.Alpha.04 # Datum("Rso.R.MinDat.Ende");
  GV.Alpha.05 # Zeit("Rso.R.MinZeit.Ende");
  GV.Alpha.06 # Datum("Rso.R.MaxDat.Start");
  GV.Alpha.07 # Zeit("Rso.R.MaxZeit.Start");
  GV.Alpha.08 # Datum("Rso.R.MaxDat.Ende");
  GV.Alpha.09 # Zeit("Rso.R.MaxZeit.Ende");
  GV.Alpha.10 # Datum("Rso.R.Plan.StartDat");
  GV.Alpha.11 # Zeit("Rso.R.Plan.StartZeit");
  GV.Alpha.12 # Datum("Rso.R.Plan.EndDat");
  GV.Alpha.13 # Zeit("Rso.R.Plan.EndZeit");
end;

// -------------------------------------------------
sub EX171()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0171'
     +cnvai(RecInfo(171,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(171, _recModified);
end;

// -------------------------------------------------
sub EX182()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0182'
     +cnvai(RecInfo(182,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(182, _recModified);
  GV.Alpha.02 # Datum("HuB.J.Datum");
  GV.Alpha.03 # Zeit("HuB.J.Zeit");
  if "HuB.J.Menge.Vorher">0.0 then "HuB.J.Menge.Vorher" # Min("HuB.J.Menge.Vorher", 100000000000.0)
  else "HuB.J.Menge.Vorher" # Max("HuB.J.Menge.Vorher", -100000000000.0);
  if "HuB.J.Menge.Diff">0.0 then "HuB.J.Menge.Diff" # Min("HuB.J.Menge.Diff", 100000000000.0)
  else "HuB.J.Menge.Diff" # Max("HuB.J.Menge.Diff", -100000000000.0);
end;

// -------------------------------------------------
sub EX200()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0200'
     +cnvai(RecInfo(200,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("Mat.Anlage.Datum");
  GV.Int64.01 # RecInfo(200, _recModified);
  GV.Alpha.03 # Bool("Mat.EigenmaterialYN");
  GV.Alpha.04 # Datum("Mat.Übernahmedatum");
  if "Mat.Dicke">0.0 then "Mat.Dicke" # Min("Mat.Dicke", 100000000000.0)
  else "Mat.Dicke" # Max("Mat.Dicke", -100000000000.0);
  if "Mat.Dicke.Von">0.0 then "Mat.Dicke.Von" # Min("Mat.Dicke.Von", 100000000000.0)
  else "Mat.Dicke.Von" # Max("Mat.Dicke.Von", -100000000000.0);
  if "Mat.Dicke.Bis">0.0 then "Mat.Dicke.Bis" # Min("Mat.Dicke.Bis", 100000000000.0)
  else "Mat.Dicke.Bis" # Max("Mat.Dicke.Bis", -100000000000.0);
  GV.Alpha.05 # Bool("Mat.DickenTolYN");
  if "Mat.DickenTol.Von">0.0 then "Mat.DickenTol.Von" # Min("Mat.DickenTol.Von", 100000000000.0)
  else "Mat.DickenTol.Von" # Max("Mat.DickenTol.Von", -100000000000.0);
  if "Mat.DickenTol.Bis">0.0 then "Mat.DickenTol.Bis" # Min("Mat.DickenTol.Bis", 100000000000.0)
  else "Mat.DickenTol.Bis" # Max("Mat.DickenTol.Bis", -100000000000.0);
  if "Mat.Breite">0.0 then "Mat.Breite" # Min("Mat.Breite", 100000000000.0)
  else "Mat.Breite" # Max("Mat.Breite", -100000000000.0);
  if "Mat.Breite.Von">0.0 then "Mat.Breite.Von" # Min("Mat.Breite.Von", 100000000000.0)
  else "Mat.Breite.Von" # Max("Mat.Breite.Von", -100000000000.0);
  if "Mat.Breite.Bis">0.0 then "Mat.Breite.Bis" # Min("Mat.Breite.Bis", 100000000000.0)
  else "Mat.Breite.Bis" # Max("Mat.Breite.Bis", -100000000000.0);
  GV.Alpha.06 # Bool("Mat.BreitenTolYN");
  if "Mat.BreitenTol.Von">0.0 then "Mat.BreitenTol.Von" # Min("Mat.BreitenTol.Von", 100000000000.0)
  else "Mat.BreitenTol.Von" # Max("Mat.BreitenTol.Von", -100000000000.0);
  if "Mat.BreitenTol.Bis">0.0 then "Mat.BreitenTol.Bis" # Min("Mat.BreitenTol.Bis", 100000000000.0)
  else "Mat.BreitenTol.Bis" # Max("Mat.BreitenTol.Bis", -100000000000.0);
  if "Mat.Länge">0.0 then "Mat.Länge" # Min("Mat.Länge", 100000000000.0)
  else "Mat.Länge" # Max("Mat.Länge", -100000000000.0);
  if "Mat.Länge.Von">0.0 then "Mat.Länge.Von" # Min("Mat.Länge.Von", 100000000000.0)
  else "Mat.Länge.Von" # Max("Mat.Länge.Von", -100000000000.0);
  if "Mat.Länge.Bis">0.0 then "Mat.Länge.Bis" # Min("Mat.Länge.Bis", 100000000000.0)
  else "Mat.Länge.Bis" # Max("Mat.Länge.Bis", -100000000000.0);
  GV.Alpha.07 # Bool("Mat.LängenTolYN");
  if "Mat.LängenTol.Von">0.0 then "Mat.LängenTol.Von" # Min("Mat.LängenTol.Von", 100000000000.0)
  else "Mat.LängenTol.Von" # Max("Mat.LängenTol.Von", -100000000000.0);
  if "Mat.LängenTol.Bis">0.0 then "Mat.LängenTol.Bis" # Min("Mat.LängenTol.Bis", 100000000000.0)
  else "Mat.LängenTol.Bis" # Max("Mat.LängenTol.Bis", -100000000000.0);
  if "Mat.RID">0.0 then "Mat.RID" # Min("Mat.RID", 100000000000.0)
  else "Mat.RID" # Max("Mat.RID", -100000000000.0);
  if "Mat.RAD">0.0 then "Mat.RAD" # Min("Mat.RAD", 100000000000.0)
  else "Mat.RAD" # Max("Mat.RAD", -100000000000.0);
  if "Mat.Kgmm">0.0 then "Mat.Kgmm" # Min("Mat.Kgmm", 100000000000.0)
  else "Mat.Kgmm" # Max("Mat.Kgmm", -100000000000.0);
  if "Mat.Dichte">0.0 then "Mat.Dichte" # Min("Mat.Dichte", 100000000000.0)
  else "Mat.Dichte" # Max("Mat.Dichte", -100000000000.0);
  if "Mat.Bestand.Gew">0.0 then "Mat.Bestand.Gew" # Min("Mat.Bestand.Gew", 100000000000.0)
  else "Mat.Bestand.Gew" # Max("Mat.Bestand.Gew", -100000000000.0);
  if "Mat.Bestellt.Gew">0.0 then "Mat.Bestellt.Gew" # Min("Mat.Bestellt.Gew", 100000000000.0)
  else "Mat.Bestellt.Gew" # Max("Mat.Bestellt.Gew", -100000000000.0);
  if "Mat.Reserviert.Gew">0.0 then "Mat.Reserviert.Gew" # Min("Mat.Reserviert.Gew", 100000000000.0)
  else "Mat.Reserviert.Gew" # Max("Mat.Reserviert.Gew", -100000000000.0);
  if "Mat.Verfügbar.Gew">0.0 then "Mat.Verfügbar.Gew" # Min("Mat.Verfügbar.Gew", 100000000000.0)
  else "Mat.Verfügbar.Gew" # Max("Mat.Verfügbar.Gew", -100000000000.0);
  if "Mat.EK.Preis">0.0 then "Mat.EK.Preis" # Min("Mat.EK.Preis", 100000000000.0)
  else "Mat.EK.Preis" # Max("Mat.EK.Preis", -100000000000.0);
  if "Mat.Kosten">0.0 then "Mat.Kosten" # Min("Mat.Kosten", 100000000000.0)
  else "Mat.Kosten" # Max("Mat.Kosten", -100000000000.0);
  if "Mat.EK.Effektiv">0.0 then "Mat.EK.Effektiv" # Min("Mat.EK.Effektiv", 100000000000.0)
  else "Mat.EK.Effektiv" # Max("Mat.EK.Effektiv", -100000000000.0);
  if "Mat.EK.Preis2">0.0 then "Mat.EK.Preis2" # Min("Mat.EK.Preis2", 100000000000.0)
  else "Mat.EK.Preis2" # Max("Mat.EK.Preis2", -100000000000.0);
  if "Mat.Reserviert2.Gew">0.0 then "Mat.Reserviert2.Gew" # Min("Mat.Reserviert2.Gew", 100000000000.0)
  else "Mat.Reserviert2.Gew" # Max("Mat.Reserviert2.Gew", -100000000000.0);
  if "Mat.Bestand.Menge">0.0 then "Mat.Bestand.Menge" # Min("Mat.Bestand.Menge", 100000000000.0)
  else "Mat.Bestand.Menge" # Max("Mat.Bestand.Menge", -100000000000.0);
  if "Mat.Bestellt.Menge">0.0 then "Mat.Bestellt.Menge" # Min("Mat.Bestellt.Menge", 100000000000.0)
  else "Mat.Bestellt.Menge" # Max("Mat.Bestellt.Menge", -100000000000.0);
  if "Mat.Reserviert.Menge">0.0 then "Mat.Reserviert.Menge" # Min("Mat.Reserviert.Menge", 100000000000.0)
  else "Mat.Reserviert.Menge" # Max("Mat.Reserviert.Menge", -100000000000.0);
  if "Mat.Verfügbar.Menge">0.0 then "Mat.Verfügbar.Menge" # Min("Mat.Verfügbar.Menge", 100000000000.0)
  else "Mat.Verfügbar.Menge" # Max("Mat.Verfügbar.Menge", -100000000000.0);
  if "Mat.EK.PreisProMEH">0.0 then "Mat.EK.PreisProMEH" # Min("Mat.EK.PreisProMEH", 100000000000.0)
  else "Mat.EK.PreisProMEH" # Max("Mat.EK.PreisProMEH", -100000000000.0);
  if "Mat.KostenProMEH">0.0 then "Mat.KostenProMEH" # Min("Mat.KostenProMEH", 100000000000.0)
  else "Mat.KostenProMEH" # Max("Mat.KostenProMEH", -100000000000.0);
  if "Mat.EK.EffektivProME">0.0 then "Mat.EK.EffektivProME" # Min("Mat.EK.EffektivProME", 100000000000.0)
  else "Mat.EK.EffektivProME" # Max("Mat.EK.EffektivProME", -100000000000.0);
  if "Mat.Reserviert2.Meng">0.0 then "Mat.Reserviert2.Meng" # Min("Mat.Reserviert2.Meng", 100000000000.0)
  else "Mat.Reserviert2.Meng" # Max("Mat.Reserviert2.Meng", -100000000000.0);
  GV.Alpha.08 # Datum("Mat.Bestelldatum");
  GV.Alpha.09 # Datum("Mat.BestellTermin");
  GV.Alpha.10 # Datum("Mat.Eingangsdatum");
  GV.Alpha.11 # Datum("Mat.Ausgangsdatum");
  GV.Alpha.12 # Datum("Mat.Inventurdatum");
  GV.Alpha.13 # Datum("Mat.VK.Rechdatum");
  if "Mat.VK.Preis">0.0 then "Mat.VK.Preis" # Min("Mat.VK.Preis", 100000000000.0)
  else "Mat.VK.Preis" # Max("Mat.VK.Preis", -100000000000.0);
  if "Mat.VK.Gewicht">0.0 then "Mat.VK.Gewicht" # Min("Mat.VK.Gewicht", 100000000000.0)
  else "Mat.VK.Gewicht" # Max("Mat.VK.Gewicht", -100000000000.0);
  GV.Alpha.14 # Datum("Mat.EK.RechDatum");
  GV.Alpha.15 # Datum("Mat.Datum.Lagergeld");
  GV.Alpha.16 # Datum("Mat.Datum.Zinsen");
  GV.Alpha.17 # Datum("Mat.Datum.Erzeugt");
  GV.Alpha.18 # Datum("Mat.Datum.VSBMeldung");
  if "Mat.VK.Korrektur">0.0 then "Mat.VK.Korrektur" # Min("Mat.VK.Korrektur", 100000000000.0)
  else "Mat.VK.Korrektur" # Max("Mat.VK.Korrektur", -100000000000.0);
  GV.Alpha.19 # Bool("Mat.Inventur.DruckYN");
  GV.Alpha.20 # Datum("Mat.Abrufdatum");
  GV.Alpha.21 # Datum("Mat.AbgerufenAm");
  GV.Alpha.22 # Datum("Mat.QS.Datum");
  GV.Alpha.23 # Zeit("Mat.QS.Zeit");
  GV.Alpha.24 # Bool("Mat.QS.FehlerYN");
  GV.Alpha.25 # Bool("Mat.StreckeYN");
  if "Mat.Streckgrenze1">0.0 then "Mat.Streckgrenze1" # Min("Mat.Streckgrenze1", 100000000000.0)
  else "Mat.Streckgrenze1" # Max("Mat.Streckgrenze1", -100000000000.0);
  if "Mat.Streckgrenze2">0.0 then "Mat.Streckgrenze2" # Min("Mat.Streckgrenze2", 100000000000.0)
  else "Mat.Streckgrenze2" # Max("Mat.Streckgrenze2", -100000000000.0);
  if "Mat.Zugfestigkeit1">0.0 then "Mat.Zugfestigkeit1" # Min("Mat.Zugfestigkeit1", 100000000000.0)
  else "Mat.Zugfestigkeit1" # Max("Mat.Zugfestigkeit1", -100000000000.0);
  if "Mat.Zugfestigkeit2">0.0 then "Mat.Zugfestigkeit2" # Min("Mat.Zugfestigkeit2", 100000000000.0)
  else "Mat.Zugfestigkeit2" # Max("Mat.Zugfestigkeit2", -100000000000.0);
  if "Mat.DehnungA1">0.0 then "Mat.DehnungA1" # Min("Mat.DehnungA1", 100000000000.0)
  else "Mat.DehnungA1" # Max("Mat.DehnungA1", -100000000000.0);
  if "Mat.DehnungA2">0.0 then "Mat.DehnungA2" # Min("Mat.DehnungA2", 100000000000.0)
  else "Mat.DehnungA2" # Max("Mat.DehnungA2", -100000000000.0);
  if "Mat.DehnungB1">0.0 then "Mat.DehnungB1" # Min("Mat.DehnungB1", 100000000000.0)
  else "Mat.DehnungB1" # Max("Mat.DehnungB1", -100000000000.0);
  if "Mat.DehnungB2">0.0 then "Mat.DehnungB2" # Min("Mat.DehnungB2", 100000000000.0)
  else "Mat.DehnungB2" # Max("Mat.DehnungB2", -100000000000.0);
  if "Mat.RP02_V1">0.0 then "Mat.RP02_V1" # Min("Mat.RP02_V1", 100000000000.0)
  else "Mat.RP02_V1" # Max("Mat.RP02_V1", -100000000000.0);
  if "Mat.RP02_V2">0.0 then "Mat.RP02_V2" # Min("Mat.RP02_V2", 100000000000.0)
  else "Mat.RP02_V2" # Max("Mat.RP02_V2", -100000000000.0);
  if "Mat.RP10_V1">0.0 then "Mat.RP10_V1" # Min("Mat.RP10_V1", 100000000000.0)
  else "Mat.RP10_V1" # Max("Mat.RP10_V1", -100000000000.0);
  if "Mat.RP10_V2">0.0 then "Mat.RP10_V2" # Min("Mat.RP10_V2", 100000000000.0)
  else "Mat.RP10_V2" # Max("Mat.RP10_V2", -100000000000.0);
  if "Mat.Körnung1">0.0 then "Mat.Körnung1" # Min("Mat.Körnung1", 100000000000.0)
  else "Mat.Körnung1" # Max("Mat.Körnung1", -100000000000.0);
  if "Mat.Körnung2">0.0 then "Mat.Körnung2" # Min("Mat.Körnung2", 100000000000.0)
  else "Mat.Körnung2" # Max("Mat.Körnung2", -100000000000.0);
  if "Mat.Chemie.C1">0.0 then "Mat.Chemie.C1" # Min("Mat.Chemie.C1", 100000000000.0)
  else "Mat.Chemie.C1" # Max("Mat.Chemie.C1", -100000000000.0);
  if "Mat.Chemie.C2">0.0 then "Mat.Chemie.C2" # Min("Mat.Chemie.C2", 100000000000.0)
  else "Mat.Chemie.C2" # Max("Mat.Chemie.C2", -100000000000.0);
  if "Mat.Chemie.Si1">0.0 then "Mat.Chemie.Si1" # Min("Mat.Chemie.Si1", 100000000000.0)
  else "Mat.Chemie.Si1" # Max("Mat.Chemie.Si1", -100000000000.0);
  if "Mat.Chemie.Si2">0.0 then "Mat.Chemie.Si2" # Min("Mat.Chemie.Si2", 100000000000.0)
  else "Mat.Chemie.Si2" # Max("Mat.Chemie.Si2", -100000000000.0);
  if "Mat.Chemie.Mn1">0.0 then "Mat.Chemie.Mn1" # Min("Mat.Chemie.Mn1", 100000000000.0)
  else "Mat.Chemie.Mn1" # Max("Mat.Chemie.Mn1", -100000000000.0);
  if "Mat.Chemie.Mn2">0.0 then "Mat.Chemie.Mn2" # Min("Mat.Chemie.Mn2", 100000000000.0)
  else "Mat.Chemie.Mn2" # Max("Mat.Chemie.Mn2", -100000000000.0);
  if "Mat.Chemie.P1">0.0 then "Mat.Chemie.P1" # Min("Mat.Chemie.P1", 100000000000.0)
  else "Mat.Chemie.P1" # Max("Mat.Chemie.P1", -100000000000.0);
  if "Mat.Chemie.P2">0.0 then "Mat.Chemie.P2" # Min("Mat.Chemie.P2", 100000000000.0)
  else "Mat.Chemie.P2" # Max("Mat.Chemie.P2", -100000000000.0);
  if "Mat.Chemie.S1">0.0 then "Mat.Chemie.S1" # Min("Mat.Chemie.S1", 100000000000.0)
  else "Mat.Chemie.S1" # Max("Mat.Chemie.S1", -100000000000.0);
  if "Mat.Chemie.S2">0.0 then "Mat.Chemie.S2" # Min("Mat.Chemie.S2", 100000000000.0)
  else "Mat.Chemie.S2" # Max("Mat.Chemie.S2", -100000000000.0);
  if "Mat.Chemie.Al1">0.0 then "Mat.Chemie.Al1" # Min("Mat.Chemie.Al1", 100000000000.0)
  else "Mat.Chemie.Al1" # Max("Mat.Chemie.Al1", -100000000000.0);
  if "Mat.Chemie.Al2">0.0 then "Mat.Chemie.Al2" # Min("Mat.Chemie.Al2", 100000000000.0)
  else "Mat.Chemie.Al2" # Max("Mat.Chemie.Al2", -100000000000.0);
  if "Mat.Chemie.Cr1">0.0 then "Mat.Chemie.Cr1" # Min("Mat.Chemie.Cr1", 100000000000.0)
  else "Mat.Chemie.Cr1" # Max("Mat.Chemie.Cr1", -100000000000.0);
  if "Mat.Chemie.Cr2">0.0 then "Mat.Chemie.Cr2" # Min("Mat.Chemie.Cr2", 100000000000.0)
  else "Mat.Chemie.Cr2" # Max("Mat.Chemie.Cr2", -100000000000.0);
  if "Mat.Chemie.V1">0.0 then "Mat.Chemie.V1" # Min("Mat.Chemie.V1", 100000000000.0)
  else "Mat.Chemie.V1" # Max("Mat.Chemie.V1", -100000000000.0);
  if "Mat.Chemie.V2">0.0 then "Mat.Chemie.V2" # Min("Mat.Chemie.V2", 100000000000.0)
  else "Mat.Chemie.V2" # Max("Mat.Chemie.V2", -100000000000.0);
  if "Mat.Chemie.Nb1">0.0 then "Mat.Chemie.Nb1" # Min("Mat.Chemie.Nb1", 100000000000.0)
  else "Mat.Chemie.Nb1" # Max("Mat.Chemie.Nb1", -100000000000.0);
  if "Mat.Chemie.Nb2">0.0 then "Mat.Chemie.Nb2" # Min("Mat.Chemie.Nb2", 100000000000.0)
  else "Mat.Chemie.Nb2" # Max("Mat.Chemie.Nb2", -100000000000.0);
  if "Mat.Chemie.Ti1">0.0 then "Mat.Chemie.Ti1" # Min("Mat.Chemie.Ti1", 100000000000.0)
  else "Mat.Chemie.Ti1" # Max("Mat.Chemie.Ti1", -100000000000.0);
  if "Mat.Chemie.Ti2">0.0 then "Mat.Chemie.Ti2" # Min("Mat.Chemie.Ti2", 100000000000.0)
  else "Mat.Chemie.Ti2" # Max("Mat.Chemie.Ti2", -100000000000.0);
  if "Mat.Chemie.N1">0.0 then "Mat.Chemie.N1" # Min("Mat.Chemie.N1", 100000000000.0)
  else "Mat.Chemie.N1" # Max("Mat.Chemie.N1", -100000000000.0);
  if "Mat.Chemie.N2">0.0 then "Mat.Chemie.N2" # Min("Mat.Chemie.N2", 100000000000.0)
  else "Mat.Chemie.N2" # Max("Mat.Chemie.N2", -100000000000.0);
  if "Mat.Chemie.Cu1">0.0 then "Mat.Chemie.Cu1" # Min("Mat.Chemie.Cu1", 100000000000.0)
  else "Mat.Chemie.Cu1" # Max("Mat.Chemie.Cu1", -100000000000.0);
  if "Mat.Chemie.Cu2">0.0 then "Mat.Chemie.Cu2" # Min("Mat.Chemie.Cu2", 100000000000.0)
  else "Mat.Chemie.Cu2" # Max("Mat.Chemie.Cu2", -100000000000.0);
  if "Mat.Chemie.Ni1">0.0 then "Mat.Chemie.Ni1" # Min("Mat.Chemie.Ni1", 100000000000.0)
  else "Mat.Chemie.Ni1" # Max("Mat.Chemie.Ni1", -100000000000.0);
  if "Mat.Chemie.Ni2">0.0 then "Mat.Chemie.Ni2" # Min("Mat.Chemie.Ni2", 100000000000.0)
  else "Mat.Chemie.Ni2" # Max("Mat.Chemie.Ni2", -100000000000.0);
  if "Mat.Chemie.Mo1">0.0 then "Mat.Chemie.Mo1" # Min("Mat.Chemie.Mo1", 100000000000.0)
  else "Mat.Chemie.Mo1" # Max("Mat.Chemie.Mo1", -100000000000.0);
  if "Mat.Chemie.Mo2">0.0 then "Mat.Chemie.Mo2" # Min("Mat.Chemie.Mo2", 100000000000.0)
  else "Mat.Chemie.Mo2" # Max("Mat.Chemie.Mo2", -100000000000.0);
  if "Mat.Chemie.B1">0.0 then "Mat.Chemie.B1" # Min("Mat.Chemie.B1", 100000000000.0)
  else "Mat.Chemie.B1" # Max("Mat.Chemie.B1", -100000000000.0);
  if "Mat.Chemie.B2">0.0 then "Mat.Chemie.B2" # Min("Mat.Chemie.B2", 100000000000.0)
  else "Mat.Chemie.B2" # Max("Mat.Chemie.B2", -100000000000.0);
  if "Mat.HärteA1">0.0 then "Mat.HärteA1" # Min("Mat.HärteA1", 100000000000.0)
  else "Mat.HärteA1" # Max("Mat.HärteA1", -100000000000.0);
  if "Mat.HärteA2">0.0 then "Mat.HärteA2" # Min("Mat.HärteA2", 100000000000.0)
  else "Mat.HärteA2" # Max("Mat.HärteA2", -100000000000.0);
  if "Mat.Chemie.Frei1.1">0.0 then "Mat.Chemie.Frei1.1" # Min("Mat.Chemie.Frei1.1", 100000000000.0)
  else "Mat.Chemie.Frei1.1" # Max("Mat.Chemie.Frei1.1", -100000000000.0);
  if "Mat.Chemie.Frei1.2">0.0 then "Mat.Chemie.Frei1.2" # Min("Mat.Chemie.Frei1.2", 100000000000.0)
  else "Mat.Chemie.Frei1.2" # Max("Mat.Chemie.Frei1.2", -100000000000.0);
  if "Mat.HärteB1">0.0 then "Mat.HärteB1" # Min("Mat.HärteB1", 100000000000.0)
  else "Mat.HärteB1" # Max("Mat.HärteB1", -100000000000.0);
  if "Mat.HärteB2">0.0 then "Mat.HärteB2" # Min("Mat.HärteB2", 100000000000.0)
  else "Mat.HärteB2" # Max("Mat.HärteB2", -100000000000.0);
  if "Mat.RauigkeitA1">0.0 then "Mat.RauigkeitA1" # Min("Mat.RauigkeitA1", 100000000000.0)
  else "Mat.RauigkeitA1" # Max("Mat.RauigkeitA1", -100000000000.0);
  if "Mat.RauigkeitA2">0.0 then "Mat.RauigkeitA2" # Min("Mat.RauigkeitA2", 100000000000.0)
  else "Mat.RauigkeitA2" # Max("Mat.RauigkeitA2", -100000000000.0);
  if "Mat.RauigkeitB1">0.0 then "Mat.RauigkeitB1" # Min("Mat.RauigkeitB1", 100000000000.0)
  else "Mat.RauigkeitB1" # Max("Mat.RauigkeitB1", -100000000000.0);
  if "Mat.RauigkeitB2">0.0 then "Mat.RauigkeitB2" # Min("Mat.RauigkeitB2", 100000000000.0)
  else "Mat.RauigkeitB2" # Max("Mat.RauigkeitB2", -100000000000.0);
  if "Mat.RauigkeitC1">0.0 then "Mat.RauigkeitC1" # Min("Mat.RauigkeitC1", 100000000000.0)
  else "Mat.RauigkeitC1" # Max("Mat.RauigkeitC1", -100000000000.0);
  if "Mat.RauigkeitC2">0.0 then "Mat.RauigkeitC2" # Min("Mat.RauigkeitC2", 100000000000.0)
  else "Mat.RauigkeitC2" # Max("Mat.RauigkeitC2", -100000000000.0);
  if "Mat.RauigkeitD1">0.0 then "Mat.RauigkeitD1" # Min("Mat.RauigkeitD1", 100000000000.0)
  else "Mat.RauigkeitD1" # Max("Mat.RauigkeitD1", -100000000000.0);
  if "Mat.RauigkeitD2">0.0 then "Mat.RauigkeitD2" # Min("Mat.RauigkeitD2", 100000000000.0)
  else "Mat.RauigkeitD2" # Max("Mat.RauigkeitD2", -100000000000.0);
  if "Mat.StreckgrenzeB1">0.0 then "Mat.StreckgrenzeB1" # Min("Mat.StreckgrenzeB1", 100000000000.0)
  else "Mat.StreckgrenzeB1" # Max("Mat.StreckgrenzeB1", -100000000000.0);
  if "Mat.StreckgrenzeB2">0.0 then "Mat.StreckgrenzeB2" # Min("Mat.StreckgrenzeB2", 100000000000.0)
  else "Mat.StreckgrenzeB2" # Max("Mat.StreckgrenzeB2", -100000000000.0);
  if "Mat.ZugfestigkeitB1">0.0 then "Mat.ZugfestigkeitB1" # Min("Mat.ZugfestigkeitB1", 100000000000.0)
  else "Mat.ZugfestigkeitB1" # Max("Mat.ZugfestigkeitB1", -100000000000.0);
  if "Mat.ZugfestigkeitB2">0.0 then "Mat.ZugfestigkeitB2" # Min("Mat.ZugfestigkeitB2", 100000000000.0)
  else "Mat.ZugfestigkeitB2" # Max("Mat.ZugfestigkeitB2", -100000000000.0);
  if "Mat.RP02_B1">0.0 then "Mat.RP02_B1" # Min("Mat.RP02_B1", 100000000000.0)
  else "Mat.RP02_B1" # Max("Mat.RP02_B1", -100000000000.0);
  if "Mat.RP02_B2">0.0 then "Mat.RP02_B2" # Min("Mat.RP02_B2", 100000000000.0)
  else "Mat.RP02_B2" # Max("Mat.RP02_B2", -100000000000.0);
  if "Mat.RP10_B1">0.0 then "Mat.RP10_B1" # Min("Mat.RP10_B1", 100000000000.0)
  else "Mat.RP10_B1" # Max("Mat.RP10_B1", -100000000000.0);
  if "Mat.RP10_B2">0.0 then "Mat.RP10_B2" # Min("Mat.RP10_B2", 100000000000.0)
  else "Mat.RP10_B2" # Max("Mat.RP10_B2", -100000000000.0);
  if "Mat.KörnungB1">0.0 then "Mat.KörnungB1" # Min("Mat.KörnungB1", 100000000000.0)
  else "Mat.KörnungB1" # Max("Mat.KörnungB1", -100000000000.0);
  if "Mat.KörnungB2">0.0 then "Mat.KörnungB2" # Min("Mat.KörnungB2", 100000000000.0)
  else "Mat.KörnungB2" # Max("Mat.KörnungB2", -100000000000.0);
  if "Mat.DehnungC1">0.0 then "Mat.DehnungC1" # Min("Mat.DehnungC1", 100000000000.0)
  else "Mat.DehnungC1" # Max("Mat.DehnungC1", -100000000000.0);
  if "Mat.DehnungC2">0.0 then "Mat.DehnungC2" # Min("Mat.DehnungC2", 100000000000.0)
  else "Mat.DehnungC2" # Max("Mat.DehnungC2", -100000000000.0);
  if "Mat.Gewicht.Netto">0.0 then "Mat.Gewicht.Netto" # Min("Mat.Gewicht.Netto", 100000000000.0)
  else "Mat.Gewicht.Netto" # Max("Mat.Gewicht.Netto", -100000000000.0);
  if "Mat.Gewicht.Brutto">0.0 then "Mat.Gewicht.Brutto" # Min("Mat.Gewicht.Brutto", 100000000000.0)
  else "Mat.Gewicht.Brutto" # Max("Mat.Gewicht.Brutto", -100000000000.0);
  GV.Alpha.26 # Bool("Mat.StehendYN");
  GV.Alpha.27 # Bool("Mat.LiegendYN");
  if "Mat.Nettoabzug">0.0 then "Mat.Nettoabzug" # Min("Mat.Nettoabzug", 100000000000.0)
  else "Mat.Nettoabzug" # Max("Mat.Nettoabzug", -100000000000.0);
  if "Mat.Stapelhöhe">0.0 then "Mat.Stapelhöhe" # Min("Mat.Stapelhöhe", 100000000000.0)
  else "Mat.Stapelhöhe" # Max("Mat.Stapelhöhe", -100000000000.0);
  if "Mat.Stapelhöhenabzug">0.0 then "Mat.Stapelhöhenabzug" # Min("Mat.Stapelhöhenabzug", 100000000000.0)
  else "Mat.Stapelhöhenabzug" # Max("Mat.Stapelhöhenabzug", -100000000000.0);
  if "Mat.Rechtwinkligkeit">0.0 then "Mat.Rechtwinkligkeit" # Min("Mat.Rechtwinkligkeit", 100000000000.0)
  else "Mat.Rechtwinkligkeit" # Max("Mat.Rechtwinkligkeit", -100000000000.0);
  if "Mat.Ebenheit">0.0 then "Mat.Ebenheit" # Min("Mat.Ebenheit", 100000000000.0)
  else "Mat.Ebenheit" # Max("Mat.Ebenheit", -100000000000.0);
  if "Mat.Säbeligkeit">0.0 then "Mat.Säbeligkeit" # Min("Mat.Säbeligkeit", 100000000000.0)
  else "Mat.Säbeligkeit" # Max("Mat.Säbeligkeit", -100000000000.0);
  if "Mat.Etk.Dicke">0.0 then "Mat.Etk.Dicke" # Min("Mat.Etk.Dicke", 100000000000.0)
  else "Mat.Etk.Dicke" # Max("Mat.Etk.Dicke", -100000000000.0);
  if "Mat.Etk.Breite">0.0 then "Mat.Etk.Breite" # Min("Mat.Etk.Breite", 100000000000.0)
  else "Mat.Etk.Breite" # Max("Mat.Etk.Breite", -100000000000.0);
  if "Mat.Etk.Länge">0.0 then "Mat.Etk.Länge" # Min("Mat.Etk.Länge", 100000000000.0)
  else "Mat.Etk.Länge" # Max("Mat.Etk.Länge", -100000000000.0);
  GV.Alpha.28 # Bool("Mat.ResttafelYN");
  if "Mat.SäbelProM">0.0 then "Mat.SäbelProM" # Min("Mat.SäbelProM", 100000000000.0)
  else "Mat.SäbelProM" # Max("Mat.SäbelProM", -100000000000.0);
  if "Mat.CO2EinstandProT">0.0 then "Mat.CO2EinstandProT" # Min("Mat.CO2EinstandProT", 100000000000.0)
  else "Mat.CO2EinstandProT" # Max("Mat.CO2EinstandProT", -100000000000.0);
  if "Mat.CO2ZuwachsProT">0.0 then "Mat.CO2ZuwachsProT" # Min("Mat.CO2ZuwachsProT", 100000000000.0)
  else "Mat.CO2ZuwachsProT" # Max("Mat.CO2ZuwachsProT", -100000000000.0);
  if "Mat.CO2SchrottProT">0.0 then "Mat.CO2SchrottProT" # Min("Mat.CO2SchrottProT", 100000000000.0)
  else "Mat.CO2SchrottProT" # Max("Mat.CO2SchrottProT", -100000000000.0);
  if "Mat.Spulbreite">0.0 then "Mat.Spulbreite" # Min("Mat.Spulbreite", 100000000000.0)
  else "Mat.Spulbreite" # Max("Mat.Spulbreite", -100000000000.0);
end;

// -------------------------------------------------
sub EX201()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0201'
     +cnvai(RecInfo(201,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(201, _recModified);
end;

// -------------------------------------------------
sub EX202()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0202'
     +cnvai(RecInfo(202,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(202, _recModified);
  GV.Alpha.02 # Datum("Mat.B.Datum");
  if "Mat.B.Gewicht">0.0 then "Mat.B.Gewicht" # Min("Mat.B.Gewicht", 100000000000.0)
  else "Mat.B.Gewicht" # Max("Mat.B.Gewicht", -100000000000.0);
  if "Mat.B.PreisW1">0.0 then "Mat.B.PreisW1" # Min("Mat.B.PreisW1", 100000000000.0)
  else "Mat.B.PreisW1" # Max("Mat.B.PreisW1", -100000000000.0);
  GV.Alpha.03 # Bool("Mat.B.FixYN");
  if "Mat.B.Menge">0.0 then "Mat.B.Menge" # Min("Mat.B.Menge", 100000000000.0)
  else "Mat.B.Menge" # Max("Mat.B.Menge", -100000000000.0);
  if "Mat.B.PreisW1ProMEH">0.0 then "Mat.B.PreisW1ProMEH" # Min("Mat.B.PreisW1ProMEH", 100000000000.0)
  else "Mat.B.PreisW1ProMEH" # Max("Mat.B.PreisW1ProMEH", -100000000000.0);
  GV.Alpha.04 # Zeit("Mat.B.Zeit");
end;

// -------------------------------------------------
sub EX203()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0203'
     +cnvai(RecInfo(203,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(203, _recModified);
  if "Mat.R.Gewicht">0.0 then "Mat.R.Gewicht" # Min("Mat.R.Gewicht", 100000000000.0)
  else "Mat.R.Gewicht" # Max("Mat.R.Gewicht", -100000000000.0);
  GV.Alpha.02 # Datum("Mat.R.Ablaufdatum");
  if "Mat.R.Menge">0.0 then "Mat.R.Menge" # Min("Mat.R.Menge", 100000000000.0)
  else "Mat.R.Menge" # Max("Mat.R.Menge", -100000000000.0);
  GV.Alpha.03 # Bool("Mat.R.TrackingYN");
end;

// -------------------------------------------------
sub EX204()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0204'
     +cnvai(RecInfo(204,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(204, _recModified);
  GV.Alpha.02 # Datum("Mat.A.Aktionsdatum");
  GV.Alpha.03 # Datum("Mat.A.TerminStart");
  GV.Alpha.04 # Datum("Mat.A.TerminEnde");
  if "Mat.A.Gewicht">0.0 then "Mat.A.Gewicht" # Min("Mat.A.Gewicht", 100000000000.0)
  else "Mat.A.Gewicht" # Max("Mat.A.Gewicht", -100000000000.0);
  if "Mat.A.Nettogewicht">0.0 then "Mat.A.Nettogewicht" # Min("Mat.A.Nettogewicht", 100000000000.0)
  else "Mat.A.Nettogewicht" # Max("Mat.A.Nettogewicht", -100000000000.0);
  if "Mat.A.KostenW1">0.0 then "Mat.A.KostenW1" # Min("Mat.A.KostenW1", 100000000000.0)
  else "Mat.A.KostenW1" # Max("Mat.A.KostenW1", -100000000000.0);
  if "Mat.A.Kosten2W1">0.0 then "Mat.A.Kosten2W1" # Min("Mat.A.Kosten2W1", 100000000000.0)
  else "Mat.A.Kosten2W1" # Max("Mat.A.Kosten2W1", -100000000000.0);
  if "Mat.A.Menge">0.0 then "Mat.A.Menge" # Min("Mat.A.Menge", 100000000000.0)
  else "Mat.A.Menge" # Max("Mat.A.Menge", -100000000000.0);
  if "Mat.A.KostenW1ProMEH">0.0 then "Mat.A.KostenW1ProMEH" # Min("Mat.A.KostenW1ProMEH", 100000000000.0)
  else "Mat.A.KostenW1ProMEH" # Max("Mat.A.KostenW1ProMEH", -100000000000.0);
  if "Mat.A.Kosten2W1ProME">0.0 then "Mat.A.Kosten2W1ProME" # Min("Mat.A.Kosten2W1ProME", 100000000000.0)
  else "Mat.A.Kosten2W1ProME" # Max("Mat.A.Kosten2W1ProME", -100000000000.0);
  GV.Alpha.05 # Zeit("Mat.A.Aktionszeit");
  if "Mat.A.CO2ProT">0.0 then "Mat.A.CO2ProT" # Min("Mat.A.CO2ProT", 100000000000.0)
  else "Mat.A.CO2ProT" # Max("Mat.A.CO2ProT", -100000000000.0);
end;

// -------------------------------------------------
sub EX210()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0210'
     +cnvai(RecInfo(210,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(210, _recModified);
  GV.Alpha.02 # Bool("Mat~EigenmaterialYN");
  GV.Alpha.03 # Datum("Mat~Übernahmedatum");
  if "Mat~Dicke">0.0 then "Mat~Dicke" # Min("Mat~Dicke", 100000000000.0)
  else "Mat~Dicke" # Max("Mat~Dicke", -100000000000.0);
  if "Mat~Dicke.Von">0.0 then "Mat~Dicke.Von" # Min("Mat~Dicke.Von", 100000000000.0)
  else "Mat~Dicke.Von" # Max("Mat~Dicke.Von", -100000000000.0);
  if "Mat~Dicke.Bis">0.0 then "Mat~Dicke.Bis" # Min("Mat~Dicke.Bis", 100000000000.0)
  else "Mat~Dicke.Bis" # Max("Mat~Dicke.Bis", -100000000000.0);
  GV.Alpha.04 # Bool("Mat~DickenTolYN");
  if "Mat~DickenTol.Von">0.0 then "Mat~DickenTol.Von" # Min("Mat~DickenTol.Von", 100000000000.0)
  else "Mat~DickenTol.Von" # Max("Mat~DickenTol.Von", -100000000000.0);
  if "Mat~DickenTol.Bis">0.0 then "Mat~DickenTol.Bis" # Min("Mat~DickenTol.Bis", 100000000000.0)
  else "Mat~DickenTol.Bis" # Max("Mat~DickenTol.Bis", -100000000000.0);
  if "Mat~Breite">0.0 then "Mat~Breite" # Min("Mat~Breite", 100000000000.0)
  else "Mat~Breite" # Max("Mat~Breite", -100000000000.0);
  if "Mat~Breite.Von">0.0 then "Mat~Breite.Von" # Min("Mat~Breite.Von", 100000000000.0)
  else "Mat~Breite.Von" # Max("Mat~Breite.Von", -100000000000.0);
  if "Mat~Breite.Bis">0.0 then "Mat~Breite.Bis" # Min("Mat~Breite.Bis", 100000000000.0)
  else "Mat~Breite.Bis" # Max("Mat~Breite.Bis", -100000000000.0);
  GV.Alpha.05 # Bool("Mat~BreitenTolYN");
  if "Mat~BreitenTol.Von">0.0 then "Mat~BreitenTol.Von" # Min("Mat~BreitenTol.Von", 100000000000.0)
  else "Mat~BreitenTol.Von" # Max("Mat~BreitenTol.Von", -100000000000.0);
  if "Mat~BreitenTol.Bis">0.0 then "Mat~BreitenTol.Bis" # Min("Mat~BreitenTol.Bis", 100000000000.0)
  else "Mat~BreitenTol.Bis" # Max("Mat~BreitenTol.Bis", -100000000000.0);
  if "Mat~Länge">0.0 then "Mat~Länge" # Min("Mat~Länge", 100000000000.0)
  else "Mat~Länge" # Max("Mat~Länge", -100000000000.0);
  if "Mat~Länge.Von">0.0 then "Mat~Länge.Von" # Min("Mat~Länge.Von", 100000000000.0)
  else "Mat~Länge.Von" # Max("Mat~Länge.Von", -100000000000.0);
  if "Mat~Länge.Bis">0.0 then "Mat~Länge.Bis" # Min("Mat~Länge.Bis", 100000000000.0)
  else "Mat~Länge.Bis" # Max("Mat~Länge.Bis", -100000000000.0);
  GV.Alpha.06 # Bool("Mat~LängenTolYN");
  if "Mat~LängenTol.Von">0.0 then "Mat~LängenTol.Von" # Min("Mat~LängenTol.Von", 100000000000.0)
  else "Mat~LängenTol.Von" # Max("Mat~LängenTol.Von", -100000000000.0);
  if "Mat~LängenTol.Bis">0.0 then "Mat~LängenTol.Bis" # Min("Mat~LängenTol.Bis", 100000000000.0)
  else "Mat~LängenTol.Bis" # Max("Mat~LängenTol.Bis", -100000000000.0);
  if "Mat~RID">0.0 then "Mat~RID" # Min("Mat~RID", 100000000000.0)
  else "Mat~RID" # Max("Mat~RID", -100000000000.0);
  if "Mat~RAD">0.0 then "Mat~RAD" # Min("Mat~RAD", 100000000000.0)
  else "Mat~RAD" # Max("Mat~RAD", -100000000000.0);
  if "Mat~Kgmm">0.0 then "Mat~Kgmm" # Min("Mat~Kgmm", 100000000000.0)
  else "Mat~Kgmm" # Max("Mat~Kgmm", -100000000000.0);
  if "Mat~Dichte">0.0 then "Mat~Dichte" # Min("Mat~Dichte", 100000000000.0)
  else "Mat~Dichte" # Max("Mat~Dichte", -100000000000.0);
  if "Mat~Bestand.Gew">0.0 then "Mat~Bestand.Gew" # Min("Mat~Bestand.Gew", 100000000000.0)
  else "Mat~Bestand.Gew" # Max("Mat~Bestand.Gew", -100000000000.0);
  if "Mat~Bestellt.Gew">0.0 then "Mat~Bestellt.Gew" # Min("Mat~Bestellt.Gew", 100000000000.0)
  else "Mat~Bestellt.Gew" # Max("Mat~Bestellt.Gew", -100000000000.0);
  if "Mat~Reserviert.Gew">0.0 then "Mat~Reserviert.Gew" # Min("Mat~Reserviert.Gew", 100000000000.0)
  else "Mat~Reserviert.Gew" # Max("Mat~Reserviert.Gew", -100000000000.0);
  if "Mat~Verfügbar.Gew">0.0 then "Mat~Verfügbar.Gew" # Min("Mat~Verfügbar.Gew", 100000000000.0)
  else "Mat~Verfügbar.Gew" # Max("Mat~Verfügbar.Gew", -100000000000.0);
  if "Mat~EK.Preis">0.0 then "Mat~EK.Preis" # Min("Mat~EK.Preis", 100000000000.0)
  else "Mat~EK.Preis" # Max("Mat~EK.Preis", -100000000000.0);
  if "Mat~Kosten">0.0 then "Mat~Kosten" # Min("Mat~Kosten", 100000000000.0)
  else "Mat~Kosten" # Max("Mat~Kosten", -100000000000.0);
  if "Mat~EK.Effektiv">0.0 then "Mat~EK.Effektiv" # Min("Mat~EK.Effektiv", 100000000000.0)
  else "Mat~EK.Effektiv" # Max("Mat~EK.Effektiv", -100000000000.0);
  if "Mat~EK.Preis2">0.0 then "Mat~EK.Preis2" # Min("Mat~EK.Preis2", 100000000000.0)
  else "Mat~EK.Preis2" # Max("Mat~EK.Preis2", -100000000000.0);
  if "Mat~Reserviert2.Gew">0.0 then "Mat~Reserviert2.Gew" # Min("Mat~Reserviert2.Gew", 100000000000.0)
  else "Mat~Reserviert2.Gew" # Max("Mat~Reserviert2.Gew", -100000000000.0);
  if "Mat~Bestand.Menge">0.0 then "Mat~Bestand.Menge" # Min("Mat~Bestand.Menge", 100000000000.0)
  else "Mat~Bestand.Menge" # Max("Mat~Bestand.Menge", -100000000000.0);
  if "Mat~Bestellt.Menge">0.0 then "Mat~Bestellt.Menge" # Min("Mat~Bestellt.Menge", 100000000000.0)
  else "Mat~Bestellt.Menge" # Max("Mat~Bestellt.Menge", -100000000000.0);
  if "Mat~Reserviert.Menge">0.0 then "Mat~Reserviert.Menge" # Min("Mat~Reserviert.Menge", 100000000000.0)
  else "Mat~Reserviert.Menge" # Max("Mat~Reserviert.Menge", -100000000000.0);
  if "Mat~Verfügbar.Menge">0.0 then "Mat~Verfügbar.Menge" # Min("Mat~Verfügbar.Menge", 100000000000.0)
  else "Mat~Verfügbar.Menge" # Max("Mat~Verfügbar.Menge", -100000000000.0);
  if "Mat~EK.PreisProMEH">0.0 then "Mat~EK.PreisProMEH" # Min("Mat~EK.PreisProMEH", 100000000000.0)
  else "Mat~EK.PreisProMEH" # Max("Mat~EK.PreisProMEH", -100000000000.0);
  if "Mat~KostenProMEH">0.0 then "Mat~KostenProMEH" # Min("Mat~KostenProMEH", 100000000000.0)
  else "Mat~KostenProMEH" # Max("Mat~KostenProMEH", -100000000000.0);
  if "Mat~EK.EffektivProME">0.0 then "Mat~EK.EffektivProME" # Min("Mat~EK.EffektivProME", 100000000000.0)
  else "Mat~EK.EffektivProME" # Max("Mat~EK.EffektivProME", -100000000000.0);
  if "Mat~Reserviert2.Meng">0.0 then "Mat~Reserviert2.Meng" # Min("Mat~Reserviert2.Meng", 100000000000.0)
  else "Mat~Reserviert2.Meng" # Max("Mat~Reserviert2.Meng", -100000000000.0);
  GV.Alpha.07 # Datum("Mat~Bestelldatum");
  GV.Alpha.08 # Datum("Mat~BestellTermin");
  GV.Alpha.09 # Datum("Mat~Eingangsdatum");
  GV.Alpha.10 # Datum("Mat~Ausgangsdatum");
  GV.Alpha.11 # Datum("Mat~Inventurdatum");
  GV.Alpha.12 # Datum("Mat~VK.Rechdatum");
  if "Mat~VK.Preis">0.0 then "Mat~VK.Preis" # Min("Mat~VK.Preis", 100000000000.0)
  else "Mat~VK.Preis" # Max("Mat~VK.Preis", -100000000000.0);
  if "Mat~VK.Gewicht">0.0 then "Mat~VK.Gewicht" # Min("Mat~VK.Gewicht", 100000000000.0)
  else "Mat~VK.Gewicht" # Max("Mat~VK.Gewicht", -100000000000.0);
  GV.Alpha.13 # Datum("Mat~EK.RechDatum");
  GV.Alpha.14 # Datum("Mat~Datum.Lagergeld");
  GV.Alpha.15 # Datum("Mat~Datum.Zinsen");
  GV.Alpha.16 # Datum("Mat~Datum.Erzeugt");
  GV.Alpha.17 # Datum("Mat~Datum.VSBMeldung");
  if "Mat~VK.Korrektur">0.0 then "Mat~VK.Korrektur" # Min("Mat~VK.Korrektur", 100000000000.0)
  else "Mat~VK.Korrektur" # Max("Mat~VK.Korrektur", -100000000000.0);
  GV.Alpha.18 # Bool("Mat~Inventur.DruckYN");
  GV.Alpha.19 # Datum("Mat~Abrufdatum");
  GV.Alpha.20 # Datum("Mat~AbgerufenAm");
  GV.Alpha.21 # Datum("Mat~QS.Datum");
  GV.Alpha.22 # Zeit("Mat~QS.Zeit");
  GV.Alpha.23 # Bool("Mat~QS.FehlerYN");
  GV.Alpha.24 # Bool("Mat~StreckeYN");
  if "Mat~Streckgrenze1">0.0 then "Mat~Streckgrenze1" # Min("Mat~Streckgrenze1", 100000000000.0)
  else "Mat~Streckgrenze1" # Max("Mat~Streckgrenze1", -100000000000.0);
  if "Mat~Streckgrenze2">0.0 then "Mat~Streckgrenze2" # Min("Mat~Streckgrenze2", 100000000000.0)
  else "Mat~Streckgrenze2" # Max("Mat~Streckgrenze2", -100000000000.0);
  if "Mat~Zugfestigkeit1">0.0 then "Mat~Zugfestigkeit1" # Min("Mat~Zugfestigkeit1", 100000000000.0)
  else "Mat~Zugfestigkeit1" # Max("Mat~Zugfestigkeit1", -100000000000.0);
  if "Mat~Zugfestigkeit2">0.0 then "Mat~Zugfestigkeit2" # Min("Mat~Zugfestigkeit2", 100000000000.0)
  else "Mat~Zugfestigkeit2" # Max("Mat~Zugfestigkeit2", -100000000000.0);
  if "Mat~DehnungA1">0.0 then "Mat~DehnungA1" # Min("Mat~DehnungA1", 100000000000.0)
  else "Mat~DehnungA1" # Max("Mat~DehnungA1", -100000000000.0);
  if "Mat~DehnungA2">0.0 then "Mat~DehnungA2" # Min("Mat~DehnungA2", 100000000000.0)
  else "Mat~DehnungA2" # Max("Mat~DehnungA2", -100000000000.0);
  if "Mat~DehnungB1">0.0 then "Mat~DehnungB1" # Min("Mat~DehnungB1", 100000000000.0)
  else "Mat~DehnungB1" # Max("Mat~DehnungB1", -100000000000.0);
  if "Mat~DehnungB2">0.0 then "Mat~DehnungB2" # Min("Mat~DehnungB2", 100000000000.0)
  else "Mat~DehnungB2" # Max("Mat~DehnungB2", -100000000000.0);
  if "Mat~RP02_V1">0.0 then "Mat~RP02_V1" # Min("Mat~RP02_V1", 100000000000.0)
  else "Mat~RP02_V1" # Max("Mat~RP02_V1", -100000000000.0);
  if "Mat~RP02_V2">0.0 then "Mat~RP02_V2" # Min("Mat~RP02_V2", 100000000000.0)
  else "Mat~RP02_V2" # Max("Mat~RP02_V2", -100000000000.0);
  if "Mat~RP10_V1">0.0 then "Mat~RP10_V1" # Min("Mat~RP10_V1", 100000000000.0)
  else "Mat~RP10_V1" # Max("Mat~RP10_V1", -100000000000.0);
  if "Mat~RP10_V2">0.0 then "Mat~RP10_V2" # Min("Mat~RP10_V2", 100000000000.0)
  else "Mat~RP10_V2" # Max("Mat~RP10_V2", -100000000000.0);
  if "Mat~Körnung1">0.0 then "Mat~Körnung1" # Min("Mat~Körnung1", 100000000000.0)
  else "Mat~Körnung1" # Max("Mat~Körnung1", -100000000000.0);
  if "Mat~Körnung2">0.0 then "Mat~Körnung2" # Min("Mat~Körnung2", 100000000000.0)
  else "Mat~Körnung2" # Max("Mat~Körnung2", -100000000000.0);
  if "Mat~Chemie.C1">0.0 then "Mat~Chemie.C1" # Min("Mat~Chemie.C1", 100000000000.0)
  else "Mat~Chemie.C1" # Max("Mat~Chemie.C1", -100000000000.0);
  if "Mat~Chemie.C2">0.0 then "Mat~Chemie.C2" # Min("Mat~Chemie.C2", 100000000000.0)
  else "Mat~Chemie.C2" # Max("Mat~Chemie.C2", -100000000000.0);
  if "Mat~Chemie.Si1">0.0 then "Mat~Chemie.Si1" # Min("Mat~Chemie.Si1", 100000000000.0)
  else "Mat~Chemie.Si1" # Max("Mat~Chemie.Si1", -100000000000.0);
  if "Mat~Chemie.Si2">0.0 then "Mat~Chemie.Si2" # Min("Mat~Chemie.Si2", 100000000000.0)
  else "Mat~Chemie.Si2" # Max("Mat~Chemie.Si2", -100000000000.0);
  if "Mat~Chemie.Mn1">0.0 then "Mat~Chemie.Mn1" # Min("Mat~Chemie.Mn1", 100000000000.0)
  else "Mat~Chemie.Mn1" # Max("Mat~Chemie.Mn1", -100000000000.0);
  if "Mat~Chemie.Mn2">0.0 then "Mat~Chemie.Mn2" # Min("Mat~Chemie.Mn2", 100000000000.0)
  else "Mat~Chemie.Mn2" # Max("Mat~Chemie.Mn2", -100000000000.0);
  if "Mat~Chemie.P1">0.0 then "Mat~Chemie.P1" # Min("Mat~Chemie.P1", 100000000000.0)
  else "Mat~Chemie.P1" # Max("Mat~Chemie.P1", -100000000000.0);
  if "Mat~Chemie.P2">0.0 then "Mat~Chemie.P2" # Min("Mat~Chemie.P2", 100000000000.0)
  else "Mat~Chemie.P2" # Max("Mat~Chemie.P2", -100000000000.0);
  if "Mat~Chemie.S1">0.0 then "Mat~Chemie.S1" # Min("Mat~Chemie.S1", 100000000000.0)
  else "Mat~Chemie.S1" # Max("Mat~Chemie.S1", -100000000000.0);
  if "Mat~Chemie.S2">0.0 then "Mat~Chemie.S2" # Min("Mat~Chemie.S2", 100000000000.0)
  else "Mat~Chemie.S2" # Max("Mat~Chemie.S2", -100000000000.0);
  if "Mat~Chemie.Al1">0.0 then "Mat~Chemie.Al1" # Min("Mat~Chemie.Al1", 100000000000.0)
  else "Mat~Chemie.Al1" # Max("Mat~Chemie.Al1", -100000000000.0);
  if "Mat~Chemie.Al2">0.0 then "Mat~Chemie.Al2" # Min("Mat~Chemie.Al2", 100000000000.0)
  else "Mat~Chemie.Al2" # Max("Mat~Chemie.Al2", -100000000000.0);
  if "Mat~Chemie.Cr1">0.0 then "Mat~Chemie.Cr1" # Min("Mat~Chemie.Cr1", 100000000000.0)
  else "Mat~Chemie.Cr1" # Max("Mat~Chemie.Cr1", -100000000000.0);
  if "Mat~Chemie.Cr2">0.0 then "Mat~Chemie.Cr2" # Min("Mat~Chemie.Cr2", 100000000000.0)
  else "Mat~Chemie.Cr2" # Max("Mat~Chemie.Cr2", -100000000000.0);
  if "Mat~Chemie.V1">0.0 then "Mat~Chemie.V1" # Min("Mat~Chemie.V1", 100000000000.0)
  else "Mat~Chemie.V1" # Max("Mat~Chemie.V1", -100000000000.0);
  if "Mat~Chemie.V2">0.0 then "Mat~Chemie.V2" # Min("Mat~Chemie.V2", 100000000000.0)
  else "Mat~Chemie.V2" # Max("Mat~Chemie.V2", -100000000000.0);
  if "Mat~Chemie.Nb1">0.0 then "Mat~Chemie.Nb1" # Min("Mat~Chemie.Nb1", 100000000000.0)
  else "Mat~Chemie.Nb1" # Max("Mat~Chemie.Nb1", -100000000000.0);
  if "Mat~Chemie.Nb2">0.0 then "Mat~Chemie.Nb2" # Min("Mat~Chemie.Nb2", 100000000000.0)
  else "Mat~Chemie.Nb2" # Max("Mat~Chemie.Nb2", -100000000000.0);
  if "Mat~Chemie.Ti1">0.0 then "Mat~Chemie.Ti1" # Min("Mat~Chemie.Ti1", 100000000000.0)
  else "Mat~Chemie.Ti1" # Max("Mat~Chemie.Ti1", -100000000000.0);
  if "Mat~Chemie.Ti2">0.0 then "Mat~Chemie.Ti2" # Min("Mat~Chemie.Ti2", 100000000000.0)
  else "Mat~Chemie.Ti2" # Max("Mat~Chemie.Ti2", -100000000000.0);
  if "Mat~Chemie.N1">0.0 then "Mat~Chemie.N1" # Min("Mat~Chemie.N1", 100000000000.0)
  else "Mat~Chemie.N1" # Max("Mat~Chemie.N1", -100000000000.0);
  if "Mat~Chemie.N2">0.0 then "Mat~Chemie.N2" # Min("Mat~Chemie.N2", 100000000000.0)
  else "Mat~Chemie.N2" # Max("Mat~Chemie.N2", -100000000000.0);
  if "Mat~Chemie.Cu1">0.0 then "Mat~Chemie.Cu1" # Min("Mat~Chemie.Cu1", 100000000000.0)
  else "Mat~Chemie.Cu1" # Max("Mat~Chemie.Cu1", -100000000000.0);
  if "Mat~Chemie.Cu2">0.0 then "Mat~Chemie.Cu2" # Min("Mat~Chemie.Cu2", 100000000000.0)
  else "Mat~Chemie.Cu2" # Max("Mat~Chemie.Cu2", -100000000000.0);
  if "Mat~Chemie.Ni1">0.0 then "Mat~Chemie.Ni1" # Min("Mat~Chemie.Ni1", 100000000000.0)
  else "Mat~Chemie.Ni1" # Max("Mat~Chemie.Ni1", -100000000000.0);
  if "Mat~Chemie.Ni2">0.0 then "Mat~Chemie.Ni2" # Min("Mat~Chemie.Ni2", 100000000000.0)
  else "Mat~Chemie.Ni2" # Max("Mat~Chemie.Ni2", -100000000000.0);
  if "Mat~Chemie.Mo1">0.0 then "Mat~Chemie.Mo1" # Min("Mat~Chemie.Mo1", 100000000000.0)
  else "Mat~Chemie.Mo1" # Max("Mat~Chemie.Mo1", -100000000000.0);
  if "Mat~Chemie.Mo2">0.0 then "Mat~Chemie.Mo2" # Min("Mat~Chemie.Mo2", 100000000000.0)
  else "Mat~Chemie.Mo2" # Max("Mat~Chemie.Mo2", -100000000000.0);
  if "Mat~Chemie.B1">0.0 then "Mat~Chemie.B1" # Min("Mat~Chemie.B1", 100000000000.0)
  else "Mat~Chemie.B1" # Max("Mat~Chemie.B1", -100000000000.0);
  if "Mat~Chemie.B2">0.0 then "Mat~Chemie.B2" # Min("Mat~Chemie.B2", 100000000000.0)
  else "Mat~Chemie.B2" # Max("Mat~Chemie.B2", -100000000000.0);
  if "Mat~HärteA1">0.0 then "Mat~HärteA1" # Min("Mat~HärteA1", 100000000000.0)
  else "Mat~HärteA1" # Max("Mat~HärteA1", -100000000000.0);
  if "Mat~HärteA2">0.0 then "Mat~HärteA2" # Min("Mat~HärteA2", 100000000000.0)
  else "Mat~HärteA2" # Max("Mat~HärteA2", -100000000000.0);
  if "Mat~Chemie.Frei1.1">0.0 then "Mat~Chemie.Frei1.1" # Min("Mat~Chemie.Frei1.1", 100000000000.0)
  else "Mat~Chemie.Frei1.1" # Max("Mat~Chemie.Frei1.1", -100000000000.0);
  if "Mat~Chemie.Frei1.2">0.0 then "Mat~Chemie.Frei1.2" # Min("Mat~Chemie.Frei1.2", 100000000000.0)
  else "Mat~Chemie.Frei1.2" # Max("Mat~Chemie.Frei1.2", -100000000000.0);
  if "Mat~HärteB1">0.0 then "Mat~HärteB1" # Min("Mat~HärteB1", 100000000000.0)
  else "Mat~HärteB1" # Max("Mat~HärteB1", -100000000000.0);
  if "Mat~HärteB2">0.0 then "Mat~HärteB2" # Min("Mat~HärteB2", 100000000000.0)
  else "Mat~HärteB2" # Max("Mat~HärteB2", -100000000000.0);
  if "Mat~RauigkeitA1">0.0 then "Mat~RauigkeitA1" # Min("Mat~RauigkeitA1", 100000000000.0)
  else "Mat~RauigkeitA1" # Max("Mat~RauigkeitA1", -100000000000.0);
  if "Mat~RauigkeitA2">0.0 then "Mat~RauigkeitA2" # Min("Mat~RauigkeitA2", 100000000000.0)
  else "Mat~RauigkeitA2" # Max("Mat~RauigkeitA2", -100000000000.0);
  if "Mat~RauigkeitB1">0.0 then "Mat~RauigkeitB1" # Min("Mat~RauigkeitB1", 100000000000.0)
  else "Mat~RauigkeitB1" # Max("Mat~RauigkeitB1", -100000000000.0);
  if "Mat~RauigkeitB2">0.0 then "Mat~RauigkeitB2" # Min("Mat~RauigkeitB2", 100000000000.0)
  else "Mat~RauigkeitB2" # Max("Mat~RauigkeitB2", -100000000000.0);
  if "Mat~RauigkeitC1">0.0 then "Mat~RauigkeitC1" # Min("Mat~RauigkeitC1", 100000000000.0)
  else "Mat~RauigkeitC1" # Max("Mat~RauigkeitC1", -100000000000.0);
  if "Mat~RauigkeitC2">0.0 then "Mat~RauigkeitC2" # Min("Mat~RauigkeitC2", 100000000000.0)
  else "Mat~RauigkeitC2" # Max("Mat~RauigkeitC2", -100000000000.0);
  if "Mat~RauigkeitD1">0.0 then "Mat~RauigkeitD1" # Min("Mat~RauigkeitD1", 100000000000.0)
  else "Mat~RauigkeitD1" # Max("Mat~RauigkeitD1", -100000000000.0);
  if "Mat~RauigkeitD2">0.0 then "Mat~RauigkeitD2" # Min("Mat~RauigkeitD2", 100000000000.0)
  else "Mat~RauigkeitD2" # Max("Mat~RauigkeitD2", -100000000000.0);
  if "Mat~StreckgrenzeB1">0.0 then "Mat~StreckgrenzeB1" # Min("Mat~StreckgrenzeB1", 100000000000.0)
  else "Mat~StreckgrenzeB1" # Max("Mat~StreckgrenzeB1", -100000000000.0);
  if "Mat~StreckgrenzeB2">0.0 then "Mat~StreckgrenzeB2" # Min("Mat~StreckgrenzeB2", 100000000000.0)
  else "Mat~StreckgrenzeB2" # Max("Mat~StreckgrenzeB2", -100000000000.0);
  if "Mat~ZugfestigkeitB1">0.0 then "Mat~ZugfestigkeitB1" # Min("Mat~ZugfestigkeitB1", 100000000000.0)
  else "Mat~ZugfestigkeitB1" # Max("Mat~ZugfestigkeitB1", -100000000000.0);
  if "Mat~ZugfestigkeitB2">0.0 then "Mat~ZugfestigkeitB2" # Min("Mat~ZugfestigkeitB2", 100000000000.0)
  else "Mat~ZugfestigkeitB2" # Max("Mat~ZugfestigkeitB2", -100000000000.0);
  if "Mat~RP02_B1">0.0 then "Mat~RP02_B1" # Min("Mat~RP02_B1", 100000000000.0)
  else "Mat~RP02_B1" # Max("Mat~RP02_B1", -100000000000.0);
  if "Mat~RP02_B2">0.0 then "Mat~RP02_B2" # Min("Mat~RP02_B2", 100000000000.0)
  else "Mat~RP02_B2" # Max("Mat~RP02_B2", -100000000000.0);
  if "Mat~RP10_B1">0.0 then "Mat~RP10_B1" # Min("Mat~RP10_B1", 100000000000.0)
  else "Mat~RP10_B1" # Max("Mat~RP10_B1", -100000000000.0);
  if "Mat~RP10_B2">0.0 then "Mat~RP10_B2" # Min("Mat~RP10_B2", 100000000000.0)
  else "Mat~RP10_B2" # Max("Mat~RP10_B2", -100000000000.0);
  if "Mat~KörnungB1">0.0 then "Mat~KörnungB1" # Min("Mat~KörnungB1", 100000000000.0)
  else "Mat~KörnungB1" # Max("Mat~KörnungB1", -100000000000.0);
  if "Mat~KörnungB2">0.0 then "Mat~KörnungB2" # Min("Mat~KörnungB2", 100000000000.0)
  else "Mat~KörnungB2" # Max("Mat~KörnungB2", -100000000000.0);
  if "Mat~DehnungC1">0.0 then "Mat~DehnungC1" # Min("Mat~DehnungC1", 100000000000.0)
  else "Mat~DehnungC1" # Max("Mat~DehnungC1", -100000000000.0);
  if "Mat~DehnungC2">0.0 then "Mat~DehnungC2" # Min("Mat~DehnungC2", 100000000000.0)
  else "Mat~DehnungC2" # Max("Mat~DehnungC2", -100000000000.0);
  if "Mat~Gewicht.Netto">0.0 then "Mat~Gewicht.Netto" # Min("Mat~Gewicht.Netto", 100000000000.0)
  else "Mat~Gewicht.Netto" # Max("Mat~Gewicht.Netto", -100000000000.0);
  if "Mat~Gewicht.Brutto">0.0 then "Mat~Gewicht.Brutto" # Min("Mat~Gewicht.Brutto", 100000000000.0)
  else "Mat~Gewicht.Brutto" # Max("Mat~Gewicht.Brutto", -100000000000.0);
  GV.Alpha.25 # Bool("Mat~StehendYN");
  GV.Alpha.26 # Bool("Mat~LiegendYN");
  if "Mat~Nettoabzug">0.0 then "Mat~Nettoabzug" # Min("Mat~Nettoabzug", 100000000000.0)
  else "Mat~Nettoabzug" # Max("Mat~Nettoabzug", -100000000000.0);
  if "Mat~Stapelhöhe">0.0 then "Mat~Stapelhöhe" # Min("Mat~Stapelhöhe", 100000000000.0)
  else "Mat~Stapelhöhe" # Max("Mat~Stapelhöhe", -100000000000.0);
  if "Mat~Stapelhöhenabzug">0.0 then "Mat~Stapelhöhenabzug" # Min("Mat~Stapelhöhenabzug", 100000000000.0)
  else "Mat~Stapelhöhenabzug" # Max("Mat~Stapelhöhenabzug", -100000000000.0);
  if "Mat~Rechtwinkligkeit">0.0 then "Mat~Rechtwinkligkeit" # Min("Mat~Rechtwinkligkeit", 100000000000.0)
  else "Mat~Rechtwinkligkeit" # Max("Mat~Rechtwinkligkeit", -100000000000.0);
  if "Mat~Ebenheit">0.0 then "Mat~Ebenheit" # Min("Mat~Ebenheit", 100000000000.0)
  else "Mat~Ebenheit" # Max("Mat~Ebenheit", -100000000000.0);
  if "Mat~Säbeligkeit">0.0 then "Mat~Säbeligkeit" # Min("Mat~Säbeligkeit", 100000000000.0)
  else "Mat~Säbeligkeit" # Max("Mat~Säbeligkeit", -100000000000.0);
  if "Mat~Etk.Dicke">0.0 then "Mat~Etk.Dicke" # Min("Mat~Etk.Dicke", 100000000000.0)
  else "Mat~Etk.Dicke" # Max("Mat~Etk.Dicke", -100000000000.0);
  if "Mat~Etk.Breite">0.0 then "Mat~Etk.Breite" # Min("Mat~Etk.Breite", 100000000000.0)
  else "Mat~Etk.Breite" # Max("Mat~Etk.Breite", -100000000000.0);
  if "Mat~Etk.Länge">0.0 then "Mat~Etk.Länge" # Min("Mat~Etk.Länge", 100000000000.0)
  else "Mat~Etk.Länge" # Max("Mat~Etk.Länge", -100000000000.0);
  GV.Alpha.27 # Bool("Mat~ResttafelYN");
  if "Mat~SäbelProM">0.0 then "Mat~SäbelProM" # Min("Mat~SäbelProM", 100000000000.0)
  else "Mat~SäbelProM" # Max("Mat~SäbelProM", -100000000000.0);
  if "Mat~CO2EinstandProT">0.0 then "Mat~CO2EinstandProT" # Min("Mat~CO2EinstandProT", 100000000000.0)
  else "Mat~CO2EinstandProT" # Max("Mat~CO2EinstandProT", -100000000000.0);
  if "Mat~CO2ZuwachsProT">0.0 then "Mat~CO2ZuwachsProT" # Min("Mat~CO2ZuwachsProT", 100000000000.0)
  else "Mat~CO2ZuwachsProT" # Max("Mat~CO2ZuwachsProT", -100000000000.0);
  if "Mat~CO2SchrottProT">0.0 then "Mat~CO2SchrottProT" # Min("Mat~CO2SchrottProT", 100000000000.0)
  else "Mat~CO2SchrottProT" # Max("Mat~CO2SchrottProT", -100000000000.0);
  if "Mat~Spulbreite">0.0 then "Mat~Spulbreite" # Min("Mat~Spulbreite", 100000000000.0)
  else "Mat~Spulbreite" # Max("Mat~Spulbreite", -100000000000.0);
end;

// -------------------------------------------------
sub EX231()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0231'
     +cnvai(RecInfo(231,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(231, _recModified);
  if "Lys.Streckgrenze">0.0 then "Lys.Streckgrenze" # Min("Lys.Streckgrenze", 100000000000.0)
  else "Lys.Streckgrenze" # Max("Lys.Streckgrenze", -100000000000.0);
  if "Lys.Zugfestigkeit">0.0 then "Lys.Zugfestigkeit" # Min("Lys.Zugfestigkeit", 100000000000.0)
  else "Lys.Zugfestigkeit" # Max("Lys.Zugfestigkeit", -100000000000.0);
  if "Lys.DehnungA">0.0 then "Lys.DehnungA" # Min("Lys.DehnungA", 100000000000.0)
  else "Lys.DehnungA" # Max("Lys.DehnungA", -100000000000.0);
  if "Lys.DehnungB">0.0 then "Lys.DehnungB" # Min("Lys.DehnungB", 100000000000.0)
  else "Lys.DehnungB" # Max("Lys.DehnungB", -100000000000.0);
  if "Lys.RP02_1">0.0 then "Lys.RP02_1" # Min("Lys.RP02_1", 100000000000.0)
  else "Lys.RP02_1" # Max("Lys.RP02_1", -100000000000.0);
  if "Lys.RP10_1">0.0 then "Lys.RP10_1" # Min("Lys.RP10_1", 100000000000.0)
  else "Lys.RP10_1" # Max("Lys.RP10_1", -100000000000.0);
  if "Lys.Körnung">0.0 then "Lys.Körnung" # Min("Lys.Körnung", 100000000000.0)
  else "Lys.Körnung" # Max("Lys.Körnung", -100000000000.0);
  if "Lys.Chemie.C">0.0 then "Lys.Chemie.C" # Min("Lys.Chemie.C", 100000000000.0)
  else "Lys.Chemie.C" # Max("Lys.Chemie.C", -100000000000.0);
  if "Lys.Chemie.Si">0.0 then "Lys.Chemie.Si" # Min("Lys.Chemie.Si", 100000000000.0)
  else "Lys.Chemie.Si" # Max("Lys.Chemie.Si", -100000000000.0);
  if "Lys.Chemie.Mn">0.0 then "Lys.Chemie.Mn" # Min("Lys.Chemie.Mn", 100000000000.0)
  else "Lys.Chemie.Mn" # Max("Lys.Chemie.Mn", -100000000000.0);
  if "Lys.Chemie.P">0.0 then "Lys.Chemie.P" # Min("Lys.Chemie.P", 100000000000.0)
  else "Lys.Chemie.P" # Max("Lys.Chemie.P", -100000000000.0);
  if "Lys.Chemie.S">0.0 then "Lys.Chemie.S" # Min("Lys.Chemie.S", 100000000000.0)
  else "Lys.Chemie.S" # Max("Lys.Chemie.S", -100000000000.0);
  if "Lys.Chemie.Al">0.0 then "Lys.Chemie.Al" # Min("Lys.Chemie.Al", 100000000000.0)
  else "Lys.Chemie.Al" # Max("Lys.Chemie.Al", -100000000000.0);
  if "Lys.Chemie.Cr">0.0 then "Lys.Chemie.Cr" # Min("Lys.Chemie.Cr", 100000000000.0)
  else "Lys.Chemie.Cr" # Max("Lys.Chemie.Cr", -100000000000.0);
  if "Lys.Chemie.V">0.0 then "Lys.Chemie.V" # Min("Lys.Chemie.V", 100000000000.0)
  else "Lys.Chemie.V" # Max("Lys.Chemie.V", -100000000000.0);
  if "Lys.Chemie.Nb">0.0 then "Lys.Chemie.Nb" # Min("Lys.Chemie.Nb", 100000000000.0)
  else "Lys.Chemie.Nb" # Max("Lys.Chemie.Nb", -100000000000.0);
  if "Lys.Chemie.Ti">0.0 then "Lys.Chemie.Ti" # Min("Lys.Chemie.Ti", 100000000000.0)
  else "Lys.Chemie.Ti" # Max("Lys.Chemie.Ti", -100000000000.0);
  if "Lys.Chemie.N">0.0 then "Lys.Chemie.N" # Min("Lys.Chemie.N", 100000000000.0)
  else "Lys.Chemie.N" # Max("Lys.Chemie.N", -100000000000.0);
  if "Lys.Chemie.Cu">0.0 then "Lys.Chemie.Cu" # Min("Lys.Chemie.Cu", 100000000000.0)
  else "Lys.Chemie.Cu" # Max("Lys.Chemie.Cu", -100000000000.0);
  if "Lys.Chemie.Ni">0.0 then "Lys.Chemie.Ni" # Min("Lys.Chemie.Ni", 100000000000.0)
  else "Lys.Chemie.Ni" # Max("Lys.Chemie.Ni", -100000000000.0);
  if "Lys.Chemie.Mo">0.0 then "Lys.Chemie.Mo" # Min("Lys.Chemie.Mo", 100000000000.0)
  else "Lys.Chemie.Mo" # Max("Lys.Chemie.Mo", -100000000000.0);
  if "Lys.Chemie.B">0.0 then "Lys.Chemie.B" # Min("Lys.Chemie.B", 100000000000.0)
  else "Lys.Chemie.B" # Max("Lys.Chemie.B", -100000000000.0);
  if "Lys.Härte1">0.0 then "Lys.Härte1" # Min("Lys.Härte1", 100000000000.0)
  else "Lys.Härte1" # Max("Lys.Härte1", -100000000000.0);
  if "Lys.Chemie.Frei1">0.0 then "Lys.Chemie.Frei1" # Min("Lys.Chemie.Frei1", 100000000000.0)
  else "Lys.Chemie.Frei1" # Max("Lys.Chemie.Frei1", -100000000000.0);
  if "Lys.Härte2">0.0 then "Lys.Härte2" # Min("Lys.Härte2", 100000000000.0)
  else "Lys.Härte2" # Max("Lys.Härte2", -100000000000.0);
  if "Lys.RauigkeitA1">0.0 then "Lys.RauigkeitA1" # Min("Lys.RauigkeitA1", 100000000000.0)
  else "Lys.RauigkeitA1" # Max("Lys.RauigkeitA1", -100000000000.0);
  if "Lys.RauigkeitA2">0.0 then "Lys.RauigkeitA2" # Min("Lys.RauigkeitA2", 100000000000.0)
  else "Lys.RauigkeitA2" # Max("Lys.RauigkeitA2", -100000000000.0);
  if "Lys.RauigkeitB1">0.0 then "Lys.RauigkeitB1" # Min("Lys.RauigkeitB1", 100000000000.0)
  else "Lys.RauigkeitB1" # Max("Lys.RauigkeitB1", -100000000000.0);
  if "Lys.RauigkeitB2">0.0 then "Lys.RauigkeitB2" # Min("Lys.RauigkeitB2", 100000000000.0)
  else "Lys.RauigkeitB2" # Max("Lys.RauigkeitB2", -100000000000.0);
  if "Lys.Streckgrenze2">0.0 then "Lys.Streckgrenze2" # Min("Lys.Streckgrenze2", 100000000000.0)
  else "Lys.Streckgrenze2" # Max("Lys.Streckgrenze2", -100000000000.0);
  if "Lys.Zugfestigkeit2">0.0 then "Lys.Zugfestigkeit2" # Min("Lys.Zugfestigkeit2", 100000000000.0)
  else "Lys.Zugfestigkeit2" # Max("Lys.Zugfestigkeit2", -100000000000.0);
  if "Lys.RP02_2">0.0 then "Lys.RP02_2" # Min("Lys.RP02_2", 100000000000.0)
  else "Lys.RP02_2" # Max("Lys.RP02_2", -100000000000.0);
  if "Lys.RP10_2">0.0 then "Lys.RP10_2" # Min("Lys.RP10_2", 100000000000.0)
  else "Lys.RP10_2" # Max("Lys.RP10_2", -100000000000.0);
  if "Lys.Körnung2">0.0 then "Lys.Körnung2" # Min("Lys.Körnung2", 100000000000.0)
  else "Lys.Körnung2" # Max("Lys.Körnung2", -100000000000.0);
  if "Lys.DehnungC">0.0 then "Lys.DehnungC" # Min("Lys.DehnungC", 100000000000.0)
  else "Lys.DehnungC" # Max("Lys.DehnungC", -100000000000.0);
  if "Lys.RauigkeitC1">0.0 then "Lys.RauigkeitC1" # Min("Lys.RauigkeitC1", 100000000000.0)
  else "Lys.RauigkeitC1" # Max("Lys.RauigkeitC1", -100000000000.0);
  if "Lys.RauigkeitC2">0.0 then "Lys.RauigkeitC2" # Min("Lys.RauigkeitC2", 100000000000.0)
  else "Lys.RauigkeitC2" # Max("Lys.RauigkeitC2", -100000000000.0);
  if "Lys.CG1">0.0 then "Lys.CG1" # Min("Lys.CG1", 100000000000.0)
  else "Lys.CG1" # Max("Lys.CG1", -100000000000.0);
  if "Lys.CG2">0.0 then "Lys.CG2" # Min("Lys.CG2", 100000000000.0)
  else "Lys.CG2" # Max("Lys.CG2", -100000000000.0);
  if "Lys.FA1">0.0 then "Lys.FA1" # Min("Lys.FA1", 100000000000.0)
  else "Lys.FA1" # Max("Lys.FA1", -100000000000.0);
  if "Lys.FA2">0.0 then "Lys.FA2" # Min("Lys.FA2", 100000000000.0)
  else "Lys.FA2" # Max("Lys.FA2", -100000000000.0);
  if "Lys.PA1">0.0 then "Lys.PA1" # Min("Lys.PA1", 100000000000.0)
  else "Lys.PA1" # Max("Lys.PA1", -100000000000.0);
  if "Lys.PA2">0.0 then "Lys.PA2" # Min("Lys.PA2", 100000000000.0)
  else "Lys.PA2" # Max("Lys.PA2", -100000000000.0);
  if "Lys.CN1">0.0 then "Lys.CN1" # Min("Lys.CN1", 100000000000.0)
  else "Lys.CN1" # Max("Lys.CN1", -100000000000.0);
  if "Lys.CN2">0.0 then "Lys.CN2" # Min("Lys.CN2", 100000000000.0)
  else "Lys.CN2" # Max("Lys.CN2", -100000000000.0);
  if "Lys.CZ1">0.0 then "Lys.CZ1" # Min("Lys.CZ1", 100000000000.0)
  else "Lys.CZ1" # Max("Lys.CZ1", -100000000000.0);
  if "Lys.CZ2">0.0 then "Lys.CZ2" # Min("Lys.CZ2", 100000000000.0)
  else "Lys.CZ2" # Max("Lys.CZ2", -100000000000.0);
  if "Lys.ZE1">0.0 then "Lys.ZE1" # Min("Lys.ZE1", 100000000000.0)
  else "Lys.ZE1" # Max("Lys.ZE1", -100000000000.0);
  if "Lys.ZE2">0.0 then "Lys.ZE2" # Min("Lys.ZE2", 100000000000.0)
  else "Lys.ZE2" # Max("Lys.ZE2", -100000000000.0);
  if "Lys.HC">0.0 then "Lys.HC" # Min("Lys.HC", 100000000000.0)
  else "Lys.HC" # Max("Lys.HC", -100000000000.0);
  if "Lys.SS">0.0 then "Lys.SS" # Min("Lys.SS", 100000000000.0)
  else "Lys.SS" # Max("Lys.SS", -100000000000.0);
  if "Lys.OA">0.0 then "Lys.OA" # Min("Lys.OA", 100000000000.0)
  else "Lys.OA" # Max("Lys.OA", -100000000000.0);
  if "Lys.OS">0.0 then "Lys.OS" # Min("Lys.OS", 100000000000.0)
  else "Lys.OS" # Max("Lys.OS", -100000000000.0);
  if "Lys.OG">0.0 then "Lys.OG" # Min("Lys.OG", 100000000000.0)
  else "Lys.OG" # Max("Lys.OG", -100000000000.0);
  if "Lys.Parallelitaet">0.0 then "Lys.Parallelitaet" # Min("Lys.Parallelitaet", 100000000000.0)
  else "Lys.Parallelitaet" # Max("Lys.Parallelitaet", -100000000000.0);
  if "Lys.Planlage">0.0 then "Lys.Planlage" # Min("Lys.Planlage", 100000000000.0)
  else "Lys.Planlage" # Max("Lys.Planlage", -100000000000.0);
  if "Lys.Ebenheit">0.0 then "Lys.Ebenheit" # Min("Lys.Ebenheit", 100000000000.0)
  else "Lys.Ebenheit" # Max("Lys.Ebenheit", -100000000000.0);
  if "Lys.Saebeligkeit">0.0 then "Lys.Saebeligkeit" # Min("Lys.Saebeligkeit", 100000000000.0)
  else "Lys.Saebeligkeit" # Max("Lys.Saebeligkeit", -100000000000.0);
  if "Lys.SaebelProM">0.0 then "Lys.SaebelProM" # Min("Lys.SaebelProM", 100000000000.0)
  else "Lys.SaebelProM" # Max("Lys.SaebelProM", -100000000000.0);
  if "Lys.StreckgrenzeQ1">0.0 then "Lys.StreckgrenzeQ1" # Min("Lys.StreckgrenzeQ1", 100000000000.0)
  else "Lys.StreckgrenzeQ1" # Max("Lys.StreckgrenzeQ1", -100000000000.0);
  if "Lys.StreckgrenzeQ2">0.0 then "Lys.StreckgrenzeQ2" # Min("Lys.StreckgrenzeQ2", 100000000000.0)
  else "Lys.StreckgrenzeQ2" # Max("Lys.StreckgrenzeQ2", -100000000000.0);
  if "Lys.ZugfestigkeitQ1">0.0 then "Lys.ZugfestigkeitQ1" # Min("Lys.ZugfestigkeitQ1", 100000000000.0)
  else "Lys.ZugfestigkeitQ1" # Max("Lys.ZugfestigkeitQ1", -100000000000.0);
  if "Lys.ZugfestigkeitQ2">0.0 then "Lys.ZugfestigkeitQ2" # Min("Lys.ZugfestigkeitQ2", 100000000000.0)
  else "Lys.ZugfestigkeitQ2" # Max("Lys.ZugfestigkeitQ2", -100000000000.0);
  if "Lys.DehnungQA">0.0 then "Lys.DehnungQA" # Min("Lys.DehnungQA", 100000000000.0)
  else "Lys.DehnungQA" # Max("Lys.DehnungQA", -100000000000.0);
  if "Lys.DehnungQB">0.0 then "Lys.DehnungQB" # Min("Lys.DehnungQB", 100000000000.0)
  else "Lys.DehnungQB" # Max("Lys.DehnungQB", -100000000000.0);
  if "Lys.DehnungQC">0.0 then "Lys.DehnungQC" # Min("Lys.DehnungQC", 100000000000.0)
  else "Lys.DehnungQC" # Max("Lys.DehnungQC", -100000000000.0);
  if "Lys.SGVerhaeltnis1">0.0 then "Lys.SGVerhaeltnis1" # Min("Lys.SGVerhaeltnis1", 100000000000.0)
  else "Lys.SGVerhaeltnis1" # Max("Lys.SGVerhaeltnis1", -100000000000.0);
  if "Lys.SGVerhaeltnis2">0.0 then "Lys.SGVerhaeltnis2" # Min("Lys.SGVerhaeltnis2", 100000000000.0)
  else "Lys.SGVerhaeltnis2" # Max("Lys.SGVerhaeltnis2", -100000000000.0);
  if "Lys.GleichmassDehn">0.0 then "Lys.GleichmassDehn" # Min("Lys.GleichmassDehn", 100000000000.0)
  else "Lys.GleichmassDehn" # Max("Lys.GleichmassDehn", -100000000000.0);
  if "Lys.GleichmassDehnQ">0.0 then "Lys.GleichmassDehnQ" # Min("Lys.GleichmassDehnQ", 100000000000.0)
  else "Lys.GleichmassDehnQ" # Max("Lys.GleichmassDehnQ", -100000000000.0);
  if "Lys.rWert">0.0 then "Lys.rWert" # Min("Lys.rWert", 100000000000.0)
  else "Lys.rWert" # Max("Lys.rWert", -100000000000.0);
  if "Lys.nWert">0.0 then "Lys.nWert" # Min("Lys.nWert", 100000000000.0)
  else "Lys.nWert" # Max("Lys.nWert", -100000000000.0);
  if "Lys.Randentkohl">0.0 then "Lys.Randentkohl" # Min("Lys.Randentkohl", 100000000000.0)
  else "Lys.Randentkohl" # Max("Lys.Randentkohl", -100000000000.0);
  if "Lys.Kantenwinkel">0.0 then "Lys.Kantenwinkel" # Min("Lys.Kantenwinkel", 100000000000.0)
  else "Lys.Kantenwinkel" # Max("Lys.Kantenwinkel", -100000000000.0);
  if "Lys.Kantenradius">0.0 then "Lys.Kantenradius" # Min("Lys.Kantenradius", 100000000000.0)
  else "Lys.Kantenradius" # Max("Lys.Kantenradius", -100000000000.0);
  if "Lys.Kantenradius2">0.0 then "Lys.Kantenradius2" # Min("Lys.Kantenradius2", 100000000000.0)
  else "Lys.Kantenradius2" # Max("Lys.Kantenradius2", -100000000000.0);
  if "Lys.EbenheitProM">0.0 then "Lys.EbenheitProM" # Min("Lys.EbenheitProM", 100000000000.0)
  else "Lys.EbenheitProM" # Max("Lys.EbenheitProM", -100000000000.0);
  if "Lys.EbenheitQ">0.0 then "Lys.EbenheitQ" # Min("Lys.EbenheitQ", 100000000000.0)
  else "Lys.EbenheitQ" # Max("Lys.EbenheitQ", -100000000000.0);
  if "Lys.Chemie.C2">0.0 then "Lys.Chemie.C2" # Min("Lys.Chemie.C2", 100000000000.0)
  else "Lys.Chemie.C2" # Max("Lys.Chemie.C2", -100000000000.0);
  if "Lys.Chemie.Si2">0.0 then "Lys.Chemie.Si2" # Min("Lys.Chemie.Si2", 100000000000.0)
  else "Lys.Chemie.Si2" # Max("Lys.Chemie.Si2", -100000000000.0);
  if "Lys.Chemie.Mn2">0.0 then "Lys.Chemie.Mn2" # Min("Lys.Chemie.Mn2", 100000000000.0)
  else "Lys.Chemie.Mn2" # Max("Lys.Chemie.Mn2", -100000000000.0);
  if "Lys.Chemie.P2">0.0 then "Lys.Chemie.P2" # Min("Lys.Chemie.P2", 100000000000.0)
  else "Lys.Chemie.P2" # Max("Lys.Chemie.P2", -100000000000.0);
  if "Lys.Chemie.S2">0.0 then "Lys.Chemie.S2" # Min("Lys.Chemie.S2", 100000000000.0)
  else "Lys.Chemie.S2" # Max("Lys.Chemie.S2", -100000000000.0);
  if "Lys.Chemie.Al2">0.0 then "Lys.Chemie.Al2" # Min("Lys.Chemie.Al2", 100000000000.0)
  else "Lys.Chemie.Al2" # Max("Lys.Chemie.Al2", -100000000000.0);
  if "Lys.Chemie.Cr2">0.0 then "Lys.Chemie.Cr2" # Min("Lys.Chemie.Cr2", 100000000000.0)
  else "Lys.Chemie.Cr2" # Max("Lys.Chemie.Cr2", -100000000000.0);
  if "Lys.Chemie.V2">0.0 then "Lys.Chemie.V2" # Min("Lys.Chemie.V2", 100000000000.0)
  else "Lys.Chemie.V2" # Max("Lys.Chemie.V2", -100000000000.0);
  if "Lys.Chemie.Nb2">0.0 then "Lys.Chemie.Nb2" # Min("Lys.Chemie.Nb2", 100000000000.0)
  else "Lys.Chemie.Nb2" # Max("Lys.Chemie.Nb2", -100000000000.0);
  if "Lys.Chemie.Ti2">0.0 then "Lys.Chemie.Ti2" # Min("Lys.Chemie.Ti2", 100000000000.0)
  else "Lys.Chemie.Ti2" # Max("Lys.Chemie.Ti2", -100000000000.0);
  if "Lys.Chemie.N2">0.0 then "Lys.Chemie.N2" # Min("Lys.Chemie.N2", 100000000000.0)
  else "Lys.Chemie.N2" # Max("Lys.Chemie.N2", -100000000000.0);
  if "Lys.Chemie.Cu2">0.0 then "Lys.Chemie.Cu2" # Min("Lys.Chemie.Cu2", 100000000000.0)
  else "Lys.Chemie.Cu2" # Max("Lys.Chemie.Cu2", -100000000000.0);
  if "Lys.Chemie.Ni2">0.0 then "Lys.Chemie.Ni2" # Min("Lys.Chemie.Ni2", 100000000000.0)
  else "Lys.Chemie.Ni2" # Max("Lys.Chemie.Ni2", -100000000000.0);
  if "Lys.Chemie.Mo2">0.0 then "Lys.Chemie.Mo2" # Min("Lys.Chemie.Mo2", 100000000000.0)
  else "Lys.Chemie.Mo2" # Max("Lys.Chemie.Mo2", -100000000000.0);
  if "Lys.Chemie.B2">0.0 then "Lys.Chemie.B2" # Min("Lys.Chemie.B2", 100000000000.0)
  else "Lys.Chemie.B2" # Max("Lys.Chemie.B2", -100000000000.0);
  if "Lys.Chemie.Frei1_2">0.0 then "Lys.Chemie.Frei1_2" # Min("Lys.Chemie.Frei1_2", 100000000000.0)
  else "Lys.Chemie.Frei1_2" # Max("Lys.Chemie.Frei1_2", -100000000000.0);
  if "Lys.Chemie.Sn">0.0 then "Lys.Chemie.Sn" # Min("Lys.Chemie.Sn", 100000000000.0)
  else "Lys.Chemie.Sn" # Max("Lys.Chemie.Sn", -100000000000.0);
  if "Lys.Chemie.Sn2">0.0 then "Lys.Chemie.Sn2" # Min("Lys.Chemie.Sn2", 100000000000.0)
  else "Lys.Chemie.Sn2" # Max("Lys.Chemie.Sn2", -100000000000.0);
  if "Lys.Chemie.Pb">0.0 then "Lys.Chemie.Pb" # Min("Lys.Chemie.Pb", 100000000000.0)
  else "Lys.Chemie.Pb" # Max("Lys.Chemie.Pb", -100000000000.0);
  if "Lys.Chemie.Pb2">0.0 then "Lys.Chemie.Pb2" # Min("Lys.Chemie.Pb2", 100000000000.0)
  else "Lys.Chemie.Pb2" # Max("Lys.Chemie.Pb2", -100000000000.0);
  if "Lys.Chemie.NbTiV">0.0 then "Lys.Chemie.NbTiV" # Min("Lys.Chemie.NbTiV", 100000000000.0)
  else "Lys.Chemie.NbTiV" # Max("Lys.Chemie.NbTiV", -100000000000.0);
  if "Lys.Chemie.NbTiV2">0.0 then "Lys.Chemie.NbTiV2" # Min("Lys.Chemie.NbTiV2", 100000000000.0)
  else "Lys.Chemie.NbTiV2" # Max("Lys.Chemie.NbTiV2", -100000000000.0);
  if "Lys.Chemie.SiP">0.0 then "Lys.Chemie.SiP" # Min("Lys.Chemie.SiP", 100000000000.0)
  else "Lys.Chemie.SiP" # Max("Lys.Chemie.SiP", -100000000000.0);
  if "Lys.Chemie.SiP2">0.0 then "Lys.Chemie.SiP2" # Min("Lys.Chemie.SiP2", 100000000000.0)
  else "Lys.Chemie.SiP2" # Max("Lys.Chemie.SiP2", -100000000000.0);
  if "Lys.Chemie.CEV">0.0 then "Lys.Chemie.CEV" # Min("Lys.Chemie.CEV", 100000000000.0)
  else "Lys.Chemie.CEV" # Max("Lys.Chemie.CEV", -100000000000.0);
  if "Lys.Chemie.CEV2">0.0 then "Lys.Chemie.CEV2" # Min("Lys.Chemie.CEV2", 100000000000.0)
  else "Lys.Chemie.CEV2" # Max("Lys.Chemie.CEV2", -100000000000.0);
  if "Lys.Chemie.Si25P">0.0 then "Lys.Chemie.Si25P" # Min("Lys.Chemie.Si25P", 100000000000.0)
  else "Lys.Chemie.Si25P" # Max("Lys.Chemie.Si25P", -100000000000.0);
  if "Lys.Chemie.Si25P2">0.0 then "Lys.Chemie.Si25P2" # Min("Lys.Chemie.Si25P2", 100000000000.0)
  else "Lys.Chemie.Si25P2" # Max("Lys.Chemie.Si25P2", -100000000000.0);
  if "Lys.Chemie.CrMoNi">0.0 then "Lys.Chemie.CrMoNi" # Min("Lys.Chemie.CrMoNi", 100000000000.0)
  else "Lys.Chemie.CrMoNi" # Max("Lys.Chemie.CrMoNi", -100000000000.0);
  if "Lys.Chemie.CrMoNi2">0.0 then "Lys.Chemie.CrMoNi2" # Min("Lys.Chemie.CrMoNi2", 100000000000.0)
  else "Lys.Chemie.CrMoNi2" # Max("Lys.Chemie.CrMoNi2", -100000000000.0);
  if "Lys.Frei.Wert1">0.0 then "Lys.Frei.Wert1" # Min("Lys.Frei.Wert1", 100000000000.0)
  else "Lys.Frei.Wert1" # Max("Lys.Frei.Wert1", -100000000000.0);
  if "Lys.Frei.Wert2">0.0 then "Lys.Frei.Wert2" # Min("Lys.Frei.Wert2", 100000000000.0)
  else "Lys.Frei.Wert2" # Max("Lys.Frei.Wert2", -100000000000.0);
  if "Lys.Frei.Wert3">0.0 then "Lys.Frei.Wert3" # Min("Lys.Frei.Wert3", 100000000000.0)
  else "Lys.Frei.Wert3" # Max("Lys.Frei.Wert3", -100000000000.0);
  if "Lys.Frei.Wert4">0.0 then "Lys.Frei.Wert4" # Min("Lys.Frei.Wert4", 100000000000.0)
  else "Lys.Frei.Wert4" # Max("Lys.Frei.Wert4", -100000000000.0);
end;

// -------------------------------------------------
sub EX250()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0250'
     +cnvai(RecInfo(250,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(250, _recModified);
  GV.Alpha.02 # Bool("Art.LagerjournalYN");
  GV.Alpha.03 # Bool("Art.ChargenführungYN");
  GV.Alpha.04 # Bool("Art.SeriennummerYN");
  GV.Alpha.05 # Bool("Art.AutoBestellYN");
  if "Art.Bestand.Min">0.0 then "Art.Bestand.Min" # Min("Art.Bestand.Min", 100000000000.0)
  else "Art.Bestand.Min" # Max("Art.Bestand.Min", -100000000000.0);
  if "Art.Bestand.Soll">0.0 then "Art.Bestand.Soll" # Min("Art.Bestand.Soll", 100000000000.0)
  else "Art.Bestand.Soll" # Max("Art.Bestand.Soll", -100000000000.0);
  if "Art.Bestand.Inventur">0.0 then "Art.Bestand.Inventur" # Min("Art.Bestand.Inventur", 100000000000.0)
  else "Art.Bestand.Inventur" # Max("Art.Bestand.Inventur", -100000000000.0);
  GV.Alpha.06 # Datum("Art.Inventurdatum");
  GV.Alpha.07 # Bool("Art.GesperrtYN");
  if "Art.GewichtProStk">0.0 then "Art.GewichtProStk" # Min("Art.GewichtProStk", 100000000000.0)
  else "Art.GewichtProStk" # Max("Art.GewichtProStk", -100000000000.0);
  if "Art.Länge">0.0 then "Art.Länge" # Min("Art.Länge", 100000000000.0)
  else "Art.Länge" # Max("Art.Länge", -100000000000.0);
  if "Art.Breite">0.0 then "Art.Breite" # Min("Art.Breite", 100000000000.0)
  else "Art.Breite" # Max("Art.Breite", -100000000000.0);
  if "Art.Dicke">0.0 then "Art.Dicke" # Min("Art.Dicke", 100000000000.0)
  else "Art.Dicke" # Max("Art.Dicke", -100000000000.0);
  if "Art.Volumen">0.0 then "Art.Volumen" # Min("Art.Volumen", 100000000000.0)
  else "Art.Volumen" # Max("Art.Volumen", -100000000000.0);
  if "Art.Fläche">0.0 then "Art.Fläche" # Min("Art.Fläche", 100000000000.0)
  else "Art.Fläche" # Max("Art.Fläche", -100000000000.0);
  if "Art.Fert.Dauer">0.0 then "Art.Fert.Dauer" # Min("Art.Fert.Dauer", 100000000000.0)
  else "Art.Fert.Dauer" # Max("Art.Fert.Dauer", -100000000000.0);
  if "Art.Fert.KostenW1">0.0 then "Art.Fert.KostenW1" # Min("Art.Fert.KostenW1", 100000000000.0)
  else "Art.Fert.KostenW1" # Max("Art.Fert.KostenW1", -100000000000.0);
  if "Art.Aussendmesser">0.0 then "Art.Aussendmesser" # Min("Art.Aussendmesser", 100000000000.0)
  else "Art.Aussendmesser" # Max("Art.Aussendmesser", -100000000000.0);
  GV.Alpha.08 # Bool("Art.KubischYN");
  GV.Alpha.09 # Bool("Art.RotativYN");
  if "Art.Innendmesser">0.0 then "Art.Innendmesser" # Min("Art.Innendmesser", 100000000000.0)
  else "Art.Innendmesser" # Max("Art.Innendmesser", -100000000000.0);
  if "Art.SpezGewicht">0.0 then "Art.SpezGewicht" # Min("Art.SpezGewicht", 100000000000.0)
  else "Art.SpezGewicht" # Max("Art.SpezGewicht", -100000000000.0);
  if "Art.GewichtProM">0.0 then "Art.GewichtProM" # Min("Art.GewichtProM", 100000000000.0)
  else "Art.GewichtProM" # Max("Art.GewichtProM", -100000000000.0);
  GV.Alpha.10 # Bool("Art.Bild.DruckenYN");
  GV.Alpha.11 # Bool("Art.SLRefreshNötigYN");
  if "Art.Cust.Sort.Num1">0.0 then "Art.Cust.Sort.Num1" # Min("Art.Cust.Sort.Num1", 100000000000.0)
  else "Art.Cust.Sort.Num1" # Max("Art.Cust.Sort.Num1", -100000000000.0);
  if "Art.Cust.Sort.Num2">0.0 then "Art.Cust.Sort.Num2" # Min("Art.Cust.Sort.Num2", 100000000000.0)
  else "Art.Cust.Sort.Num2" # Max("Art.Cust.Sort.Num2", -100000000000.0);
  if "Art.Cust.Sort.Num3">0.0 then "Art.Cust.Sort.Num3" # Min("Art.Cust.Sort.Num3", 100000000000.0)
  else "Art.Cust.Sort.Num3" # Max("Art.Cust.Sort.Num3", -100000000000.0);
  if "Art.Cust.Sort.Num4">0.0 then "Art.Cust.Sort.Num4" # Min("Art.Cust.Sort.Num4", 100000000000.0)
  else "Art.Cust.Sort.Num4" # Max("Art.Cust.Sort.Num4", -100000000000.0);
end;

// -------------------------------------------------
sub EX252()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0252'
     +cnvai(RecInfo(252,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(252, _recModified);
  GV.Alpha.02 # Datum("Art.C.Eingangsdatum");
  GV.Alpha.03 # Datum("Art.C.Ausgangsdatum");
  GV.Alpha.04 # Datum("Art.C.Inventurdatum");
  if "Art.C.Bestand">0.0 then "Art.C.Bestand" # Min("Art.C.Bestand", 100000000000.0)
  else "Art.C.Bestand" # Max("Art.C.Bestand", -100000000000.0);
  if "Art.C.Reserviert">0.0 then "Art.C.Reserviert" # Min("Art.C.Reserviert", 100000000000.0)
  else "Art.C.Reserviert" # Max("Art.C.Reserviert", -100000000000.0);
  if "Art.C.Verfügbar">0.0 then "Art.C.Verfügbar" # Min("Art.C.Verfügbar", 100000000000.0)
  else "Art.C.Verfügbar" # Max("Art.C.Verfügbar", -100000000000.0);
  if "Art.C.Bestellt">0.0 then "Art.C.Bestellt" # Min("Art.C.Bestellt", 100000000000.0)
  else "Art.C.Bestellt" # Max("Art.C.Bestellt", -100000000000.0);
  if "Art.C.OffeneAuf">0.0 then "Art.C.OffeneAuf" # Min("Art.C.OffeneAuf", 100000000000.0)
  else "Art.C.OffeneAuf" # Max("Art.C.OffeneAuf", -100000000000.0);
  if "Art.C.Fremd">0.0 then "Art.C.Fremd" # Min("Art.C.Fremd", 100000000000.0)
  else "Art.C.Fremd" # Max("Art.C.Fremd", -100000000000.0);
  if "Art.C.Kommissioniert">0.0 then "Art.C.Kommissioniert" # Min("Art.C.Kommissioniert", 100000000000.0)
  else "Art.C.Kommissioniert" # Max("Art.C.Kommissioniert", -100000000000.0);
  if "Art.C.Frei1">0.0 then "Art.C.Frei1" # Min("Art.C.Frei1", 100000000000.0)
  else "Art.C.Frei1" # Max("Art.C.Frei1", -100000000000.0);
  if "Art.C.Frei2">0.0 then "Art.C.Frei2" # Min("Art.C.Frei2", 100000000000.0)
  else "Art.C.Frei2" # Max("Art.C.Frei2", -100000000000.0);
  if "Art.C.Frei3">0.0 then "Art.C.Frei3" # Min("Art.C.Frei3", 100000000000.0)
  else "Art.C.Frei3" # Max("Art.C.Frei3", -100000000000.0);
  if "Art.C.EKDurchschnitt">0.0 then "Art.C.EKDurchschnitt" # Min("Art.C.EKDurchschnitt", 100000000000.0)
  else "Art.C.EKDurchschnitt" # Max("Art.C.EKDurchschnitt", -100000000000.0);
  if "Art.C.EKLetzter">0.0 then "Art.C.EKLetzter" # Min("Art.C.EKLetzter", 100000000000.0)
  else "Art.C.EKLetzter" # Max("Art.C.EKLetzter", -100000000000.0);
  if "Art.C.VKDurchschnitt">0.0 then "Art.C.VKDurchschnitt" # Min("Art.C.VKDurchschnitt", 100000000000.0)
  else "Art.C.VKDurchschnitt" # Max("Art.C.VKDurchschnitt", -100000000000.0);
  if "Art.C.VKLetzter">0.0 then "Art.C.VKLetzter" # Min("Art.C.VKLetzter", 100000000000.0)
  else "Art.C.VKLetzter" # Max("Art.C.VKLetzter", -100000000000.0);
  if "Art.C.Dicke">0.0 then "Art.C.Dicke" # Min("Art.C.Dicke", 100000000000.0)
  else "Art.C.Dicke" # Max("Art.C.Dicke", -100000000000.0);
  if "Art.C.Breite">0.0 then "Art.C.Breite" # Min("Art.C.Breite", 100000000000.0)
  else "Art.C.Breite" # Max("Art.C.Breite", -100000000000.0);
  if "Art.C.Länge">0.0 then "Art.C.Länge" # Min("Art.C.Länge", 100000000000.0)
  else "Art.C.Länge" # Max("Art.C.Länge", -100000000000.0);
  if "Art.C.RID">0.0 then "Art.C.RID" # Min("Art.C.RID", 100000000000.0)
  else "Art.C.RID" # Max("Art.C.RID", -100000000000.0);
  if "Art.C.RAD">0.0 then "Art.C.RAD" # Min("Art.C.RAD", 100000000000.0)
  else "Art.C.RAD" # Max("Art.C.RAD", -100000000000.0);
end;

// -------------------------------------------------
sub EX253()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0253'
     +cnvai(RecInfo(253,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(253, _recModified);
  GV.Alpha.02 # Datum("Art.J.Datum");
  if "Art.J.Menge">0.0 then "Art.J.Menge" # Min("Art.J.Menge", 100000000000.0)
  else "Art.J.Menge" # Max("Art.J.Menge", -100000000000.0);
  GV.Alpha.03 # Bool("Art.J.InventurYN");
  if "Art.J.EKDurchschnitt">0.0 then "Art.J.EKDurchschnitt" # Min("Art.J.EKDurchschnitt", 100000000000.0)
  else "Art.J.EKDurchschnitt" # Max("Art.J.EKDurchschnitt", -100000000000.0);
  if "Art.J.Ziel.EKPreisW1">0.0 then "Art.J.Ziel.EKPreisW1" # Min("Art.J.Ziel.EKPreisW1", 100000000000.0)
  else "Art.J.Ziel.EKPreisW1" # Max("Art.J.Ziel.EKPreisW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX254()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0254'
     +cnvai(RecInfo(254,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(254, _recModified);
  if "Art.P.Preis">0.0 then "Art.P.Preis" # Min("Art.P.Preis", 100000000000.0)
  else "Art.P.Preis" # Max("Art.P.Preis", -100000000000.0);
  if "Art.P.PreisW1">0.0 then "Art.P.PreisW1" # Min("Art.P.PreisW1", 100000000000.0)
  else "Art.P.PreisW1" # Max("Art.P.PreisW1", -100000000000.0);
  if "Art.P.abMenge">0.0 then "Art.P.abMenge" # Min("Art.P.abMenge", 100000000000.0)
  else "Art.P.abMenge" # Max("Art.P.abMenge", -100000000000.0);
  GV.Alpha.02 # Bool("Art.P.inclMwSt");
  GV.Alpha.03 # Datum("Art.P.Datum.Von");
  GV.Alpha.04 # Datum("Art.P.Datum.Bis");
  GV.Alpha.05 # Datum("Art.P.AngebotDatum");
  if "Art.P.Basispreis">0.0 then "Art.P.Basispreis" # Min("Art.P.Basispreis", 100000000000.0)
  else "Art.P.Basispreis" # Max("Art.P.Basispreis", -100000000000.0);
  if "Art.P.RabattProz">0.0 then "Art.P.RabattProz" # Min("Art.P.RabattProz", 100000000000.0)
  else "Art.P.RabattProz" # Max("Art.P.RabattProz", -100000000000.0);
  if "Art.P.MindestAbnahme">0.0 then "Art.P.MindestAbnahme" # Min("Art.P.MindestAbnahme", 100000000000.0)
  else "Art.P.MindestAbnahme" # Max("Art.P.MindestAbnahme", -100000000000.0);
end;

// -------------------------------------------------
sub EX255()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0255'
     +cnvai(RecInfo(255,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(255, _recModified);
  if "Art.SLK.Fert.Dauer">0.0 then "Art.SLK.Fert.Dauer" # Min("Art.SLK.Fert.Dauer", 100000000000.0)
  else "Art.SLK.Fert.Dauer" # Max("Art.SLK.Fert.Dauer", -100000000000.0);
  if "Art.SLK.Fert.KostW1">0.0 then "Art.SLK.Fert.KostW1" # Min("Art.SLK.Fert.KostW1", 100000000000.0)
  else "Art.SLK.Fert.KostW1" # Max("Art.SLK.Fert.KostW1", -100000000000.0);
  if "Art.SLK.Mat.KostW1">0.0 then "Art.SLK.Mat.KostW1" # Min("Art.SLK.Mat.KostW1", 100000000000.0)
  else "Art.SLK.Mat.KostW1" # Max("Art.SLK.Mat.KostW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX256()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0256'
     +cnvai(RecInfo(256,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(256, _recModified);
  if "Art.SL.Menge">0.0 then "Art.SL.Menge" # Min("Art.SL.Menge", 100000000000.0)
  else "Art.SL.Menge" # Max("Art.SL.Menge", -100000000000.0);
  GV.Alpha.02 # Bool("Art.SL.Kosten.StdYN");
  if "Art.SL.Kosten.FixW1">0.0 then "Art.SL.Kosten.FixW1" # Min("Art.SL.Kosten.FixW1", 100000000000.0)
  else "Art.SL.Kosten.FixW1" # Max("Art.SL.Kosten.FixW1", -100000000000.0);
  if "Art.SL.Kosten.VarW1">0.0 then "Art.SL.Kosten.VarW1" # Min("Art.SL.Kosten.VarW1", 100000000000.0)
  else "Art.SL.Kosten.VarW1" # Max("Art.SL.Kosten.VarW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX280()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0280'
     +cnvai(RecInfo(280,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("Pak.Anlage.Datum");
  GV.Int64.01 # RecInfo(280, _recModified);
  if "Pak.Gewicht">0.0 then "Pak.Gewicht" # Min("Pak.Gewicht", 100000000000.0)
  else "Pak.Gewicht" # Max("Pak.Gewicht", -100000000000.0);
  if "Pak.Zwischenlage.H">0.0 then "Pak.Zwischenlage.H" # Min("Pak.Zwischenlage.H", 100000000000.0)
  else "Pak.Zwischenlage.H" # Max("Pak.Zwischenlage.H", -100000000000.0);
  if "Pak.Unterlage.H">0.0 then "Pak.Unterlage.H" # Min("Pak.Unterlage.H", 100000000000.0)
  else "Pak.Unterlage.H" # Max("Pak.Unterlage.H", -100000000000.0);
  if "Pak.Umverpackung.H">0.0 then "Pak.Umverpackung.H" # Min("Pak.Umverpackung.H", 100000000000.0)
  else "Pak.Umverpackung.H" # Max("Pak.Umverpackung.H", -100000000000.0);
  if "Pak.Inhalt.Netto">0.0 then "Pak.Inhalt.Netto" # Min("Pak.Inhalt.Netto", 100000000000.0)
  else "Pak.Inhalt.Netto" # Max("Pak.Inhalt.Netto", -100000000000.0);
  if "Pak.Inhalt.Brutto">0.0 then "Pak.Inhalt.Brutto" # Min("Pak.Inhalt.Brutto", 100000000000.0)
  else "Pak.Inhalt.Brutto" # Max("Pak.Inhalt.Brutto", -100000000000.0);
  if "Pak.Dicke">0.0 then "Pak.Dicke" # Min("Pak.Dicke", 100000000000.0)
  else "Pak.Dicke" # Max("Pak.Dicke", -100000000000.0);
  if "Pak.Breite">0.0 then "Pak.Breite" # Min("Pak.Breite", 100000000000.0)
  else "Pak.Breite" # Max("Pak.Breite", -100000000000.0);
  if "Pak.Länge">0.0 then "Pak.Länge" # Min("Pak.Länge", 100000000000.0)
  else "Pak.Länge" # Max("Pak.Länge", -100000000000.0);
end;

// -------------------------------------------------
sub EX281()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0281'
     +cnvai(RecInfo(281,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(281, _recModified);
end;

// -------------------------------------------------
sub EX300()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0300'
     +cnvai(RecInfo(300,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(300, _recModified);
  GV.Alpha.02 # Datum("Rek.Datum");
end;

// -------------------------------------------------
sub EX301()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0301'
     +cnvai(RecInfo(301,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(301, _recModified);
  if "Rek.P.Menge">0.0 then "Rek.P.Menge" # Min("Rek.P.Menge", 100000000000.0)
  else "Rek.P.Menge" # Max("Rek.P.Menge", -100000000000.0);
  if "Rek.P.Gewicht">0.0 then "Rek.P.Gewicht" # Min("Rek.P.Gewicht", 100000000000.0)
  else "Rek.P.Gewicht" # Max("Rek.P.Gewicht", -100000000000.0);
  if "Rek.P.Wert">0.0 then "Rek.P.Wert" # Min("Rek.P.Wert", 100000000000.0)
  else "Rek.P.Wert" # Max("Rek.P.Wert", -100000000000.0);
  if "Rek.P.Wert.W1">0.0 then "Rek.P.Wert.W1" # Min("Rek.P.Wert.W1", 100000000000.0)
  else "Rek.P.Wert.W1" # Max("Rek.P.Wert.W1", -100000000000.0);
  if "Rek.P.Aner.Gew">0.0 then "Rek.P.Aner.Gew" # Min("Rek.P.Aner.Gew", 100000000000.0)
  else "Rek.P.Aner.Gew" # Max("Rek.P.Aner.Gew", -100000000000.0);
  if "Rek.P.Aner.Menge">0.0 then "Rek.P.Aner.Menge" # Min("Rek.P.Aner.Menge", 100000000000.0)
  else "Rek.P.Aner.Menge" # Max("Rek.P.Aner.Menge", -100000000000.0);
  if "Rek.P.Aner.Wert">0.0 then "Rek.P.Aner.Wert" # Min("Rek.P.Aner.Wert", 100000000000.0)
  else "Rek.P.Aner.Wert" # Max("Rek.P.Aner.Wert", -100000000000.0);
  if "Rek.P.Aner.WertW1">0.0 then "Rek.P.Aner.WertW1" # Min("Rek.P.Aner.WertW1", 100000000000.0)
  else "Rek.P.Aner.WertW1" # Max("Rek.P.Aner.WertW1", -100000000000.0);
  GV.Alpha.02 # Datum("Rek.P.Datum");
  GV.Alpha.03 # Datum("Rek.P.Status.Datum");
  GV.Alpha.04 # Zeit("Rek.P.Status.Zeit");
end;

// -------------------------------------------------
sub EX302()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0302'
     +cnvai(RecInfo(302,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(302, _recModified);
  GV.Alpha.02 # Datum("Rek.A.Aktionsdatum");
  GV.Alpha.03 # Datum("Rek.A.TerminStart");
  GV.Alpha.04 # Datum("Rek.A.TerminEnde");
  GV.Alpha.05 # Bool("Rek.A.AnerkennungYN");
  if "Rek.A.Menge">0.0 then "Rek.A.Menge" # Min("Rek.A.Menge", 100000000000.0)
  else "Rek.A.Menge" # Max("Rek.A.Menge", -100000000000.0);
  if "Rek.A.Gewicht">0.0 then "Rek.A.Gewicht" # Min("Rek.A.Gewicht", 100000000000.0)
  else "Rek.A.Gewicht" # Max("Rek.A.Gewicht", -100000000000.0);
  if "Rek.A.Kosten">0.0 then "Rek.A.Kosten" # Min("Rek.A.Kosten", 100000000000.0)
  else "Rek.A.Kosten" # Max("Rek.A.Kosten", -100000000000.0);
  if "Rek.A.KostenW1">0.0 then "Rek.A.KostenW1" # Min("Rek.A.KostenW1", 100000000000.0)
  else "Rek.A.KostenW1" # Max("Rek.A.KostenW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX400()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0400'
     +cnvai(RecInfo(400,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(400, _recModified);
  GV.Alpha.02 # Datum("Auf.Datum");
  GV.Alpha.03 # Bool("Auf.LiefervertragYN");
  GV.Alpha.04 # Bool("Auf.AbrufYN");
  GV.Alpha.05 # Datum("Auf.GültigkeitVom");
  GV.Alpha.06 # Datum("Auf.GültigkeitBis");
  if "Auf.Währungskurs">0.0 then "Auf.Währungskurs" # Min("Auf.Währungskurs", 100000000000.0)
  else "Auf.Währungskurs" # Max("Auf.Währungskurs", -100000000000.0);
  GV.Alpha.07 # Bool("Auf.WährungFixYN");
  GV.Alpha.08 # Datum("Auf.Best.Datum");
  if "Auf.Vertreter.Prov">0.0 then "Auf.Vertreter.Prov" # Min("Auf.Vertreter.Prov", 100000000000.0)
  else "Auf.Vertreter.Prov" # Max("Auf.Vertreter.Prov", -100000000000.0);
  if "Auf.Vertreter.ProT">0.0 then "Auf.Vertreter.ProT" # Min("Auf.Vertreter.ProT", 100000000000.0)
  else "Auf.Vertreter.ProT" # Max("Auf.Vertreter.ProT", -100000000000.0);
  if "Auf.Vertreter2.Prov">0.0 then "Auf.Vertreter2.Prov" # Min("Auf.Vertreter2.Prov", 100000000000.0)
  else "Auf.Vertreter2.Prov" # Max("Auf.Vertreter2.Prov", -100000000000.0);
  if "Auf.Vertreter2.ProT">0.0 then "Auf.Vertreter2.ProT" # Min("Auf.Vertreter2.ProT", 100000000000.0)
  else "Auf.Vertreter2.ProT" # Max("Auf.Vertreter2.ProT", -100000000000.0);
  GV.Alpha.09 # Bool("Auf.PAbrufYN");
  GV.Alpha.10 # Datum("Auf.Freigabe.Datum");
  GV.Alpha.11 # Zeit("Auf.Freigabe.Zeit");
  if "Auf.Freigabe.WertW1">0.0 then "Auf.Freigabe.WertW1" # Min("Auf.Freigabe.WertW1", 100000000000.0)
  else "Auf.Freigabe.WertW1" # Max("Auf.Freigabe.WertW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX401()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0401'
     +cnvai(RecInfo(401,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(401, _recModified);
  if "Auf.P.Dicke">0.0 then "Auf.P.Dicke" # Min("Auf.P.Dicke", 100000000000.0)
  else "Auf.P.Dicke" # Max("Auf.P.Dicke", -100000000000.0);
  if "Auf.P.Breite">0.0 then "Auf.P.Breite" # Min("Auf.P.Breite", 100000000000.0)
  else "Auf.P.Breite" # Max("Auf.P.Breite", -100000000000.0);
  if "Auf.P.Länge">0.0 then "Auf.P.Länge" # Min("Auf.P.Länge", 100000000000.0)
  else "Auf.P.Länge" # Max("Auf.P.Länge", -100000000000.0);
  if "Auf.P.RID">0.0 then "Auf.P.RID" # Min("Auf.P.RID", 100000000000.0)
  else "Auf.P.RID" # Max("Auf.P.RID", -100000000000.0);
  if "Auf.P.RIDMax">0.0 then "Auf.P.RIDMax" # Min("Auf.P.RIDMax", 100000000000.0)
  else "Auf.P.RIDMax" # Max("Auf.P.RIDMax", -100000000000.0);
  if "Auf.P.RAD">0.0 then "Auf.P.RAD" # Min("Auf.P.RAD", 100000000000.0)
  else "Auf.P.RAD" # Max("Auf.P.RAD", -100000000000.0);
  if "Auf.P.RADMax">0.0 then "Auf.P.RADMax" # Min("Auf.P.RADMax", 100000000000.0)
  else "Auf.P.RADMax" # Max("Auf.P.RADMax", -100000000000.0);
  if "Auf.P.Gewicht">0.0 then "Auf.P.Gewicht" # Min("Auf.P.Gewicht", 100000000000.0)
  else "Auf.P.Gewicht" # Max("Auf.P.Gewicht", -100000000000.0);
  if "Auf.P.Menge.Wunsch">0.0 then "Auf.P.Menge.Wunsch" # Min("Auf.P.Menge.Wunsch", 100000000000.0)
  else "Auf.P.Menge.Wunsch" # Max("Auf.P.Menge.Wunsch", -100000000000.0);
  if "Auf.P.Grundpreis">0.0 then "Auf.P.Grundpreis" # Min("Auf.P.Grundpreis", 100000000000.0)
  else "Auf.P.Grundpreis" # Max("Auf.P.Grundpreis", -100000000000.0);
  GV.Alpha.02 # Bool("Auf.P.AufpreisYN");
  if "Auf.P.Aufpreis">0.0 then "Auf.P.Aufpreis" # Min("Auf.P.Aufpreis", 100000000000.0)
  else "Auf.P.Aufpreis" # Max("Auf.P.Aufpreis", -100000000000.0);
  if "Auf.P.Einzelpreis">0.0 then "Auf.P.Einzelpreis" # Min("Auf.P.Einzelpreis", 100000000000.0)
  else "Auf.P.Einzelpreis" # Max("Auf.P.Einzelpreis", -100000000000.0);
  if "Auf.P.Gesamtpreis">0.0 then "Auf.P.Gesamtpreis" # Min("Auf.P.Gesamtpreis", 100000000000.0)
  else "Auf.P.Gesamtpreis" # Max("Auf.P.Gesamtpreis", -100000000000.0);
  if "Auf.P.Kalkuliert">0.0 then "Auf.P.Kalkuliert" # Min("Auf.P.Kalkuliert", 100000000000.0)
  else "Auf.P.Kalkuliert" # Max("Auf.P.Kalkuliert", -100000000000.0);
  GV.Alpha.03 # Datum("Auf.P.Termin1Wunsch");
  GV.Alpha.04 # Datum("Auf.P.Termin2Wunsch");
  GV.Alpha.05 # Datum("Auf.P.TerminZusage");
  if "Auf.P.Menge">0.0 then "Auf.P.Menge" # Min("Auf.P.Menge", 100000000000.0)
  else "Auf.P.Menge" # Max("Auf.P.Menge", -100000000000.0);
  if "Auf.P.Vertr1.Prov">0.0 then "Auf.P.Vertr1.Prov" # Min("Auf.P.Vertr1.Prov", 100000000000.0)
  else "Auf.P.Vertr1.Prov" # Max("Auf.P.Vertr1.Prov", -100000000000.0);
  if "Auf.P.Vertr2.Prov">0.0 then "Auf.P.Vertr2.Prov" # Min("Auf.P.Vertr2.Prov", 100000000000.0)
  else "Auf.P.Vertr2.Prov" # Max("Auf.P.Vertr2.Prov", -100000000000.0);
  if "Auf.P.GesamtwertEKW1">0.0 then "Auf.P.GesamtwertEKW1" # Min("Auf.P.GesamtwertEKW1", 100000000000.0)
  else "Auf.P.GesamtwertEKW1" # Max("Auf.P.GesamtwertEKW1", -100000000000.0);
  if "Auf.P.Prd.Plan">0.0 then "Auf.P.Prd.Plan" # Min("Auf.P.Prd.Plan", 100000000000.0)
  else "Auf.P.Prd.Plan" # Max("Auf.P.Prd.Plan", -100000000000.0);
  if "Auf.P.Prd.Plan.Gew">0.0 then "Auf.P.Prd.Plan.Gew" # Min("Auf.P.Prd.Plan.Gew", 100000000000.0)
  else "Auf.P.Prd.Plan.Gew" # Max("Auf.P.Prd.Plan.Gew", -100000000000.0);
  if "Auf.P.Prd.VSB">0.0 then "Auf.P.Prd.VSB" # Min("Auf.P.Prd.VSB", 100000000000.0)
  else "Auf.P.Prd.VSB" # Max("Auf.P.Prd.VSB", -100000000000.0);
  if "Auf.P.Prd.VSB.Gew">0.0 then "Auf.P.Prd.VSB.Gew" # Min("Auf.P.Prd.VSB.Gew", 100000000000.0)
  else "Auf.P.Prd.VSB.Gew" # Max("Auf.P.Prd.VSB.Gew", -100000000000.0);
  if "Auf.P.Prd.VSAuf">0.0 then "Auf.P.Prd.VSAuf" # Min("Auf.P.Prd.VSAuf", 100000000000.0)
  else "Auf.P.Prd.VSAuf" # Max("Auf.P.Prd.VSAuf", -100000000000.0);
  if "Auf.P.Prd.VSAuf.Gew">0.0 then "Auf.P.Prd.VSAuf.Gew" # Min("Auf.P.Prd.VSAuf.Gew", 100000000000.0)
  else "Auf.P.Prd.VSAuf.Gew" # Max("Auf.P.Prd.VSAuf.Gew", -100000000000.0);
  if "Auf.P.Prd.LFS">0.0 then "Auf.P.Prd.LFS" # Min("Auf.P.Prd.LFS", 100000000000.0)
  else "Auf.P.Prd.LFS" # Max("Auf.P.Prd.LFS", -100000000000.0);
  if "Auf.P.Prd.LFS.Gew">0.0 then "Auf.P.Prd.LFS.Gew" # Min("Auf.P.Prd.LFS.Gew", 100000000000.0)
  else "Auf.P.Prd.LFS.Gew" # Max("Auf.P.Prd.LFS.Gew", -100000000000.0);
  if "Auf.P.Prd.Rech">0.0 then "Auf.P.Prd.Rech" # Min("Auf.P.Prd.Rech", 100000000000.0)
  else "Auf.P.Prd.Rech" # Max("Auf.P.Prd.Rech", -100000000000.0);
  if "Auf.P.Prd.Rech.Gew">0.0 then "Auf.P.Prd.Rech.Gew" # Min("Auf.P.Prd.Rech.Gew", 100000000000.0)
  else "Auf.P.Prd.Rech.Gew" # Max("Auf.P.Prd.Rech.Gew", -100000000000.0);
  if "Auf.P.Prd.Rest">0.0 then "Auf.P.Prd.Rest" # Min("Auf.P.Prd.Rest", 100000000000.0)
  else "Auf.P.Prd.Rest" # Max("Auf.P.Prd.Rest", -100000000000.0);
  if "Auf.P.Prd.Rest.Gew">0.0 then "Auf.P.Prd.Rest.Gew" # Min("Auf.P.Prd.Rest.Gew", 100000000000.0)
  else "Auf.P.Prd.Rest.Gew" # Max("Auf.P.Prd.Rest.Gew", -100000000000.0);
  if "Auf.P.GPl.Plan">0.0 then "Auf.P.GPl.Plan" # Min("Auf.P.GPl.Plan", 100000000000.0)
  else "Auf.P.GPl.Plan" # Max("Auf.P.GPl.Plan", -100000000000.0);
  if "Auf.P.GPl.Plan.Gew">0.0 then "Auf.P.GPl.Plan.Gew" # Min("Auf.P.GPl.Plan.Gew", 100000000000.0)
  else "Auf.P.GPl.Plan.Gew" # Max("Auf.P.GPl.Plan.Gew", -100000000000.0);
  if "Auf.P.Prd.Reserv">0.0 then "Auf.P.Prd.Reserv" # Min("Auf.P.Prd.Reserv", 100000000000.0)
  else "Auf.P.Prd.Reserv" # Max("Auf.P.Prd.Reserv", -100000000000.0);
  if "Auf.P.Prd.Reserv.Gew">0.0 then "Auf.P.Prd.Reserv.Gew" # Min("Auf.P.Prd.Reserv.Gew", 100000000000.0)
  else "Auf.P.Prd.Reserv.Gew" # Max("Auf.P.Prd.Reserv.Gew", -100000000000.0);
  if "Auf.P.Prd.zuBere">0.0 then "Auf.P.Prd.zuBere" # Min("Auf.P.Prd.zuBere", 100000000000.0)
  else "Auf.P.Prd.zuBere" # Max("Auf.P.Prd.zuBere", -100000000000.0);
  if "Auf.P.Prd.zuBere.Gew">0.0 then "Auf.P.Prd.zuBere.Gew" # Min("Auf.P.Prd.zuBere.Gew", 100000000000.0)
  else "Auf.P.Prd.zuBere.Gew" # Max("Auf.P.Prd.zuBere.Gew", -100000000000.0);
  if "Auf.P.Prd.EkBest">0.0 then "Auf.P.Prd.EkBest" # Min("Auf.P.Prd.EkBest", 100000000000.0)
  else "Auf.P.Prd.EkBest" # Max("Auf.P.Prd.EkBest", -100000000000.0);
  if "Auf.P.Prd.EkBest.Gew">0.0 then "Auf.P.Prd.EkBest.Gew" # Min("Auf.P.Prd.EkBest.Gew", 100000000000.0)
  else "Auf.P.Prd.EkBest.Gew" # Max("Auf.P.Prd.EkBest.Gew", -100000000000.0);
  if "Auf.P.Streckgrenze1">0.0 then "Auf.P.Streckgrenze1" # Min("Auf.P.Streckgrenze1", 100000000000.0)
  else "Auf.P.Streckgrenze1" # Max("Auf.P.Streckgrenze1", -100000000000.0);
  if "Auf.P.Streckgrenze2">0.0 then "Auf.P.Streckgrenze2" # Min("Auf.P.Streckgrenze2", 100000000000.0)
  else "Auf.P.Streckgrenze2" # Max("Auf.P.Streckgrenze2", -100000000000.0);
  if "Auf.P.Zugfestigkeit1">0.0 then "Auf.P.Zugfestigkeit1" # Min("Auf.P.Zugfestigkeit1", 100000000000.0)
  else "Auf.P.Zugfestigkeit1" # Max("Auf.P.Zugfestigkeit1", -100000000000.0);
  if "Auf.P.Zugfestigkeit2">0.0 then "Auf.P.Zugfestigkeit2" # Min("Auf.P.Zugfestigkeit2", 100000000000.0)
  else "Auf.P.Zugfestigkeit2" # Max("Auf.P.Zugfestigkeit2", -100000000000.0);
  if "Auf.P.DehnungA1">0.0 then "Auf.P.DehnungA1" # Min("Auf.P.DehnungA1", 100000000000.0)
  else "Auf.P.DehnungA1" # Max("Auf.P.DehnungA1", -100000000000.0);
  if "Auf.P.DehnungA2">0.0 then "Auf.P.DehnungA2" # Min("Auf.P.DehnungA2", 100000000000.0)
  else "Auf.P.DehnungA2" # Max("Auf.P.DehnungA2", -100000000000.0);
  if "Auf.P.DehnungB1">0.0 then "Auf.P.DehnungB1" # Min("Auf.P.DehnungB1", 100000000000.0)
  else "Auf.P.DehnungB1" # Max("Auf.P.DehnungB1", -100000000000.0);
  if "Auf.P.DehnungB2">0.0 then "Auf.P.DehnungB2" # Min("Auf.P.DehnungB2", 100000000000.0)
  else "Auf.P.DehnungB2" # Max("Auf.P.DehnungB2", -100000000000.0);
  if "Auf.P.DehngrenzeA1">0.0 then "Auf.P.DehngrenzeA1" # Min("Auf.P.DehngrenzeA1", 100000000000.0)
  else "Auf.P.DehngrenzeA1" # Max("Auf.P.DehngrenzeA1", -100000000000.0);
  if "Auf.P.DehngrenzeA2">0.0 then "Auf.P.DehngrenzeA2" # Min("Auf.P.DehngrenzeA2", 100000000000.0)
  else "Auf.P.DehngrenzeA2" # Max("Auf.P.DehngrenzeA2", -100000000000.0);
  if "Auf.P.DehngrenzeB1">0.0 then "Auf.P.DehngrenzeB1" # Min("Auf.P.DehngrenzeB1", 100000000000.0)
  else "Auf.P.DehngrenzeB1" # Max("Auf.P.DehngrenzeB1", -100000000000.0);
  if "Auf.P.DehngrenzeB2">0.0 then "Auf.P.DehngrenzeB2" # Min("Auf.P.DehngrenzeB2", 100000000000.0)
  else "Auf.P.DehngrenzeB2" # Max("Auf.P.DehngrenzeB2", -100000000000.0);
  if "Auf.P.Körnung1">0.0 then "Auf.P.Körnung1" # Min("Auf.P.Körnung1", 100000000000.0)
  else "Auf.P.Körnung1" # Max("Auf.P.Körnung1", -100000000000.0);
  if "Auf.P.Körnung2">0.0 then "Auf.P.Körnung2" # Min("Auf.P.Körnung2", 100000000000.0)
  else "Auf.P.Körnung2" # Max("Auf.P.Körnung2", -100000000000.0);
  if "Auf.P.Chemie.C1">0.0 then "Auf.P.Chemie.C1" # Min("Auf.P.Chemie.C1", 100000000000.0)
  else "Auf.P.Chemie.C1" # Max("Auf.P.Chemie.C1", -100000000000.0);
  if "Auf.P.Chemie.C2">0.0 then "Auf.P.Chemie.C2" # Min("Auf.P.Chemie.C2", 100000000000.0)
  else "Auf.P.Chemie.C2" # Max("Auf.P.Chemie.C2", -100000000000.0);
  if "Auf.P.Chemie.Si1">0.0 then "Auf.P.Chemie.Si1" # Min("Auf.P.Chemie.Si1", 100000000000.0)
  else "Auf.P.Chemie.Si1" # Max("Auf.P.Chemie.Si1", -100000000000.0);
  if "Auf.P.Chemie.Si2">0.0 then "Auf.P.Chemie.Si2" # Min("Auf.P.Chemie.Si2", 100000000000.0)
  else "Auf.P.Chemie.Si2" # Max("Auf.P.Chemie.Si2", -100000000000.0);
  if "Auf.P.Chemie.Mn1">0.0 then "Auf.P.Chemie.Mn1" # Min("Auf.P.Chemie.Mn1", 100000000000.0)
  else "Auf.P.Chemie.Mn1" # Max("Auf.P.Chemie.Mn1", -100000000000.0);
  if "Auf.P.Chemie.Mn2">0.0 then "Auf.P.Chemie.Mn2" # Min("Auf.P.Chemie.Mn2", 100000000000.0)
  else "Auf.P.Chemie.Mn2" # Max("Auf.P.Chemie.Mn2", -100000000000.0);
  if "Auf.P.Chemie.P1">0.0 then "Auf.P.Chemie.P1" # Min("Auf.P.Chemie.P1", 100000000000.0)
  else "Auf.P.Chemie.P1" # Max("Auf.P.Chemie.P1", -100000000000.0);
  if "Auf.P.Chemie.P2">0.0 then "Auf.P.Chemie.P2" # Min("Auf.P.Chemie.P2", 100000000000.0)
  else "Auf.P.Chemie.P2" # Max("Auf.P.Chemie.P2", -100000000000.0);
  if "Auf.P.Chemie.S1">0.0 then "Auf.P.Chemie.S1" # Min("Auf.P.Chemie.S1", 100000000000.0)
  else "Auf.P.Chemie.S1" # Max("Auf.P.Chemie.S1", -100000000000.0);
  if "Auf.P.Chemie.S2">0.0 then "Auf.P.Chemie.S2" # Min("Auf.P.Chemie.S2", 100000000000.0)
  else "Auf.P.Chemie.S2" # Max("Auf.P.Chemie.S2", -100000000000.0);
  if "Auf.P.Chemie.Al1">0.0 then "Auf.P.Chemie.Al1" # Min("Auf.P.Chemie.Al1", 100000000000.0)
  else "Auf.P.Chemie.Al1" # Max("Auf.P.Chemie.Al1", -100000000000.0);
  if "Auf.P.Chemie.Al2">0.0 then "Auf.P.Chemie.Al2" # Min("Auf.P.Chemie.Al2", 100000000000.0)
  else "Auf.P.Chemie.Al2" # Max("Auf.P.Chemie.Al2", -100000000000.0);
  if "Auf.P.Chemie.Cr1">0.0 then "Auf.P.Chemie.Cr1" # Min("Auf.P.Chemie.Cr1", 100000000000.0)
  else "Auf.P.Chemie.Cr1" # Max("Auf.P.Chemie.Cr1", -100000000000.0);
  if "Auf.P.Chemie.Cr2">0.0 then "Auf.P.Chemie.Cr2" # Min("Auf.P.Chemie.Cr2", 100000000000.0)
  else "Auf.P.Chemie.Cr2" # Max("Auf.P.Chemie.Cr2", -100000000000.0);
  if "Auf.P.Chemie.V1">0.0 then "Auf.P.Chemie.V1" # Min("Auf.P.Chemie.V1", 100000000000.0)
  else "Auf.P.Chemie.V1" # Max("Auf.P.Chemie.V1", -100000000000.0);
  if "Auf.P.Chemie.V2">0.0 then "Auf.P.Chemie.V2" # Min("Auf.P.Chemie.V2", 100000000000.0)
  else "Auf.P.Chemie.V2" # Max("Auf.P.Chemie.V2", -100000000000.0);
  if "Auf.P.Chemie.Nb1">0.0 then "Auf.P.Chemie.Nb1" # Min("Auf.P.Chemie.Nb1", 100000000000.0)
  else "Auf.P.Chemie.Nb1" # Max("Auf.P.Chemie.Nb1", -100000000000.0);
  if "Auf.P.Chemie.Nb2">0.0 then "Auf.P.Chemie.Nb2" # Min("Auf.P.Chemie.Nb2", 100000000000.0)
  else "Auf.P.Chemie.Nb2" # Max("Auf.P.Chemie.Nb2", -100000000000.0);
  if "Auf.P.Chemie.Ti1">0.0 then "Auf.P.Chemie.Ti1" # Min("Auf.P.Chemie.Ti1", 100000000000.0)
  else "Auf.P.Chemie.Ti1" # Max("Auf.P.Chemie.Ti1", -100000000000.0);
  if "Auf.P.Chemie.Ti2">0.0 then "Auf.P.Chemie.Ti2" # Min("Auf.P.Chemie.Ti2", 100000000000.0)
  else "Auf.P.Chemie.Ti2" # Max("Auf.P.Chemie.Ti2", -100000000000.0);
  if "Auf.P.Chemie.N1">0.0 then "Auf.P.Chemie.N1" # Min("Auf.P.Chemie.N1", 100000000000.0)
  else "Auf.P.Chemie.N1" # Max("Auf.P.Chemie.N1", -100000000000.0);
  if "Auf.P.Chemie.N2">0.0 then "Auf.P.Chemie.N2" # Min("Auf.P.Chemie.N2", 100000000000.0)
  else "Auf.P.Chemie.N2" # Max("Auf.P.Chemie.N2", -100000000000.0);
  if "Auf.P.Chemie.Cu1">0.0 then "Auf.P.Chemie.Cu1" # Min("Auf.P.Chemie.Cu1", 100000000000.0)
  else "Auf.P.Chemie.Cu1" # Max("Auf.P.Chemie.Cu1", -100000000000.0);
  if "Auf.P.Chemie.Cu2">0.0 then "Auf.P.Chemie.Cu2" # Min("Auf.P.Chemie.Cu2", 100000000000.0)
  else "Auf.P.Chemie.Cu2" # Max("Auf.P.Chemie.Cu2", -100000000000.0);
  if "Auf.P.Chemie.Ni1">0.0 then "Auf.P.Chemie.Ni1" # Min("Auf.P.Chemie.Ni1", 100000000000.0)
  else "Auf.P.Chemie.Ni1" # Max("Auf.P.Chemie.Ni1", -100000000000.0);
  if "Auf.P.Chemie.Ni2">0.0 then "Auf.P.Chemie.Ni2" # Min("Auf.P.Chemie.Ni2", 100000000000.0)
  else "Auf.P.Chemie.Ni2" # Max("Auf.P.Chemie.Ni2", -100000000000.0);
  if "Auf.P.Chemie.Mo1">0.0 then "Auf.P.Chemie.Mo1" # Min("Auf.P.Chemie.Mo1", 100000000000.0)
  else "Auf.P.Chemie.Mo1" # Max("Auf.P.Chemie.Mo1", -100000000000.0);
  if "Auf.P.Chemie.Mo2">0.0 then "Auf.P.Chemie.Mo2" # Min("Auf.P.Chemie.Mo2", 100000000000.0)
  else "Auf.P.Chemie.Mo2" # Max("Auf.P.Chemie.Mo2", -100000000000.0);
  if "Auf.P.Chemie.B1">0.0 then "Auf.P.Chemie.B1" # Min("Auf.P.Chemie.B1", 100000000000.0)
  else "Auf.P.Chemie.B1" # Max("Auf.P.Chemie.B1", -100000000000.0);
  if "Auf.P.Chemie.B2">0.0 then "Auf.P.Chemie.B2" # Min("Auf.P.Chemie.B2", 100000000000.0)
  else "Auf.P.Chemie.B2" # Max("Auf.P.Chemie.B2", -100000000000.0);
  if "Auf.P.Härte1">0.0 then "Auf.P.Härte1" # Min("Auf.P.Härte1", 100000000000.0)
  else "Auf.P.Härte1" # Max("Auf.P.Härte1", -100000000000.0);
  if "Auf.P.Härte2">0.0 then "Auf.P.Härte2" # Min("Auf.P.Härte2", 100000000000.0)
  else "Auf.P.Härte2" # Max("Auf.P.Härte2", -100000000000.0);
  if "Auf.P.Chemie.Frei1.1">0.0 then "Auf.P.Chemie.Frei1.1" # Min("Auf.P.Chemie.Frei1.1", 100000000000.0)
  else "Auf.P.Chemie.Frei1.1" # Max("Auf.P.Chemie.Frei1.1", -100000000000.0);
  if "Auf.P.Chemie.Frei1.2">0.0 then "Auf.P.Chemie.Frei1.2" # Min("Auf.P.Chemie.Frei1.2", 100000000000.0)
  else "Auf.P.Chemie.Frei1.2" # Max("Auf.P.Chemie.Frei1.2", -100000000000.0);
  if "Auf.P.RauigkeitA1">0.0 then "Auf.P.RauigkeitA1" # Min("Auf.P.RauigkeitA1", 100000000000.0)
  else "Auf.P.RauigkeitA1" # Max("Auf.P.RauigkeitA1", -100000000000.0);
  if "Auf.P.RauigkeitA2">0.0 then "Auf.P.RauigkeitA2" # Min("Auf.P.RauigkeitA2", 100000000000.0)
  else "Auf.P.RauigkeitA2" # Max("Auf.P.RauigkeitA2", -100000000000.0);
  if "Auf.P.RauigkeitB1">0.0 then "Auf.P.RauigkeitB1" # Min("Auf.P.RauigkeitB1", 100000000000.0)
  else "Auf.P.RauigkeitB1" # Max("Auf.P.RauigkeitB1", -100000000000.0);
  if "Auf.P.RauigkeitB2">0.0 then "Auf.P.RauigkeitB2" # Min("Auf.P.RauigkeitB2", 100000000000.0)
  else "Auf.P.RauigkeitB2" # Max("Auf.P.RauigkeitB2", -100000000000.0);
  GV.Alpha.06 # Bool("Auf.P.StehendYN");
  GV.Alpha.07 # Bool("Auf.P.LiegendYN");
  if "Auf.P.Nettoabzug">0.0 then "Auf.P.Nettoabzug" # Min("Auf.P.Nettoabzug", 100000000000.0)
  else "Auf.P.Nettoabzug" # Max("Auf.P.Nettoabzug", -100000000000.0);
  if "Auf.P.Stapelhöhe">0.0 then "Auf.P.Stapelhöhe" # Min("Auf.P.Stapelhöhe", 100000000000.0)
  else "Auf.P.Stapelhöhe" # Max("Auf.P.Stapelhöhe", -100000000000.0);
  if "Auf.P.StapelhAbzug">0.0 then "Auf.P.StapelhAbzug" # Min("Auf.P.StapelhAbzug", 100000000000.0)
  else "Auf.P.StapelhAbzug" # Max("Auf.P.StapelhAbzug", -100000000000.0);
  if "Auf.P.RingKgVon">0.0 then "Auf.P.RingKgVon" # Min("Auf.P.RingKgVon", 100000000000.0)
  else "Auf.P.RingKgVon" # Max("Auf.P.RingKgVon", -100000000000.0);
  if "Auf.P.RingKgBis">0.0 then "Auf.P.RingKgBis" # Min("Auf.P.RingKgBis", 100000000000.0)
  else "Auf.P.RingKgBis" # Max("Auf.P.RingKgBis", -100000000000.0);
  if "Auf.P.KgmmVon">0.0 then "Auf.P.KgmmVon" # Min("Auf.P.KgmmVon", 100000000000.0)
  else "Auf.P.KgmmVon" # Max("Auf.P.KgmmVon", -100000000000.0);
  if "Auf.P.KgmmBis">0.0 then "Auf.P.KgmmBis" # Min("Auf.P.KgmmBis", 100000000000.0)
  else "Auf.P.KgmmBis" # Max("Auf.P.KgmmBis", -100000000000.0);
  if "Auf.P.VEkgMax">0.0 then "Auf.P.VEkgMax" # Min("Auf.P.VEkgMax", 100000000000.0)
  else "Auf.P.VEkgMax" # Max("Auf.P.VEkgMax", -100000000000.0);
  if "Auf.P.RechtwinkMax">0.0 then "Auf.P.RechtwinkMax" # Min("Auf.P.RechtwinkMax", 100000000000.0)
  else "Auf.P.RechtwinkMax" # Max("Auf.P.RechtwinkMax", -100000000000.0);
  if "Auf.P.EbenheitMax">0.0 then "Auf.P.EbenheitMax" # Min("Auf.P.EbenheitMax", 100000000000.0)
  else "Auf.P.EbenheitMax" # Max("Auf.P.EbenheitMax", -100000000000.0);
  if "Auf.P.SäbeligkeitMax">0.0 then "Auf.P.SäbeligkeitMax" # Min("Auf.P.SäbeligkeitMax", 100000000000.0)
  else "Auf.P.SäbeligkeitMax" # Max("Auf.P.SäbeligkeitMax", -100000000000.0);
  if "Auf.P.Etk.Dicke">0.0 then "Auf.P.Etk.Dicke" # Min("Auf.P.Etk.Dicke", 100000000000.0)
  else "Auf.P.Etk.Dicke" # Max("Auf.P.Etk.Dicke", -100000000000.0);
  if "Auf.P.Etk.Breite">0.0 then "Auf.P.Etk.Breite" # Min("Auf.P.Etk.Breite", 100000000000.0)
  else "Auf.P.Etk.Breite" # Max("Auf.P.Etk.Breite", -100000000000.0);
  if "Auf.P.Etk.Länge">0.0 then "Auf.P.Etk.Länge" # Min("Auf.P.Etk.Länge", 100000000000.0)
  else "Auf.P.Etk.Länge" # Max("Auf.P.Etk.Länge", -100000000000.0);
  GV.Alpha.08 # Bool("Auf.P.Bild.DruckenYN");
  if "Auf.P.SäbelProM">0.0 then "Auf.P.SäbelProM" # Min("Auf.P.SäbelProM", 100000000000.0)
  else "Auf.P.SäbelProM" # Max("Auf.P.SäbelProM", -100000000000.0);
  GV.Alpha.09 # Bool("Auf.P.MitLfEYN");
  if "Auf.P.FE.Dicke">0.0 then "Auf.P.FE.Dicke" # Min("Auf.P.FE.Dicke", 100000000000.0)
  else "Auf.P.FE.Dicke" # Max("Auf.P.FE.Dicke", -100000000000.0);
  if "Auf.P.FE.Breite">0.0 then "Auf.P.FE.Breite" # Min("Auf.P.FE.Breite", 100000000000.0)
  else "Auf.P.FE.Breite" # Max("Auf.P.FE.Breite", -100000000000.0);
  if "Auf.P.FE.Länge">0.0 then "Auf.P.FE.Länge" # Min("Auf.P.FE.Länge", 100000000000.0)
  else "Auf.P.FE.Länge" # Max("Auf.P.FE.Länge", -100000000000.0);
  if "Auf.P.FE.RID">0.0 then "Auf.P.FE.RID" # Min("Auf.P.FE.RID", 100000000000.0)
  else "Auf.P.FE.RID" # Max("Auf.P.FE.RID", -100000000000.0);
  if "Auf.P.FE.RIDMax">0.0 then "Auf.P.FE.RIDMax" # Min("Auf.P.FE.RIDMax", 100000000000.0)
  else "Auf.P.FE.RIDMax" # Max("Auf.P.FE.RIDMax", -100000000000.0);
  if "Auf.P.FE.RAD">0.0 then "Auf.P.FE.RAD" # Min("Auf.P.FE.RAD", 100000000000.0)
  else "Auf.P.FE.RAD" # Max("Auf.P.FE.RAD", -100000000000.0);
  if "Auf.P.FE.RADMax">0.0 then "Auf.P.FE.RADMax" # Min("Auf.P.FE.RADMax", 100000000000.0)
  else "Auf.P.FE.RADMax" # Max("Auf.P.FE.RADMax", -100000000000.0);
  if "Auf.P.FE.Gewicht">0.0 then "Auf.P.FE.Gewicht" # Min("Auf.P.FE.Gewicht", 100000000000.0)
  else "Auf.P.FE.Gewicht" # Max("Auf.P.FE.Gewicht", -100000000000.0);
  GV.Alpha.10 # Bool("Auf.P.StorniertYN");
end;

// -------------------------------------------------
sub EX402()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0402'
     +cnvai(RecInfo(402,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(402, _recModified);
end;

// -------------------------------------------------
sub EX403()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0403'
     +cnvai(RecInfo(403,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(403, _recModified);
  if "Auf.Z.Menge">0.0 then "Auf.Z.Menge" # Min("Auf.Z.Menge", 100000000000.0)
  else "Auf.Z.Menge" # Max("Auf.Z.Menge", -100000000000.0);
  GV.Alpha.02 # Bool("Auf.Z.MengenbezugYN");
  GV.Alpha.03 # Bool("Auf.Z.RabattierbarYN");
  GV.Alpha.04 # Bool("Auf.Z.NeuberechnenYN");
  if "Auf.Z.Preis">0.0 then "Auf.Z.Preis" # Min("Auf.Z.Preis", 100000000000.0)
  else "Auf.Z.Preis" # Max("Auf.Z.Preis", -100000000000.0);
  GV.Alpha.05 # Bool("Auf.Z.Vpg.OKYN");
  GV.Alpha.06 # Bool("Auf.Z.SichtbarYN");
  GV.Alpha.07 # Bool("Auf.Z.PerFormelYN");
  GV.Alpha.08 # Bool("Auf.Z.ProRechnungYN");
end;

// -------------------------------------------------
sub EX404()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0404'
     +cnvai(RecInfo(404,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(404, _recModified);
  GV.Alpha.02 # Datum("Auf.A.Aktionsdatum");
  GV.Alpha.03 # Datum("Auf.A.TerminStart");
  GV.Alpha.04 # Datum("Auf.A.TerminEnde");
  if "Auf.A.Menge">0.0 then "Auf.A.Menge" # Min("Auf.A.Menge", 100000000000.0)
  else "Auf.A.Menge" # Max("Auf.A.Menge", -100000000000.0);
  if "Auf.A.Gewicht">0.0 then "Auf.A.Gewicht" # Min("Auf.A.Gewicht", 100000000000.0)
  else "Auf.A.Gewicht" # Max("Auf.A.Gewicht", -100000000000.0);
  if "Auf.A.Nettogewicht">0.0 then "Auf.A.Nettogewicht" # Min("Auf.A.Nettogewicht", 100000000000.0)
  else "Auf.A.Nettogewicht" # Max("Auf.A.Nettogewicht", -100000000000.0);
  if "Auf.A.Menge.Preis">0.0 then "Auf.A.Menge.Preis" # Min("Auf.A.Menge.Preis", 100000000000.0)
  else "Auf.A.Menge.Preis" # Max("Auf.A.Menge.Preis", -100000000000.0);
  GV.Alpha.05 # Datum("Auf.A.Rechnungsdatum");
  if "Auf.A.Rechnungspreis">0.0 then "Auf.A.Rechnungspreis" # Min("Auf.A.Rechnungspreis", 100000000000.0)
  else "Auf.A.Rechnungspreis" # Max("Auf.A.Rechnungspreis", -100000000000.0);
  if "Auf.A.RechPreisW1">0.0 then "Auf.A.RechPreisW1" # Min("Auf.A.RechPreisW1", 100000000000.0)
  else "Auf.A.RechPreisW1" # Max("Auf.A.RechPreisW1", -100000000000.0);
  if "Auf.A.EKPreisSummeW1">0.0 then "Auf.A.EKPreisSummeW1" # Min("Auf.A.EKPreisSummeW1", 100000000000.0)
  else "Auf.A.EKPreisSummeW1" # Max("Auf.A.EKPreisSummeW1", -100000000000.0);
  GV.Alpha.06 # Bool("Auf.A.TheorieYN");
  if "Auf.A.RückEinzelEKW1">0.0 then "Auf.A.RückEinzelEKW1" # Min("Auf.A.RückEinzelEKW1", 100000000000.0)
  else "Auf.A.RückEinzelEKW1" # Max("Auf.A.RückEinzelEKW1", -100000000000.0);
  if "Auf.A.interneKostW1">0.0 then "Auf.A.interneKostW1" # Min("Auf.A.interneKostW1", 100000000000.0)
  else "Auf.A.interneKostW1" # Max("Auf.A.interneKostW1", -100000000000.0);
  if "Auf.A.RechGrundPrsW1">0.0 then "Auf.A.RechGrundPrsW1" # Min("Auf.A.RechGrundPrsW1", 100000000000.0)
  else "Auf.A.RechGrundPrsW1" # Max("Auf.A.RechGrundPrsW1", -100000000000.0);
  if "Auf.A.RechKorrektur">0.0 then "Auf.A.RechKorrektur" # Min("Auf.A.RechKorrektur", 100000000000.0)
  else "Auf.A.RechKorrektur" # Max("Auf.A.RechKorrektur", -100000000000.0);
  if "Auf.A.RechKorrektW1">0.0 then "Auf.A.RechKorrektW1" # Min("Auf.A.RechKorrektW1", 100000000000.0)
  else "Auf.A.RechKorrektW1" # Max("Auf.A.RechKorrektW1", -100000000000.0);
  if "Auf.A.Dicke">0.0 then "Auf.A.Dicke" # Min("Auf.A.Dicke", 100000000000.0)
  else "Auf.A.Dicke" # Max("Auf.A.Dicke", -100000000000.0);
  if "Auf.A.Breite">0.0 then "Auf.A.Breite" # Min("Auf.A.Breite", 100000000000.0)
  else "Auf.A.Breite" # Max("Auf.A.Breite", -100000000000.0);
  if "Auf.A.Länge">0.0 then "Auf.A.Länge" # Min("Auf.A.Länge", 100000000000.0)
  else "Auf.A.Länge" # Max("Auf.A.Länge", -100000000000.0);
end;

// -------------------------------------------------
sub EX405()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0405'
     +cnvai(RecInfo(405,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(405, _recModified);
  GV.Alpha.02 # Datum("Auf.K.Termin");
  if "Auf.K.Menge">0.0 then "Auf.K.Menge" # Min("Auf.K.Menge", 100000000000.0)
  else "Auf.K.Menge" # Max("Auf.K.Menge", -100000000000.0);
  GV.Alpha.03 # Bool("Auf.K.MengenbezugYN");
  if "Auf.K.Preis">0.0 then "Auf.K.Preis" # Min("Auf.K.Preis", 100000000000.0)
  else "Auf.K.Preis" # Max("Auf.K.Preis", -100000000000.0);
  GV.Alpha.04 # Bool("Auf.K.RückstellungYN");
  GV.Alpha.05 # Bool("Auf.K.EinsatzmengeYN");
end;

// -------------------------------------------------
sub EX410()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0410'
     +cnvai(RecInfo(410,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(410, _recModified);
  GV.Alpha.02 # Datum("Auf~Datum");
  GV.Alpha.03 # Bool("Auf~LiefervertragYN");
  GV.Alpha.04 # Bool("Auf~AbrufYN");
  GV.Alpha.05 # Datum("Auf~GültigkeitVom");
  GV.Alpha.06 # Datum("Auf~GültigkeitBis");
  if "Auf~Währungskurs">0.0 then "Auf~Währungskurs" # Min("Auf~Währungskurs", 100000000000.0)
  else "Auf~Währungskurs" # Max("Auf~Währungskurs", -100000000000.0);
  GV.Alpha.07 # Bool("Auf~WährungFixYN");
  GV.Alpha.08 # Datum("Auf~Best.Datum");
  if "Auf~Vertreter.Prov">0.0 then "Auf~Vertreter.Prov" # Min("Auf~Vertreter.Prov", 100000000000.0)
  else "Auf~Vertreter.Prov" # Max("Auf~Vertreter.Prov", -100000000000.0);
  if "Auf~Vertreter.ProT">0.0 then "Auf~Vertreter.ProT" # Min("Auf~Vertreter.ProT", 100000000000.0)
  else "Auf~Vertreter.ProT" # Max("Auf~Vertreter.ProT", -100000000000.0);
  if "Auf~Vertreter2.Prov">0.0 then "Auf~Vertreter2.Prov" # Min("Auf~Vertreter2.Prov", 100000000000.0)
  else "Auf~Vertreter2.Prov" # Max("Auf~Vertreter2.Prov", -100000000000.0);
  if "Auf~Vertreter2.ProT">0.0 then "Auf~Vertreter2.ProT" # Min("Auf~Vertreter2.ProT", 100000000000.0)
  else "Auf~Vertreter2.ProT" # Max("Auf~Vertreter2.ProT", -100000000000.0);
  GV.Alpha.09 # Bool("Auf~PAbrufYN");
  GV.Alpha.10 # Datum("Auf~Freigabe.Datum");
  GV.Alpha.11 # Zeit("Auf~Freigabe.Zeit");
  if "Auf~Freigabe.WertW1">0.0 then "Auf~Freigabe.WertW1" # Min("Auf~Freigabe.WertW1", 100000000000.0)
  else "Auf~Freigabe.WertW1" # Max("Auf~Freigabe.WertW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX411()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0411'
     +cnvai(RecInfo(411,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(411, _recModified);
  if "Auf~P.Dicke">0.0 then "Auf~P.Dicke" # Min("Auf~P.Dicke", 100000000000.0)
  else "Auf~P.Dicke" # Max("Auf~P.Dicke", -100000000000.0);
  if "Auf~P.Breite">0.0 then "Auf~P.Breite" # Min("Auf~P.Breite", 100000000000.0)
  else "Auf~P.Breite" # Max("Auf~P.Breite", -100000000000.0);
  if "Auf~P.Länge">0.0 then "Auf~P.Länge" # Min("Auf~P.Länge", 100000000000.0)
  else "Auf~P.Länge" # Max("Auf~P.Länge", -100000000000.0);
  if "Auf~P.RID">0.0 then "Auf~P.RID" # Min("Auf~P.RID", 100000000000.0)
  else "Auf~P.RID" # Max("Auf~P.RID", -100000000000.0);
  if "Auf~P.RIDMax">0.0 then "Auf~P.RIDMax" # Min("Auf~P.RIDMax", 100000000000.0)
  else "Auf~P.RIDMax" # Max("Auf~P.RIDMax", -100000000000.0);
  if "Auf~P.RAD">0.0 then "Auf~P.RAD" # Min("Auf~P.RAD", 100000000000.0)
  else "Auf~P.RAD" # Max("Auf~P.RAD", -100000000000.0);
  if "Auf~P.RADMax">0.0 then "Auf~P.RADMax" # Min("Auf~P.RADMax", 100000000000.0)
  else "Auf~P.RADMax" # Max("Auf~P.RADMax", -100000000000.0);
  if "Auf~P.Gewicht">0.0 then "Auf~P.Gewicht" # Min("Auf~P.Gewicht", 100000000000.0)
  else "Auf~P.Gewicht" # Max("Auf~P.Gewicht", -100000000000.0);
  if "Auf~P.Menge.Wunsch">0.0 then "Auf~P.Menge.Wunsch" # Min("Auf~P.Menge.Wunsch", 100000000000.0)
  else "Auf~P.Menge.Wunsch" # Max("Auf~P.Menge.Wunsch", -100000000000.0);
  if "Auf~P.Grundpreis">0.0 then "Auf~P.Grundpreis" # Min("Auf~P.Grundpreis", 100000000000.0)
  else "Auf~P.Grundpreis" # Max("Auf~P.Grundpreis", -100000000000.0);
  GV.Alpha.02 # Bool("Auf~P.AufpreisYN");
  if "Auf~P.Aufpreis">0.0 then "Auf~P.Aufpreis" # Min("Auf~P.Aufpreis", 100000000000.0)
  else "Auf~P.Aufpreis" # Max("Auf~P.Aufpreis", -100000000000.0);
  if "Auf~P.Einzelpreis">0.0 then "Auf~P.Einzelpreis" # Min("Auf~P.Einzelpreis", 100000000000.0)
  else "Auf~P.Einzelpreis" # Max("Auf~P.Einzelpreis", -100000000000.0);
  if "Auf~P.Gesamtpreis">0.0 then "Auf~P.Gesamtpreis" # Min("Auf~P.Gesamtpreis", 100000000000.0)
  else "Auf~P.Gesamtpreis" # Max("Auf~P.Gesamtpreis", -100000000000.0);
  if "Auf~P.Kalkuliert">0.0 then "Auf~P.Kalkuliert" # Min("Auf~P.Kalkuliert", 100000000000.0)
  else "Auf~P.Kalkuliert" # Max("Auf~P.Kalkuliert", -100000000000.0);
  GV.Alpha.03 # Datum("Auf~P.Termin1Wunsch");
  GV.Alpha.04 # Datum("Auf~P.Termin2Wunsch");
  GV.Alpha.05 # Datum("Auf~P.TerminZusage");
  if "Auf~P.Menge">0.0 then "Auf~P.Menge" # Min("Auf~P.Menge", 100000000000.0)
  else "Auf~P.Menge" # Max("Auf~P.Menge", -100000000000.0);
  if "Auf~P.Vertr1.Prov">0.0 then "Auf~P.Vertr1.Prov" # Min("Auf~P.Vertr1.Prov", 100000000000.0)
  else "Auf~P.Vertr1.Prov" # Max("Auf~P.Vertr1.Prov", -100000000000.0);
  if "Auf~P.Vertr2.Prov">0.0 then "Auf~P.Vertr2.Prov" # Min("Auf~P.Vertr2.Prov", 100000000000.0)
  else "Auf~P.Vertr2.Prov" # Max("Auf~P.Vertr2.Prov", -100000000000.0);
  if "Auf~P.GesamtwertEKW1">0.0 then "Auf~P.GesamtwertEKW1" # Min("Auf~P.GesamtwertEKW1", 100000000000.0)
  else "Auf~P.GesamtwertEKW1" # Max("Auf~P.GesamtwertEKW1", -100000000000.0);
  if "Auf~P.Prd.Plan">0.0 then "Auf~P.Prd.Plan" # Min("Auf~P.Prd.Plan", 100000000000.0)
  else "Auf~P.Prd.Plan" # Max("Auf~P.Prd.Plan", -100000000000.0);
  if "Auf~P.Prd.Plan.Gew">0.0 then "Auf~P.Prd.Plan.Gew" # Min("Auf~P.Prd.Plan.Gew", 100000000000.0)
  else "Auf~P.Prd.Plan.Gew" # Max("Auf~P.Prd.Plan.Gew", -100000000000.0);
  if "Auf~P.Prd.VSB">0.0 then "Auf~P.Prd.VSB" # Min("Auf~P.Prd.VSB", 100000000000.0)
  else "Auf~P.Prd.VSB" # Max("Auf~P.Prd.VSB", -100000000000.0);
  if "Auf~P.Prd.VSB.Gew">0.0 then "Auf~P.Prd.VSB.Gew" # Min("Auf~P.Prd.VSB.Gew", 100000000000.0)
  else "Auf~P.Prd.VSB.Gew" # Max("Auf~P.Prd.VSB.Gew", -100000000000.0);
  if "Auf~P.Prd.VSAuf">0.0 then "Auf~P.Prd.VSAuf" # Min("Auf~P.Prd.VSAuf", 100000000000.0)
  else "Auf~P.Prd.VSAuf" # Max("Auf~P.Prd.VSAuf", -100000000000.0);
  if "Auf~P.Prd.VSAuf.Gew">0.0 then "Auf~P.Prd.VSAuf.Gew" # Min("Auf~P.Prd.VSAuf.Gew", 100000000000.0)
  else "Auf~P.Prd.VSAuf.Gew" # Max("Auf~P.Prd.VSAuf.Gew", -100000000000.0);
  if "Auf~P.Prd.LFS">0.0 then "Auf~P.Prd.LFS" # Min("Auf~P.Prd.LFS", 100000000000.0)
  else "Auf~P.Prd.LFS" # Max("Auf~P.Prd.LFS", -100000000000.0);
  if "Auf~P.Prd.LFS.Gew">0.0 then "Auf~P.Prd.LFS.Gew" # Min("Auf~P.Prd.LFS.Gew", 100000000000.0)
  else "Auf~P.Prd.LFS.Gew" # Max("Auf~P.Prd.LFS.Gew", -100000000000.0);
  if "Auf~P.Prd.Rech">0.0 then "Auf~P.Prd.Rech" # Min("Auf~P.Prd.Rech", 100000000000.0)
  else "Auf~P.Prd.Rech" # Max("Auf~P.Prd.Rech", -100000000000.0);
  if "Auf~P.Prd.Rech.Gew">0.0 then "Auf~P.Prd.Rech.Gew" # Min("Auf~P.Prd.Rech.Gew", 100000000000.0)
  else "Auf~P.Prd.Rech.Gew" # Max("Auf~P.Prd.Rech.Gew", -100000000000.0);
  if "Auf~P.Prd.Rest">0.0 then "Auf~P.Prd.Rest" # Min("Auf~P.Prd.Rest", 100000000000.0)
  else "Auf~P.Prd.Rest" # Max("Auf~P.Prd.Rest", -100000000000.0);
  if "Auf~P.Prd.Rest.Gew">0.0 then "Auf~P.Prd.Rest.Gew" # Min("Auf~P.Prd.Rest.Gew", 100000000000.0)
  else "Auf~P.Prd.Rest.Gew" # Max("Auf~P.Prd.Rest.Gew", -100000000000.0);
  if "Auf~P.GPl.Plan">0.0 then "Auf~P.GPl.Plan" # Min("Auf~P.GPl.Plan", 100000000000.0)
  else "Auf~P.GPl.Plan" # Max("Auf~P.GPl.Plan", -100000000000.0);
  if "Auf~P.GPl.Plan.Gew">0.0 then "Auf~P.GPl.Plan.Gew" # Min("Auf~P.GPl.Plan.Gew", 100000000000.0)
  else "Auf~P.GPl.Plan.Gew" # Max("Auf~P.GPl.Plan.Gew", -100000000000.0);
  if "Auf~P.Prd.Reserv">0.0 then "Auf~P.Prd.Reserv" # Min("Auf~P.Prd.Reserv", 100000000000.0)
  else "Auf~P.Prd.Reserv" # Max("Auf~P.Prd.Reserv", -100000000000.0);
  if "Auf~P.Prd.Reserv.Gew">0.0 then "Auf~P.Prd.Reserv.Gew" # Min("Auf~P.Prd.Reserv.Gew", 100000000000.0)
  else "Auf~P.Prd.Reserv.Gew" # Max("Auf~P.Prd.Reserv.Gew", -100000000000.0);
  if "Auf~P.Prd.zuBere">0.0 then "Auf~P.Prd.zuBere" # Min("Auf~P.Prd.zuBere", 100000000000.0)
  else "Auf~P.Prd.zuBere" # Max("Auf~P.Prd.zuBere", -100000000000.0);
  if "Auf~P.Prd.zuBere.Gew">0.0 then "Auf~P.Prd.zuBere.Gew" # Min("Auf~P.Prd.zuBere.Gew", 100000000000.0)
  else "Auf~P.Prd.zuBere.Gew" # Max("Auf~P.Prd.zuBere.Gew", -100000000000.0);
  if "Auf~P.Prd.EkBest">0.0 then "Auf~P.Prd.EkBest" # Min("Auf~P.Prd.EkBest", 100000000000.0)
  else "Auf~P.Prd.EkBest" # Max("Auf~P.Prd.EkBest", -100000000000.0);
  if "Auf~P.Prd.EkBest.Gew">0.0 then "Auf~P.Prd.EkBest.Gew" # Min("Auf~P.Prd.EkBest.Gew", 100000000000.0)
  else "Auf~P.Prd.EkBest.Gew" # Max("Auf~P.Prd.EkBest.Gew", -100000000000.0);
  if "Auf~P.Streckgrenze1">0.0 then "Auf~P.Streckgrenze1" # Min("Auf~P.Streckgrenze1", 100000000000.0)
  else "Auf~P.Streckgrenze1" # Max("Auf~P.Streckgrenze1", -100000000000.0);
  if "Auf~P.Streckgrenze2">0.0 then "Auf~P.Streckgrenze2" # Min("Auf~P.Streckgrenze2", 100000000000.0)
  else "Auf~P.Streckgrenze2" # Max("Auf~P.Streckgrenze2", -100000000000.0);
  if "Auf~P.Zugfestigkeit1">0.0 then "Auf~P.Zugfestigkeit1" # Min("Auf~P.Zugfestigkeit1", 100000000000.0)
  else "Auf~P.Zugfestigkeit1" # Max("Auf~P.Zugfestigkeit1", -100000000000.0);
  if "Auf~P.Zugfestigkeit2">0.0 then "Auf~P.Zugfestigkeit2" # Min("Auf~P.Zugfestigkeit2", 100000000000.0)
  else "Auf~P.Zugfestigkeit2" # Max("Auf~P.Zugfestigkeit2", -100000000000.0);
  if "Auf~P.DehnungA1">0.0 then "Auf~P.DehnungA1" # Min("Auf~P.DehnungA1", 100000000000.0)
  else "Auf~P.DehnungA1" # Max("Auf~P.DehnungA1", -100000000000.0);
  if "Auf~P.DehnungA2">0.0 then "Auf~P.DehnungA2" # Min("Auf~P.DehnungA2", 100000000000.0)
  else "Auf~P.DehnungA2" # Max("Auf~P.DehnungA2", -100000000000.0);
  if "Auf~P.DehnungB1">0.0 then "Auf~P.DehnungB1" # Min("Auf~P.DehnungB1", 100000000000.0)
  else "Auf~P.DehnungB1" # Max("Auf~P.DehnungB1", -100000000000.0);
  if "Auf~P.DehnungB2">0.0 then "Auf~P.DehnungB2" # Min("Auf~P.DehnungB2", 100000000000.0)
  else "Auf~P.DehnungB2" # Max("Auf~P.DehnungB2", -100000000000.0);
  if "Auf~P.DehngrenzeA1">0.0 then "Auf~P.DehngrenzeA1" # Min("Auf~P.DehngrenzeA1", 100000000000.0)
  else "Auf~P.DehngrenzeA1" # Max("Auf~P.DehngrenzeA1", -100000000000.0);
  if "Auf~P.DehngrenzeA2">0.0 then "Auf~P.DehngrenzeA2" # Min("Auf~P.DehngrenzeA2", 100000000000.0)
  else "Auf~P.DehngrenzeA2" # Max("Auf~P.DehngrenzeA2", -100000000000.0);
  if "Auf~P.DehngrenzeB1">0.0 then "Auf~P.DehngrenzeB1" # Min("Auf~P.DehngrenzeB1", 100000000000.0)
  else "Auf~P.DehngrenzeB1" # Max("Auf~P.DehngrenzeB1", -100000000000.0);
  if "Auf~P.DehngrenzeB2">0.0 then "Auf~P.DehngrenzeB2" # Min("Auf~P.DehngrenzeB2", 100000000000.0)
  else "Auf~P.DehngrenzeB2" # Max("Auf~P.DehngrenzeB2", -100000000000.0);
  if "Auf~P.Körnung1">0.0 then "Auf~P.Körnung1" # Min("Auf~P.Körnung1", 100000000000.0)
  else "Auf~P.Körnung1" # Max("Auf~P.Körnung1", -100000000000.0);
  if "Auf~P.Körnung2">0.0 then "Auf~P.Körnung2" # Min("Auf~P.Körnung2", 100000000000.0)
  else "Auf~P.Körnung2" # Max("Auf~P.Körnung2", -100000000000.0);
  if "Auf~P.Chemie.C1">0.0 then "Auf~P.Chemie.C1" # Min("Auf~P.Chemie.C1", 100000000000.0)
  else "Auf~P.Chemie.C1" # Max("Auf~P.Chemie.C1", -100000000000.0);
  if "Auf~P.Chemie.C2">0.0 then "Auf~P.Chemie.C2" # Min("Auf~P.Chemie.C2", 100000000000.0)
  else "Auf~P.Chemie.C2" # Max("Auf~P.Chemie.C2", -100000000000.0);
  if "Auf~P.Chemie.Si1">0.0 then "Auf~P.Chemie.Si1" # Min("Auf~P.Chemie.Si1", 100000000000.0)
  else "Auf~P.Chemie.Si1" # Max("Auf~P.Chemie.Si1", -100000000000.0);
  if "Auf~P.Chemie.Si2">0.0 then "Auf~P.Chemie.Si2" # Min("Auf~P.Chemie.Si2", 100000000000.0)
  else "Auf~P.Chemie.Si2" # Max("Auf~P.Chemie.Si2", -100000000000.0);
  if "Auf~P.Chemie.Mn1">0.0 then "Auf~P.Chemie.Mn1" # Min("Auf~P.Chemie.Mn1", 100000000000.0)
  else "Auf~P.Chemie.Mn1" # Max("Auf~P.Chemie.Mn1", -100000000000.0);
  if "Auf~P.Chemie.Mn2">0.0 then "Auf~P.Chemie.Mn2" # Min("Auf~P.Chemie.Mn2", 100000000000.0)
  else "Auf~P.Chemie.Mn2" # Max("Auf~P.Chemie.Mn2", -100000000000.0);
  if "Auf~P.Chemie.P1">0.0 then "Auf~P.Chemie.P1" # Min("Auf~P.Chemie.P1", 100000000000.0)
  else "Auf~P.Chemie.P1" # Max("Auf~P.Chemie.P1", -100000000000.0);
  if "Auf~P.Chemie.P2">0.0 then "Auf~P.Chemie.P2" # Min("Auf~P.Chemie.P2", 100000000000.0)
  else "Auf~P.Chemie.P2" # Max("Auf~P.Chemie.P2", -100000000000.0);
  if "Auf~P.Chemie.S1">0.0 then "Auf~P.Chemie.S1" # Min("Auf~P.Chemie.S1", 100000000000.0)
  else "Auf~P.Chemie.S1" # Max("Auf~P.Chemie.S1", -100000000000.0);
  if "Auf~P.Chemie.S2">0.0 then "Auf~P.Chemie.S2" # Min("Auf~P.Chemie.S2", 100000000000.0)
  else "Auf~P.Chemie.S2" # Max("Auf~P.Chemie.S2", -100000000000.0);
  if "Auf~P.Chemie.Al1">0.0 then "Auf~P.Chemie.Al1" # Min("Auf~P.Chemie.Al1", 100000000000.0)
  else "Auf~P.Chemie.Al1" # Max("Auf~P.Chemie.Al1", -100000000000.0);
  if "Auf~P.Chemie.Al2">0.0 then "Auf~P.Chemie.Al2" # Min("Auf~P.Chemie.Al2", 100000000000.0)
  else "Auf~P.Chemie.Al2" # Max("Auf~P.Chemie.Al2", -100000000000.0);
  if "Auf~P.Chemie.Cr1">0.0 then "Auf~P.Chemie.Cr1" # Min("Auf~P.Chemie.Cr1", 100000000000.0)
  else "Auf~P.Chemie.Cr1" # Max("Auf~P.Chemie.Cr1", -100000000000.0);
  if "Auf~P.Chemie.Cr2">0.0 then "Auf~P.Chemie.Cr2" # Min("Auf~P.Chemie.Cr2", 100000000000.0)
  else "Auf~P.Chemie.Cr2" # Max("Auf~P.Chemie.Cr2", -100000000000.0);
  if "Auf~P.Chemie.V1">0.0 then "Auf~P.Chemie.V1" # Min("Auf~P.Chemie.V1", 100000000000.0)
  else "Auf~P.Chemie.V1" # Max("Auf~P.Chemie.V1", -100000000000.0);
  if "Auf~P.Chemie.V2">0.0 then "Auf~P.Chemie.V2" # Min("Auf~P.Chemie.V2", 100000000000.0)
  else "Auf~P.Chemie.V2" # Max("Auf~P.Chemie.V2", -100000000000.0);
  if "Auf~P.Chemie.Nb1">0.0 then "Auf~P.Chemie.Nb1" # Min("Auf~P.Chemie.Nb1", 100000000000.0)
  else "Auf~P.Chemie.Nb1" # Max("Auf~P.Chemie.Nb1", -100000000000.0);
  if "Auf~P.Chemie.Nb2">0.0 then "Auf~P.Chemie.Nb2" # Min("Auf~P.Chemie.Nb2", 100000000000.0)
  else "Auf~P.Chemie.Nb2" # Max("Auf~P.Chemie.Nb2", -100000000000.0);
  if "Auf~P.Chemie.Ti1">0.0 then "Auf~P.Chemie.Ti1" # Min("Auf~P.Chemie.Ti1", 100000000000.0)
  else "Auf~P.Chemie.Ti1" # Max("Auf~P.Chemie.Ti1", -100000000000.0);
  if "Auf~P.Chemie.Ti2">0.0 then "Auf~P.Chemie.Ti2" # Min("Auf~P.Chemie.Ti2", 100000000000.0)
  else "Auf~P.Chemie.Ti2" # Max("Auf~P.Chemie.Ti2", -100000000000.0);
  if "Auf~P.Chemie.N1">0.0 then "Auf~P.Chemie.N1" # Min("Auf~P.Chemie.N1", 100000000000.0)
  else "Auf~P.Chemie.N1" # Max("Auf~P.Chemie.N1", -100000000000.0);
  if "Auf~P.Chemie.N2">0.0 then "Auf~P.Chemie.N2" # Min("Auf~P.Chemie.N2", 100000000000.0)
  else "Auf~P.Chemie.N2" # Max("Auf~P.Chemie.N2", -100000000000.0);
  if "Auf~P.Chemie.Cu1">0.0 then "Auf~P.Chemie.Cu1" # Min("Auf~P.Chemie.Cu1", 100000000000.0)
  else "Auf~P.Chemie.Cu1" # Max("Auf~P.Chemie.Cu1", -100000000000.0);
  if "Auf~P.Chemie.Cu2">0.0 then "Auf~P.Chemie.Cu2" # Min("Auf~P.Chemie.Cu2", 100000000000.0)
  else "Auf~P.Chemie.Cu2" # Max("Auf~P.Chemie.Cu2", -100000000000.0);
  if "Auf~P.Chemie.Ni1">0.0 then "Auf~P.Chemie.Ni1" # Min("Auf~P.Chemie.Ni1", 100000000000.0)
  else "Auf~P.Chemie.Ni1" # Max("Auf~P.Chemie.Ni1", -100000000000.0);
  if "Auf~P.Chemie.Ni2">0.0 then "Auf~P.Chemie.Ni2" # Min("Auf~P.Chemie.Ni2", 100000000000.0)
  else "Auf~P.Chemie.Ni2" # Max("Auf~P.Chemie.Ni2", -100000000000.0);
  if "Auf~P.Chemie.Mo1">0.0 then "Auf~P.Chemie.Mo1" # Min("Auf~P.Chemie.Mo1", 100000000000.0)
  else "Auf~P.Chemie.Mo1" # Max("Auf~P.Chemie.Mo1", -100000000000.0);
  if "Auf~P.Chemie.Mo2">0.0 then "Auf~P.Chemie.Mo2" # Min("Auf~P.Chemie.Mo2", 100000000000.0)
  else "Auf~P.Chemie.Mo2" # Max("Auf~P.Chemie.Mo2", -100000000000.0);
  if "Auf~P.Chemie.B1">0.0 then "Auf~P.Chemie.B1" # Min("Auf~P.Chemie.B1", 100000000000.0)
  else "Auf~P.Chemie.B1" # Max("Auf~P.Chemie.B1", -100000000000.0);
  if "Auf~P.Chemie.B2">0.0 then "Auf~P.Chemie.B2" # Min("Auf~P.Chemie.B2", 100000000000.0)
  else "Auf~P.Chemie.B2" # Max("Auf~P.Chemie.B2", -100000000000.0);
  if "Auf~P.Härte1">0.0 then "Auf~P.Härte1" # Min("Auf~P.Härte1", 100000000000.0)
  else "Auf~P.Härte1" # Max("Auf~P.Härte1", -100000000000.0);
  if "Auf~P.Härte2">0.0 then "Auf~P.Härte2" # Min("Auf~P.Härte2", 100000000000.0)
  else "Auf~P.Härte2" # Max("Auf~P.Härte2", -100000000000.0);
  if "Auf~P.Chemie.Frei1.1">0.0 then "Auf~P.Chemie.Frei1.1" # Min("Auf~P.Chemie.Frei1.1", 100000000000.0)
  else "Auf~P.Chemie.Frei1.1" # Max("Auf~P.Chemie.Frei1.1", -100000000000.0);
  if "Auf~P.Chemie.Frei1.2">0.0 then "Auf~P.Chemie.Frei1.2" # Min("Auf~P.Chemie.Frei1.2", 100000000000.0)
  else "Auf~P.Chemie.Frei1.2" # Max("Auf~P.Chemie.Frei1.2", -100000000000.0);
  if "Auf~P.RauigkeitA1">0.0 then "Auf~P.RauigkeitA1" # Min("Auf~P.RauigkeitA1", 100000000000.0)
  else "Auf~P.RauigkeitA1" # Max("Auf~P.RauigkeitA1", -100000000000.0);
  if "Auf~P.RauigkeitA2">0.0 then "Auf~P.RauigkeitA2" # Min("Auf~P.RauigkeitA2", 100000000000.0)
  else "Auf~P.RauigkeitA2" # Max("Auf~P.RauigkeitA2", -100000000000.0);
  if "Auf~P.RauigkeitB1">0.0 then "Auf~P.RauigkeitB1" # Min("Auf~P.RauigkeitB1", 100000000000.0)
  else "Auf~P.RauigkeitB1" # Max("Auf~P.RauigkeitB1", -100000000000.0);
  if "Auf~P.RauigkeitB2">0.0 then "Auf~P.RauigkeitB2" # Min("Auf~P.RauigkeitB2", 100000000000.0)
  else "Auf~P.RauigkeitB2" # Max("Auf~P.RauigkeitB2", -100000000000.0);
  GV.Alpha.06 # Bool("Auf~P.StehendYN");
  GV.Alpha.07 # Bool("Auf~P.LiegendYN");
  if "Auf~P.Nettoabzug">0.0 then "Auf~P.Nettoabzug" # Min("Auf~P.Nettoabzug", 100000000000.0)
  else "Auf~P.Nettoabzug" # Max("Auf~P.Nettoabzug", -100000000000.0);
  if "Auf~P.Stapelhöhe">0.0 then "Auf~P.Stapelhöhe" # Min("Auf~P.Stapelhöhe", 100000000000.0)
  else "Auf~P.Stapelhöhe" # Max("Auf~P.Stapelhöhe", -100000000000.0);
  if "Auf~P.StapelhAbzug">0.0 then "Auf~P.StapelhAbzug" # Min("Auf~P.StapelhAbzug", 100000000000.0)
  else "Auf~P.StapelhAbzug" # Max("Auf~P.StapelhAbzug", -100000000000.0);
  if "Auf~P.RingKgVon">0.0 then "Auf~P.RingKgVon" # Min("Auf~P.RingKgVon", 100000000000.0)
  else "Auf~P.RingKgVon" # Max("Auf~P.RingKgVon", -100000000000.0);
  if "Auf~P.RingKgBis">0.0 then "Auf~P.RingKgBis" # Min("Auf~P.RingKgBis", 100000000000.0)
  else "Auf~P.RingKgBis" # Max("Auf~P.RingKgBis", -100000000000.0);
  if "Auf~P.KgmmVon">0.0 then "Auf~P.KgmmVon" # Min("Auf~P.KgmmVon", 100000000000.0)
  else "Auf~P.KgmmVon" # Max("Auf~P.KgmmVon", -100000000000.0);
  if "Auf~P.KgmmBis">0.0 then "Auf~P.KgmmBis" # Min("Auf~P.KgmmBis", 100000000000.0)
  else "Auf~P.KgmmBis" # Max("Auf~P.KgmmBis", -100000000000.0);
  if "Auf~P.VEkgMax">0.0 then "Auf~P.VEkgMax" # Min("Auf~P.VEkgMax", 100000000000.0)
  else "Auf~P.VEkgMax" # Max("Auf~P.VEkgMax", -100000000000.0);
  if "Auf~P.RechtwinkMax">0.0 then "Auf~P.RechtwinkMax" # Min("Auf~P.RechtwinkMax", 100000000000.0)
  else "Auf~P.RechtwinkMax" # Max("Auf~P.RechtwinkMax", -100000000000.0);
  if "Auf~P.EbenheitMax">0.0 then "Auf~P.EbenheitMax" # Min("Auf~P.EbenheitMax", 100000000000.0)
  else "Auf~P.EbenheitMax" # Max("Auf~P.EbenheitMax", -100000000000.0);
  if "Auf~P.SäbeligkeitMax">0.0 then "Auf~P.SäbeligkeitMax" # Min("Auf~P.SäbeligkeitMax", 100000000000.0)
  else "Auf~P.SäbeligkeitMax" # Max("Auf~P.SäbeligkeitMax", -100000000000.0);
  if "Auf~P.Etk.Dicke">0.0 then "Auf~P.Etk.Dicke" # Min("Auf~P.Etk.Dicke", 100000000000.0)
  else "Auf~P.Etk.Dicke" # Max("Auf~P.Etk.Dicke", -100000000000.0);
  if "Auf~P.Etk.Breite">0.0 then "Auf~P.Etk.Breite" # Min("Auf~P.Etk.Breite", 100000000000.0)
  else "Auf~P.Etk.Breite" # Max("Auf~P.Etk.Breite", -100000000000.0);
  if "Auf~P.Etk.Länge">0.0 then "Auf~P.Etk.Länge" # Min("Auf~P.Etk.Länge", 100000000000.0)
  else "Auf~P.Etk.Länge" # Max("Auf~P.Etk.Länge", -100000000000.0);
  GV.Alpha.08 # Bool("Auf~P.Bild.DruckenYN");
  if "Auf~P.SäbelProM">0.0 then "Auf~P.SäbelProM" # Min("Auf~P.SäbelProM", 100000000000.0)
  else "Auf~P.SäbelProM" # Max("Auf~P.SäbelProM", -100000000000.0);
  GV.Alpha.09 # Bool("Auf~P.MitLfEYN");
  if "Auf~P.FE.Dicke">0.0 then "Auf~P.FE.Dicke" # Min("Auf~P.FE.Dicke", 100000000000.0)
  else "Auf~P.FE.Dicke" # Max("Auf~P.FE.Dicke", -100000000000.0);
  if "Auf~P.FE.Breite">0.0 then "Auf~P.FE.Breite" # Min("Auf~P.FE.Breite", 100000000000.0)
  else "Auf~P.FE.Breite" # Max("Auf~P.FE.Breite", -100000000000.0);
  if "Auf~P.FE.Länge">0.0 then "Auf~P.FE.Länge" # Min("Auf~P.FE.Länge", 100000000000.0)
  else "Auf~P.FE.Länge" # Max("Auf~P.FE.Länge", -100000000000.0);
  if "Auf~P.FE.RID">0.0 then "Auf~P.FE.RID" # Min("Auf~P.FE.RID", 100000000000.0)
  else "Auf~P.FE.RID" # Max("Auf~P.FE.RID", -100000000000.0);
  if "Auf~P.FE.RIDMax">0.0 then "Auf~P.FE.RIDMax" # Min("Auf~P.FE.RIDMax", 100000000000.0)
  else "Auf~P.FE.RIDMax" # Max("Auf~P.FE.RIDMax", -100000000000.0);
  if "Auf~P.FE.RAD">0.0 then "Auf~P.FE.RAD" # Min("Auf~P.FE.RAD", 100000000000.0)
  else "Auf~P.FE.RAD" # Max("Auf~P.FE.RAD", -100000000000.0);
  if "Auf~P.FE.RADMax">0.0 then "Auf~P.FE.RADMax" # Min("Auf~P.FE.RADMax", 100000000000.0)
  else "Auf~P.FE.RADMax" # Max("Auf~P.FE.RADMax", -100000000000.0);
  if "Auf~P.FE.Gewicht">0.0 then "Auf~P.FE.Gewicht" # Min("Auf~P.FE.Gewicht", 100000000000.0)
  else "Auf~P.FE.Gewicht" # Max("Auf~P.FE.Gewicht", -100000000000.0);
  GV.Alpha.10 # Bool("Auf~P.StorniertYN");
end;

// -------------------------------------------------
sub EX440()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0440'
     +cnvai(RecInfo(440,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(440, _recModified);
  GV.Alpha.02 # Datum("Lfs.Datum.Verbucht");
  GV.Alpha.03 # Datum("Lfs.Lieferdatum");
  if "Lfs.Kosten.Pro">0.0 then "Lfs.Kosten.Pro" # Min("Lfs.Kosten.Pro", 100000000000.0)
  else "Lfs.Kosten.Pro" # Max("Lfs.Kosten.Pro", -100000000000.0);
  if "Lfs.Positionsgewicht">0.0 then "Lfs.Positionsgewicht" # Min("Lfs.Positionsgewicht", 100000000000.0)
  else "Lfs.Positionsgewicht" # Max("Lfs.Positionsgewicht", -100000000000.0);
  if "Lfs.Leergewicht">0.0 then "Lfs.Leergewicht" # Min("Lfs.Leergewicht", 100000000000.0)
  else "Lfs.Leergewicht" # Max("Lfs.Leergewicht", -100000000000.0);
  if "Lfs.Gesamtgewicht">0.0 then "Lfs.Gesamtgewicht" # Min("Lfs.Gesamtgewicht", 100000000000.0)
  else "Lfs.Gesamtgewicht" # Max("Lfs.Gesamtgewicht", -100000000000.0);
  GV.Alpha.04 # Datum("Lfs.Wiegung1.Datum");
  GV.Alpha.05 # Zeit("Lfs.Wiegung1.Zeit");
  GV.Alpha.06 # Datum("Lfs.Wiegung2.Datum");
  GV.Alpha.07 # Zeit("Lfs.Wiegung2.Zeit");
  GV.Alpha.08 # Bool("Lfs.RücknahmeYN");
  if "Lfs.PosNettogewicht">0.0 then "Lfs.PosNettogewicht" # Min("Lfs.PosNettogewicht", 100000000000.0)
  else "Lfs.PosNettogewicht" # Max("Lfs.PosNettogewicht", -100000000000.0);
end;

// -------------------------------------------------
sub EX441()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0441'
     +cnvai(RecInfo(441,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(441, _recModified);
  if "Lfs.P.Gewicht.Netto">0.0 then "Lfs.P.Gewicht.Netto" # Min("Lfs.P.Gewicht.Netto", 100000000000.0)
  else "Lfs.P.Gewicht.Netto" # Max("Lfs.P.Gewicht.Netto", -100000000000.0);
  if "Lfs.P.Gewicht.Brutto">0.0 then "Lfs.P.Gewicht.Brutto" # Min("Lfs.P.Gewicht.Brutto", 100000000000.0)
  else "Lfs.P.Gewicht.Brutto" # Max("Lfs.P.Gewicht.Brutto", -100000000000.0);
  if "Lfs.P.Menge">0.0 then "Lfs.P.Menge" # Min("Lfs.P.Menge", 100000000000.0)
  else "Lfs.P.Menge" # Max("Lfs.P.Menge", -100000000000.0);
  if "Lfs.P.Menge.Einsatz">0.0 then "Lfs.P.Menge.Einsatz" # Min("Lfs.P.Menge.Einsatz", 100000000000.0)
  else "Lfs.P.Menge.Einsatz" # Max("Lfs.P.Menge.Einsatz", -100000000000.0);
  GV.Alpha.02 # Datum("Lfs.P.Datum.Verbucht");
end;

// -------------------------------------------------
sub EX450()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0450'
     +cnvai(RecInfo(450,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(450, _recModified);
  GV.Alpha.02 # Datum("Erl.Rechnungsdatum");
  if "Erl.Währungskurs">0.0 then "Erl.Währungskurs" # Min("Erl.Währungskurs", 100000000000.0)
  else "Erl.Währungskurs" # Max("Erl.Währungskurs", -100000000000.0);
  if "Erl.Gewicht">0.0 then "Erl.Gewicht" # Min("Erl.Gewicht", 100000000000.0)
  else "Erl.Gewicht" # Max("Erl.Gewicht", -100000000000.0);
  GV.Alpha.03 # Datum("Erl.FibuDatum");
  GV.Alpha.04 # Datum("Erl.Zieldatum");
  if "Erl.Skontoprozent">0.0 then "Erl.Skontoprozent" # Min("Erl.Skontoprozent", 100000000000.0)
  else "Erl.Skontoprozent" # Max("Erl.Skontoprozent", -100000000000.0);
  GV.Alpha.05 # Datum("Erl.Skontodatum");
  if "Erl.Netto">0.0 then "Erl.Netto" # Min("Erl.Netto", 100000000000.0)
  else "Erl.Netto" # Max("Erl.Netto", -100000000000.0);
  if "Erl.NettoW1">0.0 then "Erl.NettoW1" # Min("Erl.NettoW1", 100000000000.0)
  else "Erl.NettoW1" # Max("Erl.NettoW1", -100000000000.0);
  if "Erl.Steuer">0.0 then "Erl.Steuer" # Min("Erl.Steuer", 100000000000.0)
  else "Erl.Steuer" # Max("Erl.Steuer", -100000000000.0);
  if "Erl.SteuerW1">0.0 then "Erl.SteuerW1" # Min("Erl.SteuerW1", 100000000000.0)
  else "Erl.SteuerW1" # Max("Erl.SteuerW1", -100000000000.0);
  if "Erl.Brutto">0.0 then "Erl.Brutto" # Min("Erl.Brutto", 100000000000.0)
  else "Erl.Brutto" # Max("Erl.Brutto", -100000000000.0);
  if "Erl.BruttoW1">0.0 then "Erl.BruttoW1" # Min("Erl.BruttoW1", 100000000000.0)
  else "Erl.BruttoW1" # Max("Erl.BruttoW1", -100000000000.0);
  if "Erl.Korrektur">0.0 then "Erl.Korrektur" # Min("Erl.Korrektur", 100000000000.0)
  else "Erl.Korrektur" # Max("Erl.Korrektur", -100000000000.0);
  if "Erl.KorrekturW1">0.0 then "Erl.KorrekturW1" # Min("Erl.KorrekturW1", 100000000000.0)
  else "Erl.KorrekturW1" # Max("Erl.KorrekturW1", -100000000000.0);
  if "Erl.CO2Einstand">0.0 then "Erl.CO2Einstand" # Min("Erl.CO2Einstand", 100000000000.0)
  else "Erl.CO2Einstand" # Max("Erl.CO2Einstand", -100000000000.0);
  if "Erl.CO2Zuwachs">0.0 then "Erl.CO2Zuwachs" # Min("Erl.CO2Zuwachs", 100000000000.0)
  else "Erl.CO2Zuwachs" # Max("Erl.CO2Zuwachs", -100000000000.0);
end;

// -------------------------------------------------
sub EX451()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0451'
     +cnvai(RecInfo(451,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(451, _recModified);
  GV.Alpha.02 # Datum("Erl.K.Rechnungsdatum");
  if "Erl.K.Währungskurs">0.0 then "Erl.K.Währungskurs" # Min("Erl.K.Währungskurs", 100000000000.0)
  else "Erl.K.Währungskurs" # Max("Erl.K.Währungskurs", -100000000000.0);
  if "Erl.K.Betrag">0.0 then "Erl.K.Betrag" # Min("Erl.K.Betrag", 100000000000.0)
  else "Erl.K.Betrag" # Max("Erl.K.Betrag", -100000000000.0);
  if "Erl.K.BetragW1">0.0 then "Erl.K.BetragW1" # Min("Erl.K.BetragW1", 100000000000.0)
  else "Erl.K.BetragW1" # Max("Erl.K.BetragW1", -100000000000.0);
  if "Erl.K.Gewicht">0.0 then "Erl.K.Gewicht" # Min("Erl.K.Gewicht", 100000000000.0)
  else "Erl.K.Gewicht" # Max("Erl.K.Gewicht", -100000000000.0);
  if "Erl.K.Menge">0.0 then "Erl.K.Menge" # Min("Erl.K.Menge", 100000000000.0)
  else "Erl.K.Menge" # Max("Erl.K.Menge", -100000000000.0);
  if "Erl.K.EKPreisSummeW1">0.0 then "Erl.K.EKPreisSummeW1" # Min("Erl.K.EKPreisSummeW1", 100000000000.0)
  else "Erl.K.EKPreisSummeW1" # Max("Erl.K.EKPreisSummeW1", -100000000000.0);
  if "Erl.K.InterneKostW1">0.0 then "Erl.K.InterneKostW1" # Min("Erl.K.InterneKostW1", 100000000000.0)
  else "Erl.K.InterneKostW1" # Max("Erl.K.InterneKostW1", -100000000000.0);
  if "Erl.K.Korrektur">0.0 then "Erl.K.Korrektur" # Min("Erl.K.Korrektur", 100000000000.0)
  else "Erl.K.Korrektur" # Max("Erl.K.Korrektur", -100000000000.0);
  if "Erl.K.KorrekturW1">0.0 then "Erl.K.KorrekturW1" # Min("Erl.K.KorrekturW1", 100000000000.0)
  else "Erl.K.KorrekturW1" # Max("Erl.K.KorrekturW1", -100000000000.0);
  if "Erl.K.CO2Einstand">0.0 then "Erl.K.CO2Einstand" # Min("Erl.K.CO2Einstand", 100000000000.0)
  else "Erl.K.CO2Einstand" # Max("Erl.K.CO2Einstand", -100000000000.0);
  if "Erl.K.CO2Zuwachs">0.0 then "Erl.K.CO2Zuwachs" # Min("Erl.K.CO2Zuwachs", 100000000000.0)
  else "Erl.K.CO2Zuwachs" # Max("Erl.K.CO2Zuwachs", -100000000000.0);
end;

// -------------------------------------------------
sub EX460()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0460'
     +cnvai(RecInfo(460,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(460, _recModified);
  GV.Alpha.02 # Datum("OfP.Rechnungsdatum");
  if "OfP.Währungskurs">0.0 then "OfP.Währungskurs" # Min("OfP.Währungskurs", 100000000000.0)
  else "OfP.Währungskurs" # Max("OfP.Währungskurs", -100000000000.0);
  GV.Alpha.03 # Datum("OfP.SkontoDatum");
  if "OfP.SkontoProzent">0.0 then "OfP.SkontoProzent" # Min("OfP.SkontoProzent", 100000000000.0)
  else "OfP.SkontoProzent" # Max("OfP.SkontoProzent", -100000000000.0);
  GV.Alpha.04 # Datum("OfP.Zieldatum");
  GV.Alpha.05 # Datum("OfP.Wiedervorlage");
  GV.Alpha.06 # Datum("OfP.Mahndatum1");
  GV.Alpha.07 # Datum("OfP.Mahndatum2");
  GV.Alpha.08 # Datum("OfP.Mahndatum3");
  GV.Alpha.09 # Datum("OfP.Valutadatum");
  if "OfP.Netto">0.0 then "OfP.Netto" # Min("OfP.Netto", 100000000000.0)
  else "OfP.Netto" # Max("OfP.Netto", -100000000000.0);
  if "OfP.NettoW1">0.0 then "OfP.NettoW1" # Min("OfP.NettoW1", 100000000000.0)
  else "OfP.NettoW1" # Max("OfP.NettoW1", -100000000000.0);
  if "OfP.Steuer">0.0 then "OfP.Steuer" # Min("OfP.Steuer", 100000000000.0)
  else "OfP.Steuer" # Max("OfP.Steuer", -100000000000.0);
  if "OfP.SteuerW1">0.0 then "OfP.SteuerW1" # Min("OfP.SteuerW1", 100000000000.0)
  else "OfP.SteuerW1" # Max("OfP.SteuerW1", -100000000000.0);
  if "OfP.Brutto">0.0 then "OfP.Brutto" # Min("OfP.Brutto", 100000000000.0)
  else "OfP.Brutto" # Max("OfP.Brutto", -100000000000.0);
  if "OfP.BruttoW1">0.0 then "OfP.BruttoW1" # Min("OfP.BruttoW1", 100000000000.0)
  else "OfP.BruttoW1" # Max("OfP.BruttoW1", -100000000000.0);
  if "OfP.Skonto">0.0 then "OfP.Skonto" # Min("OfP.Skonto", 100000000000.0)
  else "OfP.Skonto" # Max("OfP.Skonto", -100000000000.0);
  if "OfP.SkontoW1">0.0 then "OfP.SkontoW1" # Min("OfP.SkontoW1", 100000000000.0)
  else "OfP.SkontoW1" # Max("OfP.SkontoW1", -100000000000.0);
  if "OfP.Mahngebühr">0.0 then "OfP.Mahngebühr" # Min("OfP.Mahngebühr", 100000000000.0)
  else "OfP.Mahngebühr" # Max("OfP.Mahngebühr", -100000000000.0);
  if "OfP.MahngebührW1">0.0 then "OfP.MahngebührW1" # Min("OfP.MahngebührW1", 100000000000.0)
  else "OfP.MahngebührW1" # Max("OfP.MahngebührW1", -100000000000.0);
  if "OfP.Zinsen">0.0 then "OfP.Zinsen" # Min("OfP.Zinsen", 100000000000.0)
  else "OfP.Zinsen" # Max("OfP.Zinsen", -100000000000.0);
  if "OfP.ZinsenW1">0.0 then "OfP.ZinsenW1" # Min("OfP.ZinsenW1", 100000000000.0)
  else "OfP.ZinsenW1" # Max("OfP.ZinsenW1", -100000000000.0);
  if "OfP.Zahlungen">0.0 then "OfP.Zahlungen" # Min("OfP.Zahlungen", 100000000000.0)
  else "OfP.Zahlungen" # Max("OfP.Zahlungen", -100000000000.0);
  if "OfP.ZahlungenW1">0.0 then "OfP.ZahlungenW1" # Min("OfP.ZahlungenW1", 100000000000.0)
  else "OfP.ZahlungenW1" # Max("OfP.ZahlungenW1", -100000000000.0);
  if "OfP.Rest">0.0 then "OfP.Rest" # Min("OfP.Rest", 100000000000.0)
  else "OfP.Rest" # Max("OfP.Rest", -100000000000.0);
  if "OfP.RestW1">0.0 then "OfP.RestW1" # Min("OfP.RestW1", 100000000000.0)
  else "OfP.RestW1" # Max("OfP.RestW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX461()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0461'
     +cnvai(RecInfo(461,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(461, _recModified);
  if "OfP.Z.Betrag">0.0 then "OfP.Z.Betrag" # Min("OfP.Z.Betrag", 100000000000.0)
  else "OfP.Z.Betrag" # Max("OfP.Z.Betrag", -100000000000.0);
  if "OfP.Z.BetragW1">0.0 then "OfP.Z.BetragW1" # Min("OfP.Z.BetragW1", 100000000000.0)
  else "OfP.Z.BetragW1" # Max("OfP.Z.BetragW1", -100000000000.0);
  GV.Alpha.02 # Bool("OfP.Z.RestSkontoYN");
  if "OfP.Z.Skontobetrag">0.0 then "OfP.Z.Skontobetrag" # Min("OfP.Z.Skontobetrag", 100000000000.0)
  else "OfP.Z.Skontobetrag" # Max("OfP.Z.Skontobetrag", -100000000000.0);
  if "OfP.Z.SkontobetragW1">0.0 then "OfP.Z.SkontobetragW1" # Min("OfP.Z.SkontobetragW1", 100000000000.0)
  else "OfP.Z.SkontobetragW1" # Max("OfP.Z.SkontobetragW1", -100000000000.0);
  GV.Alpha.03 # Datum("OfP.Z.Fibudatum");
end;

// -------------------------------------------------
sub EX465()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0465'
     +cnvai(RecInfo(465,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(465, _recModified);
  if "ZEi.Währungskurs">0.0 then "ZEi.Währungskurs" # Min("ZEi.Währungskurs", 100000000000.0)
  else "ZEi.Währungskurs" # Max("ZEi.Währungskurs", -100000000000.0);
  if "ZEi.Betrag">0.0 then "ZEi.Betrag" # Min("ZEi.Betrag", 100000000000.0)
  else "ZEi.Betrag" # Max("ZEi.Betrag", -100000000000.0);
  if "ZEi.BetragW1">0.0 then "ZEi.BetragW1" # Min("ZEi.BetragW1", 100000000000.0)
  else "ZEi.BetragW1" # Max("ZEi.BetragW1", -100000000000.0);
  if "ZEi.Zugeordnet">0.0 then "ZEi.Zugeordnet" # Min("ZEi.Zugeordnet", 100000000000.0)
  else "ZEi.Zugeordnet" # Max("ZEi.Zugeordnet", -100000000000.0);
  if "ZEi.ZugeordnetW1">0.0 then "ZEi.ZugeordnetW1" # Min("ZEi.ZugeordnetW1", 100000000000.0)
  else "ZEi.ZugeordnetW1" # Max("ZEi.ZugeordnetW1", -100000000000.0);
  GV.Alpha.02 # Datum("ZEi.Zahldatum");
end;

// -------------------------------------------------
sub EX470()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0470'
     +cnvai(RecInfo(470,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(470, _recModified);
  GV.Alpha.02 # Datum("OfP~Rechnungsdatum");
  if "OfP~Währungskurs">0.0 then "OfP~Währungskurs" # Min("OfP~Währungskurs", 100000000000.0)
  else "OfP~Währungskurs" # Max("OfP~Währungskurs", -100000000000.0);
  GV.Alpha.03 # Datum("OfP~SkontoDatum");
  if "OfP~SkontoProzent">0.0 then "OfP~SkontoProzent" # Min("OfP~SkontoProzent", 100000000000.0)
  else "OfP~SkontoProzent" # Max("OfP~SkontoProzent", -100000000000.0);
  GV.Alpha.04 # Datum("OfP~Zieldatum");
  GV.Alpha.05 # Datum("OfP~Wiedervorlage");
  GV.Alpha.06 # Datum("OfP~Mahndatum1");
  GV.Alpha.07 # Datum("OfP~Mahndatum2");
  GV.Alpha.08 # Datum("OfP~Mahndatum3");
  GV.Alpha.09 # Datum("OfP~Valutadatum");
  if "OfP~Netto">0.0 then "OfP~Netto" # Min("OfP~Netto", 100000000000.0)
  else "OfP~Netto" # Max("OfP~Netto", -100000000000.0);
  if "OfP~NettoW1">0.0 then "OfP~NettoW1" # Min("OfP~NettoW1", 100000000000.0)
  else "OfP~NettoW1" # Max("OfP~NettoW1", -100000000000.0);
  if "OfP~Steuer">0.0 then "OfP~Steuer" # Min("OfP~Steuer", 100000000000.0)
  else "OfP~Steuer" # Max("OfP~Steuer", -100000000000.0);
  if "OfP~SteuerW1">0.0 then "OfP~SteuerW1" # Min("OfP~SteuerW1", 100000000000.0)
  else "OfP~SteuerW1" # Max("OfP~SteuerW1", -100000000000.0);
  if "OfP~Brutto">0.0 then "OfP~Brutto" # Min("OfP~Brutto", 100000000000.0)
  else "OfP~Brutto" # Max("OfP~Brutto", -100000000000.0);
  if "OfP~BruttoW1">0.0 then "OfP~BruttoW1" # Min("OfP~BruttoW1", 100000000000.0)
  else "OfP~BruttoW1" # Max("OfP~BruttoW1", -100000000000.0);
  if "OfP~Skonto">0.0 then "OfP~Skonto" # Min("OfP~Skonto", 100000000000.0)
  else "OfP~Skonto" # Max("OfP~Skonto", -100000000000.0);
  if "OfP~SkontoW1">0.0 then "OfP~SkontoW1" # Min("OfP~SkontoW1", 100000000000.0)
  else "OfP~SkontoW1" # Max("OfP~SkontoW1", -100000000000.0);
  if "OfP~Mahngebühr">0.0 then "OfP~Mahngebühr" # Min("OfP~Mahngebühr", 100000000000.0)
  else "OfP~Mahngebühr" # Max("OfP~Mahngebühr", -100000000000.0);
  if "OfP~MahngebührW1">0.0 then "OfP~MahngebührW1" # Min("OfP~MahngebührW1", 100000000000.0)
  else "OfP~MahngebührW1" # Max("OfP~MahngebührW1", -100000000000.0);
  if "OfP~Zinsen">0.0 then "OfP~Zinsen" # Min("OfP~Zinsen", 100000000000.0)
  else "OfP~Zinsen" # Max("OfP~Zinsen", -100000000000.0);
  if "OfP~ZinsenW1">0.0 then "OfP~ZinsenW1" # Min("OfP~ZinsenW1", 100000000000.0)
  else "OfP~ZinsenW1" # Max("OfP~ZinsenW1", -100000000000.0);
  if "OfP~Zahlungen">0.0 then "OfP~Zahlungen" # Min("OfP~Zahlungen", 100000000000.0)
  else "OfP~Zahlungen" # Max("OfP~Zahlungen", -100000000000.0);
  if "OfP~ZahlungenW1">0.0 then "OfP~ZahlungenW1" # Min("OfP~ZahlungenW1", 100000000000.0)
  else "OfP~ZahlungenW1" # Max("OfP~ZahlungenW1", -100000000000.0);
  if "OfP~Rest">0.0 then "OfP~Rest" # Min("OfP~Rest", 100000000000.0)
  else "OfP~Rest" # Max("OfP~Rest", -100000000000.0);
  if "OfP~RestW1">0.0 then "OfP~RestW1" # Min("OfP~RestW1", 100000000000.0)
  else "OfP~RestW1" # Max("OfP~RestW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX500()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0500'
     +cnvai(RecInfo(500,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(500, _recModified);
  GV.Alpha.02 # Datum("Ein.Datum");
  GV.Alpha.03 # Bool("Ein.LiefervertragYN");
  GV.Alpha.04 # Bool("Ein.AbrufYN");
  if "Ein.Währungskurs">0.0 then "Ein.Währungskurs" # Min("Ein.Währungskurs", 100000000000.0)
  else "Ein.Währungskurs" # Max("Ein.Währungskurs", -100000000000.0);
  GV.Alpha.05 # Bool("Ein.WährungFixYN");
  GV.Alpha.06 # Datum("Ein.AB.Datum");
  GV.Alpha.07 # Datum("Ein.GültigkeitVom");
  GV.Alpha.08 # Datum("Ein.GültigkeitBis");
  GV.Alpha.09 # Datum("Ein.Freigabe.Datum");
  GV.Alpha.10 # Zeit("Ein.Freigabe.Zeit");
  if "Ein.Freigabe.WertW1">0.0 then "Ein.Freigabe.WertW1" # Min("Ein.Freigabe.WertW1", 100000000000.0)
  else "Ein.Freigabe.WertW1" # Max("Ein.Freigabe.WertW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX501()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0501'
     +cnvai(RecInfo(501,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(501, _recModified);
  if "Ein.P.Dicke">0.0 then "Ein.P.Dicke" # Min("Ein.P.Dicke", 100000000000.0)
  else "Ein.P.Dicke" # Max("Ein.P.Dicke", -100000000000.0);
  if "Ein.P.Breite">0.0 then "Ein.P.Breite" # Min("Ein.P.Breite", 100000000000.0)
  else "Ein.P.Breite" # Max("Ein.P.Breite", -100000000000.0);
  if "Ein.P.Länge">0.0 then "Ein.P.Länge" # Min("Ein.P.Länge", 100000000000.0)
  else "Ein.P.Länge" # Max("Ein.P.Länge", -100000000000.0);
  if "Ein.P.RID">0.0 then "Ein.P.RID" # Min("Ein.P.RID", 100000000000.0)
  else "Ein.P.RID" # Max("Ein.P.RID", -100000000000.0);
  if "Ein.P.RIDMax">0.0 then "Ein.P.RIDMax" # Min("Ein.P.RIDMax", 100000000000.0)
  else "Ein.P.RIDMax" # Max("Ein.P.RIDMax", -100000000000.0);
  if "Ein.P.RAD">0.0 then "Ein.P.RAD" # Min("Ein.P.RAD", 100000000000.0)
  else "Ein.P.RAD" # Max("Ein.P.RAD", -100000000000.0);
  if "Ein.P.RADMax">0.0 then "Ein.P.RADMax" # Min("Ein.P.RADMax", 100000000000.0)
  else "Ein.P.RADMax" # Max("Ein.P.RADMax", -100000000000.0);
  if "Ein.P.Gewicht">0.0 then "Ein.P.Gewicht" # Min("Ein.P.Gewicht", 100000000000.0)
  else "Ein.P.Gewicht" # Max("Ein.P.Gewicht", -100000000000.0);
  if "Ein.P.Menge.Wunsch">0.0 then "Ein.P.Menge.Wunsch" # Min("Ein.P.Menge.Wunsch", 100000000000.0)
  else "Ein.P.Menge.Wunsch" # Max("Ein.P.Menge.Wunsch", -100000000000.0);
  if "Ein.P.Grundpreis">0.0 then "Ein.P.Grundpreis" # Min("Ein.P.Grundpreis", 100000000000.0)
  else "Ein.P.Grundpreis" # Max("Ein.P.Grundpreis", -100000000000.0);
  GV.Alpha.02 # Bool("Ein.P.AufpreisYN");
  if "Ein.P.Aufpreis">0.0 then "Ein.P.Aufpreis" # Min("Ein.P.Aufpreis", 100000000000.0)
  else "Ein.P.Aufpreis" # Max("Ein.P.Aufpreis", -100000000000.0);
  if "Ein.P.Einzelpreis">0.0 then "Ein.P.Einzelpreis" # Min("Ein.P.Einzelpreis", 100000000000.0)
  else "Ein.P.Einzelpreis" # Max("Ein.P.Einzelpreis", -100000000000.0);
  if "Ein.P.Gesamtpreis">0.0 then "Ein.P.Gesamtpreis" # Min("Ein.P.Gesamtpreis", 100000000000.0)
  else "Ein.P.Gesamtpreis" # Max("Ein.P.Gesamtpreis", -100000000000.0);
  if "Ein.P.Kalkuliert">0.0 then "Ein.P.Kalkuliert" # Min("Ein.P.Kalkuliert", 100000000000.0)
  else "Ein.P.Kalkuliert" # Max("Ein.P.Kalkuliert", -100000000000.0);
  GV.Alpha.03 # Datum("Ein.P.Termin1Wunsch");
  GV.Alpha.04 # Datum("Ein.P.Termin2Wunsch");
  GV.Alpha.05 # Datum("Ein.P.TerminZusage");
  if "Ein.P.Menge">0.0 then "Ein.P.Menge" # Min("Ein.P.Menge", 100000000000.0)
  else "Ein.P.Menge" # Max("Ein.P.Menge", -100000000000.0);
  if "Ein.P.FM.VSB">0.0 then "Ein.P.FM.VSB" # Min("Ein.P.FM.VSB", 100000000000.0)
  else "Ein.P.FM.VSB" # Max("Ein.P.FM.VSB", -100000000000.0);
  if "Ein.P.FM.Eingang">0.0 then "Ein.P.FM.Eingang" # Min("Ein.P.FM.Eingang", 100000000000.0)
  else "Ein.P.FM.Eingang" # Max("Ein.P.FM.Eingang", -100000000000.0);
  if "Ein.P.FM.Ausfall">0.0 then "Ein.P.FM.Ausfall" # Min("Ein.P.FM.Ausfall", 100000000000.0)
  else "Ein.P.FM.Ausfall" # Max("Ein.P.FM.Ausfall", -100000000000.0);
  if "Ein.P.FM.Rest">0.0 then "Ein.P.FM.Rest" # Min("Ein.P.FM.Rest", 100000000000.0)
  else "Ein.P.FM.Rest" # Max("Ein.P.FM.Rest", -100000000000.0);
  if "Ein.P.Erfuellgrad">0.0 then "Ein.P.Erfuellgrad" # Min("Ein.P.Erfuellgrad", 100000000000.0)
  else "Ein.P.Erfuellgrad" # Max("Ein.P.Erfuellgrad", -100000000000.0);
  if "Ein.P.Streckgrenze1">0.0 then "Ein.P.Streckgrenze1" # Min("Ein.P.Streckgrenze1", 100000000000.0)
  else "Ein.P.Streckgrenze1" # Max("Ein.P.Streckgrenze1", -100000000000.0);
  if "Ein.P.Streckgrenze2">0.0 then "Ein.P.Streckgrenze2" # Min("Ein.P.Streckgrenze2", 100000000000.0)
  else "Ein.P.Streckgrenze2" # Max("Ein.P.Streckgrenze2", -100000000000.0);
  if "Ein.P.Zugfestigkeit1">0.0 then "Ein.P.Zugfestigkeit1" # Min("Ein.P.Zugfestigkeit1", 100000000000.0)
  else "Ein.P.Zugfestigkeit1" # Max("Ein.P.Zugfestigkeit1", -100000000000.0);
  if "Ein.P.Zugfestigkeit2">0.0 then "Ein.P.Zugfestigkeit2" # Min("Ein.P.Zugfestigkeit2", 100000000000.0)
  else "Ein.P.Zugfestigkeit2" # Max("Ein.P.Zugfestigkeit2", -100000000000.0);
  if "Ein.P.DehnungA1">0.0 then "Ein.P.DehnungA1" # Min("Ein.P.DehnungA1", 100000000000.0)
  else "Ein.P.DehnungA1" # Max("Ein.P.DehnungA1", -100000000000.0);
  if "Ein.P.DehnungA2">0.0 then "Ein.P.DehnungA2" # Min("Ein.P.DehnungA2", 100000000000.0)
  else "Ein.P.DehnungA2" # Max("Ein.P.DehnungA2", -100000000000.0);
  if "Ein.P.DehnungB1">0.0 then "Ein.P.DehnungB1" # Min("Ein.P.DehnungB1", 100000000000.0)
  else "Ein.P.DehnungB1" # Max("Ein.P.DehnungB1", -100000000000.0);
  if "Ein.P.DehnungB2">0.0 then "Ein.P.DehnungB2" # Min("Ein.P.DehnungB2", 100000000000.0)
  else "Ein.P.DehnungB2" # Max("Ein.P.DehnungB2", -100000000000.0);
  if "Ein.P.DehngrenzeA1">0.0 then "Ein.P.DehngrenzeA1" # Min("Ein.P.DehngrenzeA1", 100000000000.0)
  else "Ein.P.DehngrenzeA1" # Max("Ein.P.DehngrenzeA1", -100000000000.0);
  if "Ein.P.DehngrenzeA2">0.0 then "Ein.P.DehngrenzeA2" # Min("Ein.P.DehngrenzeA2", 100000000000.0)
  else "Ein.P.DehngrenzeA2" # Max("Ein.P.DehngrenzeA2", -100000000000.0);
  if "Ein.P.DehngrenzeB1">0.0 then "Ein.P.DehngrenzeB1" # Min("Ein.P.DehngrenzeB1", 100000000000.0)
  else "Ein.P.DehngrenzeB1" # Max("Ein.P.DehngrenzeB1", -100000000000.0);
  if "Ein.P.DehngrenzeB2">0.0 then "Ein.P.DehngrenzeB2" # Min("Ein.P.DehngrenzeB2", 100000000000.0)
  else "Ein.P.DehngrenzeB2" # Max("Ein.P.DehngrenzeB2", -100000000000.0);
  if "Ein.P.Körnung1">0.0 then "Ein.P.Körnung1" # Min("Ein.P.Körnung1", 100000000000.0)
  else "Ein.P.Körnung1" # Max("Ein.P.Körnung1", -100000000000.0);
  if "Ein.P.Körnung2">0.0 then "Ein.P.Körnung2" # Min("Ein.P.Körnung2", 100000000000.0)
  else "Ein.P.Körnung2" # Max("Ein.P.Körnung2", -100000000000.0);
  if "Ein.P.Chemie.C1">0.0 then "Ein.P.Chemie.C1" # Min("Ein.P.Chemie.C1", 100000000000.0)
  else "Ein.P.Chemie.C1" # Max("Ein.P.Chemie.C1", -100000000000.0);
  if "Ein.P.Chemie.C2">0.0 then "Ein.P.Chemie.C2" # Min("Ein.P.Chemie.C2", 100000000000.0)
  else "Ein.P.Chemie.C2" # Max("Ein.P.Chemie.C2", -100000000000.0);
  if "Ein.P.Chemie.Si1">0.0 then "Ein.P.Chemie.Si1" # Min("Ein.P.Chemie.Si1", 100000000000.0)
  else "Ein.P.Chemie.Si1" # Max("Ein.P.Chemie.Si1", -100000000000.0);
  if "Ein.P.Chemie.Si2">0.0 then "Ein.P.Chemie.Si2" # Min("Ein.P.Chemie.Si2", 100000000000.0)
  else "Ein.P.Chemie.Si2" # Max("Ein.P.Chemie.Si2", -100000000000.0);
  if "Ein.P.Chemie.Mn1">0.0 then "Ein.P.Chemie.Mn1" # Min("Ein.P.Chemie.Mn1", 100000000000.0)
  else "Ein.P.Chemie.Mn1" # Max("Ein.P.Chemie.Mn1", -100000000000.0);
  if "Ein.P.Chemie.Mn2">0.0 then "Ein.P.Chemie.Mn2" # Min("Ein.P.Chemie.Mn2", 100000000000.0)
  else "Ein.P.Chemie.Mn2" # Max("Ein.P.Chemie.Mn2", -100000000000.0);
  if "Ein.P.Chemie.P1">0.0 then "Ein.P.Chemie.P1" # Min("Ein.P.Chemie.P1", 100000000000.0)
  else "Ein.P.Chemie.P1" # Max("Ein.P.Chemie.P1", -100000000000.0);
  if "Ein.P.Chemie.P2">0.0 then "Ein.P.Chemie.P2" # Min("Ein.P.Chemie.P2", 100000000000.0)
  else "Ein.P.Chemie.P2" # Max("Ein.P.Chemie.P2", -100000000000.0);
  if "Ein.P.Chemie.S1">0.0 then "Ein.P.Chemie.S1" # Min("Ein.P.Chemie.S1", 100000000000.0)
  else "Ein.P.Chemie.S1" # Max("Ein.P.Chemie.S1", -100000000000.0);
  if "Ein.P.Chemie.S2">0.0 then "Ein.P.Chemie.S2" # Min("Ein.P.Chemie.S2", 100000000000.0)
  else "Ein.P.Chemie.S2" # Max("Ein.P.Chemie.S2", -100000000000.0);
  if "Ein.P.Chemie.Al1">0.0 then "Ein.P.Chemie.Al1" # Min("Ein.P.Chemie.Al1", 100000000000.0)
  else "Ein.P.Chemie.Al1" # Max("Ein.P.Chemie.Al1", -100000000000.0);
  if "Ein.P.Chemie.Al2">0.0 then "Ein.P.Chemie.Al2" # Min("Ein.P.Chemie.Al2", 100000000000.0)
  else "Ein.P.Chemie.Al2" # Max("Ein.P.Chemie.Al2", -100000000000.0);
  if "Ein.P.Chemie.Cr1">0.0 then "Ein.P.Chemie.Cr1" # Min("Ein.P.Chemie.Cr1", 100000000000.0)
  else "Ein.P.Chemie.Cr1" # Max("Ein.P.Chemie.Cr1", -100000000000.0);
  if "Ein.P.Chemie.Cr2">0.0 then "Ein.P.Chemie.Cr2" # Min("Ein.P.Chemie.Cr2", 100000000000.0)
  else "Ein.P.Chemie.Cr2" # Max("Ein.P.Chemie.Cr2", -100000000000.0);
  if "Ein.P.Chemie.V1">0.0 then "Ein.P.Chemie.V1" # Min("Ein.P.Chemie.V1", 100000000000.0)
  else "Ein.P.Chemie.V1" # Max("Ein.P.Chemie.V1", -100000000000.0);
  if "Ein.P.Chemie.V2">0.0 then "Ein.P.Chemie.V2" # Min("Ein.P.Chemie.V2", 100000000000.0)
  else "Ein.P.Chemie.V2" # Max("Ein.P.Chemie.V2", -100000000000.0);
  if "Ein.P.Chemie.Nb1">0.0 then "Ein.P.Chemie.Nb1" # Min("Ein.P.Chemie.Nb1", 100000000000.0)
  else "Ein.P.Chemie.Nb1" # Max("Ein.P.Chemie.Nb1", -100000000000.0);
  if "Ein.P.Chemie.Nb2">0.0 then "Ein.P.Chemie.Nb2" # Min("Ein.P.Chemie.Nb2", 100000000000.0)
  else "Ein.P.Chemie.Nb2" # Max("Ein.P.Chemie.Nb2", -100000000000.0);
  if "Ein.P.Chemie.Ti1">0.0 then "Ein.P.Chemie.Ti1" # Min("Ein.P.Chemie.Ti1", 100000000000.0)
  else "Ein.P.Chemie.Ti1" # Max("Ein.P.Chemie.Ti1", -100000000000.0);
  if "Ein.P.Chemie.Ti2">0.0 then "Ein.P.Chemie.Ti2" # Min("Ein.P.Chemie.Ti2", 100000000000.0)
  else "Ein.P.Chemie.Ti2" # Max("Ein.P.Chemie.Ti2", -100000000000.0);
  if "Ein.P.Chemie.N1">0.0 then "Ein.P.Chemie.N1" # Min("Ein.P.Chemie.N1", 100000000000.0)
  else "Ein.P.Chemie.N1" # Max("Ein.P.Chemie.N1", -100000000000.0);
  if "Ein.P.Chemie.N2">0.0 then "Ein.P.Chemie.N2" # Min("Ein.P.Chemie.N2", 100000000000.0)
  else "Ein.P.Chemie.N2" # Max("Ein.P.Chemie.N2", -100000000000.0);
  if "Ein.P.Chemie.Cu1">0.0 then "Ein.P.Chemie.Cu1" # Min("Ein.P.Chemie.Cu1", 100000000000.0)
  else "Ein.P.Chemie.Cu1" # Max("Ein.P.Chemie.Cu1", -100000000000.0);
  if "Ein.P.Chemie.Cu2">0.0 then "Ein.P.Chemie.Cu2" # Min("Ein.P.Chemie.Cu2", 100000000000.0)
  else "Ein.P.Chemie.Cu2" # Max("Ein.P.Chemie.Cu2", -100000000000.0);
  if "Ein.P.Chemie.Ni1">0.0 then "Ein.P.Chemie.Ni1" # Min("Ein.P.Chemie.Ni1", 100000000000.0)
  else "Ein.P.Chemie.Ni1" # Max("Ein.P.Chemie.Ni1", -100000000000.0);
  if "Ein.P.Chemie.Ni2">0.0 then "Ein.P.Chemie.Ni2" # Min("Ein.P.Chemie.Ni2", 100000000000.0)
  else "Ein.P.Chemie.Ni2" # Max("Ein.P.Chemie.Ni2", -100000000000.0);
  if "Ein.P.Chemie.Mo1">0.0 then "Ein.P.Chemie.Mo1" # Min("Ein.P.Chemie.Mo1", 100000000000.0)
  else "Ein.P.Chemie.Mo1" # Max("Ein.P.Chemie.Mo1", -100000000000.0);
  if "Ein.P.Chemie.Mo2">0.0 then "Ein.P.Chemie.Mo2" # Min("Ein.P.Chemie.Mo2", 100000000000.0)
  else "Ein.P.Chemie.Mo2" # Max("Ein.P.Chemie.Mo2", -100000000000.0);
  if "Ein.P.Chemie.B1">0.0 then "Ein.P.Chemie.B1" # Min("Ein.P.Chemie.B1", 100000000000.0)
  else "Ein.P.Chemie.B1" # Max("Ein.P.Chemie.B1", -100000000000.0);
  if "Ein.P.Chemie.B2">0.0 then "Ein.P.Chemie.B2" # Min("Ein.P.Chemie.B2", 100000000000.0)
  else "Ein.P.Chemie.B2" # Max("Ein.P.Chemie.B2", -100000000000.0);
  if "Ein.P.Härte1">0.0 then "Ein.P.Härte1" # Min("Ein.P.Härte1", 100000000000.0)
  else "Ein.P.Härte1" # Max("Ein.P.Härte1", -100000000000.0);
  if "Ein.P.Härte2">0.0 then "Ein.P.Härte2" # Min("Ein.P.Härte2", 100000000000.0)
  else "Ein.P.Härte2" # Max("Ein.P.Härte2", -100000000000.0);
  if "Ein.P.Chemie.Frei1.1">0.0 then "Ein.P.Chemie.Frei1.1" # Min("Ein.P.Chemie.Frei1.1", 100000000000.0)
  else "Ein.P.Chemie.Frei1.1" # Max("Ein.P.Chemie.Frei1.1", -100000000000.0);
  if "Ein.P.Chemie.Frei1.2">0.0 then "Ein.P.Chemie.Frei1.2" # Min("Ein.P.Chemie.Frei1.2", 100000000000.0)
  else "Ein.P.Chemie.Frei1.2" # Max("Ein.P.Chemie.Frei1.2", -100000000000.0);
  if "Ein.P.RauigkeitA1">0.0 then "Ein.P.RauigkeitA1" # Min("Ein.P.RauigkeitA1", 100000000000.0)
  else "Ein.P.RauigkeitA1" # Max("Ein.P.RauigkeitA1", -100000000000.0);
  if "Ein.P.RauigkeitA2">0.0 then "Ein.P.RauigkeitA2" # Min("Ein.P.RauigkeitA2", 100000000000.0)
  else "Ein.P.RauigkeitA2" # Max("Ein.P.RauigkeitA2", -100000000000.0);
  if "Ein.P.RauigkeitB1">0.0 then "Ein.P.RauigkeitB1" # Min("Ein.P.RauigkeitB1", 100000000000.0)
  else "Ein.P.RauigkeitB1" # Max("Ein.P.RauigkeitB1", -100000000000.0);
  if "Ein.P.RauigkeitB2">0.0 then "Ein.P.RauigkeitB2" # Min("Ein.P.RauigkeitB2", 100000000000.0)
  else "Ein.P.RauigkeitB2" # Max("Ein.P.RauigkeitB2", -100000000000.0);
  GV.Alpha.06 # Bool("Ein.P.StehendYN");
  GV.Alpha.07 # Bool("Ein.P.LiegendYN");
  if "Ein.P.Nettoabzug">0.0 then "Ein.P.Nettoabzug" # Min("Ein.P.Nettoabzug", 100000000000.0)
  else "Ein.P.Nettoabzug" # Max("Ein.P.Nettoabzug", -100000000000.0);
  if "Ein.P.Stapelhöhe">0.0 then "Ein.P.Stapelhöhe" # Min("Ein.P.Stapelhöhe", 100000000000.0)
  else "Ein.P.Stapelhöhe" # Max("Ein.P.Stapelhöhe", -100000000000.0);
  if "Ein.P.StapelhAbzug">0.0 then "Ein.P.StapelhAbzug" # Min("Ein.P.StapelhAbzug", 100000000000.0)
  else "Ein.P.StapelhAbzug" # Max("Ein.P.StapelhAbzug", -100000000000.0);
  if "Ein.P.RingkgVon">0.0 then "Ein.P.RingkgVon" # Min("Ein.P.RingkgVon", 100000000000.0)
  else "Ein.P.RingkgVon" # Max("Ein.P.RingkgVon", -100000000000.0);
  if "Ein.P.RingkgBis">0.0 then "Ein.P.RingkgBis" # Min("Ein.P.RingkgBis", 100000000000.0)
  else "Ein.P.RingkgBis" # Max("Ein.P.RingkgBis", -100000000000.0);
  if "Ein.P.kgmmVon">0.0 then "Ein.P.kgmmVon" # Min("Ein.P.kgmmVon", 100000000000.0)
  else "Ein.P.kgmmVon" # Max("Ein.P.kgmmVon", -100000000000.0);
  if "Ein.P.kgmmBis">0.0 then "Ein.P.kgmmBis" # Min("Ein.P.kgmmBis", 100000000000.0)
  else "Ein.P.kgmmBis" # Max("Ein.P.kgmmBis", -100000000000.0);
  if "Ein.P.VEkgmax">0.0 then "Ein.P.VEkgmax" # Min("Ein.P.VEkgmax", 100000000000.0)
  else "Ein.P.VEkgmax" # Max("Ein.P.VEkgmax", -100000000000.0);
  if "Ein.P.RechtwinkMax">0.0 then "Ein.P.RechtwinkMax" # Min("Ein.P.RechtwinkMax", 100000000000.0)
  else "Ein.P.RechtwinkMax" # Max("Ein.P.RechtwinkMax", -100000000000.0);
  if "Ein.P.EbenheitMax">0.0 then "Ein.P.EbenheitMax" # Min("Ein.P.EbenheitMax", 100000000000.0)
  else "Ein.P.EbenheitMax" # Max("Ein.P.EbenheitMax", -100000000000.0);
  if "Ein.P.SäbeligkeitMax">0.0 then "Ein.P.SäbeligkeitMax" # Min("Ein.P.SäbeligkeitMax", 100000000000.0)
  else "Ein.P.SäbeligkeitMax" # Max("Ein.P.SäbeligkeitMax", -100000000000.0);
  if "Ein.P.SäbelProM">0.0 then "Ein.P.SäbelProM" # Min("Ein.P.SäbelProM", 100000000000.0)
  else "Ein.P.SäbelProM" # Max("Ein.P.SäbelProM", -100000000000.0);
  GV.Alpha.08 # Bool("Ein.P.MitLfEYN");
  if "Ein.P.FE.Dicke">0.0 then "Ein.P.FE.Dicke" # Min("Ein.P.FE.Dicke", 100000000000.0)
  else "Ein.P.FE.Dicke" # Max("Ein.P.FE.Dicke", -100000000000.0);
  if "Ein.P.FE.Breite">0.0 then "Ein.P.FE.Breite" # Min("Ein.P.FE.Breite", 100000000000.0)
  else "Ein.P.FE.Breite" # Max("Ein.P.FE.Breite", -100000000000.0);
  if "Ein.P.FE.Länge">0.0 then "Ein.P.FE.Länge" # Min("Ein.P.FE.Länge", 100000000000.0)
  else "Ein.P.FE.Länge" # Max("Ein.P.FE.Länge", -100000000000.0);
  if "Ein.P.FE.RID">0.0 then "Ein.P.FE.RID" # Min("Ein.P.FE.RID", 100000000000.0)
  else "Ein.P.FE.RID" # Max("Ein.P.FE.RID", -100000000000.0);
  if "Ein.P.FE.RIDMax">0.0 then "Ein.P.FE.RIDMax" # Min("Ein.P.FE.RIDMax", 100000000000.0)
  else "Ein.P.FE.RIDMax" # Max("Ein.P.FE.RIDMax", -100000000000.0);
  if "Ein.P.FE.RAD">0.0 then "Ein.P.FE.RAD" # Min("Ein.P.FE.RAD", 100000000000.0)
  else "Ein.P.FE.RAD" # Max("Ein.P.FE.RAD", -100000000000.0);
  if "Ein.P.FE.RADMax">0.0 then "Ein.P.FE.RADMax" # Min("Ein.P.FE.RADMax", 100000000000.0)
  else "Ein.P.FE.RADMax" # Max("Ein.P.FE.RADMax", -100000000000.0);
  if "Ein.P.FE.Gewicht">0.0 then "Ein.P.FE.Gewicht" # Min("Ein.P.FE.Gewicht", 100000000000.0)
  else "Ein.P.FE.Gewicht" # Max("Ein.P.FE.Gewicht", -100000000000.0);
  GV.Alpha.09 # Bool("Ein.P.StorniertYN");
end;

// -------------------------------------------------
sub EX502()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0502'
     +cnvai(RecInfo(502,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(502, _recModified);
end;

// -------------------------------------------------
sub EX503()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0503'
     +cnvai(RecInfo(503,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(503, _recModified);
  if "Ein.Z.Menge">0.0 then "Ein.Z.Menge" # Min("Ein.Z.Menge", 100000000000.0)
  else "Ein.Z.Menge" # Max("Ein.Z.Menge", -100000000000.0);
  GV.Alpha.02 # Bool("Ein.Z.MengenbezugYN");
  GV.Alpha.03 # Bool("Ein.Z.RabattierbarYN");
  GV.Alpha.04 # Bool("Ein.Z.NeuberechnenYN");
  if "Ein.Z.Preis">0.0 then "Ein.Z.Preis" # Min("Ein.Z.Preis", 100000000000.0)
  else "Ein.Z.Preis" # Max("Ein.Z.Preis", -100000000000.0);
  GV.Alpha.05 # Bool("Ein.Z.MatAktionYN");
  GV.Alpha.06 # Bool("Ein.Z.PerFormelYN");
  GV.Alpha.07 # Bool("Ein.Z.ProRechnungYN");
end;

// -------------------------------------------------
sub EX504()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0504'
     +cnvai(RecInfo(504,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(504, _recModified);
  GV.Alpha.02 # Datum("Ein.A.Aktionsdatum");
  GV.Alpha.03 # Datum("Ein.A.TerminStart");
  GV.Alpha.04 # Datum("Ein.A.TerminEnde");
  if "Ein.A.Menge">0.0 then "Ein.A.Menge" # Min("Ein.A.Menge", 100000000000.0)
  else "Ein.A.Menge" # Max("Ein.A.Menge", -100000000000.0);
  if "Ein.A.Gewicht">0.0 then "Ein.A.Gewicht" # Min("Ein.A.Gewicht", 100000000000.0)
  else "Ein.A.Gewicht" # Max("Ein.A.Gewicht", -100000000000.0);
end;

// -------------------------------------------------
sub EX505()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0505'
     +cnvai(RecInfo(505,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(505, _recModified);
  GV.Alpha.02 # Datum("Ein.K.Termin");
  if "Ein.K.Menge">0.0 then "Ein.K.Menge" # Min("Ein.K.Menge", 100000000000.0)
  else "Ein.K.Menge" # Max("Ein.K.Menge", -100000000000.0);
  GV.Alpha.03 # Bool("Ein.K.MengenbezugYN");
  if "Ein.K.Preis">0.0 then "Ein.K.Preis" # Min("Ein.K.Preis", 100000000000.0)
  else "Ein.K.Preis" # Max("Ein.K.Preis", -100000000000.0);
  GV.Alpha.04 # Bool("Ein.K.RückstellungYN");
  GV.Alpha.05 # Bool("Ein.K.NachtragYN");
  GV.Alpha.06 # Bool("Ein.K.EinsatzmengeYN");
end;

// -------------------------------------------------
sub EX506()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0506'
     +cnvai(RecInfo(506,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(506, _recModified);
  GV.Alpha.02 # Bool("Ein.E.VSBYN");
  GV.Alpha.03 # Datum("Ein.E.VSB_Datum");
  GV.Alpha.04 # Bool("Ein.E.EingangYN");
  GV.Alpha.05 # Datum("Ein.E.Eingang_Datum");
  GV.Alpha.06 # Bool("Ein.E.AusfallYN");
  GV.Alpha.07 # Datum("Ein.E.Ausfall_Datum");
  if "Ein.E.Preis">0.0 then "Ein.E.Preis" # Min("Ein.E.Preis", 100000000000.0)
  else "Ein.E.Preis" # Max("Ein.E.Preis", -100000000000.0);
  if "Ein.E.PreisW1">0.0 then "Ein.E.PreisW1" # Min("Ein.E.PreisW1", 100000000000.0)
  else "Ein.E.PreisW1" # Max("Ein.E.PreisW1", -100000000000.0);
  if "Ein.E.Menge">0.0 then "Ein.E.Menge" # Min("Ein.E.Menge", 100000000000.0)
  else "Ein.E.Menge" # Max("Ein.E.Menge", -100000000000.0);
  if "Ein.E.Gewicht">0.0 then "Ein.E.Gewicht" # Min("Ein.E.Gewicht", 100000000000.0)
  else "Ein.E.Gewicht" # Max("Ein.E.Gewicht", -100000000000.0);
  GV.Alpha.08 # Bool("Ein.E.GesperrtYN");
  if "Ein.E.Menge2">0.0 then "Ein.E.Menge2" # Min("Ein.E.Menge2", 100000000000.0)
  else "Ein.E.Menge2" # Max("Ein.E.Menge2", -100000000000.0);
  if "Ein.E.CO2EinstandPT">0.0 then "Ein.E.CO2EinstandPT" # Min("Ein.E.CO2EinstandPT", 100000000000.0)
  else "Ein.E.CO2EinstandPT" # Max("Ein.E.CO2EinstandPT", -100000000000.0);
  if "Ein.E.Dicke">0.0 then "Ein.E.Dicke" # Min("Ein.E.Dicke", 100000000000.0)
  else "Ein.E.Dicke" # Max("Ein.E.Dicke", -100000000000.0);
  GV.Alpha.09 # Bool("Ein.E.DickenTolYN");
  if "Ein.E.Dicke.Von">0.0 then "Ein.E.Dicke.Von" # Min("Ein.E.Dicke.Von", 100000000000.0)
  else "Ein.E.Dicke.Von" # Max("Ein.E.Dicke.Von", -100000000000.0);
  if "Ein.E.Dicke.Bis">0.0 then "Ein.E.Dicke.Bis" # Min("Ein.E.Dicke.Bis", 100000000000.0)
  else "Ein.E.Dicke.Bis" # Max("Ein.E.Dicke.Bis", -100000000000.0);
  if "Ein.E.Breite">0.0 then "Ein.E.Breite" # Min("Ein.E.Breite", 100000000000.0)
  else "Ein.E.Breite" # Max("Ein.E.Breite", -100000000000.0);
  GV.Alpha.10 # Bool("Ein.E.BreitenTolYN");
  if "Ein.E.Breite.Von">0.0 then "Ein.E.Breite.Von" # Min("Ein.E.Breite.Von", 100000000000.0)
  else "Ein.E.Breite.Von" # Max("Ein.E.Breite.Von", -100000000000.0);
  if "Ein.E.Breite.Bis">0.0 then "Ein.E.Breite.Bis" # Min("Ein.E.Breite.Bis", 100000000000.0)
  else "Ein.E.Breite.Bis" # Max("Ein.E.Breite.Bis", -100000000000.0);
  if "Ein.E.Länge">0.0 then "Ein.E.Länge" # Min("Ein.E.Länge", 100000000000.0)
  else "Ein.E.Länge" # Max("Ein.E.Länge", -100000000000.0);
  GV.Alpha.11 # Bool("Ein.E.LängenTolYN");
  if "Ein.E.Länge.Von">0.0 then "Ein.E.Länge.Von" # Min("Ein.E.Länge.Von", 100000000000.0)
  else "Ein.E.Länge.Von" # Max("Ein.E.Länge.Von", -100000000000.0);
  if "Ein.E.Länge.Bis">0.0 then "Ein.E.Länge.Bis" # Min("Ein.E.Länge.Bis", 100000000000.0)
  else "Ein.E.Länge.Bis" # Max("Ein.E.Länge.Bis", -100000000000.0);
  if "Ein.E.RID">0.0 then "Ein.E.RID" # Min("Ein.E.RID", 100000000000.0)
  else "Ein.E.RID" # Max("Ein.E.RID", -100000000000.0);
  if "Ein.E.RAD">0.0 then "Ein.E.RAD" # Min("Ein.E.RAD", 100000000000.0)
  else "Ein.E.RAD" # Max("Ein.E.RAD", -100000000000.0);
  if "Ein.E.Gewicht.Netto">0.0 then "Ein.E.Gewicht.Netto" # Min("Ein.E.Gewicht.Netto", 100000000000.0)
  else "Ein.E.Gewicht.Netto" # Max("Ein.E.Gewicht.Netto", -100000000000.0);
  if "Ein.E.Gewicht.Brutto">0.0 then "Ein.E.Gewicht.Brutto" # Min("Ein.E.Gewicht.Brutto", 100000000000.0)
  else "Ein.E.Gewicht.Brutto" # Max("Ein.E.Gewicht.Brutto", -100000000000.0);
  GV.Alpha.12 # Bool("Ein.E.StehendYN");
  GV.Alpha.13 # Bool("Ein.E.LiegendYN");
  if "Ein.E.Nettoabzug">0.0 then "Ein.E.Nettoabzug" # Min("Ein.E.Nettoabzug", 100000000000.0)
  else "Ein.E.Nettoabzug" # Max("Ein.E.Nettoabzug", -100000000000.0);
  if "Ein.E.Stapelhöhe">0.0 then "Ein.E.Stapelhöhe" # Min("Ein.E.Stapelhöhe", 100000000000.0)
  else "Ein.E.Stapelhöhe" # Max("Ein.E.Stapelhöhe", -100000000000.0);
  if "Ein.E.Stapelhöhenabz">0.0 then "Ein.E.Stapelhöhenabz" # Min("Ein.E.Stapelhöhenabz", 100000000000.0)
  else "Ein.E.Stapelhöhenabz" # Max("Ein.E.Stapelhöhenabz", -100000000000.0);
  if "Ein.E.Rechtwinkligk">0.0 then "Ein.E.Rechtwinkligk" # Min("Ein.E.Rechtwinkligk", 100000000000.0)
  else "Ein.E.Rechtwinkligk" # Max("Ein.E.Rechtwinkligk", -100000000000.0);
  if "Ein.E.Ebenheit">0.0 then "Ein.E.Ebenheit" # Min("Ein.E.Ebenheit", 100000000000.0)
  else "Ein.E.Ebenheit" # Max("Ein.E.Ebenheit", -100000000000.0);
  if "Ein.E.Säbeligkeit">0.0 then "Ein.E.Säbeligkeit" # Min("Ein.E.Säbeligkeit", 100000000000.0)
  else "Ein.E.Säbeligkeit" # Max("Ein.E.Säbeligkeit", -100000000000.0);
  if "Ein.E.SäbelProM">0.0 then "Ein.E.SäbelProM" # Min("Ein.E.SäbelProM", 100000000000.0)
  else "Ein.E.SäbelProM" # Max("Ein.E.SäbelProM", -100000000000.0);
  if "Ein.E.Streckgrenze">0.0 then "Ein.E.Streckgrenze" # Min("Ein.E.Streckgrenze", 100000000000.0)
  else "Ein.E.Streckgrenze" # Max("Ein.E.Streckgrenze", -100000000000.0);
  if "Ein.E.Zugfestigkeit">0.0 then "Ein.E.Zugfestigkeit" # Min("Ein.E.Zugfestigkeit", 100000000000.0)
  else "Ein.E.Zugfestigkeit" # Max("Ein.E.Zugfestigkeit", -100000000000.0);
  if "Ein.E.DehnungA">0.0 then "Ein.E.DehnungA" # Min("Ein.E.DehnungA", 100000000000.0)
  else "Ein.E.DehnungA" # Max("Ein.E.DehnungA", -100000000000.0);
  if "Ein.E.DehnungB">0.0 then "Ein.E.DehnungB" # Min("Ein.E.DehnungB", 100000000000.0)
  else "Ein.E.DehnungB" # Max("Ein.E.DehnungB", -100000000000.0);
  if "Ein.E.RP02_1">0.0 then "Ein.E.RP02_1" # Min("Ein.E.RP02_1", 100000000000.0)
  else "Ein.E.RP02_1" # Max("Ein.E.RP02_1", -100000000000.0);
  if "Ein.E.RP10_1">0.0 then "Ein.E.RP10_1" # Min("Ein.E.RP10_1", 100000000000.0)
  else "Ein.E.RP10_1" # Max("Ein.E.RP10_1", -100000000000.0);
  if "Ein.E.Körnung">0.0 then "Ein.E.Körnung" # Min("Ein.E.Körnung", 100000000000.0)
  else "Ein.E.Körnung" # Max("Ein.E.Körnung", -100000000000.0);
  if "Ein.E.Chemie.C">0.0 then "Ein.E.Chemie.C" # Min("Ein.E.Chemie.C", 100000000000.0)
  else "Ein.E.Chemie.C" # Max("Ein.E.Chemie.C", -100000000000.0);
  if "Ein.E.Chemie.Si">0.0 then "Ein.E.Chemie.Si" # Min("Ein.E.Chemie.Si", 100000000000.0)
  else "Ein.E.Chemie.Si" # Max("Ein.E.Chemie.Si", -100000000000.0);
  if "Ein.E.Chemie.Mn">0.0 then "Ein.E.Chemie.Mn" # Min("Ein.E.Chemie.Mn", 100000000000.0)
  else "Ein.E.Chemie.Mn" # Max("Ein.E.Chemie.Mn", -100000000000.0);
  if "Ein.E.Chemie.P">0.0 then "Ein.E.Chemie.P" # Min("Ein.E.Chemie.P", 100000000000.0)
  else "Ein.E.Chemie.P" # Max("Ein.E.Chemie.P", -100000000000.0);
  if "Ein.E.Chemie.S">0.0 then "Ein.E.Chemie.S" # Min("Ein.E.Chemie.S", 100000000000.0)
  else "Ein.E.Chemie.S" # Max("Ein.E.Chemie.S", -100000000000.0);
  if "Ein.E.Chemie.Al">0.0 then "Ein.E.Chemie.Al" # Min("Ein.E.Chemie.Al", 100000000000.0)
  else "Ein.E.Chemie.Al" # Max("Ein.E.Chemie.Al", -100000000000.0);
  if "Ein.E.Chemie.Cr">0.0 then "Ein.E.Chemie.Cr" # Min("Ein.E.Chemie.Cr", 100000000000.0)
  else "Ein.E.Chemie.Cr" # Max("Ein.E.Chemie.Cr", -100000000000.0);
  if "Ein.E.Chemie.V">0.0 then "Ein.E.Chemie.V" # Min("Ein.E.Chemie.V", 100000000000.0)
  else "Ein.E.Chemie.V" # Max("Ein.E.Chemie.V", -100000000000.0);
  if "Ein.E.Chemie.Nb">0.0 then "Ein.E.Chemie.Nb" # Min("Ein.E.Chemie.Nb", 100000000000.0)
  else "Ein.E.Chemie.Nb" # Max("Ein.E.Chemie.Nb", -100000000000.0);
  if "Ein.E.Chemie.Ti">0.0 then "Ein.E.Chemie.Ti" # Min("Ein.E.Chemie.Ti", 100000000000.0)
  else "Ein.E.Chemie.Ti" # Max("Ein.E.Chemie.Ti", -100000000000.0);
  if "Ein.E.Chemie.N">0.0 then "Ein.E.Chemie.N" # Min("Ein.E.Chemie.N", 100000000000.0)
  else "Ein.E.Chemie.N" # Max("Ein.E.Chemie.N", -100000000000.0);
  if "Ein.E.Chemie.Cu">0.0 then "Ein.E.Chemie.Cu" # Min("Ein.E.Chemie.Cu", 100000000000.0)
  else "Ein.E.Chemie.Cu" # Max("Ein.E.Chemie.Cu", -100000000000.0);
  if "Ein.E.Chemie.Ni">0.0 then "Ein.E.Chemie.Ni" # Min("Ein.E.Chemie.Ni", 100000000000.0)
  else "Ein.E.Chemie.Ni" # Max("Ein.E.Chemie.Ni", -100000000000.0);
  if "Ein.E.Chemie.Mo">0.0 then "Ein.E.Chemie.Mo" # Min("Ein.E.Chemie.Mo", 100000000000.0)
  else "Ein.E.Chemie.Mo" # Max("Ein.E.Chemie.Mo", -100000000000.0);
  if "Ein.E.Chemie.B">0.0 then "Ein.E.Chemie.B" # Min("Ein.E.Chemie.B", 100000000000.0)
  else "Ein.E.Chemie.B" # Max("Ein.E.Chemie.B", -100000000000.0);
  if "Ein.E.Härte1">0.0 then "Ein.E.Härte1" # Min("Ein.E.Härte1", 100000000000.0)
  else "Ein.E.Härte1" # Max("Ein.E.Härte1", -100000000000.0);
  if "Ein.E.Chemie.Frei1">0.0 then "Ein.E.Chemie.Frei1" # Min("Ein.E.Chemie.Frei1", 100000000000.0)
  else "Ein.E.Chemie.Frei1" # Max("Ein.E.Chemie.Frei1", -100000000000.0);
  if "Ein.E.Härte2">0.0 then "Ein.E.Härte2" # Min("Ein.E.Härte2", 100000000000.0)
  else "Ein.E.Härte2" # Max("Ein.E.Härte2", -100000000000.0);
  if "Ein.E.RauigkeitA1">0.0 then "Ein.E.RauigkeitA1" # Min("Ein.E.RauigkeitA1", 100000000000.0)
  else "Ein.E.RauigkeitA1" # Max("Ein.E.RauigkeitA1", -100000000000.0);
  if "Ein.E.RauigkeitA2">0.0 then "Ein.E.RauigkeitA2" # Min("Ein.E.RauigkeitA2", 100000000000.0)
  else "Ein.E.RauigkeitA2" # Max("Ein.E.RauigkeitA2", -100000000000.0);
  if "Ein.E.RauigkeitB1">0.0 then "Ein.E.RauigkeitB1" # Min("Ein.E.RauigkeitB1", 100000000000.0)
  else "Ein.E.RauigkeitB1" # Max("Ein.E.RauigkeitB1", -100000000000.0);
  if "Ein.E.RauigkeitB2">0.0 then "Ein.E.RauigkeitB2" # Min("Ein.E.RauigkeitB2", 100000000000.0)
  else "Ein.E.RauigkeitB2" # Max("Ein.E.RauigkeitB2", -100000000000.0);
  if "Ein.E.Streckgrenze2">0.0 then "Ein.E.Streckgrenze2" # Min("Ein.E.Streckgrenze2", 100000000000.0)
  else "Ein.E.Streckgrenze2" # Max("Ein.E.Streckgrenze2", -100000000000.0);
  if "Ein.E.Zugfestigkeit2">0.0 then "Ein.E.Zugfestigkeit2" # Min("Ein.E.Zugfestigkeit2", 100000000000.0)
  else "Ein.E.Zugfestigkeit2" # Max("Ein.E.Zugfestigkeit2", -100000000000.0);
  if "Ein.E.RP02_2">0.0 then "Ein.E.RP02_2" # Min("Ein.E.RP02_2", 100000000000.0)
  else "Ein.E.RP02_2" # Max("Ein.E.RP02_2", -100000000000.0);
  if "Ein.E.RP10_2">0.0 then "Ein.E.RP10_2" # Min("Ein.E.RP10_2", 100000000000.0)
  else "Ein.E.RP10_2" # Max("Ein.E.RP10_2", -100000000000.0);
  if "Ein.E.Körnung2">0.0 then "Ein.E.Körnung2" # Min("Ein.E.Körnung2", 100000000000.0)
  else "Ein.E.Körnung2" # Max("Ein.E.Körnung2", -100000000000.0);
  if "Ein.E.DehnungC">0.0 then "Ein.E.DehnungC" # Min("Ein.E.DehnungC", 100000000000.0)
  else "Ein.E.DehnungC" # Max("Ein.E.DehnungC", -100000000000.0);
end;

// -------------------------------------------------
sub EX507()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0507'
     +cnvai(RecInfo(507,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(507, _recModified);
end;

// -------------------------------------------------
sub EX510()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0510'
     +cnvai(RecInfo(510,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(510, _recModified);
  GV.Alpha.02 # Datum("Ein~Datum");
  GV.Alpha.03 # Bool("Ein~LiefervertragYN");
  GV.Alpha.04 # Bool("Ein~AbrufYN");
  if "Ein~Währungskurs">0.0 then "Ein~Währungskurs" # Min("Ein~Währungskurs", 100000000000.0)
  else "Ein~Währungskurs" # Max("Ein~Währungskurs", -100000000000.0);
  GV.Alpha.05 # Bool("Ein~WährungFixYN");
  GV.Alpha.06 # Datum("Ein~AB.Datum");
  GV.Alpha.07 # Datum("Ein~GültigkeitVom");
  GV.Alpha.08 # Datum("Ein~GültigkeitBis");
  GV.Alpha.09 # Datum("Ein~Freigabe.Datum");
  GV.Alpha.10 # Zeit("Ein~Freigabe.Zeit");
  if "Ein~Freigabe.WertW1">0.0 then "Ein~Freigabe.WertW1" # Min("Ein~Freigabe.WertW1", 100000000000.0)
  else "Ein~Freigabe.WertW1" # Max("Ein~Freigabe.WertW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX511()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0511'
     +cnvai(RecInfo(511,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(511, _recModified);
  if "Ein~P.Dicke">0.0 then "Ein~P.Dicke" # Min("Ein~P.Dicke", 100000000000.0)
  else "Ein~P.Dicke" # Max("Ein~P.Dicke", -100000000000.0);
  if "Ein~P.Breite">0.0 then "Ein~P.Breite" # Min("Ein~P.Breite", 100000000000.0)
  else "Ein~P.Breite" # Max("Ein~P.Breite", -100000000000.0);
  if "Ein~P.Länge">0.0 then "Ein~P.Länge" # Min("Ein~P.Länge", 100000000000.0)
  else "Ein~P.Länge" # Max("Ein~P.Länge", -100000000000.0);
  if "Ein~P.RID">0.0 then "Ein~P.RID" # Min("Ein~P.RID", 100000000000.0)
  else "Ein~P.RID" # Max("Ein~P.RID", -100000000000.0);
  if "Ein~P.RIDMax">0.0 then "Ein~P.RIDMax" # Min("Ein~P.RIDMax", 100000000000.0)
  else "Ein~P.RIDMax" # Max("Ein~P.RIDMax", -100000000000.0);
  if "Ein~P.RAD">0.0 then "Ein~P.RAD" # Min("Ein~P.RAD", 100000000000.0)
  else "Ein~P.RAD" # Max("Ein~P.RAD", -100000000000.0);
  if "Ein~P.RADMax">0.0 then "Ein~P.RADMax" # Min("Ein~P.RADMax", 100000000000.0)
  else "Ein~P.RADMax" # Max("Ein~P.RADMax", -100000000000.0);
  if "Ein~P.Gewicht">0.0 then "Ein~P.Gewicht" # Min("Ein~P.Gewicht", 100000000000.0)
  else "Ein~P.Gewicht" # Max("Ein~P.Gewicht", -100000000000.0);
  if "Ein~P.Menge.Wunsch">0.0 then "Ein~P.Menge.Wunsch" # Min("Ein~P.Menge.Wunsch", 100000000000.0)
  else "Ein~P.Menge.Wunsch" # Max("Ein~P.Menge.Wunsch", -100000000000.0);
  if "Ein~P.Grundpreis">0.0 then "Ein~P.Grundpreis" # Min("Ein~P.Grundpreis", 100000000000.0)
  else "Ein~P.Grundpreis" # Max("Ein~P.Grundpreis", -100000000000.0);
  GV.Alpha.02 # Bool("Ein~P.AufpreisYN");
  if "Ein~P.Aufpreis">0.0 then "Ein~P.Aufpreis" # Min("Ein~P.Aufpreis", 100000000000.0)
  else "Ein~P.Aufpreis" # Max("Ein~P.Aufpreis", -100000000000.0);
  if "Ein~P.Einzelpreis">0.0 then "Ein~P.Einzelpreis" # Min("Ein~P.Einzelpreis", 100000000000.0)
  else "Ein~P.Einzelpreis" # Max("Ein~P.Einzelpreis", -100000000000.0);
  if "Ein~P.Gesamtpreis">0.0 then "Ein~P.Gesamtpreis" # Min("Ein~P.Gesamtpreis", 100000000000.0)
  else "Ein~P.Gesamtpreis" # Max("Ein~P.Gesamtpreis", -100000000000.0);
  if "Ein~P.Kalkuliert">0.0 then "Ein~P.Kalkuliert" # Min("Ein~P.Kalkuliert", 100000000000.0)
  else "Ein~P.Kalkuliert" # Max("Ein~P.Kalkuliert", -100000000000.0);
  GV.Alpha.03 # Datum("Ein~P.Termin1Wunsch");
  GV.Alpha.04 # Datum("Ein~P.Termin2Wunsch");
  GV.Alpha.05 # Datum("Ein~P.TerminZusage");
  if "Ein~P.Menge">0.0 then "Ein~P.Menge" # Min("Ein~P.Menge", 100000000000.0)
  else "Ein~P.Menge" # Max("Ein~P.Menge", -100000000000.0);
  if "Ein~P.FM.VSB">0.0 then "Ein~P.FM.VSB" # Min("Ein~P.FM.VSB", 100000000000.0)
  else "Ein~P.FM.VSB" # Max("Ein~P.FM.VSB", -100000000000.0);
  if "Ein~P.FM.Eingang">0.0 then "Ein~P.FM.Eingang" # Min("Ein~P.FM.Eingang", 100000000000.0)
  else "Ein~P.FM.Eingang" # Max("Ein~P.FM.Eingang", -100000000000.0);
  if "Ein~P.FM.Ausfall">0.0 then "Ein~P.FM.Ausfall" # Min("Ein~P.FM.Ausfall", 100000000000.0)
  else "Ein~P.FM.Ausfall" # Max("Ein~P.FM.Ausfall", -100000000000.0);
  if "Ein~P.FM.Rest">0.0 then "Ein~P.FM.Rest" # Min("Ein~P.FM.Rest", 100000000000.0)
  else "Ein~P.FM.Rest" # Max("Ein~P.FM.Rest", -100000000000.0);
  if "Ein~P.Erfuellgrad">0.0 then "Ein~P.Erfuellgrad" # Min("Ein~P.Erfuellgrad", 100000000000.0)
  else "Ein~P.Erfuellgrad" # Max("Ein~P.Erfuellgrad", -100000000000.0);
  if "Ein~P.Streckgrenze1">0.0 then "Ein~P.Streckgrenze1" # Min("Ein~P.Streckgrenze1", 100000000000.0)
  else "Ein~P.Streckgrenze1" # Max("Ein~P.Streckgrenze1", -100000000000.0);
  if "Ein~P.Streckgrenze2">0.0 then "Ein~P.Streckgrenze2" # Min("Ein~P.Streckgrenze2", 100000000000.0)
  else "Ein~P.Streckgrenze2" # Max("Ein~P.Streckgrenze2", -100000000000.0);
  if "Ein~P.Zugfestigkeit1">0.0 then "Ein~P.Zugfestigkeit1" # Min("Ein~P.Zugfestigkeit1", 100000000000.0)
  else "Ein~P.Zugfestigkeit1" # Max("Ein~P.Zugfestigkeit1", -100000000000.0);
  if "Ein~P.Zugfestigkeit2">0.0 then "Ein~P.Zugfestigkeit2" # Min("Ein~P.Zugfestigkeit2", 100000000000.0)
  else "Ein~P.Zugfestigkeit2" # Max("Ein~P.Zugfestigkeit2", -100000000000.0);
  if "Ein~P.DehnungA1">0.0 then "Ein~P.DehnungA1" # Min("Ein~P.DehnungA1", 100000000000.0)
  else "Ein~P.DehnungA1" # Max("Ein~P.DehnungA1", -100000000000.0);
  if "Ein~P.DehnungA2">0.0 then "Ein~P.DehnungA2" # Min("Ein~P.DehnungA2", 100000000000.0)
  else "Ein~P.DehnungA2" # Max("Ein~P.DehnungA2", -100000000000.0);
  if "Ein~P.DehnungB1">0.0 then "Ein~P.DehnungB1" # Min("Ein~P.DehnungB1", 100000000000.0)
  else "Ein~P.DehnungB1" # Max("Ein~P.DehnungB1", -100000000000.0);
  if "Ein~P.DehnungB2">0.0 then "Ein~P.DehnungB2" # Min("Ein~P.DehnungB2", 100000000000.0)
  else "Ein~P.DehnungB2" # Max("Ein~P.DehnungB2", -100000000000.0);
  if "Ein~P.DehngrenzeA1">0.0 then "Ein~P.DehngrenzeA1" # Min("Ein~P.DehngrenzeA1", 100000000000.0)
  else "Ein~P.DehngrenzeA1" # Max("Ein~P.DehngrenzeA1", -100000000000.0);
  if "Ein~P.DehngrenzeA2">0.0 then "Ein~P.DehngrenzeA2" # Min("Ein~P.DehngrenzeA2", 100000000000.0)
  else "Ein~P.DehngrenzeA2" # Max("Ein~P.DehngrenzeA2", -100000000000.0);
  if "Ein~P.DehngrenzeB1">0.0 then "Ein~P.DehngrenzeB1" # Min("Ein~P.DehngrenzeB1", 100000000000.0)
  else "Ein~P.DehngrenzeB1" # Max("Ein~P.DehngrenzeB1", -100000000000.0);
  if "Ein~P.DehngrenzeB2">0.0 then "Ein~P.DehngrenzeB2" # Min("Ein~P.DehngrenzeB2", 100000000000.0)
  else "Ein~P.DehngrenzeB2" # Max("Ein~P.DehngrenzeB2", -100000000000.0);
  if "Ein~P.Körnung1">0.0 then "Ein~P.Körnung1" # Min("Ein~P.Körnung1", 100000000000.0)
  else "Ein~P.Körnung1" # Max("Ein~P.Körnung1", -100000000000.0);
  if "Ein~P.Körnung2">0.0 then "Ein~P.Körnung2" # Min("Ein~P.Körnung2", 100000000000.0)
  else "Ein~P.Körnung2" # Max("Ein~P.Körnung2", -100000000000.0);
  if "Ein~P.Chemie.C1">0.0 then "Ein~P.Chemie.C1" # Min("Ein~P.Chemie.C1", 100000000000.0)
  else "Ein~P.Chemie.C1" # Max("Ein~P.Chemie.C1", -100000000000.0);
  if "Ein~P.Chemie.C2">0.0 then "Ein~P.Chemie.C2" # Min("Ein~P.Chemie.C2", 100000000000.0)
  else "Ein~P.Chemie.C2" # Max("Ein~P.Chemie.C2", -100000000000.0);
  if "Ein~P.Chemie.Si1">0.0 then "Ein~P.Chemie.Si1" # Min("Ein~P.Chemie.Si1", 100000000000.0)
  else "Ein~P.Chemie.Si1" # Max("Ein~P.Chemie.Si1", -100000000000.0);
  if "Ein~P.Chemie.Si2">0.0 then "Ein~P.Chemie.Si2" # Min("Ein~P.Chemie.Si2", 100000000000.0)
  else "Ein~P.Chemie.Si2" # Max("Ein~P.Chemie.Si2", -100000000000.0);
  if "Ein~P.Chemie.Mn1">0.0 then "Ein~P.Chemie.Mn1" # Min("Ein~P.Chemie.Mn1", 100000000000.0)
  else "Ein~P.Chemie.Mn1" # Max("Ein~P.Chemie.Mn1", -100000000000.0);
  if "Ein~P.Chemie.Mn2">0.0 then "Ein~P.Chemie.Mn2" # Min("Ein~P.Chemie.Mn2", 100000000000.0)
  else "Ein~P.Chemie.Mn2" # Max("Ein~P.Chemie.Mn2", -100000000000.0);
  if "Ein~P.Chemie.P1">0.0 then "Ein~P.Chemie.P1" # Min("Ein~P.Chemie.P1", 100000000000.0)
  else "Ein~P.Chemie.P1" # Max("Ein~P.Chemie.P1", -100000000000.0);
  if "Ein~P.Chemie.P2">0.0 then "Ein~P.Chemie.P2" # Min("Ein~P.Chemie.P2", 100000000000.0)
  else "Ein~P.Chemie.P2" # Max("Ein~P.Chemie.P2", -100000000000.0);
  if "Ein~P.Chemie.S1">0.0 then "Ein~P.Chemie.S1" # Min("Ein~P.Chemie.S1", 100000000000.0)
  else "Ein~P.Chemie.S1" # Max("Ein~P.Chemie.S1", -100000000000.0);
  if "Ein~P.Chemie.S2">0.0 then "Ein~P.Chemie.S2" # Min("Ein~P.Chemie.S2", 100000000000.0)
  else "Ein~P.Chemie.S2" # Max("Ein~P.Chemie.S2", -100000000000.0);
  if "Ein~P.Chemie.Al1">0.0 then "Ein~P.Chemie.Al1" # Min("Ein~P.Chemie.Al1", 100000000000.0)
  else "Ein~P.Chemie.Al1" # Max("Ein~P.Chemie.Al1", -100000000000.0);
  if "Ein~P.Chemie.Al2">0.0 then "Ein~P.Chemie.Al2" # Min("Ein~P.Chemie.Al2", 100000000000.0)
  else "Ein~P.Chemie.Al2" # Max("Ein~P.Chemie.Al2", -100000000000.0);
  if "Ein~P.Chemie.Cr1">0.0 then "Ein~P.Chemie.Cr1" # Min("Ein~P.Chemie.Cr1", 100000000000.0)
  else "Ein~P.Chemie.Cr1" # Max("Ein~P.Chemie.Cr1", -100000000000.0);
  if "Ein~P.Chemie.Cr2">0.0 then "Ein~P.Chemie.Cr2" # Min("Ein~P.Chemie.Cr2", 100000000000.0)
  else "Ein~P.Chemie.Cr2" # Max("Ein~P.Chemie.Cr2", -100000000000.0);
  if "Ein~P.Chemie.V1">0.0 then "Ein~P.Chemie.V1" # Min("Ein~P.Chemie.V1", 100000000000.0)
  else "Ein~P.Chemie.V1" # Max("Ein~P.Chemie.V1", -100000000000.0);
  if "Ein~P.Chemie.V2">0.0 then "Ein~P.Chemie.V2" # Min("Ein~P.Chemie.V2", 100000000000.0)
  else "Ein~P.Chemie.V2" # Max("Ein~P.Chemie.V2", -100000000000.0);
  if "Ein~P.Chemie.Nb1">0.0 then "Ein~P.Chemie.Nb1" # Min("Ein~P.Chemie.Nb1", 100000000000.0)
  else "Ein~P.Chemie.Nb1" # Max("Ein~P.Chemie.Nb1", -100000000000.0);
  if "Ein~P.Chemie.Nb2">0.0 then "Ein~P.Chemie.Nb2" # Min("Ein~P.Chemie.Nb2", 100000000000.0)
  else "Ein~P.Chemie.Nb2" # Max("Ein~P.Chemie.Nb2", -100000000000.0);
  if "Ein~P.Chemie.Ti1">0.0 then "Ein~P.Chemie.Ti1" # Min("Ein~P.Chemie.Ti1", 100000000000.0)
  else "Ein~P.Chemie.Ti1" # Max("Ein~P.Chemie.Ti1", -100000000000.0);
  if "Ein~P.Chemie.Ti2">0.0 then "Ein~P.Chemie.Ti2" # Min("Ein~P.Chemie.Ti2", 100000000000.0)
  else "Ein~P.Chemie.Ti2" # Max("Ein~P.Chemie.Ti2", -100000000000.0);
  if "Ein~P.Chemie.N1">0.0 then "Ein~P.Chemie.N1" # Min("Ein~P.Chemie.N1", 100000000000.0)
  else "Ein~P.Chemie.N1" # Max("Ein~P.Chemie.N1", -100000000000.0);
  if "Ein~P.Chemie.N2">0.0 then "Ein~P.Chemie.N2" # Min("Ein~P.Chemie.N2", 100000000000.0)
  else "Ein~P.Chemie.N2" # Max("Ein~P.Chemie.N2", -100000000000.0);
  if "Ein~P.Chemie.Cu1">0.0 then "Ein~P.Chemie.Cu1" # Min("Ein~P.Chemie.Cu1", 100000000000.0)
  else "Ein~P.Chemie.Cu1" # Max("Ein~P.Chemie.Cu1", -100000000000.0);
  if "Ein~P.Chemie.Cu2">0.0 then "Ein~P.Chemie.Cu2" # Min("Ein~P.Chemie.Cu2", 100000000000.0)
  else "Ein~P.Chemie.Cu2" # Max("Ein~P.Chemie.Cu2", -100000000000.0);
  if "Ein~P.Chemie.Ni1">0.0 then "Ein~P.Chemie.Ni1" # Min("Ein~P.Chemie.Ni1", 100000000000.0)
  else "Ein~P.Chemie.Ni1" # Max("Ein~P.Chemie.Ni1", -100000000000.0);
  if "Ein~P.Chemie.Ni2">0.0 then "Ein~P.Chemie.Ni2" # Min("Ein~P.Chemie.Ni2", 100000000000.0)
  else "Ein~P.Chemie.Ni2" # Max("Ein~P.Chemie.Ni2", -100000000000.0);
  if "Ein~P.Chemie.Mo1">0.0 then "Ein~P.Chemie.Mo1" # Min("Ein~P.Chemie.Mo1", 100000000000.0)
  else "Ein~P.Chemie.Mo1" # Max("Ein~P.Chemie.Mo1", -100000000000.0);
  if "Ein~P.Chemie.Mo2">0.0 then "Ein~P.Chemie.Mo2" # Min("Ein~P.Chemie.Mo2", 100000000000.0)
  else "Ein~P.Chemie.Mo2" # Max("Ein~P.Chemie.Mo2", -100000000000.0);
  if "Ein~P.Chemie.B1">0.0 then "Ein~P.Chemie.B1" # Min("Ein~P.Chemie.B1", 100000000000.0)
  else "Ein~P.Chemie.B1" # Max("Ein~P.Chemie.B1", -100000000000.0);
  if "Ein~P.Chemie.B2">0.0 then "Ein~P.Chemie.B2" # Min("Ein~P.Chemie.B2", 100000000000.0)
  else "Ein~P.Chemie.B2" # Max("Ein~P.Chemie.B2", -100000000000.0);
  if "Ein~P.Härte1">0.0 then "Ein~P.Härte1" # Min("Ein~P.Härte1", 100000000000.0)
  else "Ein~P.Härte1" # Max("Ein~P.Härte1", -100000000000.0);
  if "Ein~P.Härte2">0.0 then "Ein~P.Härte2" # Min("Ein~P.Härte2", 100000000000.0)
  else "Ein~P.Härte2" # Max("Ein~P.Härte2", -100000000000.0);
  if "Ein~P.Chemie.Frei1.1">0.0 then "Ein~P.Chemie.Frei1.1" # Min("Ein~P.Chemie.Frei1.1", 100000000000.0)
  else "Ein~P.Chemie.Frei1.1" # Max("Ein~P.Chemie.Frei1.1", -100000000000.0);
  if "Ein~P.Chemie.Frei1.2">0.0 then "Ein~P.Chemie.Frei1.2" # Min("Ein~P.Chemie.Frei1.2", 100000000000.0)
  else "Ein~P.Chemie.Frei1.2" # Max("Ein~P.Chemie.Frei1.2", -100000000000.0);
  if "Ein~P.RauigkeitA1">0.0 then "Ein~P.RauigkeitA1" # Min("Ein~P.RauigkeitA1", 100000000000.0)
  else "Ein~P.RauigkeitA1" # Max("Ein~P.RauigkeitA1", -100000000000.0);
  if "Ein~P.RauigkeitA2">0.0 then "Ein~P.RauigkeitA2" # Min("Ein~P.RauigkeitA2", 100000000000.0)
  else "Ein~P.RauigkeitA2" # Max("Ein~P.RauigkeitA2", -100000000000.0);
  if "Ein~P.RauigkeitB1">0.0 then "Ein~P.RauigkeitB1" # Min("Ein~P.RauigkeitB1", 100000000000.0)
  else "Ein~P.RauigkeitB1" # Max("Ein~P.RauigkeitB1", -100000000000.0);
  if "Ein~P.RauigkeitB2">0.0 then "Ein~P.RauigkeitB2" # Min("Ein~P.RauigkeitB2", 100000000000.0)
  else "Ein~P.RauigkeitB2" # Max("Ein~P.RauigkeitB2", -100000000000.0);
  GV.Alpha.06 # Bool("Ein~P.StehendYN");
  GV.Alpha.07 # Bool("Ein~P.LiegendYN");
  if "Ein~P.Nettoabzug">0.0 then "Ein~P.Nettoabzug" # Min("Ein~P.Nettoabzug", 100000000000.0)
  else "Ein~P.Nettoabzug" # Max("Ein~P.Nettoabzug", -100000000000.0);
  if "Ein~P.Stapelhöhe">0.0 then "Ein~P.Stapelhöhe" # Min("Ein~P.Stapelhöhe", 100000000000.0)
  else "Ein~P.Stapelhöhe" # Max("Ein~P.Stapelhöhe", -100000000000.0);
  if "Ein~P.StapelhAbzug">0.0 then "Ein~P.StapelhAbzug" # Min("Ein~P.StapelhAbzug", 100000000000.0)
  else "Ein~P.StapelhAbzug" # Max("Ein~P.StapelhAbzug", -100000000000.0);
  if "Ein~P.RingkgVon">0.0 then "Ein~P.RingkgVon" # Min("Ein~P.RingkgVon", 100000000000.0)
  else "Ein~P.RingkgVon" # Max("Ein~P.RingkgVon", -100000000000.0);
  if "Ein~P.RingkgBis">0.0 then "Ein~P.RingkgBis" # Min("Ein~P.RingkgBis", 100000000000.0)
  else "Ein~P.RingkgBis" # Max("Ein~P.RingkgBis", -100000000000.0);
  if "Ein~P.kgmmVon">0.0 then "Ein~P.kgmmVon" # Min("Ein~P.kgmmVon", 100000000000.0)
  else "Ein~P.kgmmVon" # Max("Ein~P.kgmmVon", -100000000000.0);
  if "Ein~P.kgmmBis">0.0 then "Ein~P.kgmmBis" # Min("Ein~P.kgmmBis", 100000000000.0)
  else "Ein~P.kgmmBis" # Max("Ein~P.kgmmBis", -100000000000.0);
  if "Ein~P.VEkgmax">0.0 then "Ein~P.VEkgmax" # Min("Ein~P.VEkgmax", 100000000000.0)
  else "Ein~P.VEkgmax" # Max("Ein~P.VEkgmax", -100000000000.0);
  if "Ein~P.RechtwinkMax">0.0 then "Ein~P.RechtwinkMax" # Min("Ein~P.RechtwinkMax", 100000000000.0)
  else "Ein~P.RechtwinkMax" # Max("Ein~P.RechtwinkMax", -100000000000.0);
  if "Ein~P.EbenheitMax">0.0 then "Ein~P.EbenheitMax" # Min("Ein~P.EbenheitMax", 100000000000.0)
  else "Ein~P.EbenheitMax" # Max("Ein~P.EbenheitMax", -100000000000.0);
  if "Ein~P.SäbeligkeitMax">0.0 then "Ein~P.SäbeligkeitMax" # Min("Ein~P.SäbeligkeitMax", 100000000000.0)
  else "Ein~P.SäbeligkeitMax" # Max("Ein~P.SäbeligkeitMax", -100000000000.0);
  if "Ein~P.SäbelProM">0.0 then "Ein~P.SäbelProM" # Min("Ein~P.SäbelProM", 100000000000.0)
  else "Ein~P.SäbelProM" # Max("Ein~P.SäbelProM", -100000000000.0);
  GV.Alpha.08 # Bool("Ein~P.MitLfEYN");
  if "Ein~P.FE.Dicke">0.0 then "Ein~P.FE.Dicke" # Min("Ein~P.FE.Dicke", 100000000000.0)
  else "Ein~P.FE.Dicke" # Max("Ein~P.FE.Dicke", -100000000000.0);
  if "Ein~P.FE.Breite">0.0 then "Ein~P.FE.Breite" # Min("Ein~P.FE.Breite", 100000000000.0)
  else "Ein~P.FE.Breite" # Max("Ein~P.FE.Breite", -100000000000.0);
  if "Ein~P.FE.Länge">0.0 then "Ein~P.FE.Länge" # Min("Ein~P.FE.Länge", 100000000000.0)
  else "Ein~P.FE.Länge" # Max("Ein~P.FE.Länge", -100000000000.0);
  if "Ein~P.FE.RID">0.0 then "Ein~P.FE.RID" # Min("Ein~P.FE.RID", 100000000000.0)
  else "Ein~P.FE.RID" # Max("Ein~P.FE.RID", -100000000000.0);
  if "Ein~P.FE.RIDMax">0.0 then "Ein~P.FE.RIDMax" # Min("Ein~P.FE.RIDMax", 100000000000.0)
  else "Ein~P.FE.RIDMax" # Max("Ein~P.FE.RIDMax", -100000000000.0);
  if "Ein~P.FE.RAD">0.0 then "Ein~P.FE.RAD" # Min("Ein~P.FE.RAD", 100000000000.0)
  else "Ein~P.FE.RAD" # Max("Ein~P.FE.RAD", -100000000000.0);
  if "Ein~P.FE.RADMax">0.0 then "Ein~P.FE.RADMax" # Min("Ein~P.FE.RADMax", 100000000000.0)
  else "Ein~P.FE.RADMax" # Max("Ein~P.FE.RADMax", -100000000000.0);
  if "Ein~P.FE.Gewicht">0.0 then "Ein~P.FE.Gewicht" # Min("Ein~P.FE.Gewicht", 100000000000.0)
  else "Ein~P.FE.Gewicht" # Max("Ein~P.FE.Gewicht", -100000000000.0);
  GV.Alpha.09 # Bool("Ein~P.StorniertYN");
end;

// -------------------------------------------------
sub EX550()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0550'
     +cnvai(RecInfo(550,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(550, _recModified);
  GV.Alpha.02 # Datum("Vbk.Rechnungsdatum");
  if "Vbk.Währungskurs">0.0 then "Vbk.Währungskurs" # Min("Vbk.Währungskurs", 100000000000.0)
  else "Vbk.Währungskurs" # Max("Vbk.Währungskurs", -100000000000.0);
  if "Vbk.Gewicht">0.0 then "Vbk.Gewicht" # Min("Vbk.Gewicht", 100000000000.0)
  else "Vbk.Gewicht" # Max("Vbk.Gewicht", -100000000000.0);
  GV.Alpha.03 # Datum("Vbk.FibuDatum");
  if "Vbk.Netto">0.0 then "Vbk.Netto" # Min("Vbk.Netto", 100000000000.0)
  else "Vbk.Netto" # Max("Vbk.Netto", -100000000000.0);
  if "Vbk.NettoW1">0.0 then "Vbk.NettoW1" # Min("Vbk.NettoW1", 100000000000.0)
  else "Vbk.NettoW1" # Max("Vbk.NettoW1", -100000000000.0);
  if "Vbk.Steuer">0.0 then "Vbk.Steuer" # Min("Vbk.Steuer", 100000000000.0)
  else "Vbk.Steuer" # Max("Vbk.Steuer", -100000000000.0);
  if "Vbk.SteuerW1">0.0 then "Vbk.SteuerW1" # Min("Vbk.SteuerW1", 100000000000.0)
  else "Vbk.SteuerW1" # Max("Vbk.SteuerW1", -100000000000.0);
  if "Vbk.Brutto">0.0 then "Vbk.Brutto" # Min("Vbk.Brutto", 100000000000.0)
  else "Vbk.Brutto" # Max("Vbk.Brutto", -100000000000.0);
  if "Vbk.BruttoW1">0.0 then "Vbk.BruttoW1" # Min("Vbk.BruttoW1", 100000000000.0)
  else "Vbk.BruttoW1" # Max("Vbk.BruttoW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX551()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0551'
     +cnvai(RecInfo(551,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(551, _recModified);
  if "Vbk.K.Betrag">0.0 then "Vbk.K.Betrag" # Min("Vbk.K.Betrag", 100000000000.0)
  else "Vbk.K.Betrag" # Max("Vbk.K.Betrag", -100000000000.0);
  if "Vbk.K.BetragW1">0.0 then "Vbk.K.BetragW1" # Min("Vbk.K.BetragW1", 100000000000.0)
  else "Vbk.K.BetragW1" # Max("Vbk.K.BetragW1", -100000000000.0);
  if "Vbk.K.Gewicht">0.0 then "Vbk.K.Gewicht" # Min("Vbk.K.Gewicht", 100000000000.0)
  else "Vbk.K.Gewicht" # Max("Vbk.K.Gewicht", -100000000000.0);
end;

// -------------------------------------------------
sub EX555()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0555'
     +cnvai(RecInfo(555,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(555, _recModified);
  if "EKK.Währungskurs">0.0 then "EKK.Währungskurs" # Min("EKK.Währungskurs", 100000000000.0)
  else "EKK.Währungskurs" # Max("EKK.Währungskurs", -100000000000.0);
  if "EKK.Preis">0.0 then "EKK.Preis" # Min("EKK.Preis", 100000000000.0)
  else "EKK.Preis" # Max("EKK.Preis", -100000000000.0);
  if "EKK.PreisW1">0.0 then "EKK.PreisW1" # Min("EKK.PreisW1", 100000000000.0)
  else "EKK.PreisW1" # Max("EKK.PreisW1", -100000000000.0);
  if "EKK.Korrigiert">0.0 then "EKK.Korrigiert" # Min("EKK.Korrigiert", 100000000000.0)
  else "EKK.Korrigiert" # Max("EKK.Korrigiert", -100000000000.0);
  if "EKK.KorrigiertW1">0.0 then "EKK.KorrigiertW1" # Min("EKK.KorrigiertW1", 100000000000.0)
  else "EKK.KorrigiertW1" # Max("EKK.KorrigiertW1", -100000000000.0);
  if "EKK.Gewicht">0.0 then "EKK.Gewicht" # Min("EKK.Gewicht", 100000000000.0)
  else "EKK.Gewicht" # Max("EKK.Gewicht", -100000000000.0);
  GV.Alpha.02 # Datum("EKK.Datum");
  if "EKK.Menge">0.0 then "EKK.Menge" # Min("EKK.Menge", 100000000000.0)
  else "EKK.Menge" # Max("EKK.Menge", -100000000000.0);
  GV.Alpha.03 # Datum("EKK.Fibudatum");
  GV.Alpha.04 # Datum("EKK.Zuordnung.Datum");
  GV.Alpha.05 # Zeit("EKK.Zuordnung.Zeit");
  if "EKK.Dicke">0.0 then "EKK.Dicke" # Min("EKK.Dicke", 100000000000.0)
  else "EKK.Dicke" # Max("EKK.Dicke", -100000000000.0);
  if "EKK.Breite">0.0 then "EKK.Breite" # Min("EKK.Breite", 100000000000.0)
  else "EKK.Breite" # Max("EKK.Breite", -100000000000.0);
  if "EKK.Länge">0.0 then "EKK.Länge" # Min("EKK.Länge", 100000000000.0)
  else "EKK.Länge" # Max("EKK.Länge", -100000000000.0);
end;

// -------------------------------------------------
sub EX560()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0560'
     +cnvai(RecInfo(560,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(560, _recModified);
  GV.Alpha.02 # Datum("ERe.Rechnungsdatum");
  if "ERe.Währungskurs">0.0 then "ERe.Währungskurs" # Min("ERe.Währungskurs", 100000000000.0)
  else "ERe.Währungskurs" # Max("ERe.Währungskurs", -100000000000.0);
  GV.Alpha.03 # Datum("ERe.Valuta");
  GV.Alpha.04 # Datum("ERe.Zieldatum");
  GV.Alpha.05 # Datum("ERe.Skontodatum");
  if "ERe.SkontoProzent">0.0 then "ERe.SkontoProzent" # Min("ERe.SkontoProzent", 100000000000.0)
  else "ERe.SkontoProzent" # Max("ERe.SkontoProzent", -100000000000.0);
  GV.Alpha.06 # Datum("ERe.Wiedervorlage");
  if "ERe.Gewicht">0.0 then "ERe.Gewicht" # Min("ERe.Gewicht", 100000000000.0)
  else "ERe.Gewicht" # Max("ERe.Gewicht", -100000000000.0);
  GV.Alpha.07 # Datum("ERe.Prüfdatum");
  GV.Alpha.08 # Bool("ERe.InOrdnung");
  GV.Alpha.09 # Bool("ERe.NichtInOrdnung");
  GV.Alpha.10 # Datum("ERe.FibuDatum");
  GV.Alpha.11 # Datum("ERe.WertstellungsDat");
  GV.Alpha.12 # Bool("ERe.JobAusstehendJN");
  if "ERe.Netto">0.0 then "ERe.Netto" # Min("ERe.Netto", 100000000000.0)
  else "ERe.Netto" # Max("ERe.Netto", -100000000000.0);
  if "ERe.NettoW1">0.0 then "ERe.NettoW1" # Min("ERe.NettoW1", 100000000000.0)
  else "ERe.NettoW1" # Max("ERe.NettoW1", -100000000000.0);
  if "ERe.Steuer">0.0 then "ERe.Steuer" # Min("ERe.Steuer", 100000000000.0)
  else "ERe.Steuer" # Max("ERe.Steuer", -100000000000.0);
  if "ERe.SteuerW1">0.0 then "ERe.SteuerW1" # Min("ERe.SteuerW1", 100000000000.0)
  else "ERe.SteuerW1" # Max("ERe.SteuerW1", -100000000000.0);
  if "ERe.Brutto">0.0 then "ERe.Brutto" # Min("ERe.Brutto", 100000000000.0)
  else "ERe.Brutto" # Max("ERe.Brutto", -100000000000.0);
  if "ERe.BruttoW1">0.0 then "ERe.BruttoW1" # Min("ERe.BruttoW1", 100000000000.0)
  else "ERe.BruttoW1" # Max("ERe.BruttoW1", -100000000000.0);
  if "ERe.Skonto">0.0 then "ERe.Skonto" # Min("ERe.Skonto", 100000000000.0)
  else "ERe.Skonto" # Max("ERe.Skonto", -100000000000.0);
  if "ERe.SkontoW1">0.0 then "ERe.SkontoW1" # Min("ERe.SkontoW1", 100000000000.0)
  else "ERe.SkontoW1" # Max("ERe.SkontoW1", -100000000000.0);
  if "ERe.Zahlungen">0.0 then "ERe.Zahlungen" # Min("ERe.Zahlungen", 100000000000.0)
  else "ERe.Zahlungen" # Max("ERe.Zahlungen", -100000000000.0);
  if "ERe.ZahlungenW1">0.0 then "ERe.ZahlungenW1" # Min("ERe.ZahlungenW1", 100000000000.0)
  else "ERe.ZahlungenW1" # Max("ERe.ZahlungenW1", -100000000000.0);
  if "ERe.KontiertBetrag">0.0 then "ERe.KontiertBetrag" # Min("ERe.KontiertBetrag", 100000000000.0)
  else "ERe.KontiertBetrag" # Max("ERe.KontiertBetrag", -100000000000.0);
  if "ERe.KontiertBetragW1">0.0 then "ERe.KontiertBetragW1" # Min("ERe.KontiertBetragW1", 100000000000.0)
  else "ERe.KontiertBetragW1" # Max("ERe.KontiertBetragW1", -100000000000.0);
  if "ERe.Kontiert.Gewicht">0.0 then "ERe.Kontiert.Gewicht" # Min("ERe.Kontiert.Gewicht", 100000000000.0)
  else "ERe.Kontiert.Gewicht" # Max("ERe.Kontiert.Gewicht", -100000000000.0);
  if "ERe.KontrollBetrag">0.0 then "ERe.KontrollBetrag" # Min("ERe.KontrollBetrag", 100000000000.0)
  else "ERe.KontrollBetrag" # Max("ERe.KontrollBetrag", -100000000000.0);
  if "ERe.KontrollBetragW1">0.0 then "ERe.KontrollBetragW1" # Min("ERe.KontrollBetragW1", 100000000000.0)
  else "ERe.KontrollBetragW1" # Max("ERe.KontrollBetragW1", -100000000000.0);
  if "ERe.Kontroll.Gewicht">0.0 then "ERe.Kontroll.Gewicht" # Min("ERe.Kontroll.Gewicht", 100000000000.0)
  else "ERe.Kontroll.Gewicht" # Max("ERe.Kontroll.Gewicht", -100000000000.0);
  if "ERe.Rest">0.0 then "ERe.Rest" # Min("ERe.Rest", 100000000000.0)
  else "ERe.Rest" # Max("ERe.Rest", -100000000000.0);
  if "ERe.RestW1">0.0 then "ERe.RestW1" # Min("ERe.RestW1", 100000000000.0)
  else "ERe.RestW1" # Max("ERe.RestW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX561()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0561'
     +cnvai(RecInfo(561,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(561, _recModified);
  if "ERe.Z.Betrag">0.0 then "ERe.Z.Betrag" # Min("ERe.Z.Betrag", 100000000000.0)
  else "ERe.Z.Betrag" # Max("ERe.Z.Betrag", -100000000000.0);
  if "ERe.Z.BetragW1">0.0 then "ERe.Z.BetragW1" # Min("ERe.Z.BetragW1", 100000000000.0)
  else "ERe.Z.BetragW1" # Max("ERe.Z.BetragW1", -100000000000.0);
  GV.Alpha.02 # Bool("ERe.Z.RestSkontoYN");
  if "ERe.Z.Skontobetrag">0.0 then "ERe.Z.Skontobetrag" # Min("ERe.Z.Skontobetrag", 100000000000.0)
  else "ERe.Z.Skontobetrag" # Max("ERe.Z.Skontobetrag", -100000000000.0);
  if "ERe.Z.SkontobetragW1">0.0 then "ERe.Z.SkontobetragW1" # Min("ERe.Z.SkontobetragW1", 100000000000.0)
  else "ERe.Z.SkontobetragW1" # Max("ERe.Z.SkontobetragW1", -100000000000.0);
  GV.Alpha.03 # Datum("ERe.Z.Fibudatum");
end;

// -------------------------------------------------
sub EX565()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0565'
     +cnvai(RecInfo(565,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(565, _recModified);
  if "ZAu.Währungskurs">0.0 then "ZAu.Währungskurs" # Min("ZAu.Währungskurs", 100000000000.0)
  else "ZAu.Währungskurs" # Max("ZAu.Währungskurs", -100000000000.0);
  if "ZAu.Betrag">0.0 then "ZAu.Betrag" # Min("ZAu.Betrag", 100000000000.0)
  else "ZAu.Betrag" # Max("ZAu.Betrag", -100000000000.0);
  if "ZAu.BetragW1">0.0 then "ZAu.BetragW1" # Min("ZAu.BetragW1", 100000000000.0)
  else "ZAu.BetragW1" # Max("ZAu.BetragW1", -100000000000.0);
  GV.Alpha.02 # Datum("ZAu.Codat.Datum");
  if "ZAu.Zugeordnet">0.0 then "ZAu.Zugeordnet" # Min("ZAu.Zugeordnet", 100000000000.0)
  else "ZAu.Zugeordnet" # Max("ZAu.Zugeordnet", -100000000000.0);
  if "ZAu.ZugeordnetW1">0.0 then "ZAu.ZugeordnetW1" # Min("ZAu.ZugeordnetW1", 100000000000.0)
  else "ZAu.ZugeordnetW1" # Max("ZAu.ZugeordnetW1", -100000000000.0);
  GV.Alpha.03 # Datum("ZAu.Zahldatum");
end;

// -------------------------------------------------
sub EX572()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0572'
     +cnvai(RecInfo(572,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(572, _recModified);
  GV.Alpha.02 # Datum("Kas.B.P.Belegdatum");
  if "Kas.B.P.Eingang">0.0 then "Kas.B.P.Eingang" # Min("Kas.B.P.Eingang", 100000000000.0)
  else "Kas.B.P.Eingang" # Max("Kas.B.P.Eingang", -100000000000.0);
  if "Kas.B.P.Ausgang">0.0 then "Kas.B.P.Ausgang" # Min("Kas.B.P.Ausgang", 100000000000.0)
  else "Kas.B.P.Ausgang" # Max("Kas.B.P.Ausgang", -100000000000.0);
  if "Kas.B.P.Steuer">0.0 then "Kas.B.P.Steuer" # Min("Kas.B.P.Steuer", 100000000000.0)
  else "Kas.B.P.Steuer" # Max("Kas.B.P.Steuer", -100000000000.0);
  if "Kas.B.P.Saldo">0.0 then "Kas.B.P.Saldo" # Min("Kas.B.P.Saldo", 100000000000.0)
  else "Kas.B.P.Saldo" # Max("Kas.B.P.Saldo", -100000000000.0);
end;

// -------------------------------------------------
sub EX581()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0581'
     +cnvai(RecInfo(581,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(581, _recModified);
  GV.Alpha.02 # Datum("Kos.Belegdatum");
  GV.Alpha.03 # Datum("Kos.WertstellungsDat");
  if "Kos.NettoW1">0.0 then "Kos.NettoW1" # Min("Kos.NettoW1", 100000000000.0)
  else "Kos.NettoW1" # Max("Kos.NettoW1", -100000000000.0);
  if "Kos.SteuerW1">0.0 then "Kos.SteuerW1" # Min("Kos.SteuerW1", 100000000000.0)
  else "Kos.SteuerW1" # Max("Kos.SteuerW1", -100000000000.0);
  if "Kos.BruttoW1">0.0 then "Kos.BruttoW1" # Min("Kos.BruttoW1", 100000000000.0)
  else "Kos.BruttoW1" # Max("Kos.BruttoW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX601()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0601'
     +cnvai(RecInfo(601,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(601, _recModified);
  if "GPl.P.Gewicht">0.0 then "GPl.P.Gewicht" # Min("GPl.P.Gewicht", 100000000000.0)
  else "GPl.P.Gewicht" # Max("GPl.P.Gewicht", -100000000000.0);
  if "GPl.P.Menge">0.0 then "GPl.P.Menge" # Min("GPl.P.Menge", 100000000000.0)
  else "GPl.P.Menge" # Max("GPl.P.Menge", -100000000000.0);
end;

// -------------------------------------------------
sub EX621()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0621'
     +cnvai(RecInfo(621,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(621, _recModified);
  GV.Alpha.02 # Bool("SWe.P.AvisYN");
  GV.Alpha.03 # Datum("SWe.P.Avis_Datum");
  GV.Alpha.04 # Bool("SWe.P.EingangYN");
  GV.Alpha.05 # Datum("SWe.P.Eingang_Datum");
  GV.Alpha.06 # Bool("SWe.P.AusfallYN");
  GV.Alpha.07 # Datum("SWe.P.Ausfall_Datum");
  if "SWe.P.Preis">0.0 then "SWe.P.Preis" # Min("SWe.P.Preis", 100000000000.0)
  else "SWe.P.Preis" # Max("SWe.P.Preis", -100000000000.0);
  if "SWe.P.PreisW1">0.0 then "SWe.P.PreisW1" # Min("SWe.P.PreisW1", 100000000000.0)
  else "SWe.P.PreisW1" # Max("SWe.P.PreisW1", -100000000000.0);
  if "SWe.P.Menge">0.0 then "SWe.P.Menge" # Min("SWe.P.Menge", 100000000000.0)
  else "SWe.P.Menge" # Max("SWe.P.Menge", -100000000000.0);
  if "SWe.P.Gewicht">0.0 then "SWe.P.Gewicht" # Min("SWe.P.Gewicht", 100000000000.0)
  else "SWe.P.Gewicht" # Max("SWe.P.Gewicht", -100000000000.0);
  GV.Alpha.08 # Bool("SWe.P.GesperrtYN");
  if "SWe.P.Dicke">0.0 then "SWe.P.Dicke" # Min("SWe.P.Dicke", 100000000000.0)
  else "SWe.P.Dicke" # Max("SWe.P.Dicke", -100000000000.0);
  GV.Alpha.09 # Bool("SWe.P.DickenTolYN");
  if "SWe.P.Dicke.Von">0.0 then "SWe.P.Dicke.Von" # Min("SWe.P.Dicke.Von", 100000000000.0)
  else "SWe.P.Dicke.Von" # Max("SWe.P.Dicke.Von", -100000000000.0);
  if "SWe.P.Dicke.Bis">0.0 then "SWe.P.Dicke.Bis" # Min("SWe.P.Dicke.Bis", 100000000000.0)
  else "SWe.P.Dicke.Bis" # Max("SWe.P.Dicke.Bis", -100000000000.0);
  if "SWe.P.Breite">0.0 then "SWe.P.Breite" # Min("SWe.P.Breite", 100000000000.0)
  else "SWe.P.Breite" # Max("SWe.P.Breite", -100000000000.0);
  GV.Alpha.10 # Bool("SWe.P.BreitenTolYN");
  if "SWe.P.Breite.Von">0.0 then "SWe.P.Breite.Von" # Min("SWe.P.Breite.Von", 100000000000.0)
  else "SWe.P.Breite.Von" # Max("SWe.P.Breite.Von", -100000000000.0);
  if "SWe.P.Breite.Bis">0.0 then "SWe.P.Breite.Bis" # Min("SWe.P.Breite.Bis", 100000000000.0)
  else "SWe.P.Breite.Bis" # Max("SWe.P.Breite.Bis", -100000000000.0);
  if "SWe.P.Länge">0.0 then "SWe.P.Länge" # Min("SWe.P.Länge", 100000000000.0)
  else "SWe.P.Länge" # Max("SWe.P.Länge", -100000000000.0);
  GV.Alpha.11 # Bool("SWe.P.LängenTolYN");
  if "SWe.P.Länge.Von">0.0 then "SWe.P.Länge.Von" # Min("SWe.P.Länge.Von", 100000000000.0)
  else "SWe.P.Länge.Von" # Max("SWe.P.Länge.Von", -100000000000.0);
  if "SWe.P.Länge.Bis">0.0 then "SWe.P.Länge.Bis" # Min("SWe.P.Länge.Bis", 100000000000.0)
  else "SWe.P.Länge.Bis" # Max("SWe.P.Länge.Bis", -100000000000.0);
  if "SWe.P.RID">0.0 then "SWe.P.RID" # Min("SWe.P.RID", 100000000000.0)
  else "SWe.P.RID" # Max("SWe.P.RID", -100000000000.0);
  if "SWe.P.RAD">0.0 then "SWe.P.RAD" # Min("SWe.P.RAD", 100000000000.0)
  else "SWe.P.RAD" # Max("SWe.P.RAD", -100000000000.0);
  if "SWe.P.CO2EinstandPT">0.0 then "SWe.P.CO2EinstandPT" # Min("SWe.P.CO2EinstandPT", 100000000000.0)
  else "SWe.P.CO2EinstandPT" # Max("SWe.P.CO2EinstandPT", -100000000000.0);
  if "SWe.P.Gewicht.Netto">0.0 then "SWe.P.Gewicht.Netto" # Min("SWe.P.Gewicht.Netto", 100000000000.0)
  else "SWe.P.Gewicht.Netto" # Max("SWe.P.Gewicht.Netto", -100000000000.0);
  if "SWe.P.Gewicht.Brutto">0.0 then "SWe.P.Gewicht.Brutto" # Min("SWe.P.Gewicht.Brutto", 100000000000.0)
  else "SWe.P.Gewicht.Brutto" # Max("SWe.P.Gewicht.Brutto", -100000000000.0);
  GV.Alpha.12 # Bool("SWe.P.StehendYN");
  GV.Alpha.13 # Bool("SWe.P.LiegendYN");
  if "SWe.P.Nettoabzug">0.0 then "SWe.P.Nettoabzug" # Min("SWe.P.Nettoabzug", 100000000000.0)
  else "SWe.P.Nettoabzug" # Max("SWe.P.Nettoabzug", -100000000000.0);
  if "SWe.P.Stapelhöhe">0.0 then "SWe.P.Stapelhöhe" # Min("SWe.P.Stapelhöhe", 100000000000.0)
  else "SWe.P.Stapelhöhe" # Max("SWe.P.Stapelhöhe", -100000000000.0);
  if "SWe.P.Stapelhöhenabz">0.0 then "SWe.P.Stapelhöhenabz" # Min("SWe.P.Stapelhöhenabz", 100000000000.0)
  else "SWe.P.Stapelhöhenabz" # Max("SWe.P.Stapelhöhenabz", -100000000000.0);
  if "SWe.P.Rechtwinkligk">0.0 then "SWe.P.Rechtwinkligk" # Min("SWe.P.Rechtwinkligk", 100000000000.0)
  else "SWe.P.Rechtwinkligk" # Max("SWe.P.Rechtwinkligk", -100000000000.0);
  if "SWe.P.Ebenheit">0.0 then "SWe.P.Ebenheit" # Min("SWe.P.Ebenheit", 100000000000.0)
  else "SWe.P.Ebenheit" # Max("SWe.P.Ebenheit", -100000000000.0);
  if "SWe.P.Säbeligkeit">0.0 then "SWe.P.Säbeligkeit" # Min("SWe.P.Säbeligkeit", 100000000000.0)
  else "SWe.P.Säbeligkeit" # Max("SWe.P.Säbeligkeit", -100000000000.0);
  if "SWe.P.SäbelProM">0.0 then "SWe.P.SäbelProM" # Min("SWe.P.SäbelProM", 100000000000.0)
  else "SWe.P.SäbelProM" # Max("SWe.P.SäbelProM", -100000000000.0);
  if "SWe.P.Streckgrenze">0.0 then "SWe.P.Streckgrenze" # Min("SWe.P.Streckgrenze", 100000000000.0)
  else "SWe.P.Streckgrenze" # Max("SWe.P.Streckgrenze", -100000000000.0);
  if "SWe.P.Zugfestigkeit">0.0 then "SWe.P.Zugfestigkeit" # Min("SWe.P.Zugfestigkeit", 100000000000.0)
  else "SWe.P.Zugfestigkeit" # Max("SWe.P.Zugfestigkeit", -100000000000.0);
  if "SWe.P.DehnungA">0.0 then "SWe.P.DehnungA" # Min("SWe.P.DehnungA", 100000000000.0)
  else "SWe.P.DehnungA" # Max("SWe.P.DehnungA", -100000000000.0);
  if "SWe.P.DehnungB">0.0 then "SWe.P.DehnungB" # Min("SWe.P.DehnungB", 100000000000.0)
  else "SWe.P.DehnungB" # Max("SWe.P.DehnungB", -100000000000.0);
  if "SWe.P.RP02_1">0.0 then "SWe.P.RP02_1" # Min("SWe.P.RP02_1", 100000000000.0)
  else "SWe.P.RP02_1" # Max("SWe.P.RP02_1", -100000000000.0);
  if "SWe.P.RP10_1">0.0 then "SWe.P.RP10_1" # Min("SWe.P.RP10_1", 100000000000.0)
  else "SWe.P.RP10_1" # Max("SWe.P.RP10_1", -100000000000.0);
  if "SWe.P.Körnung">0.0 then "SWe.P.Körnung" # Min("SWe.P.Körnung", 100000000000.0)
  else "SWe.P.Körnung" # Max("SWe.P.Körnung", -100000000000.0);
  if "SWe.P.Chemie.C">0.0 then "SWe.P.Chemie.C" # Min("SWe.P.Chemie.C", 100000000000.0)
  else "SWe.P.Chemie.C" # Max("SWe.P.Chemie.C", -100000000000.0);
  if "SWe.P.Chemie.Si">0.0 then "SWe.P.Chemie.Si" # Min("SWe.P.Chemie.Si", 100000000000.0)
  else "SWe.P.Chemie.Si" # Max("SWe.P.Chemie.Si", -100000000000.0);
  if "SWe.P.Chemie.Mn">0.0 then "SWe.P.Chemie.Mn" # Min("SWe.P.Chemie.Mn", 100000000000.0)
  else "SWe.P.Chemie.Mn" # Max("SWe.P.Chemie.Mn", -100000000000.0);
  if "SWe.P.Chemie.P">0.0 then "SWe.P.Chemie.P" # Min("SWe.P.Chemie.P", 100000000000.0)
  else "SWe.P.Chemie.P" # Max("SWe.P.Chemie.P", -100000000000.0);
  if "SWe.P.Chemie.S">0.0 then "SWe.P.Chemie.S" # Min("SWe.P.Chemie.S", 100000000000.0)
  else "SWe.P.Chemie.S" # Max("SWe.P.Chemie.S", -100000000000.0);
  if "SWe.P.Chemie.Al">0.0 then "SWe.P.Chemie.Al" # Min("SWe.P.Chemie.Al", 100000000000.0)
  else "SWe.P.Chemie.Al" # Max("SWe.P.Chemie.Al", -100000000000.0);
  if "SWe.P.Chemie.Cr">0.0 then "SWe.P.Chemie.Cr" # Min("SWe.P.Chemie.Cr", 100000000000.0)
  else "SWe.P.Chemie.Cr" # Max("SWe.P.Chemie.Cr", -100000000000.0);
  if "SWe.P.Chemie.V">0.0 then "SWe.P.Chemie.V" # Min("SWe.P.Chemie.V", 100000000000.0)
  else "SWe.P.Chemie.V" # Max("SWe.P.Chemie.V", -100000000000.0);
  if "SWe.P.Chemie.Nb">0.0 then "SWe.P.Chemie.Nb" # Min("SWe.P.Chemie.Nb", 100000000000.0)
  else "SWe.P.Chemie.Nb" # Max("SWe.P.Chemie.Nb", -100000000000.0);
  if "SWe.P.Chemie.Ti">0.0 then "SWe.P.Chemie.Ti" # Min("SWe.P.Chemie.Ti", 100000000000.0)
  else "SWe.P.Chemie.Ti" # Max("SWe.P.Chemie.Ti", -100000000000.0);
  if "SWe.P.Chemie.N">0.0 then "SWe.P.Chemie.N" # Min("SWe.P.Chemie.N", 100000000000.0)
  else "SWe.P.Chemie.N" # Max("SWe.P.Chemie.N", -100000000000.0);
  if "SWe.P.Chemie.Cu">0.0 then "SWe.P.Chemie.Cu" # Min("SWe.P.Chemie.Cu", 100000000000.0)
  else "SWe.P.Chemie.Cu" # Max("SWe.P.Chemie.Cu", -100000000000.0);
  if "SWe.P.Chemie.Ni">0.0 then "SWe.P.Chemie.Ni" # Min("SWe.P.Chemie.Ni", 100000000000.0)
  else "SWe.P.Chemie.Ni" # Max("SWe.P.Chemie.Ni", -100000000000.0);
  if "SWe.P.Chemie.Mo">0.0 then "SWe.P.Chemie.Mo" # Min("SWe.P.Chemie.Mo", 100000000000.0)
  else "SWe.P.Chemie.Mo" # Max("SWe.P.Chemie.Mo", -100000000000.0);
  if "SWe.P.Chemie.B">0.0 then "SWe.P.Chemie.B" # Min("SWe.P.Chemie.B", 100000000000.0)
  else "SWe.P.Chemie.B" # Max("SWe.P.Chemie.B", -100000000000.0);
  if "SWe.P.Härte1">0.0 then "SWe.P.Härte1" # Min("SWe.P.Härte1", 100000000000.0)
  else "SWe.P.Härte1" # Max("SWe.P.Härte1", -100000000000.0);
  if "SWe.P.Chemie.Frei1">0.0 then "SWe.P.Chemie.Frei1" # Min("SWe.P.Chemie.Frei1", 100000000000.0)
  else "SWe.P.Chemie.Frei1" # Max("SWe.P.Chemie.Frei1", -100000000000.0);
  if "SWe.P.Härte2">0.0 then "SWe.P.Härte2" # Min("SWe.P.Härte2", 100000000000.0)
  else "SWe.P.Härte2" # Max("SWe.P.Härte2", -100000000000.0);
  if "SWe.P.RauigkeitA1">0.0 then "SWe.P.RauigkeitA1" # Min("SWe.P.RauigkeitA1", 100000000000.0)
  else "SWe.P.RauigkeitA1" # Max("SWe.P.RauigkeitA1", -100000000000.0);
  if "SWe.P.RauigkeitA2">0.0 then "SWe.P.RauigkeitA2" # Min("SWe.P.RauigkeitA2", 100000000000.0)
  else "SWe.P.RauigkeitA2" # Max("SWe.P.RauigkeitA2", -100000000000.0);
  if "SWe.P.RauigkeitB1">0.0 then "SWe.P.RauigkeitB1" # Min("SWe.P.RauigkeitB1", 100000000000.0)
  else "SWe.P.RauigkeitB1" # Max("SWe.P.RauigkeitB1", -100000000000.0);
  if "SWe.P.RauigkeitB2">0.0 then "SWe.P.RauigkeitB2" # Min("SWe.P.RauigkeitB2", 100000000000.0)
  else "SWe.P.RauigkeitB2" # Max("SWe.P.RauigkeitB2", -100000000000.0);
  if "SWe.P.Streckgrenze2">0.0 then "SWe.P.Streckgrenze2" # Min("SWe.P.Streckgrenze2", 100000000000.0)
  else "SWe.P.Streckgrenze2" # Max("SWe.P.Streckgrenze2", -100000000000.0);
  if "SWe.P.Zugfestigkeit2">0.0 then "SWe.P.Zugfestigkeit2" # Min("SWe.P.Zugfestigkeit2", 100000000000.0)
  else "SWe.P.Zugfestigkeit2" # Max("SWe.P.Zugfestigkeit2", -100000000000.0);
  if "SWe.P.RP02_2">0.0 then "SWe.P.RP02_2" # Min("SWe.P.RP02_2", 100000000000.0)
  else "SWe.P.RP02_2" # Max("SWe.P.RP02_2", -100000000000.0);
  if "SWe.P.RP10_2">0.0 then "SWe.P.RP10_2" # Min("SWe.P.RP10_2", 100000000000.0)
  else "SWe.P.RP10_2" # Max("SWe.P.RP10_2", -100000000000.0);
  if "SWe.P.Körnung2">0.0 then "SWe.P.Körnung2" # Min("SWe.P.Körnung2", 100000000000.0)
  else "SWe.P.Körnung2" # Max("SWe.P.Körnung2", -100000000000.0);
  if "SWe.P.DehnungC">0.0 then "SWe.P.DehnungC" # Min("SWe.P.DehnungC", 100000000000.0)
  else "SWe.P.DehnungC" # Max("SWe.P.DehnungC", -100000000000.0);
end;

// -------------------------------------------------
sub EX650()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0650'
     +cnvai(RecInfo(650,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(650, _recModified);
  GV.Alpha.02 # Datum("Vsd.Datum");
  GV.Alpha.03 # Zeit("Vsd.Zeit");
  if "Vsd.Positionsgewicht">0.0 then "Vsd.Positionsgewicht" # Min("Vsd.Positionsgewicht", 100000000000.0)
  else "Vsd.Positionsgewicht" # Max("Vsd.Positionsgewicht", -100000000000.0);
  if "Vsd.GesamtKostenW1">0.0 then "Vsd.GesamtKostenW1" # Min("Vsd.GesamtKostenW1", 100000000000.0)
  else "Vsd.GesamtKostenW1" # Max("Vsd.GesamtKostenW1", -100000000000.0);
  if "Vsd.Leergewicht">0.0 then "Vsd.Leergewicht" # Min("Vsd.Leergewicht", 100000000000.0)
  else "Vsd.Leergewicht" # Max("Vsd.Leergewicht", -100000000000.0);
  if "Vsd.Gesamtgewicht">0.0 then "Vsd.Gesamtgewicht" # Min("Vsd.Gesamtgewicht", 100000000000.0)
  else "Vsd.Gesamtgewicht" # Max("Vsd.Gesamtgewicht", -100000000000.0);
  GV.Alpha.04 # Datum("Vsd.Datum.Verbucht");
end;

// -------------------------------------------------
sub EX655()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0655'
     +cnvai(RecInfo(655,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(655, _recModified);
  GV.Alpha.02 # Datum("VsP.Termin.MinDat");
  GV.Alpha.03 # Datum("VsP.Termin.MaxDat");
  if "VsP.Menge.In.Soll">0.0 then "VsP.Menge.In.Soll" # Min("VsP.Menge.In.Soll", 100000000000.0)
  else "VsP.Menge.In.Soll" # Max("VsP.Menge.In.Soll", -100000000000.0);
  if "VsP.Menge.In.Ist">0.0 then "VsP.Menge.In.Ist" # Min("VsP.Menge.In.Ist", 100000000000.0)
  else "VsP.Menge.In.Ist" # Max("VsP.Menge.In.Ist", -100000000000.0);
  if "VsP.Menge.In.Rest">0.0 then "VsP.Menge.In.Rest" # Min("VsP.Menge.In.Rest", 100000000000.0)
  else "VsP.Menge.In.Rest" # Max("VsP.Menge.In.Rest", -100000000000.0);
  if "VsP.Menge.Out.Soll">0.0 then "VsP.Menge.Out.Soll" # Min("VsP.Menge.Out.Soll", 100000000000.0)
  else "VsP.Menge.Out.Soll" # Max("VsP.Menge.Out.Soll", -100000000000.0);
  if "VsP.Menge.Out.Ist">0.0 then "VsP.Menge.Out.Ist" # Min("VsP.Menge.Out.Ist", 100000000000.0)
  else "VsP.Menge.Out.Ist" # Max("VsP.Menge.Out.Ist", -100000000000.0);
  if "VsP.Menge.Out.Rest">0.0 then "VsP.Menge.Out.Rest" # Min("VsP.Menge.Out.Rest", 100000000000.0)
  else "VsP.Menge.Out.Rest" # Max("VsP.Menge.Out.Rest", -100000000000.0);
  if "VsP.Gewicht.Soll">0.0 then "VsP.Gewicht.Soll" # Min("VsP.Gewicht.Soll", 100000000000.0)
  else "VsP.Gewicht.Soll" # Max("VsP.Gewicht.Soll", -100000000000.0);
  if "VsP.Gewicht.Ist">0.0 then "VsP.Gewicht.Ist" # Min("VsP.Gewicht.Ist", 100000000000.0)
  else "VsP.Gewicht.Ist" # Max("VsP.Gewicht.Ist", -100000000000.0);
  if "VsP.Gewicht.Rest">0.0 then "VsP.Gewicht.Rest" # Min("VsP.Gewicht.Rest", 100000000000.0)
  else "VsP.Gewicht.Rest" # Max("VsP.Gewicht.Rest", -100000000000.0);
end;

// -------------------------------------------------
sub EX700()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0700'
     +cnvai(RecInfo(700,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.Anlage.Datum");
  GV.Int64.01 # RecInfo(700, _recModified);
  GV.Alpha.03 # Datum("BAG.Fertig.Datum");
  GV.Alpha.04 # Zeit("BAG.Fertig.Zeit");
  if "BAG.PlanKosten">0.0 then "BAG.PlanKosten" # Min("BAG.PlanKosten", 100000000000.0)
  else "BAG.PlanKosten" # Max("BAG.PlanKosten", -100000000000.0);
  if "BAG.PlanZeit">0.0 then "BAG.PlanZeit" # Min("BAG.PlanZeit", 100000000000.0)
  else "BAG.PlanZeit" # Max("BAG.PlanZeit", -100000000000.0);
  GV.Alpha.05 # Bool("BAG.VorlageYN");
  GV.Alpha.06 # Bool("BAG.VorlageSperreYN");
end;

// -------------------------------------------------
sub EX701()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0701'
     +cnvai(RecInfo(701,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.IO.Anlage.Datum");
  GV.Int64.01 # RecInfo(701, _recModified);
  GV.Alpha.03 # Bool("BAG.IO.LöschenYN");
  if "BAG.IO.GesamtKostW1">0.0 then "BAG.IO.GesamtKostW1" # Min("BAG.IO.GesamtKostW1", 100000000000.0)
  else "BAG.IO.GesamtKostW1" # Max("BAG.IO.GesamtKostW1", -100000000000.0);
  GV.Alpha.04 # Bool("BAG.IO.OhneRestYN");
  if "BAG.IO.Dicke">0.0 then "BAG.IO.Dicke" # Min("BAG.IO.Dicke", 100000000000.0)
  else "BAG.IO.Dicke" # Max("BAG.IO.Dicke", -100000000000.0);
  if "BAG.IO.Breite">0.0 then "BAG.IO.Breite" # Min("BAG.IO.Breite", 100000000000.0)
  else "BAG.IO.Breite" # Max("BAG.IO.Breite", -100000000000.0);
  if "BAG.IO.Länge">0.0 then "BAG.IO.Länge" # Min("BAG.IO.Länge", 100000000000.0)
  else "BAG.IO.Länge" # Max("BAG.IO.Länge", -100000000000.0);
  GV.Alpha.05 # Bool("BAG.IO.AutoTeilungYN");
  if "BAG.IO.Plan.In.GewN">0.0 then "BAG.IO.Plan.In.GewN" # Min("BAG.IO.Plan.In.GewN", 100000000000.0)
  else "BAG.IO.Plan.In.GewN" # Max("BAG.IO.Plan.In.GewN", -100000000000.0);
  if "BAG.IO.Plan.In.GewB">0.0 then "BAG.IO.Plan.In.GewB" # Min("BAG.IO.Plan.In.GewB", 100000000000.0)
  else "BAG.IO.Plan.In.GewB" # Max("BAG.IO.Plan.In.GewB", -100000000000.0);
  if "BAG.IO.Plan.In.Menge">0.0 then "BAG.IO.Plan.In.Menge" # Min("BAG.IO.Plan.In.Menge", 100000000000.0)
  else "BAG.IO.Plan.In.Menge" # Max("BAG.IO.Plan.In.Menge", -100000000000.0);
  if "BAG.IO.Plan.Out.GewN">0.0 then "BAG.IO.Plan.Out.GewN" # Min("BAG.IO.Plan.Out.GewN", 100000000000.0)
  else "BAG.IO.Plan.Out.GewN" # Max("BAG.IO.Plan.Out.GewN", -100000000000.0);
  if "BAG.IO.Plan.Out.GewB">0.0 then "BAG.IO.Plan.Out.GewB" # Min("BAG.IO.Plan.Out.GewB", 100000000000.0)
  else "BAG.IO.Plan.Out.GewB" # Max("BAG.IO.Plan.Out.GewB", -100000000000.0);
  if "BAG.IO.Plan.Out.Meng">0.0 then "BAG.IO.Plan.Out.Meng" # Min("BAG.IO.Plan.Out.Meng", 100000000000.0)
  else "BAG.IO.Plan.Out.Meng" # Max("BAG.IO.Plan.Out.Meng", -100000000000.0);
  if "BAG.IO.Ist.In.GewN">0.0 then "BAG.IO.Ist.In.GewN" # Min("BAG.IO.Ist.In.GewN", 100000000000.0)
  else "BAG.IO.Ist.In.GewN" # Max("BAG.IO.Ist.In.GewN", -100000000000.0);
  if "BAG.IO.Ist.In.GewB">0.0 then "BAG.IO.Ist.In.GewB" # Min("BAG.IO.Ist.In.GewB", 100000000000.0)
  else "BAG.IO.Ist.In.GewB" # Max("BAG.IO.Ist.In.GewB", -100000000000.0);
  if "BAG.IO.Ist.In.Menge">0.0 then "BAG.IO.Ist.In.Menge" # Min("BAG.IO.Ist.In.Menge", 100000000000.0)
  else "BAG.IO.Ist.In.Menge" # Max("BAG.IO.Ist.In.Menge", -100000000000.0);
  if "BAG.IO.Ist.Out.GewN">0.0 then "BAG.IO.Ist.Out.GewN" # Min("BAG.IO.Ist.Out.GewN", 100000000000.0)
  else "BAG.IO.Ist.Out.GewN" # Max("BAG.IO.Ist.Out.GewN", -100000000000.0);
  if "BAG.IO.Ist.Out.GewB">0.0 then "BAG.IO.Ist.Out.GewB" # Min("BAG.IO.Ist.Out.GewB", 100000000000.0)
  else "BAG.IO.Ist.Out.GewB" # Max("BAG.IO.Ist.Out.GewB", -100000000000.0);
  if "BAG.IO.Ist.Out.Menge">0.0 then "BAG.IO.Ist.Out.Menge" # Min("BAG.IO.Ist.Out.Menge", 100000000000.0)
  else "BAG.IO.Ist.Out.Menge" # Max("BAG.IO.Ist.Out.Menge", -100000000000.0);
end;

// -------------------------------------------------
sub EX702()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0702'
     +cnvai(RecInfo(702,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.P.Anlage.Datum");
  GV.Int64.01 # RecInfo(702, _recModified);
  GV.Alpha.03 # Bool("BAG.P.ExternYN");
  GV.Alpha.04 # Bool("BAG.P.ZielVerkaufYN");
  GV.Alpha.05 # Bool("BAG.P.Typ.1In-1OutYN");
  GV.Alpha.06 # Bool("BAG.P.Typ.1In-yOutYN");
  GV.Alpha.07 # Bool("BAG.P.Typ.xIn-yOutYN");
  GV.Alpha.08 # Bool("BAG.P.Typ.VSBYN");
  GV.Alpha.09 # Datum("BAG.P.Fenster.MinDat");
  GV.Alpha.10 # Zeit("BAG.P.Fenster.MinZei");
  GV.Alpha.11 # Datum("BAG.P.Fenster.MaxDat");
  GV.Alpha.12 # Zeit("BAG.P.Fenster.MaxZei");
  GV.Alpha.13 # Datum("BAG.P.Plan.StartDat");
  GV.Alpha.14 # Zeit("BAG.P.Plan.StartZeit");
  if "BAG.P.Plan.Dauer">0.0 then "BAG.P.Plan.Dauer" # Min("BAG.P.Plan.Dauer", 100000000000.0)
  else "BAG.P.Plan.Dauer" # Max("BAG.P.Plan.Dauer", -100000000000.0);
  GV.Alpha.15 # Datum("BAG.P.Plan.EndDat");
  GV.Alpha.16 # Zeit("BAG.P.Plan.EndZeit");
  GV.Alpha.17 # Datum("BAG.P.Fertig.Dat");
  GV.Alpha.18 # Zeit("BAG.P.Fertig.Zeit");
  if "BAG.P.Plan.DauerPost">0.0 then "BAG.P.Plan.DauerPost" # Min("BAG.P.Plan.DauerPost", 100000000000.0)
  else "BAG.P.Plan.DauerPost" # Max("BAG.P.Plan.DauerPost", -100000000000.0);
  GV.Alpha.19 # Bool("BAG.P.Plan.ManuellYN");
  if "BAG.P.Plan.DauerPst2">0.0 then "BAG.P.Plan.DauerPst2" # Min("BAG.P.Plan.DauerPst2", 100000000000.0)
  else "BAG.P.Plan.DauerPst2" # Max("BAG.P.Plan.DauerPst2", -100000000000.0);
  if "BAG.P.Kosten.Fix">0.0 then "BAG.P.Kosten.Fix" # Min("BAG.P.Kosten.Fix", 100000000000.0)
  else "BAG.P.Kosten.Fix" # Max("BAG.P.Kosten.Fix", -100000000000.0);
  if "BAG.P.Kosten.Pro">0.0 then "BAG.P.Kosten.Pro" # Min("BAG.P.Kosten.Pro", 100000000000.0)
  else "BAG.P.Kosten.Pro" # Max("BAG.P.Kosten.Pro", -100000000000.0);
  if "BAG.P.Kosten.Gesamt">0.0 then "BAG.P.Kosten.Gesamt" # Min("BAG.P.Kosten.Gesamt", 100000000000.0)
  else "BAG.P.Kosten.Gesamt" # Max("BAG.P.Kosten.Gesamt", -100000000000.0);
  if "BAG.P.Kosten.Ges.Gew">0.0 then "BAG.P.Kosten.Ges.Gew" # Min("BAG.P.Kosten.Ges.Gew", 100000000000.0)
  else "BAG.P.Kosten.Ges.Gew" # Max("BAG.P.Kosten.Ges.Gew", -100000000000.0);
  if "BAG.P.Kosten.Ges.Men">0.0 then "BAG.P.Kosten.Ges.Men" # Min("BAG.P.Kosten.Ges.Men", 100000000000.0)
  else "BAG.P.Kosten.Ges.Men" # Max("BAG.P.Kosten.Ges.Men", -100000000000.0);
  if "BAG.P.Kosten.CO2">0.0 then "BAG.P.Kosten.CO2" # Min("BAG.P.Kosten.CO2", 100000000000.0)
  else "BAG.P.Kosten.CO2" # Max("BAG.P.Kosten.CO2", -100000000000.0);
end;

// -------------------------------------------------
sub EX703()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0703'
     +cnvai(RecInfo(703,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.F.Anlage.Datum");
  GV.Int64.01 # RecInfo(703, _recModified);
  GV.Alpha.03 # Bool("BAG.F.KostenträgerYN");
  GV.Alpha.04 # Bool("BAG.F.ReservierenYN");
  if "BAG.F.Gewicht">0.0 then "BAG.F.Gewicht" # Min("BAG.F.Gewicht", 100000000000.0)
  else "BAG.F.Gewicht" # Max("BAG.F.Gewicht", -100000000000.0);
  if "BAG.F.Menge">0.0 then "BAG.F.Menge" # Min("BAG.F.Menge", 100000000000.0)
  else "BAG.F.Menge" # Max("BAG.F.Menge", -100000000000.0);
  if "BAG.F.Fertig.Gew">0.0 then "BAG.F.Fertig.Gew" # Min("BAG.F.Fertig.Gew", 100000000000.0)
  else "BAG.F.Fertig.Gew" # Max("BAG.F.Fertig.Gew", -100000000000.0);
  if "BAG.F.Fertig.Menge">0.0 then "BAG.F.Fertig.Menge" # Min("BAG.F.Fertig.Menge", 100000000000.0)
  else "BAG.F.Fertig.Menge" # Max("BAG.F.Fertig.Menge", -100000000000.0);
  GV.Alpha.05 # Bool("BAG.F.AutomatischYN");
  GV.Alpha.06 # Bool("BAG.F.PlanSchrottYN");
  GV.Alpha.07 # Bool("BAG.F.WirdEigenYN");
  if "BAG.F.Dicke">0.0 then "BAG.F.Dicke" # Min("BAG.F.Dicke", 100000000000.0)
  else "BAG.F.Dicke" # Max("BAG.F.Dicke", -100000000000.0);
  if "BAG.F.Dickentol.Von">0.0 then "BAG.F.Dickentol.Von" # Min("BAG.F.Dickentol.Von", 100000000000.0)
  else "BAG.F.Dickentol.Von" # Max("BAG.F.Dickentol.Von", -100000000000.0);
  if "BAG.F.Dickentol.Bis">0.0 then "BAG.F.Dickentol.Bis" # Min("BAG.F.Dickentol.Bis", 100000000000.0)
  else "BAG.F.Dickentol.Bis" # Max("BAG.F.Dickentol.Bis", -100000000000.0);
  if "BAG.F.Breite">0.0 then "BAG.F.Breite" # Min("BAG.F.Breite", 100000000000.0)
  else "BAG.F.Breite" # Max("BAG.F.Breite", -100000000000.0);
  if "BAG.F.Breitentol.Von">0.0 then "BAG.F.Breitentol.Von" # Min("BAG.F.Breitentol.Von", 100000000000.0)
  else "BAG.F.Breitentol.Von" # Max("BAG.F.Breitentol.Von", -100000000000.0);
  if "BAG.F.Breitentol.Bis">0.0 then "BAG.F.Breitentol.Bis" # Min("BAG.F.Breitentol.Bis", 100000000000.0)
  else "BAG.F.Breitentol.Bis" # Max("BAG.F.Breitentol.Bis", -100000000000.0);
  if "BAG.F.Länge">0.0 then "BAG.F.Länge" # Min("BAG.F.Länge", 100000000000.0)
  else "BAG.F.Länge" # Max("BAG.F.Länge", -100000000000.0);
  if "BAG.F.Längentol.Von">0.0 then "BAG.F.Längentol.Von" # Min("BAG.F.Längentol.Von", 100000000000.0)
  else "BAG.F.Längentol.Von" # Max("BAG.F.Längentol.Von", -100000000000.0);
  if "BAG.F.Längentol.Bis">0.0 then "BAG.F.Längentol.Bis" # Min("BAG.F.Längentol.Bis", 100000000000.0)
  else "BAG.F.Längentol.Bis" # Max("BAG.F.Längentol.Bis", -100000000000.0);
  if "BAG.F.RID">0.0 then "BAG.F.RID" # Min("BAG.F.RID", 100000000000.0)
  else "BAG.F.RID" # Max("BAG.F.RID", -100000000000.0);
  if "BAG.F.RIDMax">0.0 then "BAG.F.RIDMax" # Min("BAG.F.RIDMax", 100000000000.0)
  else "BAG.F.RIDMax" # Max("BAG.F.RIDMax", -100000000000.0);
  if "BAG.F.RAD">0.0 then "BAG.F.RAD" # Min("BAG.F.RAD", 100000000000.0)
  else "BAG.F.RAD" # Max("BAG.F.RAD", -100000000000.0);
  if "BAG.F.RADMax">0.0 then "BAG.F.RADMax" # Min("BAG.F.RADMax", 100000000000.0)
  else "BAG.F.RADMax" # Max("BAG.F.RADMax", -100000000000.0);
  if "BAG.F.Etk.Dicke">0.0 then "BAG.F.Etk.Dicke" # Min("BAG.F.Etk.Dicke", 100000000000.0)
  else "BAG.F.Etk.Dicke" # Max("BAG.F.Etk.Dicke", -100000000000.0);
  if "BAG.F.Etk.Breite">0.0 then "BAG.F.Etk.Breite" # Min("BAG.F.Etk.Breite", 100000000000.0)
  else "BAG.F.Etk.Breite" # Max("BAG.F.Etk.Breite", -100000000000.0);
  if "BAG.F.Etk.Länge">0.0 then "BAG.F.Etk.Länge" # Min("BAG.F.Etk.Länge", 100000000000.0)
  else "BAG.F.Etk.Länge" # Max("BAG.F.Etk.Länge", -100000000000.0);
  GV.Alpha.08 # Bool("BAG.F.BesäumenYN");
  GV.Alpha.09 # Bool("BAG.F.ResttafelYN");
  if "BAG.F.Glühtemperatur">0.0 then "BAG.F.Glühtemperatur" # Min("BAG.F.Glühtemperatur", 100000000000.0)
  else "BAG.F.Glühtemperatur" # Max("BAG.F.Glühtemperatur", -100000000000.0);
  if "BAG.F.Glühstandzeit">0.0 then "BAG.F.Glühstandzeit" # Min("BAG.F.Glühstandzeit", 100000000000.0)
  else "BAG.F.Glühstandzeit" # Max("BAG.F.Glühstandzeit", -100000000000.0);
  if "BAG.F.Spulbreite">0.0 then "BAG.F.Spulbreite" # Min("BAG.F.Spulbreite", 100000000000.0)
  else "BAG.F.Spulbreite" # Max("BAG.F.Spulbreite", -100000000000.0);
end;

// -------------------------------------------------
sub EX704()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0704'
     +cnvai(RecInfo(704,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(704, _recModified);
  GV.Alpha.02 # Bool("BAG.Vpg.StehendYN");
  GV.Alpha.03 # Bool("BAG.Vpg.LiegendYN");
  if "BAG.Vpg.Nettoabzug">0.0 then "BAG.Vpg.Nettoabzug" # Min("BAG.Vpg.Nettoabzug", 100000000000.0)
  else "BAG.Vpg.Nettoabzug" # Max("BAG.Vpg.Nettoabzug", -100000000000.0);
  if "BAG.Vpg.Stapelhöhe">0.0 then "BAG.Vpg.Stapelhöhe" # Min("BAG.Vpg.Stapelhöhe", 100000000000.0)
  else "BAG.Vpg.Stapelhöhe" # Max("BAG.Vpg.Stapelhöhe", -100000000000.0);
  if "BAG.Vpg.StapelHAbzug">0.0 then "BAG.Vpg.StapelHAbzug" # Min("BAG.Vpg.StapelHAbzug", 100000000000.0)
  else "BAG.Vpg.StapelHAbzug" # Max("BAG.Vpg.StapelHAbzug", -100000000000.0);
  if "BAG.Vpg.RingkgVon">0.0 then "BAG.Vpg.RingkgVon" # Min("BAG.Vpg.RingkgVon", 100000000000.0)
  else "BAG.Vpg.RingkgVon" # Max("BAG.Vpg.RingkgVon", -100000000000.0);
  if "BAG.Vpg.RingkgBis">0.0 then "BAG.Vpg.RingkgBis" # Min("BAG.Vpg.RingkgBis", 100000000000.0)
  else "BAG.Vpg.RingkgBis" # Max("BAG.Vpg.RingkgBis", -100000000000.0);
  if "BAG.Vpg.KgmmVon">0.0 then "BAG.Vpg.KgmmVon" # Min("BAG.Vpg.KgmmVon", 100000000000.0)
  else "BAG.Vpg.KgmmVon" # Max("BAG.Vpg.KgmmVon", -100000000000.0);
  if "BAG.Vpg.KgmmBis">0.0 then "BAG.Vpg.KgmmBis" # Min("BAG.Vpg.KgmmBis", 100000000000.0)
  else "BAG.Vpg.KgmmBis" # Max("BAG.Vpg.KgmmBis", -100000000000.0);
  if "BAG.Vpg.VEkgMax">0.0 then "BAG.Vpg.VEkgMax" # Min("BAG.Vpg.VEkgMax", 100000000000.0)
  else "BAG.Vpg.VEkgMax" # Max("BAG.Vpg.VEkgMax", -100000000000.0);
  if "BAG.Vpg.RechtwinkMax">0.0 then "BAG.Vpg.RechtwinkMax" # Min("BAG.Vpg.RechtwinkMax", 100000000000.0)
  else "BAG.Vpg.RechtwinkMax" # Max("BAG.Vpg.RechtwinkMax", -100000000000.0);
  if "BAG.Vpg.EbenheitMax">0.0 then "BAG.Vpg.EbenheitMax" # Min("BAG.Vpg.EbenheitMax", 100000000000.0)
  else "BAG.Vpg.EbenheitMax" # Max("BAG.Vpg.EbenheitMax", -100000000000.0);
  if "BAG.Vpg.SäbeligMax">0.0 then "BAG.Vpg.SäbeligMax" # Min("BAG.Vpg.SäbeligMax", 100000000000.0)
  else "BAG.Vpg.SäbeligMax" # Max("BAG.Vpg.SäbeligMax", -100000000000.0);
  if "BAG.Vpg.SäbelProM">0.0 then "BAG.Vpg.SäbelProM" # Min("BAG.Vpg.SäbelProM", 100000000000.0)
  else "BAG.Vpg.SäbelProM" # Max("BAG.Vpg.SäbelProM", -100000000000.0);
end;

// -------------------------------------------------
sub EX705()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0705'
     +cnvai(RecInfo(705,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(705, _recModified);
end;

// -------------------------------------------------
sub EX706()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0706'
     +cnvai(RecInfo(706,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(706, _recModified);
  if "BAG.AS.Dicke.Soll">0.0 then "BAG.AS.Dicke.Soll" # Min("BAG.AS.Dicke.Soll", 100000000000.0)
  else "BAG.AS.Dicke.Soll" # Max("BAG.AS.Dicke.Soll", -100000000000.0);
  if "BAG.AS.Dicke.Ist">0.0 then "BAG.AS.Dicke.Ist" # Min("BAG.AS.Dicke.Ist", 100000000000.0)
  else "BAG.AS.Dicke.Ist" # Max("BAG.AS.Dicke.Ist", -100000000000.0);
  GV.Alpha.02 # Datum("BAG.AS.Termin");
  GV.Alpha.03 # Zeit("BAG.AS.Zeit");
  if "BAG.AS.Dauer">0.0 then "BAG.AS.Dauer" # Min("BAG.AS.Dauer", 100000000000.0)
  else "BAG.AS.Dauer" # Max("BAG.AS.Dauer", -100000000000.0);
end;

// -------------------------------------------------
sub EX707()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0707'
     +cnvai(RecInfo(707,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.FM.Anlage.Datum");
  GV.Int64.01 # RecInfo(707, _recModified);
  if "BAG.FM.Menge">0.0 then "BAG.FM.Menge" # Min("BAG.FM.Menge", 100000000000.0)
  else "BAG.FM.Menge" # Max("BAG.FM.Menge", -100000000000.0);
  if "BAG.FM.Gewicht.Netto">0.0 then "BAG.FM.Gewicht.Netto" # Min("BAG.FM.Gewicht.Netto", 100000000000.0)
  else "BAG.FM.Gewicht.Netto" # Max("BAG.FM.Gewicht.Netto", -100000000000.0);
  if "BAG.FM.Gewicht.Brutt">0.0 then "BAG.FM.Gewicht.Brutt" # Min("BAG.FM.Gewicht.Brutt", 100000000000.0)
  else "BAG.FM.Gewicht.Brutt" # Max("BAG.FM.Gewicht.Brutt", -100000000000.0);
  GV.Alpha.03 # Datum("BAG.FM.Datum");
  if "BAG.FM.Menge2">0.0 then "BAG.FM.Menge2" # Min("BAG.FM.Menge2", 100000000000.0)
  else "BAG.FM.Menge2" # Max("BAG.FM.Menge2", -100000000000.0);
  GV.Alpha.04 # Bool("BAG.FM.UnverbuchtYN");
  GV.Alpha.05 # Zeit("BAG.FM.Zeit");
  if "BAG.FM.Dicke">0.0 then "BAG.FM.Dicke" # Min("BAG.FM.Dicke", 100000000000.0)
  else "BAG.FM.Dicke" # Max("BAG.FM.Dicke", -100000000000.0);
  if "BAG.FM.Dicke.1">0.0 then "BAG.FM.Dicke.1" # Min("BAG.FM.Dicke.1", 100000000000.0)
  else "BAG.FM.Dicke.1" # Max("BAG.FM.Dicke.1", -100000000000.0);
  if "BAG.FM.Breite">0.0 then "BAG.FM.Breite" # Min("BAG.FM.Breite", 100000000000.0)
  else "BAG.FM.Breite" # Max("BAG.FM.Breite", -100000000000.0);
  if "BAG.FM.Breite.1">0.0 then "BAG.FM.Breite.1" # Min("BAG.FM.Breite.1", 100000000000.0)
  else "BAG.FM.Breite.1" # Max("BAG.FM.Breite.1", -100000000000.0);
  if "BAG.FM.Länge">0.0 then "BAG.FM.Länge" # Min("BAG.FM.Länge", 100000000000.0)
  else "BAG.FM.Länge" # Max("BAG.FM.Länge", -100000000000.0);
  if "BAG.FM.Länge.1">0.0 then "BAG.FM.Länge.1" # Min("BAG.FM.Länge.1", 100000000000.0)
  else "BAG.FM.Länge.1" # Max("BAG.FM.Länge.1", -100000000000.0);
  if "BAG.FM.Rechtwinklig">0.0 then "BAG.FM.Rechtwinklig" # Min("BAG.FM.Rechtwinklig", 100000000000.0)
  else "BAG.FM.Rechtwinklig" # Max("BAG.FM.Rechtwinklig", -100000000000.0);
  if "BAG.FM.Ebenheit">0.0 then "BAG.FM.Ebenheit" # Min("BAG.FM.Ebenheit", 100000000000.0)
  else "BAG.FM.Ebenheit" # Max("BAG.FM.Ebenheit", -100000000000.0);
  if "BAG.FM.Säbeligkeit">0.0 then "BAG.FM.Säbeligkeit" # Min("BAG.FM.Säbeligkeit", 100000000000.0)
  else "BAG.FM.Säbeligkeit" # Max("BAG.FM.Säbeligkeit", -100000000000.0);
  if "BAG.FM.Dicke.2">0.0 then "BAG.FM.Dicke.2" # Min("BAG.FM.Dicke.2", 100000000000.0)
  else "BAG.FM.Dicke.2" # Max("BAG.FM.Dicke.2", -100000000000.0);
  if "BAG.FM.Breite.2">0.0 then "BAG.FM.Breite.2" # Min("BAG.FM.Breite.2", 100000000000.0)
  else "BAG.FM.Breite.2" # Max("BAG.FM.Breite.2", -100000000000.0);
  if "BAG.FM.Länge.2">0.0 then "BAG.FM.Länge.2" # Min("BAG.FM.Länge.2", 100000000000.0)
  else "BAG.FM.Länge.2" # Max("BAG.FM.Länge.2", -100000000000.0);
  if "BAG.FM.Grat.1">0.0 then "BAG.FM.Grat.1" # Min("BAG.FM.Grat.1", 100000000000.0)
  else "BAG.FM.Grat.1" # Max("BAG.FM.Grat.1", -100000000000.0);
  if "BAG.FM.Grat.2">0.0 then "BAG.FM.Grat.2" # Min("BAG.FM.Grat.2", 100000000000.0)
  else "BAG.FM.Grat.2" # Max("BAG.FM.Grat.2", -100000000000.0);
  if "BAG.FM.Grat.3">0.0 then "BAG.FM.Grat.3" # Min("BAG.FM.Grat.3", 100000000000.0)
  else "BAG.FM.Grat.3" # Max("BAG.FM.Grat.3", -100000000000.0);
  if "BAG.FM.Dicke.3">0.0 then "BAG.FM.Dicke.3" # Min("BAG.FM.Dicke.3", 100000000000.0)
  else "BAG.FM.Dicke.3" # Max("BAG.FM.Dicke.3", -100000000000.0);
  if "BAG.FM.Breite.3">0.0 then "BAG.FM.Breite.3" # Min("BAG.FM.Breite.3", 100000000000.0)
  else "BAG.FM.Breite.3" # Max("BAG.FM.Breite.3", -100000000000.0);
  if "BAG.FM.Länge.3">0.0 then "BAG.FM.Länge.3" # Min("BAG.FM.Länge.3", 100000000000.0)
  else "BAG.FM.Länge.3" # Max("BAG.FM.Länge.3", -100000000000.0);
  GV.Alpha.06 # Bool("BAG.FM.ResttafelYN");
  if "BAG.FM.RAD">0.0 then "BAG.FM.RAD" # Min("BAG.FM.RAD", 100000000000.0)
  else "BAG.FM.RAD" # Max("BAG.FM.RAD", -100000000000.0);
  if "BAG.FM.RID">0.0 then "BAG.FM.RID" # Min("BAG.FM.RID", 100000000000.0)
  else "BAG.FM.RID" # Max("BAG.FM.RID", -100000000000.0);
  if "BAG.FM.SäbelProM">0.0 then "BAG.FM.SäbelProM" # Min("BAG.FM.SäbelProM", 100000000000.0)
  else "BAG.FM.SäbelProM" # Max("BAG.FM.SäbelProM", -100000000000.0);
  if "BAG.FM.Spulbreite">0.0 then "BAG.FM.Spulbreite" # Min("BAG.FM.Spulbreite", 100000000000.0)
  else "BAG.FM.Spulbreite" # Max("BAG.FM.Spulbreite", -100000000000.0);
end;

// -------------------------------------------------
sub EX709()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0709'
     +cnvai(RecInfo(709,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.Z.Anlage.Datum");
  GV.Int64.01 # RecInfo(709, _recModified);
  GV.Alpha.03 # Datum("BAG.Z.Startdatum");
  GV.Alpha.04 # Zeit("BAG.Z.Startzeit");
  GV.Alpha.05 # Datum("BAG.Z.EndDatum");
  GV.Alpha.06 # Zeit("BAG.Z.Endzeit");
  if "BAG.Z.Dauer">0.0 then "BAG.Z.Dauer" # Min("BAG.Z.Dauer", 100000000000.0)
  else "BAG.Z.Dauer" # Max("BAG.Z.Dauer", -100000000000.0);
  if "BAG.Z.Faktor">0.0 then "BAG.Z.Faktor" # Min("BAG.Z.Faktor", 100000000000.0)
  else "BAG.Z.Faktor" # Max("BAG.Z.Faktor", -100000000000.0);
  if "BAG.Z.GesamtkostenW1">0.0 then "BAG.Z.GesamtkostenW1" # Min("BAG.Z.GesamtkostenW1", 100000000000.0)
  else "BAG.Z.GesamtkostenW1" # Max("BAG.Z.GesamtkostenW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX711()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0711'
     +cnvai(RecInfo(711,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Alpha.02 # Datum("BAG.PZ.Anlage.Datum");
  GV.Int64.01 # RecInfo(711, _recModified);
end;

// -------------------------------------------------
sub EX800()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0800'
     +cnvai(RecInfo(800,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(800, _recModified);
  GV.Alpha.02 # Bool("Usr.TapiYN");
  GV.Alpha.03 # Bool("Usr.NotifierYN");
  GV.Alpha.04 # Bool("Usr.TapiIncPopUpYN");
  GV.Alpha.05 # Bool("Usr.TapiIncMsgYN");
  GV.Alpha.06 # Bool("Usr.OutlookYN");
  GV.Alpha.07 # Bool("Usr.DeaktiviertYN");
  GV.Alpha.08 # Datum("Usr.VertretungVonDat");
  GV.Alpha.09 # Datum("Usr.VertretungBisDat");
  GV.Alpha.10 # Datum("Usr.lastLogin.Dat");
  GV.Alpha.11 # Zeit("Usr.lastLogin.Zeit");
end;

// -------------------------------------------------
sub EX810()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0810'
     +cnvai(RecInfo(810,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(810, _recModified);
end;

// -------------------------------------------------
sub EX812()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0812'
     +cnvai(RecInfo(812,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(812, _recModified);
end;

// -------------------------------------------------
sub EX813()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0813'
     +cnvai(RecInfo(813,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(813, _recModified);
  if "StS.Prozent">0.0 then "StS.Prozent" # Min("StS.Prozent", 100000000000.0)
  else "StS.Prozent" # Max("StS.Prozent", -100000000000.0);
  GV.Alpha.02 # Bool("StS.UStIDPflichtYN");
end;

// -------------------------------------------------
sub EX815()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0815'
     +cnvai(RecInfo(815,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(815, _recModified);
end;

// -------------------------------------------------
sub EX816()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0816'
     +cnvai(RecInfo(816,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(816, _recModified);
  GV.Alpha.02 # Bool("ZaB.IndividuellYN");
  GV.Alpha.03 # Bool("ZaB.SperreYN");
  GV.Alpha.04 # Bool("ZaB.abRechDatumYN");
  GV.Alpha.05 # Bool("ZaB.abLFSDatumYN");
  if "ZaB.Sknt1.Prozent">0.0 then "ZaB.Sknt1.Prozent" # Min("ZaB.Sknt1.Prozent", 100000000000.0)
  else "ZaB.Sknt1.Prozent" # Max("ZaB.Sknt1.Prozent", -100000000000.0);
  GV.Alpha.06 # Bool("ZaB.Sknt1.VorZielYN");
  if "ZaB.Sknt2.Prozent">0.0 then "ZaB.Sknt2.Prozent" # Min("ZaB.Sknt2.Prozent", 100000000000.0)
  else "ZaB.Sknt2.Prozent" # Max("ZaB.Sknt2.Prozent", -100000000000.0);
  GV.Alpha.07 # Bool("ZaB.Sknt2.VorZielYN");
  GV.Alpha.08 # Bool("ZaB.FixImAuftragYN");
  GV.Alpha.09 # Bool("ZaB.SperreNeuYN");
end;

// -------------------------------------------------
sub EX817()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0817'
     +cnvai(RecInfo(817,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(817, _recModified);
end;

// -------------------------------------------------
sub EX819()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0819'
     +cnvai(RecInfo(819,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(819, _recModified);
  if "Wgr.Dichte">0.0 then "Wgr.Dichte" # Min("Wgr.Dichte", 100000000000.0)
  else "Wgr.Dichte" # Max("Wgr.Dichte", -100000000000.0);
  if "Wgr.TränenKGproQM">0.0 then "Wgr.TränenKGproQM" # Min("Wgr.TränenKGproQM", 100000000000.0)
  else "Wgr.TränenKGproQM" # Max("Wgr.TränenKGproQM", -100000000000.0);
  GV.Alpha.02 # Bool("Wgr.OhneBestandYN");
end;

// -------------------------------------------------
sub EX820()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0820'
     +cnvai(RecInfo(820,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(820, _recModified);
  GV.Alpha.02 # Bool("Mat.Sta.GesperrtYN");
end;

// -------------------------------------------------
sub EX821()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0821'
     +cnvai(RecInfo(821,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(821, _recModified);
end;

// -------------------------------------------------
sub EX826()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0826'
     +cnvai(RecInfo(826,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(826, _recModified);
end;

// -------------------------------------------------
sub EX828()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0828'
     +cnvai(RecInfo(828,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(828, _recModified);
  GV.Alpha.02 # Bool("ArG.Typ.1In-1OutYN");
  GV.Alpha.03 # Bool("ArG.Typ.1In-yOutYN");
  GV.Alpha.04 # Bool("ArG.Typ.xIn-yOutYN");
  GV.Alpha.05 # Bool("ArG.Typ.VSBYN");
  GV.Alpha.06 # Bool("ArG.ClearMechanik2");
  GV.Alpha.07 # Bool("ArG.TauscheInOutYN");
end;

// -------------------------------------------------
sub EX831()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0831'
     +cnvai(RecInfo(831,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(831, _recModified);
  GV.Alpha.02 # Datum("Kal.P.Termin");
  if "Kal.P.Menge">0.0 then "Kal.P.Menge" # Min("Kal.P.Menge", 100000000000.0)
  else "Kal.P.Menge" # Max("Kal.P.Menge", -100000000000.0);
  GV.Alpha.03 # Bool("Kal.P.MengenbezugYN");
  if "Kal.P.PreisW1">0.0 then "Kal.P.PreisW1" # Min("Kal.P.PreisW1", 100000000000.0)
  else "Kal.P.PreisW1" # Max("Kal.P.PreisW1", -100000000000.0);
  GV.Alpha.04 # Bool("Kal.P.RückstellungYN");
  GV.Alpha.05 # Bool("Kal.P.EinsatzmengeYN");
end;

// -------------------------------------------------
sub EX832()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0832'
     +cnvai(RecInfo(832,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(832, _recModified);
  if "MQu.Dichte">0.0 then "MQu.Dichte" # Min("MQu.Dichte", 100000000000.0)
  else "MQu.Dichte" # Max("MQu.Dichte", -100000000000.0);
  if "MQu.ChemieVon.C">0.0 then "MQu.ChemieVon.C" # Min("MQu.ChemieVon.C", 100000000000.0)
  else "MQu.ChemieVon.C" # Max("MQu.ChemieVon.C", -100000000000.0);
  if "MQu.ChemieBis.C">0.0 then "MQu.ChemieBis.C" # Min("MQu.ChemieBis.C", 100000000000.0)
  else "MQu.ChemieBis.C" # Max("MQu.ChemieBis.C", -100000000000.0);
  if "MQu.ChemieVon.Si">0.0 then "MQu.ChemieVon.Si" # Min("MQu.ChemieVon.Si", 100000000000.0)
  else "MQu.ChemieVon.Si" # Max("MQu.ChemieVon.Si", -100000000000.0);
  if "MQu.ChemieBis.Si">0.0 then "MQu.ChemieBis.Si" # Min("MQu.ChemieBis.Si", 100000000000.0)
  else "MQu.ChemieBis.Si" # Max("MQu.ChemieBis.Si", -100000000000.0);
  if "MQu.ChemieVon.Mn">0.0 then "MQu.ChemieVon.Mn" # Min("MQu.ChemieVon.Mn", 100000000000.0)
  else "MQu.ChemieVon.Mn" # Max("MQu.ChemieVon.Mn", -100000000000.0);
  if "MQu.ChemieBis.Mn">0.0 then "MQu.ChemieBis.Mn" # Min("MQu.ChemieBis.Mn", 100000000000.0)
  else "MQu.ChemieBis.Mn" # Max("MQu.ChemieBis.Mn", -100000000000.0);
  if "MQu.ChemieVon.P">0.0 then "MQu.ChemieVon.P" # Min("MQu.ChemieVon.P", 100000000000.0)
  else "MQu.ChemieVon.P" # Max("MQu.ChemieVon.P", -100000000000.0);
  if "MQu.ChemieBis.P">0.0 then "MQu.ChemieBis.P" # Min("MQu.ChemieBis.P", 100000000000.0)
  else "MQu.ChemieBis.P" # Max("MQu.ChemieBis.P", -100000000000.0);
  if "MQu.ChemieVon.S">0.0 then "MQu.ChemieVon.S" # Min("MQu.ChemieVon.S", 100000000000.0)
  else "MQu.ChemieVon.S" # Max("MQu.ChemieVon.S", -100000000000.0);
  if "MQu.ChemieBis.S">0.0 then "MQu.ChemieBis.S" # Min("MQu.ChemieBis.S", 100000000000.0)
  else "MQu.ChemieBis.S" # Max("MQu.ChemieBis.S", -100000000000.0);
  if "MQu.ChemieVon.Al">0.0 then "MQu.ChemieVon.Al" # Min("MQu.ChemieVon.Al", 100000000000.0)
  else "MQu.ChemieVon.Al" # Max("MQu.ChemieVon.Al", -100000000000.0);
  if "MQu.ChemieBis.Al">0.0 then "MQu.ChemieBis.Al" # Min("MQu.ChemieBis.Al", 100000000000.0)
  else "MQu.ChemieBis.Al" # Max("MQu.ChemieBis.Al", -100000000000.0);
  if "MQu.ChemieVon.Cr">0.0 then "MQu.ChemieVon.Cr" # Min("MQu.ChemieVon.Cr", 100000000000.0)
  else "MQu.ChemieVon.Cr" # Max("MQu.ChemieVon.Cr", -100000000000.0);
  if "MQu.ChemieBis.Cr">0.0 then "MQu.ChemieBis.Cr" # Min("MQu.ChemieBis.Cr", 100000000000.0)
  else "MQu.ChemieBis.Cr" # Max("MQu.ChemieBis.Cr", -100000000000.0);
  if "MQu.ChemieVon.V">0.0 then "MQu.ChemieVon.V" # Min("MQu.ChemieVon.V", 100000000000.0)
  else "MQu.ChemieVon.V" # Max("MQu.ChemieVon.V", -100000000000.0);
  if "MQu.ChemieBis.V">0.0 then "MQu.ChemieBis.V" # Min("MQu.ChemieBis.V", 100000000000.0)
  else "MQu.ChemieBis.V" # Max("MQu.ChemieBis.V", -100000000000.0);
  if "MQu.ChemieVon.Nb">0.0 then "MQu.ChemieVon.Nb" # Min("MQu.ChemieVon.Nb", 100000000000.0)
  else "MQu.ChemieVon.Nb" # Max("MQu.ChemieVon.Nb", -100000000000.0);
  if "MQu.ChemieBis.Nb">0.0 then "MQu.ChemieBis.Nb" # Min("MQu.ChemieBis.Nb", 100000000000.0)
  else "MQu.ChemieBis.Nb" # Max("MQu.ChemieBis.Nb", -100000000000.0);
  if "MQu.ChemieVon.Ti">0.0 then "MQu.ChemieVon.Ti" # Min("MQu.ChemieVon.Ti", 100000000000.0)
  else "MQu.ChemieVon.Ti" # Max("MQu.ChemieVon.Ti", -100000000000.0);
  if "MQu.ChemieBis.Ti">0.0 then "MQu.ChemieBis.Ti" # Min("MQu.ChemieBis.Ti", 100000000000.0)
  else "MQu.ChemieBis.Ti" # Max("MQu.ChemieBis.Ti", -100000000000.0);
  if "MQu.ChemieVon.N">0.0 then "MQu.ChemieVon.N" # Min("MQu.ChemieVon.N", 100000000000.0)
  else "MQu.ChemieVon.N" # Max("MQu.ChemieVon.N", -100000000000.0);
  if "MQu.ChemieBis.N">0.0 then "MQu.ChemieBis.N" # Min("MQu.ChemieBis.N", 100000000000.0)
  else "MQu.ChemieBis.N" # Max("MQu.ChemieBis.N", -100000000000.0);
  if "MQu.ChemieVon.Cu">0.0 then "MQu.ChemieVon.Cu" # Min("MQu.ChemieVon.Cu", 100000000000.0)
  else "MQu.ChemieVon.Cu" # Max("MQu.ChemieVon.Cu", -100000000000.0);
  if "MQu.ChemieBis.Cu">0.0 then "MQu.ChemieBis.Cu" # Min("MQu.ChemieBis.Cu", 100000000000.0)
  else "MQu.ChemieBis.Cu" # Max("MQu.ChemieBis.Cu", -100000000000.0);
  if "MQu.ChemieVon.Ni">0.0 then "MQu.ChemieVon.Ni" # Min("MQu.ChemieVon.Ni", 100000000000.0)
  else "MQu.ChemieVon.Ni" # Max("MQu.ChemieVon.Ni", -100000000000.0);
  if "MQu.ChemieBis.Ni">0.0 then "MQu.ChemieBis.Ni" # Min("MQu.ChemieBis.Ni", 100000000000.0)
  else "MQu.ChemieBis.Ni" # Max("MQu.ChemieBis.Ni", -100000000000.0);
  if "MQu.ChemieVon.Mo">0.0 then "MQu.ChemieVon.Mo" # Min("MQu.ChemieVon.Mo", 100000000000.0)
  else "MQu.ChemieVon.Mo" # Max("MQu.ChemieVon.Mo", -100000000000.0);
  if "MQu.ChemieBis.Mo">0.0 then "MQu.ChemieBis.Mo" # Min("MQu.ChemieBis.Mo", 100000000000.0)
  else "MQu.ChemieBis.Mo" # Max("MQu.ChemieBis.Mo", -100000000000.0);
  if "MQu.ChemieVon.B">0.0 then "MQu.ChemieVon.B" # Min("MQu.ChemieVon.B", 100000000000.0)
  else "MQu.ChemieVon.B" # Max("MQu.ChemieVon.B", -100000000000.0);
  if "MQu.ChemieBis.B">0.0 then "MQu.ChemieBis.B" # Min("MQu.ChemieBis.B", 100000000000.0)
  else "MQu.ChemieBis.B" # Max("MQu.ChemieBis.B", -100000000000.0);
  if "MQu.ChemieVon.Frei1">0.0 then "MQu.ChemieVon.Frei1" # Min("MQu.ChemieVon.Frei1", 100000000000.0)
  else "MQu.ChemieVon.Frei1" # Max("MQu.ChemieVon.Frei1", -100000000000.0);
  if "MQu.ChemieBis.Frei1">0.0 then "MQu.ChemieBis.Frei1" # Min("MQu.ChemieBis.Frei1", 100000000000.0)
  else "MQu.ChemieBis.Frei1" # Max("MQu.ChemieBis.Frei1", -100000000000.0);
end;

// -------------------------------------------------
sub EX833()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0833'
     +cnvai(RecInfo(833,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(833, _recModified);
  if "MQu.M.bisDicke">0.0 then "MQu.M.bisDicke" # Min("MQu.M.bisDicke", 100000000000.0)
  else "MQu.M.bisDicke" # Max("MQu.M.bisDicke", -100000000000.0);
  if "MQu.M.Von.StreckG">0.0 then "MQu.M.Von.StreckG" # Min("MQu.M.Von.StreckG", 100000000000.0)
  else "MQu.M.Von.StreckG" # Max("MQu.M.Von.StreckG", -100000000000.0);
  if "MQu.M.Bis.StreckG">0.0 then "MQu.M.Bis.StreckG" # Min("MQu.M.Bis.StreckG", 100000000000.0)
  else "MQu.M.Bis.StreckG" # Max("MQu.M.Bis.StreckG", -100000000000.0);
  if "MQu.M.Von.Zugfest">0.0 then "MQu.M.Von.Zugfest" # Min("MQu.M.Von.Zugfest", 100000000000.0)
  else "MQu.M.Von.Zugfest" # Max("MQu.M.Von.Zugfest", -100000000000.0);
  if "MQu.M.Bis.Zugfest">0.0 then "MQu.M.Bis.Zugfest" # Min("MQu.M.Bis.Zugfest", 100000000000.0)
  else "MQu.M.Bis.Zugfest" # Max("MQu.M.Bis.Zugfest", -100000000000.0);
  if "MQu.M.Von.Dehnung">0.0 then "MQu.M.Von.Dehnung" # Min("MQu.M.Von.Dehnung", 100000000000.0)
  else "MQu.M.Von.Dehnung" # Max("MQu.M.Von.Dehnung", -100000000000.0);
  if "MQu.M.Bis.Dehnung">0.0 then "MQu.M.Bis.Dehnung" # Min("MQu.M.Bis.Dehnung", 100000000000.0)
  else "MQu.M.Bis.Dehnung" # Max("MQu.M.Bis.Dehnung", -100000000000.0);
  if "MQu.M.Von.Körnung">0.0 then "MQu.M.Von.Körnung" # Min("MQu.M.Von.Körnung", 100000000000.0)
  else "MQu.M.Von.Körnung" # Max("MQu.M.Von.Körnung", -100000000000.0);
  if "MQu.M.Bis.Körnung">0.0 then "MQu.M.Bis.Körnung" # Min("MQu.M.Bis.Körnung", 100000000000.0)
  else "MQu.M.Bis.Körnung" # Max("MQu.M.Bis.Körnung", -100000000000.0);
  if "MQu.M.Von.Härte">0.0 then "MQu.M.Von.Härte" # Min("MQu.M.Von.Härte", 100000000000.0)
  else "MQu.M.Von.Härte" # Max("MQu.M.Von.Härte", -100000000000.0);
  if "MQu.M.Bis.Härte">0.0 then "MQu.M.Bis.Härte" # Min("MQu.M.Bis.Härte", 100000000000.0)
  else "MQu.M.Bis.Härte" # Max("MQu.M.Bis.Härte", -100000000000.0);
  if "MQu.M.Von.DehnGrenzA">0.0 then "MQu.M.Von.DehnGrenzA" # Min("MQu.M.Von.DehnGrenzA", 100000000000.0)
  else "MQu.M.Von.DehnGrenzA" # Max("MQu.M.Von.DehnGrenzA", -100000000000.0);
  if "MQu.M.Bis.DehnGrenzA">0.0 then "MQu.M.Bis.DehnGrenzA" # Min("MQu.M.Bis.DehnGrenzA", 100000000000.0)
  else "MQu.M.Bis.DehnGrenzA" # Max("MQu.M.Bis.DehnGrenzA", -100000000000.0);
  if "MQu.M.Von.DehnGrenzB">0.0 then "MQu.M.Von.DehnGrenzB" # Min("MQu.M.Von.DehnGrenzB", 100000000000.0)
  else "MQu.M.Von.DehnGrenzB" # Max("MQu.M.Von.DehnGrenzB", -100000000000.0);
  if "MQu.M.Bis.DehnGrenzB">0.0 then "MQu.M.Bis.DehnGrenzB" # Min("MQu.M.Bis.DehnGrenzB", 100000000000.0)
  else "MQu.M.Bis.DehnGrenzB" # Max("MQu.M.Bis.DehnGrenzB", -100000000000.0);
  if "MQu.M.Dehnung.Basis">0.0 then "MQu.M.Dehnung.Basis" # Min("MQu.M.Dehnung.Basis", 100000000000.0)
  else "MQu.M.Dehnung.Basis" # Max("MQu.M.Dehnung.Basis", -100000000000.0);
  if "MQu.M.Von.RauigkeitO">0.0 then "MQu.M.Von.RauigkeitO" # Min("MQu.M.Von.RauigkeitO", 100000000000.0)
  else "MQu.M.Von.RauigkeitO" # Max("MQu.M.Von.RauigkeitO", -100000000000.0);
  if "MQu.M.Bis.RauigkeitO">0.0 then "MQu.M.Bis.RauigkeitO" # Min("MQu.M.Bis.RauigkeitO", 100000000000.0)
  else "MQu.M.Bis.RauigkeitO" # Max("MQu.M.Bis.RauigkeitO", -100000000000.0);
  if "MQu.M.Von.RauigkeitU">0.0 then "MQu.M.Von.RauigkeitU" # Min("MQu.M.Von.RauigkeitU", 100000000000.0)
  else "MQu.M.Von.RauigkeitU" # Max("MQu.M.Von.RauigkeitU", -100000000000.0);
  if "MQu.M.Bis.RauigkeitU">0.0 then "MQu.M.Bis.RauigkeitU" # Min("MQu.M.Bis.RauigkeitU", 100000000000.0)
  else "MQu.M.Bis.RauigkeitU" # Max("MQu.M.Bis.RauigkeitU", -100000000000.0);
end;

// -------------------------------------------------
sub EX835()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0835'
     +cnvai(RecInfo(835,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(835, _recModified);
  GV.Alpha.02 # Bool("AAr.KonsiYN");
  GV.Alpha.03 # Bool("AAr.ReserviereSLYN");
  GV.Alpha.04 # Bool("AAr.ReservierePosYN");
  GV.Alpha.05 # Bool("AAr.Ein.E.ReservYN");
end;

// -------------------------------------------------
sub EX837()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0837'
     +cnvai(RecInfo(837,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(837, _recModified);
  GV.Alpha.02 # Bool("Txt.RtfYN");
end;

// -------------------------------------------------
sub EX840()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0840'
     +cnvai(RecInfo(840,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(840, _recModified);
end;

// -------------------------------------------------
sub EX841()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0841'
     +cnvai(RecInfo(841,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(841, _recModified);
end;

// -------------------------------------------------
sub EX842()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0842'
     +cnvai(RecInfo(842,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(842, _recModified);
  GV.Alpha.02 # Bool("ApL.EinkaufYN");
  GV.Alpha.03 # Bool("ApL.VerkaufYN");
  GV.Alpha.04 # Bool("ApL.autoAnlegenYN");
  GV.Alpha.05 # Bool("ApL.autoAuswahlYN");
  GV.Alpha.06 # Datum("ApL.Datum.Von");
  GV.Alpha.07 # Datum("ApL.Datum.Bis");
  GV.Alpha.08 # Bool("ApL.KalkulatorischYN");
  GV.Alpha.09 # Bool("ApL.MatAktionYN");
end;

// -------------------------------------------------
sub EX843()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0843'
     +cnvai(RecInfo(843,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(843, _recModified);
  if "ApL.L.Menge">0.0 then "ApL.L.Menge" # Min("ApL.L.Menge", 100000000000.0)
  else "ApL.L.Menge" # Max("ApL.L.Menge", -100000000000.0);
  GV.Alpha.02 # Bool("ApL.L.MengenbezugYN");
  GV.Alpha.03 # Bool("ApL.L.RabattierbarYN");
  GV.Alpha.04 # Bool("ApL.L.NeuberechnenYN");
  if "ApL.L.Preis">0.0 then "ApL.L.Preis" # Min("ApL.L.Preis", 100000000000.0)
  else "ApL.L.Preis" # Max("ApL.L.Preis", -100000000000.0);
  GV.Alpha.05 # Bool("ApL.L.PerFormelYN");
  GV.Alpha.06 # Bool("ApL.L.ProRechnungYN");
  if "ApL.L.Dicke.Von">0.0 then "ApL.L.Dicke.Von" # Min("ApL.L.Dicke.Von", 100000000000.0)
  else "ApL.L.Dicke.Von" # Max("ApL.L.Dicke.Von", -100000000000.0);
  if "ApL.L.Dicke.Bis">0.0 then "ApL.L.Dicke.Bis" # Min("ApL.L.Dicke.Bis", 100000000000.0)
  else "ApL.L.Dicke.Bis" # Max("ApL.L.Dicke.Bis", -100000000000.0);
  if "ApL.L.Breite.Von">0.0 then "ApL.L.Breite.Von" # Min("ApL.L.Breite.Von", 100000000000.0)
  else "ApL.L.Breite.Von" # Max("ApL.L.Breite.Von", -100000000000.0);
  if "ApL.L.Breite.Bis">0.0 then "ApL.L.Breite.Bis" # Min("ApL.L.Breite.Bis", 100000000000.0)
  else "ApL.L.Breite.Bis" # Max("ApL.L.Breite.Bis", -100000000000.0);
  if "ApL.L.Länge.Von">0.0 then "ApL.L.Länge.Von" # Min("ApL.L.Länge.Von", 100000000000.0)
  else "ApL.L.Länge.Von" # Max("ApL.L.Länge.Von", -100000000000.0);
  if "ApL.L.Länge.Bis">0.0 then "ApL.L.Länge.Bis" # Min("ApL.L.Länge.Bis", 100000000000.0)
  else "ApL.L.Länge.Bis" # Max("ApL.L.Länge.Bis", -100000000000.0);
  if "ApL.L.Menge.Von">0.0 then "ApL.L.Menge.Von" # Min("ApL.L.Menge.Von", 100000000000.0)
  else "ApL.L.Menge.Von" # Max("ApL.L.Menge.Von", -100000000000.0);
  if "ApL.L.Menge.Bis">0.0 then "ApL.L.Menge.Bis" # Min("ApL.L.Menge.Bis", 100000000000.0)
  else "ApL.L.Menge.Bis" # Max("ApL.L.Menge.Bis", -100000000000.0);
end;

// -------------------------------------------------
sub EX844()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0844'
     +cnvai(RecInfo(844,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(844, _recModified);
  if "LPl.Max.Höhe">0.0 then "LPl.Max.Höhe" # Min("LPl.Max.Höhe", 100000000000.0)
  else "LPl.Max.Höhe" # Max("LPl.Max.Höhe", -100000000000.0);
  if "LPl.Max.Breite">0.0 then "LPl.Max.Breite" # Min("LPl.Max.Breite", 100000000000.0)
  else "LPl.Max.Breite" # Max("LPl.Max.Breite", -100000000000.0);
  if "LPl.Max.Tiefe">0.0 then "LPl.Max.Tiefe" # Min("LPl.Max.Tiefe", 100000000000.0)
  else "LPl.Max.Tiefe" # Max("LPl.Max.Tiefe", -100000000000.0);
  if "LPl.Max.Gewicht">0.0 then "LPl.Max.Gewicht" # Min("LPl.Max.Gewicht", 100000000000.0)
  else "LPl.Max.Gewicht" # Max("LPl.Max.Gewicht", -100000000000.0);
end;

// -------------------------------------------------
sub EX846()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0846'
     +cnvai(RecInfo(846,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(846, _recModified);
end;

// -------------------------------------------------
sub EX847()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0847'
     +cnvai(RecInfo(847,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(847, _recModified);
end;

// -------------------------------------------------
sub EX853()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0853'
     +cnvai(RecInfo(853,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(853, _recModified);
end;

// -------------------------------------------------
sub EX854()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0854'
     +cnvai(RecInfo(854,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(854, _recModified);
end;

// -------------------------------------------------
sub EX890()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0890'
     +cnvai(RecInfo(890,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(890, _recModified);
  if "OSt.EK.Wert">0.0 then "OSt.EK.Wert" # Min("OSt.EK.Wert", 100000000000.0)
  else "OSt.EK.Wert" # Max("OSt.EK.Wert", -100000000000.0);
  if "OSt.VK.Wert">0.0 then "OSt.VK.Wert" # Min("OSt.VK.Wert", 100000000000.0)
  else "OSt.VK.Wert" # Max("OSt.VK.Wert", -100000000000.0);
  if "OSt.interneKosten">0.0 then "OSt.interneKosten" # Min("OSt.interneKosten", 100000000000.0)
  else "OSt.interneKosten" # Max("OSt.interneKosten", -100000000000.0);
  if "OSt.VK.Gewicht">0.0 then "OSt.VK.Gewicht" # Min("OSt.VK.Gewicht", 100000000000.0)
  else "OSt.VK.Gewicht" # Max("OSt.VK.Gewicht", -100000000000.0);
  if "OSt.VK.Menge">0.0 then "OSt.VK.Menge" # Min("OSt.VK.Menge", 100000000000.0)
  else "OSt.VK.Menge" # Max("OSt.VK.Menge", -100000000000.0);
  if "OSt.DeckBeitrag1">0.0 then "OSt.DeckBeitrag1" # Min("OSt.DeckBeitrag1", 100000000000.0)
  else "OSt.DeckBeitrag1" # Max("OSt.DeckBeitrag1", -100000000000.0);
  if "OSt.Lager.Wert">0.0 then "OSt.Lager.Wert" # Min("OSt.Lager.Wert", 100000000000.0)
  else "OSt.Lager.Wert" # Max("OSt.Lager.Wert", -100000000000.0);
  if "OSt.Lager.Gewicht">0.0 then "OSt.Lager.Gewicht" # Min("OSt.Lager.Gewicht", 100000000000.0)
  else "OSt.Lager.Gewicht" # Max("OSt.Lager.Gewicht", -100000000000.0);
  if "OSt.Lager.Menge">0.0 then "OSt.Lager.Menge" # Min("OSt.Lager.Menge", 100000000000.0)
  else "OSt.Lager.Menge" # Max("OSt.Lager.Menge", -100000000000.0);
  if "OSt.EK.Gewicht">0.0 then "OSt.EK.Gewicht" # Min("OSt.EK.Gewicht", 100000000000.0)
  else "OSt.EK.Gewicht" # Max("OSt.EK.Gewicht", -100000000000.0);
  if "OSt.EK.Menge">0.0 then "OSt.EK.Menge" # Min("OSt.EK.Menge", 100000000000.0)
  else "OSt.EK.Menge" # Max("OSt.EK.Menge", -100000000000.0);
end;

// -------------------------------------------------
sub EX892()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0892'
     +cnvai(RecInfo(892,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(892, _recModified);
  if "OSt.E.Gewicht">0.0 then "OSt.E.Gewicht" # Min("OSt.E.Gewicht", 100000000000.0)
  else "OSt.E.Gewicht" # Max("OSt.E.Gewicht", -100000000000.0);
  if "OSt.E.Menge">0.0 then "OSt.E.Menge" # Min("OSt.E.Menge", 100000000000.0)
  else "OSt.E.Menge" # Max("OSt.E.Menge", -100000000000.0);
  if "OSt.E.BetragW1">0.0 then "OSt.E.BetragW1" # Min("OSt.E.BetragW1", 100000000000.0)
  else "OSt.E.BetragW1" # Max("OSt.E.BetragW1", -100000000000.0);
end;

// -------------------------------------------------
sub EX899()
begin
  GV.Alpha.01 # '00000000-0C16-0C16-0C16-0899'
     +cnvai(RecInfo(899,_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);
  GV.Int64.01 # RecInfo(899, _recModified);
  GV.Alpha.02 # Bool("Sta.EigenYN");
  GV.Alpha.03 # Datum("Sta.Re.Datum");
  if "Sta.Re.Steuerprozent">0.0 then "Sta.Re.Steuerprozent" # Min("Sta.Re.Steuerprozent", 100000000000.0)
  else "Sta.Re.Steuerprozent" # Max("Sta.Re.Steuerprozent", -100000000000.0);
  GV.Alpha.04 # Datum("Sta.Auf.Datum");
  GV.Alpha.05 # Datum("Sta.Auf.Bestell.Dat");
  if "Sta.Auf.Dicke">0.0 then "Sta.Auf.Dicke" # Min("Sta.Auf.Dicke", 100000000000.0)
  else "Sta.Auf.Dicke" # Max("Sta.Auf.Dicke", -100000000000.0);
  if "Sta.Auf.Breite">0.0 then "Sta.Auf.Breite" # Min("Sta.Auf.Breite", 100000000000.0)
  else "Sta.Auf.Breite" # Max("Sta.Auf.Breite", -100000000000.0);
  if "Sta.Auf.Länge">0.0 then "Sta.Auf.Länge" # Min("Sta.Auf.Länge", 100000000000.0)
  else "Sta.Auf.Länge" # Max("Sta.Auf.Länge", -100000000000.0);
  GV.Alpha.06 # Datum("Sta.Auf.Termin");
  GV.Alpha.07 # Datum("Sta.Lfs.Datum");
  if "Sta.Menge.Einsatz">0.0 then "Sta.Menge.Einsatz" # Min("Sta.Menge.Einsatz", 100000000000.0)
  else "Sta.Menge.Einsatz" # Max("Sta.Menge.Einsatz", -100000000000.0);
  if "Sta.Menge.VK">0.0 then "Sta.Menge.VK" # Min("Sta.Menge.VK", 100000000000.0)
  else "Sta.Menge.VK" # Max("Sta.Menge.VK", -100000000000.0);
  if "Sta.Gewicht.Netto.VK">0.0 then "Sta.Gewicht.Netto.VK" # Min("Sta.Gewicht.Netto.VK", 100000000000.0)
  else "Sta.Gewicht.Netto.VK" # Max("Sta.Gewicht.Netto.VK", -100000000000.0);
  if "Sta.Gewicht.BruttoVK">0.0 then "Sta.Gewicht.BruttoVK" # Min("Sta.Gewicht.BruttoVK", 100000000000.0)
  else "Sta.Gewicht.BruttoVK" # Max("Sta.Gewicht.BruttoVK", -100000000000.0);
  if "Sta.Betrag.EK">0.0 then "Sta.Betrag.EK" # Min("Sta.Betrag.EK", 100000000000.0)
  else "Sta.Betrag.EK" # Max("Sta.Betrag.EK", -100000000000.0);
  if "Sta.Lohnkosten">0.0 then "Sta.Lohnkosten" # Min("Sta.Lohnkosten", 100000000000.0)
  else "Sta.Lohnkosten" # Max("Sta.Lohnkosten", -100000000000.0);
  if "Sta.Betrag.VK">0.0 then "Sta.Betrag.VK" # Min("Sta.Betrag.VK", 100000000000.0)
  else "Sta.Betrag.VK" # Max("Sta.Betrag.VK", -100000000000.0);
  if "Sta.Aufpreis.VK">0.0 then "Sta.Aufpreis.VK" # Min("Sta.Aufpreis.VK", 100000000000.0)
  else "Sta.Aufpreis.VK" # Max("Sta.Aufpreis.VK", -100000000000.0);
  if "Sta.Steuer.VK">0.0 then "Sta.Steuer.VK" # Min("Sta.Steuer.VK", 100000000000.0)
  else "Sta.Steuer.VK" # Max("Sta.Steuer.VK", -100000000000.0);
  if "Sta.Korrektur.VK">0.0 then "Sta.Korrektur.VK" # Min("Sta.Korrektur.VK", 100000000000.0)
  else "Sta.Korrektur.VK" # Max("Sta.Korrektur.VK", -100000000000.0);
  if "Sta.Skonto.VK">0.0 then "Sta.Skonto.VK" # Min("Sta.Skonto.VK", 100000000000.0)
  else "Sta.Skonto.VK" # Max("Sta.Skonto.VK", -100000000000.0);
end;
