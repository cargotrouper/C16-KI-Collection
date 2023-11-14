@A+
//===== Business-Control =================================================
//
//  Prozedur    EKK_Data
//                  OHNe E_R_G
//  Info
//
//
//  02.06.2005  AI  Erstellung der Prozedur
//  07.04.2017  AH  "Mark2ERe"
//  26.06.2017  AH  Ringnummer in EKK
//  13.09.2017  AH  Wareneingang setzte MEH laut PreisMEH
//  04.11.2021  AH  AFX "EKK.Update"
//  21.02.2022  AH  ERX
//  2022-09-13  AH  "Aufheben"
//  2023-01-16  AH  bei Ein.Kalkulation ggf. Lieferant aus Bestellkopf
//  2023-01-24  AH  Ein.Kalkaulationen immer in W1
//  2023-03-17  AH  Kalkulationen HWN
//  2023-06-22  AH  "Update" braucht aBasiswert für Rückstellungen/EK-Kalkulation wegen MEH "%"
//
//  Subprozeduren
//    SUB SumMarkiert
//    SUB BereitsVerbuchtYN
//    SUB Update
//    SUB Mark2ERe
//    SUB Aufheben
//
//========================================================================
@I:Def_global
@I:Def_Rights
@I:Def_Aktionen

//========================================================================
//  SumMarkiert
//
//========================================================================
sub SumMarkiert() : float;
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vX      : float;
end;
begin
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile=555) then begin
      RecRead(555,0,_RecId,vMID);
      vX # vX + EKK.PreisW1;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RETURN vX;
end;


//========================================================================
//  BereitsVerbuchtYN
//
//========================================================================
sub BereitsVerbuchtYN(aDatei : int) : logic;
local begin
  Erx : int;
end;
begin

  RecBufClear(555);

  case (aDatei) of

    204 : begin   // Mat-Aktione
      EKK.Datei           # 204;
      EKK.ID1             # Mat.A.Materialnr;
      EKK.ID2             # Mat.A.Aktion;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      Erx # RecRead(555,1,0);
    end;

    450 : begin   // Ausgangsrechnungsrckstellung (451->405)
      EKK.Datei           # 450;
      EKK.ID1             # Erl.Rechnungsnr;
      EKK.ID2             # 0;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      Erx # RecRead(555,1,0);
      Erx # RecRead(555,1,0);
      WHILE (Erx<=_rLocked) and (EKK.ID1=Erl.REchnungsnr) do begin
        if (EKK.EingangsreNr<>0) then RETURN true;
        Erx # RecRead(555,1,_recNext);
      END;
      RETURN false;
//      if (Erx=_rNoRec) then RETURN false;
//      if (EKK.ID1<>Erl.Rechnungsnr) then RETURN false;
//      Erx # _rOk;
    end;

    501 : begin   // Einkauf Divers
      EKK.Datei           # 501;
      EKK.ID1             # Ein.P.Nummer;
      EKK.ID2             # Ein.P.Position;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      Erx # RecRead(555,1,0);
    end;

    505 : begin   // Einkauf Kalkulation
      EKK.Datei           # 505;
      EKK.ID1             # Ein.K.Nummer;
      EKK.ID2             # Ein.K.Position;
      EKK.ID3             # Ein.E.Eingangsnr;
      EKK.ID4             # Ein.K.lfdNr;
      Erx # RecRead(555,1,0);
    end;

    506 : begin   // Einkauf Wareneingang
      EKK.Datei           # 506;
      EKK.ID1             # Ein.E.Nummer;
      EKK.ID2             # Ein.E.Position;
      EKK.ID3             # Ein.E.Eingangsnr;
      EKK.ID4             # 0;
      Erx # RecRead(555,1,0);
    end;

    702 : begin   // Betriebsauftrag
      EKK.Datei           # 702;
      EKK.ID1             # BAG.P.Nummer;
      EKK.ID2             # BAG.P.Position;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      Erx # RecRead(555,1,0);
    end

    otherwise begin
todo('EKK für Datei '+AInt(aDatei));
      RETURN false;
    end;

  end;


  if (Erx>=_rLocked) then RETURN false;
  if (EKK.EingangsreNr=0) then RETURN false;

  RETURN true;
