@A+
//==== Business-Control ==================================================
//
//  Prozedur    BA1_Combo_Main
//                OHNE E_R_G
//  Info
//
//
//  02.06.2003  AI  Erstellung der Prozedur
//  28.09.2009  TM  Einsatz Mengenberechnung per Kontextmenü
//  10.02.2012  AI  Logik für Liste der zugehörigen Aufträge (lb.zuAuftragsList) eingebaut
//  25.06.2012  AI  BAG.Nummer OHNE Tauserndertrennung
//  30.08.2012  ST  EditModus bei 999  aktiviert 1326/284
//  26.09.2012  ST  Skalierung des Graphenanzeigebereiches (EvtPosChanged) Prj. 1108/65
//  19.04.2013  AI  Bei "Summe-Einsatz" nur KEINE echten IO anzeigen (Bruder<>0)
//  23.01.2015  AH  Auto-VSBs lassen sich auch abbrechen
//  09.02.2015  AH  Schnellweitergabe per Kontextmenü
//  17.03.2016  AH  Neu: Feld "BAG.P.Status"
//  07.06.2016  AH  Directory auf %temp%
//  17.01.2018  ST  Neu: Bei Arbeitsgang "Umlagern" keine Weiterverarbeitung
//  14.10.2021  AH  Neu: AFX "BAG.Combo.Init.Pre"  "BAG.Combo.Init"
//  25.01.2022  AH  Neu: Dirketes neue Pos. Einbinden
//  25.01.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB ShowInfo(aDatei : int);
//    SUB P_EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB IO_EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtMenuInitPopup(...)
//    SUB F_EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtChanged(aEvt : event) : logic
//    SUB RefreshMode(optaNoRefresh : logic);
//    SUB EvtMenuCommand(aEvt : event; aMenuItem : int) : logic
//    SUB P_EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB IO_EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB F_EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB EvtPageSelectStart(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtPageSelect(aEvt : event; aPage : int; aSelecting : logic) : logic
//    SUB EvtClicked(aEvt : event) : logic
//    SUB EvtClose(aEvt : event) : logic
//    SUB EvtPosChanged
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_BAG

define begin
  cDialog :   $BA1.Combo.Verwaltung
  cTitle :    'Betriebsauftrag'
  cFile :     702
  cMenuName   : 'BA1.Combo.Bearbeiten'
  cMenuName2  : 'BA1.I.Bearbeiten'
  cMenuName3  : 'BA1.F.Bearbeiten'
  cPrefix :   'BA1_Combo'
  cZList1 :   $RL.BA1.Pos
  cZList2 :   $RL.BA1.Input
  cZList3 :   $RL.BA1.Fertigung
  cZList4 :   $RL.BA1.Output
  cKey :      1
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
  vFont : font;
end;
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gKey      # cKey;

  case ($Label.Main->wpCustom) of
    'NB.Position','' : begin
      gPrefix   # 'BA1_P';
      gFile     # 702;
      gZLList   # cZList1;
      gMenuName # cMenuName;    // Menü setzen
    end;


    'NB.Input' : begin
      gPrefix   # 'BA1_IO_I';
      gFile     # 701;
      gZLList   # cZList2;
      gMenuName # cMenuName2;    // Menü setzen
    end;


    'NB.Fertigung' : begin
      gPrefix   # 'BA1_F';
      gFile     # 703;
      gZLList   # cZList3;
      gMenuName # cMenuName3;   // Menü setzen
    end;
  end;

  RunAFX('BAG.Combo.Init.Pre',aint(aEvt:Obj));
  App_Main:EvtInit(aEvt);
  RunAFX('BAG.Combo.Init',aint(aEvt:Obj));

  Lib_GuiCom:RecallList(cZList1);     // Usersettings holen
  Lib_GuiCom:RecallList(cZList2);     // Usersettings holen
  Lib_GuiCom:RecallList(cZList3);     // Usersettings holen

  vHdl # cZList1;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;
  vHdl # cZList2;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;
  vHdl # cZList3;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;
  vHdl # cZList4;
  if (Usr.Font.Size<>0) then begin
    vFont # vHDL->wpfont;
    vFont:Size # Usr.Font.Size * 10;
    vHDL->wpfont # vFont;
  end;

  $lb.BA.Nummer->wpcaption # aint(BAG.nummer);
  $lb.P.Nummer2->wpcaption # aint(BAG.nummer);
  $lb.IO.Nummer->wpcaption # aint(BAG.nummer);

  cZList1->wpColFocusBkg    # Set.Col.RList.Cursor;
  cZList1->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  cZList2->wpColFocusBkg    # Set.Col.RList.Cursor;
  cZList2->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  cZList3->wpColFocusBkg    # Set.Col.RList.Cursor;
  cZList3->wpColFocusOffBkg # "Set.Col.RList.CurOff";
  cZList4->wpColFocusBkg    # Set.Col.RList.Cursor;
  cZList4->wpColFocusOffBkg # "Set.Col.RList.CurOff";
end;


//========================================================================
// STD macht nix
//========================================================================
sub RePos(
  aCmd      : alpha;
  opt aMDI  : int);
begin
end;


//========================================================================
//  ShowInfo
//            "Infomaske" refreshen
//========================================================================
sub ShowInfo(aDatei : int);
local begin
  Erx     : int;
  vA      : alpha(200);
  vA2     : alpha(200);
  vHdl    : int;
  vGew    : float;
  vGew2   : float;
  vBuf701 : int;
  vBuf703 : int;
  vB,vB2  : float;
