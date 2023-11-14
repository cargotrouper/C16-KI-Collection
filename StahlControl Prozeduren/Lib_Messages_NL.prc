@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Messages_NL
//                    OHNE E_R_G
//  Info
//
// _WinIcoApplication, _WinIcoError,_WinIcoInformation,
// _WinIcoWarning,_WinIcoQuestion
//
// _WinDialogOk, _WinDialogOkCancel, _WinDialogYesNo,
// _WinDialogYesNoCancel
//
//
// ERGEBNIS:
// _WinIdOk, _WinIdCancel, _WinIdYes, _WinIdNo
//
//
//   05.02.2003  AI  Erstellung der Prozedur
//   11.09.2012  ST  "Messages_Msg()"  Angleichung an Lib_Messages:Messages_Msg
//   17.04.2018  ST  Bei Jobserver oder SOA, dann "msg" in "Error" mwandeln
//
//  Subprozeduren
//    SUB Messages_Msg(aNr : int; aPara : alpha; aSymbols : int; aButtons : int; aPreselect : int) : int
//    SUB Error_MsgBox(aWindow : int; aTitle : alpha; aText : alpha; aSymbols : int; aButtons : int; aPreselect : int) : int
//========================================================================
//
// TODO: 99=19999 usw mal ändern
//

@I:Def_Global

define begin
  cProtokolldatei : 'c:\BC_ERROR.TXT'
end;


//========================================================================
//  Fehlertext
//
//========================================================================
sub Fehlertext(aNr : int) : alpha;
local begin
  vA  : alpha(250);
end;
begin

//debug('NL:'+aint(aNr));

  case aNr of
// algemene vragen
    000001 :  vA # 'Q:Deze invoer werkelijk verwijderen?';
    000002 :  vA # 'Q:Input afwijzen?';
    000003 :  vA # 'Q:Wijzigingen afwijzen?';
    000004 :  vA # 'Q:Volledige registratie afwijzen?';
    000005 :  vA # 'Q:Verdere posities registreren?';
    000006 :  vA # 'Q:Veldinhoud van vorige positie overnemen?';
    000007 :  vA # 'Q:Deze invoer werkelijk terughalen?';
    000008 :  vA # 'Q:Wil u de delete-marker werkelijk verplaatsen?';
    000009 :  vA # 'Q:Wil u deze gegevens voor een volgende nieuwe invoer gebruiken?';
    000099 :  vA # '%1%';

// fouten bij verandering van het gebruikerspaswoord
    000010 :  vA # 'E:De paswoorden komen niet overeen!';
    000011 :  vA # 'E:Het oude paswoord klopt niet!';
    000012 :  vA # 'I:Uw paswoord werd succesvol veranderd!';

