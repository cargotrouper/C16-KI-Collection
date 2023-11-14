@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Workbench
//                                OHNE E_R_G
//  Info
//
//
//  30.05.2007  AI  Erstellung der Prozedur
//  24.08.2009  MS  um Prj.P(122) erweitert
//  24.08.2020  AH  NEU: Kurzinfo-Fenster
//  02.06.2021  AH  Edit: mit Proc für OPEN/CLOSE
//  22.07.2021  AH  Fix in "Close"
//  23.07.2021  AH  "InsertRec"
//  27.07.2021  AH  ERX
//  09.03.2022  AH  "GetKurzInfoHdl"
//  09.03.2023  DB  Einzelnen Eintrag löschen gefixt
//
//  Subprozeduren
//
//  SUB Insert(aText : alpha; aFile : int; aID : int) : logic;
//  SUB CreateName(aFile : int; var aPrefix : alpha; var aName : alpha) : logic;
//  SUB InsertRec(aDatei : int)
//  SUB InsertAllMarked(aFile : int) : logic;
//  SUB EvtDropEnter(aEvt : event; aDataObject  : int; aEffect  : int) : logic
//  SUB EvtDrop(aEvt : event;	aDataObject  : int;	aDataPlace   : int;	aEffect      : int;	aMouseBtn    : int) : logic
//  SUB EvtDragInit(aEvt : event;	aDataObject : int; aEffect : int;	aMouseBtn : int) : logic
//  SUB EvtDragTerm(aEvt : event;	aDataObject : int; aEffect : int) : logic
//  SUB CreateDragData(aFile : int; aDataObject : int) : logic;
//  SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//  SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
// SUB GetKurzInfoHdl(aDatei : int; aRecId : int)
// SUB OpenKurzInfo(aDatei : int; aRecId : int; opt aProc : alpha)
// SUB CloseKurzInfo(aDatei : int; aRecId : int) : logic
// SUB InfoEvtInit (aEvt : event): logic
// SUB InfoEvtClose(aEvt : event) : logic;


//========================================================================
@I:Def_Global

//========================================================================
//  Insert
//
//========================================================================
sub Insert(
  aText     : alpha;
  aFile     : int;
  aID       : int;
  opt aCust : alpha(4000);
  opt aMdi  : int) : logic;
local begin
  vHdl : int;
end;
begin
  vHdl # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vHdl<>0) then begin
    vHdl->WinLstDatLineAdd(aText);
    vHdl->WinLstCellSet(aFile,2,_WinLstDatLineLast);
    vHdl->WinLstCellSet(aID,3,_WinLstDatLineLast);
    vHdl->WinLstCellSet(aCust,4,_WinLstDatLineLast);
    vHdl->WinLstCellSet(aMdi,5,_WinLstDatLineLast);
  end;
  RETURN true;
end;


//========================================================================
//========================================================================
sub Find(aName  : alpha) : int;
local begin
  vDL   : int;
  vI    : int;
  vMDI  : int;
  vA    : alpha;
end;
begin
  if (gMdiWorkbench=0) then RETURN -1;
  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN -1;

  // gezieltes MDI entfernen?
  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
    vDL->WinLstCellGet(vA,1,vI);
    if (vA=aName) then RETURN vI;
  END;
  RETURN 0;
end;


//========================================================================
// DoClose
//========================================================================
sub DoClose(aMdi : int)
local begin
  vHdl  : int;
end;
begin
  vHdl # Winsearch(aMdi,'labelProc');
  if (vHdl<>0) and (vHdl->wpcustom<>'') then begin
    Call(vHdl->wpcustom, aMDI, 'CLOSE');
  end;

  Winclose(aMdi);
end;


//========================================================================
// Remove
//========================================================================
sub Remove(
  aLine     : int;
  opt aMDI  : int) : logic
local begin
  vDL   : int;
  vI    : int;
  vMDI  : int;
