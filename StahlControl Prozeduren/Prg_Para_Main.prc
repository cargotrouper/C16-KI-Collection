@A+
//==== Business-Control ==================================================
//
//  Prozedur    Prg_Para_Main
//                    OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  16.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB ParaAuswahl(aBereich : alpha; aVon : alpha; aBis : alpha; optaDatei : int; optadefault : alpha) : alpha
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//
//========================================================================
@I:Def_Global

define begin
  Title       : 'Parameterdatei'
end;


//========================================================================
//  ParaAuswahl
//              Öffnet Auswahlliste für Parameter
//========================================================================
sub ParaAuswahl(
  aBereich      : alpha;
  aVon          : alpha;
  aBis          : alpha;
  opt aDatei    : int;
  opt adefault  : alpha;
) : alpha
local begin
  Erx           : int;
  vBuf          : int;
  vX            : int;
  vName         : alpha;
  vHdl          : int;
  vA            : alpha;
  vNr           : int;
  vMaxTds       : int;
  vMaxFld       : int;
  vFld          : int;
  vTds          : int;
  vPrinterList  : int;
  vPrinter      : int;
  vTrayCount    : int;
  vZeile        : int;
  vStoDir       : int;
end;
begin

  aVon # StrCnv(aVon,_Strupper);
  aBis # StrCnv(aBis,_Strupper);

  case aBereich of
    'Drucker'     : vNr # 1;
    'Schächte'    : vNr # 2;
    'Formulare'   : vNr # 3;
    'Prozeduren'  : vNr # 8;
    'TAPI'        : vNr # 13;
    'Dateien'     : vNr # 15;
    'Felder'      : vNr # 16;
  end;

  if vNr=0 then RETURN '';
  vZeile # 1;
  case vNr of
    1 : begin   // Drucker

      if (aDefault='') then aDefault # _App->ppPrinterDefault;

      vHDL # WinOpen('Prg.Para.Auswahl',_WinOpenDialog);
      vPrinterList # _APP->ppPrinterList(_PrtListRefresh);

      if (vPrinterList > 0) then begin
        vX # 1;
        FOR   vPrinter # vPrinterList->PrtInfo(_PrtFirst)
        loop  vPrinter # vPrinter->PrtInfo(_PrtNext)
        while (vPrinter != 0) do begin

          $DL.ParaAuswahl->WinLstDatLineAdd(vPrinter->ppname);

          if (vPrinter->ppname=aDefault) then vZeile # vX;

          inc(vx);
        end;
      end;
    end;


    2 : begin   // Schächte
      vHDL # WinOpen('Prg.Para.Auswahl',_WinOpenDialog);
      vPrinter # aDatei;
      vTrayCount # vPrinter->PrtInfo(_PrtInfoBinCount);
      FOR vX # 1 loop inc(vX) while (vX<=vTrayCount) do begin
        $DL.ParaAuswahl->WinLstDatLineAdd(cnvai(vPrinter->prtInfo(_PrtInfobinId,vX)));
        $DL.ParaAuswahl->WinLstCellSet(vPrinter->prtInfoStr(_PrtInfobinName,vX) ,2,_WinLstDatLineLast);
      END;
      vX # winsearch($Dl.PAraAuswahl,'Parameter');
      vX->wpclmWidth # 30;
      vX # winsearch($Dl.PAraAuswahl,'Parameter2');
      vX->wpclmWidth # 300;
    end;


    3 : begin   // Formulare
      vHdl # Winopen('Prg.Para.Auswahl',_WinOpenDialog);
      vStoDir # StoDirOpen(0, 'PrintForm');
      FOR  vA # StrCnv(vStoDir->StoDirRead(0, aVon),_StrUpper)
      LOOP vA # StrCnv(vStoDir->StoDirRead(_stoNext, vA), _strupper)
      WHILE (vA <> '') and (vA<=aBis) DO BEGIN
        $DL.ParaAuswahl->WinLstDatLineAdd(vA);
      END;
      StoClose(vStoDir);
    end;


    16 : begin    // Felder
      vHdl # Winopen('Prg.Para.Auswahl',_WinOpenDialog);
      vMaxTds # FileInfo(aDatei ,_FileSbrCount);
      FOR vTds # 1 LOOP inc(vTds) WHILE (vTds<=vMaxTds) do begin
        vMaxFld # SbrInfo(aDatei ,vTds,_SbrFldCount);
        FOR vFld # 1 LOOP inc(vFld) WHILE (vFld<=vMaxFld) do begin
          vA # FldName(aDatei ,vTds,vFld);
          $DL.ParaAuswahl->WinLstDatLineAdd(vA);
        END;
      END;
    end;


    8 : begin   // Prozeduren
      vHdl # Winopen('Prg.Para.Auswahl',_WinOpenDialog);
      vBuf # TextOpen(0);
      Erx # Textread(vBuf,aVon, _TextProc);
      vA # StrCnv(TextInfoAlpha(vBuf,_textname),_Strupper);
      WHILE (Erx<>_rNoRec) and (vA>=aVon) and (vA<=aBis) do begin
        $DL.ParaAuswahl->WinLstDatLineAdd(vA);
        Erx # Textread(vBuf,vA,_TextNext | _TextProc);
        vA # StrCnv(TextInfoAlpha(vBuf,_textname),_Strupper);
      END;
      TextClose(vBuf);
    end;


    13 : begin    // TAPI
      vHdl # Winopen('Prg.Para.Auswahl',_WinOpenDialog);

      vBuf # gTapi;
      if (gTapi=0) then gTapi # TapiOpen();
      if (gTapi<>0) then begin
        FOR vX # gTapi->CteRead(_CteFirst)
          loop vX # gTapi->CteRead(_CteNext,vX)
          while (vX>0) do begin
          vA # vX->spName;
          $DL.ParaAuswahl->WinLstDatLineAdd(vA);
        END;
        if (vBuf=0) then gTapi->TapiClose()
      end;
    end;


    15 : begin   // Dateien
      vHdl # Winopen('Prg.Para.Auswahl',_WinOpenDialog);

      FOR vX # 1 LOOP inc(vX) WHILE (vX<=999) do begin
        if (FileInfo(vX,_FileExists)=0) then CYCLE;
        vA # FileName(vX);
        $DL.ParaAuswahl->WinLstDatLineAdd(cnvai(vX,_FmtNumNoGroup,0,3)+' '+vA);
      END;
    end;

  end;//case

  vA # '';
  gSelected # 0;
  $DL.ParaAuswahl->wpCurrentInt # vZeile;
  vHdl->WindialogRun(_WinDialogCenter,gMdi);
  if (gSelected<>0) then $DL.ParaAuswahl->WinLstCellGet(vA, 1, gSelected);
  vHdl->WinClose();

  RETURN va;

