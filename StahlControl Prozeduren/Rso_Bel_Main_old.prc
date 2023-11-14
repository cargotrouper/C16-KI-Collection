@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Bel_Main
//
//  Info
//
//
//  05.02.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB realtime(aRect : rect; aDauer : int; aPlan : logic) : rect
//    SUB RemoveAll(aObjType : int)
//    SUB RefreshAll();
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtTerm(aEvt : event) : logic
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
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

define begin
//  gVon : $edDatumVon->wpcaptiondate
//  gBis : $edDatumBis->wpcaptiondate
  cHoehe : 3
  cPositiv : '+'
  cNegativ : '-'
  gApS : 1
end;

//========================================================================
Global GanttDatum
begin
  gVon      : date;
  gBis      : date;

  gIvl      : int;
  gMove     : logic;
  gBack     : int;
  gX,gY     : Int;
  gRect     : Rect;
  gSel      : int;  // Selectionsdescriptor
  gChanges  : logic;
end;

// Berechnung der Länge eines Intervalls Aufgrund der Arbeitszeit
// Zelie 62ff
declare realtime(aRect : rect;aDauer : int;aPlan : logic;): rect

// Eventbehandlung der Mausclicks auf ein Intervall
declare IvlClicked(aEvt : event;aButton : int;aHitTest : int;aItem : int;aID : int;): logic

// Eventbehandlung beim Fallenlassen eines Intervalls
declare IvlDrop(aEvt : event;aHdlTarget : int;aHdlIvl : int;aDropType : int;aRect : rect;): logic

// Eventbehandlung für die Buttons
declare EvtClicked (aEvt : event;) : logic
declare RefreshAll();

//========================================================================

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
begin
  gMDI # aEvt:obj;
  winsearchpath(gMDI);

  RefreshAll();
end;


//========================================================================
// Realtime
//
//========================================================================
sub realtime
(
  aRect   : rect;   // Fläche des Intervalls
  aDauer  : int;    // Produktionsdauer
  aPlan   : logic;  // soll die Arbeitszeit mit eingerechnet werden?
) : rect
local begin
  vMaschine : int;  // Maschinennummer
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

  // ACHTUNG erstmal wird noch keine Arbeitszeit berechnet
  aPlan # false;


  // Wenn die Arbeitszeit nicht berücksichtigt werden soll
  // die Minimallänge des Intervalls einstellen
  If aPlan = n then begin
    aRect:Right # aRect:Left + aDauer -1;
    return aRect;
  end;

/* ACHTUNG
  // Wenn das Intervall in die zweite Zeile der Maschine verschoben wurde,
  // wird das Intervall in die erste Zeile verschoben
  If (aRect:Top % 2) = 1 then begin
    aRect:Top     # aRect:Top     - 1;
    aRect:Bottom  # aRect:Bottom  - 1;
  end;

  RecRead(150,2,_RecPos,(aRect:Top div 2)+1); // Maschine Lesen
  vMaschine # Mas.Nummer;
  vDatum    # CnvDI(CnvID(gVon)+ (aRect:left div (24*gApS)));
  vOK       # n;
  // Starttermin setzen
  repeat
    Mas.Z.Maschine  # Mas.Nummer;
    Mas.Z.Datum     # vDatum;
    RecRead(154,2,0);
    vEnde # (CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS)) + (CnvIF(Mas.Z.Dauer)*gApS);
    vStart # ((aRect:Left % (24*gApS)));
    If (Mas.Z.Dauer = 0.0) or (vStart > vEnde )then begin
      vDatum # CnvDI(CnvID(vDatum)+1);
      aRect:Left # (((aRect:Left div (24*gApS)) + 1) * (24*gApS));
      cycle;
    end;
    If vStart < (CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS)) then begin
      aRect:left # ((aRect:Left div (24*gApS))*(24*gApS))+(CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS));
    end;
    vOK # y;
  until vOK;

  vDauer # 0;
  vTemp  # aDauer
  Repeat
    // Arbeitszeit für den Aktuellen Tag lesen
    Mas.Z.Maschine  # Mas.Nummer;
    Mas.Z.Datum     # vDatum;
    RecRead(154,2,0);

    // Restarbeitszeit für den aktuellen Tag errechnen
    If vDatum = CnvDI(CnvID(gVon)+ (aRect:left div 48 )) then begin
      vStart  # (aRect:Left % (24*gApS));
      vRest   # ((CnvIF(Mas.Z.Dauer*CnvFI(gApS)) + (CnvIT(Mas.Z.Anfang)/1000/60/(60/gApS))) - vStart);
      vPlus   # (24*gApS) - vStart;
      vStart  # 0;
    end else begin
      vStart  # (CnvIT(Mas.Z.Anfang)/1000/60/(60 * gApS));
      vRest   # CnvIf(Mas.Z.Dauer*CnvFI(gApS));
      vPlus   # (24*gApS);
    end;

    // Arbeitszeit erhöhen
    If vTemp <= vRest then begin
      vEDate # vDatum;
      vDauer # vDauer + vStart + vTemp;
      vTemp  # 0;
    end else begin
      vDatum # CnvDI(CnvID(vDatum)+1);
      vDauer # vDauer + vPlus;
      vTemp  # vTemp - vRest;
    end;

  until vTemp <= 0;


  aRect:Right # aRect:Left + vDauer - 1;
  Return aRect;
*/
end;