end;
begin
  if (gMdiWorkbench=0) then RETURN false;
  vMdi # gMdiWorkbench;
  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN false;

  // gezieltes MDI entfernen?
  if (aMDI<>0) then begin
    FOR vI # 1
    LOOP inc(vI);
    WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
      vDL->WinLstCellGet(vMdi,5,vI);
      if (vMdi=aMDI) then begin
        vDL->WinLstDatLineRemove(vI);
        RETURN true;
      end;
    END;
    RETURN false;
  end;

  if (aLine<0) then begin     // ALLE löschen?
    WHILE (vDL->winLstDatLineInfo(_WinLstDatInfoCount)>0) do begin
      // ggf. InfoMDI entfernen...
      vDL->WinLstCellGet(vMdi,5,1);
      if (vMdi<>0) then DoClose(vMdi)
      else vDL->WinLstDatLineRemove(1);
    END;
    //vDL->WinLstDatLineRemove(_WinLstDatLineAll);
  end
  else begin
    // ggf. InfoMDI entfernen...
    vDL->WinLstCellGet(vMdi,5,aLine);
    if (vMdi<>0) then DoClose(vMdi);
    else vDL->WinLstDatLineRemove(aLine);   // 09.03.2023 Notwendig, um einzelne Einträge zu löschen
//    vDL->WinLstDatLineRemove(aLine);  22.07.2021
  end;
  
  gMdiWorkbench->winfocusset();
  RETURN true;
end;


//========================================================================
//  CreateName
//
//========================================================================
sub CreateName(
  aFile       : int;
  var aPrefix : alpha;
  var aName   : alpha;
  opt aKurz   : logic) : logic;
local begin
  vA  : alpha;
end;
begin
  case aFile of

    916 : begin
      aPrefix # 'Datei';
      aName   # Anh.File;
      if (Anh.Link.Datei<>0) then
        aName # StrCut(aName,3,250);  // '->' entfernen
    end;


    100 : begin
      aPrefix # 'Adr';
      aName   # Adr.Stichwort;
    end


    102 : begin
      aPrefix # 'Ansprechpartner';
      aName   # Adr.P.Stichwort;
    end


    120 : begin
      aPrefix # 'Prj';
      aName   # aint(Prj.Nummer)+' '+Prj.Stichwort;
    end


    122 : begin
      aPrefix # 'Prj'
      aName   # Aint(Prj.P.Nummer) + '/' + aint(Prj.P.Position) + ' ' + Prj.Adressstichwort + ': ' + Prj.P.Bezeichnung;
    end;


    200 : begin
      aPrefix # 'Mat';
      aName   # aint(Mat.Nummer);
    end


    250 : begin
      aPrefix # 'Art';
      aName   # Art.Stichwort;
    end


    401 : begin
      aPrefix # 'Auf'
      aName   # aInt(Auf.P.Nummer)+'/'+aInt(Auf.P.Position);
      if (aKurz=false) then begin
        if (Auf.P.Dicke<>0.0) then begin
          aName # aName + '   '+ANum(Auf.P.Dicke,Set.Stellen.Dicke);
          if (Auf.P.Breite<>0.0) then begin
            aName # aName + ' x '+ANum(Auf.P.Breite,Set.Stellen.Breite);
            if ("Auf.P.Länge"<>0.0) then
              aName # aName + ' x '+ANum("Auf.P.Länge","Set.Stellen.Länge");
          end;
        end;
      end;
    end


    501 : begin
      aPrefix # 'Ein'
      aName   # aInt(Ein.P.Nummer)+'/'+aInt(Ein.P.Position);
      if (aKurz=false) then begin
        if (Ein.P.Dicke<>0.0) then begin
          aName # aName + '   '+ANum(Ein.P.Dicke,Set.Stellen.Dicke);
          if (Ein.P.Breite<>0.0) then begin
            aName # aName + ' x '+ANum(Ein.P.Breite,Set.Stellen.Breite);
            if ("Ein.P.Länge"<>0.0) then
              aName # aName + ' x '+ANum("Ein.P.Länge","Set.Stellen.Länge");
          end;
        end;
      end;
    end


    655 : begin
      aPrefix # 'VsP';
      aName   # aint(VSP.Nummer);
    end


    700 : begin
      aPrefix # 'BAG'
      aName   # aInt(BAG.Nummer);
    end

    800 : begin
      aPrefix # 'User';
      aName   # Usr.Username;
    end


    828 : begin
      aPrefix # 'ArG';
      aName   # Arg.Aktion2;
    end

  end;


  RETURN (aName<>'');

end;


//========================================================================
//========================================================================
sub InsertRec(aDatei : int)
local begin
  vPref : alpha;
  vA  : alpha;
end;
begin
  CreateName(aDatei, var vPref, var vA);
  if (Find(vPref+':'+vA)>0) then RETURN;
  Insert(vPref+':'+vA,aDatei,RecInfo(aDatei,_recID));
end;


