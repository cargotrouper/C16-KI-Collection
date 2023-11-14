@A+
/*
//===== Business-Control =================================================

Prozedur  EDI_Einkauf
                  OHNE E_R_G
Info      EDIFACT-ORDERS    Export
          EDIFACT-ORDERSP   Import


2019-04-30  AH  Erstellung der Prozedur
2019-07-10  AH  Erweiterungen, AFX "EDI.Einkauf.RecRead"
2019-07-11  AH  Fixes
2019-07-15  AH  Fixes
2019-07-16  AH  Erweiterungen um Aufpreise
2019-07-18  AH  AFX "EDI.Einkauf.NodeCreated"
2019-11-12  AH  "CreateFile" kann auch nur eine Position
2020-06-08  AH  "StartImport"
2022-04-05  AH  ERX
2022-06-14  ST  JOB.Import hinzugefügt
2022-11-08  ST  "_MoveTOResult" optionaler

 
mögliche spezial Anker:
                EDI.Einkauf.Import.Process  : im ROOT: aNode : int; var "\", "", var vErr ; alpha

Subprozeduren
  todo

//========================================================================
*/

@I:Def_Global
@I:Def_EDI

define begin
  cTEST : true
  cWoFDateiDefekt               : 10399
  cDemoFile : 'd:\test\Einkauf_aus_sc.xml'
end;

declare ProcessFile(aFileName : alpha(1000)) : logic;
declare ProcessRoot(aRoot : int) : logic;


declare StartImport(opt aFileName : alpha(1000)) : logic;
declare ProcessRootImport(aRoot : int) : logic;
declare SucheBestellung(aLfNr : int; aBest : alpha; aEkNr : int; aEkPos : int; aAbRef : alpha; var aWofErr : int; var aErr : alpha) : logic;
declare Buche506(a506 : int; var aWofErr : int; var aErr : alpha) : logic;



//========================================================================
//========================================================================
sub VonBisNode(
  aNode   : int;
  aName   : alpha;
  aWert1  : float;
  aWert2  : float)
begin
  NewNodeF(aNode, aName+'Min', aWert1);
  NewNodeF(aNode, aName+'Bis', aWert2);
end;


//========================================================================
//  call EDI_Einkauf:CreateFile
//========================================================================
sub CreateFile(
  aFilename     : alpha(255);
  opt aNurPos   : int;
)
local begin
  Erx     : int;
  vDoc    : handle;
  vNode   : handle;
  vNode2  : handle;
  vNode3  : handle;
  vI,vJ   : int;
  vF,vF2  : float;
  vDat    : date;
  vA      : alpha(500);
  vName   : alpha;
  vTxt    : int;
