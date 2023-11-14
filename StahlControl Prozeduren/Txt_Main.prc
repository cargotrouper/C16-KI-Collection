@A+
//==== Business-Control ==================================================
//
//  Prozedur    Txt_Main
//                  OHNE E_R_G
//  Info
//
//
//  05.11.2003  ST  Erstellung der Prozedur
//  29.03.2008  ST  Lieferbedingung hinzugefügt
//  20.10.2009  MS  TxtBuffer Clearen bei Neuanlage
//  10.09.2013  ST  "M" für Email hinzugefügt
//  14.04.2015  ST  Lesen und Speichern von Lang5texten erkennt weiche Zeilenumbrüche
//  16.02.2016  AH  Bug:RecInt verändert, dass bei Neuanlage definitiv geleert wird (Prj. 1326/476)
//  27.06.2016  AH  ESC ESC ESC / StrChar(27) als Seperator für 5er Texte
//  28.05.2020  AH  RTF-Texte
//  04.02.2022  AH  ERX
//  26.07.2022  HA  Quick Jump
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB Pflichtfelder();
//    SUB RefreshIfm(optaName : alpha)
//    SUB RecInit()
//    SUB RecSave() : logic;
//    SUB RecCleanup() : logic
//    SUB RecDel()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB Auswahl(aBereich : alpha)
//    SUB AusWarengruppe()
//    SUB AusGuete()
//    SUB AusGuetenstufe()
//    SUB AusAdresse()
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB TxtSave()
//    SUB TxtRead()
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtClose(aEvt : event) : logic
//
//
//
// Angebot=A
// BAG=B
// Anfrage=D
// Einkauf=E
// Lieferbed=G
// Artikel=L
// Porjekte=P
// Reklamation=R
// Verkauf=V
// E-Mail=M  (Rundmail)
//
//========================================================================
@I:Def_Global
@I:Def_Rights


declare TxtSave();
declare TxtRead();

define begin
  cTitle :    'Texte'
  cFile :     837
  cMenuName : 'Std.Bearbeiten'
  cPrefix :   'Txt'
  cZList :    $ZL.Texte
  cKey :      1
  cListen : 'Texte'
end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;
  w_Listen # cListen;

Lib_Guicom2:Underline($edTxt.bei.Gtenstufe);
Lib_Guicom2:Underline($edTxt.bei.Gte);
Lib_Guicom2:Underline($edTxt.bei.Warengruppe);
Lib_Guicom2:Underline($edTxt.bei.Adressnr);

  // Auswahlfelder setzen...
  SetStdAusFeld('edTxt.bei.Gtenstufe'    ,'Guetenstufe');
  SetStdAusFeld('edTxt.bei.Gte'          ,'Guete');
  SetStdAusFeld('edTxt.bei.Warengruppe'  ,'Wgr');
  SetStdAusFeld('edTxt.bei.Adressnr'     ,'Adresse');

  App_Main:EvtInit(aEvt);

  // Sprachüberschriften setzen
  vHdl # gMdi->Winsearch('NB.Page2');
  vHdl -> wpCaption # Set.Sprache1;

  vHdl # gMdi->Winsearch('NB.Page3');
  vHdl -> wpCaption # Set.Sprache2;

  vHdl # gMdi->Winsearch('NB.Page4');
  vHdl -> wpCaption # Set.Sprache3;

  vHdl # gMdi->Winsearch('NB.Page5');
  vHdl -> wpCaption # Set.Sprache4;

  vHdl # gMdi->Winsearch('NB.Page6');
  vHdl -> wpCaption # Set.Sprache5;

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) and
    (Mode<>c_ModeNew2) and (Mode<>c_ModeEdit2) then RETURN;// Pflichtfelder
  // Pflichtfelder
  Lib_GuiCom:Pflichtfeld($edTxt.Nummer);
end;


