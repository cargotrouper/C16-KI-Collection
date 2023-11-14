@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Mat
//                    OHNE E_R_G
//  Info
//
//
//  03.08.2011  AI  Erstellung der Prozedur
//  09.08.0212  AI  VLDAW_MIT_LFS
//  26.03.2015  ST  RebuildErlInfo() hinzugefügt
//  04.02.2022  AH  ERX
//  25.03.2022  AH  FillKundenArtNr
//  30.03.2022  TM  FillKundenArtNr Erweiterung um LohnFertigMat
//
//  Subprozeduren
//  SUB VLDAW_MIT_LFS()
//  SUB Verkaufte_Mat_ohne_Kommission
//  SUB MEHAktivieren();
//  SUB RebuildErlInfo()
//  SUB FillKundenArtNr();
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

define begin
end;

//========================================================================
//  VLDAW_MIT_LFS
//    call Repair_Mat:VLDAW_MIT_LFS
//========================================================================
sub VLDAW_MIT_LFS()
local begin
  Erx   : int;
  v204  : int;
end;
begin

  Erx # RecRead(204,1,_recfirst);
  WHILE (Erx<=_rLockeD) do begin
    if (Mat.A.Aktionstyp=c_Akt_LFS) then begin
      v204 # RekSave(204);
      Mat.A.Aktionstyp # c_Akt_VLDAW;
      Erx # RecRead(204,4,0);
      if (Erx<=_rMultikey) then begin
        RekDelete(204,0,'AUTO');
      end;
      RekRestore(v204);
      RecRead(204,1,0);
    end;
    Erx # RecRead(204,1,_recNext);
  END;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  Verkaufte_Mat_ohne_Kommission
//    call Repair_Mat:Verkaufte_Mat_ohne_Kommission
//========================================================================
sub Verkaufte_Mat_ohne_Kommission()
local begin
  Erx : int;
end;
begin

  RecBufClear(200);

  Erx # RecRead(200,1,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if ("Mat.Löschmarker"='') or (Mat.Auftragsnr<>0) then begin
      Erx # RecRead(200,1,_RecNext);
      CYCLE;
    end;

    if (Mat.EigenmaterialYN) then begin
      if (Mat.VK.Rechnr<>0) then begin
debug('repariere EIGEN Mat:'+aint(mat.nummer));
        Erx # RecLink(404,200,24,_recFirst);    // Aufaktion loopen
        WHILE (Erx<=_rLocked) and (Mat.Auftragsnr=0) do begin
          if (Auf.A.Rechnungsnr=Mat.VK.rechnr) then begin
            Auf_Data:Read(Auf.A.Nummer, Auf.A.Position,y);
            RecRead(200,1,_recLock);
            Mat.Auftragsnr    # Auf.A.Nummer;
            Mat.Auftragspos   # Auf.A.Position;
            Mat.Kommission    # AInt(Mat.Auftragsnr)+'/'+AInt(Mat.AuftragsPos);
            Mat.KommKundennr  # Auf.P.Kundennr;
            Erx # RecLink(100,200,7,0);
            if (Erx<=_rLocked) then Mat.KommKundenSWort # Adr.Stichwort
            RekReplacE(200,0,'AUTO');
          end;
          Erx # RecLink(404,200,24,_recNext);
        END;
if (mat.auftragsnr=0) then
debug('TOTAL DEFEKT EIGEN Mat:'+aint(mat.nummer));
      end;
    end;

    if (Mat.EigenmaterialYN=false) then begin
      if (Mat.Status=441) then begin
        Erx # RecLink(441,200,27,_recLast);  // LS-Position loopen
        if (Erx<=_rLocked) then begin
debug('repariere LOHN Mat:'+aint(mat.nummer));
          Auf_Data:Read(Lfs.P.AuftragsNr, Lfs.P.Auftragspos,y);
          RecRead(200,1,_recLock);
          Mat.Auftragsnr    # Lfs.p.Auftragsnr;
          Mat.Auftragspos   # Lfs.P.Auftragspos;
          Mat.Kommission    # AInt(Mat.Auftragsnr)+'/'+AInt(Mat.AuftragsPos);
          Mat.KommKundennr  # Auf.P.Kundennr;
          Erx # RecLink(100,200,7,0);
          if (Erx<=_rLocked) then Mat.KommKundenSWort # Adr.Stichwort
          RekReplacE(200,0,'AUTO');
        end
        else begin
