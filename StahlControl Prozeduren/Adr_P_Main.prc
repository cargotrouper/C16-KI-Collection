@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_P_Main
//                    OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  21.06.2012  ST  Sub "Start" in Headerdoku eingebaut
//  06.06.2018  AH  DSGVO
//  15.06.2018  ST  Whitespaces bei Geschäftichen Emailadressen immer abschneiden
//  23.02.2021  AH  Outlook-Massenexport
//  01.02.2022  ST  E r g --> Erx
//  15.02.2022  MR Neu: Überprüfung nach gültiger Email (2228/49)
//  11.07-2022  HA  Quick Jump

//  Subprozeduren
//    SUB Start(sub Start(opt aRecId : int; opt aAdrNr : int; opt aAPNr : int; opt aView : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtLstDataInit(aevt : event; arecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cDialog   : 'Adr.P.Verwaltung'
  cRecht    : Rgt_Adr_Ansprechpartner
  cMDIVar   : gMDIAdr
  cTitle    : 'Ansprechpartner'
  cFile     : 102
  cMenuName : 'Adr.P.Bearbeiten'
  cPrefix   : 'Adr_P'
  cZList    : $ZL.Adr.Ansprechpartner
  cKey      : 1
end;

//========================================================================
//  Start
//      Startet das Fenster ein
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aAdrNr  : int;
  opt aAPNr   : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end
begin
  if (aRecId=0) and (aAdrNr<>0) then begin
    Adr.P.Adressnr  # aAdrNr;
    Adr.P.Nummer    # aAPNr;
    Erx # RecRead(102,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(102,_recID);
  end;

  App_Main_Sub:StartVerwaltung(cDialog, cRecht, var cMDIvar, aRecID, aView);
end;


//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  // 06.06.2018
  if (Set.Adr.DSGVO=1) then begin
    $NB.Page2->wpVisible # false;
    $NB.Page3->wpVisible # false;
  end;

 Lib_Guicom2:Underline($edAdr.P.Priv.PLZ);
 Lib_Guicom2:Underline($edAdr.P.Priv.LKZ);

  SetStdAusFeld('edAdr.P.Priv.PLZ'            ,'PLZ');
  SetStdAusFeld('edAdr.P.Priv.LKZ'            ,'LKZ');

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
begin
  RecLink(100,102,1,_recFirst);
  $LB.Adressnummer  -> WpCaption # AInt(Adr.Nummer);
  $LB.Partnernummer -> WpCaption # AInt(Adr.P.Nummer);
  $LB.AdrStichwort  -> WpCaption # Adr.stichwort;
  $LB.Adressnummer2 -> WpCaption # AInt(Adr.Nummer);
  $LB.Partnernummer2-> WpCaption # AInt(Adr.P.Nummer);
  $LB.AdrStichwort2 -> WpCaption # Adr.stichwort;
  $LB.Stichwort     -> WpCaption # Adr.P.Stichwort;
  $LB.Adressnummer3 -> WpCaption # AInt(Adr.Nummer);
  $LB.Partnernummer3-> WpCaption # AInt(Adr.P.Nummer);
  $LB.AdrStichwort3 -> WpCaption # Adr.stichwort;
  $LB.Stichwort2    -> WpCaption # Adr.P.Stichwort;

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
 vNr  : int
end;
begin

  if (Mode=c_ModeEdit) then begin
    $LB.Partnernummer -> WpCaption # AInt(Adr.P.Nummer);
    $LB.Partnernummer2 -> WpCaption # AInt(Adr.P.Nummer);
    $edAdr.P.Stichwort->WinFocusSet(false);
  end
  else begin
    RecLink(102,100,13,_RecLast);
    vNr # Adr.P.Nummer + 1;
    RecBufClear(102);
    Adr.P.Adressnr # Adr.Nummer;
    Adr.P.Nummer   # vNr;
    $edAdr.P.Stichwort->WinFocusSet(false);
  end;

  RefreshIfm();

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
  vRegex          : alpha(4096);
  vRetRegex       : int;
  vMax            : int;
  vTmpEmail       : alpha(4096);
  vEinzelneEmail  : alpha(4096);
  vCount          : int;
