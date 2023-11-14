
@A+
//===== Business-Control =================================================
//
//  Prozedur  F_SQL
//                      OHNE E_R_G
//  Info
//
//
//  02.05.2013  AI  Erstellung der Prozedur
//  22.06.2015  AH  Sammelrechnung
//  03.09.2015  ST  Stornorechnung aus Erlösen hinzugefügt
//  18.11.2015  AH  Para nun JSON-Node statt JSON-Alpha
//  20.01.2016  AH  "LFSWZ"
//  16.03.2016  ST  "BAGST" als Bag Statusblatt/Übersicht hinzugefügt
//  14.04.2016  AH  Sprachen werden unterschieden im FRX-Namen
//  21.04.2016  ST  Rezipienten für AB, FM und Angebot +AP erweitert
//  12.05.2016  AH  Archivierung nach ArcFlow
//  03.06.2016  ST  "PreviewPDF" neues Argument "aSubject" für Umbennenung des Formulars
//  16.06.2016  TM  Rezipienten für Bestellung +AP erweitert
//  30.09.2016  AH  "Metk2"
//  20.10.2016  ST  "Metk2" wieder zu "Metk" mit Parameter "mitAktionen"
//  27.12.2016  ST  Formular Bestellung-HUB BESTH hinzugefügt
//  19.04.2017  ST  Formular Rechnung liest Sprache aus Auftrag
//  20.04.2017  AH  Rechnung mit ZUGFeRD "REZF"
//  11.05.2017  AH  Rechnung mit "NurLfsNr"
//  25.04.2018  AH  Neu: Reklamation
//  02.08.2018  AH  Neu: PETK = Paketetikett
//  19.09.2018  AH  Fix: Nachdruck von LF-Rechnungen
//  23.10.2018  AH  Neu: MustEMA
//  11.01.2019  AH  Neu: SpracheAlsZahl wird an die FRX übergeben
//  05.03.2019  AH  Neu: MustEMA für "FM" und "AB"
//  17.09.2019  AH  Neu: MustEMA für "WZ"
//  02.09.2020  TM  Neuer Formulartyp RESTO zu Prj. 1326/592
//  06.11.2020  AH  Typ "LFSVM"
/// 10.09.2021  ST  Optionaler Aufruf mit mehreren Keys (für Etikettendruck)
//  30.09.2021  AH  Edit: Sprache + Adresse für alle Formulare im 440-Bereich
//  07.01.2022  AH  Neu: PureSQL kann genutzt werden
//  12.05.2022  ST  Neu: AddJSONBool(vJSON, 'PDF4DMS', true); Veranlasst den Printserver ein PDF auf dem Serverr im Tempordner zu generieren
//  09.06.2022  ST  Neu: "SavePDF" und "FinishListSaveOnly" hinzugefügt um Reports direkt als PDF speichern zu können
//  09.06.2022  AH  ERX
//  08.07.2022  SR  "PRJLY" erweitert
//  09.11.2022  ST  Fix: "ANF" für Bestellabfrage FAllback auf Bestrellnummer nbei GetDocNam
//  2023-05-17  AH  Fix für bessere Adressbestimmung des Dokumentes
//  10.08.2023  TM Sel.XML.Pfad wird gecheckt und List_Filename enteprechend gefüllt - nur falls noch nicht geschehen! (XML für Custom SQL Listen)
//  2023-08-11  SR Erweiterung der Parameter für "GBES" (Gelangensbestätigung)
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  AddJSONInt    : Lib_JSON:AddJSONInt
  AddJSONAlpha  : Lib_JSON:AddJSONAlpha
  AddJSONDate   : Lib_JSON:AddJSONDate
  AddJSONFloat  : Lib_JSON:AddJSONFloat
  AddJSONBool   : Lib_JSON:AddJSONBool
  CloseJSON     : Lib_JSON:CloseJSON
end;


//========================================================================
//========================================================================
sub OpenJSON(opt aSQL : logic) : int
local begin
  vJSON : int;
end;
begin
  vJSON # Lib_JSON:OpenJson(aSQL);
//  if (Frm.Druck.mitBildYN) then
//    AddJSONAlpha(vJSON, 'BackgroundPic', Set.Druck.Bilddatei);
  RETURN vJSON;
end;


//========================================================================
//========================================================================
sub DesignInSprache(aDesign : alpha; aSprache : alpha) : alpha;
begin
  if (aSprache='') or (aSprache='D') or (aSprache='DE') or (aSprache='DEU') or (aSprache='GER') then begin
    RETURN aDesign;
  end
  else begin
    // Sprache anhängen als "_xxx"
    RETURN FsiSplitName(aDesign,_FsiNamePN)+'_'+aSprache+'.'+FsiSplitName(aDesign, _FsiNameE);
  end;
end;


//========================================================================
//========================================================================
sub SpracheAlsZahl(
  aKurz : alpha) : int;
begin
  if (aKurz=^Set.Sprache1.Kurz) then RETURN 1;
  if (aKurz=^Set.Sprache2.Kurz) then RETURN 2;
  if (aKurz=^Set.Sprache3.Kurz) then RETURN 3;
  if (aKurz=^Set.Sprache4.Kurz) then RETURN 4;
  if (aKurz=^Set.Sprache5.Kurz) then RETURN 5;
  RETURN 1;
end;


//========================================================================
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  opt aNr       : int;
  ) : alpha;
local begin
  Erx : int;