//========================================================================
//========================================================================
sub CheckPages()
begin
  $NB.Page2->wpdisabled # Txt.RtfYN;
  $NB.Page3->wpdisabled # Txt.RtfYN;
  $NB.Page4->wpdisabled # Txt.RtfYN;
  $NB.Page5->wpdisabled # Txt.RtfYN;
  $NB.Page6->wpdisabled # Txt.RtfYN;
  $NB.Page7->wpdisabled # !Txt.RtfYN;
end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  CheckPages();
  RETURN true;
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  Erx     : int;
  vTxtHdl : int;
  vPos    : int;
  vTmp    : int;
end;
begin

  if (aName='') then begin

    if (StrFind(Txt.Bereichstring,'R',0) > 0) then
      $edCheckReklamation->wpCheckState # _winstatechkchecked
    else
      $edCheckReklamation->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'A',0) > 0) then
      $edCheckAngebot->wpCheckState # _winstatechkchecked
    else
      $edCheckAngebot->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'D',0) > 0) then
      $edCheckAnfrage->wpCheckState # _winstatechkchecked
    else
      $edCheckAnfrage->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'E',0) > 0) then
      $edCheckEinkauf->wpCheckState # _winstatechkchecked
    else
      $edCheckEinkauf->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'V',0) > 0) then
      $edCheckVerkauf->wpCheckState # _winstatechkchecked
    else
      $edCheckVerkauf->wpCheckState  # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'B',0) > 0) then
      $edCheckBA->wpCheckState # _winstatechkchecked
    else
      $edCheckBA->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'L',0) > 0) then
      $edCheckArtikel->wpCheckState # _winstatechkchecked
    else
      $edCheckArtikel->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'P',0) > 0) then
      $edCheckProjekt->wpCheckState # _winstatechkchecked
    else
      $edCheckProjekt->wpCheckState # _winstatechkunchecked;

    if (StrFind(Txt.Bereichstring,'G',0) > 0) then
      $edCheckLieferbed->wpCheckState # _winstatechkchecked
    else
      $edCheckLieferbed->wpCheckState # _winstatechkunchecked;

    // ST 2013-09-10: hinzugefügt
    if (StrFind(Txt.Bereichstring,'M',0) > 0) then
      $edCheckEmail->wpCheckState # _winstatechkchecked
    else
      $edCheckEmail->wpCheckState # _winstatechkunchecked;

    CheckPages();
  end;


  if (aName = '') or (aName = 'edTxt.bei.Warengruppe') then begin
    Erx # RecLink(819,837,1,_RecFirsT); // Warengruppe holen
    if (Erx>_rLockeD) then
      $lb.Warengruppe->wpcaption # ''
    else
      $lb.Warengruppe->wpcaption # Wgr.Bezeichnung.L1;
  end;

  if (aName = '') or (aName = 'edTxt.bei.Adressnr') then begin
    Erx # RecLink(100,837,2,_RecFirsT); // Adresse holen
    if (Erx>_rLockeD) or (Txt.bei.ADressnr=0) then
      $lb.Adresse->wpcaption # ''
    else
      $lb.Adresse->wpcaption # Adr.Stichwort;
  end;

  if (aName = '') or (aName = 'edCheckReklamation') then begin
    vPos # StrFind(Txt.Bereichstring,'R',0);
    if (vPos > 0) then  begin
      IF ($edCheckReklamation->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckReklamation->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'R';
    end;
  end;


  if (aName = '') or (aName = 'edCheckArtikel') then begin
    vPos # StrFind(Txt.Bereichstring,'L',0);
    if (vPos > 0) then  begin
      IF ($edCheckArtikel->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckArtikel->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'L';
    end;
  end;

  if (aName = '') or (aName = 'edCheckAngebot') then begin
    vPos # StrFind(Txt.Bereichstring,'A',0);
    if (vPos > 0) then  begin
      IF ($edCheckAngebot->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckAngebot->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'A';
    end;
  end;

  if (aName = '') or (aName = 'edCheckAnfrage') then begin
    vPos # StrFind(Txt.Bereichstring,'D',0);
    if (vPos > 0) then  begin
      IF ($edCheckAnfrage->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckAnfrage->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'D';
    end;
  end;

  if (aName = '') or (aName = 'edCheckEinkauf') then begin
    vPos # StrFind(Txt.Bereichstring,'E',0);
    if (vPos > 0) then  begin
      IF ($edCheckEinkauf->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckEinkauf->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'E';

    end;
  end;

  if (aName = '') or (aName = 'edCheckVerkauf') then begin
    vPos # StrFind(Txt.Bereichstring,'V',0);
    if (vPos > 0) then  begin
      IF ($edCheckVerkauf->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckAnfrage->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'V';
    end;
  end;

  if (aName = '') or (aName = 'edCheckBA') then begin
    vPos # StrFind(Txt.Bereichstring,'B',0);
    if (vPos > 0) then  begin
      IF ($edCheckBA->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckBA->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'B';
    end;
  end;

  if (aName = '') or (aName = 'edCheckProjekt') then begin
    vPos # StrFind(Txt.Bereichstring,'P',0);
    if (vPos > 0) then  begin
      IF ($edCheckProjekt->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckProjekt->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'P';
    end;
  end;

  if (aName = '') or (aName = 'edCheckLieferbed') then begin
    vPos # StrFind(Txt.Bereichstring,'G',0);
    if (vPos > 0) then  begin
      IF ($edCheckLieferbed->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckLieferbed->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'G';
    end;
  end;

  if (aName = '') or (aName = 'edCheckEmail') then begin
    vPos # StrFind(Txt.Bereichstring,'M',0);
    if (vPos > 0) then  begin
      IF ($edCheckEmail->wpCheckState = _winstatechkunchecked) then
        Txt.Bereichstring # StrDel(Txt.Bereichstring,vPos,1);
    end else begin
      IF ($edCheckEmail->wpCheckState = _winstatechkchecked) then
        Txt.Bereichstring # Txt.Bereichstring + 'M';
    end;
  end;





  ///////////////////////
  // Textpuffer erstellen

  // Sprache 1
  vTxtHdl # $edTxt_lang1->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang1->wpdbTextBuf # vTxtHdl;
  end;

  // Sprache 2
  vTxtHdl # $edTxt_lang2->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang2->wpdbTextBuf # vTxtHdl;
  end;

  // Sprache 3
  vTxtHdl # $edTxt_lang3->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang3->wpdbTextBuf # vTxtHdl;
  end;

  // Sprache 4
  vTxtHdl # $edTxt_lang4->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang4->wpdbTextBuf # vTxtHdl;
  end;

  // Sprache 5
  vTxtHdl # $edTxt_lang5->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_lang5->wpdbTextBuf # vTxtHdl;
  end;

  // Text All
  vTxtHdl # $edTxt_all->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $edTxt_all->wpdbTextBuf # vTxtHdl;
  end;

  // Text RTF
  vTxtHdl # $Txt.RTF->wpdbTextBuf;
  if (vTxtHdl=0) then begin
    vTxtHdl # TextOpen(32);
    $Txt.Rtf->wpdbTextBuf # vTxtHdl;
  end;

  // veränderte Felder in Objekte schreiben
  if (aName<>'') then begin
    vTmp # gMdi->winsearch(aName);
    if (vTmp<>0) then
     vTmp->winupdate(_WinUpdFld2Obj);
  end;

  if (Mode=c_Modeview) then TxtRead();

  // einfärben der Pflichtfelder
  if (Mode=c_ModeNew) or (Mode=c_ModeNew2) or
    (Mode=c_ModeEdit) or (Mode=c_ModeEdit2) then
    Pflichtfelder();

  // dynamische Pflichtfelder einfärben
  Lib_Pflichtfelder:PflichtfelderEinfaerben();
end;


//========================================================================
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  Erx     : int;
  vNummer : int;
end;
begin

  If (Mode=c_ModeNew) then begin
    Erx # RecRead(837,1,_recLast);
    if (Erx<=_rLocked) then
      vNummer # Txt.Nummer + 1;
    else
      vNummer # 0;

    RecBufClear(837);

    Txt.Nummer # vNummer;
    $edTxt.Nummer -> wpCaptionInt # Txt.Nummer;

    $edCheckArtikel->wpCheckState # _winstatechkunchecked;
    $edCheckAngebot->wpCheckState # _winstatechkunchecked;
    $edCheckAnfrage->wpCheckState # _winstatechkunchecked;
    $edCheckEinkauf->wpCheckState # _winstatechkunchecked;
    $edCheckVerkauf->wpCheckState # _winstatechkunchecked;
    $edCheckBA     ->wpCheckState # _winstatechkunchecked;
    $edCheckProjekt->wpCheckState # _winstatechkunchecked;
    $edCheckReklamation->wpCheckState # _winstatechkunchecked;
    $edCheckLieferbed->wpCheckState # _winstatechkunchecked;
    $edCheckEmail->wpCheckState # _winstatechkunchecked;

    TextClear($edTxt_all->wpdbTextBuf);
    TextClear($edTxt_lang1->wpdbTextBuf);
    TextClear($edTxt_lang2->wpdbTextBuf);
    TextClear($edTxt_lang3->wpdbTextBuf);
    TextClear($edTxt_lang4->wpdbTextBuf);
    TextClear($edTxt_lang5->wpdbTextBuf);
    TextClear($Txt.RTF->wpdbTextBuf);
    $edTxt_lang1->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang2->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang3->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang4->WinUpdate(_WinUpdBuf2Obj);
    $edTxt_lang5->WinUpdate(_WinUpdBuf2Obj);
    $Txt.RTF->WinUpdate(_WinUpdBuf2Obj);
    
  end
  else begin
    Lib_GuiCom:Disable($cbTxt.RtfYN);
    TxtRead(); // !!! ERST NACH LEEREN DER TXTBUFFER !!!
  end;

  // Felder Disablen durch:
//  Lib_GuiCom:Disable($edTxt.Nummer);
  // Focus setzen auf Feld:
  $edTxt.Bezeichnung->WinFocusSet(true);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx     : int;
  vName   : alpha
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  If (Txt.Nummer=0) then begin
    Msg(001200,Translate('Nummer'),0,0,0);
    $NB.Main->wpcurrent # 'NB.Page1';
    $edTxt.Nummer->WinFocusSet(true);
    RETURN false;
  end;


  Txt.Bereichstring # '';

  IF ($edCheckReklamation->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'R';

  IF ($edCheckArtikel->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'L';

  IF ($edCheckAngebot->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'A';

  IF ($edCheckAnfrage->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'D';

  IF ($edCheckEinkauf->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'E';

  IF ($edCheckVerkauf->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'V';

  IF ($edCheckBA->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'B';

  IF ($edCheckProjekt->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'P';

  IF ($edCheckLieferbed->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'G';

  IF ($edCheckEmail->wpCheckState = _winstatechkchecked) then
    Txt.Bereichstring # Txt.Bereichstring + 'M';


  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;

    if (ProtokollBuffer[837]->Txt.Nummer<>Txt.Nummer) then begin
      vName # '~837.'+CnvAI(ProtokollBuffer[837]->Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
      TxtDelete(vName,0);
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

  TxtSave();
  RETURN true;  // Speichern erfolgreich
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
local begin
  vTxtHdl_all : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  if (RekDelete(gFile,0,'MAN')=_rOK) then begin
//  vTxtHdl_all # $edTxt_all->wpdbtextbuf;
    TxtDelete('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF',0);
    TxtDelete('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
    if (gZLList->wpDbSelection<>0) then begin
      SelRecDelete(gZLList->wpDbSelection,gFile);
      RecRead(gFile, gZLList->wpDbSelection, 0);
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

  if((Mode=c_modeedit) or (Mode=c_modenew)) and
   (Wininfo(aEvt:Obj, _WinType)=_WinTypeRtfEdit) then begin
    aEvt:Obj->wpReadOnly  # n;
    $Txt.ToolbarRTF -> wpdisabled # false;
//    $Txt.ToolbarTXT -> wpdisabled # false;
    $Txt.ToolbarRTF->wpObjLink # aEvt:Obj->WpName;
  end
  else begin
    if ($Txt.ToolbarRTF->wpdisabled=false) then begin
      $Txt.ToolbarRTF -> winupdate(_Winupdon);
      $Txt.ToolbarRTF -> wpdisabled # true;
//      $Txt.ToolbarTXT -> wpdisabled # true;
    end;
    if (Wininfo(aEvt:Obj, _WinType)=_WinTypeRtfEdit) then begin
      aEvt:Obj->wpReadOnly  # y;
    end;
  end;



  // Auswahlfelder aktivieren
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

  if (aEvt:Obj->wpName='cbTxt.RtfYN') then begin
//    $cbTxt.RtfYN->wpcustom # '_N';
    Lib_GuiCom:Disable($cbTxt.RtfYN);
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
local begin
  vQ  : alpha(1000);
end;
begin
  case aBereich of

    'Wgr' : begin
      RecBufClear(819);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusWarengruppe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guetenstufe' : begin
      RecBufClear(848);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusGuetenstufe');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Guete' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusGuete');

      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufClear(848);
      MQu.S.Stufe # "Txt.bei.Gütenstufe";
      if (MQu.S.Stufe<>'') then begin
        vQ # ' MQu.NurStufe = '''+MQu.S.Stufe+''' OR MQu.NurStufe = '''' ';
        Lib_Sel:QRecList(0, vQ);
      end;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Adresse' : begin
      RecBufClear(100);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusAdresse');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  AusWarengruppe
//
//========================================================================
sub AusWarengruppe()
begin
  if (gSelected<>0) then begin
    RecRead(819,0,_RecId,gSelected);
    // Feldübernahme
    Txt.bei.Warengruppe # Wgr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edTxt.bei.Warengruppe->Winfocusset(false);
end;


//========================================================================
//  AusGuete
//
//========================================================================
sub AusGuete()
begin
  if (gSelected<>0) then begin
    RecRead(832,0,_RecId,gSelected);
    // Feldübernahme
    if (MQu.ErsetzenDurch<>'') then
      "Txt.bei.Güte" # MQu.ErsetzenDurch
    else if ("MQu.Güte1"<>'') then
      "Txt.bei.Güte" # "MQu.Güte1"
    else
      "Txt.bei.Güte" # "MQu.Güte2";
    gSelected # 0;
  end;
  // Focus setzen:
  $edTxt.bei.Gte->Winfocusset(false);
end;


//========================================================================
//  AusGuetenstufe
//
//========================================================================
sub AusGuetenstufe()
begin
  if (gSelected<>0) then begin
    RecRead(848,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    "Txt.bei.Gütenstufe" # MQu.S.Stufe;
  end;
  // Focus auf Editfeld setzen:
  $edTxt.bei.Gtenstufe->Winfocusset(false);
end;



//========================================================================
//  AusAdresse
//
//========================================================================
sub AusAdresse()
begin
  if (gSelected<>0) then begin
    RecRead(100,0,_RecId,gSelected);
    // Feldübernahme
    Txt.bei.AdressNr # Adr.Nummer;
    gSelected # 0;
  end;
  // Focus setzen:
  $edTxt.bei.Adressnr->Winfocusset(false);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem : int;
  vHdl : int;
end
begin

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Txt_Loeschen]=n);

  RefreshIfm();

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
  vHdl    : int;
  vMode   : alpha;
  vParent : int;
  vTmp    : int;
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Guetenstufe'  : Auswahl('Guetenstufe');
    'bt.Guete'        : Auswahl('Guete');
    'bt.Adresse'      : Auswahl('Adresse');
    'bt.Wgr'          : Auswahl('Wgr');
  end;

end;


//========================================================================
// TxtSave
//              Text abspeichern
//========================================================================
sub TxtSave()
local begin
  vTxtHdl_all           : int;         // Textpuffer für alle Sprachen
  vTxtHdl               : int;          // Handle des Textes
  i,j                   : int;
  inserted_lines        : int;         // Zeilenzähler des kompletten Textes
  txt_length            : int;
  vName                 : alpha;

  vA                    : alpha(260);
  vOpt                  : int;
  vSeperator            : alpha;
end
begin
  vName # '~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
/**
vName # '!!!';
$edTxt_lang1->WinUpdate(_WinUpdObj2Buf);
vTxtHdl # $edTxt_lang1->wpdbTextBuf;
TxtWrite(vTxtHdl,vName, _TextUnlock);
RETURN;
***/

  vTxtHdl_all # $edTxt_all->wpdbtextbuf;
  TextClear(vTxthdl_all);

  inserted_lines # 0;

  // ---------------------------
  // Sprachen eintragen
  // ---------------------------
  vSeperator # StrChar(254,3);
  if (TextSearch(vTxtHdl_all, 1, 1, 0, StrChar(27,3))>0) then
    vSeperator # StrChar(27,3);


  FOR  j # 1
  LOOP j # j + 1
  WHILE (j <= 5) DO BEGIN
    // ST 2015-04-13: kein weicher LF
    TextLineWrite(vTxtHdl_All,TextInfo(vTxtHdl_all,_TextLines)+1,vSeperator + CnvAi(j),_TextLineInsert/* | _TextNoLineFeed*/);
    //TextLineWrite(vTxtHdl_All,TextInfo(vTxtHdl_all,_TextLines)+1,StrChar(254,3) + CnvAi(j),_TextLineInsert | _TextNoLineFeed);
    inserted_lines # inserted_lines + 1;

    // zum schreibenden Text lesen
    case j of
      1 :  begin
            vTxtHdl # $edTxt_lang1->wpdbTextBuf;
            $edTxt_lang1->WinUpdate(_WinUpdObj2Buf);
          end;

      2 :  begin
            vTxtHdl # $edTxt_lang2->wpdbTextBuf;
            $edTxt_lang2->WinUpdate(_WinUpdObj2Buf);
           end;

      3 :  begin
            vTxtHdl # $edTxt_lang3->wpdbTextBuf;
            $edTxt_lang3->WinUpdate(_WinUpdObj2Buf);
           end;

      4 :  begin
            vTxtHdl # $edTxt_lang4->wpdbTextBuf;
            $edTxt_lang4->WinUpdate(_WinUpdObj2Buf);
           end;

      5 :  begin
            vTxtHdl # $edTxt_lang5->wpdbTextBuf;
            $edTxt_lang5->WinUpdate(_WinUpdObj2Buf);
           end;
    end;

    txt_length # TextInfo(vTxtHdl,_TextLines);
    FOR  i # 1
    LOOP i # i + 1
    WHILE (i <= txt_length) DO BEGIN
      inserted_lines # inserted_lines + 1;

      vA # TextLineRead(vTxtHdl,i,0);
      if (TextInfo(vTxtHdl,_TextNoLinefeed) = 1) then
        vOpt # _TextNoLinefeed
      else  // = 0
        vOpt # 0;

      // ST 2015-04-13: kein weicher LF
      TextLineWrite(vTxtHdl_all,inserted_lines,vA,_TextLineInsert | vOpt);
      //TextLineWrite(vTxtHdl_all,inserted_lines,TextLineRead(vTxtHdl,i,0),_TextLineInsert);  // NEU 14.12.2007
    END;

  END;

  // ---------------------------------------
  // Alle Sprachen in einen Text schreiben
  // ---------------------------------------

  TxtWrite(vTxtHdl_all, vName, _TextUnlock);
//  TextClose(vTxtHdl_All);

  // RTF speichern
  Lib_Texte:RtfTextSave($Txt.RTF, '~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF');

END;


//========================================================================
// TxtRead
//              Text lesen und in die Sprachen aufteilen
//========================================================================
sub TxtRead()
local begin
  vTxtHdl_all           : int;         // Textpuffer für alle Sprachen
  vTxtHdl_L1            : int;         // Handle des Textes
  vTxtHdl_L2            : int;         // Handle des Textes
  vTxtHdl_L3            : int;         // Handle des Textes
  vTxtHdl_L4            : int;         // Handle des Textes
  vTxtHdl_L5            : int;         // Handle des Textes
  i,j                   : int;
  inserted_lines        : int;         // Zeilenzähler des kompletten Textes
  vAlpha1               : alpha(255);
  vSaved                : int;
  vName                 : alpha;
  vOpt                  : int;
  vSeperator            : alpha;
end
begin
  vName # '~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
/***
vName # '!!!';
//vName # '~401.00100056.001';
vTxtHdl_L1 # $edTxt_lang1->wpdbTextBuf;
Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl_L1, '');
//TextRead(vTxtHdl_L1, vName, 0);
debug(cnvai(vTxtHdl_l1)+'  Erx');
$edTxt_lang1->wpdbTextBuf # vTxtHdl_L1;
$edTxt_lang1->WinUpdate(_WinUpdBuf2Obj);
//  Lib_Texte:TxtLoadLangBuf(vName,vTxtHdl_L1, 1);
RETURN;
***/

  vTxtHdl_all # $edTxt_all->wpdbTextBuf;
  vTxtHdl_L1 # $edTxt_lang1->wpdbTextBuf;
  vTxtHdl_L2 # $edTxt_lang2->wpdbTextBuf;
  vTxtHdl_L3 # $edTxt_lang3->wpdbTextBuf;
  vTxtHdl_L4 # $edTxt_lang4->wpdbTextBuf;
  vTxtHdl_L5 # $edTxt_lang5->wpdbTextBuf;
  TextClear(vTxtHdl_L1);
  TextClear(vTxtHdl_L2);
  TextClear(vTxtHdl_L3);
  TextClear(vTxtHdl_L4);
  TextClear(vTxtHdl_L5);
/*
  vTxtHdl_all # TextOpen(160);
  vTxtHdl_L1 # TextOpen(32);
  vTxtHdl_L2 # TextOpen(32);
  vTxtHdl_L3 # TextOpen(32);
  vTxtHdl_L4 # TextOpen(32);
  vTxtHdl_L5 # TextOpen(32);
*/

  TextRead(vTxtHdl_all,vName,0);

  vSeperator # StrChar(254,3);
  if (TextSearch(vTxtHdl_all, 1, 1, 0, StrChar(27,3))>0) then
    vSeperator # StrChar(27,3);

  inserted_lines # 0;
  j # 1;
  FOR  i # 1
  LOOP i # i + 1
  WHILE (i <= TextInfo(vTxtHdl_all,_TextLines)) DO BEGIN

    IF (StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0) <> 0) then begin
      vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
      vAlpha1 # StrCut(vAlpha1,StrFind(TextLineRead(vTxtHdl_all,i,0), vSeperator,0)+3,1);
      j # CnvIa(vAlpha1);
      end
    else begin
      vAlpha1 # TextLineRead(vTxtHdl_all,i,0);
      if (StrLen(vAlpha1)=250) then
      //if (TextInfo(vTxtHdl_all,_TextNoLinefeed) = 1) then
        vOpt # _TextNoLinefeed
      else  // = 0
        vOpt # 0;

      case j of
        1 :  TextLineWrite(vTxtHdl_L1,TextInfo(vTxtHdl_L1,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt); // NEU 14.12.2007
        2 :  TextLineWrite(vTxtHdl_L2,TextInfo(vTxtHdl_L2,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
        3 :  TextLineWrite(vTxtHdl_L3,TextInfo(vTxtHdl_L3,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
        4 :  TextLineWrite(vTxtHdl_L4,TextInfo(vTxtHdl_L4,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
        5 :  TextLineWrite(vTxtHdl_L5,TextInfo(vTxtHdl_L5,_TextLines)+1,vAlpha1,_TextLineInsert | vOpt);
      end;
    end;
  END;

  // Textpuffer an Felderübergeben
  $edTxt_lang1->wpdbTextBuf # vTxtHdl_L1;
//  $edTxt_lang1->WinUpdate(_WinUpdObj2Buf);
  $edTxt_lang1->WinUpdate(_WinUpdBuf2Obj);

  $edTxt_lang2->wpdbTextBuf # vTxtHdl_L2;
//  $edTxt_lang2->WinUpdate(_WinUpdObj2Buf);
  $edTxt_lang2->WinUpdate(_WinUpdBuf2Obj);

  $edTxt_lang3->wpdbTextBuf # vTxtHdl_L3;
//  $edTxt_lang3->WinUpdate(_WinUpdObj2Buf);
  $edTxt_lang3->WinUpdate(_WinUpdBuf2Obj);

  $edTxt_lang4->wpdbTextBuf # vTxtHdl_L4;
//  $edTxt_lang4->WinUpdate(_WinUpdObj2Buf);
  $edTxt_lang4->WinUpdate(_WinUpdBuf2Obj);

  $edTxt_lang5->wpdbTextBuf # vTxtHdl_L5;
//  $edTxt_lang5->WinUpdate(_WinUpdObj2Buf);
  $edTxt_lang5->WinUpdate(_WinUpdBuf2Obj);

//  TextClose(vTxtHdl_All);

  // RTF laden
  Lib_Texte:RtfTextRead($Txt.RTF, '~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.RTF');
debug('Lade??');

END;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
begin
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
  CheckPages();
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
local begin
  vTxtHdl : int;
end;
begin

// Sprache 1
  vTxtHdl # $edTxt_lang1->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // Sprache 2
  vTxtHdl # $edTxt_lang2->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // Sprache 3
  vTxtHdl # $edTxt_lang3->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // Sprache 4
  vTxtHdl # $edTxt_lang4->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // Sprache 5
  vTxtHdl # $edTxt_lang5->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // ALL
  vTxtHdl # $edTxt_all->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  // RTF
  vTxtHdl # $Txt.RTF->wpdbTextBuf;
  if (vTxtHdl<>0) then
    TextClose(vTxtHdl);

  RETURN true;
end;

//========================================================================
//  JumpTo
//      Schnellsprung in andere Verwaltung duch Mittlere-Maustaste auf RecList-Spalte
//========================================================================
sub JumpTo(
  aName : alpha;
  aBuf  : int);
begin

  if ((aName =^ 'edTxt.bei.Gtenstufe') AND (aBuf->"Txt.bei.Gütenstufe"<>'')) then begin
    MQu.S.Stufe # "Txt.bei.Gütenstufe";
    RecRead(848,1,0);
    Lib_Guicom2:JumpToWindow('MQu.S.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edTxt.bei.Gte') AND (aBuf->"Txt.bei.Güte"<>'')) then begin
    "MQu.Güte1" # "Txt.bei.Güte";
    RecRead(832,2,0);
    Lib_Guicom2:JumpToWindow('MQu.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edTxt.bei.Warengruppe') AND (aBuf->Txt.bei.Warengruppe<>0)) then begin
    RekLink(819,837,1,0);   // Warengruppe holen
    Lib_Guicom2:JumpToWindow('Wgr.Verwaltung');
    RETURN;
  end;
  
  if ((aName =^ 'edTxt.bei.Adressnr') AND (aBuf->Txt.bei.Adressnr<>0)) then begin
    RekLink(100,837,2,0);   // Adresse holen
    Lib_Guicom2:JumpToWindow('Adr.Verwaltung');
    RETURN;
  end;

end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================