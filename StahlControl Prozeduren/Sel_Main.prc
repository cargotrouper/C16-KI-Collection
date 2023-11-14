@A+
//===== Business-Control =================================================
//
//  Prozedur    Sel_Main
//                  OHNE E_R_G
//  Info        Routinen für die Selektionsmasken
//
//
//  28.03.2004  AI  Erstellung der Prozedur
//  26.03.2008  ST  "Land" hinzugefügt
//  12.03.2009  ST  "Gütenstufe" hinzugefügt
//  20.10.2009  MS  "Versandart" hinzugefügt
//  21.10.2009  MS  "Lagerplatz" hinzugefügt
//  01.03.2010  ST  "Kostenstelle" hinzugefügt
//  25.03.2010  ST  "Gruppe" hinzugefügt
//  21.09.2010  MS  "Zeugnisse" hinzugefügt
//  10.03.2011  MS  Erweiterung um Angabe eines 2 Wertes im Curstomfeld durch ; getrennt
//  11.12.2014  AH  Erweitert für Kombidialog
//  01.03.2015  AH  "Filter_stop" verspringt optional RecId nicht
//  04.03.2015  AH  Bugfix: "TemTyp" kann gewählt werden
//  15.03.2016  AH  "Gegenkonto" + "Kostenkopf" hinzugefügt
//  30.09.2016  AH  "SaveCaptions2XML" prüft Endung
//  16.03.2017  AH  HuB
//  08.11.2017  AH  "EvtMenuCommand" mit aGateway, zum Umbiegen von Commands (z.B. Ricken-Spalten)
//  05.03.2020  TM  "RechnungsTyp" hinzugefügt
//  03.04.2020  AH  "BDS" hinzugefügt
//  09.07.2020  AH  für Material: Artikel/Struktur-Auswal
//  14.04.2021  AH  2. Selektion
//  06.07.2021  AH  Mehrere Güten + Obfs
//  27.07.2021  AH  ERX
//  07.10.2021  AH  AFX "Sel.Spezial"
//
//  Subprozeduren
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB OkPressed(aHdl : int);
//    SUB Auswahl(aBereich : alpha)
//    SUB GetReference(aHdl : int; aUebernehmen : logic) : logic;
//    SUB InnerRedrawInfo(aObj : int; aUebernehmen : logic)
//    SUB RedrawInfo(optaUebernehmen : logic);
//    SUB AusFeld()
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObj : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB EvtTerm(aEvt : event) : logic
//
//    SUB SaveCaptions2XML(aWin : int) : logic
//    SUB LoadXML2Captions(aWin : int) : logic
//
//    SUB Filter_stop(opt aID : int);
//    SUB AddSort(aMDI : int; aSortDL : int; aName : alpha; opt aSort : alpha; opt aDefault : logic);
//
//========================================================================
@I:Def_Global

define begin
  cMenuName : 'Sel.Dialog'
  cPrefix :   'Sel'
//  cZList :    $ZL.Abteilungen
//  cKey :      1

  // XML Schreiben
  XML_NodeA(a,b,c)    : Lib_XML:NewNode(a,b,c)
  XML_NodeI(a,b,c)    : Lib_XML:NewNode(a,b, cnvai(c,_FmtNumNoGroup))
  XML_NodeF(a,b,c)    : Lib_XML:NewNode(a,b, cnvaF(c,_FmtNumNoGroup|_FmtNumPoint,0,2))
  XML_NodeB(a,b,c)    : Lib_XML:NewNodeB(a,b,c)
  XML_NodeD(a,b,c)    : Lib_XML:NewNodeD(a,b,c)
  XML_NodeT(a,b,c)    : Lib_XML:NewNode(a,b, cnvat(c,_FmtTimeSeconds))

  // XML Lesen
  XML_GetNodeType(a)  : Lib_XML:GetNodeType(a)
  XML_GetValA(a,b)    : Lib_XML:GetValue(a,b);
  XML_GetValI(a,b)    : Lib_XML:GetValueI(a,b);
  XML_GetValI16(a,b)  : Lib_XML:GetValueI16(a,b);
  XML_GetValF(a,b)    : Lib_XML:GetValueF(a,b);
  XML_GetValB(a,b)    : Lib_XML:GetValueB(a,b);
  XML_GetValD(a,b)    : Lib_XML:GetValueD(a,b);
  XML_GetValT(a,b)    : Lib_XML:GetValueT(a,b);

end;

LOCAL begin
  d_X         : int;
  d_text      : int;
  d_frame     : int;
  d_Button    : int;
  d_MenuItem  : int;
end;

declare RedrawInfo(opt aUebernehmen : logic);
declare GetReference(aHdl : int; aUebernehmen : logic);
declare SaveCaptions2XML(aWin : int; aFileName : alpha(1000)) : logic;
declare LoadXML2Captions(aWin : int; aFileName : alpha(1000)) : logic;
declare AusFeld()

