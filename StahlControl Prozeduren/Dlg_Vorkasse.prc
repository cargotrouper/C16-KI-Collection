@A+
//==== Business-Control ==================================================
//
//  Prozedur    Dlg_Vorkasse
//                    OHNE E_R_G
//  Info
//
//
//  07.04.2008  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Starten(aKunde : int)
//
//========================================================================
@I:Def_global
@I:Def_Aktionen

//========================================================================
// Zuweisen
//
//========================================================================
sub Zuweisen(
  aAuf  : int;
  aWert : float)
local begin
  Erx   : int;
  vX    : float;
  vOK   : logic;
end;
begin

  if (aWert<=0.0) then RETURN;

  Auf.Nummer # aAuf;
  Erx # RecRead(400,1,0);
  if (aAuf=0) or (Erx>=_rLocked) or (Auf.Vorgangstyp<>c_AUF) then begin
    Msg(465002,'',0,0,0);
    RETURN;
  end;

  // Währungen umrechnen von HW in FW
  Wae_Umrechnen(aWert, 1, var vX, "Auf.Währung");
  RecLink(814,400,8,_recFirsT);   // Währung holen

  Erx # RecLink(401,400,9,_recFirst);   // Positionen loopen
  WHILE (Erx<=_rLocked) do begin

    if ("Auf.P.Löschmarker"='') then begin

      if (Msg(465001,AInt(auf.p.nummer)+'|'+cnvaf(aWert),_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN;

      RecBufClear(404);
      Auf.A.Aktionstyp    # c_Akt_Kasse;
      Auf.A.Bemerkung     # c_AktBem_VorKasse;
      Auf.A.Aktionsnr     # ZEi.Nummer;
      Auf.A.Aktionspos    # 0;
      Auf.A.Aktionsdatum  # Today;
      Auf.A.TerminStart   # Today;
      Auf.A.TerminEnde    # Today;
      Auf.A.Menge         # vX;
      Auf.A.Rechnungspreis  # vX;
      Auf.A.RechPreisW1     # vX;
      Auf.A.MEH           # "Wae.Kürzel";
      //RecLink(100,400,1,_recfirst);   // Kunde holen
      //Aufx.A.Adressnummer  # Adr.Nummer;
      vOk # Auf_A_Data:NeuAnlegen()=_rOK;
      if (vOK=false) then begin
//        Error(1000+Erx,'Aktion');
        ErrorOutput;
        RETURN;
      end;

      Msg(999998,'',0,0,0); // Erfolg !!!
      RETURN;
    end;

    Erx # RecLink(401,400,9,_recNext);
  END;


  Msg(465003,'',0,0,0); // Fehler: alle gelöscht!

  RETURN;

end;


//========================================================================
// Starten
//
//========================================================================
sub Starten(aKunde : int;)
begin
  Sel.Auf.von.Nummer # 0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dlg.Vorkasse','');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// Refresh
//
//========================================================================
sub Refresh();
local begin
  Erx     : int;
  vWert   : float;
  vKasse  : float;
  vX      : float;
end;
begin

  Auf.Nummer # Sel.Auf.von.Nummer;
  Erx # RecRead(400,1,0);
  if (Erx<=_rLocked) then begin

    Erx # RecLink(401,400,9,_recFirst);   // Positionen loopen
    WHILE (Erx<=_rLocked) do begin

      Wae_Umrechnen(Auf.P.GesamtPreis, "Auf.Währung", var vX, 1);
      vWert # vWert + vX;

      Erx # RecLink(404,401,12,_RecFirst);    // Aktionen loopen
      WHILE (Erx<=_rLockeD) do begin
        if (Auf.A.Aktionstyp=c_Akt_Kasse) and ("Auf.A.Löschmarker"='') then begin
          Wae_Umrechnen(Auf.A.Menge, "Auf.Währung", var vX, 1);
          vKasse # vKasse + vX;
        end;
        Erx # RecLink(404,401,12,_RecNext);
      END;

      Erx # RecLink(401,400,9,_recNExt);
    END;
  end;

  $lbAufWert->wpcaption # cnvaf(vWert);
  $lbVorkasse->wpcaption # cnvaf(vKasse);

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
  vQ     : alpha(4000);
  vQ2    : alpha(4000);
  tErx   : int;
  //vFile  : int;
  vHdl   : int;
  vSel   : alpha;
end;
begin

  case (aMenuItem->wpName) of

    'Mnu.SelAuswahl' : begin
      RecLink(100,465,2,_recFirst); // Kunde holen
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // ehemals Selektion 401 'RECHEMPFAENGER'
      vQ  # ' LinkCount(Kopf) > 0 ';
      Lib_Sel:QInt( var vQ2, 'Auf.Rechnungsempf', '=', Adr.KundenNr);

      // Selektion aufbauen...
      vHdl # SelCreate(401, gKey);
      vHdl->SelAddLink('',400, 401, 3, 'Kopf');
      tErx # vHdl->SelDefQuery('', vQ);
      tErx # vHdl->SelDefQuery('Kopf', vQ2);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;

  end;

end;


//========================================================================
//  EvtFocusTerm
//                Fokus wechselt hier weg
//========================================================================
sub EvtFocusTerm (
  aEvt                  : event;        // Ereignis
  aFocusObj             : int           // nächstes Objekt
) : logic
begin
  Refresh();
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vAuf  : int;
  vWert : float;
  vQ     : alpha(4000);
  vQ2    : alpha(4000);
  tErx   : int;
  vHdl   : int;
  vSel   : alpha;
end;
begin

  case (aEvt:Obj->wpName) of

    'Bt.OK' : begin
      vAuf # $edAuftrag->wpcaptionint;
      vWert # $edWert->wpCaptionFloat;
      $Dlg.Vorkasse->WinClose();

      // Zuweisen...
      Zuweisen(vAuf, vWert);
    end;

    'bt.AuftragSpezi' : begin
      RecLink(100,465,2,_recFirst); // Kunde holen
      RecBufClear(401);         // ZIELBUFFER LEEREN
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.P.Verwaltung',here+':AusAuftrag');
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

      // ehemals Selektion 401 'RECHEMPFAENGER'
      vQ  # ' LinkCount(Kopf) > 0 ';
      Lib_Sel:QInt( var vQ2, 'Auf.Rechnungsempf', '=', Adr.KundenNr);

      // Selektion aufbauen...
      vHdl # SelCreate(401, gKey);
      vHdl->SelAddLink('',400, 401, 3, 'Kopf');
      tErx # vHdl->SelDefQuery('', vQ);
      tErx # vHdl->SelDefQuery('Kopf', vQ2);

      // speichern, starten und Name merken...
      w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);
      // Liste selektieren...
      gZLList->wpDbSelection # vHdl;

      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

  RETURN true;
end;


//========================================================================
//  AusAuftrag
//
//========================================================================
sub AusAuftrag()
begin

  if (gSelected<>0) then begin
    RecRead(401,0,_RecId,gSelected);
    gSelected # 0;
    // Feldübernahme
    Sel.Auf.von.Nummer # Auf.P.Nummer;
    $edAuftrag->WinUpdate(_WinUpdFld2Obj);
  end;

  $edAuftrag->Winfocusset(false);
  Refresh();

end;

//========================================================================
//========================================================================
//========================================================================