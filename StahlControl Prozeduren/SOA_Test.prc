@A+
//==== Business-Control ===================================================
//
//  Prozedur    SOA_TEST
//                        OHNE E_R_G
//  Info
//        Implementerung des Servicelayers für die Webserviceintegration
//
//  02.09.2010  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub handleRequest ( aTsk : handle; aEvtType : int )
//    sub parseRequest(aRequest : handle) : handle
//
//
//=========================================================================
@I:Def_Global
@I:Lib_SOA
@I:SOA_SVL_Protokoll

define begin
  // Quelle: C16 Hilfe, berücksichtigt Eigenheiten bei überlauf
  Sys.TicsDiff(aTicsBegin, aTicsEnd) : Abs(aTicsBegin - aTicsEnd + CnvIL(aTicsBegin >= 0 and aTicsEnd < 0))
end;


sub exec(vRequestData : handle; vRoot : handle; vArgs : handle)
local begin
  vNode : handle;
  vErg : handle;

  // Verbindungs-, Anfrage- & Antwortvariablen
  vSocket       : handle; // Socket der Verbindung
  vRequest      : handle; // Handle für das Requestobjekt

  vResponse     : handle; // Handle für Responseobjekt
  vResponseData : handle; // Antwortdaten-Container
  vResponseRoot : handle; // Einstiegsknoten für Antwort
  vResponseMem  : handle; // Speicherobjekt für Antwortdaten
  vResponseLngth  : int;    // Länge der Antwort

  // Protokolldaten
  vProtokId     : int;    // ID des entsprechenden Protokolleintrages
  vSvcErr       : int;    //  Fehlercode der Serviceausführung
  vSceTime      : int;    //  Ausführungszeit
  vSceTimeStart : int;    //  Ausführung Start
  vSceTimeEnd   : int;    //  Ausführung Ende

  // Knotenhandles
  vDoc      : handle;   // Handle für XML Document
  vHeader   : handle;   // Handle für Headerknoten


  vErrNode        : handle;
  vResponseAnswer : handle;

  vTmp  : handle;

end;
begin
dbg('Startest');
    // Zeitmessung starten
    vSceTimeStart # SysTics();

    try begin
      // Request protokollieren
      vProtokId  # prtRequest(vRequestData, vSocket, 0);
      if (vProtokID < 1) then
        vSvcErr # vProtokId;

      //HTTP Response & AntwortobjektDatenobjekt erstellen
      vResponseData   # CteOpen(_cteNode);
      vResponseData->spId # _xmlNodeDocument;
      vResponseRoot   # vResponseData->Lib_XML:AppendNode('SC_RESPONSE');

      // Fehlernode und Antwortnode anhängen, wird vom Manager, und Service beschrieben
      vErrNode        # vResponseRoot->Lib_XML:AppendNode('ERRORS');
      vResponseAnswer # vResponseRoot->Lib_XML:AppendNode('DATA');

      // Servicemanagement aufrufen
      vErg # SOA_SVM_Manager:process(vRequestData,var vResponseRoot);

      // --------------------------------------------
      // Anfrage auswerten
      if (vErg <> 0) then  begin
        // !!! Es sind Fehler aufgetreten

        // Fehler anhängen
        if (vErg > 0) then
          vResponseRoot->addErrNode(vErg);

        // Daten entfernen
        vResponseAnswer # vResponseRoot->getNode('DATA');
        if (vResponseAnswer <> 0) then begin
          vResponseAnswer->CteClear(true);
          vResponseRoot->CteDelete(vResponseAnswer);
        end;
        dbg('Fehler:' + CnvAi(vErg));

      end else begin
        // !!! Alles in Ordnung

        // Keine Fehler aufgetreten, dann Errornode entfernen
        vErrNode # vResponseRoot->getNode('ERRORS');
        if (vErrNode <> 0) then begin
          vErrNode->CteClear(true);
          vResponseRoot->CteDelete(vErrNode);
        end;
        dbg('alles IO:' + CnvAi(vErg));
      end;

    end;


    // Antwortdaten als XML für HTTP Antwort konvertieren
    vResponseMem # MemAllocate( _memAutoSize ); // Speicher für Antwort allokieren

    // Zeitmessung beenden
    vSceTimeEnd # SysTics();
    vSceTime  # Sys.TicsDiff(vSceTimeStart,vSceTimeEnd) / 32; // Messung in Millisekunden umrechnen

    prtResponse(vProtokId, vResponseData,vResponseLngth,vSvcErr, vSceTime);
