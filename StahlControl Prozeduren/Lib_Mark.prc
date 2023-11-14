@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Mark
//                  OHNE E_R_X
//  Info        Routinen für Markierungen
//
//
//  09.06.2005  AI  Erstellung der Prozedur
//  04.11.2010  PW  sub MarkInvert()
//  01.06.2012  AI  NEU: Foreach
//  21.07.2014  AH  NEU: Iterate
//  02.05.2017  ST  Edit: Foreach mit Parametern
//  31.01.2020  AH  NEU "MarkSet"
//  24.08.2021  ST  NEU: sub SumFloatFldGV100(aPara : alpha) : int
//  2023-03-21  MR  Fix von Buffer Fehler 2430/50
//
//  Subprozeduren
//    SUB TokenMark(aItem : int; varaFile : int; varaID : int)
//    SUB Selektion() : logic;
//    SUB MarkAdd(aFile : int; optaNurAdd : logic; opt aNoRefresh : logic; aZeile : int) : logic
//    SUB MarkSet(aFile : int; aMarked : logic; opt aNoRefresh : logic; aZeile : int) : logic
//    sub MarkInvert ( aFile : int; opt aNoRefresh : logic )
//    SUB MarkSave; localbeginvName : alpha; vItem : int; vF : int; vA : alpha; end; beginvName#Lib_FileIO : FileIO(_WinComFileSave,gMDI,'','Markierungs-Dateien|*.mrk');
//    SUB MarkLoad; localbeginvName : alpha; vF : int; vSize : int; vA : alpha; vMFile : int; vMID : int; end; beginvName#Lib_FileIO : FileIO(_WinComFileOpen,gMDI,'','Markierungs-Dateien|*.mrk');
//    SUB SetField(aDatei : int);
//    SUB SetPreis(aTyp : alpha);
//    SUB Filter();
//    SUB Reset(aFile : int; opt a NoZLList : logic);
//    SUB istmarkiert(aFile : int; aID : int) : logic;
//    SUB Count(aFile : int) : int;
//    SUB Foreach(aFile : int; aFunc : alpha) : int;
//
//========================================================================
@I:def_global
@I:Def_Rights

declare istmarkiert(aFile : int; aID : int) : logic;

//========================================================================
//  TokenMark
//
//========================================================================
SUB TokenMark(
  aItem     : int;
  var aFile : int;
  var aID   : int;
)
local begin
  vA  : alpha;
end;
begin
  vA # StrFmt(aItem->spname,20,_StrEnd);
  aFile # Cnvia(Str_Token(vA,'/',1));
  aID   # Cnvia(Str_Token(vA,'/',2));
end;


//========================================================================
//  Selektion
//          nimmt markierte Sätze in die "!MARK"-Selektion auf
//========================================================================
SUB Selektion() : logic;
local begin
  vA    : alpha;
end
begin
  if (gMarkList->CteRead(_CteFirst | _CteSearch, 0, cnvai(gFile)+'/'+cnvai(RecInfo(gFile,_RecId)))<>0) then
    RETURN true;
  RETURN false;
end;


//========================================================================
//  MarkAdd
//
//========================================================================
SUB MarkAdd(
  aFile           : int;
  opt aNurAdd     : logic;
  opt aNoRefresh  : logic;
  opt aZeile      : int;
) : logic
local begin
  vItem : int;
  vVar  : int;
  vA    : alpha;
end
begin

  // 02.05.2018 AH: Datalist?
  if (aZeile>0) then
    vA # cnvai(aFile)+'/'+cnvai(aZeile);
  else
    vA # cnvai(aFile)+'/'+cnvai(RecInfo(aFile,_RecId));

  vItem # gMarkList->CteRead(_CteFirst | _CteSearch, 0, vA);

  if (vItem<>0) then begin
    if (aNurAdd=n) then begin
      gMarkList->CteDelete(vItem);
    end;
  end
  else begin
    vItem # CteOpen(_CteItem);
    if (vItem = 0) then RETURN FALSE;
    vItem->spname # vA;
    gMarkList->CteInsert(vItem);
  end;

  if (gZLList<>0) and (aNoRefresh=n) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    gZLList->WinFocusSet(false);
  end;

  RETURN true;
end;


//=========================================================================
// MarkInvert [04.11.2010/PW]
//        Invertiert die Markierungen für die gegebene Datei
//=========================================================================
sub MarkInvert ( aFile : int; opt aNoRefresh : logic )
local begin
  Erx     : int;
  vName   : alpha;
  vItem   : handle;
  vPrgr   : handle;