//========================================================================
//  EvtMdiActivate
//                  Fenster aktivieren
//========================================================================
sub EvtMdiActivate(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vFilter : int;
  vHdl : int;

  tObj : int;
end;
begin

  // Vorbelegung??
  if ($bt.ok->wpcustom<>'') and ($bt.ok->wpcustom <> $bt.Abbruch->wpcustom) then begin
    Sel_Main:LoadXML2Captions(0,$bt.ok->wpcustom);
    aEvt:obj->winupdate();
    $bt.Abbruch->wpcustom # $bt.ok->wpcustom;
  end;

  gZLList # 0;
  vHdl # w_lastfocus;

  Call('App_Main:EvtMdiActivate',aEvt);

  w_lastfocus # vHdl;
  GV.Alpha.01 # '';
  if (vHdl=0) then
     RedrawInfo(n);

end;


//========================================================================
//  OkPressed
//
//========================================================================
Sub OkPressed(aHdl : int);
local begin
  vI      : int;
  vSortDL : int;
  vSort   : int;
  vJ      : int;
  vA, vB  : alpha(4096);
  vHdl    : int;
end;
begin

  if (aHdl<>0) then begin
    if (aHdl->wpcustom<>'') then begin
      vI # cnvia(aHdl->wpcustom);
      if (vI>10) then
        Sel_Main:SaveCaptions2XML(gMdi,$bt.Ok->wpcustom);
    end;
  end;


  // neues Kombifenster mit Sort?
  vSortDL # Winsearch(gMDI, 'dlSort');
  if (vSortDL<>0) then begin
    vSort # Winsearch(gMDI, 'edSort');
    if (vSort<>0) then begin

      // XML-Pfad testen
      vHdl # gMDI->Winsearch('edXML');
      if (vHdl<>0) then begin
        vA # vHdl->wpcaption;
        if (vA<>'') then begin
          if ( StrCnv( StrCut( vA, StrLen(vA) - 3, 4 ), _strLower ) != '.xml' ) then
            vA # va + '.xml';
          // Datei testen
          vHdl # FsiOpen( vA, _fsiAcsRW | _fsiDenyRW | _fsiCreate );
          if ( vHdl > 0 ) then begin
            vHdl->FsiClose();
          end
          else begin
            Msg( 910004, vA, 0, 0, 0 );
            RETURN;
          end;
        end;
        list_FileName  # vA;
      end;

      // Sortierung bestimmen
      Sel.Sortierung # '';
      vA # vSort->wpcaption;
      vJ # WinLstDatLineInfo(vSortDL, _WinLstDatInfoCount);
      FOR vI # 1
      LOOP inc(vI)
      WHILE (vI<=vJ) do begin
        WinlstCellGet(vSortDl, vB, 1, vI);
        if (vA=vB) then begin
          WinlstCellGet(vSortDl, vB, 2, vI);
          Sel.Sortierung # vB;
          BREAK;
        end;
      END;
    end;
  end;

  gSelected # 1;
end;


//========================================================================
//  Auswahl
//          Auswahliste öffnen
//========================================================================
sub Auswahl(
  aBereich  : alpha;
)
local begin
  Erx     : int;
  vA      : alpha;
  vHdl    : int;
  vHdl2   : int;
  vFilter : int;
  vSel    : alpha;
  vName   : alpha(500);
  vQ      : alpha(4000);
  vI      : int;
  vText   : alpha;
end;

begin

  vHdl # w_lastFocus;

  case aBereich of

    'BDS' : begin
      RecBufClear(836);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BDS.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Zeugnisse' : begin
      RecBufClear(839);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Zeu.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Lagerplatz' : begin
      RecBufClear(844);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'LPl.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Versandart' : begin
      RecBufClear(817);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'VsA.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Filename' : begin
      vName # Str_token(vHdl->wpcustom,';',2);
      vName # Lib_FileIO:FileIO(_WinComFileOpen, gMDI, vHdl->wpcaption, vName);
      vHdl->wpcaption # vName;
    end;


    'BAAktion' : begin
      RecBufClear(828);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ArG.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'ResGruppe' : begin
      RecBufClear(822);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Grp.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Ressource' : begin
      RecBufClear(160);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Rso.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Artikeltyp' : begin
      vHdl # w_LastFocus;
      vA # GV.Alpha.01;                 // Auswahl temp. in Gv.Alpha.01 speichern
      Lib_Einheiten:Popup('ARTIKELTYP',vHdl,999,1,1);
      if (Gv.Alpha.01<>'') then begin
        FldDefbyname(vHdl->wpDBFieldname,Gv.Alpha.01);
        vHdl->winupdate(_WinUpdFld2Obj);
      end;
      GV.Alpha.01 # vA;
    end;


    'Projekt' : begin
      RecBufClear(120);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Auftrag' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vorgangstyp' : begin
      vHdl # w_LastFocus;
      vA # GV.Alpha.01;                 // Auswahl temp. in Gv.Alpha.01 speichern
      Lib_Einheiten:Popup('Vorgangstyp',vHdl,999,1,1);
      if (Gv.Alpha.01<>'') then begin
        FldDefbyname(vHdl->wpDBFieldname,Gv.Alpha.01);
        vHdl->winupdate(_WinUpdFld2Obj);
      end;
      GV.Alpha.01 # vA;
    end;


    'Kommission' : begin
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Agr' : begin
      RecBufClear(826);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Agr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Adresse' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 4;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Kunde' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 4;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Lieferant', 'Lagerort' : begin
      RecBufClear(100);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 4;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Lageranschrift' : begin
//      RecLink(101,100,12,1);     // Lieferadresse holen
      RecBufClear(101);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Adr.A.Verwaltung', here + ':AusFeld');
      w_lastFocus # vHdl;

      if(Adr.Nummer <> 0) then begin // keine Adr. ausgewaehlt? Alle Anschriften anzeigen!
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

        vQ # '';
        Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
        vHdl # SelCreate(101, 1);
        erx # vHdl->SelDefQuery('', vQ);
        if (erx <> 0) then
          Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;
      end;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;



    'Vorgangsart' : begin
      RecBufClear(835);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'AAr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Wgr' : begin
      RecBufClear(819);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Wgr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Vertreter' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Verband' : begin
      RecBufClear(110);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Ver.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Gruppe' : begin
      RecBufClear(810);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Grp.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'HuB' : begin
      RecBufClear(180);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'HuB.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 1;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Artikelnr' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 1;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Charge' : begin
      RecBufClear(252);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.C.Verwaltung',here+':AusFeld');

      // Echte Charge auswählen?
//      if ("Art.ChargenführungYN") then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
/**
        vFilter # RecFilterCreate(252,1);
        vFilter->RecFilterAdd(1,_FltAND,_FltEq,Art.Nummer);
        vFilter->RecFilterAdd(2,_FltAND,_FltAbove,0);
        vFilter->RecFilterAdd(4,_FltAND,_FltAbove,'');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gZLList->wpDbFilter # vFilter;
        gkey # 1;
**/
        vQ # '';
        Lib_Sel:QAlpha(var vQ, 'Art.C.ArtikelNr'      , '=', Art.Nummer);
        Lib_Sel:QInt(var vQ, 'Art.C.Adressnr'         , '>', 0);
        Lib_Sel:QAlpha(var vQ, 'Art.C.Charge.Intern'  , '>', '');
        Lib_Sel:QDate(var vQ, 'Art.C.Ausgangsdatum'   , '=', 0.0.0);
        vHdl # SelCreate(252, gKey);
        erx # vHdl->SelDefQuery('', vQ);
        if (erx != 0) then Lib_Sel:QError(vHdl);
        // speichern, starten und Name merken...
        w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
        // Liste selektieren...
        gZLList->wpDbSelection # vHdl;

/*
      end
      else begin  // nur Lagerortchargen...
        vFilter # RecFilterCreate(252,1);
        vFilter->RecFilterAdd(1,_FltAND,_FltEq,Art.Nummer);
        vFilter->RecFilterAdd(2,_FltAND,_FltAbove,0);
        vFilter->RecFilterAdd(4,_FltAND,_FltEq,'');
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        gZLList->wpDbFilter # vFilter;
        gkey # 1;
      end;
*/
//      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
//      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//      gKey # 1;
//      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Artikelstichwort' : begin
      RecBufClear(250);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Art.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      gKey # 1;
      Lib_GuiCom:ZLSetSort(gKey);
    end;


    'Strukturnr' : begin
      RecBufClear(220);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MSL.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'User' : begin
      RecBufClear(800);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Status' : begin
      RecBufClear(820);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mst.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Güte' : begin
      RecBufClear(832);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Werkstoffnr' : begin
      RecBufClear(832);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Gütenstufe' : begin
      RecBufClear(848);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'MQu.S.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Obfs', 'Oberfläche' : begin
      RecBufClear(841);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Obf.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Steuerschluessel' : begin
      RecBufClear(813);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'StS.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Land' : begin
      RecBufClear(812);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Lnd.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenstelle' : begin
      RecBufClear(846);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'KSt.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Gegenkonto' : begin
      RecBufClear(854);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'GKo.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'Kostenkopf' : begin
      RecBufClear(580);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Kos.K.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'PLZ' : begin
      RecBufClear(847);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Ort.Verwaltung', here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'TemTyp' : begin
      RecBufClear(857);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'TTy.Verwaltung', here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
/***
      w_lastFocus # vHdl;
      TeM.Typ # Lib_Einheiten:Popup('Termintyp',0,0,0,0);
      gSelected # Lib_Termine:GetTypeNummer(Tem.Typ);
      Ausfeld();
***/
    end;


    'RekArt' : begin
      RecBufClear(849);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Rek.Art.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'RekStatus' : begin
      RecBufClear(850);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'VgSt.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;


    'RekFehlercode' : begin
      RecBufClear(851);
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'FhC.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
    
    
    'RechnungsTyp' : begin
      RecBufClear(853);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'RTy.Verwaltung',here+':AusFeld');
      w_lastFocus # vHdl;
      Lib_GuiCom:RunChildWindow(gMDI);
    end;

    otherwise RunAfx('Sel.Spezial','Auswahl|'+aBereich);
   
  end;

end;


//========================================================================
//  GetReference
//              holt zu einem Felddeskriptor den gelinkten Datensatz
//              und übernimmt ggf. den Inhalt in das Feld zurück
//========================================================================
sub GetReference(
  aHdl          : int;
  aUebernehmen  : logic);
local begin
  Erx     : int;
  vTyp    : alpha;
  vA,vB   : alpha;
  vX      : int;
  vN1,vN2 : int;
  vW      : int;
  vHdl    : int;
end;
begin

  vTyp # Str_Token(aHdl->wpcustom, ';', 1);

  if (vTyp='Strukturnr/Artikel/A') then vTyp # 'Artikelnr'
  else if (vTyp='Strukturnr/Artikel/S') then vTyp # 'Strukturnr';

 
  case vTyp of

    'Zeugnisse': begin
      if (gSelected<>0) then begin
        erx # RecRead(839,0,_RecId,gSelected);
      end
      else begin
        Zeu.Nummer # aHdl->wpcaptionint;
        if (Zeu.Nummer<>0) then
          erx # RecRead(839,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(839);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Zeu.Bezeichnung);
    end;

    'Versandart': begin
      if (gSelected<>0) then begin
        erx # RecRead(817,0,_RecId,gSelected);
      end
      else begin
        VsA.Nummer # aHdl->wpcaptionint;
        if (VsA.Nummer<>0) then
          erx # RecRead(817,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(817);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, VsA.Nummer);
    end;


    'Lagerplatz': begin
      if (gSelected<>0) then begin
        erx # RecRead(844,0,_RecId,gSelected);
      end
      else begin
        Lpl.Lagerplatz # aHdl->wpcaption;
        if (Lpl.Lagerplatz <> '') then
          erx # RecRead(844,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(817);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Lpl.Lagerplatz);
    end;


    'BAAktion': begin
      if (gSelected<>0) then begin
        erx # RecRead(828,0,_RecId,gSelected);
      end
      else begin
        ArG.Aktion2 # aHdl->wpcaption;
        if (ArG.Aktion2<>'') then
          erx # RecRead(828,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(828);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, ArG.Aktion2);
    end;


    'ResGruppe': begin
      if (gSelected<>0) then begin
        erx # RecRead(822,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Rso.Grp.Nummer # vW;
        if (Rso.Grp.Nummer<>0) then
          erx # RecRead(822,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(822);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Rso.Grp.Nummer);
    end;


    'Ressource': begin
      vX # Winsearch(gMDI,'edSel.BAG.Res.Gruppe');
      if (gSelected<>0) then begin
        erx # RecRead(160,0,_RecId,gSelected);
      end
      else begin
        if (vX<>0) then Rso.Gruppe # vX->wpcaptionint;
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Rso.Nummer # vW;
        if (Rso.Nummer<>0) then
          erx # RecRead(160,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(160);
      if (aUebernehmen) then begin
        FldDefByName(aHdl->wpdbfieldName, Rso.Nummer);
        if (vX<>0) then begin
          FldDefByName(vX->wpdbfieldName, Rso.Gruppe);
          GetReference(vX,n);
        end;
      end;
    end;


    'Kommission': begin
      if (gSelected<>0) then begin
        erx # RecRead(401,0,_RecId,gSelected);
      end
      else begin
       vA # aHdl->wpcaption;
       if (vA<>'') then begin
          vX # StrFind(BAG.F.Kommission,'/',0);
          if (vX<>0) then begin
            vB # Str_Token(BAG.F.Kommission,'/',1);
            vN1 # CnvIa(vB);
            vB # Str_Token(BAG.F.Kommission,'/',2);
            vN2 # CnvIa(vB);
          end;
        end;

        if (vN1<>0) and (vN2<>0) then begin
          Auf.P.Nummer    # vN1;
          Auf.P.Position  # vN2;
          erx # RecRead(401,1,0)
        end
        else begin
          erx # 999;
        end;

      end;
      if (erx>_rMultiKey) then RecBufClear(401);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, AInt(Auf.P.nummer)+'/'+AInt(Auf.P.Position));
    end;


    'Auftrag': begin
      if (gSelected<>0) then begin
        erx # RecRead(401,0,_RecId,gSelected);
        if (erx<=_rLocked) then
          Erx # RecLink(400,401,3,_recFirst)    // Kopf holen
        else
          RecbufClear(400);
      end
      else begin
        Auf.Nummer # aHdl->wpcaptionint;
        if (Auf.Nummer<>0) then begin
          erx # RecRead(400,1,0);
          if (erx>_rMultikey) then begin
            "Auf~Nummer" # aHdl->wpcaptionint;
            erx # RecRead(410,1,0);
          end;
        end
        else begin
          erx # 999;
        end;
      end;
      if (erx>_rMultiKey) then RecBufClear(400);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Auf.Nummer);
    end;


    'Charge' : begin
      if (gSelected<>0) then begin
        erx # RecRead(252,0,_RecId,gSelected);
      end
      else begin
        Art.C.Charge.Intern # aHdl->wpcaption;
        if (Art.C.Charge.Intern<>'') then
          erx # RecRead(252,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(252);
      if (aUebernehmen) then begin
        if (aHdl->wpdbfieldname<>'') then
          FldDefByName(aHdl->wpdbfieldName, Art.C.Charge.Intern)
        else
          aHdl->wpcaption # Art.C.Charge.Intern;
