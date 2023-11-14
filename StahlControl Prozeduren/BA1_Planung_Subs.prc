@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Planung_Subs
//                  OHNE E_R_G
//  Info
//
//
//  18.07.2018  AH  Erstellung der Prozedur
//  10.08.2018  AH  Konflikte in Vergangenheit sind kein FEhler, sondern nur Warnung
//  15.10.2018  AH  "FindeKommissionsTermin"
//  22.03.2019  ST  Statusanzeige "bereit" Hack für fertiggemeldete Fahraufträge, die noch nicht abgeschlossen sind
//  30.09.2019  AH  Statusanzeige prüft JEDESN Input und davon auch den Status (falls gesperrt/QS)
//  16.02.2021  ST  "SetSonderDauer" um Kosten Erweitert Projekt 2160/3
//  11.10.2021  AH  ERX
//
//  Subprozeduren
//  sub KTextBuild(aTxt : int; aGrp : int; aDat : date; aTim : time) : logic
//  sub KTextFind(aTxt : int; var aDat1 : date; var aTim1 : time; aDau : int; var aDat2 : date; var aTim2 : time) : logic;
//  sub Get701Mat();
//  sub GetSonderDauer() : int;
//  sub SetSonderDauer(aBem : alpha; aDauer : int; opt aKostenH : float;)
//  sub GetStatus(aTxt : int) : alpha;
//  sub CheckAbhaenigkeiten(aTxt : int; aDL : int; aClmStart : int; aClmEnde : int; aClmBAG  : int) : logic
//  sub CheckKonflikte(aTxt : int; aDL  : int; aClmStart : int; aClmEnde : int; aClmBAG : int) : logic;
//  sub FindeKommissionsTermin()
//
//  sub EvtDragInit...
//  sub EvtDropEnter..
//  sub EvtDropLeave...
//  sub EvtDragTerm...
//  sub EvtTerm...
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG
@I:Def_Aktionen

define begin
//  cDebug      : (gUsername='AH')
  cKeinKal          : 'KEIN KALENDER'
  cSonderZeitTyp    : 100
  cClmRecID         : 1
  cMDI              : gMdiMath
end;

//========================================================================
//========================================================================
sub _KTextPart(
  aTxt  : int;
  aDat  : date;
  aVon  : time;
  aBis  : time) : logic;
local begin
  vI    : int;
end;
begin

  //  Format: "D"Datum|von|bin

  if (aVon=24:0) and (aBis=24:0) then
    RETURN false;

  if (aVon=0:00) and (aBis=0:00) then begin
    TextAddLine(aTxt, cnvad(aDat)+'|00:00|24:00')
    RETURN true
  end;

  if (aBis=0:0) then aBis # 24:00;

  TextAddLine(aTxt, cnvad(aDat)+'|'+cnvat(aVon)+'|'+cnvat(aBis));//+'|'+aint(vI));

  RETURN true;
end;


//========================================================================
//========================================================================
sub _KTextTyp(
  aTxt  : int;
  aDat  : date)
local begin
  vOK   : logic
end;
begin
//debugx(Rso.Kal.Tag.Typ+' : '+cnvat(Rso.Kal.Tag.Von1Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis1Zeit)+'   '+cnvat(Rso.Kal.Tag.Von2Zeit)+'-'+cnvat(Rso.Kal.Tag.Bis2Zeit));
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von1Zeit, Rso.Kal.Tag.Bis1Zeit);
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von2Zeit, Rso.Kal.Tag.Bis2Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von3Zeit, Rso.Kal.Tag.Bis3Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von4Zeit, Rso.Kal.Tag.Bis4Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von5Zeit, Rso.Kal.Tag.Bis5Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von6Zeit, Rso.Kal.Tag.Bis6Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von7Zeit, Rso.Kal.Tag.Bis7Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von8Zeit, Rso.Kal.Tag.Bis8Zeit) or vOK;
  vOK # _KTextPart(aTxt, aDat, Rso.Kal.Tag.Von9Zeit, Rso.Kal.Tag.Bis9Zeit) or vOK;

  // ganzer Tag?
  if (vOK=false) then
    _KTextPart(aTxt, aDat, 0:0, 24:0);
end;


//========================================================================
//========================================================================
sub KTextBuild(
  aTxt  : int;
  aGrp  : int;
  aDat  : date) : logic
local begin
  Erx   : int;
  vOK   : logic
end;
begin

  TextClear(aTxt);

  Rso.Kal.Gruppe  # aGrp;
  Rso.Kal.Datum   # aDat;
  Erx # RecRead(163,1,0);
  if (Erx>=_rLastRec) then RETURN false;

  WHILE (Erx<_rLastRec) and (Rso.Kal.Gruppe=aGrp) and (Rso.Kal.Datum>=aDat) do begin
    Erx # RecLink(164,163,1,_recFirst); // TYP holen
    if (Erx<=_rLocked) then begin
      _KTextTyp(aTxt, Rso.Kal.Datum);
    end;

    Erx # RecRead(163,1,_recNext);
  END;

  RETURN true;
end;


//========================================================================
sub _TimDiff(
  aVon  : time;
  aBis  : time) : int;
