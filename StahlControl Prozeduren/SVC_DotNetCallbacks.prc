@A+
//==== Business-Control ==================================================
//
//  Prozedur    SVC_DotNet_Callbacks
//                  OHNE E_R_G
//  Zu Service:
//
//  Info
//              Alle Callbacks von DotNet zurück
//
//  14.11.2017  AH  Erstellung der Prozedur
//  05.10.2018  ST  "sub Exec()" leitet an "WebappActions" weiter
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert / Protokollierung SendingUSer
//  03.06.2020  AH  Neu: Fixe und gelöschte BA-Pos werden nicht gejittet
//  05.10.2020  AH  Fix: Start der ASAP nach JIT setzt für Job-Server nicht das Erledigt-Kennzeichen für das JIT
//  04.02.2022  AH  ERX
//  20.12.2022  ST  "sub ExecMemory" hinzugefügt
//
//  Subprozeduren
//    SUB api() : handle
//    SUB exec(aArgs : handle; var aResponse : handle) : int
//
//    SUB RsoReservierungSetTermine(aXmlPara : handle) : alpha
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_SOA
@I:Lib_SOA
@I:SOA_SVM_API
@I:Lib_Tapi_Snom
@I:Def_BAG


define begin
  LogActive     : true
  Log(a)        :  if (LogActive) then Lib_Soa:Dbg(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+ '['+__PROC__+':'+aint(__LINE__)+']' + ':' + a);

/*
  DebugX(a)   : Lib_Debug:Dbg_Debug(a+'   ['+__PROC__+':'+aint(__LINE__)+']')
  DebugStamp(a) : Lib_Debug:dbg_Debug(cnvat(systime(_TimeSec | _Timehsec),_FmtTimeHSeconds )+' '+a)
  */
end;

declare Message(aXmlPara    : handle) : alpha
declare RsoReservierungSetTermine(aXmlPara : handle): alpha

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
  vAPI    : handle;
  vNode   : handle;
end
begin

  // ----------------------------------
  // Standardapi erstellen
  vApi # apiCreateStd();

  // ----------------------------------
  // Speziele Api-Definition ab hier

  // ----------------------------------
  // ApiBeschreibung zurückgeben
  RETURN vAPI;

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
  vArgs       : handle;       // Handle für Argumentprüfungsstruktur
  vNode       : handle;       // Handle auf Datensegment der Antwort
  vActiontype : alpha(1000);  //  Manueller Aktionstyp
  vSendingUser : alpha(1000); // User aus MDE/WebClient
  vDruckerID  : int;          // Zum setzend der gesendeten DruckerID vom .Net-Client zur Auswahl des Druckers  2436/418
  vNaviPfad   : alpha(1000);  //Navigationspfad vom MDE
  vPostData   : handle;       // Handle für Externe XML Struktur
  vErrText    : alpha(1000);
  vReturnval  : alpha(1000);  // ggf. kurze Antwort
end
begin

//DbaLog(_LogInfo, N, 'SOA-DotNext-Callback: Started...');

  vErrText # 'unknown action';

  // --------------------------------------------------------------------------
  // Argumente Extrahieren und für Prüfung vorbereiten
  vActiontype   # aArgs->getValue('ACTION');            //  EventAktion von WebApp
  vSendingUser  # aArgs->getValue('SENDINGUSER');
  vPostData     # aArgs->GetNode('POSTDATA');
  vDruckerID    # cnvia(aArgs->getValue('DRUCKERID'));
  vNaviPfad     # aArgs->getValue('NAVIGATIONSPFAD');
  


  Log('=======================================================================');
  Log('Actiontype = "' + vActionType + '"');
  Log('SendingUser = "' + vSendingUser+ '"');
  Log('DruckerID = "' + Aint(vDruckerID)+ '"');
  Log('NavigationsPfad = "' + vNaviPfad+ '"');
  if (vSendingUser <> '') then
    gUsername # vSendingUser;
  
  if(vDruckerID <> 0 ) then
    gLastDruckerID # vDruckerID;
    
  if(vNaviPfad <> '') then
    gMdeNavigationsPfad # vNaviPfad;

  Log('gUsername= "' + gUsername+ '"');
  Log('gUsergroup= "' + gUserGroup+ '"');
  Log('gLastDruckerID= "' + Aint(gLastDruckerID)+ '"');
  Log('gMdeNavigationsPfad= "' + gMdeNavigationsPfad+ '"');
  
  case vActiontype of
    'PING' : begin
      vErrText # '';
    end;

    'MESSAGE' : begin
      vErrText # Message(vPostData->GetNode('MessageC16'));
    end;

    'RSORESERVIERUNGSETTERMINE' : begin
      vErrText # RsoReservierungSetTermine(vPostData->GetNode('RsoReservierungSetTermineC16'));
