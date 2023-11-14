@A+
//===== Business-Control =================================================
//
//  Prozedur    Auf_P_Subs
//                  OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  18.06.2010  AI  ToggleLöschmarker bei Abrufen refreseh Liferverträge
//  25.09.2012  TM  DruckAnfrage_Init() eingesetzt für AuftragsAnfrage
//  21.03.2013  ST  DruckAvis() hinzugefügt
//  30.07.2014  AH  "ToggleLoeschmarker" managed Storniert-Aktion
//  01.03.2015  AH  Neu "SelAufNr"
//  31.08.2015  AH  Neu "CopyAuf2GutBel"
//  29.10.2015  AH  Neu "CalcMengen"
//  24.03.2016  AH  Neu "CalcEinsatzMenge250" und "CalcGesamtpreis"
//  08.11.2016  AH  PAbruf
//  12.04.2017  ST  Neu AFX "Auf.P.ToggleLoeschmarker" hinzugefügt
//  16.01.2018  AH  "SelAbruf"
//  22.07.2019  AH  "VkWertVonMenge"
//  26.07.2019  AH  Fix: Statistikverbuchung
//  30.09.2021  AH  ToggleLoeschmarker entfernt NICHT auf Bestellmaterial die Kommission
//  11.03.2022  AH  ERX
//  19.05.2022  AH  Fix für Abrufmengenedit (HOW)
//  22.06.2022  AH  "CalcGewicht
//  13.09.2022  ST  Neu: ChangePosNr: Angebotspositionen ändern"
//  2023-01-17  AH  "SelUser"
//  2023-02-10  AH  "CheckMehWechsel", Proj. 2465/58
//
//  Subprozeduren
//    SUB ToggleLoeschmarker
//    SUB Versand
//    SUB AusVersand
//    SUB DruckAnfrage_Init
//    SUB DruckAvis
//    SUB StatistikBuchen
//    SUB SelAufNr
//    SUB SelAbruf
//    SUB SelUser
//    SUB CopyAuf2GutBel
//    SUB VkWertVonMenge
//    SUB CalcGewicht
//    SUB CheckMehWechsel
//
//========================================================================
@I:Def_global
@I:Def_Aktionen

//========================================================================
// ToggleLoeschmarker
//
//========================================================================
sub ToggleLoeschmarker(aManuell : logic) : logic;
local begin
  Erx     : int;
  vBuf401 : int;
  vRes    : logic;
  vVSA    : logic;
  vVSB    : logic;
  vPrd    : logic;
  vBuf200 : int;
  vStorno : logic;

  vAfxPara : alpha;
end;
begin
  vAfxPara # 'n';
  if (aManuell) then
    vAfxPara # 'y';
  if (RunAFX('Auf.P.ToggleLoeschmarker',vAfxPara)<>0) then begin
    RETURN (AfxRes = _rOK);
  end;

  RecLink(400,401,3,_RecFirst);   // Kopf holen
  Erx # RecLink(835,401,5,_recFirst);   // Auftragsart holen
  if (Erx>_rLocked) then RecBufClear(835);

  // nur Angebote kann man zurückholen!
/*
  if (Auf.Vorgangstyp<>'ANG') and ("Auf.P.Löschmarker"='*') then begin
    Msg(401005,'',0,0,0);
    RETURN true;
  end;
*/

  // 30.07.2014:
  if ("Auf.P.Löschmarker"='') then
    vStorno # (Auf.P.Prd.Lfs=0.0) and (Auf.P.Prd.Rech=0.0);


  // ANGEBOT löschen ------------------------------------------------------------
  if (Auf.Vorgangstyp=c_ANG) and("Auf.P.Löschmarker"='') then begin
    if (aManuell) then begin
      if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
      TRANSON;
    end;

    PtD_Main:Memorize(401);
    RecRead(401,1,_recLock);
    "Auf.P.Löschmarker"   # '*';
    "Auf.P.Lösch.Datum"   # today;
    "Auf.P.Lösch.Zeit"    # now;
    "Auf.P.Lösch.User"    # gUsername;
    if (aManuell) then
      Auf_Data:PosReplace(_recUnlock,'MAN')
    else
      Auf_Data:PosReplace(_recUnlock,'AUTO');
    PtD_Main:Compare(401);

    // Marker neu berechnen
    vBuf401 # RekSave(401);
    RecLink(400,401,3,_RecFirst);   // Kopf holen
    RecRead(400,1,_RecNoLoad | _RecLock);
    Auf_Data:BerechneMarker();
    Erx # RekReplace(400,0,'AUTO');
    RekRestore(vBuf401);

    if (Erx<>_rOk) then begin
      if (aManuell) then begin
        TRANSBRK;
        Msg(400018,'',0,0,0);
      end;
Erx # 1768;
AfxRes # Erx;
      RETURN false;
    end;
    if (aManuell) then TRANSOFF;
    RETURN true;
  end  // Angebot löschen
  // Angebot aktivieren ------------------------------------------------------------------
  else if (Auf.Vorgangstyp=c_ANG) and ("Auf.P.Löschmarker"='*') then begin
    if (aManuell) then begin
      if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
      TRANSON;
    end;

    PtD_Main:Memorize(401);
    RecRead(401,1,_recLock);
    "Auf.P.Löschmarker"     # '';
    "Auf.P.Lösch.Datum"     # 0.0.0;
    "Auf.P.Lösch.Zeit"      # 0:0;
    "Auf.P.Lösch.User"      # '';
    if (aManuell) then
      Auf_Data:PosReplace(_recUnlock,'MAN')
    else
      Auf_Data:PosReplace(_recUnlock,'AUTO');
    PtD_Main:Compare(401);

    // Marker neu berechnen
    vBuf401 # RekSave(401);
    RecLink(400,401,3,_RecFirst);   // Kopf holen
    RecRead(400,1,_RecNoLoad | _RecLock);
    Auf_Data:BerechneMarker();
    Erx # RekReplace(400,0,'AUTO');
    RekRestore(vBuf401);

    if (Erx<>_rOk) then begin
      if (aManuell) then begin
        TRANSBRK;
        Msg(400018,'',0,0,0);
      end;
Erx # 1799;
AfxRes # Erx;
      RETURN false;
    end;
    if (aManuell) then TRANSOFF;
    RETURN true;
  end // Angebot aktivieren


  // AUFTRAG AKTIVIEREN ----------------------------------------------
  else if (Auf.Vorgangstyp=c_Auf) and ("Auf.P.Löschmarker"='*') then begin

    if (aManuell) then begin
      if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
      TRANSON;
    end;

    // Sternchen entfernen
    PtD_Main:Memorize(401);
    RecRead(401,1,_recLock);
    Auf.P.StorniertYN       # false;
    "Auf.P.Löschmarker"     # '';
    "Auf.P.Lösch.Datum"     # 0.0.0;
    "Auf.P.Lösch.Zeit"      # 0:0;
    "Auf.P.Lösch.User"      # '';
    if (aManuell) then
      Erx # Auf_Data:PosReplace(_recUnlock,'MAN')
    else
      Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
    if (erx<>_rOk) then begin
      PtD_Main:Forget(401);
      if (aManuell) then begin
        TRANSBRK;
        Msg(401010,'',0,0,0);
      end;
