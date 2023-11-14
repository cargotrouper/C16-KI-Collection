@A+
//===== Business-Control =================================================
//
//  Prozedur  Mat_Subs
//                  OHNE E_R_G
//  Info
//
//
//  16.03.2009  AI  Erstellung der Prozedur
//  30.03.2009  ST  Materialumlagerung per Scanner hinzugefügt
//  25.08.2009  MS  Markierte Mat. Karten wurden bei Neubewertung nicht gelesen
//  15.09.2009  MS  Neubewertung erweitert um bewertung des EK-Effektivs
//  15.10.2009  AI  Kombi
//  10.11.2009  AI  Lagergeld
//  06.04.2010  AI  Zinsen
//  09.04.2010  AI  Versand
//  16.08.2010  AI  Kombi nullt den Bestand
//  07.10.2010  AI  Korrektur bei Neubewertung von EK-Grundpreis am TAg mit Kosten
//  26.10.2010  AI  NEU: RecDel
//  30.03.2011  ST  Aufteilen aus Mat_Main umgezogen
//  20.05.2011  TM  Umlagerung SCANNER - Nach Einlesen Datei mit Zeitstempel versehen und behalten
//  20.02.2012  AI  APPOFFON in Neubewertung
//  12.10.2012  AI  NEU: Werkszeugnis
//  10.04.2013  AI  MatMEH eingebaut
//  18.09.2013  ST  ZeigeAlibidaten()  hinzugefügt (1326/386)
//  13.02.2014  AH  Neu: "SetLfE"
//  14.07.2015  AH  "RecDel": manueller Löschgrunbd ist Pflichtfeld
//  17.02.0216  AH  "LagerfeldFremdMonat" (Prj. 1603/5)
//  21.03.2016  ST  Neuer Anker "Mat.Zinsen" (1589/41)
//  09.02.2018  ST  Bugfix: Fehlerprokoll funktionert jetzt wietr
//  18.11.2020  ST  sub Materialkarte(); hinzugefügts
//  13.02.2021  AH  CO2
//  27.07.2021  AH  ERX
//  2023-01-09  AH  "SelPaket"
//
//  Subprozeduren
//
//    SUB SetLfE(aLfE : int) : logic;
//    SUB Versand
//    SUB AusVersand
//    SUB Werkszeugnis
//    SUB _WerkszeugnisDelegate
//    SUB Materialkarte();

//    SUB Neubewertung();
//    SUB UmlagernScanner();
//    SUB Fehlerprotkoll();
//    SUB Kombi(aDatum : date; opt aList : handle; opt aStk  : int) : int;
//    SUB Aufteilen()  : logic

//    SUB _AddiereLG(aVon : date; aBis : date; aTree : handle) : float
//    SUB _AddiereLGMonat(aVon : date; aBis : date; aTree : handle) : float;

//    SUB _CalcLagergeld(aTree : handle; var aTTage  : float)
//    SUB _CalcLagergeldMonat(aTree : handle; var aTMonate  : float)

//    SUB LagergeldFremd();
//    SUB AusLagergeldFremd();

//    SUB LagergeldFremdMonat(aPara : alpha(4096)) : int;
//    SUB AusLagergeldFremdMonat();

//    SUB LagergeldKunde();
//    SUb AusLagergeldKunde();
//    SUB Zinsen();
//    SUB RecDel(aSilent : logic; aNullen : logic)
//    SUB ZeigeAlibidaten() : int
//    SUB SelPaket

//    AFX UmlagernScanner_LP() : int
//
//========================================================================
@I:Def_global
@I:Def_Rights
@I:Def_Aktionen

@I:Struct_Lagergeld


//========================================================================
//  SetLfE
//          setzt in dieser und den Kindern die LfENr
//========================================================================
Sub SetLfE(aLfE : int) : logic;
local begin
  Erx : int;
end;
begin
  Erx # RecRead(200,1,_recLock);
  Mat.LfENr # aLfE;
  Erx # Mat_data:Replace(_recunlock,'MAT');  // 26.08.2014 war RekReplace(200,_RecUnlock,'MAT');
  if (erx<>_rOK) then begin
    Msg(999999,aint(__LINE__),0,0,0)
    RETURN false;
  end;

  // LfE vererben
  if (Mat_Data:VererbeDaten(n,n,n,y)=false) then begin
    Msg(999999,aint(__LINE__),0,0,0);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
// Versand
//
//========================================================================
sub Versand();
begin

  // nur tatsächlich vorhandenes MAterial
  if ("Mat.Löschmarker"<>'') then RETURN;
  if (Mat.Eingangsdatum=0.0.0) then RETURN;
  if (Mat.Bestellt.Gew>0.0) or (Mat.Bestellt.Stk>0) then RETURN;
  if (Mat.Status>c_status_bisFrei) and (Mat.Status<>c_Status_VSB) then RETURN;

  RecBufClear(655);
  VsP.Vorgangstyp       # c_VSPTyp_Mat;
  VsP.Vorgangsnr        # Mat.Nummer;;
  VsP.VorgangsPos1      # 0;
  VsP.VorgangsPos2      # 0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dlg.Versandpool',here+':AusVersand');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusVersand
//
//========================================================================
sub AusVersand();
local begin
  vPool : int;
end;
begin

  if (gSelected<>0) then begin
    gSelected # 0;
    if (VsP_Data:SavePool()<>0) then begin
      Msg(999998,'',0,0,0);
    end
    else begin
      ErrorOutput;
    end;

  end;
end;


//========================================================================
//  _WerkzeugnisDelegate
//
//========================================================================
SUB _WerkszeugnisDelegate() : int;
begin
  gFormParaHdl->CteInsertItem('MAT|'+aint(Mat.Nummer),Mat.Nummer,'');
  RETURN 0;
end;


//========================================================================
//  Werkszeugnis
//        Druckt die Werkszeugnisse für markierte Karten
//========================================================================
SUB Werkszeugnis();
local begin
  vHdl  : int;
end;
begin

  gFormParaHdl # CteOpen(_CteList);
  vHdl # gFormParaHdl;

  if (Lib_Mark:Count(200)>0) then begin
    if (Lib_Mark:Foreach(200, here+':_WerkszeugnisDelegate')=0) then begin
      Lib_Dokumente:Printform(200,'Werkszeugnis',true);
    end;
  end
  else begin
    _WerkszeugnisDelegate();
    Lib_Dokumente:Printform(200,'Werkszeugnis',true);
  end;

  Sort_KillList(vHdl);
  gFormParaHdl # 0;
end;


//========================================================================
//  Materialkarte
//        Druckt die Materiakkarten für markierte Karten
//========================================================================
sub Materialkarte(opt aFormularname : alpha);
local begin
  Erx         : int;
  vI          : int;
  vMarked     : int;
  vMFile      : int;
  vMID        : int;
  vBuf200     : int;
