@A+
//  Call EDI_Analysen:Test
//===== Business-Control =================================================
//
//  Prozedur  EDI_Analysen
//                  OHNE E_R_G
//  Info      QALITY 93A
//
//
//  2017-09-21  AH  Erstellung der Prozedur
//  2017-11-29  AH  Mengen werden bestimmt
//  2022-06-14  ST  JOB.Import hinzugefügt
//  2022-06-20  ST  Bugfix: Wareneingangserkennenung nur auf Coilnummer und Werksnummer
//  2022-11-14  MK  JOB.Import: Erweiterung um opt. Parameter aJobGruppe
//  2022-12-12  ST  Beachtung von Optionalem Node "Materialnr" / Kann bei Doppelimporten Wareneingänge aktualisieren
//  2023-02-03  MR  Fix Beachtung von gelöschten Eingängen  2469/2
//  2023-08-02  ST  Edit: Doppelprüfung auf Werks- und Coilnummer bei Verrbuchung entfernt
//  2023-08-03  ST  Neu:  Ein.E.Custom.Sort kann beim Importieren genutzt werden
//
//
//  mögliche spezial Anker:
//                  EDI.Analysen.Process    : im ROOT: aNode : int; var "\", "", var vErr ; alpha
//                  EDI.Analysen.Process    : im Wert: 0, var aName : alpha, aInhalt : alpha; var vErr ; alpha
//                  EDI.Analysen.Buche.Pre  : aNew : logic ; var aWofErr : int, var aErr : alpha;
//                  EDI.Analysen.Buche.Post : aNew : logic ; var aWofErr : int, var aErr : alpha;
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_EDI

define begin
  cTEST : false

  cWoFDatei                     : 501

  cWoFNeuerSatz                 : 10300
  cWoFUpdateSatz                : 10310

  cWoFDatenAbweichend           : 10320

  cWoFBuchungsFehler            : 10398
  cWoFDateiDefekt               : 10399
end;

declare Start(opt aFileName : alpha(1000)) : logic;
declare ProcessRoot(aRoot : int) : logic;
declare SucheBestellung(aLfNr : int; aBest : alpha; aEkNr : int; aEkPos : int; aAbRef : alpha; var aWofErr : int; var aErr : alpha) : logic;
declare Buche506(a506 : int; var aWofErr : int; var aErr : alpha) : logic;

//========================================================================
//========================================================================
sub _NewMessNode(
  aPar    : int;
  aName   : alpha;
  aInhalt : alpha);
local begin
  Erx     : int;
  vNode   : int;
end;
begin
  vNode # NewNode(aPar, 'Wert');
  NewNodeAttrib(vNode, 'Name', aName);
  NewNodeAttrib(vNode, 'Inhalt', aInhalt);
end;



sub _RecCalcEinE()
local begin
  Erx : int;
end
begin
  Ein.E.Verwiegungsart  # Ein.P.Verwiegungsart;
  Erx # RekLink(818,506,12,_RecFirst);
  if (Erx>_rLockeD) then VWa.nettoyn # true;
  if (VWa.NettoYN) then
    Ein.E.Gewicht # Ein.E.Gewicht.Netto
  else
    Ein.E.Gewicht # Ein.E.Gewicht.Brutto;

  // Mengenbestimmung...
  if (StrCnv(Ein.E.MEH,_Strupper)='STK') then begin
    Ein.E.Menge # cnvfi("Ein.E.Stückzahl");
  end
  else if (StrCnv(Ein.E.MEH,_Strupper)='KG') then begin
    Ein.E.Menge # Ein.E.Gewicht;
  end
  begin
    if (Ein.E.Menge=0.0) then Ein.E.Menge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, 0.0,'', Ein.E.MEH);
  end;
  if (StrCnv(Ein.E.MEH2,_Strupper)='STK') then begin
    Ein.E.Menge2 # cnvfi("Ein.E.Stückzahl");
  end
  else if (StrCnv(Ein.E.MEH2,_Strupper)='KG') then begin
    Ein.E.Menge2 # Ein.E.Gewicht;
  end if (Ein.E.MEH2<>'') then begin
    if (Ein.E.Menge2=0.0) then Ein.E.Menge2 # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.E.MEH2);
  end;
  if (Ein.E.Gewicht.Brutto=0.0) then
    Ein.E.Gewicht.Brutto # Ein.E.Gewicht;
  if (Ein.E.Gewicht.Netto=0.0) then
    Ein.E.Gewicht.Netto # Ein.E.Gewicht;
end;

//========================================================================
//========================================================================
sub ProcessRoot(
  aRoot         : int
  ) : logic;
local begin
  vAnzSatz  : int;
  vOK       : logic;
  vWofErr   : int;
  vErr      : alpha(1000);

  xSatz     : int;
  xWert     : int;
  vName     : alpha;
  vInhalt   : alpha;

  vF        : float;
  v506      : int;
  vLfNr     : int;
  vBest     : alpha;
  vEkNr     : int;
  vEkPos    : int;
  vAbRef    : alpha(32);
  vLagerRef : alpha;

  vAFX      : alpha;