end;
begin

  case StrCnv("Frm.Kürzel",_strupper) of

    'AB', 'AUFSE',
    'AUFFM','AUFFI' : begin
      Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen 2023-05-17  AH
      aSprache  # Auf.Sprache;
      Erx # RecLink(100,400,1,_recFirst);   // Kunde holen
      aAdr # Adr.Nummer;
      RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'ANG'     : begin
      Erx # RecLink(400,401,3,_RecFirst);  // Kopf holen 2023-05-17  AH
      aSprache  # Auf.Sprache;
      Erx # RecLink(100,400,1,_recFirst); // Kunde holen
      aAdr # Adr.Nummer;
      RETURN CnvAI(Auf.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'ANF'     : begin
      aSprache  # Adr.Sprache;
      aAdr      # Adr.Nummer;
      if (aNr = 0) then begin
        Erx # RecLink(500,501,3,_RecFirst);  // Kopf holen 2023-05-17  AH
        Erx # RecLink(100,500,1,_RecFirst);  // Lieferant holen 2023-05-17  AH
        aSprache  # Ein.Sprache;
        aAdr      # Adr.Nummer;
        aNr       # Ein.Nummer;
      end;
      RETURN CnvAI(aNr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
    end;

    'BAG',
    'BAGST'    : begin
       RETURN CnvAI(BAG.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
     end;

    'BEST'    : begin
      Erx # RecLink(500,501,3,_recFirst);  // Kopf holen 2023-05-17  AH
      Erx # RecLink(100,500,1,_RecFirst);  // Lieferant holen 2023-05-17  AH
      aSprache  # Ein.Sprache;
      aAdr # Adr.Nummer;
      RETURN CnvAI(Ein.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'BESTH'    : begin
      Erx # RecLink(100,190,2,_recFirst); // Lieferant holen
      aSprache  # Adr.Sprache;
      aAdr # Adr.Nummer;
      RETURN CnvAI(HUB.EK.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'VLDAW','FST'   : begin
      Adr.Nummer # Set.eigeneAdressnr;
      RecRead(100,1,0);                     // Selber holen
      aSprache  # Adr.Sprache;
      aAdr      # Adr.Nummer;
      RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'LFSWZ','LFSVM',
    'LAVIS'    : begin
      Erx # RecLink(100,440,1,_recFirst);   // Kunde holen
      aSprache  # Adr.Sprache;
      aAdr      # Adr.Nummer;
      RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'LFS'     : begin
      Erx # RecLink(100,440,2,_recFirst);   // Zieladresse holen
      aSprache  # Adr.Sprache;
      aAdr      # Adr.Nummer;
      RETURN CnvAI(Lfs.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'LFA', 'LTA' : begin
      Erx # RecLink(100,702,7,_recFirst); // Dienstleister holen
      aSprache # Adr.Sprache;
      aAdr # Adr.Nummer;
      RETURN CnvAI(BAG.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8) + CnvAI(BAG.P.Position,_FmtNumNoGroup | _FmtNumLeadZero,0,3) ;
      end;

    'MATK2', 'METK2','METK','MATK'    :
      RETURN CnvAI(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      
    'UETK'  :
      RETURN Usr.Username;

    'PETK' :
      RETURN CnvAI(Mat.Paketnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      
    'PRJLY' :
      RETURN CnvAI(Prj.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);

    'RE','REZF','RESTO' : begin
      if (Erl.Rechnungsnr <> 0) then begin
        Erx # RekLink(451,450,1,_recFirst); // Ersten Erlös holen
        Erx # Auf_Data:Read(Erl.K.Auftragsnr,Erl.K.Auftragspos,true);
      end
      else begin
        Erx # RecLink(400,401,3,_RecLock);  // Kopf holen
      end;
      aSprache # Auf.Sprache;
//      Erx # RecLink(100,400,4,_recFirst); // Rechnungsempfänger holen 23.10.2018 AH
      Erx # RecLink(100,450,8,_recFirst); // Rechnungsempfänger holen 2023-05-17  AH
      aAdr # Adr.Nummer;
      RETURN CnvAI(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;

    'SARE', 'SRE' : begin
      Erx # RecLink(100,450,5,_recFirst); // Kunde holen
      aSprache # Adr.Sprache;
      aAdr # Adr.Nummer;
      RETURN CnvAI(Erl.Rechnungsnr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;


    'MAHN','OPKTO': begin
      Erx # RecLink(100,460,4,_recFirst); // Kunde holen
      aSprache # Adr.Sprache;
      aAdr # Adr.Nummer;
      RETURN  CnvAI(Ofp.Kundennummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)
                + CnvAd(Sysdate());
      end;


    'LETK' : begin
      RETURN  LPl.Lagerplatz + ' ' +  CnvAd(Sysdate());
      end;

         
    'LYS'    :
      RETURN CnvAI(Lys.K.Analysenr,_FmtNumNoGroup | _FmtNumLeadZero,0,8);


    'REKB','REK','REKBL'   : begin
      RETURN CnvAI(Rek.P.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);
      end;
  end;

end;


//========================================================================
//========================================================================
sub PreviewPDF(
  aName           : alpha;
  aDesign         : alpha(1000);
  aLogo           : alpha(1000);
  aMark           : alpha(1000);
  aRecipient      : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aDMSName        : alpha(4000);
  opt aSubject    : alpha(1000);
  opt aMustEMA    : alpha(4000);
  ) : logic;
local begin
  vPdfFile        : alpha(4000);
end;
begin
  vPdfFile # Lib_SQL:CreateShowPDF(aName, aDesign, aLogo, aMark, aRecipient, aParaHandle, aDMSName, false, aSubject, n, aMustEMA);
  Lib_SQL:DeletePrintFiles(vPdfFile);
  ErrorOutput;
end;


//========================================================================
//========================================================================
sub SaveXLS(
  aName           : alpha;
  aDesign         : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aXLSName        : alpha(4000)) : logic;
begin
  Lib_SQL:CreateXML(aName, aDesign, aParaHandle, aXLSName);
end;


//========================================================================
//========================================================================
sub SavePDF(
  aName           : alpha;
  aDesign         : alpha(1000);
  aParaHandle     : handle;
  aPdfName        : alpha(4000)) : logic;
begin
  Lib_SQL:CreatePDF(aName, aDesign, aParaHandle, aPdfName);
end;


//========================================================================
//========================================================================
sub PrintPDF(
  aName           : alpha;
  aDesign         : alpha(1000);
  aLogo           : alpha(1000);
  aMark           : alpha(1000);
  aRecipient      : alpha(1000);
//  aPara           : alpha(4000);
  aParaHandle     : handle;
  aDMSName        : alpha(4000);

  aKopien         : word;
  aPrinter        : alpha(4000);
  aDevice         : int;
  aSchacht        : alpha(4000)) : logic;
local begin
  vPDFFile        : alpha(4000);
  vPrinter        : int;
  vLastFoc        : int;
  vHdl            : int;
end;
begin

  if (aPrinter<>'') then begin    // 06.11.2018, falls unbekannter Druckername vorgegeben ist
    if (PrtDeviceOpen(aPrinter,_PrtDeviceSystem)<=0) then aPrinter # '';
  end;
  // kein Drucker angegeben?? -> Druckerauswahl
  if (aKopien>0) and (aPrinter='') then begin
    Lib_Print:Druckerauswahl(var aPrinter, var aKopien);
    LastPrinter # aPrinter;
  end;

  vPDFFile # Lib_SQL:CreateShowPDF(aName, aDesign, aLogo, aMark, aRecipient, aParaHandle, aDMSName, true);

  if (StrLen(vPDFFile)>2) then begin
    Dlg_PDFPreview:DirekterDruck(vPDFFile, aKopien, aPrinter, aDevice, aSchacht);
  end;
  Lib_SQL:DeletePrintFiles(vPDFFile);
  ErrorOutput;
end;


//========================================================================
//========================================================================
sub FinishList(
  aForm     : alpha;
  aDesign   : alpha(1000);
  var aJSON : handle) : logic
local begin
//  vPara       : alpha(4096);
end;
begin
debugx('');

if (Sel.XML.Pfad !='' and List_Filename = '' ) then
  List_Filename # Sel.XML.Pfad;

//  if (aJSON<>0) then
//    vPara # JSONtoPara(var aJSON);
  // 29.04.2021 AH: für SQL-Listen

  if (aForm='SQL') and (aJSON<>0) then
    Lib_JSON:AddJSONAlpha(aJSON,'ConnectionString', Lib_SQL:ConnectionString());

  if (List_Filename<>'') then begin
    FSIDelete(List_Filename);
    SaveXLS(aForm, aDesign, aJSON, List_Filename);
    CloseJSON(var aJSON);
    if (Lib_FileIO:FileExists(list_Filename)) then SysExecute('*'+List_Filename, '',0);
    RETURN true;
  end;

  PreviewPDF(aForm, aDesign, '', '', '', aJSON, '');

  CloseJSON(var aJSON);

  VarFree(Class_List);

  RETURN true;
end;



//========================================================================
//========================================================================
sub FinishListSaveOnly(
  aForm     : alpha;
  aDesign   : alpha(1000);
  var aJSON : handle) : logic
begin

  if (aForm='SQL') and (aJSON<>0) then
    Lib_JSON:AddJSONAlpha(aJSON,'ConnectionString', Lib_SQL:ConnectionString());

  if (Sel.XML.Pfad !='' and List_Filename = '' ) then
  List_Filename # Sel.XML.Pfad;

  if (List_Filename = '') then
    RETURN false;


  FSIDelete(List_Filename);
  SavePDF(aForm, aDesign, aJSON, List_Filename);
  CloseJSON(var aJSON);

  VarFree(Class_List);
  RETURN true;
end;


//========================================================================
//
//
//========================================================================
Sub Ein_Anfrage_Para() : int;
local begin
  Erx       : int;
  vJSON     : handle;
end;
begin

  Erx # RecLink(501,500,9,_recFirst);
  if (Ein.Lieferantennr<>Ein.P.Lieferantennr) then begin
    vJSON # CteOpen(_CteNode);
    // Cte-Knoten als JSON-Objekt deklarieren
    vJSON->spID # _JSONNodeObject;
    // Number
    vJSON->CteInsertNode('Bestellnr',
      _JsonNodeNumber , Ein.Nummer);
    vJSON->CteInsertNode('Lieferantnr',
      _JsonNodeNumber , Ein.Lieferantennr);
    vJSON->CteInsertNode('Lieferadresse',
      _JsonNodeNumber , Ein.Lieferadresse);
    vJSON->CteInsertNode('Lieferanschr',
      _JsonNodeNumber , Ein.Lieferanschrift);
  end
  else begin
    vJSON # CteOpen(_CteNode);
    // Cte-Knoten als JSON-Objekt deklarieren
    vJSON->spID # _JSONNodeObject;
    // Number
    vJSON->CteInsertNode('Bestellnr',
      _JsonNodeNumber , Ein.Nummer);
  end;

//  RETURN JSONtoPara(var vJSON);
  RETURN vJSON;
end;


//========================================================================
//
//
//========================================================================
Sub Auf_Anfrage();
local begin
  Erx         : int;
  vNode       : handle;
  vNode2      : handle;
  vJSON       : handle;
  vMID        : int;
  vMFile      : int;
  vItem       : int;
  vText1      : alpha;
  vText2      : alpha;
  vHdl        : Handle;
  vOK         : logic;
//  vPara       : alpha(4000);
  vMem        : handle;
  vErr        : int;
  vForm       : alpha(1000);
  vMark       : alpha(1000);
  vLogo       : alpha(1000);
  vReci       : alpha(1000);
  vDesign     : alpha(1000);
  vDMSName    : alpha(1000);
  vNr         : int;
  vPos        : int;
  vSprache    : alpha;
  vAdr        : int;
  vNew        : logic;
end;
begin

  vNr   # 0;
  vPos  # 1;
  vNr # Lib_Nummern:ReadNummer('Anfrage');
  if (vNr<>0) then
    Lib_Nummern:SaveNummer()
  else
    RETURN;

//  vDesign # 'E:\FRX\BO_Anfrage.frx';
//  vForm     # StrCnv("Frm.Kürzel",_strupper);
//  vDMSName  # GetDokName(var vSprache, var vAdr);
//  vDesign   # Frm.Style;


  vText1 # '~TMP.'+Userinfo(_UserCurrent)+'.001';
  vText2 # '~TMP.'+Userinfo(_UserCurrent)+'.002';
  vHdl # $edTxt_lang1_head->wpdbTextBuf;
  $edTxt_lang1_head->winUpdate(_WinUpdObj2Buf);
  TxtWrite(vHdl, vText1,0);
  vHdl # $edTxt_lang1_foot->wpdbTextBuf;
  $edTxt_lang1_foot->winUpdate(_WinUpdObj2Buf);
  TxtWrite(vHdl, vText2,0);
//TextRead(vHdl, vText1, 0);
//debug(aint(TextInfo(vHdl,_TextLines)));

/**/
  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  // Cte-Knoten als JSON-Objekt deklarieren
  vJSON->spID # _JSONNodeObject;

  // Number
  vJSON->CteInsertNode('Anfragenr',
    _JsonNodeNumber , vNr);
  vJSON->CteInsertNode('Adressnr',
    _JsonNodeNumber , Adr.Nummer);
  vJSON->CteInsertNode('Text1',
    _JsonNodeString , vText1);
  vJSON->CteInsertNode('Text2',
    _JsonNodeString , vText2);

  // Array
  vNode # vJSON->CteInsertNode('Positionen',
    _JsonNodeArray, NULL);
/**/
//  vJSON # OpenJSON();


  // AufPositionen loopen
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_Ctenext, vItem);
  WHILE (vItem <> 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile <> 401) then CYCLE;
    RecRead(401,0,_RecId,vMID);

    vOK # y;
    // Object
    vNode2 # vNode->CteInsertNode('aabbcc',
      _JSONNodeObject, null);
    vNode2->CteInsertNode('Nummer',
      _JsonNodeNumber, Auf.P.Nummer);
    vNode2->CteInsertNode('Position',
      _JsonNodeNumber, Auf.P.Position);

    // >>>> Anfrage in AuftragsAktionen hinterlegen
    // Pos. bereits in Anfrage enthalten?
    vNew # false;
    Erx # RecLink(404,401,12,_RecLast);
    WHILE (Erx<=_rLocked) do begin          // Aktionen durchlaufen
      if (Auf.A.Aktionstyp = 'ANF') and (Auf.A.Aktionsnr=vNr) then vNew # true; // c_Anf anlegen mit Inhalt 'ANF'
      Erx # RecLink(404,401,12,_RecPrev);
    END;

    if (vNew = false) then begin
      // Aktion vermerken
      RecBufClear(404);
      Auf.A.Nummer          # Auf.P.Nummer;
      Auf.A.Position        # Auf.P.Position;
      Auf.A.Position2       # 0;
      Auf.A.Aktion          # 0;
      Auf.A.Aktionstyp      # 'ANF';
      Auf.A.Aktionsnr       # vNr;
      Auf.A.Aktionspos      # vPos;
      Auf.A.Aktionsdatum    # today;
      Auf.A.Adressnummer    # Adr.Nummer;
      Auf.A.Bemerkung       # 'ANFRAGE ' + Adr.Stichwort;
      Auf.A.Anlage.Datum    # today;
      Auf.A.Anlage.Zeit     # now;
      Auf.A.Anlage.User     # gUserName;

      REPEAT
        Auf.A.Aktion         # Auf.A.Aktion + 1;
        Erx # RekInsert(404,0,'AUTO');
      UNTIL (erx=_rOK);

    end;
    inc(vPos);
    // Anfrage in AuftragsAktionen hinterlegen <<<<

  END;

  if (vOK=False) then begin
    FOR Erx # RecLink(401,400,9,_recFirst)
    LOOP Erx # RecLink(401,400,9,_recNext, vItem)
    WHILE (Erx<=_rLocked) do begin
      // Object
      vNode2 # vNode->CteInsertNode('aabbcc',
        _JSONNodeObject, null);
      vNode2->CteInsertNode('Nummer',
        _JsonNodeNumber, Auf.P.Nummer);
      vNode2->CteInsertNode('Position',
        _JsonNodeNumber, Auf.P.Position);
    END;

    // >>>> Anfrage in AuftragsAktionen hinterlegen
    // Pos. bereits in Anfrage enthalten?
    vNew # false;
    Erx # RecLink(404,401,12,_RecLast);
    WHILE (Erx<=_rLocked) do begin          // Aktionen durchlaufen
      if (Auf.A.Aktionstyp = 'ANF') and (Auf.A.Aktionsnr=vNr) then vNew # true; // c_Anf anlegen mit Inhalt 'ANF'
      Erx # RecLink(404,401,12,_RecPrev);
    END;

    if (vNew = false) then begin
      // Aktion vermerken
      RecBufClear(404);
      Auf.A.Nummer          # Auf.P.Nummer;
      Auf.A.Position        # Auf.P.Position;
      Auf.A.Position2       # 0;
      Auf.A.Aktion          # 0;
      Auf.A.Aktionstyp      # 'ANF';
      Auf.A.Aktionsnr       # vNr;
      Auf.A.Aktionspos      # vPos;
      Auf.A.Aktionsdatum    # today;
      Auf.A.Adressnummer    # Adr.Nummer;
      Auf.A.Bemerkung       # 'ANFRAGE ' + Adr.Stichwort;
      Auf.A.Anlage.Datum    # today;
      Auf.A.Anlage.Zeit     # now;
      Auf.A.Anlage.User     # gUserName;

      REPEAT
        Auf.A.Aktion         # Auf.A.Aktion + 1;
        Erx # RekInsert(404,0,'AUTO');
      UNTIL (erx=_rOK);

    end;
    inc(vPos);
    // Anfrage in AuftragsAktionen hinterlegen <<<<

  end;

/*
  vMem # MemAllocate(_Mem1K);
  vMem->spcharset # _CharsetUTF8;
//vErr # vJSON->JSONSave('E:\PDF\JSON-data.txt');
  vErr # vJSON->JSONSave('E:\PDF\xxx',_JsonSaveDefault, vMem, _CharsetUTF8);
  vPara # MemReadStr(vMem, 1, vMem->SpLen);

  MemFree(vMem);
  // Cte-Knoten leeren freigeben
  vJSON->CteClear(true);
  vJSON->CteClose();
*/
//      vJSON # OpenJSON();
//      AddJSONInt(vJSON, 'Nummer', BAG.Nummer);
//      AddJSONInt(vJSON, 'Position', 0);

//      vPara # JSONtoPara(var vJSON);


  vForm     # StrCnv("Frm.Kürzel",_strupper);
  vDMSName  # GetDokName(var vSprache, var vAdr, vNr);
  vDesign   # Frm.Style;

//  Lib_SQL:DesignPDF("Frm.Kürzel", vForm, vLogo, vMark, vReci,vPara);
//  Lib_SQL:CreateShowPDF(vForm, vDesign, vLogo, vMark, vReci, vPara, vDMSName);

//  PreviewPDF(vForm, vDesign, vLogo, vMark, '', vPara, vDMSName);

  vDesign # DesignInSprache(vDesign, vSprache);

  if (Frm.VorschauYN) then
    PreviewPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName);
  if (Frm.DirektDruckYN) then
    PrintPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);

  CloseJSON(var vJSON);

  Winsleep(5000);
  TxtDelete(vText1,0);
  TxtDelete(vText2,0);
end;


//========================================================================
//
//
//========================================================================
Sub AufFM();
local begin
  Erx         : int;
  vNode       : handle;
  vNode2      : handle;
  vJSON       : handle;
//  vPara       : alpha(4000);

  vItem       : int;

  vForm       : alpha(1000);
  vMark       : alpha(1000);
  vLogo       : alpha(1000);
  vReci       : alpha(1000);
  vDesign     : alpha(1000);
  vDMSName    : alpha(1000);
  vSprache    : alpha;
  vAdr        : int;
  vRecipient  : alpha;
  vMustEMA    : alpha(4000);
end;
begin

  vRecipient  # 'KD+AP';  // ST 2016-04-21

  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  // Cte-Knoten als JSON-Objekt deklarieren
  vJSON->spID # _JSONNodeObject;

  // Number
  vJSON->CteInsertNode('Auftragsnummer',    _JsonNodeNumber , Auf.Nummer);

  AddJSONDate(vJSON, 'BisDatum', today);

  // Array
  vNode # vJSON->CteInsertNode('Aktionen',  _JsonNodeArray, NULL);

  // Aktionen loopen
  FOR vItem # CteRead(gFormParaHdl,_ctefirst)
  LOOP vItem # CteRead(gFormParaHdl,_ctenext, vItem)
  WHILE (vItem<>0) do begin
    Erx # RecRead(404,0,_recid, vItem->spid);
    // Object
    vNode2 # vNode->CteInsertNode('aabbcc', _JSONNodeObject, null);
    vNode2->CteInsertNode('Nummer',         _JsonNodeNumber, Auf.A.Nummer);
    vNode2->CteInsertNode('Position',       _JsonNodeNumber, Auf.A.Position);
//    vNode2->CteInsertNode('Position2',      _JsonNodeNumber, Auf.A.Position2);
    vNode2->CteInsertNode('Aktion',         _JsonNodeNumber, Auf.A.Aktion);
  END;

//      vJSON # OpenJSON();
//      AddJSONInt(vJSON, 'Nummer', BAG.Nummer);
//      AddJSONInt(vJSON, 'Position', 0);
//  vPara # JSONtoPara(var vJSON);

  vForm     # StrCnv("Frm.Kürzel",_strupper);
  vDMSName  # GetDokName(var vSprache, var vAdr, Auf.Nummer);
  vDesign   # Frm.Style;
  vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:FM');

  vDesign # DesignInSprache(vDesign, vSprache);

  if (Frm.VorschauYN) then
    PreviewPDF(vForm, vDesign, vLogo, vMark, vRecipient, vJSON, vDMSName, '', vMustEMA);
  if (Frm.DirektDruckYN) then
    PrintPDF(vForm, vDesign, vLogo, vMark, vRecipient, vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);

  CloseJSON(var vJSON);

  Winsleep(5000);
end;


//========================================================================
//
//
//========================================================================
Sub AufSLEtikett();
local begin
  Erx         : int;
  vNode       : handle;
  vNode2      : handle;
  vJSON       : handle;
//  vPara       : alpha(4000);

  vItem       : int;

  vForm       : alpha(1000);
  vMark       : alpha(1000);
  vLogo       : alpha(1000);
  vReci       : alpha(1000);
  vDesign     : alpha(1000);
  vDMSName    : alpha(1000);
  vSprache    : alpha;
  vAdr        : int;
end;
begin

  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  // Cte-Knoten als JSON-Objekt deklarieren
  vJSON->spID # _JSONNodeObject;

  // Number
  vJSON->CteInsertNode('Auftragsnummer',    _JsonNodeNumber , Auf.Nummer);
//  AddJSONDate(vJSON, 'BisDatum', today);

  // Array
  vNode # vJSON->CteInsertNode('Stuecklisten',  _JsonNodeArray, NULL);

  // Stückliste loopen
  FOR Erx # RecLink(409,401,15,_recFirst)
  LOOP Erx # RecLink(409,401,15,_recNext)
  WHILE (Erx<=_rLocked) do begin
//    Erx # RekLink(829,409,6,_recFirst);          // Skizze holen

    // Object
    vNode2 # vNode->CteInsertNode('aabbcc', _JSONNodeObject, null);
    vNode2->CteInsertNode('Nummer',         _JsonNodeNumber, Auf.SL.Nummer);
    vNode2->CteInsertNode('Position',       _JsonNodeNumber, Auf.SL.Position);
    vNode2->CteInsertNode('lfdNr',          _JsonNodeNumber, Auf.SL.lfdnr);
//    vNode2->CteInsertNode('Image',          _JsonNodeString, Skz.Dateiname);
  END;

//  vPara # JSONtoPara(var vJSON);

  vForm     # StrCnv("Frm.Kürzel",_strupper);
  vDMSName  # GetDokName(var vSprache, var vAdr, Auf.Nummer);
  vDesign   # Frm.Style;

  vDesign # DesignInSprache(vDesign, vSprache);

  if (Frm.VorschauYN) then
    PreviewPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName);
  if (Frm.DirektDruckYN) then
    PrintPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);

  CloseJSON(var vJSON);

  Winsleep(5000);
end;


//========================================================================
//
//
//========================================================================
Sub Mahnung();
local begin
  Erx           : int;
  vKunde        : int;
  vMahnTree     : int;         // Descriptor für die Sortierungsliste
  vMahnSortKey  : alpha;       // "Sortierungsschlüssel" der Liste
  vMahnItem     : int;         // Descriptor für einen Offenen Posten

  vMarked       : int;          // Descriptor für den Marierungsbaum
  vMarkedItem   : int;          // Descriptor für markierten Eintrag

  vMFile        : int;  // Markierungen
  vMID          : int;  // Markierungen

  vMahnText1    : int;
  vMahnText2    : int;
  vMahnText3    : int;
  vTmp          : alpha;

  vNode         : handle;
  vNode2        : handle;
  vJSON         : handle;
//  vPara         : alpha(4000);

  vItem         : int;

  vForm         : alpha(1000);
  vMark         : alpha(1000);
  vLogo         : alpha(1000);
  vReci         : alpha(1000);
  vDesign       : alpha(1000);
  vDMSName      : alpha(1000);
  vSprache      : alpha;
  vAdr          : int;

  vSprachNr     : int;

  vMustEMA    : alpha(4000);
  vSubject    : alpha(1000);
end;
begin

  // - Mahnungen werden pro Kunde ausgegeben
  // - Kunde wird vor Formularaufruf ausgewählt und kann hier ausgewertet werden
  vKunde # Ofp.Kundennummer;

  // Mahnungsliste fürs Sortieren erstellen
  vMahnTree # CteOpen(_CteTreeCI);

  /* Markierungen sortiert in eigene Liste schreiben */
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext,vMarked);
  WHILE (vMarked > 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

    if (vMFile <> 460) then
      CYCLE;

    RecRead(460,0,_RecId,vMID);
    if (OFp.Kundennummer<>vKunde) then
      CYCLE;

    // gelesenen Eintrag in eigene Liste übergeben
    vMahnSortKey # CnvAi(Ofp.Kundennummer, _FmtNumNoGroup | _FmtNumLeadZero,0,10) +
                   CnvAi(100 - OfP.Mahnstufe, _FmtNumNoGroup | _FmtNumLeadZero,0,3);
    Sort_ItemAdd(vMahnTree,vMahnSortKey,460,vMID);
  END;

  // 1. Satz holen
  vMahnItem # Sort_ItemFirst(vMahntree)
  if (vMahnItem=0) then begin
    // Kunde hat keine offenen Posten zum Mahnen  markiert

    // Löschen der Liste
    Sort_KillList(vMahnTree);
    RETURN;
  end;


  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  // Cte-Knoten als JSON-Objekt deklarieren
  vJSON->spID # _JSONNodeObject;

  // Number
  vJSON->CteInsertNode('Kundennummer',    _JsonNodeNumber , vKunde);
  AddJSONDate(vJSON, 'Mahndatum', today);

  // Mahntextnummern ermitteln
  FOR   Erx # RecRead(837, 1, _recFirst);
  LOOP  Erx # RecRead(837, 1, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (StrFind(Txt.Bezeichnung,'@Mahntext',1) = 0) then
      CYCLE;

    vTmp # Str_Token(Txt.Bezeichnung,'-',2);
    case vTmp of
      '1' : vMahnText1 # Txt.Nummer;
      '2' : vMahnText2 # Txt.Nummer;
      '3' : vMahnText3 # Txt.Nummer;
    end;
  END;

  AddJSONInt(vJSON, 'MahnTextNr1', vMahntext1);
  AddJSONInt(vJSON, 'MahnTextNr2', vMahntext2);
  AddJSONInt(vJSON, 'MahnTextNr3', vMahntext3);

  AddJSONInt(vJSON, 'SetMahntage1', Set.Fin.MahnTage1);
  AddJSONInt(vJSON, 'SetMahntage2', Set.Fin.MahnTage2);


  // Sprache des Empfänges lesen
  RekLink(100,460,4,0);   // Kunde Lesen
  if ("Adr.VK.ReEmpfänger" <> 0) then begin
    Adr.Kundennr # "Adr.VK.ReEmpfänger";
    RecRead(100,2,0);
  end;
  vSprachNr # 1;
  if (Set.Sprache2.Kurz = ADr.Sprache) then vSprachNr # 2;
  if (Set.Sprache3.Kurz = ADr.Sprache) then vSprachNr # 3;
  if (Set.Sprache4.Kurz = ADr.Sprache) then vSprachNr # 4;
  if (Set.Sprache5.Kurz = ADr.Sprache) then vSprachNr # 5;

  AddJSONInt(vJSON, 'MahnSprachNr', vSprachNr);

  // Array von Rechnungen
  vNode # vJSON->CteInsertNode('Rechnungen',  _JsonNodeArray, NULL);

  // Rechnungen für Ausgabe festlegen
  FOR   vMahnItem # Sort_ItemFirst(vMahntree)
  LOOP  vMahnItem # Sort_ItemNext(vMahntree, vMahnItem)
  WHILE (vMahnItem <> 0) DO BEGIN
    RecRead(460,0,_RecId, vMahnItem->spID);

    // Object
    vNode->CteInsertNode('Nummer',         _JsonNodeNumber, OFP.Rechnungsnr);

  END;

  Sort_KillList(vMahnTree);
//  vPara # JSONtoPara(var vJSON);

  vForm     # StrCnv("Frm.Kürzel",_strupper);
  vDMSName  # GetDokName(var vSprache, var vAdr, Auf.Nummer);
  vDesign   # Frm.Style;

  vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:RE');   // 16.09.2021 AH

  vDesign # DesignInSprache(vDesign, vSprache);
//xx
  if (Frm.VorschauYN) then
    PreviewPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName, vSubject, vMustEMA);
  if (Frm.DirektDruckYN) then
    PrintPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);

  CloseJSON(var vJSON);

  //Winsleep(5000);