end;
begin
  if (aFormularname = '') then
    aFormularname # 'Materialkarte';
  
  vI # Lib_Mark:Count(200);
  if (vI>0) then begin
    if (Msg(997007,aint(vI),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin
      vBuf200 # RekSave(200);
      FOR  vMarked # gMarkList->CteRead(_CteFirst);
      LOOP vMarked # gMarkList->CteRead(_CteNext, vMarked);
      WHILE (vMarked > 0) DO BEGIN
        Lib_Mark:TokenMark(vMarked, var vMFile, var vMID);
        if (vMFile<>200) then
          CYCLE;
                    
        Erx # RecRead(200, 0, _recId, vMID);
        Lib_Dokumente:Printform(200,aFormularname,true);
      END;
      RekRestore(vBuf200);
      RETURN;
    end;
  end;

  Lib_Dokumente:Printform(200,aFormularname,true);
end;




/***
//========================================================================
//  NeubewertungALT
//
//========================================================================
sub NeubewertungALT();
local begin
  vPreis      : float;
  vPreisNew   : float;
  vPreisNewPM : float;
  vPreisEff   : float;
  vNurAb      : logic;
  vGrund      : alpha;
  vFix        : logic;
  vDatum      : date;
  vAbwertEff  : logic;
  vAenderungEUR  : float;
  vAenderungProz : float;

  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vCount    : int;
  vDif      : float;
  vDifPM    : float;
  vKorr     : float;

  vTxt      : alpha;

  vMat      : int;
end;
begin

  if (Rechte[Rgt_Mat_NeuBewerten]=n) then RETURN;

  // Ankerfunktion
  if (RunAFX('Mat.Neubewertung','')<>0) then RETURN;

  // Markierungnen loopen...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=200) then begin
      vCount # vCount + 1;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vCount=0) then RETURN;

  vNurAb  # y;
  vFix    # y;
  vDatum  # today;
  // Dialog starten...
  if (Dlg_Standard:Mat_Neubewertung(var vPreis,
                                    var vAbwertEff,
                                    var vNurAb,
                                    var vGrund,
                                    var vFix,
                                    var vDatum,
                                    var vAenderungEUR,
                                    var vAenderungProz
                                    )=false) then RETURN;

  // Sicherheitsabfrage...
  vTxt # '';

  //200024 :  vA # 'Q:Sollen die Preise dieser %1% Materialkarten %2% geändert werden?';
  if (vPreis <> 0.0) then
    vTxt # cnvai(vCount)+'| auf '+cnvaf(vPreis)+' '+"Set.Hauswährung.Kurz";
  else
  if (vAenderungEUR <> 0.0) then
    vTxt # cnvai(vCount)+'| um '+cnvaf(vAenderungEUR)+' '+"Set.Hauswährung.Kurz";
  else
  if (vAenderungProz <> 0.0) then
    vTxt # cnvai(vCount)+'| um '+cnvaf(vAenderungProz)+'% ';

  if (Msg(200024,vTxt,_WinIcoQuestion, _WinDialogYesNo,2)<>_WinIdYes) then RETURN;



// AB HIEr WIRD EIN FOKUSWECHSEL TÖDLICH....



APPOFF();
//gFrmMain->wpdisabled # y;
//_app->wpflags # _app->wpflags | _Winappbuf2fldoff;
//_app->wpflags # _app->wpflags | _WinAppWaitCursorEvt;

  // Markierungnen loopen...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
//winsleep(10);
    vDif    # 0.0;
    vDifPM  # 0.0;
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(200,0,_RecId,vMID);
//
//
vMat # Mat.Nummer;
//
//

    vKorr # 0.0;
    if (vAbwertEff) then begin
      // Aktionen loopen...
      Erx # RecLink(204,200,14,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        // alle Aktionen NACH dem Stichtag rückrechnen...
        if (Mat.A.AktionsDatum>=vDatum) then begin
          vKorr # vKorr + Mat.A.KostenW1;
        end;
        Erx # RecLink(204,200,14,_RecNext);
      END;
    end;


    // Preis weicht ab?
    if ((Mat.EK.Preis>vPreis) or
      ((Mat.EK.Preis<vPreis) and (vNurAb=false)) and (vAbwertEff = false))
      or
      ((Mat.EK.Effektiv+vKorr > vPreis) or
      ((Mat.EK.Effektiv+vKorr < vPreis) and (vNurAb = false)) and (vAbwertEff = true))
      or
      (vAenderungEUR <> 0.0)
      or
      (vAenderungProz <> 0.0)
       then begin

      TRANSON;


      Erx # RecRead(200,0,_RecId|_recLock, vMID);
//      Erx # RecRead(200,0,_RecId, vMID);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        APPON();
        RecRead(200,1,_recUnlock);
        Msg(001000+Erx,Translate('Material')+' '+cnvAI(Mat.Nummer),0,0,0);
        RETURN;
      end;

      // Preis ggf. für relative Berechnungen anpassen
      if (vAenderungEUR <> 0.0) then begin
        if (vAbwertEff = true) then
          vPreis # Mat.EK.Effektiv + vAenderungEUR;
        else
          vPreis # Mat.EK.Preis + vAenderungEUR;
      end;
      if (vAenderungProz <> 0.0) then begin
        if (vAbwertEff = true) then
          vPreis # Mat.EK.Effektiv + ((Mat.EK.Effektiv/100.0) * vAenderungProz);
        else
          vPreis # Mat.EK.Preis + ((Mat.EK.Preis/100.0) * vAenderungProz);
      end;

      // Karte ändern...

      // Wenn vAbwertEff "true", dann wird Mat.EK.Effektiv als Basispreis genommen
      if (vAbwertEff = true) then
        vPreisNew # Mat.EK.Preis + vPreis - Mat.EK.Effektiv + vKorr
      else
        vPreisNew # vPreis;

//      vDif        # vPreisNew - Mat.EK.Preis;
//      vPreisNewPM # (vPreisNew * Mat.Bestand.Gew / 1000.0);
//      DivOrNull(vPreisNewPM, vPreisNewPM, Mat.Bestand.Menge, 2);
//      vDifPM      # vPreisNewPM - Mat.EK.PreisProMEH;

      Mat.EK.Preis        # vPreisNew;
      Mat.EK.PreisProMEH  # vPReisNewPM;
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        APPON();
        RecRead(200,1,_recUnlock);
        Msg(001000+Erx,Translate('Material')+' '+cnvAI(Mat.Nummer),0,0,0);
        RETURN;
      end;

      // Eintrag in Bestandbuch anlegen...
      Mat_Data:Bestandsbuch(0, 0.0, 0.0, vDif, vDifPM, vGrund, vDatum, '',0,0,0,0, vFix);

      // vererben...
      Mat_Data:VererbeNeubewertung(vDif, vDifPM, vGrund, vDatum, vFix);

      TRANSOFF;

    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  APPON();

  // Erfolg!
  Msg(999998,'',0,0,0);

end;
***/


//========================================================================
//  Neubewertung
//
//========================================================================
sub Neubewertung();
local begin
  Erx         : int;
  vPreis      : float;
  vPreisNew   : float;
  vPreisNewPM : float;
  vPreisEff   : float;
  vAltEK      : float;
  vAltEkPro   : float;
  vAltEkEff   : float;
  vNurAb      : logic;
  vGrund      : alpha;
  vFix        : logic;
  vDatum      : date;
  vZeit       : time;
  vAbwertEff  : logic;
  vAenderungEUR  : float;
  vAenderungProz : float;

  vItem     : int;
  vMFile    : int;
  vMID      : int;
  vCount    : int;
  vDif      : float;
  vDifPM    : float;
  vTxt      : alpha;
  vMat      : int;
end;
begin

  if (Rechte[Rgt_Mat_NeuBewerten]=n) then RETURN;

  // Ankerfunktion
  if (RunAFX('Mat.Neubewertung','')<>0) then RETURN;

  // Markierungnen loopen...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=200) then begin
      vCount # vCount + 1;
    end;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vCount=0) then RETURN;

  vNurAb  # y;
  vFix    # y;
  vDatum  # today;
  vZeit   # 0:0;
  // Dialog starten...
  if (Dlg_Standard:Mat_Neubewertung(var vPreis,
                                    var vAbwertEff,
                                    var vNurAb,
                                    var vGrund,
                                    var vFix,
                                    var vDatum,
                                    var vAenderungEUR,
                                    var vAenderungProz
                                    )=false) then RETURN;

  // Sicherheitsabfrage...
  vTxt # '';

  //200024 :  vA # 'Q:Sollen die Preise dieser %1% Materialkarten %2% geändert werden?';
  if (vPreis <> 0.0) then
    vTxt # cnvai(vCount)+'| auf '+cnvaf(vPreis)+' '+"Set.Hauswährung.Kurz";
  else
  if (vAenderungEUR <> 0.0) then
    vTxt # cnvai(vCount)+'| um '+cnvaf(vAenderungEUR)+' '+"Set.Hauswährung.Kurz";
  else
  if (vAenderungProz <> 0.0) then
    vTxt # cnvai(vCount)+'| um '+cnvaf(vAenderungProz)+'% ';

  if (Msg(200024,vTxt,_WinIcoQuestion, _WinDialogYesNo,2)<>_WinIdYes) then RETURN;

  APPOFF();

  // Markierungnen loopen...
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin

    vDif    # 0.0;
    vDifPM  # 0.0;
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(200,0,_RecId,vMID);

    vMat # Mat.Nummer;


    Mat_B_Data:EkZumDatum( vDatum, var vAltEk, var vAltEkPro);
    vAltEkEff # vAltEK + Mat.Kosten;
    // Aktionen loopen...
    FOR Erx # RecLink(204,200,14,_RecFirst)
    LOOP Erx # RecLink(204,200,14,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      // alle Aktionen NACH dem Stichtag rückrechnen...
      if (Mat.A.AktionsDatum>=vDatum) then begin
        vAltEkEff # vAltEkEff - Mat.A.KostenW1;
      end;
    END;


    // Preis weicht NICHT ab?
    if (vAenderungEUR = 0.0) and (vAenderungProz = 0.0) then begin
      if (vAbwertEff = false) and
        ((vAltEK = vPreis) or ((vAltEK < vPreis) and (vNurAb))) then CYCLE;

      if (vAbWertEff) and
        ((vAltEkEff = vPreis) or ((vAltEKeff < vPreis) and (vNurAb))) then CYCLE;
    end;

    TRANSON;

    Erx # RecRead(200,0,_RecId, vMID);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RecRead(200,1,_recUnlock);
      Msg(001000+Erx,Translate('Material')+' '+cnvAI(Mat.Nummer),0,0,0);
      RETURN;
    end;

    // Preis ggf. für relative Berechnungen anpassen
    if (vAenderungEUR <> 0.0) then begin
      if (vAbwertEff = true) then
        vPreis # vAltEkEff + vAenderungEUR;
      else
        vPreis # vAltEk + vAenderungEUR;
    end;
    if (vAenderungProz <> 0.0) then begin
      if (vAbwertEff = true) then
        vPreis # vAltEkEff + ((vAltEkEff/100.0) * vAenderungProz);
      else
        vPreis # vAltEk + ((vAltEK/100.0) * vAenderungProz);
    end;


//debugx('AltEK:'+anum(vAltEK,2)+'  soll:'+anum(vPreis,2)+'   AltEff:'+anum(vAltEkEff,2));

    // Karte ändern...
    if (vAbwertEff) then
      vPreisNew # vAltEk + vPreis - vAltEkEff
    else
      vPreisNew # vPreis;

    vDif        # vPreisNew - vAltEK;


    Mat_B_Data:BewegungenRueckrechnen(vDatum);  // 14.09.2017

    vPreisNewPM # (vPreisNew * Mat.Bestand.Gew / 1000.0);
    DivOrNull(vPreisNewPM, vPreisNewPM, Mat.Bestand.Menge, 2);
    vDifPM      # vPreisNewPM - vAltEKPro;
//debug('damals:'+anum(Mat.Bestand.Gew,2)+'kg '+anum(MAt.Bestand.Menge,2)+Mat.MEH+'   preispm:'+anum(vpreisnewPM,2));

    if (Mat_Data:SetUndVererbeEkPreis(200, vDatum, vPreisNew, vPreisNewPM, Mat.MEH, 0)=false) then begin
      TRANSBRK;
      APPON();
      RecRead(200,1,_recUnlock);
      Msg(001000+Erx,Translate('Material')+' '+cnvAI(Mat.Nummer),0,0,0);
      RETURN;
    end;

    // Eintrag in Bestandbuch anlegen...
    Mat_Data:Bestandsbuch(0, 0.0, 0.0, vDif, vDifPM, vGrund, vDatum, vZeit, '',0,0,0,0, vFix);

    TRANSOFF;

  END;

  APPON();

  // Erfolg!
  Msg(999998,'',0,0,0);

end;



//========================================================================
//  UmlagernScanner()
//    Läd ein Datenfile vom Scanner und führt die darin gespeicherten
//    Umlagerungen durch
//========================================================================
sub UmlagernScanner() : logic
local begin
  Erx       : int;
  vPathData : alpha;    // Pfad zum Applikationsordner des Scannertools
  vPathEXE  : alpha;    // Pfad zur Exe
  vFlags    : alpha;    // Flags zur Programmausführung
  vTxt      : int;      // Filedeskriptor für die Inputdatei
  vLine     : alpha;    // Datenpuffer für eingelesene Zeile
  vDone     : logic;    // Merker für Dateiende
  vCheck    : float;    // Prüfsumme
  vMat      : alpha;    // temporäre Materialnummer
  vLp       : alpha;    // temporärer Lagerplatz
  vFehler   : int;      // Fehlerzähler
  vFName    : alpha;    // Pfad und Dateiname nach Einlesen
end;
begin


  // Ankerfunktion
  if (RunAFX('Mat.UmlagernScanner','')<>0) then begin
    RETURN (AfxRes=_rOK);
  end;


  // Pfad zur Exe zusammenbauen
  vPathEXE  # Set.BcsScanner.Pfad + 'Data_Read.Exe';

  // Daten in Datenverzeichnis mit Username ablegen
  vPathData # Set.BcsScanner.Pfad + 'Data\'+UserInfo(_UserName,UserID(_UserCurrent))+'.txt';

  // Flagstring für "Data_read.exe"
  vFlags  # vPathData+',1,'+CnvAi(Set.BCScanner.Port)+',1,1,1,1,1,0,0,0,2,2';

  // Scannerprogramm ausführen
  if (SysExecute('*'+vPathEXE,vFlags,_ExecWait) = _ErrOK) then begin

    // Prüfen, ob die Datei gelesen wurde und Daten enthält
    vTxt # FsiOpen(vPathData,_FsiStdRead);
    if (vTxt > 0) then begin

      // Datei offen und fertig zum einlesen

      /*
          Beispielinhalt für die Std. Umlagerungsdatei:
          -------------------
            UMT_19785
            ULP_12
            UMT_12185
            ULP_18
          Die Zeilen sind mit CR LF getrennt
      */


      // Datei bis zum Ende einlesen
      WHILE (true) DO BEGIN
        FsiMark(vTxt,10); // LF als Zeilentrenner
        if (FsiRead(vTxt,vLine) <= 0) then
          break;    // Ende der Datei, Einlesen abschließen

        // Material gefunden?
        if (StrFind(vLine,'UMT_',1) > 0) then begin
          vMat # StrCut(vLine,5,StrLen(vLine)-5);
          vCheck # 0.5; // Check setzen
        end;

        // Lagerplatz gefunden?
        if (StrFind(vLine,'ULP_',1) > 0) then begin
          vLP # StrCut(vLine,5,StrLen(vLine)-5);
          vCheck # vCheck + 1.0;
        end;

        // Prüfsumme muss 1,5 sein um sicherzustellen, dass die letzten 2 Datensätze
        // ein Material und ein Lagerplatz waren
        if (vCheck = 1.5) then begin

          // Lagerplatz lesen
          Lpl.Lagerplatz # vLP;

          Erx # RecRead(844, 1, 0);
          if (Erx <= _rLocked) then begin

            // Lagerplatz ist vorhanden...
            // ...dann Material lesen
            Mat.Nummer # CnvIA(vMat);

            // ST 2010-06-18: Inventurdaten werden jetzt zentral gesetzt
            begin
/*
            if (RecRead(200,1,0 | _RecLock) = _rOK) then begin
              // Lagerplatz ersetzen
              Mat.Lagerplatz # Lpl.Name;
              RekReplace(200,_RecUnlock);
            end
            else begin
              // Material xyz konnte nicht gefunden oder gesperrt werden
              Msg(844016 ,vMat,_WinIcoInformation,_WinDialogOk,1);
              vFehler # vFehler + 1;
            end;
*/
              if (!Mat_Data:SetInventur(Mat.Nummer,Lpl.Lagerplatz, Mat.Inventurdatum, false)) then begin
                // Material xyz konnte nicht gefunden oder gesperrt werden
                Msg(844016 ,vMat,_WinIcoInformation,_WinDialogOk,1);
                vFehler # vFehler + 1;
              end;

            end;
          end
          else begin
            // Der gescannte Lagerplatz ist nicht mehr existent
            Msg(844017,vLp,_WinIcoInformation,_WinDialogOk,1);
            vFehler # vFehler + 1;
          end;

          // Temporäre Daten für den nächsten Datensatz leeren
          vMat   # '';
          vLp    # '';
          vCheck # 0.0; // Prüfsumme zurücksetzen
        end;

      END;  // Nächste Zeile

      FsiClose(vTxt);

      // Vor dem Einlesen UMBENENNEN
      vFName # vPathData;
      vFName # Set.BcsScanner.Pfad + cnvai(Dateyear(today)-100, _FmtNumLeadZero ,0,2);
      vFname # vFName + cnvai(Datemonth(today), _FmtNumLeadZero ,0,2);
      vFname # vFName + cnvai(Dateday(today), _FmtNumLeadZero ,0,2);
      vFname # vFName + '_'+cnvai(TimeHour(now), _FmtNumLeadZero,0,2);
      vFname # vFName + cnvai(TimeMin(now), _FmtNumLeadZero,0,2);
      vFname # vFName + cnvai(TimeSec(now), _FmtNumLeadZero,0,2);
      vFName # vFName + '.csv';
      Erx # FsiRename(vPathData, vFName);

      // Vor dem Einlesen löschen
      // if (vFehler = 0) then
      //   FsiDelete(vPathData);

    end
    else begin
      //  Datei wurde nicht erstellt oder geöffnet werden
      Msg(844010 ,'',_WinIcoInformation,_WinDialogOk,1);
      vFehler # vFehler + 1;
    end;

  end
  else begin
    // Programm konnte nicht gestartet werden
    Msg(844009 ,'',_WinIcoInformation,_WinDialogOk,1);
    vFehler # vFehler + 1;
  end;


  if (vFehler = 0) then
    return true
  else
    return false;


end;

//========================================================================
//  Fehlerprotokoll
//
//========================================================================
sub Fehlerprotokoll();
local begin
  Erx     : int;
  vBuf200 : int;
end
begin


  vBuf200 # RekSave(200);
  RecBufCleaR(707);                       // BA-FM leeren

  REPEAT
    RekLink(707,200,28,0);      // FM Lesen

    if (BAG.FM.Nummer=0) and ("Mat.Vorgänger"<>0) then begin
      Mat_Data:REad("MAt.Vorgänger");
      CYCLE;
    end;

  UNTIL ("Mat.Vorgänger"=0) or (BAG.FM.Nummer<>0);

  RekRestore(vBuf200);

  if (BAG.FM.Nummer<>0) then begin
    Erx # RecRead(707,1,0);
    if (Erx<=_rLocked) then begin
      gMdi # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.FM.FH.Verwaltung','',y);
      Lib_GuiCom:RunChildWindow(gMDI);
    end;
  end;

end;


//========================================================================
//  Kombi
//
//========================================================================
sub Kombi(
  aDatum    : date;
  aZeit     : time;
  opt aList : handle;
  opt aStk  : int;
  opt a200  : int;
  ) : int;
local begin
  erx       : int;
  vSilent   : logic;
  vItem     : int;
  vItem2    : int;
  vMFile    : int;
  vMID      : int;
  vCount    : int;
  vNeueNr   : int;
  vSbr      : int;
  vSbrMax   : int;
  vFld      : int;
  vFldMax   : int;
  vI        : int;
  vError    : int;
  vBuf200   : handle;
  vBuf201   : handle;

  vStk      : int;
  vGew      : float;
  vNetto    : float;
  vBrutto   : float;
  vKosten   : float;
  vMEH      : alpha;
  vCO2Kost  : float;
  vCO2Wert  : float;
  vWert     : float;
  vMenge    : float;
  vKostMEH  : float;
  vWertMEH  : float;
  vEigen    : logic;
  vOK       : logic;
  vX        : float;
end;
begin

  if (aDatum=0.0.0) then begin
    aDatum # today;
    aZeit # now;
  end;

  vSilent # y;
  if (aList=0) then begin
    vSilent # n;
    aList # gMarkList;
  end;

  vError # 0;
  if (vSilent=n) then begin
    // Markierungnen loopen...
    vItem # aList->CteRead(_CteFirst);
    WHILE (vItem > 0) and (vError=0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=200) then begin
        Erx # RecRead(200,0,_RecId,vMID);
        if (vCount=0) then vEigen # Mat.EigenmaterialYN;
        if ("Mat.Löschmarker"='*') or (Mat.Bestellt.Gew>0.0) or (Mat.Status>c_status_bisFrei) then begin
          vError # 1;
          BREAK;
        end;
        if (vEigen<>Mat.EigenmaterialYN) then begin
          vError # 2;
          BREAK;
        end;
        vCount # vCount + 1;
      end;
      vItem # aList->CteRead(_CteNext,vItem);
    END;

    if (vError=1) then begin
      msg(200017,aint(Mat.Nummer),_WinIcoError, _WinDialogok,1);
      RETURN 0;
    end;
    if (vError=2) then begin
      msg(200018,'!',_WinIcoError, _WinDialogok,1);
      RETURN 0;
    end;
    if (vCount<=1) then RETURN 0;
    if (msg(200019,aInt(vCount),_WinIcoQuestion, _WinDialogYesNo,2)<>_winIdyes) then RETURN 0;
  end;


  TRANSON;

  // Markierungnen loopen...
  vCount # 0;
  vItem # aList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then begin
      vItem # aList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(200,0,_RecId,vMID);
    vCount # vCount + 1;

    // neue Karte anlegen?
    if (vNeueNr=0) then begin
      vNeueNr # Lib_Nummern:ReadNummer('Material');
      if (vneueNr<>0) then Lib_Nummern:SaveNummer()
      else begin
        Msg(999999,'',0,0,0);
        TRANSBRK;
        RETURN 0;
      end;
      vBuf200 # RekSave(200);
    end
    else begin
      // KEIN Vorbelegung für Zielmaterial?
      if (a200=0) then begin
        // gleiche Felder übernehmenj
        vI # 0;
        vSbrMax # Fileinfo(200,_FileSbrCount);
        FOR vSbr # 1 loop inc(vSbr) while vSbr<=vSbrMax do begin
          vFldMax # Sbrinfo(200,vSbr,_SbrFldCount);
          FOR vFld # 1 loop inc(vFld) while vFld<=vFldMax do begin
            inc(vI);
            if (RecBufCompareFld(vBuf200,vSbr,vFld)<>true) then begin
              case FldInfo(200,vSbr,vFld,_KeyFldType) of
                _TypeAlpha  : FldDef(vBuf200, vSbr, vFld, '');
                _TypeWord   : FldDef(vBuf200, vSbr, vFld, 0);
                _TypeInt    : FldDef(vBuf200, vSbr, vFld, 0);
                _TypeFloat  : FldDef(vBuf200, vSbr, vFld, 0.0);
                _TypeDate   : FldDef(vBuf200, vSbr, vFld, 0.0.0);
                _TypeTime   : FldDef(vBuf200, vSbr, vFld, 0:0);
                _TypeLogic  : FldDef(vBuf200, vSbr, vFld, false);
              end;
            end;
          END;
        END;
      end
      else begin
        RecBufCopy(a200,vBuf200);
      end;
    end;

    vStk    # vStk + Mat.Bestand.Stk;
    if (aStk<>0) then vStk # aStk;
    vGew    # vGew + Mat.Bestand.Gew;
    vNetto  # vNetto + Mat.Gewicht.Netto;
    vBrutto # vBrutto + Mat.Gewicht.Brutto;
    vMenge  # vMenge + Mat.Bestand.Menge;

    // START-Aktion anlegen -----------
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Entstanden    # vNeueNr;
    Mat.A.Aktionstyp    # c_Akt_Mat_Kombi;
    Mat.A.Aktionsdatum  # aDatum;
    Mat.A.Aktionszeit   # aZeit;
    Mat.A.Bemerkung     # '';
    Mat.A.KostenW1      # 0.0;
    Mat.A.Gewicht       # Mat.Bestand.Gew;
    "Mat.A.Stückzahl"   # Mat.Bestand.Stk;
    Mat.A.Nettogewicht  # Mat.Gewicht.Netto;
    Mat.A.Menge         # Mat.Bestand.Menge;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf200);
      TRANSBRK;
      Msg(999999,'',0,0,0);
      RETURN 0;
    end;


    // Reservierungen übernehmen---------
    Erx # RecLink(203,200,13,_recFirst | _RecLock);
    WHILE (Erx<=_rLocked) do begin
      Mat.R.Materialnr # vNeueNr;
      Erx # RekReplace(203,_recUnlock,'AUTO')
      if (Erx<>_rOK) then begin
        RecBufDestroy(vBuf200);
        TRANSBRK;
        Msg(999999,'',0,0,0);
        RETURN 0;
      end;
      Erx # RecLink(203,200,13,_recFirst | _RecLock);
    END;


/***
    // alte Karten löschen --------
    RecRead(200,1,_RecLock);
    // im Bestandsbuch austragen...
    Mat_Data:Bestandsbuch(-Mat.Bestand.Stk, -Mat.Bestand.Gew, 0.0, c_Akt_Mat_Kombi+' '+aint(vNeueNr), today, c_Akt_Mat_Kombi,0,0);
    RecRead(200,1,_recLock);
    Mat.Gewicht.Netto   # 0.0;
    Mat.Gewicht.Brutto  # 0.0;
    Mat.Bestand.Stk     # 0;
    Mat.Bestand.Gew     # 0.0;
    Mat_Data:SetLoeschmarker('*');
    Mat.Ausgangsdatum # today;
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf200);
      TRANSBRK;
      Msg(999999,'',0,0,0);
      RETURN 0;
    end;
***/


    if (vCount=1) then begin
      // Ausführungen kopieren...
      Mat_Data:CopyAF(vNeueNr);
    end
    else begin
      // AF der 1. Karte loopen...
      Erx # RecLink(201,210,11,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
//debug('hab '+AInt(mat.af.obfnr));
        vBuf201 # RekSave(201);
        vOK # n;
        // AF der Xten Karte loopen...
        Erx # RecLink(201,200,11,_RecFirst);
        WHILE (Erx<=_rLocked) do begin
//debug('checke '+AInt(vBuf201->mat.af.obfnr)+'  gegen   '+aint(Mat.af.ObfNr));
          if (Mat.AF.Seite=vBuf201->Mat.AF.Seite) and
              (Mat.AF.ObfNr=vBuf201->Mat.AF.ObfNr) and
              (Mat.AF.Zusatz=vBuf201->Mat.AF.Zusatz) then begin
            vOK # y;
            BREAK;
          end;
          Erx # RecLink(201,200,11,_RecNext);
        END;
        RekRestore(vBuf201);

        if (vOK=false) then begin
          RecRead(201,1,0);
//debug('lösche...'+AInt(Mat.AF.Obfnr));
          vI # RecLinkInfo(201,210,11,_RecGetPos);
          erx # RekDelete(201,0,'AUTO');
//          if (erx<>_rOK) then debug('xxxx');
          Erx # RecLink(201,210,11,_RecPos, 0, vI);
//debug('A:'+AInt(Mat.AF.Obfnr)+'  Erx');
          CYCLE;
        end;

        Erx # RecLink(201,210,11,_RecNext);
      END;
    end;
    vCount # vCount + 1;


    vItem # aList->CteRead(_CteNext,vItem);
  END;


  RecBufCopy(vBuf200,200);
  // neue Karte anlegen --------------
  Mat.Nummer          # vNeueNr;
  "Mat.Vorgänger"     # 0;
  Mat.Ursprung        # 0;
  Mat.Bestand.Stk     # vStk;
  Mat.Bestand.Gew     # vGew;
  Mat.Gewicht.Netto   # vNetto;
  Mat.Gewicht.Brutto  # vBrutto;
  Mat.Bestand.Menge   # vMenge;
  Mat.Reserviert.Gew  # 0.0;
  Mat.Reserviert.Stk  # 0;
  Mat.Reserviert2.Gew # 0.0;
  Mat.Reserviert2.Stk # 0;
  Mat.Ausgangsdatum   # 0.0.0;
  if ("Mat.Übernahmedatum"=0.0.0) then "Mat.Übernahmedatum" # today;
  "Mat.Löschmarker"   # '';
  "Mat.Lösch.Datum"   # 0.0.0;
  "Mat.Lösch.Zeit"    # 0:0;
  "Mat.Lösch.User"    # ''
  Mat.Eingangsdatum   # today;
  Mat.Anlage.Datum    # today;
  Mat.Anlage.User     # gUsername;
  Mat.Anlage.Zeit     # now;
  Erx # Mat_Data:Insert(_recUnlock,'MAN', aDatum);
  if (erx<>_rOK) then begin
    RecBufDestroy(vBuf200);
    Msg(999999,'',0,0,0);
    TRANSBRK;
    RETURN 0;
  end;
  Mat_Rsv_Data:RecalcAll();
  RecBufCopy(200,210);    // Neue Karte tmp. in Ablage


  vWert # 0.0;

  // Markierungnen loopen...
  vCount # 0;
  vItem # aList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>200) then begin
      vItem # aList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(vBuf200,0,_RecId,vMID);

    vKosten     # Rnd(vBuf200->Mat.Bestand.Gew * vBuf200->Mat.Kosten / 1000.0,2);
    vX          # Rnd(vBuf200->Mat.Bestand.Gew * vBuf200->Mat.EK.Preis / 1000.0,2);
    vWert       # vWert + vX;

    vCO2Kost    # Rnd(vBuf200->Mat.Bestand.Gew * vBuf200->Mat.CO2ZuwachsProT / 1000.0,2);
    vX          # Rnd(vBuf200->Mat.Bestand.Gew * vBuf200->Mat.CO2EinstandProT / 1000.0,2);
    vCo2Wert    # vCo2Wert + vX;

//debugx(anum(vBuf200->Mat.Bestand.Gew,2)+'kg * '+anum(vBuf200->Mat.EK.Preis,2) +'EK = '+anum(vX,2));
//debugx(anum(vBuf200->Mat.Bestand.Gew,2)+'kg * '+anum(vBuf200->Mat.Kosten,2) +'K = '+anum(vKosten,2));
    //  10.04.2013
    vKostMEH  # Rnd(vBuf200->Mat.Bestand.Menge * vBuf200->Mat.KostenProMEH, 2);
    vX        # Rnd(vBuf200->Mat.Bestand.Menge * vBuf200->Mat.EK.PreisProMEH, 2);
    vWertMEH  # vWertMEH + vX;
    // 2023-01-04 AH
    if (vMEH='') then vMEH # vBuf200->Mat.MEH;
    if (vMEH<>vBuf200->Mat.MEH) then vMEH # 'x';
    
debugx(anum(vBuf200->Mat.Bestand.Menge,2)+Mat.MEH+' * '+anum(vBuf200->Mat.EK.PreisProMEH,2) +'EK = '+anum(vX,2));
//debugx(anum(vBuf200->Mat.Bestand.Menge,2)+Mat.MEH+' * '+anum(vBuf200->Mat.KostenProMEH,2) +'K = '+anum(vKostMEH,2));

    // Einsatz-Aktion anlegen----------
    RecBufClear(204);
    Mat.A.Aktionsmat    # vBuf200->Mat.Nummer;
    Mat.A.Entstanden    # 0;
    Mat.A.Aktionstyp    # c_Akt_Mat_Kombi;
    Mat.A.Aktionsdatum  # aDAtum;
    Mat.A.Aktionszeit   # aZeit;
    Mat.A.Bemerkung     # '';
    Mat.A.Gewicht       # vBuf200->Mat.Bestand.Gew;
    "Mat.A.Stückzahl"   # vBuf200->Mat.Bestand.Stk;
    Mat.A.Nettogewicht  # vBuf200->Mat.Gewicht.Netto;
    Mat.A.Menge         # vBuf200->Mat.Bestand.Menge;
    if (Mat.Bestand.Gew<>0.0) then begin
      Mat.A.KostenW1    # Rnd(vKosten / Mat.Bestand.Gew * 1000.0,2);
      Mat.A.CO2ProT     # Rnd(vCO2Kost / Mat.Bestand.Gew * 1000.0,2);
    end;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf200);
      TRANSBRK;
      RETURN 0;
    end;

    vItem # aList->CteRead(_CteNext,vItem);
  END;


  // Markierungnen loopen...
  vCount # 0;
  vItem # aList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>200) then begin
      vItem # aList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(200,0,_RecId,vMID);
    // alte Karten löschen --------
    RecRead(200,1,_RecLock);
    // im Bestandsbuch austragen...
    Mat_Data:Bestandsbuch(-Mat.Bestand.Stk, -Mat.Bestand.Gew, -Mat.Bestand.Menge, 0.0, 0.0, c_Akt_Mat_Kombi+' '+aint(vNeueNr), aDatum, aZeit, c_Akt_Mat_Kombi,0,0);
    RecRead(200,1,_recLock);
    Mat.Gewicht.Netto   # 0.0;
    Mat.Gewicht.Brutto  # 0.0;
    Mat.Bestand.Stk     # 0;
    Mat.Bestand.Gew     # 0.0;
    Mat.Bestand.Menge   # 0.0;
    Mat_Data:SetLoeschmarker('*');
    Mat.Ausgangsdatum # today;
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then begin
      RecBufDestroy(vBuf200);
      TRANSBRK;
      Msg(999999,'',0,0,0);
      RETURN 0;
    end;
    vItem # aList->CteRead(_CteNext,vItem);
  END;


  // Preise in neuer Karte setzen --------------
  Mat.Nummer # vNeueNr;
  RecRead(200,1,_recLock);
  // 2023-01-04 AH
  //if (vMeh<>'x') and (vMeh<>'kg') then begin
  //end
