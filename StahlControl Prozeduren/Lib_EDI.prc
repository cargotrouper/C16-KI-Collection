@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_EDI
//                    OHNE E_R_G
//  Stand     10/2011
//
//  Info      EDL=ExterneDienstLeister (Lohn)
//
//
//  27.10.2014  AH  Erstellung der Prozedur
//  30.10.2014  ST  sub RecToXMLFile hinzugefügt Prj. 1326/408
//  11.03.2015  AH  COM an Excel
//  09.05.2016  AH  Erweiterungen
//  26.10.2016  AH  Erweiterungen
//  27.07.2021  AH  ERX
//  2022-08-22  AH  Edit: für Datei 833/231
//
//  Subprozeduren
//

/**
TODO:
- cDatenempfaengerNr
- cDatensenderNr
- cFrachtfuehrer (Spediteuer)
- Zähler der DFÜ pro Adresse

- Datum+Zeit Aufladung, Abladung, Versand, Ankunft
- Gewichte mit Ladehilfsmittel
- (Frankaturschlüssel)
- (Paketanzahl)
- Transportmittel (LKW; Schiff etc.)
- Abladestelle
- Versandart
- WerkKunde
- Art.Nummer vom Kunde
- Urpsrungsland
- Präferenzstatus
- Zollgut Ja/Nein
**/

//========================================================================
@I:Def_Global


define begin
  cTageBuffer         : -5
  cWoFDatei           : 401

  cWoFAbrufNeu                  : 100
  cWoFAbrufNeuVergangenheit     : 101
//  cWoFAbrufModified   : 101
//  cWoFAbrufZuKnapp    : 102
  cWoFAbrufPlusOhneMat          : 110
  cWoFAbrufPlusMitMat           : 111
  cWoFAbrufPlusZuKnappOhneMat   : 112
  cWoFAbrufPlusZuKnappMitMat    : 113

  cWoFAbrufMinusOhneMat         : 120
  cWoFAbrufMinusMitMat          : 121
  cWoFAbrufMinusZuKnappOhneMat  : 122
  cWoFAbrufMinusZuKnappMitMat   : 123

  cWoFAbrufNullOhneMat          : 130
  cWoFAbrufNullMitMat           : 131
  cWoFAbrufNullZuKnappOhneMat   : 132
  cWoFAbrufNullZuKnappMitMat    : 133

  cWoFDateiDefekt               : 199


  cDatenempfaengerNr  : 54321
  cDatensenderNr      : 87654321
  cFrachtfuehrer      : 'Winner Spedition'
  cAbladestelle       : 'Empfang3'

  EDI_READ(a)            : begin  vA # VDA_ReadData(vFile,a);   end;
  //VDA_READXML(a,b,c)     : _XmlFromVDA(vNode,a,b,vFile,c);

  // XML Lesen
  XML_GetNodeType(a)  : Lib_XML:GetNodeType(a)
  XML_GetValA(a,b)    : Lib_XML:GetValue(a,b);
  XML_GetValI(a,b)    : Lib_XML:GetValueI(a,b);
  XML_GetValI16(a,b)  : Lib_XML:GetValueI16(a,b);
  XML_GetValF(a,b)    : Lib_XML:GetValueF(a,b);
  XML_GetValB(a,b)    : Lib_XML:GetValueB(a,b);
  XML_GetValD(a,b)    : Lib_XML:GetValueD(a,b);
  XML_GetValT(a,b)    : Lib_XML:GetValueT(a,b);
end;

local begin
  gFileHdl  : int;
  gActNode  : int;

  gCount511 : int;
  gCount512 : int;
  gCount513 : int;
  gCount514 : int;
  gCount515 : int;
  gCount517 : int;
  gCount518 : int;
  gCount519 : int;

  gCount711 : int;
  gCount712 : int;
  gCount713 : int;
  gCount714 : int;
  gCount715 : int;
  gCount716 : int;
  gCount717 : int;
  gCount718 : int;
  gCount719 : int;
end;

declare _SaveNodeToXMLFile(aXmlDok   : int; aFilename : alpha(4000)) : int;

//========================================================================
sub MussA(
  aName : alpha;
  aWert : alpha;
  aLen  : int);
begin
//  TextLineWrite(gProto,TextInfo(gProto,_TextLines)+1,StrFmt(aWert, aLen, _strEnd) ,_TextLineInsert)
  if (gActNode<>0) then begin
    aName # Str_replaceAll(aName,' ','_');
    gActNode->Lib_XML:AppendAttributeNode(aName, aWert);
    RETURN;
  end;

  FSIWrite(gFileHdl, StrFmt(aWert, aLen, _strEnd));
end;

//========================================================================
sub KannA(
  aName : alpha;
  aWert : alpha;
  aLen  : int);
begin
//  TextLineWrite(gProto,TextInfo(gProto,_TextLines)+1,StrFmt(aWert, aLen, _strEnd) ,_TextLineInsert)
  if (gActNode<>0) then begin
    aName # Str_replaceAll(aName,' ','_');
    gActNode->Lib_XML:AppendAttributeNode(aName, aWert);
    RETURN;
  end;
  FSIWrite(gFileHdl, StrFmt(aWert, aLen, _strEnd));
end;

//========================================================================
sub MussN(
  aName : alpha;
  aWert : int;
  aLen  : int);
begin
//  TextLineWrite(gProto,TextInfo(gProto,_TextLines)+1,cnvai(aWert, _FmtNumNoGroup|_FmtNumLeadZero,0,aLen),_TextLineInsert)
  if (gActNode<>0) then begin
    aName # Str_replaceAll(aName,' ','_');
    gActNode->Lib_XML:AppendAttributeNode(aName, aint(aWert));
    RETURN;
  end;
  FSIWrite(gFileHdl, cnvai(aWert, _FmtNumNoGroup|_FmtNumLeadZero,0,aLen));
end;

//========================================================================
sub KannN(
  aName : alpha;
  aWert : int;
  aLen  : int);
begin
//  TextLineWrite(gProto,TextInfo(gProto,_TextLines)+1,cnvai(aWert, _FmtNumNoGroup|_FmtNumLeadZero,0,aLen),_TextLineInsert)
  if (gActNode<>0) then begin
    aName # Str_replaceAll(aName,' ','_');
    gActNode->Lib_XML:AppendAttributeNode(aName, aint(aWert));
    RETURN;
  end;
  FSIWrite(gFileHdl, cnvai(aWert, _FmtNumNoGroup|_FmtNumLeadZero,0,aLen));
end;

//========================================================================
Sub MussD(
  aName : alpha;
  aDat  : date)
local begin
  vA  : alpha;
end;
begin
  if (aDat>0.0.0) then
    vA # Cnvai(DateYear(aDat)-100,_FmtNumLeadZero,0,2) + Cnvai(DateMonth(aDat),_FmtNumLeadZero,0,2) + Cnvai(DateDay(aDat),_FmtNumLeadZero,0,2);
  MussA(aName, vA, 6);
end;


//========================================================================
Sub KannD(
  aName : alpha;
  aDat  : date)
local begin
  vA  : alpha;
end;
begin
  if (aDat>0.0.0) then
    vA # Cnvai(DateYear(aDat)-100,_FmtNumLeadZero,0,2) + Cnvai(DateMonth(aDat),_FmtNumLeadZero,0,2) + Cnvai(DateDay(aDat),_FmtNumLeadZero,0,2);
  MussA(aName, vA, 6);
end;


//========================================================================
Sub MussT(
  aName : alpha;
  aTim  : Time)
local begin
  vA  : alpha;
end;
begin
  vA # Cnvai(TimeHour(aTim),_FmtNumLeadZero,0,2) + Cnvai(TimeMin(aTim),_FmtNumLeadZero,0,2);
  MussA(aName, vA, 4);
end;

//========================================================================
Sub KannT(
  aName : alpha;
  aTim  : Time)
local begin
  vA  : alpha;
end;
begin
  vA # Cnvai(TimeHour(aTim),_FmtNumLeadZero,0,2) + Cnvai(TimeMin(aTim),_FmtNumLeadZero,0,2);
  MussA(aName, vA, 4);
end;


//========================================================================
sub ConvertLKZ(aLKZ : alpha) : int;
begin

  case aLKZ of
    'F'                :  RETURN 001        // Frankreich
    'NL'               :  RETURN 003        // Niederlande
    'D','DE'           :  RETURN 004        // Deutschland
    'I'                :  RETURN 005        // Italien
    'GB'               :  RETURN 006        // Vereinigtes Königreich
    'IRL'              :  RETURN 007        // Irland
    'DK'               :  RETURN 008        // Dänemark
    'GR'               :  RETURN 009        // Griechenland
// TODO
// Portugal
// Spanien
// Belgien
// Luxemburg
// Ceuta
// Melilla
// Island
// Norwegen
// Schweden
// Finnland
// Liechtenstein
// Österreich
// Schweiz
// Färöer
// Andorra
// Gibraltar
// Vatikanstadt
// Malta
// San Marino
// Türkei
// Estland
// Lettland
// Litauen
// Polen
// Tschechische Republik
// Slowakei
// Ungarn
// Rumänien
// Bulgarien
// Albanien
// Ukraine
// Belarus
// Republik Moldau
// Russische Föderation
    otherwise             RETURN 000;       // unbkeannt
  end;
end;

//========================================================================
sub ConvertPraeferenz(aLfENr : int) : alpha;
begin
//G  =  Ursprung der EU; präferenzberechtigt mit allen Ländern mit Ursprungsabkommen
//W  =  Ursprungsware der EG; präferenzberechtigt im Warenverkehr mit den EFTA-Staaten
//F  =  Finnland
//C  =  Schweiz
//O  =  Österreich
//S  =  Schweden
//N  =  Norwegen
//I  =  Island
//X  =  noch nicht überprüft, keine Ursprungsware
// TODO
  if (aLfeNr=0) then RETURN 'X';
  RETURN 'G';
end;



//========================================================================
//========================================================================
sub _ReadNode(
  aRoot     : int;
  aName     : alpha;
  var aNode : int;) : logic;
begin
  aNode # aRoot->CteRead( _cteChildList | _cteSearchCI | _cteFirst, 0, aName);
  RETURN (aNode=0);
end;


//========================================================================
//========================================================================
sub ProcessNode(aRoot : int)
local begin
  vNode               : int;
end;
begin
  // Attribute des Knotens
  if (aRoot->spAttribCount > 0) then begin
    FOR   vNode # aRoot->CteRead(_CteAttribTree | _CteFirst);
    LOOP  vNode # aRoot->CteRead(_CteAttribTree | _CteNext, vNode);
    WHILE (vNode != 0) do begin
