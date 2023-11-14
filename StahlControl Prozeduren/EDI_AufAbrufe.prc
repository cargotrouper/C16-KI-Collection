@A+
//===== Business-Control =================================================
//
//  Prozedur  EDI_AufAbrufe
//                    OHNE E_R_G
//  Info      VDA4905
//
//
//  16.08.2018  AH  Erstellung der Prozedur
//  29.08.2018  AH  Erweiterungen
//  05.04.2022  AH  ERX
//
//  mögliche spezial Anker:
//                  EDI.AufAbrufe.Process    : im ROOT: aNode : int; var "\", "", var vErr ; alpha
//                  EDI.AufAbrufe.Process    : im Wert: 0, var aName : alpha, aInhalt : alpha; var vErr ; alpha
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_EDI

define begin
  cTEST : true
  cDemoFile : 'd:\test\Abrufe_aus_sc.xml'
  cTageBuffer         : -5
  cAttachPos          : false
  cPruefeZaehler      : true

  cWoFDatei                     : 401

  cWoFAbrufNeu                  : 10100
  cWoFAbrufNeuVergangenheit     : 10101
  cWoFAbrufPlusOhneMat          : 10110
  cWoFAbrufPlusMitMat           : 10111
  cWoFAbrufPlusZuKnappOhneMat   : 10112
  cWoFAbrufPlusZuKnappMitMat    : 10113

  cWoFAbrufMinusOhneMat         : 10120
  cWoFAbrufMinusMitMat          : 10121
  cWoFAbrufMinusZuKnappOhneMat  : 10122
  cWoFAbrufMinusZuKnappMitMat   : 10123

  cWoFAbrufNullOhneMat          : 10130
  cWoFAbrufNullMitMat           : 10131
  cWoFAbrufNullZuKnappOhneMat   : 10132
  cWoFAbrufNullZuKnappMitMat    : 10133
  
  cWoFAbrufNichtGefunden        : 10190
  cWoFDateiDefekt               : 10199
end;

declare ProcessFile(aFileName : alpha(1000)) : logic;
declare ProcessRoot(aRoot : int) : logic;


//========================================================================
//  call EDI_AufAbrufe:CreateDemoFile
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
  vDat    : date;
end
begin

  /* Dateiauswahl */
  vFile # cDemoFile;
  if (vFile='') then begin
    vFile # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML Dateien|*.xml' );
    if ( vFile = '' ) then
      RETURN;
  end;

  if ( StrCnv( StrCut( vFile, StrLen( vFile ) - 3, 4 ), _strLower ) != '.xml' ) then
    vFile # vFile + '.xml'

  /* XML Initialisierung */
  vDoc       # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vDoc->CteInsertNode( '', _xmlNodeComment, ' Stahl Control 2017 - ABRUFE');

  /* Projektdaten */
  vNode # vDoc->Lib_XML:AppendNode( 'Abrufe' );
  NewNodeA(vNode, 'Version', '1.000'  );
  NewNodeI(vNode, 'Kundennr', 12345);

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=2) do begin
    vNode2 # vNode->Lib_XML:AppendNode( 'Satz' );
      NewNodeComment(vNode2,'fortlaufende Nummer pro Rahmen');
      NewNodeI(vNode2, 'Zaehlerstand', 30 + vI);
      NewNodeA(vNode2, 'MEH', 'kg' );
      NewNodeA(vNode2, 'Rahmen', '5000050/1');
      NewNodeI(vNode2, 'Rahmennr', 5000050 );
      NewNodeI(vNode2, 'Rahmenpos', 1 );
      NewNodeComment(vNode2,'ENTWEDER explizite Nr. ODER über Refcode');
      NewNodeA(vNode2, 'RahmenBestellnr_Refcode', 'abc123/'+aint(vI) );
      NewNodeA(vNode2, 'Abruf', '6004222/1');
      NewNodeI(vNode2, 'Abrufnr', 6004222 );
      NewNodeI(vNode2, 'Abrufpos', 1 );
      NewNodeA(vNode2, 'AbrufBestellnr_Refcode', 'xyz/'+aint(vI) );
    
      NewNodeComment(vNode2,'Mindestens ein Feinabruf');
      vDat # today;
      FOR vJ # 1
      LOOP inc(vJ)
      WHILE (vJ<=3) do begin
        vNode3 # vNode2->Lib_XML:AppendNode( 'Feinabruf' );
          NewNodeA(vNode3, 'Termin_Code', '444444' );
          NewNodeComment(vNode3,'Code ODER folgendes');
          NewNodeA(vNode3, 'Termin_Typ',  'KW');
          NewNodeI(vNode3, 'Termin_Zahl', 40+vI);
          NewNodeI(vNode3, 'Termin_Jahr', 2018);
          NewNodeD(vNode3, 'Datum', today);
          NewNodeF(vNode3, 'Menge', 20000.0);
        vDat->vmDayModify(7);
      END;
      // Feinabruf
      
    // Satz
  END;

  /* XML Abschluss */