//        aHdl->winupdate(_WinUpdOn);
      end;
    end;


    'Artikelstichwort' : begin
      if (gSelected<>0) then begin
        erx # RecRead(250,0,_RecId,gSelected);
      end
      else begin
        Art.Stichwort # aHdl->wpcaption;
        if (Art.Stichwort<>'') then
          erx # RecRead(250,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(250);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, Art.Stichwort);
      end;
    end;


    'Strukturnr' : begin
      if (gSelected<>0) then begin
        erx # RecRead(220,0,_RecId,gSelected);
      end
      else begin
        MsL.Strukturnr # aHdl->wpcaption;
        if (MsL.Strukturnr<>'') then
          erx # RecRead(220,3,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(220);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, Msl.Strukturnr);
      end;
    end;


    'Adresse': begin
      if (gSelected<>0) then begin
        erx # RecRead(100,0,_RecId,gSelected);
      end
      else begin
        Adr.Nummer # aHdl->wpcaptionint;
        if (Adr.Nummer<>0) then
          erx # RecRead(100,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(100);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Adr.Nummer);
    end;


    'Kunde': begin
      if (gSelected<>0) then begin
        erx # RecRead(100,0,_RecId,gSelected);
      end
      else begin
        Adr.Kundennr # aHdl->wpcaptionint;
        if (Adr.Kundennr<>0) then
          erx # RecRead(100,2,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(100);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Adr.Kundennr);
    end;


    'Lieferant': begin
      if (gSelected<>0) then begin
        erx # RecRead(100,0,_RecId,gSelected);
      end
      else begin
        Adr.Lieferantennr # aHdl->wpcaptionint;
        if (Adr.Lieferantennr<>0) then
          erx # RecRead(100,3,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(100);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Adr.Lieferantennr);
    end;


    'Lagerort': begin
      if (gSelected<>0) then begin
        erx # RecRead(100,0,_RecId,gSelected);
      end
      else begin
        Adr.Nummer # aHdl->wpcaptionint;
        if (Adr.Nummer<>0) then
          erx # RecRead(100,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(100);
      if (aUebernehmen) then begin
        if (aHdl->wpdbfieldname<>'') then
          FldDefByName(aHdl->wpdbfieldName, Adr.Nummer)
        else
          aHdl->wpcaptionint # Adr.Nummer;
      end;

       if((Str_Token(aHdl -> wpCustom, ';', 2) <> '') and (Adr.Nummer <> Adr.A.Adressnr)) then begin
        vHdl # WinSearch(gMdi, Str_Token(aHdl -> wpCustom, ';', 2));
        if(vHdl <> 0) then begin
          vHdl -> wpcaptionint # 0;
          gSelected # 0;
          GetReference(vHdl, aUebernehmen);
        end;
      end;
    end;


    'Lageranschrift': begin
      if (gSelected<>0) then begin
        erx # RecRead(101,0,_RecId,gSelected);
        GV.Alpha.01 # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        if (aHdl->wpStatusItemText<>'') then begin
          Adr.A.Adressnr # FldIntByName(aHdl->wpstatusitemtext);
        end;
        Adr.A.Nummer    # vW;
        if (Adr.A.Nummer<>0) then
          erx # RecRead(101,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(101);
      GV.Alpha.01 # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
      if (aUebernehmen) then begin
        if (aHdl->wpdbfieldname<>'') then
          FldDefByName(aHdl->wpdbfieldName, Adr.A.Nummer)
        else
          aHdl->wpcaptionint # Adr.A.Nummer;
      end;

      if((Str_Token(aHdl -> wpCustom, ';', 2) <> '') and (Adr.A.Adressnr <> 0)) then begin
        vHdl # WinSearch(gMdi, Str_Token(aHdl -> wpCustom, ';', 2));
        vHdl -> wpcaptionint # Adr.A.Adressnr;
        gSelected # 0;
        GetReference(vHdl, aUebernehmen);
      end;
    end;


    'Vertreter' : begin
      if (gSelected<>0) then begin
        erx # RecRead(110,0,_RecId,gSelected);
      end
      else begin
        Ver.Nummer # aHdl->wpcaptionint;
        if (Ver.Nummer<>0) then
          erx # RecRead(110,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(110);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Ver.Nummer);
    end;


    'Verband' : begin
      if (gSelected<>0) then begin
        erx # RecRead(110,0,_RecId,gSelected);
      end
      else begin
        Ver.Nummer # aHdl->wpcaptionint;
        if (Ver.Nummer<>0) then
          erx # RecRead(110,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(110);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Ver.Nummer);
    end;

    'Gruppe' : begin
      if (gSelected<>0) then begin
        erx # RecRead(810,0,_RecId,gSelected);
      end
      else begin
        Grp.Name # aHdl->wpcaption;
        if (Grp.Name<>'') then
          erx # RecRead(810,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(810);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Grp.Name);
    end;


    'Projekt': begin
      if (gSelected<>0) then begin
        erx # RecRead(120,0,_RecId,gSelected);
      end
      else begin
        Prj.Nummer # aHdl->wpcaptionint;
        if (Prj.Nummer<>0) then
          erx # RecRead(120,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(120);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Prj.Nummer);
    end;


    'BDS': begin
      if (gSelected<>0) then begin
        erx # RecRead(836,0,_RecId,gSelected);
      end
      else begin
        BDS.Nummer # aHdl->wpcaptionint;
        if (BDS.Nummer<>0) then
          erx # RecRead(836,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(836);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, BDS.Nummer);
    end;


    'Vorgangsart' : begin
      if (gSelected<>0) then begin
        erx # RecRead(835,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        AAR.Nummer # vW;
        if (AAR.Nummer<>0) then
          erx # RecRead(835,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(835);
      if (aUebernehmen) and (erx<=_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, AAR.Nummer);
    end;


    'User' : begin
      if (gSelected<>0) then begin
        erx # RecRead(800,0,_RecId,gSelected);
      end
      else begin
         Usr.UserName # aHdl->wpcaption;
         if (Usr.Username<>'') then begin
           erx # RecRead(800,1,0)
           if (aHdl -> wpname = 'edSel.BA.VonUser') then
             gv.alpha.18 # Usr.Username + ' '+Usr.Name
           if (aHdl -> wpname = 'edSel.BA.BisUser'  ) then
            gv.alpha.19 # Usr.Username + ' '+Usr.Name
           end
         else
            erx # 999;
      end;

      if (erx>_rMultiKey) then RecBufClear(800);
      if (aUebernehmen) then begin
        FldDefByName(aHdl->wpdbfieldName, Usr.UserName);
      end;
      Usr_data:RecReadThisUser();
    end;


    'Wgr' : begin
      if (gSelected<>0) then begin
        erx # RecRead(819,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Wgr.Nummer # vW;
        if (Wgr.Nummer<>0) then
          erx # RecRead(819,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(819);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, WGr.Nummer);
    end;


    'Agr' : begin
      if (gSelected<>0) then begin
        erx # RecRead(826,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Agr.Nummer # vW;
        if (Agr.Nummer<>0) then
          erx # RecRead(826,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(826);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, AGr.Nummer);
    end


    'Status' : begin
      if (gSelected<>0) then begin
        erx # RecRead(820,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Mat.Sta.Nummer # vW;
        if (Mat.Sta.Nummer<>0) then
          erx # RecRead(820,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(820);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, Mat.Sta.Nummer);
    end;


    'Werkstoffnr' : begin
      if (gSelected<>0) then begin
        erx # RecRead(832, 0, _RecId, gSelected);
      end
      else begin
        MQu.Werkstoffnr # aHdl->wpcaption;
        if (MQu.Werkstoffnr <> '') then
          erx # RecRead(832, 4, 0)
        else
          erx # 999;
      end;
      if (erx > _rMultiKey) then
        RecBufClear(832);
      if (aUebernehmen) then begin
        FldDefByName(aHdl->wpdbfieldName, MQu.Werkstoffnr);
      end;
    end;

    'HuB' : begin
      if (gSelected<>0) then begin
        erx # RecRead(180,0,_RecId,gSelected);
      end
      else begin
        HuB.Artikelnr # aHdl->wpcaption;
        if (Hub.Artikelnr<>'') then
          erx # RecRead(180,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(180);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, HuB.Artikelnr);
      end;
    end;

    'Artikelnr' : begin
      if (gSelected<>0) then begin
        erx # RecRead(250,0,_RecId,gSelected);
      end
      else begin
        Art.Nummer # aHdl->wpcaption;
        if (Art.Nummer<>'') then
          erx # RecRead(250,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(250);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, Art.Nummer);
      end;
    end;

    'Güte' : begin
      if (gSelected<>0) then begin
        if (lib_Mark:Count(832)>0) and (aUebernehmen) then begin
          Lib_Mark:Foreach(832,here+':AusGueten',aint(aHdl));
          Lib_Mark:Reset(832);
          aHdl->winupdate(_WinUpdFld2Obj);
          RETURN;
        end
        else begin
          erx # RecRead(832,0,_RecId,gSelected);
        end;
      end
      else begin
        erx # 999;
        if (StrFind(aHdl->wpcaption,';',1)=0) then begin
          "MQu.Güte1" # StrCut(aHdl->wpcaption,1,20);
          if (MQu.ErsetzenDurch<>'') then
            "MQu.Güte1" # MQu.ErsetzenDurch;
          if ("MQu.Güte1"<>'') then
            erx # RecRead(832,1,0)
        end;
      end;
      if (erx>_rMultiKey) then
        RecBufClear(832);
      if (aUebernehmen) and (erx<_rMultikey) then begin
        if (MQu.Ersetzendurch<>'') then
          FldDefByName(aHdl->wpdbfieldName, "MQu.Ersetzendurch")
        else if ("MQu.Güte1"<>'') then
          FldDefByName(aHdl->wpdbfieldName, "MQu.Güte1")
        else
          FldDefByName(aHdl->wpdbfieldName, "MQu.Güte2")
      end;
      //FldDefByName(aHdl->wpdbfieldName,
      //MQu_Data:Autokorrektur(FldAlphabyname(aHdl->wpdbfieldName)));
      vA # FldAlphabyname(aHdl->wpdbfieldName);
      MQu_Data:Autokorrektur(var vA);
      FldDefByName(aHdl->wpdbfieldName, vA);
    end;


    'Gütenstufe' : begin
      if (gSelected<>0) then begin
        erx # RecRead(848,0,_RecId,gSelected);
      end
      else begin
        MQu.S.Stufe # aHdl->wpcaption;
        if (MQu.S.Stufe<>'') then
          erx # RecRead(848,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(848);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, MQu.S.Stufe);

    end;


    'Obfs' : begin
      if (gSelected<>0) then begin
        if (lib_Mark:Count(841)>0) and (aUebernehmen) then begin
          Lib_Mark:Foreach(841,here+':AusObfs',aint(aHdl));
          Lib_Mark:Reset(841);
          aHdl->winupdate(_WinUpdFld2Obj);
          RETURN;
        end
        else begin
          erx # RecRead(841,0,_RecId,gSelected);
        end;
      end
      else begin
        RecBufClear(841);
      end;
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, aint(Obf.Nummer));
    end;

    'Oberfläche' : begin
      if (gSelected<>0) then begin
        erx # RecRead(841,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Obf.Nummer # vW;
        if (Obf.Nummer<>0) then
          erx # RecRead(841,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(841);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, Obf.Nummer);
    end;


    'Steuerschluessel' : begin
      if (gSelected<>0) then begin
        erx # RecRead(813,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        StS.Nummer # vW;
        if (StS.Nummer<>0) then
          erx # RecRead(813,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(813);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, StS.Nummer);
      end;
    end;


   'Land' : begin
      if (gSelected<>0) then begin
        erx # RecRead(812,0,_RecId,gSelected);
      end
      else begin
        "Lnd.Kürzel" # aHdl->wpcaption;
        if ("Lnd.Kürzel"<>'') then
          erx # RecRead(812,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(812);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, "Lnd.Kürzel");
      end;
    end;


   'Kostenstelle' : begin
       if (gSelected<>0) then begin
        erx # RecRead(846,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>100000000) then vW # 100000000;
        if (vW<0) then vW # 0;
        KSt.Nummer # vW;
        if (KSt.Nummer<>0) then
          erx # RecRead(846,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(846);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, KSt.Nummer);
      end;
    end;


   'Gegenkonto' : begin
       if (gSelected<>0) then begin
        erx # RecRead(854,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>100000000) then vW # 100000000;
        if (vW<0) then vW # 0;
        GKo.Nummer # vW;
        if (GKo.Nummer<>0) then
          erx # RecRead(854,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(854);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, GKo.Nummer);
      end;
    end;


   'Kostenkopf' : begin
       if (gSelected<>0) then begin
        erx # RecRead(580,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>100000000) then vW # 100000000;
        if (vW<0) then vW # 0;
        Kos.K.Nummer # vW;
        if (Kos.K.Nummer<>0) then
          erx # RecRead(580,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(580);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, Kos.K.Nummer);
      end;
    end;


    'TemTyp' : begin
      if (gSelected<>0) then begin
        erx # RecRead(857,0,_RecId,gSelected);
      end
      else begin
        "TTy.Typ2" # aHdl->wpcaption;
        if ("TTy.Typ2"<>'') then
          erx # RecRead(857,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(857);
      if (aUebernehmen) then
      begin
        FldDefByName(aHdl->wpdbfieldName, "TTy.Typ2");
      end;