//debug('A:'+vNode->spname);
      ProcessNode(vNode);
    END;
  end;

  // Untergeordnete Objekte des Knotens
  if (aRoot->spChildCount > 0) then begin
    FOR  vNode # aRoot->CteRead(_CteFirst | _CteChildList)
    LOOP vNode # aRoot->CteRead(_CteNext  | _CteChildList, vNode)
    WHILE (vNode > 0) DO BEGIN
      if (vNode->spname='') then CYCLE;
  //    vB # lib_XML:GetAttributeValue (vNode,'name');
  //    vA # lib_XML:GetAttributeValue (vNode,'value');
  //debug(vB+' = '+vA);
//debug('B:'+vNode->spname);
      ProcessNode(vNode);
    END;  // XML Loop
  end;

end;


//========================================================================
//========================================================================
sub _AbrufDatumToSC(
  aWert         : int;
  var aZeitraum : logic;
  var aTyp      : alpha;
  var aZahl     : word;
  var aJahr     : word;
  var aTermin   : date;
) : logic;
local begin
  vA            : alpha;
  vJJ, vMM, vTT : int;
end;
begin

  if (aWert=0) then begin
    aTyp # 'ENDE';
    RETURN true;
  end;

  vA # cnvai(aWert, _FmtNumNoGroup|_FmtNumLeadZero,0,6);

  // letzter Abruf
  if (vA='000000') then begin
    aTyp # 'ENDE';
    RETURN true;
  end;

  // Kein Bedarf
  if (vA='222222') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  // Rückstand
  if (vA='333333') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  // Sofort
  if (vA='444444') then begin
    aZeitraum # n;
    aTyp      # 'DA';
    aTermin   # today;
    Lib_Berechnungen:ZahlJahr_aus_Datum(aTermin, aTyp, var aZahl,var aJahr);
    RETURN true;
  end;

  // Zeiträume?
  if (vA='555555') then begin
    aZeitraum # y;
    aTyp      # 'EGAL';
    RETURN true;
  end;

  // Vorschau
  if (vA='999999') then begin
    aTyp # 'EGAL';
    RETURN true;
  end;

  Try begin
    vJJ # cnvia(StrCut(vA,1,2))+2000;
    vMM # cnvia(StrCut(vA,3,2));
    vTT # Cnvia(StrCut(vA,5,2));

    // Zeitraum?
    if (aZeitraum) then begin
      // Wochenbereich?
      if (vJJ<>0) and (vMM<>0) and (vTT<>0) then begin
        aTyp    # 'KW';
        aJahr   # vJJ;
        aZahl   # vMM;
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var aZahl, var aJahr, var aTermin);
        RETURN true;
      end;

      // Monat?
      if (vJJ<>0) and (vMM<>0) and (vTT=0) then begin
        aTyp    # 'MO';
        aJahr   # vJJ;
        aZahl   # vMM;
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var aZahl, var aJahr, var aTermin);
        RETURN true;
      end;

      // Woche?
      if (vJJ<>0) and (vMM=0) and (vTT<>0) then begin
        aTyp    # 'KW';
        aJahr   # vJJ;
        aZahl   # vTT;
        Lib_Berechnungen:Datum_aus_ZahlJahr(aTyp, var aZahl, var aJahr, var aTermin);
        RETURN true;
      end;

      RETURN false;
    end;


    // fester Termin?
    if (vJJ<>0) and (vMM<>0) and (vTT<>0) then begin
      aTyp    # 'DA';
      aTermin # DateMake(vTT, vMM, vJJ);
      Lib_Berechnungen:ZahlJahr_aus_Datum(aTermin, aTyp, var aZahl,var aJahr);
      RETURN true;
    end;
    //
  end;
  if (ErrGet()<>_ErrOK) then RETURN false;


  RETURN false;
end;


//========================================================================
//========================================================================
sub _UpdateAbruf(
  aRahmen : int;
  aPos    : int;
  aTyp    : alpha;
  aZahl   : int;
  aJahr   : int;
  aDat    : date;
  aMenge  : float;
  aMEH    : alpha;
  var aNr : int) : alpha;
local begin
  Erx         : int;
  v400        : int;
  v401        : int;
  vAlterKopf  : int;
  vOK         : logic;
  vPos        : int;
  vAlteMenge  : float;
  vDat        : date;
  vDelta      : float;
  vMitMat     : Logic;
end;
begin

  Auf.Nummer    # aRahmen;
  Erx # RecRead(400,1,0); // Rahmenkopf holen
  if (erx>_rLocked) then RETURN 'Rahmenkopf nicht gefunden';

  // Auftragspos. suchen
  RecBufClear(401);
  Auf.P.AbrufAufNr  # aRahmen;
  Auf.P.AbrufAufPos # aPos;
  Erx # RecRead(401,14,0);
  WHILE (erx<=_rMultikey) and (Auf.P.AbrufAufNr=aRahmen) and (Auf.P.AbrufAufPos=aPos) do begin
    vAlterKopf # Auf.P.Nummer;
    if (Auf.P.Termin1W.Art=aTyp) and (Auf.P.Termin1Wunsch=aDat) and (Auf.P.Kundennr=Auf.Kundennr) then begin
//debug('gibts schon');
      vOK # y;
      BREAK;
    end;
    Erx # RecRead(401,14,_recNext);
  END;

  // neuer Abruf??
  if (vOK=false) then begin
    Auf.P.Nummer    # aRahmen;
    Auf.P.Position  # aPos;
    Erx # RecRead(401,1,0); // Rahmenposition holen
    if (erx>_rLocked) then RETURN 'Rahmenposition nicht gefunden';

    // an anderen Auftrag anhängen?
    if (aNr=0) then aNr # vAlterKopf;

    // Kopf anlegen...
    if (aNr=0) then begin
      aNr # Lib_Nummern:ReadNummer('Auftrag');
      if (aNr<>0) then Lib_Nummern:SaveNummer()
      else RETURN 'Auftragsnummer nicht lesbar!';
      Auf.Nummer            # aNr;
      Auf.Datum             # today;
      Auf.AbrufYN           # true;
      Auf.LiefervertragYN   # false;

      Auf.Anlage.Datum      # Today;
      Auf.Anlage.Zeit       # now;
      Auf.Anlage.User       # gUsername;
      Erx # RekInsert(400,0,'JOB');
      if (erx<>_rOK) then RETURN 'AufKopf nicht speicherbar';
      vPos # 1;
//debug('neuer kopf:'+aint(aNr));
    end
    else begin
//debug('anhängen...');
      v400 # RecBufCreate(400);
      v401 # RecBufCreate(401);
      v400->Auf.Nummer # aNr;
      Erx # RekLink(v401,v400,9,_recLast); // letzte Position holen
      if (erx<=_rLocked) then vPos # v401->Auf.P.Position + 1
      else vPos # 1;
      RecBufDestroy(v400);
      RecBufDestroy(v401);
//debug('extend um pos:'+aint(aNr)+'/'+aint(vPos));
    end;

    Auf.P.Nummer        # aNr;
    Auf.P.Position      # vPos;

    // neue Pos anlegen...
    Auf_P_SMain:CopyRahmen2Abruf(aRahmen, aPos, true);

    Auf.P.AbrufAufNr    # aRahmen;
    Auf.P.AbrufAufPos   # aPos;

    Auf.P.Termin1W.Art  # aTyp;
    Auf.P.Termin1W.Zahl # aZahl;
    Auf.P.Termin1W.Jahr # aJahr;
    Auf.P.Termin1Wunsch # aDat;
    if (aMEH<>Auf.P.MEH.Einsatz) then RETURN 'falsche MEH im Rahmen'+aMeh+' '+auf.p.meh.einsatz;

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

    if (Auf_Data:PosInsert(0,'JOB')<>_rOK) then RETURN 'AufPos nicht speicherbar';
//debug('ins Pos KEY401 zu rahmen '+aint(auf.p.Abrufaufnr)+'/'+aint(auf.p.abrufaufpos));
//    Lib_Workflow:Trigger(401, 401, _WOF_KTX_NEU);
    vOk # Auf_Data:VerbucheAbruf(y);
    if (vOK=false) then RETURN 'Abruf nicht verbuchbar';

    if (Auf.P.Termin1Wunsch<today) then begin
      if (cWofAbrufNeuVergangenheit<>0) then Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufNeuVergangenheit, '');
    end
    else begin
      if (cWofAbrufNeu<>0) then Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufNeu, '');
    end;

//debugx('neuer Abruf!');
    RETURN '';
  end;


  // Abruf bereits vorhanden........................

  // Keine Änderung?
  if (Auf.P.Menge=aMenge) then RETURN '';

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
  if (Erx<>_rOk) then RETURN 'Abrufpos nicht änderbar';

  // Mengenänderung?
  vAlteMenge  # ProtokollBuffer[401]->Auf.P.Menge;
  PtD_Main:Compare(401);

  // nötige Verbuchungen im Artikel durchführen...
  Auf_Data:VerbucheArt(Auf.P.Artikelnr, vAlteMenge, "Auf.P.Löschmarker");

  vOk # Auf_Data:VerbucheAbruf(n);
  if (vOK=false) then RETURN 'Abrufsänderung nicht verbuchbar';


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
Lib_Debug:Protokoll('!!!EDI','Auftragstermin '+cnvad(Auf.P.Termin1Wunsch)+' '+aint(cTageBuffer)+'= '+cnvad(vdat));
  if (today>=vDat) then begin
//    Lib_Workflow:Trigger(cWofDatei, cWoFAbrufZuKnapp, '');
    if (vDelta>0.0) then begin
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
    end
    else begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullZuKnappMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullZuKnappOhneMat, '');
    end;
  end
  else begin
  // Zeitlich ok
//      Lib_Workflow:Trigger(cWoFDatei, cWoFAbrufModified, '');
    if (vDelta>0.0) then begin
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
    end
    else begin
      if (vMitMat) then
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullMitMat, '')
      else
        Lib_Workflow:Trigger(cWofDatei, cWoFAbrufNullOhneMat, '');
    end;
  end;
//debug('modified');

  RETURN '';
end;


//========================================================================
//========================================================================
sub ReadXML511(
  aRoot         : int;
  var aKdNr     : alpha;
  var aDfueAlt  : int;
  var aDfueNeu  : int;
  ) : alpha;
local begin
  vNode : int;
  vI    : int;
end;
begin
  if (_ReadNode(aRoot, 'vda4905_511_01', var vNode)) then RETURN 'Satzart';
  XML_GetValI(vNode, var vI);
  if (vI<>511) then RETURN 'Satzart';
  if (_ReadNode(aRoot, 'vda4905_511_03', var vNode)) then RETURN 'Kundennr.';
  XML_GetValA(vNode, var aKdNr);
  if (_ReadNode(aroot, 'vda4905_511_05', var vNode)) then RETURN 'TransfernrAlt';
  XML_GetValI(vNode, var aDfueAlt);
  if (_ReadNode(aRoot, 'vda4905_511_06', var vNode)) then RETURN 'TransfernrNeu';
  XML_GetValI(vNode, var aDfueNeu);
end;