//debugx('JsonSave:'+aint(JsonSave(vDoc,'d:\debug\testjson.txt',_JsonSaveDefault)));
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
  if (gUsername='AH') then
    vName # cDemoFile;
    
  if (vName='') then begin
    vName # Lib_FileIO:FileIO( _winComFileOpen, gMDI, '', 'XML Dateien|*.xml' );
    if ( vName = '' ) then
      RETURN;
  end;

lib_Debug:StartBlueMode();

  ProcessFile(vName);
  RETURN;
  
//  vPath   # 'd:\debug\';
//  vName   # 'Auftraegexml';
//  vDirHdl # FsiDirOpen(vPath+'*.out', _FsiAttrHidden);
//  vName   # vDirHdl->FsiDirRead(); // erste Datei
//  WHILE (vName != '') do begin
//    Start(vPath+vName);
//    vName # vDirHdl->FsiDirRead();
//  end;
//  FsiDirClose
end;


//========================================================================
//========================================================================
sub _TerminCodeAlsTyp(
  aCode         : alpha;
  var aZeitRaum : logic;
  var aTyp      : alpha;
  var aZahl     : int;
  var aJahr     : int;
  var aTermin   : date;
  var aWofErr   : int;
  var aErr      : alpha) : logic
local begin
  vA            : alpha;
  vJJ, vMM, vTT : word;
end;
begin

  if (aCode='') then begin
    aTyp # 'ENDE';
    RETURN true;
  end;

  // letzter Abruf
  if (aCode='000000') then begin
    aTyp # 'ENDE';
    RETURN true;
  end;

  // Kein Bedarf
  if (aCode='222222') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  // Rückstand
  if (aCode='333333') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  // Sofort
  if (aCode='444444') then begin
    aZeitraum # n;
    aTyp      # 'DA';
    aTermin   # today;
    Lib_Berechnungen:ZahlJahr_aus_Datum(aTermin, aTyp, var vMM, var vJJ);
    aZahl # vMM;
    aJahr # vJJ;
    RETURN true;
  end;

  // Zeiträume?
  if (aCode='555555') then begin
    aZeitraum # y;
    aTyp      # 'EGAL';
    RETURN true;
  end;

  // Vorschau
  if (aCode='999999') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  Try begin
    vJJ # cnvia(StrCut(aCode,1,2))+2000;
    vMM # cnvia(StrCut(aCode,3,2));
    vTT # Cnvia(StrCut(aCode,5,2));

    // Zeitraum?
    if (aZeitraum) then begin
      // Wochenbereich?
      if (vJJ<>0) and (vMM<>0) and (vTT<>0) then begin
        aTyp    # 'KW';
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var vMM, var vJJ, var aTermin);
        aJahr   # vJJ;
        aZahl   # vMM;
        RETURN true;
      end;

      // Monat?
      if (vJJ<>0) and (vMM<>0) and (vTT=0) then begin
        aTyp    # 'MO';
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var vMM, var vJJ, var aTermin);
        aJahr   # vJJ;
        aZahl   # vMM;
        RETURN true;
      end;

      // Woche?
      if (vJJ<>0) and (vMM=0) and (vTT<>0) then begin
        aTyp    # 'KW';
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var vTT, var vJJ, var aTermin);
        aJahr   # vJJ;
        aZahl   # vTT;
        RETURN true;
      end;

      RETURN false;
    end;


    // fester Termin?
    if (vJJ<>0) and (vMM<>0) and (vTT<>0) then begin
      aTyp    # 'DA';
      aTermin # DateMake(vTT, vMM, vJJ);
      Lib_Berechnungen:ZahlJahr_aus_Datum(aTermin, aTyp, var vMM,var vJJ);
      aZahl # vMM;
      aJahr # vJJ;
      RETURN true;
    end;
    //
  end;

  if (ErrGet()<>_ErrOK) then begin
  end;

  aErr # 'Keine gültiger TerminCode '+aCode;
  RETURN false;
end;
  

//========================================================================
//========================================================================
sub _CheckZaehler(
  aRahmnr   : int;
  aRahmPos  : int;
  aZaehler  : int)  // neue Nummer
  : logic
local begin
  Erx       : int;
  vKey      : alpha;
end;
begin


  // 30 Zeichen      123456789012345678901234567890
  vKey            # 'EDIAUFABRUF_'+aint(aRahmNr)+'/'+aint(aRahmPos);
  Prg.Nr.Name     # vKey;
  if (RecRead(902,1,0)>_rLocked) then begin
    RecBufClear(902);
    Prg.Nr.Name         # vKey;
    Prg.Nr.Nummer       # aZaehler + 1;
    Prg.Nr.Bezeichnung  # 'nächste EDI-AufAbruf-Import-Nr';
    Erx # RekInsert(902,_reclock,'AUTO');
    RETURN (Erx=_rOK);
  end;

  if (Prg.Nr.Nummer<>aZaehler) then RETURN false;
  Erx # RecRead(902,1,_recLock);
  Prg.Nr.Nummer       # Prg.Nr.Nummer + 1;
  Erx # RekReplace(902,_recunlock,'AUTO');

  RETURN (Erx=_rOK);