/***
      if (gSelected<>0) then begin
       $edTeM.Typ->wpCaption # Lib_Termine:GetTypeKrzl(cnvai(gSelected));
        FldDefByName(aHdl->wpdbfieldName, $edTeM.Typ->wpCaption);
        $edTeM.Typ->WinUpdate(_WinUpdFld2Obj);
      end;
***/
      gSelected # 0;
    end;


    'RekArt': begin
      if (gSelected<>0) then begin
        erx # RecRead(849,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Rek.Art.Nummer # vW;
        if (Rek.Art.Nummer<>0) then
          erx # RecRead(849,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(849);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Rek.Art.Nummer);
    end;


    'RekStatus': begin
      if (gSelected<>0) then begin
        erx # RecRead(850,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        Stt.Nummer # vW;
        if (Stt.Nummer<>0) then
          erx # RecRead(850,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(850);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, Stt.Nummer);
    end;


    'RekFehlercode': begin
      if (gSelected<>0) then begin
        erx # RecRead(851,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        FhC.Nummer # vW;
        if (FhC.Nummer<>0) then
          erx # RecRead(851,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(851);
      if (aUebernehmen) then
        FldDefByName(aHdl->wpdbfieldName, FhC.Nummer);
    end;

  
    'RechnungsTyp' : begin
      if (gSelected<>0) then begin
        erx # RecRead(853,0,_RecId,gSelected);
      end
      else begin
        vW # aHdl->wpcaptionint;
        if (vW>65535) then vW # 65535;
        if (vW<0) then vW # 0;
        RTy.Nummer # vW;
        if (RTy.Nummer<>0) then
          erx # RecRead(853,1,0)
        else
          erx # 999;
      end;
      if (erx>_rMultiKey) then RecBufClear(853);
      if (aUebernehmen) and (erx<_rMultikey) then
        FldDefByName(aHdl->wpdbfieldName, RTy.Nummer);
    end
  
    otherwise RunAfx('Sel.Spezial','GetReference|'+aint(aHdl)+'|'+aBool(aUebernehmen));

  end;  // CASE

  aHdl->winupdate(_WinUpdFld2Obj);

end;


//========================================================================
//========================================================================
sub AusGueten(aPara : alpha) : int
local begin
  aHdl    : int;
  vA,vB   : alpha;
end
begin
  aHdl # cnvia(aPara);

  if (MQu.Ersetzendurch<>'') then
    vA # "MQu.Ersetzendurch"
  else if ("MQu.Güte1"<>'') then
    vA # "MQu.Güte1"
  else
    vA #"MQu.Güte2";

  vB # FldAlphabyname(aHdl->wpdbfieldName);
  if (vB<>'') then vA # StrCut(vB + ';'+va,1,200);
  FldDefByName(aHdl->wpdbfieldName, vA);

end;


//========================================================================
//========================================================================
sub AusObfs(aPara : alpha) : int
local begin
  aHdl    : int;
  vA,vB   : alpha;
end
begin
  aHdl # cnvia(aPara);

  vA # aint(Obf.Nummer);

  vB # FldAlphabyname(aHdl->wpdbfieldName);
  if (vB<>'') then vA # StrCut(vB + ';'+vA,1,100);
  FldDefByName(aHdl->wpdbfieldName, vA);