end;


//========================================================================
//  Update
//
//========================================================================
sub Update(
  aDatei          : int;
  opt aBasiswert  : float;) : logic;
local begin
  Erx     : int;
  vMenge  : float;
end;
begin

  // 04.11.2021 AH
  if (RunAFX('EKK.Update',aint(aDatei))<0) then begin
    RETURN (AfxRes=_rOK);
  end;

  // EKK bereits zugeordnet??
  if (BereitsVerbuchtYN(aDatei)) then begin
//    Msg(506555,'',0,0,0);
//    RETURN false;
    RETURN true;
  end;


  RecBufClear(555);

  case aDatei of

    204 : begin   // Mat-Aktion *******************************************

      EKK.Datei           # 204;
      EKK.ID1             # Mat.A.Materialnr;
      EKK.ID2             # Mat.A.Aktion;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      // ggf. bisherige EKK löschen
      RekDelete(555,0,'AUTO');

//      EKK.Lieferant       # 0;
//      EKK.LieferStichwort # Ein.P.LieferantenSW;
      EKK.Datum           # Mat.A.Aktionsdatum;
      "EKK.Währung"       # 1;
      "EKK.Währungskurs"  # 1.0;

      vMenge # Mat.Bestand.Menge;//b_Einheiten:WandleMEH(200, Mat.Bestand.Stk, Mat.Bestand.Gew, Mat.Bestand, Mat.MEH, Mat.MEH);
      EKK.Preis           # Mat.A.KostenW1 * vMenge / 1000.0;
      EKK.PreisW1         # Rnd(EKK.Preis / "EKK.Währungskurs",2)
      "EKK.Stückzahl"     # Mat.Bestand.Stk;
      EKK.Gewicht         # Mat.Bestand.Gew;
      EKK.Menge           # vMenge;
      EKK.MEH             # 'kg';

      EKK.Materialnummer  # Mat.Nummer;
      "EKK.Güte"          # "Mat.Güte";
      EKK.Dicke           # Mat.Dicke;
      EKK.Breite          # Mat.Breite;
      "EKK.Länge"         # "Mat.Länge";
      EKK.Coilnummer      # Mat.Coilnummer;
      EKK.Ringnummer      # Mat.Ringnummer;

      EKK.Artikelnummer   # Mat.Strukturnr;
      EKK.Chargennummer   # '';
      EKK.Bemerkung       # StrCut(Mat.A.Bemerkung, 1, 64);

      // EKK neu anlegen
      Erx # RekInsert(555,0,'AUTO');
      end;

    
    450 : begin   // Erlös (über Auf.Kalk. 405) ***************************
//          vWert  #  Rnd(Auf.K.Preis * vMenge / CnvFI(Auf.K.PEH),2);
      EKK.Datei           # 450;
      EKK.ID1             # Erl.K.Rechnungsnr;
      EKK.ID2             # Erl.K.lfdNr;
      EKK.ID3             # Auf.K.lfdNr;
      EKK.ID4             # 0;
      // ggf. bisherige EKK löschen
      Erx # RekDelete(555,0,'AUTO');

//      Erx # RecLink(100,405,1, _RecFirst);  // Lieferant holen
//      if (Erx>_rLocked) then RecBufClear(100);

      EKK.Lieferant       # Auf.K.LieferantenNr;
      Erx # RecLink(100,555,4, _RecFirst);  // Lieferant holen
      if (Erx>_rLocked) then RecBufClear(100);
      EKK.LieferStichwort # Adr.Stichwort;
      EKK.Datum           # Erl.K.Rechnungsdatum;
      "EKK.Währung"       # "Erl.Währung";
      "EKK.Währungskurs"  # "Erl.WährungsKurs";
      EKK.Lieferscheinnr  # '';