//========================================================================
//========================================================================
sub ReadXML512(
  aRoot           : int;
  var aBestellNr  : alpha;
  var aKontierung : alpha;
  var aMEH        : alpha;
  var aAbrufNrAlt : int;
  var aAbrufNrNeu : int;
  ) : alpha;
local begin
  vNode : int;
  vI    : int;
end;
begin
  if (_ReadNode(aRoot, 'vda4905_512_01', var vNode)) then RETURN 'Satzart';
  XML_GetValI(vNode, var vI);
  if (vI<>512) then RETURN 'Satzart';
  if (_ReadNode(aRoot, 'vda4905_512_04', var vNode)) then RETURN 'AbrufnrNeu';
  XML_GetValI(vNode, var aAbrufnrNeu);
  if (_ReadNode(aRoot, 'vda4905_512_06', var vNode)) then RETURN 'AbrufnrAlt';
  XML_GetValI(vNode, var aAbrufnrAlt);
  if (_ReadNode(aroot, 'vda4905_512_10', var vNode)) then RETURN 'Bestellnr.';
  XML_GetValA(vNode, var aBestellNr);
  if (_ReadNode(aroot, 'vda4905_512_13', var vNode)) then RETURN 'MEH';
  XML_GetValA(vNode, var aMEH);
  aMeh # StrCnv(aMeh,_strlower);
  if (_ReadNode(aroot, 'vda4905_512_18', var vNode)) then RETURN 'Kontierungsschluessel';
  XML_GetValA(vNode, var aKontierung);

  // INMET:
  vI # cnvia(aKontierung);
  aKontierung # cnvai(vI, _FmtNumLeadZero|_FmtNumNoGroup,0,5);    // 5 stellen mit führenden Nullen
end;


//========================================================================
//========================================================================
sub ReadXML513(
  aRoot           : int;
  aNr             : int;
  var aZeitraum   : logic;
  var aTyp        : alpha;
  var aZahl       : word;
  var aJahr       : word;
  var aTermin     : date;
  var aMenge      : float;
  ) : alpha;
local begin
  vNode : int;
  vI    : int;
  vA    : alpha;
end;
begin
  if (_ReadNode(aRoot, 'vda4905_513_01', var vNode)) then RETURN 'Satzart';
  XML_GetValI(vNode, var vI);
  if (vI<>513) then RETURN 'Satzart';

  if (aNr>=1) and (aNr<=5) then begin
    vA # 'vda4905_513_'+cnvai(6+(aNr*2),_FmtNumNoGroup|_FmtNumLeadZero,0,2);
//    if (_ReadNode(aRoot, vA, var vNode)) then RETURN 'fehlt AbrufDatum'+aint(aNr);
    if (_ReadNode(aRoot, vA, var vNode)) then RETURN '';
    vI # 0;
    XML_GetValI(vNode, var vI);
    if (_AbrufDatumToSC(vI, var aZeitraum , var aTyp, var aZahl, var aJahr, var aTermin)=false) then
      RETURN 'falsch AbrufDatum'+aint(aNr);
    vA # 'vda4905_513_'+cnvai(7+(aNr*2),_FmtNumNoGroup|_FmtNumLeadZero,0,2);
//    if (_ReadNode(aRoot, vA, var vNode)) then RETURN 'AbrufMenge'+aint(aNr);
    if (_ReadNode(aRoot, vA, var vNode)) then RETURN '';
    XML_GetValF(vNode, var aMenge);
  end;

end;


//========================================================================
//========================================================================
sub ReadXML514(
  aRoot           : int;
  aNr             : int;
  var aZeitraum   : logic;
  var aTyp        : alpha;
  var aZahl       : word;
  var aJahr       : word;
  var aTermin     : date;
  var aMenge      : float;
  ) : alpha;
local begin
  vNode : int;
  vI    : int;
  vA    : alpha;
end;
begin
  aMenge # 0.0;
  if (_ReadNode(aRoot, 'vda4905_514_01', var vNode)) then RETURN 'Satzart';
  XML_GetValI(vNode, var vI);
  if (vI<>514) then RETURN 'Satzart';

  if (aNr>=1) and (aNr<=8) then begin
    vA # 'vda4905_514_'+cnvai(1+(aNr*2),_FmtNumNoGroup|_FmtNumLeadZero,0,2);
//    if (_ReadNode(aRoot, vA, var vNode)) then RETURN 'AbrufDatum'+aint(aNr+5);
    if (_ReadNode(aRoot, vA, var vNode)) then RETURN '';
    vI # 0;
    XML_GetValI(vNode, var vI);
    if (_AbrufDatumToSC(vI, var aZeitraum , var aTyp, var aZahl, var aJahr, var aTermin)=false) then
      RETURN 'AbrufDatum'+aint(aNr+5);
    vA # 'vda4905_514_'+cnvai(2+(aNr*2),_FmtNumNoGroup|_FmtNumLeadZero,0,2);
//    if (_ReadNode(aRoot, vA, var vNode)) then RETURN 'AbrufMenge'+aint(aNr+5);
    if (_ReadNode(aRoot, vA, var vNode)) then RETURN '';
    XML_GetValF(vNode, var aMenge);
  end;

end;


//========================================================================
//========================================================================
sub ReadXML519(
  aRoot : int) : alpha;
local begin
  vNode : int;
  vI    : int;
end;
begin
  if (_ReadNode(aRoot, 'vda4905_519_01', var vNode)) then RETURN 'Satzart';
  XML_GetValI(vNode, var vI);
  if (vI<>519) then RETURN 'Satzart';

  if (_ReadNode(aRoot, 'vda4905_519_03', var vNode)) then RETURN 'Zähler511';
  XML_GetValI(vNode, var vI);
  if (vI<>gCount511) then RETURN 'Zähler511';
  if (_ReadNode(aroot, 'vda4905_519_04', var vNode)) then RETURN 'Zähler512';
  XML_GetValI(vNode, var vI);
  if (vI<>gCount512) then RETURN 'Zähler512';
  if (_ReadNode(aRoot, 'vda4905_519_05', var vNode)) then RETURN 'Zähler513';
  XML_GetValI(vNode, var vI);
  if (vI<>gCount513) then RETURN 'Zähler513';
  if (_ReadNode(aRoot, 'vda4905_519_06', var vNode)) then RETURN 'Zähler514';
  XML_GetValI(vNode, var vI);
  if (vI<>gCount514) then RETURN 'Zähler514';
  // ...
  if (_ReadNode(aRoot, 'vda4905_519_09', var vNode)) then RETURN 'Zähler519';
  XML_GetValI(vNode, var vI);
  if (vI<>gCount519) then RETURN 'Zähler519';
end;


//========================================================================
//========================================================================
sub ReadXML_VDA4905(
  aRoot   : int) : alpha;
local begin
  Erx         : int;
  vBlock      : alpha;
  vNode       : int;
  vNode2      : int;
  vA,vB,vX    : alpha(200);
  vI          : int;
  vErr        : alpha(1000);

  vKdNrA      : alpha;
  vDfueAlt    : int;
  vDfueNeu    : int;
  vBestellnr  : alpha;
  vBestellPos : alpha;
  vAbrufNrAlt : int;
  vAbrufNrNeu : int;
  vTyp        : alpha;
  vZahl       : word;
  vJahr       : word;
  vTermin     : date;
  vMenge      : float;
  vMEH        : alpha;
  vZeitraum   : logic;
  vRahmen     : int;
  vRahmenPos  : int;
  vAufNr      : int;
end;
begin

  // Dfue-Kopf ---------------------------------------------------------------------------------------------
  vBlock # 'VDA4905_511';
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, vBlock)
  if (vNode=0) then RETURN 'kein 511';
  inc(gCount511);
  vErr # ReadXML511(vNode, var vKdNrA, var vDfueAlt, var vDfueNeu);
  if (vErr<>'') then RETURN '511:'+vErr;

  // INMET: Schürholz = x12018
  vKdNrA # '112018';

  // Kunde holen
  Adr.Kundennr # cnvia(vKdNrA);
  Erx # RecRead(100,2,0);
  if (Erx>_rMultikey) then RETURN 'unbekannte Kundennnr.'+vKdNrA;
//debug(adr.stichwort+' '+aint(adr.kundennr));

  // Posdaten ---------------------------------------------------------------------------------------------
  vBlock # 'VDA4905_512';
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, vBlock)
  if (vNode=0) then RETURN 'Kein 512';
  inc(gCount512);
  vErr # ReadXML512(vNode, var vBestellNr, var vBestellPos, var vMEH, var vAbrufNrAlt, var vAbrufNrNeu);
  if (vErr<>'') then RETURN '512:'+vErr;
  if (vMEH<>'kg') then RETURN '512:falsche MEH '+vMEH;

  // DFÜ-Nummer prüfen...
  Prg.Nr.Name       # 'VDA4905_DFÜ_'+aint(Adr.Nummer);
  if (RecRead(902,1,0)>_rLocked) then begin
    RecBufClear(902);
    Prg.Nr.Name         # 'VDA4905_DFÜ_'+aint(Adr.Nummer);
    Prg.Nr.Nummer       # vDfueAlt;
    Prg.Nr.Bezeichnung  # 'für VDA-Import';
    RekInsert(902,_reclock,'AUTO');
  end;
//  if (Prg.Nr.Nummer<>vDfueAlt) then RETURN '512:Lücke im DFÜ-Nummernkreis!';
  Erx # RecRead(902,1,_recLock);
  Prg.Nr.Nummer       # vDfueNeu;
  Erx # RekReplace(902,_recunlock,'AUTO');


/***
  // Abruf-Nummer prüfen...
  Prg.Nr.Name       # 'VDA4905_Abruf_'+aint(Adr.Nummer);
  if (RecRead(902,1,0)>_rLocked) then begin
    RecBufClear(902);
    Prg.Nr.Name         # 'VDA4905_Abruf_'+aint(Adr.Nummer);
    Prg.Nr.Nummer       # vAbrufNrAlt;
    Prg.Nr.Bezeichnung  # 'für VDA Abrufe';
    RekInsert(902,_reclock,'AUTO');
  end;
  if (Prg.Nr.Nummer<>vAbrufNrAlt) then RETURN '512:Lücke im Abrufnummmernkreis!';
  Erx # RecRead(902,1,_recLock);
//  Prg.Nr.Nummer       # vDfueNeu;
  Prg.Nr.Nummer       # vAbrufNrNeu;
  Erx # RekReplace(902,_recunlock,'AUTO');
***/


  // Rahmenauftrag suchen...
  // INMET:
  vBestellnr # vBestellnr + '/'+vBestellpos;
  RecBufClear(401);
  Auf.P.Best.Nummer # vBestellnr;
  FOR Erx # RecRead(401,9,0)        // nach Bestellnummer lesen
  LOOP Erx # RecRead(401,9,_RecNext)
  WHILE (erx<=_rMultikey) and (Auf.P.Best.Nummer=vBestellnr) do begin
    if ("Auf.P.Löschmarker"='') and
      ((Auf.P.Kundennr=212018) or (Auf.P.Kundennr=112018)) then begin
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (erx<=_rLocked) and (Auf.Vorgangstyp=c_Auf) and ("Auf.LiefervertragYN") then begin
        vRahmen     # Auf.P.Nummer;
        vRahmenPos  # Auf.P.Position;
        BREAK;
      end;
    end;
  END;
  if (vRahmen=0) then RETURN '512:Bestellnr. '+vBestellnr+' nicht gefunden '+vBestellNr;
