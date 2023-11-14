@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Workflow
//                      OHNE E_R_G
//  Info
//
//
//  20.08.2009  AI  Erstellung der Prozedur
//  17.02.2014  ST  Erweiterung um Auslöser 700 - Betriebsauftrag
//  19.05.2014  AH  "NextWoF" kopiert Anhänge mit
//  08.06.2016  AH  Neu: "AuswahlWoF"
//  15.06.2016  AH  NewWF mit WoF.Nummer
//  30.06.2016  AH  Tem.Bemerkung wird WoF.Akt.Text, falls dieser gefüllt ist
//  02.11.2016  AH  "RemoveAll" für Reorganisation
//  29.11.2016  AH  Neu: VertretungUser für Anker
//  11.09.2017  ST  Neuer TemAnker auch bei aDatei=999
//  13.02.2018  ST  Neu: "Verundung" der Bedingungen zu einem Schema möglich
//  07.11.2018  AH  Fix "SkipUnds"
//  14.12.2018  AH  Neu: "TriggerWorkflow"
//  18.04.2019  AH  Neu: WoF mit EMail
//  06.05.2019  AH  Neu: WoFs mit Prozedur
//  14.06.2020  AH  Fix: Zirkelbezüge bei Vertreteruser
//  27.07.2021  AH  ERX
//  19.08.2021  ST  Edit: "Trigger" 250 Zeichen für Bemerkung anstatt 64
//  23.08.2021  AH  Gruppen-WOF
//  10.01.2022  AH  Trigger mit dirketem Key (z.B. für einmaliges Datum)
//  14.03.2022  AH  Dynamischer WOF übergibt Vor-Ergebnis weiter
//  25.04.2022  ST  Neu: Unterstütztung für Projektposition hinzugefügt
//
//  Subprozeduren
//    SUB GetData(aWOF : int; aDatei : int; var aKontextNr : int; var aKontext : alpha; var aOwn : alpha; var aText1 : alpha; var aText2 : alpha) : logic
//    SUB Trigger(aDatei : int; aWOF : int; aTyp : alpha; opt aUser : alpha; opt aTemBem : alpha;) : logic;
//    SUB NewWF(aName : alpha(200); aText : alpha(200); aDatei : int; opt aVorg : int; opt aWof: int) : logic;
//    SUB SendEmail(aUser : alpha)
//    SUB AddUser(aTeM : int; aUser : alpha(200), aWie : alpha) : logic;
//    SUB NextWOF(aStatus : alpha) : logic;
//    SUB Dialog();
//    SZB AuswahlWoF(aDatei : int);
//    SUB RemoveAll(aDatei : int) : logic;
//    SUB TriggerWorkFlow(aIssuer : int; aWorkflowNr : int; opt aBemtext : alpha(1000)) : int
//
//========================================================================
@I:Def_Global

declare NewWF(aName : alpha(1250); aText : alpha(1250); aDatei : int; aVorg : int; var aWof : int; opt aOhnePlan : logic; opt aKey : alpha) : logic;
declare AddUser(aTeM  : int; aUser : alpha(200); aWie : alpha) : logic;
declare AddDatei(aTem : int; aDatei : int; aID1 : int; aID2 : int; opt aID3 : word): logic

define begin
  cStdBenachrichtigungstyp : ''
end;


//========================================================================
sub GetIDs(
  aDatei      : int;
  aKontext    : alpha;
  var aOwn    : alpha;
  var aID1    : int;
  var aID2    : int;
  var aID3    : int;
  var aText1  : alpha;
  var aText2  : alpha)