end;
begin

  case (aDatei) of
    // Einsatz Info==================================================
    // Einsatz Info==================================================
    // Einsatz Info==================================================
    701 : begin
      if ((BAG.IO.ID=0) or (BAG.IO.Nummer<>BAG.Nummer)) or
        (RecLink(701,702,2,_RecFirst | _RecTest)=_rnorec) then begin
        $LB.Info1->wpcaption # 'Einsatz';
        $LB.Info2->wpcaption # '';
        $LB.Info3->wpcaption # '';
        $LB.Info4->wpcaption # '';
        $LB.Info5->wpcaption # '';
        $LB.Info6->wpcaption # '';
        $LB.Info7->wpcaption # '';
        RETURN;
      end;

      case  (BAG.IO.Materialtyp) of

        // echtes Material?
        c_IO_Mat,c_IO_VSB : begin
          $LB.Info1->wpcaption # Translate('Material')+' '+AInt(BAG.IO.MaterialNr);
          vA # Translate('Abmessung: ')+ANum(BAG.IO.Dicke,Set.Stellen.Dicke)+' x '+ANum(BAg.IO.Breite,Set.Stellen.Breite);
          if ("BAG.IO.Länge"<>0.0) then vA # vA + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
          $LB.Info2->wpcaption # vA;
          $LB.Info3->wpcaption # Translate('Güte')+': '+"BAG.IO.Güte";
          $LB.Info4->wpcaption # Translate('Stückzahl')+': '+AInt(BAG.IO.Plan.In.Stk);
          $LB.Info5->wpcaption # Translate('Gewicht')+': '+ANum(BAG.IO.Plan.In.GewN,"Set.Stellen.Gewicht")+ ' kg';
          $LB.Info6->wpcaption # '';
          erx # Mat_Data:read(BAG.IO.Materialnr); // Material holen
          if (erx>=200) and (Mat.Reserviert.Gew>0.0) then
            $LB.Info7->wpcaption # Translate('Reservierungen vorhanden')
          else
            $LB.Info7->wpcaption # ''
        end;

        // Artikel
        c_IO_Art : begin
          $LB.Info1->wpcaption # Translate('Artikel')+' '+BAG.IO.Artikelnr;
          vA # Translate('Abmessung: ')+ANum(BAG.IO.Dicke,Set.Stellen.Dicke)+' x '+ANum(BAg.IO.Breite,Set.Stellen.Breite);
          if ("BAG.IO.Länge"<>0.0) then vA # vA + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
          $LB.Info2->wpcaption # vA;
          $LB.Info3->wpcaption # Translate('Güte')+': '+"BAG.IO.Güte";
          $LB.Info4->wpcaption # Translate('Stückzahl')+': '+AInt(BAG.IO.Plan.In.Stk);
          $LB.Info5->wpcaption # Translate('Gewicht')+': '+ANum(BAG.IO.Plan.In.GewN,"Set.Stellen.Gewicht")+ ' kg';
          $LB.Info6->wpcaption # '';
          $LB.Info7->wpcaption # '';
        end;

        // Bestellartikel
        c_IO_Beistell : begin
          $LB.Info1->wpcaption # Translate('Beistellungsartikel')+' '+BAG.IO.Artikelnr;
          vA # Translate('Abmessung: ')+ANum(BAG.IO.Dicke,Set.Stellen.Dicke)+' x '+ANum(BAg.IO.Breite,Set.Stellen.Breite);
          if ("BAG.IO.Länge"<>0.0) then vA # vA + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
          $LB.Info2->wpcaption # vA;
          $LB.Info3->wpcaption # Translate('Güte')+': '+"BAG.IO.Güte";
          $LB.Info4->wpcaption # Translate('Stückzahl')+': '+AInt(BAG.IO.Plan.In.Stk);
          $LB.Info5->wpcaption # Translate('Gewicht')+': '+ANum(BAG.IO.Plan.In.GewN,"Set.Stellen.Gewicht")+ ' kg';
          $LB.Info6->wpcaption # '';
          $LB.Info7->wpcaption # '';
        end;

        // theoret.Material?
        c_IO_Theo : begin
          $LB.Info1->wpcaption # Translate('theor.Einsatz');
          vA # Translate('Abmessung')+': '+ANum(BAG.IO.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAg.IO.Breite,"Set.Stellen.Breite");
          if ("BAG.IO.Länge"<>0.0) then vA # vA + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
          $LB.Info2->wpcaption # vA;
          $LB.Info3->wpcaption # Translate('Güte')+': '+"BAG.IO.Güte";
          $LB.Info4->wpcaption # Translate('Stückzahl')+': '+AInt(BAG.IO.Plan.In.Stk);
          $LB.Info5->wpcaption # Translate('Gewicht')+': '+ANum(BAG.IO.Plan.In.GewN,"Set.Stellen.Gewicht")+ ' kg';
          $LB.Info6->wpcaption # '';
          $LB.Info7->wpcaption # '';
        end;

        // Weiterbearbeitung?
        c_IO_BAG : begin
          vA # Translate('Weiterbearbeitung aus')+' '+AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition);
          if (BAG.IO.VonFertigung>0) and (BAG.IO.VonFertigung<999) then
            vA # vA + '/'+AInt(BAG.IO.VonFertigung);
          $LB.Info1->wpcaption # vA;
          vA # Translate('Abmessung')+': '+ANum(BAG.IO.Dicke,"Set.Stellen.Dicke")+' x '+ANum(BAg.IO.Breite,"Set.Stellen.Breite");
          if ("BAG.IO.Länge"<>0.0) then vA # vA + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
          $LB.Info2->wpcaption # vA;
          $LB.Info3->wpcaption # Translate('Güte')+': '+"BAG.IO.Güte";
          $LB.Info4->wpcaption # Translate('Stückzahl')+': '+AInt(BAG.IO.Plan.In.Stk);
          $LB.Info5->wpcaption # Translate('Gewicht')+': '+ANum(BAG.IO.Plan.In.GewN,"Set.Stellen.Länge")+ ' kg';
          $LB.Info6->wpcaption # '';
          vA # '';
          if (BAG.IO.UrsprungsID<>0) then
            vA # Translate('Ursprungseinsatz')+': '+AInt(BAG.IO.UrsprungsID);
          $LB.Info7->wpcaption # vA;
        end;

      end;
    end;


    // Positions Info================================================
    // Positions Info================================================
    // Positions Info================================================
    702 : begin
      if (BAG.P.Nummer=0) or (BAG.P.Nummer=999999999) then begin
        $LB.Info1->wpcaption # Translate('Arbeitsgang');
        $LB.Info2->wpcaption # '';
        $LB.Info3->wpcaption # '';
        $LB.Info4->wpcaption # '';
        $LB.Info5->wpcaption # '';
        $LB.Info6->wpcaption # '';
        $LB.Info7->wpcaption # '';
        RETURN;
      end;

      vA #  Translate('Arbeitsgang')+': '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
      if (BAG.P.Auftragsnr<>0) then begin
        erx # Auf_Data:Read(BAG.P.Auftragsnr, BAG.P.AuftragsPos, y);
        if (erx>=400) then
          vA # vA + ' '+Translate('für Auf.')+AInt(BAG.P.Auftragsnr)+'/'+AInt(BAG.P.Auftragspos)+' '+Auf.P.KundenSW;
      end;
      $LB.Info1->wpcaption # vA;

      vA # BAG.P.Bezeichnung+' am '+cnvad(BAG.P.Plan.StartDat);
      if (BAG.P.ExternYN) then begin  // extern?
        erx # RecLink(100,702,7,_recFirst);
        if (erx<=_rLocked) and (BAG.P.ExterneLiefNr<>0) then
          vA # vA + ' '+Translate('bei')+' '+Adr.Stichwort;
      end
      else begin
        if (BAG.P.Ressource<>0) then begin
          vA # vA + ' '+ Translate('auf Hauptressource')+' '+AInt(BAG.P.Ressource.Grp)+'/'+AInt(BAG.P.Ressource);
          erx # RecLink(160,702,11,_RecFirst);
          if (erx<=_rLocked) then vA # vA + ': '+Rso.Stichwort;
        end;
      end;
      $LB.Info2->wpcaption # vA;

      vA # '';
      if (BAG.P.Fenster.MaxDat<>0.0.0) then
        vA # Translate('spätester Start')+' '+cnvad(BAG.P.Fenster.MaxDat)+' '+cnvat(BAG.P.Fenster.MaxZei)+' '+Translate('Uhr');
      $LB.Info3->wpcaption # vA;

      vA # '';
      vA2 # '';
      if (BAG.P.Aktion=c_BAG_Spalt) then begin
        vBuf701 # RecBufCreate(701);
        erx # RecLink(vBuf701,702,2,_RecFirst);    // Input loopen
        WHILE (erx<=_rLocked) do begin
          if ((vBuf701->BAG.IO.MaterialTyp=c_IO_MAT) and (vBuf701->BAG.IO.BruderID=0)) or
            ((vBuf701->BAG.IO.MaterialTyp=c_IO_BAG) and (vBuf701->BAG.IO.BruderID=0)) then begin
            vGew # vGew + (vBuf701->BAG.IO.Plan.Out.GewN);
            if (vB=0.0) then vB # vBuf701->BAG.IO.Breite;
          end;
          erx # RecLink(vBuf701,702,2,_RecNext);
        END;

        vBuf703 # RecBufCreate(703);
        erx # RecLink(vBuf703,702,4,_recFirst);     // Fertigungen loopen
        WHILE (erx<=_rLocked) do begin
          vGew2 # vGew2 + (vBuf703->BAG.F.Gewicht);
          vB2 # vB2 + (cnvfi(vBuf703->BAG.F.StreifenAnzahl) * vBuf703->BAG.F.Breite);
          erx # RecLink(vBuf703,702,4,_recNext);
        END;
        RecBufDestroy(vBuf701);
        RecBufDestroy(vBuf703);
        vA  # 'Summe-Einsatz   : '+anum(vGew,Set.Stellen.Gewicht)+'kg   Breite:'+anum(vB,Set.Stellen.Breite)+'mm';
        vA2 # 'Summe-Fertigung: '+anum(vGew2,Set.Stellen.Gewicht)+'kg   Breite:'+anum(vB2,Set.Stellen.Breite)+'mm';
      end;  // SPALTEN

      $LB.Info4->wpcaption # vA;
      $LB.Info5->wpcaption # vA2;
      $LB.Info6->wpcaption # '';
      $LB.Info7->wpcaption # '';
      if (gUserName='AH') then begin
        $LB.Info7->wpcaption # 'fenster:'+cnvad(BAG.P.Fenster.MinDat)+cnvat(BAG.P.Fenster.MinZei)+' bis '+cnvad(BAG.P.Fenster.MaxDat)+cnvat(BAG.P.Fenster.MaxZei);
      end;
    end;


    // Fertigungs Info ==============================================
    // Fertigungs Info ==============================================
    // Fertigungs Info ==============================================
    703 : begin
      $LB.Info1->wpcaption # 'Fertigungsinfos....';
      $LB.Info2->wpcaption # vA;
      $LB.Info3->wpcaption # '';
      $LB.Info4->wpcaption # '';
      $LB.Info5->wpcaption # '';
      $LB.Info6->wpcaption # '';
      $LB.Info7->wpcaption # '';
    end;

  end;

