@A
//==== Business-Control ==================================================
//
//  Prozedur    SVC_SNOM_Action
//                  OHNE E_R_G
//  Zu Service: SNOM_Action
//
//  Info
//  SNOM_Action: Verknüpfungspunkt der Telefonanlage
//
//  13.09.2016  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//
//
//  http://192.168.0.2:5600/?sender=A1386/5&service=SNOM_ACTION&local=$local&remote=$remote&active_url=$active_url&active_user=$active_user&...
//          active_host=$active_host&csta_id=$csta_id&call_id=$call-id&display_local=$display_local&display_remote=$display_remote&expansion_module=$expansion_module&...
//          active_key=$active_key&phone_ip=$phone_ip&nr_ongoing_calls=$nr_ongoing_calls&context_url=$context_url&cancel_reason=$cancel_reason
//  ActionUrls : http://wiki.snom.com/Features/Action_URL
//
//
//
//  Aktionsurls für Telefonkonfig im Anhang von Projetzt 1326/503
//
//
//========================================================================
@I:Def_Global
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API
@I:Lib_Tapi_Snom

define begin
  get(a)        : vNode->getValue(toUpper(a));
  addToApi(a,b) : begin   vNode # vApi->apiAdd(a,_TypeBool,false,null,null,'1 | 0','1');vNode->apiSetDesc(b,'1');end;
end;


//=========================================================================
// sub api() : handle
//
//  Definiert die API Beschreibung (Servicevertrag) für den implementierten
//  Service.
//
//  DESIGNENTSCHEIDUNG
//    Diese Methode muss in jedem Service implementiert sein; wird für folgende
//    Zwecke benutzt:
//      1) Prüfung der übergebenen Argumente
//      2) Ausgabe der API für den Benutzer mit Beispieldaten
//
//  @Return
//    handle                      // Handle des XML Dokumentes der API
//
//=========================================================================
sub api() : handle
local begin
  vAPI   : handle;
  vNode : handle;
end
begin

  // ----------------------------------
  // Standardapi erstellen
  vApi # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier


  // ----------------------------------
  // ApiBeschreibung zurückgeben
  return vAPI;

End; // sub api() : handle


//=========================================================================
// sub exec(aArgs : handle; var aResponse : handle) : int
//
//  Führt den Service aus:
//    Liest die übergebene Materialnummer und gibt alle Felder aus,
//    deren Feldnamen oder Nummern in Stahl Control vorhanden sind
//
//  @Param
//    aRequestData    : handle    // Handle für die Requestdaten
//    var aAnswerNode : handle    // Referenz auf Antwortstruktur
//
//  @Return
//    int                         // Fehlercode
//
//=========================================================================
sub exec(aArgs : handle; var aResponse : handle) : int
local begin
  // Argumente zur Erstellung der Selektion
  vArgs       : handle;     // Handle für Argumentprüfungsstruktur
  vNode       : handle;     // Handle auf Datensegment der Antwort

  vActiontype             : alpha(1000); //  Manueller Aktionstyp
  vSnom_local	            : alpha(1000); //  the SIP URI of callee
  vSnom_remote	          : alpha(1000); //  the SIP URI of caller
  vSnom_active_url	      : alpha(1000); //  the SIP URI of the active outgoing identity
  vSnom_active_user	      : alpha(1000); //  the user part of the SIP URI for the active outgoing identity
  vSnom_active_host	      : alpha(1000); //  the host part of the SIP URI for the active outgoing identity
  vSnom_csta_id	          : alpha(1000); //  CSTA ID
  vSnom_call_id	          : alpha(1000); //  the call-id of the active call
  vSnom_display_local	    : alpha(1000); //  used to display the name of callee
  vSnom_display_remote	  : alpha(1000); //  used to display the name of caller.
  vSnom_expansion_module	: alpha(1000); //  used to show which Expansion Module do you use and
  vSnom_active_key	      : alpha(1000); //  the Function Key (e.g. P1, P5, P32,..) associated with a call.
  vSnom_phone_ip	        : alpha(1000); //  the current ip address of the phone
  vSnom_nr_ongoing_calls	: alpha(1000); //  contains the number of active calls
  vSnom_context_url	      : alpha(1000); //  used in log_on/off-action to provide the sip-uri of the logged-on/off
  vSnom_cancel_reason	    : alpha(1000); //  when a call has been canceled/terminated via sip-cancel this will paste the content of the reason-header

  vAnruferNr    :   alpha;
  vZiel         :   alpha;
  vCallId       :   alpha;
  vTimestamp    :   caltime;
