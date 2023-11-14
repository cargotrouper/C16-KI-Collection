@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lfm_Ausgabe
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  02.08.2013  AH  NEU: SQL-Listen
//  13.03.2015  AH  NEU: SQL-Listen werden rausgefilter, wenn kein Link besteht
//  20.07.2016  AH  User-Vertretung
//  16.02.2022  AH  ERX, "Cleanup"
//
//  Subprozeduren
//    SUB Cleanup();
//    SUB Starten(aNr : int)
//    SUB Auswahl(aBereich : alpha)
//    SUB EvtKeyItem(aEvt : event; aKey : int; aID : int)
//    SUB EvtMouseItem(aEvt : event; aButton : int; aHit : int; aItem : int; aID : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB evtlstselect(aevt : event; aRecId : int) : logic
//    SUB EvtLstRecControl(aEvt : event; aRecID : int) : logic
//
//========================================================================
@I:Def_global

LOCAL begin
end;

//========================================================================
//  Cleanup   17.02.2022 AH
//========================================================================
sub Cleanup()
begin
  // Struktur entfernen
  if ( VarInfo( Class_List ) != 0 ) then begin
    VarFree(Class_List);
  end;
end;


//========================================================================
// Starten
//          Startet das Listenformat mit der angegebenen Nummer
//========================================================================
sub Starten(
  aKuerzel  : alpha;
  aNr       : int;
)
local begin
  Erx       : int;
  vFileName : alpha(250);
  vSel      : int;
  vFileHdl  : handle;
  vOK       : logic;
  v800      : int;
end;
begin
  gSQLBuffer  # 0;
  RecBufClear(910);
  Lfm.Kuerzel # aKuerzel;
  Lfm.Nummer  # aNr;
  Erx # RecRead(910,1,0);
  if (Erx<>_rOk) then begin
    Msg(910001,CnvAI(aNr),0,0,0);
    RETURN;
  end;

  if (Lfm.EinzelrechtYN) then begin
    RecBufClear(911);
    vOK # true;
    Lfm.Usr.Kuerzel   # Lfm.Kuerzel;
    Lfm.Usr.Nummer    # Lfm.Nummer;
    Lfm.Usr.Username  # gUsername;
    Erx # RecRead(911,1,0);
    if (Erx>_rLocked) then begin
      // Vertretung?
      vOK # false;
      v800 # RecBufCreate(800);
      v800->Usr.VertretungUser # gUsername;
      Erx # RecRead(v800,4,0);
      WHILE (Erx<=_rMultiKey) and (v800->Usr.VertretungUser=gUsername) do begin

        if (today<v800->Usr.VertretungVonDat) or (today>v800->Usr.VertretungBisDat) then begin
          Erx # RecRead(v800,4,_recNext);
          CYCLE;
        end;

        Lfm.Usr.Kuerzel   # Lfm.Kuerzel;
        Lfm.Usr.Nummer    # Lfm.Nummer;
        Lfm.Usr.Username  # v800->Usr.Name;
        Erx # RecRead(911,1,0);
        if (Erx<=_rLocked) then begin
          vOK # true;
          BREAK;
        end;
      END;
      RecBufDestroy(v800);
    end;

    if (vOK=False) then begin
      Msg(911001,'',0,0,0);
      RETURN;
    end;
  end;


  // SQL-Liste?
// 07.06.2015 AH  if (cnvia(Lfm.Prozedur)<10000) and ((Lfm.Ausgabeart='') or (Lfm.Ausgabeart='?')) then
if (cnvia(Lfm.Prozedur)<10000) and ((Lfm.Ausgabeart='')) then
    Lfm.Ausgabeart # 'S';
  if (cnvia(Lfm.Prozedur)<10000) and (Lfm.Ausgabeart<>'S') then begin