end;


//========================================================================
//  P_EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub P_EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  Erx     : int;
  vFilter : int;
  vHdl    : int;
  vTmp    : int;
end;
begin
  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  // nur refreshen, wenn echter Modus vorhanden!
  if (Mode='') then RETURN false;

  erx # RecRead(702,0,0,cZList1->wpdbrecid);
  if (erx<>_rOK) then RecBufClear(702);

  // bei leerem Arbeitsgang erstmal alle Anzeigen ausmachen
  if (BAG.P.Nummer=0) then begin
    erx # RecLink(702,700,1,_recFirst);
  end;

  if (BAG.P.Nummer=0) then begin
    RecBufClear(701);
    RecBufClear(703);
    RecBufClear(704);
    RecBufClear(705);
    RecBufClear(706);

    cZList2->wpautoupdate   # false;
    cZList2->wpDbFileNo     # 999;
    cZList2->wpDbLinkFileNo # 0;
    cZList2->wpDbKeyNo      # 1;
    cZList2->wpdisabled     # y;
    cZList2->wpautoupdate   # true;

    cZList3->wpautoupdate   # false;
    cZList3->wpDbFileNo     # 999;
    cZList3->wpDbLinkFileNo # 0;
    cZList3->wpDbKeyNo      # 1;
    cZList3->wpdisabled     # y;
    cZList3->wpautoupdate   # true;

    cZList4->wpautoupdate   # false;
    cZList4->wpDbFileNo     # 999;
    cZList4->wpDbLinkFileNo # 0;
    cZList4->wpDbKeyNo      # 1;
    cZList4->wpdisabled     # y;
    cZList4->wpautoupdate   # true;
  end
  else begin
    cZList2->wpautoupdate   # false;
    cZList2->wpDbFileNo     # 702;
    cZList2->wpDbKeyNo      # 2;
    cZList2->wpDbLinkFileNo # 701;
    cZList2->wpdisabled     # n;
    cZList2->wpautoupdate   # true;

    cZList3->wpautoupdate   # false;
    cZList3->wpDbFileNo     # 702;
    cZList3->wpDbKeyNo      # 4;
    cZList3->wpDbLinkFileNo # 703;
    cZList3->wpdisabled     # n;
    cZList3->wpautoupdate   # true;

    cZList4->wpautoupdate   # false;
    cZList4->wpDbFileNo     # 702;
    cZList4->wpDbKeyNo      # 3;
    cZList4->wpDbLinkFileNo # 701;
    cZList4->wpdisabled     # n;
    cZList4->wpautoupdate   # true;
  end;


  if (Mode=c_ModeDelete) then RETURN false;

  if (aFocusobject<>0) then begin
    if (aFocusobject->wpname='Edit') or (aFocusobject->wpname='NB.List') then begin
      //(StrFind(aFocusobject->wpname='Edit' then begin
      gZLList->Winfocusset(true);
      RETURN false;
    end;
  end;

  $LB.List1->wpColFg # _WinColLightRed;
  $LB.List2->wpColFg # _WinColParent;
  $LB.List3->wpColFg # _WinColParent;

  ShowInfo(702);
  gZLList # cZList1;

  vTmp # Winsearch(gMDI,'NB.Page1');
  if (vTmp<>0) and ( $Label.Main->wpCustom<>'NB.Positon') then begin
    vTmp->wpname # $Label.Main->wpCustom;
  end;
  vTmp # Winsearch(gMDI,'NB.Position');
  if (vTmp<>0) then begin
    vTmp->wpdisabled # n;
    vTmp->wpname # 'NB.Page1';
  end;
  vTmp # Winsearch(gMDI,'NB.Input');
  if (vTmp<>0) then vTmp->wpdisabled # y;
  vTmp # Winsearch(gMDI,'NB.Fertigung');
  if (vTmp<>0) then vTmp->wpdisabled # y;

  $Label.Main->wpCustom # 'NB.Position';
  gPrefix # 'BA1_P';
  gFile # 702;

  gMenuName # cMenuName;   // Menü setzen
  gFrmMain->wpMenuname # gMenuName;
  if (gPrefix<>'') then begin
    vHdl # gFrmMain->WinInfo(_WinMenu);
    Lib_SFX:CreateMenu(vHdl, gPrefix);
  end;
  Lib_GuiCom2:RefreshQB(gFrmMain->WinInfo(_WinMenu));

  // Pflichtfelder...
  if (w_Obj4Auswahl<>0) then begin
    Lib_Ramsort:KillList(w_Obj4Auswahl);  // Liste "zerstoeren"
    w_Obj4Auswahl # 0;
    Lib_Pflichtfelder:PflichtfelderListeFuellen(w_Name,var w_Pflichtfeld, var w_Obj4auswahl, y);
  end;
  SetStdAusFeld('edBAG.P.ExterneLiefNr'   ,'Lieferant');
  SetStdAusFeld('edBAG.P.ExterneLiefAns'  ,'LieferantAns');
  SetStdAusFeld('edBAG.P.Aktion'          ,'Arbeitsgang');
  SetStdAusFeld('edBAG.P.Kosten.MEH'      ,'MEH');
  SetStdAusFeld('edBAG.P.Ressource'       ,'Ressource');
  SetStdAusFeld('edBAG.P.Ressource.Grp'   ,'ResGruppe');
  SetStdAusFeld('edBAG.P.Kommission'      ,'Kommission');
  SetStdAusFeld('edBAG.P.Zieladresse'     ,'Zieladresse');
  SetStdAusFeld('edBAG.P.Zielanschrift'   ,'Zielanschrift');
  SetStdAusFeld('edBAG.P.Status'          ,'Status');