end;


//========================================================================
//
//
//========================================================================
Sub OpKontoauszug();
local begin
  Erx           : int;
  vKunde        : int;
  vMahnTree     : int;         // Descriptor für die Sortierungsliste
  vMahnSortKey  : alpha;       // "Sortierungsschlüssel" der Liste
  vMahnItem     : int;         // Descriptor für einen Offenen Posten
  vMarked       : int;          // Descriptor für den Marierungsbaum
  vMarkedItem   : int;          // Descriptor für markierten Eintrag

  vMFile        : int;  // Markierungen
  vMID          : int;  // Markierungen

  vMahnText1    : int;
  vMahnText2    : int;
  vMahnText3    : int;
  vTmp          : alpha;

  vNode         : handle;
  vNode2        : handle;
  vJSON         : handle;
//  vPara         : alpha(4000);

  vItem         : int;

  vForm         : alpha(1000);
  vMark         : alpha(1000);
  vLogo         : alpha(1000);
  vReci         : alpha(1000);
  vDesign       : alpha(1000);
  vDMSName      : alpha(1000);
  vSprache      : alpha;
  vAdr          : int;
end;
begin

  // - Mahnungen werden pro Kunde ausgegeben
  // - Kunde wird vor Formularaufruf ausgewählt und kann hier ausgewertet werden
  RecREaD(460,1,0);
  vKunde # Ofp.Kundennummer;

  // Liste für Sortieren erstellen
  vMahnTree # CteOpen(_CteTreeCI);

  /* Markierungen sortiert in eigene Liste schreiben */
  FOR   Erx # RecRead(460,2,0);
  LOOP  Erx # RecRead(460,2,_RecNext);
  WHILE (Erx < _rNokey) AND (Ofp.Kundennummer = vKunde) DO BEGIN

    if ("OFP.Löschmarker"='*') then CYCLE;


    vMid # RecInfo(460,_RecID);

    // gelesenen Eintrag in eigene Liste übergeben
    vMahnSortKey # CnvAi(Ofp.Kundennummer, _FmtNumNoGroup | _FmtNumLeadZero,0,10) +
                   Lib_Strings:DateForSort(OfP.Rechnungsdatum);
    Sort_ItemAdd(vMahnTree,vMahnSortKey,460,vMID);
  END;

  // 1. Satz holen
  vMahnItem # Sort_ItemFirst(vMahntree)
  if (vMahnItem=0) then begin
    // Kunde hat keine offenen Posten zum Mahnen  markiert

    // Löschen der Liste
    Sort_KillList(vMahnTree);
    RETURN;
  end;


  // XML-Dokument als Cte-Knoten anlegen
  vJSON # CteOpen(_CteNode);
  // Cte-Knoten als JSON-Objekt deklarieren
  vJSON->spID # _JSONNodeObject;

  // Number
  vJSON->CteInsertNode('Kundennummer',    _JsonNodeNumber , vKunde);

  // Array von Rechnungen
  vNode # vJSON->CteInsertNode('Rechnungen',  _JsonNodeArray, NULL);

  // Rechnungen für Ausgabe festlegen
  FOR   vMahnItem # Sort_ItemFirst(vMahntree)
  LOOP  vMahnItem # Sort_ItemNext(vMahntree, vMahnItem)
  WHILE (vMahnItem <> 0) DO BEGIN
    RecRead(460,0,_RecId, vMahnItem->spID);

    // Object
    vNode->CteInsertNode('Nummer',         _JsonNodeNumber, OFP.Rechnungsnr);
  END;

  Sort_KillList(vMahnTree);