end;


//========================================================================
//  _SucheRahmenPos
//      anhand Nr/Pos oder Referenz-Nummer + KdNr
//========================================================================
sub _SucheRahmenPos(
  aKdNr         : int;
  aRahmen       : alpha;
  aRef          : alpha;
  var aRahmNr   : int;
  var aRahmPos  : int;
  var aWofErr   : int;
  var aErr      : alpha) : logic;
local begin
  Erx       : int;
  vA        : alpha;
  vA1, vA2  : alpha;
end;
begin
/***
  if (cTest) then begin
    FOR Erx # RecRead(400,1,_recFirst)
    LOOP Erx # RecRead(400,1,_recNext)
    WHILE (Erx<=_rLocked) do begin
      if (Auf.LiefervertragYN) then begin
        Erx # RecLink(401,400,9,_recFirst);   // 1. Pos holen
        aRahmNr   # Auf.P.Nummer;
        aRahmPos  # Auf.P.Position;
        aKdNr   # Auf.P.Kundennr;
        BREAK;
      end;
    END;
  end;
***/
  if (aRahmNr=0) and  (aRef='') and (aRahmen='') then begin
    aErr # 'Keine Rahmen-Nummer angegeben';
    RETURN false;
  end;

  // Anhand Rahmenstring finden?
  if (aRahmNr=0) and (aRahmen<>'') then begin
    vA # Str_Token(aRahmen,'/',1);
    if (TryI(vA, var aRahmNr)=false) then begin
      aErr # 'Keine gültiger Rahmen "'+aRahmen+'"';
      RETURN false;
    end;
    vA # Str_Token(aRahmen,'/',2);
    if (TryI(vA, var aRahmPos)=false) then begin
      aErr # 'Keine gültige Rahmen "'+aRahmen+'"';
      RETURN false;
    end;
  end;

  // anhand Ref-Nummer finden?
  if (aRahmNr=0) and (aRef<>'') and (aKdNr<>0) then begin
    aRahmPos # 0;
    // gezielt Pos. suchen...
    RecBufClear(401);
    Auf.P.Best.Nummer # aRef;
    FOR Erx # RecRead(401,9,0)
    LOOP Erx # RecRead(401,9,_recNext)
    WHILE (Erx<=_rMultikey) and (Auf.P.Best.Nummer=aRef) do begin
//debugx('KEY401');
      if (Auf.P.Kundennr=aKdNr) then begin
        Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
        if (Erx>_rLocked) or (Auf.LiefervertragYN=false) then CYCLE;
        aRahmNr   # Auf.P.Nummer;
        aRahmPos  # Auf.P.Position;
        BREAK;
      end;
    END;

    // über den Kopf suchen?
    if (aRahmNr=0) then begin
      if (Lib_Strings:Strings_Count(aRef,'/')<>1) then begin
        aErr # 'Keine zugehöriger Rahmen gefunden';
        RETURN false;
      end;

      vA1 # Str_Token(aRef,'/',1);
      vA2 # Str_Token(aRef,'/',2);

      // Kopf aus Token1 ermitteln...
      RecBufClear(400);
      Auf.Best.Nummer # vA1;
      FOR Erx # RecRead(400,4,0)
      LOOP Erx # RecRead(400,4,_recNext)
      WHILE (Erx<=_rMultikey) and (Auf.Best.Nummer=vA1) do begin
        if (Auf.Kundennr=aKdNr) then begin
          aRahmNr   # Auf.Nummer;
          BREAK;
        end;
      END;
      if (aRahmNr=0) then begin
        aErr # 'Keine aktiver Rahmen mit Referenz"'+aRef+'" gefunden';
        RETURN false;
      end;

      // Pos. anhang Token2 suchen...
      FOR Erx # RecLink(401,400,9,_recFirst)  // Posten loopen...
      LOOP Erx # RecLink(401,400,9,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (Auf.P.Best.Nummer=vA2) and (vA2<>'') then begin
          aRahmPos  # Auf.P.Position;
          BREAK;
        end;
      END;
      if (aRahmPos=0) then begin
        if (TryI(vA2, var aRahmPos)=false) then begin
          aErr # 'Keine aktiver Rahmen mit Referenz"'+aRef+'" gefunden';
          RETURN false;
        end;
      end;
    end;  // über Kopf
  end;  // anhand Ref-Nummer

  if (aRahmNr=0) or (aRahmPos=0) then begin
    aErr # 'Keine zugehöriger Rahmen gefunden';
    RETURN false;
  end;

  Auf.P.Nummer    # aRahmNr;
  Auf.P.Position  # aRahmPos;
  Erx # RecRead(401,1,0);
  if (Erx<>_rOK) or ("Auf.P.Löschmarker"='*') then begin
    aErr # 'Keine aktiver Rahmen "'+aint(aRahmNr)+'/'+aint(aRahmPos)+'" gefunden';
    RETURN false;
  end;

  Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
  if (Erx<>_rOK) then begin
    aErr # 'Keine aktiver Rahmen "'+aint(aRahmNr)+'/'+aint(aRahmPos)+'" gefunden';
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  _SucheAbrufPos
//      anhand Nr/Pos oder geladener RahmenPos + Termin + Ref
//========================================================================
sub _SucheAbrufPos(
  aKdNr         : int;
  var aRahmNr   : int;
  var aRahmPos  : int;
  aAbruf        : alpha;
  aAbrufNr      : int;
  aAbrufPos     : int;
  aRef          : alpha;
  aTerminTyp    : alpha;
  aTerminZahl   : int;
  aTerminJahr   : int;
  aTerminDat    : date;
  var aKopfNr   : int;    // Result, wenn NEUER Abruf, aber anderer ähnlicher Kopf
  aCodePostFix  : alpha;
) : logic;
local begin
  Erx         : int;
  vA          : alpha;
  vA1, vA2    : alpha;
  vCode       : alpha;