end;


//========================================================================
//========================================================================
//========================================================================
//  EvtKeyItem
//              Tastendruck in Auswahlliste
//========================================================================
sub EvtKeyItem(
  aEvt                  : event;      // Ereignis
  aKey                  : int;
  aID                   : int;        // RecId
)
local begin
  vDL   : int;
  vI    : int;
  vMax  : int;
  vA,vB : alpha(1000);
end;
begin

  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    $Prg.Para.Auswahl->Winclose();
  end;

  if (aKey=_WinKeyEsc) then begin
    gSelected # 0;
    $Prg.Para.Auswahl->Winclose();
  end;

  // 07.10.2019
  if ((aKey>=17) and (aKey<=42)) then         // a - z = 25 Zeichen
    aKey # aKey + 65 - 17;
  else if ((aKey>=410) and (aKey<=419)) then   // 0 - 9
    aKey # aKey - 410 + 48
  else
    RETURN;
  
  vA # StrCnv(StrChar(aKey),_StrUpper);
  vDL # aEvt:Obj;
  vMax # WinLstDatLineInfo(vDl, _WinLstDatInfoCount);
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    if (WinLstCellGet(vDL, vB, 1, vI)=false) then BREAK;
    if (StrCnv(StrCut(vB,1,1),_StrUpper)=vA) then begin
      vDL->wpcurrentint # vI;
      BREAK;
    end;
  END;
  
end;


//========================================================================
//  EvtMouseItem
//                Mausclick in Auswahlliste
//========================================================================
sub EvtMouseItem(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
  aHit                  : int;          // Hitcode
  aItem                 : int;          // Item
  aID                   : int;          // ID
) : logic
begin

  if (aItem=0) or (aID=0) then RETURN true;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    $Prg.Para.Auswahl->Winclose();
  end;

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================