end;


//========================================================================
//  InnerRedrawInfo
//              für RedrawInfo
//========================================================================
sub InnerRedrawInfo(
  aObj          : int;
  aUebernehmen  : logic;
)
local begin
  x       : int;
  t.iObj  : int;
  vHdl    : int;
end;
begin

  WHILE (aObj<>0) do begin
   x # (aObj->WinInfo(_WinType));
   t.iObj # aObj;
   // wenn der Frame einen Clientbereich hat -> runtersteigen, sonst werden die
   // subelemente nicht durchlaufen !!
   if (x = _wintypeFrameClient) then begin
     t.iobj # aobj -> wininfo(_winfirst,0);
     aobj # t.iobj
   end;

   // gar nicht beachten...
   if (x<>_WinTypeLabel) or (aObj->wpname='LastFocus') or (aObj->wpname='ListProc') then begin
     aObj # t.iObj->WinInfo(_WinNext,0);
     t.iObj # aObj;
     CYCLE;
   end;


   // ist es ein gelinktes Label?
   if (Str_Token(aObj->wpcustom , ';', 1) <> '') then begin
      vHdl # gMdi->winsearch(Str_Token(aObj->wpcustom , ';', 1));
      if (vHdl<>0) then begin
        GetReference(vHdl,aUebernehmen);  // gelinkten Daten holen
        aObj->winupdate(_WinUpdFld2Obj);                // Label neu malen
      end;
    end;

    aObj # t.iObj->WinInfo(_WinNext,0);
    t.iObj # aObj;
  END; // while
end;


//========================================================================
//  RedrawInfo
//            zeichnet alle "gelinkten" Labels neu
//========================================================================
sub RedrawInfo(
  opt aUebernehmen  : logic
  );
local begin
  t.iObj : int;
end;
begin
  if (HdlInfo(gMDI, _HdlExists)=0) then RETURN; // 13.08.2015
  t.iObj # gmdi-> WinInfo(_WinFirst,0);
  if (t.iObj<>0) then InnerRedrawInfo(t.iObj, aUebernehmen);
end;


//========================================================================
//  AusFeld
//
//========================================================================
sub AusFeld()
local begin
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
end;
begin

  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState(gMdi,true);
  vHdl # w_LastFocus;
  GetReference(vHdl,y);
  gSelected # 0;

  RedrawInfo();
//  vHdl->WinFocusset(false);

end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  Erx : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (aEvt:obj->wpname='jump') then begin
    erx # Winsearch(gMDI, Str_Token(aEvt:obj->wpcustom, ';', 1));
    if (erx<>0) then
      erx->Winfocusset(false);
    RedrawInfo();
    RETURN true;
  end;

  // Ermitteln des Frames
  d_Frame # aEvt:Obj->WinInfo(_WinFrame);
  if (d_Frame = 0) then RETURN TRUE;

  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeFloatEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeIntEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeTimeEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) or
  //(aEvt:Obj->Wininfo(_WinType)=_WinTypeTextEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeDateEdit) then begin

    if (aEvt:Obj->Wininfo(_WinType)=_WinTypeCheckbox) then
      aEvt:Obj->wpColBkg # Set.Col.Field.Cursor   // 2022-09-15 AH aEvt:Obj->wpColBkg # _WinColCyan;
    else if (gFrmMain->wpmenuname<>gMenuName) then begin
      gFrmMain->wpMenuname # gMenuName;    // Menü setzen
      gMenu # gFrmMain->WinInfo(_WinMenu);
    end;

    if (Str_Token(aEvt:obj->wpcustom, ';', 1) <> '') then begin
      Lib_GuiCom:AuswahlEnable(aEvt:Obj);
    end
    else begin
      if (aEvt:Obj->Wininfo(_WinType)<>_WinTypeCheckbox) then
//        aEvt:Obj->wpColFocusBkg # ColFocus;
        aEvt:Obj->wpColFocusBkg # Set.Col.Field.Cursor;
        Lib_GuiCom:AuswahlDisable(aEvt:Obj);
    end;

    //aEvt:Obj->wpColFocusBkg # (((175<<8)+177)<<8)+087;
    //aEvt:Obj->wpColFocusBkg # (((175<<8)+177)<<8)+100;
    //aEvt:Obj->wpColFocusBkg # (((90<<8)+160)<<8)+190;
  end;

  RETURN true;
end;


//========================================================================
//  EvtFocusTerm
//                Fokus wechselt hier weg
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObj             : int           // nächstes Objekt
) : logic
local begin
  vHdl :int;
end;
begin

  // Selektion von bis Oberflaeche
  // bis = von
  if (aEvt:Obj->wpname='edOberflaeche') then begin
    if (Sel.Auf.ObfNr <> 0 and Sel.Auf.ObfNr2 = 999) then
      Sel.Auf.ObfNr2 # Sel.Auf.ObfNr;
    else if (Sel.Mat.ObfNr <> 0 and Sel.Mat.ObfNr2 = 999) then
      Sel.Mat.ObfNr2 # Sel.Mat.ObfNr;

    $edOberflaeche2->WinUpdate(_WinUpdFld2Obj);
  end;

  if (aEvt:Obj->Wininfo(_WinType)=_WinTypeEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeFloatEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeIntEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeTimeEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeTextEdit) or
    (aEvt:Obj->Wininfo(_WinType)=_WinTypeDateEdit) then begin
      aEvt:Obj->wpColFocusBkg # _WinColParent;
  end;
  if (aEvt:Obj->Wininfo(_WinType)=_WinTypecheckbox) then begin
    aEvt:Obj->wpColBkg # _WinColParent;
  end;

//  vHdl # gMdi->winsearch('ListProc');
//  if (vHdl->wpcustom<>'') then Call(vHdl->wpcustom+':Refresh',aEvt:Obj->wpname);
  if (StrCut(Str_Token(aEvt:obj->wpcustom, ';', 1), 1, 2)='P:') then begin
    Call(StrCut(Str_Token(aEvt:obj->wpcustom, ';', 1), 3, 100) + ':EvtFocusTerm', aEvt, aFocusObj);
    RETURN true;
  end;

  RedrawInfo();

/*
  if (aEvt:Obj->wpcustom='Lageranschrift') then begin
x    GetReference(aEvt:obj, y);
    GV.Alpha.01 # Adr.A.Name + ', ' + "Adr.A.Straße" +', ' + Adr.A.Ort;
todo(gv.alpha.01);
//  RedrawInfo();
  end;
*/

  RETURN true;
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vHdl      : int;
  vI        : int;
  vHdl2     : int;
  vName     : alpha(250);
  vFileHdl  : int;
end;
begin

  case (aEvt:Obj->wpName) of

    'bt.XML' : begin
      vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
      vName # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'Excel-Dateien|*.xml');
      if (vName<>'') then begin
        if ( StrCnv( StrCut( vName, StrLen( vName ) - 3, 4 ), _strLower ) != '.xml' ) then
        vName # vName + '.xml';
        // Datei testen
        vFileHdl # FsiOpen( vName, _fsiAcsRW | _fsiDenyRW | _fsiCreate );
        if ( vFileHdl > 0 ) then begin
          vFileHdl->FsiClose();
          FsiDelete(vName);
        end
        else begin
          Msg( 910004, vName, 0, 0, 0 );
          RETURN false;
        end;
        vHdl->wpcaption # vName;
      end;
    end;


    'Bt.Save' : begin
      SaveCaptions2XML(gMDI,'');
    end;


    'Bt.Load' : begin
      LoadXML2Captions(gMDI,'');
    end;


    'Bt.OK' : begin
      OKPressed(aEvt:obj);
    end;


    'Bt.Abbruch' : begin
      gSelected # 0;
    end;


    'xbt.Filename' : begin
      vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
      vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, vHdl->wpcaption, '');
      vHdl->wpcaption # vName;
    end;


    otherwise begin
/*
      vHdl # gMdi->winsearch('LastFocus');
      vHdl->wpcustom # aEvt:Obj->wpcustom;
*/
      vHdl # gMDI->Winsearch(aEvt:Obj->wpcustom);
      w_LastFocus # vHdl;
