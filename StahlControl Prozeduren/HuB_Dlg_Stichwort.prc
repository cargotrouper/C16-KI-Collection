@A+
//==== Business-Control ==================================================
//
//  Prozedur    HuB_Dlg_Stichwort
//                    OHNE E_R_G
//  Info
//
//
//  19.08.2003  ST Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event) : logic
//    SUB EvtClicked(aEvt : event) : logic
//
//========================================================================
@I:Def_Global

LOCAL begin
  lText   : alpha;
end;


//========================================================================
//
//
//========================================================================
Sub EvtInit
(
  aEvt  : event;
) : logic
begin
   $edText->WinFocusSet(true);
end;

//========================================================================
// EvtClicked+
//
//========================================================================
Sub EvtClicked
(
  aEvt      : event;
) : logic
local begin
  vRecFlag  : int;
end;
begin
  Case aEvt:Obj->wpName of
    'OK' : begin

      if (RecRead(180,1, _RecLock) = _rOk) then begin
        HuB.Stichwort # $edText->wpCaption;

        Transon;
        If (RekReplace(180,_RecUnlock,'AUTO') <> _rOk) then begin
          Transbrk;
  //      Fehlermeldung
        end else
          TransOff;

        // Positionen durchgehen
        HuB.EK.P.Artikelnr # HuB.Artikelnr;
        vRecFlag # _RecFirst | _RecLock;

        WHILE (RecRead(191,3,vRecFlag) <> _rNoRec) DO BEGIN

          Hub.EK.P.ArtikelSW # HuB.Stichwort;

          Transon;
          if (RekReplace(191,_RecUnlock,'AUTO') <> _rOk) then begin
            TransBrk;
  //        Fehlermeldung
          end else
            TransOff;


            vRecFlag # _RecNext | _RecLock;
        END;
      end;    // Artikel erfolgreich gesichert?
    end;
  end; //case


  $HuB.Dlg.Stichwort->WinClose();

  return true;
end;

//========================================================================
// Main
//
//========================================================================
MAIN
(
  aText   : alpha;
) : alpha
local begin
  vID : int;
end;
begin
  lText   # aText;
  vId # WinDialog('HuB.Dlg.Stichwort',_WinDialogCenter);
  If vId = _WinIdOk then return lText
  else return '';
end;

//========================================================================