//      EKK.Lief.AB.Nummer  # '';
      EKK.Lief.AB.Nummer  # cnvai(Auf.P.Nummer)+'/'+cnvai(Auf.P.Position);

      if (Auf.K.PEH<>0) then
        EKK.Preis           # Rnd(Auf.K.Preis * Auf.K.Menge / CnvFI(Auf.K.PEH),2);
      if ("EKK.Währungskurs"<>0.0) then
        EKK.PreisW1         # Rnd(EKK.Preis / "EKK.Währungskurs",2)
      "EKK.Stückzahl"     # 0;
      EKK.Gewicht         # 0.0;
      EKK.Menge           # Auf.K.Menge;
      EKK.MEH             # Auf.K.MEH;

      EKK.Materialnummer  # 0;
      // EKK neu anlegen
      Erx # RekInsert(555,0,'AUTO');

    end;


    505 : begin   // Einkauf Kalkulation **********************************

      if ("Ein.K.NachtragYN"=n) and ("Ein.K.RückstellungYN"=n) then RETURN true;

      begin    // RÜCKSTELLUNG ***** können aus andere Währung kommen ALSO IMMER W1

        Erx # RecLink(500,501,3,_RecFirst); // Bestellkopf holen

        // nur eigene Zahlungen
        Erx # RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
        if (Ein.Rechnungsempf<>0) and (Ein.Rechnungsempf<>Adr.Lieferantennr) then RETURN true;

        EKK.Datei           # 505;
        EKK.ID1             # Ein.K.Nummer;
        EKK.ID2             # Ein.K.Position;
        EKK.ID3             # Ein.E.Eingangsnr;
        EKK.ID4             # Ein.K.lfdNr;
        // ggf. bisherige EKK löschen
        Erx # RekDelete(555,0,'AUTO');
        // 2023-06-20 AH zum Löschen
        if ("Ein.K.Löschmarker"='*') then RETURN (erx=_rOK);

//        Erx # RecLink(814,500,8,_RecFirst); // Währung holen
//        Erx # RecLink(814,506,16,_recFirst);   // Währung holen

        // Lieferant holen
//        Erx # RecLink(100,505,1,_recfirst);
//        if (Erx>_rLocked) then RecBufClear(100);
        EKK.Lieferant       # Ein.K.Lieferantennr;
        if (Ekk.Lieferant=0) then EKK.Lieferant # Ein.P.Lieferantennr;  //  2023-01-16  AH
        Erx # RecLink(100,555,4, _RecFirst);  // Lieferant holen
        if (Erx>_rLocked) then RecBufClear(100);

        EKK.LieferStichwort # Adr.Stichwort;
        EKK.Datum           # today;
        "EKK.Währung"       # 1;
//        "EKK.Währung"       # "Ein.E.Währung";
//        if ("Ein.WährungFixYN") then
//          "EKK.Währungskurs" # "Ein.Währungskurs"
//        else
//          "EKK.Währungskurs" # Wae.EK.Kurs;

        // Daten aus WARENEINGANG (!!!)
        EKK.Datum           # Ein.E.Eingang_Datum;
        if (Ein.K.MEH='%') then begin
// 2023-06-22 AH Prozente auf Basiswert rechnen...
//          vMenge # Lib_Einheiten:WandleMEH(501, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH);
//          EKK.Preis # Ein.E.Preis / Cnvfi(Ein.P.PEH) * vMenge;
//          EKK.Preis # EKK.Preis / Cnvfi(Ein.K.PEH) * Ein.K.Menge;
          EKK.Preis # aBasiswert;
          Ein.K.PEH   # 100;
          EKK.Preis   # Rnd(EKK.Preis / Cnvfi(Ein.K.PEH) * Ein.K.Menge,2);
          vMenge      # 1.0;
        end
        else begin
          if (Ein.K.MengenbezugYN) then begin
            vMenge # Lib_Einheiten:WandleMEH(501, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.K.MEH);
            if (Ein.K.PEH<>0) then
            EKK.Preis           # Ein.K.Preis * vMenge / Cnvfi(Ein.K.PEH);
          end
          else begin
            EKK.Preis # Ein.K.Preis;
            if (Ein.K.PEH=0) then Ein.K.PEH # 1;
            if (Ein.K.Menge<>0.0) then
              EKK.Preis # Ein.K.Preis * Ein.K.Menge / cnvfi(Ein.K.PEH);
          end;
        end;
