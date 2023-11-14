@A+
//==== Business-Control ==================================================
//
//  Prozedur    _gantt
//
//  Info
//
//
//  05.02.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB realtime(aRect : rect; aDauer : int; aPlan : logic; aNr : int; aPos : int) : rect
//    SUB Init(aEvt : event) : logic
//    SUB IvlClicked(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB IvlDrop(aEvt : event; aHdlTarget : int; aHdlIvl : int; aDropType : int; aRect : rect) : logic
//    SUB Uebernahme() : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB BAsEinplanen() : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB SetzeMarker(aRecID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHitTest : int; aItem : int; aID : int) : logic
//    SUB EvtKeyItem(aEvt : event; aKey : int; aRecID : int) : logic
//    SUB rlCopyBAInit(aEvt : event) : logic
//    SUB EvtLstDataInit(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_Global

Global GanttDatum
begin
  gI        : int;
  gVon,gBis : date;
  gIvl      : int;
  gMove     : logic;
  gBack     : int;
  gX,gY     : Int;
  gRect     : Rect;
  gSel      : int;  // Selectionsdescriptor
  gApS      : int;  // Abschnitte pro Stunde
  gChanges  : logic;
  gErg      : int;
end;

// Berechnung der Länge eines Intervalls Aufgrund der Arbeitszeit
// Zelie 62ff
declare realtime(aRect : rect;aDauer : int;aPlan : logic;aNr : int;aPos : int;): rect

// Initialisirung das Fenster
// Zeile 163ff
declare Init (aEvt : event;) : logic

// Eventbehandlung der Mausclicks auf ein Intervall
// Zeile 291ff
declare IvlClicked(aEvt : event;aButton : int;aHitTest : int;aItem : int;aID : int;): logic

// Eventbehandlung beim Fallenlassen eines Intervalls
// Zeile 358ff
declare IvlDrop(aEvt : event;aHdlTarget : int;aHdlIvl : int;aDropType : int;aRect : rect;): logic

// Eventbehandlung für die Buttons
// Zeile 442ff
declare EvtClicked (aEvt : event;) : logic

/* ==== Anweisungsteil ================================================ */

/***
main ()
local Begin
  vErg : int;
End;
begin
  VarAllocate(Datum);                                 // Globale Variablen laden
  gApS  # 2;
  If (gApS < 1) then gApS # 1;
  vErg  # WinDialog('Mas.L.Belegung',_WinDialogCenter) // Fenster öffnen
  VarFree(Datum);                                     // Globale Variablen freigeben

end;
***/

/*----------------------------------------------------------------------*/
/*  Realtime                                                            */
/*----------------------------------------------------------------------*/
sub realtime(
  aRect   : rect;   // Fläche des Intervalls
  aDauer  : int;    // Produktionsdauer
  aPlan   : logic;  // soll die Arbeitszeit mit eingerechnet werden?
  aNr     : int;    // Betriebsauftragsnummer
  aPos    : int;    // Betriebsauftragsposition
) : rect
local begin
  vRso1,vRso2 : int;  // Maschinennummer
  vDauer    : int;  // Dauer des Auftrags
  vDatum    : date; // temp. Datum in der Berechnungsschleife
  vStart    : int;  // Startspalte des Intervalls im Raster
  vEnde     : int;  // Endspalte des Intervalls im Raster
  vTemp     : int;  // unverplante Restdauer
  vRest     : int;  // Restliche Arbeitszeit für den aktuellen Tag
  vPlus     : int;  // Erhöhungsschrit der Arbeitszeit
  vOK       : logic;// Variable für Schleifenabbruch
  vSDate    : date; // Startdatum
  vSTime    : time; // Startuhrzeit
  vEDate    : date; // Endedatum
  vETime    : time; // Endeuhrzeit
end;
begin

  // Wenn die Arbeitszeit nicht berücksichtigt werden soll
  // die Minimallänge des Intervalls einstellen

  If (aPlan = n) then begin
    aRect:Right # aRect:Left + aDauer -1;
    return aRect;
  end;

  // Wenn das Intervall in die zweite Zeile der Maschine verschoben wurde,
  // wird das Intervall in die erste Zeile verschoben
  If (aRect:Top % 2) = 1 then begin
    aRect:Top     # aRect:Top     - 1;
    aRect:Bottom  # aRect:Bottom  - 1;
  end;

