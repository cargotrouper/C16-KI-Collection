@A+
//===== Business-Control =================================================
//
//  Prozedur  Dlg_TAPI_Incoming
//                    OHNE E_R_G
//  Info
//
//
//  23.05.2012  AI  Erstellung der Prozedur
//  13.09.2016  ST  Integration Snom Tapi
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//========================================================================
sub Start(
  aNummer : alpha;
  aCallID : int;
  aStamp  : caltime);
local begin
  vDlg    : int;
  vHdl    : int;
  vDatei  : int;
  vBuf    : int;
  vTime   : time;
  vBuf800 : int;
  vBuf100 : int;
  vName1  : alpha(200);
  vName2  : alpha(200);
//  vAkt    : alpha;
  vNoti   : alpha(200);
  vRecId  : int;
  vDatie  : int;
  vNew    : logic;
  vIntern : logic;
  vA      : alpha(4096);
  vWB     : int;
  vMitCockpit : logic;
end;
begin

  vTime # aStamp->vptime;
  vA # aNummer+'|'+aint(aCallID)+'|'+cnvat(vTime,_FmtTimeHSeconds);
  if (RunAFX('TAPI.Incoming.Start',vA)<>0) then RETURN;


//  vAkt  # 'TAPI';

  // passenden Dantsatz suchen
//    Lib_Tapi:IdentifyNumber(aNummer, var vDatei, var vBuf);
//  Lib_Tapi:IdentifyNumber(aNummer, var vName1, var vName2, var vAkt, var vNoti, var vRecid, var vIntern, var vNew);
  Lib_Tapi:IdentifyNumber(aNummer, var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew);


  // Fenster bereits öffnen?
  if (gDlgTAPI<>0) then begin

    if (gMDINotifier<>0) then begin
      vWB  # VarInfo(WindowBonus);
      VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
      vMitCockpit # (gZonelist<>0);
      VarInstance(WindowBonus, vWB);
    end;

    // in Notifier schieben...
    if (vMitCockpit=false) then
      Lib_Notifier:NewEvent( gUserName, 'TAPI/'+aint(vDatei)+'/'+aNummer, vNoti, vRecID ); // User, Aktion, Text, Int

    RETURN;
  end;


  vDlg # winOpen('Dlg.TAPI.Incoming', _WinOpenDialog);
  vHdl # Winsearch(vDlg,'lbName1');
  vHdl->wpcaption # vName1;
  vHdl->wpcustom # aNummer;

  vHdl # Winsearch(vDlg,'lbName2');
  vHdl->wpcaption # vName2;
  vHdl->wpcustom # cnvai(aCallid);

  vHdl # Winsearch(vDlg,'lbNotifier');
//  vHdl->wpcaption # vAkt;
  vHdl->wpcaption # 'TAPI/'+aint(vDatei)+'/'+aNummer
  vHdl->wpcustom  # vNoti;

  vHdl # Winsearch(vDlg,'lbZeit');
//    vHdl->wpcaption # cnvac(aStamp, _FmtCaltimeRFC)+':';
  vHdl->wpcaption # ''+cnvat(vTime, _FmtTimeSeconds)+' Uhr';
  vHdl->wpcustom  # aint(vRecID);

  // Kein Notifier?
  vBuf800 # RecBufCreate( 800 );
  vBuf800->Usr.Username # gUserName;
  if ( RecRead( vBuf800, 1, 0 ) > _rLocked ) or ( vBuf800->Usr.NotifierYN=false ) then begin
    vDlg->wpareabottom # vDlg->wpareabottom - 96;
    vHdl # Winsearch(vDlg,'bt2List');
    vHdl->wpvisible # false;
  end;
  RecBufDestroy(vBuf800);


  vHdl # Winsearch(vDlg,'bt2Adresse');
  vHdl->wpcustom # aint(vRecID);
  if (vIntern) then begin
    vHdl->wpdisabled # true;
  end;
  if (vNew) then begin
    vHdl->wpvisible # false;
    vHdl # Winsearch(vDlg,'btCopy');
    vHdl->wpvisible # true;
    vHdl->wpcustom  # aNummer;
  end;


  gDlgTAPI # vDLG;
  WinDialogRun(vDlg, _WinDialogNoActivate | _WinDialogAsync | _WinDialogAlwaysOnTop | _WinDialogCenter, gFrmMain );
