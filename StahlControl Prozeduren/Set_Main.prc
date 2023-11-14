@A+
//==== Business-Control ==================================================
//
//  Prozedur    Set_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  26.09.2018  AH  Neu: "Check" prüft Printserver-Version
//  21.07.2021  ST  Fix: "Check" echte Fehlermeldung für Job-Server Prj 2222/76
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB Check()
//
//========================================================================
@I:Def_Global

//========================================================================
// Verwaltung
//
//========================================================================
sub Verwaltung();
local begin
  Erx     : int;
  vModule : alpha;
end;
begin
  vModule # Set.Module;
  RecRead(903,1,_RecLock);

  if (WinDialog('Set.Verwaltung',_WinDialogCenter,gFrmMain)=2) then begin

    if (Set.Druckerpfad='') then begin
// 07.06.2016 AH: %temp%
//      Msg(999999,'Druckerausgabepfad fehlt!',_WinIcoError,_windialogok,1);
    end
    else begin

      if (StrCut(Set.Druckerpfad, StrLen(Set.Druckerpfad),1)<>'\') then
        Set.Druckerpfad # Set.Druckerpfad + '\';
      if (StrCut(Set.Druckerpfad, 1,1)='.') then
        Set.Druckerpfad # StrCut(Set.Druckerpfad,2,1000);

      if (StrCut(Set.Druckerpfad, 1,2) <> '\\') then begin
        if (StrCut(Set.Druckerpfad, 1,1)='\') then
          Set.Druckerpfad # StrCut(Set.Druckerpfad,2,1000);

        if (StrCut(Set.Druckerpfad, 2,1)<>':') then
          Set.Druckerpfad # FSIPath() +'\' + Set.Druckerpfad;
      end;


      Erx # FsiOpen(Set.Druckerpfad+'TEST.TXT', _FsiAcsRW | _FsiCreate | _FsiTruncate);
      if (Erx<0) then begin
        Msg(912005,'',_WinIcoError,_windialogok,1);
      end
      else begin
        Erx->FsiCLose();
        FsiDelete(Set.Druckerpfad+'TEST.TXT');
      end;
    end;

    // Dateipfade korrigieren und prüfen
    Set.SOA.Path # Lib_FileIO:CorrectPath(Set.SOA.Path);
    if (Set.ExtArchiev.Path<>'CA1') then
      Set.ExtArchiev.Path # Lib_FileIO:CorrectPath(Set.ExtArchiev.Path);
//    if (Lib_FileIO:PathExists(Set.SOA.Path+'log')=false) then
//      Msg(999999,'Path does not exist: '+Set.SOA.Path, _WinIcoError, _WinDialogOk,1);

    RekReplace(903,_RecUnLock,'AUTO');

  end
  else begin
    RecRead(903,1,_RecUnLock);
  end;

  Lib_Initialize:ReadIni();

  Set.Module # vModule;
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  $colb.Art.SL.Col1->wpCaptionColor   # Set.Art.SL.Col.Sperr;
  $colb.Art.SL.Col2->wpCaptionColor   # Set.Art.SL.Col.Refsh;
  $colb.Art.SL.Col3->wpCaptionColor   # Set.Art.SL.Col.Resso;
  $colb.Art.SL.Col4->wpCaptionColor   # Set.Art.SL.Col.ArG;
  $colb.Art.SL.Col5->wpCaptionColor   # Set.Art.SL.Col.Text;

  $colb.Mat.Frei->wpCaptionColor      # Set.Mat.Col.Frei;
  $colb.Mat.Fremd->wpCaptionColor     # Set.Mat.Col.Fremd;
  $colb.Mat.Gesperrt->wpCaptionColor  # Set.Mat.Col.Gesperrt;

  $colb.Mat.Bestellt->wpCaptionColor  # Set.Mat.Col.Bestellt;
  $colb.Mat.EKVSB->wpCaptionColor     # Set.Mat.Col.EKVSB;
  $colb.Mat.Reserv->wpCaptionColor    # Set.Mat.Col.Reserv;
  $colb.Mat.TeilRes->wpCaptionColor   # Set.Mat.Col.TeilRes;
  $colb.Mat.Kommi->wpCaptionColor     # Set.Mat.Col.Kommissi;
  $colb.Mat.inBAG->wpCaptionColor     # Set.Mat.Col.inBAG;
  $colb.RList.Cursor->wpCaptionColor  # Set.Col.RList.Cursor;
  $colb.RList.Marke->wpCaptionColor   # Set.Col.RList.Marke;
  $colb.RList.Deleted->wpCaptionColor # Set.Col.RList.Deletd;
  $colb.RList.CurOff->wpCaptionColor  # "Set.Col.RList.CurOff";
  $colb.Field.Cursor->wpCaptionColor  # Set.Col.Field.Cursor;

  $colb.Auf.Frei1->wpCaptionColor     # Set.Auf.Col.Frei1;
  $colb.Auf.Frei2->wpCaptionColor     # Set.Auf.Col.Sperre;
  $colb.Auf.Ang->wpCaptionColor       # Set.Auf.Col.Ang;
  $colb.Auf.Gut->wpCaptionColor       # Set.Auf.Col.Gut;
  $colb.Auf.LVertrag->wpCaptionColor  # Set.Auf.Col.LVertrag;

end;


//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vA    : alpha;
  vName : alpha;
end;
begin
  case (aEvt:Obj->wpname) of

    'Bt.Import' : begin
      vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'Settings-Dateien|*.set');
      if (vName='') then RETURN false;
      If (Msg(998005,vName,_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then begin
        CallOld('old_autoTransfer',903,y,vName);
        RETURN true;
      end;
    end;

    'Bt.Export' : begin
      vName # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'Settings-Dateien|*.set');
      if (vName='') then RETURN false;
      if (StrCnv(StrCut(vName,strlen(vName)-3,4),_StrUpper) <>'.SET') then vName # vName + '.set';
      If (Msg(998003,vName,_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then begin
        CallOld('old_autoTransfer',903,n,vName);
        RETURN true;
      end;
    end;

    'colb.Auf.Frei1' : begin
      Set.Auf.Col.Frei1 # $colb.Auf.Frei1->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Auf.Frei2' : begin
      Set.Auf.Col.Sperre # $colb.Auf.Frei2->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Auf.Ang' : begin
      Set.Auf.Col.Ang # $colb.Auf.Ang->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Auf.Gut' : begin
      Set.Auf.Col.Gut # $colb.Auf.Gut->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Auf.LVertrag' : begin
      Set.Auf.Col.LVertrag # $colb.Auf.LVertrag->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;


    'colb.Art.SL.Col1' : begin
      Set.Art.SL.Col.Sperr # $colb.Art.SL.Col1->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Art.SL.Col2' : begin
      Set.Art.SL.Col.RefSh # $colb.Art.SL.Col2->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Art.SL.Col3' : begin
      Set.Art.SL.Col.Resso # $colb.Art.SL.Col3->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Art.SL.Col4' : begin
      Set.Art.SL.Col.ArG   # $colb.Art.SL.Col4->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Art.SL.Col5' : begin
      Set.Art.SL.Col.Text  # $colb.Art.SL.Col5->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;


    'colb.Mat.Frei' : begin
      Set.Mat.Col.Frei # $colb.Mat.Frei->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.Fremd' : begin
      Set.Mat.Col.Fremd # $colb.Mat.Fremd->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.Gesperrt' : begin
      Set.Mat.Col.Gesperrt # $colb.Mat.Gesperrt->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.Bestellt' : begin
      Set.Mat.Col.Bestellt # $colb.Mat.Bestellt->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.EKVSB' : begin
      Set.Mat.Col.EKVSB # $colb.Mat.EKVSB->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.Reserv' : begin
      Set.Mat.Col.Reserv # $colb.Mat.Reserv->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.TeilRes' : begin
      Set.Mat.Col.TeilRes # $colb.Mat.TeilRes->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.Kommi' : begin
      Set.Mat.Col.Kommissi # $colb.Mat.Kommi->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Mat.inBAG' : begin
      Set.Mat.Col.inBAG # $colb.Mat.inBAG->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.Field.Cursor' : begin
      Set.Col.Field.Cursor # $colb.Field.Cursor->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.RList.Cursor' : begin
      Set.Col.RList.Cursor # $colb.RList.Cursor->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.RList.Marke' : begin
      Set.Col.RList.Marke # $colb.RList.Marke->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.RList.CurOff' : begin
      "Set.Col.RList.CurOff" # $colb.RList.CurOff->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;
    'colb.RList.Deleted' : begin
      Set.Col.RList.Deletd # $colb.RList.Deleted->wpCaptionColor;
      $Set.Verwaltung->winupdate(_WinUpdFld2Obj);
    end;


    'bt.saveTAPI' : begin
      Lib_Initialize:SaveIni();
    end;

    'bt.saveBarPort' : begin
      Lib_Initialize:SaveIni();
    end;

    'bt.TAPI' : begin
      vA # Prg_Para_Main:ParaAuswahl('TAPI','','zzz');
      if (vA<>'') then Set.TAPI.Name # vA;
      $edSet.TAPI.Name->WinFocusSet();
      $Set.Verwaltung->WinUpdate();
    end;
  end;
end;


//========================================================================
//  Check
//
//========================================================================
sub Check() : logic;
local begin
  vOK : logic;
  vA  : alpha(4000);
end;
begin

  vOK # true;

  // Set.BA.Lohnkost.wie
  if (Set.BA.Lohnkost.wie<>'K') and (Set.BA.Lohnkost.wie<>'G') then begin
    Msg(903000,Translate('BA-Kosten'),0,0,0);
    vOK # false;
  end;

  if(Set.DMS.AF.ApiPath <> '') then begin // ArcFlow aktiv?
    if ( ((Set.DMS.PDFPath = '') and (Set.DMS.AF.Drucker = '')) or (Set.DMS.MetadataPath = '') ) then begin
      Msg(903000,Translate('ArcFlow Metadaten/PDF/Drucker Dateipfad'),0,0,0);
      vOK # false;
    end;
  end;


  if (Set.Mech.Dehnung.Wie<>1) and (Set.Mech.Dehnung.Wie<>2) then begin
    Msg(903000,Translate('Dehnungslängenfeld'),0,0,0);
    vOK # false;
  end;

  // 26.09.2018 AH: PrintServer Verison checken...
  if (Set.SQL.Database<>'') and (Set.SQL.Instance<>'') and (Set.SQL.PrintsrvURL<>'') then begin
    vA # Lib_DotNetServices:Version('');//  20.10.2020 AH: UrlUmbau Lib_DotNetServices:ServerURL());
    if (vA<>'OK') then begin
      vA # 'PrintServer-Versions-Problem: '+vA;
      // ST 2021-07-21 P 2222/76: Jobserver bei der Anmeldung Fehlermeldung anzeigen, die durch "Msg(...)" unterdrückt würde
      if (gUsergroup = 'JOB-SERVER') then
        WindialogBox(0,'Login',vA, _WinIcoError, _Windialogok|_WinDialogAlwaysOnTop,1);
      else
        Msg(99,vA,0,0,0);
    end;
  end;
  
  RETURN vOK;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================