debug('TOTAL DEFEKT LOHN Mat:'+aint(mat.nummer));
        end;

      end;
    end;


    Erx # RecRead(200,1,_recNext);
  END;


todo('DBEUG.TXT BEACHTEN!!!!!!');
  msg(999998,'',0,0,0);
end;


//========================================================================
//  MehAktivieren
//    call repair_mat:MehAktivieren
//========================================================================
SUB MEHAktivieren();
local begin
  Erx       : int;
  vDatei    : int;
  vX        : float;
  vGew      : float;
  vBestand  : float;
  vBestellt : float;
  vProto    : int;
end;
begin


  vProto # TextOpen(20);

  FOR vDatei # 200
  LOOP vDatei # vDatei + 10
  WHILE (vDatei<=210) do begin

    if (vDatei=200) then
      TextAddLine(vProto,'START MEH_ERMITTLUNG für Materialdatei')
    else
      TextAddLine(vProto,'START MEH_ERMITTLUNG für Materialablage');

    FOR Erx # RecRead(vDatei,1,_recFirst)
    LOOP Erx # RecRead(vDatei,1,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (vDatei=210) then RecbufCopy(210,200);
//if (mat.nummer=4418) then debugx('TEST '+Mat.MEH);

//      RekLink(819,200,1,_recFirst);             // Warengruppe holen
//      if (Wgr.Dateinummer<>209) then begin
//        TextAddLine(vProto,'Mat.'+aint(mat.Nummer)+' trägt keinen MATMIX Warengruppe '+Mat.Strukturnr);
//        RecBufClear(250);
//        Art.MEH # 't'
//        end
//      else begin
      if (Mat.Strukturnr='') then begin
        RecBufClear(250);
        Art.MEH # 't'
      end
      else begin
        Erx # RekLink(250,200,26,_recFirst);  // Artikel holen
        if (Erx>_rLocked) then begin
//          TextAddLine(vProto,'Mat.'+aint(mat.Nummer)+' UNBEKANNTEN Artikel "'+Mat.Strukturnr+'" - behandle Mat nun wie ohne Art. (also Tonne)');
          RecBufClear(250);
          Art.MEH # 't'
        end;
      end;


      if (Mat.MEH<>'') and (Mat.MEH<>Art.MEH) then begin
        TextAddLine(vProto,'Mat.'+aint(mat.Nummer)+' MEH wird von '+Mat.MEH+' auf '+Art.MEH+' verändert!');
      end;


      RecRead(vDatei,1,_recLock);
      Mat.MEH # Art.MEH;

  //if (MAt.Nummer=3099) then debug('bestand: '+anum(mat.bestand.gew+mat.bestellt.gew,2)+'kg');

      Mat.Bestand.Menge   # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
      Mat.Bestellt.Menge  # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestellt.Stk, Mat.Bestellt.Gew, Mat.Bestellt.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