end;
begin

  if (Lib_SFX:Check_AFX('EDI.Analysen.Process')) then
    vAFX # AFX.Prozedur;

  TRANSON;

  vWofErr # cWofDateiDefekt;

  v506 # RecBufCreate(506);

  // Sätze loopen...
  vOK # true;
  FOR xSatz # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'Satz')
  LOOP xSatz # aRoot->CteRead( _cteChildList | _cteSearch | _CteNext, xSatz, 'Satz')
  WHILE (xSatz<>0) and (vOK) do begin
    inc(vAnzSatz);
    vOK # false;
    RecBufClear(506);

    if (vAFX<>'') then begin
      // Typ, aNode, var vErr
      vName # '\';
      Call(vAFX, xSatz, var vName, '', var vErr);
      if (vErr<>'') then BREAK;
    end;

/***
  if (Lib_EDI:_ReadNode(xSatz, 'Bemerkung', var Erx)=false) then begin
    Erx # Erx->CteRead(_CteFirst  | _CteChildList)
    if (Erx <> 0) AND (Erx->spID = _XmlNodeText) then begin
      GV.Alpha.01 # StrCnv(Erx->spValueAlpha,_StrFromUTF8);
      Erx->spValueAlpha # 'x'+gv.alpha.01+'x';
    end;
  end;
***/

    // PFLICHTNODES:
    if (NodeI(xSatz, var vErr, 'Lieferantennr',         var vLfNr)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Bestellung',            var vBest)=false) then BREAK;
    if (NodeI(xSatz, var vErr, 'Bestellnummer',         var vEkNr)=false) then BREAK;
    if (NodeI(xSatz, var vErr, 'Bestellposition',       var vEkPos)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Bestellung_Refcode',    var vAbRef)=false) then BREAK;

    if (NodeA(xSatz, var vErr, 'Werksnr',               var Ein.E.Werksnummer)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Chargennr',             var Ein.E.Chargennummer)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Coilnr',                var Ein.E.Coilnummer)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Ringnr',                var Ein.E.Ringnummer)=false) then BREAK;

    if (NodeI(xSatz, var vErr, 'Stueck',                var "Ein.E.Stückzahl")=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Gewicht_Netto',         var Ein.E.Gewicht.netto)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Gewicht_Brutto',        var Ein.E.Gewicht.Brutto)=false) then BREAK;

    if (NodeA(xSatz, var vErr, 'Guete',                 var "Ein.E.Güte")=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Dicke',                 var Ein.E.Dicke)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Breite',                var Ein.E.Breite)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Laenge',                var "Ein.E.Länge")=false) then BREAK;

    if (NodeD(xSatz, var vErr, 'Datum',                 var Ein.E.VSB_Datum)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Lageradresse_Refcode',  var vLagerRef)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Ursprungsland',         var Ein.E.Ursprungsland)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Lieferscheinnr',        var Ein.E.LieferscheinNr)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Bemerkung',             var Ein.E.Bemerkung)=false) then BREAK;

    // Optionale Nodes
    NodeI(xSatz, var vErr, 'Materialnr',                var Ein.E.Materialnr);

    // OPTIONALE Messfelder:
    FOR xWert   # xSatz->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'Wert')
    LOOP xWert  # xSatz->CteRead( _cteChildList | _cteSearch | _CteNext, xWert, 'Wert')
    WHILE (xWert<>0) do begin

      if (Lib_XML:GetAttributeValueOrBreak(xWert, 'Name', var vName)=false) then begin
        vErr # 'Kein Namensattribut';
        BREAK;
      end;
      if (Lib_XML:GetAttributeValueOrBreak(xWert, 'Inhalt', var vInhalt)=false) then begin
        vErr # 'Kein Inhaltsattribut';
        BREAK;
      end;
      vName # StrCnv(vName,_StrUpper);

      if (vAFX<>'') then begin
        // Typ, aNode, var vErr
        Call(vAFX, 0, var vName, vInhalt, var vErr);
        if (vErr<>'') then BREAK;
      end;

      case (vName) of
        'STRECKGRENZE' :
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.Streckgrenze, var Ein.E.Streckgrenze2)=false) then BREAK;
        'ZUGFESTIGKEIT', 'RM' :
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.Zugfestigkeit, var Ein.E.Zugfestigkeit2)=false) then BREAK;
        'A80' : begin
          Ein.E.DehnungA # 80.0;
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.DehnungB, var Ein.E.DehnungC)=false) then BREAK;
        end;
        'A50' : begin
          Ein.E.DehnungA # 50.0;
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.DehnungB, var Ein.E.DehnungC)=false) then BREAK;
        end;
        'A5' : begin
          Ein.E.DehnungA # 5.0;
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.DehnungB, var Ein.E.DehnungC)=false) then BREAK;
        end;
        'RP1','RP10' :
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.RP10_1, var Ein.E.RP10_2)=false) then BREAK;
        'RP2', 'RP02' :
          if (WertMinMax(vName, vInhalt, var vErr, var Ein.E.RP02_1, var Ein.E.RP02_2)=false) then BREAK;
        'KOERNUNG' :
          if (WertMinMax(vName, vInhalt, var vErr, var "Ein.E.Körnung", var "Ein.E.Körnung2")=false) then BREAK;
        'HAERTE' :
          if (WertMinMax(vName, vInhalt, var vErr, var "Ein.E.Härte1", var "Ein.E.Härte2")=false) then BREAK;
        'RAUHIGKEITOS' :
          if (WertMinMax(vName, vInhalt, var vErr, var "Ein.E.RauigkeitA1", var "Ein.E.RauigkeitA2")=false) then BREAK;
        'RAUHIGKEITUS' :
          if (WertMinMax(vName, vInhalt, var vErr, var "Ein.E.RauigkeitB1", var "Ein.E.RauigkeitB2")=false) then BREAK;

        'C','ZC','KOHLENSTOFF' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.C)=false) then BREAK;
        'SI','ZSI' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.SI)=false) then BREAK;
        'MN','ZMN' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.MN)=false) then BREAK;
        'P','ZP' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.P)=false) then BREAK;
        'S','ZS' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.S)=false) then BREAK;
        'AL','ZAL' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.AL)=false) then BREAK;
        'CR','ZCR' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.CR)=false) then BREAK;
        'V','ZV' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.V)=false) then BREAK;
        'NB','ZNB' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.NB)=false) then BREAK;
        'TI','ZTI' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.TI)=false) then BREAK;
        'N','ZN' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.N)=false) then BREAK;
        'CU','ZCU' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.CU)=false) then BREAK;
        'NI','ZNI' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.NI)=false) then BREAK;
        'MO','ZMO' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.MO)=false) then BREAK;
        'B','ZB' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.B)=false) then BREAK;
        'X1' :
          if (WertF(vName, vInhalt, var vErr, var Ein.E.Chemie.Frei1)=false) then BREAK;
        'MECH_SONSTIGES' :
          Ein.E.Mech.Sonstig # vInhalt;
      end;  // CASE

    END;  // Werte

    // KONSTANTEN
    Ein.E.VSBYN           # y;

    RecBufCopy(506,v506);

    if (SucheBestellung(vLfNr, vBest, vEkNr, vEkPos, vAbRef, var vWofErr, var vErr)=false) then BREAK;