begin
  case aDatei of
    100 : begin // Projekt --------------------------
      aOwn    # Adr.Anlage.User;
      aText1  # aKontext+' Adr.'+AInt(Adr.Nummer);
      aText2  # 'Adr.'+AInt(Adr.Nummer);
    end;
    
    120 : begin // Projekt --------------------------
      aOwn    # Prj.Anlage.User;
      aText1  # aKontext+' Prj.'+AInt(Prj.Nummer);
      aText2  # 'Prj.'+AInt(Prj.Nummer);
    end;

    // ST 2022-04-25
    122 : begin // Projekt Position--------------------------
      aOwn    # Prj.Anlage.User;
      aText1  # aKontext+' Prj.'+AInt(Prj.P.Nummer)+'/'+Aint(Prj.P.Position)+'/'+Aint(Prj.P.SubPosition);
      aID1    # Prj.P.Nummer;
      aID2    # Prj.P.Position;
      aID3    # Prj.P.SubPosition;
    end;


    200 : begin // Material -------------------------
      aOwn    # Mat.Anlage.User;
      aText1  # aKontext+' Mat.'+AInt(Mat.Nummer);
      aText2  # 'Mat.'+AInt(Mat.Nummer);
    end;

    203 : begin // Mat.Reservierung -----------------
      aOwn    # Mat.R.Anlage.User;
      aText1  # aKontext+' Reserv.'+AInt(Mat.R.Reservierungnr);
      aText2  # 'Mat.'+AInt(Mat.R.Materialnr)+', '+ANum(Mat.R.Gewicht,0)+'kg, '+Mat.R.KundenSW;
      if (Mat.R.Auftragsnr<>0) then begin
        aText2 # aText2 + ', '+AInt(Mat.R.Auftragsnr)+'/'+AInt(Mat.R.Auftragspos);
      end;
    end;

    400 : begin // Auftragskopf ---------------------
      aOwn    # Auf.Anlage.User;
      aText1  # aKontext+' Auf.'+AInt(Auf.Nummer);
      aID1    # Auf.Nummer;
      aID2    # 0;
      aID3    # 0;
    end;

    401 : begin // Auftragsposition -----------------
      aOwn    # Auf.P.Anlage.User;
      aText1  # aKontext+' Auf.'+AInt(Auf.P.Nummer)+'/'+AInt(Auf.P.Position);
      aText2  # Auf.P.KundenSW;
      aID1    # Auf.P.Nummer;
      aID2    # Auf.P.Position;
      aID3    # 0;
    end;

    440 : begin // Lieferscheinkopf ---------------------
      aOwn    # Auf.Anlage.User;
      aText1  # aKontext+' Lfs.'+AInt(Lfs.Nummer);
      aID1    # Lfs.Nummer;
      aID2    # 0;
      aID3    # 0;
    end;

    500 : begin // Bestellkopf ----------------------
      aOwn    # Ein.Anlage.User;
      aText1  # aKontext+' Ein.'+AInt(Ein.Nummer);
      aID1    # Ein.Nummer;
      aID2    # 0;
      aID3    # 0;
    end;

    501 : begin // BestellPosition ------------------
      aOwn    # Ein.P.Anlage.User;
      aText1  # aKontext+' Ein.'+AInt(Ein.P.Nummer)+'/'+AInt(Ein.P.Position);
      aText2  # Ein.P.LieferantenSW;
      aID1    # Ein.P.Nummer;
      aID2    # Ein.P.Position;
      aID3    # 0;
    end;

    540 : begin // Bedarf ----------------------
      aOwn    # Ein.Anlage.User;
      aText1  # aKontext+' Bdf.'+AInt(Bdf.Nummer);
      aID1    # Bdf.Nummer;
      aID2    # 0;
      aID3    # 0;
    end;

    700 : begin // Betriebsauftragskopf ----------------------
      aOwn    # BAG.Anlage.User;
      aText1  # aKontext+' Bag.'+AInt(Bag.Nummer);
      aID1    # Bag.Nummer;
      aID2    # 0;
      aID3    # 0;
    end;

    702 : begin // Betriebsauftragskopf ----------------------
      aOwn    # BAG.P.Anlage.User;
      aText1  # aKontext+' Bag.'+AInt(Bag.P.Nummer)+'/'+aint(bag.p.position);
      aID1    # Bag.P.Nummer;
      aID2    # Bag.P.Position;
      aID3    # 0;
    end;

    916 : begin // Anhang ------------------------------------
      aOwn    # Anh.Anlage.User;
      aText1  # aKontext+' Anhang';
//      aID1    # Anh.P.Nummer;
//      aID2    # Bag.P.Position;
//      aID3    # 0;
      aText2 # Anh.Key;
    end;

  end;

  aText1  # StrAdj(aText1,_strBegin);
end;


//========================================================================
//  GetData
//
//========================================================================
sub GetData(
  aWOF            : int;
  aDatei          : int;
  var aKontextNr  : int;
  var aKontext    : alpha;
  var aOwn        : alpha;
  var aText1      : alpha;
  var aText2      : alpha;
  var aID1        : int;
  var aID2        : int;
  var aID3        : int) : logic;
local begin
  Erx : int;
end;
begin

  WoF.Sch.Nummer # aWOF;
  Erx # RecRead(940,1,0);   // Workflow suchen
  if (Erx>_rLocked) then RETURN false;
  if (WoF.Sch.Datei<>aDatei) then RETURN false;

  if (aKontextNr=0) then begin
    If (WoF.Sch.Kontext1=aKontext) then aKontextNr # 1;
    If (WoF.Sch.Kontext2=aKontext) then aKontextNr # 2;
    If (WoF.Sch.Kontext3=aKontext) then aKontextNr # 3;
    If (WoF.Sch.Kontext4=aKontext) then aKontextNR # 4;
    If (WoF.Sch.Kontext5=aKontext) then aKontextNr # 5;
    If (aKontext='') then aKontextNr # 6;
    if (aKontextNr=0) then RETURN false;
  end
  else begin
    if (aKontextNr=1) then aKontext # WoF.Sch.Kontext1;
    if (aKontextNr=2) then aKontext # WoF.Sch.Kontext2;
    if (aKontextNr=3) then aKontext # WoF.Sch.Kontext3;
    if (aKontextNr=4) then aKontext # WoF.Sch.Kontext4;
    if (aKontextNr=5) then aKontext # WoF.Sch.Kontext5;
    if (aKontextNr<>6) and (aKontext='') then RETURN false;
  end;

  aKontext # '';    // 26.11.2014

  GetIDS(aDatei, aKontext, var aOwn, var aID1, var aID2, var aID3, var aText1, var aText2);

  RETURN true;
end;


//========================================================================
//  Trigger
//
//========================================================================
sub Trigger(
  aDatei      : int;
  aWOF        : int;
  aTyp        : alpha;
  opt aUser   : alpha(1000);
  opt aTemBem : alpha(1000);
  opt aWie    : alpha;
  opt aNotiText : alpha(1000);
  opt aKey    : alpha;
) : logic;
local begin
  Erx     : int;
  vAkt    : int;
  vFilter : int;
  vOwner  : alpha;
  vText   : alpha(250);
  vText2  : alpha(250);
  vID1    : int;
  vID2    : int;
  vID3    : int;
  vOK     : logic;
  vWofNr  : int;
  vTyp    : alpha;