begin
  if (aBis=0:0) then
    RETURN 1440 - (cnvit(aVon)/60000);
  
  RETURN (cnvit(aBis)/60000) - (cnvit(aVon)/60000);
end;


//========================================================================
//========================================================================
sub KTextFirstStart(
  aTxt      : int;
  var aDat  : date;
  var aTim  : time;
) : logic;
local begin
  vA        : alpha;
end;
begin
  //Mittwoch|10:00|17:00
  // Tage gefunden, passt Zeit?
  vA # TextLineRead(aTxt, 1, 0);
  if (vA='') then RETURN false;
  
  aDat # cnvda(Str_Token(vA, '|',1));
  aTim # cnvta(Str_Token(vA, '|',2));

  RETURN true;
end;


//========================================================================
//========================================================================
sub KTextFind(
  aTxt      : int;
  var aDat1 : date;
  var aTim1 : time;
  aDau      : int;
  var aDat2 : date;
  var aTim2 : time;
) : logic;
local begin
  vTry  : int;
  vI,vZ : int;
  vA    : alpha;
  vVon  : time;
  vBis  : time;
end;
begin
//debug('suche start '+cnvad(aDat1)+' '+cnvat(aTim1));
  vZ # 1;
  WHILE (vTry<20) do begin
    vI # TextSearch(aTxt,vZ, 1, _TextSearchCI, cnvad(aDat1)+'|');
    if (vI=0) then begin
      inc(vTry);
      vZ # 1;
      aDat1->vmDayModify(1);
      aTim1 # 0:0;
      CYCLE;
    end;
    vZ # vI;

    //Montag|12:00|15:00
    //Dienstag|08:00|10:00
    //Dienstag|12:00|15:00
    //Dienstag|16:00|17:00
    //Mittwoch|10:00|17:00

    // Tage gefunden, passt Zeit?
    vA # TextLineRead(aTxt, vI, 0);
    vVon # cnvta(Str_Token(vA, '|',2));
    vBis # cnvta(Str_Token(vA, '|',3));
    // Spanne ist FRÜHER?
    if (vBis<=aTim1) then begin
      vZ # vZ + 1;  // nächste Zeile prüfen
      CYCLE;
    end;

    // Spanne ist SPÄTER?
    if (vVon>aTim1) then begin
      aTim1 # vVon;
    end
    else begin
    // Spanne umfasst TIM
    end;

    BREAK;
  END;
  if (vTry=20) then RETURN false;

//debugx('      start wäre '+cnvad(aDat1)+' '+cnvat(aTim1)+'    Z:'+aint(vZ)+' '+vA);

  // ENDE bestimmen
  aDat2 # aDat1;
  aTim2 # aTim1;
  WHILE (aDau>0) do begin
    vI # _TimDiff(aTim2, vBis);
//debugx('Rest diesne Tag :'+aint(vI));
    // Mehr Zeit als nötig?
    if (vI>aDau) then begin
      aTim2->vmSecondsModify(aDau*60);
//debugx('      ENDE '+cnvad(aDat2)+' '+cnvat(aTim2)+'    Z:'+aint(vZ)+' '+vA);
      RETURN true;
    end;
    aDau # aDau - vI;

//debugx('restliche Dauer : '+aint(aDau));
    vZ # vZ + 1;
    vA # TextLineRead(aTxt, vZ, 0);
    if (vA='') then RETURN false;   // KEINE ZEILEN MEHR???
//debug('nächster Te = '+vA);
    aDat2 # cnvda(Str_Token(vA,'|',1));
    vVon # cnvta(Str_Token(vA, '|',2)); // Montag wieder
    vBis # cnvta(Str_Token(vA, '|',3));
    aTim2 # vVon;
  END

//debugx('      ENDE '+cnvad(aDat2)+' '+cnvat(aTim2)+'    Z:'+aint(vZ)+' '+vA);
  RETURN true;
end;


//========================================================================
//========================================================================
sub Get701Mat();
local begin
  Erx   : int;
  v701  : int;
end;
begin

  v701 # RekSave(701);
  if (BAG.IO.Materialnr<>0) then begin
    if (Mat_Data:Read(BAG.IO.Materialnr)<200) then RecbufClear(200);
  end
  else begin
    if (BAG.IO.Materialtyp=c_IO_BAG) then begin
      if (BAG.IO.UrsprungsID<>BAG.IO.ID ) and (BAG.IO.UrsprungsID<>0) then begin
        BAG.IO.ID # BAG.IO.UrsprungsID;
        Erx # RecRead(701,1,0);
        if (Erx<=_rLocked) then Get701Mat();
//debugx('gehe zum Vorgänger KEY702 KEY200');
      end;
    end;
  end;
  RekRestore(v701);

end;



//========================================================================
//========================================================================
sub GetSonderDauer() : int;
local begin
  Erx : int;
end;
begin
  FOR Erx # RecLink(709,702,6,_recFirst)  // Zeiten loopen
  LOOP Erx # RecLink(709,702,6,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.Z.Fertigmeldung<>0) or (BAG.Z.Fertigung<>0) then CYCLE;

    if (BAG.Z.ZeitenTyp=cSonderZeitTyp) then begin
      RETURN cnvif(BAG.Z.Dauer);
    end;
  END;
  RETURN 0;