// SIREN??

    if (Buche506(v506, var vWofErr, var vErr)=false) then BREAK;

    vOK # true;
  END;  // Satz


  RecBufClear(v506);
  if (vOK=false) then begin
    TRANSBRK;
    EDIERROR(999, vWofErr, 'Satz '+aint(vAnz)+': '+vErr);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  SucheBestellung
//      anhand Nr/Pos oder AB-Nummer + LfNr
//========================================================================
sub SucheBestellung(
  aLfNr       : int;
  aBest       : alpha;
  aEkNr       : int;
  aEkPos      : int;
  aAbRef      : alpha;
  var aWofErr : int;
  var aErr    : alpha) : logic;
local begin
  Erx : int;
  vA        : alpha;
  vA1, vA2  : alpha;
end;
begin

  if (cTest) then begin
    Erx # RecRead(501,1,_recLast);
    aEkNr   # Ein.P.Nummer;
    aEkPos  # Ein.P.Position;
    aLfNr   # Ein.P.Lieferantennr;
  end;

  if (aEkNr=0) and (aBest='') and (aAbRef='') then begin
    aErr # 'Keine Bestell-Nummer angegeben';
    RETURN false;
  end;

  // Anhand Bestellstring finden?
  if (aEkNr=0) and (aBest<>'') then begin
    vA # Str_Token(aBest,'/',1);
    if (TryI(vA, var aEkNr)=false) then begin
      aErr # 'Keine gültige Bestellung "'+aBest+'"';
      RETURN false;
    end;
    vA # Str_Token(aBest,'/',2);
    if (TryI(vA, var aEkPos)=false) then begin
      aErr # 'Keine gültige Bestellung "'+aBest+'"';
      RETURN false;
    end;
  end;

  // anhand AB-Nummer finden?
  if (aEkNr=0) and (aAbRef<>'') and (aLfNr<>0) then begin
    aEkPos # 0;
    // gezielt Pos. suchen...
    RecBufClear(501);
    Ein.P.AB.Nummer # aAbRef;
    FOR Erx # RecRead(501,13,0)
    LOOP Erx # RecRead(501,13,_recNext)
    WHILE (Erx<=_rMultikey) and (Ein.P.AB.Nummer=aAbRef) do begin
      if (Ein.P.Lieferantennr=aLfNr) then begin
        aEkNr   # Ein.P.Nummer;
        aEkPos  # Ein.P.Position;
        BREAK;
      end;
    END;

    // über den Kopf suchen?
    if (aEkNr=0) then begin
      if (Lib_Strings:Strings_Count(aAbRef,'/')<>1) then begin
        aErr # 'Keine zugehörige Bestellung gefunden';
        RETURN false;
      end;

      vA1 # Str_Token(aAbRef,'/',1);
      vA2 # Str_Token(aAbRef,'/',2);

      // Kopf aus Token1 ermitteln...
      RecBufClear(500);
      Ein.AB.Nummer # vA1;
      FOR Erx # RecRead(500,4,0)
      LOOP Erx # RecRead(500,4,_recNext)
      WHILE (Erx<=_rMultikey) and (Ein.AB.Nummer=vA1) do begin
        if (Ein.Lieferantennr=aLfNr) then begin
          aEkNr   # Ein.Nummer;
          BREAK;
        end;
      END;
      if (aEkNr=0) then begin
        aErr # 'Keine aktive Bestellung mit Referenz"'+aAbRef+'" gefunden';
        RETURN false;
      end;

      // Pos. anhang Token2 suchen...
      FOR Erx # RecLink(501,500,9,_recFirst)  // Posten loopen...
      LOOP Erx # RecLink(501,500,9,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Ein.P.AB.Nummer=vA2) and (vA2<>'') then begin
          aEkPos  # Ein.P.Position;
          BREAK;
        end;
      END;
      if (aEkPos=0) then begin
        if (TryI(vA2, var aEkPos)=false) then begin
          aErr # 'Keine aktive Bestellung mit Referenz"'+aAbRef+'" gefunden';
          RETURN false;
        end;
      end;
    end;  // über Kopf
  end;  // anhand AB-Nummer

  if (aEkNr=0) or (aEkPos=0) then begin
    aErr # 'Keine zugehörige Bestellung gefunden';
    RETURN false;
  end;

  Ein.P.Nummer    # aEkNr;
  Ein.P.Position  # aEkPos;
  Erx # RecRead(501,1,0);
  if (Erx<>_rOK) or ("Ein.P.Löschmarker"='*') then begin
    aErr # 'Keine aktive Bestellung "'+aint(aEkNr)+'/'+aint(aEkPos)+'" gefunden';
    RETURN false;
  end;

  Erx # RecLink(500,501,3,_recFirst);   // Kopf holen
  if (Erx<>_rOK) then begin
    aErr # 'Keine aktive Bestellung "'+aint(aEkNr)+'/'+aint(aEkPos)+'" gefunden';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  Buche506