/*****

  RecRead(150,2,_RecPos,(aRect:Top div 2)+1); // Maschine Lesen
  vRso1     # Mas.Nummer;
  vDatum    # CnvDI(CnvID(gVon)+ (aRect:left div (24*gApS)));
  vOK       # n;

  // Starttermin setzen
  REPEAT
    Mas.Z.Maschine  # Mas.Nummer;
    Mas.Z.Datum     # vDatum;
    gErg # RecRead(154,2,0);

    vEnde  # (CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS)) + (CnvIF(Mas.Z.Dauer)*gApS);
    vStart # ((aRect:Left % (24*gApS)));
    if (gErg=_rNoRec) or (Mas.Z.Datum<vDatum) then BREAK;

    If (Mas.Z.Dauer = 0.0) or (vStart > vEnde )then begin
      vDatum      # CnvDI(CnvID(vDatum)+1);
      aRect:Left  # (((aRect:Left div (24*gApS)) + 1) * (24*gApS));
      cycle;
    end;
    If (vStart < (CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS))) then begin
      aRect:left # ((aRect:Left div (24*gApS))*(24*gApS))+(CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS));
    end;
    vOK # y;
  UNTIL vOK;


  vDauer # 0;
  vTemp  # aDauer
  REPEAT
    // Arbeitszeit für den Aktuellen Tag lesen
    Mas.Z.Maschine  # Mas.Nummer;
    Mas.Z.Datum     # vDatum;
    gErg # RecRead(154,2,0);

    // Restarbeitszeit für den aktuellen Tag errechnen

    If (vDatum = CnvDI(CnvID(gVon)+ (aRect:left div 48 ))) then begin
      vStart  # (aRect:Left % (24*gApS));         // muss bis ende der Arbeitszeit gerechnet werden
      vRest   # ((CnvIF(Mas.Z.Dauer*CnvFI(gApS)) + (CnvIT(Mas.Z.Anfang)/1000/60/60*gApS)) - vStart);
      vPlus   # (24*gApS) - vStart - vRest;
      vStart  # 0;
    end else begin
      vStart  # (CnvIT(Mas.Z.Anfang)/1000/60/60 * gApS);
      vRest   # CnvIf(Mas.Z.Dauer*CnvFI(gApS));
      vPlus   # (24*gApS)-vRest-vStart;
    end;

    // Arbeitszeit erhöhen
    If (vTemp <= vRest) then begin
      vEDate # vDatum;
      vDauer # vDauer + vStart + vTemp;
      vTemp  # 0;
    end else begin
      vDatum # CnvDI(CnvID(vDatum)+1);
      vDauer # vDauer + vStart + vRest + vPlus;
      vTemp  # vTemp - vRest;
    end;

    if (gErg=_rNoRec) then BREAK;

  UNTIL (vTemp <= 0);
****/

  aRect:Right # aRect:Left + vDauer - 1;
  RETURN aRect;
end;


/*----------------------------------------------------------------------*/
/*  Init                                                                */
/*----------------------------------------------------------------------*/
sub Init (aEvt : event;) : logic
local begin
  vI,vX       : int;
  vFilter     : int;          // Filterdeskriptor
  vErg        : int;
  vStart      : int;
  vRect       : rect;
  vMaschinen  : alpha(4096);  // Beschriftung der Maschinen
  vMGrp       : int;          // Maschinengruppe
  vIvl        : int;          // Intervalldeskriptor