end;
begin

  if (aAbrufNr=0) and (aRef='') and ((aTerminTyp='') or
    ((aTerminZahl=0) and (aTerminJahr=0) and (aTerminDat=0.0.0))) then begin
    Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', 'Zeile ???');
    RETURN false;
  end;
  
  // Fehlercode erstellen...
  vCode # '(Kd:'+aint(aKdNr);
  if (aRahmNr<>0) or (aRahmPos<>0) then
    vCode # vCode + '; R:'+aint(aRahmNr)+'/'+aint(aRahmPos);
  if (aAbruf<>'') then
    vCode # vCode + '; Abruf:'+aAbruf
  else if (aAbrufNr<>0) or (aAbrufPos<>0) then
    vCode # vCode + '; Abruf:'+aint(aAbrufNr)+'/'+aint(aAbrufPos);
  if (aRef<>''); then
    vCode # vCode + '; Ref:'+aRef;
  vCode # vCode + '; Term:'+aTerminTyp;
  if (aTerminDat<>0.0.0) then
    vCode # vCode + ' '+cnvad(aTerminDat)
  else
    vCode # vCode + ' '+aint(aTerminZahl)+'/'+aint(aTerminJahr);
  vCode # vCode + '; M:'+aCodePostFix+')';
    
    

  if (aAbrufNr=0) and (aAbruf<>'') then begin
    vA # Str_Token(aAbruf,'/',1);
    if (TryI(vA, var aAbrufNr)=false) then begin
      Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', vCode+'SC-Nr. unbekannt: '+aAbruf);
      RETURN false;
    end;
    vA # Str_Token(aAbruf,'/',2);
    if (TryI(vA, var aAbrufPos)=false) then begin
      Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', vCode+'SC-Nr. unbekannt: '+aAbruf);
      RETURN false;
    end;
  end;

  // Abruf anhand Ref-Nummer finden?
  if (aAbrufNr=0) and (aRef<>'') then begin
    aAbrufPos # 0;

//debugx('suche Abruf zu '+aTerminTyp+' '+cnvad(aTerminDat));

    // gezielt Pos. suchen...
    RecBufClear(401);
    Auf.P.Best.Nummer # aRef;
    FOR Erx # RecRead(401,9,0)
    LOOP Erx # RecRead(401,9,_recNext)
    WHILE (Erx<=_rMultikey) and (Auf.P.Best.Nummer=aRef) do begin
//debugx('KEY401');

      if (Auf.P.Kundennr<>aKdNr) then CYCLE;
      if (Auf.P.AbrufAufNr=0) or (Auf.P.AbrufAufPos=0) then CYCLE;
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (Erx>_rLocked) or (Auf.AbrufYN=false) then CYCLE;

      if (aRahmNr=0) or (aRahmPos=0) then begin
        aRahmnr   # Auf.P.AbrufAufNr;
        aRahmPos  # Auf.P.AbrufAufPos;
//debugx('wahrscheinlich R'+aint(aRahmnr)+'/'+aint(aRahmPos))
      end;
     
      if (Auf.P.Termin1W.Art<>aTerminTyp) or (Auf.P.Termin1Wunsch<>aTerminDat) then CYCLE;
//debugx('found KEY401');
      aAbrufNr   # Auf.P.Nummer;
      aAbrufPos  # Auf.P.Position;
      BREAK;
    END;
  end;


  // konkreter Abruf genannt?
  if (aAbrufNr<>0) or (aAbrufPos<>0) then begin
    Auf.P.Nummer    # aAbrufNr;
    Auf.P.Position  # aAbrufPos;
    Erx # RecRead(401,1,0);
    if (Erx<>_rOK) or ("Auf.P.Löschmarker"='*') then begin
      Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', 'Keine aktiver Abruf "'+aint(aAbrufNr)+'/'+aint(aAbrufPos)+'" gefunden! '+vCode);
      RETURN false;
    end;

    Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
    if (Erx<>_rOK) then begin
      Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', 'Keine aktiver Abruf"'+aint(aAbrufnr)+'/'+aint(aAbrufPos)+'" gefunden! '+vCode);
      RETURN false;
    end;
