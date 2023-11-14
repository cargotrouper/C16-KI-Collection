@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rso_Wrt_Main
//                  OHNE E_R_G
//
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  05.01.2004  FR  Neuer Menüpunkt: Mnu.WrtKopieren
//  13.04.2004  FR  Löschprozedur für untergeordnete Datensätze: DeleteIHA()
//  04.02.2022  AH  ERX
//
//  Subprozeduren
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
//    SUB EvtLstDataInit(aEvt : event; aRecid : int);
//    SUB EvtLstSelect(aEvt : event; aRecid : int);
//    SUB EvtClose(aEvt : event) : logic
//    SUB WartungKopieren()
//    SUB Pflichtfelder();
//    SUB DeleteIHA()
//
//
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  cTitle :    'Wartungen'
  cFile :     165
  cMenuName : 'Rso.Wrt.Bearbeiten'
  cPrefix :   'Rso_Wrt'
  cZList :    $ZL.Rso.Wrt
  cKey :      1

  cDokumente : '*.doc;*.xls;*.txt;*.pdf;*.rtf'
end;

declare WartungKopieren();
declare Pflichtfelder();
declare DeleteIHA();

local begin
  vResult : logic;
  vDatum1 : date;
  vDatum2 : date;
  vCount  : int;
  vWochen : int;
  vPuffer : int;
  vFlags  : int;
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

  SetStdAusFeld('edXXXXX', '');

  $Lb.Ressource       -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname  -> wpcaption # Rso.Bezeichnung1;
  $Lb.Ressource2      -> wpcaption # AInt(Rso.Nummer);
  $Lb.Ressourcenname2 -> wpcaption # Rso.Bezeichnung1;

  App_Main:EvtInit(aEvt);
end;


//========================================================================
//  RefreshIfm
//            "Infomasken" refreshen
//========================================================================
sub RefreshIfm(
  opt aName : alpha;
)
local begin
  vTmp  : int;
end;
begin

  if (aName='') then begin
    $Lb.Nummer2         -> wpcaption # aint(Rso.Iha.Nummer);
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
//  RecInit
//          Init für Änderung und Neuanlage
//========================================================================
sub RecInit()
local begin
  vNr : int;
end;
begin
  // Felder Disablen durch:
  //Lib_GuiCom:Disable($...);
  if (Mode=c_ModeNew) then begin
    /*RecRead(165,1,_Reclast);
    vNr # Rso.IHA.Nummer + 1; */

    vNr # Lib_Nummern:ReadNummer('Instandhaltungen');
    if (vNr <> 0) then Lib_Nummern:SaveNummer();
    else Debug('Reservierung fehlgeschlagen');

    RecBufClear(165);
    Rso.IHA.Gruppe      # Rso.Gruppe;
    Rso.IHA.Ressource   # Rso.Nummer;
    Rso.IHA.Nummer      # vNr;
    Rso.IHA.WartungYN   # True;
  end;

  // Focus setzen auf Feld:
  $edRso.IHA.Termin->WinFocusSet(true);

end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave() : logic;
local begin
  Erx : int;
end;
begin
  // dynamische Pflichtfelder überprüfen
  if ( !Lib_Pflichtfelder:PflichtfelderPruefenVorSpeichern() ) then
    RETURN false;

  // logische Prüfung
  // Nummernvergabe
  // Satz zurückspeichern & protokolieren
  if (Mode=c_ModeEdit) then begin
    Erx # RekReplace(gFile,_RecUnlock,'MAN');
    if (Erx<>_rOk) then begin
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN False;
    end;
    PtD_Main:Compare(gFile);
  end
  else begin
    REPEAT
      Erx # RekInsert(gFile,0,'MAN');
      if (Erx<>_rOK) then
        Rso.IHA.Nummer # Rso.IHA.Nummer + 1;
    UNTIl (Erx=_rOk);
  end;

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
  Erx : int;
end;
begin
  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;

  Erx # Msg(165000,'',4,2,1);
  if (Erx = _WinIdOk) then begin
    DeleteIHA();   // löscht untergeordnete Datensätze
    RekDelete(gFile,0,'MAN');
  end;

  Erx # RecRead(165,1,1); // Für Zugriffsliste
  if (Erx > _rLocked) then
    RecBufClear(165);
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
local begin
  vKW   : word;
  vJahr : word;