end
begin

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vActiontype             # aArgs->getValue('action');            //  EventAktion vom Snom

  vSnom_local	            # aArgs->getValue('local');             //  the SIP URI of callee
  vSnom_remote	          # aArgs->getValue('remote');            //  the SIP URI of caller
  vSnom_active_url	      # aArgs->getValue('active_url');        //  the SIP URI of the active outgoing identity
  vSnom_active_user	      # aArgs->getValue('active_user');       //  the user part of the SIP URI for the active outgoing identity
  vSnom_active_host	      # aArgs->getValue('active_host');       //  the host part of the SIP URI for the active outgoing identity
  vSnom_csta_id	          # aArgs->getValue('csta_id');           //  CSTA ID
  vSnom_call_id	          # aArgs->getValue('call_id');           //  the call-id of the active call
  vSnom_display_local	    # aArgs->getValue('display_local');     //  used to display the name of callee
  vSnom_display_remote	  # aArgs->getValue('display_remote');    //  used to display the name of caller.
  vSnom_expansion_module	# aArgs->getValue('expansion_module');  //  used to show which Expansion Module do you use and
  vSnom_active_key	      # aArgs->getValue('active_key');        //  the Function Key (e.g. P1, P5, P32,..) associated with a call.
  vSnom_phone_ip	        # aArgs->getValue('phone_ip');          //  the current ip address of the phone
  vSnom_nr_ongoing_calls	# aArgs->getValue('nr_ongoing_calls');  //  contains the number of active calls
  vSnom_context_url	      # aArgs->getValue('context_url');       //  used in log_on/off-action to provide the sip-uri of the logged-on/off
  vSnom_cancel_reason	    # aArgs->getValue('cancel_reason');     //  when a call has been canceled/terminated via sip-cancel this will paste the content of the reason-header

  // Anrufvarianten
  // 1) Eingehend Extern, Abnehmen, Telefonieren, Auflegen
  //      IncomingCall -> OnOffhook -> OnConnected -> OnOnhook -> OnDisconnected

  vAnruferNr  #  Str_Token(vSnom_remote,'@',1);
  vZiel       #  vSnom_phone_ip;
  vCallId     #  Str_Token(vSnom_call_id,'@',1);
  vTimestamp->vmSystemTime();

  case vActiontype of

    cIncomingCall,
    cOnConnected,
    cOnDisconnected,
    cMissedCall      : begin

      Lib_Tapi_Snom:ServerActionlistAddItem(vActiontype, vCallId, vZiel, vAnruferNr, vTimestamp);

      // Zusätzlichen Eintrag für angenommenes Telefonat
      if (vActiontype = cOnConnected) then
        Lib_Tapi_Snom:ServerActionlistAddItem(vActiontype, vCallId, vZiel, vAnruferNr, vTimestamp, vCallId);
    end;

    'OutgoingCall' : begin
      end;

    'OnOffhook'    : begin
Lib_Tapi_Snom:ServerActionlistDebugItems();
      end;

    'OnOnhook'     : begin
      end;

    'DNDoff'  : begin
//Lib_Tapi_Snom:ServerActionlistClear();
    end;



    'TransferCall'  : begin
      end;

    'BlindTransfer' : begin
      end;

    'AttendedTransfer' : begin
      end;

    'ReceivedAttendedTransfer' : begin
      end;

    // weitere mögliche Aktionen vom Telefon
    'DNDon', 'DNDoff','CallForwardingOn','CallForwardingOff','SetupFinished','RegistrationFailed',
     'Login', 'Logoff','HoldCall','UnholdCall': begin end;

  end;




  // Daten des Services sind angehängt
  return _rOk;

End; // sub exec(...) : int



//=========================================================================
//=========================================================================
//=========================================================================


