@A+
//===== Business-Control =================================================
//
//  Prozedur    C16_UserPassw
//                    OHNE E_R_G
//  Info
//
//
//  19.08.2003  ST  Erstellung der Prozedur
//  09.05.2016  AH  Vertretung
//
//  Subprozeduren
//    SUB Init()
//    SUB Save(aEvt : event) : logic
//========================================================================
@I:Def_Global
LOCAL begin
  vHdl  : int
end;

//========================================================================
//
//
//========================================================================
sub Init()
begin
  Usr.Username # gUsername;
  RecRead(800,1,0);
  Usr_data:RecReadThisUser();
  vHdl # WinDialog('C16.SetPassW',_WinDialogCenter);
end;


//========================================================================
// Save
//
//========================================================================
sub Save(
  aEvt                  : event;        // Ereignis
) : logic
local begin
  Erx : int;
  vPW : logic;
end;
begin

  if ($EdPassNew->WpCaption <> '') or ($EdPassOld->WpCaption <> '') then begin

    If ($EdPassNew->WpCaption <> $EdPAssWiederhol->WpCaption) then begin
      Msg(000010,Translate('Passwort'),0,0,0);
      RETURN false;   // 2022-12-14 AH
    end;

    Erx # UserPassword('',$EdPassOld->WpCaption,$EdPassNew->WpCaption);
    if (Erx<>_ErrOK) then begin
      Msg(000011,Translate('Passwort'),0,0,0);
      RETURN false;
    end;
    vPW # true;
  end;

  // 25.08.2020 AH:
  if ($EdVertretung->WpCaption<>'') then begin
    Usr.Username # $EdVertretung->WpCaption;
    Erx # RecRead(800,1,0);
    if (Erx<>_rOK) then begin
      Msg(800005,$EdVertretung->WpCaption,0,0,0);
      RETURN false;
    end;
    if (Usr.VertretungUser<>'') then begin
      Msg(800006,$EdVertretung->WpCaption+'|'+Usr.VertretungUser,0,0,0);
    end;
  end;
  
  Usr.Username # gUsername;
  RecRead(800,1,_recLock);
  Usr.VertretungUser    # $EdVertretung->WpCaption;
  Usr.VertretungVonDat  # $EdVertretungVon->WpCaptionDate;
  Usr.VertretungBisDat  # $EdVertretungBis->WpCaptiondate;
  RekReplace(800);

  $C16.SetPassW -> WinClose();

  if (vPW) then begin
    Msg(000012,Translate('Passwort'),0,0,0);
  end;

end;


//========================================================================