// 2023-01-24 AH        if ("EKK.Währungskurs"<>0.0) then
//          EKK.PreisW1         # Rnd(EKK.Preis / "EKK.Währungskurs",2)
        EKK.PreisW1         # EKK.Preis;

        "EKK.Stückzahl"     # "Ein.E.Stückzahl";
        EKK.Gewicht         # Ein.E.Gewicht;
        EKK.Menge           # Ein.E.Menge;
        EKK.MEH             # Ein.E.MEH;
        EKK.Lieferscheinnr  # Ein.E.Lieferscheinnr;
        EKK.Lief.AB.Nummer  # Ein.P.AB.Nummer;
        if (EKK.Lief.AB.Nummer='') then
          EKK.Lief.AB.Nummer  # Ein.AB.Nummer;

        if (Wgr_Data:IstMat(Ein.P.Wgr.Dateinr) or (Wgr_Data:IstMix(Ein.P.Wgr.Dateinr))) then begin
          EKK.Materialnummer  # Ein.E.Materialnr;
          EKK.Mat.Aktionsnr   # Mat.A.Aktion;
        end;
        // EKK neu anlegen
        Erx # RekInsert(555,0,'AUTO');
      end; // Rückstellung
    end;


    506 : begin   // Einkauf Wareneingang *********************************
      // Bestellposition/Kopf holen
      Erx # RecLink(501,506,1,_RecFirst);
      Erx # RecLink(500,501,3,_RecFirst);

      // nur eigene Zahlungen
      Erx # RecLink(100,500,4,_recFirst);   // Rechnungsempf. holen
      if (Ein.Rechnungsempf<>0) and (Ein.Rechnungsempf<>Adr.Lieferantennr) then RETURN true;

      EKK.Datei           # 506;
      EKK.ID1             # Ein.E.Nummer;
      EKK.ID2             # Ein.E.Position;
      EKK.ID3             # Ein.E.Eingangsnr;
      EKK.ID4             # 0;
      // ggf. bisherige EKK löschen
      RekDelete(555,0,'AUTO');

      if (Ein.E.EingangYN=n) or ("Ein.E.Löschmarker"='*') then RETURN true;

      RecLink(819,506,4,_RecFirst);       // Warengruppe holen
//      Erx # RecLink(814,500,8,_RecFirst); // Währung holen
      Erx # RecLink(814,506,16,_recFirst);   // Währung holen

      EKK.Lieferant       # Ein.P.Lieferantennr;
      EKK.LieferStichwort # Ein.P.LieferantenSW;
      EKK.Datum           # Ein.E.Eingang_Datum;
      "EKK.Währung"       # "Ein.E.Währung";
      if ("Ein.WährungFixYN") then
        "EKK.Währungskurs" # "Ein.Währungskurs"
      else
        "EKK.Währungskurs" # Wae.EK.Kurs;
      EKK.Lieferscheinnr  # Ein.E.Lieferscheinnr;
      EKK.Lief.AB.Nummer  # Ein.P.Ab.Nummer;
      if (EKK.Lief.AB.Nummer='') then
        EKK.Lief.AB.Nummer  # Ein.AB.Nummer;

      // 13.09.2017
      if (Ein.P.MEH.Preis=Ein.E.MEH) then
        vMenge # Ein.E.Menge
      else if (Ein.P.MEH.Preis=Ein.E.MEH2) then
        vMenge # Ein.E.Menge2
      else
        vMenge # Lib_Einheiten:WandleMEH(506, "Ein.E.Stückzahl", Ein.E.Gewicht, Ein.E.Menge, Ein.E.MEH, Ein.P.MEH.Preis);
//debug('xxx:'+cnvaf(vMenge)+'MEH   '+cnvaf(ein.E.preis));
      if (Ein.P.PEH<>0) then begin
        EKK.Preis           # Ein.E.Preis * vMenge / Cnvfi(Ein.P.PEH);
        EKK.PreisW1         # Ein.E.PreisW1* vMenge / Cnvfi(Ein.P.PEH);
      end;
