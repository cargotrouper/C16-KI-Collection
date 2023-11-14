@A+
//===== Business-Control =================================================
//
//  Prozedur    Calc_Main
//                OHNE E_R_G
//  Info
//
//
//  18.02.2009  TM  Erstellung der Prozedur
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtMdiActivate(aEvt : event) : logic
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB EvtFocusTerm(aEvt : event; aFocusObject : int) : logic
//    SUB EvtClicked(aEvt : event) : logic
//
//========================================================================
@I:Def_global

define begin
  cMDI    :   $Mdi.Coilculator

  gD      :   Gv.Num.01
  gB      :   Gv.Num.02
  gL      :   Gv.Num.03
  gRID    :   Gv.Num.04
  gRAD    :   Gv.Num.05
  gAH     :   Gv.Num.06
  gDichte :   Gv.Num.07
  gkgmm   :   Gv.Num.08
  gStk    :   Gv.Num.09
  gGew    :   Gv.Num.10
  gStkGew :   Gv.Num.11
  gTlg    :   Gv.Num.12
  gTraene :   Gv.Num.13

  cTitle      : 'Coilculator'
  cFile       :  0
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : ''
  cZList      : 0
  cKey        : 0
end;


//========================================================================
// EvtInit
//          Initialisieren der Tastatur
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  gDichte   # 7.85;

  $edGew->wpDecimals # Set.STellen.Gewicht;
  $edStkGew->wpDecimals # Set.STellen.Gewicht;
  App_Main:EvtInit(aEvt);
end;