end;
begin
  // Start und Endedatum bestimmen
  vErg # RecRead(154,3,_RecFirst);
  gVon # Mas.Z.Datum;
  If (gVon=0.0.0) then gVon # 1.1.2005;
  vErg # RecRead(154,3,_RecLast);
  gBis # Mas.Z.Datum;
  If (gBis < SysDate()) then gBis # Sysdate();

  //Gantt-Graphen initialisieren
  $Belegung->wpCellCountHorz      # (CnvID(gBis) - CnvID(gVon)+1) * 24 * gApS;
  $Belegung->wpCellCountVert      # RecInfo(150,_RecCount)*2;
  $Belegung->wpHelpTipTimeDelay   # 0;
  $Belegung->wpHelpTipTimeShow    # 300000;
  $Belegung->WinGanttLineAdd(0,_winColLightMagenta);
  verg # RecRead(150,2,_RecFirst);
  RecBufClear(701);
  $GB.Detail->Winupdate();

  vI # 1;
  WHILE (vErg <> _rNoRec) do begin
    vMGrp # Mas.Maschinengruppe;
    If vMaschinen <> '' then vMaschinen # vMaschinen + ',';
    vMaschinen # vMaschinen + Mas.Bezeichnung;
    verg # RecRead(150,2,_RecNext);
    If (vMGrp <> Mas.Maschinengruppe) then begin
      $Belegung->WinGanttLineAdd(vI*2,_winColLightMagenta);
    end;
    Inc(vI);
  END;


  $Belegung->WinGanttLineAdd((vI*2)-2,_WinColLightMagenta);
  FOR vI # 0 loop inc(vI) while vI <= 7 - (RecInfo(150,_RecCount)) do begin
    vMaschinen # vMaschinen + ',';
  END;


  $Datum->wpScalaLabels # '$(DATE,'+CnvAD(gVon,_FmtDateLongYear)+','+CnvAD(gBis,_FmtDateLongYear)+',1,dd:MM:yyyy)';
  $Stunden->wpSubDivisions # CnvAI(gApS);
  $Maschinen->wpScalaLabels # vMaschinen;

  // Ruhezeiten einzeichnen
  FOR vI # 0 loop Inc(vI) while vI < (CnvID(gBis) - CnvID(gVon)+1) do begin

    verg # RecRead(150,2,_RecFirst);
    vX   # 0;
    WHILE (vErg < _rMultiKey) do begin
      vFilter # RecFilterCreate(154,2);
      RecFilterAdd(vFilter,1,_FltAnd,_FltEq,Mas.Nummer);
      Mas.Z.Maschine  # Mas.Nummer;
      Mas.Z.Datum     # CnvDI(CnvID(gVon)+vI);
      vErg # Recread(154,2,0,vFilter);
      RecFilterDestroy(vFilter);
      If (Mas.Z.Datum > CnvDI(CnvID(gVon)+vI)) or (vErg = _rNoRec) then RecBufClear(154);
      vRect:top     # vX*2;
      vRect:bottom  # vX*2+1;
      vRect:left    # (vI * 24*gApS)+(CnvIT(Mas.Z.Anfang)/(1000*60*(60/gApS))) ;
      vRect:Right   # vRect:left + (CnvIF(Mas.Z.Dauer)*gApS)-1;
      $Belegung->WinGanttBoxAdd(vRect,_WinColLightGray);
      verg # RecRead(150,2,_RecNext);
      Inc(vX);
    END;

  END;


  // Wartungen eintragen
  RecRead(150,2,_RecFirst);
  FOR vI # 0 loop Inc(vI) while vI < RecInfo(150,_RecCount) do begin

    gErg # RecLink(165,150,10,_RecFirst);
    WHILE (gErg<_rNoRec) do begin

      if (RSO.IHA.Termin>=gVon) and (RSO.IHA.Termin<=gBis) then begin

        vStart # (CnvID(RSO.IHA.Termin) - CnvID(gVon))*24*gApS;
        // Hier könnte man noch am Titel des Eintrages was machen
        vIvl # $Belegung->WinGanttIvlAdd(vStart,1+(vI*2),24*gApS,CnvAI(RecInfo(165,_RecId),_FmtInternal),'Wartung');
        If (vIvl <> 0) then begin
          vIvl->wpHelpTip           # 'Wartung';
          vIvl->wpCustom            # 'NOCLICK';
          vIvl->wpID                # RecInfo(165,_RecId);
          vIvl->wpColBkg  # _WinColYellow;
          vIvl->wpColFg   # _WinColWhite;
        end;
      end;

      gErg # RecLink(165,150,10,_recNext);
    END;

    gErg # RecRead(150,2,_RecNext);
  END;



  // Intervalle eintragen
  RecRead(150,2,_RecFirst);
//debug('von bis:'+cnvad(gVOn)+' '+cnvad(gbis));
  FOR vI # 0 loop Inc(vI) while vI < RecInfo(150,_RecCount) do begin
    BAg.P.Maschinennr # Mas.nummer;
    BAG.p.Termindatum # gVon;
    vErg # RecRead(701,4,0);

    WHILE (bag.p.termindatum<=gBis) and (bag.p.termindatum>=gVon) and
      (BAG.P.Maschinennr=Mas.nummer) and
      (vErg<=_rNoKey)  do begin