//========================================================================
// RemoveAll
//
//========================================================================
sub RemoveAll
(
  aObjType      : int;  // Übergebener Objekt-Typ
)

local begin
  tObject       : int;   // Interval-Deskriptor
  tTemp         : int;   // Zwischenspeicher
end;

begin
  if ((aObjType <> _WinTypeInterval) and
      (aObjType <> _WinTypeIvlBox  ) and
      (aObjType <> _WinTypeIvlLine )) then RETURN;

  // Intervalle "unsichtbar" entfernen.
  $Belegung->wpAutoUpdate # false;

  tObject # $Belegung ->WinInfo(_WinFirst, 1, aObjType);

  WHILE (tObject <> 0) do begin
    tTemp # tObject->WinInfo(_WinNext, 1, aObjType);
    tObject->WinGanttIvlRemove();
    tObject # tTemp;
  END;

  // GanttGraph neu zeichnen.
  $Belegung ->wpAutoUpdate # true;
end;


//========================================================================
// RefreshAll
//
//========================================================================
sub RefreshAll();
local begin
  vI,vX       : int;
  vFilter     : int;          // Filterdeskriptor
  vErg        : int;
  vStart      : int;
  vRect       : rect;
  vMaschinen  : alpha(4096);  // Beschriftung der Maschinen
  vMGrp       : int;          // Maschinengruppe
  vIvl        : int;          // Intervalldeskriptor
  vRead       : int;
  vDatum      : date;
  vY          : int;
  vTop        : int;
  vLeft       : int;
  vL          : int;
end;
begin

  RemoveAll(_WinTypeInterval);