end;
begin
//debug('trigger für'+aint(aDatei)+' ID:'+aint(awof)+' '+atyp);
//  if (gUserGroup<>'SOA_SERVER') and (gUserGroup<>'JOB-SERVER') then
//    if (StrFind(Set.Module,'W',0)=0) then begin
//      Error(99,'keine Lizenz');
//      RETURN false;
//    end;

  aUser     # StrCut(aUser,1,32);
  //aTemBem   # StrCut(aTemBem, 1, 64);
  aTemBem   # StrCut(aTemBem, 1, 250); // ST 2021-08-19: Erweitert von 64 auf 250; wird in "sub NewWF(...)" auf 250 gecutted

  // Dateibezogene Daten bestimmen...
  if (aKey='') then begin
    vOK # GetData(aWoF, aDatei, var vAkt, var aTyp, var vOwner, var vText, var vText2, var vID1, var vID2, var vID3);
    if (vOK=false) then begin
      if (Set.Installname='BSC') and (aDatei<>aWOF) then  // 2023-03-28 AH SystemWOF ignorieren
        Error(99,'Kein Bezug');
      RETURN false;
    end;
  end
  else begin
    WoF.Sch.Nummer # aWOF;
    Erx # RecRead(940,1,0);   // Workflow suchen
    if (Erx>_rLocked) then begin
      Error(99,'Kein WOF gefunden');
      RETURN false;
    end;
    vAkt # 6;
  end;

//debugx('das ist akt:'+aint(wof.sch.nummer)+'/'+aint(vakt)+' | '+aTyp);
  RecBufClear(941);
  WoF.Akt.Nummer  # WoF.Sch.Nummer;
  WoF.Akt.Kontext # vAkt;
  FOR Erx # RecRead(941,1,0)
  LOOP Erx # RecRead(941,1,_RecNext)
  WHILE (Erx<=_rNoKey) and
    (WoF.Akt.Nummer=WoF.Sch.Nummer) and (WoF.Akt.Kontext=vAkt) do begin

    // Aktivität OHNE Bedingungen suchen...
    if (RecLinkinfo(942,941,1,_recCOunt)<>0) then CYCLE;

    if ((aUser='') and
      ((WoF.Akt.anBesitzerYN) and (vOwner='')) and
      ((WoF.Akt.anSelberYN) and (gUserName='')) and
      (WoF.Akt.anUser1='') and
      (WoF.Akt.anUser2='') and
      (WoF.Akt.anUser3='')) then begin
      aUser # Usr_Main:ChooseUser();
      if (aUser='') then begin
// 2023-03-28 AH woher??        TRANSBRK;
        RETURN false;
      end;
    end;

    TRANSON;

//debug('STARTE :'+wof.akt.name);

    // Dateibezogene Daten bestimmen...  neu 16.06.2016 AH:
    if (aKey='') then
      GetData(WoF.Akt.Nummer, aDatei, var vAkt, var vTyp, var vOwner, var vText, var vText2, var vID1, vAr vID2, var vID3);
//      vText # '';

    if (WoF.Akt.Text<>'') then vText2 # WoF.Akt.Text;

    if (vText<>'') then vText # vText + ':';
    if (aNotiText<>'') then vText # vText + aNotiText
    else vText # vText + WoF.Akt.Name;

    // ganz neuen Workflow einstartn...
    if (aTemBem='') then
      vOK # NewWF(vText, vText2, aDatei, 0, var vWofNr, false, aKey)
    else
      vOK # NewWF(vText, aTemBem, aDatei, 0, var vWofNr, false, aKey);

    if (vOK=false) then begin
      TRANSBRK;
  if (gUserGroup<>'SOA_SERVER') and (gUserGroup<>'JOB-SERVER') then
todo('workflow nicht startbar!!!');
      RETURN false;
    end;

    
    if (WoF.Sch.Datei=122) then begin
      AddDatei(Tem.Nummer, 122,vID1, vID2, vID3);
    end;

    if (WoF.Sch.Datei=400) then begin
      //AddDatei(Tem.Nummer, 400,vID1, vID2);
      AddDatei(Tem.Nummer, 401,vID1, vID2);
    end;
    if (WoF.Sch.Datei=401) then begin
      AddDatei(Tem.Nummer, 401,vID1, vID2);
    end;
    if (WoF.Sch.Datei=500) then begin
      AddDatei(Tem.Nummer, 501,vID1, vID2);
    end;
    if (WoF.Sch.Datei=501) then begin
      AddDatei(Tem.Nummer, 501,vID1, vID2);
    end;
    if (WoF.Sch.Datei=540) then begin
      AddDatei(Tem.Nummer, 540,vID1, vID2);
    end;
    if (WoF.Sch.Datei=916) then begin
      AddDatei(Tem.Nummer, 916,vID1, vID2);
    end;

    if (aUser<>'') then begin
      AddUser(Tem.Nummer, aUser, aWie);
    end;
    if (WoF.Akt.anBesitzerYN) then begin
      AddUser(Tem.Nummer, vOwner, WoF.Akt.anBesitz.Wie);
    end;
    if (WoF.Akt.anSelberYN) then begin
      AddUser(Tem.Nummer, gUserName, WoF.Akt.anSelber.Wie);
    end;
    if (WoF.Akt.anUser1<>'') then begin
      AddUser(Tem.Nummer, WoF.Akt.anUser1, WoF.Akt.anUser1.Wie);
    end;
    if (WoF.Akt.anUser2<>'') then begin
      AddUser(Tem.Nummer, WoF.Akt.anUser2, WoF.Akt.anUser2.Wie);
    end;
    if (WoF.Akt.anUser3<>'') then begin
      AddUser(Tem.Nummer, WoF.Akt.anUser3, WoF.Akt.anUser3.Wie);
    end;

    TRANSOFF;

  END;


  RETURN true;