//  else
  if (Mat.Bestand.Gew<>0.0) then begin
    Mat.EK.Preis        # Rnd(vWert / (Mat.Bestand.Gew / 1000.0),2);
    Mat.CO2EinstandProT # Rnd(vCo2Wert / (Mat.Bestand.Gew / 1000.0),2);
    if (Mat.Bestand.Menge<>0.0) then begin
      if (Mat.MEH='kg') then
        Mat.EK.PreisProMEH  # Rnd(vWert / Mat.Bestand.Gew,2);
      else
        Mat.EK.PreisProMEH  # Rnd(vWertMEH / Mat.Bestand.Menge,2);
debugx(Mat.meh+' : '+anum(vWertMEH,2)+' / '+anum(Mat.Bestand.Menge,2)+' = '+anum(Mat.Ek.PreisproMEH,2))
    end
    else begin
      Mat.EK.PreisProMEH  # 0.0;
    end;
  end
  else begin
    Mat.EK.Preis        # 0.0;
    Mat.EK.PreisProMEH  # 0.0;
    Mat.CO2EinstandProT # 0.0;
  end;

//debugx('summe:'+anum(mat.ek.preis,2)+'/t   '+anum(mat.ek.preispromeh,2)+'/'+mat.meh);
  "Mat.AusführungOben"  # Obf_Data:BildeAFString(200,'1');
  "Mat.AusführungUnten" # Obf_Data:BildeAFString(200,'2');
  Mat_Data:Replace(_recunlock, 'AUTO');
  Mat_A_Data:Addkosten();
  RecBufDestroy(vBuf200);

  TRANSOFF;


  if (vSilent=n) then begin
    // Markierungnen loopen zun entfernen...
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      vItem2 # gMarkList->CteRead(_CteNext,vItem);
      if (vMFile=200) then begin
        gMarkList->CteDelete(vItem);
      end;
      vItem # vItem2;
    END;

    // Erfolg!
    Msg(999998,'',0,0,0);

    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  end;

  RETURN vNeueNr;
