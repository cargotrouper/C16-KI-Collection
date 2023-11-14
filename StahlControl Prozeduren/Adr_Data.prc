@A+
//===== Business-Control =================================================
//
//  Prozedur  Adr_Data
//                    OHNE E_R_G
//
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  19.10.2010  AI  BugFix bei Zahlungsmoralerrechnung für OP-Ablage
//  14.05.2012  AI  BUGFIX: Stichwort ändern (101 nicht geladen!)
//  30.05.2012  AI  NEU: HoleBufferAdrOderanschrift
//  13.06.2012  ST  Browsersteuerung Googlesuche bei leerer Website
//                  hinzugefügt (Prj 1326/238)
//  18.09.2012  ST  ZeigeVerkaufe hinzugefügt (Prj 1420/1)
//  30.09.2015  ST  Info/Verkäufe beachtet jetzt Mat/Art/Mix/Warengruppentypen
//  18.07.2016  AH  Neu Setting "Set.KLP.BruttoYN"
//  12.12.2016  AH  "RepairSW"
//  25.04.2018  AH  Neu: Summe-Lieferverträge
//  06.06.2018  AH  LeereAllePersonenbezogeneDaten
//  23.10.2018  AH  Neu "GetEmaByCode"
//  20.09.2019  AH  Neu in "BerechneFinanzen" Brutto/Netto
//  08.04.2020  AH  Edit: "SetStichwort" optimiert
//  08.02.2021  AH  Edit: "SetStichwort" für LFE
//  28.01.2022  AH  Set.KLP.OhneAuf
//  01.02.2022  ST  E r g --> Erx
//  2022-07-07  AH  DEADLOCK
//
//  Subprozeduren
//    SUB RecSave(
//    SUB Import
//    SUB Diagnose
//    SUB BerechneFinanzen
//    SUB LoopDataAndReplaceSW
//    SUB SetStichwort
//    SUB ArcFlowExport
//    SUB HoleOrt
//    sub OpenGoogleMaps
//    sub HoleBufferAdrOderAnschrift
//    sub OpenWWW
//    sub OpenGoogleSearch
//    sub ZeigeVerkaeufe
//    sub ZeigeVerkaeufe
//    sub _ZeigeVerkaeufe_Data
//    sub _ZeigeVerkaeufe_Data_Pos
//    sub _ZeigeVerkaeufe_Data_Sort
//    sub LeereAllePersonenbezogeneDaten
//    sub GetEmaByCode
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

declare OpenGoogleSearch()

define begin
  dEK_Preis : Gv.Num.01
  dEK_MEH   : Gv.Alpha.01
  dEK_PEH   : Gv.Int.01
  dLieferant : Gv.Alpha.02
end;

//========================================================================
//  RecSave
//
//========================================================================
sub RecSave(
  aNeuYN      : logic;
  opt aImport : logic;
) : int;
local begin
  Erx       : int;
  vExists   : logic;
  vAutoKu   : logic;
  vAutoLf   : logic;
