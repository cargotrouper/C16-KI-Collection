@A+
//===== Business-Control =================================================
//
//  Prozedur  EDI_LFS
//                    OHNE E_R_G
//  Info      VDA4913
//
//
//  17.07.2018  AH  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  mögliche spezial Anker:
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_EDI

define begin
  cTEST : true

  cWoFDatei                     : 440
end;

declare Start(opt aFileName : alpha(1000)) : logic;
declare ProcessRoot(aRoot : int) : logic;
declare SucheBestellung(aLfNr : int; aBest : alpha; aEkNr : int; aEkPos : int; aAbRef : alpha; var aWofErr : int; var aErr : alpha) : logic;
declare Buche506(a506 : int; var aWofErr : int; var aErr : alpha) : logic;


//========================================================================
//  call EDI_LFS:Export
//========================================================================
sub Export(
  aLfs      : int;
  aFileName : alpha(4000);
  ) : int
local begin
  Erx     : int;
  vAnz    : int;
  vDoc    : handle;
  vNode   : handle;
  vNode2  : handle;
  vNode3  : handle;
  vI,vJ   : int;
  vF,vF2  : float;
  vLohn   : alpha;
end
begin

  Lfs.Nummer # aLfs;
  RecRead(440,1,0);

  /* Dateiauswahl */
//  vFile # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML Dateien|*.xml' );
//  if ( vFile = '' ) then
//    RETURN;

  if (gUsername='AH') then
    aFileName # 'D:\debug\LFS.xml';
  if ( StrCnv( StrCut( aFilename, StrLen( aFileName ) - 3, 4 ), _strLower ) != '.xml' ) then
    aFileName # aFileName + '.xml'

  /* XML Initialisierung */
  vDoc       # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vDoc->CteInsertNode( '', _xmlNodeComment, ' Stahl Control 2018 - LIEFERSCHEIN');

  // XML-START -------------------------------
  vNode # vDoc->Lib_XML:AppendNode( 'LieferAvis' );
  NewNodeA(vNode, 'Version', '1.000'  );


  FOR Erx # RekLink(441,440,4,_recFirst)    // Positionen loopen
  LOOP Erx # RekLink(441,440,4,_recNext)
  WHILE (Erx<=_rLocked) do begin

    // Daten vorbereiten ---------------------------------------------------
    if (vAnz=0) then begin  // für Kopf...
      Erx # RekLink(100, 440, 1, _recFirst);    // Kunde holen
      vLohn # '';
      if (Lfs.zuBA.Nummer<>0) then
        vLohn # aint(Lfs.zuBA.Nummer)+'/'+aint(Lfs.zuBA.Position);
    end;
    
    if (Lfs.P.Artikelnr='') then
      Lfs.P.Artikelnr # aint(Lfs.P.Materialnr);
    if (Lfs.P.Art.Charge='') then
      Lfs.P.Art.Charge # aint(Lfs.P.Materialnr);
    RecBufClear(200);
    if (Lfs.P.Materialnr<>0) then
      Mat_Data:Read(Lfs.P.Materialnr)
    else
      Mat.Ursprungsland # 'D';
    "Lnd.Kürzel" # Mat.Ursprungsland;       // Land holen
    Erx # RecRead(812,1,0);
    if (Erx>_rLocked) then RecBufClear(812);


    // Kommission holen
    RecBufClear(400);
    RecBufClear(401);
    if (Lfs.P.Auftragsnr<>0) then
      Auf_Data:Read(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, true);
    


    if (vAnz=0) then begin
      // SATZKOPF
      vNode2 # vNode->Lib_XML:AppendNode( 'Satz' );
      NewNodeI(vNode2, 'Lieferscheinnr',                Lfs.Nummer);
      NewNodeD(vNode2, 'Lieferdatum',                   Lfs.Lieferdatum);// Lfs.Anlage.Datum);
//      NewNodeT(vNode2, 'Lieferzeit',                    Lfs.Anlage.Zeit);
      NewNodeI(vNode2, 'Kundennr',                      Lfs.Kundennummer);
      NewNodeA(vNode2, 'Lieferantennr_Refcode',         Adr.VK.Referenznr);
      NewNodeA(vNode2, 'Zielanschrift',                 aint(Lfs.Zieladresse)+'/'+aint(Lfs.Zielanschrift));
      NewNodeI(vNode2, 'Versandart',                    Auf.Versandart);