end;


//========================================================================
//  Aufteilen
//
//========================================================================
sub Aufteilen()  : logic
local begin
  erx       : int;
  vStk      : int;
  vN,vB     : float;
  vDat      : date;
  vTim      : time;
  vGew      : float;
  vNr       : int;
  vMenge    : float;
end
begin
  if (RunAFX('Mat.Aufteilen','')<>0) then begin
    if (AfxRes<>_rOK) then
      RETURN false;
    else
      RETURN true;
  end;


  if ("Mat.Löschmarker"<>'') or (Mat.Auftragsnr<>0) or
    (Mat.Eingangsdatum=0.0.0) or (Mat.Ausgangsdatum<>0.0.0) or
    (Mat.Bestellt.Gew<>0.0) or (Mat.Bestellt.Stk<>0) then begin
//        (Mat.Reserviert.Gew<>0.0) or (Mat.Reserviert.Stk<>0) then begin
    Msg(200100,'',0,0,0);
    RETURN false;
  end;

/***
  if (Dlg_Standard:Anzahl(translate('Stückzahl'),var vI)=false) then RETURN true;
  if (vI<=0) or (vI>Mat.Bestand.Stk) then RETURN false;

  if (Mat.Gewicht.Netto>0.0) then begin
    if (Mat.Bestand.Stk<>0) then
      vX # (Mat.Gewicht.Netto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
    if (Dlg_Standard:Menge(translate('Nettogewicht'),var vX, vX)=false) then RETURN true;
    if (vX<=0.0) or (vX>Mat.Gewicht.Netto) then RETURN false;
  end;

  if (Mat.Gewicht.Brutto>0.0) then begin
    if (Mat.Bestand.Stk<>0) then
      vY # (Mat.Gewicht.Brutto / cnvfi(Mat.Bestand.Stk) ) * cnvfi(vI);
    if (Dlg_Standard:Menge(translate('Bruttogewicht'),var vY,vY)=false) then RETURN true;
    if (vY<=0.0) or (vY>Mat.Gewicht.Brutto) then RETURN false;
  end;
***/
  Erx # RecLink(818,200,10,_recFirst);    // Verwiegungsart holen
  vDat # today;
  if (Dlg_Mat_Splitten:Splitten(var vStk, var vGew, var vN, var vB, var vDat, VwA.NettoYN)=false) then RETURN true;
  if (vDat=today) then vTim # now;
  if (vStk<=0) or (vStk>Mat.Bestand.Stk) then RETURN false;
  if (((vN<=0.0) or (vN>Mat.Gewicht.Netto)) and (Mat.Gewicht.Netto > 0.0)) then
    RETURN false;
  if (((vB<=0.0) or (vB>Mat.Gewicht.Brutto)) and (Mat.Gewicht.Brutto > 0.0))then
    RETURN false;

  /*
  if (Dlg_Standard:Menge(translate('Gewicht'),var vX)=false) then RETURN true;
  if (vX<=0.0) or (vX>Mat.Bestand.Gew) then RETURN false;
  vY # vX / Mat.Bestand.Gew;
  vX # Mat.Gewicht.Netto  * vY;
  vY # Mat.Gewicht.Brutto * vY;
  */

  // VORLÄUFIG:
  vMenge # 0.0;
  if (Mat_Data:Splitten(vStk, vN, vB, vMenge, vDat, vTim, var vNr,'')=true) then begin
    Msg(200101,AInt(vNr),0,0,0);
  end
  else begin

// ST 2010-04-06: Fehlermeldungen werden jetzt innherhalb von Splitten() ausgegeben
//        Msg(200102,'',0,0,0);
  end;

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect)
  RETURN true;
end;


//========================================================================
//  _AddiereLG
//
//========================================================================
sub _AddiereLG(
  aVon    : date;
  aBis    : date;
  aTree   : handle) : float;
local begin
  Erx     : int;
  vItem   : handle;
  vBuf200 : int;
  vOK     : logic;
end;
begin

  if (cnvid(aBis) - cnvid(aVon)<=0) then RETURN 0.0;

  VarAllocate(Struct_Lagergeld);          // neue Structure anlegen

  s_Gewicht # Mat.Bestand.Gew;
  s_Tage    # cnvid(aBis) - cnvid(aVon);

  if (Mat.Datum.Erzeugt>=aVon) then begin
    vOK # y;
    if ("Mat.Vorgänger"<>0) then begin
      vBuf200 # RecBufCreate(200);
      vBuf200->Mat.Nummer # "Mat.Vorgänger";
      RecRead(vBuf200,1,0);
      if (Erx<=_rLocked) and
        (Mat.Lageradresse=vBuf200->MAt.LAgeradresse) and
        (Mat.Lageranschrift=vBuf200->Mat.Lageranschrift) then
        vOK # n;
      RecBufDestroy(vBuf200);
    end;

    if (vOK) then begin
//debug('Add 1 bei '+aint(mat.nummer));
      s_Tage # s_Tage + 1;
    end;
  end;

  s_MatNr   # Mat.Nummer;
  s_VonDat  # aVon;
  s_BisDat  # aBis;
  s_Gewicht # Mat.Bestand.Gew;
  s_TTage   # Rnd(s_Gewicht / 1000.0 * cnvfi(s_Tage),2);

  // Item für Baum anlegen...
  vItem # CteOpen(_CteItem);

  // Sortierung über EINDEUTIGEN Name
  vItem->spname # cnvai(s_MatNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+
                  ADatReverse(s_VonDat)+
                  ADatReverse(s_BisDat);

/*
  vItem->spname # ADatReverse(s_BisDat)+
                  ADatReverse(s_VonDat)+
                  cnvai(s_MatNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8);
*/

  // Handle der Structure im Item mekren...
  vItem->spid   # VarInfo(struct_Lagergeld);

  // Item im Baum speicehrn...
  Cteinsert(aTree, vitem);

//debug(cnvai(Mat.Nummer)+' '+cnvad(aVon)+'-'+cnvad(aBis)+' : '+ANum(Mat.Bestand.Gew,0)+'kg  =  '+ANum(s_TTage,2)+' t/Tag' + vA);

  RETURN s_TTage;
end;


//========================================================================
//  _AddiereLGMonat
//
//========================================================================
sub _AddiereLGMonat(
  aVon    : date;
  aBis    : date;
  aTree   : handle) : float;
local begin
  vItem   : handle;
  vBuf200 : int;
  vOK     : logic;
end;
begin

// Knappstein: Selbst "eine Sekunde" im Lager erzeugt Monatskosten (also "<" statt "<=")
  if (cnvid(aBis) - cnvid(aVon)<0) then RETURN 0.0;


  VarAllocate(Struct_Lagergeld);          // neue Structure anlegen

  s_Gewicht # Mat.Bestand.Gew;
  s_Tage    # ((aBis->vpMonth)+(aBis->vpYear*12)) - ((aVon->vpMonth)+(aVon->vpYear*12));
  s_Tage # s_Tage + 1;

  s_MatNr   # Mat.Nummer;
  s_VonDat  # aVon;
  s_BisDat  # aBis;
  s_Gewicht # Mat.Bestand.Gew;
  s_TTage   # Rnd(s_Gewicht / 1000.0 * cnvfi(s_Tage),2);

  // Item für Baum anlegen...
  vItem # CteOpen(_CteItem);

  // Sortierung über EINDEUTIGEN Name
  vItem->spname # cnvai(s_MatNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8)+
                  ADatReverse(s_VonDat)+
                  ADatReverse(s_BisDat);

  // Handle der Structure im Item mekren...
  vItem->spid   # VarInfo(struct_Lagergeld);

  // Item im Baum speicehrn...
  Cteinsert(aTree, vitem);

// TEST debug(cnvai(Mat.Nummer)+' '+cnvad(aVon)+'-'+cnvad(aBis)+' : '+ANum(Mat.Bestand.Gew,0)+'kg  =  '+ANum(s_TTage,2)+' t/Tag');

  RETURN s_TTage;
end;



//========================================================================
//  _VererbeDatum
//
//========================================================================
sub _vererbeDatum(
  aMat      : int;
  aVon      : date;
  aBis      : date;
  aTreeDat  : handle);
local begin
  Erx     : int;
  vNr     : int;
  vBuf204 : int;
  vItem   : handle;
end;
begin

//debug('set:'+aINt(aMat)+' auf '+cnvad(aBis));
  vItem # aTreeDat->CteRead(_CteFirst | _CteSearch, 0, cnvai(aMat,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
  if (vItem<>0) then CteDelete(aTreeDat, vItem);
  vItem # CteOpen(_CteItem);
  vItem->spname   # cnvai(aMat,_FmtNumNoGroup|_FmtNumLeadZero,0,8);
  vItem->spCustom # cnvad(aBis);
  Cteinsert(aTreeDat, vitem);

  vBuf204 # RekSave(204);

  vNr     # Mat.Nummer;
  Mat.Nummer  # aMat;

  // Lagergelddatum einfügen...
  Erx # RecLink(204,200,14,_recFirst);    // Aktionen loopen
  WHILE (Erx<=_rLocked) do begin
//debug('akt:'+aint(vbuf204->mat.A.Aktionsnr)+' '+cnvai(vBuf204->mat.A.Entstanden)+' '+cnvad(vBuf204->Mat.A.Aktionsdatum));
    if (mat.A.Entstanden<>aMat) and (Mat.A.Entstanden<>0) and
      (Mat.A.Aktionsdatum>aVon) and
      (Mat.A.Aktionsdatum<=aBis) then begin
      _VererbeDatum(Mat.A.Entstanden, aVon, aBis, aTreedat);
    end;
    Erx # RecLink(204,200,14,_recNext);
  END;

  RekRestore(vBuf204);
  RecRead(204,1,0);
  Mat.Nummer # vNr;

end;


//========================================================================
//  _AddiereZinsen
//
//========================================================================
sub _AddiereZinsen(
  aSatz     : float;
  aVon      : date;
  aBis      : date;
  aTree     : handle;
  aTreeDat  : handle;
  aMod      : int) : float;
local begin
  vA    : alpha;
  vItem : handle;
end;
begin

  if (cnvid(aBis) - cnvid(aVon)<=0) then RETURN 0.0;
  if (Mat.Bestand.Gew<=0.0) then RETURN 0.0;

//debug('set:'+aINt(mat.nummer)+' auf '+cnvad(aBis));
  _VererbeDatum(mat.Nummer, aVon, aBis, aTreeDat);

  VarAllocate(Struct_Lagergeld);          // neue Structure anlegen

  if (aMod=1) and (Mat.Ursprung<>Mat.Nummer) then aMod # 0;
  s_Gewicht # Mat.Bestand.Gew;
  s_Tage    # cnvid(aBis) - cnvid(aVon) + aMod;

//  if (Mat.Ursprung<>Mat.Nummer) then begin
//    s_Tage # s_Tage - 1;
//    vA # '*';
//  end;

  s_MatNr   # Mat.Nummer;
  s_VonDat  # aVon;
  s_BisDat  # aBis;
  s_Gewicht # Mat.Bestand.Gew;
  s_TTage   # Rnd(s_Gewicht / 1000.0 * Mat.EK.Effektiv,2);
  s_TTage   # s_TTage / 100.0 * aSatz;
  s_TTage   # Rnd(s_TTage / 365.0 * cnvfi(s_Tage) ,2);

  // Item für Baum anlegen...
  vItem # CteOpen(_CteItem);

  // Sortierung über EINDEUTIGEN Name
  vItem->spname # ADatReverse(s_BisDat)+
                  ADatReverse(s_VonDat)+
                  cnvai(s_MatNr,_FmtNumNoGroup|_FmtNumLeadZero,0,8);

  // Handle der Structure im Item mekren...
  vItem->spid   # VarInfo(struct_Lagergeld);

  // Item im Baum speicehrn...
  Cteinsert(aTree, vitem);

//debug(cnvai(Mat.Nummer)+' '+cnvad(aVon)+'-'+cnvad(aBis)+' : '+ANum(Mat.Bestand.Gew,0)+'kg  =  '+ANum(s_TTage,2)+' t/Tag' + vA);

  RETURN s_TTage;
end;


//========================================================================
//  _CalcLagergeld
//
//========================================================================
sub _CalcLagergeld(
  aTree       : handle;
  var aTTage  : float);
local begin
  Erx       : int;
  vVon      : date;
  vBis      : date;
  vVon2     : date;
  vBis2     : date;
  vI        : int;
  vX        : float;