end;
begin

  // logische Prüfung von Verknüpfungen
  RefreshIfm(aEvt:Obj->wpName);

  if (aFocusObject=0) then RETURN true;

  if (aEvt:Obj->wpname='edRso.IHA.Termin') then begin
    if (Rso.IHA.Termin<>0.0.0) then begin
      vKW # Rso.IHA.TerminKW;
      vJahr # Rso.IHA.TerminJahr;
      Lib_Berechnungen:KW_aus_Datum(Rso.IHA.Termin, var vKW, var vJahr);
      Rso.IHA.TerminKW # vKW;
      Rso.IHA.TerminJahr # vJahr;
      RefreshIfm('edRso.IHA.TerminKW');
      RefreshIfm('edRso.IHA.TerminJahr');
    end;

    if (Rso.IHA.Termin=0.0.0) then begin
      Lib_GuiCom:Enable($edRso.IHA.TerminKW);
      Lib_GuiCom:Enable($edRso.IHA.TerminJahr);
      if (aFocusObject->wpname='edRso.IHA.DatumEnde') then begin
        $edRso.IHA.TerminKW->winfocusset(true);
      end;
    end
    else begin
      Lib_GuiCom:Disable($edRso.IHA.TerminKW);
      Lib_GuiCom:Disable($edRso.IHA.TerminJahr);
      if (aFocusObject->wpname='edRso.IHA.TerminKW') or
        (aFocusObject->wpname='edRso.IHA.TerminKW') then begin
        $edRso.IHA.DatumEnde->winfocusset(true);
      end;
    end
  end;

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
  Erx   : int;
  vParent : int;
  vA    : alpha;
  vMode : alpha;
  vTmp  : int;
end;
begin

  case aBereich of

    'Dokument' : begin
      vTmp # WinOpen(_WinComFileopen,_WinOpenDialog);
      if (vTmp<>0) then begin
        vTmp->wpFileFilter # 'Dokumente|' + cDokumente  + '|Alle Dateien|*.*';
        Erx # vTmp;
        if (vTmp->WinDialogRun(_WinDialogCenter,gMdi) = _rOK) then begin
          Rso.IHA.externesDok # StrAdj(Erx->wpPathname+ Erx->wpFileName,_StrEnd);
          $edRso.IHA.externesDok->wpcaption # Rso.IHA.externesDok;
          RefreshIfm('edRso.IHA.externesDok');
        end;
        WinClose(Erx);
      end;
    end;

  end;

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

  $Rso.Wrt.Verwaltung->wpVisible # true; // Einblenden

  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Anlegen]=n);
  vHdl # gMenu->WinSearch('Mnu.New');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Anlegen]=n);

  vHdl # gMdi->WinSearch('Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Aendern]=n);
  vHdl # gMenu->WinSearch('Mnu.Edit');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Aendern]=n);

  vHdl # gMdi->WinSearch('Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Loeschen]=n);
  vHdl # gMenu->WinSearch('Mnu.Delete');
  if (vHdl <> 0) then
    vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_Rso_Wrt_Loeschen]=n);

  // Deaktivieren, wenn keine Wartungen vorhanden sind
/***
  Rso.IHA.Gruppe # Rso.Gruppe;
  Rso.IHA.Ressource # Rso.Nummer;
  Rso.IHA.WartungYN # true;
***/

  if (RecRead(165,1,_RecTest) >= _rNoKey) then begin
    vHdl # gMenu->WinSearch('Mnu.WrtKopieren');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;

    vHdl # gMenu->WinSearch('Mnu.Ursachen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # true;
  end
  else begin
    vHdl # gMenu->WinSearch('Mnu.WrtKopieren');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;

    vHdl # gMenu->WinSearch('Mnu.Ursachen');
    if (vHdl <> 0) then
      vHdl->wpDisabled # false;
  end;

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
  vFilter : int;
  vTmp    : int;
  vQ      : alpha(4000);
end;
begin

  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);
  case (aMenuItem->wpName) of

    'Mnu.Ursachen' : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Urs.Verwaltung','',y);
      RecBufClear(824);
