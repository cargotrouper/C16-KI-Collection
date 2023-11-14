@A+
//===== Business-Control =================================================
//
//  Prozedur    Ein_A_Data
//                        OHNE E_R_G
//  Info
//
//
//  05.02.2004  AI  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB RecalcAll() : logic
//    SUB NeuAmKopfAnlegen(opt akeineAutoNr  : logic) : logic;
//    SUB NeuAnlegen() : logic;
//    SUB Entfernen() : logic;
//    SUB LiesAktion(aAufNr : int; aPosNr : int; aTyp : alpha; aAktNr : int; aAktPos1 : int; opt aBem : alpha; opt aDel : logic) : logic;
//    SUB ToggleLoeschmarker(aManuell : logic) : logic;
//    SUB SetSperre(aPos : int; aGrund  : alpha; aAktiv  : logic; aNurSet : logic) : int
//    SUB SperreUmsetzen() : logic
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_Rights

declare LiesAktion(aEinNr : int; aPosNr : int; aTyp : alpha; aAktNr : int; aAktPos1 : int; opt aBem : alpha; opt aDel : logic) : logic;

//========================================================================
// RecalcAll  +ERR
//
//========================================================================
sub RecalcAll() : logic;
local begin
  Erx     : int;
  vBuf504 : int;
  vProz   : float;
end;
begin

  vBuf504 # RekSave(504);

  TRANSON;

  // Position anpassen
  Erx # RecRead(501,1,_RecLock);
  If (Erx<>_rOK) then begin
    TRANSBRK;
    Error(504102,AInt(Ein.A.Nummer));
    RekRestore(vBuf504);
    RETURN false;
  end;
  Erx # RecLink(500,501,3,_recFirst);
  If (Erx>_rLocked) then begin
    TRANSBRK;
    Error(504105,AInt(Ein.A.Nummer));
    RETURN false;
  end;

  if (Ein.LiefervertragYN) then begin
    Ein.P.FM.Eingang      # 0.0;
    Ein.P.FM.Eingang.Stk  # 0;
  end;

  // ALLE AKTIONEN SUMMIEREN...
  Erx # RecLink(504,501,15,_recFirst);  // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin

    case Ein.A.Aktionstyp of

      // Abruf
      c_Akt_Abruf : begin
        // Liefervertrag minimieren
        Ein.P.FM.Eingang      # Ein.P.FM.Eingang      + Ein.A.Menge;
        Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  + "Ein.A.Stückzahl";
        vProz # Lib_Berechnungen:Prozent(Ein.P.FM.Eingang, ein.P.Menge.Wunsch);
        if (Ein.P.Aktionsmarker<>'$') and
          (vProz>="Set.Ein.WEDelEin%") then begin
          "Ein.P.Löschmarker"     # '*';
          "Ein.P.Lösch.Datum"     # today;
          "Ein.P.Lösch.Zeit"      # now;
          "Ein.P.Lösch.User"      # gUsername;
        end;
      end;

    end;

    Erx # RecLink(504,501,15,_recNext);
  END;


  Ein.P.FM.Rest # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
  Ein.P.FM.Rest.Stk # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
  if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
  if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
  Ein_Data:SumAufpreise(c_ModeEdit);
  Ein.P.Gesamtpreis # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);

  Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    RecRead(501,1,_recunlock);
    Error(504102,AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position));
    RekRestore(vBuf504);
    RETURN false;
  end;

  if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
    // Restkarte update
    if (Ein_Data:UpdateMaterial()=false) then begin
      TRANSBRK;
      RETURN False;
    end;
  end;

  TRANSOFF;

  RekRestore(vBuf504);

  RETURN true;
end;


//========================================================================
// NeuAmiKopfAnlegen
//
//========================================================================
sub NeuAmKopfAnlegen(opt akeineAutoNr  : logic) : logic;
local begin
  Erx     : int;
  vInSL   : logic;
  vInPos  : logic;
  vBuf500 : int;
  vBuf100 : int;
end;
begin
  Ein.A.Nummer        # Ein.P.Nummer;
  Ein.A.Position      # 0;

  if (Adr.Lieferantennr<>Ein.P.Lieferantennr) or (Adr.Lieferantennr=0) then begin
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,501,4,_recFirst);   // Lieferant holen
    Ein.A.Adressnummer  # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
    end
  else begin
    Ein.A.Adressnummer  # Adr.Nummer;
  end;

  Ein.A.Anlage.User   # gUserName;
  Ein.A.Anlage.Datum  # today;
  Ein.A.Anlage.Zeit   # Now;

  TRANSON;

  if (aKeineAutoNr=n) or (Ein.A.Aktion=0) then begin
    Ein.A.Aktion      # 1;
    WHILE (RecRead(504,1,_RecTest)<=_rLocked) do
      Ein.A.Aktion # Ein.A.Aktion + 1;
  end;

  Erx # RekInsert(504,0,'AUTO');    // war mal _recLock
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;
  TRANSOFF;

  RETURN true;