end;
begin
  vVon # Mat.Datum.Lagergeld;
  if (vVon=0.0.0) then vVon # Mat.Eingangsdatum;
  if (vVon<Sel.Mat.von.EDatum) then vVon # Sel.Mat.von.EDatum;
  if (vVon<Mat.Datum.Erzeugt) then vVon # Mat.Datum.Erzeugt;

  vBis # Sel.Mat.Bis.EDatum;
  if (Mat.Ausgangsdatum<>0.0.0) and (Mat.Ausgangsdatum<Sel.Mat.Bis.EDatum) then vBis # Mat.Ausgangsdatum;

  vI # cnvid(vBis) - cnvid(vVon);

  if ((vI>=0) and (Mat.Status<>c_Status_Geliefert)) or (vI>0) then begin
    Erx # RecLink(202,200,12,_RecLast);     // Bestandsbuch loopen
    WHILE (Erx<=_rLocked) and (Mat.B.Datum>vVon) do begin
      if (Mat.B.Menge<>0.0) or ("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0) then begin
        Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
        Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
        Mat.BEstand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
      end;
      Erx # RecLink(202,200,12,_RecPrev);
    END;

    Erx # RecLink(202,200,12,_RecFirst);    // Bestandsbuch loopen
    WHILE (Erx<=_rLocked) and
          ((Mat.B.Datum<=vVon) or (("Mat.B.Stückzahl"=0) and (Mat.B.gewicht=0.0) and (Mat.B.Menge=0.0))) do
      Erx # RecLink(202,200,12,_RecNext);

    vVon2 # vVon;
    vBis2 # vBis;

    if (Erx<=_rLocked) and (Mat.B.Datum<=vBis) then begin
      REPEAT
        vBis2   # Mat.B.Datum;
        aTTage  # aTTage + _AddiereLG(vVon2, vBis2, aTree );
        vVon2   # vBis2;

        WHILE (Erx<=_rLocked) and (Mat.B.Datum=vBis2) do begin
          Mat.Bestand.Gew   # Mat.Bestand.Gew + Mat.B.Gewicht;
          Mat.Bestand.Stk   # Mat.Bestand.Stk + "Mat.B.Stückzahl";
          Mat.Bestand.Menge # Mat.Bestand.Menge + Mat.B.Menge;
          Erx # RecLink(202,200,12,_RecNext);
        END;
      UNTIl (Erx>_rLockeD) or (Mat.B.Datum>vBis);
      if (vVon2>vVon) and (vVon2<=vBis) then begin
        aTTage  # aTTage + _AddiereLG(vVon2, vBis, aTree);
      end;
    end
    else begin
      aTTage  # aTTage + _AddiereLG(vVon, vBis, aTree);
    end;

  end;
end;


//========================================================================
//  _CalcLagergeldMonat
//
//========================================================================
sub _CalcLagergeldMonat(
  aTree         : handle;
  var aTMonate  : float);
local begin
  erx       : int;
  vVon      : date;
  vBis      : date;
  vVon2     : date;
  vBis2     : date;
  vI        : int;
  vX        : float;
  vCT       : caltime;
end;
begin
  vVon # Mat.Datum.Lagergeld;

  // aus "Mitte" vom Monat wird Erster vom Folgemonat...
  if (vVon<>0.0.0) then begin
    vCT->vpDate # DateMake(1, vVon->vpMonth, vVon->vpYear);
    vCT->vmMonthmodify(1);
    vVon # vCT->vpDate;
  end;

  if (vVon=0.0.0) then vVon # Mat.Eingangsdatum;
  if (vVon<Sel.Mat.von.EDatum) then vVon # Sel.Mat.von.EDatum;
  if (vVon<Mat.Datum.Erzeugt) then vVon # Mat.Datum.Erzeugt;

  vBis # Sel.Mat.Bis.EDatum;
  if (Mat.Ausgangsdatum<>0.0.0) and (Mat.Ausgangsdatum<Sel.Mat.Bis.EDatum) then vBis # Mat.Ausgangsdatum;

  vI # cnvid(vBis) - cnvid(vVon);

  if ((vI>=0) and (Mat.Status<>c_Status_Geliefert)) or (vI>0) then begin
    Erx # RecLink(202,200,12,_RecLast);     // Bestandsbuch IMMER KOMPLETT rückrechnen!!!
    WHILE (Erx<=_rLocked) do begin
      if (Mat.B.Menge<>0.0) or ("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0) then begin
        Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
        Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
        Mat.Bestand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
      end;
      Erx # RecLink(202,200,12,_RecPrev);
    END;

    aTMonate # aTMonate + _AddiereLGMonat(vVon, vBis, aTree);
  end;

end;


//========================================================================
//  _CalcZinsen
//
//========================================================================
sub _CalcZinsen(
  aSatz       : float;
  aTree       : handle;
  aTreeDat    : handle;
  var aZinsen : float;
  aVon        : date;
  aBis        : date);
local begin
  erx       : int;
  vVon      : date;
  vBis      : date;
  vVon2     : date;
  vBis2     : date;
  vI        : int;
  vX        : float;

  vFirst    : logic;
  vItem     : handle;
  vDat      : date;
  vVor      : int;
  vBuf200   : int;
end;
begin

//debug('CALC '+aint(Mat.nummer));

  vVon # aVon;

  vItem # aTreeDat->CteRead(_CteFirst | _CteSearch, 0, cnvai(Mat.Nummer,_FmtNumNoGroup|_FmtNumLeadZero,0,8));
  if (vItem<>0) then begin
    vDat # cnvda(vItem->spCustom);
  end;

  if (vDat=0.0.0) then vDat # Mat.Datum.Zinsen;
  if (vVon<vDat) then vVon # vDat;

  vBis # vBis;
  if (Mat.Ausgangsdatum<>0.0.0) and (Mat.Ausgangsdatum<aBis) then vBis # Mat.Ausgangsdatum;
  if (vBis=0.0.0) then vBis # aBis;


  vI # cnvid(vBis) - cnvid(vVon);
  if (vI<=0) then RETURN;


  Erx # RecLink(202,200,12,_RecLast);     // Bestandsbuch loopen
  WHILE (Erx<=_rLocked) and (Mat.B.Datum>vVon) do begin
    if ("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0) or (Mat.B.Menge<>0.0) then begin
      Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
      Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
      Mat.Bestand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
    end;
    Erx # RecLink(202,200,12,_RecPrev);
  END;

  Erx # RecLink(202,200,12,_RecFirst);    // Bestandsbuch loopen
  WHILE (Erx<=_rLocked) and
        ((Mat.B.Datum<=vVon) or (("Mat.B.Stückzahl"=0) and (Mat.B.gewicht=0.0) and (Mat.B.Menge=0.0))) do
    Erx # RecLink(202,200,12,_RecNext);

  vVon2 # vVon;
  vBis2 # vBis;

  if (Erx<=_rLocked) and (Mat.B.Datum<=vBis) then begin
    vFirst # y;
    REPEAT
      vBis2   # Mat.B.Datum;
      if (vFirst) then
        aZinsen # aZinsen + _AddiereZinsen(aSatz, vVon2, vBis2, aTree, AtreeDat, 1)
      else
        aZinsen # aZinsen + _AddiereZinsen(aSatz, vVon2, vBis2, aTree, AtreeDat, 0);
      vFirst # n;
      Erx # _rOK;
      vVon2   # vBis2;
      WHILE (Erx<=_rLocked) and (Mat.B.Datum=vBis2) do begin
        Mat.Bestand.Gew   # Mat.Bestand.Gew + Mat.B.Gewicht;
        Mat.Bestand.Stk   # Mat.Bestand.Stk + "Mat.B.Stückzahl";
        Mat.Bestand.Menge # Mat.Bestand.Menge + Mat.B.Menge;
        Erx # RecLink(202,200,12,_RecNext);
      END;
    UNTIl (Erx>_rLockeD) or (Mat.B.Datum>vBis);
    if (vVon2>vVon) and (vVon2<=vBis) then begin
      aZinsen # aZinsen + _AddiereZinsen(aSatz, vVon2, vBis, aTree, aTreeDat,0);
    end;
  end
  else begin
    aZinsen # aZinsen + _AddiereZinsen(aSatz, vVon, vBis, aTree, aTreeDat,1);
  end;

end;


//========================================================================
//  LagergeldFremd
//
//========================================================================
sub LagergeldFremd();
begin

  if (RunAFX('Mat.LagergeldFremd','')<>0) then RETURN;

  RecBufClear(998);
  GV.Num.01   # 0.0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mat.Lagergeld',here+':AusLagergeldFremd');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusLagergeldFremd
//
//========================================================================
sub AusLagergeldFremd();
local begin
  Erx       : int;
  vKosten   : float;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vTTage    : float;
  vTree     : handle;
  vItem     : handle;
  vBasis    : float;
end;
begin

  // Logische Prüfungen...
  if (Sel.Mat.Lagerort=0) then begin
    Msg(1200,Translate('Lageradresse'),0,0,0);
    RETURN;
  end;

  if (Sel.Mat.von.EDatum=0.0.0) then begin
    Msg(1200,Translate('Startdatum'),0,0,0);
    RETURN;
  end;

  if (Sel.Mat.bis.EDatum>today) then begin
    Msg(200020,'',0,0,0);
    RETURN;
  end;

  if (GV.Num.01=0.0) then begin
    Msg(1200,Translate('Betrag'),0,0,0);
    RETURN;
  end;


  vKosten # GV.Num.01;
  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  // BESTAND-Selektion
  Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat.Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagerAnschri<>0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri);
  vQ # vQ + ' AND (Mat.EigenmaterialYN)';

  vSel # SelCreate(200, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(200,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    _CalcLagergeld(vTree, var vTTage);
    Erx # RecRead(200,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);


  // ABLAGE-Selektion
  vQ # '';
  Lib_Sel:QVonBisD(var vQ, '"Mat~Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat~Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, '"Mat~Lageradresse"', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagerAnschri<>0) then
    Lib_Sel:QInt(var vQ, '"Mat~Lageranschrift"', '=', Sel.Mat.LagerAnschri);
  vQ # vQ + ' AND ("Mat~EigenmaterialYN")';

  vSel # SelCreate(210, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(210,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    RecBufCopy(210,200);
    _CalcLagergeld(vTree, var vTTage);
    Erx # RecRead(210,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);


  // LISTE anzeigen ----------------------------------------------------------------
  if (vTTage<>0.0) then
    vBasis # Rnd(vKosten / vTTage,4);

  GV.Int.01 # vTree;
  GV.Num.01 # vBasis;
  Lfm_Ausgabe:Starten('', 200007);
//  Lfm_Ausgabe:Starten(200568);

  Erx # Msg(200021,ANum(vBasis,4),_WinIcoQuestion, _WinDialogYesNo,2);
  if (Erx<>_WinIdYes) then begin
    // Tree durchlaufen und
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin

      // Structure holen...
      VarInstance(struct_Lagergeld, vItem->spID);

      // Structure zerstören...
      VarFree(struct_Lagergeld);
    END;

    // Baum löschen...
    Sort_KillList(vTree);

    RETURN;
  end;


  // BUCHEN --------------------------------------------------------------------

  TRANSON;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    Mat.Nummer # s_MatNr;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      // Datum im Material merken...
      RecRead(200,1,_recLock);
      Mat.Datum.Lagergeld # s_BisDat;
      Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');
      // Aktion anlegen...
      RecBufClear(204);
      Mat.A.Aktionsmat    # s_MatNr;
      Mat.A.Aktionstyp    # c_Akt_Lagergeld;
      Mat.A.Bemerkung     # c_AktBem_Lagergeld;
      Mat.A.Aktionsdatum  # s_BisDat;
      Mat.A.Terminstart   # s_vonDat;
      Mat.A.Terminende    # s_BisDat;
      Mat.A.Adressnr      # 0;
      //Mat.A.KostenW1      # Rnd(vBasis * s_TTage,2);
      if (s_Gewicht<>0.0) then
        Mat.A.KostenW1      # Rnd(vBasis * s_TTage / s_Gewicht * 1000.0,2);
      //Mat.A.Kostenstelle # ArG.Kostenstelle;
      Mat_a_data:Insert(0,'AUTO')
      if (Mat_A_Data:Vererben('LAGERGELD')=falsE) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;
    end
    else begin
      "Mat~Nummer" # s_MatNr;
      Erx # RecRead(210,1,0);
      if (Erx<=_rLocked) then begin
        // Datum im Material merken...
        RecRead(210,1,_recLock);
        "Mat~Datum.Lagergeld" # s_BisDat;
        RekReplace(210,_recunlock,'AUTO');
        RecBufCopy(210,200);
        // Aktion anlegen...
        RecBufClear(204);
        Mat.A.Aktionsmat    # s_MatNr;
        Mat.A.Aktionstyp    # c_Akt_Lagergeld;
        Mat.A.Bemerkung     # c_AktBem_Lagergeld;
        Mat.A.Aktionsdatum  # s_BisDat;
        Mat.A.Terminstart   # s_vonDat;
        Mat.A.Terminende    # s_BisDat;
        Mat.A.Adressnr      # 0;
        //Mat.A.KostenW1      # Rnd(vBasis * s_TTage,2);
        if (s_Gewicht<>0.0) then
          Mat.A.KostenW1      # Rnd(vBasis * s_TTage / s_Gewicht * 1000.0,2);
        //Mat.A.Kostenstelle # ArG.Kostenstelle;
        Mat_A_data:Insert(0,'AUTO')
        Mat_A_Abl_Data:Abl_Vererben('LAGERGELD');
      end;
    end;

    // Structure zerstören...
    VarFree(struct_Lagergeld);
  END;

  TRANSOFF;

  // Baum löschen...
  Sort_KillList(vTree);

  // ERFOLG:
  Msg(999998,'',0,0,0);

end;


//========================================================================
//  LagergeldFremdMonat
//
//========================================================================
sub LagergeldFremdMonat(aPara : alpha(4096)) : int;
begin

  RecBufClear(998);
  GV.Num.01   # 0.0;
/*** TEST
GV.Num.01 # 5000.0;
Sel.Mat.Lagerort # 654;
Sel.Mat.Lageranschri # 1;
Sel.Mat.von.EDatum # 1.1.2015;
Sel.Mat.Bis.EDatum # 31.12.2015;
***/

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mat.Lagergeld',here+':AusLagergeldFremdMonat');
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN -1;
end;


//========================================================================
//  AusLagergeldFremdMonat
//
//========================================================================
sub AusLagergeldFremdMonat();
local begin
  Erx       : int;
  vKosten   : float;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vTTage    : float;
  vTree     : handle;
  vItem     : handle;
  vBasis    : float;
  vCT       : caltime;
end;
begin

  // Logische Prüfungen...
  if (Sel.Mat.Lagerort=0) then begin
    Msg(1200,Translate('Lageradresse'),0,0,0);
    RETURN;
  end;

  if (Sel.Mat.von.EDatum=0.0.0) then begin
    Msg(1200,Translate('Startdatum'),0,0,0);
    RETURN;
  end;
  if (Sel.Mat.von.EDatum->vpDay<>1) then begin
    Msg(99,'Der Zeitraum darf nur am Ersten eines Monats beginnen!',0,0,0);
    RETURN;
  end;

  if (Sel.Mat.bis.EDatum=0.0.0) then begin
    Msg(1200,Translate('Enddatum'),0,0,0);
    RETURN;
  end;
  vCT->vpDate # Sel.Mat.Bis.EDatum;
  vCT->vmDayModify(1);
  if (vCT->vpDay<>1) then begin
    Msg(99,'Der Zeitraum darf nur am Letzen eines Monats enden!',0,0,0);
    RETURN;
  end;

  if (GV.Num.01=0.0) then begin
    Msg(1200,Translate('Betrag'),0,0,0);
    RETURN;
  end;


  vKosten # GV.Num.01;
  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  // BESTAND-Selektion
  Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat.Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagerAnschri<>0) then
    Lib_Sel:QInt(var vQ, 'Mat.Lageranschrift', '=', Sel.Mat.LagerAnschri);
  vQ # vQ + ' AND (Mat.EigenmaterialYN)';
  Lib_Sel:QDate(var vQ, '"Mat.Datum.Lagergeld"', '<', "Sel.Mat.bis.EDatum", 'AND');

  vSel # SelCreate(200, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

//SelCopy(200, vSelname, 'AAA');

  FOR Erx # RecRead(200,vSel,_recFirst)
  LOOP Erx # RecRead(200,vSel,_recNext)
  WHILE (Erx <= _rLocked) DO BEGIN
/* TEST
if (Mat.Nummer<>194643) and
    (Mat.Nummer<>194715) and
    (Mat.Nummer<>210417) and
    (Mat.Nummer<>213804) and
    (Mat.Nummer<>214168) and
    (Mat.Nummer<>217630) and
    (Mat.Nummer<>223375) then CYCLE;
//if (Random()>0.01) then CYCLE;
*/
    _CalcLagergeldMonat(vTree, var vTTage);
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);

/*** TEST */
  // ABLAGE-Selektion
  vQ # '';
  Lib_Sel:QVonBisD(var vQ, '"Mat~Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat~Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, 'Mat~Lageradresse', '=', Sel.Mat.Lagerort);
  if (Sel.Mat.LagerAnschri<>0) then
    Lib_Sel:QInt(var vQ, 'Mat~Lageranschrift', '=', Sel.Mat.LagerAnschri);
  vQ # vQ + ' AND ("Mat~EigenmaterialYN")';
  Lib_Sel:QDate(var vQ, '"Mat~Datum.Lagergeld"', '<', "Sel.Mat.bis.EDatum", 'AND');

  vSel # SelCreate(210, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR Erx # RecRead(210,vSel,_recFirst)
  LOOP Erx # RecRead(210,vSel,_recNext)
  WHILE (Erx <= _rLocked) DO BEGIN
    RecBufCopy(210,200);
    _CalcLagergeldMonat(vTree, var vTTage);
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);
/***/


  // LISTE anzeigen ----------------------------------------------------------------
  if (vTTage=0.0) then begin
    Sort_KillList(vTree);
    Msg(99,'Keine Tonnage gefunden!',0,0,0);
    RETURN;
  end;
  vBasis # Rnd(vKosten / vTTage, 4);


  GV.Int.01 # vTree;
  GV.Num.01 # vBasis;
  Lfm_Ausgabe:Starten('', 200007);

//Lib_Debug:StartBlueMode();

  Erx # Msg(99,'Sollen die '+ANum(vBasis,4)+"Set.Hauswährung.Kurz"+' pro TonnenMonat verbucht werden?',_WinIcoQuestion, _WinDialogYesNo,2);
  if (Erx<>_WinIdYes) then begin
    // Tree durchlaufen und
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin

      // Structure holen...
      VarInstance(struct_Lagergeld, vItem->spID);

      // Structure zerstören...
      VarFree(struct_Lagergeld);
    END;

    // Baum löschen...
    Sort_KillList(vTree);

    RETURN;
  end;


  // BUCHEN --------------------------------------------------------------------

  TRANSON;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    Mat.Nummer # s_MatNr;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      // Datum im Material merken...
      RecRead(200,1,_recLock);
      Mat.Datum.Lagergeld # s_BisDat;
      Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');
      // Aktion anlegen...
      RecBufClear(204);
      Mat.A.Aktionsmat    # s_MatNr;
      Mat.A.Aktionstyp    # c_Akt_Lagergeld;
      Mat.A.Bemerkung     # c_AktBem_Lagergeld;
      Mat.A.Aktionsdatum  # s_BisDat;
      Mat.A.Terminstart   # s_vonDat;
      Mat.A.Terminende    # s_BisDat;
      Mat.A.Adressnr      # 0;
      //Mat.A.KostenW1      # Rnd(vBasis * s_TTage,2);
      if (s_Gewicht<>0.0) then
        Mat.A.KostenW1      # Rnd(vBasis * s_TTage / s_Gewicht * 1000.0,2);
      //Mat.A.Kostenstelle # ArG.Kostenstelle;
      Mat_a_data:Insert(0,'AUTO')
      if (Mat_A_Data:Vererben('LAGERGELD')=falsE) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;

    end
    else begin
      "Mat~Nummer" # s_MatNr;
      Erx # RecRead(210,1,0);
      if (Erx<=_rLocked) then begin
        // Datum im Material merken...
        RecRead(210,1,_recLock);
        "Mat~Datum.Lagergeld" # s_BisDat;
        RekReplace(210,_recunlock,'AUTO');
        RecBufCopy(210,200);
        // Aktion anlegen...
        RecBufClear(204);
        Mat.A.Aktionsmat    # s_MatNr;
        Mat.A.Aktionstyp    # c_Akt_Lagergeld;
        Mat.A.Bemerkung     # c_AktBem_Lagergeld;
        Mat.A.Aktionsdatum  # s_BisDat;
        Mat.A.Terminstart   # s_vonDat;
        Mat.A.Terminende    # s_BisDat;
        Mat.A.Adressnr      # 0;
        //Mat.A.KostenW1      # Rnd(vBasis * s_TTage,2);
        if (s_Gewicht<>0.0) then
          Mat.A.KostenW1      # Rnd(vBasis * s_TTage / s_Gewicht * 1000.0,2);
        //Mat.A.Kostenstelle # ArG.Kostenstelle;
        Mat_A_data:Insert(0,'AUTO')
        Mat_A_Abl_Data:Abl_Vererben('LAGERGELD');
      end;
    end;

    // Structure zerstören...
    VarFree(struct_Lagergeld);
  END;

  TRANSOFF;

  // Baum löschen...
  Sort_KillList(vTree);

  // ERFOLG:
  Msg(999998,'',0,0,0);

end;


//========================================================================
//  LagergeldKunde
//
//========================================================================
sub LagergeldKunde();
begin
  RecBufClear(998);
  GV.Num.01   # 0.0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mat.LagergeldKunde',here+':AusLagergeldKunde');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusLagergeldKunde
//
//========================================================================
sub AusLagergeldKunde();
local begin
  Erx       : int;
  vKosten   : float;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vTTage    : float;
  vTree     : handle;
  vItem     : handle;
end;
begin

  // Logische Prüfungen...
  if (Sel.Mat.Lieferant=0) then begin
    Msg(1200,Translate('Lieferant'),0,0,0);
    RETURN;
  end;

  if (Sel.Mat.von.EDatum=0.0.0) then begin
    Msg(1200,Translate('Startdatum'),0,0,0);
    RETURN;
  end;

  if (Sel.Mat.bis.EDatum>today) then begin
    Msg(200020,'',0,0,0);
    RETURN;
  end;

  if (GV.Num.01=0.0) then begin
    Msg(1200,Translate('Betrag'),0,0,0);
    RETURN;
  end;


  vKosten # GV.Num.01;
  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  // BESTAND-Selektion
  Lib_Sel:QVonBisD(var vQ, '"Mat.Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat.Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', Sel.Mat.Lieferant);
  Lib_Sel:QInt(var vQ, 'Mat.Lageradresse', '=', Set.eigeneAdressnr);
  vQ # vQ + ' AND (!Mat.EigenmaterialYN)';

  vSel # SelCreate(200, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(200,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    _CalcLagergeld(vTree, var vTTage);
    Erx # RecRead(200,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);


  // ABLAGE-Selektion
  vQ # '';
  Lib_Sel:QVonBisD(var vQ, '"Mat~Eingangsdatum"', 1.1.1900, "Sel.Mat.Bis.EDatum");
  Lib_Sel:QDate(var vQ, '"Mat~Datum.Erzeugt"', '<=', "Sel.Mat.Bis.EDatum", 'AND');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '>=', "Sel.Mat.von.EDatum",'AND (');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  Lib_Sel:QInt(var vQ, '"Mat~Lieferant"', '=', Sel.Mat.Lieferant);
  vQ # vQ + ' AND (!"Mat~EigenmaterialYN")';

  vSel # SelCreate(210, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(210,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    RecBufCopy(210,200);
    _CalcLagergeld(vTree, var vTTage);
    Erx # RecRead(210,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);


  // LISTE anzeigen ----------------------------------------------------------------

  GV.Int.01 # vTree;
  GV.Num.01 # vKosten;
  Lfm_Ausgabe:Starten('', 200008);

  Erx # Msg(200021,ANum(vKosten,2),_WinIcoQuestion, _WinDialogYesNo,2);
  if (Erx<>_WinIdYes) then begin
    // Tree durchlaufen und
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin

      // Structure holen...
      VarInstance(struct_Lagergeld, vItem->spID);

      // Structure zerstören...
      VarFree(struct_Lagergeld);
    END;

    // Baum löschen...
    Sort_KillList(vTree);

    RETURN;
  end;


  // BUCHEN --------------------------------------------------------------------

  TRANSON;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    Mat.Nummer # s_MatNr;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      // Datum im Material merken...
      RecRead(200,1,_recLock);
      Mat.Datum.Lagergeld # s_BisDat;
      Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');

      // Aktion anlegen...
      RecBufClear(204);
      Mat.A.Aktionsmat    # s_MatNr;
      Mat.A.Aktionstyp    # c_Akt_Lagergeld;
      Mat.A.Bemerkung     # c_AktBem_Lagergeld;
      Mat.A.Aktionsdatum  # s_BisDat;
      Mat.A.Terminstart   # s_vonDat;
      Mat.A.Terminende    # s_BisDat;
      Mat.A.Adressnr      # 0;
      //Mat.A.KostenW1      # Rnd(vKosten * s_TTage,2);
      if (s_Gewicht<>0.0) then
        Mat.A.KostenW1      # Rnd(vKosten * s_TTage / s_Gewicht * 1000.0,2);
      //Mat.A.Kostenstelle # ArG.Kostenstelle;
      Mat_a_data:Insert(0,'AUTO')
      if (Mat_A_Data:Vererben('LAGERGELD')=false) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;
    end
    else begin
      "Mat~Nummer" # s_MatNr;
      Erx # RecRead(210,1,0);
      if (Erx<=_rLocked) then begin
        // Datum im Material merken...
        RecRead(210,1,_recLock);
        "Mat~Datum.Lagergeld" # s_BisDat;
        RekReplace(210,_recunlock,'AUTO');
        RecBufCopy(210,200);
        // Aktion anlegen...
        RecBufClear(204);
        Mat.A.Aktionsmat    # s_MatNr;
        Mat.A.Aktionstyp    # c_Akt_Lagergeld;
        Mat.A.Bemerkung     # c_AktBem_Lagergeld;
        Mat.A.Aktionsdatum  # s_BisDat;
        Mat.A.Terminstart   # s_vonDat;
        Mat.A.Terminende    # s_BisDat;
        Mat.A.Adressnr      # 0;
        //Mat.A.KostenW1      # Rnd(vKosten * s_TTage,2);
        if (s_Gewicht<>0.0) then
          Mat.A.KostenW1      # Rnd(vKosten * s_TTage / s_Gewicht * 1000.0,2);
        //Mat.A.Kostenstelle # ArG.Kostenstelle;
        Mat_A_data:Insert(0,'AUTO')
        Mat_A_Abl_Data:Abl_Vererben('LAGERGELD');
      end;
    end;

    // Structure zerstören...
    VarFree(struct_Lagergeld);
  END;

  TRANSOFF;

  // Baum löschen...
  Sort_KillList(vTree);

  // ERFOLG:
  Msg(999998,'',0,0,0);

