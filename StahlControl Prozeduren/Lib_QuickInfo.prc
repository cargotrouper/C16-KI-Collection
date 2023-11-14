@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_QuickInfo
//                  OHNE E_R_G
//  Info  Funktionsbibliothek für QuickInfoanzeige
//
//
//  10.09.2012  ST  Erstellung der Prozedur
//  10.01.2013  ST  Erweiterung um Summierbare Felder
//  18.12.1214  AH  Summierungszeile optional
//  21.11.2016  ST  Bugfix: Summenzeile wird als BigInt hinzugefügt
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    sub Show(aCaption : alpha(200);var aFeldueberschriften : alpha[]; var aFeldFormate: int[];aCallBackFunktion : alpha(60)) : int
//    sub _SetSort(aSortColumnIndex : int )
//    sub _FillDataList(opt aSortDirection : alpha)
//    sub _PrepareSums(var aFeldFormate : int[]; aSumsToShow  : alpha(300); )
//    sub EvtMenuCommand( aEvt : event; aMenuItem : handle;) : logic
//    sub EvtMouseItem(aEvt : event;aButton : int; aHit : int; aItem : int;aID : int;) : logic
//
//========================================================================
@I:Def_Global

global QIData begin
  qiCallBackFunc  : alpha;
  qiSortTree      : int;
  qiIMaxCol       : int;        // ermittelte Schleifenzähler-Obergrenze
  qiSumRow        : int;
  qiFeldFormate   : int[100];
  qiSumFlds       : alpha(300);
end;

declare _FillDataList(opt aSortDirection : alpha);
declare _SetSort(aSortColumnIndex : int )
declare _PrepareSums();

//========================================================================
//  Show
//    Startet die Anzeige der Schnellinformation
//      aCaption : alpha(200);
//      var aFeldueberschriften : alpha[];    // Feldbezeichnungen
//      var aFeldFormate        : int[];      // Feldformatierungen
//      aCallBackFunktion       : alpha(60)   // Funktionsname für Füllung
//      opt aMaximized          : logic;
//      opt aSumsToShow         : alpha(300); // Feldsummierungen
//========================================================================
sub Show(
  aCaption : alpha(200);
  var aFeldueberschriften : alpha[];    // Feldbezeichnungen
  var aFeldFormate        : int[];      // Feldformatierungen
  aCallBackFunktion       : alpha(60);  // Funktionsname für Füllung
  opt aMaximized          : logic;
  opt aSumsToShow         : alpha(300); // Feldsummierungen
) : int
local begin
  vSortTree : int;        // SortTree Handle für Sortierungen und Datenhaltung
  i         : int;        // Schleifenzähler
  vDlg      : handle;     // Handle auf den SChnellinfo Dialog
  vLbl      : handle;     // Handle für den Headertext

  vData     : alpha(4096);
  vHdlClm   : int;
  vHdlDL    : handle;

  pMuendig  : logic;
  pNoList   : logic;
end
begin

  Varallocate(QIData);

  // Rambaum anlegen
  qiSortTree    # CteOpen(_CteTreeCI);

  // Sortierte Liste füllen
  qiCallBackFunc #   aCallBackFunktion;
  Call(qiCallBackFunc, var qiSortTree);

  // Dialog erstellen und Daten füllen
  pMuendig  # false;
  pNoList   # true;
  vDlg # Lib_GuiCom:AddChildWindow(gMDI,'Mdi.Quickinfo',here+':_AusShow');


  vHdlDL # vDlg->Winsearch('DLRamBaum');
  vLbl # vDlg->WinSearch( 'lbHeader' );
  vLbl->wpCaption # aCaption;

  // ----------------------------------
  // Spalten konfigurieren
  FOR i # 1
  LOOP inc(i)
  WHILE i <= 100 DO BEGIN
    vData # aFeldueberschriften[i];
    qiFeldFormate[i] # aFeldFormate[i];
    if (vData = '') then begin
      qiIMaxCol # i;
      break;
    end;

    // Vorgefertigte Spalte in DL suchen
    vHdlClm # vDlg->Winsearch('col'+cnvai(i));
    if (vHdlClm <> 0) then begin

      //vHdlClm->wpCaption  # '('+Aint(i)+')' + vData;
      vHdlClm->wpCaption  # vData;
      vHdlClm->wpVisible  # true;
      vHdlClm->wpClmWidth # 90;       // Vorerst Standardbreite
      vHdlClm->wpClmSortImage # _WinClmSortImageKey;
      // Formartierungen je nach Eingangstyp
      case (aFeldFormate[i]) of
        _TypeAlpha,
        _TypeDate,
        _TypeTime,
        _TypeLogic : begin  vHdlClm->wpClmAlign #  _WinClmAlignLeft;  end;

        _TypeInt,
        _TypeByte,
        _TypeWord,
        _TypeBigInt,
        _TypeFloat,
        _TypeDecimal  : begin vHdlClm->wpClmAlign #  _WinClmAlignRight;  end;

        otherwise begin
          todo('unbekannter Feldtyp: ' + aint(i));
        end;
      end; // Case

    end; // Clm gefunden

  END;


  qiSumFlds # aSumsToShow;

  // Sortierte Liste füllen
  _FillDataList();

  // Summendarstellung
  if (aSumsToShow <> '') then begin
    _PrepareSums();
    $DLRamBaum->wpCustom # Aint(qiSumRow);
  end
  else begin
    _PrepareSums();
  end;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//=========================================================================