//
//========================================================================
sub Buche506(
  a506        : int;
  var aWofErr : int;
  var aErr    : alpha) : logic;
local begin
    Erx : int;
  vWeNr       : int;
  vMat        : int;
  vCh         : alpha;
  vMin, vMax  : float;


end;
begin

  // Neuer oder alter Satz?
  FOR Erx # RecLink(506,501,14,_recFirst) // Eingänge loopen
  LOOP Erx # RecLink(506,501,14,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if("Ein.E.Löschmarker" <> '') then CYCLE; //  2023-02-03  MR  Beachtung von gelöschten Eingängen  2469/2
    if ((a506->Ein.E.Werksnummer<>'') and (Ein.E.Werksnummer=a506->Ein.E.Werksnummer)) or
/*      ((a506->Ein.E.Chargennummer<>'') and (Ein.E.Chargennummer=a506->Ein.E.Chargennummer)) or */
      ((a506->Ein.E.Coilnummer<>'') and (Ein.E.Coilnummer=a506->Ein.E.Coilnummer)) or
      ((a506->Ein.E.Materialnr<>0) and (Ein.E.materialnr=a506->ein.E.Materialnr))  then begin
      vWeNr # Ein.E.Eingangsnr;
      BREAK;
    end;
  END;


  if (a506->Ein.E.Lageradresse=0) then begin
    if (a506->Ein.E.EingangYN) then begin
      a506->Ein.E.Lageradresse    # Ein.Lieferadresse;
      a506->Ein.E.Lageranschrift  # Ein.Lieferanschrift;
    end
    else begin
      // Adressnummer des Lieferanten lesen
      if (RecLink(100,500,1,0) <= _rLocked) then begin
        a506->Ein.E.Lageradresse    # Adr.Nummer;
        a506->Ein.E.Lageranschrift  # 1;
      end;
    end;
  end;


  // ALTER SATZ -------------------------------
  if (vWeNr<>0) then begin
    // doch irgendwie "anderes" ???

  // ST 2023-08-02  Doppeltprüfung deaktiviert, damit eigengenerierte Coilnummern bei einem Change
  //                seitens des Lieferantens hier nicht zu einem Fehler führen.
  //                Die eigene Coilnummer wird in der Regel nie dem Lieferanten mitgeteilt!