//  vPara # JSONtoPara(var vJSON);


  // 2022-03-18 TM: Richtige Stelle für Mahnung nach ArcFlow??
  vForm     # 'MAHN';
  vDMSName  # GetDokName(var vSprache, var vAdr, Auf.Nummer);
  vDesign   # Frm.Style;

  if (Set.DMS.PDFPath<>'')then begin
    Erx # RecLink(100,400,1,_RecFirst);                     // Kunde holen
    DMS_ArcFlow:SetSqlPdfName('MAHN',Auf.Nummer, Adr.Nummer);
  end;


  vDesign # DesignInSprache(vDesign, vSprache);

  if (Frm.VorschauYN) then
    PreviewPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName);
  if (Frm.DirektDruckYN) then
    PrintPDF(vForm, vDesign, vLogo, vMark, '', vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);

  CloseJSON(var vJSON);

  //Winsleep(5000);
end;



//========================================================================
//
//
//========================================================================
main(opt aKeys    : alpha(250))
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vLogo       : alpha(4096);
  vMark       : alpha(4096);
  vRecipient  : alpha(4096);
  vDMSName    : alpha(4096);
  vOK         : logic;
  vHdl        : int;
  vItem       : int;
  vMFile      : int;
  vMId        : int;
  vSprache    : alpha;
  vAdr        : int;
