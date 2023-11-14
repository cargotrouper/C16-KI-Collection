@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_EDI_QAL
//                            OHNE E_R_G
//  Stand     11/2016
//
//  Info      EDL=ExterneDienstLeister (Lohn)
//
//
//  02.11.2016  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cTEST : false

  cWoFDatei                     : 501

  cWoFNeuerSatz                 : 300
  cWoFUpdateSatz                : 310

  cWoFDickeFalsch               : 320
  cWoFBreiteFalsch              : 321
  cWoFGueteFalsch               : 322

  cWoFMehrfachMessungen         : 393
  cWoFBuchungsFehler            : 394
  cWoFKeinKopfMatch             : 395
  cWoFKeinPosMatch              : 396
  cWoFKeinAdrMatch              : 397
  cWoFKeineGroup5               : 398
  cWoFDateiDefekt               : 399


  EDI_READ(a)            : begin  vA # VDA_ReadData(vFile,a);   end;
  // XML Lesen
  XML_GetNodeType(a)  : Lib_XML:GetNodeType(a)
  XML_GetValA(a,b)    : Lib_XML:GetValue(a,b);
  XML_GetValI(a,b)    : Lib_XML:GetValueI(a,b);
  XML_GetValI16(a,b)  : Lib_XML:GetValueI16(a,b);
  XML_GetValF(a,b)    : Lib_XML:GetValueF(a,b);
  XML_GetValB(a,b)    : Lib_XML:GetValueB(a,b);
  XML_GetValD(a,b)    : Lib_XML:GetValueD(a,b);
  XML_GetValT(a,b)    : Lib_XML:GetValueT(a,b);

  _ReadNode   : Lib_EDI:_ReadNode
end;

local begin
  gErr        : alpha(1000);
  gWof        : int;
  gWofText    : alpha(1000);

  gFileHdl    : int;
  gActNode    : int;

  gCountDummy : int;
  gCountUNB   : int;
  gCountUNH   : int;
  gCountBGM   : int;
  gCountDTM   : int;
  gCountIMD   : int;
  gCountGrp5  : int;
  gCountUNT   : int;
  gCountUNZ   : int;

  gContext    : alpha;
  gAbmCheck   : logic;
end;

declare _SaveNodeToXMLFile(aXmlDok   : int; aFilename : alpha(4000)) : int;


//========================================================================
//========================================================================
sub StartWoF(
  aDatei  : int;
  aNr     : int;
  aText   : alpha(1000));
begin
  if (aNr=0) then RETURN;
  if (Lib_Workflow:Trigger(aDatei, aNr, '')) then begin
    if (aText<>'') then begin
      RecRead(980,1,_recLock);
      if (Tem.Bemerkung<>'') then
        TeM.Bemerkung # Tem.Bemerkung + ' '+StrCut(aText,1,192)
      else
        TeM.Bemerkung # StrCut(aText,1,192);
      RekReplace(980);
    end;
  end;
end;


//========================================================================
//========================================================================
sub Must(
  aRoot       : int;
  aBlock      : alpha;
  var aCount  : int) : int;
local begin
  vI          : int;
  vNode       : int;
end;
begin
//debugx('must :'+aBlock);
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aBlock)
  if (vNode=0) then begin
    gErr # 'kein '+aBlock;
    RETURN -1;
  end;
  inc(aCount);
  vI # Call(here+':Process_'+aBlock, vNode);
  if (vI<0) then begin
    gErr # aBlock+':'+gErr;
    RETURN -1;
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Can(
  aRoot       : int;
  aBlock      : alpha;
  var aCount  : int) : int;
local begin
  vNode       : int;
  vI          : int;
end;
begin
//debugx('can :'+aBlock);
  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aBlock)
  if (vNode<>0) then begin
    inc(aCount);
    vI # Call(here+':Process_'+aBlock, vNode);
    if (vI<0) then begin
      gErr # aBlock+':'+gErr;
      RETURN -1;
    end;
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Iterate(
  aRoot       : int;
  aBlock      : alpha) : int;
local begin
  vNode       : int;
  vErr        : alpha(1000);
  vAnz        : int;
  vI          : int;
end;
begin

//debugx('iterate :'+aBlock);

  vNode # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aBlock)