end;


//========================================================================
//========================================================================
sub StartSnom(
  aNummer : alpha;
  aCallID : alpha;
  aStamp  : caltime);
local begin
  vDlg    : int;
  vHdl    : int;
  vDatei  : int;
  vBuf    : int;
  vTime   : time;
  vBuf800 : int;
  vBuf100 : int;
  vName1  : alpha(200);
  vName2  : alpha(200);
  vNoti   : alpha(200);
  vRecId  : int;
  vDatie  : int;
  vNew    : logic;
  vIntern : logic;
  vA      : alpha(4096);
  vWB     : int;
  vMitCockpit : logic;
end;
begin

  vTime # aStamp->vptime;
  vA # aNummer+'|'+aCallID+'|'+cnvat(vTime,_FmtTimeHSeconds);
  if (RunAFX('TAPI.Incoming.Start',vA)<>0) then RETURN;


//  vAkt  # 'TAPI';

  // passenden Dantsatz suchen
//    Lib_Tapi:IdentifyNumber(aNummer, var vDatei, var vBuf);
//  Lib_Tapi:IdentifyNumber(aNummer, var vName1, var vName2, var vAkt, var vNoti, var vRecid, var vIntern, var vNew);
  Lib_Tapi:IdentifyNumber(aNummer, var vName1, var vName2, var vNoti, var vDatei, var vRecid, var vIntern, var vNew);


  // Fenster bereits öffnen?
  if (gDlgTAPI<>0) then begin

    if (gMDINotifier<>0) then begin
      vWB  # VarInfo(WindowBonus);
      VarInstance(WindowBonus,cnvIA(gMDINotifier->wpcustom));
      vMitCockpit # (gZonelist<>0);
      VarInstance(WindowBonus, vWB);
    end;

    // in Notifier schieben...
    if (vMitCockpit=false) then
      Lib_Notifier:NewEvent( gUserName, 'TAPI/'+aint(vDatei)+'/'+aNummer, vNoti, vRecID ); // User, Aktion, Text, Int

    RETURN;
  end;


  vDlg # winOpen('Dlg.TAPI.Incoming', _WinOpenDialog);
  vHdl # Winsearch(vDlg,'lbName1');
  vHdl->wpcaption # vName1;
  vHdl->wpcustom # aNummer;

  vHdl # Winsearch(vDlg,'lbName2');
  vHdl->wpcaption # vName2;
  vHdl->wpcustom # aCallid;

  vHdl # Winsearch(vDlg,'lbNotifier');
//  vHdl->wpcaption # vAkt;
  vHdl->wpcaption # 'TAPI/'+aint(vDatei)+'/'+aNummer
  vHdl->wpcustom  # vNoti;

  vHdl # Winsearch(vDlg,'lbZeit');
//    vHdl->wpcaption # cnvac(aStamp, _FmtCaltimeRFC)+':';
  vHdl->wpcaption # ''+cnvat(vTime, _FmtTimeSeconds)+' Uhr';
  vHdl->wpcustom  # aint(vRecID);

  // Kein Notifier?
  vBuf800 # RecBufCreate( 800 );
  vBuf800->Usr.Username # gUserName;
  if ( RecRead( vBuf800, 1, 0 ) > _rLocked ) or ( vBuf800->Usr.NotifierYN=false ) then begin
    vDlg->wpareabottom # vDlg->wpareabottom - 96;
    vHdl # Winsearch(vDlg,'bt2List');
    vHdl->wpvisible # false;
  end;
  RecBufDestroy(vBuf800);


  vHdl # Winsearch(vDlg,'bt2Adresse');
  vHdl->wpcustom # aint(vRecID);
  if (vIntern) then begin
    vHdl->wpdisabled # true;
  end;
  if (vNew) then begin
    vHdl->wpvisible # false;
    vHdl # Winsearch(vDlg,'btCopy');
    vHdl->wpvisible # true;
    vHdl->wpcustom  # aNummer;
  end;


  gDlgTAPI # vDLG;
  WinDialogRun(vDlg, _WinDialogNoActivate | _WinDialogAsync | _WinDialogAlwaysOnTop | _WinDialogCenter, gFrmMain );
end;