end;


//========================================================================
//  NewWF
//
//========================================================================
sub NewWF(
  aName     : alpha(1250);
  aText     : alpha(1250);
  aDatei    : int;
  aVorg     : int;    // 16.06.2016 kein OPT mehr
  var aWof  : int;
  opt aOhnePlan : logic;
  opt aKey  : alpha;
  ) : logic;
local begin
  vDate : CalTime;
  vTmp  : int;
end;
begin
  aName # StrCut(aName, 1,250);
  aText # StrCut(aText, 1,250);

  vDate->vpdate # today;
  vDate->vptime # now;
  RecBufClear(980);
  TeM.Nummer # Lib_Nummern:ReadNummer('Termin');    // Nummer lesen
  if (TeM.Nummer=0) then RETURN false;
  Lib_Nummern:SaveNummer();                         // Nummernkreis aktuallisiern
  TeM.Start.Von.Datum   # vDate->vpdate;
  TeM.Start.Von.Zeit    # vDate->vpTime;
  TeM.Start.Bis.Datum   # TeM.Start.Von.Datum;
  TeM.Start.Bis.Zeit    # TeM.Start.Von.Zeit;
  vDate->vmDayModify(WoF.Akt.MaxDauerTage);
  vDate->vmSecondsModify(WoF.Akt.MaxDauerH * 60 * 60);
//  vDate->vmSecondsModify(1 * 60);
  TeM.Ende.Von.Datum    # vDate->vpdate;
  TeM.Ende.Von.Zeit     # vDate->vpTime;
  TeM.Ende.Bis.Datum    # TeM.Ende.Von.Datum;
  TeM.Ende.Bis.Zeit     # TeM.Ende.Von.Zeit;
//TeM.Start.Von.Datum   # TeM.Ende.Bis.Datum;
//TeM.Start.Von.Zeit    # TeM.Ende.Bis.Zeit;
//TeM.Start.Bis.Datum   # TeM.Ende.Bis.Datum;
//TeM.Start.Bis.Zeit    # TeM.Ende.Bis.Zeit;
  "TeM.WoF.VorgängerTem"  # aVorg;
  TeM.WoF.SchemaNr      # WoF.Akt.Nummer;
  TeM.WoF.Kontext       # WoF.Akt.Kontext;
  TeM.WoF.Position      # WoF.Akt.Position;
  TeM.WoF.Datei         # aDatei;

  TeM.WoF.Key           # aKey;
  if (aDatei<>0) AND (aDatei <> 999) then
    TeM.WoF.Key         # Lib_Rec:MakeKey(aDatei,y);

  TeM.Anlage.Datum      # Today;
  TeM.Anlage.Zeit       # Now;
  TeM.Anlage.User       # gUserName;
  TeM.Typ               # 'WOF';
  TeM.Bezeichnung       # StrCut(aName,1,64);
  TeM.Bemerkung         # StrCut(aText,1,250);
  TeM.SichtbarPlanerYN  # aOhnePlan=false;
  TeM.PrivatYN          # n;
  TeM.Erledigt.User     # '';

  // Dauer errechnen
  TeM.Dauer # 0.0;
  if (TeM.Start.Von.Datum<>0.0.0) and (TeM.Ende.Von.Datum<>0.0.0) then begin
    vTmp # (CnvID(TeM.Start.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Start.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp);
    vTmp # (CnvID(TeM.Ende.Von.Datum) - cnvid(1.1.2000)) * 24 * 60;
    vTmp # vTmp + (Cnvit(TeM.Ende.Von.Zeit)/60000);
    TeM.Dauer # CnvFI(vTmp) - TeM.Dauer;
  end;

  if (aWof=0) then begin
    aWof # Lib_Nummern:ReadNummer('Workflow');    // Nummer lesen
    if (aWof=0) then RETURN false;
    Lib_Nummern:SaveNummer();                         // Nummernkreis aktuallisiern
  end;
  TeM.WoF.Nummer # aWof;

  if (RekInsert(980,0,'AUTO')<>_rOK) then RETURN false;

  // 06.05.2019
  if (WoF.Akt.Prozedur<>'') then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      Call(Wof.Akt.Prozedur,'START');
    end;
  end;

  RETURN true;
end;


//========================================================================
// SendEmailToUser
//========================================================================
sub SendEmailToUser(aUser : alpha)
local begin
  Erx   : int;
  v800  : int;
  vTxt  : int;