//debugx('nimm KEY401');
    RETURN true;
  end;

  
  // kein KONKRETER Abruf -> dann über Rahmen suchen...
  if (aRahmNr=0) or (aRahmpos=0) then begin
    Lib_Workflow:Trigger(999, cWoFAbrufNichtGefunden, '', '', 'kein Rahmen angegeben! '+vCode);
    RETURN false;
  end;

  // Abrufspos. suchen
  RecBufClear(401);
  Auf.P.AbrufAufNr  # aRahmNr;
  Auf.P.AbrufAufPos # aRahmPos;
//debugx('suche abrufe zu '+aint(aRahmNr)+'/'+aint(aRahmpos));
  FOR Erx # RecRead(401,14,0)
  LOOP Erx # RecRead(401,14,_recNext)
  WHILE (Erx<=_rMultikey) and (Auf.P.AbrufAufNr=aRahmNr) and (Auf.P.AbrufAufPos=aRahmPos) do begin
//debugx('KEY401');
    if (Auf.P.Nummer=aRahmNr) and (Auf.P.Position=aRahmPos) then CYCLE;
    if (Auf.P.Kundennr <> aKdNr) then CYCLE;

    if (aRef<>'') then
      if (aRef<>Auf.P.Best.Nummer) then CYCLE;

    if (aKopfNr=0) then begin
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (Erx<=_rLocked) and ("Auf.Löschmarker"='') and (Auf.AbrufYN) then begin
        aKopfNr # Auf.Nummer;
      end;
    end;
     
    if (Auf.P.Termin1W.Art=aTerminTyp) and (Auf.P.Termin1Wunsch=aTerminDat) then begin
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (Erx<=_rLocked) and (Auf.AbrufYN) then begin
        aKopfNr # Auf.Nummer;
//debugx('FOUND KEY401');
        RETURN true;
      end;
    end;
  END;

  // also NEUER Abruf:
//debugx('NEUER ABRUF');
  RecBufClear(400);
  RecBufClear(401);
  RETURN true;
end;


//========================================================================
//========================================================================
sub _VerbucheAbruf(
  aRahmNr     : int;
  aRahmPos    : int;
  aTyp        : alpha;
  aZahl       : int;
  aJahr       : int;
  aDat        : date;
  aMenge      : float;
  aMEH        : alpha;
  aKopfNr     : int;
  aRef        : alpha;
  var aWofErr : int;
  var aErr    : alpha) : logic;
local begin
  Erx         : int;
  v400        : int;
  v401        : int;
  vOK         : logic;
  vPos        : int;
  vAlteMenge  : float;
  vDat        : date;
  vDelta      : float;
  vMitMat     : Logic;
end;
begin
//debugx('Verbuche zu Rahm'+aint(aRahmNr)+'/'+aint(aRahmPos)+'   KEY401');

  // neuer Abruf??
  if (Auf.P.Nummer=0) then begin
    Auf.P.Nummer    # aRahmNr;
    Auf.P.Position  # aRahmPos;
    Erx # RecRead(401,1,0); // Rahmenposition holen
    if (Erx>_rLocked) then begin
      aErr #'Rahmenposition nicht gefunden';
      RETURN false;
    end;

    // an komplett neuer Auftragskopf?
    if (aKopfNr=0) or (cAttachPos=false) then begin
      Auf.Nummer    # aRahmNr;
      Erx # RecRead(400,1,0); // Rahmenkopf holen
      if (Erx>_rLocked) then begin
        aErr # 'Rahmenkopf nicht gefunden';
        RETURN false;
      end;
    
      aKopfNr # Lib_Nummern:ReadNummer('Auftrag');
      if (aKopfNr<>0) then Lib_Nummern:SaveNummer()
      else begin
        aErr # 'Auftragsnummer nicht lesbar!';
        RETURN false;
      end;
      Auf.Nummer            # aKopfNr;
      Auf.Datum             # today;
      Auf.AbrufYN           # true;
      Auf.LiefervertragYN   # false;
      if (aRef<>'') then Auf.Best.Nummer # aRef;

      Auf.Anlage.Datum      # Today;
      Auf.Anlage.Zeit       # now;
      Auf.Anlage.User       # gUsername;
      Erx # RekInsert(400,0,'JOB');
      if (Erx<>_rOK) then begin
        aErr # 'AufKopf nicht speicherbar';
        RETURN false;
      end;
      vPos # 1;
//debugx('neuer kopf:'+aint(aKopfNr));
    end
    else begin
//debugx('anhängen...');
      v400 # RecBufCreate(400);
      v401 # RecBufCreate(401);
      v400->Auf.Nummer # aKopfNr;
      Erx # RekLink(v401,v400,9,_recLast); // letzte Position holen
      if (Erx<=_rLocked) then vPos # v401->Auf.P.Position + 1
      else vPos # 1;
      RecBufDestroy(v400);
      RecBufDestroy(v401);