todo('Manueller Check ende');

end;



sub testKundenFM_1(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1387');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'kndfm');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'testkey');
  vArgs->Lib_XML:AppendNode(toUpper('kundennr'),'121212');
end;

sub testKundenFM_2(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1387');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'kndfm');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'testkey');
  vArgs->Lib_XML:AppendNode(toUpper('kundennr'),'121212');
  vArgs->Lib_XML:AppendNode(toUpper('dickeVon'),'');
end;

// ----
sub testFreiesMaterial_1(var vArgs : handle)
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'V106');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'matfrei');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'testkey');
  vArgs->Lib_XML:AppendNode(toUpper('dickeVon'),'');
end;

//-----
sub testSWECreate_1(var vArgs : handle)
local begin
  vHead : handle;
  vPos  : handle;

end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1387');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'CreateSWE');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'testkey');
  vArgs->Lib_XML:AppendNode(toUpper('write'),'1');

  vHead # vArgs->Lib_XML:AppendNode(toUpper('SWe'));
    vHead->Lib_XML:AppendNode(toUpper('Vorgangsnr'),'12345678');
    vHead->Lib_XML:AppendNode(toUpper('Termin'),'01.01.2010');
    vHead->Lib_XML:AppendNode(toUpper('Bemerkung1'),'ich bin Bemerkung 1');
    vHead->Lib_XML:AppendNode(toUpper('Bemerkung2'),'ich bin Bemerkung 2');
    vHead->Lib_XML:AppendNode(toUpper('Versandart'),'3');
    vHead->Lib_XML:AppendNode(toUpper('Ursprungsland'),'DE');

    vPos # vHead->Lib_XML:AppendNode(toUpper('Pos'));
      vPos->Lib_XML:AppendNode(toUpper('RefID'),'1');
      vPos->Lib_XML:AppendNode(toUpper('Referenznummer'),'V123423/1');
      vPos->Lib_XML:AppendNode(toUpper('Avisiertzum'),'15.02.2010');
      vPos->Lib_XML:AppendNode(toUpper('Lieferscheinnr'),'LF234324');
      vPos->Lib_XML:AppendNode(toUpper('Stueckzahl'),'1');
      vPos->Lib_XML:AppendNode(toUpper('Gewicht'),'25500');
      vPos->Lib_XML:AppendNode(toUpper('GewichtNetto'),'25000.0');
      vPos->Lib_XML:AppendNode(toUpper('GewichtBrutto'),'25050.0');
      vPos->Lib_XML:AppendNode(toUpper('Intrastatnr'),'DE1212131');
      vPos->Lib_XML:AppendNode(toUpper('Coilnummer'),'Coil321');
      vPos->Lib_XML:AppendNode(toUpper('Chargennummer'),'Charge321');
      vPos->Lib_XML:AppendNode(toUpper('Ringnummer'),'Ring321');
      vPos->Lib_XML:AppendNode(toUpper('Werksnummer'),'Werk321');

      vPos->Lib_XML:AppendNode(toUpper('Guetenstufe'),'2a');
      vPos->Lib_XML:AppendNode(toUpper('Guete'),'DD12');
      vPos->Lib_XML:AppendNode(toUpper('AusfuehrungOben'),'geb,öl');
      vPos->Lib_XML:AppendNode(toUpper('AusfuehrungUnten'),'');
      vPos->Lib_XML:AppendNode(toUpper('Warengruppe'),'50');
      vPos->Lib_XML:AppendNode(toUpper('Ursprungsland'),'DE');

      vPos->Lib_XML:AppendNode(toUpper('Dicke'),'1.78');
      vPos->Lib_XML:AppendNode(toUpper('DickenToleranz'),'+-1');
      vPos->Lib_XML:AppendNode(toUpper('Breite'),'1200');
      vPos->Lib_XML:AppendNode(toUpper('BreitenToleranz'),'+-10');
      vPos->Lib_XML:AppendNode(toUpper('Laenge'),'');
      vPos->Lib_XML:AppendNode(toUpper('LaengenToleranz'),'+-100');
      vPos->Lib_XML:AppendNode(toUpper('RID'),'508');
      vPos->Lib_XML:AppendNode(toUpper('RAD'),'2851.1');
      vPos->Lib_XML:AppendNode(toUpper('Bemerkung'),'Positionsbemerkung 1');





    vPos # vHead->Lib_XML:AppendNode(toUpper('Pos'));
      vPos->Lib_XML:AppendNode(toUpper('RefID'),'2');
      vPos->Lib_XML:AppendNode(toUpper('Referenznummer'),'V123423/2');
      vPos->Lib_XML:AppendNode(toUpper('Avisiertzum'),'30.01.2010');
      vPos->Lib_XML:AppendNode(toUpper('Lieferscheinnr'),'LF1234');
      vPos->Lib_XML:AppendNode(toUpper('Stueckzahl'),'2');
      vPos->Lib_XML:AppendNode(toUpper('Gewicht'),'15000');
      vPos->Lib_XML:AppendNode(toUpper('GewichtNetto'),'14985');
      vPos->Lib_XML:AppendNode(toUpper('GewichtBrutto'),'15011');
      vPos->Lib_XML:AppendNode(toUpper('Intrastatnr'),'DE1234232');
      vPos->Lib_XML:AppendNode(toUpper('Coilnummer'),'Coil123');
      vPos->Lib_XML:AppendNode(toUpper('Chargennummer'),'Charge123');
      vPos->Lib_XML:AppendNode(toUpper('Ringnummer'),'Ring123');
      vPos->Lib_XML:AppendNode(toUpper('Werksnummer'),'Werk123');

      vPos->Lib_XML:AppendNode(toUpper('Guetenstufe'),'1a');
      vPos->Lib_XML:AppendNode(toUpper('Guete'),'DD11');
      vPos->Lib_XML:AppendNode(toUpper('AusfuehrungOben'),'Gebeizt, Gefettet');
      vPos->Lib_XML:AppendNode(toUpper('AusfuehrungUnten'),'Gebeizt, Geölt');
      vPos->Lib_XML:AppendNode(toUpper('Warengruppe'),'50');
      vPos->Lib_XML:AppendNode(toUpper('Ursprungsland'),'NL');

      vPos->Lib_XML:AppendNode(toUpper('Dicke'),'1');
      vPos->Lib_XML:AppendNode(toUpper('DickenToleranz'),'+-1');
      vPos->Lib_XML:AppendNode(toUpper('Breite'),'1500');
      vPos->Lib_XML:AppendNode(toUpper('BreitenToleranz'),'+-10');
      vPos->Lib_XML:AppendNode(toUpper('Laenge'),'');
      vPos->Lib_XML:AppendNode(toUpper('LaengenToleranz'),'+-100');
      vPos->Lib_XML:AppendNode(toUpper('RID'),'508');
      vPos->Lib_XML:AppendNode(toUpper('RAD'),'2500');

      vPos->Lib_XML:AppendNode(toUpper('Bemerkung'),'Positionsbemerkung2');

      // Analyse
      vPos->Lib_XML:AppendNode(toUpper('StreckgrenzeVon'),'1');
      vPos->Lib_XML:AppendNode(toUpper('StreckgrenzeBis'),'2');
      vPos->Lib_XML:AppendNode(toUpper('ZugfestigkeitVon'),'2');
      vPos->Lib_XML:AppendNode(toUpper('ZugfestigkeitBis'),'3');
      vPos->Lib_XML:AppendNode(toUpper('DehnungA'),'4');
      vPos->Lib_XML:AppendNode(toUpper('DehnungB'),'5');
      vPos->Lib_XML:AppendNode(toUpper('Rp02Von'),'6');
      vPos->Lib_XML:AppendNode(toUpper('Rp02Bis'),'7');
      vPos->Lib_XML:AppendNode(toUpper('Rp10Von'),'8');
      vPos->Lib_XML:AppendNode(toUpper('Rp10Bis'),'9');
      vPos->Lib_XML:AppendNode(toUpper('Koernung'),'10');
      vPos->Lib_XML:AppendNode(toUpper('HaerteVon'),'11');
      vPos->Lib_XML:AppendNode(toUpper('HaerteBis'),'12');
      vPos->Lib_XML:AppendNode(toUpper('RauhigkeitObenVon'),'13');
      vPos->Lib_XML:AppendNode(toUpper('RauhigkeitObenBis'),'14');
      vPos->Lib_XML:AppendNode(toUpper('RauhigkeitUntenVon'),'15');
      vPos->Lib_XML:AppendNode(toUpper('RauhigkeitUntenBis'),'16');
      vPos->Lib_XML:AppendNode(toUpper('MechanikSonstiges'),'17');

      vPos->Lib_XML:AppendNode(toUpper('C'),'1');
      vPos->Lib_XML:AppendNode(toUpper('Si'),'2');
      vPos->Lib_XML:AppendNode(toUpper('Mn'),'3');
      vPos->Lib_XML:AppendNode(toUpper('P'),'4');
      vPos->Lib_XML:AppendNode(toUpper('S'),'5');
      vPos->Lib_XML:AppendNode(toUpper('Al'),'6');
      vPos->Lib_XML:AppendNode(toUpper('Cr'),'7');
      vPos->Lib_XML:AppendNode(toUpper('V'),'8');
      vPos->Lib_XML:AppendNode(toUpper('Nb'),'9');
      vPos->Lib_XML:AppendNode(toUpper('Ti'),'10');
      vPos->Lib_XML:AppendNode(toUpper('N'),'11');
      vPos->Lib_XML:AppendNode(toUpper('Cu'),'12');
      vPos->Lib_XML:AppendNode(toUpper('Ni'),'13');
      vPos->Lib_XML:AppendNode(toUpper('Mo'),'14');
      vPos->Lib_XML:AppendNode(toUpper('B'),'15');

      // Verpackung
      vPos->Lib_XML:AppendNode(toUpper('AbbindungLaengs'),'1');
      vPos->Lib_XML:AppendNode(toUpper('AbbindungQuer'),'2');
      vPos->Lib_XML:AppendNode(toUpper('Zwischenlage'),'3');
      vPos->Lib_XML:AppendNode(toUpper('Unterlage'),'4');
      vPos->Lib_XML:AppendNode(toUpper('Umverpackung'),'5');
      vPos->Lib_XML:AppendNode(toUpper('Stehend'),'0');
      vPos->Lib_XML:AppendNode(toUpper('Liegend'),'1');
      vPos->Lib_XML:AppendNode(toUpper('Nettoabzug'),'6');
      vPos->Lib_XML:AppendNode(toUpper('Stapelhoehe'),'7');
      vPos->Lib_XML:AppendNode(toUpper('Stapelhoehenabzug'),'8');
      vPos->Lib_XML:AppendNode(toUpper('Rechtwinkeligkeit'),'9');
      vPos->Lib_XML:AppendNode(toUpper('Ebenheit'),'10');
      vPos->Lib_XML:AppendNode(toUpper('Saebeligkeit'),'11');
      vPos->Lib_XML:AppendNode(toUpper('Wicklung'),'12');


    //     vPos->Lib_XML:AppendNode(toUpper(''),'');