//debug('found RahmenPos: KEY401');
/**  RecBufClear(400);
  Auf.Best.Nummer # vBestellnr;
  Erx # RecRead(400,4,0); // Auftragskopf lesen
  WHILE (erx<=_rMultikey) and (Auf.Best.Nummer=vBestellnr) do begin
    if (Auf.Vorgangstyp=c_Auf) and ("Auf.LiefervertragYN") and (Auf.Kundennr=Adr.Kundennr) and ("Auf.Löschmarker"='') then begin
      vRahmen # Auf.Nummer;
      BREAK;
    end;
    Erx # RecRead(400,4,_RecNext);
  END;
  if (vRahmen=0) then RETURN '512:Bestellnr. nicht gefunden '+vBestellNr;
debug('found Rahmen: KEY400');
***/

  // bisher keine Abrufnummer?
  if (Cus_Data:Read(401,RecInfo(401,_RecId), 1000) <> _rOK) then begin
    Cus_data:Insert(401, RecInfo(401,_RecId), 1000, aint(vAbrufNrAlt));
  end;
  // Abrufnummer prüfen...
  if (Cus.Inhalt<>aint(vAbrufNrAlt)) then RETURN '512:Lücke im Abrufnummmernkreis!';
  Erx # RecRead(931,1,_recLock);
  Cus.Inhalt          # aint(vAbrufNrNeu);
  Erx # RekReplace(931);



  // Abrufdaten 1-5 ------------------------------------------------------------------------------------------
  vBlock # 'VDA4905_513';
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, vBlock)
  if (vNode=0) then RETURN 'Kein 513';
  inc(gCount513);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=5) do begin
    vErr # ReadXML513(vNode, vI, var vZeitraum, var vTyp, var vZahl, var vJahr, var vTermin, var vMenge);
    if (vErr<>'') then RETURN '513:'+vErr;
    if (vTyp='ENDE') then BREAK;
    if (vTyp='EGAL') then CYCLE;
//debug('abruf '+aint(vI)+'------------'+cnvaf(vMenge,0)+' '+vTyp+aint(vZahl)+'/'+aint(vJahr));
    vErr # _UpdateAbruf(vRahmen, vRahmenPos, vTyp, vZahl, vJahr, vTermin, vMenge, vMEH, var vAufNr);
    if (vErr<>'') then RETURN vErr;
  END;

  // Abrufdaten 6-13 -----------------------------------------------------------------------------------------
  vBlock # 'VDA4905_514';
  FOR vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, vBlock)
  LOOP vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteNext, vNode, vBlock)
  WHILE (vNode<>0) do begin
    inc(gCount514);
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=8) do begin
      vErr # ReadXML514(vNode, vI, var vZeitraum, var vTyp, var vZahl, var vJahr, var vTermin, var vMenge);
      if (vErr<>'') then RETURN '514:'+vErr;
      if (vTyp='ENDE') then BREAK;
      if (vTyp='EGAL') then CYCLE;
//debug('abruf '+aint(vI+5)+'------------'+cnvaf(vMenge,0)+' '+vTyp+aint(vZahl)+'/'+aint(vJahr));
      vErr # _UpdateAbruf(vRahmen, vRahmenPos, vTyp, vZahl, vJahr, vTermin, vMenge, vMEH, var vAufNr);
      if (vErr<>'') then RETURN vErr;
    END;
  END;

  // ... andere Pakete ...

  // Dfue-Fuss
  vBlock # 'VDA4905_519';
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, vBlock)
  if (vNode=0) then RETURN 'kein 519';
  inc(gCount519);
  vErr # ReadXML519(vNode);
  if (vErr<>'') then RETURN '519:'+vErr;

//debugx('alles ok');

  RETURN '';
end;


//========================================================================
//  LoadXML_VDA4905
//  call lib_edi:LoadXML_VDA4905
//========================================================================
SUB LoadXML_VDA4905(
  opt aFileName   : alpha(1000);
) : logic;
local begin
  Erx       : int;
  vDoc      : int;
  vRoot     : int;
  vNode     : int;
  vI        : int;
  vA,vB,vX  : alpha(200);
  vErr      : alpha(1000);
end;
begin
//aFilename # 'E:\inmet\inmet333.xml';
//  if (aFilename='') then begin
//    /* Dateiauswahl */
//    aFilename # Lib_FileIO:FileIO( _winComFileopen, gMDI, '', 'XML Dateien|*.xml' );
    if ( aFilename = '' ) then RETURN false;