/*
    if ((a506->Ein.E.Werksnummer<>'') and (Ein.E.Werksnummer<>a506->Ein.E.Werksnummer)) or

//      ((a506->Ein.E.Chargennummer<>'') and (Ein.E.Chargennummer<>a506->Ein.E.Chargennummer)) or
      ((a506->Ein.E.Coilnummer<>'') and (Ein.E.Coilnummer<>a506->Ein.E.Coilnummer))
      //  or   ((a506->Ein.E.Materialnr<>0) and (Ein.E.materialnr<>a506->ein.E.Materialnr))
      then begin

      aWofErr # cWoFBuchungsFehler;
      aErr # 'Identifizierungs Daten abweichend bei Wareneingang "'+aint(Ein.E.Nummer)+'/'+aint(Ein.E.Position)+'/'+aint(Ein.E.eingangsnr)+'"';
      RETURN false;
    end;
*/

    PtD_Main:Memorize(506);
    RecRead(506,1,_recLock);
    vMat  # Ein.E.Materialnr;
    vCh   # Ein.E.Charge;

    //RecBufCopy(v506, 506, false);
    Ein.E.VSB_Datum         # a506->Ein.E.VSB_Datum;
    Ein.E.Lageradresse      # a506->Ein.E.Lageradresse;
    Ein.E.Lageranschrift    # a506->Ein.E.Lageranschrift

    // Daten aus 1. TDS per "Hand" übermehen
    "Ein.E.Gewicht.Netto"  # a506->"Ein.E.Gewicht.Netto" ;
    "Ein.E.Gewicht.Brutto" # a506->"Ein.E.Gewicht.Brutto";
    "Ein.E.Güte"           # a506->"Ein.E.Güte"          ;
    "Ein.E.Dicke"          # a506->"Ein.E.Dicke"         ;
    "Ein.E.Breite"         # a506->"Ein.E.Breite"        ;
    "Ein.E.Länge"          # a506->"Ein.E.Länge"         ;
    "Ein.E.Bemerkung"      # a506->"Ein.E.Bemerkung"     ;
    "Ein.E.Cust.Sort"      # a506->"Ein.E.Cust.Sort"     ;

    SbrCopy(a506, 2, 506,2);
    SbrCopy(a506, 3, 506,3);
    SbrCopy(a506, 4, 506,4);
    SbrCopy(a506, 5, 506,5);
    Ein.E.MaterialNr  # vMat;
    Ein.E.Charge      # vCh;

    _RecCalcEinE();

    if (Lib_SFX:Check_AFX('EDI.Analysen.Buche.Pre')) and (AFX.Prozedur<>'') then begin
      // var aWofErr, var aErr
      Call(AFX.Prozedur, false, var aWofErr, var aErr)
      if (aErr<>'') then RETURN false;
    end;

    Erx # RekReplace(506);
    if (Erx<>_rOK) then begin
      PtD_Main:Forget(506);
      aWofErr # cWoFBuchungsFehler;
      aErr # 'Wareneingang "'+aint(Ein.E.Nummer)+'/'+aint(Ein.E.Position)+'/'+aint(Ein.E.eingangsnr)+'" kann nicht verändert werden';
      RETURN false;
    end;
    // Update...
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      PtD_Main:Forget(506);
      aWofErr # cWoFBuchungsFehler;
      aErr # 'Wareneingang "'+aint(Ein.E.Nummer)+'/'+aint(Ein.E.Position)+'/'+aint(Ein.E.eingangsnr)+'" kann nicht verbucht werden';
      RETURN false;
    end;
    PtD_Main:Compare(506);

    StartWof(cWofDatei, cWofUpdateSatz,'WE.'+aint(Ein.E.Eingangsnr));

// WEITERE CEHCKS !!!
    if (Lib_SFX:Check_AFX('EDI.Analysen.Buche.Post')) and (AFX.Prozedur<>'') then begin
      // var aWofErr, var aErr
      Call(AFX.Prozedur, false, var aWofErr, var aErr)
      if (aErr<>'') then RETURN false;
    end;

    RETURN TRUE;
  end;

  // NEUER SATZ -------------------------------
  RecBufCopy(a506, 506);
  Ein.E.Nummer          # Ein.P.Nummer;
  Ein.E.Position        # Ein.P.Position;
  Ein.E.Anlage.User     # gUserName;
  Ein.E.Anlage.Datum    # Today;
  Ein.E.Anlage.Zeit     # Now;
  Ein.E.Lieferantennr   # Ein.P.Lieferantennr;
  Ein.E.Warengruppe     # Ein.P.Warengruppe;
  Ein.E.MEH             # Ein.P.MEH;
  Ein.E.Artikelnr       # Ein.P.Artikelnr;
  Ein.E.Kommission      # Ein.P.Kommission;
  "Ein.E.Währung"       # "Ein.Währung";
  Ein.E.Intrastatnr     # Ein.P.Intrastatnr;

  Ein.E.AbbindungL        # Ein.P.AbbindungL;
  Ein.E.AbbindungQ        # Ein.P.AbbindungQ;
  Ein.E.Zwischenlage      # Ein.P.Zwischenlage;
  Ein.E.Unterlage         # Ein.P.Unterlage;
  Ein.E.Umverpackung      # Ein.P.Umverpackung;
  Ein.E.Wicklung          # Ein.P.Wicklung;
  Ein.E.StehendYN         # Ein.P.StehendYN;
  Ein.E.LiegendYN         # Ein.P.LiegendYN;
  Ein.E.Nettoabzug        # Ein.P.Nettoabzug;
  "Ein.E.Stapelhöhe"      # "Ein.P.Stapelhöhe";
  "Ein.E.Stapelhöhenabz"  # "Ein.P.StapelhAbzug";
  Ein.E.AusfOben          # Ein.P.AusfOben;
  Ein.E.AusfUnten         # Ein.P.AusfUnten;

  _RecCalcEinE();


  if (Lib_SFX:Check_AFX('EDI.Analysen.Buche.Pre')) and (AFX.Prozedur<>'') then begin
    // var aWofErr, var aErr
    Call(AFX.Prozedur, true, var aWofErr, var aErr)
    if (aErr<>'') then RETURN false;
  end;

  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Erx # RekInsert(506,0,'JOB');
  UNTIL (Erx=_rOK);

  // Ausführungen kopieren
  FOR Erx # RecLink(502,501,12,_recFirst)
  LOOP Erx # RecLink(502,501,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Ein.E.AF.Nummer       # Ein.E.Nummer;
    Ein.E.AF.Position     # Ein.E.Position;
    Ein.E.AF.Eingang      # Ein.E.Eingangsnr;
    Ein.E.AF.Seite        # Ein.AF.Seite;
    Ein.E.AF.lfdNr        # Ein.AF.lfdNr;
    Ein.E.AF.ObfNr        # Ein.AF.ObfNr;
    Ein.E.AF.Bezeichnung  # Ein.AF.Bezeichnung;
    Ein.E.AF.Zusatz       # Ein.AF.Zusatz;
    Ein.E.AF.Bemerkung    # Ein.AF.Bemerkung;
    "Ein.E.AF.Kürzel"     # "Ein.AF.Kürzel";
    RekInsert(507,0,'AUTO');
  END;

  // Insert...
  if (Ein_E_Data:Verbuchen(y)=false) then begin
    aWofErr # cWoFBuchungsFehler;
    aErr # 'Wareneingang "'+aint(Ein.E.Nummer)+'/'+aint(Ein.E.Position)+'/'+aint(Ein.E.eingangsnr)+'" kann nicht verbucht werden';
    RETURN false;
  end;

  if ("Ein.E.Güte"<>"Ein.P.Güte") then
    StartWof(cWofDatei, cWofDatenAbweichend, 'Güte: WE.'+aint(Ein.E.Eingangsnr));

  if (Ein.E.Dickentol<>'') then begin
    Lib_Berechnungen:ToleranzZuWerten(Ein.E.Dickentol,var vMin, var vMax);
    vMin # vMin + Ein.P.Dicke;
    vMax # vMax + Ein.P.Dicke;
    if (Ein.E.Dicke<vMin) or (Ein.E.Dicke>vMax) then
      StartWof(cWofDatei, cWofDatenAbweichend, 'Dicke: WE.'+aint(Ein.E.Eingangsnr));
  end;

  if (Ein.E.Breitentol<>'') then begin
    Lib_Berechnungen:ToleranzZuWerten(Ein.E.Breitentol,var vMin, var vMax);
    vMin # vMin + Ein.P.Breite;
    vMax # vMax + Ein.P.Breite;
    if (Ein.E.Breite<vMin) or (Ein.E.Breite>vMax) then
      StartWof(cWofDatei, cWofDatenAbweichend, 'Breite: WE.'+aint(Ein.E.Eingangsnr));
  end;

  if ("Ein.E.Längentol"<>'') then begin
    Lib_Berechnungen:ToleranzZuWerten("Ein.E.Längentol",var vMin, var vMax);
    vMin # vMin + "Ein.P.Länge";
    vMax # vMax + "Ein.P.Länge";
    if ("Ein.E.Länge"<vMin) or ("Ein.E.Länge">vMax) then
      StartWof(cWofDatei, cWofDatenAbweichend, 'Länge: WE.'+aint(Ein.E.Eingangsnr));
  end;

  StartWof(cWofDatei, cWofNeuerSatz,'WE.'+aint(Ein.E.Eingangsnr));

  if (Lib_SFX:Check_AFX('EDI.Analysen.Buche.Post')) and (AFX.Prozedur<>'') then begin
    // var aWofErr, var aErr
    Call(AFX.Prozedur, true, var aWofErr, var aErr);
    if (aErr<>'') then RETURN false;
  end;

  RETURN true;