end;
begin
  vPrgr # Lib_Progress:Init( 'Markierung durchführen', RecInfo( aFile, _recCount ) );
  FOR  Erx # RecRead( aFile, 1, _recFirst );
  LOOP Erx # RecRead( aFile, 1, _recNext );
  WHILE ( Erx <= _rLocked ) AND ( vPrgr->Lib_Progress:Step() ) DO BEGIN
    vName # CnvAI( aFile ) + '/' + CnvAI( RecInfo( aFile, _recId ) );
    vItem # gMarkList->CteRead( _cteFirst | _cteSearch, 0, vName );

    if ( vItem != 0 ) then
      gMarkList->CteDelete( vItem );
    else begin
      vItem # CteOpen( _cteItem );
      if ( vItem = 0 ) then
        RETURN;
      vItem->spName # vName;
      gMarkList->CteInsert( vItem );
    end;
  END;

  vPrgr->Lib_Progress:Term();
  if ( gZLList != 0 ) and ( !aNoRefresh ) then begin
    gZLList->WinUpdate( _winUpdOn, _winLstRecFromRecID | _winLstRecDoSelect );
    gZLList->WinFocusSet( false );
  end;
end;


//========================================================================
//  MarkSet
//
//========================================================================
SUB MarkSet(
  aFile           : int;
  aMarked         : logic;
  opt aNoRefresh  : logic;
  opt aZeile      : int;
) : logic
local begin
  vItem : int;
  vVar  : int;
  vA    : alpha;
end
begin

  // 02.05.2018 AH: Datalist?
  if (aZeile>0) then
    vA # cnvai(aFile)+'/'+cnvai(aZeile);
  else
    vA # cnvai(aFile)+'/'+cnvai(RecInfo(aFile,_RecId));

  vItem # gMarkList->CteRead(_CteFirst | _CteSearch, 0, vA);

  if (vItem<>0) then begin
    if (aMarked=n) then begin
      gMarkList->CteDelete(vItem);
    end;
  end
  else if (aMarked) then begin
    vItem # CteOpen(_CteItem);
    if (vItem = 0) then RETURN FALSE;
    vItem->spname # vA;
    gMarkList->CteInsert(vItem);
  end;

  if (gZLList<>0) and (aNoRefresh=n) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    gZLList->WinFocusSet(false);
  end;

  RETURN true;
end;


//========================================================================
//  MarkSave
//
//========================================================================
SUB MarkSave;
local begin
  vName : alpha(4096);
  vItem : int;
  vF    : int;
  vA    : alpha(4096);
end;
begin
  vName # Lib_FileIO:FileIO(_WinComFileSave, gMDI, '', 'Markierungs-Dateien|*.mrk');
  if (vName='') then RETURN;
  
  if (FsiSplitname(StrCnv(vName, _StrUpper), _FsiNameE) <> 'MRK') then vName # vName + '.mrk'; //2021-08-18 TJ übernommen von Herrn Bartsch

  vF # FSIOpen(vName, _FsiAcsRW | _FsiDenynone | _FsiCreate | _FsiTruncate);
  if (vF=0) then RETURN;

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    vA # vItem->spname + StrChar(13);
    FSIWrite(vF,vA);

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  vF->FSIClose();

end;


//========================================================================
//  MarkLoad
//
//========================================================================
SUB MarkLoad;
local begin
  Erx   : int;
  vName : alpha(4096);
  vF    : int;
  vSize : int;
  vA    : alpha(4096);
  vMFile : int;
  vMID   : int;
end;
begin
  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'Markierungs-Dateien|*.mrk');
  if (vName='') then RETURN;

  vF # FSIOpen(vName,_FsiStdRead);
  if (vF=0) then RETURN;
  vSize # FSISize(vF);
  FSIMark(vF, 13);

  WHILE (FsiSeek(vF)<vSize) do begin

    FSIRead(vF, vA);

    vMFile # Cnvia(Str_Token(vA,'/',1));
    vMID   # Cnvia(Str_Token(vA,'/',2));

    Erx # RecRead(vMFile,0,0,vMID);
    if (erx=_rOK) then begin
      MarkAdd(vMFile,y,y);
    end;

  END;

  vF->FSIClose();

  if (gZLList<>0) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;

end;