end;



//========================================================================
//========================================================================
sub SetSonderDauer(
  aBem         : alpha;
  aDauer       : int;
  opt aKostenH : float;
)
local begin
  Erx : int;
end;
begin

  FOR Erx # RecLink(709,702,6,_recFirst)  // Zeiten loopen
  LOOP Erx # RecLink(709,702,6,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.Z.Fertigmeldung<>0) or (BAG.Z.Fertigung<>0) then CYCLE;

    if (BAG.Z.ZeitenTyp=cSonderZeitTyp) then begin
      // Löschen???
      if (aDauer=0) then begin
        RekDelete(709);
        RETURN;
      end;
      RecRead(709,1,_RecLock);
      BAG.Z.Dauer           # cnvfi(aDauer);
      BAG.Z.GesamtkostenW1  # Rnd(Bag.Z.Dauer/60.0*aKostenH,2);
      BAG.Z.Bemerkung       # aBem;
      RekReplace(709);
      RETURN;
    end;
  END;

  // NEU anlegen
  if (aDauer<>0) then begin
    RecbufClear(709);
    BAG.Z.Nummer          # BAG.P.Nummer;
    BAG.Z.Position        # BAG.P.Position;
    BAG.Z.Zeitentyp       # cSonderZeitTyp;
    BAG.Z.Bemerkung       # aBem;
    BAg.Z.Dauer           # cnvfi(aDauer);
    BAG.Z.GesamtkostenW1  # Rnd(Bag.Z.Dauer/60.0*aKostenH,2);
    
    REPEAT
      BAG.Z.lfdNr # BAG.Z.LfdNr + 1;
      Erx # RekInsert(709);
    UNTIL (Erx=_rOK);
  end;
  
end;



//========================================================================
//========================================================================
sub GetStatus(
  aTxt      : int;
  ) : alpha;
local begin
  Erx   : int;
  v701  : int;
  v702  : int;
  v702b : int;
  vA,vB : alpha;
  vA2   : alpha;
  vI    : int;
  vEcht : logic;
end;
begin

//debugx('suche status zu KEY702');

  vI # TextSearch(aTxt, 1, 1, _TextSearchCI, 'STATUS'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
  if (vI<>0) then begin
    vA # TextLineRead(aTxt, vI, 0);
//debug('          => '+vA);
    RETURN vA;
  end;


  vA # '';
  if (BAG.P.Fertig.Dat<>0.0.0) then begin
    vA # 'fertig';
    if (BAG.P.Aktion=c_BAG_Check) then begin
      FOR Erx # RecLink(707,702,5,_recFirst)    // FMs loopen
      LOOP Erx # RecLink(707,702,5,_recNext)
      WHILE (Erx<=_rLocked) and (vA<>'') do begin
        // wenn nicht alle FMs der QS bewertet sind, dann ist die QS-Pos NICHT fertig!!!
        if (BAG.FM.Status=c_Status_BAGfertSperre) or (BAG.FM.Status=c_Status_BAGfertUnklar) then vA # '';
      END;
    end;
  end;

  if (vA='') then begin
    v702 # RekSave(702);

    // 24.03.2020 AH BSP: beim Fahren bedeutet EINE FM, dass alles
    if (Set.InstallName='BSP') and (BAG.P.Aktion=c_BAG_Fahr09) then begin
      if (RecLinkInfo(707,702,5,_recCount)>0) then vA # 'fertig';
    end;
    
    if (vA='') then begin
      FOR Erx # RecLink(701,v702,2,_recFirst)    // Input loopen
      LOOP Erx # RecLink(701,v702,2,_recNext)
      WHILE (Erx<=_rLocked) do begin

        if (BAG.IO.Materialtyp=c_IO_Mat) then begin

          // 18.05.2020 AH; Proj. 2042/104
          if (Mat_Data:Read(BAG.IO.Materialnr)<200) then begin
            vA # 'fehlt';
            CYCLE;
          end;
          if (Mat.Status=758) then begin      // noch keine Freigabe der QS??
            CYCLE;
          end;
    
          // Lagerentnahme?
          if (BAG.IO.VonFertigmeld=0) then begin
            vA # 'bereit';
            CYCLE;
          end;
          
          // 30.09.2019 auf SPERRE prüfen:
          Erx # RecLink(707,701,18,_recFirst);    // FM holen
          if (Erx>_rLocked) then CYCLE;
          if (BAG.FM.Status=c_Status_BAGfertSperre) or (BAG.FM.Status=c_Status_BAGfertUnklar) then begin
            Erx # RecLink(702,701,2,_RecFirst);     // VonPos holen
            Erx # RecLink(828,702,8,_recFirst);     // Arbeitsgang holen
            vA # 'zum '+ArG.Bezeichnung+' (Pos.'+aint(BAG.P.Position)+')';
            vI # TextSearch(aTxt, 1, 1, _TextSearchCI, 'BA'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
            if (vI>0) then begin
              vB # TextLineRead(aTxt, vI, 0);
              vB # Str_Token(vB, '|',2);
              if (vB<>'') then
                vA # vA + ', Stich '+vB;
            end;
            BREAK;
          end;
          vA # 'bereit';
          CYCLE;  // 30.09.2019
          //BREAK;
        end;

        if (BAG.IO.VonFertigmeld<>0) then CYCLE;

        if (BAG.IO.Materialtyp=c_IO_Theo) then begin
          vA # 'warte auf Material';
          BREAK;
        end;


        if (BAG.IO.Materialtyp=c_IO_BAG) then begin
          Erx # RecLink(702, 701,2,_RecFirst);    // VonPos holen
          if (Erx<=_rLocked) then begin
            vA # Str_Token(GetStatus(aTxt),'|',2);
            if (vA='fertig') then begin
              vA # 'bereit';
              CYCLE;  // 30.09.2019 weitere prüfen
              //BREAK;
            end;

            if (vA='bereit') then begin
              if (BAG.P.Aktion = c_BAG_Fahr) then begin
              // ST 2019-03-22 "Hack" für fertiggemeldete Fahraufträge, die noch nicht abgeschlossen sind
                if (RecLinkInfo(707,702,5,_RecCount) > 0) then BREAK;
              end;

              Erx # RecLink(828,702,8,_recFirst);   // Arbeitsgang holen
              vA # 'zum '+ArG.Bezeichnung+' (Pos.'+aint(BAG.P.Position)+')';

              vI # TextSearch(aTxt, 1, 1, _TextSearchCI, 'BA'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
              if (vI>0) then begin
                vB # TextLineRead(aTxt, vI, 0);
                vB # Str_Token(vB, '|',2);
                if (vB<>'') then
                  vA # vA + ', Stich '+vB;
              end;
              BREAK;
            end;
          end;

        end;
      end;

    END;

    RekRestore(v702);
  end;

  if (vA='') then vA # '???';

  vA # 'STATUS'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+'|'+vA;