//========================================================================
//========================================================================
sub AnrufToNotifier();
local begin
  vHdl      : int;
  vAkt      : alpha(200);
  vNoti     : alpha(200);
  vRecId    : int;
end;
begin
  if (gDlgTAPI>0) then begin
    vHdl    # Winsearch(gDlgTAPI,'bt2Adresse');
    vRecId  # cnvia(vHdl->wpcustom);
    vHdl    # Winsearch(gDlgTAPI,'lbNotifier');
    vAkt    # vHdl->wpcaption;
    vNoti   # vHdl->wpcustom;
  end;
  // in Notifier schieben...
// TODO Lib_Notifier:NewEvent( gUserName, vAkt, vNoti, vRecID ); // User, Aktion, Text, Int

end;


//========================================================================
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
begin
//  gTAPIDev->TapiListen(false,gFrmMain);
//  gTAPIDev->TapiListen(true,aEvt:obj);
  RETURN(true);
end;


//========================================================================
//========================================================================
sub xxxEvtCreated(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  Erx     : int;
  vDlg    : int;
  vOrgNr  : alpha;
  vNummer : alpha;
  vHdl    : int;
  vName1  : alpha;
  vName2  : alpha;
  vTim    : caltime;
  vBuf100 : int;
  vBuf102 : int;
  vInfo   : alpha;
  vNewNr  : alpha;
  vRecId  : int;
end;
begin

return true;

  vDlg # aEvt:obj;
  vHdl # Winsearch(vDlg,'lbName1');
  vOrgNr # vHdl->wpcustom;
  vOrgNr # '02371788410';
//  vOrgNr # '321321';

  vNummer # vOrgNr;

  if (vNummer='') then begin
    vName1 # Translate('Rufnummer unterdrückt');
    vName2 # Translate('unbekannter Anrufer');
    end
  else if (StrLen(vNummer)<=-2) then begin
    vName1 # Translate('interner Anruf');
    vName2 # vNummer;
    end
  else begin

    vNummer # StrCnv(vNummer,_StrLetter);

    vBuf100 # RecBufCreate(100);
    vBuf102 # RecBufCreate(102);

    // Adrese prüfen...
    vBuf100->Adr.Telefon1 # vNummer;
    Erx # RecRead(vBuf100,7,0);
    if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon1,_StrLetter)=vNummer) then begin
      vInfo # vBuf100->Adr.Sperrvermerk;
      if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
      vName1  # vBuf100->Adr.Stichwort;
      vName2  # vOrgNr;
      vNewNr  # '';
      vRecID  # RecInfo(vBuf100,_recid);//vBuf100->Adr.Nummer;
      vInfo   # '100'+'|'+vBuf100->Adr.Stichwort;
      end
    else begin
      vBuf100->Adr.Telefon2 # vNummer;
      Erx # RecRead(vBuf100,8,0);
      if (Erx<>_rNoRec) and (StrCnv(vBuf100->Adr.Telefon2,_StrLetter)=vNummer) then begin
        vInfo # vBuf100->Adr.Sperrvermerk;
        if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
        vName1  # vBuf100->Adr.Stichwort;
        vName2  # vOrgNr;
        vNewNr  # '';
        vRecID  # RecInfo(vBuf100,_recid);//vBuf100->Adr.Nummer;
        vInfo   # '100'+'|'+vBuf100->Adr.Stichwort;
        end
      // Ansprechpartner prüfen...
      else begin
        vBuf102->Adr.P.Telefon # vNummer;
        Erx # RecRead(vBuf102,2,0);
        if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Telefon,_StrLetter)=vNummer) then begin
          RecLink(vBuf100,vBuf102,1,_recFirst);   // Adresse holen
          vInfo # vBuf100->Adr.Sperrvermerk;
          if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;