// ACHTUNG
/*
  // Start und Endedatum bestimmen
  RecRead(154,3,_RecFirst);
  gVon # Mas.Z.Datum;
  RecRead(154,3,_RecLast);
  gBis # Mas.Z.Datum;
  If gBis < SysDate() then gBis # Sysdate();
*/

  //Gantt-Graphen initialisieren

  // Ressourcen eintragen
  $Belegung->wpCellCountHorz      # (CnvID(gBis) - CnvID(gVon)+1) * 24 * gApS;
  $Belegung->wpCellCountVert      # RecInfo(160,_RecCount)*cHoehe;
  $Belegung->wpHelpTipTimeDelay   # 0;
  $Belegung->wpHelpTipTimeShow    # 300000;
  $Belegung->WinGanttLineAdd(0,_winColLightMagenta);
  vI # 1;
  vY # 0;
  vErg # RecRead(160,1,_RecFirst);
  vMGrp # Rso.Gruppe;
  WHILE (vErg <> _rNoRec) do begin

    If (vMaschinen <> '') then vMaschinen # vMaschinen + ',';
    vMaschinen # vMaschinen + Rso.Stichwort;

    vErg # RecRead(160,1,_RecNext);

    If (vMGrp <> Rso.Gruppe) or (vErg=_rNoRec) then begin
      $Belegung->WinGanttLineAdd(vI*cHoehe,_winColLightMagenta);
      vRect:top     # (vY*cHoehe);
      vRect:bottom  # (vI*cHoehe)-1;

      // Kalender eintragen
      vFilter # RecFilterCreate(163,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,vMGrp);
      Erg # RecRead(163,1,_RecFirst,vFilter);
      WHILE (Erg<_rMultiKey) do begin

        Erg # RecLink(164,163,1,_RecFirst);
        if (Erg=_rNoRec) then Rso.Kal.Tag.String # StrChar(StrToChar(cNegativ,1),24);
        vRect:left    # 0;

        vX # Strfind(Rso.Kal.Tag.String, cNegativ, vX);
        WHILE (vX>0) do begin
          vRect:left    # ((CnvID(Rso.Kal.Datum) - CnvID(gVon))*24*gApS) + (vX*gApS) - 1;
          vX # Strfind(Rso.Kal.Tag.String, cPositiv, vX);
          if (vX=0) then
            vRect:right # ((CnvID(Rso.Kal.Datum) - CnvID(gVon))*24*gApS) + (24*gApS) - 1
          else
            vRect:right # ((CnvID(Rso.Kal.Datum) - CnvID(gVon))*24*gApS) + (vX*gApS) - 2;

          $Belegung->WinGanttBoxAdd(vRect,_WinColred,'Frei');

          if (vX>0) then vX # Strfind(Rso.Kal.Tag.String, cNegativ, vX+1);
        END;
        Erg # RecRead(163,1,_RecNext,vFilter);
      END;
      vFilter->RecFilterDestroy();
      vY # vI;
      vMGrp # Rso.Gruppe;
    end;


    Inc(vI);    // nächste Resource
  END;




  vI # 1;
  vErg # RecRead(160,1,_RecFirst);
  WHILE (vErg <> _rNoRec) do begin

    // Wartungen eintragen
    vFilter # RecFilterCreate(165,2);
    vFilter->RecFilterAdd(1,_FltAnd,_FltEq,Rso.Gruppe);
    vFilter->RecFilterAdd(2,_FltAnd,_FltEq,Rso.Nummer);
    vFilter->RecFilterAdd(3,_FltAnd,_FltEq,true);
    vFilter->RecFilterAdd(4,_FltAnd,_FltAboveEq,gVon);

    vRect:top     # (vI*cHoehe);
    vRect:bottom  # vRect:Top + cHoehe - 1;

    vRead # _RecFirst;
    WHILE (Recread(165,2,vRead,vFilter) <= _rLocked) and (Rso.IHA.Termin<=gBis) do begin
      If (Rso.IHA.Termin <> 0.0.0) then begin
        vRect:Left # (CnvID(Rso.IHA.Termin) - CnvID(gVon))*24*gApS;
      end else begin
        Lib_Berechnungen:Mo_von_KW(Rso.IHA.TerminKW,Rso.IHA.TerminJahr,Var vDatum);
        vRect:Left # (CnvID(vDatum) - CnvID(gVon))*24*gApS;
      end;
      vRect:Right # vRect:Left + (24*gApS) - 1;
      $Belegung->WinGanttBoxAdd(vRect,RGB(170,0,0),'Wartung');
      vRead # _RecNext;
    END;
    vFilter->RecfilterDestroy();



    // Zufalls Reservierung
    vTop     # ((vI-1)*cHoehe)+1;
    FOR vX # 0 loop Inc(vX) while vX < 10 do begin
      Rso.IHA.Termin # cnvdi( cnvif(Random() * 20.0) + cnvid(1.12.2005) );
      vLeft # ( (CnvID(Rso.IHA.Termin) - CnvID(gVon))*24) + cnvif(random()*5.0) *gApS;
      vL # 3+(cnvif(random()*30.0))*gApS;

      vIvl # $Belegung->WinGanttIvlAdd(vLeft,vTop,vL,'','Res');
//      vIvl # $Belegung->WinGanttIvlAdd(vStart,vI*cHoehe+1,(60*24)/(60/gApS),'Res'+cnvai(vI),'');
      If (vIvl <> 0) then begin
  //      vIvl->wpArea    # realtime(vIvl->wpArea,CnvIF(Rso.Rso.Dauer)/(60/gApS),y);
        vIvl->wpHelpTip # 'Reservierung';
        vIvl->wpID      # vX;
        vIvl->wpColBkg  # _WinColLightCyan;
        vIvl->wpColFg   # _WinColBlack;
        vIvl->wpCustom  # '999';