end;
begin
  v800 # RecBufCreate( 800 );
  v800->Usr.Username # aUser;
  if ( RecRead( v800, 1, 0 ) <= _rLocked ) and ( v800->Usr.eMail<>'') then begin
    vTxt # TextOpen(20);
    TextAddLine(vTxt, 'Bemerkung:');
    TextAddLine(vTxt, TeM.Bemerkung);
    TextAddLine(vTxt, '');
    if (TeM.Ende.Bis.Datum<>0.0.0) then begin
      TextAddLine(vTxt, 'Bitte erledigen bis '+cnvad(TeM.Ende.Bis.Datum)+', '+cnvat(TeM.Ende.Bis.Zeit)+' Uhr!');
      TextAddLine(vTxt, '');
    end;
    TextAddLine(vTxt, 'Erhalten von '+TeM.Anlage.User+' mit Nr. '+aint(TeM.Nummer))

    Erx # Dlg_EMail:SmtpMail(vTxt, 0, v800->Usr.eMail, TeM.Typ+':'+TeM.Bezeichnung, 0);
    if (Erx<0) then debugx('Error SmptMail:'+aint(Erx));
    TextClose(vTxt);
  end;
  RecBufClear(v800);
end;


//========================================================================
//  AddOneUser
//
//========================================================================
sub AddOneUser(
  aUser       : alpha(200);
  aWie        : alpha;
) : logic;
local begin
  Erx         : int;
  vA          : alpha;
  vOK         : logic;
  v800        : int;
  vCount      : int;
end;
begin

  if (aUser='') then RETURN false;

  RecBufClear(981);
  TeM.A.Nummer      # TeM.Nummer;
  TeM.A.Code        # aUser;
  TeM.A.Datei       # 800;
  TeM.A.Start.Datum # today;
  TeM.A.Start.Zeit  # now;
  TeM.A.lfdNr       # 1;
  TeM.A.EventErzeugtYN # y;
  vA # Usr.Username;

  // 18.04.2019 AH: auch per Email? NICHT an Vertretung!
  if (aWie='E') or (aWie='e') then begin
    SendEmailToUser(aUser);
  end;

  // 29.11.2016 AH: Vertretungsuer
  vOK # false;
  v800 # RecBufCreate(800);
  v800->Usr.Username # aUser;
  Erx # RecRead(v800,1,0);
  WHILE (Erx<=_rLocked) and
    (v800->Usr.Vertretunguser<>'') and
    (today>=v800->Usr.VertretungVonDat) and (today<=v800->Usr.VertretungBisDat) do begin
    inc(vCount);
    if (vCount>10) then BREAK;    // gegen Zirkelbezüge
    aUser # v800->Usr.Vertretunguser;
    v800->Usr.Username # aUser;
    Erx # RecRead(v800,1,0);
  END;
  RecBufDestroy(v800);

  Usr.Username # aUser;

  if (aWie='e') then    // NUR per email
    TeM_A_Data:Anker(800, 'AUTO', true)
  else
    TeM_A_Data:Anker(800, 'AUTO');

  Usr.Username # vA;

  RETURN true;
end;


//========================================================================
// AddGruppe
//========================================================================
sub AddGruppe(
  aUser       : alpha(200);
  aWie        : alpha;
) : logic;
local begin
  Erx         : int;
  vA          : alpha;
end
begin
  vA # Usr.Username;

  FOR Erx # RecLink(802,801,1,_recFirst)
  LOOP Erx # RecLink(802,801,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Usr.Username # "Usr.U<>G.User";
    Erx # RecRead(800,1,0);
    if (erx<=_rLockeD) then AddOneUser("Usr.U<>G.User", aWie);
  END;

  Usr.Username # vA;

  RETURN true;
end;


//========================================================================
//  AddUser
//
//========================================================================
sub AddUser(
  aTeM        : int;
  aUser       : alpha(200);
  aWie        : alpha;
) : logic;
local begin
  Erx         : int;
end;
begin

  if (aUser='') then RETURN false;

  if (aTem<>TeM.Nummer) then begin
    TeM.Nummer  # aTeM;
    Erx # RecRead(980,1,_RecTest);
    if (Erx>_rLocked) then RETURN false;
  end;

  Usr.Grp.Gruppenname # aUser;
  Erx # recRead(801,1,0);
  if (erx<=_rLocked) then begin
    RETURN AddGruppe(aUser, aWie);
  end;

  RETURN AddOneUser(aUser, aWie);
end;


//========================================================================
//  AddDatei
//
//========================================================================
sub AddDatei(
  aTeM        : int;
  aDatei      : int;
  aID1        : int;
  aID2        : int;
  opt aID3    : word;
) : logic;
local begin
  Erx : int;
end;
begin

  if (aTem<>TeM.Nummer) then begin
    TeM.Nummer  # aTeM;
    Erx # RecRead(980,1,_RecTest);
    if (Erx>_rLocked) then RETURN false;
  end;

  RecBufClear(981);
  TeM.A.Nummer      # aTeM;
//  TeM.A.Code        # aUser;
  TeM.A.Datei       # aDatei;
  TeM.A.ID1         # aID1;
  TeM.A.ID2         # aID2;
  TeM.A.ID3         # aID3;
  TeM.A.Start.Datum # today;
  TeM.A.Start.Zeit  # now;
  TeM.A.lfdNr       # 1;