//debug('a:'+ cnvai(BAG.P.Nummer) );
      vStart # (CnvID(BAG.P.Termindatum) - CnvID(gVon))*24*gApS;
      vStart # vStart + (TimeHour(BAG.P.Terminzeit)*gApS);

      If TimeMin(BAG.P.Terminzeit) >= 60 / gApS then Inc(vStart);

      If CnvIF(Bag.P.Laufzeit) < 60 / gApS then Bag.P.Laufzeit # CnvFI(60/gApS);

      // Hier könnte man noch am Titel des Eintrages was machen
      vIvl # $Belegung->WinGanttIvlAdd(vStart,vI*2,CnvIF(BAG.P.Laufzeit)/(60/gApS),CnvAI(RecInfo(701,_RecId),_FmtInternal),'');

      If (vIvl <> 0) then begin

        vIvl->wpArea # realtime(vIvl->wpArea,CnvIF(BAG.P.Laufzeit)/(60/gApS),y,BAG.P.Nummer,BAG.P.Position);

        vIvl->wpHelpTip           # CnvAI(BAG.P.Nummer)+'/'+CnvAI(BAG.P.Position);
        vIvl->wpID                # RecInfo(701,_RecId);
        Case BAG.P.Bearbeitung of
          701 : begin // Spalten
            vIvl->wpColBkg  # _WinColLightYellow;
            vIvl->wpColFg   # _WinColBlack;
          end;
          702 : begin // Walzen
            vIvl->wpColBkg  # _WinColLightBlue;
            vIvl->wpColFg   # _WinColWhite;
          end;
          705 : begin // Abtafeln/Zuschnitt
            vIvl->wpColBkg  # RGB(  0,255, 64);
            vIvl->wpColFg   # _WinColBlack;
          end;
          707 : begin // Oberflächenbearbeitung
            vIvl->wpColBkg  # RGB(255,128,0);
            vIvl->wpColFg   # _WinColWhite;
          end;
          703 : begin // Kantenbearbeitung
            vIvl->wpColBkg  # _WinColMagenta;
            vIvl->wpColFg   # _WinColWhite;
          end;
          704 : begin // Umwickeln
            vIvl->wpColBkg  # RGB(254,109,243);
            vIvl->wpColFg   # _WinColBlack;
          end;
          706 : begin  // Ronden schneiden
            vIvl->wpColBkg  # _WinColLightCyan;
            vIvl->wpColFg   # _WinColBlack;
          end;
        end;

      end;

      vErg # RecRead(701,4,_RecNext);
    END;

    RecRead(150,2,_recNext);
  END;

  // Datumsfeld für die Positionierung vorbelegen
  $edDatum->wpMinDate     # gVon;
  $edDatum->wpMaxDate     # gBis;
  $edDatum->wpCaptionDate # SysDate();
  $edDatum->WinUpdate();
  $Belegung->wpCellOfsHorz # (CnvID(SysDate()) - CnvID(gVon)) * 24 * gApS;

  RecBufClear(701);
  $GB.Detail->Winupdate();

end;


/*----------------------------------------------------------------------*/
/*  IvlClicked                                                          */
/*----------------------------------------------------------------------*/
Sub IvlClicked
( aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aID       : int;
) : logic
local begin
  vID : int;
  vName : alpha;
  vRect : Rect;
end;
begin
  // Ausgabezeile bei Rechtsklick löschen
  If (aButton = _WinMouseRight) then begin
/*    $rlsBAG->wpDbFileNo  # 0;
    $rlsBAG->wpDbKeyNo   # 0;
    $rlsBAG->WinUpdate(_WinUpdOn,0);*/
    RecBufClear(701);
    $GB.Detail->Winupdate();
    $feLaufzeit->wpCaptionFloat # 0.0;
  end;
  If (aHitTest <> _winHitIvl) and (aButton <> _WinMouseRight) then return(false);

  if (aItem<>0) and (aID>1000) then begin
    if (WinInfo(aItem,_wintype)=_WinTypeInterval) then
      if (aItem->wpCustom='NOCLICK') then RETURN false;
  end;

  // Intervallfarbe setzen
  If (gIvl <> 0) then begin
    RecRead(701,0,_RecId,gIvl->wpID);
    Case BAG.P.Bearbeitung of
          701 : begin // Spalten
            gIvl->wpColBkg  # _WinColLightYellow;
            gIvl->wpColFg   # _WinColBlack;
          end;
          702 : begin // Walzen
            gIvl->wpColBkg  # _WinColLightBlue;
            gIvl->wpColFg   # _WinColWhite;
          end;
          705 : begin // Abtafeln/Zuschnitt
            gIvl->wpColBkg  # RGB(  0,255, 64);
            gIvl->wpColFg   # _WinColBlack;
          end;
          707 : begin // Oberflächenbearbeitung
            gIvl->wpColBkg  # RGB(255,128,0);
            gIvl->wpColFg   # _WinColWhite;
          end;
          703 : begin // Kantenbearbeitung
            gIvl->wpColBkg  # _WinColMagenta;
            gIvl->wpColFg   # _WinColWhite;
          end;
          704 : begin // Umwickeln
            gIvl->wpColBkg  # RGB(254,109,243);
            gIvl->wpColFg   # _WinColBlack;
          end;
          706 : begin  // Ronden schneiden
            gIvl->wpColBkg  # _WinColLightCyan;
            gIvl->wpColFg   # _WinColBlack;
          end;
    end;
  end;

  If (aButton = _WinMouseRight) then return True;

  // Ausgabezeile ausgeben
/*  $rlsBAG->wpDbFileNo  # 701;
  $rlsBAG->wpDbKeyNo   # 1;*/
  gIvl # aItem;
  gIvl->wpColBkg # _WinColLightRed;
  RecRead(701,0,_RecId,aID);
  $feLaufzeit->wpCaptionFloat # BAG.P.Laufzeit;
/*  $rlsBAG->WinUpdate(_WinUpdOn,_WinLstRecDoSelect|_WinLstPosTop);*/
  BAG.P.Fertigung.Stk # 0;
  BAG.P.Fertigung.Gew # 0.0;
  gErg # RecLink(702,701,2,_RecFirst);
  WHILE (gerg<=_rLocked) do begin
    BAG.P.Fertigung.Stk # BAG.P.Fertigung.Stk + BAG.F.Planung.Stk;
    BAG.P.Fertigung.Gew # BAG.P.Fertigung.Gew + BAG.F.Planung.Gew;
    gErg # RecLink(702,701,2,_RecNext);
  END;
