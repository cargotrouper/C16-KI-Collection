@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Picture
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2006  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB PicPropSet(aObj : int; aProp : int; aVal : int)
//    SUB EvtChanged(	aEvt : event) : logic
//    SUB EvtClicked(	aEvt : event) : logic
//    SUB ShowPic(aName : alpha(500))
//========================================================================
@I:Def_Global

//========================================================================
//   Bildeigenschaft setzen
//
//========================================================================
sub PicPropSet(
  aObj              : int;        // Objekt
  aProp             : int;        // Eigenschaft
  aVal              : int;        // Ausprägung
)
local begin
  vVal              : int;        // Vorherige Ausprägung
end;
begin
  // Vorherige Ausprägung ermitteln
  WinPropGet(aObj, aProp, vVal);

  // Unterscheidung über Eigenschaft
  case (aProp) of
    // Faktor
    _WinPropZoomFactor : begin
      // Negativer Zoom-Faktor (zentriert mit Zoom) oder zentriert
      if ((vVal < 0) OR (aObj -> wpModeDraw = _WinModeDrawCenter)) then begin
        // Zentrieren und neuen Zoomfaktor übernehmen
        aVal # 0 - Abs(aVal);
        end
      else begin
        // "Manuell" auswählen
//        $dlsPicView -> wpCurrentInt # 4;
      end;
    end;


    // Zoom-Modus
    _WinPropModeZoom : begin
      // Darstellungs-Eigenschaft leeren
      aObj -> wpModeDraw # _WinModeDrawNone;
      // Unterscheidung über Ausprägung
      case (vVal) of
        // Kein Zoom
        _WinModeZoomNone : begin
          // Bildanzeige rücksetzen
          aObj -> wpModeZoom   # vVal;
          aObj -> wpModeEffect # _WinModeEffectNone;
          aObj -> wpZoomFactor # 100;

          $IE.Zoom -> wpColBkg # _WinColWindow;
        end;

        // Manueller Zoom : Zoomanzeige weiß für richtigen Zoom-Faktor
        _WinModeZoomCursor : $IE.Zoom -> wpColBkg # _WinColWindow

        // Standard : Zoomanzeige rot für falschen Zoom-Faktor
        otherwise $IE.Zoom -> wpColBkg # 8224255;
      end;
    end;


    // Darstellungs-Modus
    _WinPropModeDraw : begin
      // Unterscheidung über Ausprägung
      case (aVal) of
        // Zentriert
        _WinModeDrawCenter : begin
          // Zoomanzeige weiß für richtigen Zoom-Faktor
          $IE.Zoom -> wpColBkg # _WinColWindow;
          // Darstellungs-Modus aufheben
          aObj -> wpModeDraw     # _WinModeDrawNone;
          // Zoom-Modus aufheben
          aObj -> wpModeZoom     # _WinModeZoomNone;
          // Zoom-Faktor für zentrierte Ansicht setzen
          aObj -> wpZoomFactor   # 0 - Abs(aObj -> wpZoomFactor);
        end

        // Standard
        otherwise begin
          // Zoomanzeige rot für falschen Zoom-Faktor
          $IE.Zoom -> wpColBkg # 8224255;
          // Zoom-Modus aufheben
          aObj -> wpModeZoom # _WinModeZoomNone;
          // Zoom-Faktor aufheben
          aObj -> wpZoomFactor # 100;
        end;
      end;
    end;

    // Effekt
    _WinPropModeEffect : begin
    end;

  end;
  // Neue Ausprägung setzen
  WinPropSet(aObj, aProp, aVal);
end;


//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
	aEvt         : event     // Ereignis
) : logic
begin

  // Unterscheidung über Objektnamen
  case (aEvt:obj -> wpName) of
    // Zoomanzeige
    'IE.Zoom' : begin
      // Zoomanzeige manuell verändert und Inhalt nicht leer oder 0
      if ((aEvt:obj -> wpChanged) AND (aEvt:obj -> wpCaptionInt != 0)) then begin
        // Zoom-Faktor übernehmen
        PicPropSet($picview.Picture, _WinPropZoomFactor, aEvt:obj -> wpCaptionInt);
      end;
    end;

    // Bildanzeige
    'Picture1' : begin
      // Zoom-Faktor anzeigen
      $IE.Zoom  -> wpCaptionInt # Abs(aEvt:obj -> wpZoomFactor);
    end;
  end;

	RETURN (true);
end;


//========================================================================
//  EvtClicked
//
//========================================================================
sub EvtClicked(
	aEvt         : event     // Ereignis
) : logic
begin

  case aEvt:obj->wpname of

    'bt.ZoomOut' : begin
      $IE.Zoom->wpCaptionInt # $IE.Zoom->wpCaptionInt- 25;
    end;

    'bt.ZoomIn' : begin
      $IE.Zoom->wpCaptionInt # $IE.Zoom->wpCaptionInt + 25;
    end;

  end;

  if  ($IE.Zoom->wpCaptionInt != 0) then begin
    PicPropSet($picview.Picture, _WinPropZoomFactor, $IE.Zoom->wpCaptionInt);
  end;

	RETURN (true);
end;



//========================================================================
//  ShowPic
//
//========================================================================
sub ShowPic(
  aName : alpha(500);
)
local begin
  vHdl  : int;
  vHdl2 : int;
end;
begin
  vHdl # Winopen('Pic.Viewer',_WinOpenDialog);
  if (vHdl=0) then RETURN;

  vHdl2 # vHdl->WinSearch('picview.Picture');
  vHdl2->wpcaption # aName;
//  PicPropSet(vHdl2, _WinPropModeDraw, _WinModeDrawRatio);
  PicPropSet(vHdl2, _WinPropModeDraw, _WinModeDrawCenter);
  vHdl->WinDialogRun();
  vHdl->WinClose();
end;


//========================================================================