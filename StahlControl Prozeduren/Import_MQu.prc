@A+
//==== Business-Control ==================================================
//
//  Prozedur    Impotz_MQu
//                  OHNE E_R_G
//  Info
//
//
//  02.06.2008  MS  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB Import_TSR()
//
//========================================================================
@I:Def_Global


define begin
  GetAlphaUp(a,b) : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  GetAlpha(a,b)   : a # FldAlphabyName('X_'+b);
  GetInt(a,b)     : a # FldIntbyName('X_'+b);
  GetWord(a,b)    : a # FldWordbyName('X_'+b);
  GetNum(a,b)     : a # FldFloatbyName('X_'+b);
  GetBool(a,b)    : a # FldLogicbyName('X_'+b);
  GetDate(a,b)    : a # FldDatebyName('X_'+b);
  GetTime(a,b)    : a # FldTimebyName('X_'+b);
end;

//========================================================================
//  Import_TSR
//
//  GetAlphaUp
//  GetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime
//========================================================================
sub Import_TSR()
local begin
  Erx     : int;
  Ansprechpartner : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
//  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin

    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2820,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(832);

    /*
    GetInt(,'');
    GetWord(,'');
    GetAlpha(,'');
    GetNum(,'');
    GetDate(,'');
    GetBool(,'');
    */

    GetWord(MQu.ID,'MQL.Nummer');
    GetAlpha("MQu.Güte1",'MQL.BezeichnungDIN');
    GetAlpha("MQu.Güte2",'MQL.BezeichnungAlt');
    GetAlpha(MQu.Werkstoffnr,'MQl.Werkstoffnummer');
    GetAlpha(MQu.ErsetzenDurch,'MQL.Ersetzung');


    GetAlpha(GV.Alpha.01,'MQL.A.Wert01.V'); // C
    GetAlpha(GV.Alpha.02,'MQL.A.Wert02.V'); // Si
    GetAlpha(GV.Alpha.03,'MQL.A.Wert03.V'); // Mn
    GetAlpha(GV.Alpha.04,'MQL.A.Wert04.V'); // P
    GetAlpha(GV.Alpha.05,'MQL.A.Wert05.V'); // S
    GetAlpha(GV.Alpha.06,'MQL.A.Wert06.V'); // Al
    GetAlpha(GV.Alpha.07,'MQL.A.Wert07.V'); // Cr
    GetAlpha(GV.Alpha.08,'MQL.A.Wert08.V'); // V
    GetAlpha(GV.Alpha.09,'MQL.A.Wert09.V'); // Nb
    GetAlpha(GV.Alpha.10,'MQL.A.Wert10.V'); // Ti
    GetAlpha(GV.Alpha.11,'MQL.A.Wert11.V'); // N
    GetAlpha(GV.Alpha.12,'MQL.A.Wert12.V'); // Cu
    GetAlpha(GV.Alpha.13,'MQL.A.Wert13.V'); // W
    GetAlpha(GV.Alpha.14,'MQL.A.Wert14.V'); // Mo
    GetAlpha(GV.Alpha.15,'MQL.A.Wert15.V'); // B
    GetAlpha(GV.Alpha.16,'MQL.A.Wert16.V'); // Ni

    GetAlpha(GV.Alpha.17,'MQL.A.Wert01.B'); // C
    GetAlpha(GV.Alpha.18,'MQL.A.Wert02.B'); // Si
    GetAlpha(GV.Alpha.19,'MQL.A.Wert03.B'); // Mn
    GetAlpha(GV.Alpha.20,'MQL.A.Wert04.B'); // P
    GetAlpha(GV.Alpha.21,'MQL.A.Wert05.B'); // S
    GetAlpha(GV.Alpha.22,'MQL.A.Wert06.B'); // Al
    GetAlpha(GV.Alpha.23,'MQL.A.Wert07.B'); // Cr
    GetAlpha(GV.Alpha.24,'MQL.A.Wert08.B'); // V
    GetAlpha(GV.Alpha.25,'MQL.A.Wert09.B'); // Nb
    GetAlpha(GV.Alpha.26,'MQL.A.Wert10.B'); // Ti
    GetAlpha(GV.Alpha.27,'MQL.A.Wert11.B'); // N
    GetAlpha(GV.Alpha.28,'MQL.A.Wert12.B'); // Cu
    GetAlpha(GV.Alpha.29,'MQL.A.Wert13.B'); // W
    GetAlpha(GV.Alpha.30,'MQL.A.Wert14.B'); // Mo
    GetAlpha(GV.Alpha.31,'MQL.A.Wert15.B'); // B
    GetAlpha(GV.Alpha.32,'MQL.A.Wert16.B'); // Ni

    MQu.ChemieVon.C     # cnvFA(GV.Alpha.01);
    MQu.ChemieBis.C     # cnvFA(GV.Alpha.17);
    MQu.ChemieVon.Si    # cnvFA(GV.Alpha.02);
    MQu.ChemieBis.Si    # cnvFA(GV.Alpha.18);
    MQu.ChemieVon.Mn    # cnvFA(GV.Alpha.03);
    MQu.ChemieBis.Mn    # cnvFA(GV.Alpha.19);
    MQu.ChemieVon.P     # cnvFA(GV.Alpha.04);
    MQu.ChemieBis.P     # cnvFA(GV.Alpha.20);
    MQu.ChemieVon.S     # cnvFA(GV.Alpha.05);
    MQu.ChemieBis.S     # cnvFA(GV.Alpha.21);
    MQu.ChemieVon.Al    # cnvFA(GV.Alpha.06);
    MQu.ChemieBis.Al    # cnvFA(GV.Alpha.22);
    MQu.ChemieVon.Cr    # cnvFA(GV.Alpha.07);
    MQu.ChemieBis.Cr    # cnvFA(GV.Alpha.23);
    MQu.ChemieVon.V     # cnvFA(GV.Alpha.08);
    MQu.ChemieBis.V     # cnvFA(GV.Alpha.24);
    MQu.ChemieVon.Nb    # cnvFA(GV.Alpha.09);
    MQu.ChemieBis.Nb    # cnvFA(GV.Alpha.25);
    MQu.ChemieVon.Ti    # cnvFA(GV.Alpha.10);
    MQu.ChemieBis.Ti    # cnvFA(GV.Alpha.26);
    MQu.ChemieVon.N     # cnvFA(GV.Alpha.11);
    MQu.ChemieBis.N     # cnvFA(GV.Alpha.27);
    MQu.ChemieVon.Cu    # cnvFA(GV.Alpha.12);
    MQu.ChemieBis.Cu    # cnvFA(GV.Alpha.28);
    MQu.ChemieVon.Ni    # cnvFA(GV.Alpha.16);
    MQu.ChemieBis.Ni    # cnvFA(GV.Alpha.32);
    MQu.ChemieVon.Mo    # cnvFA(GV.Alpha.14);
    MQu.ChemieBis.Mo    # cnvFA(GV.Alpha.30);
    MQu.ChemieVon.B     # cnvFA(GV.Alpha.15);
    MQu.ChemieBis.B     # cnvFA(GV.Alpha.31);
    MQu.ChemieVon.Frei1 # cnvFA(GV.Alpha.13);
    MQu.ChemieBis.Frei1 # cnvFA(GV.Alpha.29);






    /*
    GetAlpha(GV.Alpha.33,'');
    GetAlpha(GV.Alpha.34,'');
    GetAlpha(GV.Alpha.35,'');
    GetAlpha(GV.Alpha.36,'');
    GetAlpha(GV.Alpha.37,'');
    GetAlpha(GV.Alpha.38,'');
    GetAlpha(GV.Alpha.39,'');
    GetAlpha(GV.Alpha.40,'');
    */


    Erx #  RekInsert(832,0,'MAN');

    Erx # RecRead(2820,1,_recNext);

  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Qualitäten wurden importiert!',0,0,0);
end;

//========================================================================
//========================================================================