/***
      vFilter # RecFilterCreate(166,1);
      vFilter->RecFilterAdd(1,_FltAND,_FltEq,Rso.IHA.Gruppe);
      vFilter->RecFilterAdd(2,_FltAND,_FltEq,Rso.IHA.Ressource);
      vFilter->RecFilterAdd(3,_FltAND,_FltEq,Rso.IHA.WartungYN);
      vFilter->RecFilterAdd(4,_FltAND,_FltEq,Rso.IHA.Nummer);
      $ZL.Rso.Ursachen->wpDbFilter # vFilter;
***/
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      vQ # '';
      Lib_Sel:QInt(var vQ, 'Rso.Urs.Gruppe', '=', Rso.IHA.Gruppe);
      Lib_Sel:QInt(var vQ, 'Rso.Urs.Ressource', '=', Rso.IHA.Ressource);
      Lib_Sel:QLogic(var vQ, 'Rso.Urs.WartungYN', Rso.IHA.WartungYN);
      Lib_Sel:QInt(var vQ, 'Rso.Urs.IHA', '=', Rso.IHA.Nummer);
      vHdl # SelCreate(166, 1);
      Erx # vHdl->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vHdl);
      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Mnu.WrtKopieren' : begin
      // Nur zulassen, wenn IHA vorhanden ist
      if(Rso.IHA.Nummer <> 0) then
        WartungKopieren();
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

  if (Mode=c_ModeView) then RETURN true;

  case (aEvt:Obj->wpName) of
    'bt.Dokument' :   Auswahl('Dokument');
  end;

end;


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
//  App_Main:Refreshmode();
end;


//========================================================================
//  EvtLstSelect
//
//========================================================================
sub EvtLstSelect(
                        aEvt      : event;
                        aRecid    : int;
                   ) : logic;
begin
//  RecRead(165,1,0);
  if (arecid=0) then RETURN true;
  RecRead(gFile,0,_recid,aRecID);
  RefreshMode(y);
//  App_Main:Refreshmode();    // Aktivieren/Deaktivieren von Datansatzabhängigen Menüpunkten
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


//========================================================================
// WartungKopieren
//          Kopiert Wartung auf Zeitraum
//========================================================================
sub WartungKopieren ()
local begin
  Erx     : int;
  vIHANum : int;  // Für Nummernkreisreservierungend;
  vUrsNum : int;
  vMasNum : int;
  vErtNum : int;
  vRsoNum : int;

  vGruppe     : word; // Schlüsselfelder zum Auslagern
  vRessource  : word;
  vIHA        : word;
  vURS        : word;
  vMAS        : word;
  vERT        : word;
  vRSO        : word;

  vKw         : word; // Zur Berechnung von KW/Jahr
  vJahr       : word;