end;


//========================================================================
// NeuAnlegen
//
//========================================================================
sub NeuAnlegen(
  opt akeineAutoNr  : logic
  ): logic;
local begin
  Erx     : int;
  vBuf100 : int;
end;
begin
  Ein.A.Nummer      # Ein.P.Nummer;
  Ein.A.Position    # Ein.P.Position;
  Ein.A.Anlage.User # gUserName;
  //Ein.A.Aktion      # 1;


  if (Adr.Lieferantennr<>Ein.P.Lieferantennr) or (Adr.Lieferantennr=0) then begin
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,501,4,_recFirst);   // Lieferant holen
    Ein.A.Adressnummer  # vBuf100->Adr.Nummer;
    RecBufDestroy(vBuf100);
    end
  else begin
    Ein.A.Adressnummer  # Adr.Nummer;
  end;


  if (aKeineAutoNr=n) or (EIN.A.Aktion=0) then begin
    Ein.A.Aktion      # 1;
    WHILE (RecRead(504,1,_RecTest)<=_rLocked) do
      Ein.A.Aktion # Ein.A.Aktion + 1;
  end;

  Ein.A.Anlage.Datum  # today;
  Ein.A.Anlage.Zeit   # Now;
  Erx # RekInsert(504,_RecLock,'AUTO');
  if (Erx<>_rOK) then RETURN false;


  // Bestellposition updaten
  Erx # RecLink(819,501,1,_recFirst);
  If (Erx>_rLocked) then begin
    Msg(504100,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;

  // Bestellkopf holen
  Erx # RecLink(500,501,3,_recFirst);
  If (Erx>_rLocked) then begin
    Msg(504105,AInt(Ein.A.Nummer),0,0,0);
    RETURN false;
  end;


  // Position anpassen
  RecRead(501,1,_RecLock);
  RecRead(500,1,_RecLock);

  case Ein.A.Aktionstyp of
    // Abruf
    c_Akt_Abruf : begin
      if (Ein.LiefervertragYN) then begin
        // Liefervertrag minimieren
        Ein.P.FM.Eingang      # Ein.P.FM.Eingang      + Ein.A.Menge;
        Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  + "Ein.A.Stückzahl";
        Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
        Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
        if (Ein.P.FM.Rest<0.0) then Ein.P.FM.Rest # 0.0;
        if (Ein.P.FM.Rest.Stk<0) then Ein.P.FM.Rest.Stk # 0;
      end;

    end;
  end;

  // Zurückspeichern
  RekReplace(504,_recUnlock,'AUTO');
  Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504102,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;
  Erx # RekReplace(500,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504106,AInt(Ein.A.Nummer),0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Entfernen
//
//========================================================================
sub Entfernen() : logic;
local begin
  Erx : int;
end;
begin

  // Löschen
  Erx # RekDelete(504,0,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504104,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;

  // Bestellposition updaten
  Erx # RecLink(819,501,1,_recFirst);
  If (Erx>_rLocked) then begin
    Msg(504100,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;


  // Position anpassen
  RecRead(501,1,_RecLock);

  case Ein.A.Aktionstyp of
    // Abruf
    c_Akt_Abruf : begin
      // Liefervertrag minimieren
      Ein.P.FM.Eingang      # Ein.P.FM.Eingang      - Ein.A.Menge;
      Ein.P.FM.Eingang.Stk  # Ein.P.FM.Eingang.Stk  - "Ein.A.Stückzahl";
      Ein.P.FM.Rest       # Ein.P.Menge - Ein.P.FM.Eingang - Ein.P.FM.VSB -  Ein.P.FM.Ausfall;
      Ein.P.FM.Rest.Stk   # "Ein.P.Stückzahl" - Ein.P.FM.Eingang.Stk - Ein.P.FM.VSB.Stk - Ein.P.FM.Ausfall.Stk;
    end;
  end;

  Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504102,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// LiesAktion
//
//========================================================================
sub LiesAktion(
  aEinNr    : int;
  aPosNr    : int;
  aTyp      : alpha;
  aAktNr    : int;
  aAktPos1  : int;
  opt aBem  : alpha;
  opt aDel  : logic;
) : logic;
local begin
  vErx : int;
end;
begin
  vErx # _rNoRec;
  RecbufClear(504);
  Ein.A.Nummer        # aEinNr;
  Ein.A.Position      # aPosNr;
  Ein.A.AktionsTyp    # aTyp;
  Ein.A.Aktionsnr     # aAktNr;
  Ein.A.AktionsPos    # aAktPos1;
  vErx # RecRead(504,5,0);
  WHILE ((vErx=_rLocked) or (vErx=_rOk) or (vErx=_rMultikey)) and
    (Ein.A.Nummer=aEinNr) and (Ein.A.Position=aPosNr) and
    (Ein.A.AktionsTyp=aTyp) and (Ein.A.Aktionsnr=aAktNr) and (Ein.A.AktionsPos=aAktPos1) do begin

    if (aBem<>'') then
      if (aBem<>Ein.A.Bemerkung) then begin
        vErx # RecRead(504,5,_RecNext);
        CYCLE;
    end;

    if ("Ein.A.Löschmarker"='') or (aDel) then RETURN true;

    vErx # RecRead(504,5,_RecNext);
  END;

  RecbufClear(504);
  RETURN false;
end;


//========================================================================
// ToggleLoschmarker
//
//========================================================================
sub ToggleLoeschmarker() : logic;
local begin
  Erx     : int;
  vInPos  : logic;
end;
begin

  TRANSON;

  // Löschen
  RecRead(504,1,_recLock);
  if ("Ein.A.Löschmarker"='') then
    "Ein.A.Löschmarker" # '*'
  else
    "Ein.A.Löschmarker" # '';
  Erx # RekReplace(504,_recUnlock,'AUTO');
  if (Erx<>_rOk) then begin
    Msg(504104,AInt(Ein.A.Nummer)+'/'+AInt(Ein.A.Position),0,0,0);
    RETURN false;
  end;

  if (RecalcAll()=false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  SetSperre
//
//========================================================================
SUB SetSperre(
  aPos    : int;
  aGrund  : alpha;
  aAktiv  : logic;
  aNurSet : logic) : int;
begin

  if (aAktiv=false) then begin
    // ggf. Sperratktion löschen
    if (Ein_A_Data:LiesAktion(Ein.Nummer, aPos, c_Akt_Sperre, Ein.Nummer, aPos, aGrund,y)) then begin
      if ("Ein.A.Löschmarker"='') then begin
        ToggleLoeschmarker();
        RETURN -1;
      end;
    end;

    end
  else begin
    // Aktion anlegen
    if (Ein_A_Data:LiesAktion(Ein.Nummer, aPos, c_Akt_Sperre, Ein.Nummer, aPos, aGrund,y)) then begin
      if ("Ein.A.Löschmarker"='*') then begin
        if (aNurSet=falsE) then begin
          ToggleLoeschmarker();
          RETURN 1;
          end
        else begin
          RETURN 0;
        end;
      end;
      end
    else begin

      RecBufClear(504);
      Ein.A.Aktionstyp    # c_Akt_Sperre;
      Ein.A.Bemerkung     # aGrund;
      Ein.A.Aktionsnr     # Ein.Nummer;
      Ein.A.Aktionspos    # aPos;
      Ein.A.Aktionsdatum  # Today;
      Ein.A.TerminStart   # Today;
      Ein.A.TerminEnde    # Today;
      if (aPos=0) then
        NeuAmKopfAnlegen()
      else
        NeuAnlegen();

      RETURN 1;
    end;
  end;

  RETURN 0;
end;


//========================================================================
//  SperreUmsetzen
//
//========================================================================
SUB SperreUmsetzen() : logic
local begin
  vSum    : float;
  vA      : alpha(200);
end;
begin

  if (Rechte[Rgt_Ein_A_Sperre]=n) or (Ein.A.Aktionstyp<>c_Akt_Sperre) then RETURN false;

  // AFX
  if (RunAFX('Ein.A.SperreUmsetzen','')<0) then RETURN true;

  // todo bei STDsperren...

/***
    if ("Ein.A.Löschmarker"='') then begin
      vA # 'Wollen Sie den Auftrag über '+anum(vSum,2)+' '+"Set.Hauswährung.Kurz"+' freigeben?';
      if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end
    else begin
      // Aufhebung...
      if (Ein.Freigabe.WertW1<>0.0) then begin
        if (Ein.Freigabe.Datum<>0.0.0) then vA # 'am '+cnvad(Ein.Freigabe.Datum);
        vA # 'Der Auftrag wurde '+vA+' mit '+anum(Ein.Freigabe.WertW1,2)+' '+"Set.Hauswährung.Kurz"+' von '+Auf.Freigabe.User+' freigegeben!';
        vA # vA + StrChar(13)+'Freigabe löschen?';
        if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
        end
      else begin
        vA # 'Wollen Sie die die Kreidtlimitsperre wieder aktivieren?';
        if (Msg(99,vA,_WinIcoWarning,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end;
    end;
    ToggleLoeschmarker();
    Ein_Data:FreigabeErrechnen(vSum, gUsername);
***/
  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  RETURN true;
end;


//========================================================================