//  vPara       : alpha(4096);
  vJSON       : handle;
  vNode       : int;

  vXLSFile    : alpha(4000);
  vFileHdl    : int;

  vMeta       : int;
  vTree       : int;
  vA          : alpha;
  vMustEMA    : alpha(4000);
  vSubject    : alpha(1000);

  i           : int;
  vToken      : alpha;
  vCntMax     : int;
  vDelim      : alpha;
  Erx         : int;
  vPureSQL    : logic;
end;
begin

  vForm     # StrCnv("Frm.Kürzel",_strupper);
  vDMSName  # GetDokName(var vSprache, var vAdr);
  vDesign   # Frm.Style;

  vPureSql  # (Frm.EMA.Code='@SQL');
  if vSprache = '' then vSprache  # Adr.Sprache;
  if (vAdr=0) then vAdr      # Adr.Nummer;

  //vMark       # 'Super Kopie';
  //vRecipient  # 'KD';
  //vLogo       # 'E:\Webseite\mc9090.jpg';
  case vForm of
/***
    'SQL'     : begin
      vRecipient  # '';
      vJSON # OpenJSON(TRUE);
      Lib_JSON:AddJSONAlpha(vJSON,'ConnectionString', Lib_SQL:ConnectionString());
    end;
***/

    'TEST' : begin