//========================================================================
//  SetField
//
//========================================================================
SUB SetField(aDatei : int);
local begin
  Erx     : int;
  vFeld   : alpha;
  vTds    : int;
  vFld    : int;
  vItem   : int;
  vCount  : int;
  vA      : alpha;
  vMFile  : int;
  vMID    : int;
  vI      : int;
  vW      : word;
  vF      : float;
  vD      : date;
  vArt    : alpha;
  vT      : time;
  vOK     : logic;
end;
begin

  if (Rechte[Rgt_SerienEdit]=false) then RETURN;

  Msg(997001,'',0,0,0);
  vFeld # Prg_Para_Main:ParaAuswahl('Felder','','',aDatei);
  if  (vFeld='') then RETURN;

  vTds   # FldInfoByName(vFeld,_FldSbrnumber);
  vFld   # FldInfoByName(vFeld,_Fldnumber);

  vA # '';
  vOK # y;
  case FldInfo(aDatei, vTds, vFld, _FldType) of

    _TypeAlpha  : begin
      vOk # Dlg_Standard:Standard('neuer Inhalt',var vA);
      if (StrLen(vA)>FldInfo(aDatei, vTds, vFld, _FldLen)) then
        vA # StrCut(vA,1,FldInfo(aDatei, vTds, vFld, _FldLen));
    end;

    _TypeDate   : begin vOk # Dlg_Standard:Datum('neuer Inhalt',var vD); vA # cnvad(vd); end;

    _Typeword   : begin vOk # Dlg_Standard:Anzahl('neuer Inhalt',var vI); vW # vI; vA # cnvai(vW); end;

    _typeint    : begin vOk # Dlg_Standard:Anzahl('neuer Inhalt',var vI); vA # cnvai(vI); end;

    _Typefloat  : begin
                  Erx # WindialogBox(gFrmMain,gTitle,'Wollen Sie eine prozentuale Änderung durchführen?',_WinIcoQuestion, _WinDialogYesNoCancel |_WinDialogAlwaysOnTop,1);
                  if (Erx=_WinIdCancel) then RETURN;
                  if (Erx=_WinIdYes) then begin
                    vArt # '%';
                    vOk # Dlg_Standard:Menge('Prozentabweichung',var vF);
                    vA # cnvaf(vF)+'%';
                  end
                  else begin
                    Erx # WindialogBox(gFrmMain,gTitle,'Wollen Sie einen festen Wert addieren/subtrahieren?',_WinIcoQuestion, _WinDialogYesNoCancel |_WinDialogAlwaysOnTop,1);
                    if (Erx=_WinIdCancel) then RETURN;
                    if (Erx=_WinIdYes) then begin
                      vArt # '+-';
                      vOk # Dlg_Standard:Menge('Differenz',var vF);
                      vA # cnvaf(vF);
                    end
                    else begin
                      vArt # 'fix';
                      vOk # Dlg_Standard:Menge('neuer Inhalt',var vF);
                      vA # cnvaf(vF);
                    end;
                  end;
      end;

    _typelogic  : case WindialogBox(gFrmMain,gTitle,'Neuer Inhalt',_WinIcoQuestion, _WinDialogYesNoCancel |_WinDialogAlwaysOnTop,1) of
                    _WinIdYes : begin vA # 'Ja'; end;
                    _winIdNo  : begin vA # 'Nein'; end;
                    _WinIdCancel : RETURN;
                  end;
    _TypeTime   : begin vOk # Dlg_Standard:Zeit('neuer Inhalt',var vT); vA # Cnvat(vT); end;
  end;
  if (vOk=false) then RETURN;

  // Markierungsliste durchlaufen und dieses Feld belegen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=aDatei) then inc(vCount);

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (Msg(997002,cnvai(vCount)+'|'+vFeld+'|'+vA,_WinIcoQuestion,_winDialogYesNo,1)=_WinIdNO) then RETURN;

  TRANSON;

  // Markierungsliste durchlaufen und dieses Feld belegen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=aDatei) then begin
      Erx # RecRead(aDatei,0,_recLock,vMID);
      PtD_main:Memorize(aDatei);
      if (erx=_rOK) then begin

        case FldInfo(aDatei, vTds, vFld, _FldType) of
          _TypeAlpha  : FldDef(aDatei,vTds,vFld,vA);
          _TypeDate   : FldDef(aDatei,vTds,vFld,vD);
          _Typeword   : FldDef(aDatei,vTds,vFld,vW);
          _typeint    : FldDef(aDatei,vTds,vFld,vI);
          _Typefloat  : begin
            if (vArt='%') then
              FldDef(aDatei,vTds,vFld, FldFloat(aDatei,vTds,vFld) * (vF+100.0) / 100.0)
            else if (vArt='+-') then
              FldDef(aDatei,vTds,vFld, FldFloat(aDatei,vTds,vFld) + vF)
            else
              FldDef(aDatei,vTds,vFld,vF);
            end;
          _typelogic  : FldDef(aDatei,vTds,vFld,vA='Ja');
          _TypeTime   : FldDef(aDatei,vTds,vFld,vT);
        end;

        Erx # RekReplace(aDatei,_recUnlock,'AUTO');
        if (erx<>_rOK) then begin
          Ptd_Main:Forget(aDatei);
          BREAK;
        end;
        PtD_Main:Compare(aDatei);
      end;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (erx<>_rOK) then begin
    TRANSBRK;
    Msg(997004,'',0,0,0);
  end
  else begin
    TRANSOFF;
    Msg(997003,'',0,0,0);
  end;

  if (gZLList<>0) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;