//debug('merke:'+cnvai(vhdl)+' '+vHdl->wpname);
      case aEvt:Obj->wpname of
        'bt.BDS'          : Auswahl('BDS')
        'bt.Zeugnisse'    : Auswahl('Zeugnisse')
        'bt.Versandart'   : Auswahl('Versandart')
        'bt.Lagerplatz'   : Auswahl('Lagerplatz')
        'bt.Filename'     : Auswahl('Filename');
        'bt.BAAktion'     : Auswahl('BAAktion');
        'bt.ResGruppe'    : Auswahl('ResGruppe');
        'bt.Ressource'    : Auswahl('Ressource');
        'bt.Auftrag'      : Auswahl('Auftrag');
        'bt.Vorgangstyp'  : Auswahl('Vorgangstyp');
        'bt.Kommission'   : Auswahl('Kommission');
        'bt.Adresse'      : Auswahl('Adresse');
        'bt.Kunde'        : Auswahl('Kunde');
        'bt.Lieferant'    : Auswahl('Lieferant');
        'bt.Vertreter'    : Auswahl('Vertreter');
        'bt.Verband'      : Auswahl('Verband');
        'bt.Gruppe'       : Auswahl('Gruppe');
        'bt.Wgr'          : Auswahl('Wgr');
        'bt.Agr'          : Auswahl('Agr');
        'bt.Artikeltyp'   : Auswahl('Artikeltyp');
        'bt.Vorgangsart'  : Auswahl('Vorgangsart');
        'bt.HuB'          : Auswahl('HuB');
        'bt.Artikelnr'    : Auswahl('Artikelnr');
        'bt.Artikelstichwort': Auswahl('Artikelstichwort');
        'bt.Charge'       : Auswahl('Charge');
        'bt.Auftragsart'  : Auswahl('Vorgangsart');
        'bt.Strukturnr'   : Auswahl('Strukturnr');
        'bt.Strukturnr_Artikelnr'   : begin
          vHdl # Winsearch(gMDI, aEvt:Obj->wpcustom);
          if (vHdl<>0) then begin
            if (Msg(99,'Artikelauswahl öffnen?',_WinIcoQuestion, _WinDialogYesNo,1)=_winidyes) then begin
              vHdl->wpCustom # 'Strukturnr/Artikel/A';
              Auswahl('Artikelnr');
            end
            else begin
              vHdl->wpCustom # 'Strukturnr/Artikel/S';
              Auswahl('Strukturnr');
            end;
          end;
        end;
        'bt.Projekt'      : Auswahl('Projekt');
        'bt.User' ,
        'bt.Uservon',
        'bt.Userbis'      : Auswahl('User');
        'bt.StatusVon',
        'bt.StatusBis'    : Auswahl('Status');
        'bt.Guete'        : Auswahl('Güte');
        'bt.Werkstoffnr'  : Auswahl('Werkstoffnr');
        'bt.Guetenstufe'  : Auswahl('Gütenstufe');
        'bt.Oberflaeche'  : Auswahl('Oberfläche');
        'bt.Obfs'         : Auswahl('Obfs');
        'bt.Lagerort'     : Auswahl('Lagerort');
        'bt.Status'       : Auswahl('Status');
        'bt.Steuerschluessel' : Auswahl('Steuerschluessel');
        'bt.Lageranschrift'     : begin
          if (vHdl->wpStatusItemText<>'') then begin
            Adr.Nummer # FldIntByName(vHdl->wpstatusitemtext);
          end;
          Auswahl('Lageranschrift');
        end;
        'bt.Land'         : Auswahl('Land');
        'bt.Kostenstelle' : Auswahl('Kostenstelle');
        'bt.Gegenkonto'   : Auswahl('Gegenkonto');
        'bt.Kostenkopf'   : Auswahl('Kostenkopf');
        'bt.PLZ'          : Auswahl('PLZ');
        'bt.TemTyp'       : Auswahl('TemTyp');
        'bt.RekArt'       : Auswahl('RekArt');
        'bt.RekStatus'    : Auswahl('RekStatus');
        'bt.RekFehlercode' : Auswahl('RekFehlercode');
        'bt.RechnungsTyp' : Auswahl('RechnungsTyp');
        otherwise begin
          if (StrCut(aEvt:Obj->wpcustom,1,2)='P:') then begin
            Call(StrCut(aEvt:Obj->wpcustom,3,100)+':EvtClicked', aEvt);
            RETURN true;
          end
          else begin
            RunAfx('Sel.Spezial','EvtClicked|'+aint(aEvt:Obj));
          end;
        end;

      end;
    end;

  end;

  RETURN true;
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
/**
  aEvt:Obj->wpcustom # cnvai(VarInfo(WindowBonus));
  if (w_Name<>'') then todo('PANIK!!!!');
  w_Name # aEvt:obj->wpname;
  Lib_GuiCom:TranslateObject(aEvt:Obj);
  RETURN true;
*/
//  gTitle    # Translate(cTitle);
//  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
//  gZLList   # cZList;
//  gKey      # cKey;
  gSelected # 0;

  App_Main:EvtInit(aEvt);

  WinSearchPath(aEvt:Obj);
end;


//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vParent : int;
  vName   : alpha;
  vTmp    : int;
end;
begin

   if (gFrmMain <> $AppFrameFM) then   // Beim Appframe FM wird kein Tree geöffnet
     if (Mode=c_ModeNew) or (Mode=c_ModeEdit) then
       RETURN false;

  if (aEvt:Obj->wpname='Sel.BA1.Planung') then gMDIBAG # 0;

  // Parentfenster koennen nicht geschlossen werden
  if (w_Child<>0) then RETURN false;

  // Sortierung nicht bei "Auswahl" merken !!!
  //erx # Lib_GuiCom:FindWindowRelation(gMdi);

  gFile   # 0;
  gPrefix # '';
  gZLList # 0;
/*** ???
  // Wenn Unterfenster dann Parent aktivieren
  vParent # Lib_GuiCom:FindParentWindow(aEvt:Obj);
  if (vParent<>0) then begin
    Lib_GuiCom:ChangeChild(aEvt:Obj);
    vParent->wpdisabled # false;
    vParent->wpCustom # Mode; //c_ModeView;
    vParent->WinUpdate(_WinUpdActivate);
    gMdi # vParent;
    App_Main:RefreshMode();
  end;
****/
  // Elternbeziehung aufheben?
  if (w_Parent<>0) then begin
    vTmp # VarInfo(Windowbonus);
    VarInstance(WindowBonus,cnvIA(w_parent->wpcustom));
    w_Child # 0;
    if (gZLList<>0) then gZLList->wpdisabled # false;
    VarInstance(WindowBonus,vTmp);
    w_Parent->wpdisabled # n;
    w_Parent->WinUpdate(_WinUpdActivate);
  end;

  RETURN true;
end;


//========================================================================
//  EvtMenuCommand
//                  Menüpunkt aufgerufen
//========================================================================
sub EvtMenuCommand (
  aEvt                  : event;        // Ereignis
  aMenuItem             : int;          // Menüeintrag
  opt aGateway          : logic;
) : logic
local begin
  vHdl      : handle;
  vHdl2     : handle;
  vA        : alpha;
  vI        : int;
  vName     : alpha(250);
  vFileHdl  : int;
end;
begin

  vA # WinEvtProcNameGet(gMDI, _WinEvtMenuCommand);

  if (vA<>'') and (aGateway=false) then
    if (StrFind(vA,'APP_MAIN:',0,_StrCaseIgnore)=0) then RETURN Call(vA, aEvt, aMenuItem);

  case (aMenuItem->wpName) of

    'Mnu.SelAuswahl' : begin
      vHdl # WinFocusGet();     // Feld
/*
      vHdl2 # gMdi->winsearch('LastFocus');
      vHdl2->wpcustom # vHdl->wpname;
*/
      w_LastFocus # vHdl;
//debug('merke:'+cnvai(vhdl));
      if (StrCut(vHdl->wpcustom,1,2)='P:') then begin
        Call(StrCut(vHdl->wpcustom,3,100)+':EvtMenuCommand', aEvt, aMenuItem);
        RETURN true;
      end;

      if (StrFind(vHdl->wpcustom,'Filename',0)<>0) then
        Auswahl('Filename');

      case (Str_token(vHdl->wpcustom, ';', 1)) of

        'Sort' : begin
          vHdl->wpPopupopen # true;
          RETURN true;
        end;


        'XMLFile' : begin
          vName # Lib_FileIO:FileIO(_WinComFileSave,gMDI, '', 'Excel-Dateien|*.xml');
          if (vName<>'') then begin
            if ( StrCnv( StrCut( vName, StrLen( vName ) - 3, 4 ), _strLower ) != '.xml' ) then
            vName # vName + '.xml';
            // Datei testen
            vFileHdl # FsiOpen( vName, _fsiAcsRW | _fsiDenyRW | _fsiCreate );
            if ( vFileHdl > 0 ) then begin
              vFileHdl->FsiClose();
              FsiDelete(vName);
            end
            else begin
              Msg( 910004, vName, 0, 0, 0 );
              RETURN false;
            end;
            vHdl->wpcaption # vName;
          end;
          RETURN true;
        end;


        'BDS'             : Auswahl('BDS');
        'Zeugnisse'       : Auswahl('Zeugnisse');
        'Versandart'      : Auswahl('Versandart');
        'Lagerplatz'      : Auswahl('Lagerplatz');
        'BAAktion'        : Auswahl('BAAktion');
        'ResGruppe'       : Auswahl('ResGruppe');
        'Ressource'       : Auswahl('Ressource');
        'Auftrag'         : Auswahl('Auftrag');
        'Vorgangstyp'     : Auswahl('Vorgangstyp');
        'Kommission'      : Auswahl('Kommission');
        'Adresse'         : Auswahl('Adresse');
        'Kunde'           : Auswahl('Kunde');
        'Lieferant'       : Auswahl('Lieferant');
        'Vertreter'       : Auswahl('Vertreter');
        'Verband'         : Auswahl('Verband');
        'Gruppe'          : Auswahl('Gruppe');
        'Projekt'         : Auswahl('Projekt');
        'Wgr'             : Auswahl('Wgr');
        'Agr'             : Auswahl('Agr');
        'Artikeltyp'      : Auswahl('Artikeltyp');
        'Vorgangsart'     : Auswahl('Vorgangsart');
        'HuB'             : Auswahl('HuB');
        'Artikelnr'       : Auswahl('Artikelnr');
        'Artikelstichwort': Auswahl('Artikelstichwort');
        'Charge'          : Auswahl('Charge');
        'Strukturnr/Artikel/A',
        'Strukturnr/Artikel/S'   : begin
          if (Msg(99,'Artikelauswahl öffnen?',_WinIcoQuestion, _WinDialogYesNo,1)=_winidyes) then begin
            vHdl->wpCustom # 'Strukturnr/Artikel/A';
            Auswahl('Artikelnr');
          end
          else begin
            vHdl->wpCustom # 'Strukturnr/Artikel/S';
            Auswahl('Strukturnr');
          end;
        end;
        'User'            : Auswahl('User');
        'Status'          : Auswahl('Status');
        'Werkstoffnr'     : Auswahl('Werkstoffnr');
        'Güte'            : Auswahl('Güte');
        'Gütenstufe'      : Auswahl('Gütenstufe');
        'Oberfläche'      : Auswahl('Oberfläche');
        'Obfs'            : Auswahl('Obfs');
        'Lagerort'        : Auswahl('Lagerort');
        'Steuerschluessel': Auswahl('Steuerschluessel');
        'Lageranschrift'  : begin
          if (vHdl->wpStatusItemText<>'') then begin
            Adr.Nummer # FldIntByName(vHdl->wpstatusitemtext);
          end;
          Auswahl('Lageranschrift');
        end;
        'Land'            : Auswahl('Land');
        'Kostenstelle'    : Auswahl('Kostenstelle');
        'Kostenkopf'      : Auswahl('Kostenkopf');
        'PLZ'             : Auswahl('PLZ');
        'TemTyp'          : Auswahl('TemTyp');
        'RekArt'          : Auswahl('RekArt');
        'RekStatus'       : Auswahl('RekStatus');
        'RekFehlercode'   : Auswahl('RekFehlercode');
        'RechnungsTyp'    : Auswahl('RechnungsTyp');
        otherwise begin
          RunAfx('Sel.Spezial','EvtMenuCommand|'+aint(aEvt:Obj)+'|'+aint(aMenuItem));
        end;
      end;
    end;


    'Mnu.SelSave' : begin
      vHdl # Winsearch(gMdi, 'bt.OK');
      OKpressed(vHdl);
      gMDI->Winclose();
    end;


    'Mnu.SelCancel' : begin
      gSelected # 0;
      gMDI->Winclose();
    end;
  end;