//  end;

  /* XML Initialisierung */
  vDoc # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;

  Erx # vDoc->XmlLoad( aFilename);
  if (erx != _errOk ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
//    Msg(998017, ' (' + XmlError( _xmlErrorText ) + ')', 0, 0, 0 );
debugx('kein XML file');
    RETURN false;
  end;

  vRoot # vDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'VDA4905');
  if (vRoot=0) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
//    Msg(99, 'Nicht VDA4905', 0, 0, 0 );
debugx('Kennung "VDA4905" fehlt');
    RETURN false;
  end;


  TRANSON;

  vErr # ReadXML_VDA4905(vRoot);
  if (vErr<>'') then begin
debugX('Fehler:'+vErr);
    TRANSBRK;
    if (cWofDateiDefekt<>0) then Lib_Workflow:Trigger(999, cWoFDateiDefekt, '');
    // Aufräumen...
    vDoc->CteClear( true );
    vDoc->CteClose();
    RETURN false;
  end;

  TRANSOFF;

  // Aufräumen...
  vDoc->CteClear( true );
  vDoc->CteClose();

  RETURN true;
end;


//========================================================================
//========================================================================
sub VDA711(
  aNode         : int;
  aDatenVon     : int;
  aDatenAn      : int;
  aUeberNrAlt   : int;
  aUeberNrNeu   : int;
  aDat          : date;
  aFrachtf      : alpha;
) : int;
local begin
  vNode         : int;
end;
begin

  if (aNode<>0) then gActNode # aNode->Lib_XML:AppendNode('VDA711');

  Inc(gCount711);
                                          //
  MussN('Satzart',                        711, 3);
  MussA('Version',                        '03', 2);
  MussN('Datenempfänger',                 aDatenAn, 9);
  MussN('Datensender',                    aDatenVon, 9);
  MussN('Übertragungsnr. alt',            aUeberNrAlt, 5);
  MussN('Übertragsungsnr. neu',           aUeberNrNeu, 5);
  MussD('Übertragungsdatum',              aDat);
  KannA('Unterlieferant',                 '', 9);
                                          // K Frachtführer (712,13, Spediteur)
  KannA('Frachtführer',                   aFrachtF, 9);
  KannA('Lagerhaltungschlüssel',          '', 1);
  KannA('Lieferungskennung',              '', 1);
  MussA('Leer',                           '', 69);

  RETURN gActNode;
end;


//========================================================================
//========================================================================
sub VDA719(aNode : int) : int;
begin

//  if (gIsXML) then gActNode # gFileHdl->Lib_XML:AppendNode('VDA719');
  if (aNode<>0) then gActNode # aNode->Lib_XML:AppendNode('VDA719');

  Inc(gCount719);
                                          //
  MussN('Satzart',                        719, 3);
  MussA('Version',                        '02', 2);
  MussN('Anzahl 711',                     gCount711, 7);
  MussN('Anzahl 712',                     gCount712, 7);
  MussN('Anzahl 713',                     gCount713, 7);
  MussN('Anzahl 714',                     gCount714, 7);
  MussN('Anzahl 715',                     gCount715, 7);
  MussN('Anzahl 716',                     gCount716, 7);
  MussN('Anzahl 718',                     gCount718, 7);
  MussN('Anzahl 719',                     gCount719, 7);
  MussN('Anzahl 717',                     gCount717, 7);
  MussA('Leer',                           '', 60);

  RETURN gActNode;
end;


//========================================================================
// zum TRANSPORT
//========================================================================
sub VDA712(
  aNode         : int;
  aSendungsNr   : int;
  aFrachtF      : alphA;
  aFrachtFDat   : date;
  aFrachtFZeit  : time;
) : int;
begin

  if (aNode<>0) then gActNode # aNode->Lib_XML:AppendNode('VDA712');

  Inc(gCount712);
                                          //
  MussN('Satzart',                        712, 3);
  MussA('Version',                        '03', 2);
                                          // Bezugsnummer
                                          // ODER - Verladenummer (6) + Zählernummer pro Spedauftrag (2)
  MussN('Sendundungsladungsbezugsnr.',    aSendungsNr, 8);
  KannA('werklieferant',                  '', 3);
  MussA('Frachtführer',                   aFrachtF, 14);
  MussD('Frachtführer Übergabedatum',     aFrachtFDat);
  MussT('Frachtführer Übergabezeit',      aFrachtFZeit);
  MussN('Sendungsgewicht Brutto',         cnvif(Lfs.Positionsgewicht), 7);
  KannN('Sendungsgewicht Netto',          0, 7);
  KannN('Frakaturschlüssel',              0, 2);
  KannA('Spediteuer DFÜ-Schlüssel',       '', 1);
  KannN('Anzahl PAckstücke',              0, 4);
  KannA('Transportpatnernr.',             '', 14);
                                          // 01 = KFZ
  MussN('Transportmittelschlüssel',       1, 2);
  MussA('Transportmittelnr.',             Lfs.Kennzeichen, 25);
  KannA('Schlüssel tu 17',                '', 1);
  KannA('Inhalt laut 16',                 '', 8);
  KannD('Eintreffdatum Sull',             0.0.0);
  KannT('Eintreffzeit Soll',              0:0);
                                          // 1 DZ
  KannN('Lagemeter',                      0, 3);
  KannN('LKW-Art-Schlüssel',              0, 1);
  MussA('Leer',                           '', 3);

  RETURN gActNode;
end;


//========================================================================
// zum LIEFERSCHEIN
//========================================================================
sub VDA713(
  aNode         : int;
  aVersandDat   : date;
  aLfNrBeiKd    : alpha;
  aAbladeStelle : alpha;
  aVersandart   : int;
  aWerkKunde    : alpha;
) : int;
begin

  if (aNode<>0) then gActNode # aNode->Lib_XML:AppendNode('VDA713');

  Inc(gCount713);
                                          //
  MussN('Satzart',                        713, 3);
  MussA('Version',                        '03', 2);
  MussN('Lieferscheinnr.',                Lfs.Nummer, 8);
  MussD('Versanddatum',                   aVersandDat);
  MussA('Abladestelle',                   aAbladestelle, 5);
  MussN('Versandart',                     aVersandart, 2);
  KannA('Zeichen des Kunden',             '', 4);
  KannA('Bestellnr.',                     '', 12);
  KannN('Vorgangschlüssel',               0, 2);
  MussA('Leer1',                          '', 4);
  MussA('Werk Kunde',                     aWerkKunde, 3);
  KannN('Konsignation',                   0, 8);
  KannA('Warenempfängernr.',              '', 9);
  MussA('Leer2',                          '', 1);
  KannA('Lagerort Kunde',                 '', 7);
  MussA('Lieferantennr.',                 aLfNrBeiKd, 9);
  KannA('Verbrauchsstelle',               '', 14);
  KannA('Abrufnr.',                       '', 4);
  KannA('Zeichen des Kunden',             '', 6);
  KannA('Dokumentnr. Kunde',              '', 14);
  MussA('Leer3',                          '', 5);

  RETURN gActNode;
end;


//========================================================================
// pro LFS-Position
//========================================================================
sub VDA714(aNode : int) : int;
begin

  // Daten vorbereiten ---------------------------------------------------
  if (Lfs.P.Artikelnr='') then
    Lfs.P.Artikelnr # aint(Lfs.P.Materialnr);
  if (Lfs.P.Art.Charge='') then
    Lfs.P.Art.Charge # aint(Lfs.P.Materialnr);
  RecBufClear(200);
  if (Lfs.P.Materialnr<>0) then begin
    Mat_Data:Read(Lfs.P.Materialnr);
  end
  else begin
    Mat.Ursprungsland # 'D';
  end;

  // Kommission holen
  RecBufClear(400);
  RecBufClear(401);
  if (Lfs.P.Auftragsnr<>0) then begin
    Auf_Data:Read(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, true);
  end;

  // Ausgabe -------------------------------------------------------------

  if (aNode<>0) then gActNode # aNode->Lib_XML:AppendNode('VDA714');

  Inc(gCount714);
                                          //
  MussN('Satzart',                        714, 3);
  MussA('Version',                        '03', 2);
  MussA('Sachnummer Kunde',               Auf.P.KundenArtNr, 22);
  MussA('Sachnummer Lieferant',           Lfs.P.Artikelnr, 22);
  MussN('Ursprungsland',                  ConvertLKZ(Mat.Ursprungsland), 3);
  MussN('Liefermenge1',                   cnvif(Lfs.P.Menge), 13);    // 12.07.2018 AH war /1000
  MussA('MEH1',                           Lfs.P.MEH, 2);
  KannN('Liefermenge2',                   0, 13);
  KannA('MEH2',                           '', 2);
  KannN('Umsatzsteuersatz',               0, 3);
  MussA('Leer1',                          '', 1);
  MussN('LFA-Positionsnr.',               Lfs.P.Position, 3);
  KannA('Abrufschlüssel',                 '', 1);
  KannA('Chargennr.',                     Lfs.P.Art.Charge, 15)
  MussA('Verwendungsschlüssel',           '', 1); // ohne Angabe
  KannA('Gefährliche-Stoffe-Schlüssel',   '', 8);
  MussA('Präferenzstatus',                ConvertPraeferenz(Mat.LfENr), 1);
                                          // BLANK = nein, 1 = ja
  MussA('Zollgut',                        '', 1);
  MussA('Leer2',                          '', 1);
  MussA('Bestandsstatus',                 '', 1);
  MussA('Geänderte-Ausführung-Schlüssel', '', 2);
  KannA('Ursprungs-LFS-Nr.',              '', 8);

  RETURN gActNode;
end;


//========================================================================
//  LfsToVDA4913
//
//========================================================================
sub LfsToVDA4913(
  aFileName : alpha(4000);
  aAlsXML   : logic;
) : logic;
local begin
  Erx       : int;
  vXML      : int;
  vBase     : int;
  v711      : int;
  v712      : int;
  v713      : int;
  v714      : int;
  vDFUEAlt  : int;
  vDFUENeu  : int;
end;
begin

  // alles wunderbar...
  Gv.Int.01       # EDI_LFS:Export(Lfs.Nummer, aFileName);
  RETURN GV.Int.01>0;


  // Daten vorbereiten ---------------------------------------------------
  Erx # RekLink(100, 440, 1, _recFirst);    // Kunde holen
  if (Adr.Kundennr=0) then RETURN false;

  // DFÜ-Nummer bestimmen...
  Prg.Nr.Name       # 'VDA_DFÜ_'+aint(Adr.Nummer);
  if (RecRead(902,1,0)>_rLocked) then begin
    RecBufClear(902);
    Prg.Nr.Name         # 'VDA_DFÜ_'+aint(Adr.Nummer);
    Prg.Nr.Nummer       # 1;
    Prg.Nr.Bezeichnung  # 'für VDA-Export';
    RekInsert(902,_reclock,'AUTO');
    vDFUEAlt            # 0;
    vDFUENeu            # 1;
  end
  else begin
    vDFUEalt # Lib_Nummern:ReadNummer(Prg.Nr.Name);
    if (vDFUEalt=0) then begin
      Lib_Nummern:FreeNummer();
      RETURN false;
    end;
    vDFUEneu # vDFUEalt + 1;
    if (vDFUEneu>99999) then begin
      Prg.Nr.Nummer # 0;
      vDFUEneu      # 1;
    end;
  end;


  if (aAlsXML) then begin
    // XML Dokument erstellen
    vXML       # CteOpen(_CteNode);
    vXML->spID # _XmlNodeDocument;

    // Metadaten füllen
    vXML->CteInsertNode('', _XmlNodeComment, 'Stahl-Control');

    // Umfassendes node erstellen
    vBase # vXml->Lib_XML:AppendNode('Inhalt');
  end
  else begin
    //gProto # TextOpen(20);
    gFileHdl # FSIOpen(aFileName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  end;


  // Export --------------------------------------------------------------
  APPOFF();
  v711 # VDA711(vBase, cDatenSenderNR, cDatenEmpfaengerNr, vDFUEalt, vDFUENeu, today, 'Frachthorst');

    // Übergabedatum
    v712 # VDA712(v711, Lfs.Nummer, 'frachthorst', Lfs.Anlage.Datum, Lfs.Anlage.Zeit); // Sendung

      // Versanddatum, LfNrBeimKunden, Abladestelle, Versandart (5=meinLKW), WerkKunde
      v713 # VDA713(v712, Lfs.Anlage.Datum, Adr.VK.Referenznr, 'Abladestelle', 5, 'WRK');

      FOR Erx # RekLink(441,440,4,_recFirst)
      LOOP Erx # RekLink(441,440,4,_recNext)
      WHILE (Erx<=_rLocked) do begin
        v714 # VDA714(v713);
      END;

  VDA719(vBase);




  if (aAlsXML) then begin
    _SaveNodeToXmlFile(vXML, aFileName);
    vXML->CteClear(true);
    vXML->CteClose();
  end
  else begin
  /*
    if (gProto<>0) then begin
      TextDelete(myTmpText,0);
      TextWrite(gProto,MyTmpText,0);
      TextClose(gProto);
      Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
      TextDelete(myTmpText,0);
    end;
  */
    FsiClose(gFileHdl);
  end;

  APPON();


  Lib_Nummern:SaveNummer();

  // alles wunderbar...
  Gv.Int.01       # 1;

  RETURN true;

end;


//========================================================================
//========================================================================
//========================================================================

//========================================================================
//  sub _RecToXMLNode
//                                        ST 2014-10-30  Projekt 1326/408
//
//  Hängt einen kompletten Datensatz der angegebenen Datei an in das
//  übergebene XML Node
//========================================================================
sub _RecToXMLNode(
  aFileNo   : int;
  aNode     : int;
  opt aDeep : logic) : int
local begin
  Erx       : int;
  vTdsCnt   : int;
  vTds      : int;

  vFldCnt   : int;
  vFld      : int;
  vFldData  : alpha(4000);
  vFldName  : alpha(250);

  vNode     : int;
end;
begin

  // Datei vorhanden?
  if (FileInfo(aFileNo,_FileExists) = _ErrNoFile) then
    RETURN -1;

  // Satznode erstellen
  aNode # aNode->Lib_XML:AppendNode('Record');
  aNode->Lib_XML:AppendAttributeNode('RecID',CnvAI(RecInfo(aFileNo,_RecID),_FmtNumNoGroup));

  // Teildatensätze durchgehen
  vTdsCnt # FileInfo(aFileNo,_FileSbrCount);
  FOR  vTds # 1;
  LOOP vTds # vTds + 1;
  WHILE (vTds <= vTdsCnt) DO BEGIN

    // Felder durchgehen
    vFldCnt # SbrInfo(aFileNo,vTds,_SbrFldCount);
    FOR  vFld # 1;
    LOOP vFld # vFld + 1;
    WHILE (vFld <= vFldCnt) DO BEGIN

      CASE (FldInfo(aFileNo,vTds,vFld,_FldType)) OF
        _TypeAlpha    : vFldData # FldAlpha(aFileNo,vTds,vFld          );
        _TypeBigInt   : vFldData # CnvAb(FldBigint(aFileNo,vTds,vFld)  );
        _TypeByte     : vFldData # CnvAi(FldInt(aFileNo,vTds,vFld)     );
        _TypeDate     : vFldData # CnvAd(FldDate(aFileNo,vTds,vFld)    );
        _TypeDecimal  : vFldData # CnvAM(FldDecimal(aFileNo,vTds,vFld) );
        _TypeFloat    : vFldData # CnvAf(FldFloat(aFileNo,vTds,vFld)   );
        _TypeInt      : vFldData # CnvAi(Fldint(aFileNo,vTds,vFld)     );
        _TypeLogic    : vFldData # CnvAi(CnvIl(FldLogic(aFileNo,vTds,vFld))  );
        _TypeTime     : vFldData # CnvAT(FldTime(aFileNo,vTds,vFld)    );
        _TypeWord     : vFldData # CnvAi(FldWord(aFileNo,vTds,vFld)    );
      END;

      // Datensatz ist gelesen
      vFldName # (FldName(aFileNo,vTds,vFld));
      aNode->Lib_XML:AppendNode(vFldName,vFldData);

    END; // Felder durchgehen

  END; // // Teildatensätze durchgehen


  if (aDeep) then begin
    if (aFileNo=100) then begin
      FOR Erx # RecLink(101,100, 12, _recfirst)
      LOOP Erx # RecLink(101,100, 12, _recNext)
      WHILE (erx<=_rLocked) do begin
        vNode # _RecToXMLNode(101, aNode)
        if (vNode<0) then RETURN -1;
      END;

      FOR Erx # RecLink(102,100, 13, _recfirst)
      LOOP Erx # RecLink(102,100, 13, _recNext)
      WHILE (erx<=_rLocked) do begin
        vNode # _RecToXMLNode(102, aNode)
        if (vNode<0) then RETURN -1;
      END;
    end;
  end;

  RETURN aNode;
end;


//========================================================================
//  sub _InitXML
//
//========================================================================
sub _InitXML(
  aFileNo   : int;
  var aXML  : int;
  var aNode : int) : logic;
begin
  // XML Dokument erstellen
  aXml       # CteOpen(_CteNode);
  aXml->spID # _XmlNodeDocument;

  // Metadaten füllen
  aXml->CteInsertNode('', _XmlNodeComment, 'Stahl-Control');

  // Umfassendes node erstellen
  aNode # aXml->Lib_XML:AppendNode('Records');
  aNode->Lib_XML:AppendAttributeNode('Fileno',Aint(aFileNo));
  aNode->Lib_XML:AppendAttributeNode('Filename',FileName(aFileNo));

  RETURN true;
end;


//========================================================================
//========================================================================
sub _CloseXML(
  aXmlDok : int);
begin
  aXmlDok->CteClear(true);
  aXmlDok->CteClose();
end;


//========================================================================
//  sub _SaveNodeToXmlFile
//========================================================================
sub _SaveNodeToXMLFile(
  aXmlDok   : int;
  aFilename : alpha(4000)) : int;
local begin
  Erx : int;
end;

begin
  // Datei speichern und Node schließen
  Erx # aXmlDok->XmlSave(aFilename,_XmlSaveDefault,0, _CharsetUTF8);
  Erg # erx;    // TODOERX
  RETURN erx;
end;

//========================================================================
//  sub RecToXMLFile
//                                         ST 2014-10-30  Projekt 1326/408
//
//  Erstellt eine XML Struktur, lässt diese anhand der Dateinummer befüllen
//  und schreibt die XML Datei.
//========================================================================
sub RecToXmlFile(
  aFileNo   : int;
  aFilename : alpha(4000);
  opt aDeep : logic) : int;
local begin
  Erx       : int;
  vXmlDok   : int;
  vNode     : int;
  vBase     : int;
end;
begin

  if (aFilename='') then begin
    aFilename # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'XML-Dateien|*.xml');
    if (aFilename='') then RETURN 0;
    if (StrCnv(StrCut(aFilename,strlen(aFilename)-3,4),_StrUpper) <>'.XML') then aFileName # aFileName + '.xml';
  end;

  _InitXML(aFileNo, var vXmlDok, var vBase);

  // Node mit gelesenen Daten befüllen
  vNode # _RecToXMLNode(aFileno, vBase, aDeep);

  // Fehler in Datenbereitstellung
  if (vNode < 0) then begin
    _CloseXML(vXmlDok);
    RETURN vNode;
  end;

  Erx # _SaveNodeToXMLFile(vXmlDok, aFilename);
  _CloseXML(vXmlDok);

  // Fehler für Datenspeicherung
  Gv.Int.01       # 1;

  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
// TableToXMLFile
//========================================================================
sub TableToXMLFile(
  aFileNo   : int;
  aFilename : alpha(4000);
  opt aDeep : logic;
  opt aMark : logic) : int
local begin
  Erx       : int;
  vXmlDok   : int;
  vNode     : int;
  vBase     : int;
  vHdl      : int;
  vMax      : int;
  vPrgr     : int;
  vAnz      : int;
end;
begin

  vMax # RecInfo(aFileNo, _reccount);
  if (aMark) then begin
    vMax # Lib_Mark:Count(aFileNo);
    if (vMax=0) then begin
      Msg(997006,'',0,0,0);
      RETURN -1;
    end;
  end;

  if (aFilename='') then begin
    aFilename # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'XML-Dateien|*.xml');
    if (aFilename='') then RETURN 0;
    if (StrCnv(StrCut(aFilename,strlen(aFilename)-3,4),_StrUpper) <>'.XML') then aFileName # aFileName + '.xml';
  end;


  vPrgr # Lib_Progress:Init( 'XML-Export', vMax, true );


  _InitXML(aFileNo, var vXmlDok, var vBase);

  FOR Erx # RecRead(aFileNo, 1, _recfirst)
  LOOP Erx # RecRead(aFileNo, 1, _recNext)
  WHILE (erx<=_rLocked) and (vNode>=0) do begin

    if (aMark) then begin
      if (Lib_Mark:istmarkiert(aFileNo,RecInfo(aFileNo, _recId))=false) then CYCLE;
    end;

    vPrgr->Lib_Progress:Step();
    inc(vAnz);

    vNode # _RecToXMLNode(aFileNo, vBase, aDeep);

    // Fehler in Datenbereitstellung
    if (vNode < 0) then begin
      _CloseXML(vXmlDok);
      RETURN vNode;
    end;

  END;

  Erx # _SaveNodeToXMLFile(vXmlDok, aFilename);
  _CloseXML(vXmlDok);

  vPrgr->Lib_Progress:Term();

  // Fehler für Datenspeicherung
  Gv.Int.01       # vAnz;
  Erg # Erx;    // TODOERX
  RETURN Erx;
end;


//========================================================================
//========================================================================
sub _ChooseFileName(aDlg : int);
local begin
  vFilename : alpha(4000);
  vTyp      : alpha;
end;
begin

  vTyp # $edFilename->wpcustom;
  if (vTyp='XML') then    vTyp # 'XML-Dateiein|*.xml';
  if (vTyp='Excel') then  vTyp # 'CSV-Dateiein|*.csv';
  if (vTyp='VDA') then    vTyp # 'TXT-Dateiein|*.txt';

  vFilename # Lib_FileIO:FileIO(_WinComFileOpen, aDlg, '', vTyp);
  if (vFilename='') then RETURN;
  vTyp # Str_Token(vTyp,'|',2);
  vTyp # '.'+Str_Token(vTyp,'.',2);
  if (StrCnv(StrCut(vFilename,strlen(vFilename)-3,4),_Strlower) <>vTyp) then vFileName # vFileName + vTyp;
  $edFilename->wpcaption # vFilename;
  Winfocusset($edFilename, true);
end;


//========================================================================
// RecListToClipboard
//========================================================================
sub RecListToClipboard(
  aList : int;
  ) : logic;
local begin
  Erx   : int;
  vTxt  : int;
  vHdl  : int;
  vA,vB : alpha(4000);
  vEvt  : event;
end;
begin
  vTxt # Textopen(20);


  // Überschrift
  vA # '';
  FOR vHDL # aList->WinInfo( _winFirst)
  LOOP vHDL # vHDL->WinInfo( _winNext)
  WHILE (vHdl<>0) do begin
    if (vA<>'') then vA # vA + StrChar(9);
    vA # vA + vHdl->wpcaption;
  END;
  TextAddLine(vTxt, vA);


  FOR erx # RecRead(gFile, gKey, _recFirst)
  LOOP erx # RecRead(gFile, gKey, _recNext)
  WHILE (Erx<_rLocked) do begin

    Call(gPrefix+'_Main:EvtLstDataInit', vEvt, RecInfo(gFile, _recID));

    vA # '';
    FOR vHDL # aList->WinInfo( _winFirst)
    LOOP vHDL # vHDL->WinInfo( _winNext)
    WHILE (vHdl<>0) do begin
      vB # vHdl->wpdbFieldname;
      if (vB<>'') then begin
        case FldInfoByName(vB, _FldType) of
          _TypeAlpha  : vB # FldAlphaByName(vB);
          _TypeWord   : vB # aint(FldWordByName(vB));
          _TypeInt    : vB # aint(FldIntByName(vB));
          _TypeFloat  : vB # anum(FldFloatbyName(vB), vHdl->wpFmtPostComma);
          _TypeDate   : vB # cnvad(FldDateByName(vB));
          _TypeTime   : vB # cnvat(FldTimeByName(vB));
          _TypeLogic  : if (FldLogicByName(vB)) then vB # 'J'; else vB # 'N';
          otherwise vB # '???';
        end; // case
      end;
      if (vA<>'') then vA # vA + StrChar(9);
      vA # vA + vB;
    END;
    TextAddLine(vTxt, vA);

  END;

  TextWrite(vTxt, 'SC', _TextClipboard);
  Textclose(vTxt);

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtKeyItem(
  aEvt                 : event;    // Ereignis
  aKey                 : int;      // Taste
  aID                  : int;      // RecID bei RecList, Node-Deskriptor bei TreeView, Focus-Objekt bei Frame und AppFrame
) : logic;
local begin
  vHdl  : int;
end;
begin

  vHdl # Winfocusget();

  if (aKey=_WinKeyF9) then begin
    if (vHdl->wpname='edFilename') then
      _ChooseFilename(Wininfo(aEvt:obj, _winframe));
    RETURN true;
  end;

  if  (aKey=_WinKeyF2) then begin
    WindialogResult(Wininfo(aEvt:obj, _winframe), _WinIdOk);
    Winclose(Wininfo(aEvt:obj, _winframe));
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vDlg      : int;
  vFilename : alpha(4000);
  vPostfix  : alpha;
  vTyp      : alpha;
end;
begin

  if (aEvt:Obj->wpname<>'btFilename') then begin
    if ($rbExcel->wpCheckState=_WinStateChkChecked) then    vTyp # 'Excel';
    if ($rbXML->wpCheckState=_WinStateChkChecked) then      vTyp # 'XML';
    if ($rbXMLDeep->wpCheckState=_WinStateChkChecked) then  vTyp # 'XML+';
    if ($rbVDA->wpCheckState=_WinStateChkChecked) then      vTyp # 'VDA';
    if ($rbCOM->wpCheckState=_WinStateChkChecked) then      vTyp # 'COM';
    $edFilename->wpcustom # vTyp;
  end
  else begin
    _ChooseFilename(Wininfo(aEvt:obj, _winframe));
  end;

  Lib_guicom:able($edFilename, vTyp<>'COM');
  Lib_guicom:able($btFilename, vTyp<>'COM');
  $rbEiner->wpdisabled # vTyp='COM';
  $rbAlle->wpdisabled # vTyp='COM';
  $rbMark->wpdisabled # vTyp='COM';

  RETURN (true);
end;


//========================================================================
//========================================================================
sub RunExportDialog(
  aFileNo       : int;
  var aTyp      : alpha;
  var aFilename : alpha;
  var aAlle     : logic;
  var aMark     : logic;
  opt aOrgFile  : int) : logic;
local begin
  vMDI      : int;
  vDlg      : int;
  vHdl      : int;
  vID       : int;
  vA        : alpha;
end;
begin
  vMDI # gMDI;
  if (gMDI=0) then vMDI # gFrmMain;
  if (gMDI=gMDINOtifier) or (gMDI=gMdiWorkbench) or (gMDI=gMdiMenu) then vMDI # gFrmMain;

  vDlg  # WinOpen('Dlg.EDI',_WinOpenDialog)
  vHdl # winsearch(vDlg, 'lbTabname');
  vA # Lib_Odbc:Tablename(aFileNo);
  if (vA='') then vA # FileName(aFileno);
  vHdl->wpcaption # vA;
  

  vHdl # winsearch(vDlg, 'edFilename');
  Lib_GuiCom:AuswahlEnable(vHDL);

  vHdl # winsearch(vDlg, 'rbXMLDeep');
  vHdl->wpvisible # (aFileNo=100);

  vHdl # winsearch(vDlg, 'rbVDA');
  vHdl->wpvisible  # (aFileNo=440);

  vHdl # winsearch(vDlg, 'rbCOM');
  vHdl->wpvisible  # (gFile<>0) and (gZLList<>0);

  // 2022-08-22 AH
  if (aFileNo=231) and (aOrgFile=833) then begin
    vHdl # winsearch(vDlg, 'rbXML');
    vHdl->wpvisible  # false;
    vHdl # winsearch(vDlg, 'rbVDA');
    vHdl->wpvisible  # false;
    vHdl # winsearch(vDlg, 'rbCOM');
    vHdl->wpvisible  # false;
    vHdl # winsearch(vDlg, 'rbEiner');
    vHdl->wpvisible  # false;
    vHdl # winsearch(vDlg, 'rbMark');
    vHdl->wpvisible  # false;
    vHdl # winsearch(vDlg, 'rbAlle');
    vHdl->wpCheckState # _WinStateChkChecked;
  end;
  
  vID # vDlg->Windialogrun(0,vMDI);

  vHdl # winsearch(vDlg, 'edFilename');
  aFilename # vHdl->wpcaption;

  vHdl # winsearch(vDlg, 'rbExcel');
  if (vHdl->wpCheckState=_WinStateChkChecked) then aTyp # 'Excel'
  else begin
    vHdl # winsearch(vDlg, 'rbXML');
    if (vHdl->wpCheckState=_WinStateChkChecked) then aTyp # 'XML'
    else begin
      vHdl # winsearch(vDlg, 'rbXMLDeep');
      if (vHdl->wpCheckState=_WinStateChkChecked) then aTyp # 'XML+'
      else begin
        vHdl # winsearch(vDlg, 'rbVDA');
        if (vHdl->wpCheckState=_WinStateChkChecked) then aTyp # 'VDA';
        else begin
          vHdl # winsearch(vDlg, 'rbCOM');
          if (vHdl->wpCheckState=_WinStateChkChecked) then aTyp # 'COM';
        end;
      end;
    end;
  end;

  vHdl # winsearch(vDlg, 'rbEiner');
  vHdl # winsearch(vDlg, 'rbAlle');
  aAlle # (vHdl->wpCheckState=_WinStateChkChecked);
  vHdl # winsearch(vDlg, 'rbMark');
  aMark # (vHdl->wpCheckState=_WinStateChkChecked);

  vDlg->winclose();

  RETURN (vId = _WinIdOk) and ((aFileName<>'') or (aTyp='COM'));
end;


//========================================================================
//========================================================================
sub Export();
local begin
  vFileNo   : int;
  vTyp      : alpha;
  vFilename : alpha(4000);
  vAlle     : logic;
  vMark     : logic;
  vDeep     : logic;
  vOK       : logic;
  vHdl      : int;
  vBonus    : int;
  vSel      : int;
  vQ        : alpha(4000);
  Erx       : int;
  vSelName  : alpha;
end
begin
    
  vFileNo # gFile;
  if (vFileNo=0) then RETURN;
  vBonus # VarInfo(WindowBonus);
  
  // 2022-08-22 AH
  if (vFileNo=833) and (Set.LyseErweitertYN) then
    vFileNo # 231;
  
  vOK # RunExportDialog(vFileNo, var vTyp, var vFilename, var vAlle, var vMark, gFile);
  VarInstance(WindowBonus,vBonus);
  if (vOK=false) then RETURN;
  vOK # false;

  if (vTyp='COM') then begin
    vHdl # gZLList;
    gZLList # 0;
    //vOK # RecListToClipboard(vHdl);
    vOK # Lib_Com:ExportRecList(gTitle, vHdl, gFile, gPrefix+'_Main:EvtLstDataInit');
    gZLList # vHdl;
    vTyp # '';
    RETURN;
  end;
  
  // 2022-08-22 AH
  if (vFileNo=231) and (gFile=833) then begin
    vQ # '"Lys.Trägerdatei"=833';
    vSel # SelCreate(231, 1);
    Erx # vSel->SelDefQuery('', vQ);
    if (Erx<>0) then Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);
  end;
  

  if (vTyp='XML') or (vTyp='XML+') then begin
    if (vAlle) or (vMark) then
      vOK # TableToXmlFile(vFileNo, vFilename, vTyp='XML+', vMark)>0;
    else
      vOK # RecToXmlFile(vFileNo, vFilename, vTyp='XML+')>0;
  end
  else if (vTyp='Excel') then begin
    vOK # Lib_Excel:SchreibeDatei(vFileNo, vFileName, vMark, 0, n, (vAlle=false) AND (vMark=false), vSel );
  end
  else if (vTyp='VDA') and (gFile=440) then begin
    vOK # LfsToVDA4913(vFileName, (StrCnv(FsiSplitName(vFilename, _FsiNameE),_Strupper)='XML'));
  end;

  if (vSel<>0) then begin
    SelClose(vSel);
    SelDelete(vFileNo, vSelName);
  end;

  if (vOK) then
    Msg(998004,vFileName+'|'+cnvai(Gv.int.01),_WinIcoInformation,0,0)
  else
    Msg(999999,gv.alpha.01,_WinIcoError,0,0);