end;


//========================================================================
//  SetPreis
//
//========================================================================
SUB SetPreis(aTyp : alpha);
local begin
  Erx     : int;
  vCount  : int;
  vItem   : int;
  vItem2  : int;
  vF      : float;
  vD1,vD2 : date;
  vAblauf : date;
  vOK     : logic;
  vFehler : logic;
  vMFile  : int;
  vMID    : int;
end;
begin

  vOk # Dlg_Standard:DatumVonBis('Gültigkeitszeitraum des neuen Preises',var vD1,var vD2);
  if (vOk=false) then RETURN;
  vAblauf # vD1;
  vAblauf->vmdaymodify(-1);

  vOk # Dlg_Standard:Menge('Prozentabweichung',var vF);
  if (vOk=false) then RETURN;

  // Markierungsliste durchlaufen und dieses Feld belegen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=250) then inc(vCount);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (Msg(997002,cnvai(vCount)+'|'+aTyp+'-Preis'+'|'+cnvaf(vF)+'%',_WinIcoQuestion,_winDialogYesNo,1)=_WinIdNO) then RETURN;

  // ALLE Preismarker entfernen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=254) then begin
      vItem2 # gMarkList->CteRead(_CteNext,vItem);
      gMarkList->CteDelete(vItem);
      vItem # vItem2;
    end
    else begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
    end;
  END;


  // zutreffende Preise markieren
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=250) then begin
      // Artikel holen
      Erx # RecRead(250,0,0,vMID);
      if (erx<>_rOK) then BREAK;

      // Preise loopen
      Erx # RecLink(254,250,6,_RecFirsT);
      WHILE (erx<=_rLocked) do begin
        if (Art.P.Datum.Bis=Art.P.Datum.Von) and (Art.P.Datum.Bis=0.0.0) then Art.P.Datum.Bis # today;
        if (Art.P.Datum.Von>today) or (Art.P.Datum.Bis<today) or (Art.P.Adressnr<>0) or (Art.P.Preistyp<>aTyp) then begin
          Erx # RecLink(254,250,6,_RecNext);
          CYCLE;
        end;

        MarkAdd(254,n,y);

        Erx # RecLink(254,250,6,_RecNext);
      END;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  TRANSON;

  vFehler # n;
  // Markierungsliste durchlaufen und dieses Feld belegen
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin

    TokenMark(vItem,var vMFile,var vMID);
//    vMFile # Cnvia(Str_Token(vItem->spname,'/',1));
//    vMID   # Cnvia(Str_Token(vItem->spname,'/',2));
    if (vMFile=254) then begin
      // alten Preis umdatieren
      RecRead(254,0,_recLock,vMID);
      Art.P.Datum.Bis # vAblauf;
      Erx # Art_P_Data:Replace(_recUnlock,'MAN');
      if (erx<>_rOK) then begin
         vFehler # y;
        BREAK;
      end;

      Art.P.Basispreis # Art.P.Basispreis * (vF+100.0) / 100.0;
      Art.P.Preis # Art.P.Basispreis * ((100.0-"Art.P.RabattProz")/100.0);
      Wae_Umrechnen(Art.P.Preis,"Art.P.Währung",var Art.P.PreisW1, 1);
      Art.P.Datum.Von # vD1;
      Art.P.Datum.Bis # vD2;

      Art.P.Nummer        # 0;
      REPEAT
        Art.P.Nummer # Art.P.Nummer + 1;
        art_P_Data:Insert(0,'MAN');
      UNTIL (Erx=_rOK) or (Art.P.Nummer=1000);
      if (Art.P.Nummer=1000) then begin
        vFehler # y;
        BREAK;
      end;

    end;

    gMarkList->CteDelete(vItem);

    vItem # gMarkList->CteRead(_CteFirst);
  END;


  if (vFehler) then begin
    TRANSBRK;
    Msg(997004,'',0,0,0);
  end
  else begin
    TRANSOFF;
    Msg(997003,'',0,0,0);
  end;

  if (gZLList<>0) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;