//debug('bestellt: '+anum(mat.bestellt.gew,0)+' kg = '+anum(mat.bestellt,2)+' '+mat.meh);
      vGew # Mat.Bestand.Gew+Mat.Bestellt.Gew;
      // Keine Menge? Dann für 1000kg errechnen:
      if (vGew=0.0) then begin
        vGew # 1000.0;
        Mat.Bestand.Menge   # Rnd(Lib_Einheiten:WandleMEH(200, 0, vGew, vGew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
        Mat.Bestellt.Menge  # 0.0;
      end;

      if (vGew<>0.0) then begin
        vX # Mat.EK.preis * vGew / 1000.0;
        DivOrNull(Mat.EK.PreisProMEH, vX, (Mat.Bestand.Menge + Mat.Bestellt.Menge),2);
        vX # Mat.Kosten * vGew / 1000.0;
        DivOrNull(Mat.KostenproMEH, vX, (Mat.Bestand.Menge + Mat.Bestellt.Menge),2);
      end;
      Mat.Bestand.Menge     # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
      Mat.Bestellt.Menge    # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Bestellt.Stk, Mat.Bestellt.Gew, Mat.Bestellt.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
      Mat.Reserviert.Menge  # Rnd(Lib_Einheiten:WandleMEH(200, Mat.Reserviert.Stk, Mat.Reserviert.Gew, Mat.Reserviert.Gew, 'kg', Mat.MEH) ,Set.Stellen.Menge);
      "Mat.Verfügbar.Menge" # Mat.Bestand.Menge + Mat.Bestellt.Menge - Mat.Reserviert.Menge;



      // Profil/Rohr(Stab
      if (Wgr.Materialtyp=c_WgrTyp_Profil) or (Wgr.Materialtyp=c_WgrTyp_Rohr) or (Wgr.Materialtyp=c_WgrTyp_Stab) then begin
        if (Mat.MEH='m') then
          DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) * 1000.0, 5)
        else if (Mat.MEH='dm') then
          DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) * 100.0, 5)
        else if (Mat.MEH='cm') then
          DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge) * 10.0, 5)
        else if (Mat.MEH='mm') then
          DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), (Mat.Bestand.Menge + Mat.Bestellt.Menge), 5);
        else begin
          DivOrNull(Mat.KgMM, (Mat.Bestand.Gew+Mat.Bestellt.Gew), ("Mat.Länge" * cnvfi(Mat.Bestand.Stk+Mat.Bestellt.Stk) ), 5)
        end;
      end;

      // Speichern...
      if (vDatei=210) then RecBufCopy(200,210);
      if (RekReplace(vDatei,_recunlock,'AUTO')<>_rOK) then TextAddLine(vProto, 'replace fehler bei '+aint(mat.nummer));

//if (Art.Nummer='938383') then
//debug(aint(mat.nummer)+' '+anum(mat.bestand.gew,2)+'kg '+anum(Mat.Bestand.Menge,3)+Mat.MEH+'  '+"mat.löschmarker");

//      if (Mat.EK.Preis<>Mat.Ek.PreisProMeH) then debug('differenz bei:'+aint(mat.Nummer)+' in '+Mat.MEH+'  Alt:'+cnvaf(mat.ek.preis,0,0,8)+' neu:'+cnvaf(mat.ek.preisProMEH,0,0,8));

    END;

    TextAddLine(vProto,'...fertig');
    TextAddLine(vProto,'');
  END;



  // ALLE Artikel jetzt neu summieren,,,
  TextAddLine(vProto,'Starte Artikelreclac...');
  Art_Data:ReCalcAll();
  TextAddLine(vProto,'...fertig');
  TextAddLine(vProto,'');



  // Mengen gegenprüfen...
  TextAddLine(vProto,'Starte Mengenprüfung Artikel <-> Material...');
  FOR Erx # RecRead(250,1,_recFirst)
  LOOP Erx # RecRead(250,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

//if (Art.Nummer<>'100014') then CYCLE;

    Erx # RekLink(819,250,10,_recFirst);    // Warengruppe holen
    if (Wgr.Dateinummer=209) then begin

      vBestand  # 0.0;
      vBestellt # 0.0;
      // Basischarge holen
      RecBufClear(252);
      Art.C.ArtikelNr   # Art.Nummer;
      Art_Data:ReadCharge();

      FOR Erx # RecLink(200,250,8,_recFirst)
      LOOP Erx # RecLink(200,250,8,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if ("Mat.Löschmarker"='') then begin

          RekLink(819,200,1,_recFirst);             // Warengruppe holen

          if (Wgr_Data:IstMix()) then begin
            vBestand  # Rnd(vBestand + Mat.Bestand.Menge, set.stellen.menge);
            vBestellt # Rnd(vBestellt + Mat.Bestellt.Menge, Set.stellen.menge);
          end;
        end;
      END;

      if (vBestand<>Art.C.Bestand) then
        TextAddLine(vProto,'Art:'+Art.Nummer+' Bestand im Art:'+cnvaf(art.c.bestand,0,0,-2)+Art.MEH+'   im Mat:'+cnvaf(vBestand,0,0,-2)+Art.MEH);
      if (vBestellt<>Art.C.Bestellt) then
        TextAddLine(vProto,'Art:'+Art.Nummer+' Bestellt im Art:'+cnvaf(art.c.bestellt,0,0,-2)+Art.MEH+'   im Mat:'+cnvaf(vBestellt,0,0,-2)+Art.MEH);
    end;
  END;
  TextAddLine(vProto,'...fertig');
  TextAddLine(vProto,'');


  TextAddLine(vProto,'ENDE');

  // Ausgabe des Protokolls...
  TextDelete(myTmpText,0);
  TextWrite(vProto,MyTmpText,0);
  TextClose(vProto);
  Mdi_TxtEditor_Main:Start(MyTmpText, n, 'Protokoll');
  TextDelete(myTmpText,0);


  Msg(999998,'',0,0,0);