lfm.ausgabeart # '?';
      if (Lfm.Ausgabeart='?') then begin
        if (Msg(99,'Soll die Liste als Exceldatei (XLS) gespeichert werden?',_WinIcoQuestion,_WinDialogYesNo, 2)=_winidyes) then Lfm.Ausgabeart # 'X';
      end;
      if (Lfm.Ausgabeart='X') then begin
        if ( gUsergroup = 'JOB-SERVER' ) or (gUsername=*^'SOA*') then begin
          vXLSFile # Job.Parameter;
          end
        else begin
          // Filename abfragen
          REPEAT
            vXLSFile # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'Excel-Dateien|*.xls', vXLSFile);
            if (vXLSFile = '' ) then RETURN;
            vFileHdl # FsiOpen(vXLSFile,_FsiStdRead);
            if (vFileHdl > 0) then begin
              vFileHdl->FsiClose();
              if (Msg(910006,'',0,_WinDialogYesNo, 2)=_winidno) then CYCLE;
            end;
          UNTIL (1=1);
          if ( StrCnv( StrCut( vXLSFile, StrLen( vXLSFile ) - 3, 4 ), _strLower ) != '.xls' ) then
            vXLSFile # vXLSFile + '.xls';
        end;
      end;

      // LISTE/REPORT
      vForm # 'Mat0001';
      vDesign # 'ALS_Mat0001.frx';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'VonMaterialnr', 1);
      AddJSONInt(vJSON, 'BisMaterialnr', 16342);
      AddJSONAlpha(vJSON, 'VonStrukturnr', '0');
      AddJSONAlpha(vJSON, 'BisStrukturnr', 'zzz');
//      vPara # JSONtoPara(var vJSON);

      if (vXLSFile<>'') then begin
        FSIDelete(VXLSFile);
        SaveXLS(vForm, vDesign, vJSON, vXLSFile);
        CloseJSON(var vJSON);
        if (Lib_FileIO:FileExists(vXLSFile)) then SysExecute('*'+vXLSFile, '',0);
        RETURN;
      end;

    end;


    'AB'      : begin
//      vPara     # aint(Auf.Nummer);  // 2111271
//vForm # 'SFX:BBB.PrintJob_AufBest';
      vSprache # Auf.Sprache; // Warum muss das hier nochmal?
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:AB');
      vRecipient  # 'KD+AP';  // ST 2016-04-21

      // 2023-02-01 AH : wenn per KOMBI-SQL:    MUSTER
      //vJSON # OpenJSON(true);//vPureSQL);
      //Lib_JSON:AddJSONAlpha(vJSON,'ConnectionString', Lib_SQL:ConnectionString());
      // wenn nur per ViewModel:
      vJSON # OpenJSON(vPureSQL);
      
      AddJSONInt(vJSON, 'Auftragsnr', Auf.Nummer);
      AddJSONInt(vJSON, 'Sprachnr', SpracheAlsZahl(Auf.Sprache));
      // xxxxxxxxxxxxxxxxx

      // <<< MUSTER
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,400,1,_RecFirst);                     // Kunde holen
        DMS_ArcFlow:SetSqlPdfName('AB',Auf.Nummer, Adr.Nummer);
//        vMeta # DMS_ArcFlow:CreateMetadata('AB_'+cnvai(Auf.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
//      DMS_ArcFlow:WriteMetaData(vMeta, 'Adressen\1386\Verkauf');
//      DMS_ArcFlow:WriteMetaData(vMeta, 'Adressen\1397\Verkauf');
//        DMS_ArcFlow:WriteMetaData(vMeta, 'Verkauf\00100747');
//        DMS_ArcFlow:WriteMetaData(vMeta, 'Verkauf\00100748');
//        DMS_ArcFlow:CloseMetaData(vMeta);
      end;
      vSubject # vForm + '_' + cnvai(Auf.Nummer, _FmtNumNoGroup);
      // ENDE MUSTER >>>
    end;


    'AUFFM','AUFFI' : begin
      AufFM();
      RETURN;
    end;


    'AUFSE' : begin
      AufSLEtikett();
      RETURN;
    end;


    'ANG'     : begin
//      vPara # aint(Auf.Nummer);
      vRecipient  # 'KD+AP';  // ST 2016-04-21
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Auftragsnr', Auf.Nummer);
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,400,1,_RecFirst);                     // Kunde holen
        DMS_ArcFlow:SetSqlPdfName('ANG',Auf.Nummer, Adr.Nummer);
      end;
    end;


    'ANF'     : begin
      if (vForm='ANF') then begin
        Erx # RecLink(100,500,1,_RecFirst);
        vMustEMA # Adr_Data:GetEmAByCode(Adr.Nummer, 'EMA:ANF');
      end

      if (Frm.Bereich=500) then begin
        //vPara # Ein_Anfrage_Para();
        vJSON # Ein_Anfrage_Para();
        vForm # 'BEST';
        if (Set.DMS.PDFPath<>'')then begin
          Erx # RecLink(100,500,1,_RecFirst);                     // Lieferant holen
          DMS_ArcFlow:SetSqlPdfName('BEST',Ein.Nummer, Adr.Nummer);
        end;
      end
      else begin
        FOR vItem # gMarkList->CteRead(_CteFirst)
        LOOP vItem # gMarkList->CteRead(_Ctenext, vItem);
        WHILE (vItem <> 0) do begin
          Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

          if (vMFile <> 100) then CYCLE;
          RecRead(100,0,_RecId,vMID);

          vOK # y;
          Auf_Anfrage();
        END;

        if (vOK=false) then Auf_Anfrage();
        RETURN;
      end;
    end;  // Anfrage


    'BAG',
    'BAGST' : begin
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Nummer', BAG.Nummer);
      AddJSONInt(vJSON, 'Position', 0);
      if (Set.DMS.PDFPath<>'')then begin
        DMS_ArcFlow:SetSqlPdfName('BAG',BAG.Nummer,0);
      end;
      //vPara # JSONtoPara(var vJSON);
    end;

    'LFA' : begin
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Nummer', BAG.P.Nummer);
      AddJSONInt(vJSON, 'Position', Bag.P.Position);
      if (Set.DMS.PDFPath<>'')then begin
        DMS_ArcFlow:SetSqlPdfName('LFA',BAG.Nummer,0);
      end;
//      vPara # JSONtoPara(var vJSON);
    end;


    'LTA', 'LSA', 'LBA', 'LWA' : begin
      vForm # 'LOHNBAG';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Nummer', BAG.P.Nummer);
      AddJSONInt(vJSON, 'Position', Bag.P.Position);
      if (Set.DMS.PDFPath<>'')then begin
        DMS_ArcFlow:SetSqlPdfName(vForm, BAG.Nummer,0);
      end;
      //vPara # JSONtoPara(var vJSON);
    end;


    'BEST'    : begin