end;


//========================================================================
//  Filter
//
//========================================================================
SUB Filter();
local begin
  Erx       : int;
  vHdl      : int;
  vSel      : int;
  vSelName  : alpha;
  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vPrgr     : handle;

  vVorSel   : int;
  vWinBon   : int;
end;
begin

  // bisherige Mark-Sel rausnehmen...
  if (gZLList->wpdbselection<>0) and (StrFind(w_selName,'.MARK',0)>0) then begin

    gZLList->wpautoupdate # n;
    vHdl # gZLList->wpdbselection;
    gZLList->wpDbSelection # 0;
    SelClose(vHdl);
    SelDelete(gFile,w_selName);
    w_SelName # '';
    vHdl # gMenu->WinSearch('Mnu.Mark.Filter');
    if (vHdl<> 0) then vHdl->wpMenucheck # n;

    if (w_SelVorherName<>'') and (w_SelVorherHdl<>0) then begin
      Lib_Sel:Run(w_SelVorherHdl);
      gZLList->wpDbSelection # w_SelVorherHdl;
      w_SelName       # w_SelVorherName;
      w_SelVorherName # '';
      w_SelVorherHdl  # 0;
      gZLList->wpautoupdate # y;
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer|_WinLstRecDoSelect);
      RETURN;
    end;
    gZLList->wpautoupdate # y;

    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    RETURN;
  end;

  // std.Selektion JOINEN mit Mart-Sel...
  if (gZLList->wpdbselection<>0) then begin
    vVorSel # gZLList->wpdbselection ;
    w_SelVorherName # w_Selname;
    w_SelVorherHdl  # vVorSel;
  end;

  vHdl # VarInfo(WindowBonus);

  vSel # SelCreate(gFile,gZLList->wpdbKeyno);

  vSelName # Lib_Sel:Save(vSel,'.MARK');

  varInstance(WindowBonus, Cnvia(gMDI->wpcustom));
  w_SelName # vSelname;
  varInstance(WindowBonus, vHdl);

//  vSel # aHdl->SelOpen();
//  vSel->SelStore

  vHdl # SelOpen();
  vHdl->SelRead( gFile, _selLock, vSelName );

  vPrgr # Lib_Progress:Init( 'Filterung...', gMarkList->CteInfo( _cteCount ) );

  if (vVorSel=0) then begin
    FOR  vItem # gMarkList->CteRead( _cteFirst );
    LOOP vItem # gMarkList->CteRead( _cteNext, vItem );
    WHILE ( vItem > 0 ) and ( vPrgr->Lib_Progress:Step() ) DO BEGIN
      TokenMark( vItem, var vMFile, var vMID );
      if ( vMFile = gFile ) then begin
        Erx # RecRead( vMFile, 0, 0, vMID );
        Erx # vHdl->SelRecInsert( gFile );
      end;
    END;
  end
  else begin
    Erx # RecRead(gFile,vVorSel,_recFirst);
    WHILE (erx<=_rLocked) do begin
      if (istmarkiert(gFile,RecInfo(gFile, _recId))) then
        Erx # vHdl->SelRecInsert( gFile );

      Erx # RecRead(gFile,vVorSel,_recNext);
    END;
  end;


  vPrgr->Lib_Progress:Term();

  gZLList->wpDbSelection # vHdl;
//todo('Link:'+aint(RecLinkInfo(122,120,4,_RecCount)));
//todo('sel:'+aint(RecInfo(120,_RecCount,vHdl)));
//todo('Link:'+aint(RecLinkInfo(122,vHdl,4,_RecCount)));

  vHdl # gMenu->WinSearch('Mnu.Mark.Filter');
  if (vHdl<> 0) then vHdl->wpMenucheck # y;

  //gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromBuffer|_WinLstRecDoSelect);