//debugx('extend um pos:'+aint(aKopfNr)+'/'+aint(vPos));
    end;

    Auf.P.Nummer        # aKopfNr;
    Auf.P.Position      # vPos;

    // neue Pos anlegen...
    Auf_P_SMain:CopyRahmen2Abruf(aRahmNr, aRahmPos, true);

    Auf.P.AbrufAufNr    # aRahmNr;
    Auf.P.AbrufAufPos   # aRahmPos;
    
    if (aRef<>'') then Auf.P.Best.Nummer # aRef;

    Auf.P.Termin1W.Art  # aTyp;
    Auf.P.Termin1W.Zahl # aZahl;
    Auf.P.Termin1W.Jahr # aJahr;
    Auf.P.Termin1Wunsch # aDat;
    if (aMEH<>Auf.P.MEH.Einsatz) then begin
      aErr # 'falsche MEH im Rahmen'+aMeh+' '+auf.p.meh.einsatz;
      RETURN false;
    end;

    Auf.P.Menge           # aMenge;
    Auf.P.Flags           # 'A';

//    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMixMat(Auf.P.Wgr.Dateinr)) then begin
    if (Auf.P.MEH.Einsatz='Stk') then "Auf.P.Stückzahl" # Cnvif(Auf.P.Menge);
    if (Auf.P.MEH.Einsatz='kg') then "Auf.P.Gewicht" # rnd(Auf.P.Menge, Set.Stellen.Gewicht);
    if (Auf.P.MEH.Einsatz='t') then "Auf.P.Gewicht" # rnd(Auf.P.Menge / 1000.0, Set.Stellen.Gewicht);
    if (Auf.P.MEH.Wunsch='kg') then   Auf.P.Menge.Wunsch  # Auf.P.Gewicht
    else if (Auf.P.MEH.Wunsch='Stk') then  Auf.P.Menge.Wunsch  # cnvfi("Auf.P.Stückzahl")
    else if (Auf.P.MEH.Wunsch=Auf.P.MEH.Einsatz) then Auf.P.Menge.Wunsch  # Auf.P.Menge
    else Auf.P.Menge.Wunsch # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Wunsch);
    Auf.P.Prd.Rest        # Auf.P.Menge - Auf.P.Prd.LFS;
    Auf.P.Prd.Rest.Stk    # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
    Auf.P.Prd.Rest.Gew    # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew;
    Auf_Data:SumAufpreise();
    Auf_K_Data:SumKalkulation();
    Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht)

    Auf.P.Anlage.Datum    # Today;
    Auf.P.Anlage.Zeit     # now;
    Auf.P.Anlage.User     # gUsername;

    if (Auf_Data:PosInsert(0,'JOB')<>_rOK) then begin
      aErr # 'AufPos nicht speicherbar';
      RETURN false;
    end;
      
//debugx('ins Pos KEY401 zu rahmen '+aint(auf.p.Abrufaufnr)+'/'+aint(auf.p.abrufaufpos));
//    Lib_Workflow:Trigger(401, 401, _WOF_KTX_NEU);
    vOk # Auf_Data:VerbucheAbruf(y);
    if (vOK=false) then begin
      aErr # 'Abruf nicht verbuchbar';
      RETURN false;
    end;
      

    if (Auf.P.Termin1Wunsch<today) then begin
      if (cWofAbrufNeuVergangenheit<>0) then Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufNeuVergangenheit, '');
    end
    else begin
      if (cWofAbrufNeu<>0) then Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufNeu, '');
    end;

//debugx('neuer Abruf!');
    RETURN true;
  end;


  // Abruf bereits vorhanden........................

  // Keine Änderung?
  if (Auf.P.Menge=aMenge) then RETURN true;

  // Mengenänderung...
  PtD_Main:Memorize(401);
  Erx # RecRead(401,1,_recLock);

  vDelta # (aMenge - Auf.P.Menge);
  Auf.P.Menge       # aMenge;
  Auf.P.Flags       # 'A';