// algemene fouten
    001001 :  vA # 'E:#%1%:Record is geblokkeerd door gebruiker: '+LockedBy;
    001002 :  vA # 'E:#%1%:Geen unieke toegang mogelijk!';
    001003 :  vA # 'E:#%1%:Record niet gevonden!';
    001004 :  vA # 'E:#%1%:Geen verdere records beschikbaar!';
    001005 :  vA # 'E:#%1%:Bestand leeg/geen gevolg beschikbaar!';
    001006 :  vA # 'E:#%1%:Record bestaat reeds!';
    001007 :  vA # 'E:#%1%:Record is niet geblokkeerd!';
    001008 :  vA # 'E:#%1%:Verbreking door gebruiker!';
    001010 :  vA # 'E:#%1%:Record is DEADLOCKED/vastgelopen!!!';

    001100 :  vA # 'E:#Transactiefout: DUBBELE OPSTART!';
    001101 :  vA # 'E:#Transactiefout: Niets om te beëindigen!';
    001102 :  vA # 'E:#Transactiefout: Niets om te verbreken!';
    001103 :  vA # 'E:#Transactiefout: Niet afgehandelde transactie bij einde van het programma!!!%CR%De laatste wijzigingen worden NIET opgeslagen!!!%CR%AUB DRINGEND CONTACT OPNEMEN MET DE FABRIKANT!';

    001200 :  vA # '%1% moet vermeld worden!';
    001201 :  vA # '%1% niet beschikbaar!';
    001202 :  vA # 'Geen %1% geselecteerd!';
    001203 :  vA # '%1% buiten bereik';
    001204 :  vA # 'E:Er bestaat reeds een record met deze kernwaarden!';
    001205 :  vA # '%1% mag niet negatief zijn!';

    001300 :  vA # 'E:Externe gegevens %1% niet beschikbaar!';

    001400 :  vA # 'E:%1% %2%  vermeld die voor einddatum '+CnvAD(Set.Abschlussdatum)+'!';

    001999 :  vA # 'E:#PROCEDURE ONTBREEKT: %1%';

    // --------------------------------
    010001 :  vA # 'E:Positie %1%: Materiaal/artikel %2% niet gevonden!';
    010002 :  vA # 'E:Positie %1%: Materiaal %2% is reeds verwijderd!';
    010003 :  vA # 'E:Positie %1%: Materiaal %2% heeft een foutief order';
    010004 :  vA # 'E:Positie %1%, Materiaal %2%: Reservering kon niet aangepast of verwijderd worden!';
    010005 :  vA # 'E:Positie %1%: Materiaal %2% kon niet gesplitst worden!';
    010006 :  vA # 'E:Positie %1%: Materiaal %2% heeft nog reserveringen!';
    010007 :  vA # 'E:Positie %1%: Materiaal %2% kon niet geüpdatet worden!';
    010008 :  vA # 'E:Positie %1% kon niet  geüpdatet worden!';
    010009 :  vA # 'E:Positie %1%: Bestelling %2% niet gevonden!';
    010010 :  vA # 'E:Positie %1%, Order %2%: Bestelling kon niet gemaakt worden!';
    010011 :  vA # 'E:Positie %1%: Artikel %2% kon niet geregistreerd worden!';
    010012 :  vA # 'E:Positie %1%: Ordertoeslag kon niet geregistreerd worden!';
    010013 :  vA # 'E:Positie %1% is reeds geregistreerd!';
    010014 :  vA # 'E:Positie %1%: Order %2% niet gevonden!';
    010015 :  vA # 'E:Positie %1%, Order %2%: Orderhoofd niet gevonden!';
    010016 :  vA # 'E:Positie %1%, Order %2%: Klant niet gevonden!';
    010017 :  vA # 'E:Positie %1%, Materiaal %2%: Actie kon niet verwijderd worden!';
    010018 :  vA # 'E:Positie %1%: Order %2% kon niet geüpdatet worden!';
    010019 :  vA # 'E:Positie %1%, Order %2%: Bestelling kon niet verwijderd worden!';
    010020 :  vA # 'E:Positie %1%, Order %2%: Bestelling kon niet geüpdatet worden!';
    010021 :  vA # 'E:Positie %1%, Materiaal %2%: Reservering kon niet opnieuw aangemaakt worden!';
    010022 :  vA # 'E:Positie %1%, Materiaal %2%: Aktie kon niet geüpdatet worden!';
    010023 :  vA # 'E:Positie %1%, Order %2% heeft geen toereikende vrijgave van levering (VVL)!';
    010024 :  vA # 'E:Positie %1%, Order %2%: Positie stuklijst niet gevonden!';
    010025 :  vA # 'E:Positie %1%, Order %2%: Positie stuklijst kon niet geüpdatet worden!';
    010026 :  vA # 'E:Positie %1% is niet geregistreerd!';
    010027 :  vA # 'E:BAG %1%: Input %2% niet gevonden!';
    010028 :  vA # 'E:BAG %1%, Input %2%: Follow-up productie niet gevonden!';
    010029 :  vA # 'E:BAG %1%: Erbij behorende positie afleveringsbewijs niet gevonden!';
    010030 :  vA # 'E:Positie %1% kon niet verwijderd worden!';
    010031 :  vA # 'E:BAG %1%: Order %2% niet gevonden!';
    010032 :  vA # 'E:Afleveringsbewijs kon niet opgeslagen worden!';
    010033 :  vA # 'E:BAG %1%: Productie kon niet opnieuw aangemaakt worden!';
    010034 :  vA # 'E:BAG %1% kon niet geactualiseerd worden!';
    010035 :  vA # 'E:BAG %1%: Input-materiaal %2% kon niet geactualiseerd worden!';
    010036 :  vA # 'E:BAG %1%: Input %2% kon niet verwijderd worden!';
    010037 :  vA # 'E:BAG %1%: Productie %2% kon niet verwijderd worden!';
    010038 :  vA # 'E:BAG %1%: Bestelling niet gevonden!';
    010039 :  vA # 'E:BAG %1%: Bestelling %2% kon niet verwijderd worden!';
    010040 :  vA # 'E:BAG %1%: Input-materiaal %2% niet gevonden!';
    010041 :  vA # 'E:BAG %1%, Order %2%: Bestelling kon niet aangemaakt worden!';
    010042 :  vA # 'E:Materiaal %1% heeft een foute status : %2% ipv %3%!';
    010043 :  vA # 'E:%1% geblokkeerd door !'+Lockedby;
    010044 :  vA # 'E:BAG %1%: Verdere verwerking kon niet gevonden worden!';

    019999 :  vA # '%1%';
  end;

    // Specifieke foutmeldingen van gegevens ********************************
  case aNr of

    // Adressen
    100000 :  vA # 'E:Klantennummer reeds verstrekt!';
    100001 :  vA # 'E:Leveranciersnummer reeds verstrekt!';
    100002 :  vA # 'E:#Hoofdadres (1) kon niet aangemaakt worden!';
    100003 :  vA # 'E:#Kredietlimiet kon niet aangemaakt worden!';
    100004 :  vA # 'E:Adres mag niet verwijderd worden, daar reeds %1% daarvoor bestaan!';
    100005 :  vA # 'E:Klant %1% is geblokkeerd!'
    100006 :  vA # 'E:Leverancier %1% is geblokkeerd!'
    100010 :  vA # 'E:Klant werd reeds door andere registraties benut!%CR%Nu geen wijziging meer mogelijk!';
    100011 :  vA # 'E:Leverancier werd reeds door andere registraties benut!%CR%Nu geen wijziging meer mogelijk!';

    101000 :  vA # 'E:Ardresnummer reeds verstrekt!';
    101001 :  vA # 'E:Adresnummer moet aangegeven worden!';

    103000 :  vA # 'W:huidig kredietlimiet:%1%%CR%open posten:%2%%CR%geregistreerde orders:%3%';
    103001 :  vA # 'E:Het kredietlimit van de gefactureerden is verstreken!';
    103002 :  vA # 'E:De gefactureerde is volledig geblokkeerd!';

    105000 :  vA # 'E:Verpakkingsnummer reeds verstrekt!';
    105001 :  vA # 'E:Instructie kon niet verwijderd worden!';

    // Projecten
    120000 :  vA # 'E:Met deze interval mag men geen onderhoud maken!';
    120001 :  vA # 'W:Moeten voor ALLE noodzakelijke onderhoudsprojecten orders aangemaakt worden?';
    120002 :  vA # 'I:Er zijn %1% orders succesvol aangemaakt!';
    120003 :  vA # 'E:Automatische orderbijlage bij project %1% mislukt! Code %2%';
    120004 :  vA # 'E:Automatische orderbijlage bij project %1% mislukt!%CR%Geen geldige waarde gevonden!';
    120005 :  vA # 'E:Het project is reeds geheel verwijderd!';
    120006 :  vA # 'E:Positie %1% is nog niet verwijderd!';
    120007 :  vA # 'E:Het project: %1% bestaat niet, of is verwijderd!%CR%Veranderen niet mogelijk';
    120008 :  vA # 'W:Het streefproject bevat stuklijsten.%CR%Toch veranderen?';
    120009 :  vA # 'E:Het oorspronkelijk project kon niet gelezen worden!';
    120010 :  vA # 'E:In het oorsponkelijk project konden niet alle tijden geblokkeerd worden!';
    120011 :  vA # 'E:Fout bij het veranderen van de tijden [lfnNr.:%1%]!';
    120012 :  vA # 'E:Fout bij het lezen van de teksten!%CR%[%1%]';
    120013 :  vA # 'E:Fout bij het opslagen van de teksten!%CR%[%1%]';
    120014 :  vA # 'E:Het oorspronkelijk project kon niet geblokkeerd worden!';
    120015 :  vA # 'E:Het streefproject kon niet opgeslagen worden!';
    120016 :  vA # 'E:Fout bij het opstellen van het meldingsbericht!';

    // Hulpmiddelen
    161000 :  vA # 'E:Geeft u aub geldige sleutelwaarde in!';
    161001 :  vA # 'E:Er bestaat reeds een registratie met deze sleutelwaarden!';

    165000 :  vA # 'E:Oorzaken, maatregelen, reserveonderdelen en IHA-bronnen worden eveneens verwijderd!';
    165001 :  vA # 'E:#Opdracht mislukt!';

    166000 :  vA # 'E:Maatregelen, reserveonderdelen en IHA-bronnen worden eveneens verwijderd!';

    167000 :  vA # 'E:Reserveonderdelen en IHA-bronnen worden eveneens verwijderd!';


    181000 :  vA # 'E:#HuB-artikel %1% niet gevonden';
    181001 :  vA # 'E:#HuB-artikel %1% is geblokkeerd door gebruiker: '+LockedBy;

    182000 :  vA # 'E:#HuB-artikel %1% niet gevonden';
    182001 :  vA # 'E:#HuB-artikel %1% is geblokkeerd door gebruiker: '+LockedBy;

    191000 :  vA # 'E:#HuB-artikel %1% niet gevonden';
    191001 :  vA # 'E:#HuB-artikel %1% is geblokkeerd door gebruiker: '+LockedBy;

    192000 :  vA # 'E:#Bestelhoofd niet gevonden!';

    // Materiaal
    200000 :  vA # 'E:Beperkingen eigen materiaal en aankoopdatum gaan niet samen!';
    200001 :  vA # 'E:Aankoopdatum ligt NA ontvangstdatum!';
    200002 :  vA # 'E:Ontvangstdatum ligt NA begindatum!';
    200003 :  vA # 'E:Verwijderingsmarker en begindatum gaan niet samen!';
    200004 :  vA # 'W:Opgelet!%CR%Deze kaart is afkomstig uit een bestelling/goederenontvangst!%CR%Correcties zouden eigenlijk daar uitgevoerd moeten worden!';
    200005 :  vA # 'E:Enkel besteld materiaal kan de status VSB hebben!';
    200006 :  vA # 'E:Dit materiaal is reeds verwijderd';
    200007 :  vA # 'Q:Wilt U de huidige bestelling verwijderen en het materiaal opnieuw beschikbaar maken?';
    200008 :  vA # 'W:Het materiaal zou daarmee de status "VSB" krijgen!%CR%Wilt U doorgaan?';
    200009 :  vA # 'E:Het materiaal is reeds gereserveerd!';
    200010 :  vA # 'W:Het materiaal zal nu opgesplitst worden!%CR%Doorgaan?'
    200011 :  vA # 'E:Het materiaal is reeds besteld!';
    200012 :  vA # 'Q:Moet dit materiaal als verwijderd aangeduid worden?';
    200013 :  vA # 'Q:Moet dit materiaal gereactiveerd worden? (Status moet manueel ingesteld worden!)';
    200014 :  vA # 'Q:Moeten de AK-prijzen van deze %1% materiaalkaarten op %2% gezet worden?';
    200015 :  vA # 'Q:Materiaal wordt als verwijderd aangeduid.%CR%Zal de materiaalprijs op nul gezet worden en op de volgende kaarten evenredig overgenomen worden?';
    200016 :  vA # 'W:Er zal een NEGATIEF overschot ontstaan!%CR%Doorgaan?'
    200017 :  vA # 'E:De aangeduide kaart %1% heeft een foutieve status en kan niet met anderen gecombineerd worden!';
    200018 :  vA # 'E:De aangeduide kaarten zijn gedeeltelijk eigen en gedeeltelijk vreemd materiaal en kunnen niet gecombineerd worden!';
    200019 :  vA # 'Q:Moeten de %1% kaarten tot één enkele gecombineerd worden?';

    202000 :  vA # 'E:De valutadatum liep buiten de tijd, die bestond in deze kaart!';

    200100 :  vA # 'E:Helaas kan deze kaart niet juist opgesplitst worden.';
    200101 :  vA # 'I:De kaart werd juist ingedeeld.%CR%De nieuwe nummer is %1%.';
    200102 :  vA # 'E:De kaart kon niet juist opgesplitst worden!';
    200103 :  vA # 'Q:Bent U zeker, dat U hieruit een nieuwe kaart wil samenstellen?';
    200104 :  vA # 'I:Er werd succelvol een kopie %1% gemaakt!';
    200105 :  vA # 'E:Kopie kon niet gemaakt worden!'
    200106 :  vA # 'E:Materiaal %1% kon niet veranderd worden!'

    200400 :  vA # 'E:Deze opdracht is ongeldig!';
    200401 :  vA # 'I:Bestelling succesvol uitgevoerd!';
    200402 :  vA # 'I:Bestelling kon niet veranderd worden! (Fout %1%)';

    203001 :  vA # 'Q:Moeten de reserveringen zoals aangegeven opgedeeld worden?';
    203002 :  vA # 'E:Reserveringen konden NIET opgedeeld worden!';
    203003 :  vA # 'I:Reserveringen werden succesvol opgedeeld!';

    204000 :  vA # 'E:De materiaalkaart bevat reeds bewerkingen!';

    // Materiaal-stock
     210000 :  vA # 'Q:!!! OPGELET !!!%CR%Bij een reorganisatie mogen GEEN gebruikers in de materiaalgegevens werken!!!%CR%Moeten de volledig verwijderde materiaal-bomen in de stock verplaatst worden?';
    210001 :  vA # 'I:Materiaal-reorganisatie succesvol uitgevoerd!';
    210002 :  vA # 'E:Materiaal-reorganisatie geannuleerd !!!';
    210010 :  vA # 'E:Materiaal %1% NIET in de stock gevonden!!!!';
    210011 :  vA # 'E:Ophalen mislukt!!!';

    220001 :  vA # 'Q:Mogen enkel overeenkomende registraties getoond worden?';

    // Artikel
    250000 :  vA # 'E:Artikelnummer reeds verstrekt!';
    250001 :  vA # 'E:Itemnummer reeds verstrekt!';
    250002 :  vA # 'E:Catalogusnummer reeds verstrekt!';
    250003 :  vA # 'E:Deze berekening is enkel bij produktie-artikelen mogelijk.'
    250004 :  vA # 'E:Reserveringen kunnen niet veranderd worden!';

    250004 :  vA # 'E:Deze optie is enkel bij produktie-artikelen mogelijk.'
    250006 :  vA # 'E:Deze berekening is bij produktie-artikelen niet mogelijk.'
    250540 :  vA # 'E:Artikel: %1% %CR%Automatische indeling mislukt!';
    250541 :  vA # 'Q:Automatische beschikbaarheidsverloop voor alle artikels starten?';
    250542 :  vA # 'I:Automatische beschikbaarheidsverloop succesvol voltooid!';

    252000 :  vA # 'Q:Lot geblokkeerd door: %1%%CR%Herhalen?';

    253000 :  vA # 'E:#Bewegings-artikel %1% niet gevonden!';
    253001 :  vA # 'E:Serienummerartikel! Aantal mag enkel EEN zijn!';
    253002 :  vA # 'E:Serienummer reeds beschikbaar!';

    // Prijzen voor artikels
    254002 :  va # 'E:Prijsregistratie is geblokkeerd door gebruiker '+lockedby + ', Verwijderen niet mogelijk.';
    254003 :  va # 'E:Prijsregistratie niet beschikbaar, verwijderen niet mogelijk.';

    // Stuklijst
    256001 :  vA # 'E:Dit artikel mag niet ingevoerd worden, daar het tot een vicieuze cirkel-verband leidt!';

    //Klachten
    300000 :  vA # 'I:Niewe klacht aangemaakt: %1%%CR%%2%/%3%';
    300001 :  vA # 'I:Enkel klantenklachten toegestaan!%CR%Bewerking wordt geannuleerd.'
    300002 :  vA # 'E:Materiaalkaart kon niet gevonden worden!%CR%Bewerking wordt geannuleerd.'
    300003 :  vA # 'E:Geen bestelnr. op materiaalkaart %1% !!%CR%Bewerking wordt geannuleerd.'

    // Bestellingen
    400001 :  vA # 'E:Geen berekenbare invoer gevonden!';
    400002 :  vA # '#Actielijst van positie %1% is geblokkeerd door gebruiker: '+LockedBy;
    400003 :  vA # '#Positie %1% is geblokkeerd door gebruiker: '+LockedBy;
    400004 :  vA # 'Q:Factuur %1% zo boeken?';
    400005 :  vA # 'I:Factuur %1% succesvol gemaakt!';
    400006 :  vA # 'W:Enkele toeslagen zijn nog niet aangepast!';
    400007 :  vA # 'E:Enkel aangeduide posities van een offerte kunnen tot een order omgezet worden! ';
    400008 :  vA # 'Q:De %1% gemarkeerde offerteposities naar een nieuw order omzetten?';
    400009 :  vA # 'E:#Algemene fout bij omschakeling van offerte naar order!%CR%Regel %1%';
    400010 :  vA # 'I:Offerte wordt naar order %1% gekopieerd';
    400011 :  vA # 'Q:Zullen voor alle berekenbare orders facturen worden afgedrukt?%CR%(Individuele data van betaling worden overgeslagen)';
    400012 :  vA # 'E:In order %1% is een fout opgetreden!';
    400013 :  vA # 'I:Facturen werden succesvol opgemaakt!';
    400014 :  vA # 'E:Voor dit order bestaat een open afleveringsbewijs (laadopdracht) %1%!%CR%Deze moet eerst geboekt zijn, voordat men verder mag leveren!';
    400015 :  vA # 'Q:Voor dit order bestaat een open afleveringsbewijs (laadopdracht) %1%!%CR%Wil U dit overschrijven (Ja) of een nieuwe afleveringsbewijs maken? (Neen)';
    400016 :  vA # 'Q:Voor dit order bestaat een open afleveringsbewijs (laadopdracht) %1%!%CR%Dit wordt overschreven!%CR%Doorgaan?';
    400017 :  vA # 'W:Het afleveringsbewijs (laadopdracht) %1% werd opnieuw gemaakt!%CR%Aub de oude papieren verwijderen en nieuwe afdrukken!';
    400018 :  vA # 'E:Orderhoofd kon niet veranderd worden!';
    400019 :  vA # 'E:Order heeft reeds bijbehorende bewerkingen!%CR%Geen wijziging van de klantennummer meer mogelijk!';
    400020 :  vA # 'E:Order heeft reeds bijbehorende bewerkingen!%CR%Geen wijziging van de gefactureerden meer mogelijk!';

    400095 :  vA # 'W:OPGELET!%CR%Factuurnummer kon NIET teruggezet worden!!!';
    400096 :  vA # 'I:Factuurnummer werd teruggezet!'
    400097 :  vA # 'E:#FACTUURVERSCHIL!!!%CR%De print-out gaf een bedrag van %1% en de boeking %2%!%CR%UITVOERING GESTOPT!';
    400098 :  vA # 'E:#Control-toets(combinatie) niet gevonden!';
    400099 :  vA # 'E:#Algemene boekingsfout! %CR%Regel %1%';

    401000 :  vA # 'E:Verwijderen MISLUKT! %CR%Code:%1%';
    401001 :  vA # 'E:De productengroep kan achteraf niet van het ene bestandstype in een ander veranderd worden!';
    401002 :  vA # 'W:OPGELET!!!%CR%Dit bestelnummer bestaat reeds!';
    401003 :  vA # 'W:OPGELET!!!%CR%Sommige posities hebben geen datum vastgesteld!%CR%Toch opslaan?';
    401004 :  vA # 'Q:Deze data in alle verdere posities zonder datum registreren?';
    401005 :  vA # 'E:Deze soort van positie kan niet teruggehaald worden!';
    401006 :  vA # 'E:Deze positie kan niet verwijderd worden, daar nog open meer bepaald niet berekende leveringen aanwezig zijn!';
    401007 :  vA # 'Q:Deze positie heeft reeds een geplande produktie!%CR%Toch doorgaan?';
    401008 :  vA # 'Q:Deze positie heeft reeds vast voorbehouden loten!%CR%Toch doorgaan?';
    401009 :  vA # 'Q:Wil U op deze positie %1% het tegoed berekenen?';
    401010 :  vA # 'E:Positie kan niet aangepast worden!';
    401011 :  vA # 'Q:Wil U op deze postie %1% de belasting berekenen?';
    401012 :  vA # 'Q:Wil U het artikel %1% door %2% vervangen?';
    401013 :  vA # 'Q:Wil U de de afmetingen in het order met deze van het artikel overschrijven?';
    401014 :  vA # 'W:Er bestaan nog materiaal-reservaties voor deze positie!%CR%Wil U deze positie EN de reservaties verwijderen?';
    401015 :  vA # 'W:Het materiaal heeft afwijkende afmetingen!%CR%Toch toewijzen?';
    401016 :  vA # 'E:Het materiaal heeft afwijkende afmetingen!%CR%Toewijzing gestopt!';

    401200 :  vA # 'E:Het materiaal behoort niet tot het order vanwege: %1%'
    401201 :  vA # 'Q:Het materiaal werd als "verkocht" aangeduid, maar werd verder in uw voorraad ingevoerd!%CR%Doorgaan?';
    401202 :  vA # 'Q:Het materiaal werd als "verkocht" aangeduid en uit uw voorraad verwijderd!%CR%Doorgaan?';
    401203 :  vA # 'E:Het materiaal kon niet toegewezen worden!%CR%Foutcode %1%';
    401204 :  vA # 'I:Het materiaal werd succesvol aan het order toegewezen en uitgeboekt!';
    401205 :  vA # 'E:Het materiaal kan niet als vreemd materiaal overgenomen worden,%CR%daar de klant geen leveranciersnummer heeft!';
    401206 :  vA # 'I:Het materiaal werd succesvol aan het order toegewezen%CR%en een nieuwe klantenkaart met nummer %1% werd aangemaakt!';

    401250 :  vA # 'Q:Wil U echt %1% dadelijk factureren?%CR%(Voorraad wordt afgeschreven, order wordt berekenbaar)';
    401251 :  vA # 'I:De aangegeven hoeveelheid werd succesvol dadelijk gefactureerd!';
    401252 :  vA # 'E:Dit lot is reeds voorbehouden en kan niet toegewezen worden!';
    401253 :  vA # 'E:Dit lot heeft helaas slechts %1% stuks in voorraad!';
    401254 :  vA # 'I:De aangegeven hoeveelheid van deze partij werd deze bestelling%CR%succevol toegewezen en de opdracht werd aangemaakt!';
    401255 :  vA # 'E:Dit artikel heeft helaas maar %1% %2% beschikbaar!';
    401256 :  vA # 'E:Er mogen slechts positieve hoeveelheden toegewezen worden!';
    401257 :  vA # 'Q:Daarmee wordt dit order uitgeleverd!%CR%Toch doorgaan?';

    401401 :  vA # 'W:#Orderpositie %1%: Kon afroep niet aanmaken/registreren!';
    401403 :  vA # 'E:#Kon de toeslag niet updaten!';
    401404 :  vA # 'E:#De bewerking kon niet aangemaakt worden!';
    401405 :  vA # 'E:#Kon de berekening niet updaten!';
    401408 :  va # 'E:#Kon de detailafroep niet updaten!';
    401409 :  va # 'E:#Kon de stuklijst niet updaten!';
    401410 :  vA # 'E:#Hoeveelheid in toegewezen werkorder kon NIET gecorrigeerd worden!';
    401999 :  vA # 'E:#%1%: Orderpositie niet gevonden!';

    404000 :  vA # 'E:Deze bewerking kan niet opnieuw geactiveerd worden!';
    404001 :  vA # 'E:Deze bewerking kan niet geannuleerd worden!';
    404002 :  vA # 'Q:Moet deze levering ongedaan gemaakt worden en de geleverde goederen opnieuw in de voorraad opnemen?';
    404003 :  vA # 'E:Bewerking kon niet geannuleerd worden!';
    404004 :  vA # 'Q:Moet deze VVL-hoeveelheid ongedaan gemaakt worden en opnieuw vrije voorraad worden?';

    404100 :  vA # 'E:#Bestelde ongeldige ordertype!';
    404101 :  vA # 'E:#Orderpositie %1% is reeds verwijderd!';
    404102 :  vA # 'E:#Orderpositie %1% kon niet geüpdatet worden!';
    404103 :  vA # 'E:#Orderpositie %1%: te verwijderen bewerking is reeds berekend!';
    404104 :  vA # 'E:#Orderpositie %1%: Bewerking kon niet verwijderd worden!';
    404105 :  vA # 'E:#Order %1%: Orderhoofd niet gevonden!';
    404106 :  vA # 'E:#Order %1% kon niet geüpdatet worden!';
    404107 :  vA # 'E:#Orderpostie %1% niet gevonden!';
    404108 :  vA # 'E:#Invoer stuklijsten %1% kon niet geüpdatet worden!';
    404109 :  vA # 'E:#Order %1% heeft geen vrijgegeven betalingsvoorwaarde!';

    404200 :  vA # 'W:Aub past U ook de materiaalkaart %1% overeenkomstig aan!';
    404201 :  vA # 'E:Het overeenkomstige materiaal %1% kon niet in de voorraad ingelezen worden!';
    404202 :  vA # 'E:Het overeenkomstige materiaal %1% is in een aktieve factuur opgenomen!';
    404250 :  vA # 'E:De partij %1% kon niet in de voorraad ingelezen worden!';

    409001 :  vA # 'E:Deze verdeling is niet aanvaardbaar!';
    409002 :  vA # 'E:De %1% verdeling is zo niet in oke!';
    409003 :  vA # 'Q:Moet de hoeveelheid van %1% in het order overgenomen worden?';
    409700 :  vA # 'Q:Wil U alle geplande reservanties VAN DEZE positie tezamen gereedmelden?';
    409701 :  vA # 'I:De reservaties worden zo gereed gemeld en de hoeveelheden scrap verwijderd!';
    409702 :  vA # 'Q:Wil U nu uit de bestellingsstuklijst het artikel %1% produceren?';
    409703 :  vA # 'E:Kon het ingepute artikel %1% niet afboeken!';
    409704 :  vA # 'E:Kon het eindprodukt %1% niet inboeken!';
    409705 :  vA # 'E:PRODUCTIE MISLUKT! %1%';
    409706 :  vA # 'I:%1% wordt volgens rangorde geproduceerd';
    409707 :  vA # 'Q:Wil U alle geplande reservaties VAN ALLE posities gereedmelden?';

    410000 :  vA # 'Q:!!! OPGELET !!!%CR%Voor een reorganisatie mogen GEEN gebruikers in het orderbestand werken!!!%CR%Moeten de als verwijderd aangeduide orders in de file verplaatst worden?';
    410001 :  vA # 'I:Order-reorganisatie succesvol uitgevoerd!';
    410002 :  vA # 'E:Order reorganisatie verbroken !!!';
    410010 :  vA # 'E:Ordernr. %1% NIET in de file gevonden!!!!';
    410011 :  vA # 'E:Ophaling mislukt!!!';

    // Afleveringsbewijs
    440000 :  vA # 'Q:Schrijven afleveringsbewijs verbreken?';
    440001 :  vA # 'E:Het afleveringsbewijs heeft nog steeds posities!';
    440002 :  vA # 'Q:Wil U het afleveringsbewijs opslaan?';
    440003 :  vA # 'Q:Afleveringsbewijs afdrukken & boeken?';
    440004 :  vA # 'Q:Moeten alle bestelde materialen automatisch ingevoerd worden?';

    440100 :  vA # 'E:#Afleveringsbewijs %1% kon niet geblokkeerd gelezen worden!';
    440101 :  vA # 'E:Afleveringsbewijs %1% werd reeds geboekt!';
    440102 :  vA # 'E:#Afleveringsbewijs-hoofd kon niet opgeslagen worden!';
    440103 :  vA # 'E:#Afleveringsbewijs kon NIET geboekt worden! (Code %1%)';
    440104 :  vA # 'E:#Afleveringsbewijs %1% is niet geboekt!';
    440105 :  vA # 'E:Geen toewijzingen tot uitleveren gevonden!';
    440441 :  vA # 'E:#Kon de afleveringsbewijs-positie niet updaten! (Code %1%)';
    440700 :  vA # 'E:De routebeschrijving kon niet gemaakt worden!';
    440996 :  vA # 'I:De afleveringsbewijs-herberekening werd succesvol beëindigd.';
    440998 :  vA # 'I:Afleveringsbewijs succesvol geannuleerd!';
    440999 :  vA # 'I:Afleveringsbewijs succesvol geboekt!';

    441000 :  vA # 'E:Positie %1% kon niet verwijderd worden!';
    441001 :  vA # 'Q:Wil U ALLE gegevens van het bestand %1% met het VVL-materiaal %2% gereedmelden?';
    441002 :  vA # 'E:Het materiaal heeft niet de geschikte status!';
    441003 :  vA # 'W:Het materiaal heeft een andere voorraadplaats!%CR%Toch opslagen?';
    441004 :  vA # 'W:De materialen liggen op verschillende voorraadplaatsen!';
    441005 :  vA # 'E:Afleveringsbewijzen mogen geen AK-VVL-materiaal bevatten!';
    441006 :  vA # 'E:Deze bestelling heeft een afwijkende klant!';
    441007 :  vA # 'E:Het materiaal %1% is helaas voor geen order besteld en mag niet afgeleverd worden!';
    441008 :  vA # 'E:Positie werd NIET onthouden!';

    441100 :  vA # 'E:#Positie %1% is geblokkeerd door '+LockedBy;

    441700 :  vA # 'Q:Moet de hoeveelheid van %1% werkelijk gereedgemeld worden?';
    441701 :  vA # 'E:Fout bij het gereedmelden!';

    // Winsten/omzet
    450000 :  vA # 'Q:Deze winst werkelijk terugboeken?';
    450001 :  vA # 'Q:Deze, reeds aan de Fibo doorgegeven, winst werkelijk terugboeken?';
    450002 :  vA # 'I:Winst werd succesvol teruggeboekt!';
    450003 :  vA # 'E:#Bestellingsaktie %1% geblokkeerd door '+Lockedby;
    450004 :  vA # 'E:#Orderpositie van bewerking %1% niet gevonden!';
    450005 :  vA # 'E:#Orderpositie %1% geblokkeerd door '+Lockedby;
    450006 :  vA # 'E:#Orderhoofd van bewerking %1% niet gevonden!';
    450007 :  vA # 'E:#Orderhoofd %1% geblokkeerd door '+Lockedby;
    450008 :  vA # 'E:#Toeslag %1% van order %2% geblokkeerd door '+Lockedby;

    400099 :  vA # 'E:#Algemene terugboekfout!';
    450100 :  vA # 'E:Factuurdatum %1% ligt voor de afsluitdatum '+CnvAD(Set.Abschlussdatum)+'!';
    450101 :  vA # 'E:Fibo-uitvoer-procedure niet ingesteld!';
    450102 :  vA # 'I:Fibo-uitvoer succesvol afgesloten!%CR%%1% Facturen in bestand "%2%" overzetten!';
    450103 :  vA # 'Q:Alle aangeduide winsten naar de Fibo exporteren?';
    450104 :  vA # 'E:Bestand %1% kon niet beschreven worden!';
    450105 :  vA # 'E:%1% verwacht een verzamelrekening en geen aparte factuur!';

    450200 :  vA # 'E:Een winst kon geen geschikte tegenrekening vaststellen!%CR%Overdracht VERBROKEN!';

    // Open posten
    460001 :  vA # 'Q:Aanmaningen boeken?';

    461001 :  vA # 'Q:Bij deze betaling een passende binnenkomende betaling automatisch aanbrengen?';
    461002 :  vA # 'E:De munteenheden passen niet bij elkaar!';

    // Binnenkomende betaling
    465001 :  vA # 'Q:Wil U het order %1% %2% '+"Set.Hauswährung.Kurz"+' als vooruitbetaling toewijzen?';
    465002 :  vA # 'E:Order bestaat niet!';
    465003 :  vA # 'E:Order is reeds verwijderd!';

    // OP-archief
    470000 :  vA # 'Q:!!! OPGELET !!!%CR%Voor een reorganisatie mogen GEEN gebruikers in de openstaande posten werken!!!%CR%Moeten de als verwijderd aangeduide openstaande posten in het archief verplaatst worden?';
    470001 :  vA # 'I:OP-reorganisatie succesvol uitgevoerd!';
    470002 :  vA # 'E:OP-reorganisatie verbroken !!!';
    470010 :  vA # 'E:Factuur %1% NIET in het archief gevonden!!!!';
    470011 :  vA # 'E:Ophaling mislukt!!!';

    // Bestellingen
    501001 :  vA # 'E:Bestelling kan niet verwijderd worden, da er nog actieve VVL-invoer aanwezig zijn!';
    501002 :  vA # 'E:De leverancier kan niet meer veranderd worden, daar reeds ontvangsten geboekt werden!';
    501003 :  vA # 'I:Aub kiest U de nieuwe leveranciers uit...';

    501200 :  vA # 'E:#Materiaalkaart kon niet aangemaakt/veranderd worden!';
    501250 :  vA # 'E:Artikel-Bestelhoeveelheid kon niet aangemaakt/veranderd worden!';
    501503 :  vA # 'E:#Meerprijs kon niet aangemaakt worden!';
    501505 :  vA # 'E:Berekening kon niet aangemaakt worden!';

    504100 :  vA # 'E:#Bestelpositie %1% heeft ongeldige goederencategorie!';
    504101 :  vA # 'E:#Bestelpositie %1% is reeds verwijderd!';
    504102 :  vA # 'E:#Bestelpositie %1% kon niet geüpdatet worden!';
    504104 :  vA # 'E:#Bestelpositie %1%: Bewerking kon niet verwijderd worden!';
    504105 :  vA # 'E:#Bestelling %1%: Bestelhoofd niet gevonden!';
    504106 :  vA # 'E:#Bestelling %1% kon niet geüpdatet worden!';
    504107 :  vA # 'E:#Bestelpositie %1% niet gevonden!';

    506001 :  vA # 'E:#Invoer kan niet geboekt worden!';
    506002 :  vA # 'E:VVL, ontvangst of verlies moet aangegeven worden!';
    506003 :  vA # 'E:Materiaal %1% kan niet aan deze goederenontvangst toegewezen worden!%CR%Kaart niet gevonden!';
    506004 :  vA # 'E:Materiaal %1% kan niet aan deze goederenontvangst toegewezen worden!%CR%Kaart heeft ongeldige waarde!';
    506005 :  vA # 'Q:Volgende analysewaarden zijn niet geschikt:%CR%%1%Toch boeken?';
    506006 :  vA # 'E:Volgende analysewaarden zijn niet geschikt:%CR%%1%Boeking niet mogelijk!';
    506007 :  vA # 'Q:Moet deze invoer als verlies geboekt worden?%CR%(Nee = enkel verwijderen)';

    506008 :  vA # 'Q:Moet de analyse van deze goederenontvangsten in de aangeduide %1% zinnen gekopieerd worden?';
    506009 :  vA # 'E:Er zijn goederenontvangsten met verschillende %1% aangeduid!';
    506010 :  vA # 'E:De oorspronkelijke en de uiteindelijke goederenontvangst zijn identiek!';
    506011 :  vA # 'E:De analyse kon niet in de %1% record gekopieerd worden!';
    506012 :  vA # 'I:De waarden van het materiaalbestand werden waarschijnlijk manueel veranderd!%CR%Toch goederenontvangst opslagen en daarmee materiaalbestand overschrijven?';

    506555 :  vA # 'E:Aankoopcontrole werd reeds toegewezen!';

    510000 :  vA # 'Q:!!! OPGELET !!!%CR%Voor een reorganisatie mogen GEEN gebruikers in het bestelbestand werken!!!%CR%Moeten de als verwijderd aangeduide bestellingen in het archief verplaatst worden?';
    510001 :  vA # 'I:Bestel-reorganisatie succesvol uitgevoerd!';
    510002 :  vA # 'E:Bestel-reorganisatie verbroken !!!';
    510010 :  vA # 'E:Bestelnummer %1% NIET in het archief gevonden!!!!';
    510011 :  vA # 'E:Ophaling mislukt!!!';

    // Benodigdhedenbestand
    540001 :  vA # 'I:Bestelling %1% succesvol aangemaakt!';
    540002 :  vA # 'W:OPGELET!%CR%De aangeduide zinnen hebben verschillende leveranciers!';
    540003 :  vA # 'E:Geen leverancier in de aangeduide zinnen aangegeven!';
    540004 :  vA # 'I:Aanvraag %1% succesvol aangemaakt!';
    540005 :  vA # 'W:Aub leverancier voor aanvraag uitkiezen...';
    540006 :  vA # 'E:Aub vooraf de gewenste benodigdheden aanduiden.';
    540099 :  vA # 'E:Bestelling kon niet aangemaakt worden!';
    540100 :  vA # 'Q:Alle aangeduide posities naar EEN bestelling bij leverancier %1% omzetten?';

    // AKK
    555001 :  vA # 'Q:Deze toewijzing werkelijk ongedaan maken?';
    555002 :  vA # 'Q:Wil U alle aangeduide invoer (%1%) overnemen?';
    555003 :  vA # 'E:AKK-invoer kon niet toegewezen worden!';
    555004 :  vA # 'I:De som van de aangeduide aankoopcontrole-invoer bedraagt %1%';
    555005 :  vA # 'E:Er moet een factuurpositie tussen 1 en 100 aangebracht worden!';

    // Ontvangen rekeningen
    560001 :  vA # 'E:Leveranciers komen niet overeen!';
    560002 :  vA # 'E:Ongeldige uitgaande betaling opgegeven!';
    560003 :  vA # 'E:Ongeldige binnenkomende rekening opgegeven!';
    560004 :  vA # 'Q:Betalingen en uitgaande betalingen aanmaken?';
    560005 :  vA # 'I:Gegevens worden aangemaakt!';
    560006 :  vA # 'I:De som van de aangeduide binnenkomende rekeningen bedraagt %1%';
    560007 :  vA # 'E:Er mogen geen betalingen toegewezen zijn!';
    560008 :  vA # 'E:De binnenkomende rekening %1% is niet "in orde" en mag niet betaald worden!';
    560009 :  vA # 'Q:Moet de binnenkomende rekening %1% opnieuw op "ongecontroleerd" gezet worden?';
    560010 :  vA # 'W:Opgelet!%CR% het overgeboekt bedrag komt niet overeen met de brutowaarde!';
    560011 :  vA # 'E:Deze kosten konden niet op het materiaal overgenomen worden!';

    561001 :  vA # 'E:Deze betaling werd reeds verricht!';
    561002 :  vA # 'Q:Bij deze betaling een passende uitgaande betaling automatisch aanbrengen?';

    // Uitgaande betaling
    565001 :  vA # 'Q:Wil U voor alle aangeduide betalingen cheques uitprinten?';
    565002 :  vA # 'W:Enkele aangeduide betalingen zijn reeds als "betaald" gekenmerkt!%CR%Toch doorgaan?';
    565003 :  vA # 'Q:Moet de uitprint van de cheque in de betalingen verboekt worden?';

    // Verzamelde goederenbinnenkomsten
    621001 :  vA # 'E:Bericht, ontvangst of verlies moet opgegeven worden!';
    621002 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelesen werden. Position kann nicht gelöscht werden.';
    621003 :  vA # 'E:Das Material zu diesem Einsatz enthält bereits Aktionen. Position kann nicht gelöscht werden.';
    621004 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelöscht werden. Position kann nicht gelöscht werden.';
    621005 :  vA # 'E:Die Position konnte nicht gelöscht werden.';


    // Verzending
    650000 :  vA # 'Q:Is de verzending zo compleet en moeten daaruit nu transportopdrachten aangemaakt worden?';
    650001 :  vA # 'E:Verzending kon niet geboekt worden!';

    // Verzendingsdepot
    655000 :  vA # 'E:De verzending kon niet opgedragen worden!';
    655001 :  vA # 'E:Er kon geen verzendingsdepotnummer vastgesteld worden!';
    655101 :  vA # 'E:Adres %1% niet gevonden!';
    655200 :  vA # 'E:Materiaal %1% niet gevonden!';
    655201 :  vA # 'E:Materiaal %1% is reeds in het verzendingsdepot!';
    655202 :  vA # 'E:Materiaal %1% stemt niet overeen met de voorwaarden voor een verzending!';
    655400 :  vA # 'E:Opdracht %1% niet gevonden!';
  end;

  case aNr of
    // GWO  :
    700001 :  vA # 'Q:Moet het volledige WO met de geplande hoeveelheden gereedgemeld worden?';
    700002 :  vA # 'E:Werkorder %1% niet gevonden!';
    700003 :  vA # 'E:Werkorder-positie %1% niet gevonden!';
    700004 :  vA # 'Q:Moeten alle posities van deze werkorders automatisch %1% ingepland worden?';
    700005 :  vA # 'I:Succesvolle automatische planing!';
    700006 :  vA # 'E:Positie %1% kon niet op schema ingepland worden!%CR%Planning verbroken!';

    701001 :  vA # 'E:Voorgaande niet gevonden!';
    701002 :  vA # 'E:Voorgaande werd reeds verder verwerkt!';
    701003 :  vA # 'E:Input materiaal kan niet veranderd worden!';
    701004 :  vA # 'E:Hiermee wordt een circulatie ontwikkeld!';
    701005 :  vA # 'E:Het vermelde materiaal kon niet als input materiaal geboekt worden!';
    701006 :  vA # 'E:Het input materiaal kon niet opnieuw "vrij" gemaakt worden!';
    701007 :  vA # 'E:Het materiaal kan niet meer als input verwijderd worden, daar er reeds gereedmeldingen zijn!';
    701008 :  vA # 'E:Deze input omvat geen concreet materiaal!';
    701009 :  vA # 'E:Deze toepassing is niet langer te boeken!';
    701010 :  vA # 'E:Berekening van de toepassing mislukt!!!';
    701011 :  vA # 'Q:Dit is VVL-materiaal - eigenlijke input materiaal nu registreren?';
    701012 :  vA # 'E:Het VVL-materiaal kon niet gelezen worden!';
    701013 :  vA # 'E:De bestelling voor dit VVL-materiaal kon niet gelezen worden!';
    701014 :  vA # 'E:Bij transportopdrachten moet de gehele hoeveelheid ingeput worden, daar geen hoofd kan gevormd worden!%CR%(event. voordien een manuele opsplitsing uitvoeren)';
    701015 :  vA # 'Q:Deze productie is eigenlijk reeds gedaan - toch daarop verder gereed melden?';
    701016 :  vA # 'Q:Deze input heeft slechts %1%. Toch daarop gereed melden?';

    701017 :  vA # 'E:Input werkorder kon niet ingevoerd worden!';
    701018 :  vA # 'E:Toepassing werkorder kon niet actueel gemaakt worden!';
    701019 :  vA # 'E:VVL materiaal %1% kon niet vrijgegeven worden!';
    701020 :  vA # 'E:VVL materiaal %1% kon niet ingevoerd worden!';
    701021 :  vA # 'E:Het materiaal %1% kon niet als input materiaal geboekt worden!';
    701022 :  vA # 'E:Input werkorder kon niet veranderd worden (ID: %1%)!';

    701023 :  vA # 'Q:Daarvan werd reeds een deel gereedgemeld.%CR%Bent U zeker, dat U verder wil gereedmelden?';

    702001 :  vA # 'E:Positie is reeds afgesloten!';
    702002 :  vA # 'E:Positie kan niet verwijderd worden, daar er reeds gereedmeldingen zijn!';
    702003 :  vA # 'E:Positie kan niet verwijderd worden, daar er nog productie is!';
    702004 :  vA # 'E:Kon de struktuur niet juist boeken!';
    702005 :  vA # 'Q:Moeten alle toepassingen van deze werkfase automatisch in een VVL-werkfase geregistreerd worden?';
    702006 :  vA # 'I:Automatische VVLs succesvol gemaakt!'
    702007 :  vA # 'E:Automatische VVLs konden NIET aangemaakt worden!!!'
    702008 :  vA # 'E:Deze positie kan niet gereedgemeld worden!';
    702009 :  vA # 'E:Deze positie is reeds verwijderd meer bep. Gereed gemeld!';
    702010 :  vA # 'Q:Door het afsluiten werd in totaal %1% schroot geproduceer!%CR%Positie werkelijk afsluiten?';
    702011 :  vA # 'I:Positie werd succesvol afgesloten!';
    702012 :  vA # 'E:FOUT: Positie kon NIET afgesloten worden! (Code %1%)';
    702013 :  vA # 'E:Positie kan niet verwijderd worden, daar er nog input is!';
    702014 :  vA # 'E:Aub transportopdrachten voor het afleveringsbewijs gereedmelden!';
    702015 :  vA # 'Q:Minstens één positie werd door een andere user in een detailplanning opgenomen!%CR%Moeten toch uw gegevens opgeslagen worden?';
    702016 :  vA # 'Q:Wil U deze detailplanning opslagen voor het afsluiten?';
    702017 :  vA # 'Q:Moeten alle toepassingen VAN ALLE werkstadia automatisch in een VVL-werdfase ingebracht worden?';
    702018 :  vA # 'Q:Er ontbreken eigenlijk nog %1%!%CR%Positie werkelijk afsluiten?';
    702019 :  vA # 'E:Aub kiest U allereerst een werkfase op de rechterkant uit!';
    702020 :  vA # 'E:Werkfase %1% kon niet gelezen en geblokkeerd worden!';
    702021 :  vA # 'E:De verzendingsmodule is niet actief!';
    702022 :  vA # 'Q:Moet de werkfase %1% met de theoretische toepassingswaarden gereed gemeld worden?';
    702023 :  vA # 'Q:Wenst U etiketten?';
    702024 :  vA # 'E:Minstens één voorgaande van deze werkfase is nog niet gereed gemeld!';
    702025 :  vA # 'E:Fout bij de kostenbestemming!%CR%Het werkorder werd niet afgesloten.';
    702026 :  vA # 'E:Fout bij de kostenbestemming!%CR%Voor geplande schrootproducties is minstens één productie-kostendrager nodig!%CR%Het werkorder werd niet afgesloten.';
    702027 :  vA # 'E:Fout bij de kostenbestemming!%CR%Voor de ontstane kosten is er geen kostendrager!%CR%Het werkorder werd niet afgesloten.';

    702440 :  vA # 'E:FOUT: Afleveringsbewijs kon NIET geboekt worden!';
    702441 :  vA # 'E:FOUT: Afleveringsbewijs %1% kon NIET gevonden worden!';
    702442 :  vA # 'E:FOUT: Afleveringsbewijspositie %1% kon niet verwijderd worden!';

    703001 :  vA # 'E:Voor de %1%. Productie geeft reeds gereedmeldingen!%CR%Daarom kan ze niet meer verwijderd worden!';
    703002 :  vA # 'E:Deze productie wordt voortgezet en kan niet verwijderd worden!';
    703003 :  vA # 'I:De bestaande productie werd succesvol aangepast en een nieuwe aangemaakt!';
    703004 :  vA # 'E:Deze indeling kon niet uitgevoerd worden!';

    707001 :  vA # 'I:Gereedmelding werd zoals voorgeschreven aangemaakt en geboekt';
    707002 :  vA # 'E:De gereedmelding kon NIET geboekt worden! (Code %1%)';
    707003 :  vA # 'I:Gereedmelding werd succesvol geannuleerd!';
    707004 :  vA # 'E:Gereedmelding kon NIET verwijderd worden!';
    707005 :  vA # 'I:Bij nettowegingen mag het brutogewicht niet stroken met het nettogewicht en mag niet NUL zijn!';
    707006 :  vA # 'E:Aub de gemeten waarden controleren!';
    707007 :  vA # 'E:Fout bij etikettendruk!%CR%Productie kon niet gelezen worden!';
    707008 :  vA # 'E:Fout bij etikettendruk!%CR%Verpakking kon niet gelezen worden!';
    707009 :  vA # 'E:Fout bij etikettendruk!%CR%Etikettendefinitie %1% kon niet gelezen worden!';
    707010 :  vA # 'Q:Wil U alle algemene reserveringen (bv. van order)%CR%van het input materiaal overnemen?';
    707011 :  vA # 'E:De bijbehorende verzendingsopdracht %1% kon niet geboekt worden!';

    707100 :  vA # 'E:Materiaal %1% heeft reeds verdere akties en kan niet geannuleerd worden!';
    707101 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%Oorspronkelijk materiaal %1% kon niet gelezen worden!';
    707102 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%Invoer werkingslijst van het oorspronkelijk materiaal %1% kon niet gemaakt worden!';
    707103 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%Eindmateriaal kon niet aangemaakt worden!';
    707104 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%De reservering van het eindmateriaal %1% kon niet aangemaakt worden!';
    707105 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%De theoretische toepassingsgegevens konden niet geactualiseerd worden!';
    707106 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%De reservering kon niet gemaakt worden!!';
    707107 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%De eindhoeveelheid kon niet geactualiseerd worden!';
    707108 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%De identificatie eindmateriaal kon niet geactualiseerd worden!';
    707109 :  vA # 'E:Fout bij de constructie van het eindmateriaal!%CR%Het afleveringsbewijs voor de transportopdracht %1% kon niet geactualiseerd worden!';

    708001 :  vA # 'E:De hoeveelheid van de terbeschikkingstelling moet positief zijn!';