end;



//========================================================================
//  Start
//
//========================================================================
SUB Start(
  opt aFileName   : alpha(1000);
) : logic;
local begin
  vDoc      : int;
  vRoot     : int;
  vOK       : logic;
  vErr      : alpha(1000);
  vDebugpath  : alpha;
end;
begin

  if (aFileName = '') then begin
  
  
   // Datei auswählen
    if  (App_Main:Entwicklerversion()) then
      vDebugpath   # 'c:\debug\';
    
   
    // Datei auswählen
    aFileName # Lib_FileIO:FileIO(_WINCOMFILEOPEN,gMDI,vDebugpath,'XML-Dateien |*.xml');
    if (aFileName = '') then
      RETURN true;
  end;

  vErr # EDI_Base:OpenXML(aFileName, 'Analysen', var vDoc, var vRoot);
  if (vErr<>'') then begin
    EDIERROR(999, cWofDateiDefekt, vErr);
    RETURN false;
  end;

  vOK # ProcessRoot(vRoot);

  // Aufräumen...
  EDI_Base:CloseXML(vDoc);

  RETURN vOK;
end;



//========================================================================
//  call EDI_Analysen:CreateDemoFile
//========================================================================
sub CreateDemoFile()
local begin
  vFile   : alpha(255);
  vDoc    : handle;
  vNode   : handle;
  vNode2  : handle;
  vNode3  : handle;
  vI,vJ   : int;
  vF,vF2  : float;
  vVersionsJahr : caltime;
  
end
begin

  /* Dateiauswahl */