//=========================================================================
sub _AusShow()
local begin
end;
begin

  if (qiSortTree <> 0) then begin
    Sort_KillList(qiSortTree); // Löschen der Liste
  end;

end;


//=========================================================================
// sub _SetSort(aSortColumnIndex : int )
//    Durchläuft den aktuellen SortTree und erstellt einen neuen Sortierungs-
//    Baum anhand der Spaltennummer.
//=========================================================================
sub _SetSort(aSortColumnIndex : int )
local begin
  vNewSortTree : int;
  vItem     : int;        // Item einer Sortierung
  vSortkey  : alpha;
  vRec      : alpha[100];
end;
begin

  // Neuen Sortierbaum für neue Sortierung
  vNewSortTree # CteOpen(_CteTreeCI);

  // Aktuellen SortBaum durchlaufen
  FOR   vItem # Sort_ItemFirst(qiSortTree)
  loop  vItem # Sort_ItemNext(qiSortTree,vItem)
  WHILE (vItem != 0) DO BEGIN

    // Positionsdaten lesen  (vRec spielt in diesem fall keine Rolle)
    Call(qiCallBackFunc + '_Pos', vItem, var vRec);

    // Sortierungsfeld lesen
    vSortKey # Call(qiCallBackFunc + '_Sort', aSortColumnIndex);

    // mit neuen Sortkey in NewSortTree schreiben
    Sort_ItemAdd(vNewSortTree,vSortKey,cnvIA(vItem->spCustom),vItem->spID);
  END;

  //  SortTrees austauschen
  qiSortTree # vNewSortTree;
end;



//=========================================================================
// sub _FillDataList()
//    Füllt die Angezeigte Datalist mit den Werten, die innerhalb des
//    Sortierungsbaumes hinterlegt sind.
//=========================================================================
sub _FillDataList(opt aSortDirection : alpha)
local begin
  i         : int;

  vItem     : int;
  vItemCnt  : int;
  vRec      : alpha[100];

  vRow      : int;
  vColumn   : int;

  vData     : alpha(4096);

  vSumNum   : float[100];
end
begin

  $DLRamBaum->wpAutoUpdate # false;
  $DLRamBaum->WinLstDatLineRemove(_WinLstDatLineAll);

  // ------------------------------
  // Datalist füllen
  vItemCnt  # 0;
  if (aSortDirection <> 'DESC') then
    vItem # Sort_ItemFirst(qiSortTree)
  else
    vItem # Sort_ItemLast(qiSortTree);
  WHILE (vItem != 0) do begin

    inc(vItemCnt);
    // Positionsdaten lesen
    Call(qiCallBackFunc + '_Pos', vItem, var vRec);

    vRow # $DLRamBaum->WinLstDatLineAdd(vItem->spID,_WinLstDatLineLast);
    $DLRamBaum->WinLstCellSet(cnvIA(vItem->spCustom), 2);

    // Felder anhängen
    FOR   i # 1
    LOOP  inc(i)
    WHILE i < qiIMaxCol DO BEGIN
      vData # vRec[i];
      vColumn # i + 2;
      $DLRamBaum->WinLstCellSet(vData, vColumn);

      // Numerische Spalteninhalte Summieren
      vSumNum[vColumn]  # vSumNum[vColumn] + CnvFA(vData);

    END; // while Column

    if (aSortDirection <> 'DESC') then
      vItem # Sort_ItemNext(qiSortTree,vItem)
    else
      vItem # Sort_ItemPrev(qiSortTree,vItem)

  END; // while Item



  // ------------------------------------------------------
  // Summierung von Integer und Float Werten hinzufügen