//========================================================================
//  InsertAllMarked
//
//========================================================================
sub InsertAllMarked(
  aFile   : int) : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vPref   : alpha;
  vA      : alpha;
  vBuf    : int;
end;
begin
  vHdl # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vHdl=0) then RETURN false;

  vBuf # RekSave(aFile);

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile=aFile) then begin
      Erx # RecRead(vMFile,0,0,vMID);

      CreateName(aFile, var vPref, var vA);
      if (vA<>'') then begin
        vA # vPref + ':'+vA;
        vHdl->WinLstDatLineAdd(vA);
        vHdl->WinLstCellSet(aFile,2,_WinLstDatLineLast);
        vHdl->WinLstCellSet(vMID,3,_WinLstDatLineLast);
      end;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RekRestore(vBuf);

  RETURN true;
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vFormat : int;
  vTxt    : int;
end;
begin
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
	RETURN (true);
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vFormat : int;
  vA      : alpha(4000);
  vFile   : int;
  vID     : int;
  vPref   : alpha;

  vData   : int;
  vFileList : int;
  vListObj  : int;
end;
begin

//debugx('N:'+aDataObject->wpName+'   C:'+aDataObject->wpcustom);
//if (aDataObject->wpFormatEnum(_WinDropDataFile)) then debugx('file');
//if (aDataObject->wpFormatEnum(_WinDropDataUser)) then debugx('user');
//if (aDataObject->wpFormatEnum(_WinDropDataContent)) then debugx('cont');

  // BLOB?
  if (aDataObject->wpFormatEnum(_WinDropDataContent) and
    (aDataObject->wpcustom = 'vonSC|Blob')) then begin

    // DragData-Objekt ermitteln
    vData # aDataObject->wpData(_WinDropDataContent);
    // Eigentum der Daten übernehmen, da die Objekte sonst nach dem Ereignis entfernt werden
    vData->wpDataOwner # FALSE;
    // Liste mit den Daten ermitteln
    vFileList # vData->wpData;

    // alle übertragenen Dateinamen auswerten
    // Existieren schon?
    FOR  vListObj # vFileList->CteRead(_CteFirst);
    LOOP vListObj # vFileList->CteRead(_CteNext, vListObj);
    WHILE (vListObj > 0) do begin
      vA # vListObj->spcustom;
      // Caption, File, ID, Custom
      Insert('Datei:'+FsiSplitname(vA, _FsiNameNE), 0, 0, 'vonSC|Blob|'+vA);
    END;

    RETURN true;
  end;


  // nur DateText-Obj. aufnehmen und NUR wenn sie einen Text(Custom) haben
  // Workbench->Workbench geht somit nicht, da da kein Text übergeben wird
  if (aDataObject->wpFormatEnum(_WinDropDataText)) and
    (aDataObject->wpcustom<>'') then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    CreateName(vFile, var vPref, var vA);
    if (Find(vPref+':'+vA)>0) then RETURN true;
    Insert(vPref+':'+vA,vFile,vID);
  end;

	RETURN (true);
end