//---
    800001 :  vA # 'E:#Gebruiker kon niet geblokkeerd worden!'
    800002 :  vA # 'E:#Gebruiker kon niet opgeslagen worden!'
    800003 :  va # 'E:#Bevoegdheid voor [ %1% ] niet toereikend.'
    800004 :  va # 'E:Gebruiker [%1%] niet beschikbaar.'
    801001 :  vA # 'E:#Gebruikersgroep kon niet geblokkeerd worden!'
    801002 :  vA # 'E:#Gebruikersgroep kon niet opgeslagen worden!'

    802001 :  vA # 'E:#Opdracht bestaat reeds!'
    802002 :  vA # 'Q:Opdracht ongedaan maken?'

    814000 :  vA # 'E:Valuta %1% niet gevonden!';
    814001 :  vA # 'E:#Valutanr. %1%: Omrekeningskoers is NUL!';

    816001 :  vA # 'E:Tijden korting voor contant mogen elkaar niet overlappen!';
    816002 :  vA # 'E:Tijd korting voor contant is ongeldig, maandoverlappingen zijn niet mogelijk.';

    828001 :  va # 'E:De werkfase [ %1% ] is in de voorkeursgegevens niet beschikbaar.'

    831000 :  va # 'E:De werkfase [ %1% ] is reeds beschikbaar.'

    842000 :  vA # 'Q:Wil U de meerprijs automatisch toewijzen?';

    844000 :  vA # 'Q:Er bestaat reeds een inventarisatiebestand van %1%. %CR%Moet deze weggegooid worden? ';
    844001 :  vA # 'I:Het inventarisatiebestand werd succesvol ingelezen.';
    844002 :  vA # 'E:Het inventarisatiebestand kon niet ingelezen worden!';
    844003 :  vA # 'E:De naam van de voorrraadplaats is te lang. Voor een inventarisatie mag deze maximaal 15 plaatsen lang zijn!';
    844004 :  vA # 'E:Het oude inventarisatiebestand kon niet verwijderd worden!';
    844005 :  vA # 'Q:Moeten de inventarisatiegegevens voor de gemarkeerde voorraadplaatsen overgenomen worden?';
    844006 :  vA # 'I:Inventarisatie succesvol geboekt.';
    844007 :  vA # 'E:Fout bij het boeken van de inventarisatie!';
    844008 :  vA # 'I:Aub scant U de te controleren voorraadplaats in, aktiveer op de scanner de zendmodus en klikt U op OK.';
    844009 :  vA # 'E:Fout bij de scannerverbinding!%CR%Aub controleert U de verbinding en of de scanner in zendmodus is.';
    844010 :  vA # 'E:Fout bij het inlezen van de gescande gegevens!';
    844011 :  vA # 'E:De uitgekozen voorraadplaats komt niet overeen met de gescande voorraadplaats overeen!';

    844012 :  vA # 'I:Aub scant U de verplaatsing in, aktiveer op de scanner de zendmodus en klikt U op OK.';
    844013 :  vA # 'I:Omboeking succesvol ingelezen.';
    844014 :  vA # 'E:Niet alle omboekingen konden succesvol opgeslagen worden!%CR%De scannergegevens werden niet verwijderd om de fout te begrijpen.';
    844015 :  vA # 'E:Het scannerbestand bevat structurele fouten!';
    844016 :  vA # 'E:Materiaal (%1%) kon niet gelezen worden!';
    844017 :  vA # 'E:Voorraadplaats (%1%) kon niet gelezen worden!';
    844018 :  vA # 'I:De oude invetarisatiegegevens werden succesvol verwijderd.';
    844019 :  vA # 'I:Aub scant U de voorraadplaats, aktiveer op de scanner de zendmodus en klikt U op OK.';
    844020 :  vA # 'Q:Moeten de volledig inventarisatiegegevens overgenomen worden?';

    890000 :  vA # 'E:U heeft helaas geen bevoegdheid deze online-statistiek op te roepen!';
    890001 :  vA # 'Q:Moet de volledige statistiek opnieuw berekend worden?';

    899001 :  vA # 'Q:Bent U zeker, dat U de volledige statistiek opnieuw uitrekenen wil?';

    902001 :  vA # 'E:%1%-getallenreeks geblokkeerd door: %2%%CR%herhalen?';
    902002 :  vA # 'E:#%1%-getallenreeks kon niet verhoogt worden!!!';
    902003 :  vA # 'E:#%1%-getallenreeks kon NIET gelezen worden!!!%CR%!!! CANCEL !!!';
    903000 :  va # 'E:In den Settings fehlt die Angabe für [ %1% ]';

    910001 :  vA # 'E:Lijst nummer %1% niet gevonden!';
    910002 :  vA # 'Q:De lijst als XML-bestand omzetten? (anders afdruk)';
    910003 :  vA # 'I:XML-bestand %1% werd succesvol gemaakt!';
    910004 :  vA # 'E:XML-bestand %1% kon niet gemaakt worden!';
    910005 :  vA # 'E:XML-bestand %1% kon niet gemaakt worden! Afdruk werd aangestipt.';

    911001 :  vA # 'E:Geen bevoegdheid voor output lijst!';
    911002 :  vA # 'E:Opdracht bestaat reeds!';
    911003 :  vA # 'E:Opdracht beëindigen?';

    912001 :  va # 'Q:Moet het reeds gedrukte dokument aangegeven worden?';
    912002 :  va # 'E:#Formulier %1% niet gevonden!';
    912003 :  vA # 'Q:Moet het fax-logo mee uitgeprint worden?';
    912004 :  vA # 'Q:Moet het email-logo mee uitgeprint worden?';
    912005 :  vA # 'E:U heeft geen schrijfbevoegdheid in de printmap : '+Set.Druckerpfad;
    912006 :  vA # 'Q:Moet het print-logo mee uitgeprint worden?';

    915001 :  vA # 'E:#Documenttype onbekend: %1%';
    915002 :  vA # 'E:DMS-systeem: %1%';

    921000 :  vA # 'E:Speciale functie kon niet correct uitgevoerd worden!';
    921001 :  vA # 'I:Uitvoering van de speciale functie beëindigd.';

    990001 :  vA # 'E:#Protocolbuffer opgelegd!';
    990002 :  vA # 'E:#Protocolbuffer leeg! (forget)';
    990003 :  vA # 'E:#Protocolbuffer leeg! (compare)';
    990010 :  vA # 'E:#Protocolzin kon niet aangemaakt worden!';

    997000 :  vA # 'E:Getraande coils kunnen niet berekend worden.';

    997001 :  vA # 'W:Aub kiest U dat voor het te wijzigen veld uit...';
    997002 :  vA # 'Q:Bent U zeker, dat U in de %1% aangeduide zinnen het veld "%2%" met "%3%" wil overschrijven?';
    997003 :  vA # 'I:De aangeduide zinnen werden succesvol veranderd!';
    997004 :  vA # 'E:Niet alle aangeduide zinnen konden veranderd worden!!!%CR%ALLES werd ongedaan gemaakt!';
    997005 :  vA # 'Q:Moeten de aanduidingen ongedaan gemaakt worden?';
    997006 :  vA # 'I:U heeft geen geschikte gegevenszin aangeduid!';

    998000 :  vA # 'Q:Lijstengeneratie duurt ongewoon lang%CR%Lijst afbreken?';
    998001 :  vA # 'I:TELEFOON!!!%CR%Interne oproep van toestel %1%';
    998002 :  vA # 'I:TELEFOON!!!%CR%Oproep van %1%';
    998003 :  vA # 'Q:Wil U ALLE gegevens van deze tabel naar %1% exporteren?';
    998004 :  vA # 'I:Bestand %1% geschreven!%CR%Aantal zinnen: %2%';
    998005 :  vA # 'Q:Wil U ALLE gegevens van het bestand %1% inlezen?';
    998006 :  vA # 'I:Bestand %1% ingelezen!%CR%Aantal zinnen: %2%';
    998007 :  vA # 'E:De visualiseringstool GRAPHVIZ schijnt niet geïnstalleerd te zijn!';
    998008 :  vA # 'E:Daarvoor moeten alle andere gebruikers de gegevensbank verlaten!';
    998009 :  vA # 'W:Alvorens een diagnose is het NOODZAKELIJK EEN BACK-UP manueel aan te maken!!!%CR%Diagnose nu starten?';
    998010 :  vA # 'W:Alvorens een optimalisatie is het NOODZAKELIJK EEN BACK-UP manueel aan te maken!!!%CR%Optimalisatie nu starten?';
    998011 :  vA # 'Hoofdreorganisatie nu starten?';
    998012 :  vA # 'Q:Wil U enkel de GEMARKEERDE gegevens van deze tabel naar %1% exporteren?';
    998013 :  vA # 'Q:Wil U de markeringen ongedaan maken?';

    999001 :  vA # 'E:Programma-licentie niet gevonden!';
    999002 :  vA # 'E:Programma-licentie niet correct!';
    999003 :  vA # 'E:Programma-licentie niet geschikt voor dit product!';
    999004 :  vA # 'E:Programma-licentie past niet bij de gegevensbank-licenties!';
    999005 :  vA # 'E:Programma-licentie is afgelopen!';
    999010 :  vA # 'E:Gebruikersaantal voor deze programma-licentie te hoog!';
    999011 :  vA # 'E:Job-server-aantal voor deze programma-licentie te hoog!';
    999012 :  vA # 'E:In werking-gebruikersaantal voor deze programma-licentie te hoog!';

    999050 :  vA # 'Q:Wil U een nieuw/ander programma-licentie installeren?';
    999051 :  vA # 'I:Programma-licentie opgenomen - Aub herstarten!';
    999998 :  vA # 'I:Succesvol!';
    999999 :  vA # 'E:!!! ALGEMENE FOUTEN !!!%CR%%1%';

    otherwise if (vA='') then vA # Lib_Messages:Fehlertext( aNr );
  end;

  RETURN vA;
