@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_MAT_Etikett
//                        OHNE E_R_G
//  Info
//    Druckt ein Materialetikett
//
//
//  16.07.2007  ST Erstellung der Prozedur
//  27.02.2015  Dialog zum Ändern der Etikettendaten ausgebaut,
//              Globale Variablen für Anzahleingabe gepuffert
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//
//========================================================================

@I:Def_Global


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(Mat.Nummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  // Datenspezifische Variablen
  vErg,i            : int;
  vHdl            : int;       // Descriptor für Textfelder d. Ausgabe Elementes
  vPrt            : int;        // Descriptor für Ausgabe Elemende
  vHeader         : int;
  vFooter         : int;
  vAnzahl         : int;
  vID             : int;
  vBuf200         : int;
  vBuf999         : int;
end;
begin

// ------ Druck vorbereiten ----------------------------------------------------------------

  // GGf. Maske anzeigen
  if (gUserGroup <> 'BETRIEB') AND (gUsergroup<>'MC9090') and
      (gUserGroup <> 'BETRIEB_TS') then  begin
/*
    vHdl # WinOpen('Dlg.Etikett.Material',_WinOpenDialog);
    if (vHdl != 0) then begin
      vId # vHdl->WinDialogRun(_WinDialogCenter);
      vHdl->WinClose();

      if (vId = _WinIdCancel) then
        RETURN;
    end;

*/
    // Etikettenanzahlabfrage
    RecRead(912,1,0);         // Formulare lesen
                              // Anzahl = Anzahl der Kopien
    vBuf200 # RekSave(200);
    vBuf999 # RekSave(999);

    if (Dlg_Standard:Anzahl('Anzahl Etk',var vAnzahl,Frm.Kopien)=false) then begin
      RekRestore(vBuf200);
      RekRestore(vBuf999);
      RETURN;
    end;
    RekRestore(vBuf999);
    RekRestore(vBuf200);

  end;


  if (vAnzahl <= 0) then
    vAnzahl # 1;


  // Start des Druckes
  FOR i # 0 LOOP inc(i) WHILE (i < vAnzahl) DO BEGIN

    if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_EtikettA5querAufA4Hoch', 'FALSE') < 0) then begin
      RETURN;
    end;


    Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

    form_RandOben   # 0.0;
    form_RandUnten  # 0;


    vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.Material');
    Lib_Print:LfPrint(vPrt);


    // Sofortdruck für Betriebsuser?
    if (Lib_Strings:Strings_Count(gUsergroup,'BETRIEB') > 0) then
      Lib_Print:FrmJobClose(true)  // FALSE für Sofortdruck
    else
      Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");

  END;


end;


//========================================================================
//  EvtInit
//
//========================================================================
Sub EvtInit(
  aEvt  : event;
) : logic
begin
   $edGV.Alpha.01->WinFocusSet(true);
end;


//========================================================================
//  EvtMouse
//
//========================================================================
sub EvtMouse(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Button
) : logic
local begin
  vFld      : int;
  vFldType  : int;
  vHdl      : int;
end;
begin

  if (gUsergroup <> 'BETRIEB_TS') then
    RETURN true;

  // Für Betriebsuser mit Touchscreen die Bildschirmeingaben aktivieren
  vFldType # aEvt:Obj->WinInfo(_WinType);
  vFld     # aEvt:Obj;

  // Je Nach Feldtyp Buchstaben oder Num Tastatur öffnen
  case vFldType of
    _winTypeEdit,
    _WinTypeTextEdit    : begin
                            g_sSelected # vFld->wpCaption;
                            vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur'),_WinOpenDialog);
                          end;

    _WinTypeDecimalEdit:  begin
                            g_sSelected # CnvAM(vFld->wpCaptionDecimal);
                            vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur.Num'),_WinOpenDialog);
                          end;

    _winTypeFloatEdit:    begin
                            g_sSelected # CnvAF(vFld->wpCaptionFloat);
                            vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur.Num'),_WinOpenDialog);
                          end;

    _winTypeIntEdit:      begin
                            g_sSelected # CnvAI(vFld->wpCaptionInt);
                            vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur.Num'),_WinOpenDialog);
                          end;

    _WinTypeBigIntEdit :  begin
                            g_sSelected # CnvAB(vFld->wpCaptionBigInt);
                            vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('Mdi.Tastatur.Num'),_WinOpenDialog);
                          end;

    _WinTypeDateEdit,
    _WinTypeTimeEdit :    begin
                            todo('Time- und Dateedit für Usergrp BETRIEB_TS');
                          end;
  end; // EO Case


  // Dialog anzeigen
  vHdl->wpCaption # vFld->wpCustom;

  vHdl->WinDialogRun(_WinDialogCenter);
  vHdl->WinClose();
  if (g_sSelected <> '') then begin

    case vFldType of
      _winTypeEdit,
      _WinTypeTextEdit    : vFld->wpCaption # g_sSelected;
      _WinTypeDecimalEdit : vFld->wpCaptionDecimal # CnvMa(g_sSelected);
      _winTypeFloatEdit   : vFld->wpCaptionFloat # CnvFa(g_sSelected);
      _winTypeIntEdit     : vFld->wpCaptionInt # CnvIa(g_sSelected);
      _WinTypeBigIntEdit  : vFld->wpCaptionBigInt # CnvBa(g_sSelected);

      _WinTypeDateEdit ,
      _WinTypeTimeEdit :  begin
                              todo('Time- und Dateedit für Usergrp BETRIEB_TS');
                            end;
    end; // EO Case

    g_sSelected # '';
  end; // EO (g_sSelected <> '') then begin


end;





//========================================================================