//        vIvl->wpStyleIvl # _WinStyleIvlStandard;
      end;
    END;



    // BAs *******************************************************
    vTop     # ((vI-1)*cHoehe)+0;
    Erg # RecLink(702,160,8,_recFirst);   // BA.Positionen loopen
    WHILE (erg<=_rLocked) do begin
      if (BAG.P.Plan.StartDat<gVon) then begin
        Erg # RecLink(702,160,8,_recNext);
        CYCLE;
      end;

      vLeft # ( (CnvID(BAG.P.Plan.Startdat) - CnvID(gVon))*24)
      vLeft # vLeft + (cnvit(BAG.P.Plan.StartZeit)/1000/60/60 *gApS);

//      vL # 10+(cnvif(random()*50.0))*gApS;
//      vL # 10+(cnvit(BAG.P.Plan.EndZeit)/1000/60/60 *gApS);
      vL # cnvif(BAG.P.Plan.Dauer)/60;
      if (BAG.P.Plan.Dauer % 60.0>0.0) then vL # vL + 1;
      vL # vL *gApS;
      if (vL<1) then vL # 1;

      vIvl # $Belegung->WinGanttIvlAdd(vLeft,vTop,vL,'',c_AKt_BA);
      If (vIvl <> 0) then begin
        vIvl->wpHelpTip           # AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
        vIvl->wpID                # RecInfo(702,_RecId);
   //      vIvl->wpArea    # realtime(vIvl->wpArea,CnvIF(Rso.Rso.Dauer)/(60/gApS),y);
//        vIvl->wpID      # vX;
        vIvl->wpColBkg  # _WinColLightyellow;
        vIvl->wpColFg   # _WinColBlack;
        vIvl->wpCustom  # c_AKt_BA;
//        vIvl->wpStyleIvl # _WinStyleIvlStandard;
        case BAG.P.Aktion of
          c_BAG_Spalt : begin
            vIvl->wpColBkg  # _WinColLightYellow;
            vIvl->wpColFg   # _WinColBlack;
          end;
          c_BAG_Tafel, c_BAG_ABCOIL : begin
            vIvl->wpColBkg  # RGB(  0,255, 64);
            vIvl->wpColFg   # _WinColBlack;
          end;
        end;
      end;
      Erg # RecLink(702,160,8,_recNext);
    END;


    Inc(vI);    // nächste Resource
    vErg # RecRead(160,1,_RecNext);
  END;


//  $Belegung->WinGanttLineAdd((vI*cHoehe)-2,_WinColLightMagenta);
  FOR vI # 0 loop inc(vI) while vI <= 7 - (RecInfo(160,_RecCount)) do begin
    vMaschinen # vMaschinen + ',';
  END;
  $Datum->wpScalaLabels # '$(DATE,'+CnvAD(gVon,_FmtDateLongYear)+','+CnvAD(gBis,_FmtDateLongYear)+',1,dd:MM:yyyy)';
  $Stunden->wpSubDivisions # AInt(gApS);
  $Ressource->wpScalaLabels # vMaschinen;

