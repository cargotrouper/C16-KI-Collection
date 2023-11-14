@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Messages_E
//                  OHNE E_R_G
//  Info
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

  case aNr of

    // allgemeine Fragen
    000001 :  vA # 'Q:Are you sure that you want delete this entry?';
    000002 :  vA # 'Q:Discard input?';
    000003 :  vA # 'Q:Discard changes?';
    000004 :  vA # 'Q:Abort the complete acquisition?';
    000005 :  vA # 'Q:Collect more positions?';
    000006 :  vA # 'Q:Transfer field contents from last position?';
    000007 :  vA # 'Q:Retrieve this Entry?';
    000008 :  vA # 'Q:Are your sure you want to toggle the deletion-marker?';
    000009 :  vA # 'Q:Wollen Sie diese Daten für einen weiteren neue Eintrag nutzen?';
    000099 :  vA # '%1%';

    // Fehler beim Benutzerpasswortwechsel
    000010 :  vA # 'E:The passwords didn´t match!';
    000011 :  vA # 'E:The old password is not correct!';
    000012 :  vA # 'I:Your password successfully changed!';

    // allgemeine Fehler
    001001 :  vA # 'E:#%1%:Record is blocked by user: '+LockedBy;
    001002 :  vA # 'E:#%1%:No explicit access available!';
    001003 :  vA # 'E:#%1%:Record not found!';
    001004 :  vA # 'E:#%1%:No more data records available!';
    001005 :  vA # 'E:#%1%:File is empty/no more records available!';
    001006 :  vA # 'E:#%1%:Record already exists!';
    001007 :  vA # 'E:#%1%:Record is not locked!';
    001008 :  vA # 'E:#%1%:Abort by user!';
    001010 :  vA # 'E:#%1%:Record is DEADLOCKED!!!';

    001100 :  vA # 'E:#Transaction Error: DOUBLESTART!';
    001101 :  vA # 'E:#Transaction Error: Nothing to close!';
    001102 :  vA # 'E:#Transaction Error: Nothing to cancel!';
    001103 :  vA # 'E:#Transaction Error: Open transaction when program finished!!!%CR%Last changes were NOT safed!!!%CR%PLEASE IMMEDIATELY CONTACT THE MANUFACTURER!';

    001200 :  vA # 'E:%1% must be indicated!';
    001201 :  vA # 'E:%1% missing!';
    001202 :  vA # 'E:No %1% selected!';
    001203 :  vA # 'E:%1% out of range';
    001204 :  vA # 'E:A record with this values already exists!';

    001300 :  vA # 'E:External File %1% not found!';

    001400 :  vA # 'E:%1% %2% is ahead of the end of date '+CnvAD(Set.Abschlussdatum)+'!';

    001999 :  vA # 'E:#PROCEDURE IS MISSING: %1%';

    // Dateispezifische Fehlermeldungen ********************************

    // Adressen
    100000 :  vA # 'E:Customer number already exist!';
    100001 :  vA # 'E:Vendor number already exist!';
    100002 :  vA # 'E:#Main-Address (1) could not be applied!';
    100003 :  vA # 'E:#Credit limit could not be applied!';
    100004 :  vA # 'E:Address is not allowed to be deleted, because %1% exists for!';
    100005 :  vA # 'E:Customer is prohibited!'
    100006 :  vA # 'E:Supplier is prohibited!'

    101000 :  vA # 'E:Address number already exist!';
    101001 :  vA # 'E:Address number must be indicated!';

    103000 :  vA # 'W:aktuelles Kreditlimit:%1%%CR%offene Posten:%2%%CR%erfasste Aufträge:%3%';

    105000 :  vA # 'E:Package number already exist!';
    105001 :  vA # 'E:Instruction can`t be deleted!';

    // Projekte
    120000 :  vA # 'E:With this interval you aren`t allowed to create a maintenance!';
    120001 :  vA # 'W:Create orders to ALL due maintenance projects?';
    120002 :  vA # 'I:%1% orders were successfully created!';
    120003 :  vA # 'E:Automatische Auftragsanlage bei Projekt %1% fehlgeschlagen! Code %2%';
    120004 :  vA # 'E:Automatic order appendix %1% failed!%CR%There is no current price!';
    120005 :  vA # 'E:The project is deleted already!';
    120006 :  vA # 'E:Position %1% is not deleted!';
    120007 :  vA # 'E:Project: %1% does not exists, or it is deleted!%CR%Verschieben nicht möglich';
    120008 :  vA # 'W:The destination-project contains an object list.%CR%Move anyway?';
    120009 :  vA # 'E:The source-project could not be read!';
    120010 :  vA # 'E:Im Quellprojekt konnten nicht alle Zeiten gesperrt werden!';
    120011 :  vA # 'E:Fehler beim Verschieben der Zeiten [lfnNr.:%1%]!';
    120012 :  vA # 'E:Fehler beim Lesen des Textes!%CR%[%1%]';
    120013 :  vA # 'E:Fehler beim Speichern des Texte!%CR%[%1%]';
    120014 :  vA # 'E:Das Quellprojekt konnte nicht gesperrt werden!';
    120015 :  vA # 'E:Das Zielprojekt konnte nicht gespeichert werden!';
    120016 :  vA # 'E:Fehler beim Erstellen der Notifier-Message!';

    // Ressourcen
    161000 :  vA # 'E:Please enter valid values!';
    161001 :  vA # 'E:A record with this values already exists!';

    165000 :  vA # 'E:Causes, sanctions, spare parts and IHA-ressources will be deleted!';
    165001 :  vA # 'E:#Allocation failed!';

    166000 :  vA # 'E:Causes, sanctions, spare parts and IHA-ressources will be deleted!';

    167000 :  vA # 'E:Spare parts and IHA-ressources will be deleted!';


    181000 :  vA # 'E:#HuB-products %1% not found';
    181001 :  vA # 'E:#HuB-product %1% is blocked by user: '+LockedBy;

    182000 :  vA # 'E:#HuB-products %1% not found';
    182001 :  vA # 'E:#HuB-product %1% is blocked by user: '+LockedBy;

    191000 :  vA # 'E:#HuB-products %1% not found';
    191001 :  vA # 'E:#HuB-product %1% is blocked by user: '+LockedBy;

    192000 :  vA # 'E:#Order header not found!';

    // Material
    200000 :  vA # 'E:Self-material hooks and assumption date do not fit!';
    200001 :  vA # 'E:Assumption date lies AFTER the input information!';
    200002 :  vA # 'E:Input information lies AFTER the output date!';
    200003 :  vA # 'E:The deletion-marker and the output-date do not fit!';
    200004 :  vA # 'W:Note!%CR%This card originates from order/incoming goods!%CR%Corrections should be accomplished actually there!';
    200005 :  vA # 'E:Only commission material may have the status RTS!';
    200006 :  vA # 'E:This card is already deleted';
    200007 :  vA # 'Q:Do you want to remove the past commission and to make the material available again?';
    200008 :  vA # 'W:The material will become "RTS"!%CR%Continue?';
    200009 :  vA # 'E:The material is already reserved!';
    200010 :  vA # 'W:The material will be splitted!%CR%Continue?'
    200011 :  vA # 'E:The material is already in commission!';
    200012 :  vA # 'Q:Do you want the mark this material as deleted?';
    200013 :  vA # 'Q:Do you want to reactivate this material? (status needs to be set manually!)';

    200100 :  vA # 'E:Unfortunately this card cannot be split up properly.';
    200101 :  vA # 'I:The card was split up ordinary.%CR%The number is %1%.';
    200102 :  vA # 'E:The card could not be split up ordinary!';
    200103 :  vA # 'Q:Are you sure that you want to generate a new materialcard?';
    200104 :  vA # 'I:A copy %1% was successfully provided!';
    200105 :  vA # 'E:The copy could not be created!'

    200400 :  vA # 'E:This order is invalid!';
    200401 :  vA # 'I:Commission successfully converted!';
    200402 :  vA # 'I:Commission could not be changed! (error %1%)';

    203001 :  vA # 'Q:Do you want to split the reservations like that?';
    203002 :  vA # 'E:The reservations could NOT be splitted correctly!!';
    203003 :  vA # 'I:The reservations were successfully splitted !';

    220001 :  vA # 'Q:Do you only want to see matching records?';

    // Artikel
    250000 :  vA # 'E:Article number already assigned!';
    250001 :  vA # 'E:Article code already assigned!';
    250002 :  vA # 'E:Catalogue number is already assigned!';
    250003 :  vA # 'E:This calculation is possible only with production articles.'
    250004 :  vA # 'E:Reservierungen konnten nicht verändert werden!';

    250004 :  vA # 'E:This option is possible only with production articles.'
    250006 :  vA # 'E:This calculation is not possible with production articles.'
    250540 :  vA # 'E:Article: %1% %CR%Automatic disposition failed!';
    250541 :  vA # 'Q:Do you want to start the automatic disposition running for all products?';
    250542 :  vA # 'I:Automatic dispo running successfully closed!';

    252000 :  vA # 'Q:Charge disabled by: %1%%CR%Retry?';

    253000 :  vA # 'E:#Product to move %1% could not be found!';
    253001 :  vA # 'E:Serial number product! Quantity have to be ONE!';
    253002 :  vA # 'E:Serial number already exist!';
    // Preise für Artikel
    254002 :  va # 'E:Price record is blocked by user '+lockedby + ', erasure not possible.'
    254003 :  va # 'E:Price record not available, erasure not possible.'
    // Stückliste
    256001 :  vA # 'E:This article can not be inserted, because that would create a cycle!';

    //Reklamationen
    300000 :  vA # 'I:New complaint created: %1%%CR%%2%/%3%';
    300001 :  vA # 'I:Only customer complaints allowed!%CR%Treatment is broken off.'
    300002 :  vA # 'E:The data of material could not found!%CR%Treatment is broken off.'
    300003 :  vA # 'E:No Purchase order number in the data of material %1% !!%CR%Treatment is broken off.'

    // Aufträge
    400001 :  vA # 'E:No calculable entries found!';
    400002 :  vA # 'E:#Action list of position %1% is blocked by user: '+LockedBy;
    400003 :  vA # 'E:#Position %1% is blocked by user: '+LockedBy;
    400004 :  vA # 'Q:Book calculation %1% this way?';
    400005 :  vA # 'I:Calculation %1% successfully created!';
    400006 :  vA # 'W:Some additional charges are not adjusted!';
    400007 :  vA # 'E:Only marked positions of an offer can be converted to an order! ';
    400008 :  vA # 'Q:Convert the %1% marked offer items to a new order?';
    400009 :  vA # 'E:#General error with convert from offer into order!%CR%Line %1%';
    400010 :  vA # 'I:Offer was copied to order %1%';
    400011 :  vA # 'Q:Do you want to print calculations to all calculated orders?%CR%(Individual Payment targets can be jumped over)';
    400012 :  vA # 'E:An error accured in order %1%!';
    400013 :  vA # 'I:Calculations were successfully created!';
    400014 :  vA # 'E:For this order an open delivery note (instruction for shipping) exists %1%!%CR%This have to be booked, before your delivery goes on!';
    400015 :  vA # 'Q:For this order an open delivery note (instruction for shipping) exists %1%!%CR%Do you want to overwrite this (Yes) or to create a new delivery note? (No)';
    400016 :  vA # 'Q:For this order an open delivery note (instruction for shipping) exists %1%!%CR%This will be overwritten!%CR%Continue?';
    400017 :  vA # 'W:The delivery note (instruction for shipping) %1% was generated again!%CR%Please destroy the old papers and print new!';
    400018 :  vA # 'E:Auftragskopf konnte nicht verändert werde!';

    400095 :  vA # 'W:Attention!%CR%Invoice number could NOT be reseted!!!';
    400096 :  vA # 'I:Invoice number was reseted!'
    400097 :  vA # 'E:#INVOICE DIFFERENCE!!!%CR%The term delivered a value of %1% and the booking %2%!%CR%BOOKING CANCELED!';
    400098 :  vA # 'E:#Control key(combination) could not be found!';
    400099 :  vA # 'E:#Global booking error! %CR%Line %1%';

    401000 :  vA # 'E:Erasure FAILED! %CR%Code:%1%';
    401001 :  vA # 'E:The material group cannot be changed into another data type!';
    401002 :  vA # 'W:ATTENTION!!!%CR%This order number already exist!';
    401003 :  vA # 'W:ATTENTION!!!%CR%Some positions do not have a target date!%CR%Save anyway?';
    401004 :  vA # 'Q:Copy these target dates to all positions without target dates?';
    401005 :  vA # 'E:This type of position cannot be returned!';
    401006 :  vA # 'E:This position cannot be deleted because there are still some open or uncalculated consigments!';
    401007 :  vA # 'Q:This position has already a planned production!%CR%Continue anyway?';
    401008 :  vA # 'Q:This Position already has a reserved charge!%CR%Continue anyway?';
    401009 :  vA # 'Q:do you want to book %1% onto this position for the credit memo?';
    401010 :  vA # 'E:Position konnte nicht verändert werden!';
    401011 :  vA # 'Q:Wollen Sie auf dieser Position %1% für die Belastung berechnen?';
    401012 :  vA # 'Q:Wollen Sie den Artikel %1% gegen %2% austauschen?';


    401200 :  vA # 'E:This material does not work with the assignment because of: %1%'
    401201 :  vA # 'Q:This material would set to "sold", but it would be conduct in your deposit!%CR%Continue?';
    401202 :  vA # 'Q:This material would set to "sold" and it would be removed from your deposit%CR%Continue?';
    401203 :  vA # 'E:This material could not be collate!%CR%Code: %1%';
    401204 :  vA # 'I:This material was ordered and booked up to the assignment successfully!';
    401205 :  vA # 'E:This material cannot adopt as foreign material,%CR%because the client has no vendor number!';
    401206 :  vA # 'I:The material was collated to the assignment%CR%and a new foreign card %1% was created!';

    401250 :  vA # 'Q:Do you really want to invoice directly %1% ?%CR%(Storage will be charged, order becomes calculable)';
    401251 :  vA # 'I:The indicated quantity was successfully invoiced directly!';
    401252 :  vA # 'E:This charge is already reserved an cannot be assigned!';
    401253 :  vA # 'E:This charge has only %1% pieces stock!';
    401254 :  vA # 'I:The specified quantity of charge was collated to this commission%CR% and the order was created successfully!';
    401255 :  vA # 'E:This product has only %1% %2%!';
    401256 :  vA # 'E:Just positives can be collated!';
    401257 :  vA # 'Q:The order would be handed down!%CR%Continue anyway?';

    401401 :  vA # 'W:#Order position %1%: Was not able to create/book callorder!';
    401403 :  vA # 'E:#Could not update surchages!';
    401404 :  vA # 'E:#Action could not be saved!';
    401405 :  vA # 'E:#Could not update calculation!';
    401408 :  va # 'E:#Could not update just-in-time deliveries!';
    401409 :  va # 'E:#Could not update object list!';
    401410 :  vA # 'E:#Could NOT correct amount in business order!';
    401999 :  vA # 'E:#%1%: Order position could not be found!';

    404000 :  vA # 'E:This action can not be reactivated!';
    404001 :  vA # 'E:This action can not be reversed!';
    404002 :  vA # 'Q:Do you want to reverse this delivery and put it back to stock?';
    404003 :  vA # 'E:Aktion konnte nicht storniert werden!';

    404100 :  vA # 'E:#Order position %1% has invalid order type!';
    404101 :  vA # 'E:#Order position %1% has already been deleted!';
    404102 :  vA # 'E:#Order position %1% could not be updated!';
    404103 :  vA # 'E:#Order position %1%: reset action already calculated!';
    404104 :  vA # 'E:#Order position %1%: activity could not be deleted!';
    404105 :  vA # 'E:#Order %1%: Header was not found!';
    404106 :  vA # 'E:#Order %1% could not be updated!';
    404107 :  vA # 'E:#Order position %1% was not found!';
    404108 :  vA # 'E:#Object list inscription %1% could not be updated!';

    404200 :  vA # 'W:Please set the data of material %1% correctly!';
    404201 :  vA # 'E:The proper material %1% could not be read from stock!';
    404202 :  vA # 'E:Das zugehörige Material %1% ist in einer aktiven Rechnung enthalten!';

    409001 :  vA # 'E:This classification is not acceptable!';
    409002 :  vA # 'E:This %1%.classification is not correct!';
    409003 :  vA # 'Q:Aplly amount of %1% to order?';
    409700 :  vA # 'Q:Are you finish with all reservation of THIS position?';
    409701 :  vA # 'I:The reservations are finished and the scrap was deleted!';
    409702 :  vA # 'Q:Do you want to produce the product %1% of the object list?';
    409703 :  vA # 'E:Could not book up charge %1% !';
    409704 :  vA # 'E:Could not check in prepacked product %1%!';
    409705 :  vA # 'E:PRODUCTION FAILED! %1%';
    409706 :  vA # 'I:%1% was produced successfully';
    409707 :  vA # 'Q:Do you want to finish the reservations of ALL positions?';

    410000 :  vA # 'Q:!!! ATTENTION !!!%CR%For a reorganization NO users should work in the order file!!!%CR%Do you want to move the deleted marked orders into the deposit?';
    410001 :  vA # 'I:Order reorganisation realized successfully!';
    410002 :  vA # 'E:Order reorganisation cancelled !!!';
    410010 :  vA # 'E:Order number %1% NOT found in deposit!!!!';
    410011 :  vA # 'E:Restore failed!!!';

    // Lieferschein
    440000 :  vA # 'Q:Cancel delivery-note-writing?';
    440001 :  vA # 'E:This delivery-note does still have positions!';

    440100 :  vA # 'E:#Deliviery note %1% could not read while the note is locked!';
    440101 :  vA # 'E:Delivery note %1% already entered!';
    440102 :  vA # 'E:#Header of delivery note could not be saved!';
    440103 :  vA # 'E:#Delivery note COULD NOT be booked! (Code %1%)';
    440104 :  vA # 'E:#Delivery note %1% is not booked!';
    440105 :  vA # 'E:No action allocations to deliver found!';
    440441 :  vA # 'E:#Could not update delivery-position! (Code %1%)';
    440700 :  vA # 'E:The wage driving order could not be generated! (Code %1%)';
    440998 :  vA # 'I:Delivery note cancelled successfully!';
    440999 :  vA # 'I:Delivery not entered successfully!';

    441000 :  vA # 'E:#Position %1%: Could not reserve material!';
    441001 :  vA # 'E:#Position %1%: Could not update position!';
    441002 :  vA # 'E:The reservation could not be adjusted/deleted!';
    441003 :  vA # 'E:#Position %1%: The material does not look like decent deliverance material!%CR%(%2%)';
    441004 :  vA # 'E:#Position %1%: Could not update material!';
    441005 :  vA # 'E:#Position %1%: material not splitted!';
    441006 :  vA # 'E:#Position %1%: activity not found!';
    441007 :  vA # 'E:#Position %1%: activity was already calculated!';
    441008 :  vA # 'E:Position could not be deleted!';

    441100 :  vA # 'E:#Position %1% is locked by '+LockedBy;
    441101 :  vA # 'E:#Position %1%: commission %2% not found!';
    441102 :  vA # 'E:#Position %1%: material/product could not be found!';
    441103 :  vA # 'E:#Position %1%: could not book order action!';
    441104 :  vA # 'E:#Auftrag %1%: Orderheader not found!';
    441105 :  vA # 'E:#Auftrag %1%: client not found!';
    441106 :  vA # 'E:#Position %1%: could not book order price!';
    441107 :  vA # 'E:#Position %1%: acticity is not deletable!';
    441108 :  vA # 'E:There is no acceptable delivery release for Position %1%!';

    441700 :  vA # 'Q:Is the quantity of %1% to be really announced?';
    441701 :  vA # 'E:Error when finished announcing!';

    441999 :  vA # 'E:#Position %1%: booking-error!!%CR%Reason:%2%';

    // Erlöse/Umsätze
    450000 :  vA # 'Q:Cancel proceed?';
    450001 :  vA # 'Q:Really cancel these already to the FIBU handed over proceeds?';
    450002 :  vA # 'I:proceed caceled successfully!';
    450003 :  vA # 'E:#Activity order %1% locked by '+Lockedby;
    450004 :  vA # 'E:#Order position of activity %1% not found!';
    450005 :  vA # 'E:#Order position locked by %1% '+Lockedby;
    450006 :  vA # 'E:#Orderheader for activity %1% not found!';
    450007 :  vA # 'E:#Orderheader %1% locked by '+Lockedby;
    450008 :  vA # 'E:#extra charge %1% of order %2% locked by '+Lockedby;

    400099 :  vA # 'E:#General cancel error!';
    450100 :  vA # 'E:The date of calculate %1% is ahead of the end of date '+CnvAD(Set.Abschlussdatum)+'!';
    450101 :  vA # 'E:FIBU export procedure not adjusted!';
    450102 :  vA # 'E:FIBU export successfully completed!%CR%%1% Invoice number handed over!';
    450103 :  vA # 'Q:Export all marked proceeds to the FIBU?';

    450200 :  vA # 'E:Proceeds could not determine a suitable counter account!%CR%Transfer CANCELED!';

    // Offene Posten
    460001 :  vA # 'Enter warning?';

    461001 :  vA # 'Q:Create receipt of payment for this donation automatically?';
    461002 :  vA # 'The currencies do not match!';

    470000 :  vA # 'Q:!!! ATTENTION !!!%CR%For a reorganization NO users should work in the open-items!!!%CR%Do you want to move the deleted marked open-items into the deposit?';
    470001 :  vA # 'I:Open-item reorganisation realized successfully!';
    470002 :  vA # 'E:Open-item reorganisation cancelled !!!';
    470010 :  vA # 'E:Invoicenumber %1% NOT found in deposit!!!!';
    470011 :  vA # 'E:Restore failed!!!';

    // Bestellungen
    501200 :  vA # 'E:#Materialcard could not be created/changed!';
    501250 :  vA # 'E:Product order quantity could not be created/changed!';
    501503 :  vA # 'E:Calculation could not be created!';
    501505 :  vA # 'E:#Extra charge could not be created!';

    504100 :  vA # 'E:#Purchase order item %1% has incorrect material group!';
    504101 :  vA # 'E:#Purchase order item %1% already has been deleted!';
    504102 :  vA # 'E:#Purchase order item %1% could not be updated!';
    504104 :  vA # 'E:#Purchase order item %1%: activity could not be deleted!';
    504105 :  vA # 'E:#Purchase order : purchase order header not found!';
    504106 :  vA # 'E:#Purchase order %1% could not be updated!';
    504107 :  vA # 'E:#Purchase order position %1% not found!';

    510000 :  vA # 'Q:!!! ATTENTION !!!%CR%For a reorganization NO users should work in the order file!!!%CR%Do you want to move the deleted marked orders into the deposit?';
    510001 :  vA # 'I:Purchase order reorganisation realized successfully!';
    510002 :  vA # 'E:Purchase order reorganisation cancelled !!!';
    510010 :  vA # 'E:Purchase order number %1% NOT found in deposit!!!!';
    510011 :  vA # 'E:Restore failed!!!';

    506001 :  vA # 'E:#Entry cannot be booked!';
    506002 :  vA # 'E:Ready for dispatch, Entrance or loss must be indicated!!';
    506003 :  vA # 'E:Material %1% can not be assigned to this entrance!%CR%Material not found!';
    506004 :  vA # 'E:Material %1% can not be assigned to this entrance!%CR%Material has wrong data!';
    506005 :  vA # 'Q:Folgende Analysewerte passen nicht:%CR%%1%Trotzdem verbuchen?';
    506006 :  vA # 'E:Folgende Analysewerte passen nicht:%CR%%1%Verbuchung nicht möglich!';

    506555 :  vA # 'E:Purchase control was already assigned!';

    // Bedarfsdatei
    540001 :  vA # 'I:Order %1% created successfully!';
    540002 :  vA # 'W:ATTENTION!%CR% The marked parts have different suppliers!';
    540003 :  vA # 'E:No supplier called in the marked parts!';
    540004 :  vA # 'I:Request %1% created successfully!';
    540005 :  vA # 'W:Please choose victualer for request...';
    540006 :  vA # 'E:Please mark the wanted parts.';
    540099 :  vA # 'E:Purchase order could not be generated!';
    540100 :  vA # 'Q:Change all marked positions to ONE purchase order at victualer %1% ?';

    // EKK
    555001 :  vA # 'Q:Do you really want to cancel these assignments?';

    // Eingangsrechnungen
    560001 :  vA # 'E:Suppliers are not similar!';
    560002 :  vA # 'E:Incorrect outgoing payments!';
    560003 :  vA # 'E:Incorrect incoming invoice!';
    560004 :  vA # 'Q:Generate payments and outgoing payments?';
    560005 :  vA # 'I:Generated Files!';

    561001 :  vA # 'E:This playment has been booked already!';
    561002 :  vA # 'Q:Create receipt of payment for this outgoing payment automatically?';

    // Sammelwareneingänge
    621001 :  vA # 'E:Avis, Eingang oder Ausfall muss angegeben werden!';
    621002 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelesen werden. Position kann nicht gelöscht werden.';
    621003 :  vA # 'E:Das Material zu diesem Einsatz enthält bereits Aktionen. Position kann nicht gelöscht werden.';
    621004 :  vA # 'E:Das Material zu diesem Einsatz konnte nicht gelöscht werden. Position kann nicht gelöscht werden.';
    621005 :  vA # 'E:Die Position konnte nicht gelöscht werden.';

  end;

  case aNr of
    // BAG :
    700001 :  vA # 'Q:Is the complete business order to be announced with the planned quantities?';

    701001 :  vA # 'E:Forerunner not found!';
    701002 :  vA # 'E:Forerunner is already further processed!';
    701003 :  vA # 'E:Cannot change Material component!';
    701004 :  vA # 'E:You would create a cycle with this!';
    701005 :  vA # 'E:The specified material cannot entered as specified material!';
    701006 :  vA # 'E:Could not "clear" specified material!';
    701007 :  vA # 'E:The material cannot be deleted from input because readiness messages already exist!';
    701008 :  vA # 'E:This application has no correct material!';
    701009 :  vA # 'E:This output is not bookable!';
    701010 :  vA # 'E:Output calculation failed!!!';
    701011 :  vA # 'Q:This is RTS-material - do you want do enter the real iputmaterial now?';
    701012 :  vA # 'E:Could not read the RTS-material!';
    701013 :  vA # 'E:Could not read the purchase of this TTS-material!';

    702001 :  vA # 'E:This position is already complete!';
    702002 :  vA # 'E:Position cannot be deleted because readiness messages already exist!';
    702003 :  vA # 'E:Position can not be deletee position! Productions still exist!';
    702004 :  vA # 'E:Cannot enter constitution!';
    702005 :  vA # 'Q:Are all commissioned outputs to be registered automatically into a RFDs processing step?';
    702006 :  vA # 'I:Automatic RFDs successfully generated!'
    702007 :  vA # 'E:COULD NOT generate automatically RFDs !!!'
    702008 :  vA # 'E:This position can not be accomplished!';
    702009 :  vA # 'E:This position is already deleted / set ready!';
    702010 :  vA # 'Q:There would be created %1% scrap!%CR%complete position really?';
    702011 :  vA # 'I:Position complete successfully!';
    702012 :  vA # 'E:ERROR: Position COULD NOT be completed! (Code: %1%)';
    702013 :  vA # 'E:Position can not be deleted because there is still an input!';
    702014 :  vA # 'E:Fahraufträge bitte über den Lieferschein fertigmelden!';
    702015 :  vA # 'Q:Mindestens eine Position wurde durch einen anderen User in eine Feinplanung aufgenommen!%CR%Sollen trotzdem Ihre Daten gespeichert werden?';
    702016 :  vA # 'Q:Wollen Sie diese Feinplanung vorm Verlassen speichern?';

    702440 :  vA # 'E:FEHLER: Delivery note could not be booked!';

    703001 :  vA # 'E:For the %1%th manufacturing there are already readindess messages!%CR%Therefore it cannot be deleted!';
    703002 :  vA # 'W:This manufacturing is processed and cannot not be deleted!';
    703003 :  vA # 'I:The old manufacturing has successfully been changed and a new one has been created!';
    703004 :  vA # 'E:The splitting has failed!';

    707001 :  vA # 'I:Readiness message was created and booked';
    707002 :  vA # 'E:Readiness message could not be booked! (Code %1%)';
    707003 :  vA # 'I:Fertigmeldung wurde erfolgreich storniert!';
    707004 :  vA # 'E:Fertigmeldung konnte NICHT gelöscht werden!';
    707005 :  vA # 'I:Bei Nettoverwiegungen darf das Bruttogewicht nicht dem Nettogewicht entsprechen und darf nicht NULL sein!';
    707006 :  vA # 'E:Bitte die Messwerte überprüfen!';