end;


//========================================================================
//  Reset
//
//========================================================================
SUB Reset(
  aFile         : int;
  opt aNoZLList : logic;
  );
local begin
  vItem   : int;
  vItem2  : int;
  vMFile  : int;
  vMID    : int;
  vBuf    : int;
end;
begin

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=aFile) then begin
      vItem2 # gMarkList->CteRead(_cteNext,vItem);
      gMarkList->CteDelete(vItem);
      vItem # vItem2;
    end
    else begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
    end;
  END;

  if (gZLList<>0) and (aNoZLList=false) then begin
    if (HdlInfo(gZLList, _HdlExists)=0) then RETURN;  // 28.01.2021 AHGWS
    if (gZLList->wpDbFileNo<>aFile) then RETURN;      // 2023-04-18 AH Proj. 2335/24
/* 2023-07-20  AH Proj. 2511/6
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecDoSelect); //2023-03-21  MR  Fix von Buffe Fehler 2430/50
    Das verspringt die Buffer 400+500 !!!
*/

  end;

end;


//========================================================================
//  IstMarkiert
//
//========================================================================
SUB istmarkiert(aFile : int; aID : int) : logic;
begin
  if (gMarkList->CteRead(_CteFirst | _CteSearch, 0, cnvai(aFile)+'/'+cnvai(aID))<>0) then RETURN true;
  RETURN false;
end;


//========================================================================
//  Count
//
//========================================================================
sub Count(aFile : int) : int;
local begin
  vC      : int;
  vItem   : int;
  vMFile  : int;
  vMID    : int;
end;
begin

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=aFile) then vC # vC + 1;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RETURN vC;
end;

//========================================================================
//  Foreach
//
//========================================================================
sub Foreach(aFile : int; aFunc : alpha; opt aPara : alpha) : int;
local begin
  Erx     : int;
  vErr    : int;
  vItem   : int;
  vMFile  : int;
  vMID    : int;
end;
begin

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) and (vErr=0) do begin
    TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=aFile) then begin
      Erx # RecRead(vMFile,0,0,vMID);
      if (erx>_rLocked) then begin
        Erg # Erx; // TODOERX
        RETURN Erx;
      end;
      if (aPara <> '') then
        vErr # Call(aFunc,aPara);
      else
        vErr # Call(aFunc);
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  Erg # vErr; // TODOERX
  RETURN vErr;
end;

//========================================================================
//  Iterate
//
//========================================================================
sub Iterate(
  aFile       : int;
  var aItem   : int;
  opt aDL     : logic) : int;
local begin
  Erx     : int;
  vErr    : int;
  vMFile  : int;
  vMID    : int;
end;
begin

  if (aItem=0) then begin
    FOR aItem # gMarkList->CteRead(_CteFirst)
    LOOP aItem # gMarkList->CteRead(_CteNext,aItem);
    WHILE (aItem<>0) do begin
      TokenMark(aItem,var vMFile,var vMID);
      if (vMFile=aFile) then begin
        if (aDL=false) then begin
          Erx # RecRead(vMFile,0,0,vMID);
          if (Erx>_rLocked) then RETURN 0;
          RETURN aItem;
        end;
        RETURN vMID;
      end;
    END;
    RETURN 0;
  end;

  FOR aItem # gMarkList->CteRead(_CteNext,aItem);
  LOOP aItem # gMarkList->CteRead(_CteNext,aItem);
  WHILE (aItem<>0) do begin
    TokenMark(aItem,var vMFile,var vMID);
    if (vMFile=aFile) then begin
      if (aDL=false) then begin
        Erx # RecRead(vMFile,0,0,vMID);
        if (Erx>_rLocked) then RETURN 0;
        RETURN aItem;
      end;
      RETURN vMID;
    end;
  END;

  RETURN 0;
end;




//========================================================================
// sub SumFloatFldGV100(aPara : alpha) : int   ST 2021-08-24 Projekt 2166/30
//
//  Summiert eine per Feldnamen übergebene Spalte als Summe in Gv.Num.100
//========================================================================
sub SumFloatFldGV100(aPara : alpha) : int
local begin
  vValFloat  :  float
end
begin
  vValFloat # FldFloatByName(aPara);
  Gv.Num.100 # Gv.Num.100 + vValFloat;
  RETURN _rOK;
end;

//========================================================================