end;


//========================================================================
//========================================================================
Sub ParseMsg(
  aNr           : int;
  aPara         : alpha(1000);
  var aSymbols  : int;
  var aButtons  : int;
) : alpha
local begin
  vA,vB   : alpha(500);
  vA1     : alpha(4000);
  vA2     : alpha(4000);
  vA3     : alpha(4000);
  vA4     : alpha(4000);
  vA5     : alpha(4000);
  vX      : int;
end;
begin
  vB # gUserSprache;
  if (vB='D') or (vB='') then
    vA # Lib_messages:Fehlertext(aNr)
  else
    vA # Call('Lib_Messages_'+vB+':Fehlertext', aNr);

  // Testzwecke
//  vA # vA +StrChar(13)+'Debugcode: '+cnvai(aNr);

  // Symbol ermitteln
  if (StrCut(vA,2,1)=':') then begin
    case StrCut(vA,1,2) of
      'Q:' : begin
        aSymbols # _WinIcoQuestion;
        if (aButtons=0) then aButtons # _WinDialogYesNo;
        end;
      'E:' : aSymbols # _WinIcoError;
      'W:' : aSymbols # _WinIcoWarning;
      'I:' : aSymbols # _WinIcoInformation;
      'A:' : aSymbols # _WinIcoApplication;
    end;
    vA # StrCut(vA,3,999);
  end;

  vA1 # Str_Token(aPara,'|',1);
  vA2 # Str_Token(aPara,'|',2);
  vA3 # Str_Token(aPara,'|',3);
  vA4 # Str_Token(aPara,'|',4);
  vA5 # Str_Token(aPara,'|',5);

  vX # strfind(vA,'%1%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA1+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%2%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA2+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%3%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA3+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%4%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA4+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%5%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA5+StrCut(vA,vX+3,999);

  // alle _CR_zu CR umwanden
  REPEAT
    vX # strfind(vA,'%CR%',0);
    if vX<>0 then
      vA # StrCut(vA,1,vX-1)+StrChar(13)+StrCut(vA,vX+4,999);
  UNTIL (vX=0);
  
  RETURN vA;