//debugx(qiSumFlds);
  if (vItemCnt > 0)
    and (qiSumFlds<>'') then begin
//    if (vFound=falsE) then begin
//      vFound # true;
      vRow # $DLRamBaum->WinLstDatLineAdd(-1\b,_WinLstDatLineLast);
      qiSumRow # vRow;
      $DLRamBaum->WinLstCellSet(0, 2);   // Dateinummer 0
//    end;

    // Felder anhängen
    FOR   i # 1
    LOOP  inc(i)
    WHILE i < qiIMaxCol DO BEGIN
      vColumn # i + 2;
      vData # Anum(vSumNum[vColumn],2);
      $DLRamBaum->WinLstCellSet(vData, vColumn);

    END; // while Column
  end;

  $DLRamBaum->wpAutoUpdate # true;
end;


//=========================================================================
// sub _PrepareSums
//    Liest die nach Aufbereitung der Liste die erstellte Summenzeile und
//    Prüft diese auf Summierbare Werte und zeigt diese entweder an oder
//    blendet den Wert aus
//=========================================================================
sub _PrepareSums()
local begin
  i : int;
  vColumn : int;
end
begin

  if (StrCut(qiSumFlds,1,1) <> ',') then
    qiSumFlds # ','+qiSumFlds;

  if (StrCut(qiSumFlds,StrLen(qiSumFlds),1) <> ',') then
    qiSumFlds # qiSumFlds+',';

  // Summenfelder säubern
  FOR   i # 1
  LOOP  inc(i)
  WHILE i < qiIMaxCol DO BEGIN
      vColumn  # i+2;

    case (qiFeldFormate[i]) of
      _TypeAlpha,
      _TypeDate,
      _TypeTime,
      _TypeLogic : begin
        // Keine Summierung
          $DLRamBaum->WinLstCellSet('',vColumn,qiSumRow);
        end;

      _TypeInt,
      _TypeByte,
      _TypeWord,
      _TypeBigInt,
      _TypeFloat,
      _TypeDecimal  : begin
        // Summierte Werte

        // Ausblenden, wenn nicht ausgeblendet werden soll
        if (StrFind(qiSumFlds,','+Aint(i)+',', 1) = 0) then begin
          // Keine Summierung gewünscht
          $DLRamBaum->WinLstCellSet('',vColumn,qiSumRow);
        end;

      end;

      otherwise begin
        todo('unbekannter Feldtyp: ' + aint(i));
      end;

    end;

  END;

end;


//========================================================================
//  EvtMouseItem
//                Mausklicks in Listen
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
local begin
  vCol : int;
  vSortOrder : alpha;

  i : int;
  vHdlClm : int;
end;
begin

  if ( aItem = 0 ) then RETURN false;

  // Klick auf Spaltenheader?
  if ( aEvt:obj = $DLRamBaum ) and( aButton = _winMouseLeft ) and ( aHit = _winHitLstHeader ) then begin

    // aItem hat Spaltennummer im Namen stehen z.B. "Col8"
    vCol # CnvIa(aItem->wpName);

    // Spalte kennzeichnen und Richtung ermitteln
    vSortOrder  # '';
    if (aItem->wpClmSortImage = _WinClmSortImageDown) then begin
      vSortOrder # 'DESC';
      aItem->wpClmSortImage # _WinClmSortImageUp;
    end else begin
      vSortOrder # 'ASC';
      aItem->wpClmSortImage # _WinClmSortImageDown;
    end;

    // Headerbilder angleichen
    FOR i # 1
    LOOP inc(i)
    WHILE i <= 100 DO BEGIN
      // Vorgefertigte Spalte in DL suchen
      vHdlClm # $DLRamBaum->Winsearch('col'+cnvai(i));
      if (vHdlClm <> 0) then begin
        if (vCol = i) then
          CYCLE
        vHdlClm->wpClmSortImage # _WinClmSortImageKey;
        winUpdate(vHdlClm);
      end else
        break;
    END;

    // Sortierung umsetzen
    _SetSort(vCol);

    //und DL neu zeichnen
    _FillDataList(vSortOrder);

    _PrepareSums();

  end;

end;



//=========================================================================
//=========================================================================
//        Verwendungsbeispiel
//=========================================================================
//=========================================================================