//    if (Wgr_Data:IstMat(Auf.P.Wgr.Dateinr)) or (Wgr_Data:IstMixMat(Auf.P.Wgr.Dateinr)) then begin
  if (Auf.P.MEH.Einsatz='Stk') then "Auf.P.Stückzahl" # Cnvif(Auf.P.Menge);
  if (Auf.P.MEH.Einsatz='kg') then "Auf.P.Gewicht" # rnd(Auf.P.Menge, Set.Stellen.Gewicht);
  if (Auf.P.MEH.Einsatz='t') then "Auf.P.Gewicht" # rnd(Auf.P.Menge / 1000.0, Set.Stellen.Gewicht);
  if (Auf.P.MEH.Wunsch='kg') then   Auf.P.Menge.Wunsch  # Auf.P.Gewicht
  else if (Auf.P.MEH.Wunsch='Stk') then  Auf.P.Menge.Wunsch  # cnvfi("Auf.P.Stückzahl")
  else if (Auf.P.MEH.Wunsch=Auf.P.MEH.Einsatz) then Auf.P.Menge.Wunsch  # Auf.P.Menge
  else Auf.P.Menge.Wunsch # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Wunsch);
  Auf.P.Prd.Rest        # Auf.P.Menge - Auf.P.Prd.LFS;
  Auf.P.Prd.Rest.Stk    # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
  Auf.P.Prd.Rest.Gew    # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew;

  Erx # Auf_Data:PosReplace(_recUnlock,'JOB');
  if (Erx<>_rOk) then begin
    aErr # 'Abrufpos nicht änderbar';
    RETURN false;
  end;

  // Mengenänderung?
  vAlteMenge  # ProtokollBuffer[401]->Auf.P.Menge;
  PtD_Main:Compare(401);

  // nötige Verbuchungen im Artikel durchführen...
  Auf_Data:VerbucheArt(Auf.P.Artikelnr, vAlteMenge, "Auf.P.Löschmarker");

  vOk # Auf_Data:VerbucheAbruf(n);
  if (vOK=false) then begin
    aErr # 'Abrufsänderung nicht verbuchbar';
    RETURN false;
  end;
   


  vMitMat # (Auf.P.Prd.Plan<>0.0) or (Auf.P.Prd.VSB<>0.0) or (Auf.P.Prd.VSAuf<>0.0) or (Auf.P.Prd.LFS<>0.0) or
        (Auf.P.Prd.Rech<>0.0) or (Auf.P.Prd.Reserv<>0.0) or (Auf.P.Prd.zuBere<>0.0);
          // ggf. löschen oder Mindern-Workflow?
  if ("Auf.P.Löschmarker"='') then begin
    // Keine Menge mehr und Auftrag noch "jüngfräulich"? -> dann löschen
    if (Auf.P.Menge=0.0) and (vMitMat=false) then begin
      RecRead(401,1,_recLock);
      Auf.P.Flags # '';
      RekReplace(401);
      Auf_P_Subs:ToggleLoeschmarker(n);
    end;
  end;

  // Zeitfenster zu knapp?
  vDat # Lib_Berechnungen:AddWerkTage(Auf.P.Termin1Wunsch, cTageBuffer);
//Lib_Debug:Protokoll('!!!EDI','Auftragstermin '+cnvad(Auf.P.Termin1Wunsch)+' '+aint(cTageBuffer)+'= '+cnvad(vdat));
  if (today>=vDat) then begin
//    Lib_Workflow:Trigger(cWofDatei, cWoFAbrufZuKnapp, '');
    if (aMenge=0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullZuKnappMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullZuKnappOhneMat, '');
    end
    else if (vDelta>0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufPlusZuKnappMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufPlusZuKnappOhneMat, '');
    end
    else if (vDelta<0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufMinusZuKnappMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufMinusZuKnappOhneMat, '');
    end;
  end
  else begin
  // Zeitlich ok
//      Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufModified, '');
    if (aMenge=0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullOhneMat, '');
    end
    else if (vDelta>0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufPlusMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufPlusOhneMat, '');
    end
    else if (vDelta<0.0) then begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufMinusMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufMinusOhneMat, '');
    end;
  end;
//debugx('modified');

  RETURN true;
end;


//========================================================================
//========================================================================
sub _ProcessRoot(
  aRoot         : int
  ) : logic;
local begin
  Erx       : int;
  vAFX      : alpha;
  vOK       : logic;
  vWofErr   : int;
  vErr      : alpha(1000);
  vName     : alpha;

  vSatz     : int;
  vAnzSatz  : int;

  vFein     : int;
  vAnzFein  : int;

  vKdNr     : int;
  vZaehler  : int;
  vMEH      : alpha;
  vRahm     : alpha;
  vRahmRef  : alpha;
  vRahmNr   : int;
  vRahmPos  : int;
  vAbruf    : alpha;
  vAbrufRef : alpha;
  vAbrufNr  : int;
  vAbrufPos : int;

  vTermZR   : logic;
  vTermCode : alpha;
  vTermTyp  : alpha;
  vTermZahl : int;
  vTermJahr : int;
  vTermDat  : date;
  vMenge    : float;
  vKopfNr   : int;