//debug('SETb KEY702 '+vA);
  TextAddLine(aTxt, vA);
  RETURN vA;
end;


//========================================================================
//========================================================================
sub CheckAbhaenigkeiten(
  aMdi        : int;
  aDlPlanName : alpha;  // +1, +2, +3 etc. autoamtisch
  aTxt        : int;
  aClmStart   : int;
  aClmEnde    : int;
  aClmBAG     : int;
  opt aStart  : alpha;
  opt aEnde   : alpha;
  ) : logic
local begin
  vPlannr     : int;
  vName       : alpha;
  vDL         : int;
  vI,vJ       : int;
  vErrTxt     : int;
  vA, vB      : alpha;
  vBA         : alpha;
  vID         : int;
  vZ          : int;
  v702        : int;
  vCT         : caltime;
  vCT2        : caltime;
  vCTGrenze   : caltime;
  vErr        : alpha(1000);
  vRTF        : int;
  vOK         : logic;
  vOffset     : int;
  vTagName    : alpha[10];
  vCancel     : logic;
  vFirst      : logic;
  vDLvorher   : int;
  Erx         : int;
end;
begin

  vErrTxt # TextOpen(16);

  vPlannr # 1;
  vDL # Winsearch(aMdi,aDLPlanName);
  if (vDL=0) then begin
    vName # aDLPlanName+aint(vPlanNr);
  end
  else begin
    vName # aDLPlanname;
  end;
  
  FOR vDL # Winsearch(aMdi,vName)
  LOOP vDL # Winsearch(aMdi,vName)
  WHILE (vDL<>0) do begin
    vOffset # vPlanNr * 1000;
    vTagName[vPlannr] # vDL->wpCustom;
    
    // alle Einträge aufnehmen...
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)) do begin
      WinLstCellGet(vDL, vID,   cClmRecId, vI);
      WinLstCellGet(vDL, vBA,   aClmBAG, vI);

      if (aClmStart<>0) then begin
        WinLstCellGet(vDL, vA,    aClmStart, vI);
        WinLstCellGet(vDL, vB,    aClmEnde, vI);
      end
      else begin
        vA # aStart;
        vB # aEnde;
      end;
      TextAddLine(aTxt, 'B'+vBA+'|'+aint(vI+vOffset)+'|'+vA+'|'+vB);    // Merke: B1234/1|9|12.12.2018 12:00|12.12.2018 14:00
    END;

    inc(vPlannr);
    vName # aDLPlanName+aint(vPlanNr);
  END;


  vPlannr # 1;
  vDL # Winsearch(aMdi,aDLPlanName);
  if (vDL=0) then begin
    vName # aDLPlanName+aint(vPlanNr);
  end
  else begin
    vName # aDLPlanname;
  end;
  
  vFirst # true;
  vDLvorher # 0;


  FOR vDL # Winsearch(aMdi,vName)
  LOOP vDL # Winsearch(aMdi,vName)
  WHILE (vDL<>0) do begin

    // 02.12.2019 TM
    if vFirst then begin
      vFirst # false;
      vDLvorher # vDL;
    end
    else begin
      if vDL != vDLvorher then
        vDLVorher # vDL;
      else
        BREAK;
    end;

  
    
    
    vOffset # vPlanNr * 1000;

    FOR vI # 1 + vOffset
    LOOP inc(vI)
    WHILE (vI<=WinLstDatLineInfo(vDL, _WinLstDatInfoCount)+vOffset) do begin
      WinLstCellGet(vDL, vID,   cClmRecId, vI - vOffset);
      WinLstCellGet(vDL, vBA,   aClmBAG, vI - vOffset);

      if (aClmStart<>0) then begin
        WinLstCellGet(vDL, vA,    aClmStart, vI - vOffset);
        WinLstCellGet(vDL, vB,    aClmEnde, vI - vOffset);
      end
      else begin
        vA # aStart;
        vB # aEnde;
      end;

      Erx # RecRead(702, 0,_recId,vID);
      If (Erx<>_rOK) then begin
        TextAddLine(vErrTxt, 'BA-Pos. '+vBA+' nicht gefunden!');
        CYCLE;
      end;


      if (vA<>cKeinKal) then begin
        v702 # RekSave(702);
        // Vorgänger prüfen......................................
        vCT->vpDate     # cnvda(Str_Token(vA,' ',1));     // mein START
        vCT->vpTime     # cnvta(Str_Token(vA,' ',2));
        vCTGrenze # vCT;
        FOR Erx # RecLink(701,v702,2,_recFirst)    // Input loopen
        LOOP Erx # RecLink(701,v702,2,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.IO.Materialtyp<>c_IO_BAG) or (BAG.IO.VonFertigmeld<>0) or (BAG.IO.VonBAG=0) then CYCLE;
          vZ # TextSearch(aTxt,1, 1, _TextSearchCI, 'B'+aint(BAG.IO.VonBAG)+'/'+aint(BAG.IO.VonPosition)+'|');
          if (vZ<>0) then begin   // Ist in DIESER Planung...
            vA # TextLineRead(aTxt, vZ, 0);
            vJ # cnvia(Str_Token(vA,'|',2));
            if (vJ>=vI) then begin    // Abhängikeit verdreht?
              if (vDL->wpCustom<>'') then
                vErr # vTagName[vI div 1000]+' Zeile '+aint(vI%1000)+' MUSS NACH '+vTagName[vJ div 1000]+' Zeile '+aint(vJ%1000)+' liegen!'
              else
                vErr # 'Zeile '+aint(vI%1000)+' MUSS NACH Zeile '+aint(vJ%1000)+' liegen!';
             vErr # vErr + '(FEHLER)';
  //           vCancel # true;
            end;
          end
          else begin              // Ist NICHT in dieser Planung...
            Erx # RecLink(702,701,2,_recFirst);   // VonPos holen...
            if (Erx<=_rLocked) and (BAG.P.Plan.EndDat<>0.0.0) then begin
              vCT2->vpDate     # BAG.P.Plan.EndDat;
              vCT2->vpTime     # BAG.P.Plan.EndZeit;
              if (vCTGrenze<vCT2) then begin    // spätestes/max. Ende ermitteln
                vCTGrenze # vCT2;
                if (vDL->wpCustom<>'') then
                  vErr # vTagName[vI div 1000]+' Zeile '+aint(vI%1000)+': BA '+vBA+' muss NACH dem '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+' Uhr starten';
                else
                  vErr # 'Zeile '+aint(vI%1000)+': BA '+vBA+' muss NACH dem '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+' Uhr starten';
                vErr # vErr + '(FEHLER)';
  //              vCancel # true;
              end;
            end;
          end;
        END;    // Input
        if (vErr<>'') then
          TextAddLine(vErrTxt, vErr);
        vErr # '';

        
        // Nachfolger prüfen......................................
        vCT->vpDate     # cnvda(Str_Token(vB,' ',1));     // mein ENDE
        vCT->vpTime     # cnvta(Str_Token(vB,' ',2));
        vCTGrenze # vCT;
        FOR Erx # RecLink(701,v702,3,_recFirst)    // Output loopen
        LOOP Erx # RecLink(701,v702,3,_recNext)
        WHILE (Erx<=_rLocked) do begin
          if (BAG.IO.Materialtyp<>c_IO_BAG) or (BAG.IO.VonFertigmeld<>0) or (BAG.IO.NachBAG=0) then CYCLE;
          vZ # TextSearch(aTxt,1, 1, _TextSearchCI, 'B'+aint(BAG.IO.NachBAG)+'/'+aint(BAG.IO.NachPosition)+'|');
          if (vZ<>0) then begin   // Ist in DIESER Planung...
            vA # TextLineRead(aTxt, vZ, 0);
            vJ # cnvia(Str_Token(vA,'|',2));
            if (vJ<=vI) then begin    // Abhängikeit verdreht?
              if (vDL->wpCustom<>'') then
                vErr # vTagName[vI div 1000]+' Zeile '+aint(vI%1000)+' MUSS VOR '+vTagName[vJ div 1000]+' Zeile '+aint(vJ%1000)+' liegen!'
              else
                vErr # 'Zeile '+aint(vI%1000)+' MUSS VOR Zeile '+aint(vJ%1000)+' liegen!';
              vErr # vErr + '(FEHLER)';
  //            vCancel # true;
            end;
          end
          else begin              // Ist NICHT in dieser Planung...
            Erx # RecLink(702,701,4,_recFirst);   // NachPos holen...
            if (Erx<=_rLocked) and (BAG.P.Plan.StartDat<>0.0.0) then begin
              vCT2->vpDate     # BAG.P.Plan.StartDat;
              vCT2->vpTime     # BAG.P.Plan.StartZeit;
              if (vCTGrenze>vCT2) then begin    // früheste/min. Start ermitteln
                vCTGrenze # vCT2;
                if (vDL->wpCustom<>'') then
                  vErr # vTagName[vI div 1000]+' Zeile '+aint(vI%1000)+': BA '+vBA+' muss VOR dem '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+' Uhr enden'
                else
                  vErr # 'Zeile '+aint(vI%1000)+': BA '+vBA+' muss VOR dem '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+' Uhr enden';
                if (BAG.P.Plan.StartDat>today) then begin
  //                vCancel # true;
                  vErr # vErr + '(FEHLER)';
                end;
              end;
            end;
          end;
        END;    // Output
        if (vErr<>'') then
          TextAddLine(vErrTxt, vErr);
        vErr # '';
        
      END;  // Zeilen

      inc(vPlannr);
      vName # aDLPlanName+aint(vPlanNr);
    END;    // mehrere DLs loopen

    if (v702<>0) then begin
      RecBufDestroy(v702);
      v702 # 0;
    end;
  END;  // DLs


  vOK # true;
  if (TextInfo(vErrTxt, _TextLines)>0) then begin
    if (vCancel) then
      TextLineWrite(vErrTxt, 1, '\cf2\fs28Bitte lösen Sie zunächst folgende zeitlichen Probleme:\cf1\fs22', _TextLineInsert)
    else
      TextLineWrite(vErrTxt, 1, '\cf2\fs28Folgende zeitlichen Probleme entstehen:\cf1\fs22', _TextLineInsert);
    vRTF # TextOpen(16);
    Lib_Texte:Txt2Rtf(vErrTxt, vRTF, 'Calibre', 12, 0, (TextInfo(vRTF,_textLines)>0));
    Dlg_Standard:TooltipRTF(vRTF,'Info');
    TextClose(vRTF);
    if (vCancel) then begin
      vOK # false;
    end
    else begin
      vOK # (Msg(99,'Trotzdem speichern?',_WinIcoQuestion,_WinDialogOkCancel,2)=_Winidok);
    end;
  end;

  TextClose(vErrTxt);
  
  RETURN vOK;