//          vName1 # vBuf100->Adr.Stichwort+':';
//          if (vName1<>'') then vName1 # vName1 + ' ';
          vName1 # vName1 + vBuf102->Adr.P.Vorname;
          if (vName1<>'') then vName1 # vName1 + ' ';
          vName1  # vName1 + vBuf102->Adr.P.Name;
          vName2  # vBuf100->Adr.Stichwort;
          vNewNr  # '';
          vRecID  # RecInfo(vBuf100,_recid);//vBuf100->Adr.Nummer;
          vInfo   # '102/'+aint(vBuf102->Adr.P.Nummer)+'|'+vBuf100->Adr.Stichwort+': '+vBuf102->Adr.P.Stichwort;
          end
        else begin
          vBuf102->Adr.P.Mobil # vNummer;
          Erx # RecRead(vBuf102,3,0);
          if (Erx<>_rNoRec) and (StrCnv(vBuf102->Adr.P.Mobil,_StrLetter)=vNummer) then begin
            RecLink(vBuf100,vBuf102,1,_recFirst);   // Adresse holen
            vInfo # vBuf100->Adr.Sperrvermerk;
            if (vBuf100->Adr.SperrKundeYN) or (vBuf100->Adr.SperrLieferantYN) then vInfo # Translate('Adresse GESPERRT!')+' '+vInfo;
//            vName1 # vBuf100->Adr.Stichwort+':';
//            if (vName1<>'') then vName1 # vName1 + ' ';
            vName1 # vName1 + vBuf102->Adr.P.Vorname;
            if (vName1<>'') then vName1 # vName1 + ' ';
            vName1  # vName1 + vBuf102->Adr.P.Name;
            vName2  # vBuf100->Adr.Stichwort;
            vNewNr  # '';
            vRecID  # RecInfo(vBuf100,_recid);//vBuf100->Adr.Nummer;
            vInfo   # '102/'+aint(vBuf102->Adr.P.Nummer)+'|'+vBuf100->Adr.Stichwort+': '+vBuf102->Adr.P.Stichwort;
            end
          else begin
            vName1  # vOrgNr;
            vName2  # Translate('unbekannter Anrufer');
            vNewNr  # vOrgNr;
            vRecID  # 0;
            vInfo   # '';
          end
        end;
      end;
    end;

    RecBufDestroy(vBuf100);
    RecBufDestroy(vBuf102);
  end;


  vHdl # Winsearch(vDlg,'lbName1');
  vHdl->wpcaption # vName1;

  vHdl # Winsearch(vDlg,'lbName2');
  vHdl->wpcaption # vName2;

  vHdl # Winsearch(vDlg,'bt2List');
  vHdl->wpcustom # vInfo;

  vHdl # Winsearch(vDlg,'bt2Adresse');
  vHdl->wpcustom # aint(vRecID);

  if (vNewNr<>'') then begin
    vHdl # Winsearch(vDlg,'bt2Adresse');
    vHdl->wpvisible # false;
    vHdl # Winsearch(vDlg,'btCopy');
    vHdl->wpvisible # true;
    vHdl->wpcustom  # vNewNr;
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHDL      : int;
  vRecID    : int;
  vAkt      : alpha(200);
end;
begin
  case (aEvT:Obj->wpname) of

    'btOK' : begin
      // Fenster schliessen
      Winclose(gDlgTAPI);
      gDlgTAPI # 0;
    end;


    'btRueckruf' : begin
      vHdl # Winsearch(gDlgTAPI,'lbName2');

      if (Lib_Tapi_Snom:Isdev()) then begin
        // Hörer Abheben
        Lib_Tapi_Snom:TapiAnnehmen();
      end else begin
        TapiCall(cnvia(vHdl->wpcustom),_TapiCallOpAnswer);
      end;

      // Fenster schliesen
      winclose(gDLGTapi);
      gDlgTAPI # 0;
    end;


    'bt2List' : begin
      AnrufToNotifier();
      // Fenster schliessen
      winclose(gDLGTapi);
      gDlgTAPI # 0;
    end;


    'bt2Adresse' : begin
      vHdl    # Winsearch(gDlgTAPI,'bt2Adresse');
      vRecID  # cnvia(aEvt:Obj->wpcustom);
      vHdl    # Winsearch(gDlgTAPI,'lbNotifier');
      vAkt    # vHdl->wpcaption;
      vAkt    # Str_Token(vAkt, '/',2);
      if (vAkt='100') then
        Adr_Main:Start(vRecId, 0, y);
      else if (vAkt='102') then
        Adr_P_Main:Start(vRecId, 0, 0, y);
    end;


    'btCopy' : begin
      vHdl # Winsearch(gDlgTAPI,'btCopy');
      ClipboardWrite(vHdl->wpcustom);
//      vHdl->wpdisabled # true;
    end;

  end;

  RETURN(true);
end;

//========================================================================