//      if ("EKK.Währungskurs"<>0.0) then
//        EKK.PreisW1         # Rnd(EKK.Preis / "EKK.Währungskurs",2)
      "EKK.Stückzahl"     # "Ein.E.Stückzahl";
      EKK.Gewicht         # Ein.E.Gewicht;
      EKK.Menge           # vMenge;//Ein.E.Menge;   13.09.2017
      EKK.MEH             # Ein.P.MEH.Preis;//Ein.E.MEH;

      EKK.Materialnummer  # Ein.E.Materialnr;
      "EKK.Güte"          # "Ein.E.Güte";
      EKK.Dicke           # Ein.E.Dicke;
      EKK.Breite          # Ein.E.Breite;
      "EKK.Länge"         # "Ein.E.Länge";
      EKK.Coilnummer      # Ein.E.Coilnummer;
      EKK.Ringnummer      # Ein.E.Ringnummer;

      EKK.Artikelnummer   # Ein.E.Artikelnr;
      EKK.Chargennummer   # Ein.E.Charge;
      EKK.Bemerkung       # StrCut(Ein.E.Bemerkung, 1, 64);

      // EKK neu anlegen
      Erx # RekInsert(555,0,'AUTO');
      end;


    702 : begin   // Betriebsauftrag **************************************
      RecRead(702,1,0);
      if (BAG.P.ExternYN=n) then RETURN true;       // nur externe BAs

      EKK.Datei           # 702;
      EKK.ID1             # BAG.P.Nummer;
      EKK.ID2             # BAG.P.Position;
      EKK.ID3             # 0;
      EKK.ID4             # 0;
      // ggf. bisherige EKK löschen
      RekDelete(555,0,'AUTO');

      if (BAG.P.Fertig.Dat=0.0.0) then RETURN true; // nur fertige BAs


      Erx # RecLink(814,702,15,_RecFirst);  // Währung holen
//      Erx # RecLink(100,702,7, _RecFirst);  // Lieferant holen
//      if (Erx>_rLocked) then RecBufClear(100);

      EKK.Lieferant       # BAG.P.ExterneLiefNr;
      Erx # RecLink(100,555,4, _RecFirst);  // Lieferant holen
      if (Erx>_rLocked) then RecBufClear(100);

      EKK.LieferStichwort # Adr.Stichwort;
      EKK.Datum           # BAG.P.Fertig.Dat;
      "EKK.Währung"       # BAG.P.Kosten.Wae;
      "EKK.Währungskurs"  # Wae.EK.Kurs;
//todo(anum(bag.p.kosten.ges.gew,0));
      EKK.Preis           # BAG.P.Kosten.Gesamt;
      if ("EKK.Währungskurs"<>0.0) then
        EKK.PreisW1         # Rnd(EKK.Preis / "EKK.Währungskurs",2)
      "EKK.Stückzahl"     # BAG.P.Kosten.Ges.Stk;
      EKK.Gewicht         # BAG.P.Kosten.Ges.Gew;
      EKK.Menge           # BAG.P.Kosten.Ges.Men;
      EKK.MEH             # BAG.P.Kosten.Ges.MEH;

      EKK.Lief.AB.Nummer  # BAG.P.Kommission;

      EKK.Materialnummer  # 0;
      EKK.Bemerkung       # BAG.P.Bemerkung;

      // EKK neu anlegen
      Erx # RekInsert(555,0,'AUTO');
      end


  otherwise begin
todo('EKK für Datei '+AInt(aDatei));
    RETURN false;
    end;

  end;


  if (Erx<>_rOK) then RETURN false;


  RETURN true;
end;


//========================================================================
//  Mark2Ere
//      markierte EKKs zu einer neuen Eingangsrechnungn (ERE) wandeln
//========================================================================
Sub Mark2Ere();
local begin
  Erx       : int;
  vAnz      : int;
  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vNetto    : float;
  vNettoW1  : float;
  vLf       : int;
  v560      : int;
  vWae      : int;
  vStk      : int;
  vGew      : float;
  vList     : int;