end
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;



  // MR 15.02.2022 Überprüfung nach gültiger Email  [+] MR 11.04.2021  Es soll möglich sein mehrere Emailadressen angeben zukönnen. (2335/14)
  if ((Mode=c_ModeEdit) or (Mode=c_ModeNew)) then begin
    if(Adr.P.eMail <> '') then begin
    
      // [+] MR 11.04.2021  Es soll möglich sein mehrere E-Mail-Adressen angeben zukönnen. (2335/14)
      vMax # Lib_Strings:Strings_Count(Adr.P.eMail,';') + 2;
  
      vTmpEmail # Adr.P.eMail +';';
      FOR vCount # 1
      LOOP vCount # vCount+1
      UNTIL (vCount = vMax) do begin
        //vEinzelneEmail # Lib_Strings:Strings_Token(Adr.P.eMail,';', vCount);  2023-03-28  AH VBS/HB
        vEinzelneEmail # StrAdj(Lib_Strings:Strings_Token(Adr.P.eMail,';', vCount), _strBegin | _strEnd);
  
        vRegex # '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,100}|[0-9]{1,100})(\]?)$'
        vRetRegex # StrFindRegEx(vEinzelneEmail,vRegex, 0, vRetRegex  );
    
        if(vRetRegex = 0) then begin
          Msg(100017,vEinzelneEmail,0,0,0);
          $NB.Main->wpcurrent # 'NB.Page1';
          $edAdr.eMail->WinFocusSet(true);
          RETURN false;
        end;
      end;
    end;
  end;

  // ST 2018-06-15 Whitespaces bei Geschäftichen Emailadressen immer abschneiden
  Adr.P.eMail # StrAdj(Adr.P.eMail, _StrBegin | _StrEnd);

  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  Adr_Ktd_Data:UpdateFromPartner();


  RETURN true;  // Speichern erfolgreichend;
end;


//========================================================================
//  RecCleanup
//              Aufräumen bei "Cancel"
//========================================================================
sub RecCleanup() : logic
begin
  RETURN true;
end;


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
    if (RekDelete(gFile,0,'MAN')=_rOK) then begin
      if (gZLList->wpDbSelection<>0) then begin
       SelRecDelete(gZLList->wpDbSelection,gFile);
        RecRead(gFile, gZLList->wpDbSelection, 0);
      end;
    end;
  end;
end;


//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

end;


//========================================================================
//  EvtFocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
begin

  if (aEvt:obj->wpname='edAdr.P.Telefon') then begin
    Adr.P.Telefon # Lib_TAPI:Telefonnummer(Adr.P.Telefon);
  end;
  if (aEvt:obj->wpname='edAdr.P.Telefax') then begin
    Adr.P.Telefax # Lib_TAPI:Telefonnummer(Adr.P.Telefax);
  end;
  if (aEvt:obj->wpname='edAdr.P.Mobil') then begin
    Adr.P.Mobil # Lib_TAPI:Telefonnummer(Adr.P.Mobil);
  end;
  if (aEvt:obj->wpname='edAdr.P.Priv.Telefon') then begin
    Adr.P.Priv.Telefon # Lib_TAPI:Telefonnummer(Adr.P.Priv.Telefon);
  end;
  if (aEvt:obj->wpname='edAdr.P.Priv.Telefax') then begin
    Adr.P.Priv.Telefax # Lib_TAPI:Telefonnummer(Adr.P.Priv.Telefax);
  end;
  if (aEvt:obj->wpname='edAdr.P.Priv.Mobil') then begin
    Adr.P.Priv.Mobil # Lib_TAPI:Telefonnummer(Adr.P.Priv.Mobil);
  end;

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;





//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich : alpha;
)
begin

  case aBereich of
   'PLZ' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusPLZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LKZ' : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung', here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


  end;
end;



//========================================================================
//  AusPLZ
//
//========================================================================
sub AusPLZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Adr.P.Priv.LKZ   # Ort.LKZ;
    Adr.P.Priv.PLZ   # Ort.PLZ;
    Adr.P.Priv.Ort   # Ort.Name;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.P.Priv.PLZ->Winfocusset(false);

  gMDI->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusLKZ
//
//========================================================================
sub AusLKZ()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    Adr.P.Priv.LKZ  # "Lnd.Kürzel";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.P.Priv.LKZ->Winfocusset(false);

end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  // Button sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_Anlegen]=n) or (W_Parent=0);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_Anlegen]=n) or (W_Parent=0);

  // Button sperren
  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_aendern]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_aendern]=n);

  // Button sperren
  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_loeschen]=n);
  // Menü sperren
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_P_loeschen]=n);

  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;

  $bt.TAPI1->wpdisabled # false;
  $bt.TAPI2->wpdisabled # false;
  $bt.FAX->wpdisabled # false;
  $bt.eMail->wpdisabled # false;
  $bt.TAPI1privat->wpdisabled # false;
  $bt.TAPI2privat->wpdisabled # false;
  $bt.FAXprivat->wpdisabled # false;
  $bt.eMailprivat->wpdisabled # false;
  $bt.Maps->wpDisabled # false;

  $bt.OutlookExport->wpDisabled # (!Usr.OutlookYN);

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) and (aNoRefresh=false) then RefreshIfm();