//  erx # RecRead(702,0,0,cZList1->wpdbrecid);
//  if (erx<>_rOK) then RecBufClear(702);
  // kein Einsatz auswählen
//xxx  cZList2->wpdbrecid      # 0;
//  cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);

  // Fertigungen dieser Produktion anzeigen
  if (BAG.P.Nummer<>0) then begin

    cZList3->wpAutoUpdate   # false;
    cZList3->wpdbFileNo     # 702;
    cZList3->wpdbKeyNo      # 4;
    cZList3->wpDbLinkFileNo # 703;
    cZList3->wpAutoUpdate   # true;

/*** xxx
    vFilter # cZList3->wpDbFilter;
    if (vFilter<>0) then begin
      RecFilterDestroy(vFilter);
      vFilter # 0;
    end;
    cZList3->wpDbFilter # vFilter;
***/
// xxx    cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst );

    if (Mode=c_ModeList) then BA1_P_Data:UpdateSort();
  end;

  App_Main:Refreshmode();
end;


//========================================================================
//  IO_EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub IO_EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vFilter : int;
  vHdl    : int;
  vTmp    : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (BAG.P.Nummer=0) or (BAG.P.Nummer=999999999) then RETURN false;
  if (Mode=c_ModeDelete) then RETURN false;


  $LB.List2->wpColFg # _WinCollightRed;
  $LB.List1->wpColFg # _WinColParent;
  $LB.List3->wpColFg # _WinColParent;
  ShowInfo(701);
  gZLList # cZList2;

  vTmp # Winsearch(gMDI,'NB.Page1');
  if (vTmp<>0) and ( $Label.Main->wpCustom<>'NB.Input') then begin
    vTmp->wpname # $Label.Main->wpCustom;
  end;
  vTmp # Winsearch(gMDI,'NB.Input');
  if (vTmp<>0) then begin
    vTmp->wpdisabled # n;
    vTmp->wpname # 'NB.Page1';
  end;
  vTmp # Winsearch(gMDI,'NB.Position');
  if (vTmp<>0) then vTmp->wpdisabled # y;
  vTmp # Winsearch(gMDI,'NB.Fertigung');
  if (vTmp<>0) then vTmp->wpdisabled # y;

  $Label.Main->wpCustom # 'NB.Input';
  gPrefix # 'BA1_IO_I';
  gFile # 701;

  gMenuName # cMenuName2;   // Menü setzen
  gFrmMain->wpMenuname # gMenuName;
  if (gPrefix<>'') then begin
    vHdl # gFrmMain->WinInfo(_WinMenu);
    Lib_SFX:CreateMenu(vHdl, gPrefix);
  end;
  Lib_GuiCom2:RefreshQB(gFrmMain->WinInfo(_WinMenu));

  // Pflichtfelder...
  if (w_Obj4Auswahl<>0) then begin
    Lib_Ramsort:KillList(w_Obj4Auswahl);  // Liste "zerstoeren"
    w_Obj4Auswahl # 0;
    Lib_Pflichtfelder:PflichtfelderListeFuellen(w_Name,var w_Pflichtfeld, var w_Obj4auswahl, y);
  end;
  SetStdAusFeld('edEinsatztyp'                ,'Einsatztyp');
  SetStdAusFeld('edBAG.IO.Materialnr'         ,'Material');
  SetStdAusFeld('edBAG.IO.Artikelnr_Art'      ,'Artikel_Art');
  SetStdAusFeld('edBAG.IO.Artikelnr_Theo'     ,'Artikel_Theo');
  SetStdAusFeld('edBAG.IO.Charge'             ,'Charge');
  SetStdAusFeld('edBAG.IO.MaterialnrVSB'      ,'MaterialVSB');
  SetStdAusFeld('edBAG.IO.VonID'              ,'Vorgaenger');//2');
  SetStdAusFeld('edBAG.IO.Warengruppe_Theo'   ,'WGR');
  SetStdAusFeld('edBAG.IO.Guete_Theo'         ,'Guete');
  SetStdAusFeld('edBAG.IO.GuetenStufe_Theo'   ,'GuetenStufe');
  SetStdAusFeld('edBAG.IO.Lageradresse_Theo'  ,'Lageradresse');
  SetStdAusFeld('edBAG.IO.Lageranschr_Theo'   ,'Lageranschrift');
  SetStdAusFeld('edBAG.IO.Art.Zustand'        ,'Zustand');
  SetStdAusFeld('edBAG.IO.Lageradresse_Art'   ,'Lageradresse');
  SetStdAusFeld('edBAG.IO.Lageranschr_Art'    ,'Lageranschrift');


  // 1zu1-Arbeitsgang?
/* xxx  if ("BAG.P.Typ.1In-1OutYN") then begin
*** xxx
    if (cZList3->wpDbFilter<>0) then begin
      RecFilterdestroy(cZList3->wpDbFilter);
      cZList3->wpDbFilter # 0;
    end;
***
    // Fertigungen dieser Produktion+Einsatz anzeigen

    cZList3->wpdbFileNo     # 702;
    cZList3->wpdbKeyNo      # 4;
    cZList3->wpDbLinkFileNo # 703;
    cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst);
    cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst);
  end;
*/
  App_Main:Refreshmode();

end;


//========================================================================
//  EvtMenuInitPopup
//          Aufbau des Rechtsklick-Menüs
//========================================================================
sub EvtMenuInitPopup(
  aEvt                 : event;    // Ereignis
  aMenuItem            : handle;   // Auslösender Menüeintrag
) : logic;
begin

  if (aEvt:Obj=cZList3) then
    RETURN BA1_F_Main:EvtMenuInitPopup(aEvt, aMenuItem);
    
  if (aEvt:Obj=cZList4) then
    RETURN BA1_IO_O_Main:EvtMenuInitPopup(aEvt, aMenuItem);
 
  RETURN false;
end;


//========================================================================
//  F_EvtFocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub F_EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
local begin
  vHdl  : int;
  vTmp  : int;
end;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  // wenn View beim Unterfenster der Fertigung (Splaten, Tafel...) KEIN Focus wieder auf die ZL zulassen
  if (Mode=c_ModeView) then RETURN false;

  if (BAG.P.Nummer=0) or (BAG.P.Nummer=999999999) then RETURN false;
  if (w_Child<>0) then RETURN false;
  if (Mode=c_ModeDelete) then RETURN false;