//  vFile # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML Dateien|*.xml' );
//  if ( vFile = '' ) then
//    RETURN;

  vFile # 'D:\test\Analysen.xml';
  if ( StrCnv( StrCut( vFile, StrLen( vFile ) - 3, 4 ), _strLower ) != '.xml' ) then
    vFile # vFile + '.xml'

  /* XML Initialisierung */
  vDoc       # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vVersionsJahr->vpDate  # today;
  vDoc->CteInsertNode( '', _xmlNodeComment, ' Stahl Control '+Aint(vVersionsJahr->vpYear)+' - ANALYSEN');

  /* Projektdaten */
  vNode # vDoc->Lib_XML:AppendNode( 'Analysen' );
  NewNodeA(vNode, 'Version', '1.000'  );

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=2) do begin
    vF # vF + 1.0;
    vNode2 # vNode->Lib_XML:AppendNode( 'Satz' );
      NewNodeI(vNode2, 'Lieferantennr', 5555 );
      NewNodeA(vNode2, 'Bestellung', '1234/'+aint(vI) );
      NewNodeI(vNode2, 'Bestellnummer', 1234 );
      NewNodeI(vNode2, 'Bestellposition', vI );
      NewNodeA(vNode2, 'Bestellung_Refcode', '54321/'+aint(vI) );

      NewNodeI(vNode2, 'Materialnr', 4710+vI );
      NewNodeA(vNode2, 'Werksnr', '123ABC'+aint(vI) );
      NewNodeA(vNode2, 'Chargennr', 'BCABCA'+aint(vI) );
      NewNodeA(vNode2, 'Coilnr', 'D44XMP'+aint(vI) );
      NewNodeA(vNode2, 'Ringnr', 'XXAA'+aint(vI) );

      NewNodeI(vNode2, 'Stueck', 1 );
      NewNodeF(vNode2, 'Gewicht_Netto', 4500.0 + vF*500.0);
      NewNodeF(vNode2, 'Gewicht_Brutto', 4500.0 + vF*500.0);

      NewNodeA(vNode2, 'Guete', 'DD 11' );
      NewNodeF(vNode2, 'Dicke', 2.0);
      NewNodeF(vNode2, 'Breite', 1000.0);
      NewNodeF(vNode2, 'Laenge', 1200.0);

      NewNodeD(vNode2, 'Datum', 24.12.2017);
      NewNodeA(vNode2, 'Lageradresse_Refcode', '9988776655' );
      NewNodeA(vNode2, 'Ursprungsland', 'USA' );
      NewNodeA(vNode2, 'Lieferscheinnr', '4440004/12' );
      NewNodeA(vNode2, 'Bemerkung', 'nicht verpackt' );

      _NewMessNode(vNode2, 'RP02', '12');
      _NewMessNode(vNode2, 'RP1', '34');
      _NewMessNode(vNode2, 'Zugfestigkeit', '56');
      _NewMessNode(vNode2, 'Streckgrenze', '78');
      _NewMessNode(vNode2, 'A80', '10');
      _NewMessNode(vNode2, 'Koernung', '23');
      _NewMessNode(vNode2, 'Haerte', '56');

      _NewMessNode(vNode2, 'RauhigkeitOS', '11');
      _NewMessNode(vNode2, 'RauhigkeitUS', '13');

      _NewMessNode(vNode2, 'C',   '1.1');
      _NewMessNode(vNode2, 'SI',  '1.2');
      _NewMessNode(vNode2, 'MN',  '1.3');
      _NewMessNode(vNode2, 'P',   '1.4');
      _NewMessNode(vNode2, 'S',   '1.5');
      _NewMessNode(vNode2, 'AL',  '1.6');
      _NewMessNode(vNode2, 'CR',  '1.7');
      _NewMessNode(vNode2, 'V',   '1.8');
      _NewMessNode(vNode2, 'NB',  '1.9');
      _NewMessNode(vNode2, 'TI',  '2.1');
      _NewMessNode(vNode2, 'N',   '2.2');
      _NewMessNode(vNode2, 'CU',  '2.3');
      _NewMessNode(vNode2, 'NI',  '2.4');
      _NewMessNode(vNode2, 'MO',  '2.5');
      _NewMessNode(vNode2, 'B',   '2.6');
      _NewMessNode(vNode2, 'X1',  '2.7');

    // Satz
  END;


  /* XML Abschluss */
  vDoc->XmlSave(vFile,_XmlSaveDefault,0, _CharsetUTF8);

  vDoc->CteClear( true );
  vDoc->CteClose();
end;



//========================================================================
// Test
//    Call EDI_Analysen:Test
//========================================================================
sub Test();
local begin
  vPath   : alpha(1000);
  vDirHdl : int;
  vName   : alpha(1000);
end;
begin
  /*
  vPath   # 'c:\debug\';
  vName   # 'Analysen.xml';
  */
  lib_Debug:StartBlueMode();
  Start();
end;




/*
-------------------------------------------------------------------
2022-06-14 ST

Verschiebt eine importierte Datei in den angegebenen Ergebnisordner
und hängt der Importierten Daten in Timestamp an.
-------------------------------------------------------------------
*/
sub _MoveToResultfolderxxx(
  aSrcFile  : alpha(250);   // Vollständiger Dateipfad zur Quelldatei
  aType     : alpha         // Name des Zielordners, innerhalnb des Importverzeichnisses
  ) : logic;
local begin
  vRet        : logic;
  vHdl        : int;
  vDestPath   : alpha(250);
  vDestFile   : alpha(250);
end
begin
  vRet #  true;

  vDestpath # FsiSplitname(aSrcFile,_FsiNameP);

  vDestpath # vDestpath + aType;
  vDestFile # Lib_FileIO:StampFilename(FsiSplitname(aSrcFile,_FsiNameNE));

  vDestpath # Lib_FileIO:CorrectPath(vDestpath);
  Lib_FileIO:CreateFullPath(vDestpath);

  if (Lib_FileIO:FsiCopy(aSrcFile,vDestpath+vDestFile,true) != _rOK) then
    vRet # false

  RETURN vRet;
end;


/*
-------------------------------------------------------------------
2022-06-14 ST

Prüft ob die übergebene Datei importiert werden soll oder nicht.
-------------------------------------------------------------------
*/
sub __acceptFile(aFile : alpha(250)) : logic
local begin
  vExt  : alpha;