$GB.Detail->Winupdate();
  return true;
end;


/*----------------------------------------------------------------------*/
/*  IvlDrop                                                             */
/*----------------------------------------------------------------------*/
Sub IvlDrop
( aEvt        : event;
  aHdlTarget  : int;
  aHdlIvl     : int;
  aDropType   : int;
  aRect       : rect;
) : logic
local begin
  vTempRect   : rect;
  vTempRect2  : rect;
  vSel        : int;
  vSelName    : alpha;
  vUeber      : int;
  vObject     : int;
end;
begin
  vTempRect # aRect;

  // Intervallfarben setzen
  If (gIvl <> 0) then begin
    RecRead(701,0,_RecId,gIvl->wpID);
    Case BAG.P.Bearbeitung of
          701 : begin // Spalten
            gIvl->wpColBkg  # _WinColLightYellow;
            gIvl->wpColFg   # _WinColBlack;
          end;
          702 : begin // Walzen
            gIvl->wpColBkg  # _WinColLightBlue;
            gIvl->wpColFg   # _WinColWhite;
          end;
          705 : begin // Abtafeln/Zuschnitt
            gIvl->wpColBkg  # RGB(  0,255, 64);
            gIvl->wpColFg   # _WinColBlack;
          end;
          707 : begin // Oberflächenbearbeitung
            gIvl->wpColBkg  # RGB(255,128,0);
            gIvl->wpColFg   # _WinColWhite;
          end;
          703 : begin // Kantenbearbeitung
            gIvl->wpColBkg  # _WinColMagenta;
            gIvl->wpColFg   # _WinColWhite;
          end;
          704 : begin // Umwickeln
            gIvl->wpColBkg  # RGB(254,109,243);
            gIvl->wpColFg   # _WinColBlack;
          end;
          706 : begin  // Ronden schneiden
            gIvl->wpColBkg  # _WinColLightCyan;
            gIvl->wpColFg   # _WinColBlack;
          end;
    end;
  end;

  // Ausgabezeile löschen
/*  $rlsBAG->wpDbFileNo  # 0;
  $rlsBAG->wpDbKeyNo   # 0;*/
  RecBufClear(701);
  $GB.Detail->Winupdate();
  gIvl # 0;

  Recread(150,2,_RecPos,aRect:Top+1);

  // Intervallgrösse bestimmen
  RecRead(701,0,_RecId,aHdlIvl->wpID);

  If CnvIF(Bag.P.Laufzeit) < 60 / gApS then Bag.P.Laufzeit # CnvFI(60/gApS);
  If aHdlTarget = $Belegung then vTempRect # realtime(aRect,CnvIF(BAG.P.Laufzeit)/(60/gApS),y,BAG.P.Nummer,BAG.P.Position)
  else vTempRect # realtime(aRect,CnvIF(BAG.P.Laufzeit)/(60/gApS),n,BAG.P.Nummer,BAG.P.Position);

  // Auf Überschneidungen Prüfen
  vUeber # 0;
  vObject # $Belegung->WinInfo(_WinFirst, 1,_WinTypeInterval);
  while vObject != 0 do begin
    vTempRect2 # vObject->wpArea;
    If  (vTempRect2:Top = vTempRect:Top) and (vObject <> aHdlIvl) then begin
      if (((vTempRect2:Left <= vTempRect:Left)   and (vTempRect2:Right >= vTempRect:Left))   or
          ((vTempRect2:Left <= vTempRect:Right)  and (vTempRect2:Right >= vTempRect:Right))  or
          ((vTempRect2:Left >= vTempRect:Left)   and (vTempRect2:Right <= vTempRect:Right))) then begin
        vUeber # vUeber + 1;
      end;
    end;
    vObject # vObject->WinInfo(_WinNext,1,_WinTypeInterval);
  END;

  If vUeber = 0 then begin
    gChanges  # true;
    aRect     # vTempRect;
    Return True;
  end else return false;
end;


/*----------------------------------------------------------------------*/
/*  Übernahme                                                           */
/*----------------------------------------------------------------------*/
sub Uebernahme () : logic
local begin
  vObject : int;
  vTemp   : int;
  vRect   : Rect;
end;
begin
  // Ausgabezeile löschen