end;
begin
  vResult # Dlg_Standard:DatumVonBis('Bitte Zeitraum für Wartungen eingeben',var vDatum2,var vDatum1,Rso.IHA.Termin,Rso.IHA.Termin);
  if (vResult) then
    vResult # Dlg_Standard:Anzahl('In welchem wöchentlichen Abstand sollen die Kopien angelegt werden?',var vWochen, 1);

  if (vResult) then begin
    // Debug(CnvAD(vDatum1) + ' - ' + CnvAI(vWochen));

    vDatum2 # CnvDI(CnvID(vDatum2) + vWochen*7); // nicht auf erstes Datum kopieren

    FOR  vDatum2 # vDatum2
    LOOP vDatum2 # CnvDI(CnvID(vDatum2) + vWochen*7)
    WHILE (CnvID(vDatum2) <= CnvID(vDatum1)) DO  BEGIN

      vIHANum #  Lib_Nummern:ReadNummer('Instandhaltungen');
      if (vIHANum <> 0) then
        Lib_Nummern:SaveNummer()
      else begin
        Debug('Reservierung fehlgeschlagen');
        BREAK;
      end;

      vFlags # _recFirst;
      WHILE (RecLink(166,165,1,vFlags) <= _rLocked) DO BEGIN
        vUrsNum #  Lib_Nummern:ReadNummer('Ursachen');
        if (vUrsNum <> 0) then
          Lib_Nummern:SaveNummer()
        else begin
          Debug('Reservierung fehlgeschlagen');
          BREAK;
        end;

        vFlags # _recFirst;
        WHILE (RecLink(167,166,1,vFlags) <= _rLocked) DO BEGIN
          vMasNum #  Lib_Nummern:ReadNummer('Massnahmen');
          if (vMasNum <> 0) then
            Lib_Nummern:SaveNummer()
          else begin
            Debug('Reservierung fehlgeschlagen');
            BREAK;
          end;

          vFlags # _recFirst;
          WHILE (RecLink(168,167,1,vFlags) <= _rLocked) DO BEGIN
            vErtNum #  Lib_Nummern:ReadNummer('Ersatzteile');
            if (vErtNum <> 0) then
              Lib_Nummern:SaveNummer()
            else begin
              Debug('Reservierung fehlgeschlagen');
              BREAK;
            end;

            vGruppe           # Rso.ErT.Gruppe;
            vRessource        # Rso.ErT.Ressource;
            vIHA              # Rso.ErT.IHA;
            vURS              # Rso.ErT.Ursache;
            vMAS              # "Rso.ErT.Maßnahme";
            vERT              # Rso.ErT.Nummer;

            Rso.ErT.Gruppe    # Rso.IHA.Gruppe;
            Rso.ErT.Ressource # Rso.IHA.Ressource;
            Rso.ErT.WartungYN # true;   // Nur Wartungen können kopiert werden!
            Rso.ErT.IHA       # vIHANum;
            Rso.ErT.Ursache   # vUrsNum;
           "Rso.ErT.Maßnahme" # vMasNum;
            Rso.ErT.Nummer    # vErtNum;

            RekInsert(168,0,'MAN');


            Rso.ErT.Gruppe    # vGruppe;
            Rso.ErT.Ressource # vRessource;
            Rso.ErT.WartungYN # true;
            Rso.ErT.IHA       # vIHA;
            Rso.ErT.Ursache   # vURS;
           "Rso.ErT.Maßnahme" # vMAS;
            Rso.ErT.Nummer    # vERT;

            vFlags # _recNext;
          END;

          vFlags # _recFirst;
          WHILE (RecLink(169,167,2,vFlags) <= _rLocked) DO BEGIN
            vRsoNum #  Lib_Nummern:ReadNummer('Ressourcen');
            if (vRsoNum <> 0) then
              Lib_Nummern:SaveNummer()
            else begin
              Debug('Reservierung fehlgeschlagen');
              BREAK;
            end;

            vGruppe           # Rso.Rso.Gruppe;
            vRessource        # Rso.Rso.Ressource;
            vIHA              # Rso.Rso.IHA;
            vURS              # Rso.Rso.Ursache;
            vMAS              # "Rso.Rso.Maßnahme";
            vRso              # Rso.Rso.Nummer;

            Rso.Rso.Gruppe    # Rso.IHA.Gruppe;
            Rso.Rso.Ressource # Rso.IHA.Ressource;
            Rso.Rso.WartungYN # true;   // Nur Wartungen können kopiert werden!
            Rso.Rso.IHA       # vIHANum;
            Rso.Rso.Ursache   # vUrsNum;
           "Rso.Rso.Maßnahme" # vMasNum;
            Rso.Rso.Nummer    # vRsoNum;

            RekInsert(169,0,'MAN');


            Rso.Rso.Gruppe    # vGruppe;
            Rso.Rso.Ressource # vRessource;
            Rso.Rso.WartungYN # true;
            Rso.Rso.IHA       # vIHA;
            Rso.Rso.Ursache   # vURS;
           "Rso.Rso.Maßnahme" # vMAS;
            Rso.Rso.Nummer    # vRSO;

            vFlags # _recNext;
          END;

          vGruppe           # "Rso.Maß.Gruppe";
          vRessource        # "Rso.Maß.Ressource";
          vIHA              # "Rso.Maß.IHA";
          vURS              # "Rso.Maß.Ursache";
          vMAS              # "Rso.Maß.Nummer";

          "Rso.Maß.Gruppe"   # Rso.IHA.Gruppe;
          "Rso.Maß.Ressource"# Rso.IHA.Ressource;
          "Rso.Maß.WartungYN"# true;   // Nur Wartungen können kopiert werden!
          "Rso.Maß.IHA"      # vIHANum;
          "Rso.Maß.Ursache"  # vUrsNum;
          "Rso.Maß.Nummer"   # vMasNum;

          RekInsert(167,0,'MAN');

          //Debug('Insert MAß: '  + CnvAI(vMasNum) + ' '  + CnvAI("Rso.Maß.Ursache") + ' ' + CnvAI("Rso.Maß.IHA") + ' ' + CnvAI("Rso.Maß.Ressource") + ' ' + CnvAI("Rso.ErT.Gruppe"));

          "Rso.Maß.Gruppe"   # vGruppe;
          "Rso.Maß.Ressource"# vRessource;
          "Rso.Maß.WartungYN"# true;
          "Rso.Maß.IHA"      # vIHA;
          "Rso.Maß.Ursache"  # vURS;
          "Rso.Maß.Nummer"   # vMAS;

          vFlags # _recNext;
        END;

        vGruppe           # Rso.Urs.Gruppe;
        vRessource        # Rso.Urs.Ressource;
        vIHA              # Rso.Urs.IHA;
        vURS              # Rso.Urs.Nummer;

        Rso.Urs.Gruppe    # Rso.IHA.Gruppe;
        Rso.Urs.Ressource # Rso.IHA.Ressource;
        Rso.Urs.WartungYN # true;   // Nur Wartungen können kopiert werden!
        Rso.Urs.IHA       # vIHANum;
        Rso.Urs.Nummer    # vUrsNum;

        RekInsert(166,0,'MAN');

        //Debug('Insert URS: '  + CnvAI(vUrsNum) + ' ' + CnvAI(Rso.Urs.IHA) + ' ' + CnvAI(Rso.Urs.Ressource) + ' ' + CnvAI(Rso.Urs.Gruppe));

        Rso.Urs.Gruppe    # vGruppe;
        Rso.Urs.Ressource # vRessource;
        Rso.Urs.WartungYN # true;
        Rso.Urs.IHA       # vIHA;
        Rso.Urs.Nummer    # vURS;

        vFlags # _recNext;
      END;

      Rso.IHA.DatumEnde # CnvDI(CnvID(vDatum2) + (CnvID(Rso.IHA.DatumEnde) - CnvID(Rso.IHA.Termin)));
      Rso.IHA.Termin # vDatum2;
      Lib_Berechnungen:KW_aus_Datum(vDatum2,var vKW,var vJahr);
      Rso.IHA.TerminKW # vKw;
      Rso.IHA.TerminJahr # vJahr;

      Rso.IHA.Nummer # vIHANum;

      //Debug('Insert IHA: ' + CnvAI(vIHANum));

      RekInsert(165,0,'MAN');
    END;
  end;
  Erx # RecRead(165,1,1); // Für Zugriffsliste

