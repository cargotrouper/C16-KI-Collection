@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Termine
//                        OHNE E_R_G
//  Info
//
//
//  06.08.2003  ST  Erstellung der Prozedur
//  04.03.2015  AH  "GetTypeNummer"
//  25.05.2020  AH  Termintypen als eigene Datei 857
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB GetBasisTyp(aTyp : alpha) : alpha;
//    SUB GetTypeName(aKuerzel : alpha) : alpha;
//    (SUB GetTypeNummer(aKuerzel : alpha): int;)
//    SUB GetTypeKrzl(aText : alpha) : alpha;
//    SUB GetCodeText(aCode : alpha; aID1 : int; aID2 : int) : alpha;
//    SUB get_hours(sAnfDat : date; sanftime : time; sEnddat : date; sEndtime : time) : float
//
//========================================================================
@I:Def_Global

//========================================================================
//  GetBasisTyp
//
//========================================================================
sub GetBasisTyp(
  aTyp : alpha;
): alpha;
local begin
  Erx   : int;
  v857  : int;
  vA    : alpha;
end;
begin
  v857 # RecBufCreate(857);
  v857->TTy.Typ2 # StrCut(aTyp,1,3);
  Erx # RecRead(v857,1,0);
  if (Erx<=_rLocked) then begin
    vA # v857->TTy.Typ;
  end;
  RecBufDestroy(v857);
  RETURN vA;
end;

//========================================================================
//  GetTypeName
//  Erwartet das Typenkürzel oder die Auswahl ID und gibt die lange Beschreibung zurück
//========================================================================
sub GetTypeName(
  aKuerzel    : alpha;       // Kürzel wird übergeben
  opt aBasis  : logic;
): alpha;
local begin
  Erx   : int;
  v857  : int;
  vA    : alpha;
end;
begin
  if (aBasis=false) then begin
    // 25.05.2020 AH: Termintypen als eigene Datei
    v857 # RecBufCreate(857);
    v857->TTy.Typ2 # StrCut(aKuerzel,1,3);
    Erx # RecRead(v857,1,0);
    if (Erx<=_rLocked) then begin
      vA # v857->TTy.Bezeichnung;
    end;
    RecBufDestroy(v857);
    RETURN vA;
  end;
  
  case aKuerzel of
    'WVL','1'  : RETURN(Translate('Wiedervorlage'));
    'TER','2'  : RETURN(Translate('Termin'));
    'AFG','3'  : RETURN(Translate('Aufgabe'));
    'TEL','4'  : RETURN(Translate('Telefonat'));
    'BRF','5'  : RETURN(Translate('Brief'));
    'FAX','6'  : RETURN(Translate('Fax'));
    'EMA','7'  : RETURN(Translate('EMail'));
    'SMS','8'  : RETURN(Translate('SMS'));
    'GSV','9'  : RETURN(Translate('Geschenkversand'));
    'BSP','10' : RETURN(Translate('Besprechung'));
    'INF','11' : RETURN(Translate('Info'));
    'WOF','12' : RETURN(Translate('Workflow'));
    'DSK','13' : RETURN(Translate('Diskussion'));
  end;
  RETURN '';

end;


//========================================================================
//  GetTypeNummer
//  Erwartet das Typenkürzel und gibt die Auswahl-ID zurück
//========================================================================
/*** 25.05.2020 AH
sub GetTypeNummer(
  aKuerzel : alpha;       // Kürzel wird übergeben
): int;
begin
  case aKuerzel of
    'WVL' : RETURN 1;
    'TER' : RETURN 2;
    'AFG' : RETURN 3;
    'TEL' : RETURN 4;
    'BRF' : RETURN 5;
    'FAX' : RETURN 6;
    'EMA' : RETURN 7;
    'SMS' : RETURN 8;
    'GSV' : RETURN 9;
    'BSP' : RETURN 10;
    'INF' : RETURN 11 ;
    'WOF' : RETURN 12;
    'DSK' : RETURN 13;
  end;

  RETURN 0;
end;
***/

//========================================================================
//  GetTypeKrzl
//  Erwartet den Typentext oder die Auswahl ID und gibt Kürzel zurück
//========================================================================
sub GetTypeKrzl(
  aText : alpha;       // Kürzel wird übergeben
): alpha;
begin
  case aText of
    Translate('Wiedervorlage')  ,'1'   : RETURN ('WVL');
    Translate('Termin')         ,'2'   : RETURN ('TER');
    Translate('Aufgabe')        ,'3'   : RETURN ('AFG');
    Translate('Telefonat')      ,'4'   : RETURN ('TEL');
    Translate('Brief')          ,'5'   : RETURN ('BRF');
    Translate('Fax')            ,'6'   : RETURN ('FAX');
    Translate('EMail')          ,'7'   : RETURN ('EMA');
    Translate('SMS')            ,'8'   : RETURN ('SMS');
    Translate('Geschenkversand'),'9'   : RETURN ('GSV');
    Translate('Besprechung')    ,'10'  : RETURN ('BSP');
    Translate('Info')           ,'11'  : RETURN ('INF');
    Translate('Workflow')       ,'12'  : RETURN ('WOF');
    Translate('Diskussion')     ,'13'  : RETURN ('DSK');
  end;
end;