//  REPEAT
//    Erx # TeM_A_Data:Insert(0,'AUTO');
//    if (Erx<>_rOK) then inc(TeM.A.lfdNr);
//  UNTIl (Erx=_rOK);
  TeM_A_Data:Anker(aDatei, 'AUTO');

  RETURN true;
end;



//========================================================================
//========================================================================
sub AddIDsToTem(
  aDatei  : int;
  aID1    : int;
  aID2    : int)
begin
  if (aDatei=400) then begin
    //AddDatei(Tem.Nummer, 400,vID1, vID2);
    AddDatei(Tem.Nummer, 401, aID1, aID2);
  end;
  if (aDatei=401) then begin
    AddDatei(Tem.Nummer, 401, aID1, aID2);
  end;
  if (aDatei=500) then begin
    AddDatei(Tem.Nummer, 501, aID1, aID2);
  end;
  if (aDatei=501) then begin
    AddDatei(Tem.Nummer, 501, aID1, aID2);
  end;
  if (aDatei=540) then begin
    AddDatei(Tem.Nummer, 540, aID1, aID2);
  end;
  if (aDatei=916) then begin
    AddDatei(Tem.Nummer, 916, aID1, aID2);
  end;
end;


//========================================================================
//  sub SkipUNDs(aWofNr : int) : logic
//    Prüft ob die Bedingungen des geladenen Workflowschemas "Verundet"
//    betrachtet werden müssen und prüft entsprechend alle "TEM Rückmeldungen"
//
//========================================================================
sub SkipUNDs(aWofNr : int) : logic
local begin
  Erx   : int;
  vRet  : logic;
  v941  : int;
  v942  : int;
  v980  : int;

  vBedNurUnd : logic;
  vBedCheckCnt : int;
  vBedCheckCntSoll : int;
end
begin

  // bin im Nachfolger!!

  // 07.11.2018 AH:
  if (StrFind(WoF.Akt.Name,'[UND]',1) = 0) and (Wof.Akt.Bed.UND=false) then RETURN false; // NORMAL weiter machen

  vRet # false;
  v941 # RekSave(941);
  v942 # RekSave(942);

  // Workflowpositionsbedingungen UND Bedingung?
  if (StrFind(WoF.Akt.Name,'[UND]',1) > 0) or (Wof.Akt.Bed.UND) then begin
    // Bedingungen auf "nur" Verundungen prüfen
    vBedNurUnd # true;
    FOR  Erx # RecLink(942,941,1,_RecFirst)
    LOOP Erx # RecLink(942,941,1,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (WoF.Bed.VonStatus <> 'Y') then begin
        vBedNurUnd # false;
        BREAK;
      end;
    END;
  end;

  // Prüfung auf Reaktionen mit "IO" in Terminen
  if (vBedNurUnd) then begin
    v980 # RekSave(980);
    vRet # true;
    vBedCheckCnt      # 0;    // Geprüfte Aktionen zählen um fehlende Rückmeldungen zu erkennen
    vBedCheckCntSoll  # RecLinkInfo(942,941,1,_RecCount);

    // Alle Bedingungen  prüfen...
    FOR   Erx # RecLink(942,941,1,_RecFirst)
    LOOP  Erx # RecLink(942,941,1,_RecNext)
    WHILE (Erx <= _rLocked) DO BEGIN

      // Alle Aktionen lesen für Bedingung prüfen
      TeM.WoF.Nummer # aWofNr;
      FOR   Erx # RecRead(980,5,0);
      LOOP  Erx # RecRead(980,5,_RecNext);
      WHILE Erx <= _rMultikey DO BEGIN

        // Nur Aktionen prüfen, die zur Bedingung passen
        if (TeM.WoF.Position = WoF.Bed.VonPosition) AND
           (TeM.WoF.Kontext = WoF.Bed.Kontext) then begin

          inc(vBedCheckCnt);

          if (TeM.InOrdnungYN = false) then begin
            vRet # false;
            BREAK;
          end;

        end;
        // Nächster "TEM"
      END;

      // Nächste Bedingung
    END;
    RekRestore(v980);

    // Wenn noch nicht alle positiv geantwortet haben, kein Erfolg
    if (vBedCheckCnt <> vBedCheckCntSoll) then
      vRet # false;
  end;

  RekRestore(v941);
  RekRestore(v942);
  RETURN !vRet;
end;


//========================================================================
//  DynsmischerWof
//
//========================================================================
sub DynamischerWOF(
  aDatei      : int;
  aUser       : alpha;
  aTemBem     : alpha(4000);
  opt aVorg   : int;
  opt aWofNr  : int) : logic;
local begin
  vText   : alpha(250);
  vText2  : alpha(250);
  vOK     : logic;
  vWofNr  : int;

  vOwn    : alpha;
  vID1    : int;
  vID2    : int;
  vID3    : int;
end;
begin
//debugx('start DynWof für'+aint(aDatei)+' vorg:'+aint(aVorg));