// xxx  cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  $LB.List3->wpColFg # _WinCollightRed;
  $LB.List1->wpColFg # _WinColParent;
  $LB.List2->wpColFg # _WinColParent;
  ShowInfo(703);
  gZLList # cZList3;

  gMenuName # cMenuName3;   // Menü setzen
  gFrmMain->wpMenuname # gMenuName;

  vTmp # Winsearch(gMDI,'NB.Page1');
  if (vTmp<>0) and ( $Label.Main->wpCustom<>'NB.Fertigung') then begin
    vTmp->wpname # $Label.Main->wpCustom;
  end;
  vTmp # Winsearch(gMDI,'NB.Fertigung');
  if (vTmp<>0) then begin
    vTmp->wpdisabled # n;
    vTmp->wpname # 'NB.Page1';
  end;

  vTmp # Winsearch(gMDI,'NB.Input');
  if (vTmp<>0) then vTmp->wpdisabled # y;
  vTmp # Winsearch(gMDI,'NB.Position');
  if (vTmp<>0) then vTmp->wpdisabled # y;

  $Label.Main->wpCustom # 'NB.Fertigung';
  gPrefix # 'BA1_F';
  gFile # 703;
  if (gPrefix<>'') then begin
    vHdl # gFrmMain->WinInfo(_WinMenu);
    Lib_SFX:CreateMenu(vHdl, gPrefix);
  end;
  Lib_GuiCom2:RefreshQB(gFrmMain->WinInfo(_WinMenu));

  App_Main:Refreshmode();

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

  case ($Label.Main->wpcustom) of

    'NB.Position' : begin
      gPrefix # 'BA1_P';
      Call('BA1_P_Main:EvtFocusInit',aEvt,aFocusObject);
      end;

    'NB.Input' : begin
      gPrefix # 'BA1_IO_I';
      Call('BA1_IO_I_Main:EvtFocusInit',aEvt,aFocusObject);
      end;

    'NB.Fertigung' : begin
      gPrefix # 'BA1_F';
      Call('BA1_F_Main:EvtFocusInit',aEvt,aFocusObject);
      end;
  end;

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
  RETURN true;
end;