end;
begin

  if (aImport=false) then begin
    if (aNeuYN=n) then begin
      vAutoKu # (ProtokollBuffer[100]->Adr.KundenNr=0) and (Adr.Kundennr<>0);
      vAutoLf # (ProtokollBuffer[100]->Adr.LieferantenNr=0) and (Adr.LieferantenNr<>0);
    end
    else begin
      vAutoKu # (Adr.KundenNr<>0);
      vAutoLf # (Adr.LieferantenNr<>0);
    end;
  end;

  // autom. Nummerve r gabe??
  if (Set.Adr.AutoKuNr) and (vAutoKu) then begin
    Adr.KundenNr # Lib_Nummern:ReadNummer('Kundennummer');
    if (Adr.KundenNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      RETURN -1;
    end;
  end;
  if (Set.Adr.AutoLfNr) and (vAutoLf) then begin
    Adr.LieferantenNr # Lib_Nummern:ReadNummer('Lieferantennummer');
    if (Adr.LieferantenNr<>0) then Lib_Nummern:SaveNummer()
    else begin
      RETURN -1;
    end;
  end;

  // Sichern
  if (aNeuYN) then begin

    // nochmals auf Eindeutigkeit prüfen
    if (Adr.KundenNr<>0) then begin
      Erx # RecRead(100,2,_Rectest);
      if (Erx<=_rMultikey) then begin
        RETURN 100000;
      end;
    end;
    if (Adr.LieferantenNr<>0) then begin
      Erx # RecRead(100,3,_Rectest);
      if (Erx<=_rMultikey) then begin
        RETURN 100001;
      end;
    end;

    Adr.Anlage.Datum  # today;
    Adr.Anlage.Zeit   # Now;
    Adr.Anlage.User   # gUsername;

    if (aImport=false) then begin
      Adr.Nummer # Lib_Nummern:ReadNummer('Adresse');
      if (Adr.Nummer<>0) then Lib_Nummern:SaveNummer()
      else begin
        RETURN -1;
      end;
    end;
    if (Adr.Kundennr<>0) then begin
      Adr.VK.Std.Lieferadr # Adr.Nummer;
      Adr.VK.Std.Lieferans # 1;
    end;
  end;  // Neuanlage

  if (aNeuYN=n) then begin
    "Adr.Änderung.Datum"  # today;
    "Adr.Änderung.Zeit"   # Now;
    "Adr.Änderung.User"   # gUserName;
  end;


  // Anschrift aktualisieren
  Adr.A.Adressnr    # Adr.Nummer;
  Adr.A.Nummer      # 1;
  vExists # n;
 if (RecRead(101,1,0)<=_rLocked) then begin
    vExists # y;
    if (RecRead(101,1,_RecLock)<>_rOK) then RETURN -1;
  end
  else begin
    RecBufClear(101);
  end;
  Adr.A.Adressnr    # Adr.Nummer;
  Adr.A.Nummer      # 1;
  Adr.A.Stichwort   # Adr.Stichwort;
  Adr.A.Anrede      # Adr.Anrede;
  Adr.A.Name        # Adr.Name;
  Adr.A.Zusatz      # Adr.Zusatz;
  "Adr.A.Straße"    # "Adr.STraße";
  Adr.A.LKZ         # Adr.LKZ;
  Adr.A.PLZ         # Adr.PLZ;
  Adr.A.Ort         # Adr.Ort;
  Adr.A.Telefon     # Adr.Telefon1;
  Adr.A.Telefax     # Adr.Telefax;
  Adr.A.eMail       # Adr.eMail;
  Adr.A.Vertreter   # Adr.Vertreter;
  Adr.A.USIdentNr   # Adr.USIdentNr;
  "Adr.A.Steuerschlüsse"  # "Adr.Steuerschlüssel";
  if (vExists) then
    Erx # RekReplace(101,_recUnlock,'MAN')
  else
    Erx # RekInsert(101,_recUnlock,'MAN');
  if (Erx<>_rOk) then begin
    RETURN 100002;
  end;

  // Kreditlimit aktualisieren
  Adr.K.Nummer    # Adr.Nummer;
  vExists # n;
  if (RecRead(103,1,0)<=_rLocked) then begin
    vExists # y
    if (RecRead(103,1,_RecLock)<>_rOK) then RETURN -1;
  end
  else begin
    RecBufClear(103);
  end;
  Adr.K.Nummer    # Adr.Nummer;
  Adr.K.Stichwort # Adr.Stichwort;
  if (vExists) then begin
    Erx # RekReplace(103,_recUnlock,'MAN');
  end
  else begin
    "Adr.K.Währung" # 1;
    Erx # RekInsert(103,0,'MAN');
  end;
  if (Erx<>_rOk) then begin
    RETURN 100003;
  end;

  // Sonderfunktion:
  RunAFX('Adr.RecSave.Post','');

  RETURN 0;
end;


//========================================================================
//  Diagnose
//
//========================================================================
sub Diagnose()
local begin
  Erx : int;
end
begin

  // Ansprechpartner
  Erx # RecRead(102,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (Art.P.Adressnr<>0) then begin
      Erx # RecLink(100,102,1,_recFirst); // Adresse holen
      if (Erx>_rLocked) then begin
        RekDelete(102,0,'AUTO');
        Erx # RecRead(102,1,0);
        Erx # RecRead(102,1,0);
        CYCLE;
      end;
    end;

    Erx # RecRead(102,1,_recNext);
  END;


  // Kreditlimit
  Erx # RecRead(103,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    if (RecLinkInfo(100,103,1,_recCOunt)<=0) then begin
      RekDelete(103,0,'AUTO');
      Erx # RecRead(103,1,0);
      Erx # RecRead(103,1,0);
      CYCLE;
    end;

    Erx # RecRead(103,1,_recNext);
  END;

end;


//========================================================================
// BerechneFinanzen
//
//========================================================================
sub BerechneFinanzen(
  opt aOhneAuf  : int;
) : logic
local begin
  Erx : int;
  vSumOP    : float;
  vSumOPB   : float;
  vSumAB    : float;
  vSumBere  : float;
  vSumLfs   : float;
  vSumRes   : float;
  vSumPlan  : float;
  vSumABLV  : float;
  vSumBest  : float;

  vVzg      : float;
  vVzgAnz   : int;

  vBuf401   : int;
  vBuf400   : int;

  vStk      : int;
  vGew      : float;
  vX        : float;

  vBuf451   : int;
  vWert     : float;
  vReKdNr   : int;
end;
begin

  vBuf401 # Reksave(401);
  vBuf400 # Reksave(400);

  vSumOP    # 0.0;
  vSumOPB   # 0.0;
  vSumAB    # 0.0;
  vSumBere  # 0.0;
  vSumLfs   # 0.0;
  vSumRes   # 0.0;    // FEHLT !!!

  vBuf451 # RecBufCreate(451);

  Erx # RecLink(460,100,26,_recFirst);          // OPs loopen
  WHILE (Erx<=_rLocked) do begin
    if ("Ofp.Löschmarker"='') and (Abs(Ofp.RestW1)>0.5) and (Ofp.BruttoW1<>0.0) then begin
/*      Erx # RecLink(vBuf451, 460, 3,_recFirst); // 1. Konto holen
      if (Erx<=_rLocked) then begin
        Erx # RecLink(813, vBuf451, 10,_RecFirst);  // Steuerschlüssel holen
        if (Erx>_rLocked) then RecBufClear(813);
        vSumOP # vSumOP + (Ofp.RestW1 / (Sts.Prozent/100.0 + 1.0));
        end
      else begin
        vSumOP # vSumOP + Ofp.RestW1;
      end;
*/
      vX # OfP.NettoW1 / Ofp.BruttoW1;
      vSumOPB # vSumOPB + Ofp.RestW1;
      vSumOP  # vSumOP + (Ofp.RestW1 * vX);
    end;
    Erx # RecLink(460,100,26,_RecNext);
  END;

  RecBufDestroy(vBuf451);


  // 28.01.2022 AH:
  if (Set.KLP.OhneAuf=false) then begin
    FOR Erx # RecLink(401,100,22,_recFirst)     // Auftragspos. loopen
    LOOP Erx # RecLink(401,100,22,_RecNext)
    WHILE (Erx<=_rLocked) do begin

      if (aOhneAuf=Auf.P.Nummer) then CYCLE;

      RecLink(400,401,3,_recfirst);           // Kopf holen
      if (Auf.Vorgangstyp=c_AUF) and ("Auf.P.Löschmarker"='') and
        ((Auf.Freigabe.WertW1<>0.0) or ("Set.KLP.Auf-anlage"<>'A')) then begin

  //      if (Auf.LiefervertragYN) and (Set.KLP.AufRahmenYN=false) then CYCLE;

        RecLink(814,400,8,_recfirst); // Währung holen
        if ("Auf.WährungFixYN") then
          Wae.VK.Kurs       # "Auf.Währungskurs";
        if (Wae.VK.Kurs<>0.0) then
          Auf.P.Einzelpreis   # Rnd(Auf.P.einzelpreis / "Wae.VK.Kurs",2)

        vX # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.Rest.Stk, Auf.P.Prd.Rest.Gew, Auf.P.Prd.Rest, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
        vWert # (Auf.P.Einzelpreis * vX / cnvfi(Auf.P.PEH));
        // 18.07.2016 AH: Brutto errechnen...
        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;

        if (Auf.LiefervertragYN=false) or (Set.KLP.AufRahmenYN) then
          vSumAB    # vSumAB + vWert;
        if (Auf.LiefervertragYN) then
          vSumABLV  # vSumABLV + vWert;
        if (Auf.LiefervertragYN) and (Set.KLP.AufRahmenYN=false) then CYCLE;


        // 23.07.2019
        vX # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.EkBest.Stk, Auf.P.Prd.EkBest.Gew, Auf.P.Prd.EkBest, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
        vWert # (Auf.P.Einzelpreis * vX / cnvfi(Auf.P.PEH));
        // 20.09.2019
        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;
        vSumBest  # vSumBest + vWert;


        vX # Lib_Einheiten:WandleMEH(401, Auf.P.Prd.VSAuf.Stk, Auf.P.Prd.VSAuf.Gew, Auf.P.Prd.VSAuf, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
        vWert # (Auf.P.Einzelpreis * vX / cnvfi(Auf.P.PEH));
        // 18.07.2016 AH: Brutto errechnen...
        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;
        vSumLFS   # vSumLFS + vWert;

        vX # Auf.P.Prd.zuBere;
        vWert # (Auf.P.Einzelpreis * vX / cnvfi(Auf.P.PEH));
        // 18.07.2016 AH: Brutto errechnen...
        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;
        vSumBere  # vSumBere + vWert;

  //      vX    # Auf.P.Prd.Plan + Auf.p.Prd.VSB + Auf.P.Prd.VSAuf + Auf.P.Prd.LFS - Auf.P.Prd.Rech;
  //      vStk  # Auf.P.Prd.Plan.Stk + Auf.p.Prd.VSB.Stk + Auf.P.Prd.VSAuf.Stk + Auf.P.Prd.LFS.Stk - Auf.P.Prd.Rech.Stk;
  //      vGew  # Auf.P.Prd.Plan.Gew + Auf.p.Prd.VSB.Gew + Auf.P.Prd.VSAuf.Gew + Auf.P.Prd.LFS.Gew - Auf.P.Prd.Rech.Gew

        vX    # Auf.P.Prd.Plan + Auf.p.Prd.VSB;
        vStk  # Auf.P.Prd.Plan.Stk + Auf.p.Prd.VSB.Stk;
        vGew  # Auf.P.Prd.Plan.Gew + Auf.p.Prd.VSB.Gew;
  //debug('KEY401 : '+anum(Auf.P.Prd.Plan,0)+'Plan + '+anum(Auf.p.Prd.VSB,0)+'VSB + '+anum( Auf.P.Prd.VSAuf,0)+'VSAuf + '+anum(Auf.P.Prd.LFS,0)+'LFS + '+anum(Auf.P.Prd.Rech,0)+'Bere');
  // a) Mat ist VSB -> Fahren
  // b) Mat ist nicht VSB -> Fahren
  // c) BA letzter Schritt Fahren
  //      vX    # Lib_Einheiten:WandleMEH(401, vStk, vGew, vX, Auf.P.MEH.Einsatz, Auf.P.MEH.Preis);
  //      vWert # (Auf.P.Einzelpreis * vX / cnvfi(Auf.P.PEH));
        Auf_P_Subs:VkWertVonMenge(Auf.P.Nummer, Auf.P.Position, vStk, vGew, vGew, vX, Auf.P.MEH.Einsatz, 0.0, '', 401, var vWert, var vReKdNr);

        // 18.07.2016 AH: Brutto errechnen...
        if (Set.KLP.BruttoYN) then begin
          RekLink(819,401,1,_recFirst); // Warengruppe holen
          StS.Nummer # ("Wgr.Steuerschlüssel" * 100) + "Auf.Steuerschlüssel";
          Erx # RecRead(813,1,0);
          if (Erx>_rLocked) then RecBufClear(813);
          vWert # Rnd(vWert * ((100.0 + Sts.Prozent) / 100.0), 2);
        end;
        vSumPlan  # vSumPlan + vWert;
      end;

    END;
  end;  // AUF
  

  // Zahlungsverzug
  vVzg    # 0.0;
  vVzgAnz # 0;
  FOR  Erx # RecLink( 460, 100, 26, _recFirst );
  LOOP Erx # RecLink( 460, 100, 26, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    // ungelöschte Offene Posten ignorieren
    if ( "OfP.Löschmarker" != '*' ) then
      CYCLE;

    // ungültige Offene Posten ignorieren
    if ( OfP.Zieldatum = 0.0.0 ) then
      CYCLE;

    // Interne Stornierungen ignorieren
    if ( OfP.Bemerkung = Translate( 'STORNO-OP' ) ) or ( OfP.Bemerkung = Translate( 'STORNIERT' ) ) then
      CYCLE;

    // Letzte Zahlung
    if ( RecLink( 461, 460, 1, _recLast ) > _rLocked ) then
      CYCLE;

    RecLink( 465, 461, 2, _recFirst ); // Zahlungseingang


    vVzg    # vVzg + CnvFI( CnvID( Zei.Zahldatum ) - CnvID( OfP.Zieldatum ) );
    vVzgAnz # vVzgAnz + 1;
  END;


  // OP-Albage...
  FOR  Erx # RecLink( 470, 100, 72, _recFirst );
  LOOP Erx # RecLink( 470, 100, 72, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    // ungültige Offene Posten ignorieren
    if ( "OfP~Zieldatum" = 0.0.0 ) then
      CYCLE;

    // Interne Stornierungen ignorieren
    if ( "OfP~Bemerkung" = Translate( 'STORNO-OP' ) ) or ( "OfP~Bemerkung" = Translate( 'STORNIERT' ) ) then
      CYCLE;

    // Letzte Zahlung
    if ( RecLink( 461, 470, 1, _recLast ) > _rLocked ) then
      CYCLE;

    RecLink( 465, 461, 2, _recFirst ); // Zahlungseingang
//debug( CnvAI( OfP~Rechnungsnr ) + ' / ' + CnvAF( CnvFI( CnvID( Zei.Zahldatum ) - CnvID( OfP.Zieldatum ) ) ) )
    vVzg    # vVzg + CnvFI( CnvID( Zei.Zahldatum ) - CnvID( "OfP~Zieldatum" ) );
    vVzgAnz # vVzgAnz + 1;
  END;
  if ( vVzgAnz != 0 ) then
    vVzg # vVzg / CnvFI( vVzgAnz );


  // Werte rückspeichern:
  Erx # RecRead(100,1,_recLock);
  if (Erx=_rOK) then begin
    Adr.Fin.SummeOP       # vSumOP;
    Adr.Fin.SummeOPB      # vSumOPB;
    Adr.Fin.SummeAB       # vSumAB;
    Adr.Fin.SummeAB.LV    # vSumAbLV;
    Adr.Fin.SummeABBere   # vSumBere;
    Adr.Fin.SummeLfs      # vSumLfs;
    Adr.Fin.SummeRes      # vSumRes;
    Adr.Fin.SummeEkBest   # vSumBest;
    Adr.Fin.Refreshdatum  # today;
    Adr.Fin.SummePlan     # vSumPLan;
    Adr.Fin.Vzg.AnzZhlg   # vVzgAnz;
    Adr.Fin.Vzg.Offset    # vVzg;
    Erx # RekReplace(100,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then RETURN false;

  RekRestore(vBuf401);
  RekRestore(vBuf400);
  
  RETURN true;
end;


//========================================================================
//  08.04.2020 AH
//========================================================================
sub LoopDataAndReplaceSW(
  aZieldatei                : int;
  aSuchFeld                 : alpha;
  aSuchWert                 : int;
  aFeld                     : alpha;
  aNeuerInhalt              : alpha;
) : logic;
local begin
  Erx : int;
  vI        : int;
  vBuf      : int;
  vAnz      : int;

  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
end;
begin

  Lib_Sel:QInt(var vQ, '"'+aSuchfeld+'"',  '=', aSuchWert);

  vSel # SelCreate(aZielDatei, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  if  (vSelname='') then RETURN false
  
  FOR Erx # RecRead(aZielDatei ,vSel, _recFirst | _recLock)
  LOOP Erx # RecRead(aZielDatei, vSel, _recNext | _recLock)
  WHILE (Erx <= _rLocked) DO BEGIN
    FldDefByName(aFeld, aNeuerInhalt);
    Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
    if(Erx <> _rOK) then
      RETURN false; // konnte geaenderten Datensatz nicht speichern
    inc(vAnz);
  END;
  if (Erx=_rDeadLock) then RETURN false;
  SelClose(vSel);
  Erx # SelDelete(aZielDatei, vSelName);
  if (erx<>_rOK) then RETURN false;

//debugx(aint(aZieldatei)+' : '+aint(vAnz));
  RETURN true;
end;


//========================================================================
//  SetStichwort
//
//========================================================================
sub SetStichwort(aNeu : alpha; opt aNoMat :logic) : alpha;
local begin
  Erx : int;
  vRecFlag  : int;
  vReplace  : logic;
  my_Adr    : int;
  my_KNr    : int;
  my_LNr    : int;

  vErx      : int;

  vBuf100 : int;
  vAdrNr  : int;
  vKdNr   : int;
  vLfNr   : int;
end;
begin

  aNeu   # StrAdj( aNeu, _strBegin | _strEnd );
  vAdrNr # Adr.Nummer;
  vKdNr  # Adr.Kundennr;
  vLfNr  # Adr.Lieferantennr;

  my_Adr # Adr.Nummer;               // Keyfelder von der Adresse merken
  my_KNr # Adr.Kundennr;
  my_Lnr # Adr.Lieferantennr;

  // 100 - Adressstichwort
  Erx # RecRead( 100, 1, _recLock );
  if (Erx=_rOK) then begin
    Adr.Stichwort # aNeu;
    Erx # RekReplace( 100, _recUnlock,'AUTO');
  end;
  if (Erx<>_rOk ) then RETURN 'Adresse';

  // 101 - erste Anschrift
  Erx # RecLink( 101, 100, 12, _recFirst | _recLock );
  if (Erx= _rOK ) then begin
    Adr.A.Stichwort # aNeu;
    Erx # RekReplace( 101, _recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then RETURN 'Anschrift';

  // 103 - Kreditlimit
  Adr.K.Nummer # vAdrNr;
  Erx # RecRead( 103, 1, _recLock );
  if (erx= _rOk ) then begin
    Adr.K.Stichwort # aNeu;
    Erx # RekReplace( 103, _recUnlock,'AUTO')
  end;
  if (Erx<>_rOk ) then RETURN 'Kreditlimit';

  // 120 - Projekte
  FOR  Erx # RecLink( 120, 100, 30, _recFirst | _recLock );
  LOOP Erx # RecLink( 120, 100, 30, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Prj.AdressStichwort # aNeu;
    if ( RekReplace( 120, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Projekte';
  END;
  if (Erx=_rDeadLock) then RETURN 'Projekte';

  // 130 - LFE
  if (vLfNr<>0) then begin
    FOR  Erx # RecLink( 130, 100, 75, _recFirst | _recLock );
    LOOP Erx # RecLink( 130, 100, 75, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Lfe.LieferantenSW # aNeu;
      if ( RekReplace( 130, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Lieferantenerklärungen';
    END;
    if (Erx=_rDeadLock) then RETURN 'Lieferantenerklärungen';
  end;
  
  // 181 - HuB Preise
  if ( vLfNr != 0 ) then begin
     if (LoopDataAndReplaceSW(181, 'HuB.P.Lieferant', vLfNr, 'HuB.P.LieferSWort' , aNeu) = false) then RETURN 'Hub-Preise';
  end;

  // 190 - HuB Einkauf
  if ( vLfNr != 0 ) then begin
    if (LoopDataAndReplaceSW(190, 'HuB.EK.Lieferant', vLfNr, 'HuB.EK.LieferStichw' , aNeu) = false) then RETURN 'Hubs';
  end;

  // 191 - HuB EK Positionen
  if ( vLfNr != 0 ) then begin
    if (LoopDataAndReplaceSW(191, 'HuB.EK.P.Lieferant', vLfNr, 'HuB.EK.P.LieferSW' , aNeu) = false) then RETURN 'Hub-Preise';
  end;

  if (aNoMat=false) then begin
    // 200 - Material
    if ( vLfNr != 0 ) then begin
      FOR  Erx # RecLink( 200, 100, 17, _recFirst | _recLock );
      LOOP Erx # RecLink( 200, 100, 17, _recNext | _recLock );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        Mat.LieferStichWort # aNeu;
        vBuf100 # RekSave( 100 );
        Erx     # Mat_Data:Replace( _recUnlock, 'AUTO' );
        RekRestore( vBuf100 );
        if ( Erx != _rOk ) then
          RETURN 'Material';
      END;
      if (Erx=_rDeadLock) then RETURN 'Material';
    end;

    FOR  Erx # RecLink( 200, 100, 18, _recFirst | _recLock );
    LOOP Erx # RecLink( 200, 100, 18, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Mat.LagerStichWort # aNeu;
      vBuf100 # RekSave( 100 );
      Erx     # Mat_Data:Replace( _recUnlock, 'AUTO' );
      RekRestore( vBuf100 );
      if ( Erx != _rOk ) then
        RETURN 'Material';
    END;
    if (Erx=_rDeadLock) then RETURN 'Material';

    if ( vKdNr != 0 ) then begin
      FOR  Erx # RecLink( 200, 100, 19, _recFirst | _recLock );
      LOOP Erx # RecLink( 200, 100, 19, _recNext | _recLock );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        Mat.KommKundenSWort # aNeu;
        vBuf100 # RekSave( 100 );
        Erx     # Mat_data:Replace( _recUnlock, 'AUTO' );
        RekRestore( vBuf100 );
        if ( Erx != _rOk ) then
          RETURN 'Material';
      END;
      if (Erx=_rDeadLock) then RETURN 'Material';
    end;
  end;

  // 203 - Reservierungen
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 203, 100, 34, _recFirst | _recLock );
    LOOP Erx # RecLink( 203, 100, 34, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Mat.R.KundenSW # aNeu;
      if ( RekReplace( 203, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Material-Reservierung';
    END;
      if (Erx=_rDeadLock) then RETURN 'Material-Reservierung';
  end;

  RecLink( 101, 100, 12, _recFirst);    // 1. Anschrift holen
  // 252 - Artikel, Chargen
  FOR  Erx # RecLink( 252, 101, 4, _recFirst | _recLock );
  LOOP Erx # RecLink( 252, 101, 4, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Art.C.AdrStichwort # aNeu;
    if ( RekReplace( 252, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Chargen';
  END;
  if (Erx=_rDeadLock) then RETURN 'Chargen';

  // 254 - Artikel, Preise
  FOR  Erx # RecLink( 254, 100, 20, _recFirst | _recLock );
  LOOP Erx # RecLink( 254, 100, 20, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    Art.P.AdrStichwort # aNeu;
    if ( RekReplace( 254, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Artikelpreise';
  END;
  if (Erx=_rDeadLock) then RETURN 'Artikelpreise';

  // 300/301 - Reklamationen
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 300, 100, 49, _recFirst | _recLock );
    LOOP Erx # RecLink( 300, 100, 49, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Rek.Stichwort # aNeu;
      if ( RekReplace( 300, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Reklamationskopf';
      FOR  Erx # RecLink( 301, 300, 1, _recFirst | _recLock );
      LOOP Erx # RecLink( 301, 300, 1, _recNext | _recLock );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        Rek.P.Stichwort # aNeu
        if ( RekReplace( 301, _recUnlock,'AUTO') != _rOk ) then
          RETURN 'Reklamationsposition';
      END;
      if (Erx=_rDeadLock) then RETURN 'Reklamationsposition';
    END;
    if (Erx=_rDeadLock) then RETURN 'Reklamationskopf';
  end;
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 300, 100, 61, _recFirst | _recLock );
    LOOP Erx # RecLink( 300, 100, 61, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Rek.Stichwort # aNeu;
      if ( RekReplace( 300, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Reklamationskopf';

      FOR  Erx # RecLink( 301, 300, 1, _recFirst | _recLock );
      LOOP Erx # RecLink( 301, 300, 1, _recNext | _recLock );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        Rek.P.Stichwort # aNeu
        if ( RekReplace( 301, _recUnlock,'AUTO') != _rOk ) then
          RETURN 'Reklamationsposition';
      END;
      if (Erx=_rDeadLock) then RETURN 'Reklamationsposition';
    END;
    if (Erx=_rDeadLock) then RETURN 'Reklamationskopf';
  end;

  // 301 - Reklamationsverursacher
  FOR  Erx # RecLink( 301, 100, 70, _recFirst | _recLock );
  LOOP Erx # RecLink( 301, 100, 70, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( Rek.P.Verursacher != 1 ) then
      CYCLE;
    Rek.P.VerursacherSW # aNeu;
    if ( RekReplace( 301, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Reklamationsverursacher';
  END;
  if (Erx=_rDeadLock) then RETURN 'Reklamationsverursacher';

  // 401/400 - Auftragspositionen & Kopf
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 401, 100, 22, _recFirst | _recLock );
    LOOP Erx # RecLink( 401, 100, 22, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Auf.P.KundenSW # aNeu;
      if (RekReplace(401, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Auf.Position';

      RecLink( 400, 401, 3, _recFirst | _recLock );
      Auf.KundenStichwort # aNeu;
      if ( RekReplace( 400, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Auf.Kopf';
    END;
    if (Erx=_rDeadLock) then RETURN 'Auf.Position';
  end;

  // 440 - Lieferscheine
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 440, 100, 42, _recFirst | _recLock );
    LOOP Erx # RecLink( 440, 100, 42, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Lfs.Kundenstichwort # aNeu;
      if ( RekReplace( 440, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Lieferschein';
    END;
    if (Erx=_rDeadLock) then RETURN 'Lieferschein';
  end;


  // 450 - Erlöse
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 450, 100, 25, _recFirst | _recLock );
    LOOP Erx # RecLink( 450, 100, 25, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Erl.KundenStichwort # aNeu;
      if ( RekReplace( 450, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Erlöse';
    END;
    if (Erx=_rDeadLock) then RETURN 'Erlöse';
  end;

  // 460 - Offene Posten
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 460, 100, 26, _recFirst | _recLock );
    LOOP Erx # RecLink( 460, 100, 26, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      OfP.KundenStichwort # aNeu;
      if ( RekReplace( 460, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Offene Posten';
    END;
    if (Erx=_rDeadLock) then RETURN 'Offene Posten';
  end;

  // 465 - Zahlungseingang
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 465, 100, 37, _recFirst | _recLock );
    LOOP Erx # RecLink( 465, 100, 37, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      ZEi.KundenStichwort # aNeu;
      if ( RekReplace( 465, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Zahlungseingang';
    END;
    if (Erx=_rDeadLock) then RETURN 'Zahlungseingang';
  end;

  // 501/500/511 - Einkauf
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 501, 100, 23, _recFirst | _recLock );
    LOOP Erx # RecLink( 501, 100, 23, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Ein.P.LieferantenSW # aNeu;
      if (RekReplace(501, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Ein.Position';

      RecLink( 500, 501, 3, _recFirst | _recLock );
      Ein.LieferantenSW # aNeu;
      if ( RekReplace( 500, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Ein.Kopf';
    END;
    if (Erx=_rDeadLock) then RETURN 'Ein.Position';

    FOR  Erx # RecLink( 511, 100, 29, _recFirst | _recLock );
    LOOP Erx # RecLink( 511, 100, 29, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      "Ein~P.LieferantenSW" # aNeu;
      if ( RekReplace( 511, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Ein.Position';
    END;
    if (Erx=_rDeadLock) then RETURN 'Ein.Position';
  end;

  // 540 - Bedarf
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 540, 100, 36, _recFirst | _recLock );
    LOOP Erx # RecLink( 540, 100, 36, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Bdf.LieferSW.Wunsch # aNeu;
      if ( RekReplace( 540, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Bedarf';
    END;
    if (Erx=_rDeadLock) then RETURN 'Bedarf';

    FOR  Erx # RecLink(545,100,31,_recFirst|_recLock);
    LOOP Erx # RecLink(545,100,31,_recNext|_recLock);
    WHILE ( Erx <= _rLocked ) DO BEGIN
      "Bdf~LieferSW.Wunsch" # aNeu;
      if ( RekReplace( 545, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Bedarf';
    END;
    if (Erx=_rDeadLock) then RETURN 'Bedarf';
  end;

  // 550 - Verbindlichkeiten
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 550, 100, 27, _recFirst | _recLock );
    LOOP Erx # RecLink( 550, 100, 27, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Vbk.LieferStichwort # aNeu;
      if ( RekReplace( 550, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Verbindlichkeiten';
    END;
    if (Erx=_rDeadLock) then RETURN 'Verbindlichkeiten';
  end;

  // 555 - EKK
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 555, 100, 24, _recFirst | _recLock );
    LOOP Erx # RecLink( 555, 100, 24, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      EKK.LieferStichwort # aNeu;
      if ( RekReplace( 555, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'EKK';
    END;
    if (Erx=_rDeadLock) then RETURN 'EKK';
  end;

  // 560 - Eingangsrechnung
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 560, 100, 28, _recFirst | _recLock );
    LOOP Erx # RecLink( 560, 100, 28, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      ERe.LieferStichwort # aNeu;
      if ( RekReplace( 560, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Eingangsrechnungen';
    END;
    if (Erx=_rDeadLock) then RETURN 'Eingangsrechnung';;
  end;

  // 565 - Zahlungsausgang
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 565, 100, 38, _recFirst | _recLock );
    LOOP Erx # RecLink( 565, 100, 38, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      ZAu.LieferStichwort # aNeu;
      if ( RekReplace( 565, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Zahlungsausgang';
    END;
    if (Erx=_rDeadLock) then RETURN 'Zahlungsausgang';
  end;

  // 620 - SammelWarenEingang
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 620, 100, 44, _recFirst | _recLock );
    LOOP Erx # RecLink( 620, 100, 44, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      SWe.LieferantenSW # aNeu;
      if ( RekReplace( 620, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Sammelwareneingänge';
    END;
    if (Erx=_rDeadLock) then RETURN 'Sammelwareneingang';
  end;

  // 650 - Versand, Selbstabholer
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 650, 100, 67, _recFirst | _recLock );
    LOOP Erx # RecLink( 650, 100, 67, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Vsd.SelbstabholSW # aNeu;
      if ( RekReplace( 650, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Versandselbstabholer';
    END;
    if (Erx=_rDeadLock) then RETURN 'Versandselbstabholer';
  end;

  // 650/655 - Versand, VersandPool, Kunde
  if ( vLfNr != 0 ) then begin
    FOR  Erx # RecLink( 650, 100, 66, _recFirst | _recLock );
    LOOP Erx # RecLink( 650, 100, 66, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      Vsd.SpediteurSW # aNeu;
      if ( RekReplace( 650, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Versand';
    END;
    if (Erx=_rDeadLock) then RETURN 'Versand';

    FOR  Erx # RecLink( 655, 100, 65, _recFirst | _recLock );
    LOOP Erx # RecLink( 655, 100, 65, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      VsP.SpediteurSW # aNeu;
      if ( RekReplace( 655, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Versandpool';
    END;
    if (Erx=_rDeadLock) then RETURN 'Versandpool';
  end;
  if ( vKdNr != 0 ) then begin
    FOR  Erx # RecLink( 655, 100, 78, _recFirst | _recLock );
    LOOP Erx # RecLink( 655, 100, 78, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      VsP.AuftragsKdSW # aNeu;
      if ( RekReplace( 655, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Versandpool';
    END;
    if (Erx=_rDeadLock) then RETURN 'Versandpool';
    FOR  Erx # RecLink( 656, 100, 79, _recFirst | _recLock );
    LOOP Erx # RecLink( 656, 100, 79, _recNext | _recLock );
    WHILE ( Erx <= _rLocked ) DO BEGIN
      "VsP~AuftragsKdSW" # aNeu;
      if ( RekReplace( 656, _recUnlock,'AUTO') != _rOk ) then
        RETURN 'Versandpool';
    END;
    if (Erx=_rDeadLock) then RETURN 'Versandpool';
  end;


  // 843 - Aufpreispositionen
  FOR  Erx # RecLink( 843, 100,77, _recFirst | _recLock );
  LOOP Erx # RecLink( 843, 100,77, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    ApL.L.AdressSW # aNeu;
    if ( RekReplace(843, _recUnlock,'AUTO') != _rOk ) then
      RETURN 'Aufpreispositionen';
  END;
  if (Erx=_rDeadLock) then RETURN 'Aufpreispositionen';


  RecLink( 101, 100, 12, _recFirst);    // 1. Anschrift holen
  // 702 - BAG.Positionen
  FOR  Erx # RecLink( 702, 101, 5, _recFirst | _recLock );
  LOOP Erx # RecLink( 702, 101, 5, _recNext | _recLock );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    BAG.P.Zielstichwort # aNeu;
    if ( RekReplace(702, _recUnlock,'AUTO') != _rOk ) then
//    if ( BA1_P_Data:Replace(_recUnlock,'AUTO') != _rOk ) then
      RETURN 'Betriebsauftragspositionen';
  END;
  if (Erx=_rDeadLock) then RETURN 'Betriebsauftragspositionen';

// Statistik
/***
  if (Adr.Kundennr<>0) then begin
    Erx # RecLink(899,100,40,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Sta.Adr.Stichwort # Adr.Stichwort;
      if (RekReplace(899,_RecUnlock,'AUTO') <> _rOk) then RETURN('Statistik');
      Erx # RecLink(899,100,40,_recNext|_recLock);
    END;
  end;
  if (Adr.Lieferantennr<>0) then begin
    Erx # RecLink(899,100,41,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Sta.Adr.Stichwort # Adr.Stichwort;
      if (RekReplace(899,_RecUnlock,'AUTO'); <> _rOk) then RETURN('Statistik');
      Erx # RecLink(899,100,41,_recNext|_recLock);
    END;
  end;
***/

  if (LoopDataAndReplaceSW(230, 'Lys.K.Lieferant', vLfNr, 'Lys.K.LieferantenSW' , aNeu) = false) then RETURN 'Analysen-Lieferanten';
  if (LoopDataAndReplaceSW(230, 'Lys.K.Kundennr', vKdNr, 'Lys.K.KundenSW' , aNeu) = false) then RETURN 'Analysen-Kunden';

  RETURN '';
end;


//========================================================================
//  ArcFlowExport
//
//========================================================================
sub ArcFlowExport();
local begin
  vAFMappe  : int;
  vAFMappe2 : int;
  vA        : alpha(4096);
  vAFDate   : date;
  vAFTeil   : int;
  vAFType   : int;
end;
begin

RETURN;

/***
  Erx # DMS_ArcFlow:Init();
  if (Erx<>0) then begin
    Error(915002,'ArcFlow:INIT ERROR '+cnvai(Erx));
    RETURN;
   end;

  // Vorhandene Mappe öffen bzw. anlegen + updaten...
  // GetKndMappenId(aAdrNr : int; aKndName : alpha(250); var aKndAbmId : int; var aErrCodeAlpha : alpha; opt aAbmKndCreate : logic; opt aAbmKndUpdate : logic;): int;
//   Erx # AF_Sys_ArcFlow:GetKndMappenId(Adr.Nummer, Adr.Name, var vAFMappe, var vA, y, y);
  Erx # DMS_ArcFlow:GetKndMappenId(Adr.Nummer, Adr.Stichwort, var vAFMappe, var vA, y, y);
  if (Erx<>0) then begin
    AF_SYS_ArcFlow:TermArcFlow();
    Error(915002,'ArcFlow:'+vA);
    RETURN;
  end;

//      if (Erx<>_rOK) then begin // MAppe nicht existent
//      end;
      // Mappenstruktur angelegt!
/*
      Erx # AF.API:AFAbmReadByName('Bestellungen', vAFMappe, 0,//sAbmSearchParent,
                             var vAFMappe2, var vA, var vAFMappe,
                             var vA, var vAFDate, var vAFTeil, var vAFType);
*/

  // ArcFlow diconnecten...
  DMS_ArcFlow:Term();

  // Erfolg !
  Error(999998,'');
***/
end;


//========================================================================
//  HoleOrt
//
//========================================================================
sub HoleOrt(aLKZ : alpha; aPLZ : alpha) : logic
local begin
  Erx : int;
end
begin

  RecBufClear(847);
  if (RecInfo(847,_recCount)=0) then RETURN false;

  Ort.LKZ # aLKZ;
  Ort.PLZ # aPLZ;
  Erx # RecRead(847,1,0);
  if (Ort.LKZ=aLKZ) and (Ort.PLZ=aPLZ) then RETURN true;

  RecBufClear(847);
  RETURN false;
end;


//========================================================================
//  OpenMaps
//                Google Maps Routenplanung starten
//========================================================================
sub OpenGoogleMaps (aStr : alpha; aPLZ : alpha; aOrt : alpha;)
local begin
  vUrl    : alpha(500);
  vBuf100 : int;
end
begin
  vUrl    # '*http://maps.google.com/maps?source=s_d&hl=de'
  vBuf100 # RekSave(100);

  // Startadresse (eigene Adresse)
  Adr.Nummer # Set.eigeneAdressNr;
  if (RecRead(100, 1, 0) = _rOk) then
    vUrl # vUrl + '&saddr=' + "Adr.Straße" + ', ' + "Adr.PLZ" + ' ' + "Adr.Ort"
  RekRestore(vBuf100);

  // Zieladresse
  vUrl # vUrl + '&daddr=' + aStr + ', ' + aPLZ + ' ' + aOrt
  SysExecute(vUrl, '', 0);
end;


//========================================================================
//  HoleBufferAdrOderAnschrift
//      stellt eine temporären Adressbuffer zusammen mit ggf. Anschriftsdaten
//========================================================================
sub HoleBufferAdrOderAnschrift(
  aKdNr     : int;
  aAnschr   : int) : int;
local begin
  Erx : int;
  vBuf100 : int;
  vBuf101 : int;
end;
begin

  if (aKdNr<=0) then RETURN 0;

  vBuf100 # RecBufCreate(100);
  vBuf101 # RecBufCreate(101);

  vBuf100->Adr.Kundennr # aKdNr;
  Erx # RecRead(vBuf100,2,0);   // Kunde holen
  if (Erx>_rMultiKey) then begin
    RecBufDestroy(vBuf100);
    RecBufDestroy(vBuf101);
    RETURN 0;
  end;

  if (aAnschr=1) then begin
    RecBufDestroy(vBuf101);
    RETURN vBuf100;
  end;

  vBuf101->Adr.A.Adressnr # vBuf100->Adr.Nummer;
  vBuf101->Adr.A.Nummer   # aAnschr;
  Erx # RecRead(vBuf101,1,0);   // Anschrift holen
  if (Erx>_rLocked) then begin
    RecBufDestroy(vBuf100);
    RecBufDestroy(vBuf101);
    RETURN 0;
  end;

  // Daten aus Anschrift überschrieben ggf. Adresse
  vBuf100->Adr.Stichwort        # vBuf101->Adr.A.Stichwort       ;
  vBuf100->Adr.Anrede           # vBuf101->Adr.A.Anrede          ;
  vBuf100->Adr.Name             # vBuf101->Adr.A.Name            ;
  vBuf100->Adr.Zusatz           # vBuf101->Adr.A.Zusatz          ;
  vBuf100->"Adr.Straße"         # vBuf101->"Adr.A.Straße"        ;
  vBuf100->Adr.LKZ              # vBuf101->Adr.A.LKZ             ;
  vBuf100->Adr.PLZ              # vBuf101->Adr.A.PLZ             ;
  vBuf100->Adr.Ort              # vBuf101->Adr.A.Ort             ;
  if (vBuf101->Adr.A.Telefon         <>'') then vBuf100->Adr.Telefon1         # vBuf101->Adr.A.Telefon         ;
  if (vBuf101->Adr.A.Telefax         <>'') then vBuf100->Adr.Telefax          # vBuf101->Adr.A.Telefax         ;
  if (vBuf101->Adr.A.eMail           <>'') then vBuf100->Adr.eMail            # vBuf101->Adr.A.eMail           ;
  if (vBuf101->Adr.A.Vertreter       <>0)  then vBuf100->Adr.Vertreter        # vBuf101->Adr.A.Vertreter       ;
  if (vBuf101->Adr.A.USIdentNr       <>'') then vBuf100->Adr.USIdentNr        # vBuf101->Adr.A.USIdentNr       ;
  if (vBuf101->"Adr.A.Steuerschlüsse"<>0)  then vBuf100->"Adr.Steuerschlüssel"# vBuf101->"Adr.A.Steuerschlüsse";

  RecBufDestroy(vBuf101);

  RETURN vBuf100;
end;


//========================================================================
//  sub OpenWWW()
//      Öffnet die Webseite der Adresse im Browser, oder startet die
//      Googlesuche
//========================================================================
sub OpenWWW()
begin
  if (Adr.Website <> '') then
    SysExecute('*http://'+Adr.Website,'',0);
  else
    OpenGoogleSearch();
end;


//========================================================================
//  sub OpenGoogleSearch()
//          Öffnet den Browser und sucht nach der Firmenadresse
//  <:http://www.blogeffekt.com/seo/google-parameter-operatoren.html:>
//========================================================================
sub OpenGoogleSearch()
local begin
  vUrl    : alpha(500);
  vSearch : alpha(500);
end
begin
//  vUrl     # '...?hl=de&q='; // Spracheinstellung von Browsereinstellungen nutzen
  vUrl     # '*http://www.google.de/search?q=';

  // Zieladresse
  //Suche: '...&q=oks+iserlohn---';
  vSearch # vSearch + Adr.Name + ' ';
  vSearch # vSearch + Adr.Ort + ' ';
  vSearch # StrAdj(vSearch, _StrBegin | _StrEnd);

  // Leerzeichen durch "+" ersetzen für detailiertere Erxebnisse
  vSearch # Str_ReplaceAll(vSearch, ' ', '+');

  vUrl    # vUrl + vSearch;
  SysExecute(vUrl, '', 0);
end;


//========================================================================
//  sub ZeigeVerkaeufe()
//
//========================================================================
sub ZeigeVerkaeufe(aAdresse : int)
local begin
  v100 : int;
  v200, v210, v250, v401, v411 : handle;
  i       : int;
  vFeld   : alpha[100];
  vTyp    : int[100];
  vQInfo  : Alpha(1000);
end
begin

  // hier AFX Aufruf
  if (RunAFX('Adr.Info.Verkäufe',Aint(aAdresse))<>0) then
    RETURN;


  v100 # RekSave(100);    // WICHTIG!!! Ermöglicht das Sortieren allen Feldern
  v200 # RekSave(200);
  v210 # RekSave(210);
  v250 # RekSave(250);
  v401 # RekSave(401);
  v411 # RekSave(411);

  Adr.Nummer # aAdresse;
  if (RecRead(100,1,0) <> _rOK) then
    RETURN;

  i # 1;
  vFeld[i] # 'Rech.Dat.';      vTyp[i]  # _TypeDate;   inc(i);
  vFeld[i] # 'Artikel.Nr.';    vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Artikel.Stw.';   vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Strukturnr.';    vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Qualität';       vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Dicke';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Breite';         vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Länge';          vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'Ausf.Oben';      vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'Materialnr';     vTyp[i]  # _TypeInt;    inc(i);
  vFeld[i] # 'Kommission';     vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'VK-Menge';       vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'VK-MEH';         vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'VK-Grundpreis';  vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'VK-Einzelpreis'; vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'VK-PEH';         vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'VK-Rech.Nr.';    vTyp[i]  # _TypeInt;    inc(i);
  vFeld[i] # 'EK-Lieferant';   vTyp[i]  # _TypeAlpha;  inc(i);
  vFeld[i] # 'EK-Einzel';      vTyp[i]  # _TypeFloat;  inc(i);
  vFeld[i] # 'EK PEH';         vTyp[i]  # _TypeAlpha;  inc(i);

  vQInfo  # 'Verkäufe an Kunde:' + Adr.Stichwort + '  Kundennummer:'+ aInt(Adr.Kundennr);
  Lib_QuickInfo:Show(vQInfo, var vFeld,var vTyp, here+':_ZeigeVerkaeufe_Data', false);

  RekRestore(v100);
  RekRestore(v200);
  RekRestore(v210);
  RekRestore(v250);
  RekRestore(v401);
  RekRestore(v411);
end;


//========================================================================
// sub _ZeigeVerkaeufe_Data(var aSortTreeHandle : int)
//      Ermittelt die darzustellenden Datensätze
//========================================================================
sub _ZeigeVerkaeufe_Data(var aSortTreeHandle : int)
local begin
    Erx : int;
  vPrg        : int;
  vMax        : int;
  vCurrent    : int;
  vSortKey    : alpha;
end;
begin

  vPrg # Lib_Progress:Init('Datenermittlung');

  vMax # RecLinkInfo(899,100,52,_RecCount);

  // Statstikdatei rückwärts durchlaufen, da normalerweise die aktuellsten Datensätze interessant sind
  FOR   Erx # RecLink(899,100,52,_RecLast)
  LOOP  Erx # RecLink(899,100,52,_RecPrev)
  WHILE Erx <= _rLocked DO BEGIN
    inc(vCurrent);
    if (vCurrent > 1000) then
      BREAK;

    vPrg->Lib_Progress:SetLabel('Sortierung ' + Aint(vCurrent) + '/' + Aint(vMax))
    if (vPrg->Lib_Progress:Step() = false) then begin
      break;
    end;

    // Sortierungsschlüssel definieren
    vSortKey # cnvAI(Sta.Re.Nummer,_FmtNumLeadZero|_fmtNumNoGroup,0,10);

    Sort_ItemAdd(aSortTreeHandle,vSortKey,899,RecInfo(899,_RecId));
  END;

  vPrg->Lib_Progress:Term();
end;


//========================================================================
// sub _ZeigeVerkaeufe_Data_Pos(aSortItem : int; var aRecord : alpha[];)
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub _ZeigeVerkaeufe_Data_Pos(aSortItem : int; var aRecord : alpha[];)
local begin
  Erx : int;
  i : int;
  vEKPreis : float;
end;
begin

  RecRead(cnvIA(aSortItem->spCustom), 0, 0, aSortItem->spID); // Datensatz holen

  i # 1;
  if (cnvIA(aSortItem->spCustom) = 899) then begin
    // Verlinkte Daten lesen

    // Material / Ablage
    RecBufClear(200);
    if (Sta.Lfs.Materialnr <> 0) then begin
      Mat_Data:Read(Sta.Lfs.Materialnr);
    end;

    // Artikel
    RecBufClear(250);
    if (Sta.Auf.Artikel.Nr <> '') then begin
      Art.Nummer # Sta.Auf.Artikel.Nr;
      if (RecRead(250,1,0) <> _rOK) then begin
        RecBufClear(250);
      end;
    end;

    // Auftragspos / Ablage
    RecBufClear(401);
    if (Sta.Auf.Nummer <> 0) AND (Sta.Auf.Position <> 0) then begin

      Auf.P.Nummer    # Sta.Auf.Nummer;
      Auf.P.Position  # Sta.Auf.Position;
      if (RecRead(401,1,0) <> _rOK) then begin

        "Auf~P.Nummer"    # Sta.Auf.Nummer;
        "Auf~P.Position"  # Sta.Auf.Position;;
        if (RecRead(411,1,0) <> _rOK) then
          RecBufClear(411);
        else begin
          RecBufCopy(411,401,false);
        end;
      end;
    end;

    dEK_Preis # 0.0;
    dEK_MEH   # '';
    dEK_PEH   # 0;
    dLieferant # '';
    if (Sta.EigenYN) then begin
      // Statistikdatensatz aus Stahl Control
      if (WGr_data:IstMat(Auf.P.Wgr.Dateinr)) OR ((WGr_data:IstMixMat(Auf.P.Wgr.Dateinr))) then begin
        // EK-Preis für Materialkarten und 209er Materialchargen
        dEK_Preis   # Mat.EK.Preis;
        dEK_MEH     # 'kg';
        dEK_PEH     # 1000;
        dLieferant  #  Mat.LieferStichwort;
      end else begin
        // EK-Preis bei Artikeln, wird in die Auftragspos. kalkulation gezogen
        Auf.K.Nummer    # Auf.P.Nummer;
        Auf.K.Position  # Auf.P.Position;
        Erx # RecRead(405,1,0);
        WHILE (Erx <= _rMultikey) DO BEGIN
          if (Auf.K.Nummer <> Auf.P.Nummer) OR (Auf.K.Position <> Auf.P.Position) OR (dEK_Preis <> 0.0) then
            BREAK;

          dEK_Preis # Auf.K.Preis;
          dEK_MEH   # Auf.K.MEH;
          dEK_PEH   # Auf.K.PEH;

          if (Auf.K.Lieferantennr <> 0) then begin
            if (ReCLink(100,405,1,0) = _rOK) then
              dLieferant # Adr.Stichwort;
          end;

          Erx # RecRead(405,1,_RecNext);
        END;
      end;
    end else begin
      // Statistikdatensatz aus Fremdsystem

      // Lieferant lesen
      if (ReCLink(100,899,9,0) = _rOK) then
        dLieferant # Adr.Stichwort;

      // Einzelpreis errechnen
      STA.Auf.PEH # max(1, STa.Auf.PEH);
      
        if ("Sta.Menge.VK" / CnvFi(Sta.Auf.PEH)<>0.0) then begin
          dEK_Preis # Sta.Betrag.EK / ("Sta.Menge.VK" / CnvFi(Sta.Auf.PEH));
        dEK_MEH   # Sta.MEH.VK;
        dEK_PEH   # Sta.Auf.PEH;

        Auf.P.Grundpreis  # Sta.Betrag.VK / ("Sta.Menge.VK" / CnvFi(Sta.Auf.PEH));
        Auf.P.Einzelpreis # Auf.P.Grundpreis   +
                          (Sta.Lohnkosten / ("Sta.Menge.VK" / CnvFi(Sta.Auf.PEH)) )  +
                          (Sta.Aufpreis.VK / ("Sta.Menge.VK" / CnvFi(Sta.Auf.PEH))
                          );
      end;
    end;


    // Zeile zusammenstellen
    aRecord[i] # CnvAd(Sta.Re.Datum);                         inc(i);
    aRecord[i] # Sta.Auf.Artikel.Nr;                          inc(i);
    aRecord[i] # Sta.Auf.Artikel.SW;                          inc(i);
    aRecord[i] # Sta.Auf.Strukturnr;                          inc(i);
    aRecord[i] # "Sta.Auf.Güte";                              inc(i);
    aRecord[i] # ANum(Sta.Auf.Dicke,  Set.Stellen.Dicke);     inc(i);
    aRecord[i] # ANum(Sta.Auf.Breite, Set.Stellen.Breite);    inc(i);
    aRecord[i] # ANum("Sta.Auf.Länge", "Set.Stellen.Länge");  inc(i);
    aRecord[i] # "Sta.Auf.Ausführung.O";                      inc(i);
    aRecord[i] # Aint(Sta.Lfs.Materialnr);                    inc(i);
    aRecord[i] # Aint(Sta.Auf.Nummer)+ '/' + Aint(Sta.Auf.Position);   inc(i);
    aRecord[i] # ANum(Sta.Menge.VK,2);                        inc(i);
    aRecord[i] # Sta.MEH.VK;                                  inc(i);
    aRecord[i] # ANum(Auf.P.Grundpreis,2);                    inc(i);
    aRecord[i] # ANum(Auf.P.Einzelpreis,2);                   inc(i);
    aRecord[i] # AInt(Sta.Auf.PEH) + ' ' + Sta.MEH.VK;        inc(i);
    aRecord[i] # Aint(Sta.Re.Nummer);                         inc(i);
    aRecord[i] # dLieferant;                                  inc(i);
    aRecord[i] # ANum(dEK_Preis,2);                           inc(i);
    aRecord[i] # AInt(dEK_PEH) + ' ' + dEK_MEH;               inc(i);

  end;

end;

//========================================================================
// sub _ZeigeVerkaeufe_Data_Pos(aSortItem : int; var aRecord : alpha[];)
//      Weist dem Zeilenarray die gewünschten Daten zu
//========================================================================
sub _ZeigeVerkaeufe_Data_Sort(aRowIndex : int) : alpha
begin
  case (aRowIndex) of
    1 : begin RETURN Lib_Strings:DateForSort( Sta.Re.Datum);            end;
    2 : begin RETURN                          Sta.Auf.Artikel.Nr;       end;
    3 : begin RETURN                          Sta.Auf.Artikel.SW;       end;
    4 : begin RETURN                          Sta.Auf.Strukturnr;       end;
    5 : begin RETURN                          "Sta.Auf.Güte";           end;
    6 : begin RETURN Lib_Strings:NumForSort(  Sta.Auf.Dicke);           end;
    7 : begin RETURN Lib_Strings:NumForSort(  Sta.Auf.Breite);          end;
    8 : begin RETURN Lib_Strings:NumForSort(  "Sta.Auf.Länge");         end;
    9 : begin RETURN                          "Sta.Auf.Ausführung.O";   end;
   10 : begin RETURN Lib_Strings:IntForSort(  Sta.Lfs.Materialnr);      end;
   11 : begin RETURN Lib_Strings:IntForSort(  Sta.Auf.Nummer)  + '/' +
                     Lib_Strings:IntForSort(  Sta.Auf.Position);        end;
   12 : begin RETURN Lib_Strings:NumForSort(  Sta.Menge.VK);            end;
   13 : begin RETURN                          Sta.MEH.VK;               end;
   14 : begin RETURN Lib_Strings:NumForSort(  Auf.P.Grundpreis);        end;
   15 : begin RETURN Lib_Strings:NumForSort(  Auf.P.Einzelpreis);       end;
   16 : begin RETURN Lib_Strings:IntForSort(  Sta.Auf.PEH);             end;
   17 : begin RETURN Lib_Strings:IntForSort(  Sta.Re.Nummer);           end;
   18 : begin RETURN                          dLieferant;               end;
   19 : begin RETURN Lib_Strings:NumForSort(  dEK_Preis);               end;
   20 : begin RETURN                          Aint(dEK_PEH) + ' ' + dEK_MEH;  end;
  end;
end;


//========================================================================
// Call Adr_Data:RepairSW
//========================================================================
sub RepairSW();
local begin
  Erx : int;
end
begin
  // Adressen loopen...
  FOR Erx # RecRead(100,1,_recFirst)
  LOOP Erx # RecRead(100,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    SetStichwort(Adr.Stichwort);
  END;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  call Adr_Data:LeereAllePersonenbezogeneDaten
//========================================================================
sub LeereAllePersonenbezogeneDaten()
local begin
  Erx : int;
end
begin
  
  FOR Erx # RecRead(102,1,_RecFirst|_RecLock)
  LOOP Erx # RecRead(102,1,_RecNext|_recLock)
  WHILE (Erx<=_rLocked) do begin
    Adr.P.Priv.LKZ        # '';
    Adr.P.Priv.PLZ        # '';
    "Adr.P.Priv.Straße"   # '';
    Adr.P.Priv.Ort        # '';
    Adr.P.Priv.Telefon    # '';
    Adr.P.Priv.Telefax    # '';
    Adr.P.Priv.eMail      # '';
    Adr.P.Priv.Mobil      # '';
    Adr.P.Geburtsdatum    # 0.0.0;
    Adr.P.Familienstand   # '';
    Adr.P.Hobbies         # '';
    Adr.P.Vorlieben       # '';
    Adr.P.Auto            # '';
    Adr.P.Religion        # '';
    Adr.P.Partner.Name    # '';
    Adr.P.Partner.GebTag  # 0.0.0;
    Adr.P.Hochzeitstag    # 0.0.0;
    Adr.P.Kind1.Name      # '';
    Adr.P.Kind1.GebTag    # 0.0.0;
    Adr.P.Kind2.Name      # '';
    Adr.P.Kind2.GebTag    # 0.0.0;
    Adr.P.Kind3.Name      # '';
    Adr.P.Kind3.GebTag    # 0.0.0;
    Adr.P.Kind4.Name      # '';
    Adr.P.Kind4.GebTag    # 0.0.0;
    Erx # RekReplace(102);
    if (Erx<>_rOK) then begin
      Msg(999999,'Fehler!',0,0,0);
      RETURN
    end;
    Adr_Ktd_Data:UpdateFromPartner();
  END;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//
//========================================================================
sub GetEmaByCode(
  aAdr  : int;
  aCode : alpha) : alpha;
local begin
  Erx : int;
  vA    : alpha(4096);
end;
begin
  RecBufClear(102);
  Adr.P.Adressnr  # aAdr;
  Adr.P.Funktion  # aCode;

  Erx # RecRead(102,6,0);   // Ansprechpartner suchen
  
  WHILE (Erx<=_rMultikey) and
    (Adr.P.Adressnr=aAdr) and (Adr.P.Funktion=aCode) do begin
      if (vA<>'') then vA # vA + ';';
      vA # StrCut(vA + Adr.P.eMail, 1,3000);
      Erx # RecRead(102,6,_recNext);
    END;
  
  /***                     // SR & TM cleared den Ansprechpartner, wenn Funktion nicht gefunden
   if (Adr.P.Funktion != aCode) then begin
   RecBufClear(102)
   end;
   ***/
  RETURN vA;
end;

//========================================================================