//      vPara     # aint(Ein.Nummer);
      if (vForm='BEST') then begin
        Erx # RecLink(100,500,1,_RecFirst);
        vMustEMA # Adr_Data:GetEmAByCode(Adr.Nummer, 'EMA:BEST');
      end;

      vRecipient  # 'LF+AP';  // TM 2016-06-16
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Bestellnr', Ein.Nummer);
      AddJSONInt(vJSON, 'Sprachnr', SpracheAlsZahl(Ein.Sprache));
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,500,1,_RecFirst);                     // Liefernat holen
        DMS_ArcFlow:SetSqlPdfName('BEST', Ein.Nummer, Adr.Nummer);
      end;
      vSubject # vForm + '_' + cnvai(Ein.Nummer, _FmtNumNoGroup);
    end;

    // Hilfs und Betriebsstoffe
    'BESTH'    : begin
      vRecipient  # 'LF';  // ST +AP geht noch nicht im Standard
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Bestellnr', HuB.EK.Nummer);
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,190,2,_RecFirst);                     // Liefernat holen
        DMS_ArcFlow:SetSqlPdfName('BESTH', HuB.EK.Nummer, Adr.Nummer);
      end;
    end;
    
    'GBES'    : begin
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:RE');
      vSprache # Auf.Sprache;

      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Auftragsnummer', Auf.Nummer);
      AddJSONInt(vJSON, 'Auftragsposition', Auf.P.Position); //SR: Erweiterung der Parameter
      AddJSONDate(vJSON, 'AktionsDatumMax', Gv.Datum.01);
     
      vRecipient  # 'RE';

      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,400,4,_RecFirst);                     // ReEmpfänger holen
        DMS_ArcFlow:SetSqlPdfName('GBES', Auf.Nummer, Adr.Nummer);
      end;
    end;


    'LFSVM',
    'LAVIS',      // Lieferavis
    'FST',        // FREISTELLUNG
    'VLDAW',
    'LFS'      : begin
//      vPara     # aint(Lfs.Nummer);
      if (vForm='LFS') then
        vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:LFS');

      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Lieferscheinnr', Lfs.Nummer);
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,440,1,_RecFirst);                     // Kunde holen
        DMS_ArcFlow:SetSqlPdfName(vForm, Lfs.Nummer, Adr.Nummer);

        // in anderen Auftragsmappen eintragen...
        vTree # CteOpen(_CteTreeCI);
        FOR Erx # ReCLink(441,440,4,_recFirst)    // Positionen loopen
        LOOP Erx # ReCLink(441,440,4,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Lfs.P.Auftragsnr=0) then CYCLE;
          vTree->CteInsertItem(aint(Lfs.P.Auftragsnr), Lfs.P.Auftragsnr, '');
        END;
        FOR vItem # CteRead(vTree, _CteFirst)
        LOOP vItem # CteRead(vTree, _CteNext, vItem)
        WHILE (vItem<>0) do begin
          if (vMeta=0) then begin
            vMeta # DMS_ArcFlow:CreateMetadata('LFS_'+cnvai(Lfs.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
          end;
          DMS_ArcFlow:WriteMetaData(vMeta, 'Verkauf\'+cnvai(vItem->spID,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
        END;
        vTree->CteClear( true );
        vTree->CteClose();
        if (vMeta<>0) then
          DMS_ArcFlow:CloseMetaData(vMeta);
      end;
    end;


    'LFSWZ'    : begin
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:WZ');
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Lieferscheinnr', Lfs.Nummer);
      AddJSONBool(vJSON, 'ProLieferantChargeAnalyseNrZusammenfassen', true);
      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,440,1,_RecFirst);                     // Kunde holen
        DMS_ArcFlow:SetSqlPdfName('WZ',Lfs.Nummer, Adr.Nummer);

        // in anderen Auftragsmappen eintragen...
        vTree # CteOpen(_CteTreeCI);
        FOR Erx # ReCLink(441,440,4,_recFirst)    // Positionen loopen
        LOOP Erx # ReCLink(441,440,4,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Lfs.P.Auftragsnr=0) then CYCLE;
          vTree->CteInsertItem(aint(Lfs.P.Auftragsnr), Lfs.P.Auftragsnr, '');
        END;
        FOR vItem # CteRead(vTree, _CteFirst)
        LOOP vItem # CteRead(vTree, _CteNext, vItem)
        WHILE (vItem<>0) do begin
          if (vMeta=0) then begin
            vMeta # DMS_ArcFlow:CreateMetadata('LFS_'+cnvai(Lfs.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
          end;
          DMS_ArcFlow:WriteMetaData(vMeta, 'Verkauf\'+cnvai(vItem->spID,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
        END;
        vTree->CteClear( true );
        vTree->CteClose();
        if (vMeta<>0) then
          DMS_ArcFlow:CloseMetaData(vMeta);

      end;
    end;


    'METK','MATK'    : begin
      vForm # 'METK';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Materialnr', Mat.Nummer);
    end;
    
        'UETK'    : begin
      vForm # 'UETK';
      vJSON # OpenJSON(vPureSQL);
      AddJSONAlpha(vJSON, 'Username', Usr.Username);
    end;


    'METK2','MATK2'    : begin
      vForm # 'METK';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Materialnr', Mat.Nummer);
      AddJSONBool(vJSON, 'MitAktionen', true);
    end;


    'METKS' : begin
      vForm     # 'METKS';

      vJSON # CteOpen(_CteNode);        // XML-Dokument als Cte-Knoten anlegen
      vJSON->spID # _JSONNodeObject;    // Cte-Knoten als JSON-Objekt deklarieren
      // 2023-02-01 AH : wenn per KOMBI-SQL:  MUSTER
      ///Lib_JSON:AddJSONAlpha(vJSON,'ConnectionString;String', Lib_SQL:ConnectionString());
      //vNode # vJSON->CteInsertNode('Materialnummern;ListInt',  _JsonNodeArray, NULL);
      // wenn nur per Viewmodel:
      vNode # vJSON->CteInsertNode('Materialnummern',  _JsonNodeArray, NULL);

      // ggf. hier Keys oder über Materialmarkierung
      if (aKeys <> '') then begin
        vDelim    # ',';
        vCntMax   # Lib_Strings:Strings_Count(aKeys,vDelim) + 1;

        FOR i # 1
        LOOP inc(i)
        WHILE i <= vCntMax DO BEGIN
          vToken #  Str_Token(aKeys,vDelim,i);
          if (vToken = '') then
            CYCLE;

          vNode->CteInsertNode('Nummer', _JsonNodeNumber, CnvIa(vToken));
        END;
      end
      else
      if (Lib_Mark:Count(200) > 0 ) then begin
        FOR vItem # gMarkList->CteRead(_CteFirst)
        LOOP vItem # gMarkList->CteRead(_Ctenext, vItem);
        WHILE (vItem <> 0) do begin
          Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

          if (vMFile <> 200) then CYCLE;
          RecRead(200,0,_RecId,vMID);
          vNode->CteInsertNode('Nummer',  _JsonNodeNumber, Mat.Nummer);
        END;


      end else
        vNode->CteInsertNode('Nummer', _JsonNodeNumber, Mat.Nummer);
    end;

    'LYS'    : begin
      vForm # 'LYS';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Analysenr', Lys.K.Analysenr);
    end;

    'PETK'   : begin
      vForm # 'METK';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Materialnr', Mat.Nummer);
      AddJSONBool(vJSON, 'MitPaketdaten', true);
    end;
    
    'LPE'   : begin
      vForm # 'LplEtikett';
      vJSON # OpenJSON(vPureSQL);
      AddJSONAlpha(vJSON, 'Lagerplatz', Lpl.Lagerplatz);
      AddJSONBool(vJSON, 'MitCheckSum', true);
    end;
    
    'LPL'   : begin
      vForm # 'Lpl_Etikett_List';
      vJSON # OpenJSON(vPureSQL);
      AddJSONBool(vJSON, 'MitCheckSum', true);
    end;
    
    
    'PRJLY'    : begin
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:PRJ');
      vForm # 'PRJLY';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Projektnr', Prj.Nummer);
      vA # ';';
      FOR   vItem # gMarkList->CteRead(_CteFirst);      // erste Element holen
      LOOP  vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
      WHILE (vItem > 0) DO BEGIN
        Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
        if (vMFile<>122) then CYCLE;
        Erg # RecRead(122,0,_RecID, vMID);
        if (erg<=_rLocked) then begin
          vA # StrCut(vA + aint(Prj.P.Position) + ';',1,4000);
        end;
      END;
    end;


    'RE','REZF','RESTO'  : begin
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:RE');

      vJSON # OpenJSON(vPureSQL);
      //ErloesObj.Skontodatum, ErloesObj.Rechnungsdatum, ErloesObj.Skontoprozent, ErloesObj.Brutto
      AddJSONInt(vJSON, 'Rechnungsnummer', Erl.Rechnungsnr);
      if (Erl.Rechnungsnr=0) then
        AddJSONInt(vJSON, 'Auftragsnummer', Auf.Nummer)
      else
        AddJSONInt(vJSON, 'Auftragsnummer', 0);
      AddJSONDate(vJSON, 'Rechnungsdatum', Erl.Rechnungsdatum);

      AddJSONDate(vJSON, 'Valutadatum', Ofp.Valutadatum);
      AddJSONDate(vJSON, 'Zieldatum', Ofp.Zieldatum);

      AddJSONDate(vJSON, 'Skontodatum', Erl.Skontodatum);
      AddJSONFloat(vJSON, 'Skontoprozent', Erl.Skontoprozent);
      AddJSONDate(vJSON, 'AktionsDatumMax', Gv.Datum.01);
      AddJSONInt(vJSON, 'NurLfsNr', GV.Int.10);

//      if (vForm='REZF') then
        AddJSONBool(vJSON, 'MitZugferd', true);


      // 19.09.2018 AH: für Lieferantenrechnungen
      vA # '';
      if (Erl.Brutto=0.0) then begin
        if (Erl.Rechnungstyp=c_Erl_Gut) then
          vA # c_Gut+' '+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup);
        if (Erl.Rechnungstyp=c_Erl_Bel_Lf) then
          vA # c_Bel_LF+' '+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup);
        if (vA<>'') then begin
          RecBufClear(560);
          ERe.Rechnungsnr # vA;
          Erx # RecRead(560,4,0);
          if (Erx<=_rMultikey) then begin
            Erl.Brutto # - ERe.Brutto;
          end;
        end;
      end;

      AddJSONFloat(vJSON, 'Bruttowert', Erl.Brutto);

//      vPara # JSONtoPara(var vJSON);
//      vPara       # aint(Erl.Rechnungsnr);
      vRecipient  # 'RE';

      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,400,4,_RecFirst);                     // ReEmpfänger holen
        DMS_ArcFlow:SetSqlPdfName('RE', Erl.Rechnungsnr, Adr.Nummer);
      end;
    end;


    'SARE'    : begin
      vJSON # OpenJSON(vPureSQL);
      //ErloesObj.Skontodatum, ErloesObj.Rechnungsdatum, ErloesObj.Skontoprozent, ErloesObj.Brutto
      AddJSONInt(vJSON, 'Rechnungsnummer', Erl.Rechnungsnr);
      if (Erl.Rechnungsnr=0) then
        AddJSONInt(vJSON, 'Kundennummer', Erl.Kundennummer)
      else
        AddJSONInt(vJSON, 'Auftragsnummer', 0);
      AddJSONDate(vJSON, 'Rechnungsdatum', Erl.Rechnungsdatum);

      AddJSONDate(vJSON, 'Valutadatum', Ofp.Valutadatum);
      AddJSONDate(vJSON, 'Zieldatum', Ofp.Zieldatum);

      AddJSONDate(vJSON, 'Skontodatum', Erl.Skontodatum);
      AddJSONFloat(vJSON, 'Skontoprozent', Erl.Skontoprozent);
      AddJSONDate(vJSON, 'AktionsDatumMax', Gv.Datum.01);
      AddJSONFloat(vJSON, 'Bruttowert', Erl.Brutto);