//========================================================================
//  EvtDragInit
//              Sourceobjekt auswählen
//========================================================================
sub EvtDragInit(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int;      // Rückgabe der erlaubten Effekte (_WinDropEffectNone = Cancel)
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vFile : int;
  vID   : int;
  vA    : alpha(4000);
end;
begin

  if (aEvt:obj->wpcurrentint=0) then RETURN false;


  // Blob?
  aEvt:obj->WinLstCellGet(vA,4,_WinLstDatLineCurrent);
  if (Str_Token(vA,'|',1)='vonSC') then begin
    if (Str_Token(vA,'|',2)='Blob') then begin
      vA # Str_Token(vA,'|',3);
//debugX(vA);
      aDataObject->wpName   # vA;
      aDataObject->wpcustom # 'vonSC|Blob';
      aDataObject->wpFormatEnum(_WinDropDataText) # true;
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN true;
    end;
  end;


  // Datensatz?
  aEvt:obj->WinLstCellGet(vA,1,_WinLstDatLineCurrent);
  aEvt:obj->WinLstCellGet(vFile,2,_WinLstDatLineCurrent);
  aEvt:obj->WinLstCellGet(vID,3,_WinLstDatLineCurrent);
  if (vFile=0) or (vID=0) then RETURN false;

  aDataObject->wpName # cnvai(vFile,0,0,3)+'|'+aint(vID);
  aDataObject->wpcustom # 'vonSC|'+cnvai(vFile,0,0,3);
  aDataObject->wpFormatEnum(_WinDropDataText) # true;
  aEffect # _WinDropEffectCopy | _WinDropEffectMove;
  RETURN (true);
end;


//========================================================================
//  EvtDragTerm
//              D&D beenden
//========================================================================
sub EvtDragTerm(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt;Durchgeführte Dragoperation (_WinDropEffectNome = abgebrochen)
	aEffect      : int
) : logic
local begin
  vFormat : int;
  vTxtBuf : int;
  vHdl    : int;
end;
begin
  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    // Format-Objekt ermitteln.
    vFormat # aDataObject->wpData(_WinDropDataText);
    // Format schliessen.
    aDataObject->wpFormatEnum(_WinDropDataText) # false;
  end;

  // Eintrag löschen...
  if (aEffect=_WinDropEffectMove) or (aEffect=_WinDropEffectCopy) then begin
    vHdl # $DL.Workbench;
    vHdl->WinLstDatLineRemove(_WinLstDatLineCurrent);
  end;

end;


//========================================================================
//  CreateDragData
//
//========================================================================
sub CreateDragData(aFile : int; aDataObject : int) : logic;
local begin
  vA    : alpha(4000);
  vPref : alpha;
end;
begin

  CreateName(aFile, var vPref, var vA);
  if (vA='') then RETURN false;

  aDataObject->wpCustom # vPref+':'+vA;
  // eindeutigen Namen erzeugen
  aDataObject->wpName   # cnvai(aFile,0,0,3)+'|'+Cnvai(RecInfo(aFile,_recID),_FmtNumNoGroup,0,15)+'|'+Lib_Rec:Makekey(aFile,y);
  aDataObject->wpFormatEnum(_WinDropDataText) # true;
	RETURN (true);
end;


//========================================================================
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Maustaste
  aHitTest              : int;          // Hittest-Code
  aItem                 : handle;       // Spalte oder Gantt-Intervall
  aID                   : bigint;       // RecID bei RecList / Zelle bei GanttGraph / Druckobjekt bei PrtJobPreview
) : logic;
local begin
  vMDI : int;
end;
begin
  if (aID=0) then RETURN true;
  if (aButton= _winMouseLeft | _winMouseDouble) then begin
    aEvt:Obj->WinLstCellGet(vMdi,5,aID);
    if (vMdi<>0) then begin
      vMdi->winfocusset(true);
    end;
  end;

  RETURN(true);
end;


//========================================================================
sub NextWin(
  aMdi  : int;
  aDir  : int)
local begin
  vDL   : int;
  vMDI  : int;
  vI    : int;
  vSoll : int;
end;
begin
  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN ;

  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
    vDL->WinLstCellGet(vMdi,5,vI);
    if (vMdi=aMdi) then begin
      vSoll # vI + aDir;
      if (vSoll=0) then
        vSoll # vDL->winLstDatLineInfo(_WinLstDatInfoCount)
      else if (vSoll>vDL->winLstDatLineInfo(_WinLstDatInfoCount)) then
        vSoll # 1;
      vDL->WinLstCellGet(vMdi,5,vSoll);
      if (vMdi<>0) then begin
        vMdi->winupdate(_WinUpdActivate);
//        vMdi->winupdate(_WinUpdOn);
      end;
      RETURN;
    end;
  END;
  
end;


//========================================================================
sub ArrangeWins()
local begin
  vDL   : int;
  vMDI  : int;
  vI    : int;
  vX    : int;
  vY    : int;
  vXX   : int;
  vYY   : int;
  vRect : rect;
end;
begin
  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN ;

  gFrmmain->winUpdate(_winupdoff);
  vY # 0;

  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
    vDL->WinLstCellGet(vMdi,5,vI);
    vYY # vMdi->wpAreaHeight;
    vXX # vMdi->wpAreaWidth;
    vRect:Left    # vX;
    vRect:Right   # vX + vXX;
    vRect:Top     # vY;
    vRect:Bottom  # vY + vYY;
    vMdi->wpArea  # vRect;
    vY # vY + vYY;
    if (vY+300>gFrmmain->wpareaheight) then begin
      vY # 0;
      vX # vX + vXX;
    end;
    vMdi->winUpdate(_WinUpdActivate);
  END;
  
  gFrmmain->winUpdate(_winupdon);

end;

//========================================================================
sub CascadeWins()
local begin
  vDL   : int;
  vMDI  : int;
  vI    : int;
  vXX   : int;
  vYY   : int;
  vRect : rect;