end;


//========================================================================
// EvtTerm
//          Terminieren eines Fensters
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vTermProc : alpha;
  vHdl      : int;
end;
begin
  if (aEvt:obj->wpcustom<>'') then VarInstance(WindowBonus,cnvIA(aEvt:Obj->wpcustom));

  // AusAuswahlprozedur starten?
  If (w_TermProc<>'') then begin
    vTermPRoc # w_TermProc;
    vHdl # VarInfo(WindowBonus);
    if (w_parent<>0) then begin
      WinSearchPath(w_Parent);
      VarInstance(Windowbonus,cnvia(w_Parent->wpcustom));
    end;

    if (gSelected<>0) then Call(vTermProc)
    else Lfm_Ausgabe:Cleanup();

    VarInstance(Windowbonus,vHdl);
  end;

  RETURN true;
end;


//========================================================================
//  SaveCaptions2XML
//
//========================================================================
SUB SaveCaptions2XML(
  aWin        : int;
  aFilename   : alpha(1000)) : logic;
local begin
  Erx       : int;
  vI        : int;
  vHdl      : int;
  vFilename : alpha(4000);
  vDoc      : int;
  vRoot     : int;
  vNode     : int;
  vTyp      : int;
  vName     : alpha;
  vMem      : int;
  vBlobDir  : int;
  vBlobDir2 : int;
  vBlob     : int;
end;
begin

  if (aWin=0) then RETURN false;

  if (aFilename='') then begin
    vFilename # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML Dateien|*.xml' );
    if ( vFilename = '' ) then RETURN false;
    if (StrCnv(FsiSplitName(vFilename, _FsiNameE),_Strupper)<>'XML') then
      vFileName # vFIlename+ '.XML';
  end;

  // Create document node
  vDoc # CteOpen(_CteNode);
  vDoc->spID # _XmlNodeDocument;

  // insert comment
  vDoc->CteInsertNode('', _XmlNodeComment, 'Stahl-Control');

  // insert root
  if (aFilename='') then
    vRoot   # XML_NodeA(vDoc,   aWin->wpname,        '')
  else
    vRoot   # XML_NodeA(vDoc,   'USERSEL',        '');

//  vNode   # XML_NodeA(vRoot,  'xxxx',        'mooo');
//  vNode   # XML_NodeI(vRoot,  cBA_BagNummer,    BAG.P.Nummer);

  FOR vHdl # aWin->WinInfo(_WinFirst)
  LOOP vHdl # vHdl->WinInfo(_WinNext)
  WHILE (vHdl<>0) do begin

    vTyp # vHdl->wininfo(_Wintype);

    if (vTyp=_WintypeEdit) or (vTyp=_WintypeFloatEdit) or (vTyp=_WintypeIntEdit) or
      (vTyp=_WintypeTimeEdit) or (vTyp=_WintypeDateEdit) or (vTyp=_WintypeRadiobutton) or
      (vTyp=_WintypeCheckbox) then

      vName # vHdl->wpDbfieldname;  // ST 2011-02-02: Hier keine Konvertierung

      // Eingabeobjekt OHNE Datenbankfeld?? -> dann Objektname nutzen
      if (vName='') then vName # vHdl->wpname;

//debug('Write:'+vname);
    case (vTyp) of
/***
      _WinTypeEdit        : vNode   # XML_NodeA(vRoot,  vHdl->wpDbFieldName, vHdl->wpCaption);
      _WinTypeFloatEdit   : vNode   # XML_NodeF(vRoot,  vHdl->wpDbFieldName, vHdl->wpCaptionfloat);
      _WinTypeIntEdit     : vNode   # XML_NodeI(vRoot,  vHdl->wpDbFieldName, vHdl->wpCaptionInt);
      _WinTypeTimeEdit    : vNode   # XML_NodeT(vRoot,  vHdl->wpDbFieldName, vHdl->wpCaptiontime);
      _WinTypeDateEdit    : vNode   # XML_NodeD(vRoot,  vHdl->wpDbFieldName, vHdl->wpCaptiondate);
      //_WinTypeTextEdit    : vNode   # XML_NodeA(vRoot,  vHdl->wpname, cnvai(vHdl->wpCaptionInt));
      //_wintypeColorEdit
      //_WinTypeColorButton
      _WinTypeRadioButton : vNode   # XML_NodeB(vRoot,  vHdl->wpDbFieldName, (vHdl->wpCheckState=_WinStateChkChecked));
      _WinTypeCheckBox    : vNode   # XML_NodeB(vRoot,  vHdl->wpDbFieldName, (vHdl->wpCheckState=_WinStateChkChecked));
***/
      _WinTypeEdit        : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        Lib_XML:AppendAttributeNode(vNode, 'value',vHdl->wpcaption);
      end;
      _WinTypeFloatEdit   : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        Lib_XML:AppendAttributeNode(vNode, 'value',anum(vHdl->wpcaptionfloat,8));
      end;
      _WinTypeIntEdit     : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        Lib_XML:AppendAttributeNode(vNode, 'value',aint(vHdl->wpcaptionInt));
      end;
      _WinTypeTimeEdit    : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        Lib_XML:AppendAttributeNode(vNode, 'value',cnvat(vHdl->wpcaptiontime));
      end;
      _WinTypeDateEdit    : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        Lib_XML:AppendAttributeNode(vNode, 'value',cnvad(vHdl->wpcaptiondate,_FmtDateLongYear));
      end;
      _WinTypeRadioButton, _WinTypeCheckBox : begin
        vNode # Lib_XML:NewNode(vRoot, 'field','');
        Lib_XML:AppendAttributeNode (vNode, 'name',vName);
        if (vHdl->wpCheckState=_WinStateChkChecked) then
          Lib_XML:AppendAttributeNode(vNode, 'value', 'Y')
        else
          Lib_XML:AppendAttributeNode(vNode, 'value', 'N');
      end;

    end;

  END;


  if (vFilename<>'') then begin
    // XML extern speichern...
//    erx # vDoc->XmlSave(vFilename,_XmlSaveDefault,0);   //  ST 2011-02-02: Kein Encoding angeben!!
      erx # vDoc->XmlSave(vFilename,_XmlSaveDefault,0, _CharsetUTF8);
  end
  else begin
    // XML intern speichern...
    vMem # MemAllocate(_memautosize);
//    erx # vDoc->XmlSave('',_Xmlsavedefault, vMem);
    erx # vDoc->XmlSave('',_XmlSaveDefault,vMem, _CharsetUTF8);
    vBlobDir  # BinDirOpen(0,'Selektionen',_Bincreate);
    vBlobDir2 # BinDirOpen(vBlobDir,gUsername,_Bincreate);
    Binclose(vBlobDir);
    vBlob # BinOpen(vBlobdir2,aFilename,_Bincreate | _BinLock);
    erx # BinWriteMem(vBlob, vMem);
    MemFree(vMem);
    Binclose(vBlobDir2);
    Binclose(vBlob);
  end;

  vDoc->CteClear(true);
  vDoc->CteClose();

  // Fehler?
  if (erx<>0) then begin
    if (aFilename='') then Msg(998015,vFileName,_WinIcoError,0,0);
    RETURN false;
  end;

  if (aFilename='') then Msg(998016,vFileName,_WinIcoInformation,0,0);
  RETURN true;