lfm.ausgabeart # '?';
/*** 10.12.2014   alles im SELEKTIONSDIALOG*/
    if (Lfm.Ausgabeart='?') then begin
      if (Msg(99,'Soll die Liste als Exceldatei (XML) gespeichert werden?',_WinIcoQuestion,_WinDialogYesNo, 2)=_winidyes) then Lfm.Ausgabeart # 'X';
    end;
    if (Lfm.Ausgabeart='X') then begin
      if ( gUsergroup = 'JOB-SERVER' ) or (gUsername=*^'SOA*') then begin
        vFileName # Job.Parameter;
      end
      else begin
        // Filename abfragen
        REPEAT
          vFilename # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'Excel-Dateien|*.xml', vFilename);
          if (vFilename = '' ) then RETURN;
          if (Lib_FileIO:FileExists(vFilename)) then
            if (Msg(910006,'',0,_WinDialogYesNo, 2)=_winidno) then CYCLE;
        UNTIL (1=1);
        if ( StrCnv( StrCut( vFilename, StrLen( vFilename ) - 3, 4 ), _strLower ) != '.xml' ) then
          vFilename # vFilename + '.xml';

      // Datei testen
        vFileHdl # FsiOpen( vFileName, _fsiAcsRW | _fsiDenyRW | _fsiCreate );
        if ( vFileHdl > 0 ) then
          vFileHdl->FsiClose();
        else begin
          Msg( 910004, vFileName, 0, 0, 0 );
          RETURN;
        end;

      end;
    end;
/***/

    VarAllocate( Class_List );
    list_FileName # vFileName;
    List_MDI      # gMDI;

    try begin
      ErrTryIgnore( _rLocked, _rNoRec );
      ErrTryCatch( _ErrNoProcInfo, true );
      ErrTryCatch( _ErrNoSub, true );
      Call( Lfm.Prozedur ); // Standardlistenprozedur starten
    end;
    Erx # Errget();
    if (Erx<>_errok) then begin
    //if ( ErrGet() != _errOK ) then begin
      if ((gUsergroup <> 'SOA_SERVER') AND ((gUsergroup <> 'JOB-SERVER'))) then
        Todo( 'Listenprozedur ' + Lfm.Prozedur+'   E:'+aint(erx));
    end;

    RETURN;
  end;  // SQL-Liste




  if (gUsergroup='JOB-SERVER') or (gUsername=*^'SOA*') then begin
    if (Job.Parameter='') then Lfm.Ausgabeart # 'P'
    else Lfm.Ausgabeart # 'X';
  end;

  // XML-Ausgabe möglich?, dann nachfragen
  if (Lfm.Ausgabeart='') then Lfm.Ausgabeart # '?';

  if (Lfm.Ausgabeart='?') then begin
    if (StrFind(StrCnv(Lfm.Listenformat,_Strupper),'.FRX',0)>0) then  begin
      if (Msg(910007,'',0,_WinDialogYesNo, 2)=_winidyes) then Lfm.Ausgabeart # 'X';
    end
    else begin
      if (Msg(910002,'',0,_WinDialogYesNo, 2)=_winidyes) then Lfm.Ausgabeart # 'X';
    end;
  end;

  // XML-Ausgabe?
  if ( Lfm.Ausgabeart = 'X' ) then begin
    if ( gUsergroup = 'JOB-SERVER' ) or (gUsername=*^'SOA*') then begin
      vFilename # Job.Parameter;
    end
    else begin
      // Filename abfragen
      REPEAT
        if (StrFind(StrCnv(Lfm.Listenformat,_Strupper),'.FRX',0)>0) then begin
          vFileName # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML-Dateien|*.xml', vFilename);
        end
        else begin
          vFileName # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML-Dateien|*.xml', vFilename);
        end;
        if ( vFileName = '' ) then RETURN;
        vFileHdl # FsiOpen(vFilename,_FsiStdRead);
        if (vFileHdl > 0) then begin
          vFileHdl->FsiClose();
          if (Msg(910006,'',0,_WinDialogYesNo, 2)=_winidno) then CYCLE;
        end;
      UNTIL (1=1);
    end;


    if ( StrCnv( StrCut( vFileName, StrLen( vFileName ) - 3, 4 ), _strLower ) != '.xml' ) then
      vFileName # vFileName + '.xml';

    // Datei testen
    vFileHdl # FsiOpen( vFileName, _fsiAcsRW | _fsiDenyRW | _fsiCreate );
    if ( vFileHdl > 0 ) then
      vFileHdl->FsiClose();
    else begin
      Msg( 910004, vFileName, 0, 0, 0 );
      RETURN;
    end;

    Cleanup();

    VarAllocate( Class_List );
    list_XML      # true;
    list_FileName # vFileName;
  end
  else if ( Lfm.Ausgabeart != '' ) then begin // XML-Format, aber drucken...
    // Struktur erzeugen
    VarAllocate( Class_List );
    list_XML # false;
  end;

  List_MDI # gMDI;