end;


//========================================================================
//  Zinsen
//
//========================================================================
sub Zinsen();
local begin
  Erx       : int;
  vVon      : date;
  vBis      : date;
  vQ        : alpha(4000);
  vSel      : int;
  vSelName  : alpha;
  vZinsen   : float;
  vTree     : handle;
  vTreeDat  : handle;
  vItem     : handle;
  vSatz     : float;
end;
begin

  if (RunAFX('Mat.Zinsen','')<>0) then RETURN;


  if (Dlg_Standard:DatumVonBis(Translate('Zeitraum'),var vVon, var vBis)=false) then RETURN;
  if (Dlg_Standard:Menge(Translate('Zinssatz in %'),var vSatz)=false) then RETURN;

  if (vVon=0.0.0) then begin
    Msg(1200,Translate('Startdatum'),0,0,0);
    RETURN;
  end;
  if (vBis>today) then begin
    Msg(200020,'',0,0,0);
    RETURN;
  end;


  vTree # CteOpen(_CteTree);      // Rambaum anlegen
  vTreeDat # CteOpen(_CteTree);   // Rambaum anlegen

  // BESTAND-Selektion
//  vQ # '((Mat.Ursprung = 19) or (Mat.Ursprung=20))';
  Lib_Sel:QDate(var vQ, '"Mat.Datum.Erzeugt"', '<=', vBis, 'AND');
  Lib_Sel:QVonBisD(var vQ, '"Mat.Übernahmedatum"', 1.1.1900, vBis);
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '>=', vVon,'AND (');
  Lib_Sel:QDate(var vQ, '"Mat.Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  vQ # vQ + ' AND (Mat.EigenmaterialYN)';

  vSel # SelCreate(200, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(200,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    _CalcZinsen(vSatz, vTree, vTreeDat, var vZinsen, vVon, vBis);
    Erx # RecRead(200,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);


  // ABLAGE-Selektion
  vQ # '';
  Lib_Sel:QVonBisD(var vQ, '"Mat~Übernahmedatum"', 1.1.1900, vBis);
  Lib_Sel:QDate(var vQ, '"Mat~Datum.Erzeugt"', '<=', vBis, 'AND');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '>=', vVon,'AND (');
  Lib_Sel:QDate(var vQ, '"Mat~Ausgangsdatum"', '=', 0.0.0, 'OR');
  vQ # vQ + ')';
  vQ # vQ + ' AND ("Mat~EigenmaterialYN")';

  vSel # SelCreate(210, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(210,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    RecBufCopy(210,200);
    _CalcZinsen(vSatz, vTree, vTreeDat, var vZinsen, vVon, vBis);
    Erx # RecRead(210,vSel,_recNext);
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);


  // LISTE anzeigen ----------------------------------------------------------------

  GV.Int.01 # vTree;
  GV.Num.01 # vSatz;
  Sel.Mat.Von.EDatum # vVon;
  Sel.Mat.Bis.EDatum # vBis;
  Lfm_Ausgabe:Starten('', 200009);

  Erx # Msg(200022,ANum(vZinsen,2),_WinIcoQuestion, _WinDialogYesNo,2);
  if (Erx<>_WinIdYes) then begin
    // Tree durchlaufen und
    FOR   vItem # Sort_ItemFirst(vTree)
    loop  vItem # Sort_ItemNext(vTree,vItem)
    WHILE (vItem != 0) do begin

      // Structure holen...
      VarInstance(struct_Lagergeld, vItem->spID);

      // Structure zerstören...
      VarFree(struct_Lagergeld);
    END;

    // Baum löschen...
    Sort_KillList(vTree);
    Sort_KillList(vTreeDat);

    RETURN;
  end;


  // BUCHEN --------------------------------------------------------------------
  TRANSON;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Structure holen...
    VarInstance(struct_Lagergeld, vItem->spID);

    Mat.Nummer # s_MatNr;
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
      // Datum im Material merken...
      RecRead(200,1,_recLock);
      Mat.Datum.Zinsen # s_BisDat;
      Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');

      // Aktion anlegen...
      RecBufClear(204);
      Mat.A.Aktionsmat    # s_MatNr;
      Mat.A.Aktionstyp    # c_Akt_Zinsen;
      Mat.A.Bemerkung     # c_AktBem_Zinsen;
      Mat.A.Aktionsdatum  # s_BisDat;
      Mat.A.Terminstart   # s_vonDat;
      Mat.A.Terminende    # s_BisDat;
      Mat.A.Adressnr      # 0;
      //Mat.A.KostenW1      # s_TTage;
      if (s_Gewicht<>0.0) then
        Mat.A.KostenW1      # Rnd(s_TTage / s_Gewicht * 1000.0,2);
      //Mat.A.Kostenstelle # ArG.Kostenstelle;
      Mat_a_data:Insert(0,'AUTO')
      if (Mat_A_Data:Vererben()=false) then begin
        TRANSBRK;
        ErrorOutput;
        RETURN;
      end;

    end
    else begin
      "Mat~Nummer" # s_MatNr;
      Erx # RecRead(210,1,0);
      if (Erx<=_rLocked) then begin
        // Datum im Material merken...
        RecRead(210,1,_recLock);
        "Mat~Datum.Zinsen" # s_BisDat;
        RekReplace(210,_recunlock,'AUTO');
        RecBufCopy(210,200);
        // Aktion anlegen...
        RecBufClear(204);
        Mat.A.Aktionsmat    # s_MatNr;
        Mat.A.Aktionstyp    # c_Akt_Zinsen;
        Mat.A.Bemerkung     # c_AktBem_Zinsen;
        Mat.A.Aktionsdatum  # s_BisDat;
        Mat.A.Terminstart   # s_vonDat;
        Mat.A.Terminende    # s_BisDat;
        Mat.A.Adressnr      # 0;
        //Mat.A.KostenW1      # s_TTage;
        if (s_Gewicht<>0.0) then
          Mat.A.KostenW1      # Rnd(s_TTage / s_Gewicht * 1000.0,2);
        //Mat.A.Kostenstelle # ArG.Kostenstelle;
        Mat_A_Data:Insert(0,'AUTO')
        Mat_A_Abl_Data:Abl_Vererben();
      end;
    end;

    // Structure zerstören...
    VarFree(struct_Lagergeld);
  END;

  // Tree durchlaufen und Datum setzen
  FOR   vItem # Sort_ItemFirst(vTreeDat)
  loop  vItem # Sort_ItemNext(vTreeDat,vItem)
  WHILE (vItem != 0) do begin
    Mat.Nummer # cnvia(vItem->spName);
    Erx # RecRead(200,1,0);
    if (Erx<=_rLocked) then begin
        RecRead(200,1,_recLock);
        Mat.Datum.Zinsen # cnvda(vItem->spcustom)
        Mat_data:Replace(_recunlock,'AUTO');  // 26.08.2014 war RekReplace(200,_RecUnlock,'AUTO');
    end
    else begin
      "Mat~Nummer" # cnvia(vItem->spName);
      Erx # RecRead(210,1,0);
      if (Erx<=_rLocked) then begin
        RecRead(210,1,_recLock);
        "Mat~Datum.Zinsen" # cnvda(vItem->spcustom)
        RekReplace(210,_recUnlock,'AUTO');
      end;
    end;
  END;

  TRANSOFF;

  // Baum löschen...
  Sort_KillList(vTree);
  Sort_KillList(vTreeDat);

  // ERFOLG:
  Msg(999998,'',0,0,0);