end;
begin
  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN ;

  gFrmmain->winUpdate(_winupdoff);

  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
    vDL->WinLstCellGet(vMdi,5,vI);
    vYY # vMdi->wpAreaHeight;
    vXX # vMdi->wpAreaWidth;
    vRect:Left    # vI * 20;
    vRect:Right   # vRect:Left + vXX;
    vRect:Top     # vI * 20;
    vRect:Bottom  # vRect:Top + vYY;
    vMdi->wpArea  # vRect;
    vMdi->winUpdate(_WinUpdActivate);
  END;
  
  gFrmmain->winUpdate(_winupdon);

end;


//========================================================================
//  EvtMenuCommand
//
//========================================================================
sub EvtMenuCommand(
	aEvt         : event;    // Ereignis
	aMenuItem    : int       // Auslösender Menüpunkt / Toolbar-Button
) : logic
local begin
  vHdl  : int;
  vA    : alpha;
end;
begin

  vHdl # $DL.Workbench;

  case aMenuItem->wpname of
    'Mnu.All.Cancel'    : Remove(-1);
    'Mnu.Wins.Arrange'  : ArrangeWins();
    'Mnu.Wins.Cascade'  : CascadeWins();
    'Mnu.Wins.Prev'     : NextWin(gMDI, -1);
    'Mnu.Wins.Next'     : NextWin(gMDI, 1);
    'Mnu.Ktx.Workbench.Del' : begin
      if (vHdl->wpcurrentint<>0) then Remove(vHdl->wpcurrentint);
      RETURN true;
    end;

    'Mnu.Ktx.Workbench.DelAll' : begin
      Remove(-1);
      RETURN true;
    end;
  end;

  RETURN true;

end;


//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect       : rect;
end
begin

  if (aFlags & _WinPosSized != 0) then begin
    vRect           # $dl.Workbench->wpArea;
    vRect:right     # aRect:right-aRect:left-8;
    vRect:bottom    # aRect:bottom-aRect:Top-34;
    $dl.Workbench->wparea # vRect;
  end;


	RETURN (true);
end;


//========================================================================
//========================================================================
sub GetKurzInfoHdl(
  aDatei    : int;
  aRecId    : int) : int;
local begin
  vMDI  : int;
  vName : alpha;
  vBuf  : int;
  vPref : alpha;
  vA    : alpha(4096);
  vI    : int;
  vDL   : int;
end;
begin
  if (gMdiWorkbench=0) then RETURN 0;
  
  vBuf # RecBufDefault(aDatei);
  RecRead(aDatei, 0, _RecId, aRecID);
  CreateName(aDatei, var vPref, var vA, true);
  RecBufDestroy(vBuf);
  vI # Find(vPref+':'+vA);

  if (vI>0) then begin
    vDL # gMdiWorkbench->WinSearch('DL.Workbench');
    if (vDL=0) then RETURN 0;
    vDL->WinLstCellGet(vMdi,5,vI);
  end;
  
  RETURN vMDI;
end;


/*========================================================================
2022-08-22  AH
========================================================================*/
sub FindMaxRect(
  aMDI      : int;
  var aRect : rect);
local begin
  vDL   : int;
  vMdi  : int;
  vI    : int;
  vZ    : int;
end;
begin
  aRect # RectMake(0,0,0,0);

  vDL # gMdiWorkbench->WinSearch('DL.Workbench');
  if (vDL=0) then RETURN;

  // "unterstes" suchen
  FOR vI # 1
  LOOP inc(vI);
  WHILE (vI<=vDL->winLstDatLineInfo(_WinLstDatInfoCount)) do begin
    vDL->WinLstCellGet(vMdi,5,vI);
    if (vMDI=0) then CYCLE;   // 2023-03-10 AH : Arbeitsfeldzeile OHNE Fenster
    if (vMDI->wpAreaBottom>aRect:bottom) then begin
      aRect # vMDI->wparea;
    end
    else if (vMDI->wpAreaBottom=aRect:bottom) then begin
      if (vMDI->wpArearight>aRect:Right) then begin
        aRect # vMDI->wparea;
      end;
    end;
//debugx('Max '+aint(aRect:left)+'/'+aint(aRect:top)+' - '+aint(aRect:right)+'/'+aint(aRect:bottom));
  END;
 
end;


//========================================================================
//========================================================================
sub OpenKurzInfo(
  aDatei      : int;
  aRecId      : int;
  opt aProc   : alpha;
  opt aNoAct  : logic)