//vErrText # '';
    end;

    otherwise begin
      // Alternativ eine WebAppAction prüfen
      RETURN SVC_WEBAPP_Action:exec(aArgs, var aResponse);
    end;

  end;  // case

  // --------------------------------------------------------------------------
  // Result schreiben
  if (vErrText = '') then begin
    vNode # aResponse->getNode('DATA');
    vNode->Lib_XML:AppendNode('Erg','ok');

    if (vReturnVal <> '') then
      vNode->Lib_XML:AppendNode('Return',vReturnval);

  end
  else begin
    vNode # aResponse->getNode('ERRORS');
    vNode->Lib_XML:AppendNode('Error',StrCnv( vErrText, _strToUTF8 ));
    RETURN -1;
  end;

  // Daten des Services sind angehängt
  RETURN _rOk;

End; // sub exec(...) : int



//=========================================================================
// execMemory
//   Führt den Service mit einer direkten Binärausgabe aus.
//=========================================================================
sub execMemory (aArgs : handle; var aMem : handle; var aContentType : alpha ) : int
begin
  RETURN SVC_WEBAPP_Action:ExecMemory(aArgs, var aMem, var aContentType);
end;



//=========================================================================
//  Message
//    Refrehed ein INFO-Event
//=========================================================================
sub Message(
  aXmlPara    : handle) : alpha
local begin
  vErg    : alpha;
  vUser   : alpha;
  vBig    : bigint;
  vText   : alpha;
end;
begin

  // Daten extrahieren
  if (aXmlPara <= 0) then RETURN '';

  Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'User'), var vUser);
  Lib_XML:GetValueLong(  Lib_Soa:getNode(aXmlPara, 'ID'), var vBig);
  Lib_XML:GetValue(  Lib_Soa:getNode(aXmlPara, 'Text'), var vText);

  // 10.06.2020 AH: Über Notifier? oder bei NEGATIV per RmtData
//Log('got RequestID :'+cnvab(vBig));
  if (vBig>0) then begin
    Lib_Notifier:UpdateInfo(vUser, vBig, vText);
  end
  else begin
//  RmtDataWrite(aKey, _recunlock | _RmtDataTemp, aWert);
//Log('write RMTDATA : '+vUSer+' ,#'+cnvab(vBig));
    //Lib_RmtData:UserWrite('#'+cnvab(vBig), 'TRUE', vUser);
//    RmtDataWrite('JOB|#'+cnvab(vBig), _recunlock, 'TRUE');    // SESSIONÜBERGREIFEND !!!    05.10.2020 AH: per "SetTermFinished"
  end;

  RETURN vErg;
end;


//=========================================================================
//=========================================================================
sub SetTermFinished(
  aUser       : alpha;
  aRequestID  : bigint)
begin
//Log('incomin ANTWORT : '+aUser+'|#'+cnvab(aRequestID));
  // wenn JOB!?
  if (aRequestID<0) then begin
    RmtDataWrite(aUser+'|#'+cnvab(aRequestID), _recunlock, 'TRUE');    // SESSIONÜBERGREIFEND !!!
  end;