//========================================================================
// EvtChanged
//            Feldveränderungen
//========================================================================
sub EvtChanged
(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  $Graph->wpzoomfactor # -($IE.Zoom->wpcaptionint);
end;


//========================================================================
//  RefreshMode
//              Setzt alle Menüs/Toolbars/Buttons passend zum Modus
//========================================================================
sub RefreshMode(opt aNoRefresh : logic);
local begin
  d_MenuItem  : int;
  vHdl        : int;
end
begin
  gMenu # gFrmMain->WinInfo(_WinMenu);

  // Button & Menßs sperren
  vHdl # gMdi->WinSearch('Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Search');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMdi->WinSearch('Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;
  vHdl # gMenu->WinSearch('Mnu.Mark');
  if (vHdl <> 0) then
    vHdl->wpDisabled # y;

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
  vMode   : alpha;
  vParent : int;
  vL      : float;
  vOK     : logic;
  vAnz    : int;
end;
begin
  if (Mode=c_ModeList) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  // 25.01.2022 AH: direktes Einbinden
  if (aMenuItem->wpName=*'Ktx.InsertNeuePosNachFert*') then begin
    cZList1->winfocusset(true);
    w_Command # aMenuItem->wpName;
    App_Main:Action(c_Modenew);
    RETURN true;
  end;
  
  // 22.07.2020 AH:
  if (aMenuItem->wpName=*'Ktx.InsertPosNachFert*') then begin
    erx # RecRead(703, 0, _recId, cZList3->wpdbRecId);      // Fertigung holen
    if (erx>_rLocked) then RETURN true;
    // WeiterDurchPos(6251,1,1,9); Pos9 nach 6251/1/1
    vOK # BA1_F_Subs:WeiterDurchPos(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, cnvia(StrCut(aMenuItem->wpname,21,5)));
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    ErrorOutput;
    if (vOK) then Msg(999998,'',0,0,0);
    RETURN true;
  end;

  // 22.07.2020 AH:
  if (aMenuItem->wpName=*'Ktx.FertExportNachPos*') then begin
    erx # RecRead(703, 0, _recId, cZList3->wpdbRecId);      // Fertigung holen
    if (erx>_rLocked) then RETURN true;
    // ImportFert(6251,10, 1,2); 1/2 -> 10
    vOK # BA1_F_Subs:ImportFert(BAG.F.Nummer, cnvia(StrCut(aMenuItem->wpname,22,5)), BAG.F.Position, BAG.F.Fertigung);
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    ErrorOutput;
    if (vOK) then Msg(999998,'',0,0,0);
    RETURN true;
  end;

  if (StrCut(aMenuItem->wpName,1,15)='Ktx.FertNachPos') then begin
    erx # RecRead(703, 0, _recId, cZList3->wpdbRecId);      // Fertigung holen
    if (erx>_rLocked) then RETURN true;
    vOK # BA1_F_Data:FertNachPos(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, BAG.P.Nummer, cnvia(StrCut(aMenuItem->wpname,15,5)));
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
//    cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    ErrorOutput;
    if (vOK) then Msg(999998,'',0,0,0);
    RETURN true;
  end;

  if (aMenuItem->wpName='Ktx.FertNachQTeil') then begin
    if (Dlg_Standard:Anzahl(Translate('Teilungszahl'),var vAnz)=false) then RETURN true;
    erx # RecRead(703, 0, _recId, cZList3->wpdbRecId);      // Fertigung holen
    if (erx>_rLocked) then RETURN true;
    vOK # BA1_F_Data:FertNachQTeil(BAG.F.Nummer, BAG.F.Position, BAG.F.Fertigung, vAnz);
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    ErrorOutput;
    if (vOK) then Msg(999998,'',0,0,0);
    RETURN true;
  end;


  if (StrCut(aMenuItem->wpName,1,15)='Ktx.AusbNachPos') then begin
    erx # RecRead(701, 0, _recId, cZList4->wpdbRecId);      // Ausbringung holen
    if (erx>_rLocked) then RETURN true;
    vOK # BA1_IO_Data:OutputNachPos(BAG.IO.Nummer, BAG.IO.ID, BAG.P.Nummer, cnvia(StrCut(aMenuItem->wpname,15,5)));
    cZList1->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
//    cZList3->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
    ErrorOutput;
    if (vOK) then Msg(999998,'',0,0,0);
    RETURN true;
  end;

  case (aMenuItem->wpName) of

//    'Mnu.Ktx.AusWorkbench' : begin
//      BA1_IO_I_Main:DropAllMarked();
//    end;

    'Mnu.Druck.Lohnformular' : begin
      RecRead(702,1,0);
      BA1_P_Subs:Print_Lohnformular(BAG.P.Nummer, BAG.P.Position);
    end;


    'Mnu.Ktx.Errechnen' : begin

      // Material
      begin
        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Stk_Mat') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.Stk # Lib_Berechnungen:Stk_aus_KgDBLWgrArt(BAG.IO.Plan.Out.GewN,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstNetto_Mat->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.Stk # CnvIF(CnvFa($lb.IO.IstStk_Mat->wpCaption) * BAG.IO.Plan.Out.GewN / CnvFa($lb.IO.IstNetto_Mat->wpCaption));
          $edBAG.IO.Plan.Out.Stk_Mat->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewN_Mat') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewN # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_Mat->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewN # CnvFa($lb.IO.IstNetto_Mat->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_Mat->wpCaption);
          BAG.IO.Plan.Out.GewN # Rnd(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewN_Mat->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewB_Mat') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewB # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_Mat->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewB # CnvFa($lb.IO.IstBrutto_Mat->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_Mat->wpCaption);
          BAG.IO.Plan.Out.GewB # Rnd(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewB_Mat->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Meng_Mat') then begin
          // Mengengerechnung abhängig von Einstellung und Mengeneinheit
          if (BAG.IO.MEH.Out='qm') then begin
            // Korrekturen bei der Berechnung; Berücksichtigung der Ringlänge [29.10.2009/PW]
            if ( "BAG.IO.Länge" != 0.0 ) then
              vL # "BAG.IO.Länge"
            else
              vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
            BAG.IO.Plan.Out.Meng  # Rnd( cnvfi(BAG.IO.Plan.Out.Stk) * BAG.IO.Breite * vL / 1000000.0 , Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='m') then begin
//            vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, ), "Wgr.TränenKgProQM");
            vL # "BAG.IO.Länge" * cnvfi(BAG.IO.Plan.Out.Stk);
            BAG.IO.Plan.Out.Meng  # Rnd( vL / 1000.0, Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='kg') then begin
            BAG.IO.Plan.Out.Meng  # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          end;
          // berechnete Menge wurde in BAG.IO.Plan.In.Menge geschrieben und mit BAG.IO.Plan.In.Stk berechnet. (In->Out)
          BAG.IO.Plan.Out.Meng # Rnd(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge);
          $edBAG.IO.Plan.Out.Meng_Mat->winupdate(_WinUpdFld2Obj);
        end;
      end; // Material


      // Artikel
      begin
        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Stk_Art') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.Stk # Lib_Berechnungen:Stk_aus_KgDBLWgrArt(BAG.IO.Plan.Out.GewN,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstGewicht_Art->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.Stk # CnvIF(CnvFa($lb.IO.IstStk_Art->wpCaption) * BAG.IO.Plan.Out.GewN / CnvFa($lb.IO.IstGewicht_Art->wpCaption));
          $edBAG.IO.Plan.Out.Stk_Art->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewN_Art') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewN # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_Art->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewN # CnvFa($lb.IO.IstGewicht_Art->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_Art->wpCaption);
          BAG.IO.Plan.Out.GewN # Rnd(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewN_Art->winupdate(_WinUpdFld2Obj);
        end;
      end; // Artikel


      // BAG
      begin
        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Stk_BAG') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.Stk # Lib_Berechnungen:Stk_aus_KgDBLWgrArt(BAG.IO.Plan.Out.GewN,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstNetto_BAG->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.Stk # CnvIF(CnvFa($lb.IO.IstStk_BAG->wpCaption) * BAG.IO.Plan.Out.GewN / CnvFa($lb.IO.IstNetto_BAG->wpCaption));
          $edBAG.IO.Plan.Out.Stk_BAG->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewN_BAG') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewN # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_BAG->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewN # CnvFa($lb.IO.IstNetto_BAG->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_BAG->wpCaption);
          BAG.IO.Plan.Out.GewN # Rnd(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewN_BAG->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewB_BAG') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewB # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_BAG->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewB # CnvFa($lb.IO.IstBrutto_BAG->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_BAG->wpCaption);
          BAG.IO.Plan.Out.GewB # Rnd(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewB_BAG->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Meng_BAG') then begin
          // Mengengerechnung abhängig von Einstellung und Mengeneinheit
          if (BAG.IO.MEH.Out='qm') then begin
            // Korrekturen bei der Berechnung; Berücksichtigung der Ringlänge [29.10.2009/PW]
            if ( "BAG.IO.Länge" != 0.0 ) then
              vL # "BAG.IO.Länge"
            else
              vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
            BAG.IO.Plan.Out.Meng  # Rnd( cnvfi(BAG.IO.Plan.Out.Stk) * BAG.IO.Breite * vL / 1000000.0 , Set.Stellen.Menge);
          end
          else
            BAG.IO.Plan.Out.Meng  # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          // berechnete Menge wurde in BAG.IO.Plan.In.Menge geschrieben und mit BAG.IO.Plan.In.Stk berechnet. (In->Out)
          BAG.IO.Plan.Out.Meng # Rnd(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge);
          $edBAG.IO.Plan.Out.Meng_BAG->winupdate(_WinUpdFld2Obj);
        end;

      end; // BAG


      // VSB
      begin
        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Stk_VSB') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.Stk # Lib_Berechnungen:Stk_aus_KgDBLWgrArt(BAG.IO.Plan.Out.GewN,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstNetto_VSB->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.Stk # CnvIF(CnvFa($lb.IO.IstStk_VSB->wpCaption) * BAG.IO.Plan.Out.GewN / CnvFa($lb.IO.IstNetto_VSB->wpCaption));
          $edBAG.IO.Plan.Out.Stk_VSB->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewN_VSB') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewN # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_VSB->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewN # CnvFa($lb.IO.IstNetto_VSB->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_VSB->wpCaption);
          BAG.IO.Plan.Out.GewN # Rnd(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewN_VSB->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewB_VSB') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewB # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if (CnvFa($lb.IO.IstStk_VSB->wpCaption) <> 0.0) then
            BAG.IO.Plan.Out.GewB # CnvFa($lb.IO.IstBrutto_VSB->wpCaption) * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFa($lb.IO.IstStk_VSB->wpCaption);
          BAG.IO.Plan.Out.GewB # Rnd(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewB_VSB->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Meng_VSB') then begin
          // Mengengerechnung abhängig von Einstellung und Mengeneinheit
          if (BAG.IO.MEH.Out='qm') then begin
            // Korrekturen bei der Berechnung; Berücksichtigung der Ringlänge [29.10.2009/PW]
            if ( "BAG.IO.Länge" != 0.0 ) then
              vL # "BAG.IO.Länge"
            else
              vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
            BAG.IO.Plan.Out.Meng  # Rnd( cnvfi(BAG.IO.Plan.Out.Stk) * BAG.IO.Breite * vL / 1000000.0 , Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='m') then begin
//            vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, ), "Wgr.TränenKgProQM");
            vL # "BAG.IO.Länge" * cnvfi(BAG.IO.Plan.Out.Stk);
            BAG.IO.Plan.Out.Meng  # Rnd( vL / 1000.0, Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='kg') then begin
            BAG.IO.Plan.Out.Meng  # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          end;
          // berechnete Menge wurde in BAG.IO.Plan.In.Menge geschrieben und mit BAG.IO.Plan.In.Stk berechnet. (In->Out)
          BAG.IO.Plan.Out.Meng # Rnd(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge);

          $edBAG.IO.Plan.Out.Meng_VSB->winupdate(_WinUpdFld2Obj);
        end;

      end; // VSB


      // Theorie
      begin
        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Stk_Theo') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.Stk # Lib_Berechnungen:Stk_aus_KgDBLWgrArt(BAG.IO.Plan.Out.GewN,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if ($edBAG.IO.Plan.In.GewN_Theo->wpCaptionFloat <> 0.0) then
            BAG.IO.Plan.Out.Stk # CnvIF(CnvFi($edBAG.IO.Plan.In.Stk_Theo->wpCaptionInt) * BAG.IO.Plan.Out.GewN / $edBAG.IO.Plan.In.GewN_Theo->wpCaptionFloat);
          $edBAG.IO.Plan.Out.Stk_Theo->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewN_Theo') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewN # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if ($edBAG.IO.Plan.In.Stk_Theo->wpCaptionInt <> 0) then
            BAG.IO.Plan.Out.GewN # $edBAG.IO.Plan.In.GewN_Theo->wpCaptionFloat * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFI($edBAG.IO.Plan.In.Stk_Theo->wpCaptionInt);
          BAG.IO.Plan.Out.GewN # Rnd(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewN_Theo->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.GewB_Theo') then begin
          if ("BAG.IO.Länge" <> 0.0) then
            BAG.IO.Plan.Out.GewB # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          else if ($edBAG.IO.Plan.In.Stk_Theo->wpCaptionInt <> 0) then
            BAG.IO.Plan.Out.GewB # $edBAG.IO.Plan.In.GewB_Theo->wpCaptionFloat * CnvFi(BAG.IO.Plan.Out.Stk) / CnvFi($edBAG.IO.Plan.In.Stk_Theo->wpCaptionInt);
          BAG.IO.Plan.Out.GewB # Rnd(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
          $edBAG.IO.Plan.Out.GewB_Theo->winupdate(_WinUpdFld2Obj);
        end;

        if (aEvt:Obj->wpname='edBAG.IO.Plan.Out.Meng_Theo') then begin
          // Mengengerechnung abhängig von Einstellung und Mengeneinheit
          if (BAG.IO.MEH.Out='qm') then begin
            // Korrekturen bei der Berechnung; Berücksichtigung der Ringlänge [29.10.2009/PW]
            if ( "BAG.IO.Länge" != 0.0 ) then
              vL # "BAG.IO.Länge"
            else
              vL # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.Out.GewN, BAG.IO.PLan.Out.Stk, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKgProQM");
            BAG.IO.Plan.Out.Meng  # Rnd( cnvfi(BAG.IO.Plan.Out.Stk) * BAG.IO.Breite * vL / 1000000.0 , Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='m') then begin
            vL # "BAG.IO.Länge" * cnvfi(BAG.IO.Plan.Out.Stk);
            BAG.IO.Plan.Out.Meng  # Rnd( vL / 1000.0, Set.Stellen.Menge);
          end
          else if (BAG.IO.MEH.Out='kg') then begin
            BAG.IO.Plan.Out.Meng  # Lib_Berechnungen:KG_aus_StkDBLWgrArt(BAG.IO.Plan.Out.Stk,BAG.IO.Dicke, BAG.IO.Breite, "BAG.IO.Länge", BAG.IO.Warengruppe, "BAG.IO.Güte", BAG.IO.Artikelnr);
          end;
          // berechnete Menge wurde in BAG.IO.Plan.In.Menge geschrieben und mit BAG.IO.Plan.In.Stk berechnet. (In->Out)
          BAG.IO.Plan.Out.Meng # Rnd(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge);

          $edBAG.IO.Plan.Out.Meng_Theo->winupdate(_WinUpdFld2Obj);
        end;

      end; // Theorie

    end;

  end; // case

end;


//========================================================================
//  P_EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub P_EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  Erx     : int;
  vFilter : int;
  vButton : int;
end;
begin
//  $RL.BA1.Input->wpColBkgApp # RGB(cnvif(rnd(Random()*200.0)),cnvif(rnd(Random()*200.0)),cnvif(rnd(Random()*200.0)));

  if (aRecid=0) then RETURN true;
//  RecRead(gFile,0,_recid,aRecID);
//  RefreshMode(y);

  erx # RecRead(702,0,0,cZList1->wpdbrecid);
  if (erx>_rLocked) then begin
    RecBufClear(702);
    RecBufClear(703);
    RecBufClear(704);
    RecBufClear(705);
    RecBufClear(706);
  end;
  if (BAG.P.Nummer=0) then BAG.P.Nummer # 999999999;

  if (WinFocusGet()=cZList1) then begin
    ShowInfo(702);
  end;

  BA1_P_Main:RefreshMode(y);

  // VSB oder TEST Arbeitsgang?
  cZList3->wpdisabled # (BAG.P.Typ.VSBYN) or (BAG.P.Aktion=c_BAG_Check);
  cZList3->wpVisible  # !((BAG.P.Typ.VSBYN) or (BAG.P.Aktion=c_BAG_Check));

  // 28.01.2020 AH:
  vButton # gMdi->WinSearch('Attachment');
  if (vButton <> 0) then begin
    if (Mode=c_ModeList) then
      RecRead(gFile,0,0,gZLList->wpdbrecid);
    if (RunAFX('Anh.Check',aint(gFile))>=0) then begin
      Erx # Anh_Data:Check(gFile);
    end;
    if (erx < _rNoKey) then
      vButton->wpImageTileUSer # 185+1
    else
      vButton->wpImageTileuser # 185;
    vFilter->RecFilterDestroy();
  end;

  cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  cZList4->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);