end;


//========================================================================
//  RebuildErlInfo
//    call Repair_mat:RebuildErlInfo
//========================================================================
sub RebuildErlInfo()
local begin
  Erx     : int;
  vProgr  : int;
end
begin

  vProgr # Lib_Progress:Init('Durchlaufe Auftragsaktionen',RecInfo(404,_RecCount));

  FOR   Erx # RecRead(404,1,_RecFirst)
  LOOP  Erx # RecRead(404,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN

    if (vProgr->Lib_Progress:Step() = false) then
      BREAK;

    // Nur Rechnungaktionen
    if (Auf.A.Rechnungsnr = 0) OR (Auf.A.Materialnr = 0) then
      CYCLE;

    // Rechnung lesen
    Erl.Rechnungsnr # Auf.A.Rechnungsnr;
    Erx # RecRead(450,1,0);
    if (Erx <> _rOK) then begin
      Msg(99,'Rechnung ' + Aint(Erl.Rechnungsnr) + ' konnte nicht gelesen werden. Auftragsaktion: ' + Aint(Auf.A.nummer) + '/'+ Aint(Auf.A.Position) + '/' + Aint(Auf.A.Aktion),_WinIcoError,1,1);
    end;


    // Material lesen und aktualisieren
    Mat.Nummer # Auf.A.MaterialNr;
    Erx # RecRead(200,1,_RecLock);
    if (Erx=_rOK) then begin  // Materialbestand
      if (Mat.VK.Rechnr<>0) and (Mat.VK.Rechnr<>Erl.Rechnungsnr) then begin
        RecRead(200,1,_RecUnlock);
        Msg(99,'Materialnummer ' + Aint(Auf.A.MaterialNr) + ' trägt bereits eine Rechnungsnummer!?! Auftragsaktion: ' + Aint(Auf.A.nummer) + '/'+ Aint(Auf.A.Position) + '/' + Aint(Auf.A.Aktion),_WinIcoError,1,1);
        CYCLE;
      end;
      RekLink(818,200,10,0);  // Verwiegungsart lesen
      Mat.VK.Kundennr   # Erl.Kundennummer;
      Mat.VK.Rechnr     # Erl.Rechnungsnr;
      Mat.VK.Rechdatum  # Erl.Rechnungsdatum;
      if (VwA.NettoYN) then
        Mat.VK.Gewicht # Auf.A.Nettogewicht
      else
        Mat.VK.Gewicht # Auf.A.Gewicht;
      Mat.VK.Preis # Auf.A.RechPreisW1;
      if (Mat.Bestand.Gew<>0.0) then
        Mat.VK.Preis      # Rnd(Mat.VK.Preis / Mat.Bestand.Gew *1000.0,2);
      Mat_data:Replace(_RecUnlock,'AUTO');
    end
    else begin  // Materialablage
      "Mat~Nummer" # Auf.A.MaterialNr;
      Erx # RecRead(210,1,_RecLock);
      if (Erx>=_rLocked) then begin
        Msg(99,'Materialnummer ' + Aint(Auf.A.MaterialNr) + ' konnte nicht gelesen werden. Auftragsaktion: ' + Aint(Auf.A.nummer) + '/'+ Aint(Auf.A.Position) + '/' + Aint(Auf.A.Aktion),_WinIcoError,1,1);
        CYCLE;
      end;
      if ("Mat~VK.Rechnr"<>0) and ("Mat~VK.Rechnr"<>Erl.Rechnungsnr) then begin
        RecRead(210,1,_RecUnlock);
        Msg(99,'Materialnummer ' + Aint(Auf.A.MaterialNr) + ' trägt bereits eine Rechnungsnummer!?! Auftragsaktion: ' + Aint(Auf.A.nummer) + '/'+ Aint(Auf.A.Position) + '/' + Aint(Auf.A.Aktion),_WinIcoError,1,1);
        CYCLE;
      end;

      RekLink(818,210,10,0);  // Verwiegungsart lesen
      "Mat~VK.Kundennr"   # Erl.Kundennummer;
      "Mat~VK.Rechnr"     # Erl.Rechnungsnr;
      "Mat~VK.Rechdatum"  # Erl.Rechnungsdatum;
      if (VwA.NettoYN) then
        "Mat~VK.Gewicht" # Auf.A.Nettogewicht
      else
        "Mat~VK.Gewicht" # Auf.A.Gewicht;

      "Mat~VK.Preis" # Auf.A.RechPreisW1;