//TODO('Zinsen');
end;


//========================================================================
//
//========================================================================
sub Verschrotten(
  aMitUmlage          : logic;
  aGrund              : alpha(200);
  opt aStatus         : int;
  opt aAktNr          : int;
  opt aAktPos         : int;
  opt aAktPos2        : int;
  opt aBemerkung      : alpha(200)
  ) : logic;
local begin
  Erx                 : int;
  vMitNachfolger      : logic;

  vMat                : int;
  vNrSchrott          : int;

  vGewichtEntstanden  : float;
  vMengeEntstanden    : float;
  vMatWertGesamt      : float;
  vMatWertGesamtPM    : float;
  vSchrottumlage      : float;
  vSchrottumlagePM    : float;
  vMatEK              : float;
  vMatEKPM            : float;
  vDat                : date;
  vTim                : time;
  vBuf204             : int;
  vIstGew             : float;
  vIstStk             : int;
  vIstMenge           : float;
end;
begin

  vDat                # today;
  vTim                # now;
  vMat                # Mat.Nummer;
  vMatEK              # Mat.EK.Effektiv;
  vMatEKPM            # Mat.EK.EffektivProME;
  vMatWertGesamt      # Mat.Bestand.Gew / 1000.0 * vMatEK;
  vMatWertGesamtPM    # Mat.Bestand.Menge * vMatEKPM;
  vIstGew             # Mat.Bestand.Gew;
  vIstStk             # Mat.Bestand.Stk;
  vIstMenge           # Mat.Bestand.Menge;


  if (aMitUmlage) then begin
    FOR Erx # RecLink(204, 200, 14, _recFirst)  // Material Aktionen loopen
    LOOP Erx # RecLink(204, 200, 14, _recNext)
    WHILE (Erx <= _rLocked) DO BEGIN
      if (Mat.A.Entstanden = 0) or (Mat.A.Entstanden = Mat.Nummer) or (Mat.A.Aktionsdatum<vDat) then CYCLE;

      vMitNachfolger # y;
      BREAK;
    END;
  end;


  TRANSON;


  PtD_Main:Memorize(200);

  // alle vorhandenen Reservierugen löschen
  WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
    if (Mat_Rsv_data:Entfernen()=false) then begin
      TRANSBRK;
      APPON();
      PtD_Main:Forget(200);
      Error(702012,'1010');
      RETURN false;
    end;
  END;

  RecRead(200,1,_recLock);

  if (vMitNachfolger=false) and (aStatus<>0) then Mat_Data:SetStatus(aStatus);

  Mat_Data:SetLoeschmarker('*', aGrund);
  Mat.Kommission    # '';
  Mat.Auftragsnr    # 0;
  Mat.Auftragspos   # 0;
  Mat.Auftragspos2  # 0;
  Mat.KommKundennr  # 0;

  Mat.Ausgangsdatum # vDat;
  Erx # Mat_data:Replace(_RecUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    PtD_Main:Forget(200);
    RETURN false;
  end;

  // keine Kosten umlegen??
  if (aMitUmlage=false) then begin
    PtD_Main:Compare(200);
    TRANSOFF;
    RETURN true;
  end;


  APPOFF();

  // Umlagekosten errechnen....
  FOR Erx # RecLink(204, 200, 14, _recFirst)  // Material Aktionen loopen
  LOOP Erx # RecLink(204, 200, 14, _recNext)
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Mat.A.Entstanden = 0) or (Mat.A.Materialnr <> Mat.Nummer) then begin // entstandenes Material?
      CYCLE;
    end;

    Mat.Nummer # Mat.A.Entstanden;
    Erx # RecRead(200, 1, 0); // Material lesen
    if (Erx > _rLocked) then RecBufClear(200);
    vGewichtEntstanden  # vGewichtEntstanden + Mat.Bestand.Gew;
    vMengeEntstanden    # vMengeEntstanden + Mat.Bestand.Menge;
    Mat.Nummer # vMat;
    RecRead(200,1,0);
  END;

  if (vGewichtEntstanden <> 0.0) then
    vSchrottumlage # vMatWertGesamt / (vGewichtEntstanden / 1000.0);

  if (vMengeEntstanden <> 0.0) then
    vSchrottumlagePM # vMatWertGesamtPM / vMengeEntstanden;




  if (vMitNachfolger) then begin
    vNrSchrott # Lib_Nummern:ReadNummer('Material');
    if (vNrSchrott<>0) then begin
      Lib_Nummern:SaveNummer()
    end
    else begin
      TRANSBRK;
      PtD_Main:Forget(200);
      APPON();
      RETURN false;
    end;

    // neue Schrottkarte anlegen...
    Mat.Nummer        # vNrSchrott;;
    "Mat.Vorgänger"   # vMat;

//    Mat_Data:SetStatus(c_Status_ManuellerSchrott);
    if (aStatus<>0) then Mat_Data:SetStatus(aStatus)
    else Mat_Data:SetStatus(c_Status_ManuellerSchrott);

    Mat_Data:SetLoeschmarker('*', aGrund);
    Mat.Ausgangsdatum     # vDat;
    Mat.Kosten            # -Mat.EK.Preis;
    Mat.KostenProMEH      # -Mat.EK.PreisProMEH;
    Mat.EK.Effektiv       # 0.0;
    Mat.EK.EffektivProME  # 0.0;
    Erx # Mat_Data:Insert(0,'AUTO', vDat);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      PtD_Main:Forget(200);
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;

    // NULLUNG-Aktionen anlegen
    RecBufClear(204);
    Mat.A.Aktionsmat      # Mat.Nummer;
    Mat.A.Aktionstyp      # c_Akt_Mat_Umlage;
    Mat.A.Aktionsdatum    # vDat;
    Mat.A.Bemerkung       # c_AktBem_Mat_Schrott;
// war 1
    Mat.A.Kosten2W1        # vMatEK * -1.0;
    Mat.A.Kosten2W1ProME  # vMatEKPM * -1.0;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      PtD_Main:Forget(200);
      APPON();
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;

    // Mutterkarte wieder holen...
    // AF kopieren
    Mat.Nummer  # vMat;
    RecRead(200,1,0);
    if (Mat_Data:CopyAF(vNrSchrott)=false) then begin
      TRANSBRK;
      PtD_Main:Forget(200);
      APPON();
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;

    // Mutterkarte wieder holen...
    Mat.Nummer  # vMat;
    RecRead(200,1,_recLock);

    // Mutterkarte selber löschen...
    Mat_Data:Bestandsbuch(-vIstStk, -vIstGew, -vIstMenge, 0.0, 0.0, c_AktBem_Schrott, vDat, vTim, c_Akt_Schrott,0,0);

    Mat.Gewicht.Netto   # 0.0;
    Mat.Gewicht.Brutto  # 0.0;
    Mat.Bestand.Stk     # 0;
    Mat.Bestand.Gew     # 0.0;
    Mat.Bestand.Menge   # 0.0;
    Erx # Mat_Data:Replace(_recunlock,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      PtD_Main:Forget(200);
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;
  end;



  PtD_Main:Compare(200);



  // Kosten umlagern...
  FOR Erx # RecLink(204, 200, 14, _recFirst)  // Material Aktionen loopen
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (Erx <= _rLocked) DO BEGIN

    if (Mat.A.Entstanden=0) or (Mat.A.Entstanden=vMat) or (vNrSchrott=Mat.A.Entstanden) then
      CYCLE; // entstandenes Material?

    Mat.Nummer # Mat.A.Entstanden;
    RecRead(200,1,0);

    vBuf204 # RekSave(204);

    // Aktionen anlegen
    RecBufClear(204);
    Mat.A.Aktionsmat      # Mat.Nummer;
    Mat.A.Aktionstyp      # c_Akt_Mat_Umlage;
    Mat.A.Aktionsdatum    # vDat;
    Mat.A.Bemerkung       # c_AktBem_BA_Umlage;
    Mat.A.KostenW1        # vSchrottumlage;
    Mat.A.KostenW1ProMEH  # vSchrottUmlagePM;
    Mat.A.Gewicht         # 0.0;
    Mat.A.Nettogewicht    # 0.0;
    Mat.A.Menge           # 0.0;
    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;

    if (Mat_A_Data:Vererben() = false) then begin
      TRANSBRK;
      APPON();
      ErrorOutput;
      RETURN false;
    end;

    RekRestore(vBuf204);

    Mat.Nummer # vMat;
    RecRead(200,1,0);
  END;



  // Materialaktion für Schrottkarte anlegen...
  if (vNrSchrott<>0) then begin
    RecBufClear(204);
    Mat.A.Aktionsmat    # Mat.Nummer;
    Mat.A.Entstanden    # vNrSchrott;
    Mat.A.Aktionstyp    # c_Akt_Schrott;
    Mat.A.Aktionsdatum  # vDat;

    Mat.A.Aktionsnr     # aAktNr;
    Mat.A.AktionsPos    # aAktPos;
    Mat.A.AktionsPos2   # aAktPos2;
    if (aBemerkung<>'') then
      Mat.A.Bemerkung     # aBemerkung
    else
      Mat.A.Bemerkung     # c_AktBem_Schrott;

    Erx # Mat_A_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Msg(1000+Erx,'',0,0,0);
      RETURN false;
    end;
  end;

  TRANSOFF;

  APPON();

  RETURN true;
end;


//========================================================================
//  RecDel
//          Karte manuell löschen/entlöschen
//========================================================================
sub RecDel(
  aSilent : logic;
  aNullen : logic)
local begin
  Erx                 : int;
  vI                  : int;
  vGewichtEntstanden  : float;
  vMengeEntstanden    : float;
  vMatWertGesamt      : float;
  vMatWertGesamtPM    : float;
  vSchrottumlage      : float;
  vSchrottumlagePM    : float;
  vMatEK              : float;
  vMatEKPM            : float;
  vMat                : int;
  vMatSchrott         : int;
  vBuf204             : int;
  vGrund              : alpha;