end;


//=========================================================================
//  RsoReservierungSetTermine
//      Ändert die Termine der angegebenen Reservierungen
//=========================================================================
sub RsoReservierungSetTermine(
  aXmlPara    : handle;
) : alpha
local begin
  Erx         : int;
  vNr         : int;
  vStart      : caltime;
  vEnde       : caltime;
  vDauer      : int;
  vDauerPost  : int;
  vA,vB       : alpha;
  vErg        : alpha;
  vItem       : int;
  vFirst      : logic;
  vZusatz     : alpha;
  vAntwort    : alpha;
  vMin        : caltime;
  vTxt        : int;
  vI          : int;
  vDat, vDat2 : date;
  vRedoAsap   : logic;
  vUsername   : alpha;
  vRequestID  : bigint;
  v702        : int;
  vVorherDat    : date;
  vVorherDauer  :int;
end;
begin
//Log('In Reserv '+userinfo(_UserCurrent));

  vMin->vpDate # 31.12.2099;

  // Daten extrahieren
  if (aXmlPara <= 0) then RETURN '';

  vTxt # TextOpen(20);

  Lib_XML:GetValue(Lib_Soa:getNode(aXmlPara,'Antwortcode'), var vAntwort);
  Lib_XML:GetValue(Lib_Soa:getNode(aXmlPara,'Username'), var vUsername);
  Lib_XML:GetValueLong(Lib_Soa:getNode(aXmlPara, 'CallbackID'), var vRequestID);

  axmlPara # Lib_Soa:getNode(aXmlPara,'Reservierungen')
  if (aXmlPara <= 0) then RETURN '';

  FOR vItem # Lib_Soa:getNode(aXmlPara,'RsoReservierungSetTermineSubC16')
  LOOP vItem # aXmlPara->CteRead(_CteSearch | _CteNext |_CteChildList ,vItem , 'RsoReservierungSetTermineSubC16')
  WHILE (vItem<>0) do begin
//Log('item...');
    Lib_XML:GetValueI(  Lib_Soa:getNode(vItem,'Nr'), var vNr);
    Lib_XML:GetValueC(  Lib_Soa:getNode(vItem,'Start'), var vStart);
    Lib_XML:GetValueC(  Lib_Soa:getNode(vItem,'Ende'), var vEnde);
    Lib_XML:GetValueI(  Lib_Soa:getNode(vItem,'Dauer'), var vDauer);
    Lib_XML:GetValueI(  Lib_Soa:getNode(vItem,'DauerPost'), var vDauerPost);

//debug(cnvai(vNr)+': '+cnvac(vStart, _FmtCalTimeRFC)+' '+cnvac(vEnde, _FmtCalTimeRFC));
    if (vNr=0) then CYCLE;

    Rso.R.Reservierungnr # vNr;
    Erx # RecRead(170,1,0);
    if (Erx<>_rOK) or ("Rso.R.Löschmarker"<>'') then CYCLE;  // 03.06.2020 * oder Fix

    if (vFirst=false) then begin
      TRANSON;
      vFirst # y;
    end;
    Erx # RecRead(170,1,_recLock);

vVorherDat    # Rso.R.Plan.StartDat;
vVorherDauer  # Rso.R.Dauer;
    Rso.R.Plan.StartDat   # vStart->vpDate;
    Rso.R.Plan.StartZeit  # vStart->vpTime;
    Rso.R.Plan.EndDat     # vEnde->vpDate;
    Rso.R.Plan.EndZeit    # vEnde->vpTime;
    Rso.R.Dauer           # vDauer;
    Rso.R.DauerPost       # vDauerPost;
