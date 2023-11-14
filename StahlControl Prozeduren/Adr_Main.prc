@A+
//==== Business-Control ==================================================
//
//  Prozedur    Adr_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  13.03.2009  TM  Adresslöschung abbrechen wenn Charge vorhanden
//  05.06.2012  AI  NEU: Start
//  13.06.2012  ST  Webseitenaufruf umgestellt (Prj 1326/238)
//  18.06.2012  ST  UstIdentprofügun integriert (Prj 1326/239)
//  18.09.2012  ST  Menüpunkt Info/Verkäufe hinzugefügt (Prj 1420/1) + Recht
//  11.06.2013  AI  Steuerschlüssel nur Pflich, wenn Kunde oder Lieferant
//  03.11.2014  AH  Info->Auftrag & Bestellung nun Selektion
//  12.11.2014  AH  Neu; Druck Besuchsbericht
//  11.02.2015  AH  Neu: Std.Lieferanschrift
//  18.05.2015  AH  Neu: ReAnschrift
//  23.06.2016  AH  Adr.VK.Std.LiefAdr nur Pflichtfeld bei Kunden
//  14.12.2018  ST  AFX Init und Init.Pre hinzugefügt
//  26.02.2019  ST  AFX RecInit hinzugefügt
//  28.08.2019  AH  Datumsangaben sind EINSCHLIEßLICH
//  18.01.2022  AH  ERX
//  31.01.2022  AH  Fix: Texte weg bei dirketem Edit (F6)
//  15.02.2022  MR  Neu: Überprüfung nach gültiger Email (2228/49)
//  11.04.2022  MR  Fix: Es soll möglich sein mehrere Emailadressen angeben zukönnen. (2335/14)
//  12.07.2022  HA  Quick Jump
//  2023-08-14  AH  "LiB.SperreNeuYN"
//
//  Subprozeduren
//    SUB Start(opt aRecId  : int; opt aView   : logic) : logic;
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB RefreshIfm(optaName : alpha; opt aChanged : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusFusstextEK()
//    SUB AusFusstextVK()
//    SUB AusSachbearbeiter()
//    SUB AusVertreter()
//    SUB AusVertreter2()
//    SUB AusVerband()
//    SUB AusLKZ()
//    SUB AusPLZ()
//    SUB AusPLZ2()
//    SUB AusGruppe()
//    SUB AusAnrede()
//    SUB AusSteuerschluessel()
//    SUB AusKreditadresse()
//    SUB AusEKVerwiegungsart()
//    SUB AusVKVerwiegungsart()
//    SUB AusEKWaehrung()
//    SUB AusEKVersandart()
//    SUB AusEKZahlungsbed()
//    SUB AusEKLieferbed()
//    SUB AusVKWaehrung()
//    SUB AusVKVersandart()
//    SUB AusVKZahlungsbed()
//    SUB AusVKLieferbed()
//    SUB AusReEmpfaenger()
//    SUB AusReAnschrift()
//    SUB AusLieferadresse()
//    SUB AusLieferanschrift()
//    SUB AusInfo()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB AdrTextSave()
//    SUB AdrTextRead()
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtLstDataInit(aevt : event; arecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtPosChanged...
//
//========================================================================
@I:Def_Global
@I:Def_Rights

local
begin
  Line1 : int;      // Deskriptor von 'PrtLine0'
  Line2 : int;      // Deskriptor von 'PrtLine1'
  Line3 : int;      // Deskriptor von 'PrtLine2'
end;
declare AdrTextRead(opt aMustRead : logic)
declare AdrTextSave();
declare adr.prt(srcdesc  : int; sTxt : alpha(4096));

define begin
  cTitle      : 'Adressen'
  cFile       : 100
  cMenuName   : 'Adr.Bearbeiten'
  cPrefix     : 'Adr'
  cZList      : $ZL.Adressen
  cKey        : 4
  cDialog     : 'Adr.Verwaltung'
  cMdiVar     : gMDIAdr
  cRecht      : Rgt_Adressen
end;


//========================================================================
//  Start
//      Startet die Verwaltung
//========================================================================
sub Start(
  opt aRecId  : int;
  opt aAdrNr  : int;
  opt aView   : logic) : logic;
local begin
  Erx : int;
end;
begin
  if (aRecId=0) and (aAdrNr<>0) then begin
    Adr.Nummer # aAdrNr;
    Erx # RecRead(100,1,0);
    if (Erx>_rLocked) then RETURN false;
    aRecId # RecInfo(100,_recID);
  end;

  if (Set.DokumentePFad='CA1') then
    App_Main_Sub:StartVerwaltung(cDialog+'2', cRecht, var cMDIvar, aRecID, aView)
  else
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
  WinSearchPath(aEvt:Obj);

  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;


  if (Set.Adr.Text1<>'') then begin
    $bt.Text1->wpvisible # true;
    $bt.Text1->wpcaption # Set.Adr.Text1;
  end;
  if (Set.Adr.Text2<>'') then begin
    $bt.Text2->wpvisible # true;
    $bt.Text2->wpcaption # Set.Adr.Text2;
  end;
  if (Set.Adr.Text3<>'') then begin
    $bt.Text3->wpvisible # true;
    $bt.Text3->wpcaption # Set.Adr.Text3;
  end;
  if (Set.Adr.Text4<>'') then begin
    $bt.Text4->wpvisible # true;
    $bt.Text4->wpcaption # Set.Adr.Text4;
  end;
  if (Set.Adr.Text5<>'') then begin
    $bt.Text5->wpvisible # true;
    $bt.Text5->wpcaption # Set.Adr.Text5;
  end;

  Lib_Guicom2:Underline($edAdr.PLZ);
  Lib_Guicom2:Underline($edAdr.Postfach.PLZ);
  Lib_Guicom2:Underline($edAdr.LKZ);
  Lib_Guicom2:Underline($edAdr.Gruppe);
  Lib_Guicom2:Underline($edAdr.Sachbearbeiter);
  Lib_Guicom2:Underline($edAdr.Vertreter);
  Lib_Guicom2:Underline($edAdr.Vertreter2);
  Lib_Guicom2:Underline($edAdr.Verband);
  Lib_Guicom2:Underline($edAdr.EK.Lieferbed);
  Lib_Guicom2:Underline($edAdr.EK.Zahlungsbed);
  Lib_Guicom2:Underline($edAdr.EK.Versandart);
  Lib_Guicom2:Underline($edAdr.EK.Verwiegeart);
  Lib_Guicom2:Underline($edAdr.EK.Waehrung);
  Lib_Guicom2:Underline($edAdr.EK.Fusstext);
  Lib_Guicom2:Underline($edAdr.VK.Lieferbed);
  Lib_Guicom2:Underline($edAdr.VK.Zahlungsbed);
  Lib_Guicom2:Underline($edAdr.VK.Versandart);
  Lib_Guicom2:Underline($edAdr.VK.Verwiegeart);
  Lib_Guicom2:Underline($edAdr.VK.Waehrung);
  Lib_Guicom2:Underline($edAdr.VK.Fusstext);
  Lib_Guicom2:Underline($edAdr.VK.Std.LieferAns);
  Lib_Guicom2:Underline($edAdr.VK.ReAnschrift);
  Lib_Guicom2:Underline($edAdr.Steuerschluessel);
   
  // Auswahlfelder setzen...
  SetStdAusFeld('edAdr.Sprache'        ,'Sprache');
  SetStdAusFeld('edAdr.AbmessungEH'    ,'AbmessungEH');
  SetStdAusFeld('edAdr.GewichtEH'      ,'GewichtEH');
  SetStdAusFeld('edAdr.Pfad.Bild'      ,'Bilddatei');
  SetStdAusFeld('edAdr.Pfad.Doks'      ,'Dokumentpfad');
  SetStdAusFeld('edAdr.Sachbearbeiter' ,'Sachbearbeiter');
  SetStdAusFeld('edAdr.Vertreter'      ,'Vertreter');
  SetStdAusFeld('edAdr.Vertreter2'     ,'Vertreter2');
  SetStdAusFeld('edAdr.Verband'        ,'Verband');
  SetStdAusFeld('edAdr.LKZ'            ,'LKZ');
  SetStdAusFeld('edAdr.PLZ'            ,'PLZ');
  SetStdAusFeld('edAdr.Postfach.PLZ'   ,'PLZ2');
  SetStdAusFeld('edAdr.Gruppe'         ,'Gruppe');
  SetStdAusFeld('edAdr.Steuerschluessel','Steuerschluessel');
  SetStdAusFeld('edAdr.Briefanrede'    ,'Briefanrede');
  SetStdAusFeld('edAdr.Kreditnummer'   ,'Kreditnummer');
  SetStdAusFeld('edAdr.VK.Verwiegeart' ,'VKVerwiegungsart');
  SetStdAusFeld('edAdr.EK.Verwiegeart' ,'EKVerwiegungsart');
  SetStdAusFeld('edAdr.EK.Zahlungsbed' ,'EKZahlungsbed');
  SetStdAusFeld('edAdr.EK.Lieferbed'   ,'EKLieferbed');
  SetStdAusFeld('edAdr.EK.Waehrung'    ,'EKWaehrung');
  SetStdAusFeld('edAdr.EK.Versandart'  ,'EKVersandart');
  SetStdAusFeld('edAdr.EK.Fusstext'    ,'FusstextEK');
  SetStdAusFeld('edAdr.VK.Zahlungsbed' ,'VKZahlungsbed');
  SetStdAusFeld('edAdr.VK.Lieferbed'   ,'VKLieferbed');
  SetStdAusFeld('edAdr.VK.Waehrung'    ,'VKWaehrung');
  SetStdAusFeld('edAdr.VK.Versandart'  ,'VKVersandart');
  SetStdAusFeld('edAdr.VK.Fusstext'    ,'FusstextVK');
  SetStdAusFeld('edAdr.VK.Std.LieferAdr', 'Lieferadresse');
  SetStdAusFeld('edAdr.VK.Std.LieferAns', 'Lieferanschrift');
  SetStdAusFeld('edAdr.VK.ReEmpfaenger', 'ReEmpfaenger');
  SetStdAusFeld('edAdr.VK.ReAnschrift' , 'ReAnschrift');


  if (Set.DokumentePFad='CA1') then begin
    $lbAdr.Pfad.Doks->wpvisible # false;
    $edAdr.Pfad.Doks->wpvisible # false;
    $bt.Dokumentpfad->wpvisible # false;
  end;

  // 26.05.2020 AH: Jump-Logik fehlte bisher????
  Lib_GuiDynamisch:CreateJumper($NB.Main, 'Adr.TextEdit1RTF', 'edAdr.Nummer');
  Lib_GuiDynamisch:CreateJumper($NB.Main, 'edAdr.Bemerkung', 'edAdr.EK.Referenznr');
  Lib_GuiDynamisch:CreateJumper($NB.Main, 'edAdr.VK.EigentumVBDat', 'edAdr.USIdentNr');
  Lib_GuiDynamisch:CreateJumper($NB.Main, 'edAdr.Fin.Vzg.FixTag', 'edAdr.Sprache');
  Lib_GuiDynamisch:CreateJumper($NB.Main, 'edAdr.Servicekey', 'Adr.TextEdit1RTF');

  //App_Main:EvtInit(aEvt);
  RunAFX('Adr.Init.Pre',aint(aEvt:Obj));

//if (gUsername='AH') then begin
//  SFX_Chromium:AddFreeChromiumNotebookPage($NB.Main,0,'Webbrowser','https:\\www.heise.de','*www.heise.de*');
//end;
  App_Main:EvtInit(aEvt);
  RunAFX('Adr.Init',aint(aEvt:Obj));
  
end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  //if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder

  Lib_GuiCom:Pflichtfeld($edAdr.Name);
// 15.02.2018 AH  Lib_GuiCom:Pflichtfeld($edAdr.Strae);
  Lib_GuiCom:Pflichtfeld($edAdr.PLZ);
  Lib_GuiCom:Pflichtfeld($edAdr.Ort);
  Lib_GuiCom:Pflichtfeld($edAdr.LKZ);
  Lib_GuiCom:Pflichtfeld($edAdr.Stichwort);
  Lib_GuiCom:Pflichtfeld($edAdr.Sprache);
  Lib_GuiCom:Pflichtfeld($edAdr.AbmessungEH);
  Lib_GuiCom:Pflichtfeld($edAdr.GewichtEH);


  if (Adr.Kundennr <> 0) then begin
    if (Mode=c_ModeEdit) then begin
      Lib_GuiCom:Pflichtfeld($edAdr.VK.Std.Lieferadr);
      Lib_GuiCom:Pflichtfeld($edAdr.VK.Std.Lieferans);
    end;
/*
    Lib_GuiCom:Pflichtfeld($edAdr.VK.Lieferbed);
    Lib_GuiCom:Pflichtfeld($edAdr.VK.Zahlungsbed);
    Lib_GuiCom:Pflichtfeld($edAdr.VK.Versandart);
*/
    Lib_GuiCom:Pflichtfeld($edAdr.VK.Waehrung);
//    Lib_GuiCom:Pflichtfeld($edAdr.VK.Verwiegeart);

    Lib_GuiCom:Pflichtfeld($edAdr.Steuerschluessel);
    Lib_GuiCom:Pflichtfeld($edAdr.AbmessungEH);
    Lib_GuiCom:Pflichtfeld($edAdr.GewichtEH);
  end;

  if (Adr.Lieferantennr <> 0) then begin
/*
    Lib_GuiCom:Pflichtfeld($edAdr.EK.Lieferbed);
    Lib_GuiCom:Pflichtfeld($edAdr.EK.Zahlungsbed);
    Lib_GuiCom:Pflichtfeld($edAdr.EK.Versandart);
*/
    Lib_GuiCom:Pflichtfeld($edAdr.EK.Waehrung);
//    Lib_GuiCom:Pflichtfeld($edAdr.EK.Verwiegeart);

    Lib_GuiCom:Pflichtfeld($edAdr.Steuerschluessel);
    Lib_GuiCom:Pflichtfeld($edAdr.AbmessungEH);
    Lib_GuiCom:Pflichtfeld($edAdr.GewichtEH);
  end;

end;


//========================================================================
//  RecInit
//
//========================================================================
sub RecInit()
local begin
  vTxtHdl : int;
end;
begin
  // Ankerfunktion?
  if (RunAFX('Adr.RecInit','') < 0) then RETURN;


  $edAdr.Nummer->Winupdate(_WinUpdFld2Obj);
  Lib_GuiCom:Disable($edAdr.Nummer);

  if (Mode=c_ModeNew) then begin
    Adr.Sprache     # Set.Sprache1.Kurz;
    Adr.AbmessungEH # 'mm';
    Adr.GewichtEH   # 'kg';

    vTxtHdl # $Adr.TextEdit1RTF->wpdbTextBuf;
    if (vTxtHdl<>0) then begin
      TextClear(vTxtHdl);
      $Adr.TextEdit1RTF->WinUpdate(_WinUpdBuf2Obj);
    end;

  end;

  if (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Kreditlimit]=n) then begin
    Lib_GuiCom:Disable($edAdr.Kreditnummer);
    Lib_GuiCom:Disable($bt.Kreditnummer);
    $edAdr.Kundennr->WinFocusSet(true);
  end;

  if (Mode=c_ModeEdit) then begin
    AdrTextRead(true);
    Lib_GuiCom:Enable($bt.Lieferanschrift);
    Lib_GuiCom:Enable($edAdr.VK.Std.Lieferadr);
    Lib_GuiCom:Enable($edAdr.VK.Std.Lieferans);

    Lib_GuiCom:Disable($edAdr.Stichwort);
    if (Adr.Kundennr<>0) then
      Lib_GuiCom:Disable($edAdr.Kundennr);
    if (Adr.Lieferantennr<>0) then
      Lib_GuiCom:Disable($edAdr.Lieferantennr);
    if (Adr.Kundennr<>0) then
      $edAdr.KundenFibunr->WinFocusSet(true)
    else
      $edAdr.Kundennr->WinFocusSet(true);
  end;

end;


//========================================================================
//  RecSave
//
//========================================================================
sub RecSave() : logic;
local begin
  Erx             : int;
  vExists         : logic;
  vBuf100         : int;
  vCheckKdNr      : logic;
  vCheckLfNr      : logic;
  vRegex          : alpha(4096);
  vRetRegex       : int;
  vMax            : int;
  vTmpEmail       : alpha(4096);
  vEinzelneEmail  : alpha(4096);
  vCount          : int;
end;
begin

  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  
  
  // MR 15.02.2022 Überprüfung nach gültiger Email
  if ((Mode=c_ModeEdit) or (Mode=c_ModeNew)) then begin
    if(Adr.eMail <> '') then begin
    
      // [+] MR 11.04.2021  Es soll möglich sein mehrere E-Mail-Adressen angeben zukönnen. (2335/14)
      vMax # Lib_Strings:Strings_Count(Adr.eMail,';') + 2;
      
      vTmpEmail # Adr.eMail +';';
      FOR vCount # 1
      LOOP vCount # vCount+1
      UNTIL (vCount = vMax) do begin
        vEinzelneEmail # StrAdj(Lib_Strings:Strings_Token(Adr.eMail,';', vCount), _strBegin | _strEnd);

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
  
  

  // KundenNr & LieferantenNr Überprüfung [04.05.2010/PW]
  if (Adr.KundenNr != 0) then begin
    vExists # false;
    vBuf100 # RecBufCreate( 100 );
    vBuf100->Adr.KundenNr # Adr.KundenNr;

    if ( RecRead( vBuf100, 2, 0 ) <= _rMultiKey ) and ( vBuf100->Adr.Nummer != Adr.Nummer ) then
      vExists # true;

    RecBufDestroy( vBuf100 );
  end;
  if ( vExists ) then begin
    Msg( 100000, '', 0, 0, 0 );
    RETURN false;
  end;

  if ( Adr.LieferantenNr != 0 ) then begin
    vExists # false;
    vBuf100 # RecBufCreate( 100 );
    vBuf100->Adr.LieferantenNr # Adr.LieferantenNr;

    if ( RecRead( vBuf100, 3, 0 ) <= _rMultiKey ) and ( vBuf100->Adr.Nummer != Adr.Nummer ) then
      vExists # true;

    RecBufDestroy( vBuf100 );
  end;
  if ( vExists ) then begin
    Msg( 100001, '', 0, 0, 0 );
    RETURN false;
  end;

  // Plausibilitätsprüfungen
  If (Adr.Stichwort='') then begin
    Msg(001200,Translate('Stichwort'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.Stichwort->WinFocusSet(true);
    RETURN false;
  end;

  If (Adr.Name='') then begin
    Msg(001200,Translate('Name'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.Name->WinFocusSet(true);
    RETURN false;
  end;
/*** 15.02.2018
  If ("Adr.Straße"='') then begin
    Msg(001200,Translate('Straße'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.Strae->WinFocusSet(true);
    RETURN false;
  end;
***/
  If (Adr.PLZ='') then begin
    Msg(001200,Translate('PLZ'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.PLZ->WinFocusSet(true);
    RETURN false;
  end;

  If (Adr.Ort='') then begin
    Msg(001200,Translate('Ort'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.Ort->WinFocusSet(true);
    RETURN false;
  end;

  If (Adr.LKZ='') then begin
    Msg(001200,Translate('Land'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.LKZ->WinFocusSet(true);
    RETURN false;
  end;
  Erx # RecLink(812,100,10,0);
  If (Erx>_rLocked) then begin
    Msg(001201,Translate('Land'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edAdr.LKZ->WinFocusSet(true);
    RETURN false;
  end;

  if (Adr.Vertreter<>0) then begin
    Erx # RecLink(110,100,15,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Vertreter'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edAdr.Vertreter->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Adr.Vertreter2<>0) then begin
    Erx # RecLink(110,100,32,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Vertreter'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edAdr.Vertreter2->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Adr.Verband<>0) then begin
    Erx # RecLink(110,100,16,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('Verband'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page1';
      $edAdr.Verband->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.EK.Lieferbed"<>0) then begin
    Erx # RecLink(815,100,2,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('EK-Lieferbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.EK.Lieferbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.EK.Zahlungsbed"<>0) then begin
    Erx # RecLink(816,100,3,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('EK-Zahlungsbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.EK.Zahlungsbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.EK.Versandart"<>0) then begin
    Erx # RecLink(817,100,4,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('EK-Versandart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.EK.Versandart->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.EK.Verwiegeart"<>0) then begin
    Erx # RecLink(818,100,73,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('EK-Verwiegungsart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.EK.Verwiegeart->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Adr.Lieferantennr<>0) and ("Adr.EK.Währung"=0) then begin
    Msg(001200,Translate('EK-Währung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edAdr.EK.Waehrung->WinFocusSet(true);
    RETURN false;
  end;
  if ("Adr.EK.Währung"<>0) then begin
    Erx # RecLink(814,100,1,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('EK-Währung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.EK.Waehrung->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.VK.Lieferbed"<>0) then begin
    Erx # RecLink(815,100,6,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('VK-Lieferbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.Lieferbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.VK.Zahlungsbed"<>0) then begin
    Erx # RecLink(816,100,7,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('VK-Zahlungsbedingung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.Zahlungsbed->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.VK.Versandart"<>0) then begin
    Erx # RecLink(817,100,8,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('VK-Versandart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.Versandart->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if (Adr.Kundennr<>0) and ("Adr.VK.Währung"=0) then begin
    Msg(001200,Translate('VK-Währung'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page2';
    $edAdr.VK.Waehrung->WinFocusSet(true);
    RETURN false;
  end;
  if ("Adr.VK.Währung"<>0) then begin
    Erx # RecLink(814,100,5,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('VK-Währung'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.Waehrung->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.VK.Verwiegeart"<>0) then begin
    Erx # RecLink(818,100,9,0);
    If (Erx>_rLocked) then begin
      Msg(001201,Translate('VK-Verwiegungsart'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.Verwiegeart->WinFocusSet(true);
      RETURN false;
    end;
  end;

  if ("Adr.VK.ReEmpfänger"<>0) then begin
    vBuf100 # RecBufCreate(100);
    vBuf100->Adr.Kundennr # "Adr.VK.ReEmpfänger";
    Erx # RecRead(vBuf100,2,0);
    if (Erx>_rMultiKey) or (Adr.VK.ReAnschrift=0) then begin
      RecBufDestroy(vBuf100);
      Msg(001201,Translate('Rechnungsempfänger'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page2';
      $edAdr.VK.ReEmpfaenger->WinFocusSet(true);
      RETURN false;
    end;
    Adr.A.Adressnr # vBuf100->Adr.Nummer;
    Adr.A.Nummer   # Adr.VK.ReAnschrift;
    RecBufDestroy(vBuf100);
    Erx # RecRead(101,1,0);
    if (Erx>=_rLocked) then begin
      Lib_Guicom2:InhaltFalsch('Rechnungsempfänger', 'NB.Page2', 'edAdr.VK.ReEmpfaenger');
      RETURN false;
    end;
  end;


  if (Mode=c_Modeedit) then begin
    if (Adr.Kundennr<>0) then begin
      if (Adr.VK.Std.LieferAdr=0) then begin
        Lib_Guicom2:InhaltFehlt('Lieferanschrift', 'NB.Page2', 'edAdr.VK.Std.LieferAdr');
        RETURN false;
      end;
      if (Adr.VK.Std.LieferAns=0) then begin
        Lib_Guicom2:InhaltFehlt('Lieferanschrift', 'NB.Page2', 'edAdr.VK.Std.LieferAns');
        RETURN false;
      end;
      Erx # RekLink(101,100,76,0);    // Anschrift holen
      if (Erx>_rMultiKey) then begin
        Lib_Guicom2:InhaltFalsch('Lieferanschrift', 'NB.Page2', 'edAdr.VK.Std.LieferAdr');
        RETURN false;
      end;
    end;
  end;



  if (Adr.Kundennr <> 0) or (Adr.Lieferantennr<>0) then begin
    If ("Adr.Steuerschlüssel"=0) then begin
      Msg(001200,Translate('Steuerschlüssel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page3';
      $edAdr.Steuerschluessel->WinFocusSet(true);
      RETURN false;
    end;
  end;
  if ("Adr.Steuerschlüssel"<>0) then begin
    Erx # RecLink(813,100,11,0);
    If (Erx>_rLocked) or ("Adr.Steuerschlüssel">999) then begin
      Msg(001201,Translate('Steuerschlüssel'),0,0,0);
      $NB.Main->wpcurrent # 'NB.Page3';
      $edAdr.Steuerschluessel->WinFocusSet(true);
      RETURN false;
    end;
  end;
  if (Adr.Kundennr <> 0) or (Adr.Lieferantennr<>0) then begin
    if (StS.UstIDPflichtYN) and (Adr.USIdentNr='') then begin
      Msg(100012,'',_WinIcoWarning,_WinDialogOk,1);
    end;
  end;

  If ("Adr.Sprache"='') then begin
    Msg(001200,Translate('Sprache'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page4';
    $edAdr.Sprache->WinFocusSet(true);
    RETURN false;
  end;

  If ("Adr.AbmessungEH"='') then begin
    Msg(001200,Translate('Abmessungseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page4';
    $edAdr.AbmessungEH->WinFocusSet(true);
    RETURN false;
  end;

  If ("Adr.GewichtEH"='') then begin
    Msg(001200,Translate('Gewichtseinheit'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page4';
    $edAdr.GewichtEH->WinFocusSet(true);
    RETURN false;
  end;


  // Sonderfunktion:
  if (RunAFX('Adr.RecSave','')<>0) then begin
    if (AfxRes<>_rOk) then begin
      RETURN False;
    end;
  end;


  TRANSON;

  if (Adr.Pfad.Doks<>'') and (StrCut(Adr.Pfad.Doks,StrLen(Adr.Pfad.Doks),1)<>'\') then Adr.Pfad.Doks # Adr.Pfad.Doks + '\';

  // allen verbundenen Daten anlegen:
  Erx # Adr_Data:RecSave(Mode=c_ModeNew);
  if (Erx>0) then begin
    TRANSBRK;
    Msg(100003,'',0,0,0);
    RETURN false;
  end;
  if (Erx<0) then begin
    TRANSBRK;
    RETURN false;
  end;


  // Text aktualisieren
  AdrTextSave();


  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_recUnlock,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    if (Adr.Kreditnummer=0) then Adr.Kreditnummer # Adr.Nummer;
    Erx # RekInsert(gFile,0,'MAN');
    if (Erx<>_rOk) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
  end;

  Adr_Ktd_Data:UpdateFromAdresse();

  TRANSOFF;


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
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdno) then RETURN;

  if (Adr_Subs:Delete()) then begin
    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
    end;
  end;

end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName     : alpha;
  opt aChanged  : logic;
)
local begin
  Erx       : int;
  vTxtHdl   : int;
  vBuf100   : int;
  vA        : alpha;
  vFont     : font;
  vL        : float;
  vTmp      : int;
end;
begin

  // 08.02.2017 WORKAROUND:
  if (Adr.KundenFibuNr=StrCnv(Adr.KundenFibuNr,_StrLetter)) then
    $edAdr.KundenFibuNr->wpJustifyView # _WinJustRight
  else
    $edAdr.KundenFibuNr->wpJustifyView # _WinJustLeft;
  if (Adr.LieferantFibuNr=StrCnv(Adr.LieferantFibuNr,_StrLetter)) then
    $edAdr.LieferantFibuNr->wpJustifyView # _WinJustRight
  else
    $edAdr.LieferantFibuNr->wpJustifyView # _WinJustLeft;


  // Anker Projekt 1381/90
  if (aChanged) then begin
    if (RunAFX('Adr.RefreshIfm',aName+'|Y')<0) then RETURN;
  end
  else begin
    if (RunAFX('Adr.RefreshIfm',aName+'|N')<0) then RETURN;
  end;

  $bt.Finanzrefresh->wpDisabled # mode <> c_modeView;

  vTxtHdl # $Adr.TextEdit1RTF->wpdbtextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Adr.TextEdit1RTF->wpdbTextBuf # vTxtHdl;
  end;

  if (aName='') then AdrTextRead();

  if (aName='') and ($NB.Main->wpcurrent='NB.Page6') then begin
    if (Set.DokumentePfad<>'CA1') then Adr_Dokumente:Term();
    Adr_Dokumente:Init();
  end;

  if (aName='') or (aName='edAdr.Nummer') then begin
    $lb.Adressnr->wpcaption # AInt(Adr.Nummer);
    $lb.Adressnr2->wpcaption # $lb.Adressnr->wpcaption;
    $lb.Adressnr3->wpcaption # $lb.Adressnr->wpcaption;
    $lb.Adressnr4->wpcaption # $lb.Adressnr->wpcaption;
    $lb.Adressnr5->wpcaption # $lb.Adressnr->wpcaption;
  end;

  if (aName='') or (aName='edAdr.Stichwort') then begin
    $lb.Stichwort->wpcaption # Adr.Stichwort;
    $lb.Stichwort2->wpcaption # $lb.Stichwort->wpcaption;
    $lb.Stichwort3->wpcaption # $lb.Stichwort->wpcaption;
    $lb.Stichwort4->wpcaption # $lb.Stichwort->wpcaption;
    $lb.Stichwort5->wpcaption # $lb.Stichwort->wpcaption;
  end;

  if (aName='') or (aName='edAdr.Pfad.Bild') then begin
    $Picture1->wpcaption # '*'+Adr.Pfad.Bild;
  end;

  if (aName='') or (aName='edAdr.Gruppe') then begin
  end;

  if (aName='') or (aName='edAdr.Sachbearbeiter') then begin
  end;

  if (aName='') or (aName='edAdr.Vertreter') then begin
    Erx # RekLink(110,100,15,0);
    $Lb.Vertreter->wpcaption # Ver.Stichwort;
    if (Ver.ProvisionProTJN) then
      $lb.Prov1->wpcaption # '/t'
    else
      $lb.Prov1->wpcaption # '%';
  end;
  if (aName='') or (aName='edAdr.Vertreter2') then begin
    Erx # RekLink(110,100,32,0);
    $Lb.Vertreter2->wpcaption # Ver.Stichwort;
    if (Ver.ProvisionProTJN) then
      $lb.Prov2->wpcaption # '/t'
    else
      $lb.Prov2->wpcaption # '%';
  end;

  if (aName='') or (aName='edAdr.Verband') then begin
    Erx # RekLink(110,100,16,0);
    $Lb.Verband->wpcaption # Ver.Stichwort;
  end;

  if (aName='') or (aName='edAdr.LKZ') then begin
    Erx # RekLink(812,100,10,0);
    $Lb.Land->wpcaption # Lnd.Name.L1
  end;

  if (aName='') or (aName='edAdr.Briefanrede') then begin
  end;

  if (aName='') or (aName='edAdr.Kreditnummer') then begin
    Erx # RecLink(103,100,14,0);
    if (Erx>_rLocked) then RecBufClear(103);
    $Lb.Kreditadresse->wpcaption # Adr.K.Stichwort
    vL # Adr_K_Data:VersichertAm(today);
//    if (today<=Adr.K.InternKurz.Dat) then  vL # Adr.K.InternKurz;
//    if (vL=0.0) then vL # Adr.K.InternLimit;
//    if (vL=0.0) and (today<=Adr.K.KurzLimit.Dat) then vL # Adr.K.KurzLimitW1;
//    if (vL=0.0) then vL # Adr.K.VersichertW1;
    $Lb.Kreditlimit->wpcaption    # ANum(vL,2);
  end;

  if (aName='') or (aName='edAdr.EK.Lieferbed') then begin
    Erx # RekLink(815,100,2,0);
    $Lb.EK.Lieferbed->wpcaption # LiB.Bezeichnung.L1;
  end;

  if (aName='') or (aName='edAdr.EK.Zahlungsbed') then begin
    Erx # RecLink(816,100,3,0);
    if Erx<=_rLocked then
      $Lb.EK.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung
    else
      $Lb.EK.Zahlungsbed->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.EK.Versandart') then begin
    Erx # RecLink(817,100,4,0);
    if Erx<=_rLocked then
      $Lb.EK.Versandart->wpcaption # VsA.Bezeichnung.L1
    else
      $Lb.EK.Versandart->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.EK.Waehrung') then begin
    Erx # RecLink(814,100,1,0);
    if Erx<=_rLocked then
      $Lb.EK.Waehrung->wpcaption # Wae.Bezeichnung
    else
      $Lb.EK.Waehrung->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.VK.Lieferbed') then begin
    Erx # RecLink(815,100,6,0);
    if Erx<=_rLocked then
      $Lb.VK.Lieferbed->wpcaption # LiB.Bezeichnung.L1
    else
      $Lb.VK.Lieferbed->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.VK.Zahlungsbed') then begin
    Erx # RecLink(816,100,7,0);
    if Erx<=_rLocked then
      $Lb.VK.Zahlungsbed->wpcaption # ZaB.Kurzbezeichnung
    else
      $Lb.VK.Zahlungsbed->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.VK.Versandart') then begin
    Erx # RecLink(817,100,8,0);
    if Erx<=_rLocked then
      $Lb.VK.Versandart->wpcaption # VsA.Bezeichnung.L1
    else
      $Lb.VK.Versandart->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.VK.Waehrung') then begin
    Erx # RecLink(814,100,5,0);
    if Erx<=_rLocked then
      $Lb.VK.Waehrung->wpcaption # Wae.Bezeichnung
    else
      $Lb.VK.Waehrung->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.VK.Verwiegeart') then begin
    Erx # RecLink(818,100,9,0);
    if Erx<=_rLocked then
      $Lb.VK.Verwiegeart->wpcaption # VwA.Bezeichnung.L1
    else
      $Lb.VK.Verwiegeart->wpcaption # '';
  end;
  if (aName='') or (aName='edAdr.EK.Verwiegeart') then begin
    Erx # RecLink(818,100,73,0);
    if Erx<=_rLocked then
      $Lb.EK.Verwiegeart->wpcaption # VwA.Bezeichnung.L1
    else
      $Lb.EK.Verwiegeart->wpcaption # '';
  end;


  if (aName='') or (aName='edAdr.VK.Std.LieferAdr') or (aName='edAdr.VK.Std.LieferAns') then begin
    Erx # RekLink(101,100,76,0);    // Anschrift holen
    $Lb.VK.Lieferanschrift->wpcaption # Adr.A.Stichwort+', '+Adr.A.Ort;
  end;

  if (aName='') or (aName='edAdr.VK.ReEmpfaenger') or (aName='edAdr.VK.ReAnschrift') then begin
    $Lb.VK.RechnungsEmpf->wpcaption # '';
    if ("Adr.VK.ReEmpfänger"<>0) then begin
//      if ("Adr.VK.ReEmpfänger"<>Adr.Kundennr) then begin
        vBuf100 # RecBufCreate(100);
        vBuf100->Adr.Kundennr # "Adr.VK.ReEmpfänger";
        Erx # RecRead(vBuf100,2,0);
        if (Erx<=_rMultiKey) then begin
          Adr.A.Adressnr # vBuf100->Adr.Nummer;
          Adr.A.Nummer   # Adr.VK.ReAnschrift;
          Erx # RecRead(101,1,0);
          if (Erx<=_rLocked) then
            $Lb.VK.RechnungsEmpf->wpcaption # Adr.A.Stichwort+', '+Adr.A.Ort;
        end;
        RecBufDestroy(vBuf100);
//      end;
    end;
    $Lb.TageNachZiel->wpcaption   # ANum(Adr.Fin.Vzg.Offset,2);
    $Lb.letzterAufDat->wpcaption  # cnvad(Adr.Fin.letzterAufam);
    $Lb.letzteReDat->wpcaption    # cnvad(Adr.Fin.letzteReAm);
    $lb.SummeAuf->wpcaption       # ANum(Adr.Fin.SummeAB,2);
    $lb.SummeRes->wpcaption       # ANum(Adr.Fin.SummeRes,2);
    $lb.SummePlan->wpcaption      # ANum(Adr.Fin.SummePlan,2);
    $lb.SummeBest->wpcaption      # ANum(Adr.Fin.SummeEkBest,2);
    $lb.SummeLfs->wpcaption       # ANum(Adr.Fin.SummeLFS,2);
    $lb.SummeDollar->wpcaption    # ANum(Adr.Fin.SummeABBere,2);

    if (Set.KLP.BruttoYN) then begin
      $labelSummen->wpcaption # Translate('Wertsummen')+' '+translate('Brutto')+':';
      $lb.SummeOP->wpcaption        # ANUm(Adr.Fin.SummeOPB,2);
      $lb.SummeOP.Ext->wpcaption    # ANum(Adr.Fin.SummeOPB.Ext,2);
    end
    else begin
      $labelSummen->wpcaption # Translate('Wertsummen')+' '+translate('Netto')+':';
      $lb.SummeOP->wpcaption        # ANUm(Adr.Fin.SummeOP,2);
      $lb.SummeOP.Ext->wpcaption    # ANum(Adr.Fin.SummeOP.Ext,2);
    end;

    $lb.SummeAB.LV->wpcaption     # ANum(Adr.Fin.SummeAB.LV,2);
    $Lb.Fin.Refreshdatum->wpcaption # cnvad(Adr.Fin.Refreshdatum);
  end;

  if (aName='') or (aName='edAdr.Steuerschluessel') then begin
    Erx # RecLink(813,100,11,0);
    if (Erx<=_rLocked) then
      $Lb.Steuerschluessel->wpcaption # StS.Bezeichnung
    else
      $Lb.Steuerschluessel->wpcaption # '';
  end;

  if (aName='') or (aName='edAdr.Sprache') then begin
  end;

  if (aName='') or (aName='edAdr.AbmessungEH') then begin
  end;

  if (aName='') or (aName='edAdr.GewichtEH') then begin
  end;

  if (aName='') or (aName='edAdr.Pfad.Bild') then begin
  end;

  if (aName='') or (aName='edAdr.Pfad.Doks') then begin
  end;

  if ( aName = '' ) then begin
    vTxtHdl # TextOpen( 16 );
    vA      # '~100.' + CnvAI( Adr.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 );
    vFont   # $bt.Text1->wpFont;

    if ( Set.Adr.Text1 != '' ) and ( vTxtHdl->TextRead( vA + '.001', _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.Text1->wpFont  # vFont;

    if ( Set.Adr.Text2 != '' ) and ( vTxtHdl->TextRead( vA + '.002', _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.Text2->wpFont  # vFont;

    if ( Set.Adr.Text3 != '' ) and ( vTxtHdl->TextRead( vA + '.003', _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.Text3->wpFont  # vFont;

    if ( Set.Adr.Text4 != '' ) and ( vTxtHdl->TextRead( vA + '.004', _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.Text4->wpFont  # vFont;

    if ( Set.Adr.Text5 != '' ) and ( vTxtHdl->TextRead( vA + '.005', _textNoContents ) <= _rLocked ) then
      vFont:Attributes # _winFontAttrBold;
    else
      vFont:Attributes # _winFontAttrNormal;
    $bt.Text5->wpFont  # vFont;

    vTxtHdl->TextClose();
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;



//========================================================================
//  EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vHdl : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (Lib_Pflichtfelder:TypAuswahlFeld(aEvt:Obj)<>'') then
    Lib_GuiCom:AuswahlEnable(aEvt:Obj);
  else
    Lib_GuiCom:AuswahlDisable(aEvt:Obj);

   if (aEvt:obj -> wpname ='Adr.TextEdit1RTF') then begin
     $Adr.ToolbarRTF -> wpdisabled # false;
     $Adr.ToolbarTXT -> wpdisabled # false;
   end
   else if ($Adr.ToolbarRTF->wpdisabled=false) then begin
     $Adr.ToolbarRTF -> winupdate(_Winupdon);
     $Adr.ToolbarRTF -> wpdisabled # true;
     $Adr.ToolbarTXT -> wpdisabled # true;
   end;
end;


//========================================================================
//  FocusTerm
//            Fokus vom Objekt wegbewegen
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // neu zu fokusierendes Objekt
) : logic
local begin
  vBuf  : int;
  vOk   : logic;
  vBig  : bigint;
end;
begin

  case (aEvt:Obj->wpName) of
/*
    'edAdr.KundenFibuNr' : begin
      vBig # StrCnv(cnvba(aEvt:Obj->wpCaption);
      if (vBig
      Adr._KundenBuchNr # cnvAdr.KundenFibuNr    # cnvai(Adr._KundenBuchNr, _FmtNumNogroup | _FmtNumNoZero);
    'edAdr.LieferantFibuNr' :
    Adr.LieferantFibuNr # cnvai(Adr._LieferantBuchNr, _FmtNumNogroup | _FmtNumNoZero);
*/

    'edAdr.Telefon1' : begin
      Adr.Telefon1 # Lib_TAPI:Telefonnummer(Adr.Telefon1);
    end;


    'edAdr.Telefon2' : begin
      Adr.Telefon2 # Lib_TAPI:Telefonnummer(Adr.Telefon2);
    end;


    'edAdr.Telefax' : begin
      Adr.Telefax # Lib_TAPI:Telefonnummer(Adr.Telefax);
    end;

/*
    'edAdr.KundenNr' : begin
      if (Set.Adr.AutoKuNr) then begin
      end
      else begin
        vOk # y;
        if (Adr.KundenNr<>0) then begin
          Erx # RecRead(100,2,_Rectest);
          if (Erx<=_rMultikey) then begin
            vBuf # RecBufCreate(100);
            RecBufCopy(100,vBuf);
            RecRead(100,2,0);
            if ((vBuf->Adr.Nummer)<>Adr.Nummer) then vOk # n;
            RecBufCopy(vBuf,100);
            RecBufDestroy(vBuf);
          end;
          if (vOk=n) then begin
            Msg(100000,'',0,0,0);
            RETURN false;
          end;
        end;
      end;
    end;


    'edAdr.LieferantenNr' : begin
      if (Set.Adr.AutoLfNr) then begin
      end
      else begin
        vOk # y;
        if (Adr.LieferantenNr<>0) then begin
          Erx # RecRead(100,3,_Rectest);
          if (Erx<=_rMultikey) then begin
            vBuf # RecBufCreate(100);
            RecBufCopy(100,vBuf);
            RecRead(100,3,0);
            if ((vBuf->Adr.Nummer)<>Adr.Nummer) then vOk # n;
            RecBufCopy(vBuf,100);
            RecBufDestroy(vBuf);
          end;
          if (vOk=n) then begin
            Msg(100001,'',0,0,0);
            RETURN false;
          end;
        end;
      end;
    end;

*/
   'Adr.TextEdit1RTF' :    begin
    end;

  end;  // ...case

  RefreshIfm(aEvt:Obj->wpName);

  RETURN true;
end;


//========================================================================
//  Auswahl
//          Auswahlisten öffnen
//========================================================================
 sub Auswahl(
  aBereich : alpha;
)
local begin
  Erx         : int;
  vBuf        : int;
  vA          : alpha;
  vHdl,vHdl2  : int;
  vQ          : alpha(4000);
  vPath       : alpha(1000);
end;

begin
  case aBereich of

    'ReEmpfaenger' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung' ,here+':AusReEmpfaenger');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.Kundennr', '>', 0);
      vHdl # SelCreate(100, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ReAnschrift' : begin
      vBuf  # RecBufCreate(100);
      vBuf->Adr.Kundennr # "Adr.VK.ReEmpfänger";
      Erx # RecRead(vBuf,2,0);
      if (Erx>_rMultikey) then begin
        RecBufDestroy(vBuf);
        RETURN;
      end;
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung' ,here+':AusReAnschrift');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', vBuf->Adr.Nummer);
      RecBufDestroy(vBuf);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferadresse' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung' ,here+':AusLieferadresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lieferanschrift' : begin
      vBuf # Adr.VK.Std.LieferAdr;
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung' ,here+':AusLieferanschrift');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', vBuf);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Text1' : begin
      Mdi_RtfEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001', Rechte[Rgt_Adr_Aendern] or Rechte[Rgt_Adr_Text1_Aendern], Set.Adr.Text1);
      //Mdi_TXTEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.001', Rechte[Rgt_Adr_Aendern], Set.Adr.Text1);
    end;


    'Text2' : begin
      Mdi_RtfEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.002', Rechte[Rgt_Adr_Aendern] or Rechte[Rgt_Adr_Text2_Aendern], Set.Adr.Text2);
    end;


    'Text3' : begin
      Mdi_RtfEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.003', Rechte[Rgt_Adr_Aendern] or Rechte[Rgt_Adr_Text3_Aendern], Set.Adr.Text3);
    end;


    'Text4' : begin
      Mdi_RtfEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.004', Rechte[Rgt_Adr_Aendern] or Rechte[Rgt_Adr_Text4_Aendern], Set.Adr.Text4);
    end;


    'Text5' : begin
      Mdi_RtfEditor_Main:Start('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.005', Rechte[Rgt_Adr_Aendern] or Rechte[Rgt_Adr_Text5_Aendern], Set.Adr.Text5);
    end;


    'FusstextEK' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstextEK');
      // MUSTER für QRecList
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'E';
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'FusstextVK' : begin
      RecBufClear(837);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Txt.Verwaltung',here+':AusFusstextVK');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      Gv.Alpha.01 # 'V';
      vQ # '';
      Lib_Sel:QenthaeltA(var vQ, 'Txt.Bereichstring', Gv.Alpha.01);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vertreter' : begin
      RecBufClear(110);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVertreter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vertreter2' : begin
      RecBufClear(110);
      Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVertreter2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verband' : begin
      RecBufClear(110);
      gMdi # Lib_GuiCom:AddChildWindow(gMDI, 'Ver.Verwaltung',here+':AusVerband');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'AbmessungEH' : begin
      Lib_Einheiten:Popup('AbmessungsEH',$edAdr.AbmessungEH,100,5,5);
    end;


    'GewichtEH' : begin
      Lib_Einheiten:Popup('GewichtsEH',$edAdr.GewichtEH,100,5,6);
    end;


    'Sprache' : begin
      Lib_Einheiten:Popup('Sprache',$edAdr.Sprache,100,5,4);
     end;


    'Bilddatei' : begin
      Adr.Pfad.Bild # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, Adr.Pfad.Bild, 'Bilddateien|*.bmp;*.jpg;*.gif');
      $edAdr.Pfad.Bild->winupdate(_WinUpdFld2Obj);
      RefreshIfm('edAdr.Pfad.Bild');
    end;


    'Dokumentpfad' : begin
      if (Set.DokumentePFad='CA1') then RETURN;

      // 25.11.2016 AH
      vPath # Set.Dokumentepfad;
      if (Lib_Strings:Strings_Count(vPath,'|')>0) then begin
        if (isTestsystem) then
          vPath # Str_Token(vPath,'|',2)
        else
          vPath # Str_Token(vPath,'|',1);
      end;

      Adr.Pfad.Doks # Lib_FileIO:FileIO(_wincompath, gMDI, vPath+Adr.Pfad.doks);
      Adr.Pfad.Doks # StrAdj(Adr.Pfad.Doks,_StrEnd);
      if (StrFind(StrCnv(Adr.Pfad.Doks,_Strupper),StrCnv(vPath,_StrUpper),0)<>0) then begin
        Adr.Pfad.Doks # StrAdj(StrDel(Adr.Pfad.Doks,1,Strlen(vPath)),_Strend);
      end;
      if (Strlen(Adr.Pfad.Doks)>0) then begin
        if (StrCut(Adr.Pfad.Doks,Strlen(Adr.Pfad.Doks),1)<>'\') then
          Adr.Pfad.Doks # Adr.Pfad.Doks + '\';
      end;
      $edAdr.Pfad.Doks->winupdate(_WinUpdFld2Obj);
    end;


    'Sachbearbeiter' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Usr.Verwaltung',here+':AusSachbearbeiter');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'LKZ' : begin
      RecBufClear(812);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lnd.Verwaltung', here+':AusLKZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'PLZ' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusPLZ');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'PLZ2' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusPLZ2');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Gruppe' : begin
      RecBufClear(810);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Grp.Verwaltung', here+':AusGruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Briefanrede' : begin
      RecBufClear(811);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Anr.Verwaltung',here+':AusAnrede');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerschluessel' : begin
      RecBufClear(813);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusSteuerschluessel');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKVerwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VwA.Verwaltung',here+':AusVKVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKVerwiegungsart' : begin
      RecBufClear(818);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VwA.Verwaltung',here+':AusEKVerwiegungsart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kreditnummer' : begin
      RecBufClear(103);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.K.Verwaltung' ,here+':AusKreditadresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKWaehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Wae.Verwaltung',here+':AusEKWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKVersandart' : begin
      RecBufClear(817);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VsA.Verwaltung',here+':AusEKVersandart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKZahlungsbed' : begin
      RecBufClear(816);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'ZAB.Verwaltung',here+':AusEKZahlungsbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'ZaB.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'EKLieferbed' : begin
      RecBufClear(815);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Lib.Verwaltung',here+':AusEKLieferbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'LiB.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKWaehrung' : begin
      RecBufClear(814);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Wae.Verwaltung',here+':AusVKWaehrung');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKVersandart' : begin
      RecBufClear(817);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VsA.Verwaltung',here+':AusVKVersandart');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKZahlungsbed' : begin
      RecBufClear(816);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'ZaB.Verwaltung',here+':AusVKZahlungsbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'ZaB.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'VKLieferbed' : begin
      RecBufClear(815);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'LiB.Verwaltung',here+':AusVKLieferbed');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # 'LiB.SperreNeuYN=false';
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;  // ...case

end;


//========================================================================
//  AusFusstextEK
//
//========================================================================
sub AusFusstextEK()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    Adr.EK.Fusstext # Txt.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gSelected # 0;

  // Focus auf Editfeld setzen:
  $edAdr.EK.Fusstext->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusFusstextVK
//
//========================================================================
sub AusFusstextVK()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(837,0,_RecId,gSelected);
    Adr.VK.Fusstext # Txt.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  gSelected # 0;
  // Focus auf Editfeld setzen:
  $edAdr.VK.Fusstext->Winfocusset(false);
  // ggf. Labels refreshen
end;


//========================================================================
//  AusSachbearbeiter
//
//========================================================================
sub AusSachbearbeiter()
local begin
  vTmp  : int;
end;
begin
  $ZL.Adressen->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Adr.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(800,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Sachbearbeiter # Usr.Username;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  Usr_data:RecReadThisUser();
  $edAdr.Sachbearbeiter->Winfocusset(false);
//  RefreshIfm('edAdr.Sachbearbeiter');
end;


//========================================================================
//  AusVertreter
//
//========================================================================
sub AusVertreter()
local begin
  vTmp  : int;
end;
begin
  $ZL.Adressen->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Adr.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Vertreter   # Ver.Nummer;
    Adr.Vertr1.Prov # Ver.ProvisionProz;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Vertreter->Winfocusset(false);
//  RefreshIfm('edAdr.Vertreter');
end;


//========================================================================
//  AusVertreter2
//
//========================================================================
sub AusVertreter2()
local begin
  vTmp  : int;
end;
begin
  $ZL.Adressen->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Adr.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Vertreter2   # Ver.Nummer;
    Adr.Vertr2.Prov # Ver.ProvisionProz;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Vertreter2->Winfocusset(false);
//  RefreshIfm('edAdr.Vertreter');
end;


//========================================================================
//  AusVerband
//
//========================================================================
sub AusVerband()
local begin
  vTmp  : int;
end;
begin
  $ZL.Adressen->wpdisabled # false;
  Lib_GuiCom:SetWindowState($Adr.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(110,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Verband   # Ver.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Verband->Winfocusset(false);
//  RefreshIfm('edAdr.Verband');
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
//  $ZL.Adressen->wpdisabled # false;
//  Lib_GuiCom:SetWindowState($Adr.Verwaltung,true);
  if (gSelected<>0) then begin
    RecRead(812,0,_RecId,gSelected);
    gSelected # 0;
    Adr.LKZ               # "Lnd.Kürzel";
    "Adr.Steuerschlüssel" # "Lnd.Steuerschlüssel";
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.LKZ->Winfocusset(false);
//  RefreshIfm('edAdr.LKZ');
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
    Adr.LKZ   # Ort.LKZ;
    Adr.PLZ   # Ort.PLZ;
    Adr.Ort   # Ort.Name;
//    $edAdr.Ort->Winupdate(_WinUpdFld2Obj);
//    $edAdr.LKZ->Winupdate(_WinUpdFld2Obj);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.PLZ->Winfocusset(false);

  RefreshIfm('edAdr.LKZ',y);

  gMDI->WinUpdate(_WinUpdFld2Obj);
end;


//========================================================================
//  AusPLZ2
//
//========================================================================
sub AusPLZ2()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(847,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Postfach.PLZ   # Ort.PLZ;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Postfach.PLZ->Winfocusset(false);
//  RefreshIfm('edAdr.LKZ');
end;


//========================================================================
//  AusGruppe
//
//========================================================================
sub AusGruppe()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(810,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Gruppe # Grp.Name
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Gruppe->Winfocusset(false);
//  RefreshIfm('edAdr.Gruppe');
end;


//========================================================================
//  AusAnrede
//
//========================================================================
sub AusAnrede()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(811,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Briefanrede # Anr.Bezeichnung;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Briefanrede->Winfocusset(false);
//  RefreshIfm('edAdr.Briefanrede');
end;


//========================================================================
//  AusSteuerschluessel
//
//========================================================================
sub AusSteuerschluessel()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(813,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.Steuerschlüssel" # StS.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Steuerschluessel->Winfocusset(false);
//  RefreshIfm('edAdr.Steuerschluessel');
end;


//========================================================================
//  AusKreditadresse
//
//========================================================================
sub AusKreditadresse()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(103,0,_RecId,gSelected);
    gSelected # 0;
    Adr.Kreditnummer # Adr.K.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.Kreditnummer->Winfocusset(false);
//  RefreshIfm('edAdr.Kreditadresse');
end;


//========================================================================
//  AusVKVerwiegungsart
//
//========================================================================
sub AusVKVerwiegungsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Verwiegeart # VwA.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Verwiegeart->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Verwiegeart');
end;


//========================================================================
//  AusEKVerwiegungsart
//
//========================================================================
sub AusEKVerwiegungsart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(818,0,_RecId,gSelected);
    gSelected # 0;
    Adr.EK.Verwiegeart # VwA.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.EK.Verwiegeart->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Verwiegeart');
end;


//========================================================================
//  AusEKWaehrung
//
//========================================================================
sub AusEKWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.EK.Währung" # Wae.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.EK.Waehrung->Winfocusset(false);
//  RefreshIfm('edAdr.EK.Waehrung');
end;


//========================================================================
//  AusEKVersandart
//
//========================================================================
sub AusEKVersandart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(817,0,_RecId,gSelected);
    gSelected # 0;
    Adr.EK.Versandart # VsA.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.EK.Versandart->Winfocusset(false);
//  RefreshIfm('edAdr.EK.Versandart');
end;


//========================================================================
//  AusEKZahlungsbed
//
//========================================================================
sub AusEKZahlungsbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(816,0,_RecId,gSelected);
    gSelected # 0;
    Adr.EK.Zahlungsbed # ZaB.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.EK.Zahlungsbed->Winfocusset(false);
//  RefreshIfm('edAdr.EK.Zahlungsbed');
end;


//========================================================================
//  AusEKLieferbed
//
//========================================================================
sub AusEKLieferbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(815,0,_RecId,gSelected);
    gSelected # 0;
    Adr.EK.Lieferbed # LiB.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.EK.Lieferbed->Winfocusset(false);
//  RefreshIfm('edAdr.EK.Lieferbed');
end;


//========================================================================
//  AusVKWaehrung
//
//========================================================================
sub AusVKWaehrung()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(814,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.VK.Währung" # Wae.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Waehrung->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Waehrung');
end;


//========================================================================
//  AusEKVersandart
//
//========================================================================
sub AusVKVersandart()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(817,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Versandart # VsA.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Versandart->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Versandart');
end;


//========================================================================
//  AusVKZahlungsbed
//
//========================================================================
sub AusVKZahlungsbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(816,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Zahlungsbed # ZaB.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Zahlungsbed->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Zahlungsbed');
end;


//========================================================================
//  AusVKLieferbed
//
//========================================================================
sub AusVKLieferbed()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(815,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Lieferbed # LiB.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Lieferbed->Winfocusset(false);
//  RefreshIfm('edAdr.VK.Lieferbed');
end;


//========================================================================
// AusReEmpfaenger
//
//========================================================================
SUB AusReEmpfaenger()
local begin
  vTmp  : int;
  v100  : int;
end;
begin
  if (gSelected<>0) then begin
    v100 # RecBufCreate(100);
    RecRead(v100,0,_RecId,gSelected);
    gSelected # 0;
    "Adr.VK.ReEmpfänger" # v100->Adr.Kundennr;
    Adr.VK.ReAnschrift   # 1;
    RecBufDestroy(v100);
    $edAdr.VK.ReAnschrift->Winupdate(_WinUpdFld2Obj);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.ReEmpfaenger->Winfocusset(false);
  RefreshIfm('edAdr.VK.ReEmpfaenger');
end;


//========================================================================
// AusReAnschrift
//
//========================================================================
SUB AusReAnschrift()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.ReAnschrift  # Adr.A.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.ReAnschrift->Winfocusset(false);
  RefreshIfm('edAdr.VK.ReAnschrift');
end;


//========================================================================
// AusLieferadresse
//
//========================================================================
SUB AusLieferadresse()
local begin
  vTmp  : int;
  v100  : int;
end;
begin
  if (gSelected<>0) then begin
    v100 # RecBufCreate(100);
    RecRead(v100,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Std.Lieferadr # v100->Adr.Nummer;
    Adr.VK.Std.Lieferans # 1;
    RecBufDestroy(v100);
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Std.LieferAns->Winfocusset(false);
  RefreshIfm('edAdr.VK.Std.LieferAns');
end;


//========================================================================
// AusLieferanschrift
//
//========================================================================
SUB AusLieferanschrift()
local begin
  vTmp  : int;
end;
begin
  if (gSelected<>0) then begin
    RecRead(101,0,_RecId,gSelected);
    gSelected # 0;
    Adr.VK.Std.Lieferadr # Adr.A.Adressnr;
    Adr.VK.Std.Lieferans # Adr.A.Nummer;
    vTmp # WinFocusget();   // LastFocus-Feld refreshen
    if (vTmp<>0) then vTmp->Winupdate(_WinUpdFld2Obj);
  end;
  $edAdr.VK.Std.LieferAns->Winfocusset(false);
  RefreshIfm('edAdr.VK.Std.LieferAns');
end;


//========================================================================
//  AusInfo
//
//========================================================================
sub AusInfo()
begin
//debug('retut:'+adr.Stichwort+' '+cnvai(adr.kundennr));
  $edit->Winfocusset(false);
  gSelected # 0;
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

  // ----

  vHdl # gMenu->WinSearch('Mnu.Mark.Sel');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Mode<>c_ModeList);

  vHdl # gMenu->WinSearch('Mnu.Info');
  if (vHdl <> 0) then
    vHdl->wpDisabled # vHdl->wpdisabled or (Rechte[Rgt_Adr_Info]=false);

  vHdl # gMenu->WinSearch('Mnu.Auftraege');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Auftrag]=false);

  vHdl # gMenu->WinSearch('Mnu.Aktionen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Aktionen]=false);

  vHdl # gMenu->WinSearch('Mnu.Verkaeufe');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Info_Verkaeufe]=false;

  vHdl # gMenu->WinSearch('Mnu.Erloese');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Umsatz]=false);

  vHdl # gMenu->WinSearch('Mnu.ErloeseReEmpf');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Umsatz]=false);

  vHdl # gMenu->WinSearch('Mnu.OP');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Erloes]=false);

  vHdl # gMenu->WinSearch('Mnu.Bestellungen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Bestellung]=false);

  vHdl # gMenu->WinSearch('Mnu.BestellungenABL');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Bestellung]=false);

  vHdl # gMenu->WinSearch('Mnu.Verbindlichkeiten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Verbindlichk]=false);

  vHdl # gMenu->WinSearch('Mnu.ER');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Eingangsrech]=false);

  vHdl # gMenu->WinSearch('Mnu.Aktivitaeten');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Termine]=false);

  vHdl # gMenu->WinSearch('Mnu.LfE');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_LfErklaerungen]=false) or
        (StrFind(Set.Module,'L',0)=0) or
        (Adr.Lieferantennr=0);


  vHdl # gMenu->WinSearch('Mnu.Protokoll');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Info_Protokoll]=false);

  vHdl # gMenu->WinSearch('Listen');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (Rechte[Rgt_Adr_Listen]=false);

  // ----


  vHdl # gMenu->WinSearch('Mnu.Scripte');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Scripte]=false));

  vHdl # gMenu->WinSearch('Mnu.Rabatte');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Rabatte]=false));

  vHdl # gMenu->WinSearch('Mnu.Ansprechpartner');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Ansprechpartner]=false));

  vHdl # gMenu->WinSearch('Mnu.Anschriften');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Anschriften]=false));

  vHdl # gMenu->WinSearch('Mnu.Kreditlimit');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
    ((Mode=c_ModeEdit) or (Mode=C_ModeNew) or (Rechte[Rgt_Adr_Kreditlimit]=false));

  vHdl # gMenu->WinSearch('Mnu.Verpackungen');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Verpackungen]=false));

  vHdl # gMenu->WinSearch('Mnu.Stichwort');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Change_Stichwort]=false));

  vHdl # gMenu->WinSearch('Mnu.Kundennr');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Change_Kundennr]=false));

  vHdl # gMenu->WinSearch('Mnu.Lieferantennr');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_Adr_Change_Lieferantennr]=false));
/*** 10.08.2017 AH ????
  vHdl # gMenu->WinSearch('Mnu.Verkaeufe');
  if (vHdl <> 0) then
    vHdl->wpDisabled #
      ((Mode=c_ModeEdit) or (Mode=c_ModeNew) or (Rechte[Rgt_OSt_AAr]=false));
***/

  vHdl # gMenu->WinSearch('Mnu.Mark.SetField');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_SerienEdit]=false;
  vHdl # gMenu->WinSearch('Mnu.Daten.Export');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Export]=false;
  vHdl # gMenu->WinSearch('Mnu.Excel.Import');
  if (vHdl <> 0) then
    vHdl->wpDisabled # Rechte[Rgt_Adr_Excel_Import]=false;




  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_Loeschen]=n);

  vHdl # gMdi->WinSearch('Bt.DocRefresh');
  If (vHdl <> 0) then
    vHdl->wpDisabled # false;

  vHdl # gMdi->WinSearch('Bt.DocWord');
  If (vHdl <> 0) then
    vHdl->wpDisabled # true;

  vHdl # gMdi->WinSearch('Bt.DocExcel');
  If (vHdl <> 0) then
    vHdl->wpDisabled # true;


  vHdl # gMdi->WinSearch('cbAdr.SperrKundeYN');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_SperrKundeYN]=n);


  vHdl # gMdi->WinSearch('cbAdr.SperrLieferantYN');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Adr_SperrLieferantYN]=n);


  vHdl # gMdi->WinSearch('NB.Page6');
  if vHdl <> 0 then
    vHdl->wpDisabled # ((Adr.Pfad.Doks='') and (Set.DokumentePfad<>'CA1')) or ((Mode=c_ModeEdit) or (Mode=c_ModeNew));

  if (((Adr.Pfad.Doks='') and (Set.DokumentePfad<>'CA1')) or (Mode=c_ModeEdit) or (Mode=c_ModeNew)) and
    ($NB.Main->wpcurrent='NB.Page6') then $NB.Main->wpcurrent # 'NB.Page5';

  $bt.TAPI1->wpdisabled # false;
  $bt.TAPI2->wpdisabled # false;
  $bt.FAX->wpdisabled # false;
  $bt.eMail->wpdisabled # false;
  $bt.WWW->wpdisabled # false;
  $bt.Maps->wpDisabled # false;
  $bt.UstIdentCheck->wpDisabled # false;

  $bt.OutlookExport->wpDisabled # (!Usr.OutlookYN);

  $bt.Text1->wpdisabled # (Mode<>c_ModeView);
  $bt.Text2->wpdisabled # (Mode<>c_ModeView);
  $bt.Text3->wpdisabled # (Mode<>c_ModeView);
  $bt.Text4->wpdisabled # (Mode<>c_ModeView);
  $bt.Text5->wpdisabled # (Mode<>c_ModeView);

  if (Mode<>c_ModeOther) and (Mode<>c_ModeList) then RefreshIfm();

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
  Erx     : int;
  vHdl    : int;
  vQ      : alpha;
  vFilter : int;
  vA      : alpha;
  vNumNeu : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.LfE' : begin
      if (Rechte[Rgt_LfErklaerungen]=false) or
        (StrFind(Set.Module,'L',0)=0) or
        (Adr.Lieferantennr=0) then RETURN false;
      RecBufClear(130);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'LfE.Verwaltung','');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'LfE.Lieferantennr', '=', Adr.Lieferantennr);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.EMail' : Dlg_EMail(100);


    'Mnu.Filter.Start' : begin
      Adr_Mark_Sel('100.xml');
      RETURN true;
    end;


    'Mnu.CUS.Felder' : begin
      CUS_Main:Start(gFile, RecInfo(gFile, _recID));
    end;


    'Mnu.Adressetikett' : begin
      Lib_Dokumente:Printform(100, 'Adressetikett', true);
    end;


    'Mnu.Druck.Besuchsbericht' : begin
      Lib_Dokumente:PrintForm(100,'BesuchsBericht',false);
    end;


    'Mnu.Akte' : begin
      Lib_Dokumente:Printform(100, 'KundenLieferantenAkte', true);
    end;


    'Mnu.Aktivitaeten' : begin
      TeM_Subs:Start(100);
    end;


    'Mnu.DMS.Export' : begin
      Adr_Data:ArcFlowExport();
      ErrorOutput;
    end;


    'Mnu.DMS' : begin
      DMS_ArcFlow:ShowAdr(aint(Adr.Nummer));
    end;


    'Mnu.Scripte' : begin
      RecBufClear(109);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.Scr.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Protokoll' : begin
      PtD_Main:View(gFile,Adr.Anlage.Datum, Adr.Anlage.Zeit, Adr.Anlage.User);
    end;


    'Mnu.Mark.SetField' : begin
      Lib_Mark:SetField(gFile);
    end;


    'Mnu.Mark.Sel' : begin
      Adr_Mark_Sel();
    end;


    'Mnu.OSt' : begin
      if (Rechte[Rgt_OSt_Kunde]=n) then begin
        Msg(890000,'',0,0,0);
        RETURN true;
      end;
      Lib_COM:DisplayOSt('KU:' + CnvAI(Adr.KundenNr), -1, 'Kunde ' + CnvAI(Adr.KundenNr) + ', ' + Adr.Stichwort);
    end;


    'Mnu.Adr2Word' : begin
      Lib_COM:CreateLetterToAdr(100);
    end;


    'Mnu.Rabatte' : begin
      RecBufClear(830);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rab.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpdbfileno     # 100;
      gZLList->wpdbkeyno      # 31;
      gZLList->wpdbLinkFileNo # 830;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Anschriften' : begin
      RecBufClear(101);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.A.Verwaltung', '', true);

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
      vHdl # SelCreate(101, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Ansprechpartner' : begin
      RecBufClear(102);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.P.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/*
      gZLList->wpdbfileno     # 100;
      gZLList->wpdbkeyno      # 13;
      gZLList->wpdbLinkFileNo # 102;
*/
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.P.Adressnr'  , '=', Adr.Nummer);
      vHdl # SelCreate(102, gKey);
      Erx  # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Kreditlimit' : begin
      RecBufClear(103);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.K.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecLink(103,100,14,_RecFirst);
      Mode # c_modeBald+c_ModeView;
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 14;
      gZLList->wpDbLinkFileno # 103;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Verpackungen' : begin
      RecBufClear(105);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.V.Verwaltung','',y);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Adr.V.AdressNr', '=', Adr.Nummer);
      Lib_Sel:QRecList(0, vQ);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Stichwort' : begin
      Dlg_Stichwort(Adr.Stichwort,'Adr.Stichwort',Translate('Stichwort'));
      gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;


    'Mnu.Kundennr' : begin
      Msg(010045, '', 0, 0, 0);
      vNumNeu # Adr.Kundennr;
      if ( Dlg_Standard:Anzahl('Neue Kundennummer', var vNumNeu, vNumNeu)=false) then RETURN true;
      if (vNumNeu <> Adr.Kundennr) and (vNumNeu>=0) and (vNumNeu < 99999999) then begin
        if (Adr_Subs:SetKundennr(vNumNeu) = false) then
          Msg(100007, '', 0, 0, 0)
        else
          Msg(999998,'',0,0,0);
      end;

      cZList->WinUpdate(_WinUpdOn, _winLstRecFromRecid | _winLstRecDoSelect);
      $edAdr.KundenNr->WinUpdate(_winUpdFld2Obj);
    end;


    'Mnu.Lieferantennr' : begin
      vNumNeu # Adr.Lieferantennr;
      if (Dlg_Standard:Anzahl('Neue Lieferantennummer', var vNumNeu, vNumNeu)=false) then RETURN true;

      if (vNumNeu != Adr.Lieferantennr) and (vNumNeu>=0) and (vNumNeu < 99999999) then
        if (Adr_Subs:SetLieferantennr(vNumNeu) = false) then
          Msg(100007, '', 0, 0, 0)
        else
          Msg(999998,'',0,0,0);

      cZList->WinUpdate(_WinUpdOn, _winLstRecFromRecid | _winLstRecDoSelect);
      $edAdr.LieferantenNr->WinUpdate(_winUpdFld2Obj);
    end;


    'Mnu.Auftraege' : begin
      RecBufclear(401);
      RecLink(401,100,22,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.P.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/* 03.11.2014
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 22;
      gZLList->wpDbLinkFileno # 401;
*/
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Auf.P.Kundennr"'  , '=', Adr.KundenNr);

      vHdl # SelCreate(401, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.AuftraegeABL' : begin
      RecBufclear(411);
      RecLink(411,100,71,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.P.Ablage',here+':AusInfo',n,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      /*
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 71;
      gZLList->wpDbLinkFileno # 411;
      */

      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Auf~P.Kundennr"'  , '=', Adr.KundenNr);

      vHdl # SelCreate(411, gKey);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Aktionen' : begin
      RecBufclear(404);
      RecLink(404,100,21,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Auf.A.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 21;
      gZLList->wpDbLinkFileno # 404;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Verkaeufe' : begin
      Adr_Data:ZeigeVerkaeufe(Adr.Nummer);
    end;


    'Mnu.Bestellungen' : begin
      RecBufclear(501);
      RecLink(501,100,23,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.P.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/* 03.11.2014
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 23;
      gZLList->wpDbLinkFileno # 501;
*/
      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Ein.P.Lieferantennr"'  , '=', Adr.LieferantenNr);

      vHdl # SelCreate(501, gKey);
      Erx   # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.BestellungenABL' : begin
      RecBufclear(511);
      RecLink(511,100,29,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ein.P.Ablage',here+':AusInfo',n,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      /*
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 29;
      gZLList->wpDbLinkFileno # 511;
      */

      // Selektion aufbauen...
      vQ # '';
      Lib_Sel:QInt(var vQ, '"Ein~P.Lieferantennr"'  , '=', Adr.LieferantenNr);

      vHdl # SelCreate(511, gKey);
      Erx   # vHdl->SelDefQuery('', vQ);
      if (Erx != 0) then Lib_Sel:QError(vHdl);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Erloese' : begin
      RecBufclear(450);
      RecLink(450,100,25,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Erl.Verwaltung',here+':AusInfo',y,n,'-INFO');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 25;
      gZLList->wpDbLinkFileno # 450;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.ErloeseReEmpf' : begin
      RecBufclear(450);
      RecLink(450, 100, 47, _recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Erl.Verwaltung',here+':AusInfo',y,n,'-INFO');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 47;
      gZLList->wpDbLinkFileno # 450;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.OP' : begin
      RecBufclear(460);
      RecLink(460,100,26,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ofp.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 26;
      gZLList->wpDbLinkFileno # 460;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.Verbindlichkeiten' : begin
      RecBufclear(550);
      RecLink(550,100,27,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Vbk.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 27;
      gZLList->wpDbLinkFileno # 550;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.ER' : begin
      RecBufclear(560);
      RecLink(560,100,28,_recFirst);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'ErE.Verwaltung',here+':AusInfo',y,n,'-INFO');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gZLList->wpDbFileno     # 100;
      gZLList->wpDbKeyNo      # 28;
      gZLList->wpDbLinkFileno # 560;
      // Flag setzen, da vorher KEINE Verknüpfung aktiv war!
      gZLList->wpLstFlags # gZLList->wpLstFlags | _WinLstRecFocusTermReset;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;
end;


//========================================================================
// IsPageActive
//========================================================================
Sub IsPageActive(aName : alpha) : logic;
begin
  RETURN aName<>'NB.Page6';
end


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
begin

  case (aEvt:Obj->wpName) of
    'bt.Text1'          : Auswahl('Text1');
    'bt.Text2'          : Auswahl('Text2');
    'bt.Text3'          : Auswahl('Text3');
    'bt.Text4'          : Auswahl('Text4');
    'bt.Text5'          : Auswahl('Text5');

    'bt.TAPI1'          : Lib_Tapi:TapiDialNumber(Adr.Telefon1); //Callold('old_TapiDial',Adr.Telefon1);
    'bt.TAPI2'          : Lib_Tapi:TapiDialNumber(Adr.Telefon2);// Callold('old_TapiDial',Adr.Telefon2);
//  'bt.FAX'            :
    'bt.eMail'          : SysExecute('*mailto:'+Adr.eMail,'',0);
    'bt.WWW'            : Adr_Data:OpenWWW();
    'bt.Maps'           : Adr_Data:OpenGoogleMaps("Adr.Straße", Adr.PLZ, Adr.Ort);
    'bt.OutlookExport'  : Lib_COM:ExportAdr(100);
    'bt.UstIdentCheck'  : Dlg_UstIdent();

    'bt.BIC'            : begin
      Adr_Subs:CheckBLZ(Adr.Bank1.BLZ, var Adr.Bank1.Name, var Adr.Bank1.BIC.SWIFT);
      $edAdr.Bank1.BIC.SWIFT->winupdate(_WinUpdFld2Obj);
      $edAdr.Bank1.Name->winupdate(_WinUpdFld2Obj);
      RETURN true;
    end;
    'bt.BIC2'           : begin
      Adr_Subs:CheckBLZ(Adr.Bank2.BLZ, var Adr.Bank2.Name, var Adr.Bank2.BIC.SWIFT);
      $edAdr.Bank2.BIC.SWIFT->winupdate(_WinUpdFld2Obj);
      $edAdr.Bank2.Name->winupdate(_WinUpdFld2Obj);
      RETURN true;
    end;
    'bt.IBAN' : begin
      if (Adr.Bank1.IBAN<>'') then begin
        Adr_Subs:CheckIBAN(Adr.Bank1.IBAN);
      end
      else begin
        Adr.Bank1.IBAN # Adr_Subs:CalcIBAN(Adr.LKZ, Adr.Bank1.BLZ, Adr.Bank1.Kontonr);
        $edAdr.Bank1.IBAN->winupdate(_WinUpdFld2Obj);
      end;
    end;
    'bt.IBAN2' : begin
      if (Adr.Bank2.IBAN<>'') then begin
        Adr_Subs:CheckIBAN(Adr.Bank2.IBAN);
      end
      else begin
        Adr.Bank2.IBAN # Adr_Subs:CalcIBAN(Adr.LKZ, Adr.Bank2.BLZ, Adr.Bank2.Kontonr);
        $edAdr.Bank2.IBAN->winupdate(_WinUpdFld2Obj);
      end;
    end;

    'bt.Finanzrefresh'  : begin
      Adr_Data:BerechneFinanzen();
      $Lb.TageNachZiel->wpcaption   # ANum(Adr.Fin.Vzg.Offset,2);
      $Lb.letzterAufDat->wpcaption  # cnvad(Adr.Fin.letzterAufam);
      $Lb.letzteReDat->wpcaption    # cnvad(Adr.Fin.letzteReAm);
      $lb.SummeAuf->wpcaption       # ANum(Adr.Fin.SummeAB,2);
      $lb.SummeRes->wpcaption       # ANum(Adr.Fin.SummeRes,2);
      $lb.SummePlan->wpcaption      # ANum(Adr.Fin.SummePlan,2);
      $lb.SummeLfs->wpcaption       # ANum(Adr.Fin.SummeLFS,2);
      $lb.SummeBest->wpcaption      # ANum(Adr.Fin.SummeEkBest,2);
      $lb.SummeDollar->wpcaption    # ANum(Adr.Fin.SummeABBere,2);
      if (Set.KLP.BruttoYN) then begin
        $lb.SummeOP->wpcaption        # ANUm(Adr.Fin.SummeOPB,2);
        $lb.SummeOP.Ext->wpcaption    # ANum(Adr.Fin.SummeOPB.Ext,2);
      end
      else begin
        $lb.SummeOP->wpcaption        # ANUm(Adr.Fin.SummeOP,2);
        $lb.SummeOP.Ext->wpcaption    # ANum(Adr.Fin.SummeOP.Ext,2);
      end;
      $lb.SummeAB.LV->wpcaption     # ANum(Adr.Fin.SummeAB.LV,2);
      $Lb.Fin.Refreshdatum->wpcaption # cnvad(Adr.Fin.Refreshdatum);
     end;
  end;

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Bilddatei'      :   Auswahl('Bilddatei');
    'bt.Dokumentpfad'   :   Auswahl('Dokumentpfad');
    'bt.Sachbearbeiter' :   Auswahl('Sachbearbeiter');
    'bt.Vertreter'      :   Auswahl('Vertreter');
    'bt.Vertreter2'     :   Auswahl('Vertreter2');
    'bt.Verband'        :   Auswahl('Verband');
    'bt.LKZ'            :   Auswahl('LKZ');
    'bt.PLZ'            :   Auswahl('PLZ');
    'bt.PLZ2'           :   Auswahl('PLZ2');
    'bt.Gruppe'         :   Auswahl('Gruppe');
    'bt.Steuerschluessel' : Auswahl('Steuerschluessel');
    'bt.Briefanrede'    :   Auswahl('Briefanrede');
    'bt.Kreditnummer'   :   Auswahl('Kreditnummer');
    'bt.Rechempfaenger'  :  Auswahl('ReEmpfaenger');
    'bt.Lieferanschrift' :  Auswahl('Lieferanschrift');
    'bt.VK.Verwiegeart' :   Auswahl('VKVerwiegungsart');
    'bt.EK.Verwiegeart' :   Auswahl('EKVerwiegungsart');
    'bt.EK.Zahlungsbed' :   Auswahl('EKZahlungsbed');
    'bt.EK.Lieferbed'   :   Auswahl('EKLieferbed');
    'bt.EK.Waehrung'    :   Auswahl('EKWaehrung');
    'bt.EK.Versandart'  :   Auswahl('EKVersandart');
    'bt.VK.Zahlungsbed' :   Auswahl('VKZahlungsbed');
    'bt.VK.Lieferbed'   :   Auswahl('VKLieferbed');
    'bt.VK.Waehrung'    :   Auswahl('VKWaehrung');
    'bt.VK.Versandart'  :   Auswahl('VKVersandart');
    'bt.Sprache'        :   Auswahl('Sprache');
    'bt.AbmessungEH'    :   Auswahl('AbmessungEH');
    'bt.GewichtEH'      :   Auswahl('GewichtEH');
    'bt.EK.Fusstext'    :   Auswahl('FusstextEK');
    'bt.VK.Fusstext'    :   Auswahl('FusstextVK');
  end;

end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTxtHdl : int;
end;
begin
  vTxtHdl # $Adr.TextEdit1RTF->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);
  RETURN true;
end;


//========================================================================
// AdrTextSave
//              Text abspeichern
//========================================================================
sub AdrTextSave()
local begin
  vTxtHdl             : int;          // Handle des Textes
  Erx                 : int;
end
begin
  // Text laden
  vTxtHdl # $Adr.TextEdit1RTF->wpdbTextBuf;
  $Adr.TextEdit1RTF->WinRtfSave(_WinStreamBufText,_winrtfsaveRtf,vTxtHdl);

  // Text speichern
  Erx # TxtWrite(vTxtHdl,'~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), _TextUnlock);
//if (Set.Installname='HWE') then
//Lib_Debug:Protokoll('!HWE_Log_Komisch', 'AdrText Save: Nr.'+aint(Adr.Nummer)+' Hdl'+aint(vTxtHdl)+' Len'+aint(TextInfo(vTxtHdl,_TextLines))+'='+aint(erx)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')

//TxtCopy('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),'!!!CCCCCC' ,0);
//TxtDelete('~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), _TextUnlock);
//TxtCreate('!!!DINGEN!!!', 0);

  // AFX
  RunAFX('Adr.TextSave','~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8));

END;


//========================================================================
// AdrTextRead
//              Text einlesen
//========================================================================
sub AdrTextRead(opt aMustRead : logic)
local begin
  Erx                 : int;
  vTxtHdl             : int;          // Handle des Textes
end
begin
  if (Mode=c_ModeEdit) and (aMustRead=false) then RETURN;

  // Text laden
  vTxtHdl # $Adr.TextEdit1RTF->wpdbTextBuf;
  
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Adr.TextEdit1RTF->wpdbTextBuf # vTxtHdl;
  end;

  Erx # TextRead(vTxtHdl,'~100.'+CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8), _TextUnlock);
//if (Set.Installname='HWE') then
//Lib_Debug:Protokoll('!HWE_Log_Komisch', 'AdrText Load: Nr.'+aint(Adr.Nummer)+' Hdl'+aint(vTxtHdl)+' Len'+aint(TextInfo(vTxtHdl,_TextLines))+'='+aint(erx)+'   ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
  
  if (Erx>_rLocked) then
    TextClear(vTxtHdl);

  $Adr.TextEdit1RTF ->WinRtfLoad(_WinStreamBufText, _WinRtfLoadMix ,vTxtHdl);
end;


//========================================================================
//  EvtPageSelect2
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect2(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin

  If (aSelecting=n) and
   (aPage->wpname='NB.Page6') then begin
    Adr_Dokumente:Term();
  end;

  RETURN App_Main:EvtPageSelect(aEvt,aPage,aSelecting);
end;


//========================================================================
//  EvtPageSelect
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelect(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin

  If (aSelecting) then begin
    case aPage->wpname of
      'NB.Page6'    : Adr_Dokumente:Init();
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aevt      : event;
  arecid    : int;
  Opt aMark : logic;
);
begin

  // AFX
  if (aMark) then begin
    if (RunAFX('Adr.EvtLstDataInit','y')<0) then RETURN;
  end
  else if (RunAFX('Adr.EvtLstDataInit','n')<0) then RETURN;
    if (aMark=n) then begin
      if (Adr.SperrKundeYN) or (Adr.SperrLieferantYN) then
        Lib_GuiCom:ZLColorLine(gZLList,Set.Col.RList.Deletd)
  end;

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
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);
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
  vHdl      : int;
  vRect     : rect;
end
begin

  App_Main:EvtPoschanged(aEvt, aRect, aClientSize, aFlags);

  if (aFlags & _WinPosSized != 0) then begin
    Lib_GuiCom:ObjSetPos($Bt.DocRefresh, 0, 520 + (aRect:Bottom - aRect:Top)-602);
    Lib_GuiCom:ObjSetPos($tvStrukturen, 0, 0, 0, 516 + ((aRect:Bottom - aRect:Top) - 602) );
    Lib_GuiCom:ObjSetPos($dlDateien, 0, 0, 886 + ((aRect:right - aRect:left) - 890), 516 + ((aRect:Bottom - aRect:Top) - 602) );
  end;

  // Quickbar
  vHdl # Winsearch(gMDI,'gs.Main');
  if (vHdl<>0) then begin
    vRect           # vHdl->wpArea;
    vRect:right     # aRect:right-aRect:left+2;
    vRect:bottom    # aRect:bottom-aRect:Top+5;
    vHdl->wparea    # vRect;
  end;

	RETURN (true);
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
local begin
  vQ        :  alpha(1000);
  vBuf100   : int;
end
begin

  if ((aName =^ 'edAdr.PLZ') AND (aBuf->Adr.PLZ<>'')) then begin
    Ort.PLZ # Adr.PLZ;
    RecRead(847,1,0)
    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.Postfach.PLZ') AND (aBuf->Adr.Postfach.PLZ<>'')) then begin
    Ort.PLZ # Adr.Postfach.PLZ;
    RecRead(847,1,0)
    Lib_Guicom2:JumpToWindow('Ort.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.LKZ') AND (aBuf->Adr.LKZ<>'')) then begin
    RekLink(812,100,10,0);   // Land holen
    Lib_Guicom2:JumpToWindow('Lnd.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.Gruppe') AND (aBuf->Adr.Gruppe<>'')) then begin
    Grp.Name # Adr.Gruppe;
    RecRead(810,1,0)
    Lib_Guicom2:JumpToWindow('Grp.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.Sachbearbeiter') AND (aBuf->Adr.Sachbearbeiter<>'')) then begin
    Usr.Username # Adr.Sachbearbeiter;
    RecRead(800,1,0)
    Lib_Guicom2:JumpToWindow('Usr.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.Vertreter') AND (aBuf->Adr.Vertreter<>0)) then begin
    RekLink(110,100,15,0);   // 1.Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.Vertreter2') AND (aBuf->Adr.Vertreter2<>0)) then begin
    RekLink(110,100,32,0);   // 2.Vertreter holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.Verband') AND (aBuf->Adr.Verband<>0)) then begin
    RekLink(110,100,16,0);   // Verband holen
    Lib_Guicom2:JumpToWindow('Ver.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Lieferbed') AND (aBuf->Adr.EK.Lieferbed<>0)) then begin
    RekLink(815,100,2,0);   // Lieferbed holen
    Lib_Guicom2:JumpToWindow('Lib.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Zahlungsbed') AND (aBuf->Adr.EK.Zahlungsbed<>0)) then begin
    RekLink(816,100,3,0);   // Zahlungsbed holen
    Lib_Guicom2:JumpToWindow('ZAB.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Versandart') AND (aBuf->Adr.EK.Versandart<>0)) then begin
    RekLink(817,100,4,0);   // Versandart holen
    Lib_Guicom2:JumpToWindow('VsA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Verwiegeart') AND (aBuf->Adr.EK.Verwiegeart<>0)) then begin
    RekLink(818,100,73,0);   // Verweigungsart holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Waehrung') AND (aBuf->"Adr.EK.Währung"<>0)) then begin
    RekLink(814,100,1,0);   // Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.EK.Fusstext') AND (aBuf->Adr.EK.Fusstext<>0)) then begin
  todo('FusstextEK')
  //  RekLink(814,100,1,0);   // FussText holen
    Lib_Guicom2:JumpToWindow('Txt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.VK.Lieferbed') AND (aBuf->Adr.VK.Lieferbed<>0)) then begin
    RekLink(815,100,6,0);   // Verkauf Lieferbed holen
    Lib_Guicom2:JumpToWindow('LiB.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.VK.Zahlungsbed') AND (aBuf->Adr.VK.Zahlungsbed<>0)) then begin
    RekLink(816,100,7,0);   // Verkauf Zahlungsbed holen
    Lib_Guicom2:JumpToWindow('ZaB.Verwaltung');
    RETURN;
  end;
  
   if ((aName =^ 'edAdr.VK.Versandart') AND (aBuf->Adr.VK.Versandart<>0)) then begin
    RekLink(817,100,8,0);   // Verkauf Versand holen
    Lib_Guicom2:JumpToWindow('VsA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.VK.Verwiegeart') AND (aBuf->Adr.VK.Verwiegeart<>0)) then begin
    RekLink(818,100,9,0);   // Verkauf Verweigerung holen
    Lib_Guicom2:JumpToWindow('VwA.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.VK.Waehrung') AND (aBuf->"Adr.VK.Währung"<>0)) then begin
    RekLink(814,100,5,0);   // Verkauf Währung holen
    Lib_Guicom2:JumpToWindow('Wae.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.VK.Std.LieferAns') AND (aBuf->Adr.VK.Std.LieferAns<>0)) then begin
    RekLink(101,100,76,0);
    Adr.A.Adressnr # Adr.VK.Std.LieferAdr;
    Adr.A.Nummer # Adr.VK.Std.LieferAns;
    RecRead(101,1,0);
    
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.VK.Std.LieferAdr);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung',vQ);
    RETURN;
  end;

  if ((aName =^ 'edAdr.VK.ReAnschrift') AND (aBuf->Adr.VK.ReAnschrift<>0)) then begin
    vBuf100 # RecBufCreate(100);
    vBuf100->Adr.KundenNr # "Adr.VK.ReEmpfänger";
    RecRead(vBuf100,2,0);
           
    Adr.A.Adressnr # vBuf100->Adr.Nummer;  // Adressr
    Adr.A.Nummer   # Adr.VK.ReAnschrift;
    RecRead(101,1,0);
  
    Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', vBuf100->Adr.Nummer);
    
    RecBufDestroy(vBuf100);
    Lib_Guicom2:JumpToWindow('Adr.A.Verwaltung',vQ);
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.VK.Fusstext') AND (aBuf->Adr.VK.Fusstext<>0)) then begin
    Txt.Nummer # Adr.VK.Fusstext;
    RecRead(837,1,0)
    Lib_Guicom2:JumpToWindow('Txt.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edAdr.Steuerschluessel') AND (aBuf->"Adr.Steuerschlüssel"<>0)) then begin
    RekLink(813,100,11,0);   // Steuerschlüssel holen
    Lib_Guicom2:JumpToWindow('StS.Verwaltung');
    RETURN;
  end;
  
  
end;

//========================================================================
//========================================================================
//========================================================================