end;
begin

  if (Rechte[Rgt_ERe]=false) then RETURN;

  If (Lib_Mark:Count(555)=0) then begin
    Msg(9997006,'',0,0,0);    // nix markiert!
    RETURN;
  end;

  vList # CteOpen(_CteList);

  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile=555) then begin
      RecRead(555,0,_RecId,vMID);
      if (EKK.Eingangsrenr<>0) then begin
        Lib_Ramsort:KillList(vList);
        Msg(555007,'!',0,0,0);
        RETURN;
      end;
      if (vLf=0) then vLf # EKK.Lieferant;
      if (vLF<>EKK.Lieferant) then begin
        Lib_Ramsort:KillList(vList);
        Msg(555008,Translate('Lieferant'),0,0,0);
        RETURN;
      end;

      if (vWae=0) then vWAe # "EKK.Währung";
      if (vWae<>"EKK.Währung") then begin
        Lib_Ramsort:KillList(vList);
        Msg(555008,Translate('Währung'),0,0,0);
        RETURN;
      end;

      vList->CteInsertItem(cnvab(RecInfo(555,_recID)),RecInfo(555,_recID), anum(Ekk.Preis,2));
      vAnz      # vAnz + 1;
      vNetto    # vNetto + EKK.Preis;
      vNettow1  # vNettoW1 + EKK.PreisW1;
      vStk      # vStk + "EKK.Stückzahl";
      vGew      # VGew + EKK.Gewicht;
    end;
  END;

  Wae.Nummer  # vWae;
  Erx # RecRead(814,1,0);     // Währung holen
  if (Msg(555009,aint(vAnz)+'|'+anum(vNetto,2)+' '+"Wae.Kürzel",_WinIcoQuestion,_WinDialogYesNo,1)<>_Winidyes) then begin
    Lib_Ramsort:KillList(vList);
    RETURN;
  end;


  // ERE vorbelegen...
  Erx # RecLink(100,555,4,_recFirst);     // Lieferant holen
  Erx # RecLink(813,100,11,_recFirst);    // Steuerschluessel holen

  RecBufClear(560);
  "ERe.Stückzahl"     # vStk;
  ERe.Gewicht         # vGew;
  ERe.Lieferant       # vLf;
  ERe.LieferStichwort # Adr.Stichwort;
  ERe.Adr.Steuerschl  # "Adr.Steuerschlüssel";
  ERe.LKZ             # Adr.LKZ;
  if (Sts.LKZ<>'') then
    ERe.LKZ # Sts.LKZ;
  "ERe.Währung"       # vWae;
  "ERe.Währungskurs"  # Wae.EK.Kurs;
  ERe.Rechnungstyp    # Set.ERe.Rechnungstyp;
  ERe.Netto           # vNetto;
  ERe.NettoW1         # vNettoW1;
  ERe.Steuer          # Rnd((ERe.Netto/100.0)*StS.Prozent,2);
  ERe.Brutto          # ERe.Steuer + ERe.Netto;
  ERe.Rest            # Rnd(ERe.Brutto - ERe.Zahlungen,2);
  ERe.Skonto          # Rnd(ERe.Brutto * ERe.SkontoProzent/100.0,2);
  if ("ERe.WÄhrungskurs"<>0.0) then begin
    ERe.SteuerW1        # ERe.Steuer       / "ERe.Währungskurs";
    ERe.BruttoW1        # ERe.Brutto       / "ERe.Währungskurs";
    ERe.SkontoW1        # ERe.Skonto       / "ERe.Währungskurs";
    ERe.RestW1          # ERe.Rest         / "ERe.Währungskurs";
  end;
  ERe.SkontoW1  # Rnd(ERe.BruttoW1 * ERe.SkontoProzent/100.0,2);
  v560 # RekSave(560);


//  if (gMdiERe = 0) then begin
//    gMdiERe # Lib_GuiCom:OpenMdi(gFrmMain, 'ERe.Verwaltung', _WinAddHidden);
//    VarInstance(WindowBonus,cnvIA(gMDIERe->wpcustom));
//    Mode # c_ModeNew;
//    w_Command # 'vonEKK';
//    Filter_ERe # y;
//    Lib_Sel:QRecList( 0, '"ERe.Löschmarker" = ''''' );
//    gMdiERe->WinUpdate(_WinUpdOn);
//    $NB.Main->WinFocusSet(true);

    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'ERe.Verwaltung', '', true);//here+':AusLFS');
    // gleich in Neuanlage....
    VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//    Mode # c_ModeNew;