//  if (gUserGroup<>'SOA_SERVER') and (gUserGroup<>'JOB-SERVER') then
//    if (StrFind(Set.Module,'W',0)=0) then RETURN false;

  aUser     # StrCut(aUser,1,32);
  aTemBem   # StrCut(aTemBem, 1, 250);

  // User auswählen?
  if (aUser='') then begin
    aUser # Usr_Main:ChooseUser();
    if (aUser='') then RETURN false;
  end;

  if (aTemBem='') then begin
    if (Dlg_Standard:Standard(translate('Text'), var aTemBem, n, 250)=false) then RETURN false;
  end;

  TRANSON;

  // Dateibezogene Daten bestimmen...
  GetIDs(aDatei, '', var vOwn, var vID1, var vID2, var vID3, var vText, var vText2);

  // ganz neuen Workflow einstartn...
  RecBufClear(940);   // KEIN SCHEMA !!!
  RecBufClear(941);
  vWofNr # aWofNr;

  if (aTemBem='') then
    vOK # NewWF(vText, vText2, aDatei, aVorg, var vWofNr, true);
  else
    vOK # NewWF(vText, aTemBem, aDatei, aVorg, var vWofNr, true);

  if (vOK=false) then begin
    TRANSBRK;
  if (gUserGroup<>'SOA_SERVER') and (gUserGroup<>'JOB-SERVER') then
todo('dynworkflow nicht startbar!!!');
    RETURN false;
  end;

  AddIDsToTem(aDatei, vID1, vID2);

  AddUser(Tem.Nummer, aUser, cStdBenachrichtigungstyp);

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  NextWOF
//
//========================================================================
sub NextWOF(
  aStatus : alpha;
) : logic;
local begin
  erx     : int;
  v980    : handle;
  v980b   : handle;
  v941    : handle;
  vAkt    : int;
  vTyp    : alpha;
  vOwner  : alpha;
  vText   : alpha(250);
  vText2  : alpha(250);
  vID1    : int;
  vID2    : int;
  vID3    : int;
  vWofNr  : int;

  vUseAND   : logic;
  vOK       : logic;
end;
begin
//debugx('NextWOF:'+aint(Tem.Wof.SchemaNr));
  // DYNAMISCHER WOF?
  if (Tem.Wof.SchemaNr=0) then begin
    // zugehörigen Datensatz holen
    if (Tem.WoF.Datei<>0) then begin
      if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)>_rOK) then RecBufClear(Tem.WoF.Datei);
    end;
    v980 # RekSave(980);
//    vOK # DynamischerWof(Tem.Wof.Datei, '', 'Zurück', Tem.Nummer, TeM.WoF.Nummer);

    // 14.03.2022 AH
    vText # Translate('Zurück');
    if (aStatus='Y') then
      vText # vText + ': '+Translate('i.O.')+': '+TeM.Bemerkung
    else if (aStatus='N') then
      vText # vText + ': '+Translate('nicht i.O.')+': '+TeM.Bemerkung
    else
      vText # vText + ': '+Translate('Timeout')+': '+TeM.Bemerkung
    vOK # DynamischerWof(Tem.Wof.Datei, '', vText, Tem.Nummer, TeM.WoF.Nummer);

    RekRestore(v980);
    RETURN vOK;
  end;


  WoF.Sch.Nummer  # TeM.WoF.SchemaNr;
  Erx # RecRead(940,1,0);   // Workflow holen
  if (Erx>_rLocked) then RETURN false;

  WoF.Akt.Nummer    # WoF.Sch.Nummer;
  WoF.Akt.Kontext   # TeM.WoF.Kontext;
  WoF.Akt.Position  # TeM.WoF.Position;
  Erx # RecRead(941,1,0);   // Aktivität holen
  if (Erx>_rLocked) then RETURN false;

  vWOFNr # TeM.Wof.Nummer;

  // 06.05.2019
  if (WoF.Akt.Prozedur<>'') then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      Call(Wof.Akt.Prozedur,aStatus);
    end;
  end;

  TRANSON;

  FOR Erx # RecLink(942,941,2,_RecFirst)  // nachfolgende Bed. holen
  LOOP Erx # RecLink(942,941,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    if (aStatus<>WoF.Bed.VonStatus) then CYCLE;

    vAkt # TeM.WoF.Kontext;
    v980 # Reksave(980);
    v941 # Reksave(941);
    Erx # Reclink(941,942,2,_recFirst);   // Nachfolger holen
    if (Erx<=_rLocked) then begin

      // ST 2018-02-13 Projekt 1630/3551 "Verundung" der Bedingungen prüfen
      if (SkipUNDs(vWOFNr)) then
        CYCLE;

      // zugehörigen Datensatz holen
      if (Tem.WoF.Datei<>0) then begin
        if (Lib_Rec:ReadByKey(TeM.WoF.Datei, TeM.Wof.Key)>_rOK) then RecBufClear(Tem.WoF.Datei);
//debugx('KEY401   '+auf.p.Kundensw);
      end;

      // Dateibezogene Daten bestimmen...
      GetData(WoF.Akt.Nummer, TeM.WoF.Datei, var vAkt, var vTyp, var vOwner, var vText, var vText2, var vID1, vAr vID2, var vID3);

      if (WoF.Akt.Text<>'') then vText2 # WoF.Akt.Text;

      // nächsten Schritt starten...
// "NEU Auf.100706:alles Prima"
//debugx(vText+':'+WoF.Akt.Name+'|'+vText2+'|'+aint(TeM.WoF.Datei)+'|'+aint(v980->TeM.Nummer));
      if (NewWF(vText+':'+WoF.Akt.Name, vText2, TeM.WoF.Datei, v980->TeM.Nummer, var vWofNr)=false) then begin
        TRANSBRK;
  if (gUserGroup<>'SOA_SERVER') and (gUserGroup<>'JOB-SERVER') then