end;


//========================================================================
//========================================================================
sub CheckKonflikte(
  aMDI        : int;
  aDlPlanName : alpha;  // +1, +2, +3 etc. autoamtisch
  aTxt        : int;
  aClmStart   : int;
  aClmEnde    : int;
  aClmBAG     : int;
) : logic;
local begin
  Erx     : int;
  vPLannr : int;
  vDL     : int;
  vName   : alpha;
  vI      : int;
  vID     : int;
  vA,vB   : alpha(1000);
  vDat    : date;
  vTim    : time;
  vErrTxt : int;
  vRTF    : int;
  vCT     : caltime;
  vCTvon  : caltime;
  vCTbis  : caltime;
  vErr    : int;
  vZ      : int;
end;
begin

  vPlannr # 0;
  vDL # Winsearch(aMdi,aDLPlanName);
  if (vDL=0) then begin
    vPlannr # 1;
    vName # aDLPlanName+aint(vPlanNr);
  end
  else begin
    vName # aDLPlanname;
  end;
  
  FOR vDL # Winsearch(aMdi,vName)
  LOOP vDL # Winsearch(aMdi,vName)
  WHILE (vDL<>0) do begin
    inc(vPlannr);
    vName # aDLPlanName+aint(vPlanNr);

  
    WinLstCellGet(vDL, vA,    aClmStart, 1);
    WinLstCellGet(vDL, vB,    aClmEnde, WinLstDatLineInfo(vDL, _WinLstDatInfoCount));
    If (vA=cKeinKal) or (vB=cKeinKal) then begin
      Msg(99,'Bitte Ressourcen-Kalender erst richtig ausfüllen!',0,0,0);
      RETURN false;
    end;
    if (vA='') then RETURN true;   // leere Liste?
    
    vErrTxt # TextOpen(16);
    vCTbis->vpDate # cnvda(Str_Token(vB,' ',1));
    vCTbis->vpTime # cnvta(Str_Token(vB,' ',2));
    RecBufClear(702);
    BAG.P.Ressource.Grp   # Rso.Gruppe;
    BAG.P.Ressource       # Rso.Nummer;
    BAG.P.Plan.EndDat     # cnvda(Str_Token(vA,' ',1));
    BAG.P.Plan.EndZeit    # cnvta(Str_Token(vA,' ',2));
    BAG.P.Plan.EndZeit->vmSecondsModify(1);
  //debug('check '+aint(BAG.P.Ressource.Grp)+'/'+aint(BAG.P.Ressource)+' @ '+cnvad(BAG.P.Plan.EndDat)+':'+cnvat(BAG.P.Plan.EndZeit));
    FOR Erx # RecRead(702,7,0)    // Position laut ENDTERMIN suchen...
    LOOP Erx # RecRead(702,7,_recNext)
    WHILE (Erx<_rLastRec) and (BAG.P.Ressource=Rso.Nummer) and (BAG.P.Ressource.Grp=Rso.Gruppe) do begin
  //debug('ERG FOUND '+aint(BAG.P.Ressource.Grp)+'/'+aint(BAG.P.Ressource)+' @ '+cnvad(BAG.P.Plan.StartDat)+':'+cnvat(BAG.P.Plan.StartZeit));
      if (BAG.P.Aktion=c_BAG_VSB) then CYCLE;

      // Ist diese Position teil DIESER Planung??
      vZ # TextSearch(aTxt,1, 1, _TextSearchCI, 'B'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+'|');
      if (vZ<>0) then begin   // Ist in DIESER Planung?? => dann überspringen
  //debug('ist mit hier');
        CYCLE;
      end;
     
      // ist SPÄTER?
      vCT->vpDate # BAG.P.Plan.StartDat;
      vCT->vpTime # BAG.P.Plan.StartZeit;
  //debugX('check '+cnvac(vCT,_FmtCaltimeRFC)+' >= '+cnvac(vCTbis,_FmtCaltimeRFC));
      if (vCT>=vCTbis) then BREAK;
  //debugx('ist NICHT so');
      if (vErr=0) then
        TextAddLine(vErrTxt, '\cf2\fs28Folgende Konflikte mit ANDEREN BAs würden entstehen:\cf1\fs22');
      inc(vErr);
      TextAddLine(vErrTxt, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' geplant für '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+' Uhr bis '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+' Uhr');
    END;

  END;  // mehrere DLs loopen


  if (TextInfo(vErrTxt, _TextLines)>0) then begin
    vRTF # TextOpen(16);
    Lib_Texte:Txt2Rtf(vErrTxt, vRTF, 'Calibre', 12, 0, (TextInfo(vRTF,_textLines)>0));
    Dlg_Standard:TooltipRTF(vRTF,'Info');
    TextClose(vRTF);
    if (Msg(99,'Trotzdem speichern?',_WinIcoQuestion,_WinDialogOkCancel,2)<>_Winidok) then begin
      Textclose(vErrTxt);
      RETURN false;
    end;
  end;
  Textclose(vErrTxt);
  
  RETURN true;