//========================================================================
//  GetCodeText
//  Erwartet das Typen Kürzel und gibt die lange Beschreibung zurück
//========================================================================
sub GetCodeText(
  aCode : alpha;      // Kürzel wird übergeben
  aID1  : int;        // Nummer
  aID2  : int;        // Position
): alpha;
local begin
  Erx   : int;
  tText : alpha;
  tUser : alpha;
end;
begin

  if (aID1 <> 0) OR (aID2 <> 0) then begin

    case aCode of

      // Auftrag
      'AUF' : begin
        Auf.P.Nummer    # TeM.A.ID1;
        Auf.P.Position  # TeM.A.ID2;
        Erx # RecRead(401,1,0);
        if (Erx<_rLocked) then
          tText # Translate('Auftrag') + ' ' + Auf.P.KundenSw;
      end;

      // Bestellung
      'EIN' : begin
        Ein.P.Nummer    # TeM.A.ID1;
        Ein.P.Position  # TeM.A.ID2;
        Erx # RecRead(501,1,0);
        if (Erx<_rLocked) then
          tText # Translate('Bestellung') + ' ' + Ein.P.LieferantenSw;
      end;

      // Adresse
      'ADR' : begin
        Adr.Nummer # TeM.A.ID1;
        Erx # RecRead(100,1,0);
        if (Erx<_rLocked) then
          tText # Translate('Kunde') + ' ' + Adr.Name;
      end;

      // Ansprechpartner
      'ANP' : begin
         Adr.P.Adressnr # TeM.A.ID1;
         Adr.P.Nummer   # TeM.A.ID2;
         Erx # RecRead(102,1,0);
         if (Erx<_rLocked) then
           tText  # Translate('Ansprechpartner') +  ' '+ Adr.P.Vorname + ' ' + Adr.P.Name;
       end;

      // Materialkarte
      'MAT' : begin
          Mat.Nummer  # TeM.A.ID1;
          Erx #  RecRead(200,1,0)
          if (Erx<_rLocked) then
            tText # Translate('Materialkarte Nr.:') + ' ' + cnvAi(Mat.Nummer);
      end;

    end;  // CASE

  end else begin
    tUser # Usr.UserName;       // Alten user merken
    Usr.Username # aCode;
    if (RecRead(800,1,0) = _rOk) then
      tText #  Translate('Mitarbeiter') + ' ' + Usr.Vorname + ' ' + Usr.Name
    else
      tText # Translate('Falscher Code');
   // RESTORE
//    Usr.Username # tUser;
//    RecRead(800,1,0);
    Usr_data:RecReadThisUser();
  end;

  RETURN (tText);
end;
// Caltime


//========================================================================
// get_hours
// liefert die Stunden zwischen 2 Zeitpunkten
//
//========================================================================
sub get_hours(
                sAnfDat  : date;  // Anfangsdatum
                sanftime : time;  // Zeitpunkt am Anfangsdatunmstag
                sEnddat  : date;  // Endedatum
                sEndtime : time   // Zeitpunkt am Endedatum
              ) : float
local begin

   summe : int;
  summe2 : int;
  summe3 : int;
  kosten : float;
  ierr : int;
  temp : int;
  zZeit : int;
  mm    : int;
  mmm   : float;
  zz    : int;
  sAnftagzeit  : float;
  between : int;
  sHours  : float;
end

bEGIN
  sHours # 0.0;
  if (cnvid(sanfdat) = 0) Then
  begin
    return(sHours)
  end;

  if (cnvid(sendDat) = 0) then
  begin
    sEnddat #  sanfdat;
  end;
   zZeit # cnvid(senddat) - cnvid(sanfdat);
   zz # zzeit;
   mm # cnvit(sEndtime) - cnvit(sAnftime);  // differenz für anfangdatum = endedatum
   mmm # cnvfi(mm)/3600000.00; //in Stunden umrecnen
  if (zzeit = 0) then // amSelben Tag
  begin
     // RX.AK.BEARB.ZEIT.2 # cnvfi(zZeit)+ mmm; // /3600000.00;
     sHours # cnvfi(zZeit)+ mmm;  // d.h 0 + mmm !!!
  end   else
  begin
     between  # zz -1; // Tage zwischen 1. und letztem Tag
                            // - diff = 1 -> kein Tag dawischen, nur Anfangs und Endtag
                            // - diff = 2 -> ein Tag dazwischen usw
          // zz # zz -2;  // 1. und letzter Tag raus !!
          if (between = 0) then
          begin

            sAnfTagzeit # 24.00 - cnvfi(cnvit(sAnftime))/3600000.00; // Rest des ANfangstages
            // RX.AK.BEARB.ZEIT.2 # cnvfi(cnvit(sEndtime))/3600000.00 + sAnfTagZeit
            sHours # cnvfi(cnvit(sEndtime))/3600000.00 + sAnfTagZeit;
            // nur die Stunden Rest ANfabngsTag + angebrochene Zeit endeTag
          end   else
          begin
             // 1. und letzter Tag wie oben wie oben, ganze Tage dazwichen -> Mult
             zz # zz -1;

             sAnfTagzeit # 24.00 - cnvfi(cnvit(sANftime))/3600000.00;
             // RX.AK.BEARB.ZEIT.2 # cnvfi(zz*24)+  cnvfi(cnvit(sendtime))/3600000.00 + sAnfTagZeit;
             sHours # cnvfi(zz*24)+  cnvfi(cnvit(sendtime))/3600000.00 + sAnfTagZeit;
          end;
   end;

   return(sHours);
end;

//============================================================================================