/*
  if (gFile=Lfm.File) then begin
    if (gZLList<>0) then begin
      if (gZLList->wpDbSelection<>0) then begin
        vSel # gZLList->wpDbSelection;
        gZLList->wpDbSelection # 0;
        SelClose(vSel);
      end;
    end;
  end;
*/

  // Listenprozedur starten [16.03.2010/PW]
  WinEvtProcessSet( _winEvtTimer, false );

  if ( Set.TranslateYN ) and ( Set.Listen.Postfix != '' ) then begin
    try begin
      ErrTryIgnore( _rLocked, _rNoRec );
      ErrTryCatch( _ErrNoProcInfo, true );
      ErrTryCatch( _ErrNoSub, true );
      Call( Lfm.Prozedur + Set.Listen.Postfix ); // Speziallistenprozedur starten
    end;
    if ( ErrGet() != _errOK ) then begin
      try begin
        ErrTryIgnore( _rLocked, _rNoRec );
        ErrTryCatch( _ErrNoProcInfo, true );
        ErrTryCatch( _ErrNoSub, true );
        Call( Lfm.Prozedur ); // Standardlistenprozedur starten
      end;
      Erx # Errget();
      if (Erx<>_errok) then begin
      //if ( ErrGet() != _errOK ) then begin
        Todo( 'Listenprozedur ' + Lfm.Prozedur+'   E:'+aint(Erx));
      end;
    end;
  end
  else begin
    try begin
      ErrTryIgnore( _rLocked, _rNoRec );
      ErrTryCatch( _ErrNoProcInfo, true );
      ErrTryCatch( _ErrNoSub, true );
      Call( Lfm.Prozedur ); // Standardlistenprozedur starten
    end;
    Erx # Errget();
    if (Erx<>_errok) then begin
    //if ( ErrGet() != _errOK ) then begin
      if ((gUsergroup <> 'SOA_SERVER') AND ((gUsergroup <> 'JOB-SERVER'))) then
        Todo( 'Listenprozedur ' + Lfm.Prozedur+'   E:'+aint(Erx));
    end;
  end;

  WinEvtProcessSet( _winEvtTimer, true );

end;



//========================================================================
// Auswahl
//          Zugriffsliste der zum Bereich passenden Listen öffnen
//========================================================================
sub Auswahl(
  aBereich        : alpha;
  opt aNurAuswahl : logic;
) : logic
local begin
  Erx       : int;
  vMode     : alpha;
  vFilter   : int;
  vHdl      : int;