end;


//========================================================================
//  Msg
//      Gibt eine Meldung aus
//      Sonderzeichen
//      '%x%': X=1,2,3,4,5 = Platzhalter für Token
//      '%CR$': Carriage Return
//      Start 'Q:' = _WinIcoQuestion;
//      Start 'E:' = _WinIcoError;
//      Start 'W:' = _WinIcoWarning;
//      Start 'I:' = _WinIcoInformation;
//      Start 'A:' = _WinIcoApplication;
//      1.Zeichen '#' = Fehler wird protokolliert
//
//
//========================================================================
sub Messages_Msg(
  aNr         : int;
  aPara       : alpha(1000);
  aSymbols    : int;
  aButtons    : int;
  aPreselect  : int;
  opt aProc   : alpha;
) : int
local begin
  vA,vB   : alpha(500);
  vText   : alpha(300);
  vOldF   : int;
  vButton : int;
  vFile   : int;
  vOK     : logic;
  vTitle  : alpha(500);
  vIsJobServer  : logic;
end;
begin

//RETURN Lib_Messages_NL:Messages_Msg(aNr, aPara, aSymbols, aButtons, aPreselect, aProc);

/*
  if (VarInfo(varSysPublic)<>0) then begin
    if (ErrMsg<>0) then begin
      vX # ErrMsg;
      ErrMsg # 0;
      Messages_Msg(vX,'',0,0,0);
    end;
  end;
*/