//  $RL.BA1.Fertigung->Winupdate(_WinUpdOn, _WinLstfromfirst);
end;


//========================================================================
//  IO_EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub IO_EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
begin
  RecRead(701,0,0,cZList2->wpdbrecid);
  if (WinFocusGet()=cZList2) then begin
    ShowInfo(701);

    // Fertigungen dieser Produktion+Einsatz anzeigen
//xxx    cZList3->wpdbFileNo     # 702;
//    cZList3->wpdbKeyNo      # 4;
//    cZList3->wpDbLinkFileNo # 703;

//xxx    cZList3->wpdbrecid # 0;
//    cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst);
    cZList4->Winupdate(_WinUpdOn, _WinLstfromfirst);
  end;
end;


//========================================================================
//  F_EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub F_EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  vHdl  : int;

  vSchopfEditYN  : logic;
end;
begin
  RecRead(703,0,0,cZList3->wpdbrecid);
  if (WinFocusGet()=cZList3) then begin
    ShowInfo(703);

    // ST 2012-08-30: Edit für 999 aktiviert 1326/284
    Arg.Aktion2 # Bag.P.Aktion;
    RecRead(828,1,0);
    vSchopfEditYN #  (Arg.Aktion = c_BAG_Divers) OR
                     (Arg.Aktion = c_BAG_AbCoil) OR
                     (Arg.Aktion = c_BAG_Spalt)  OR
                     (Arg.Aktion = c_BAG_Tafel);

    vHdl # gMdi->WinSearch('New');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);
    // Menü sperren
    vHdl # gMenu->WinSearch('Mnu.New');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Anlegen]=n);

    vHdl # gMdi->WinSearch('Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or (Rechte[Rgt_BAG_Aendern]=n) or
                          ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false));//(BAG.F.AutomatischYN) or (BAG.F.Fertigung=999);
    vHdl # gMenu->WinSearch('Mnu.Edit');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or (Rechte[Rgt_BAG_Aendern]=n) or
                          ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false));//(BAG.F.AutomatischYN) or (BAG.F.Fertigung=999) ;
    vHdl # gMenu->WinSearch('Mnu.Edit2');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Versand) or (Rechte[Rgt_BAG_Aendern]=n) or
                         ((Bag.F.Fertigung = 999) AND (vSchopfEditYN=false));//(BAG.F.AutomatischYN) or (BAG.F.Fertigung=999);

    vHdl # gMdi->WinSearch('Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
    // Menü sperren
    vHdl # gMenu->WinSearch('Mnu.Delete');
    if (vHdl <> 0) then
      vHdl->wpDisabled # (vHdl->wpDisabled) or (Rechte[Rgt_BAG_Loeschen]=n);
  end

end;


//========================================================================
//  EvtPageSelectStart
//                Seitenauswahl von Notebooks
//========================================================================
sub EvtPageSelectStart(
  aEvt                  : event;        // Ereignis
  aPage                 : int;
  aSelecting            : logic;
) : logic
begin

  if (aPage->wpcustom='Fertigung') and (aSelecting) then begin
    if (BAG.F.AutomatischYN) then RETURN false;
    if (RecRead(gFile,0,0,gZLList->wpdbrecid)<=_rLocked) then BA1_F_Main:Auswahl('Detail');
    RETURN false;
  end;


  if (aPage->wpcustom='Input') and (aSelecting) then begin