end;


//========================================================================
//========================================================================
//========================================================================
//      VDA Read Provisorium
//========================================================================
//========================================================================
//========================================================================

sub VDA_ReadData(aFile : int; aLength : int) : alpha
local begin
  vRet : alpha(200);
end
begin

  FSIRead(aFile, vRet, aLength);
  if (StrFind(vRet,StrChar(13),1) > 0) then begin
    vRet # Lib_Strings:Strings_ReplaceAll(vRet,StrChar(13),'');
    vRet # vRet + VDA_ReadData(aFile,1);
  end;

  if (StrFind(vRet,StrChar(10),1) > 0) then begin
    vRet # Lib_Strings:Strings_ReplaceAll(vRet,StrChar(10),'');
    vRet # vRet + VDA_ReadData(aFile,1);
  end;

  RETURN vRet;
end;

/*

sub _XmlFromVDA(
  aNode : int;            // Node zum Hinzufügen
  aFldId : alpha;         // Knotenname
  aAttribName : alpha;    // Beschreibender Text
  aFile : int;            // Dateidesktriptor
  aLength : int;          // Anzahl der zu lesenden zeichen
  ) : int;
local begin
  vA  : alpha(1000);
  vNode : int;
end
begin

  aAttribName # StrCut(StrAdj(aAttribName,_StrAll),1,20);

  vA # VDA_ReadData(aFile,aLength);

  vNode # aNode->Lib_Xml:AppendNode(aFldId,vA);
  vNode->Lib_XML:AppendAttributeNode('Name',aAttribName);

  RETURN vNode;
end;
*/