end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int           // Menüeintrag
) : logic
local begin
  vHdl      : int;
  vMode     : alpha;
  vParent   : int;
  vTmp      : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.EMail' : Dlg_EMail(102);

    'Mnu.Mark.Sel' : Adr_P_Mark_Sel();

    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(102);
    end;


    'Mnu.2Word' : begin
      Lib_COM:CreateLetterToAdr( 102 );
    end;


    'Mnu.zuAdresse' : begin
      if (Adr_P_Subs:andereAdresse(Adr.P.Adressnr,Adr.P.Nummer)) then begin
        WinUpdate(gzlList,_WinUpdOn,_WinLstFromFirst | _WinLstRecDoSelect);
        Msg(102000, '', 0, 0, 0);
      end
      else begin
        WinUpdate(gzlList,_WinUpdOn,_WinLstFromFirst | _WinLstRecDoSelect);
        Msg(102001, '', 0, 0, 0);
      end;

    end;


    'Mnu.Outlook.ExportP' : begin
      Adr_P_Subs:Outlookexport();
    end;


    'Mnu.Tobit.ExportP' : begin
      If (Msg(998003,'"Globaler Adressordner"',_WinIcoQuestion,_WinDialogYesNo,2)=_WinidYes) then begin
        if (Lib_AdrExportTobit:ExportP()=true) then
          Msg(998004,'"Globaler Adressordner"'+'|'+cnvai(Gv.int.01),_WinIcoInformation,0,0)
        else
          Msg(999999,gv.alpha.01,_WinIcoError,0,0);
        RETURN true;
      end;

    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View( gFile );
    end;

  end; // case


end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  case (aEvt:Obj->wpName) of
    'bt.TAPI1'          :   Lib_Tapi:TapiDialNumber(Adr.P.Telefon); // Callold('old_TapiDial',Adr.P.Telefon);
    'bt.TAPI2'          :   Lib_Tapi:TapiDialNumber(Adr.P.Mobil); // Callold('old_TapiDial',Adr.P.Mobil);
//  'bt.FAX'            :
    'bt.eMail'          :   SysExecute('*mailto:'+Adr.P.eMail,'',0);
    'bt.Maps'           :   Adr_Data:OpenGoogleMaps( "Adr.P.Priv.Straße", Adr.P.Priv.PLZ, Adr.P.Priv.Ort );
    'bt.OutlookExport'  :   Lib_COM:ExportAdr( 102 );
    'bt.TAPI1privat'    :   Lib_Tapi:TapiDialNumber(Adr.P.Priv.Telefon); //Callold('old_TapiDial',Adr.P.Priv.Telefon);
    'bt.TAPI2privat'    :   Lib_Tapi:TapiDialNumber(Adr.P.Priv.Mobil); // Callold('old_TapiDial',Adr.P.Priv.Mobil);
//  'bt.FAX'            :
    'bt.eMailprivat'    :   SysExecute('*mailto:'+Adr.P.Priv.eMail,'',0);
  end;

  if Mode=c_ModeView then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.PLZ'            :   Auswahl('PLZ');
    'bt.LKZ'            :   Auswahl('LKZ');
  end;

end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aevt      :  event;
  arecid    : int;
  Opt aMark : logic;
                  );
local begin
  Erx : int;
end
begin
  Erx # RecLink(100,102,1,_recFirst); // Adresse holen
  if (Erx>_rLocked) then RecBufClear(100);
//  Refreshmode();
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
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose
(
  aEvt                  : event;        // Ereignis
): logic
begin
  RETURN true;
end;


sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edAdr.P.Priv.PLZ') AND (aBuf->Adr.P.Priv.PLZ<>'')) then begin
    Ort.LKZ  # Adr.P.Priv.LKZ;
    Ort.PLZ  # Adr.P.Priv.PLZ;
    Ort.Name # Adr.P.Priv.Ort;
    RecRead(847,1,0);
    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.P.Priv.LKZ') AND (aBuf->Adr.P.Priv.LKZ<>'')) then begin
    RecRead(812,1,0)
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;

end;






//========================================================================
//========================================================================
//========================================================================
//========================================================================