/*
      if ("Mat~VK.Gewicht"<>0.0) then
        "Mat~VK.Preis"      # vPosGewicht / "Mat~VK.Gewicht"
      else if (Mat.Bestand.Gew<>0.0) then
        "Mat~VK.Preis"      # vPosGewicht / "Mat~Bestand.Gew"
      else "Mat~VK.Preis" # 0.0;
*/
      Mat_Abl_data:ReplaceAblage(_RecUnlock,'AUTO');
    end;

    // Nächste Aktion
  END;

  vProgr->Lib_Progress:Term();

end;


//========================================================================
//========================================================================
sub _RebuildMatASchrottnullungMat()
local begin
  Erx       : int;
  vM        : float;
  vGew      : float;
  vStk      : int;
end
begin
  vM    # Mat.Bestand.Menge + Mat.Bestellt.Menge;
  vStk  # Mat.Bestand.Stk + Mat.Bestellt.Stk;
  vGew  # Mat.Bestand.Gew + Mat.Bestellt.Gew;

  if (vM=0.0) then begin
    if (vGew=0.0) then begin
      if (vStk=0) then vStk # 10;
      Erx # RekLink(819,200,1,0);   // Warengruppe holen
      vGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(vStk, Mat.Dicke, Mat.Breite, "Mat.Länge", Mat.Dichte, "Wgr.TränenKgProQM");
      if (vGew=0.0) then begin
        vGew # 1000.0;
        vStk # Lib_Berechnungen:Stk_aus_KgDBLDichte2(vGew, Mat.Dicke, Mat.Breite, "Mat.Länge", Mat.Dichte, "Wgr.TränenKgProQM");
      end;
    end;
    vM # Mat_Data:MengeVorlaeufig( vStk, vGew, vGew);
  end;

  RecRead(204,1,_RecLock);
  if (vM<>0.0) then
    Mat.A.KostenW1ProMEH # Rnd( (Mat.A.KostenW1 * vGew / 1000.0) / vM ,2);
  if (vM<>0.0) then
    Mat.A.Kosten2W1ProME # Rnd( (Mat.A.Kosten2W1 * vGew / 1000.0) / vM ,2);

  RekReplace(204,_RecUnLock);
    
  Mat_A_Data:Vererben();
end;


//========================================================================
//  RebuildMatASchrottnullung()
//    call Repair_mat:RebuildMatASchrottnullung
//========================================================================
sub RebuildMatASchrottnullung()
local begin
  Erx         : int;
  vProgr      : int;
  vKostenEff  : float;