// mögliche Symbole, Buttons, Ergebnisse:
//
// _WinIcoApplication, _WinIcoError,_WinIcoInformation,
// _WinIcoWarning,_WinIcoQuestion
//
// _WinDialogOk, _WinDialogOkCancel, _WinDialogYesNo,
// _WinDialogYesNoCancel
//
//
// ERGEBNIS:
// _WinIdOk, _WinIdCancel, _WinIdYes, _WinIdNo

//  vA # FehlerText(aNr);
/***
  case (gUserSprachnummer) of
    1 : vB # Set.Sprache1.Kurz;
    2 : vB # Set.Sprache2.Kurz;
    3 : vB # Set.Sprache3.Kurz;
    4 : vB # Set.Sprache4.Kurz;
    5 : vB # Set.Sprache5.Kurz;
  //  2 : vA # Lib_messages_NL:Fehlertext(aNr);
  //  2 : vA # Lib_messages_E:Fehlertext(aNr);
  //  otherwise
  //    vA # Lib_messages:Fehlertext(aNr)
  end;
***/
/****
  vB # gUserSprache;
  if (vB='D') or (vB='') then
    vA # Lib_messages:Fehlertext(aNr)
  else
    vA # Call('Lib_Messages_'+vB+':Fehlertext', aNr);

  // Testzwecke
//  vA # vA +StrChar(13)+'Debugcode: '+cnvai(aNr);

  // Symbol ermitteln
  if (StrCut(vA,2,1)=':') then begin
    case StrCut(vA,1,2) of
      'Q:' : begin
        aSymbols # _WinIcoQuestion;
        if (aButtons=0) then aButtons # _WinDialogYesNo;
        end;
      'E:' : aSymbols # _WinIcoError;
      'W:' : aSymbols # _WinIcoWarning;
      'I:' : aSymbols # _WinIcoInformation;
      'A:' : aSymbols # _WinIcoApplication;
    end;
    vA # StrCut(vA,3,999);
  end;

  vA1 # Str_Token(aPara,'|',1);
//  aPara # Str_Token(aPara,'|',2);
  vA2 # Str_Token(aPara,'|',2);
//  aPara # Str_Token(aPara,'|',2);
  vA3 # Str_Token(aPara,'|',3);
//  aPara # Str_Token(aPara,'|',2);
  vA4 # Str_Token(aPara,'|',4);
//  aPara # Str_Token(aPara,'|',2);
  vA5 # Str_Token(aPara,'|',5);
//  aPara # Str_Token(aPara,'|',2);

  vX # strfind(vA,'%1%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA1+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%2%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA2+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%3%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA3+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%4%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA4+StrCut(vA,vX+3,999);
  vX # strfind(vA,'%5%',0);
  if vX<>0 then
    vA # StrCut(vA,1,vX-1)+vA5+StrCut(vA,vX+3,999);

  // ggf. Protokolldatei mitschreiben
  if (StrCut(vA,1,1)='#') then begin
    vA # StrCut(vA,2,250);
    vText # CnvAD(Today)+':'+CnvAT(Now)+'|'+cnvAI(aNr)+'|'+vA+'|'+gUserName;
    vText # vText + strchar(13) + strchar(10);
    vFile # FSIOpen(cProtokollDatei,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      FsiWrite(vFile, vText);
      FsiClose(vFile);
    end;
  end;

  // alle _CR_zu CR umwanden
  REPEAT
    vX # strfind(vA,'%CR%',0);
    if vX<>0 then
      vA # StrCut(vA,1,vX-1)+StrChar(13)+StrCut(vA,vX+4,999);
  UNTIL (vX=0);
***/

  // 30.05.2018 AH : als SUB
  vA # ParseMsg(aNr, aPara, var aSymbols, var aButtons);
  
  // ggf. Protokolldatei mitschreiben
  if (StrCut(vA,1,1)='#') then begin
    vA # StrCut(vA,2,250);
    vText # CnvAD(Today)+':'+CnvAT(Now)+'|'+cnvAI(aNr)+'|'+vA+'|'+gUserName;
    vText # vText + strchar(13) + strchar(10);
    vFile # FSIOpen(cProtokollDatei,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      FsiWrite(vFile, vText);
      FsiClose(vFile);
    end;
  end;

  if (TransActive) then vA # '!!! TRANSACTION OPEN !!! '+StrChar(13)+vA;

  // ST 2018-04-17: Bei Jobserver oder SOA, dann "simple" in Errormeldung umwandeln
  vIsJobServer  # (gUsergroup = 'SOA_SERVER') OR (gUsergroup = 'JOB-SERVER');
  if (vIsJobServer) then begin
    ERROR(99,vA);
    RETURN _WinIdCancel;    // Klappt, wenn die Abfragen Positive Angaben abfragen
  end;
  

  if (VarInfo(windowbonus)<>0) then
    vTitle # gTitle
  else
    vTitle # cPrgName;
  if (aSymbols=_WinIcoError) then begin
    vTitle # vTitle + '('+cnvai(aNr)+')';
    if (aProc<>'') then vA # vA + ' (P:'+aProc+')';
  end;

  vOldF # WinFocusGet();


  // Falls es eine TRAY ist...
  if (gFrmMain<>0) then begin
    if (Wininfo(gFrmMain,_wintype)=_WinTypeTrayFrame) then begin
      vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
      RETURN vButton;
    end;
    // auf jeden Fall Anwendung aktivieren....
    APPON();
  end;


  if (gMdi<>0) then begin
    TRY begin
      Winpropget(gMDI,_Winpropname,vB);
    END
    if (errGet()=_rOK) then begin
      vOK # y;