//  if (vNode=0) then begin
//    gErr # 'Kein '+aBlock;
//    RETURN -1;
//  end;

  // LOOP
  WHILE (vNode<>0) do begin
    inc(vAnz);

    vI # Call(here+':Process_'+aBlock, vNode);
    if (vI<0) then begin
      gErr # aBlock+':'+gErr;
      RETURN -1;
    end;

    vNode # aRoot->CteRead( _cteChildList | _cteSearch | _CteNext, vNode, aBlock)
  END;

  RETURN vAnz;
end;


//========================================================================
//========================================================================
sub Buche506(
  aWie  : alpha) : int;
local begin
  Erx   : int;
  v506  : int;
  vLfd  : int;
  vMat  : int;
  vCh   : alpha;
  vMin, vMax  : float;
end;
begin

  if (aWie<>'Werksnummer') then RETURN -1;

  vLfd # 0;
  v506 # RekSave(506);
  FOR Erx # RecLink(506,501,14,_recFirst) // Eingänge loopen
  LOOP Erx # RecLink(506,501,14,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (aWie='Werksnummer') and (Ein.E.Werksnummer=v506->Ein.E.Werksnummer) then begin
      vLfd  # Ein.E.Eingangsnr;
      BREAK;
    end;
  END;

  TRANSON;

  // ALTER SATZ -------------------------------
  if (vLfd<>0) then begin
    PtD_Main:Memorize(506);
    RecRead(506,1,_recLock);
    vMat  # Ein.E.Materialnr;
    vCh   # Ein.E.Charge;
    //RecBufCopy(v506, 506, false);
    Ein.E.VSB_Datum         # v506->Ein.E.VSB_Datum;
    Ein.E.Lageradresse      # v506->Ein.E.Lageradresse;
    Ein.E.Lageranschrift    # v506->Ein.E.Lageranschrift
    Ein.E.Menge             # v506->Ein.E.Menge;
    "Ein.E.Stückzahl"       # v506->"Ein.E.Stückzahl";
    Ein.E.Gewicht           # v506->Ein.E.Gewicht;
    SbrCopy(v506, 2, 506,2);
    SbrCopy(v506, 3, 506,3);
    SbrCopy(v506, 4, 506,4);
    SbrCopy(v506, 5, 506,5);
    Ein.E.MaterialNr  # vMat;
    Ein.E.Charge      # vCh;
    Erx # RekReplace(506);
    if (erx<>_rOK) then begin
      PtD_Main:Forget(506);
      RekRestore(v506);
      TRANSBRK;
      RETURN -1;
    end;
    // Update...
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      PtD_Main:Forget(506);
      RekRestore(v506);
      TRANSBRK;
      RETURN -1;
    end;
    PtD_Main:Compare(506);

