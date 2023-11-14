@A+
//===== Business-Control =================================================
//
//  Prozedur    Dlg_Bild
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  13.10.2009  MS  EvtPosChanged hinzugefuegt
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//  SUB EvtChanged(aEvt : event) : logic
//  SZB EvtClicked (aEvt : event) : logic
//  SUB EvtPosChanged(aEvt : event;	aRect : rect;aClientSize : point;aFlags : int) : logic
//
//========================================================================
@I:def_Global

//========================================================================
//  EvtChanged
//
//========================================================================
sub EvtChanged(
	aEvt         : event     // Ereignis
) : logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  $Bild->wpzoomfactor # $IE.Zoom->wpCaptionInt ;

	RETURN (true);
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  Erx         : int;
  vHdl        : int;
  vHdl2       : int;
  vName       : alpha(500);
  vPapersize  : alpha;

  vJobName    : alpha;
  vPage       : int;
  vJob        : int;
end;
begin

  case (aEvt:Obj->wpName) of

    'Bt.Druck' : begin

      vHdl2   # $Dlg.Bild->Winsearch('Bild');
      vName # vHdl2->wpcaption;

      vHdl # PrtFormOpen(_PrtTypePrintForm, 'xFRM.Picture');
      vHdl2 # Winsearch(vHdl,'prtPicture');
      vHdl2->wpcaption # ''+vName;
      vHdl2->wparealeft # PrtUnitLog(5.0,_PrtUnitMillimetres);
      vHdl2->wpareatop  # PrtUnitLog(5.0,_PrtUnitMillimetres);
      //vHdl2->wpAutosize # y;
      vHdl2->wpPictureMode # _WinPictStretch;// | _WinPictLeftTop;
      //Lib_Print:FrmJobOpen('tmp'+AInt(gUserID),0,0,n,n,y);

      if (Set.Druckerpfad<>'') then begin
        vJobName # Set.Druckerpfad + 'tmp'+AInt(gUserID)+'.Job';
      end
      else begin
        FsiPathCreate(_Sys->spPathTemp+'StahlControl');
        FsiPathCreate(_Sys->spPathTemp+'StahlControl\Druck');
        vJobName # _Sys->spPathTemp+'StahlControl\Druck\' + 'tmp'+AInt(gUserID)+'.Job';
      end;

      vPaperSize # 'DinA4quer';
      vJob # PrtJobOpen(vPapersize, vJobName,_PrtJobOpenWrite,_PrtTypePrintDoc);
      if (vJob = 0) then begin
        vHdl->PrtFormClose();
        RETURN false;
      end;

      // PrintDocument ermitteln
      Erx # vJob->PrtInfo(_PrtDoc);
      if (Erx > 0) then begin
        Erx->ppZoomFactor  # 100;
      end;
      _App->wpWaitcursor # true;
      if (gTAPI<>0) then Lib_Tapi:TapiTerm();
      vPage # vJob->PrtJobWrite(_PrtJobPageStart);


      vPage->PrtAdd(vHdl, _PrtAddTop);
      vHdl->PrtFormClose();

      //Lib_Print:FrmJobClose(y);
      _App->wpWaitcursor # false;
      if (vJob=0) then begin
        Lib_Tapi:TAPIInitialize();
        RETURN true;
      end;
      vJob->PrtJobWrite(_PrtJobPageEnd);
//      if (form_printer<>0) then
//        Erx # form_Job -> PrtJobClose(_PrtJobPreview,Form_Printer)
//      else
      Erx # vJob -> PrtJobClose(_PrtJobPreview);

      FSIDelete(vJobName);

      Lib_Tapi:TAPIInitialize();
      RETURN true;
    end;

  end;

  RETURN true;
end;

//========================================================================
// EvtPosChanged
//
//========================================================================
sub EvtPosChanged(
	aEvt         : event;    // Ereignis
	aRect        : rect;     // Größe des Fensters
	aClientSize  : point;    // Größe des Client-Bereichs
	aFlags       : int       // Aktion
) : logic
local begin
  vRect     : rect;
end
begin
  if (aFlags & _WinPosSized != 0) then begin
    vRect           # $Bild->wpArea;
    vRect:right     # aRect:right-aRect:left-8;
    vRect:bottom    # aRect:bottom-aRect:Top-34;
    $Bild->wparea # vRect;
  end;
	RETURN (true);
end;



//========================================================================
//  Main
//
//========================================================================
main(
  aFilename : alpha(500);
  );
local begin
  vHdl    : int;
  vHdl2   : int;
  vRect   : rect;
//  vInst   : int;
end;
begin

//  vInst # VarInfo(windowbonus);

  vHdl    # WinOpen('Dlg.Bild',_WinOpenDialog);

  // Grösse anpassen
  vRect # _app->wpareawork;
  vHdl->wpArea # vRect;
  vHdl2   # vHdl->Winsearch('Bild');
  vHdl2->wparearight  # vRect:Right - 14;
  vHdl2->wpAreaBottom # vRect:Bottom - 40;
  // Bild anzeigen
  vHdl2   # vHdl->Winsearch('Bild');
  vHdl2->wpcaption # aFilename;

  // Dialog starten
  vHdl->Windialogrun(0,gMDI);//gFrmMain);

  // Dialog schliessen
  vHdl->winclose();

  // Hauptmenü setzen
//  app_Main:_SetMenu(gMenuName);
//debug(aint(vInst)+'  '+aint(varinfo(windowbonus)));
//debug(w_name);
//varinstance(Windowbonus,vInst);
//debug(w_name);

  RETURN;
end

//========================================================================