end
begin
  vProgr # Lib_Progress:Init('Durchlaufe Materialaktionen',RecInfo(204,_RecCount));
  
  FOR Erx # RecRead(204,1,_RecFirst)
  LOOP Erx # RecRead(204,1,_RecNext)
  WHILE Erx= _rOK DO BEGIN
    vProgr->Lib_Progress:Step();
    
    if (Mat.A.Kosten2W1ProME = 0.0) and (Mat.A.Kosten2W1 <> 0.0) then begin
      RekLink(200,204,1,0); // Material
      if (Mat.Status < 700) OR(Mat.Status > 799) then
        CYCLE;
       
      vKostenEff # Mat.EK.Effektiv + Mat.EK.EffektivProME;
      _RebuildMatASchrottnullungMat();
      if (vKostenEff  <>(Mat.EK.Effektiv + Mat.EK.EffektivProME)) then
        debugstamp('Korrigiert:' + Aint(Mat.Nummer));
    end;
  END;
 
  vProgr->Lib_Progress:Term();
end;


//========================================================================
//  Call Repair_Mat:RebuildMatKosten
//========================================================================
sub RebuildMatKosten()
local begin
  Erx         : int;
  vProgr      : int;
  vKostenEff  : float;
end
begin
  vProgr # Lib_Progress:Init('Durchlaufe Material',RecInfo(200,_RecCount));
  
  FOR Erx # RecRead(200,1,_RecFirst)
  LOOP Erx # RecRead(200,1,_RecNext)
  WHILE Erx= _rOK DO BEGIN
    vProgr->Lib_Progress:Step();
//    if (Mat.Nummer=5167) then begin
      Mat_A_Data:AddKosten(200);
//    end;
  END;
 
  vProgr->Lib_Progress:Term();
end;


//========================================================================
// Call FillKundenArtNr()
//========================================================================
SUB FillKundenArtNr()
local begin
  Erx : int;
end;
begin




  // Material loopen...
  FOR Erx # RecRead(200,1,_recFirst)
  LOOP Erx # RecRead(200,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    
    if (Mat.Auftragsnr=0) then CYCLE;
    
    If (Mat.EigenmaterialYN) then begin
      Erx # Auf_Data:read(Mat.Auftragsnr, Mat.Auftragspos, false);
      if (Erx>=400) then begin
        if (Mat.KundenArtNr<>Auf.P.KundenArtNr) then begin
          RecRead(200,1, _recLock);
          Mat.KundenArtNr # Auf.P.KundenArtNr;
          RekReplace(200);
        end;
      end;
    end

    else begin
      Erx # RecLink(707,200,28,0);
      if (Erx > _rLocked) then CYCLE;
      Erx # RecLink(703,707,3,0);
      if (Erx > _rLocked) then CYCLE;
    
      if (Mat.KundenArtNr<>BAG.F.KundenArtNr) then begin
        RecRead(200,1, _recLock);
        Mat.KundenArtNr # BAG.F.KundenArtNr;
        RekReplace(200);
      end;
    end;
  
  END;
  
  // Materialablage loopen...
  FOR Erx # RecRead(210,1,_recFirst)
  LOOP Erx # RecRead(210,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if ("Mat~Auftragsnr"=0) then CYCLE;
    
    If (Mat.EigenmaterialYN) then begin
    
      Erx # Auf_Data:read("Mat~Auftragsnr", "Mat~Auftragspos", false);
      if (Erx>=400) then begin
        if ("Mat~KundenArtNr"<>Auf.P.KundenArtNr) then begin
          RecRead(210,1, _recLock);
          "Mat~KundenArtNr" # Auf.P.KundenArtNr;
          RekReplace(210);
        end;
      end;
    end
    
    else begin
      Erx # RecLink(707,210,28,0);
      if (Erx > _rLocked) then CYCLE;
      Erx # RecLink(703,707,3,0);
      if (Erx > _rLocked) then CYCLE;
    
      if ("Mat~KundenArtNr"<>BAG.F.KundenArtNr) then begin
        RecRead(210,1, _recLock);
        "Mat~KundenArtNr" # BAG.F.KundenArtNr;
        RekReplace(210);
      end;
    end;
  
  END;
  
  Msg(999998,'',0,0,0);
  
end;

//========================================================================