if (gAbmCheck) then begin
    if ("Ein.E.Güte"<>"Ein.P.Güte") then
      StartWof(cWofDatei, cWofGueteFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
    if (Ein.P.Dickentol<>'') then begin
      Lib_Berechnungen:ToleranzZuWerten(Ein.P.Dickentol,var vMin, var vMax);
      vMin # vMin + Ein.P.Dicke;
      vMax # vMax + Ein.P.Dicke;
      if (Ein.E.Dicke<vMin) or (Ein.E.Dicke>vMax) then
        StartWof(cWofDatei, cWofDickeFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
    end;
    if (Ein.P.Breitentol<>'') then begin
      Lib_Berechnungen:ToleranzZuWerten(Ein.P.Breitentol,var vMin, var vMax);
      vMin # vMin + Ein.P.Breite;
      vMax # vMax + Ein.P.Breite;
      if (Ein.E.Breite<vMin) or (Ein.E.Breite>vMax) then
        StartWof(cWofDatei, cWofBreiteFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
    end;
end;


    TRANSOFF;
    RecbufDestroy(v506);
    RETURN 0;
  end;

  // NEUER SATZ -------------------------------
  RekRestore(v506);

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
  Ein.E.Verwiegungsart  # Ein.P.Verwiegungsart;
  Erx # RekLink(818,506,12,_RecFirst);
  if (erx>_rLockeD) then VWa.nettoyn # true;
  if (VWa.NettoYN) then
    Ein.E.Gewicht # Ein.E.Gewicht.Netto
  else
    Ein.E.Gewicht # Ein.E.Gewicht.Brutto;

  Ein.E.AbbindungL      # Ein.P.AbbindungL;
  Ein.E.AbbindungQ      # Ein.P.AbbindungQ;
  Ein.E.Zwischenlage    # Ein.P.Zwischenlage;
  Ein.E.Unterlage       # Ein.P.Unterlage;
  Ein.E.Umverpackung    # Ein.P.Umverpackung;
  Ein.E.Wicklung        # Ein.P.Wicklung;
  Ein.E.StehendYN       # Ein.P.StehendYN;
  Ein.E.LiegendYN       # Ein.P.LiegendYN;
  Ein.E.Nettoabzug      # Ein.P.Nettoabzug;
  "Ein.E.Stapelhöhe"    # "Ein.P.Stapelhöhe";
  "Ein.E.Stapelhöhenabz"  # "Ein.P.StapelhAbzug";

  Ein.E.AusfOben        # Ein.P.AusfOben;
  Ein.E.AusfUnten       # Ein.P.AusfUnten;

  REPEAT
    Ein.E.Eingangsnr # Ein.E.Eingangsnr + 1;
    Erx # RekInsert(506,0,'JOB');
  UNTIL (erx=_rOK);

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
    TRANSBRK;
    RETURN -1;
  end;

  if ("Ein.E.Güte"<>"Ein.P.Güte") then
    StartWof(cWofDatei, cWofGueteFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
  if (Ein.E.Dickentol<>'') then begin
    Lib_Berechnungen:ToleranzZuWerten(Ein.E.Dickentol,var vMin, var vMax);
    vMin # vMin + Ein.P.Dicke;
    vMax # vMax + Ein.P.Dicke;
    if (Ein.E.Dicke<vMin) or (Ein.E.Dicke>vMax) then
      StartWof(cWofDatei, cWofDickeFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
  end;
  if (Ein.E.Breitentol<>'') then begin
    Lib_Berechnungen:ToleranzZuWerten(Ein.E.Breitentol,var vMin, var vMax);
    vMin # vMin + Ein.P.Breite;
    vMax # vMax + Ein.P.Breite;
    if (Ein.E.Breite<vMin) or (Ein.E.Breite>vMax) then
      StartWof(cWofDatei, cWofBreiteFalsch,' Nr.'+aint(Ein.E.Eingangsnr));
  end;

  TRANSOFF;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_UNB(
  aRoot         : int) : int;
local begin
end;
begin
  RETURN 1;
end;

//========================================================================
//========================================================================
sub Process_UNH(
  aRoot         : int) : int;
local begin
end;
begin
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_BGM(
  aRoot         : int) : int;
local begin
end;
begin
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_DTM(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
  vDat          : date;
end;
begin

  if (_ReadNode(aRoot, 'C507', var vNode)) then RETURN -1;

  // kein Datum???
  if (_ReadNode(vNode, 'D2005', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);
  if (vTyp<>'137') then RETURN -1;

  // verdrehtes Datum?
  if (_ReadNode(vNode, 'D2379', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);
  if (vTyp<>'204') then RETURN -1;

  if (_ReadNode(vNode, 'D2380', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vInhalt);

  if (StrLen(vInhalt)<>14) then RETURN -1
  vDat # DateMake(cnvia(strcut(vInhalt,7,2)), cnvia(strcut(vInhalt,5,2)), cnvia(strcut(vInhalt,1,4))-1900);


  if (gContext='RFF=AAK') then begin
    Ein.E.VSB_Datum # vDat;
    Ein.E.VSBYN     # y;
  end;

  gContext # '';

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_RFF(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
  vInhalt2      : alpha;
end;
begin
//Lib_Edi:ProcessNode(aRoot);
  if (_ReadNode(aRoot, 'C506', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D1153', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);

  if (_ReadNode(vNode, 'D1154', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vInhalt);
  if (_ReadNode(vNode, 'D1156', var vNode2)=false) then
    XML_GetValA(vNode2, var vInhalt2);

  case vTyp of
    'CO'  : Ein.E.Nummer    # cnvia(vInhalt);
    'VN'  : Ein.P.AB.Nummer # vInhalt+'/'+vInhalt2;
    'AAK' : gContext        # 'RFF=AAK';
    // AEE
  end;

  RETURN 1;
end;

//========================================================================
//========================================================================
sub Process_IMD(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vTyp          : alpha;
  vInhalt       : alpha;
end;
begin
  if (_ReadNode(aRoot, 'D7081', var vNode)) then RETURN -1;
  XML_GetValA(vNode, var vTyp);

  if (_ReadNode(aRoot, 'C273', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D7008', var vNode)) then RETURN -1;
  XML_GetValA(vNode, var vInhalt);

  case vTyp of
//    '1' :   debugx('Certificate = '+vInhalt);
//    '8' :   debugx('Product = '+vInhalt);
    '13' : "Ein.E.Güte" # StrCut(vInhalt,1,20);
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_UNT(
  aRoot         : int) : int;
local begin
end;
begin
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_UNZ(
  aRoot         : int) : int;
local begin
end;
begin
  RETURN 1;
end;

//========================================================================
//========================================================================
sub Process_Group_5(
  aRoot         : int) : int;
local begin
  Erx           : int;
  vSiren        : alpha;
  vStichwort    : alpha;
  vBest, vPos   : alpha;
  vI            : int;
end;
begin

  RecBufClear(500);
  RecBufClear(501);
  RecBufClear(506);
  "Ein.E.Stückzahl" # 1;

  if (Must(aRoot, 'LIN', var gCountDummy)<0) then RETURN -1;
  if (Iterate(aRoot, 'PIA')<0) then RETURN -1;
  if (Iterate(aRoot, 'IMD')<0) then RETURN -1;
  if (Iterate(aRoot, 'MEA')<0) then RETURN -1;
  if (Iterate(aRoot, 'Group_6')<0) then RETURN -1;
  if (Iterate(aRoot, 'Group_7')<0) then RETURN -1;
  if (Iterate(aRoot, 'Group_12')<0) then RETURN -1;



  // Erzeuger suchen anhand SIREN ----------------------------------------
  vSiren      # Ein.E.Bemerkung;
  vStichwort  # Ein.E.Mech.Sonstig;
  if (cTEST) then begin
    vSiren # '0936811119214';
  end;

  Ein.E.Bemerkung     # '';
  Ein.E.Mech.Sonstig  # '';
  if (Cus_Data:FindTheOne(100, 100, vSiren)=_rOK) then begin
    RecRead(100, 0, _RecID, CUS.RecID); // Adresse laden
    Ein.E.Erzeuger        # Adr.Nummer;
    Ein.E.Lageradresse    # Adr.Nummer;
    Ein.E.Lageranschrift  # 1;
  end
  else if (Cus_Data:FindTheOne(100, 100, vStichwort)=_rOK) then begin
    RecRead(100, 0, _RecID, CUS.RecID); // Adresse laden
    Ein.E.Erzeuger        # Adr.Nummer;
    Ein.E.Lageradresse    # Adr.Nummer;
    Ein.E.Lageranschrift  # 1;
  end
  else if (Cus_Data:FindTheOne(101, 100, vSiren)=_rOK) then begin
    RecRead(101, 0, _RecID, CUS.RecID); // Anschrift laden
    Ein.E.Erzeuger        # Adr.A.Adressnr;
    Ein.E.Lageradresse    # Adr.A.Adressnr;
    Ein.E.Lageranschrift  # Adr.A.Nummer;
  end
  else if (Cus_Data:FindTheOne(101, 100, vStichwort)=_rOK) then begin
    RecRead(101, 0, _RecID, CUS.RecID); // Anschrift laden
    Ein.E.Erzeuger        # Adr.A.Adressnr;
    Ein.E.Lageradresse    # Adr.A.Adressnr;
    Ein.E.Lageranschrift  # Adr.A.Nummer;
  end
  else begin
//gErr # 'kein SIREN Match '+vSiren+'|'+vStichwort;
    gWof      # cWofKeinAdrMatch;
    gWofText  # vSiren+'/'+vStichwort;
    // KEIN MATCH
    RETURN -1;
  end;


  // Bestellung suchen --------------------------------------------------
  vBest # Str_token(Ein.P.AB.Nummer,'/',1);
  vPos  # Str_token(Ein.P.AB.Nummer,'/',2);

  if (cTEST) then begin
    vBest  # 'FH6HINM006';
    vPos   # '000001';
  end;

  Ein.P.AB.Nummer # '';
  Ein.AB.Nummer # vBest;
  Erx # RecRead(500,4,0); // nach AB-Nummer suchen
  if (Erx>_rMultikey) then begin
//gErr # 'kein KOPF Match : '+vBest;
    gWof      # cWofKeinKopfMatch;
    gWofText  # vBest;
    // KEIN KOPF
    RETURN -1;
  end;
  FOR Erx # RecLink(501,500,9,_recFirst)  // Posten loopen...
  LOOP Erx # RecLink(501,500,9,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (Ein.P.AB.Nummer=vPos) then begin
      // FOUND !!!
      Ein.E.Nummer      # Ein.P.Nummer;
      Ein.E.Position    # Ein.P.Position;

      vI # Buche506('Werksnummer');
      if (vI<0) then begin
//gErr # 'Wareneingang nicht buchbar : '+vBest+'|'+vPos;
        gWof      # cWofBuchungsFehler;
        gWofText  # vBest+'/'+vPos;
        RETURN -1;
      end;
      if (vI>0) then begin
        // NEU
//debugx('neur WE !');
        StartWof(cWofDatei, cWofNeuerSatz,' Nr.'+aint(Ein.E.Eingangsnr));
      end
      else begin
        // ALT
//debugx('alter WE !');
        StartWof(cWofDatei, cWofUpdateSatz,' Nr.'+aint(Ein.E.Eingangsnr));
      end;
//      Lib_Debug:Dump(506);
      RETURN 1;
    end;
  END;

//gErr # 'kein POS Match : '+vBest+'|'+vPos;
  gWof      # cWofKeinPosMatch;
  gWofText  # vBest+'/'+vPos;

  // KEINE POSITION
  RETURN -1;
end;


//========================================================================
//========================================================================
sub Process_LIN(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vTyp          : alpha;
  vInhalt       : alpha;
end;
begin
  if (_ReadNode(aRoot, 'C212', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D7140', var vNode)) then RETURN -1;
  XML_GetValA(vNode, var vInhalt);

  Ein.E.Werksnummer # StrCut(vInhalt,1,32);

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_PIA(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
end;
begin
  if (_ReadNode(aRoot, 'C212', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D7140', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vInhalt);

  Ein.E.Chargennummer # StrCut(vInhalt,1,32);

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Wert_C174(
  aRoot         : int;
  var aWert     : float) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
end;
begin
  if (_ReadNode(aRoot, 'C174', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D6411', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);
  if (_ReadNode(vNode, 'D6314', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vInhalt);

  case vTyp of
    'MTR' : aWert # cnvfa(vInhalt)*1000.0   // Meter
    'MMT' : aWert # cnvfa(vInhalt)          // mm
    'GRM' : aWert # cnvfa(vInhalt)*1000.0   // Gramm
    'GGM' : aWert # cnvfa(vInhalt)          // kg
    'TNE' : aWert # cnvfa(vInhalt)*1000.0   // Tonne
    //'MTK' : aWert # cnvfa(vInhalt)        // qm
    'P1'  : aWert # cnvfa(vInhalt)          // Prozent
    'MPa' : aWert # cnvfa(vInhalt)          // MegaPascal
    'PC'  : aWert # cnvfa(vInhalt)          // Prozent
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_MEA(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
  vN            : float;
end;
begin
  if (_ReadNode(aRoot, 'C502', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D6313', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);

  case vTyp of
    'AAL' : begin                                       // NETTOGEWICHT
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Gewicht.Netto # vN;
    end;

    'G' : begin                                         // BRUTTOGEWICHT
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Gewicht.Brutto # vN
    end;

    'TH' : begin                                        // DICKE
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Dicke # vN;
    end;

    'WD' : begin                                        // BREITE
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Breite # vN;
    end;

    'LN' : begin                                        // LÄNGE
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      "Ein.E.Länge" # vN;
    end;

    'ZC' : begin                                        // Chemie C
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.C # vN;
    end;
    'ZSI' : begin                                       // Chemie Si
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Si # vN;
    end;
    'ZMN' : begin                                       // Chemie Mn
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Mn # vN;
    end;
    'ZP' : begin                                        // Chemie P
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.P # vN;
    end;
    'ZS' : begin                                        // Chemie S
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.S # vN;
    end;
    'ZAL' : begin                                       // Chemie Al
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Al # vN;
    end;
    'ZCR' : begin                                       // Chemie CR
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Cr # vN;
    end;
    'ZTV' : begin                                       // Chemie V
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.V # vN;
    end;
    'ZNB' : begin                                       // Chemie Nb
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Nb # vN;
    end;
    'ZTI' : begin                                       // Chemie Ti
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Ti # vN;
    end;
    'ZN' : begin                                        // Chemie N
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.N # vN;
    end;
    'ZCU' : begin                                       // Chemie Cu
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Cu # vN;
    end;
    'ZNI' : begin                                       // Chemie Ni
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Ni # vN;
    end;
    'ZMO' : begin                                       // Chemie Mo
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.Mo # vN;
    end;
    'ZB' : begin                                        // Chemie B
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Chemie.B # vN;
    end;

    'YS' : begin                                        // Mech Streckgrenze
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Streckgrenze # vN;
    end;
    'CR' : begin                                        // Mech Zugfestigkeit
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.Zugfestigkeit # vN;
    end;
    'EA' : begin                                        // Mech DehnungA
      if (Wert_C174(aRoot, var vN)<0) then RETURN -1;
      Ein.E.DehnungA # vN;
    end;
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_NAD(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
  vSiren        : alpha;
  vStichwort    : alpha;
end;
begin

  if (_ReadNode(aRoot, 'D3035', var vNode)) then RETURN -1;
  XML_GetValA(vNode, var vTyp);
  if (vTyp<>'MP') then RETURN 0;

  if (_ReadNode(aRoot, 'C080', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D3036', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vStichwort);
  if (_ReadNode(aRoot, 'D3039', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vSiren);
  Ein.E.Bemerkung     # vSiren;
  Ein.E.Mech.Sonstig  # vStichwort;

  if (_ReadNode(aRoot, 'D3207', var vNode)) then RETURN -1;
  XML_GetValA(vNode, var vInhalt);
  Ein.E.Ursprungsland # vInhalt;

//  if (_ReadNode(aRoot, 'D3124', var vNode)) then RETURN -1;
//  XML_GetValA(vNode, var vInhalt);

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_Group_6(
  aRoot         : int) : int;
local begin
end;
begin
  if (Iterate(aRoot, 'RFF')<0) then RETURN -1;
  if (Iterate(aRoot, 'DTM')<0) then RETURN -1;
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_Group_7(
  aRoot         : int) : int;
local begin
end;
begin
  if (Must(aRoot, 'NAD', var gCountDummy)<0) then RETURN -1;
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_Group_12(
  aRoot         : int) : int;
local begin
  vNode         : int;
  vNode2        : int;
  vTyp          : alpha;
  vInhalt       : alpha;
  vN            : float;
end;
begin
  if (_ReadNode(aRoot, 'CCI', var vNode)) then RETURN -1;
  if (_ReadNode(vNode, 'D7059', var vNode2)) then RETURN -1;
  XML_GetValA(vNode2, var vTyp);

  // Chemie?
  if (vTyp='1') then begin
    if (Iterate(aRoot, 'Group_14')<0) then RETURN -1;
  end
  // Mechanik
  else if (vTyp='2') then begin
    if (Iterate(aRoot, 'Group_14')<0) then RETURN -1;
  end;

  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_Group_14(
  aRoot         : int) : int;
local begin
end;
begin
  if (Must(aRoot, 'MEA', var gCountDummy)<0) then RETURN -1;
  RETURN 1;
end;


//========================================================================
//========================================================================
sub Process_QALITY(
  aRoot   : int) : logic;
local begin
  vBlock      : alpha;
  vNode       : int;
  vNode2      : int;
  vA,vB,vX    : alpha(200);
  vI          : int;

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
  if (Must(aRoot, 'UNB', var gCountUNB)<0) then RETURN false;
  if (Must(aRoot, 'UNH', var gCountUNH)<0) then RETURN false;
  if (Must(aRoot, 'BGM', var gCountBGM)<0) then RETURN false;
  if (Must(aRoot, 'DTM', var gCountDTM)<0) then RETURN false;
  if (Can(aRoot, 'IMD', var gCountIMD)<0) then RETURN false;

  gCountGrp5 # Iterate(aRoot, 'Group_5')
  if (gCountGrp5<0) then RETURN false;
  if (gCountGrp5=0) then begin
    //gErr  # 'keine GROUP_5 im File';
    gWof  # cWofKeineGroup5;
    RETURN false;
  end;

  if (Must(aRoot, 'UNT', var gCountUNT)<0) then RETURN false;
  if (Must(aRoot, 'UNZ', var gCountUNZ)<0) then RETURN false;

//  if (vMEH<>'kg') then RETURN '512:falsche MEH '+vMEH;

/***
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
    vErr # ProcessXML513(vNode, vI, var vZeitraum, var vTyp, var vZahl, var vJahr, var vTermin, var vMenge);
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
      vErr # ProcessXML514(vNode, vI, var vZeitraum, var vTyp, var vZahl, var vJahr, var vTermin, var vMenge);
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
  vErr # ProcessXML519(vNode);
  if (vErr<>'') then RETURN '519:'+vErr;
***/

  RETURN true;
end;


//========================================================================
//  LoadXML_QALITY
//  call lib_edi_Qal:LoadXML_QALITY
//========================================================================
SUB LoadXML_QALITY(
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

  if (aFilename='') then begin
    aFileName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'XML-Dateien|*.xml');
    if ( aFilename = '' ) then RETURN false;
  end;
lib_Debug:StartBlueMode();

  /* XML Initialisierung */
  vDoc # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;

  Erx # vDoc->XmlLoad( aFilename);
  if (erx != _errOk ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
//debugx('kein XML file');
    StartWoF(999, cWofDateiDefekt, 'kein XML file');
    RETURN false;
  end;

  vRoot # vDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'QALITY');
  if (vRoot=0) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
//debugx('Kennung "QALITY" fehlt');
    StartWoF(999, cWofDateiDefekt, 'kein QALITY-XML file');
    RETURN false;
  end;


gAbmCheck # Msg(99,'Abmessungen & Güte prüfen?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes;


  TRANSON;

  if (Process_QALITY(vRoot)=false) then begin
    TRANSBRK;
    StartWoF(999, gWof, gWofText);
//Msg(99,'Fehler:'+StrChar(13)+gErr,0,0,0);
//todox('    if (cWofDateiDefekt<>0) then Lib_Workflow:Trigger(999, cWoFDateiDefekt, '');');
    // Aufräumen...
    vDoc->CteClear( true );
    vDoc->CteClose();
    RETURN false;
  end;

  // Aufräumen...
  vDoc->CteClear( true );
  vDoc->CteClose();

  TRANSOFF;

/***
gErr # 'ALLES OK - siehe DEBUG.TXT'+StrChar(13)+
'UNB '+aint(gCountUNB)+StrChar(13)+
'UNH '+aint(gCountUNH)+StrChar(13)+
'BGM '+aint(gCountBGM)+StrChar(13)+
'DTM '+aint(gCountDTM)+StrChar(13)+
'IMD '+aint(gCountIMD)+StrChar(13)+
'Grp5 '+aint(gCountGrp5)+StrChar(13)+
'UNT '+aint(gCountUNT)+StrChar(13)+
'UNZ '+aint(gCountUNZ)+StrChar(13);
Msg(99,gErr,0,0,0);
***/
  RETURN true;
end;


//========================================================================
// Call Lib_EDI_Qal:Beispiele
//========================================================================
sub Beispiele();
local begin
  vPath   : alpha(1000);
  vDirHdl : int;
  vName   : alpha(1000);
end;
begin
  vPath   # 'd:\inmet\Beispiele\';
  vDirHdl # FsiDirOpen(vPath+'*.out', _FsiAttrHidden);
  vName   # vDirHdl->FsiDirRead(); // erste Datei
  WHILE (vName != '') do begin
//debug(vPath+vName);
    LoadXML_Qality(vPath+vName);

    vName # vDirHdl->FsiDirRead();
  end;
end;


//========================================================================