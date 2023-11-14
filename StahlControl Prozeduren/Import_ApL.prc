@A+
//===== Business-Control =================================================
//
//  Prozedur    Import_ApL
//                    OHNE E_R_G
//  Info
//
//
//  02.06.2008  MS  Erstellung der Prozedur
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
  Erx             : int;
  Ansprechpartner : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.0.100','!Thyssen','thomas','','');
  if (Erx<>_rOK) then begin

    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2840,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(842);

    /*
    GetInt(,'');
    GetWord(,'');
    GetAlpha(,'');
    GetNum(,'');
    GetDate(,'');
    GetBool(,'');
    */
    ApL.Key1 # 1;
    //GetWord(ApL.Key1,'1  APL.Listenart');
    GetWord(ApL.Key2,'APL.Typ');
    GetWord(ApL.Key3,'APL.Liste');
    //GetWord(ApL.Aufpreisgruppe,'');
    GetAlpha(GV.Alpha.01,'APL.Bezeichnung');
    ApL.Bezeichnung # StrCut(GV.Alpha.01,0,32);
    GetAlpha("ApL.gültigeLKZ",'APL.LKZ');
    //GetInt(ApL.Adressnummer,'');
    //GetInt(ApL.Erzeugernummer,'');
    //GetBool(ApL.EinkaufYN,'');
    //GetBool(ApL.VerkaufYN,'');
    GetBool(ApL.autoAnlegenYN,'APL.autoEinfügen');
    GetBool(ApL.autoAuswahlYN,'APL.autoWählen');
    //GetBool(ApL.KalkulatorischYN,'');
    //GetBool(ApL.MatAktionYN,'');
    GetDate(ApL.Datum.Von,'APL.GültigVon');
    GetDate(ApL.Datum.Bis,'APL.GültigBis');


    Erx #  RekInsert(842,0,'MAN');


    Erx # RecLink(2841,2840,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      RecBufClear(843);
      ApL.L.Key1 # 1;
      //GetWord(ApL.L.Key1,'APL.L.');
      GetWord(ApL.L.Key2,'APL.L.Typ');
      GetWord(ApL.L.Key3,'APL.L.Liste');
      GetWord(ApL.L.Key4,'APL.L.Position');
      //GetWord(ApL.L.Warengruppe,'APL.L.');
      GetWord(ApL.L.Aufpreisgruppe,'APL.L.Aufpreisgruppe');
      //GetWord(ApL.L.Artikelgruppe,'APL.L.');

      GetAlpha(ApL.L.Bezeichnung.L1,'APL.L.Bezeichnung');
      /*
      GetAlpha(ApL.L.Bezeichnung.L2,'APL.L.');
      GetAlpha(ApL.L.Bezeichnung.L3,'APL.L.');
      GetAlpha(ApL.L.Bezeichnung.L4,'APL.L.');
      GetAlpha(ApL.L.Bezeichnung.L5,'APL.L.');
      */
      GetAlpha(ApL.L.MEH,'APL.L.Mengeneinheit');
      GetAlpha(ApL.L.Menge.MEH,'APL.L.Mengeneinheit');

      //GetAlpha(,'');

      GetNum(ApL.L.Menge,'APL.L.Menge');
      GetNum(ApL.L.Preis,'APL.L.Aufpreis');
      GetNum(ApL.L.Dicke.Von,'APL.L.vonDicke');
      GetNum(ApL.L.Dicke.Bis,'APL.L.bisDicke');
      GetNum(ApL.L.Breite.Von,'APL.L.vonBreite');
      GetNum(ApL.L.Breite.Bis,'APL.L.bisBreite');
      GetNum("ApL.L.Länge.Von",'APL.L.vonLänge');
      GetNum("ApL.L.Länge.Bis",'APL.L.bisLänge');
      GetNum(ApL.L.Menge.Von,'APL.L.vonGewicht');
      GetNum(ApL.L.Menge.Bis,'APL.L.bisGewicht');

      GetBool(ApL.L.MengenbezugYN,'APL.L.Mengenaufpreis');
      GetBool(ApL.L.RabattierbarYN,'APL.L.Rabattierfähig');
      GetBool(ApL.L.NeuberechnenYN,'APL.L.Neuberechnung');

      GetInt(ApL.L.PEH,'APL.L.Preiseinheit');


      /*
      GetInt(ApL.L.Adresse,'APL.L.');
      GetInt(ApL.L.Erzeuger,'APL.L.');
      GetWord(ApL.L.ObfNr,'APL.L.');
      GetAlpha("ApL.L.Güte",'APL.L.');
      GetAlpha(ApL.L.ObfZusatz,'APL.L.');
      GetAlpha(ApL.L.Zeugnis,'APL.L.');
      GetAlpha(ApL.L.Artikelnummer,'APL.L.');
      */



      Erx # RekInsert(843,0,'MAN');

      Erx # RecLink(2841,2840,1,_recNext);
    END;

    Erx # RecRead(2840,1,_recNext);

  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'Aufpreise wurden importiert!',0,0,0);
end;
//========================================================================