end;

//-----
sub testGECreate(var vArgs : handle)
local begin
  vHead : handle;
  vPos  : handle;

  vTele       : int;
  vSync       : int;
  vTyp        : int;
  vLfdnr      : int;
  vSetupStat  : int;
  vSetupPart  : int;
  vFlag       : int;

end;
begin
  // Kopf ----
  vTele       # 0;    // Länge des Telegramms in Byte, Kopf incl. Positionen
  vSync       # 0;    // Synch-Zeichen, NICHT VERWENDET!
  vTyp        # 1001; // Telegrammtyp
  vLfdNr      # 123;  // laufende Nummer 0-1000
  
  vSetupStat  # 1;    // 1 = OK, alles andere Error-ID
  vSetupPart  # 2;    // 2 = Part 1 (pass 11-20)
  
  // Positionen ----
  vFlag # 1111; // Bit-weise Auswertung   0-11
  
   
  
  
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1387');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'CreateGE');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'testkey');
  vArgs->Lib_XML:AppendNode(toUpper('write'),'1');

  vHead # vArgs->Lib_XML:AppendNode(toUpper('Kopf'));
  vHead->Lib_XML:AppendNode(toUpper('Tele_Groesse'),aint(vTele));
  vHead->Lib_XML:AppendNode(toUpper('Synch Nr.'),aint(vSync));
  vHead->Lib_XML:AppendNode(toUpper('Telegrammnr'),aint(vTele));
  vHead->Lib_XML:AppendNode(toUpper('Übertragungsnr'),aint(vLfdNr));

    vPos # vHead->Lib_XML:AppendNode(toUpper('Pos'));
      vPos->Lib_XML:AppendNode(toUpper('SetupStat'),aint(vSetupStat));
      vPos->Lib_XML:AppendNode(toUpper('SetupPart'),aint(vSetupPart));
      vPos->Lib_XML:AppendNode(toUpper('vFlag'),aint(vFlag));
      


    //     vPos->Lib_XML:AppendNode(toUpper(''),'');