todo('workflow nicht startbar!!!');
        RETURN false;
      end;

      // Alle Anhänge verknüpfen
      Anh_Data:Copyall(v980, 980, n, y);

      AddIDsToTem(Wof.Sch.Datei, vID1, vID2);

      if (WoF.Akt.anBesitzerYN) then begin
        // kein aktueller Dateibesitzer? -> dann erster Auslöser des WOF suchen...
        if (vOwner='') then begin
          v980b # RecBufCreate(980);
          v980b->TeM.Nummer # v980->Tem.Nummer;
          Erx # RecRead(v980b,1,0);
          WHILE (Erx<=_rLocked) and (v980b->"Tem.WoF.VorgängerTem"<>0) do begin
            v980b->TeM.Nummer # v980b->"Tem.WoF.VorgängerTeM";
            Erx # RecRead(v980b,1,0);
          END;
          vOwner # v980b->TeM.Anlage.User;
          RecBufDestroy(v980b);
        end;
        AddUser(Tem.Nummer, vOwner, WoF.Akt.anBesitz.Wie);
      end;
      if (WoF.Akt.anSelberYN) then    AddUser(Tem.Nummer, gUserName, WoF.Akt.anSelber.Wie);
      if (WoF.Akt.anUser1<>'') then   AddUser(Tem.Nummer, WoF.Akt.anUser1, WoF.Akt.anUser1.Wie);
      if (WoF.Akt.anUser2<>'') then   AddUser(Tem.Nummer, WoF.Akt.anUser2, WoF.Akt.anUser2.Wie);
      if (WoF.Akt.anUser3<>'') then   AddUser(Tem.Nummer, WoF.Akt.anUser3, WoF.Akt.anUser3.Wie);
    end;

    RekRestore(v941);
    RekRestore(v980);
  END;

  TRANSOFF;

  vAkt # TeM.WoF.Position;
  // Dateibezogene Daten bestimmen...
//  GetData(TeM.WoF.Nummer, TeM.WoF.Datei, var vAkt, var aTyp, var vOwner, var vText, var vText2);

  RETURN true;
end;


//========================================================================
//  AuswahlWof
//
//========================================================================
sub AuswahlWOF(aDatei : int)
local begin
  Erx   : int;
  vQ    : alpha(4000);
  vHdl  : int;
end;
begin
  RecBufClear(940);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'WoF.Sch.Verwaltung',here+':_AusWOF');

  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Wof.Sch.Datei', '=', aDatei);
  vHdl # SelCreate(940, 1);
  Erx # vHdl->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vHdl);
  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  _ausWoF
//========================================================================
sub _ausWOF();
begin
  if (gSelected=0) then RETURN;

  RecRead(940,0,_RecId,gSelected);
  gSelected # 0;

  Trigger(WoF.Sch.Datei, Wof.Sch.Nummer, '');

end;


//========================================================================
//  RemoveAll
//
//========================================================================
Sub RemoveAll(aDatei : int) : logic;
local begin
  Erx   : int;
  vKey  : alpha;
end;
begin
  vKey # Lib_Rec:MakeKey(aDatei, y);
  Tem.WoF.Datei # aDatei;
  Tem.WoF.Key   # vKey;
  Erx # RecRead(980,6,0);
  WHILE (Erx<=_rMultikey) and (Tem.WoF.Datei=aDatei) and (Tem.WoF.Key=vKey) do begin
    //if (Tem.InOrdnungYN=false) and (Tem.NichtInOrdnungYN=false) then begin
    if (TeM.Typ='WOF') and (Tem.Erledigt.Datum=0.0.0) then begin
      RecRead(980,1,_recLock);
//      Tem.InOrdnungYN       # true;
//      Tem.NichtInOrdnungYN  # true;
      TeM.Erledigt.Datum  # today;
      RekReplace(980);
      Lib_Notifier:RemoveAllEvents('980/'+AInt(TeM.Nummer), 0);
      Lib_Notifier:RemoveAllEvents('980',TeM.Nummer);
    end;
    Erx # RecRead(980,6,_recNext);
  END;

end;


//========================================================================
// TriggerWorkFlow
//========================================================================
sub TriggerWorkFlow(aIssuer : int; aWorkflowNr : int; opt aBemtext : alpha(1000)) : int
local begin
  Erx     : int;
  vWofNr  : int;
  vWofPos : int;
  vTemBuf : int;
end
begin
  Trigger(aIssuer, aWorkflowNr,'');

  if (aBemtext = '') then
    RETURN 0;

  vWofNr  # TeM.WoF.Nummer;
  FOR   Erx # RecRead(980,5,0)
  LOOP  Erx # RecRead(980,5,_RecNext)
  WHILE (Erx <= _rMultikey) AND (vWofNr  = TeM.WoF.Nummer) DO BEGIN
    vTemBuf # RekSave(980);
    RecRead(980,1,_recLock);
    TeM.Bemerkung # StrCut(aBemText,1,192);
    RekReplace(980);
    RekRestore(vTemBuf);
  END;

  RETURN vWofNr;
end;




/***
//========================================================================
//  Dialog
//
//========================================================================
sub xxxDialog();
begin
end;
***/

//========================================================================