/* ACHTUNG
  // Betriebsaufträge eintragen
  RecRead(150,2,_RecFirst);
  For vI # 0 loop Inc(vI) while vI < RecInfo(150,_RecCount) do begin
    vErg # RecLink(701,150,9,_RecFirst);
    While vErg <> _rNoRec do begin
      vStart # (CnvID(BAG.P.Termindatum) - CnvID(gVon))*24*gApS;
      vStart # vStart + (TimeHour(BAG.P.Terminzeit)*gApS);
      If TimeMin(BAG.P.Terminzeit) >= 60 / gApS then Inc(vStart);
      If CnvIF(Bag.P.Laufzeit) < 60 / gApS then Bag.P.Laufzeit # CnvFI(60/gApS);
      vIvl # $Belegung->WinGanttIvlAdd(vStart,vI*2,CnvIF(BAG.P.Laufzeit)/(60/gApS),CnvAI(RecInfo(701,_RecId),_FmtInternal),'');
      If vIvl <> 0 then begin
        vIvl->wpArea # realtime(vIvl->wpArea,CnvIF(BAG.P.Laufzeit)/(60/gApS),y,BAG.P.Nummer,BAG.P.Position);
        vIvl->wpHelpTip           # CnvAI(BAG.P.Nummer)+'/'+CnvAI(BAG.P.Position);
        vIvl->wpID                # RecInfo(701,_RecId);
        vIvl->wpCustom            # '701';

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
            vIvl->wpColBkg  # RGB(255,128,  0);
            vIvl->wpColFg   # _WinColBlack;
          end;
          703 : begin // Kantenbearbeitung
            vIvl->wpColBkg  # RGB(128,  0,255);
            vIvl->wpColFg   # _WinColWhite;
          end;
          704 : begin // Umwickeln
            vIvl->wpColBkg  # RGB(64 ,128,128);
            vIvl->wpColFg   # _WinColBlack;
          end;
        end;
      end;
      vErg # RecLink(701,150,9,_RecNext);
    END;
    RecRead(150,2,_recNext);
  end;
**/



  // Datumsfeld für die Positionierung vorbelegen
  $edDatum->wpMinDate     # gVon;
  $edDatum->wpMaxDate     # gBis;
  $edDatum->wpCaptionDate # SysDate();
  $edDatum->WinUpdate();
  $Belegung->wpCellOfsHorz # (CnvID(SysDate()) - CnvID(gVon)) * 24 * gApS;

end;


//========================================================================
// EvtInit
//
//========================================================================
sub EvtInit (aEvt : event;) : logic
begin
  WinSearchPath(aEvt:Obj);

  VarAllocate(GanttDatum);         // Globale Variablen laden
  gVon # 01.12.2005;
  gBis # 01.02.2006;

//  RefreshAll();

  Call('App_Main:EvtInit',aEvt);
end;


//========================================================================
// EvtTerm
//
//========================================================================
sub EvtTerm
(
  aEvt : event;
) : logic
begin
  VarFree(GanttDatum); // Globale Variablen freigeben
  Call('App_Main:EvtTerm',aEvt);
end;