//      vPara # JSONtoPara(var vJSON);
//      vPara       # aint(Erl.Rechnungsnr);
      vRecipient  # 'RE';

      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,450,5,_RecFirst);                     // ReEmpfänger holen
        DMS_ArcFlow:SetSqlPdfName('SR',Erl.Rechnungsnr, Adr.Nummer);

        // in anderen Auftragsmappen eintragen...
        vTree # CteOpen(_CteTreeCI);
        FOR Erx # ReCLink(451,450,1,_recFirst)    // Konten loopen
        LOOP Erx # ReCLink(451,450,1,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (Erl.K.Auftragsnr=0) then CYCLE;
          vTree->CteInsertItem(aint(Erl.K.Auftragsnr), Erl.K.Auftragsnr, '');
        END;
        FOR vItem # CteRead(vTree, _CteFirst)
        LOOP vItem # CteRead(vTree, _CteNext, vItem)
        WHILE (vItem<>0) do begin
          if (vMeta=0) then begin
            vMeta # DMS_ArcFlow:CreateMetadata('SR_'+cnvai(Erl.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
          end;
          DMS_ArcFlow:WriteMetaData(vMeta, 'Verkauf\'+cnvai(vItem->spID,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
        END;
        vTree->CteClear( true );
        vTree->CteClose();
        if (vMeta<>0) then
          DMS_ArcFlow:CloseMetaData(vMeta);

      end;

    end;


    // Stornorechnung
    'SRE'    : begin
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Rechnungsnummer', Erl.Rechnungsnr);
//      vPara # JSONtoPara(var vJSON);
      vRecipient  # 'RE';

      if (Set.DMS.PDFPath<>'')then begin
        Erx # RecLink(100,450,5,_RecFirst);                     // ReEmpfänger holen
        DMS_ArcFlow:SetSqlPdfName('SR',Erl.Rechnungsnr, Adr.Nummer);
      end;

    end;


    'MAHN' : begin
      Mahnung();
      RETURN;
    end;

    'OPKTO' : begin
      OPKontoauszug();
      RETURN;
    end;


    // Lagerplatzetikett
    'LETK' : begin
      vJSON # OpenJSON(vPureSQL);

      vNode # vJSON->CteInsertNode('Lagerplaetze',  _JsonNodeArray, NULL);
      if (Lib_Mark:Count(844) > 0) then begin
        FOR vItem # gMarkList->CteRead(_CteFirst)
        LOOP vItem # gMarkList->CteRead(_Ctenext, vItem);
        WHILE (vItem <> 0) do begin
          Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

          if (vMFile <> 844) then CYCLE;
          RecRead(844,0,_RecId,vMID);
          vNode->CteInsertNode('Lpl',         _JsonNodeString, LPL.Lagerplatz);
        END;

      end else begin
        vNode->CteInsertNode('Lpl',         _JsonNodeString, LPL.Lagerplatz);
      end;
      //vPara # JSONtoPara(var vJSON);
    end;


    'REKB', 'REK', 'REKBL' : begin
      
      vForm     # StrCnv("Frm.Kürzel",_strupper);
      
      vForm # 'REKB';
      vJSON # OpenJSON(vPureSQL);
      AddJSONInt(vJSON, 'Reklamationsnr', Rek.P.Nummer);
      vRecipient  # '';
  
      vDMSName  # GetDokName(var vSprache, var vAdr, Auf.Nummer);
      vDesign   # Frm.Style;
      vMustEMA # Adr_Data:GetEmAByCode(vAdr, 'EMA:QS');   // 16.09.2021 AH
      
      if (Set.DMS.PDFPath<>'')then begin
        DMS_ArcFlow:SetSqlPdfName('REKB',Rek.P.Nummer, 0);
      end;
    end;

  end;  // CASE

  if (vPureSQL) and (vJSON<>0) then begin
    Lib_JSON:AddJSONAlpha(vJSON,'ConnectionString', Lib_SQL:ConnectionString());
    Lib_JSON:AddJSONInt(vJSON,'EigeneAdressnr', Set.eigeneAdressnr);
    Lib_JSON:AddJSONInt(vJSON,'Adressartnr', vAdr);
    Lib_JSON:AddJSONAlpha(vJSON,'Sprache', vSprache);
    vForm # 'SQL';
  end;

  vDesign # DesignInSprache(vDesign, vSprache);
//debug(vForm+' , '+vDesign+' ,'+vLogo+' , '+vMark+' , '+' , '+vRecipient, vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);
  if (Frm.VorschauYN) then begin
    PreviewPDF(vForm, vDesign, vLogo, vMark, vRecipient, vJSON, vDMSName, vSubject, vMustEMA);
  end;
  if (Frm.DirektDruckYN) then begin
    PrintPDF(vForm, vDesign, vLogo, vMark, vRecipient, vJSON, vDMSName, Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);
  end;

  CloseJSON(var vJSON);

end;

//========================================================================