end;
begin

  if (Lib_SFX:Check_AFX('EDI.AufAbrufe.Process')) then
    vAFX # AFX.Prozedur;

  // PFLICHTNODES:
  if (NodeI(aRoot, var vErr, 'Kundennr',         var vKdNr)=false) or (vKdNr=0) then begin
    EDIERROR(999, cWofKundeFehlt, vErr);
    RETURN false;
  end;

  Adr.Kundennr # vKdNr;
  Erx # RecRead(100,2,0); // Kunde holen
  if (Erx>_rMultikey) then begin
    EDIERROR(999, cWofKundeFehlt, 'KdNr '+aint(vKdNr));
    RETURN false;
  end;


  TRANSON;

  vWofErr # cWofDateiDefekt;

  // Sätze loopen...
  vOK # true;
  FOR vSatz # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'Satz')
  LOOP vSatz # aRoot->CteRead( _cteChildList | _cteSearch | _CteNext, vSatz, 'Satz')
  WHILE (vSatz<>0) and (vOK) do begin
    inc(vAnzSatz);
    vOK # false;

    if (vAFX<>'') then begin
      // Typ, aNode, var vErr
      vName # '\';
      Call(vAFX, vSatz, var vName, '', var vErr);
      if (vErr<>'') then BREAK;
    end;


    // PFLICHTNODES:
    if (NodeI(vSatz, var vErr, 'Zaehlerstand',            var vZaehler)=false) then BREAK;
    if (NodeA(vSatz, var vErr, 'MEH',                     var vMEH)=false) then BREAK;
    
    // OPTIONAL:
    NodeA(vSatz, var vErr, 'Rahmen',                  var vRahm);
    NodeA(vSatz, var vErr, 'RahmenBestellnr_Refcode', var vRahmRef);
    NodeI(vSatz, var vErr, 'Rahmennr',                var vRahmNr);
    NodeI(vSatz, var vErr, 'Rahmenpos',               var vRahmPos);
    NodeA(vSatz, var vErr, 'Abruf',                   var vAbruf);
    NodeA(vSatz, var vErr, 'AbrufBestellnr_Refcode',  var vAbrufRef);
    NodeI(vSatz, var vErr, 'Abrufnr',                 var vAbrufNr);
    NodeI(vSatz, var vErr, 'Abrufpos',                var vAbrufPos);

    if (vRahm='') and (vRahmRef='') and (vRahmNr=0) and (vRahmPos=0) then begin
  //    vRahmRef # vAbrufRef;
      RecBufClear(400);
      RecBufClear(401);
    end
    else begin
      if (_SucheRahmenPos(vKdNr, vRahm, vRahmRef, var vRahmNr, var vRahmPos, var vWofErr, var vErr)=false) then BREAK;
    end;
    
//debugx('zu Rahmen KEY401')

    // Feinabrufe loopen...
    vAnzFein # 0;
    vOK # true;
    FOR vFein # vSatz->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'Feinabruf')
    LOOP vFein # vSatz->CteRead( _cteChildList | _cteSearch | _CteNext, vFein, 'Feinabruf')
    WHILE (vFein<>0) and (vOK) do begin
      vOK # false;
      inc(vAnzFein);

      NodeA(vFein, var vErr, 'Termin_Code',           var vTermCode);
      NodeA(vFein, var vErr, 'Termin_Typ',            var vTermTyp);
      NodeI(vFein, var vErr, 'Termin_Zahl',           var vTermZahl);
      NodeI(vFein, var vErr, 'Termin_Jahr',           var vTermJahr);
      NodeD(vFein, var vErr, 'Datum',                 var vTermDat);
      if (NodeF(vFein, var vErr, 'Menge',             var vMenge)=false) then BREAK;
      
      if (vTermTyp='') then begin
        vTermZR # true;
        if (_TerminCodeAlsTyp(vTermCode, var vTermZR, var vTermTyp, var vTermZahl, var vTermJahr, var vTermDat, var vWofErr, var vErr)=false) then BREAK;
      end;
      
      if (_SucheAbrufPos(vKdNr, var vRahmNr, var vRahmPos, vAbruf, vAbrufNr, vAbrufPos, vAbrufRef, vTermtyp, vTermZahl, vTermJahr, vTermDat, var vKopfNr, anum(vMenge,0)+vMEH)) then begin
        if (vAnzFein=1) and (cPruefeZaehler) then begin
          if (_CheckZaehler(vRahmnr, vRahmPos, vZaehler)=false) then begin
            vErr # 'Zählerstand falsch';
            BREAK;
          end;
        end;
        if (_VerbucheAbruf(vRahmNr, vRahmPos, vTermTyp, vTermZahl, vTermJahr, vTermDat, vMenge, vMEH, vKopfNr, vAbrufRef, var vWofErr, var vErr)=false) then BREAK;
      end;

      vOK # true;
    END;
    if (vAnzFein>0) and (vOK=false) then BREAK;

    vOK # true;
  END;  // Satz

  if (vOK=false) then begin
    TRANSBRK;
    EDIERROR(999, vWofErr, 'Satz '+aint(vAnz)+': '+vErr);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  ProcessFile
//
//========================================================================
SUB ProcessFile(
  aFileName   : alpha(1000);
) : logic;
local begin
  vDoc      : int;
  vRoot     : int;
  vOK       : logic;
  vErr      : alpha(1000);
end;
begin
//TRANSON;
  vErr # EDI_Base:OpenXML(aFileName, 'Abrufe', var vDoc, var vRoot);
//TRANSBRK;
  if (vErr<>'') then begin
    EDIERROR(999, cWofDateiDefekt, vErr);
    RETURN false;
  end;

  vOK # _ProcessRoot(vRoot)

  // Aufräumen...
  EDI_Base:CloseXML(vDoc);

  RETURN vOK;
end;

//========================================================================