end;


//========================================================================
//  FindeKommissionsTermin
//    Loopt Fertigungen der Position bis VSB-Kunde und holt aus der Auftragspos. die Termine
//========================================================================
sub FindeKommissionsTermine(
  var aDat1 : date;
  var aDat2 : date;
  var aDat3 : date;
): logic
local begin
  Erx   : int;
  v702  : int;
  v701  : int;
  vOK   : logic;
end;
begin

  aDat1 # 0.0.0;
  aDat2 # 0.0.0;
  aDat3 # 0.0.0;
  
  v702 # RekSave(702);
  // 01.07.2020 AH: prüfen, ob überhaupt VSB-Schritt vorhanden ist...
  FOR Erx # RecLink(702,700,1,_recFirst)
  LOOP Erx # RecLink(702,700,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then BREAK;
  END;
  RecBufCopy(v702,702);
  if (Erx>_rLocked) then RETURN false;

  // Outputs loopen...
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.BruderID<>0) or (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
    if (BAG.IO.NachPosition=0) then CYCLE;

    // Weiterbearbeitungs-Fertigungs-IO gefunden...
    Erx # RecLink(702,701,4,_recFirst);   // Nach-Pos holen
    if (Erx<=_rLocked) then begin
      // Kunden-VSB gefunden?
      if (BAG.P.Typ.VSBYN) and (BAG.P.Auftragsnr<>0) then begin
        Erx # Auf_Data:read(BAG.P.Auftragsnr, BAG.P.AuftragsPos ,false);
        if (Erx>=400) then begin
// 08.11.2019
//          vDat # Auf.P.TerminZusage;
//          if (vDat=0.0.0) then vDat # Auf.P.Termin2Wunsch;
//          if (vDat=0.0.0) then vDat # Auf.P.Termin1Wunsch;
          aDat1 # Auf.P.TerminZusage;
          aDat2 # Auf.P.Termin1Wunsch;
          aDat3 # Auf.P.Termin2Wunsch;
        end;
        RekRestore(v702);
        RETURN true;
      end;
      v701 # RekSave(701);
//      vDat # FindeKommissionsTermin();
      vOK # FindeKommissionsTermine(var aDat1, var aDat2, var aDat3);
      RekRestore(v701);
//      if (vDat<>0.0.0) then BREAK;
      if (vOK) then BREAK;
    end;
    RecBufCopy(v702,702);
  END;
  
  RekRestore(v702);
  RETURN vOK;
end;


//========================================================================
// EvtDragInit
//========================================================================
sub EvtDragInit(
  aEvt                  : event;    // Ereignis
  aDataObject           : handle;   // Drag-Datenobjekt
  var aEffect           : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
  aMouseBtn             : int;      // Verwendete Maustasten (optional)
  aDataPlace            : handle;
  aModulname            : alpha;
) : logic;
local begin
  vCTE      : int;
  vI        : int;
  vID       : int;
  vItem     : int;
  vFormat   : int;
  vDragList : int;
end;
begin

//  if (gDragList=0) then
//    gDragList # CteOpen(_CteList);
//  CteClear(gDragList, y);

  aEffect # _WinDropEffectCopy | _WinDropEffectMove | _WinDropEffectLink;

  vCTE  # aEvt:Obj->wpSelData;
  // MULTI?
  if (vCTE<>0) then begin
    vCTE  # vCTE->wpData(_WinSelDataCteTree);

    FOR vItem # CteRead(vCte,_CteFirst)
    LOOP vItem # CteRead(vCte,_Ctenext, vItem)
    WHILE (vItem<>0) do begin
      vI # vItem->spID;
  //debugx('folge :'+aint(vID));
      WinLstCellGet(aEvt:Obj, vID, cClmRecID, vI);

  //debugx(vA+':'+aint(vI));
  //    if (vA='') then CYCLE;
      if (vDragList=0) then
        vDragList # CteOpen(_CteList);

      // Objekt in Liste einfügen
      vDragList->CteInsertItem(aint(vI), vI, aint(vID));
  //debugx('add');
    END;
  end
  else begin
    vI # aDataPlace->wpArgInt;
    WinLstCellGet(aEvt:Obj, vID, cClmRecID, vI);
    // SINGLE
    vDragList # CteOpen(_CteList);
    vDragList->CteInsertItem(aint(vI), vI, aint(vID));
//debugx('DRAG '+aint(vI)+' '+aint(vID));
  end;

  // Setzen der Informationen im Data-Objekt
  // Format aktivieren
  aDataObject->wpFormatEnum(_WinDropDataUser) # true;
  aDataObject->wpName   # aModulname;
  aDataObject->wpcustom # aint(aEvt:obj);

  // Format-Objekt ermittel und Daten anhängen
  vFormat # aDataObject->wpData(_WinDropDataUser);
  vFormat->wpData # vDragList;

  RETURN(true);
end;


//========================================================================
//  EvtDropEnter
//========================================================================
sub EvtDropEnter(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Rückgabe der erlaubten Effekte
) : logic;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectLink | _WinDropEffectMove
  RETURN(true);
end;


//========================================================================
//  EvtDropLeave
//========================================================================
sub EvtDropLeave(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  RETURN(true);
end;


//========================================================================
//  EvtDragTerm
//
//========================================================================
sub EvtDragTerm(
  aEvt                 : event;    // Ereignis
  aDataObject          : handle;   // Drag-Datenobjekt
  aEffect              : int;      // Durchgeführte Dragoperation (_WinDropEffectNone = abgebrochen)
) : logic;
local begin
  vData : int;
end;
begin

  vData # aDataObject->wpData(_WinDropDataUser);
  vData # vData->wpData;
  if (vData<>0) then begin
    CteClear(vData, y);
    CteClose(vData);
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  if (cMDI=aEvt:Obj) then cMDI # 0;
  RETURN(true);
end


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vHdl      : int;
  vTermProc : alpha;
end;
begin
  cMDI # 0;

  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;
    if (gSelected<>0) then Call(vTermProc);
    VarInstance(Windowbonus,vHdl);
  end;

end;


//========================================================================
//========================================================================
sub Druck1(
  aDL               : int;
  opt amitEntnahme  : logic)
local begin
  Erx   : int;
  vI    : int;
  vID   : int;
end;
begin
  if (aDL=0) then RETURN;
  vI # aDL->wpCurrentInt;
  if (vI=0) then begin
    Msg(99,'Bitte markieren einen BA auswählen!',0,0,0);
    RETURN;
  end;

  WinLstCellGet(aDL, vID, cClmRecID, vI);
  Erx # RecRead(702, 0,_recId,vID);
  If (Erx>_rLocked) then RETURN;

  Lib_Dokumente:Printform(700,'BetriebsauftragEinzel',true);

  if (aMitEntnahme) then begin
    if (Set.InstallName='BSP') then
      Call('SFX_BSP_BAG:Entnahmedruck');
  end;
end;


//========================================================================
//========================================================================
sub DruckAll(aDL  : int)
local begin
  Erx   : int;
  vI    : int;
  vID   : int;
end;
begin
  if (aDL=0) then RETURN;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vID, cClmRecID, vI);
    Erx # RecRead(702, 0,_recId,vID);
    If (Erx>_rLocked) then CYCLE;

//Todo('Print '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
Lib_Dokumente:Printform(700,'BetriebsauftragEinzel',true);
  END;
  
end;


//========================================================================
//========================================================================
sub DruckAllEnt(aDL  : int)
local begin
  Erx   : int;
  vI    : int;
  vID   : int;
end;
begin
  if (aDL=0) then RETURN;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=WinLstDatLineInfo(aDL, _WinLstDatInfoCount)) do begin
    WinLstCellGet(aDL, vID, cClmRecID, vI);
    Erx # RecRead(702, 0,_recId,vID);
    If (Erx>_rLocked) then CYCLE;

    Lib_Dokumente:Printform(700,'BetriebsauftragEinzel',true);
    if (Set.Installname='BSP') then
      call('SFX_BSP_BAG:Entnahmedruck');
  END;
  
end;

//========================================================================
//========================================================================