sub EvtDragInit
(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
{
debug('dragini');
	return (true);
}


//========================================================================
// IvlClicked
//
//========================================================================
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
debug('click');
  // Ausgabezeile bei Rechtsklick löschen
  If (aButton = _WinMouseRight) then begin
    RETURN falsE;
  end;
//debug('item:'+cnvai(aItem)+'  ID:'+cnvai(aID)+'   Obj:'+cnvai(aevt:obj));

//  If (aID<>0) then RETURN false;
  If (aHitTest <> _winHitIvl) and (aButton <> _WinMouseRight) then RETURN false;

 //todo(aItem->wpcustom);
  if (aItem->wpcustom=c_AKt_BA) then begin
    RecRead(702,0,_RecId,aItem->wpID);
    $GB.Detail->winupdate(_WinUpdFld2Obj);
  end;

  // Intervallfarbe setzen
  If (gIvl <> 0) then begin
/* ACHTUNG
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
        gIvl->wpColBkg  # RGB(255,128,  0);
        gIvl->wpColFg   # _WinColBlack;
      end;
      703 : begin // Kantenbearbeitung
        gIvl->wpColBkg  # RGB(128,  0,255);
        gIvl->wpColFg   # _WinColWhite;
      end;
      704 : begin // Umwickeln
        gIvl->wpColBkg  # RGB(64 ,128,128);
        gIvl->wpColFg   # _WinColBlack;
      end;
      165 : begin // Instandhaltung
// ACHTUNG
      end;
    end;
*/
  end;

/* ACHTUNG
  // Ausgabezeile ausgeben
  $rlsBAG->wpDbFileNo  # 701;
  $rlsBAG->wpDbKeyNo   # 1;
  gIvl # aItem;
  gIvl->wpColBkg # _WinColLightRed;
  RecRead(701,0,_RecId,aID);
  $feLaufzeit->wpCaptionFloat # BAG.P.Laufzeit;
  $rlsBAG->WinUpdate(_WinUpdOn,_WinLstRecDoSelect|_WinLstPosTop);
*/

  RETURN true;
end;


//========================================================================
// IvlDrop
//
//========================================================================
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
debug('lbldrop');
  vTempRect # aRect;

  // Intervallfarben setzen
/* ACHTUNG
  If gIvl <> 0 then begin
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
        gIvl->wpColBkg  # RGB(255,128,  0);
        gIvl->wpColFg   # _WinColBlack;
      end;
      703 : begin // Kantenbearbeitung
        gIvl->wpColBkg  # RGB(128,  0,255);
        gIvl->wpColFg   # _WinColWhite;
      end;
      704 : begin // Umwickeln
        gIvl->wpColBkg  # RGB(64 ,128,128);
        gIvl->wpColFg   # _WinColBlack;
      end;
    end;
  end;
*/
  // Ausgabezeile löschen
  gIvl # 0;

  Recread(160,1,_RecPos,(aRect:Top Div cHoehe)+1);

  Case aHdlIvl->wpCustom of
    '165' : begin
      If (aHdlTarget = $Belegung) then begin
        If vTempRect:Top % cHoehe <> 2 then begin
          vTempRect:Top # vTempRect:Top - (vTempRect:Top % cHoehe) + 2;
        end;
      end;
      RecRead(165,0,_RecId,aHdlIvl->wpId);
      If Rso.Gruppe <> Rso.IHA.Gruppe or Rso.Nummer <> Rso.IHA.Ressource then return false;
    end;

    c_AKt_BA  : begin
      If (aHdlTarget = $Belegung) then begin
        If (vTempRect:Top % cHoehe <> 0) then begin
          vTempRect:Top # vTempRect:Top - (vTempRect:Top % cHoehe) + 0;
        end;
      end;
//      RecRead(165,0,_RecId,aHdlIvl->wpId);
  //    If Rso.Gruppe <> Rso.IHA.Gruppe or Rso.Nummer <> Rso.IHA.Ressource then return false;

/* Achtung
      // Intervallgrösse bestimmen
      RecRead(701,0,_RecId,aHdlIvl->wpID);

      If CnvIF(Bag.P.Laufzeit) < 60 / gApS then Bag.P.Laufzeit # CnvFI(60/gApS);
      If aHdlTarget = $Belegung then vTempRect # realtime(aRect,CnvIF(BAG.P.Laufzeit)/(60/gApS),y,BAG.P.Nummer,BAG.P.Position)
      else vTempRect # realtime(aRect,CnvIF(BAG.P.Laufzeit)/(60/gApS),n,BAG.P.Nummer,BAG.P.Position);
*/
    end;
  end;
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


//========================================================================
// Uebernahme
//
//========================================================================
sub Uebernahme () : logic
local begin
  vObject : int;
  vTemp   : int;
  vRect   : Rect;
end;
begin
  // Ausgabezeile löschen
  $rlsBAG->wpDbFileNo  # 0;
  $rlsBAG->wpDbKeyNo   # 0;
  $rlsBAG->WinUpdate(_WinUpdOn,0);

  // Abfrage wenn noch Objekte in der Zwischenablage sind
  vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
  If vObject <> 0 then begin
    vTemp # WindialogBox(gFrmMain, 'Zwischenablage','Es befinden sich noch Einträge in der Zwischenablage.'+StrChar(13,1)+
                            'Sollen diese Einteilungen zurückgenommen werden?',_WinIcoError,_WinDialogYesNo,2);
    If vTemp = _WinIdYes then begin
      vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
      while vObject != 0 do begin
        Case vObject->wpCustom of
          c_AKt_BA : begin
/* ACHTUNG
            RecRead(701,0,_RecLock | _RecId,vObject->wpID);
            vRect # vObject->wpArea;
            RecRead(150,2,_RecPos,(vRect:Top+2)/2);
            BAG.P.Termindatum     # CnvDI(0);
            BAG.P.Terminzeit      # CnvTI(0);
            BAG.P.PlanFertigDat   # CnvDI(0);
            BAG.P.PlanFertigZeit  # CnvTI(0);
            BAG.P.Maschinennr     # 0;
            Bag.P.UserName        # '';
            kReplace(_RecUnlock);
            WinGanttIvlRemove(vObject);
            vObject # $Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval);
*/
          end;
          '165' : begin

          end;
        end;
      END;
    end else return False;
  end;

  // Belegung zurückspreichern
  vObject # $Belegung->WinInfo(_WinFirst, 1,_WinTypeInterval);
  while vObject != 0 do begin
    Case vObject->wpCustom of
      c_AKt_BA : begin