//========================================================================
// EvtMdiActivate
//
//========================================================================
sub EvtMdiActivate(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  gFrmMain->wpMenuname # Lib_GuiCom:GetAlternativeName('Mdi.Coilculator');
  RETURN(true);
end;


//========================================================================
// EvtFocusInit
//
//========================================================================
sub EvtFocusInit(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus zuvor hatte
) : logic;
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  RETURN(true);
end;


//========================================================================
// EvtFocusTerm
//
//========================================================================
sub EvtFocusTerm(
  aEvt                 : event;    // Ereignis
  aFocusObject         : int;      // Objekt, das den Fokus bekommt
) : logic;
begin

  case (aEvt:obj->wpname) of

    'edTlg' : begin

      If (aEvt:obj->wpchanged) then begin

        If ((gGew <> 0.0) and (gStk <> 0.0) and (gB <> 0.0) and (gDichte <> 0.0) and (gRID <> 0.0)) then begin
          gRAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(gGew,cnvIF(gStk),gB,gDichte,gRID,cnvIF(gTlg));
        End;


        gStk # gStk * (gTlg +1.0);
        gTlg # 0.0;

        $edRAD->wpColBkg # _WinColLightYellow;
        $edStk->wpColBkg # _WinColLightYellow;

        cMDI->Winupdate(_WinUpdFld2Obj);
      End;

    end;

  end;

  RETURN(true);
end;

//========================================================================
// EvtClicked
//
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  case (aEvt:obj->wpname) of

    // ---- RESET ----
    'bt.Reset' : begin

      gD      # 0.0;
      gB      # 0.0;
      gL      # 0.0;
      gRID    # 0.0;
      gRAD    # 0.0;
      gAH     # 0.0;
      gDichte # 0.0;
      gkgmm   # 0.0;
      gStk    # 0.0;
      gGew    # 0.0;
      gStkGew # 0.0;
      gTlg    # 0.0;
      gTraene # 0.0;

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

    end;


    // ---- LÄNGE ----
    'bt.Laenge' : begin

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If (gGew    = 0.0) then begin $edGew->wpColBkg    # _WinColLightYellow end;
      If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;
      If (gD      = 0.0) then begin $edDicke->wpColBkg  # _WinColLightYellow end;
      If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
      If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;

      // -- Länge aus Gewicht, Stück, Dicke, Breite und Dichte
      gL # Lib_Berechnungen:L_aus_KgStkDBDichte2(gGew,cnvIF(gStk),gD,gB,gDichte,gTraene);

    end;
    //====================================================================

    // ---- KG PRO MM BANDBREITE ----
    'bt.kgmm' : begin

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;
      If (gRID    = 0.0) then begin $edRID->wpColBkg    # _WinColLightYellow end;
      If (gRAD    = 0.0) then begin $edRAD->wpColBkg    # _WinColLightYellow end;

      // -- kg/mm aus Dichte, RID und RAD

       If gTraene <> 0.0 then begin
         Msg(997000,Translate('Coilculator'),0,0,0);
         gTraene # 0.0;
         cMDI->Winupdate(_WinUpdFld2Obj);
         RETURN(true);
       End;

      If gDichte <> 0.0 and gRID <> 0.0 and gRAD <> 0.0 then begin
        gkgmm # Lib_Berechnungen:Kgmm_aus_DichteRIDRAD(gDichte,gRID,gRAD);
      end;

    end;

    // ---- AUSSENDURCHMESSER ----
    'bt.RAD' : begin

      // -- RAD aus Gewicht, Stück, Breite, Dichte und RID


      If gTraene <> 0.0 then begin
        Msg(997000,Translate('Coilculator'),0,0,0);
        gTraene # 0.0;
        cMDI->Winupdate(_WinUpdFld2Obj);
        RETURN(true);
      End;

        If ((gGew <> 0.0) and (gStk <> 0.0) and (gB <> 0.0) and (gDichte <> 0.0) and (gRID <> 0.0)) then begin
          gRAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRIDTlg(gGew,cnvIF(gStk),gB,gDichte,gRID,cnvIF(gTlg));
        End;



      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If (gRAD = 0.0) then begin
        If (gGew    = 0.0) then begin $edGew->wpColBkg    # _WinColLightYellow end;
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;
        If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gRID    = 0.0) then begin $edRID->wpColBkg    # _WinColLightYellow end;
      End;

    end;

    // ---- AUFLAUFHÖHE ----

    'bt.AH' : begin

      If gTraene <> 0.0 then begin
        Msg(997000,Translate('Coilculator'),0,0,0);
        gTraene # 0.0;
        cMDI->Winupdate(_WinUpdFld2Obj);
        RETURN(true);
      End;

      // -- Auflaufhöhe aus Gewicht, Stück, Breite, Dichte und RID
      gAH # Lib_Berechnungen:AuflaufH_aus_RIDRAD(gRID,gRAD);

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If (gAH = 0.0) then begin

        If (gRID    = 0.0) then begin $edRID->wpColBkg    # _WinColLightYellow end;
        If (gRAD    = 0.0) then begin $edRAD->wpColBkg    # _WinColLightYellow end;

      End;

    end;

    //====================================================================

    // ---- STÜCKZAHL ----
    'bt.Stk' : begin

      If ((gGew <> 0.0) and (gD <> 0.0) and (gB <> 0.0) and (gL <> 0.0) and (gDichte <> 0.0)) then begin
        gStk # CnvFI(Lib_Berechnungen:Stk_aus_KgDBLDichte2(gGew,gD,gB,gL,gDichte,0.0));
      End;

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If (gStk = 0.0) then begin
        If (gD      = 0.0) then begin $edDicke->wpColBkg  # _WinColLightYellow end;
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gL      = 0.0) then begin $edLaenge->wpColBkg # _WinColLightYellow end;
        If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;
        If (gGew    = 0.0) then begin $edGew->wpColBkg    # _WinColLightYellow end;
      End;

    end;

    // ---- GEWICHT ----
    'bt.Gew' : begin

      // -- Gewicht aus d * D * b/1000 * l/1000 * Stk
      if ((gStk<>0.0) and (gD<>0.0) and (gB<>0.0) and (gL<>0.0) and (gDichte<>0.0)) then begin
        gGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(cnvif(gStk), gD, gB, gL, gDichte,gTraene);
        end

      // -- Gewicht aus RAD^2 - RID^2 * pi * b/100 * Stk
      else if ((gStk<>0.0) and (gB<>0.0) and (gRID<>0.0) and (gRAD<>0.0) and (gDichte<>0.0)) then begin

        If gTraene <> 0.0 then begin
          Msg(997000,Translate('Coilculator'),0,0,0);
          gTraene # 0.0;
          cMDI->Winupdate(_WinUpdFld2Obj);
          RETURN(true);
        End;

        gGew # Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD(cnvif(gStk), gB, gDichte, gRID, gRAD);
        end

      // -- Gewicht aus Stückgew. * Stk
      else if ((gStkGew<>0.0) and (gStk<>0.0)) then begin
        gGew # gStkGew * gStk;
      end;


      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If ((gD = 0.0) and (gB = 0.0) and (gL = 0.0) and (gStk = 0.0 or gStkGew = 0.0)) then begin
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;
        If (gStkGew = 0.0) then begin $edStkGew->wpColBkg # _WinColLightYellow end;

      End else If ((gGew = 0.0) and (gL = 0.0) and (gRID > 0.0 or gRAD > 0.0)) then begin
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gRID    = 0.0) then begin $edRID->wpColBkg    # _WinColLightYellow end;
        If (gRAD    = 0.0) then begin $edRAD->wpColBkg    # _WinColLightYellow end;
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;

      End else If (gGew = 0.0) then begin
        If (gD      = 0.0) then begin $edDicke->wpColBkg  # _WinColLightYellow end;
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gL      = 0.0) then begin $edLaenge->wpColBkg # _WinColLightYellow end;
        If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;
      End;

    end;

    // ---- STÜCKGEWICHT ----

    'bt.StkGew' : begin

      // -- Stückgew. aus d * D * b/1000 * l/1000
      if ((gStk<>0.0) and (gD<>0.0) and (gB<>0.0) and (gL<>0.0) and (gDichte<>0.0)) then begin
        gStkGew # Lib_Berechnungen:kg_aus_StkDBLDichte2(1, gD, gB, gL, gDichte,gTraene);
        end

      // -- Stückgew. aus RAD^2 - RID^2 * pi * b/100
      else if ((gStk<>0.0) and (gB<>0.0) and (gRID<>0.0) and (gRAD<>0.0) and (gDichte<>0.0)) then begin

        If gTraene <> 0.0 then begin
          Msg(997000,Translate('Coilculator'),0,0,0);
          gTraene # 0.0;
          cMDI->Winupdate(_WinUpdFld2Obj);
          RETURN(true);
        End;

        gStkGew # Lib_Berechnungen:Kg_aus_StkBDichteRIDRAD(1, gB, gDichte, gRID, gRAD);
        end

      // -- Stückgew. aus Gewicht / Stk
      else if ((gGew<>0.0) and (gStk<>0.0)) then begin
        gStkGew # gGew / gStk;
      end;

      // ---- Alle Feldfarben zurücksetzen ----
      $edDicke->wpColBkg  # _WinColWindow;
      $edBreite->wpColBkg # _WinColWindow;
      $edLaenge->wpColBkg # _WinColWindow;
      $edDichte->wpColBkg # _WinColWindow;

      $edRID->wpColBkg    # _WinColWindow;
      $edRAD->wpColBkg    # _WinColWindow;
      $edAH->wpColBkg     # _WinColWindow;
      $edkgmm->wpColBkg   # _WinColWindow;

      $edStk->wpColBkg    # _WinColWindow;
      $edTlg->wpColBkg    # _WinColWindow;
      $edGew->wpColBkg    # _WinColWindow;
      $edStkGew->wpColBkg # _WinColWindow;

      // ---- Benötigte Eingabefelder markieren ----
      If ((gD = 0.0) and (gB = 0.0) and (gL = 0.0) and (gStk = 0.0 or gStkGew = 0.0)) then begin
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;
        If (gGew = 0.0) then begin $edGew->wpColBkg       # _WinColLightYellow end;

      End else If ((gGew = 0.0) and (gL = 0.0) and (gRID > 0.0 or gRAD > 0.0)) then begin
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gRID    = 0.0) then begin $edRID->wpColBkg    # _WinColLightYellow end;
        If (gRAD    = 0.0) then begin $edRAD->wpColBkg    # _WinColLightYellow end;
        If (gStk    = 0.0) then begin $edStk->wpColBkg    # _WinColLightYellow end;

      End else If (gGew = 0.0) then begin
        If (gD      = 0.0) then begin $edDicke->wpColBkg  # _WinColLightYellow end;
        If (gB      = 0.0) then begin $edBreite->wpColBkg # _WinColLightYellow end;
        If (gL      = 0.0) then begin $edLaenge->wpColBkg # _WinColLightYellow end;
        If (gDichte = 0.0) then begin $edDichte->wpColBkg # _WinColLightYellow end;
      End;

    end;

    //====================================================================

  end;  // Case

  cMDI->Winupdate(_WinUpdFld2Obj);

  // RETURN(true);
end;




//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
  vFile   : int;
end;
begin
  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if (vFile=200) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  Erx     : int;
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vPos    : int;
  vNr     : int;
end;
begin


  $mdi.coilculator->winupdate(_winupdactivate);

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      200 : begin
        Erx # RecRead(vFile,0,_RecId,vID);    // Satz holen
        if (Erx<>_rOK) then begin
        	RETURN (false);
        end;

        gD      # Mat.Dicke;
        gB      # Mat.Breite;
        gL      # "Mat.Länge";
        gRID    # Mat.RID;
        gRAD    # Mat.RAD;
        gAH     # 0.0;
        gDichte # Mat.Dichte;
        gkgmm   # Mat.kgmm;
        gStk    # cnvfi(Mat.Bestand.Stk);
        gGew    # Mat.Bestand.Gew;
        gStkGew # 0.0;
        gTlg    # 0.0;
        gTraene # 0.0;
        cMDI->Winupdate(_WinUpdFld2Obj);

      end;

    end;

  end;

	RETURN (true);
end



//========================================================================