sub _ImportVDA_4905_511(aNode : int; aFile : int)  : int;
local begin
  vA  : alpha(1000);
  vFile : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_511');
//  vNode # aNode->Lib_Xml:AppendNode('Vorsatz Lieferabruf 511');
//  vNode->Lib_XML:AppendAttributeNode('Segment','511');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','511');

  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // 03 Kundennummer
  EDI_READ(9);
  vNode->Lib_Xml:AppendNode('Kundennr',vA);

  // 04 Lieferantennummer
  EDI_READ(9);
  vNode->Lib_Xml:AppendNode('Lieferantennr',vA);

  // 05 Übertragungsnr alt
  EDI_READ(5);
  vNode->Lib_Xml:AppendNode('ÜbertragungsnrAlt',vA);

  // 06 Übertragungsnr neu
  EDI_READ(5);
  vNode->Lib_Xml:AppendNode('ÜbertragungsnrNeu',vA);

  // 07 Übertragungsdatum  JJMMTT
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('Übertragungsdatum',vA);

  // 08 Datum-Nullstellung JJMMTT
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('Datumnullstellung',vA);

  // 09 Leer
  EDI_READ(83);
  vNode->Lib_Xml:AppendNode('Datumnullstellung',vA);

  RETURN vNode;
end;


sub _ImportVDA_4905_512(aNode : int; aFile : int) : int;
local begin
  vA  : alpha(1000);
  vFile : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_512');
  //vNode # aNode->Lib_Xml:AppendNode('Einmalige Datenelemente Lieferabruf');
  //vNode->Lib_XML:AppendAttributeNode('Segment','512');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','512');


  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // 03 Werk Kunde
  EDI_READ(3);
  vNode->Lib_Xml:AppendNode('Werk-Kunde',vA);

  // 04 Lieferabrufnummer neu
  EDI_READ(9);
  vNode->Lib_Xml:AppendNode('LieferabrufNr-Neu',vA);

  // 05 Lieferabrufdatum-neu
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('LieferabrufDat-Neu',vA);

  // 06 Lieferabrufnummer alt
  EDI_READ(9);
  vNode->Lib_Xml:AppendNode('LieferabrufNr-Alt',vA);

  // 07 Lieferabrufdatum-alt
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('LieferabrufDat-Alt',vA);

  // 08 Sachnummer Kunde
  EDI_READ(22);
  vNode->Lib_Xml:AppendNode('SachnummerKunde',vA);

  // 09 Sachnummer Lieferant
  EDI_READ(22);
  vNode->Lib_Xml:AppendNode('SachnummerLieferant',vA);

  // 10 Abschluss-bestellnummer
  EDI_READ(12);
  vNode->Lib_Xml:AppendNode('AbschlussBestellnummer',vA);

  // 11 Abladestelle
  EDI_READ(5);
  vNode->Lib_Xml:AppendNode('Abladestelle',vA);

  // 12 Zeichen des Kunden
  EDI_READ(4);
  vNode->Lib_Xml:AppendNode('ZeichendesKunden',vA);

  // 13 Mengeneinheit
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Mengeneinheit',vA);

  // 14 Anlieferungsinterval
  EDI_READ(1);
  vNode->Lib_Xml:AppendNode('Anlieferungsinterval',vA);

  // 15 Fertigungsfreigabe
  EDI_READ(1);
  vNode->Lib_Xml:AppendNode('Fertigungsfreigabe',vA);

  // 16 Materialfreigabe
  EDI_READ(1);
  vNode->Lib_Xml:AppendNode('Materialfreigabe',vA);

  // 17 Verwendungsschlüssel
  EDI_READ(1);
  vNode->Lib_Xml:AppendNode('Verwendungsschlüssel',vA);

  // 18 Kontierungsschlüssel
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('Kontierungsschlüssel',vA);

  // 19 LAger
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('Lager',vA);

  // 20 Leer
  EDI_READ(5);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNode;
end;