end
begin

  if ( StrCnv( StrCut( aFileName, StrLen( aFilename ) - 3, 4 ), _strLower ) != '.xml' ) then
    aFileName # aFilename + '.xml'

  vTxt # TextOpen(20);

  // XML Initialisierung
  vDoc       # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vDoc->CteInsertNode( '', _xmlNodeComment, ' Stahl Control 2019 - EINKAUF');

  RunAFX('EDI.Einkauf.RecRead','500|Kopf');

  Erx # RecLink(100,500,1,_recFirst);   // Lieferant holen
  RunAFX('EDI.Einkauf.RecRead','100|Lieferant');

  // Kopfdateten
  vNode # vDoc->Lib_XML:AppendNode( 'Einkauf' );
  NewNodeA(vNode, 'Version', '1.001'  );
  NewNodeI(vNode, 'Bestellnr', Ein.Nummer);
  NewNodeI(vNode, 'Lieferantennr', Ein.Lieferantennr);
  NewNodeA(vNode, 'Kundennr', Adr.EK.Referenznr);
  NewNodeD(vNode, 'Datum', Ein.Datum);
  NewNodeA(vNode, 'AB_Nummer', Ein.AB.Nummer);
  NewNodeD(vNode, 'AB_Datum', Ein.AB.Datum);
 
  Erx # RecLink(101,500,2,_recFirst);   // Lieferanschrift holen
  RunAFX('EDI.Einkauf.RecRead','101|Lieferanschrift');

  NewNodeA(vNode, 'Lieferanschrift_Anrede', Adr.A.Anrede);
  NewNodeA(vNode, 'Lieferanschrift_Name',   Adr.A.Name);
  NewNodeA(vNode, 'Lieferanschrift_Zusatz', Adr.A.Zusatz);
  NewNodeA(vNode, 'Lieferanschrift_Strasse',"Adr.A.Straße");
  NewNodeA(vNode, 'Lieferanschrift_LKZ',    Adr.A.LKZ);
  NewNodeA(vNode, 'Lieferanschrift_PLZ',    Adr.A.PLZ);
  NewNodeA(vNode, 'Lieferanschrift_Ort',    Adr.A.Ort);

  FOR Erx # RecLink(501,500,9,_RecFirst)
  LOOP Erx # RecLink(501,500,9,_RecNext)
  WHILE (Erx<=_rLocked) do begin
  
    if (aNurPos<>0) then begin
      if (Ein.P.Position<>aNurPos) then CYCLE;
    end;

    if (RunAFX('EDI.Einkauf.RecRead','501|Position')<>0) then begin
      if (AfxRes<>_rOK) then CYCLE;
    end;
    
    if ("Ein.P.Löschmarker"<>'') then CYCLE;

    vNode2 # vNode->Lib_XML:AppendNode( 'Position' );
      NewNodeComment(vNode2,'fortlaufende Nummer pro Rahmen');
      NewNodeI(vNode2, 'Bestellposition', Ein.P.Position);

      NewNodeA(vNode2, 'LfArtikelnr', "Ein.P.LieferArtNr");
      NewNodeA(vNode2, 'Artikelnr', "Ein.P.Artikelnr");
      NewNodeA(vNode2, 'Sachnummer', Ein.P.Sachnummer);
      NewNodeA(vNode2, 'Bemerkung', "Ein.P.Bemerkung");
      NewNodeA(vNode2, 'Guete', "Ein.P.Güte");
      NewNodeA(vNode2, 'Guetenstufe', "Ein.P.Gütenstufe");
      NewNodeF(vNode2, 'Dicke', Ein.P.Dicke);
      NewNodeF(vNode2, 'Breite', Ein.P.Breite);
      NewNodeF(vNode2, 'Laenge', "Ein.P.Länge");
      NewNodeA(vNode2, 'Dickentoleranz', "Ein.P.Dickentol");
      Lib_Berechnungen:ToleranzZuWerten("Ein.P.Dickentol", var vF, var vF2);
      NewNodeF(vNode2, 'Dickentoleranz_Von', vF);
      NewNodeF(vNode2, 'Dickentoleranz_Bis', vF2);
      NewNodeA(vNode2, 'Breitentoleranz', "Ein.P.Breitentol");
      Lib_Berechnungen:ToleranzZuWerten("Ein.P.Breitentol", var vF, var vF2);
      NewNodeF(vNode2, 'Breitentoleranz_Von', vF);
      NewNodeF(vNode2, 'Breitentoleranz_Bis', vF2);
      NewNodeA(vNode2, 'Laengentoleranz', "Ein.P.Längentol");
      Lib_Berechnungen:ToleranzZuWerten("Ein.P.Längentol", var vF, var vF2);
      NewNodeF(vNode2, 'Laengentoleranz_Von', vF);
      NewNodeF(vNode2, 'Laengentoleranz_Bis', vF2);
      NewNodeF(vNode2, 'RIDmin', Ein.P.RID);
      NewNodeF(vNode2, 'RIDmax', Ein.P.RIDMax);
      NewNodeF(vNode2, 'RADmin', Ein.P.RAD);
      NewNodeF(vNode2, 'RADmax', Ein.P.RADMax);
      NewNodeA(vNode2, 'Zeugnis', Ein.P.Zeugnisart);
      NewNodeI(vNode2, 'Erzeugernr', Ein.P.Erzeuger);
      Erx # RecLink(100,501,11,_recfirst);    // Erzeuger holen
      if (Erx>_rLocked) then RecbufClear(100);
      RunAFX('EDI.Einkauf.RecRead','100|Erzeuger');

      vA # Adr.Stichwort;
      NewNodeA(vNode2, 'ErzeugerStichwort', vA);
      NewNodeF(vNode2, 'Grundpreis', Ein.P.Grundpreis);
      NewNodeF(vNode2, 'Einzelpreis', Ein.P.Einzelpreis);
      NewNodeF(vNode2, 'Gesamtpreis', Ein.P.Gesamtpreis);

      NewNodeI(vNode2, 'Stueckzahl', "Ein.P.Stückzahl" );
      NewNodeF(vNode2, 'Gewicht', Ein.P.Gewicht);
      NewNodeA(vNode2, 'MEH', Ein.P.MEH.Wunsch);
      NewNodeF(vNode2, 'Menge', Ein.P.Menge.Wunsch);
     
      NewNodeComment(vNode2,'ENTWEDER explizite Nr. ODER über Refcode');
      NewNodeD(vNode2, 'Wunschtermin', Ein.P.Termin1Wunsch);
      NewNodeA(vNode2, 'Termintyp', Ein.P.Termin1W.Art);
      NewNodeI(vNode2, 'Terminzahl', Ein.P.Termin1W.Zahl);
      NewNodeI(vNode2, 'Terminjahr', Ein.P.Termin1W.Jahr);

      NewNodeD(vNode2, 'Wunschtermin2', Ein.P.Termin2Wunsch);
      NewNodeI(vNode2, 'Termin2zahl', Ein.P.Termin2W.Zahl);
      NewNodeI(vNode2, 'Termin2jahr', Ein.P.Termin2W.Jahr);

      NewNodeA(vNode2, 'Zwischenlage', Ein.P.Zwischenlage);
      NewNodeA(vNode2, 'Unterlage', Ein.P.Unterlage);
      NewNodeA(vNode2, 'Umverpackung', Ein.P.Umverpackung);
      NewNodeF(vNode2, 'StapelhoeheMax', "Ein.P.Stapelhöhe");
      NewNodeF(vNode2, 'RinggewichtMin', "Ein.P.RingkgVon");
      NewNodeF(vNode2, 'RinggewichtMax', "Ein.P.RingkgBis");
      NewNodeF(vNode2, 'kgmmMin', "Ein.P.kgmmVon");
      NewNodeF(vNode2, 'kgmmMax', "Ein.P.kgmmBis");
      NewNodeF(vNode2, 'VEMax', "Ein.P.VEkgmax");
      NewNodeI(vNode2, 'AbbindungLaengs', "Ein.P.AbbindungL");
      NewNodeI(vNode2, 'AbbindungQuer', "Ein.P.AbbindungQ");
      NewNodeI(vNode2, 'Etikettentyp', Ein.P.Etikettentyp);
      Erx # RecLink(840,501,9,_RecFirst);       // Etikettentyp
      if (Erx>_rLocked) then RecBufClear(840);
      RunAFX('EDI.Einkauf.RecRead','840|Etikettentyp');
      NewNodeA(vNode2, 'Etikettentyp_Bezeichnung', Eti.Bezeichnung);
      vA # '';
      if (Ein.P.StehendYN) then vA # 'stehend';
      if (Ein.P.LiegendYN) then vA # 'liegend';
      NewNodeA(vNode2, 'Lage', vA);
      vA # 'nein';
      if (Ein.P.MitLfEYN) then vA # 'ja';
      NewNodeA(vNode2, 'Lieferantenerklaerung', vA);

      vName # '';
      if (Ein.P.TextNr1=501) then         // individuelker Text?
        vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)
      else if (Ein.P.TextNr1=500) then    // anderer PosText?
        vName # '~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
      if (vName<>'') then
        Erx # TextRead(vTxt, vName,0);
        
      if (Ein.P.TextNr1=0) then begin     // Standard Text?
        vName # '~837.'+CnvAI(Ein.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
        Erx # TextRead(vTxt, vName,0);
        if (Erx<=_rLocked) then begin
          Lib_Texte:TxtLoad5Buf('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), vTxt,0,0,0,0);
        end;
      end;

      RunAFX('EDI.Einkauf.RecRead','Text|'+aint(vTxt));

      vI # 1;
      WHILE (vI<=5) and (vI<=TextInfo(vTxt, _textLines)) do begin
        vA # TextLineread(vTxt, vI, 0);
        NewNodeA(vNode2, 'Text'+aint(vI), StrCut(vA,1,70));
        inc(vI);
      END;

      VonBisNode(vNode2, 'Streckgrenze', Ein.P.Streckgrenze1, Ein.P.Streckgrenze2);
      VonBisNode(vNode2, 'Zugfestigkeit', Ein.P.Zugfestigkeit1, Ein.P.Zugfestigkeit2);
      NewNodeF(vNode2, 'DehnungA', Ein.P.DehnungA1);
      VonBisNode(vNode2, 'Dehnung', Ein.P.DehnungB1, Ein.P.DehnungB2);
      VonBisNode(vNode2, 'DehngrenzeRp02', Ein.P.DehngrenzeA1, Ein.P.DehngrenzeA2);
      VonBisNode(vNode2, 'DehngrenzeRp10', Ein.P.DehngrenzeB1, Ein.P.DehngrenzeB2);
      VonBisNode(vNode2, 'Koernung', "Ein.P.Körnung1", "Ein.P.Körnung2");
      VonBisNode(vNode2, 'Haerte', "Ein.P.Härte1", "Ein.P.Härte2");
      VonBisNode(vNode2, 'RauhigkeitOben', Ein.P.RauigkeitA1, Ein.P.RauigkeitA2);
      VonBisNode(vNode2, 'RauhigkeitUnten', Ein.P.RauigkeitB1, Ein.P.RauigkeitB2);
      
      VonBisNode(vNode2, 'Chemie_C',   Ein.P.Chemie.C1, Ein.P.Chemie.C2);
      VonBisNode(vNode2, 'Chemie_Si',  Ein.P.Chemie.Si1, Ein.P.Chemie.Si2);
      VonBisNode(vNode2, 'Chemie_Mn', Ein.P.Chemie.Mn1, Ein.P.Chemie.Mn2);
      VonBisNode(vNode2, 'Chemie_P', Ein.P.Chemie.P1, Ein.P.Chemie.P2);
      VonBisNode(vNode2, 'Chemie_S', Ein.P.Chemie.S1, Ein.P.Chemie.S2);
      VonBisNode(vNode2, 'Chemie_Al', Ein.P.Chemie.Al1, Ein.P.Chemie.Al2);
      VonBisNode(vNode2, 'Chemie_Cr', Ein.P.Chemie.Cr1, Ein.P.Chemie.Cr2);
      VonBisNode(vNode2, 'Chemie_V', Ein.P.Chemie.V1, Ein.P.Chemie.V2);
      VonBisNode(vNode2, 'Chemie_Nb', Ein.P.Chemie.Nb1, Ein.P.Chemie.Nb2);
      VonBisNode(vNode2, 'Chemie_Ti', Ein.P.Chemie.Ti1, Ein.P.Chemie.Ti2);
      VonBisNode(vNode2, 'Chemie_N', Ein.P.Chemie.N1, Ein.P.Chemie.N2);
      VonBisNode(vNode2, 'Chemie_Cu', Ein.P.Chemie.Cu1, Ein.P.Chemie.Cu2);
      VonBisNode(vNode2, 'Chemie_Ni', Ein.P.Chemie.Ni1, Ein.P.Chemie.Ni2);
      VonBisNode(vNode2, 'Chemie_Mo', Ein.P.Chemie.Mo1, Ein.P.Chemie.Mo2);
      VonBisNode(vNode2, 'Chemie_B', Ein.P.Chemie.B1, Ein.P.Chemie.B2);
      VonBisNode(vNode2, 'Chemie_Frei1', Ein.P.Chemie.Frei1.1, Ein.P.Chemie.Frei1.2);

      NewNodeA(vNode2, 'VpgText1', Ein.P.VpgText1);
      NewNodeA(vNode2, 'VpgText2', Ein.P.VpgText2);
      NewNodeA(vNode2, 'VpgText3', Ein.P.VpgText3);
      NewNodeA(vNode2, 'VpgText4', Ein.P.VpgText4);
      NewNodeA(vNode2, 'VpgText5', Ein.P.VpgText5);
      NewNodeA(vNode2, 'VpgText6', Ein.P.VpgText6);

      // Aufpreise loopen...
      FOR Erx # RecLink(503,501,7,_RecFirst)
      LOOP Erx # RecLink(503,501,7,_RecNext)
      WHILE (Erx<=_rLocked) do begin

        if (RunAFX('EDI.Einkauf.RecRead','503|PosAufpreis')<>0) then begin
          if (AfxRes<>_rOK) then CYCLE;
        end;
    
        vNode3 # vNode2->Lib_XML:AppendNode( 'PosAufpreis' );
        NewNodeI(vNode3, 'lfdNr', Ein.Z.lfdNr);
        NewNodeA(vNode3, 'Bezeichnung', Ein.Z.Bezeichnung);
        NewNodeB(vNode3, 'Mengenbezogen', Ein.Z.MengenbezugYN);
        NewNodeF(vNode3, 'Menge', Ein.Z.Menge);
        NewNodeI(vNode3, 'PEH', Ein.Z.PEH);
        NewNodeA(vNode3, 'MEH', Ein.Z.MEH);
        NewNodeF(vNode3, 'Preis', Ein.Z.Preis);
        
        RunAFX('EDI.Einkauf.NodeCreated',aint(vNode3)+'|PosAufpreis');

      END;  // Aufpreise

      RunAFX('EDI.Einkauf.NodeCreated',aint(vNode2)+'|Position');

  END;  // Position

  RunAFX('EDI.Einkauf.NodeCreated',aint(vNode)+'|Kopf');

  TextClose(vTxt);

  /* XML Abschluss */
  vDoc->XmlSave(aFilename,_XmlSaveDefault,0, _CharsetUTF8);

  vDoc->CteClear( true );
  vDoc->CteClose();
end;


//========================================================================
// TestExport
//    Call EDI_Einkauf:TestExport
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

  CreateFile(vName);
  RETURN;
  
end;


//========================================================================
// TestImport
//    Call EDI_Einkauf:TestImport
//========================================================================
sub TestImport();
local begin
  vPath   : alpha(1000);
  vDirHdl : int;
  vName   : alpha(1000);
end;
begin
lib_Debug:StartBlueMode();
  vPath   # 'd:\debug\';
  vName   # 'edi_ordersp.xml';
  StartImport(vPath+vName);
end;


//========================================================================
//  StartImport
//
//========================================================================
SUB StartImport(
  opt aFileName   : alpha(1000);
) : logic;
local begin
  vDoc      : int;
  vRoot     : int;
  vOK       : logic;
  vErr      : alpha(1000);
end;
begin
  if (App_Main:Entwicklerversion()) AND (gUsername = 'JOB-SERVER') then
    RETURN true;


  vErr # EDI_Base:OpenXML(aFileName, 'Einkauf_Antwort', var vDoc, var vRoot);
  if (vErr<>'') then begin
    EDIERROR(999, cWofDateiDefekt, vErr);
    RETURN false;
  end;

  vOK # ProcessRootImport(vRoot)

  // Aufräumen...
  EDI_Base:CloseXML(vDoc);

  RETURN vOK;
end;


//========================================================================
/*** BEISPIEL
sub Import.Process(
  aNode     : int;
  var aPath : alpha;
  aDing     : alpha;
  var aErr  : alpha;
)
local begin
  vDat      : date;
  vF        : float;
end;
begin
  if (NodeD(aNode, var aErr, 'Lieferdatum',         var vDat)=false) then RETURN;

  // Liefertermin übernehmen...
  if (vDat<>Ein.P.TerminZusage) then begin
    Erx # RecRead(501,1,_recLock);
    Ein.P.TerminZusage # vDat;
    RekReplace(501);
  end;

  if (NodeF(aNode, var aErr, 'Dicke',               var vF)=false) then RETURN;
  if (vF<>Ein.P.Dicke) then begin
    StartWof(cWofDatei, cWofImportProblem, 'Dicke ist Mist!');
  end;
...

end;
***/


//========================================================================
//========================================================================
sub ProcessRootImport(
  aRoot         : int
  ) : logic;
local begin
  Erx       : int;
  vAnzSatz  : int;
  vOK       : logic;
  vWofErr   : int;
  vErr      : alpha(1000);

  xSatz     : int;
  xWert     : int;
  vName     : alpha;

  vBest     : alpha;

  vAFX      : alpha;
end;
begin

  if (Lib_SFX:Check_AFX('EDI.Einkauf.Import.Process')) then
    vAFX # AFX.Prozedur;

  vWofErr # cWofDateiDefekt;

  if (NodeA(aRoot, var vErr, 'Ref',             var vBest)=false) then begin
    vErr # 'Element "Ref" nicht gefunden!';
    EDIERROR(999, vWofErr, 'Satz '+aint(vAnz)+': '+vErr);
    RETURN false;
  end;

  TRANSON;

  // Sätze loopen...
  vOK # true;
  FOR xSatz # aRoot->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'Position')
  LOOP xSatz # aRoot->CteRead( _cteChildList | _cteSearch | _CteNext, xSatz, 'Position')
  WHILE (xSatz<>0) and (vOK) do begin
    inc(vAnzSatz);
    vOK # false;
    RecBufClear(501);

    // PFLICHTNODES:
    if (NodeA(xSatz, var vErr, 'ZuBestell',           var vBest)=false) then BREAK;
    if (Lib_Berechnungen:Int2AusAlpha(vBest, var Ein.P.Nummer, var Ein.P.Position)=false) then begin
      vErr # 'Illegale Bestellnummer '+vBest;
      BREAK;
    end;
    Erx # RecRead(501,1,0);
    if (Erx>_rLocked) then begin
      vErr # 'Unbekannte Bestellnummer '+vBest;
      BREAK;
    end;
    
    if (vAFX<>'') then begin
      // Typ, aNode, var vErr
      vName # '\';
      Call(vAFX, xSatz, var vName, '', var vErr);
      if (vErr<>'') then BREAK;
    end;
/***
    if (NodeA(xSatz, var vErr, 'Nummer',              var Ein.P.AB.Nummer)=false) then BREAK;
    if (NodeD(xSatz, var vErr, 'Lieferdatum',         var Ein.P.TerminZusage)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Bezeichnung',         var Ein.P.Bemerkung)=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Qualitaet',           var "Ein.P.Güte")=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Guetenstufe',         var "Ein.P.Gütenstufe")=false) then BREAK;
    if (NodeA(xSatz, var vErr, 'Papierzwischenlage',  var Ein.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Breite',              var Ein.P.Breite)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'BreitenTolMinus',     var Ein.P.Br Ein.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'BreitenTolPlus',      var xEin.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Dicke',               var Ein.P.Dicke)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'DickenTolMinus',      var xEin.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'DickenTolPlus',       var xEin.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'RID',                 var Ein.P.RID)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'Kgmm',                var xEin.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'KgmmVon',             var xEin.E.Nummer)=false) then BREAK;
    if (NodeF(xSatz, var vErr, 'KgmmBis',             var xEin.E.Nummer)=false) then BREAK;
    if (NodeI(xSatz, var vErr, 'AbbindungL',          var xEin.E.Nummer)=false) then BREAK;
    if (NodeI(xSatz, var vErr, 'AbbindungQ',          var Ein.E.Nummer)=false) then BREAK;
***/
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




/*
-------------------------------------------------------------------
2022-06-14 ST

Verschiebt eine importierte Datei in den angegebenen Ergebnisordner
und hängt der Importierten Daten in Timestamp an.
-------------------------------------------------------------------
*/
sub _MoveToResultfolder(
  aSrcFile  : alpha(250);     // Vollständiger Dateipfad zur Quelldatei
  aType     : alpha;          // Name des Zielordners, innerhalnb des Importverzeichnisses
  opt aDontDelete   : logic;  // Lässt das Quellfile zum Abräumen an einer andernen Stelle liegen
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
    
  if (Lib_FileIO:FsiCopy(aSrcFile,vDestpath+vDestFile,(aDontDelete = false)) != _rOK) then
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
  RETURN (vExt = 'xml');
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
  aPara : alpha     //  Parameter aus Job Eintrag: Pfad zum Quellordner
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
                       
      if (StartImport(vFullPathToFile)) then
        _MoveToResultfolder(vFullPathToFile,'Erledigt');
      else
        _MoveToResultfolder(vFullPathToFile,'Fehlerhaft');
  
      vLastFilename # vFilename;
      vFileName     # vHdl->FsiDirRead(); // Nächste Datei
    END;
        
    vHdl->FsiDirClose();
  end;
            
  RETURN vRet;
end;


//========================================================================
