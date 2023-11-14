@A+
//==== Business-Control ==================================================
//
//  Prozedur    App_Tastatur
//                  OHNE E_R_G
//  Info
//
//
//  20.07.2007  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtInit(aEvt : event): logic
//    SUB EvtClicked(aEvt : event) : logic
//
//========================================================================
@I:Def_Global
@I:Def_Rights

//========================================================================
// EvtInit
//          Initialisieren der Tastatur
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);

//  aEvt:Obj->wpCaption # aEvt:Obj->wpCaption + '    [ TRALLALLA ]';

  // Feld vorbelegen
  if (g_sSelected <> '') then
    $Ed.Vorschau->wpCaption # g_sSelected;

  $Ed.Vorschau->wpCaption # $Ed.Vorschau->wpCaption + StrChar(95);
  $Ed.Vorschau->WinFocusSet(true);

end;

//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vLine  : alpha(100);
  vMode  : int;
  vHdl   : int;
  vHdlObj : int;
  vToken : alpha;
  vChar  : int;
end;
begin

  // Cursor aus Text ausschneiden
  $Ed.Vorschau->wpCaption # StrCut($Ed.Vorschau->wpCaption,1,StrLen($Ed.Vorschau->wpCaption)-1);

  // Einladen
  vLine # $Ed.Vorschau->wpCaption;
  vMode # CnvIa($Ed.Vorschau->wpCustom);

  // Maximale Eingabelänge als komplett abgeschlossene Eingabe ansehen
  if (StrLen(vLine) >=40) then begin
    g_sSelected # vLine;
    $Mdi.Tastatur->WinClose();
  end;


  // Bei Tastatureingaben Modusbuttons zurücksetzen
  vHdl # aEvt:Obj->WinInfo(_WinFrame);
  if (vHdl->wpName = Lib_GuiCom:GetAlternativeName('Mdi.Tastatur')) then begin

    $bt.Key_Shift->wpStyleButton # _WinStyleButtonNormal;
    $bt.Key_Shift->wpColBkg # _WinColParent;
    vHdl # $Mdi.Tastatur->winsearch('bt.Key_Shift');
    vHdl->Winupdate(_Winupdon);

    $bt.Key_AltGr->wpStyleButton # _WinStyleButtonNormal;
    $bt.Key_AltGr->wpColBkg # _WinColParent;
    vHdl # $Mdi.Tastatur->winsearch('bt.Key_AltGr');
    vHdl->Winupdate(_Winupdon);

    $bt.Key_Strg_l->wpStyleButton  # _WinStyleButtonNormal;
    $bt.Key_Strg_l->wpColBkg # _WinColParent;
    vHdl # $Mdi.Tastatur->winsearch('bt.Key_Strg_l');
    vHdl->Winupdate(_Winupdon);

    $bt.Key_Strg_R->wpStyleButton  # _WinStyleButtonNormal;
    $bt.Key_Strg_R->wpColBkg # _WinColParent;
    vHdl # $Mdi.Tastatur->winsearch('bt.Key_Strg_R');
    vHdl->Winupdate(_Winupdon);

    $bt.Key_Alt->wpStyleButton   # _WinStyleButtonNormal;
    $bt.Key_Alt->wpColBkg # _WinColParent;
    vHdl # $Mdi.Tastatur->winsearch('bt.Key_Alt');
    vHdl->Winupdate(_Winupdon);
  end;

  // Eingabe Abfragen
  if (aEvt:Obj->wpCustom <> '') then begin
    // Je nach Modus den Customwert lesen
    vToken # Lib_Strings:Strings_Token(aEvt:Obj->wpCustom,';',vMode);
    vChar # CnviA(vToken);

    // und den angegeben Wert einschreiben
    vLine # vLine + StrChar(vChar);

    vMode # 1;
  end else begin

    case (aEvt:Obj->wpName) of
      // Funktionstasten abfragen
      'bt.Key_Shift' :  begin
                            vMode # 2;
                            $bt.Key_Shift->wpStyleButton # _WinStyleButtonTBar;
                            $bt.Key_Shift->wpColBkg # _WinColDarkGray;
                            vHdl # $Mdi.Tastatur->winsearch('bt.Key_Shift');
                            vHdl->Winupdate(_Winupdon);
                        end;

      'bt.Key_AltGr' :  begin
                            vMode # 3;
                            $bt.Key_AltGr->wpStyleButton # _WinStyleButtonTBar;
                            $bt.Key_AltGr->wpColBkg # _WinColDarkGray;
                            vHdl # $Mdi.Tastatur->winsearch('bt.Key_AltGr');
                            vHdl->Winupdate(_Winupdon);
                        end;

      'bt.Key_Backspace' :  vLine # StrCut(vLine,1,StrLen(vLine)-1);

      'bt.Key_Clear' :      vLine # '';

      'bt.Key_Esc'   :  begin
                            vLine # '';
                            vHdl # aEvt:Obj->WinInfo(_WinFrame);
                            vHdl->WinClose();
                        end;

      'bt.Key_ENTER' :  begin
                            g_sSelected # vLine;
                            vHdl # aEvt:Obj->WinInfo(_WinFrame);
                            vHdl->WinClose();
                        end;

      'bt.Key_Strg_l' :   begin
                            $bt.Key_Strg_l->wpStyleButton # _WinStyleButtonTBar;
                            $bt.Key_Strg_l->wpColBkg # _WinColDarkGray;
                            vHdl # $Mdi.Tastatur->winsearch('bt.Key_Strg_l');
                            vHdl->Winupdate(_Winupdon);
                        end;
      'bt.Key_Strg_r' :   begin
                            $bt.Key_Strg_r->wpStyleButton # _WinStyleButtonTBar;
                            $bt.Key_Strg_R->wpColBkg # _WinColDarkGray;
                            vHdl # $Mdi.Tastatur->winsearch('bt.Key_Strg_r');
                            vHdl->Winupdate(_Winupdon);
                        end;

      'bt.Key_Alt' :    begin
                            $bt.Key_Alt->wpStyleButton # _WinStyleButtonTBar;
                            $bt.Key_Alt->wpColBkg # _WinColDarkGray;
                            vHdl # $Mdi.Tastatur->winsearch('bt.Key_Alt');
                            vHdl->Winupdate(_Winupdon);
                        end;
      'bt.Key_PosNeg': begin
                            if(Lib_Strings:Strings_PosNum(vLine,'-',1) > 0) then begin
                              vLine # Str_ReplaceAll(vLine,'-','');
                              vLine # '+' + vLine
                            end else begin
                              vLine # Str_ReplaceAll(vLine,'+','');
                              vLine # '-' + vLine;
                            end;

                      end;

    end; //EO Case
  end;

  $Ed.Vorschau->wpCustom # CnvAi(vMode);
  $Ed.Vorschau->wpCaption # vLine +  StrChar(95);

  vHdl # aEvt:Obj->WinInfo(_WinFrame);
  vHdl # vHdl->winsearch('Ed.Vorschau');
  vHdl->Winupdate(_Winupdon);

end;




//========================================================================
//========================================================================
//========================================================================
//========================================================================