//debugx('A' + Aint(Bag.IO.nummer));
    RecRead(701,0,0,cZList2->wpdbrecid);
//debugx('B' + Aint(Bag.IO.nummer));
  end;

  RETURN App_Main:EvtPageSelect(aEvt, aPage, aSelecting);
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
local begin
  vFile       : int;
  vTextName   : alpha(200);
  vBildName   : alpha(200);
  vPlainName  : alpha(200);
end;
begin

  if (aPage->wpname='NB.Graph') and (aSelecting) then begin

//    if (FsiAttributes('c:\graph\dot.exe')<0) then begin
//    if (FsiAttributes(Set.Graph.Exe.Datei)<0) then begin
//      Msg(998007,'',0,0,0);
//      RETURN false;
//    end;

    FsiPathCreate(_Sys->spPathTemp+'StahlControl');
    FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');
    vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
    vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

    Mode # c_modeview;

    // Graph deaktivieren
    $Graph->wpcaption # '';

    // Graphtext erzeugen
//    BA1_Graph:BuildText('c:\graph\graph.txt');
    BA1_Graph:BuildText(vTextName);

    // Graph erstellen
//    SysExecute('c:\programme\att\graphviz\bin\fdp.exe','-Tjpg -oc:\graph\Graph.jpg c:\graph\graph.txt',_execminimized|_execwait);
//    SysExecute('c:\graph\dot.exe','-Tjpg -oc:\graph\Graph.jpg c:\graph\graph.txt',_execminimized|_execwait);
//    SysExecute(set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
//    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

  //  auch als PLAIN?
  if (vPlainName<>'') then
    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tplain -o'+vPlainName+' -Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
  else
    SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

    // Graph derstellen
    $Graph->wpcaption # '*'+vBildName;

    if (vPlainName<>'') then begin
      Lib_Graph:CreateGraphFromPlain(0, $Graph, 0, null, vPlainName, false);
    end;

  end;

  RETURN true;

end;


//========================================================================
//  EvtClicked
//              Mausklick auf Buttons
//========================================================================
sub EvtClicked(
  aEvt                  : event;        // Ereignis
) : logic
begin

  if (gPrefix='BA1_F') then
    RETURN BA1_F_Main:EvtClicked(aEvt);

  RETURN App_Main:EvtClicked(aEvt);
end;


/*** Workaround für autoamtisches F9
//========================================================================
// EvtTimer
//
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerId              : int;
): logic
local begin
  vParent : int;
  vA    : alpha;
  vMode : alpha;
end;
begin

  if (aTimerID=gTimer2) then begin
    gTimer2->SysTimerClose();
    gTimer2 # 0;
    w_TimerVar # '';
debugx('StartF9 A ' + Aint(Bag.IO.Nummer));
    Call(gPrefix+'_Main:Auswahl','Einsatztyp');
debugx('StartF9 B ' + Aint(Bag.IO.Nummer));
    end
  else begin
    App_Main:EvtTimer(aEvt, aTimerId);
  end;

  RETURN true;
end;
***/

//========================================================================
// EvtClose
//          Schliessen eines Fensters
//========================================================================
sub EvtClose(
  aEvt                  : event;        // Ereignis
): logic
local begin
  Erx     : int;
  vHdl    : int;
  vList   : int;
  vOK     : logic;
end;
begin

  vHdl # WinSearch(aEvt:Obj, 'lb.zuAuftragsList');
  if (vHdl<>0) then vList # cnvia(vHdl->wpcustom);
  if (vList<>0) then begin
    erx # Msg(702017,'',_WinIcoQuestion,_WinDialogYesNoCancel,1);   // auch ABBRUCH möglich 23.01.2015
    if (erx=_WinIdCancel) then begin
      // MUSTER zum Nicht-Schliessen von Fenster
      Mode # c_modelist;
      App_Main:Refreshmode();
      RETURN false;
    end;

    if (erx=_WinIdYes) then begin
      erx # RecLink(702,700,1,_RecFirst);   // Arbeitsgänge loopen
      vOK # y;
      WHILE (erx<=_rLocked) and (vOK) do begin
        vOK # BA1_P_Data:AutoVSB()
        erx # RecLink(702,700,1,_RecNext);
      END;
    end;
  end;


  Lib_GuiCom:RememberList(cZList1);
  Lib_GuiCom:RememberList(cZList2);
  Lib_GuiCom:RememberList(cZList3);

  BA1_P_Data:ComboClosedCheck();

  // Ankerfunktion
  RunAFX('BAG.Combo.EvtClose','');

/*** xxx
  if (cZList3->wpDbFilter<>0) then begin
    RecFilterdestroy(cZList3->wpDbFilter);
    cZList3->wpDbFilter # 0;
  end;
***/
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
  vRect     : rect;
  vHdl      : int;
end
begin

  // WORKAROUND
  if (gMDI->wpname<>w_Name) then RETURN false;

  if (aFlags & _WinPosSized != 0) then begin

    // Hauptfensterelemente
    vRect           # $gs.Main->wpArea;
    //vRect:right     # aRect:right-aRect:left-4;
    //vRect:bottom    # aRect:bottom-aRect:Top-28;
    vRect:right     # aRect:right-aRect:left;   // 10.04.2020 AH
    vRect:bottom    # aRect:bottom-aRect:Top;
    $gs.Main->wparea # vRect;

    vRect             # $gs.Main2->wpArea;
    vRect:right       # aRect:right-aRect:left;
    vRect:bottom      # aRect:bottom-aRect:Top;
    $gs.Main2->wparea # vRect;

    // Graph Bild mit der gleichen Zeichenbereich skalieren, wie die Hauptübersicht
    vRect # $Graph->wparea;
    vRect:right     # aRect:right-aRect:left-4;
    vRect:bottom    # aRect:bottom-aRect:Top-28-w_QBHeight;
    $Graph->wparea # vRect;
    
    //vHdl # Winsearch(aEvt:Obj,'gt.Ausbringung');
    vHdl # Winsearch(aEvt:Obj,'gs.Main2');
    if (vHdl<>0) then begin
      vRect           # vHdl->wpArea;
      vRect:bottom    # (aRect:bottom-aRect:Top-28- w_QBHeight);
      vHdl->wparea    # vRect;
    end;
  end;
	RETURN (true);
end;



//========================================================================
//========================================================================
sub RefreshAll(opt aMDI : int;);
local begin
  vA    : alpha;
  vCmd  : alpha;
end;
begin
  if (aMDI<>0) then WinsearchPath(aMDI);
  
  $lb.BA.Nummer->wpcaption # aint(BAG.nummer);
  $lb.P.Nummer2->wpcaption # aint(BAG.nummer);
  $lb.IO.Nummer->wpcaption # aint(BAG.nummer);
  $Lb.BA.Bemerkung->wpcaption # BAG.Bemerkung;

  vA # Str_Token(WinEvtProcNameGet(gMDI, _Winevtinit),':',1);
  if (vA<>'') then begin
    vA # vA + ':RePos';
    vCmd # w_Command;
    Call(vA, '', aMDI);
  end;

  cZList1->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  cZList2->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  cZList3->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);
  cZList4->Winupdate(_WinUpdOn, _WinLstfromfirst | _WinLstRecDoSelect);

  if (vCmd<>'') then begin
    Call(vA, vCmd, aMDI);
  end;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================