local begin
  vAlt    : int;
  vMDI    : int;
  vName   : alpha;
  vBuf    : int;
  vBuf2   : int;
  vPref   : alpha;
  vA      : alpha(4096);
  vHdl    : int;
  vX,vY   : int;
  vZ      : int;
  vXX     : int;
  vYY     : int;
  vRect   : rect;
end;
begin
  vAlt # gMDI;
//debugx('start '+w_name+' '+gMdi->wpname);


  vBuf # RecBufDefault(aDatei);
  RecRead(aDatei, 0, _RecId, aRecID);

  CreateName(aDatei, var vPref, var vA, true);
  if (Find(vPref+':'+vA)>0) then begin
    RecBufDestroy(vBuf);
    RETURN;
  end;

  vName # 'Mdi.Kurzinfo.Mat';
  if (aDatei=401) then
    vName # 'Mdi.Kurzinfo.Auf';

  vMDI # Lib_GuiCom:OpenMdi(gFrmMain, vName, _WinAddHidden, true);
  
  if (aProc<>'') then begin
    vHdl # Winsearch(vMdi,'labelProc');
    if (vHdl<>0) then vHdl->wpcustom # aProc;
    Call(aProc, vMDI, 'OPEN');
  end;
 
  VarInstance(WindowBonus,cnvIA(vMDI->wpcustom));
  gTitle # vPref+' '+vA;
  vMDI->wpcaption # gTitle;
//debugx(vMdi->wpname+' : '+gtitle);

  if (gMdiWorkbench<>0) then begin
    vHdl # Winsearch(gMdiWorkbench,'lbKurzinfo');
    if (vHdl<>0) then begin
      vZ # cnvia(vHdl->wpcaption);
      inc(vZ);
      vHdl->wpcaption # aint(vZ);
    end;
  end;

  // Anzeigen
  
  vZ # vZ * 20;
  FindMaxRect(vMdi, var vRect);
//  vX # vZ;
//  vY # vZ;
  vXX # (vMDI->wparearight-vMDI->wparealeft);
  vYY # (vMDI->wpAreaBottom-vMDI->wpareaTop);
  // zu weit rechts?
  if (vRect:Right+vXX>gFrmMain->wparearight) then begin
    vX # 0;
    vY # vRect:bottom;
//debugx('next line 0/'+aint(vY));
  end
  else begin
    vX # vRect:right;
    vY # vRect:top;
//debugx('rechts '+aint(vX)+'/'+aint(vY));
  end;
  
  Lib_GuiCom:ObjSetPos(vMDI, vX, vY);
  
//  if (aNoAct=false) then
    vMDI->WinUpdate(_WinUpdOn);
//  vMDI->Winfocusset(true);
  RecBufCopy(vBuf, aDatei);
  
  Insert(vPref+':'+vA,aDatei,aRecID,'',vMDI);

  if (vAlt<>0) then begin
//    if (aNoAct) then begin
//vMDI->WinUpdate(_WinUpdActivate|_Winupdon);
//      VarInstance(WindowBonus,cnvIA(vAlt->wpcustom));
//debugx('set ' +w_name+' '+gMdi->wpname);
//      gMDI # vAlt;
//    end
//    else begin
      vAlt->WinUpdate(_WinUpdActivate);
//    end;
  end;
end;


//========================================================================
//========================================================================
sub CloseKurzInfo(
  aDatei    : int;
  aRecId    : int) : logic
local begin
  vPref : alpha;
  vZ    : int;
  vA    : alpha;
end;
begin
  RecRead(aDatei, 0, _RecId, aRecID);

  CreateName(aDatei, var vPref, var vA, true);

  vZ # Find(vPref+':'+vA);
  if (vZ=0) then RETURN false;

//debugx(vA+' = '+aint(vZ));
  Remove(vZ);
  RETURN true;
end;


//========================================================================
// InfoEvtInit
//          Initialisieren der Applikation
//========================================================================
sub InfoEvtInit (
  aEvt      : event;
): logic
local begin
end;
begin
  gMenuName     # 'Mdi.Kurzinfo';//'cMenuName;
  gMenuEvtProc  # here+':EvtMenuCommand';
  Mode          # c_ModeView;
  App_Main:EvtInit( aEvt );
end;


//========================================================================
// InfoEvtClose
//========================================================================
sub InfoEvtClose(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  Remove(0, aEvt:Obj);
  RETURN(true);
end;

//========================================================================