end;
begin

  gSelected # 0;

  if (HdlInfo(gMDI, _HdlExists)=0) then RETURN false;   // 13.08.2015

  if (gUsergroup='PROGRAMMIERER') then begin
    vFilter # RecFilterCreate(910,3);
    vFilter->RecFilterAdd(1,_fltAND,_FltEq, aBereich);
    vHdl # WinOpen('Lfm.Auswahl',_WinOpenDialog);
    $ZL.Listenauswahl->wpDBKeyNo  # 3;
    $ZL.Listenauswahl->wpDBFilter # vFilter;
  end
  else begin
    vFilter # RecFilterCreate(910,2);
    vFilter->RecFilterAdd(1,_fltAND,_FltEq, aBereich);
    vHdl # WinOpen('Lfm.Auswahl',_WinOpenDialog);
    $ZL.Listenauswahl->wpDBFilter # vFilter;
  end;
  //WinDialog('Lfm.Auswahl',_WinDialogCenter,gMdi);

  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl->WinClose();

  RecFilterDestroy(vFilter);
 // msg(700900,cnvai(gselected),0,0,0);
  if (gSelected=0) then RETURN false;

  Erx # recread(910, 0,_recID, gSelected);
  gSelected # 0;
  if (aNurAuswahl) then RETURN true;
  Starten(Lfm.Kuerzel, Lfm.Nummer);

  RETURN true;
end;


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
  vHdl : int;
end;
begin
  if (aKey=_WinKeyReturn) then begin
    gSelected # aID;
    vHdl # $Lfm.Auswahl;
    if (vHdl<>0) then vHdl->Winclose();
    vHdl # $Lfm.Sortierung;
    if (vHdl<>0) then vHdl->Winclose();
  end;
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
local begin
  vTmp  : int;
end;
begin

  if (aItem=0) or (aID=0) then RETURN false;

  if ((aButton & _WinMouseLeft)<>0) and ((aButton & _WinMouseDouble)<>0) then begin
    gSelected # aID;
    vTmp # $Lfm.Auswahl;
    if (vTmp<>0) then vTmp->Winclose();
    vTmp # $Lfm.Sortierung;
    if (vTmp<>0) then vTmp->Winclose();
  end;

end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl    : int;
  vHdl2   : int;
  Erx     : int;
end;
begin

  vHdl # $Lfm.Sortierung;
  if (vHdl=0) then vHdl # $Lfm.Auswahl;
  if (vHdl<>0) then WinSearchPath(vHDL);

  case (aEvt:Obj->wpName) of
    'Bt.OKauswahl' : begin
      recread(910, 1,_rnolock);
//      gselected # cnvia(aevt:obj -> wpcustom);
      gSelected # RecInfo(910,_recID);
      vHdl # $Lfm.Auswahl;
      if (vHdl<>0) then vHdl->winClose();
      Erx # recread(910, 0,_recID, gSelected);
//todo(aEvt:Obj->wpname+'  erg:'+cnvai(Erx)+'   Nr:'+cnvai(lfm.nummer));
      RETURN true;
    end;


    'Bt.OK' : begin
      vHdl # $lfm.Sortierung->Winsearch('dl.Sort');
      gSelected # vHdl->wpCurrentInt;
      vHdl # $Lfm.Sortierung;
      if (vHdl<>0) then vHdl->winClose();
      vHdl # $Lfm.Auswahl;
      if (vHdl<>0) then vHdl->winClose();
    end;


    'Bt.Abbruch' : begin
      gSelected # 0;
      vHdl # $Lfm.Sortierung;
      if (vHdl<>0) then vHdl->winClose();
      vHdl # $Lfm.Auswahl;
      if (vHdl<>0) then vHdl->winClose();
    end;

  end;

  RETURN true;
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub evtlstselect(
  aevt  : event;
  aRecId : int
) : logic
begin
  case aevt:obj -> wpname of
    'ZL.Listenauswahl' : begin
       if arecid = 0 then RETURN(true)
       recread(910,0,_recid,arecid);
     end
   end
   RETURN(true)
end


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtLstRecControl(
	aEvt         : event;    // Ereignis
	aRecID       : int       // Record-ID des Datensatzes
) : logic
begin

  // SQL-Liste?
  if (Set.SQL.Instance='') and (Lfm.Nummer<=9999) then begin
    RETURN false;
  end
  else begin
    if (App_Main:Entwicklerversion()) and (Set.SQL.Instance<>'') and
      (DbaName( _dbaAreaAlias )='!@SC-Entwicklung') then
    RETURN true;
  end;

	RETURN (Lfm.InaktivYN=n);
end;


//========================================================================
//========================================================================
//========================================================================