//      gMDI->wpdisabled # y;
      if (VarInfo(windowbonus)<>0) then
//        vButton # WindialogBox(gFrmMain,vTitle,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect)
        vButton # WindialogBox(gMDI,vTitle,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect)
      else
//        vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
        vButton # WindialogBox(gMDI,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
//      gMDI->wpdisabled # n;
    end;
  end;
  if (vOK=n) then begin
    vButton # WindialogBox(gFrmMain,cPrgName,vA,aSymbols,aButtons|_WinDialogAlwaysOnTop,aPreselect);
  end;

  if (vOldF<>0) then begin
    Try begin
      ErrTryIgnore(_ErrHdlInvalid);
//      vOldf # vOldf + 123;
      vOldF->WinFocusSet();
    end;
  end;
  RETURN vButton;

end;

/***
//========================================================================
//  MsgBox
//          Gibt eine Meldung aus
//========================================================================
sub Error_MsgBox(
  aWindow   : int;
  aTitle    : alpha;
  aText     : alpha;
  aSymbols  : int;
  aButtons  : int;
  aPreselect : int;
): int
local begin
  vX,vY : int;
end;
begin
  vY # WinFocusGet();
  vX # WinDialogBox(aWindow,aTitle,aText,aSymbols,aButtons,aPreselect);
  if (vY<>0) then vY->WinFocusSet();
  RETURN vX;
end;
***/

//========================================================================