//      NewNodeI(vNode2, 'Identnr',                       5555 );
      NewNodeA(vNode2, 'Fahrauftragsnr',                vLohn);
      NewNodeA(vNode2, 'Abholanschrift',                aint(Mat.Lageradresse)+'/'+aint(Mat.Lageranschrift));
//      NewNodeA(vNode2, 'WerkKunde',                     'blabla');
      NewNodeI(vNode2, 'Spediteurnr',                   Lfs.Spediteurnr);
      NewNodeA(vNode2, 'Sepditeuer',                    Lfs.Spediteur);
      NewNodeA(vNode2, 'Frachtfuehrer',                 Lfs.Fahrer);
      NewNodeA(vNode2, 'KFZ_Kennzeichen',               Lfs.Kennzeichen);
      NewNodeA(vNode2, 'Bemerkung',                     Lfs.Bemerkung);
      NewNodeF(vNode2, 'Gewicht_Brutto',                Lfs.Positionsgewicht);
//      NewNodeD(vNode2, 'Frachtfuehrer_Uebergabedatum',  today);
//      NewNodeT(vNode2, 'Frachtfuehrer_Uebergabezeit',   now);
//      NewNodeI(vNode2, 'Tansportmittel',                1);
//      NewNodeA(vNode2, 'Abladestelle',                  'Halle1');
//      NewNodeA(vNode2, 'Bestellnr',                     '2345/1');
//      NewNodeA(vNode2, 'Abrufnr',                       '1234/1');
    end;  // Kopf
  
    inc(vAnz);
    
    // 714
    vNode3 # vNode2->Lib_XML:AppendNode( 'Position' );
    NewNodeI(vNode3, 'Position',            Lfs.P.Position);
    NewNodeA(vNode3, 'Auftragsnr',          Lfs.P.Kommission);
    NewNodeA(vNode3, 'Bestellung_Refcode',  Auf.P.Best.Nummer);
//    NewNodeA(vNode3, 'Abrufnr',            '1234/1');
    NewNodeI(vNode3, 'Materialnr',          Lfs.P.Materialnr);
    NewNodeA(vNode3, 'Chargennr',           Mat.Chargennummer);
    NewNodeA(vNode3, 'SachnrKunde',         Auf.P.KundenArtNr);
    NewNodeA(vNode3, 'SachnrLieferant',     Lfs.P.Artikelnr);
    //NewNodeI(vNode3, 'Ursprungsland', 123);
    NewNodeI(vNode3, 'Ursprungsland',       "Lnd.Länderkennzahl");
    NewNodeI(vNode3, 'Lieferantenerklaerung', Mat.LfENr);
    NewNodeI(vNode3, 'Stueck',              "Lfs.P.Stück");
    NewNodeF(vNode3, 'Gewicht_Brutto',      Lfs.P.Gewicht.Brutto);
    NewNodeF(vNode3, 'Gewicht_Netto',       Lfs.P.Gewicht.Netto);
    NewNodeF(vNode3, 'Menge1',              Lfs.P.Menge);
    NewNodeA(vNode3, 'MEH1',                Lfs.P.MEH);
    NewNodeF(vNode3, 'Menge2',              Lfs.P.Menge.Einsatz);
    NewNodeA(vNode3, 'MEH2',                Lfs.P.MEH.Einsatz);
    NewNodeA(vNode3, 'Bemerkung',           Lfs.P.Bemerkung);
//    Lib_XML:NewNode(vNode3, 'Praeferenzstatus',    '');
//      NewNodeA(vNode3, 'Verwendung', 'KG');
//      NewNodeA(vNode3, 'Abrufschluessel'. 'KG');
  END;  // Positionen
  // Satzende

  // XML Abschluss
  vDoc->XmlSave(aFileName,_XmlSaveDefault,0, _CharsetUTF8);
  vDoc->CteClear( true );
  vDoc->CteClose();
  
  // alles wunderbar...
  RETURN 1;
end;

//========================================================================