end;


//========================================================================
//  LoadXML2Captions
//
//========================================================================
SUB LoadXML2Captions(
  aWin        : int;
  aFileName   : alpha(1000);
) : logic;
local begin
  Erx       : int;
  vFilename : alpha(4000);
  vDoc      : int;
  vRoot     : int;
  vNode     : int;
  vI        : int;
  vA,vB,vX  : alpha(500);
  vD        : date;
  vMem      : int;
  vBlob     : int;
  vBlobDir  : int;
  vBlobDir2 : int;
  vHdl      : int;
end;
begin

  if (aFilename='') then begin
    /* Dateiauswahl */
    vFilename # Lib_FileIO:FileIO( _winComFileopen, gMDI, '', 'XML Dateien|*.xml' );
    if ( vFilename = '' ) then RETURN false;
  end;

  /* XML Initialisierung */
  vDoc # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;

  if (vFilename<>'') then begin
    erx # vDoc->XmlLoad( vFilename);
  end
  else begin
    vMem # MemAllocate(_memautosize);
    vBlobDir  # BinDirOpen(0,'Selektionen',_Bincreate);
    vBlobDir2 # BinDirOpen(vBlobDir,gUsername,_Bincreate);
    Binclose(vBlobDir);
    vBlob # BinOpen(vBlobdir2,aFilename);
    Errset(0);
    if (vBlob<0) then begin
      vDoc->CteClear( true );
      vDoc->CteClose();
      Binclose(vBlobDir2);
      MemFree(vMem);
      RETURN false;
    end;

    erx # BinReadMem(vBlob, vMem);
    Binclose(vBlobDir2);
    Binclose(vBlob);
    erx # vDoc->XmlLoad('',0, vMem);
    MemFree(vMem);
  end;
  if (erx != _errOk ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
    Msg(998017, ' (' + XmlError( _xmlErrorText ) + ')', 0, 0, 0 );
    RETURN false;
  end;

  if (aWin<>0) then
    vRoot # vDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, aWin->wpname)
  else
    vRoot # vDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'USERSEL');
  if (vRoot=0) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();
    Msg(998017, '', 0, 0, 0 );
    RETURN false;
  end;


  // BAG Nodes Durchlaufen
  FOR  vNode # vRoot->CteRead(_CteFirst | _CteChildList)
  LOOP vNode # vRoot->CteRead(_CteNext  | _CteChildList, vNode)
  WHILE (vNode > 0) DO BEGIN
    vA # '';
    vD # 0.0.0;

    vB # lib_XML:GetAttributeValue (vNode,'name');
    vA # lib_XML:GetAttributeValue (vNode,'value');

    // Objekt OHNE Datenbankfeld?
    if (FldInfobyname(vB, _FldExists)=0) then begin
      vHdl # winsearch(aWin, vB);
      if (vHdl<>0) then begin
        vI # vHdl->Wininfo(_Wintype);
        case (vI) of
          _WinTypeEdit        : vHdl->wpcaption # vA;
          _WinTypeFloatEdit   : vHdl->wpcaptionfloat # cnvfa(vA);
          _WinTypeIntEdit     : vHdl->wpcaptionInt # cnvia(vA);
          _WinTypeTimeEdit    : vHdl->wpcaptiontime # cnvta(vA);
          _WinTypeDateEdit    : vHdl->wpcaptiondate # cnvda(vA);
          _WinTypeRadioButton, _WinTypeCheckBox : begin
            if (vA='Y') then vHdl->wpCheckState # _WinStateChkChecked
            else vHdl->wpCheckState # _WinStateChkUnChecked;
          end;
        end;
      end;
      CYCLE;
    end;

    vI # FldInfobyname(vB, _Fldtype);
//    vI # FldInfobyname(vNode->spname, _Fldtype);
//debug('tpye :'+vnode->spname+'  '+aint(vI));
//debug('type :'+cnvai(vnode->sptype)+'  '+vnode->spcustom);
    case vI of
      _TypeFloat  : FldDefbyname(vB, cnvfa(vA));

      _typeAlpha    : begin
//        XML_GetValA(vNode, var vA);
//        FldDefbyname(vNode->spname, vA);
          FldDefbyname(vB, vA);
      end;

      _Typeint,_Typeword     : begin
//        XML_GetValA(vNode, var vA);
//        FldDefbyname(vNode->spname, cnvia(vA));
          FldDefbyname(vB, cnvia(vA));
      end;

      _Typedate     : begin
//        XML_GetValD(vNode, var vD);
        vD # cnvda(vA);
//        FldDefbyname(vNode->spname, vD);
        FldDefbyname(vB, vD);
      end;

      _TypeTime     : begin
//        XML_GetValA(vNode, var vA);
//        FldDefbyname(vNode->spname, cnvta(vA));
        FldDefbyname(vB, cnvta(vA));
      end;

      _TypeBool     : begin
//        XML_GetValA(vNode, var vA);
//        FldDefbyname(vNode->spname, (vA='Y'));
        FldDefbyname(vB, (vA='Y'));
      end;

    end;

  END;  // XML Loop
/**/

  /* XML Abschluss */
  vDoc->CteClear( true );
  vDoc->CteClose();

  if (aWin<>0) then aWin->Winupdate(_WinUpdFld2Obj);
  RedrawInfo();

  RETURN true;
end;


//========================================================================
//  Filter_Stop
//
//========================================================================
sub Filter_stop(
  opt aID   : int;
) : logic;
local begin
  Erx   : int;
  vHdl  : int;
  vUpd  : logic;
end;
begin
  if (gZLList->wpdbselection=0) then RETURN false;
  if (w_SelName='') and (w_Sel2Name='') then RETURN false;
//  if (StrFind(w_selName,'.SEL',0)=0) then RETURN false;
  // 1. da, aber KEIN Filter?
  if (w_SelName<>'') and (w_Sel2Name='') then begin
    if (StrFind(w_selName,'.SEL',0)=0) then RETURN false;
  end;

  vUpd # gZLList->wpAutoUpdate;

  // von 2 auf 1
  if (w_SelName<>'') and (w_Sel2Name<>'') then begin
    gZLList->wpAutoUpdate # false;
    vHdl # gZLList->wpdbselection;
    gZLList->wpDbSelection # 0;
    SelClose(vHdl);
    vHdl # SelOpen();
    erx # vHdl->SelRead(gFile, _selLock, w_Selname);
    erx # Lib_Sel:Run(vHdl, false);
    if (erx<>_rOK) then RETURN true;
   
    gZLList->wpDbSelection # vHdl;

    SelDelete(gFile,w_sel2Name);
    w_Sel2Name # '';

    vHdl # gMenu->WinSearch('Mnu.Filter.Stop');
    if (vHdl<> 0) then vHdl->wpMenucheck # n;
    w_AktiverFilter # Str_token(w_AktiverFilter,'|',2);
    
    if (aId<>0) then begin
      RecRead(gFile,0, _recId, aID);
      if (vUpd) then gZLList->WinUpdate(_WinUpdOn,_WinLstRecDoSelect);
    end
    else begin
      if (vUpd) then gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    end;
    App_Main:Refreshmode();
    
    RETURN true;
  end;
  
  // SEL RAUSNEHMEN
  gZLList->wpAutoUpdate # false;

  vHdl # gZLList->wpdbselection;
  gZLList->wpDbSelection # 0;
  SelClose(vHdl);
  SelDelete(gFile,w_selName);
  w_SelName # '';

  vHdl # gMenu->WinSearch('Mnu.Filter.Stop');
  if (vHdl<> 0) then vHdl->wpMenucheck # n;
  w_AktiverFilter # '';

  if (aId<>0) then begin
    RecRead(gFile,0, _recId, aID);
    if (vUpd) then gZLList->WinUpdate(_WinUpdOn,_WinLstRecDoSelect);
  end
  else begin
    if (vUpd) then gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
  end;
  App_Main:Refreshmode();

  RETURN true
end;


//========================================================================
//  AddSort
//
//========================================================================
sub AddSort(
  aMDI          : int;
  aName         : alpha;
  opt aSort     : alpha;
  opt aDefault  : logic);
local begin
  vDL           : int;
  vHdl          : int;
end;
begin
  if (aSort='') then aSort # aName;
  aName # Translate(aName);

  vDL # Winsearch(aMDI, 'dlSort');
  if (vDL=0) then RETURN;

  vDL->WinLstDatLineAdd(aName);
  vDL->WinLstCellSet(aSort,2);

  if (aDefault) then begin
    vHdl # Winsearch(aMDI, 'edSort');
    vHdl->wpcaption # aName;
  end;

end;


//========================================================================
// als DUMMY siet 10.06.2016 AH weil Sonnestahl das manchmal haben??
//========================================================================
sub RefreshMode(
  opt aReentry : logic;
);
begin
end;


//========================================================================