Erx # 2000;
AfxRes # Erx;
      RETURN false;
    end;
    PtD_Main:Compare(401);

    // so tun, als ob die Position neu wäre...
    vBuf401 # RecBufCreate(401);
    Auf_Data:SperrPruefung(vBuf401);
    RecBufDestroy(vBuf401);

    if ((Auf.AbrufYN) or (Auf.PAbrufYN)) and (Auf.P.AbrufAufNr<>0) then begin
      Auf_Data:VerbucheAbruf(n);
    end;

    // Storno vorhanden?
    RecBufClear(404);
    Auf.A.Aktionstyp    # c_Akt_Storniert;
    Auf.A.Aktionsnr     # Auf.P.Nummer;
    Auf.A.Aktionspos    # Auf.P.Position;
    Erx # RecRead(404,2,0);
    if (Erx<=_rMultikey) then
      Auf_A_Data:Entfernen(false);

    // nötige Verbuchungen im Artikel druchführen...
    Auf_Data:VerbucheArt('', 0.0, '*');

    end   // Auftrag aktivieren



  // AUFTRAG LÖSCHEN---------------------------------------------------
  else if (Auf.Vorgangstyp=c_AUF) and ("Auf.P.Löschmarker"='') then begin

    Erx # RecLink(835,401,5,_RecFirst);     // Auftragsart holen
    if (Erx>_rlocked) then RecBufClear(819);
    // keine kostenlose Lieferung?
    if (AAr.Berechnungsart<>100) and
      ((AAr.Berechnungsart<700) or (AAr.Berechnungsart>799)) then begin
      // offener Versand darf nicht gelöscht werden!
      // 10.06.2014 : nur gleiche MEH vergleichen:lib_
      if (Auf.LiefervertragYN = false) then begin
        if ((Auf.P.Prd.VSAUF<>0.0)) or
           ((Auf.P.MEH.Einsatz=Auf.P.MEH.Preis) and (Auf.P.Prd.LFS-Auf.P.Prd.Rech>0.0)) or
           ((Auf.P.MEH.Einsatz<>Auf.P.MEH.Preis) and (Auf.P.Prd.LFS.Gew-Auf.P.Prd.Rech.Gew>0.0)) then begin
          Msg(401006,'',0,0,0);
          RETURN true;
        end;
      end;
    end;

    if (aManuell) then begin

      if (Auf.P.Prd.Plan>0.0) then  vPrd # y;
      if (Auf.P.Prd.VSB>0.0) then   vVSB # y;

      if (AAr.ReserviereSLYN) then begin
        Erx # RecLink(409,401,15,_recFirst);  // Stückliste loopen
        WHILE (Erx<=_rLocked) do begin
          if (Auf.SL.Prd.VSB<>0.0) then   vVSB # y;
          if (Auf.SL.Prd.Plan<>0.0) then  vRes # y;
          Erx # RecLink(409,401,15,_recNext);
        END;
      end;

      if (vRes) then begin
        if (Msg(401007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end;
      if (vPrd) then begin
        Msg(401017,'',_WinIcoError,_WinDialogOk,1);
        RETURN true;
      end;
      if (vVSB) then begin
        if (Msg(401008,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then RETURN true;
      end;

      // Mat-Reservierungen existieren???
      if (RecLinkInfo(203,401,18,_recCount)<>0) then begin
        if (Msg(401014,'',0,_WinDialogOkCancel,2)<>_WinIdOK) then RETURN true;
        end
      else begin
        if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
      end;

      if (vStorno) then
        vStorno # (Msg(401025,'',_WinIcoQuestion,_WinDialogYesNo,1)=_Winidyes);

    end;


    // los gehts...
    if (aManuell) then TRANSON;

    RecLink(819,401,1,_RecFirst); // Warengruppe holen

    // ARTIKEL??? ***********************************************
    Erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
    if (Erx<=_rLocked) and (Auf.P.Artikelnr<>'') then begin

      // bisherige VSB suchen
      Erx # RecLink(404,401,12,_recFirst);
      WHILE (Erx<=_rLocked) do begin

        if (Auf.A.Aktionstyp=c_Akt_VSB) and ("Auf.A.Löschmarker"='') then begin
          // alte Reservierung löschen
//          Art_Data:Reservierung(Auf.A.ArtikelNr, Auf.A.Charge.Adresse, Auf.A.Charge.Anschr, Auf.A.Charge, 'AUF', Auf.P.Nummer, Auf.P.Position, 0, -Auf.A.Menge, -"Auf.A.Stückzahl",0);
          if (Auf_A_Data:Storno(true)=false) then begin
            if (aManuell) then begin
              TRANSBRK;
              Msg(401010,'',0,0,0);
            end;
Erx # 200;
AfxRes # Erx;
            RETURN false;
          end;
        end;

        Erx # RecLink(404,401,12,_recNext);
      END;
    end; // Artikel


    // Mat-Kommission löschen...
    Erx # RecLink(200,401,17,_recFirst);
    WHILE (Erx<=_rLocked) do begin

      if ("Mat.Löschmarker"='') and ((Mat.Status<500) or (Mat.Status>599)) then begin // 30.09.2021 AH STATUS ABRRAGEN
        Erx # Mat_Data:SetKommission(Mat.Nummer, 0,0,0, 'AUTO');
        if (Erx<>_rOK) then begin
          if (aManuell) then begin
            TRANSBRK;
            Msg(401010,'',0,0,0);
            ErrorOutput;
          end;
Erx # 246;
AfxRes # Erx;
          RETURN false;
        end;
        Erx # RecLink(200,401,17,0);
        Erx # RecLink(200,401,17,0);
        CYCLE;
      end;

      Erx # RecLink(200,401,17,_recNext);
    END;

    // Mat-Reservierungen löschen...
    Erx # RecLink(203,401,18,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (Mat_Rsv_Data:Entfernen()=false) then begin
        if (aManuell) then begin
          TRANSBRK;
          Msg(401010,'',0,0,0);
        end;
Erx # 286;
AfxRes # Erx;
        RETURN false;
      end;
      Erx # RecLink(203,401,18,_recFirst);
    END;

    // Sternchen setzen
    PtD_Main:Memorize(401);
    RecRead(401,1,_recLock);
    Auf.P.StorniertYN       # vStorno;
    "Auf.P.Löschmarker"     # '*';
    "Auf.P.Lösch.Datum"     # today;
    "Auf.P.Lösch.Zeit"      # now;
    "Auf.P.Lösch.User"      # gUsername;
    if (aManuell) then
      Erx # Auf_Data:PosReplace(_recUnlock,'MAN')
    else
      Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
    if (Erx<>_rOk) then begin
      PtD_Main:Forget(401);
      if (aManuell) then begin
        TRANSBRK;
        Msg(401010,'',0,0,0);
      end;
Erx # 1967;
AfxRes # Erx;
      RETURN false;
    end;

    if (vStorno) then begin
      RecBufClear(404);
      Auf.A.Aktionstyp    # c_Akt_Storniert;
      Auf.A.Bemerkung     # c_AktBem_Storniert;
      Auf.A.Aktionsnr     # Auf.P.Nummer;
      Auf.A.Aktionspos    # Auf.P.Position;
      Auf.A.Aktionsdatum  # Today;
      Auf.A.TerminStart   # Today;
      Auf.A.TerminEnde    # Today;
      Auf_A_Data:NeuAnlegen();
    end;

    PtD_Main:Compare(401);

    // so tun, als ob die Position neu wäre...
    vBuf401 # RecBufCreate(401);
    Auf_Data:SperrPruefung(vBuf401,y);
    RecBufDestroy(vBuf401);


    if ((Auf.AbrufYN) or  (Auf.PAbrufYN)) and (Auf.P.AbrufAufNr<>0) then begin
      Auf_Data:VerbucheAbruf(n);
    end;

    // nötige Verbuchungen im Artikel druchführen...
// 19.05.2022     Auf_Data:VerbucheArt(Auf.P.Artikelnr, Auf.P.Menge-Auf.P.Prd.LFS, '');
    Auf_Data:VerbucheArt(Auf.P.Artikelnr, Auf.P.Menge - Auf.P.Prd.Plan - Auf.P.Prd.VSB - Auf.P.Prd.LFS, '');


  end // Auftrag Löschen
  // Gutschrift --------------------------------------------------------------------
  else if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin

    if ("Auf.P.Löschmarker"='*') then begin
      if (aManuell) then begin
        if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
        TRANSON;
      end;

      PtD_Main:Memorize(401);
      RecRead(401,1,_recLock);
      "Auf.P.Löschmarker"     # '';
      "Auf.P.Lösch.Datum"     # 0.0.0;
      "Auf.P.Lösch.Zeit"      # 0:0;
      "Auf.P.Lösch.User"      # '';
      if (aManuell) then
        Auf_Data:PosReplace(_recUnlock,'MAN')
      else
        Auf_Data:PosReplace(_recUnlock,'AUTO');
      PtD_Main:Compare(401);
    end
    else if ("Auf.P.Löschmarker"='') then begin
      if (aManuell) then begin
        if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
        TRANSON;
      end;


      PtD_Main:Memorize(401);
      RecRead(401,1,_recLock);
      "Auf.P.Löschmarker"     # '*';
      "Auf.P.Lösch.Datum"     # today;
      "Auf.P.Lösch.Zeit"      # now;
      "Auf.P.Lösch.User"      # gUsername;
      if (aManuell) then
        Auf_Data:PosReplace(_recUnlock,'MAN')
      else
        Auf_Data:PosReplace(_recUnlock,'AUTO');
      PtD_Main:Compare(401);
    end;
  end // Gutschrift
  // Belastung ---------------------------------------------------------------
  else if (Auf.Vorgangstyp=c_BEL_KD) or (Auf.Vorgangstyp=c_BEL_LF) then begin

    if ("Auf.P.Löschmarker"='*') then begin
      if (aManuell) then begin
        if (Msg(000007,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
        TRANSON;
      end;

      PtD_Main:Memorize(401);
      RecRead(401,1,_recLock);
      "Auf.P.Löschmarker"     # '';
      "Auf.P.Lösch.Datum"     # 0.0.0;
      "Auf.P.Lösch.Zeit"      # 0:0;
      "Auf.P.Lösch.User"      # '';
      if (aManuell) then
        Auf_Data:PosReplace(_recUnlock,'MAN')
      else
        Auf_Data:PosReplace(_recUnlock,'AUTO');
      PtD_Main:Compare(401);
    end

    else if ("Auf.P.Löschmarker"='') then begin

      if (aManuell) then begin
        if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN true;
        TRANSON;
      end;

      PtD_Main:Memorize(401);
      RecRead(401,1,_recLock);
      "Auf.P.Löschmarker"     # '*';
      "Auf.P.Lösch.Datum"     # today;
      "Auf.P.Lösch.Zeit"      # now;
      "Auf.P.Lösch.User"      # gUsername;
      if (aManuell) then
        Auf_Data:PosReplace(_recUnlock,'MAN')
      else
        Auf_Data:PosReplace(_recUnlock,'AUTO');
      PtD_Main:Compare(401);
    end;
  end;  // Belastung




  // Marker neu berechnen
  vBuf401 # RekSave(401);
  RecLink(400,401,3,_RecFirst);   // Kopf holen
  RecRead(400,1,_RecNoLoad | _RecLock);
  Auf_Data:BerechneMarker();
  Erx # RekReplace(400,0,'AUTO');
  RekRestore(vBuf401);
  if (erx<>_rOk) then begin
    if (aManuell) then begin
      TRANSBRK;
      Msg(400018,'',0,0,0);
    end;
Erx # 1989;
AfxRes # Erx;
    RETURN false;
  end;

  // alles ok
  if (aManuell) then TRANSOFF;
  RETURN true;
end;


//========================================================================
// Versand
//
//========================================================================
sub Versand();
begin
  RecBufClear(655);
  VsP.Vorgangstyp       # c_VSPTyp_Auf;
  VsP.Vorgangsnr        # Auf.P.Nummer;
  VsP.VorgangsPos1      # Auf.P.Position;
  VsP.VorgangsPos2      # 0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dlg.Versandpool',here+':AusVersand');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusVersand
//
//========================================================================
sub AusVersand();
begin

  if (gSelected<>0) then begin

    if (VsP_Data:Auf2Pool()<>0) then begin
      Msg(999998,'',0,0,0);
      end
    else begin
      ErrorOutput;
    end;

  end;
  gSelected # 0;
end;


//========================================================================
// DruckAnfrage_Init
//
//========================================================================
sub Druckanfrage_Init() : logic;
local begin
  vZList  : handle;
  vKLim   : float;
  vBuf401 : int;
end;
begin
  vZList # gZLList;

  // Kopf und Fusstexte Dialog
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Auf.AnfKFT.Dialog.Sel','');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
// sub DruckAvis()
//
//========================================================================
sub DruckAvis();
local begin
  vBuf401 : int;
end;
begin

  // Sonderfunktion:
  if (RunAFX('Auf.P.DruckLieferavis','')<>0) then
      RETURN;

  RecLink(400,401,3,_RecFirst);  // Kopf holen
  vBuf401 # RekSave(401);
  Lib_Dokumente:Printform(400,'Lieferavis',false);
  RekRestore(vBuf401);

end;


//========================================================================
// StatistikBuchen
//
//========================================================================
Sub StatistikBuchen(
  opt a400          : int;
  opt a401          : int;
  opt aDat          : date;
  opt aOhneEingang  : logic;
  opt aOhneBestand  : logic;
);
local begin
  Erx       : int;
  vLocal400 : logic;
  vLocal401 : logic;
  vTyp      : alpha;
  vUmbuchen : logic;
  vDat      : date;
  vVorgang  : alpha;

  vAdr1     : int;
  vWert1    : float;
  vStk1     : int;
  vGew1     : float;
  vMenge1   : float;
  vKurs1    : float;
  vKonto1A  : alpha;
  vKonto1B  : alpha;

  vAdr2     : int;
  vWert2    : float;
  vStk2     : int;
  vGew2     : float;
  vMenge2   : float;
  vKurs2    : float;
  vKonto2A  : alpha;
  vKonto2B  : alpha;

  vDifWert  : float;
  vDifStk   : int;
  vDifGew   : float;
  vDifMenge : float;
  vDif      : logic;
end;
begin

  vDat # today;

  if (aDat<>0.0.0) then vDat # aDat;
  if (Auf.Vorgangstyp='REK') then RETURN;

  vVorgang # aint(Auf.P.Nummer)+'/'+aint(Auf.P.Position);

  // 25.07.2019
  if (a400<>0) then if (a400->Auf.Nummer=0) then a400 # 0;
  if (a401<>0) then if (a401->Auf.P.Nummer=0) then a401 # 0;

  if (a401=0) then vTyp # '-'
  else begin
    if (a401->"Auf.P.Löschmarker"='') then vTyp # 'B'
    else if (a401->Auf.P.StorniertYN) then vTyp # 'S'
    else vTyp # 'G';
  end;

  if ("Auf.P.Löschmarker"='') then vTyp # vTyp + 'B'
  else if (Auf.P.StorniertYN) then vTyp # vTyp + 'S'
  else vTyp # vTyp + 'G';



  if (a401=0) then begin
    vLocal401 # true;
    a401 # RecBufCreate(401);
    RecBufCopy(401,a401);
  end
  else begin
    if (a401->Auf.P.StorniertYN) then aOhneEingang # false;   // 26.07.2019
  end;

  if (a400<>0) then begin
    RecLink(814,a400,8,_recfirst);    // Währung holen
    if (a400->"Auf.WährungFixYN") then
      vKurs1 # a400->"Auf.Währungskurs"
    else
      vKurs1 # "Wae.VK.Kurs";
  end
  else begin
    vLocal400 # true;
    a400 # RecBufCreate(400);
    RecLink(a400,401,3,_recFirst);    // Kopf holen
    RecLink(814,a400,8,_recfirst);    // Währung holen
    if (a400->"Auf.WährungFixYN") then
      vKurs1 # a400->"Auf.Währungskurs"
    else
      vKurs1 # "Wae.VK.Kurs";
  end;
  RecLink(814,400,8,_recfirst);       // Währung holen
  if ("Auf.WährungFixYN") then
    vKurs2 # "Auf.Währungskurs"
  else
    vKurs2 # "Wae.VK.Kurs";
  if (vKurs1=0.0) then vKurs1 # 1.0;
  if (vKurs2=0.0) then vKurs2 # 1.0;


  vUmbuchen # (a400->Auf.Vertreter<>Auf.Vertreter) or
              (a400->Auf.LiefervertragYN<>Auf.LiefervertragYN) or (a400->Auf.AbrufYN<>Auf.AbrufYN) or (a400->Auf.PAbrufYN<>Auf.PAbrufYN) or
              (a400->Auf.Vorgangstyp<>Auf.Vorgangstyp);

  vKonto1a  # a400->Auf.Vorgangstyp+'_';
  if (a400->Auf.AbrufYN) or (a400->Auf.PAbrufYN) then vKonto1a # vKonto1a + 'AR_';
  if (a400->Auf.LiefervertragYN) then vKonto1a # vKonto1a + 'LV_';
  vKonto2a   # Auf.Vorgangstyp+'_';
  if (Auf.AbrufYN) or (Auf.PAbrufYN) then vKonto2a # vKonto2a + 'AR_';
  if (Auf.LiefervertragYN) then vKonto2a # vKonto2a + 'LV_';


  if (Adr.Kundennr<>a400->Auf.Kundennr) then Erx # Reklink(100,a400,1,_recFirst);   // Kunde holen
  vAdr1 # Adr.Nummer;
  if (Adr.Kundennr<>Auf.Kundennr) then Erx # Reklink(100,400,1,_recFirst);          // Kunde holen
  vAdr2 # Adr.Nummer;

  RecLink(814,a400,8,_recfirst);    // Währung holen
  if (a400->"Auf.WährungFixYN") then
    vKurs1 # a400->"Auf.Währungskurs"
  else
    vKurs1 # "Wae.VK.Kurs";

  vUmbuchen # (vUmbuchen) or
              (a401->Auf.P.Kundennr<>Auf.P.Kundennr) or
              (a401->Auf.P.Auftragsart<>Auf.P.Auftragsart) or (a401->Auf.P.Warengruppe<>Auf.P.Warengruppe) or
              (a401->Auf.P.Artikelnr<>Auf.P.Artikelnr) or (a401->"Auf.P.Güte"<>"Auf.P.Güte");

/*
Vorher,   Jetzt     =Eingang    =Rest   Typ (Bestand, Storno, Gelöscht)
-,-       ok, 10    = +10       +10     -B*
ok, 10    ok, 13    = +3        +3      BB*
ok, 13    ok, 10    = -3        -3      BB*

-,-       del, 10   = +10       nix     -G*
del, 10   del, 13   = +3        nix     GG*
del, 13   del, 10   = -3        nix     GG*

-,-       sto, 10   = nix       nix     -S*
sto, 10   sto, 13   = nix       nix     SS*
sto, 13   Sto, 10   = nix       nix     SS*

del, 10   ok, 10    = nix       +10     GB*
del, 10   ok, 13    = +3        +13     GB*
del, 13   ok, 10    = -3        +10     GB*

sto, 10   ok, 10    = +10       +10     SB*
sto, 10   ok, 13    = +13       +13     SB*
sto, 13   ok, 10    = +10       +10     SB*

ok, 10    del, 10   = nix       -10     BG
ok, 10    del, 13   = +3        -10     BG
ok, 13    del, 10   = -3        -13     BG

ok, 10    sto, 10   = -10       -10     BS
ok, 10    sto, 13   = -10       -10     BS
ok, 13    sto, 10   = -13       -13     BS
*/
  // Stack(aTyp, aAdrNr, aVert, aAufArt, aWGr, aArtNr, aGuete, aKst, aWertW1, aStk, aGew, aMenge, aMEH);

  // AUFTRAGSEINGANG ---------------------------------------------------------------------------
  if (aOhneEingang=false) then begin
    vKonto1b  # vKonto1a + 'EINGANG';
    vKonto2b  # vKonto2a + 'EINGANG';

  //      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);
    vStk1     # a401->"Auf.P.Stückzahl";
    vGew1     # a401->Auf.P.Gewicht;
    vMenge1   # a401->Auf.P.Menge;
    vWert1    # a401->Auf.P.Gesamtpreis;
    vWert1    # Rnd(vWert1 / vKurs1,2)

    vStk2     # "Auf.P.Stückzahl";
    vGew2     # Auf.P.Gewicht;
    vMenge2   # Auf.P.Menge;
    vWert2    # Auf.P.Gesamtpreis;
    vWert2    # Rnd(vWert2 / vKurs2,2)

    vDifStk   # vStk2 - vStk1;
    vDifGew   # vGew2 - vGew1;
    vDifMenge # vMenge2 - vMenge1;
    vDifWert  # vWert2 - vWert1;
    vDif # (vDifStk<>0) or (vDifGew<>0.0) or (vDifMenge<>0.0) or (vDifWert<>0.0);


  //debugx('Auf_P:'+vtyp+' '+vKonto1b+' -> '+vKonto2b);

    // Konten:
    //  Erfasst(+), Storniert(-) und Summe
    case vTyp of

      '-G' : begin
        if (aDat<>0.0.0) then begin
          OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        end;
      end;

      '-B' : begin  // neu erfasst
        OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
      end;


      'GB', 'BB' : begin  // (wie) verändert mit ggf. Umbuchung
        if (vUmbuchen) then begin
          OSt_Data:Stack('-', '+'+vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);
          OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);

          OSt_Data:Stack('+', '+'+vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        end
        else begin
          if (vDif) then begin
            OSt_Data:Stack('', '+'+vKonto1b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Auf.P.MEH.Einsatz);
            OSt_Data:Stack('', vKonto1b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Auf.P.MEH.Einsatz);
          end;
        end
      end;

      'BS' : begin  // stornieren = Ursprungsmengen entfernen
        OSt_Data:Stack('+', '-'+vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);
        OSt_Data:Stack('', vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);
      end;

      'SB' : begin  // Storno zurückolen
        OSt_Data:Stack('-', '-'+vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        OSt_Data:Stack('', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
      end;

    end;
  end;  // EINGANG


  // AUFTRAGBESTAND ---------------------------------------------------------------------------
  if (aOhneBestand=false) then begin
    vKonto1b  # vKonto1a + 'BESTAND';
    vKonto2b  # vKonto2a + 'BESTAND';

    vStk1   # a401->Auf.P.Prd.Rest.Stk;
    vGew1   # a401->Auf.P.Prd.Rest.Gew;
    vMenge1 # a401->Auf.P.Prd.Rest;;
    vWert1  # Lib_Berechnungen:Dreisatz(a401->Auf.P.Gesamtpreis, a401->Auf.P.Menge, vMenge1);
    vWert1  # Rnd(vWert1 / vKurs1,2)

    vStk2   # Auf.P.Prd.Rest.Stk;
    vGew2   # Auf.P.Prd.Rest.Gew;
    vMenge2 # Auf.P.Prd.Rest;
    vWert2  # Lib_Berechnungen:Dreisatz(Auf.P.Gesamtpreis, Auf.P.Menge, vMenge2);
    vWert2  # Rnd(vWert2 / vKurs2,2)

    vDifStk   # vStk2 - vStk1;
    vDifGew   # vGew2 - vGew1;
    vDifMenge # vMenge2 - vMenge1;
    vDifWert  # vWert2 - vWert1;
    vDif # (vDifStk<>0) or (vDifGew<>0.0) or (vDifMenge<>0.0) or (vDifWert<>0.0);

    case vTyp of
      '-G' : begin
        if (aDat<>0.0.0) then begin
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        end;
      end;

      '-B', 'GB','SB' : begin  // (wie) neu erfasst
        OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
      end;

      'BB' : begin  //  verändert mit ggf. Umbuchung
        if (vUmbuchen) then begin
          OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);
          OSt_Data:Stack('+', vKonto2b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vWert2, vStk2, vGew2, vMenge2, Auf.P.MEH.Einsatz);
        end
        else begin
          if (vDif) then
            OSt_Data:Stack('', vKonto1b, vVorgang, vAdr2, Auf.Vertreter, Auf.P.Auftragsart, Auf.P.Warengruppe, Auf.P.Artikelnr, "Auf.P.Güte", 0, vDat, vDifWert, vDifStk, vDifGew, vDifMenge, Auf.P.MEH.Einsatz);
        end
      end;

      'GS', 'SG' : todox('');

      'BS', 'BG' : begin  // löschen
        OSt_Data:Stack('-', vKonto1b, vVorgang, vAdr1, a400->Auf.Vertreter, a401->Auf.P.Auftragsart, a401->Auf.P.Warengruppe, a401->Auf.P.Artikelnr, a401->"Auf.P.Güte", 0, vDat, -vWert1, -vStk1, -vGew1, -vMenge1, a401->Auf.P.MEH.Einsatz);
      end;

    end;

  end; // BESTAND


  if (vLocal400) then RecBufDestroy(a400);
  if (vLocal401) then RecBufDestroy(a401);

//debug('');

end;


//========================================================================
// SelAufNr
//          Selektiert nur diese Auftragsnummer
//========================================================================
sub SelAufNr();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    if (w_AktiverFilter='AufNr') then begin
      if (Sel_Main:Filter_Stop(gZLList->wpdbrecid)) then RETURN;
    end
    else begin
      gZLList->wpAutoUpdate # false;
      Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    end;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  //Auf_P_Mark_Sel('401.xml');
  Auf_P_Mark_Sel:DefaultSelection()
  Sel.Auf.Von.Nummer     # Auf.P.Nummer;
  Sel.Auf.bis.Nummer     # Auf.P.Nummer;

  Auf_P_Mark_Sel:StartSel('AufNr');
  gZLList->wpAutoUpdate # true;
end;


//========================================================================
// SelAbruf
//          Selektiert nur Abrufe des Liefervertrages
//========================================================================
sub SelAbruf();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    if (w_AktiverFilter='Abruf') then begin
      if (Sel_Main:Filter_Stop(gZLList->wpdbrecid)) then RETURN;
    end
    else begin
      gZLList->wpAutoUpdate # false;
      Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    end;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  Auf_P_Mark_Sel:DefaultSelection()
  Sel.Auf.NurRahmen       # Auf.P.Nummer;
  Sel.Auf.NurRahmenPos    # Auf.P.Position;
  Sel.Auf.OffeneYN        # n;    // 11.03.2022 AH

  Auf_P_Mark_Sel:StartSel('Abruf');
  gZLList->wpAutoUpdate # true;
end;


//========================================================================
// SelUser
//          Selektiert nur diesen User als Sachbearbeiter
//========================================================================
sub SelUser();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    if (w_AktiverFilter='User') then begin
      if (Sel_Main:Filter_Stop(gZLList->wpdbrecid)) then RETURN;
    end
    else begin
      gZLList->wpAutoUpdate # false;
      Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    end;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  Auf_P_Mark_Sel:DefaultSelection()
  Sel.Auf.Sachbearbeit # gUsername;

  Auf_P_Mark_Sel:StartSel('User');
  gZLList->wpAutoUpdate # true;
end;


//========================================================================
//  CopyAuf2GutBel
//========================================================================
SUB CopyAuf2GutBel(
  aNr         : int;
  aPos        : int)
  : logic;
local begin
  Erx         : int;
  v401, v411  : int;
  vName       : alpha;
  vTxtHdl     : int;
end;
begin
  Erl.K.Rechnungsnr   # Auf.P.AbrufAufNr;
  Erl.K.RechnungsPos  # Auf.P.AbrufAufPos;
  Erx # RecRead(451,4,0);
  If (Erx>_rMultikey) or (Erl.K.Auftragsnr=0) or (Erl.K.Auftragspos=0) then RETURN false;
  if (Msg(401018,'',0,0,0)<>_WinIdYes) then RETURN false;

  v401 # RecBufCreate(401);
  v411 # RecBufCreate(411);
  Erx # RecLink(v401, 451, 8,_recFirst);   // Aufpos holen
  if (Erx>_rLocked) then begin
    Erx # RecLink(v411, 451, 9,_recFirst);   // ~Aufpos holen
    if (Erx>_rLocked) then RecBufClear(v411);
    recbufCopy(v411,v401);
  end;

  if (v401->Auf.P.Nummer=0) then begin
  RecBufDestroy(v411);
  RecBufDestroy(v401);
    RETURN false;
  end;

  // 30.05.2017 AH wegen HB
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then
    Auf.P.Auftragsart   # v401->Auf.P.Auftragsart;

  Auf.P.Warengruppe   # v401->Auf.P.Warengruppe;
  Auf.P.Wgr.Dateinr   # v401->Auf.P.Wgr.Dateinr;
  Auf.P.Artikeltyp    # v401->Auf.P.Artikeltyp;

  if (v401->Auf.P.Best.Nummer<>'') then Auf.P.Best.Nummer # v401->Auf.P.Best.Nummer;  // 20.02.2020 AH
  Auf.P.Projektnummer # v401->Auf.P.Projektnummer;
  Auf.P.ArtikelID     # v401->Auf.P.ArtikelID;
  Auf.P.Artikelnr     # v401->Auf.P.Artikelnr;
  Auf.P.ArtikelSW     # v401->Auf.P.ArtikelSW;
  Auf.P.KundenArtNr   # v401->Auf.P.KundenArtNr;
  Auf.P.Sachnummer    # v401->Auf.P.Sachnummer;
  Auf.P.Katalognr     # v401->Auf.P.Katalognr;
  "Auf.P.Güte"        # v401->"Auf.P.Güte";
  "Auf.P.Gütenstufe"  # v401->"Auf.P.Gütenstufe";
  Auf.P.Werkstoffnr   # v401->Auf.P.Werkstoffnr;
  Auf.P.Intrastatnr   # v401->Auf.P.Intrastatnr;
  Auf.P.Strukturnr    # v401->Auf.P.Strukturnr;
  Auf.P.Erzeuger      # v401->Auf.P.Erzeuger;
  Auf.P.Bemerkung     # v401->Auf.P.Bemerkung;

  // Text kopieren...
  vName # '';
  Auf.P.Textnr1       # 401;
  Auf.P.Textnr2       # 0;
  if (v401->Auf.P.TextNr1=0) then begin // STD-Text
    Auf.P.Textnr1     # 0;
    Auf.P.Textnr2     # v401->Auf.P.Textnr2;
  end;
  if (v401->Auf.P.TextNr1=400) then // anderer Psoitionstext
    vName # '~401.'+CnvAI(v401->Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(v401->Auf.P.TextNr2,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  if (v401->Auf.P.TextNr1=401) then // Idividuell
    vName # '~401.'+CnvAI(v401->Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(v401->Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  if (vName<>'') then begin
    vTxtHdl # $Auf.P.TextEditPos->wpdbTextBuf;
    Erx # TextRead(vTxtHdl, vName , 0);
    $Auf.P.TextEditPos->wpcustom # myTmpText+'.401.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
    $Auf.P.TextEditPos->WinUpdate(_WinUpdBuf2Obj);
  end;


  // Ausführugen löschen & kopieren
  WHILE (RecLink(402,401,11,_recFirst)=_rOK) do
    RekDelete(402,0,'MAN');

  // Ausführungen kopieren...
  Erx # RecLink(402,v401,11,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.AF.Nummer   # Auf.P.Nummer;
    Auf.AF.Position # Auf.P.Position;
    RekInsert(402,0,'MAN');
    Auf.AF.Nummer   # v401->Auf.P.Nummer;
    Auf.AF.Position   # v401->Auf.P.Position;
    Recread(402,1,0);
    Erx # RecLink(402,v401,11,_recNext);
  END;

  // Vorkaklulation kopieren...
  Erx # RecLink(405,v401,7,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Auf.K.Nummer   # Auf.P.Nummer;
    Auf.K.Position # Auf.P.Position;
    RekInsert(405,0,'MAN');
    Auf.K.Nummer     # v401->Auf.P.Nummer;
    Auf.K.Position   # v401->Auf.P.Position;
    Recread(405,1,0);
    Erx # RecLink(405,v401,7,_recNext);
  END;

  Auf.P.AusfOben      # v401->Auf.P.AusfOben;
  Auf.P.AusfUnten     # v401->Auf.P.AusfUnten;

  Auf.P.AbmessString  # v401->Auf.P.AbmessString;
  Auf.P.Dicke         # v401->Auf.P.Dicke;
  Auf.P.Breite        # v401->Auf.P.Breite;
  "Auf.P.Länge"       # v401->"Auf.P.Länge";
  Auf.P.Dickentol     # v401->Auf.P.Dickentol;
  Auf.P.Breitentol    # v401->Auf.P.Breitentol;
  "Auf.P.Längentol"   # v401->"Auf.P.Längentol";
  Auf.P.Zeugnisart    # v401->Auf.P.Zeugnisart;
  Auf.P.RID           # v401->Auf.P.RID;
  Auf.P.RIDMax        # v401->Auf.P.RIDMax;
  Auf.P.RAD           # v401->Auf.P.RAD;
  Auf.P.RADMax        # v401->Auf.P.RadMax;
  Auf.P.PEH           # v401->Auf.P.PEH;
  Auf.P.Grundpreis    # v401->Auf.P.Grundpreis;
  Auf.P.MEH.Einsatz   # v401->Auf.P.MEH.Einsatz;
  Auf.P.MEH.Preis     # v401->Auf.P.MEH.Preis;
  Auf.P.MEH.Wunsch    # v401->Auf.P.MEH.Wunsch
  Auf.P.Menge         # v401->Auf.P.Menge;
  "Auf.P.Stückzahl"   # v401->"Auf.P.Stückzahl";
  Auf.P.Gewicht       # v401->Auf.P.Gewicht;
  Auf.P.Menge.Wunsch  # v401->Auf.P.Menge.Wunsch;

  Auf_P_SMain:Switchmask(y);

  Erx # RecLink(404,451,7,_recFirst); // Aktionsliste holen
  if (Erx>_rLockeD) then RecBufClear(404);
  Auf.P.Termin1Wunsch # Auf.A.TerminEnde;
  Auf.P.Termin1W.Jahr # 0;
  Auf.P.Termin1W.Zahl # 0;
  Auf.P.Termin1W.Art  # v401->Auf.P.Termin1W.Art;
  Lib_Berechnungen:ZahlJahr_aus_Datum(Auf.P.Termin1Wunsch, Auf.P.Termin1W.Art, var Auf.P.Termin1W.Zahl,var Auf.P.Termin1W.Jahr);

  RecBufDestroy(v411);
  RecBufDestroy(v401);

  RunAFX('Auf.P.Copy2GutBel.Post','');

  RETURN true;
end;


//========================================================================
// CalcMengen
//========================================================================
Sub CalcMengen();
begin
  Auf.P.Prd.Rest      # Auf.P.Menge - Auf.P.Prd.LFS;
  Auf.P.Prd.Rest.Stk  # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
  Auf.P.Prd.Rest.Gew  # Auf.P.Gewicht - Auf.P.Prd.LFS.Gew;
  if (Auf.Vorgangstyp=c_BOGUT) or (Auf.Vorgangstyp=c_REKOR) or (Auf.Vorgangstyp=c_GUT) then begin
    if (Auf.P.Prd.Rest>0.0) then Auf.P.Prd.Rest # 0.0;
    if (Auf.P.Prd.Rest.Stk>0) then Auf.P.Prd.Rest.Stk # 0;
    if (Auf.P.Prd.Rest.Gew>0.0) then Auf.P.Prd.Rest.Gew # 0.0;
  end
  else begin
    if (Auf.P.Prd.Rest<0.0) then Auf.P.Prd.Rest # 0.0;
    if (Auf.P.Prd.Rest.Stk<0) then Auf.P.Prd.Rest.Stk # 0;
    if (Auf.P.Prd.Rest.Gew<0.0) then Auf.P.Prd.Rest.Gew # 0.0;
  end;
end;


//========================================================================
// CalcEinsatzMenge250
//========================================================================
Sub CalcEinsatzMenge250();
begin

  if (RecLinkInfo(409,401,15,_RecCount)=0) then begin
    "Auf.P.Stückzahl" # 0;
    Auf.P.Gewicht     # 0.0;
// 24.03.2016 AH besser so laut Sonne/KuZ      Art_Data:BerechneFelder(var "Auf.P.Stückzahl", var Auf.P.Gewicht, var Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch);
    Auf.P.Menge       # Rnd(Lib_Einheiten:WandleMEH(401, 0, 0.0, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, Auf.P.MEH.Einsatz), Set.Stellen.Menge);
    "Auf.P.Stückzahl" # cnvif(Lib_Einheiten:WandleMEH(401, 0, 0.0, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, 'Stk'));
    Auf.P.Gewicht     # Rnd(Lib_Einheiten:WandleMEH(401, 0, 0.0, Auf.P.Menge.Wunsch, Auf.P.MEH.Wunsch, 'kg'),Set.Stellen.Gewicht);
  end;

  $edAuf.P.Menge->winupdate(_WinUpdFld2Obj);
  $lb.Auf.P.Gewicht->winupdate(_WinUpdFld2Obj);
  $lb.Auf.P.Stueck->winupdate(_WinUpdFld2Obj);

  CalcMengen();
  $lb.Auf.P.Prd.Rest->wpcaption # ANum(Auf.P.Prd.Rest,Set.Stellen.Menge);
end;


//========================================================================
// CalcGesamtPreis
//========================================================================
Sub CalcGesamtPreis();
begin
  Auf.P.Einzelpreis # Auf.P.Grundpreis + Auf.P.Aufpreis;
  Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);
  $lb.P.Einzelpreis_Mat->wpcaption # ANum(Auf.P.Einzelpreis,2);
  $lb.Kalkuliert->wpcaption # ANum(Auf.P.Kalkuliert,2);
  $lb.Poswert->wpcaption # ANum(Auf.P.Gesamtpreis,2);
  $lb.Poswert_Mat->wpcaption # ANum(Auf.P.Gesamtpreis,2);
  $lb.Rohgewinn->wpcaption # ANum(Auf.P.Gesamtpreis - "Auf.P.GesamtwertEKW1",2);
end;


//========================================================================
// SFX VDA_Freigabe
//========================================================================
Sub VDA_Freigabe();
local begin
  Erx   : int;
  vKey  : alpha;
  v981  : int;
end;
begin

  if ("Auf.P.Löschmarker"<>'') or (Auf.Vorgangstyp<>c_Auf) or (Auf.AbrufYN=false) then begin
    Msg(99,'Dies ist kein gültiger Abruf!',0,0,0);
    RETURN;
  end;

  if (Auf.P.Flags<>'A') then begin
    Msg(99,'Dieser Abruf ist bereits freigegeben!',0,0,0);
    RETURN;
  end;

  TRANSON;

  // Position freigeben...
  Erx # RecRead(401,1,_recLock);
  Auf.P.Flags # '';
  Erx # RekReplace(401,_recunlock,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(99,'Diese Position ist nicht änderbar!',_WinIcoError,0,0);
    RETURN;
  end;

  // in Aktionsliste schreiben
  RecBufClear(404);
  Auf.A.Aktionstyp    # 'FREI';
  Auf.A.Aktionsnr     # Auf.P.Nummer;
  Auf.A.Aktionspos    # Auf.P.Position;
  Auf.A.Aktionsdatum  # Today;
  Auf.A.TerminStart   # Today;
  Auf.A.TerminEnde    # Today;
  Auf.A.Bemerkung     # 'Freigabe der VDA-Daten';
  if (Auf_A_Data:NeuAnlegen()<>_rOK) then begin
    TRANSBRK;
    Msg(99,'Aktionsliste kann nicht erweitert werden!',_WinIcoError,0,0);
    RETURN;
  end;

/***
  // 13.10.2016 AH: TEM erledigen
  // Tem.Anker durchsuchen...
  RecBufClear(981);
  TeM.A.Datei # 401;
  vKey        # Lib_Rec:MakeKey(Tem.A.Datei, n);
  TeM.A.Key   # vKey;
  Erx # RecRead(981,4,0);
  WHILE (Erx<=_rMultikey) and (TeM.A.Datei=401) and (TeM.A.Key=vKey)  do begin

    Erx # RecLink(980,981,1,_RecFirst);   // TeM holen
    if (Erx<=_rLocked) and (TeM.WOF.Nummer=cWoFAbrufNeu) and (TeM.InOrdnungYN=false) and (TeM.NichtInOrdnungYN=false) then begin
      // Tem ändernn...
      RecRead(980,1,_recLock);
      TeM.InOrdnungYN     # true;
      TeM.Erledigt.User   # gUsername;
      TeM.Erledigt.Datum  # today;
      TeM.Erledigt.Zeit   # now;
      RekReplace(980);
      // alle Events raus!
      v981 # RekSave(981);
      Lib_Notifier:RemoveAllEvents('980',TeM.Nummer);
      RekRestore(v981);
    end;

    Erx # RecRead(981,4,_recNext);
  END;
***/
  TRANSOFF;

  Lib_guicom2:Refresh_List(gZLList, _WinLstRecFromRecID | _WinLstRecDoSelect);

  Msg(999998,'',0,0,0);

end;


//========================================================================
//  VkWertVonMenge
//========================================================================
sub VkWertVonMenge(
  aAufNr      : int;
  aAufPos     : int;
  aStk        : int;
  aNetto      : float;
  aBrutto     : float;
  aM1         : float;
  aMEH1       : alpha;
  aM2         : float;
  aMEH2       : alpha;
  aAusDatei   : int;
  var aWert   : float;
  var aReKdNr : int;
) : logic;
local begin
  Erx   : int;
  vWert : float;
  vM    : float;
  v401  : int;
  v400  : int;
end;
begin

  if (aMEH1='kg') then begin
    if (aNetto=0.0) then  aNetto # aM1;
    if (aBrutto=0.0) then aBrutto # aM1;
  end;
  if (aMEH1='t') then begin
    if (aNetto=0.0) then  aNetto # aM1 * 1000.0;
    if (aBrutto=0.0) then aBrutto # aM1 * 1000.0;
  end;
  if (aMEH2='kg') then begin
    if (aNetto=0.0) then  aNetto # aM2;
    if (aBrutto=0.0) then aBrutto # aM2;
  end;
  if (aMEH2='t') then begin
    if (aNetto=0.0) then  aNetto # aM2 * 1000.0;
    if (aBrutto=0.0) then aBrutto # aM2 * 1000.0;
  end;

  aWert   # 0.0;
  aReKdNr # 0;
  if (aAufNr=0) then RETURN true;

  v401 # RecbufCreate(401);
  v401->Auf.P.Nummer    # aAufNr;
  v401->Auf.P.Position  # aAufPos;
  Erx # RecRead(v401,1,0);
  if (Erx>_rLocked) then begin
    RecBufDestroy(v401);
    RETURN false;
  end;
  v400 # RecbufCreate(400);
  Erx # RecLink(v400,v401,3,_RecFirst);   // AufKopf holen
  if (Erx>_rLocked) then begin
    RecBufDestroy(v401);
    RecBufDestroy(v400);
    RETURN false;
  end;
  aReKdNr # v400->Auf.Rechnungsempf ;
  RecBufDestroy(v400);
  
  if (VwA.Nummer<>v401->Auf.P.Verwiegungsart) then begin
    Erx # RecLink(818,v401,9,_recfirst); // Verwiegungsart holen
    if (Erx>_rLocked) then begin
      RecBufClear(818);
      VWa.NettoYN # Y;
    end;
  end;

  case v401->Auf.P.MEH.Preis of
    't','kg'  : begin
      if (VWa.NettoYN) then
        vM # aNetto
      else
        vM # aBrutto;
      if (v401->Auf.P.MEH.Preis='t') then vM # vM / 1000.0;
    end;

    'Stk' : vM # cnvfi(aStk);

    aMEH1 : vM # aM1;

    aMEH2 : vM # aM2;

    otherwise
      vM # Lib_Einheiten:WandleMEH(aAusDatei, aStk, aNetto, aM1, aMEH1, v401->Auf.P.MEH.Preis);
  end;  // Case-MEH-Preis

  vM # Rnd(vM, Set.Stellen.Menge);
  vWert # Rnd(vM * v401->Auf.P.Einzelpreis / cnvfi(v401->Auf.P.PEH),2);

  RecBufDestroy(v401);

  aWert # vWert;
  
  RETURN true;
end;


//========================================================================
// 2020-06-21 AH
//      Berechnet das Positionsgewicht über diverse Formeln
//========================================================================
sub CalcGewicht() : float;
local begin
  vDich : float;
  vX    : float;
  vGew  : float;
end;
begin
  vGew # Lib_Berechnungen:KG_aus_StkDBLWgrArt("Auf.P.Stückzahl", Auf.P.Dicke, Auf.P.Breite, "Auf.P.länge", Auf.P.Warengruppe, "Auf.P.Güte", Auf.P.Artikelnr);

  if (vGew=0.0) then begin
    RekLink(819,401,1,0);   // Warengruppe holen
    vDich # Wgr_Data:GetDichte(Wgr.Nummer, 401);

    if (Wgr.Materialtyp='ST') then begin
      vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Auf.P.Stückzahl", "Auf.P.Länge", vDich, 0.0, Auf.P.RAD);
    end
    else if (Wgr.Materialtyp='RO') then begin
      vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Auf.P.Stückzahl", "Auf.P.Länge", vDich, Auf.P.RID, Auf.P.RAD);
    end
    else if (Wgr.Materialtyp='RONDE') then begin
      vGew #  Lib_Berechnungen:kg_aus_StkDAdDichte2("Auf.P.Stückzahl", Auf.P.Dicke, Auf.P.RAD, vDich, 0.0);
    end
    else if (Wgr.Materialtyp='FR') then begin
      vGew #  Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD("Auf.P.Stückzahl", "Auf.P.Dicke", vDich, Auf.P.RID, Auf.P.RAD);
    end
    else if (Wgr.Materialtyp='TA') then begin   // 2022-08-25 AH
      vGew #  Lib_Berechnungen:kg_aus_StkDBLDichte2("Auf.P.Stückzahl", "Auf.P.Dicke", Auf.P.Breite, "Auf.P.Länge", Wgr.Dichte, "Wgr.TränenKgProQM");
    end;
    
  end;
  RETURN vGew;
  
//  Auf.P.Gewicht # vGew;
/***
  if (Auf.P.MEH.Wunsch='kg') then   Auf.P.Menge.Wunsch  # Rnd(Auf.P.Gewicht, Set.Stellen.Menge)
  else if (Auf.P.MEH.Wunsch='t') then   Auf.P.Menge.Wunsch  # Rnd(Auf.P.Gewicht / 1000.0, Set.Stellen.Menge)
  else if (Auf.P.MEH.Wunsch='Stk') then  Auf.P.Menge.Wunsch  # cnvfi("Auf.P.Stückzahl")
  else if (Auf.P.MEH.Wunsch=Auf.P.MEH.Einsatz) then Auf.P.Menge.Wunsch  # Auf.P.Menge
  else Auf.P.Menge.Wunsch # Lib_Einheiten:WandleMEH(401, "Auf.P.Stückzahl", Auf.P.Gewicht, Auf.P.Menge, Auf.P.MEH.Einsatz, Auf.P.MEH.Wunsch);
***/
end;



//========================================================================
// ST 2022-09-13
//     Verschiebt eine Angebotsposition
//========================================================================
sub ChangePosNr() : int
local begin
  Erx     : int;
  vPosNew : int;
  v401    : int;
  
  vTextnameOld  :  alpha;
  vTextnameNew  :  alpha;
end;
begin

  // Auftragspositionen verschieben nur für Angebote
  RekLink(400,401,3,0);  // Auftratgskopf lesen1
  if (Auf.Vorgangstyp <> c_Ang) then
    RETURN 0;
      
  if (Dlg_Standard:Anzahl('Neue Position', var vPosNew) = false) then
    RETURN 0;

  // Position schon vergeben?
  v401 # RecBufCreate(401);
  v401->Auf.P.Nummer    # Auf.P.Nummer;
  v401->Auf.P.Position  # vPosNew;
  Erx # RecRead(v401,1,0);
  RecBufDestroy(v401);
  if (Erx = _rOK) then begin
    Error(400045 ,'');    // Position ist schon vorhanden
    RETURN 0;
  end;
  
  // -------------------------------------------------------------------
  //  Start Umbenennung
  // -------------------------------------------------------------------
    
  
  // Positionsaufpreise
  FOR   Erx # RecLink(403,401,6,_RecFirst | _RecLock)
  LOOP  Erx # RecLink(403,401,6,_RecFirst | _RecLock)
  WHILE Erx = _rOK DO BEGIN
    Auf.Z.Position # vPosNew;
    Erx # RekReplace(403,_RecUnlock);
  END;
    
  // Ausführungen
  FOR   Erx # RecLink(402,401,11,_RecFirst | _RecLock)
  LOOP  Erx # RecLink(402,401,11,_RecFirst | _RecLock)
  WHILE Erx = _rOK DO BEGIN
    Auf.AF.Position # vPosNew;
    Erx # RekReplace(402,_RecUnlock);
  END;
  
  // Kalkulation
  FOR   Erx # RecLink(405,401,7,_RecFirst | _RecLock)
  LOOP  Erx # RecLink(405,401,7,_RecFirst | _RecLock)
  WHILE Erx = _rOK DO BEGIN
    Auf.K.Position # vPosNew;
    Erx # RekReplace(405,_RecUnlock);
  END;
  
  // Aktionen
  FOR   Erx # RecLink(404,401,12,_RecFirst | _RecLock)
  LOOP  Erx # RecLink(404,401,12,_RecFirst | _RecLock)
  WHILE Erx = _rOK DO BEGIN
    Auf.A.Position # vPosNew;
    Erx # RekReplace(404,_RecUnlock);
  END;
    
  // Indi.Text
  vTextnameOld # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  vTextnameNew # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vPosNew,_FmtNumLeadZero | _FmtNumNoGroup,0,3);
  Erx # TxtRename(vTextnameOld,vTextnameNew , 0);
   
  // Interner RTF Text
  vTextnameOld # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
  vTextnameNew # '~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(vPosNew,_FmtNumLeadZero | _FmtNumNoGroup,0,3)+'.01';
  Erx # TxtRename(vTextnameOld,vTextnameNew , 0);

  // -------------------------------------------------------------------
  // Position Umbenennen
  Erx # RecRead(401,1,_RecLock);
  if (Erx <> _rOK) then begin
    Error(001014,'Auftragsposition ' + Aint(Auf.P.Position));
    RETURN -1;
  end;

  Auf.P.Position  # vPosNew;
  
  Erx # RekReplace(401,_RecUnlock);
  if (Erx <> _rOK) then begin
    Error(001012,'Auftragsposition ' + Aint(Auf.P.Position));
    RETURN -1;
  end;
    
  RETURN _rOK;
end;


/*========================================================================
2023-02-10  AH        Proj. 2465/58
========================================================================*/
sub CheckMehWechsel(
  aAlt        : alpha;
  aNeu        : alpha;
  aWarnTest   : logic;
) : logic
local begin
  Erx     : int;
  vDelta  : float;
end;
begin

  if (aAlt=aNeu) then RETURN true;
  if (Auf.P.Aktionsmarker<>'$') then RETURN true;
  
  if (aWarntest) then begin
    if (Msg(401033,aAlt+'|'+aNeu,_WinIcoWarning,_WinDialogOkCancel, 2)<>_winidok) then RETURN false;
    RETURN true;
  end;

  // IN PARENT-TRANSAKTION
  FOR Erx # RecLink(404,401,12,_recFirst)
  LOOP Erx # RecLink(404,401,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Auf.A.Rechnungsmark<>'$') or (Auf.A.Rechnungsnr<>0) then CYCLE;
    if (Auf.A.MEH.Preis<>aNeu) then begin
      Erx # RecRead(404,1,_RecLock);
      if (erx=_rOK) then begin
        Auf.A.MEH.Preis # aNeu;
        vDelta # Auf.A.Menge.Preis;
        if (Auf.A.MEH.Preis='Stk') then Auf.A.Menge.Preis # cnvfi("Auf.A.Stückzahl")
        else if (Auf.A.MEH.Preis='kg') then begin
          if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
            Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
            if (Erx>_rLocked) then begin
              RecBufClear(818);
              VWa.NettoYN # Y;
            end;
          end;
          if (VWa.NettoYN) then
            Auf.A.Menge.Preis # Auf.A.NettoGewicht
          else
            Auf.A.Menge.Preis # Auf.A.Gewicht;
        end;
        Erx # RekReplace(404);
        vDelta # Auf.A.Menge.Preis - vDelta;
        Auf.P.Prd.zuBere # Auf.P.Prd.zuBere + vDelta;
      end;
      if (Erx<>_rOK) then begin
        if (Erx<>_rDeadLock) then TRANSBRK;
        Msg(404005,'',0,0,0);
        RETURN false;
      end;
    end;
  END;

  RETURN true;
end;


//========================================================================