end;


//========================================================================
// Pflichtfelder
//              Färbt Pflichtfelder richtig ein
//========================================================================
sub Pflichtfelder();
begin
  if (Mode<>c_ModeNew) and (Mode<>c_ModeEdit) then RETURN;

  // Pflichtfelder
  // Lib_GuiCom:Pflichtfeld($ed...);
end;


//========================================================================
//  DeleteIHA
//      Löscht Datensätze unter IHA
//========================================================================
sub DeleteIHA()
begin
  vFlags # _recFirst;
  WHILE (RecLink(166,165,1,vFlags) <= _rLocked) DO BEGIN

    vFlags # _recFirst;
    WHILE (RecLink(167,166,1,vFlags) <= _rLocked) DO BEGIN

      vFlags # _recFirst;
      WHILE (RecLink(168,167,1,vFlags) <= _rLocked) DO BEGIN
        HuB_Data:MengenBewegung(Rso.ErT.Artikelnr,Rso.ErT.Menge,'IHA:'+AInt(Rso.ErT.IHA)+'/'+AInt(Rso.ErT.Ursache)+'/'+AInt("Rso.ErT.Maßnahme")+'/'+AInt(Rso.ErT.Nummer)+' Zuteilung gelöscht')
        RekDelete(168,0,'MAN');
        vFlags # _recNext;
      END;

      vFlags # _recFirst;
      WHILE (RecLink(169,167,2,vFlags) <= _rLocked) DO BEGIN
        RekDelete(169,0,'MAN');
        vFlags # _recNext;
      END;
      RekDelete(167,0,'MAN');
      vFlags # _recNext;
    END;
    RekDelete(166,0,'MAN');
    vFlags # _recNext;
  END;
end;

//========================================================================
//========================================================================
//========================================================================
//========================================================================