if (Set.Installname='BSP') and ((vVorherDat<>Rso.R.Plan.StartDat) or (vVorherDauer<>Rso.R.Dauer)) then begin   // 2022-11-14 AH    Proj. 2329/63
Lib_Debug:Protokoll('!BSP_Log_Komisch', "Rso.R.Trägertyp"+' '+aint("Rso.r.Trägernummer1")+'/'+aint("Rso.R.Trägernummer2")+' : '+cnvad(Rso.R.Plan.StartDat)+' '+aint(Rso.R.Dauer)+' ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
end;

    vMin # Min(vStart, vMin);
//debug(cnvai(vNr)+'::'+cnvad(Rso.R.Plan.StartDat)+':'+cnvat(Rso.R.Plan.StartZeit)+' '+cnvad(Rso.R.Plan.EndDat)+':'+cnvat(Rso.R.Plan.EndZeit));
    vZusatz # '#AUTOJIT#';
    Erx # Rso_Rsv_Data:Replace(_recunlock, 'AUTO', 'FIX', vZusatz);
//Recread(170,1,_recunlock);
//Erx # _rOK;
    if (Erx<>_rOK) then begin
      TRANSBRK;
      TextClose(vTxt);
      SetTermFinished(vUsername, vRequestID);   // 05.10.2020 AH
      RETURN 'Res.'+aint(vNr)+' nicht änderbar!';
    end;

    // 30.04.2019 AH: BA-Kommissionen suchen...
    if ("Rso.R.Trägertyp"='BAG') then begin
      BAG.P.Nummer    # "Rso.R.Trägernummer1";
      BAG.P.Position  # "Rso.R.Trägernummer2";
//        Erx # RecRead(702,1,_recLock);  03.06.2020 ohne Lock!?
      Erx # RecRead(702,1,0);
      v702 # RekSave(702);    // 05.10.2020 AH
      if (Erx<=_rOK) then begin
        // ist die Ba-Pos ein "Anfang"?
        FOR Erx # RecLink(701,702,2,_RecFirst)
        LOOP Erx # RecLink(701,702,2,_RecNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.IO.Materialtyp=c_IO_BAG) then begin
            // NEIN !!!
            BREAK;
          end;
        END;
        if (Erx>_rLocked) then begin    // JA?
          TextAddLine(vTxt, 'BAPOS|'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
        end;


        FOR Erx # RecLink(703,702,4,_recFirst)    // Fertigungen loopen
        LOOP Erx # RecLink(703,702,4,_recNext)
        WHILE (Erx<=_rLocked) do begin

          if (BAG.F.Kommission<>'') then begin
            vI # TextSearch(vTxt, 1,1, _TextSearchCI, 'AUF|'+BAG.F.Kommission+'|');
            // neuer Auftrag?
            if (vI=0) then begin
              TextAddLine(vTxt, 'AUF|'+BAG.F.Kommission+'|'+cnvad(vEnde->vpDate)+'|'+aint(BAG.P.Position));
//debugx('add '+'|'+BAG.F.Kommission+'|'+cnvad(vEnde->vpDate));
            end
            else begin  // sonst größtes Datum merken
              vA # TextLineRead(vTxt, vI, 0);
              vB # Str_token(vA, '|',2);
              vDat # cnvda(Str_token(vA, '|',3));
              vDat # Max(vDat, vEnde->vpDate);
              vB # 'AUF|'+vB+'|'+cnvad(vDat);
              TextLineWrite(vTxt, vI, vB, 0);
//debugx('edit '+vB);
            end;
          end;
        END;
      end;
    end;

//Log(aint(Rso.R.Reservierungnr)+':'+cnvad(Rso.R.Plan.StartDat)+':'+cnvat(Rso.R.Plan.StartZeit)+' '+cnvad(Rso.R.Plan.EndDat)+':'+cnvat(Rso.R.Plan.EndZeit));

  END;

  if (vFirst) then begin
    TRANSOFF;
//TRANSBRK;
  end;

  // "Linke" Grenze beachten bei JIT...
  if (vAntwort='JIT') or (vAntwort='JIT+ASAP') then begin
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=TextInfo(vTxt, _TextLines)) do begin
      vA # TextLineRead(vTxt, vI, 0);
      if (Str_token(vA,'|',1)<>'BAPOS') then CYCLE;

      vB # Str_Token(vA, '|', 2);
      if (Lib_Berechnungen:IntsAusAlpha(vB, var BAG.P.Nummer, var BAG.P.Position, var Auf.SL.lfdNr)=false) then CYCLE;
      Erx # RecRead(702,1,0);

      // Input loopen...
      vDat # 31.12.2099;
      FOR Erx # RecLink(701,702,2,_RecFirst)
      LOOP Erx # RecLink(701,702,2,_RecNext)
      WHILE (Erx<=_rLocked) do begin
        if (BAG.IO.Materialtyp=c_IO_Theo) then begin
          if (BAG.IO.Artikelnr<>'') then begin
            Erx # RecLink(250,701,8,_recFirst);   // Artikel holen
            if (Erx<=_rLocked) then begin
              // Kleinsten Beschaffungszeitraum holen
              // Preise loopen...
              FOR Erx # RecLink(254,250,6,_recFirst)
              LOOP Erx # RecLink(254,250,6,_recNext)
              WHILE (Erx<=_rLocked) do begin
                if (Art.P.Preistyp<>'EK') then CYCLE;
                if (Art.P.LieferTage=0) then CYCLE;
                vDat2 # today;
                vDat2->vmDayModify(Art.P.LieferTage);
                vDat # Min(vDat2, vDat);
              END;
            end;
          end;
        end;
      END;
      if (vMin->vpDate<vDat) then begin
//debug('UNTER LINKEN GRENZE :'+cnvad(vDat));
        if (vAntwort='JIT+ASAP') then begin
        // wenn JIT zu früh, dann mal ASAP...
          vRedoAsap # true;
        end;
      end;
    END;
  end;

  // Finale Termine in den Auftrag schreiben...
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=TextInfo(vTxt, _TextLines)) do begin

    vA # TextLineRead(vTxt, vI, 0);
    if (Str_token(vA,'|',1)<>'AUF') then CYCLE;
    vDat # cnvda(Str_token(vA, '|',3));
    vDat->vmDayModify(1);
    vB # Str_Token(vA, '|', 2);

    if (Lib_Berechnungen:IntsAusAlpha(vB, var Auf.P.Nummer, var Auf.P.Position, var Auf.SL.lfdNr)) then begin
      Erx # Auf_Data:Read(Auf.P.Nummer, Auf.P.Position, false, Auf.SL.LfdNr)
      if (Erx=401) then begin
        Erx # RecRead(401,1,_RecLock);
        Auf.P.Termin2Wunsch # vDat;
        Lib_Berechnungen:ZahlJahr_aus_Datum(Auf.P.Termin2Wunsch, Auf.P.Termin1W.Art, var Auf.P.Termin2W.Zahl,var Auf.P.Termin2W.Jahr);
        RekReplace(401);
        BAG.P.Position # cnvia(Str_Token(vA, '|', 4));

        if (vReDoAsap) then vA # 'Y'
        else vA # 'N';
        if (Auf.P.Termin2Wunsch>Auf.P.Termin1Wunsch) then begin
//debugx('RECHTS DRÜBER!!!');
//          if (vAntwort='ASAP') then begin
          RunAFX('BAG.Planung.AufPosTerminProblem', vA);
//          end;
        end
        else begin
          RunAFX('BAG.Planung.AufPosTerminIstOK', vA);
        end;

      end;
    end;
  END;

  if (v702<>0) then RekRestore(v702);

  TextClose(vTxt);

  if (vRedoAsap) then begin
//log('redoasap');
    SFX_Std_BAG:PlanungAsap(true, vUsername);
    RETURn vErg;
  end;

   SetTermFinished(vUsername, vRequestID);   // 05.10.2020 AH

//log('END !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
  RETURN vErg;
end;

//=========================================================================
//=========================================================================
//=========================================================================