/* ACHTUNG
        RecRead(701,0,_RecLock | _RecId,vObject->wpID);
        vRect # vObject->wpArea;
        RecRead(150,2,_RecPos,(vRect:Top+2)/2);
        BAG.P.Termindatum     # CnvDI(((vRect:left div (24*gApS)))+ CnvID(gVon));
        BAG.P.Terminzeit      # CnvTI((vRect:left % (24*gApS))*(60 / gApS)*60*1000);
        BAG.P.PlanFertigDat   # CnvDI(((vRect:right div (24*gApS)))+ CnvID(gVon));
        BAG.P.PlanFertigZeit  # CnvTI(((vRect:right % (24*gApS))+1)*(60 / gApS)*60*1000);
        BAG.P.Maschinennr     # Mas.Nummer;
        Bag.P.UserName        # '';
        xRekReplace(701,_RecUnlock);
*/
      end;
      '165' : begin

      end;
    end;
    vObject # vObject->WinInfo(_WinNext,1,_WinTypeInterval);
  END;
  gChanges # false;
  return true;
end;


//========================================================================
// EvtClose
//
//========================================================================
sub EvtClose(
  aEvt : event;
) : logic
local begin
  vFilter : int;
  vID     : int;
end;
begin

  If (gChanges) then begin
    vID # WindialogBox(gFrmMain,'Beenden', 'Es wurden Änderungen gemacht, die noch nicht übernommen wurden!'+StrChar(13)+
                                    'Wollen Sie wirklich die Erfassung abbrechen?',_WinIcoQuestion,_WinDialogYesNo,2);
    If (vID = _WinIdNo) then return false;
  end;

  If ($Zwischenablage->WinInfo(_WinFirst, 1,_WinTypeInterval) <> 0) then begin
    vID # WindialogBox(gFrmMain,'Beenden','Es befinden sich noch BAs in der Zwischenablage.'+StrChar(13)+
                              'Wollen sie das Einplanen wirklich beenden?',_WinIcoQuestion,_WinDialogYesNo,2);
    if (vID = _WinIdNo) then return false;
  end;

/* ACHTUNG
vFilter # RecFilterCreate(701,8);
RecFilterAdd(vFilter,1,_FltAND,_FltEq,UserInfo(_UserName))
while RecRead(701,8,_RecFirst,vFilter) <= _rLocked do begin
  RecRead(701,1,_RecLock);
  Bag.P.UserName # '';
  RekReplace(701,_RecUnlock);
END;
RecFilterDestroy(vFilter);
*/

  Call('App_Main:EvtClose',aEvt);

  RETURN true;
end;


//========================================================================
// EvtClicked
//
//========================================================================
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
    'btRefresh' : begin
      RefreshAll();
      $Belegung->wpCellOfsHorz # (CnvID($edDatum->wpCaptionDate) - CnvID(gVon)) * 48;
      RETURN true;
    end;

    // Sichernbutton gedrückt
    'Sichern' : begin
      Return Uebernahme();
    end;

    // Laufzeit setzen
    'LzSetzen' : begin
      If gIvl = 0 then return false;
      Case gIvl->wpCustom of
        c_AKt_BA : begin
/* ACHTUNG
          RecRead(701,0,_RecId,gIvl->wpID);
          vLZ # $feLaufzeit->wpCaptionFloat;
          If vLZ < CnvFI(60 / gApS) then vLZ # CnvFI(60 / gApS);
          vTempRect # realtime(gIvl->wpArea,CnvIF(vLZ)/(60/gApS),gIvl->WinInfo(_WinParent) = $Belegung,BAG.P.Nummer,BAG.P.Position)
*/
        end;
        '165' : begin

        end;
      end;
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
        Case gIvl->wpCustom of
          c_AKt_BA : begin
/* ACHTUNG
            RecRead(701,1,_RecLock);
            Bag.P.Laufzeit # vLZ;
            RekReplace(701,_RecUnLock);
            gIvl->wpArea # vTempRect;
            gChanges # true;
*/
          end;
          '165' : begin

          end;
        end;
        return true;
      end else begin
        WindialogBox(gFrmMain,'Laufzeit','Die eingegebene Laufzeit führt zu Überschneidungen!',_WinIcoWarning,_WinDialogOK,1);