sub _ImportVDA_4905_513(aNode : int; aFile : int) : int;
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_513');
  //vNode # aNode->Lib_Xml:AppendNode('Abgrenzungs- und Abrufdaten');
  //vNode->Lib_XML:AppendAttributeNode('Segment','513');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','513');


  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // 03 Erfassungs-Datum letzter Eingang
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('ErfassungsdatLetzterEingang',vA);

  // 04 Lieferschein-Nummer letzter Eingang
  EDI_READ(8);
  vNode->Lib_Xml:AppendNode('LieferscheinNummerLetzterEingang',vA);

  // 05 Lieferschein-Datum letzter Eingang
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('LieferscheinDatumLetzerEingang',vA);

  // 06 Menge letzter Eingang
  EDI_READ(12);
  vNode->Lib_Xml:AppendNode('MengeLetzterEingang',vA);

  // 07 Eingangs-Fortschrittszahl
  EDI_READ(10);
  vNode->Lib_Xml:AppendNode('EinangsFortschrittszahl',vA);

  // Abrufdatum & Menge 1 - 5
  FOR   i # 1
  LOOP  inc(i)
  WHILE i <= 5 DO BEGIN
    // Abrufdatum
    EDI_READ(6);
    vNode->Lib_Xml:AppendNode('Abrufdatum' + Aint(i),vA);

    //  Abrufmenge
    EDI_READ(9);
    vNode->Lib_Xml:AppendNode('Abrufmenge' + Aint(i),vA);
  END;

  // 18 leer
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('Blank',vA);


  RETURN vNOde;
end;


sub _ImportVDA_4905_514(aNode : int; aFile : int) : int
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_514');
  //vNode # aNode->Lib_Xml:AppendNode('Weitere Abrufdaten 514');
  //vNode->Lib_XML:AppendAttributeNode('Segment','514');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','514');


  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // Abrufdatum & Menge 6 bis 13
  FOR   i # 6
  LOOP  inc(i)
  WHILE i <= 13 DO BEGIN
    // 03,05,07,09,... Abrufdatum
    EDI_READ(6);
    vNode->Lib_Xml:AppendNode('Abrufdatum' + Aint(i),vA);

    // 04,06,08,10,... Abrufmenge 1
    EDI_READ(9);
    vNode->Lib_Xml:AppendNode('Abrufmenge' + Aint(i),vA);
  END;


  // 19 leer
  EDI_READ(3);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNode;

end;


sub _ImportVDA_4905_515(aNode : int; aFile : int) : int
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNOde : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_515');
//  vNode # aNode->Lib_Xml:AppendNode('Zusatz LAB-Informationen');
//  vNode->Lib_XML:AppendAttributeNode('Segment','515');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','515');

  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // 03 Fertigungsfreigabe Anfangsdatum
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('FertigungsfreigabeAnfangsdatum',vA);

  // 04 Fertigungsfreigabe Enddatum
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('FertigungsfreigabeEnddatum',vA);

  // 05 Fertigungsfreigabe Kum.Bedarf
  EDI_READ(10);
  vNode->Lib_Xml:AppendNode('FertigungsfreigabeKumBedarf',vA);

  // 06 Materialfreigabe Anfangsdatum
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('MaterialfreigabeAnfangsdatum',vA);

  // 07 Materialfreigabe Enddatum
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('MaterialfreigabeEnddatum',vA);

  // 08 Materialfreigabe Kum.Bedarf
  EDI_READ(10);
  vNode->Lib_Xml:AppendNode('MaterialfreigabeKum.Bedarf',vA);

  // 09 Ergänzende Sachnummer
  EDI_READ(22);
  vNode->Lib_Xml:AppendNode('ErgänzendeSachnummer',vA);

  // 10 Zwischenlieferant
  EDI_READ(9);
  vNode->Lib_Xml:AppendNode('Zwischenlieferant',vA);

  // 11 Datum Planungshorizont
  EDI_READ(6);
  vNode->Lib_Xml:AppendNode('DatumPlanungshorizont',vA);

  // 12 Verbrauchsstelle
  EDI_READ(14);
  vNode->Lib_Xml:AppendNode('Verbrauchsstelle',vA);

  // 13 Zur Nullstellung erreichte Fortschrittszahl
  EDI_READ(10);
  vNode->Lib_Xml:AppendNode('ZurNullstellungerreichteFortschrittszahl',vA);

  // 14 Blank
  EDI_READ(18);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNode;
end;

sub _ImportVDA_4905_517(aNode : int; aFile : int) : int;
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_517');

//  vNode # aNode->Lib_Xml:AppendNode('Datenelement 517');
//  vNode->Lib_XML:AppendAttributeNode('Segment','517');
  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','517');

  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Version',vA);

  // 03 Packmittelnummer Kunde
  EDI_READ(22);
  vNode->Lib_Xml:AppendNode('PackmittelnummerKunde',vA);

  // 04 Packmittelnummer Lieferant
  EDI_READ(22);
  vNode->Lib_Xml:AppendNode('PackmittelnummerLieferant',vA);

  // 05 Fassungsvermögen
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('Fassungsvermögen',vA);

  // 06 Blank
  EDI_READ(72);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNOde;
end;



sub _ImportVDA_4905_518(aNode : int; aFile : int) : int
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNode : int;
end;
begin
  vFIle # aFile;

  vNode # aNode->Lib_Xml:AppendNode('SEG_518');
  // vNode # aNode->Lib_Xml:AppendNode('Datenelement 518');
  // vNode->Lib_XML:AppendAttributeNode('Segment','518');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','518');

  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Versionsnummer',vA);

  // 03 Lieferabruf Text 1
  EDI_READ(40);
  vNode->Lib_Xml:AppendNode('LieferabrufText1',vA);

  // 04 Lieferabruf Text 2
  EDI_READ(40);
  vNode->Lib_Xml:AppendNode('LieferabrufText2',vA);

  // 05 Lieferabruf Text 3
  EDI_READ(40);
  vNode->Lib_Xml:AppendNode('LieferabrufText3',vA);

  // 06 Blank
  EDI_READ(3);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNOde;
end;


sub _ImportVDA_4905_519(aNode : int; aFile : int) : int
local begin
  vA  : alpha(1000);
  vFile : int;
  i  : int;
  vNode : int;
end;
begin
  vFIle # aFile;


  vNode # aNode->Lib_Xml:AppendNode('SEG_519');

  // 01 Typ
  vNode->Lib_Xml:AppendNode('Typ','519');

  // 02 Versionsnummer
  EDI_READ(2);
  vNode->Lib_Xml:AppendNode('Versionsnummer',vA);

  // 03 Zähler Satzart 511
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart511',vA);

  // 04 Zähler Satzart 512
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart512',vA);

  // 05 Zähler Satzart 513
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart513',vA);

  // 06 Zähler Satzart 514
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart514',vA);

  // 07 Zähler Satzart 517
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart517',vA);

  // 08 Zähler Satzart 518
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart518',vA);

  // 09 Zähler Satzart 519
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart519',vA);

  // 10 Zähler Satzart 515
  EDI_READ(7);
  vNode->Lib_Xml:AppendNode('ZählerSatzart515',vA);

  // 11 Blank
  EDI_READ(67);
  vNode->Lib_Xml:AppendNode('Blank',vA);

  RETURN vNOde;
end;


//========================================================================
//  sub ImportAsXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
//    Importiert eine Edifakt Datei und läd Sie in ein XML Baum zur Anzeige
//    in der Vorschau
//========================================================================
sub ImportAsXML(aPathToFile : alpha(1000); var vLevel : int; var vElems : int) : handle
local begin
  vDoc      : int;
  vNode     : handle;
  vMaxLevel : int;
  vFile     : int;
  vA        : alpha(1000);

  vTmp      : int;
  i         : int;

  vCnt511, vCnt512, vCnt513, vCnt514,  vCnt517,  vCnt518, vCnt519, vCnt515 : int;
  vNode511, vNode512  : int;
end begin

  // Node erstellen um XML Dokument laden zu können
  vNode # CteOpen(_cteNode);
  vNode->spID # _XmlNodeDocument;     // XML Dokument erstellen

  vDoc  # vNode;

  // Datei öffen und interpretieren
  vFile # FSIOpen(aPathToFile, _FsiStdRead);

  WHILE (TRUE) DO BEGIN
    EDI_READ(3);

    case vA of
      '511' : begin  vNode511 # _ImportVDA_4905_511(vNode,vFile);     inc(vCnt511);        end;

          '512' : begin  vNode512 # _ImportVDA_4905_512(vNode511,vFile);  inc(vCnt512);  end;

              '513' : begin  _ImportVDA_4905_513(vNode512,vFile);  inc(vCnt513);  end;

              '514' : begin  _ImportVDA_4905_514(vNode512,vFile);  inc(vCnt514);  end;
              '515' : begin  _ImportVDA_4905_515(vNode512,vFile);  inc(vCnt515); end;
              '517' : begin  _ImportVDA_4905_517(vNode512,vFile);  inc(vCnt517); end;
              '518' : begin  _ImportVDA_4905_518(vNode512,vFile);  inc(vCnt518);  end;

          '519' : begin  _ImportVDA_4905_519(vNode511,vFile);  inc(vCnt519);  end;

      otherwise
        break;
    end;

  END;


  FSIClose(vFile);


  // _SaveNodeToXMLFile(vDoc,'c:\test.xml');

  // Tiefen ermitteln
  Lib_XML:SetDepth(vNode,var vMaxLevel, var vElems);

  // Maximales Level zurückgeben
  vLevel # vMaxLevel;

  RETURN vNode;
end;


//========================================================================
// Call Lib_EDI:Repair_AufFuerSchuerholz
//========================================================================
sub Repair_AufFuerSchuerholz();
local begin
  Erx   : int;
  vA,vB : alpha;
  vI    : int;
end;
begin

  TRANSON;

  FOR Erx # RecRead(401,1,_recFirst)
  LOOP Erx # RecRead(401,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ((Auf.P.Kundennr=212018) or (Auf.P.Kundennr=112018)) then begin
      Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
      if (erx<=_rLocked) and (Auf.Vorgangstyp=c_Auf) and ("Auf.LiefervertragYN") then begin
        vA # Auf.P.Best.Nummer;
        if (vA<>'') then begin
          Erx # RecRead(401,1,_recLock);
          vB # Str_Token(vA,'/',1);
          vI # cnvia(Str_Token(vA,'/',2));
          if (vI=0) then vI # 10;
          Auf.P.Best.Nummer # vB + '/' + cnvai(vI, _FmtNumLeadZero|_FmtNumNoGroup,0,5);    // 5 Stellen mit führenden Nullen
Debug('Change KEY401 von '+vA+' auf '+Auf.P.Best.Nummer);
          Erx # RekReplace(401,_recunlock,'AUTO');
          if (erx<>_rOK) then begin
            TRANSBRK;
Todo('Error bei '+aint(auf.p.nummer)+'/'+aint(Auf.p.Position));
            RETURN;
          end;
        end;
      end;
    end;
  END;

  TRANSOFF;

  Msg(999998,'',0,0,0);

end;


//========================================================================