end;
//----


sub testMatinfo(var vArgs : handle)
local begin
  vTmp : alpha;

end;
begin
/*
http://192.168.0.2:5050/?service=matinfo&sender=A1386&
felder=individuell
&nummer=3100&
mat.nummer=1&mat.vorgaenger=1&mat.ursprung=0
*/
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'matinfo');
  vArgs->Lib_XML:AppendNode(toUpper('felder'),'individuell');
  vArgs->Lib_XML:AppendNode(toUpper('nummer'),'3100');

  vTmp # StrCnv(toUpper('mat.vorgänger'),_StrToURI);

vTmp # StrCnv(toUpper('mat.vorgänger'),_StrToHTML);
vTmp # StrCnv(toUpper('mat.vorgänger'),_StrToUTF8);

vTmp # StrCnv(toUpper('mat.vorgänger'),_StrToOEM);
vTmp # StrCnv(toUpper('mat.vorgänger'),_StrToAnsi);


  vArgs->Lib_XML:AppendNode(toUpper('mat.nummer'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('mat.ursprung'),'1');
  vArgs->Lib_XML:AppendNode(StrCnv(toUpper('mat.vorgänger'),_StrToURI),'1');



end;




sub testMatSel(var vArgs : handle)
local begin
  vTmp : alpha;

end;
begin
/*
http://192.168.0.2:5050/?service=matinfo&sender=A1386&
felder=individuell
&nummer=3100&
mat.nummer=1&mat.vorgaenger=1&mat.ursprung=0
*/
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'mat_sel');
  vArgs->Lib_XML:AppendNode(toUpper('felder'),'indi');
  vArgs->Lib_XML:AppendNode(toUpper('mat.dicke'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('sel_not_Mat.Dicke'),'3.50|5.00');
end;



sub testAdrSel(var vArgs : handle)
local begin
  vTmp : alpha;

end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'adr_sel');
  vArgs->Lib_XML:AppendNode(toUpper('felder'),'indi');
  vArgs->Lib_XML:AppendNode(toUpper('adr.Stichwort'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('adr.Kundennr'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('sel_aus_Adr.Kundennr'),'1011|1012|1013');
end;


sub testAnsSel(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'ans_sel');
  vArgs->Lib_XML:AppendNode(toUpper('felder'),'indi');
  vArgs->Lib_XML:AppendNode(toUpper('adr.p.name'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('sel_von_adr.P.adressnr'),'0');
end;

sub testMabSel(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'mab_sel');
//  vArgs->Lib_XML:AppendNode(toUpper('felder'),'indi');
//  vArgs->Lib_XML:AppendNode(toUpper('adr.p.name'),'1');
//  vArgs->Lib_XML:AppendNode(toUpper('sel_von_adr.P.adressnr'),'0');
end;


sub testToUpper()
local begin
  vTmp : alpha;
end;
begin
  vTmp # 'RSO.t_Ruestbasis';
  vTmp # toUpper(vTmp);
end;


sub testMatResNew(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'mat_res_new');
  vArgs->Lib_XML:AppendNode(toUpper('materialnr'),'3111');
  vArgs->Lib_XML:AppendNode(toUpper('stueckzahl'),'1');
  vArgs->Lib_XML:AppendNode(toUpper('gewicht'),'333');
  vArgs->Lib_XML:AppendNode(toUpper('kundennummer'),'1213');
end;


sub testVSBEingang(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'ein_pos_we_onvsb');
  vArgs->Lib_XML:AppendNode(toUpper('materialnr'),'3558');

  vArgs->Lib_XML:AppendNode(toUpper('Bestellnummer'),'1306');
  vArgs->Lib_XML:AppendNode(toUpper('Bestellposition'),'3');
  vArgs->Lib_XML:AppendNode(toUpper('Datum'),'25.05.2011');
  vArgs->Lib_XML:AppendNode(toUpper('Gewicht'),'4999');
  vArgs->Lib_XML:AppendNode(toUpper('Lagerplatz'),'halle1');
  vArgs->Lib_XML:AppendNode(toUpper('DickeIst'),'2,2');
  vArgs->Lib_XML:AppendNode(toUpper('breiteIst'),'1001,30');

end;



sub testAPPLEGETFILE(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386/3');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'IPAD_GETFILE');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'test');

end;

sub testBinary(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386/3');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'IPAD_FILE');
  vArgs->Lib_XML:AppendNode(toUpper('key'),'test');

end;


sub testBagNew(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_NEW');
  vArgs->Lib_XML:AppendNode(toUpper('bemerkung'),'bag test');
end;






sub testMatWareneingang_Allgemein(var vArgs : handle)
local begin
  vPostData : int;
  vTransferObj : int;
end
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender')   ,'A3123');
  vArgs->Lib_XML:AppendNode(toUpper('service')  ,'DOTNET_CALLBACKS');
  vArgs->Lib_XML:AppendNode(toUpper('action')   ,'MATWARENEINGANG_ALLGEMEIN');
  
  vPostData  # vArgs->Lib_XML:AppendNode(toUpper('POSTDATA'));
    vTransferObj # vPostData->Lib_XML:AppendNode(toUpper('WeTransferObj'));
    vTransferObj->Lib_XML:AppendNode('Lieferantennr'    ,   '1');
    vTransferObj->Lib_XML:AppendNode('Lagerplatz'       ,   'Halle1');
    vTransferObj->Lib_XML:AppendNode('Werksnummer'      ,   'Werksnr');
    vTransferObj->Lib_XML:AppendNode('TransportID'      ,   'Intrastat');
    vTransferObj->Lib_XML:AppendNode('Paketnummer'      ,   '1');
    vTransferObj->Lib_XML:AppendNode('Ringnummer'       ,   'Ringnr');
    vTransferObj->Lib_XML:AppendNode('Coilnummer'       ,   'Coilnr');
    vTransferObj->Lib_XML:AppendNode('Chargennummer'    ,   'Charge');
    vTransferObj->Lib_XML:AppendNode('Dicke'            ,   '1,5');
    vTransferObj->Lib_XML:AppendNode('Breite'           ,   '150,1');
    vTransferObj->Lib_XML:AppendNode('Laenge'           ,   '0,0');
    vTransferObj->Lib_XML:AppendNode('Stueck'           ,   '1');
    vTransferObj->Lib_XML:AppendNode('Gewicht'          ,   '15000');
    vTransferObj->Lib_XML:AppendNode('Gewicht_Netto'    ,   '15000');
    vTransferObj->Lib_XML:AppendNode('Gewicht_Brutto'   ,   '15001');
    vTransferObj->Lib_XML:AppendNode('Verwiegungsart'   ,   '1');
    vTransferObj->Lib_XML:AppendNode('Guete'            ,   'DD123');
    vTransferObj->Lib_XML:AppendNode('Guetenstufe'      ,   'A1');
    vTransferObj->Lib_XML:AppendNode('RID'              ,   '508');
    vTransferObj->Lib_XML:AppendNode('RAD'              ,   '');
    vTransferObj->Lib_XML:AppendNode('Bemerkung1'       ,   'Bem1');
    vTransferObj->Lib_XML:AppendNode('Bemerkung2'       ,   'Bem2');
    vTransferObj->Lib_XML:AppendNode('Lageranschrift'   ,   '1');
    vTransferObj->Lib_XML:AppendNode('Warengruppe'      ,   '100');
    vTransferObj->Lib_XML:AppendNode('EigenmaterialYN'  ,   '1');
    vTransferObj->Lib_XML:AppendNode('Eingangsdatum'    ,   '01.01.2020');
    vTransferObj->Lib_XML:AppendNode('AusfuehrungOben'  ,   '10,12');
    vTransferObj->Lib_XML:AppendNode('AusfuehrungUnten' ,   '');
end;





sub TestInit()
begin

  // ALLE EVENTS ERLAUBEN:
  WinEvtProcessSet(_WinEvtAll,true);

  // Uhrzeit vom Server holen
  DbaControl(_DbaTimeSync);

  VarAllocate(VarSysPublic);   // public Variable allokieren
  gCodepage # _Sys->spCodepageOS;


  VarAllocate(WindowBonus);
  gUserGroup # 'SOA_SERVER';    // Globale Daten Vorbelegen
  gUserName  # UserInfo(_Username); //'SOA_SYNC';      // Vorlegung Standarduser, kann vom Request umgeschrieben werden
  
  Lib_SFX:InitAFX();            // AFX initialisieren
  
  RETURN Lib_ODBC:Init();       // ODBC initalizieren
end;






sub JSN(var vArgs : handle)
local begin
  vTmp : alpha;
end;
begin
  vArgs->Lib_XML:AppendNode(toUpper('sender'),'A1386');
  vArgs->Lib_XML:AppendNode(toUpper('service'),'BAG_JSN_DATA');
  vArgs->Lib_XML:AppendNode(toUpper('Nummer'),'1564');
  vArgs->Lib_XML:AppendNode(toUpper('Position'),'1');
end;





//=========================================================================
//=========================================================================

main
local begin
  vRequestData  : handle; // Daten der Anfrage
  vRoot     : handle;   // Handle für XML Root
  vArgs     : handle;   // Handle für Argumentenknoten

  vMem  : handle;
  vContentyp  : alpha
end
begin
  TestInit();

  // Request Data zusammenstellen
  vRequestData        # CteOpen(_cteNode);
  vRequestData->spId  # _xmlNodeDocument;
  vRoot       # vRequestData->Lib_XML:AppendNode('REQUEST');
  vArgs       # vRoot->Lib_XML:AppendNode('ARGS');


  // Kundenfertigmaterial
  // testKundenFM_1(var vArgs);
  // testFreiesMaterial_1(var vArgs);
  //  testSWECreate_1(var vArgs);
  // testAnsSel(var vArgs);
  //  testMabSel(var vArgs)
//   testToUpper();
//    testMatResNew(var vArgs);
  //testVSBEingang(var vArgs);

  //testAPPLEGETFILE(var vArgs);
  //testBinary(var vArgs);
//  testBagNew(var vArgs);

  //testMatWareneingang_Allgemein(var vArgs);
  /*
  JSN(var vArgs);
  vMem # MemAllocate(_MemAutoSize);

  SVC_JSN_Example:execMemory(vArgs, var vMem, var vContentyp);
*/
end;

//=========================================================================
//=========================================================================
//=========================================================================