/*  $rlsBAG->wpDbFileNo  # 0;
  $rlsBAG->wpDbKeyNo   # 0;
  $rlsBAG->WinUpdate(_WinUpdOn,0);*/
  RecBufClear(701);
  $GB.Detail->Winupdate();

  // Abfrage wenn noch Objekte in der Zwischenablage sind
  vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
  If vObject <> 0 then begin
    vTemp # WinDialogBox(0, 'Zwischenablage','Es befinden sich noch Einträge in der Zwischenablage.'+StrChar(13,1)+
                            'Sollen diese Einteilungen zurückgenommen werden?',_WinIcoError,_WinDialogYesNo,2);
    If vTemp = _WinIdYes then begin
      vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
      while vObject != 0 do begin
        RecRead(701,0,_RecLock | _RecId,vObject->wpID);
        vRect # vObject->wpArea;
        RecRead(150,2,_RecPos,(vRect:Top+2)/2);
        BAG.P.Termindatum     # CnvDI(0);
        BAG.P.Terminzeit      # CnvTI(0);
        BAG.P.PlanFertigDat   # CnvDI(0);
        BAG.P.PlanFertigZeit  # CnvTI(0);
        BAG.P.Maschinennr     # 0;
        Bag.P.UserName        # '';
        RecReplace(701,_RecUnlock);
        WinGanttIvlRemove(vObject);
        vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
      END;
    end else return False;
  end;

  // Betriebsaufträge zurückspreichern
  vObject # $Belegung->WinInfo(_WinFirst, 1,_WinTypeInterval);
  while vObject != 0 do begin
    RecRead(701,0,_RecLock | _RecId,vObject->wpID);
    vRect # vObject->wpArea;
    RecRead(150,2,_RecPos,(vRect:Top+2)/2);
    BAG.P.Termindatum     # CnvDI(((vRect:left div (24*gApS)))+ CnvID(gVon));
    BAG.P.Terminzeit      # CnvTI((vRect:left % (24*gApS))*(60 / gApS)*60*1000);
    BAG.P.PlanFertigDat   # CnvDI(((vRect:right div (24*gApS)))+ CnvID(gVon));
    BAG.P.PlanFertigZeit  # CnvTI(((vRect:right % (24*gApS))+1)*(60 / gApS)*60*1000);

    BAG.P.Maschinennr     # Mas.Nummer;
    Bag.P.UserName        # '';
    RecReplace(701,_RecUnlock);
    vObject # vObject->WinInfo(_WinNext,1,_WinTypeInterval);
  END;
  gChanges # false;
  return true;
end;


/*----------------------------------------------------------------------*/
/*  EvtClose                                                            */
/*----------------------------------------------------------------------*/
sub EvtClose
(
  aEvt : event;
) : logic
local begin
  vFilter : int;
  vID     : int;
end;
begin

  If gChanges then begin
    vID # WinDialogBox(0,'Beenden', 'Es wurden Änderungen gemacht, die noch nicht übernommen wurden!'+StrChar(13)+
                                    'Wollen Sie wirklich die Erfassung abbrechen?',_WinIcoQuestion,_WinDialogYesNo,2);
    If vID = _WinIdNo then return false;
  end;

  If $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval) <> 0 then begin
    vID # WinDialogBox(0,'Beenden','Es befinden sich noch BAs in der Zwischenablage.'+StrChar(13)+
                                'Wollen sie das Einplanen wirklich beenden?',_WinIcoQuestion,_WinDialogYesNo,2);
    if vID = _WinIdNo then return false;
  end;


  vFilter # RecFilterCreate(701,8);
  RecFilterAdd(vFilter,1,_FltAND,_FltEq,UserInfo(_UserName,CnviA(UserInfo(_UserCurrent))))
  while RecRead(701,8,_RecFirst,vFilter) <= _rLocked do begin
    RecRead(701,1,_RecLock);
    Bag.P.UserName # '';
    RecReplace(701,_RecUnlock);
  END;
  RecFilterDestroy(vFilter);


  Return true;

end;


/*----------------------------------------------------------------------*/
/*  EvtClicked                                                          */
/*----------------------------------------------------------------------*/
sub EvtClicked (aEvt : event;) : logic
local begin
  vLZ         : float;
  vTempRect   : rect;
  vTempRect2  : rect;
  vUeber      : int;
  vObject     : int;