end
begin
  vExt  # StrCnv(FsiSplitName(aFile,_FsiNameE),_StrLower);
  RETURN (vExt =^ 'xml');
end;


/*
-------------------------------------------------------------------
2022-06-14 ST
Jobfunktion zum zeitlich geplanten Import von EDI Dateien

aPara für den Jobserver enthält den Pfad zum Basisverzeichnis, sowie
die erlaubte Dateieindung.


EDI_Einkauf:JOB.Import
-------------------------------------------------------------------
*/
sub JOB.Import(
  aPara           : alpha;     //  Parameter aus Job Eintrag: Pfad zum Quellordner
  opt aJobGruppe  : int
) : logic
local begin
  vRet            : logic;
  vHdl            : int;
  vPath           : alpha;
  vFilename       : alpha;
  vLastFilename   : alpha;
  vFullPathToFile : alpha(250);
end
begin
  vRet # true;

  vPath # Str_Token(aPara,'|',1);
  vPath # Lib_FileIO:CorrectPath(vPath);

  // 14.11.22 MK
  if (aJobGruppe = 0) then
    Job.Gruppe # 1
  else
    Job.Gruppe # aJobGruppe;

  // Lesen aller .dat-Dateien im aktuellen Verzeichnis
  vHdl # FsiDirOpen(vPath,_FsiAttrHidden);
  if (vHdl <= 0) then begin
    vRet # false;
  end else begin

    // Dateiliste durchgehen und verschieben
    vFileName # vHdl->FsiDirRead();
    WHILE vFileName <> '' DO BEGIN

      // nur XML Dateien einlesen
      if (__acceptFile(vFilename) = false) then begin
        vFileName  # vHdl->FsiDirRead(); // Nächste Datei
        CYCLE;
      end;

      if (vFileName = vLastFilename) then begin
        // Datei doppelt einlesen? --> fehler
        vRet # false;
        BREAK;
      end;

      vFullPathToFile # vPath+vFileName;

      if (Start(vFullPathToFile)) then
        EDI_Einkauf:_MoveToResultfolder(vFullPathToFile,'Erledigt');
      else
        EDI_Einkauf:_MoveToResultfolder(vFullPathToFile,'Fehlerhaft');

      vLastFilename # vFilename;
      vFileName     # vHdl->FsiDirRead(); // Nächste Datei
    END;

    vHdl->FsiDirClose();
  end;

  RETURN vRet;
end;


/*
========================================================================
2022-09-15  ST                           Proj. 2396/102

========================================================================
*/
sub Filescanner.Import(aPara : alpha(1000)) : logic
local begin
  vRet        : logic;
  Erx         : int;
  vErrLogFile : alpha(500);
end
begin
  Lib_Error:_Flush();

  if (Start(aPara)) then begin
    EDI_Einkauf:_MoveToResultfolder(aPara,'Erledigt');
    vRet # true;
  end else begin
    // Quelldatei veschieben
    EDI_Einkauf:_MoveToResultfolder(aPara,'Fehlerhaft');

    // Errorlog erstellen und veschieben
    vErrLogFile # FsiSplitName(aPara,_FsiNameP) + 'Fehlerhaft\' +
                  FsiSplitName(aPara,_FsiNameN);
    vErrLogFile # Lib_FileIO:StampFilename(vErrLogFile);
    vErrLogFile # vErrLogFile + 'ERROR.TXT';
    Lib_Error:OutputToFile(StrCnv(vErrLogFile,_StrUpper));
    vRet # false;
  end;


  // Weiter mit normalem Programmfluss
  AfxRes # _rOk;
  ErrSet(_rOK);
  RETURN vRet;
end



/*
========================================================================
2022-09-15  ST

EDI_Analysen:Dialog.Import
========================================================================
*/
sub Dialog.Import() : logic
local begin
  vRet        : logic;
  Erx         : int;
  vErrLogFile : alpha(500);
  vFullFilename : alpha(1000);
  vDebugpath  : alpha(1000);
end
begin
  Lib_Error:_Flush();

 // Datei auswählen
  if  (App_Main:Entwicklerversion()) then
    vDebugpath   # 'c:\debug\';
  
  
  vFullFilename # Lib_FileIO:FileIO(_WINCOMFILEOPEN,gMDI,vDebugpath  ,'XML-Dateien |*.XML');
  if (vFullFilename = '') then
    RETURN false;

  if (Start(vFullFilename)) then begin
    EDI_Einkauf:_MoveToResultfolder(vFullFilename,'Erledigt');
    vRet # true;
  end else begin
    // Quelldatei veschieben
    EDI_Einkauf:_MoveToResultfolder(vFullFilename,'Fehlerhaft');

    // Errorlog erstellen und veschieben
    vErrLogFile # FsiSplitName(vFullFilename,_FsiNameP) + 'Fehlerhaft\' +
                  FsiSplitName(vFullFilename,_FsiNameN);
    vErrLogFile # Lib_FileIO:StampFilename(vErrLogFile);
    vErrLogFile # vErrLogFile + 'ERROR.TXT';
    Lib_Error:OutputToFile(StrCnv(vErrLogFile,_StrUpper));
    vRet # false;
  end;

  // Weiter mit normalem Programmfluss
  AfxRes # _rOk;
  ErrSet(_rOK);
  RETURN vRet;
end



//========================================================================