Mode # c_modeBald + c_modeNew;
    w_Command # 'vonEKK|'+aint(v560)+'|'+aint(vList);

    Lib_GuiCom:RunChildWindow(gMDI);
/*
  end
  else begin
    VarInstance(WindowBonus,cnvIA(gMDIEre->wpcustom));
    if (Mode<>c_ModeList) and (Mode<>c_ModeView) then begin
      Lib_Ramsort:KillList(vList);
      VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
      RecBufDestroy(v560);
      RETURN;
    end;

Mode # c_modeBald + c_modeNew;
    w_Command # 'vonEKK|'+aint(v560)+'|'+aint(vList);
    Lib_guiCom:ReOpenMDI(gMdiERe);
  end;
*/

end;


//========================================================================
//  EKK_Aktion
//========================================================================
sub EKK_Aktion(
  aMatNr  : int) : logic;
local begin
  vOK     : logic;
end;
begin
  // 14.03.2022 AH
  if (RunAFX('EKK.Aktion',aint(aMatNr))<0) then RETURN (AfxRes=_rOK);

  if (Mat.Nummer<>aMatNr) then begin
    Mat_Data:Read(aMatNr);
  end;

  RecBufClear(204);
  Mat.A.Materialnr    # aMatNr;
  Mat.A.Aktionsmat    # aMatNr;
  Mat.A.Aktionstyp    # c_akt_EKK;
  Mat.A.EK.RechNr     # 0;
  Mat.A.Bemerkung     # c_aktBem_EKK;
  Mat.A.Aktionsdatum  # today;
  Mat.A.Terminstart   # today;
  Mat.A.Terminende    # today;
  Mat.A.Adressnr      # 0;
  Mat.A.KostenW1      # 0.0;
  if (Mat_A_data:Insert(0,'AUTO')=_rOK) then begin
    if (gZLList->wpDbSelection<>0) then
      SelRecInsert(gZLList->wpDbSelection,gfile);
  end;
end;


/*========================================================================
2022-09-13  AH  Proj. 2429/303/10
========================================================================*/
sub Aufheben() : int
local begin
  Erx : int;
end;
begin
  
  TRANSON;
  
  Erx # RecRead(555, 1, _RecLock);
  if (Erx=_rDeadlock) then RETURN Erx;
  EKK.EingangsReNr    # 0;
  EKK.Zuordnung.Datum # 0.0.0;
  EKK.Zuordnung.Zeit  # 0:0;
  EKK.Zuordnung.User  # '';
  Erx # Rekreplace(555,_recUnlock,'AUTO');
  if (Erx=_rDeadlock) then RETURN Erx;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN Erx;
  end;

  // Wareneingang?
  if (EKK.Datei=506) then begin
    Erx # RecLink(506,555,2,_RecFirst);
    if (Erx>_rOK) then RecBufClear(506);
    // Materialeingang?
    if (Ein.E.Materialnr<>0) then begin
      Erx # RecLink(200,506,8,_recFirst);
      if (Erx=_rOK) then begin
        Erx # RecRead(200,1,_recLock);
        if (Erx=_rDeadlock) then RETURN Erx;
        Mat.EK.RechNr # 0;
        Mat.EK.RechDatum # 0.0.0;
        Erx # Mat_data:Replace(_RecUnlock,'AUTO');
        if (Erx=_rDeadlock) then RETURN Erx;
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RETURN Erx;
        end;
      end
      else begin
        Erx # RecLink(210,506,9,_recFirst);
        if (Erx=_rDeadlock) then RETURN Erx;
        if (Erx=_rOK) then begin
          Erx # RecRead(210,1,_recLock);
          if (Erx=_rDeadlock) then RETURN Erx;
          "Mat~EK.RechNr"     # 0;
          "Mat~EK.RechDatum"  # 0.0.0;
          Erx # Mat_Abl_Data:ReplaceAblage(_RecUnlock,'AUTO');
          if (Erx=_rDeadlock) then RETURN Erx;
        end;
      end;
    end;
  end;

  if (Erx<>_rOK) then begin
    TRANSBRK;
    RETURN Erx;
  end;

  TRANSOFF;
  RETURN Erx;
end;


//========================================================================