end;
begin
  Case (aEvt:Obj->wpName) of
    // Sprungbutton gedrückt
    'Sprung' : begin
      $Belegung->wpCellOfsHorz # (CnvID($edDatum->wpCaptionDate) - CnvID(gVon)) * 48;
      return true;
    end;

    // Sichernbutton gedrückt
    'Sichern' : begin
      Return Uebernahme();
    end;

    // Laufzeit setzen
    'LzSetzen' : begin
      If gIvl = 0 then return false;
      RecRead(701,0,_RecId,gIvl->wpID);
      vLZ # $feLaufzeit->wpCaptionFloat;
      If vLZ < CnvFI(60 / gApS) then vLZ # CnvFI(60 / gApS);
      vTempRect # realtime(gIvl->wpArea,CnvIF(vLZ)/(60/gApS),gIvl->WinInfo(_WinParent) = $Belegung,BAG.P.Nummer,BAG.P.Position)
      // Auf Überschneidungen Prüfen
      vUeber # 0;
      vObject # $Belegung->WinInfo(_WinFirst, 1,_WinTypeInterval);
      while vObject != 0 do begin
        vTempRect2 # vObject->wpArea;
        If  (vTempRect2:Top = vTempRect:Top) and (vObject <> gIvl) then begin
          if (((vTempRect2:Left <= vTempRect:Left)   and (vTempRect2:Right >= vTempRect:Left))   or
              ((vTempRect2:Left <= vTempRect:Right)  and (vTempRect2:Right >= vTempRect:Right))  or
              ((vTempRect2:Left >= vTempRect:Left)   and (vTempRect2:Right <= vTempRect:Right))) then begin
            vUeber # vUeber + 1;
          end;
        end;
        vObject # vObject->WinInfo(_WinNext,1,_WinTypeInterval);
      END;

      If vUeber = 0 then begin
        RecRead(701,1,_RecLock);
        Bag.P.Laufzeit # vLZ;
        RecReplace(701,_RecUnLock);
        gIvl->wpArea # vTempRect;
        gChanges # true;
        return true;
      end else begin
        WinDialogBox(0,'Laufzeit','Die eingegebene Laufzeit führt zu Überschneidungen!',_WinIcoWarning,_WinDialogOK,1);
        $feLaufzeit->wpCaptionFloat # BAG.P.Laufzeit;
        return false;
      end;
    end;
  end;/*Case*/
end;


/*----------------------------------------------------------------------*/
/*  BAsEinplanen                                                        */
/*----------------------------------------------------------------------*/
sub BAsEinplanen () : logic
local begin
  vI      : int;
  vIvl    : int;
  vSel    : alpha;
  vID     : int;
  vErg    : int;
  vFilter : int;
  vRead   : int;
end;
begin
  vFilter # RecFilterCreate(701,8);
  RecFilterAdd(vFilter,1,_FltAND,_FltEq,UserInfo(_UserName,cnvia(userinfo(_usercurrent))));

  If (RecRead(701,8,_RecFirst,vFilter) < _rNoRec) then begin

    if WinDialogBox(0,'Übernahme','Achtung! Eventuelle Änderungen werden übernommen!',_WinIcoWarning,_WinDialogOkCancel,2) = -4 then begin
      If !Uebernahme() then begin
        RecFilterDestroy(vFilter);
        return false;
      end;
    end else begin
      RecFilterDestroy(vFilter);
      return false;
    end;
  end;


  vSel # '~tmp.'+CnvAI(UserID(_UserCurrent),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
  SelDelete(701,vSel);
  SelCopy(701,'STD EINZUPLANEN',vSel);
  gSel # SelOpen();
  vErg # gSel->SelRead(701,_SelLock | _SelKeyMode ,vSel);
  vErg # gSel->SelRun(_SelDisplay | _SelBreak);

  vId  # WinDialog('Mas.L.KopieBA',_WinDialogCenter);

  Case vID of

    -2 : begin                    /* Abbruch    */
      vRead # _RecFirst;
      While (RecRead(701,8,vRead | _RecLock,vFilter) <= _rLocked) do begin
        Bag.P.UserName # '';
        RecReplace(701,_RecUnlock);
  //      vRead # _RecNext;
      END;
    end;

    1 : begin /* Übernehmen */
      vI # 0;
      vRead # _RecFirst;

      While RecRead(701,8,vRead,vFilter) <= _rLocked do begin
        vRead # _RecNext;
        If CnvIF(Bag.P.Laufzeit) < 60 / gApS then Bag.P.Laufzeit # CnvFI(60/gApS);

        vIvl # $Zwischenablage->WinGanttIvlAdd(0,vI,CnvIF(BAG.P.Laufzeit)/(60/gApS),CnvAI(RecInfo(701,_RecId),_FmtInternal),'');

        If vIvl <> 0 then begin

          vIvl->wpArea # realtime(vIvl->wpArea,CnvIF(BAG.P.Laufzeit)/(60/gApS),n,BAG.P.Nummer,BAG.P.Position);

          vIvl->wpHelpTip           # CnvAI(BAG.P.Nummer)+'/'+CnvAI(BAG.P.Position);
          vIvl->wpID                # RecInfo(701,_RecId);

          Case BAG.P.Bearbeitung of
            701 : begin // Spalten
              vIvl->wpColBkg  # _WinColLightYellow;
              vIvl->wpColFg   # _WinColBlack;
            end;
            702 : begin // Walzen
              vIvl->wpColBkg  # _WinColLightBlue;
              vIvl->wpColFg   # _WinColWhite;
            end;
            705 : begin // Abtafeln/Zuschnitt
              vIvl->wpColBkg  # RGB(  0,255, 64);
              vIvl->wpColFg   # _WinColBlack;
            end;
            707 : begin // Oberflächenbearbeitung
              vIvl->wpColBkg  # RGB(255,128,0);
              vIvl->wpColFg   # _WinColWhite;
            end;
            703 : begin // Kantenbearbeitung
              vIvl->wpColBkg  # _WinColMagenta;
              vIvl->wpColFg   # _WinColWhite;
            end;
            704 : begin // Umwickeln
              vIvl->wpColBkg  # RGB(254,109,243);
              vIvl->wpColFg   # _WinColBlack;
            end;
            706 : begin  // Ronden schneiden
              vIvl->wpColBkg  # _WinColLightCyan;
              vIvl->wpColFg   # _WinColBlack;
            end;

          end;
          vI # vI + 1;
        end;
      END;


    end;

    otherwise begin
      WinDialogBox(0,'Schaltfläche',CnvAI(vID),_WinIcoInformation,_WinDialogOK,1);
    end;
  end;

  RecFilterDestroy(vFilter);
  gSel->SelClose();
  gSel # 0;
  SelDelete(701,vSel);