//        $feLaufzeit->wpCaptionFloat # BAG.P.Laufzeit;
        return false;
      end;
    end;
  end;/*Case*/
end;


//========================================================================
// BAsEinplanen
//
//========================================================================
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
/* ACHTUNG erst wenn es BAs gibt

vFilter # RecFilterCreate(701,8);
RecFilterAdd(vFilter,1,_FltAND,_FltEq,UserInfo(_UserName))
If RecRead(701,8,_RecFirst,vFilter) <= _rLocked then begin
  if WindialogBox(gFrmMain,'Übernahme','Achtung! Eventuelle Änderungen werden übernommen!',_WinIcoWarning,_WinDialogOkCancel,2) = -4 then begin
    If !Uebernahme() then begin
      RecFilterDestroy(vFilter);
      return false;
    end;
  end else begin
    return false;
    RecFilterDestroy(vFilter);
  end;
end;
vSel # '~tmp.'+CnvAI(UserID(_UserCurrent),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
SelDelete(701,vSel);
SelCopy(701,'STD EINZUPLANEN',vSel);
gSel # SelOpen();
vErg # gSel->SelRead(701,_SelLock,vSel);
vErg # gSel->SelRun(_SelDisplay | _SelBreak | _SelWait);
vId # WinDialog('Mas.L.KopieBA',_WinDialogCenter);
Case vID of
  -2 : begin /* Abbruch    */
    While RecRead(701,8,_RecFirst | _RecLock,vFilter) <= _rLocked do begin
      Bag.P.UserName # '';
      RekReplace(701,_RecUnlock);
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
            vIvl->wpColBkg  # RGB(255,128,  0);
            vIvl->wpColFg   # _WinColBlack;
          end;
          703 : begin // Kantenbearbeitung
            vIvl->wpColBkg  # RGB(128,  0,255);
            vIvl->wpColFg   # _WinColWhite;
          end;
          704 : begin // Umwickeln
            vIvl->wpColBkg  # RGB(64 ,128,128);
            vIvl->wpColFg   # _WinColBlack;
          end;
        end;
        vI # vI + 1;
      end;
    END;
  end;

  otherwise begin
    WindialogBox(gFrmMain,'Schaltfläche',CnvAI(vID),_WinIcoInformation,_WinDialogOK,1);
  end;
end;
RecFilterDestroy(vFilter);
gSel->SelClose();
gSel # 0;
SelDelete(701,vSel);

*/
end;


//========================================================================
// EvtMenuCommand
//
//========================================================================
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
//DbgConnect('*',n,n);
//DbgControl(_DbgEnter);
//DbgControl(_DbgStop);

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

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
//DbgDisconnect();
end;


//========================================================================
// SetzeMarker
//
//========================================================================
sub SetzeMarker
(
  aRecID    : int;
)
begin
/* ACHTUNG
  If RecRead(701,0,_RecID | _RecLock,aRecId) = _rOK then begin
    If Bag.P.UserName = '' then Bag.P.UserName # UserInfo(_UserName)
    else if Bag.P.UserName = UserInfo(_UserName) then bag.P.UserName # '';
    RekReplace(701,_RecUnlock);
    $rlCopyBA->WinUpdate(_WinUpdOn,_WinLstPosSelected | _WinLstRecDoSelect | _WinLstRecFromBuffer);
  end;
*/
end;


//========================================================================
// EvtMouseItem
//
//========================================================================
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


//========================================================================
// EvtKeyItem
//
//========================================================================
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


//========================================================================
// KopiereBAInit
//
//========================================================================
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


//========================================================================
// EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
) : logic
begin
/* ACHTUNG
  If Bag.P.UserName = UserInfo(_UserName) then
    GV.Alpha.01 # '>'
  else if Bag.P.UserName <> '' then
    GV.ALPHA.01 # 'X'
  else
    GV.ALPHA.01 # '';
  return true;
*/
end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);   // falls Menüs gesetzte werden sollen
end;


//========================================================================
//========================================================================
//========================================================================