/*
// Die zu verwendende Prozedur muss 4  subs implementieren ()
//  a) Aufrufende Sub:   z.B. sub Info_Start()()
//      Definiert 2 Arrays mit Spaltenüberschriften und deren Typen
//      Zusätzlich können Zusatzinformationen für die Überschrift
//      angegeben werden
//      WICHTIG: Angabe des Namens für SUB laut b)
//
//  b) Sub für Datenermittlung: z.B. Info_Data(...)
//      Fügt diverse Datensätze in den übergebenen RamBaum-Handle ein und
//      kümmert sich um die Logik und Benutzeranzeige während der Ermittlung
//
//  c) Sub für Datenbereitstellung (Name = b+'_Pos'): z.B. Info_Data_Pos(...)
//      Diese Sub wird für jeden Datensatz in der Ergebnismenge aufgerufen
//      und füllt den übergebenen Array mit formatierten Alpha-Werten in der
//      richtigen Reihenfolge (laut a)). Das SortItem wird mit übergeben.
//
//  d) Sub zum Setzen der Sortierungsinformation (Name = b+'_Sort') z.B. Info_Data_Sort(...)
//      Gibt für jede Spalte den entsprechenden Sortierungsschlüsselwert
//      zurück.
//

//========================================================================
//  Start
//      Aufruf der Anzeigefunktion
//========================================================================
sub Info_Start()  : int
local begin
  i       : int;
  vFeld   : alpha[100];
  vTyp    : int[100];
  vQInfo  : Alpha(1000);
  vSumStr : alpha(300);
end
begin

  // IO zur Fertigung lesen
  RecLink(701,703,3,_RecFirst);

  i # 1;
  vFeld[i] # 'Nummer';         vTyp[i]  # _TypeInt;    inc(i);
  vFeld[i] # 'Position';       vTyp[i]  # _TypeInt;    inc(i);
  vFeld[i] # 'Kunde';          vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Bestellt am';    vTyp[i]  # _TypeDate;   inc(i);
  vFeld[i] # 'Güte';           vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Oberfläche';     vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Dicke';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Breite';         vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Länge';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Stk';            vTyp[i]  # _TypeInt;    inc(i);
  vFeld[i] # 'Bestellt kg';    vTyp[i]  # _TypeFloat;  inc(i);  vSumStr # vSumStr + Aint(i) + ',';
  vFeld[i] # 'Rest kg';        vTyp[i]  # _TypeFloat;  inc(i);  vSumStr # vSumStr + Aint(i) + ',';
  vFeld[i] # 'Termin';         vTyp[i]  # _TypeAlpha;  inc(i);

  vQInfo  # "BAG.IO.Güte"         + ', ' +
            "BAG.IO.AusfOben"     + ', ' +
            ANum("BAG.IO.Dicke",Set.Stellen.Dicke) + ' x ' +
            ANum("BAG.IO.Breite",Set.Stellen.Breite) + ' mm, ' +
            ANum("BAG.IO.Plan.In.Menge",Set.Stellen.Gewicht) + ' KG';

  Lib_QuickInfo:Show('passende Auftragspositionen für: '+ vQInfo,
                      var vFeld,
                      var vTyp,
                      here+':Info_Data',
                      false,    // Fullscreen nein
                      vSumStr);
end;


//========================================================================
// sub Info_Data(var aSortTreeHandle : int;)
//      Ermittelt die darzustellenden Datensätze
//========================================================================
sub Info_Data(var aSortTreeHandle : int)
local begin
  vPrg        : int;
  vQ          : alpha(4096);
  vSel        : int;
  vSelName    : alpha;
  vSelCnt     : int;
  vCurrent    : int;
  vSortKey    : alpha;
end;
begin

  vPrg # Lib_Progress:Init('Datenermittlung');
  //
  vQ # '';
  Lib_Sel:QAlpha(   var vQ, '"Auf.P.Löschmarker"', '=', '' );
  Lib_Sel:QInt(     var vQ, 'Auf.P.Nummer',       '<',  1000000000 );
  Lib_Sel:QAlpha(   var vQ, '"Auf.P.Güte"',      '=*', "BAG.IO.Güte" );
  Lib_Sel:QVonBisF( var vQ, '"Auf.P.Dicke"',  "BAG.IO.Dicke", "BAG.IO.Dicke");
  Lib_Sel:QVonBisF( var vQ, '"Auf.P.Breite"', 0.0,            "BAG.IO.Breite");

  vSel # SelCreate( 401, 1 );
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun( var vSel, 0);
  vSelCnt  # vSel->SelInfo(_SelCount);

  FOR   Erx # RecRead(401,vSel,_RecFirst)
  LOOP  Erx # RecRead(401,vSel,_RecNext)
  WHILE Erx <= _rLocked DO BEGIN
    inc(vCurrent);
    vPrg->Lib_Progress:SetLabel('Sortierung ' + Aint(vCurrent) + '/' + Aint(vSelCnt))
    if (vPrg->Lib_Progress:Step() = false) then begin
      break;
    end;

    // Sortierungsschlüssel definieren
    vSortKey # "Auf.P.Güte" +
               cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+
               Auf.P.KundenSw;

    Sort_ItemAdd(aSortTreeHandle,vSortKey,401,RecInfo(401,_RecId));
  END;

  // Beenden
  vPrg->Lib_Progress:Term();
  SelDelete(401, vSelName);

end;


//========================================================================
// sub Info_Data_Pos(aSortItem : int; var aRecord : alpha[];)
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub Info_Data_Pos(aSortItem : int; var aRecord : alpha[];)
local begin
  i : int;
end;
begin
  RecRead(cnvIA(aSortItem->spCustom), 0, 0, aSortItem->spID); // Datensatz holen
  RecLink(400,401,3,0); // Auftragskopf lesen

  i # 1;
  if (cnvIA(aSortItem->spCustom) = 401) then begin
    aRecord[i] # Aint(Auf.P.Nummer);                            inc(i);
    aRecord[i] # Aint(Auf.P.Position);                          inc(i);
    aRecord[i] # Auf.P.KundenSW;                                inc(i);
    aRecord[i] # CnvAd(Auf.Datum);                              inc(i);
    aRecord[i] # "Auf.P.Güte";                                  inc(i);
    aRecord[i] # "Auf.P.AusfOben";                              inc(i);
    aRecord[i] # ANum(Auf.P.Dicke,Set.Stellen.Dicke);           inc(i);
    aRecord[i] # ANum(Auf.P.Breite, Set.Stellen.Breite);        inc(i);
    aRecord[i] # ANum("Auf.P.Länge", "Set.Stellen.Länge");      inc(i);
    aRecord[i] # AInt("Auf.P.Stückzahl");                       inc(i);
    aRecord[i] # ANum(Auf.P.Gewicht,Set.Stellen.Gewicht);       inc(i);
    aRecord[i] # ANum(Auf.P.Prd.Rest.Gew,Set.Stellen.Gewicht);  inc(i);
    aRecord[i] # CnvAd(Auf.P.TerminZusage);                     inc(i);
  end;

end;

//========================================================================
// sub Info_Data_Sort(aRowIndex : int) : alpha
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub Info_Data_Sort(aRowIndex : int) : alpha
begin
  case (aRowIndex) of
    1 : begin RETURN Lib_Strings:IntForSort(  Sta.Re.Nummer);           end;
    2 : begin RETURN Lib_Strings:DateForSort( Sta.Re.Datum);            end;
    3 : begin RETURN                          Sta.Auf.Artikel.Nr;       end;
    4 : begin RETURN                          Sta.Auf.Artikel.SW;       end;
    5 : begin RETURN Lib_Strings:NumForSort(  Sta.Menge.VK);            end;
    6 : begin RETURN                          Sta.MEH.VK;               end;
    7 : begin RETURN Lib_Strings:NumForSort(  Auf.P.Einzelpreis);       end;
    8 : begin RETURN Lib_Strings:NumForSort(  1.1);                     end;
    9 : begin RETURN                          Sta.Auf.Strukturnr;       end;
   10 : begin RETURN                          "Sta.Auf.Güte";           end;
   11 : begin RETURN Lib_Strings:NumForSort(  Sta.Auf.Dicke);           end;
   12 : begin RETURN Lib_Strings:NumForSort(  Sta.Auf.Breite);          end;
   13 : begin RETURN Lib_Strings:NumForSort(  "Sta.Auf.Länge");         end;
   14 : begin RETURN                          "Sta.Auf.Ausführung.O";   end;
   15 : begin RETURN                          "Sta.Auf.Ausführung.U";   end;
   16 : begin RETURN Lib_Strings:IntForSort(  Sta.Lfs.Materialnr);      end;
   17 : begin RETURN Lib_Strings:IntForSort(  Sta.Auf.Nummer)  + '/' +
                     Lib_Strings:IntForSort(  Sta.Auf.Position);        end;
   18 : begin RETURN Lib_Strings:NumForSort(  Sta.Betrag.EK);           end;
   19 : begin RETURN                          Mat.LieferStichwort;      end;
  end;
end;

*/


//=========================================================================
//=========================================================================
//=========================================================================