end;


/*----------------------------------------------------------------------*/
/*  EvtMenuCommand                                                      */
/*----------------------------------------------------------------------*/

sub EvtMenuCommand
(
  aEvt      : event;
  aMenuItem : int;
) : logic
local begin
  vI      : int;
  vIvl    : int;
  vSel    : alpha;
  vID     : int;
  vErg    : int;
  vFilter : int;
  vName   : alpha;
  vRead   : int;
end;
begin

  vName # aEvt:obj->wpName;
  Case vName of
    'Zwischenablage' : begin
      case aMenuItem->wpMenuID of
        1 : begin /* BA in Ablage holen */
          return BAsEinplanen();
        end;
      end;
    end; /* Zwischenablage */

    'Mas.L.Belegung' : begin
      case aMenuItem->wpName of

        'miUebernahme' : begin
          return Uebernahme();
        end; /* miUebernahme */

        'miBAs' : begin
          return BAsEinplanen();
        end; /* miBAs */

      end; /* case */


    end; /* Mas.L.Belegung */

  end;

end;


/*----------------------------------------------------------------------*/
/*  SetzeMarker                                                         */
/*----------------------------------------------------------------------*/
sub SetzeMarker
(
  aRecID    : int;
)
begin
  If RecRead(701,0,_RecID | _RecLock,aRecId) = _rOK then begin

    If Bag.P.UserName = '' then
      Bag.P.UserName # UserInfo(_UserName)
    else
    if Bag.P.UserName = UserInfo(_UserName) then
      Bag.P.UserName # '';

    RecReplace(701,_RecUnlock);
    $rlCopyBA->WinUpdate(_WinUpdOn,_WinLstPosSelected | _WinLstRecDoSelect | _WinLstRecFromBuffer);
  end;
end;


/*----------------------------------------------------------------------*/
/*  EvtMouseItem                                                        */
/*----------------------------------------------------------------------*/
sub EvtMouseItem
(
  aEvt      : event;
  aButton   : int;
  aHitTest  : int;
  aItem     : int;
  aID       : int;
) : logic
begin
  case aEvt:Obj->wpName of
    'rlCopyBA' : begin
      If aHitTest = _WinHitLstView and aButton = _WinMouseDouble | _WinMouseLeft then SetzeMarker(aID);
        return true;
    end;
  end;
end;


/*----------------------------------------------------------------------*/
/*  EvtKeyItem                                                          */
/*----------------------------------------------------------------------*/
Sub EvtKeyItem
(
  aEvt      : event;
  aKey      : int;
  aRecID    : int;
) : logic
begin
  case aEvt:Obj->wpName of
    'rlCopyBA' : begin
      SetzeMarker(aRecID);
    end;
  end;
end;


/*----------------------------------------------------------------------*/
/*  KopiereBAInit                                                       */
/*----------------------------------------------------------------------*/
sub rlCopyBAInit
(
  aEvt : event;
) : logic
local Begin
  vSel : int;
end;
begin
  vSel # gSel;
  $rlCopyBA->wpDbFileNo       # 701;
  $rlCopyBA->wpDbSelection    # vSel;
end;


/*----------------------------------------------------------------------*/
/*  EvtLstDataInit                                                      */
/*----------------------------------------------------------------------*/
sub EvtLstDataInit
(
  aEvt      : event;
  aRecID    : int;
) : logic
begin

  If Bag.P.UserName = UserInfo(_UserName,CnviA(UserInfo(_UserCurrent))) then
    GV.Alpha.01 # '>'
  else if Bag.P.UserName <> '' then
    GV.ALPHA.01 # 'X'
  else
    GV.ALPHA.01 # '';

  return true;
end;


/* ==== [END OF PROCEDURE] ============================================ */