/*
    707007 :  vA # 'E:Fehler beim Etikettendruck!%CR%Fertigung konnte nicht gelesen werden!';
    707008 :  vA # 'E:Fehler beim Etikettendruck!%CR%Verpackung konnte nicht gelesen werden!';
    707009 :  vA # 'E:Fehler beim Etikettendruck!%CR%Etikettendefinition konnte nicht gelesen werden!';
*/

   //---
    800001 :  vA # 'E:#User could not be locked!'
    800002 :  vA # 'E:#User could not be saved!'
    800003 :  va # 'E:#authorization for [ %1% ] not acceptable.'
    800004 :  va # 'E:User [%1%] does not exist.'
    801001 :  vA # 'E:#Usergroup could not be locked!'
    801002 :  vA # 'E:#Usergroup could not be saved!'

    802001 :  vA # 'E:#assignment already exist!'
    802002 :  vA # 'Q:assignment cancel?'

    814000 :  vA # 'E:Currency %1% not found!';
    814001 :  vA # 'E:#Currency number %1%: Exchange rate is ZERO!';
    828001 :  va # 'E:The process [ %1% ] does not exist in demand data.'

    831000 :  va # 'E:The process [ %1% ] already exist.'

    842000 :  vA # 'E:Would you like to create the surcharges automatically?';

    844000 :  vA # 'Q:An inventury file is imported already from %1%. %CR%Do you want to delete it this file?';
    844001 :  vA # 'I:Inventory-file ipmorted successfully.';
    844002 :  vA # 'E:Inventory-file could not be imported!';
    844003 :  vA # 'E:The name of the stockyard is too long. It should have a maximal length of 15 characters!';
    844004 :  vA # 'E:The obsolete inventury-file could not be deleted!';
    844005 :  vA # 'Q:Do you want to save the inventory data of the highlighted stockyards?';
    844006 :  vA # 'I:Inventory saved successfully.';
    844007 :  vA # 'E:The inventory could not be saved!';
    844008 :  vA # 'I:Bitte scannen Sie den zu prüfenden Lagerplatz ein, aktivieren am Scanner den Sendemodus und klicken Sie auf OK.';
    844009 :  vA # 'E:Fehler bei der Scannerkomunikation!%CR%Bitte prüfen Sie die Verbindung und ob der Scanner im Sendemodus ist.';
    844010 :  vA # 'E:Fehler beim Einlesen der gescannten Daten!';
    844011 :  vA # 'E:Der ausgewählte Lagerplatz stimmt nicht mit dem gescannten Lagerplatz überein!';


    890000 :  vA # 'E:You have no authorization to call this on-line statistics!';
    890001 :  vA # 'Q:Do you want to delete and recalculate the whole online statistic?';

    902001 :  vA # 'E:%1% number range locked by: %2%%CR%repeat?';
    902002 :  vA # 'E:#%1% number range  could not set higher!!!';
    902003 :  vA # 'E:#%1% number range COULD NOT be read!!!%CR%!!! CANCEL !!!';
    903000 :  va # 'E:Missing statements in settings [ %1% ]';

    910001 :  vA # 'E:List number %1% not found!';
    910002 :  vA # 'Q:Create XML-file of this list? (otheriwise printable form)';
    910003 :  vA # 'I:XML-file %1% has been created successfully!';
    910004 :  vA # 'E:XML-file %1% could not be written!';
    910005 :  vA # 'E:XML-file %1% could not be written! Showing printable form.';

    911001 :  vA # 'E:No authorization to display list!';
    911002 :  vA # 'E:Assignment already exist!';
    911003 :  vA # 'E:Cancel assignment?';

    912001 :  va # 'Q:Show the printed document?';
    912002 :  va # 'E:#Formular %1% `not found!';
    912003 :  vA # 'Q:Include the fax header?';
    912004 :  vA # 'Q:Include the email header?';

    915001 :  vA # 'E:#Form type unknown: %1%';

    921000 :  vA # 'E:This special-function could not be executed correctly!';

    990001 :  vA # 'E:#Protocolpuffer already in use!';
    990002 :  vA # 'E:#Protocolpuffer empty! (forget)';
    990003 :  vA # 'E:#Protocolpuffer empty! (compare)';
    990010 :  vA # 'E:#Could not create protocol!';

    997001 :  vA # 'W:Choose the changing field...';
    997002 :  vA # 'Q:Are you sure that you want to overwrite the %1% marked records the field "%2%" with "%3%"?';
    997003 :  vA # 'I:Changed the marked parts successfully!';
    997004 :  vA # 'E:Not all of this marked parts could be changed!!!%CR% reset EVERYTHING!';
    997005 :  vA # 'Q:Do you wanr to remove all markers?';

    998000 :  vA # 'Q:List generation takes more time then usually%CR%Cancel list?';
    998001 :  vA # 'I:TELEPHONE!!!%CR%Internal call from phone %1%';
    998002 :  vA # 'I:TELEPHONE!!!%CR%Call of %1%';
    998003 :  vA # 'Q:Do you want to export all of these tables to %1%?';
    998004 :  vA # 'I:Written file %1%!%CR%Number of parts: %2%';
    998005 :  vA # 'Q:Do you want to read ALL datas of File %1%?';
    998006 :  vA # 'I:Read file %1%!%CR%Number of parts: %2%';
    998007 :  vA # 'E:Das Visualiesierungstool GRAPHVIZ schient nicht installiet zu sein!';
    998008 :  vA # 'E:All user have to leave the database for this!';
    998009 :  vA # 'W:Before a diagnosis you got to CREATE A BACKUP manually!!!%CR%Start diagnosis now?';
    998010 :  vA # 'W:Before a optimization you got to CREATE A BACKUP manually!!!%CR%Start optimization now?';
    998011 :  vA # 'Q:Start key-reorganisation now?';

    999001 :  vA # 'E:Program-Licence not found!';
    999002 :  vA # 'E:Program-Licence not found!';
    999003 :  vA # 'E:Program license does not fit this product!';
    999004 :  vA # 'E:Program license does not fit the data base licenses!';
    999005 :  vA # 'Program license ran off!';
    999010 :  vA # 'Number of users is too high for this porgram-licence!';
    999011 :  vA # 'Number of Job-Servers is too high for this program-licence!';
    999012 :  vA # 'Number of operating users is too high for this program license!';

    999050 :  vA # 'Q:Install a new/ other program-licence?';
    999051 :  vA # 'I:Insallation successful - Please restart!';
    999998 :  vA # 'I:Success!';
    999999 :  vA # 'E:!!! PUBLIC ERROR !!!%CR%%1%';

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