end;
begin

  vMat # Mat.Nummer;


  // Diesen Eintrag wieder aktivieren?
  if ("Mat.Löschmarker"='*') then begin
    if !(aSilent) then
      if (Msg(200013,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;
    PtD_Main:Memorize(200);
    RecRead(200,1,_recLock);
    Mat_Data:SetLoeschmarker('');
    Mat.Ausgangsdatum # 0.0.0;
    Mat_data:Replace(_RecUnlock,'MAN');
    PtD_Main:Compare(200);
    RETURN;
  end;



  Erx # RecLinkInfo(203, 200 , 13, _recCount) // MS 09.07.2009 Reservierung auf Material?
  if (Erx > 0) then begin
    Msg(200009, '', 0, 0, 0);
    RETURN;
  end;

  vMatEK              # Mat.EK.Effektiv;
  vMatEKPM            # Mat.EK.EffektivProME;
  vMatWertGesamt      # Mat.Bestand.Gew / 1000.0 * vMatEK;
  vMatWertGesamtPM    # Mat.Bestand.Menge * vMatEKPM;
  vGewichtEntstanden  # 0.0;

  Erx # RecLink(204, 200, 14, _recFirst); // Material Aktionen loopen
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Mat.A.Entstanden = 0) or (Mat.A.Materialnr <> Mat.Nummer) then begin // entstandenes Material?
      Erx # RecLink(204, 200, 14, _recNext);
      CYCLE;
    end;

    Mat.Nummer # Mat.A.Entstanden;
    Erx # RecRead(200, 1, 0); // Material lesen
    if (Erx > _rLocked) then RecBufClear(200);
    vGewichtEntstanden  # vGewichtEntstanden + Mat.Bestand.Gew;
    vMengeEntstanden    # vMengeEntstanden + Mat.Bestand.Menge;
    Mat.Nummer # vMat;
    RecRead(200,1,0);

    Erx # RecLink(204, 200, 14, _recNext);
  END;

  if (vGewichtEntstanden <> 0.0) then
    vSchrottumlage # vMatWertGesamt / (vGewichtEntstanden / 1000.0);

  if (vMengeEntstanden <> 0.0) then
    vSchrottumlagePM # vMatWertGesamtPM / vMengeEntstanden;

  // hat die Karte noch Wert??
  vI # _WinIdNo;
  if ((vMatWertGesamt<>0.0) and (vGewichtEntstanden<>0.0)) or
    ((vMatWertGesamtPM<>0.0) and (vMengeEntstanden<>0.0)) then begin
    if (!aSilent) then
      vI # Msg(200015,'',_WinIcoQuestion,_WinDialogYesNoCancel,2)
    else begin
      if (aNullen) then
        vI # _WinIdYes
      else
        vI # _WinIdNo;
    end;
    if (vI=_winIdCancel) then RETURN;
  end
  else begin
    // Diesen Eintrag wirklich löschen?
    if !(aSilent) then
      if (Msg(200012,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN;
  end;

  if (aSilent=false) then begin
    REPEAT
      if (Dlg_Standard:Standard(Translate('Grund'),var vGrund,n,32)=false) then RETURN;
    UNTIL (vGrund<>'');
  end;


  Verschrotten(vI=_winidyes, vGrund);
/**** 09.07.2015
  // keine Kosten umlegen...
  if (vI = _WinIdNo) then begin
    PtD_Main:Memorize(200);
    RecRead(200,1,_recLock);
    Mat_Data:SetLoeschmarker('*', vGrund);
    Mat.Ausgangsdatum # today;
    Mat_data:Replace(_RecUnlock,'MAN');
    PtD_Main:Compare(200);
    RETURN;
  end;


  TRANSON;

  vMatSchrott # Lib_Nummern:ReadNummer('Material');
  if (vMatSchrott<>0) then begin
    Lib_Nummern:SaveNummer()
  end
  else begin
    TRANSBRK;
    RETURN;
  end;

  APPOFF();

  Mat.Nummer        # vMatSchrott;;
  "Mat.Vorgänger"   # vMat;

  // Schrottkarte setzen
  Mat_Data:SetStatus(c_Status_ManuellerSchrott);
  Mat_Data:SetLoeschmarker('*', vGrund);
  Mat.Ausgangsdatum     # today;
  Mat.Kosten            # -Mat.EK.Preis;
  Mat.KostenProMEH      # -Mat.EK.PreisProMEH;
  Mat.EK.Effektiv       # 0.0;
  Mat.EK.EffektivProME  # 0.0;
  Erx # Mat_Data:Insert(0,'AUTO', today);
  if (erx<>_rOK) then begin
    TRANSBRK;
    APPON();
    Msg(1000+Erx,'',0,0,0);
    RETURN;
  end;

  // NULLUN-Aktionen anlegen
  RecBufClear(204);
  Mat.A.Aktionsmat      # Mat.Nummer;
//debug('nulle:'+aint(mat.a.aktionsmat));
  Mat.A.Aktionstyp      # c_Akt_Mat_Umlage;
  Mat.A.Aktionsdatum    # today;
  Mat.A.Bemerkung       # c_AktBem_Mat_Schrott;
  Mat.A.KostenW1        # vMatEK * -1.0;
  Mat.A.KostenW1ProMEH  # vMatEKPM * -1.0;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    APPON();
    Msg(1000+Erx,'',0,0,0);
    RETURN;
  end;

  // AF kopieren
  Mat.Nummer  # vMat;
  RecRead(200,1,0);
  if (Mat_Data:CopyAF(vMatSchrott)=false) then begin
    TRANSBRK;
    APPON();
    Msg(1000+Erx,'',0,0,0);
    RETURN;
  end;


  // Mutterkarte wieder holen...
  Mat.Nummer  # vMat;
  RecRead(200,1,0);

  // Mutterkarte selber löschen...
  Mat_Data:Bestandsbuch(-Mat.Bestand.Stk, -Mat.Bestand.Gew, -Mat.Bestand.Menge, 0.0, 0.0, c_AktBem_Schrott, today, c_Akt_Schrott,0,0);
  PtD_Main:Memorize(200);

  RecRead(200,1,_recLock);
  Mat.Gewicht.Netto   # 0.0;
  Mat.Gewicht.Brutto  # 0.0;
  Mat.Bestand.Stk     # 0;
  Mat.Bestand.Gew     # 0.0;
  Mat.Bestand.Menge   # 0.0;
  Mat_Data:SetLoeschmarker('*', vGrund);
  Mat.Ausgangsdatum # today;
  Mat_data:Replace(_RecUnlock,'MAN');
  PtD_Main:Compare(200);

  // Kosten umlagern...
  Erx # RecLink(204, 200, 14, _recFirst); // Material Aktionen loopen
  WHILE (Erx <= _rLocked) DO BEGIN

    if (Mat.A.Entstanden<>0) and (Mat.A.Entstanden<>vMat) then begin // entstandenes Material?
      Mat.Nummer # Mat.A.Entstanden;
      RecRead(200,1,0);

      vBuf204 # RekSave(204);

      // Aktionen anlegen
      RecBufClear(204);
      Mat.A.Aktionsmat      # Mat.Nummer;
      Mat.A.Aktionstyp      # c_Akt_Mat_Umlage;
      Mat.A.Aktionsdatum    # today;
      Mat.A.Bemerkung       # c_AktBem_BA_Umlage;
      Mat.A.KostenW1        # vSchrottumlage;
      Mat.A.KostenW1ProMEH  # vSchrottUmlagePM;
      Mat.A.Gewicht         # 0.0;
      Mat.A.Nettogewicht    # 0.0;
      Mat.A.Menge           # 0.0;
      Erx # Mat_A_Data:Insert(0,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        APPON();
        Msg(1000+Erx,'',0,0,0);
        RETURN;
      end;

      if (Mat_A_Data:Vererben() = false) then begin
        TRANSBRK;
        APPON();
        ErrorOutput;
        RETURN;
      end;

      RekRestore(vBuf204);

      Mat.Nummer # vMat;
      RecRead(200,1,0);
    end;

    Erx # RecLink(204,200,14,_recNext);
  END;


  // Materialaktion für Schrottkarte anlegen...
  RecBufClear(204);
  Mat.A.Aktionsmat    # Mat.Nummer;
//debug('Mutter->Schrott:'+aint(mat.a.aktionsmat));
  Mat.A.Entstanden    # vMatSchrott;
  Mat.A.Aktionstyp    # c_Akt_Schrott;
  Mat.A.Aktionsdatum  # today;
  Mat.A.Bemerkung     # c_AktBem_Schrott;
  Erx # Mat_A_Data:Insert(0,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    APPON();
    Msg(1000+Erx,'',0,0,0);
    RETURN;
  end;

  TRANSOFF;

  APPON();
***/
end;


//========================================================================
//  AFX UmlagernScanner_LP()
//    Läd ein Datenfile vom Scanner und führt die darin gespeicherten
//    Umlagerungen durch:
//    pro Lagerplatz können mehrere Materialien gescannt werden!
//========================================================================
sub UmlagernScanner_LP(aPara : alpha):int
local begin
  erx       : int;
  vPathData : alpha;    // Pfad zum Applikationsordner des Scannertools
  vPathEXE  : alpha;    // Pfad zur Exe
  vFlags    : alpha;    // Flags zur Programmausführung
  vTxt      : int;      // Filedeskriptor für die Inputdatei
  vLine     : alpha;    // Datenpuffer für eingelesene Zeile
  vDone     : logic;    // Merker für Dateiende
  vCheck    : float;    // Prüfsumme
  vMat      : alpha;    // temporäre Materialnummer
  vLp       : alpha;    // temporärer Lagerplatz
  vFehler   : int;      // Fehlerzähler
end;
begin

  // Pfad zur Exe zusammenbauen
  vPathEXE  # Set.BcsScanner.Pfad + 'Data_Read.Exe';

  // Daten in Datenverzeichnis mit Username ablegen
  vPathData # Set.BcsScanner.Pfad + 'Data\'+UserInfo(_UserName,UserID(_UserCurrent))+'.txt';

  // Flagstring für "Data_read.exe"
  vFlags  # vPathData+',1,'+CnvAi(Set.BCScanner.Port)+',1,1,1,1,1,0,0,0,2,2';

  if(Set.BCScanner.Port = 0) then
    vFlags # '';

  // Scannerprogramm ausführen
  if (SysExecute('*'+vPathEXE,vFlags,_ExecWait) = _ErrOK) then begin

    // Prüfen, ob die Datei gelesen wurde und Daten enthält
    vTxt # FsiOpen(vPathData,_FsiStdRead);
    if (vTxt > 0) then begin

      // Datei offen und fertig zum einlesen

      /*
          Beispielinhalt für die Std. Umlagerungsdatei:
          -------------------
            ULP_12
            UMT_19785
            UMT_12185
            ULP_18
            UMT_19997
            UMT_12200

          Die Zeilen sind mit CR LF getrennt
      */


      // Datei bis zum Ende einlesen
      WHILE (true) DO BEGIN
        FsiMark(vTxt,10); // LF als Zeilentrenner
        if (FsiRead(vTxt,vLine) <= 0) then
          break;    // Ende der Datei, Einlesen abschließen

        // Lagerplatz gefunden?
        if (StrFind(vLine,'ULP_',1) > 0) then
          vLP # StrCut(vLine,5,StrLen(vLine)-5);

        // Material gefunden?
        if (StrFind(vLine,'UMT_',1) > 0) then
          vMat # StrCut(vLine,5,StrLen(vLine)-5);

        // Lagerplatz lesen
        if(vLP <> '') then begin // wenn Lagerplatz Variable gefuellt
          Lpl.Lagerplatz # vLP;
          Erx # RecRead(844, 1, 0);
          if (Erx <= _rLocked) then begin
            vLP # ''; // Lagerplatz leeren (bereits gescannt)
            CYCLE;    // naechsten Datensatz in Scannerdatei lesen (normal Material)
          end
          else begin
            // Der gescannte Lagerplatz ist nicht mehr existent
            Msg(844017,vLp,_WinIcoInformation,_WinDialogOk,1);
            vFehler # vFehler + 1;
          end;
        end;

        // Lagerplatz ist vorhanden...
        // ...dann Material lesen
        Mat.Nummer # CnvIA(vMat);
        begin // ST 2010-06-18: Inventurdaten werden jetzt zentral gesetzt
          if (!Mat_Data:SetInventur(Mat.Nummer, Lpl.Lagerplatz, Mat.Inventurdatum, false)) then begin
            // Material xyz konnte nicht gefunden oder gesperrt werden
            Msg(844016 ,vMat,_WinIcoInformation,_WinDialogOk,1);
            vFehler # vFehler + 1;
          end;
        end;

        // Temporäre Daten für den nächsten Datensatz leeren
        vMat   # '';
      END;  // Nächste Zeile

      FsiClose(vTxt);

      // Vor dem Einlesen löschen
      if (vFehler = 0) then
        FsiDelete(vPathData);
    end
    else begin
      //  Datei wurde nicht erstellt oder geöffnet werden
      Msg(844010 ,'',_WinIcoInformation,_WinDialogOk,1);
      vFehler # vFehler + 1;
    end;
  end
  else begin
    // Programm konnte nicht gestartet werden
    Msg(844009 ,'',_WinIcoInformation,_WinDialogOk,1);
    vFehler # vFehler + 1;
  end;


  if (vFehler = 0) then
    return 9;
  else
    return 1;


end;


//========================================================================
//   sub ZeigeAlibidaten() : int
//
//    Zeigt für die selektierte Materialkarte die in der Verwiegung
//    hinterlegten Waagendaten an
//========================================================================
sub ZeigeAlibidaten() : int
local begin
  vTxt  : alpha(500);
end;
begin

  RecRead(200,1,0);

  // Vewiegung lesen
  RekLink(707,200,28,0);
  if (Bag.FM.Nummer = 0) then begin
    Msg(99,'Keine Fertigmeldung gefunden!',_WinIcoWarning,_WinDialogOk,1);
    RETURN 0;
  end;


  // Daten anzeigen
  vTxt #  'Daten aus '                                        + StrChar(10) +
          'Fertigmeldung: ' + Aint(BAG.FM.Nummer)     + '/ ' +
                              Aint(BAG.FM.Position)   + '/ ' +
                              Aint(BAG.FM.Fertigung)  + '/ ' +
                              Aint(BAG.FM.Fertigmeldung)      + StrChar(10) +
          '--------------------------------'                  + StrChar(10) +
          BAG.FM.Waagedaten1                    + StrChar(10) +
          BAG.FM.Waagedaten2                    + StrChar(10) +
          BAG.FM.Waagedaten3                    + StrChar(10) +
          BAG.FM.Waagedaten4                    + StrChar(10) +
          BAG.FM.Waagedaten5;

  Msg(99,vTxt,_WinIcoInformation,_WinDialogOk,0);
  RETURN 1;
end;


/*========================================================================
2023-01-09  AH
          Selektiert nur dieses Paket
========================================================================*/
sub SelPaket();
local begin
  Erx : int;
end;
begin

  if (gZLList=0) then RETURN;

  if (gZLList->wpdbselection<>0) then begin
    Sel_Main:Filter_Stop(gZLList->wpdbrecid);
    RETURN;
  end;

  Erx # RecRead(gFile,0,0,gZLList->wpdbrecid);
  if (Erx>_rLocked) then RETURN;

  Mat_Mark_Sel:DefaultSelection()
  Sel.Mat.PaketNr        # Mat.Paketnr;

  Mat_Mark_Sel:StartSel(true);
end;


//========================================================================