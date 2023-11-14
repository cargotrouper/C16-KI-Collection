@A+
//==== Business-Control ==================================================
//
//  Prozedur    Obf_Data
//                    OHNE E_R_G
//  Info
//
//
//  28.05.2008  AI  Erstellung der Prozedur
//  22.10.2010  AI  NEU: BildeAFString
//  26.10.2010  AH  EDIT: BildeAFString
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Import_TSR()
//    SUB SetKuerzel(aNewKuerzel : alpha)
//    SUB BildeAFSTring(aDatei : int; aSeite : alpha) : alpha
//
//========================================================================
@I:Def_Global


define begin
  ErrorDlg(a,b) : begin     TRANSBRK;     Msg(999999,a+' konnte nicht gespeichert werden! Wahrscheinlich gesperrt durch: ' + UserInfo(_UserName,RecInfo(b,_recLockedBy)),0,0,0);       end;

  GetAlphaUp(a,b) : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  GetAlpha(a,b)   : a # FldAlphabyName('X_'+b);
  GetInt(a,b)     : a # FldIntbyName('X_'+b);
  GetWord(a,b)    : a # FldWordbyName('X_'+b);
  GetNum(a,b)     : a # FldFloatbyName('X_'+b);
  GetBool(a,b)    : a # FldLogicbyName('X_'+b);
  GetDate(a,b)    : a # FldDatebyName('X_'+b);
  GetTime(a,b)    : a # FldTimebyName('X_'+b);

  d_AF_Seite        : FldAlpha(vZiel,1,vOff+0)
  d_AF_lfdNr        : FldWord(vZiel,1,vOff+1)
  d_AF_ObfNr        : FldWord(vZiel,1,vOff+2)
  d_AF_Bezeichnung  : FldAlpha(vZiel,1,vOff+3)
  d_AF_Zusatz       : FldAlpha(vZiel,1,vOff+4)
  d_AF_Bemerkung    : FldAlpha(vZiel,1,vOff+5)
  d_AF_Kurz         : FldAlpha(vZiel,1,vOff+6)
end;

declare BildeAFString(aDatei : int; aSeite : alpha) : alpha

//========================================================================
//  SetKuerzel
//
//
//========================================================================
sub SetKuerzel(aNewKuerzel : alpha)
local begin
  Erx   : int;
  vAFNr : int;
  vBuf  : int;
end;
begin
  TRANSON;

  // Oberflaeche lesen
  Erx # RecRead(841,1,0 | _recLock);
  if(Erx = _rOK) then begin
    "Obf.Kürzel" # aNewKuerzel;
    Erx # RekReplace(841,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('841',841);
    end;

  end;


  // Adressen.V.Ausfuehrung
  Erx # RecLink(106,841,1,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
    "Adr.V.AF.Kürzel" # aNewKuerzel;
    Erx # RekReplace(106,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('106',106);
    end;

    if(Adr.V.AF.Adressnr > 999999999) then begin
      Erx # RecLink(106,841,1,_recNext | _recLock);
      CYCLE;
    end;

    Adr.V.Adressnr # Adr.V.AF.Adressnr;
    Adr.V.lfdNr    # Adr.V.AF.Verpacknr;
    Erx # RecRead(105,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(106);
      Adr.V.AusfOben  # BildeAFString(105,'1');
      Adr.V.AusfUnten # BildeAFString(105,'2');
      RekRestore(vBuf);
      Erx # RekReplace(105,_recUnlock,'AUTO');
      if(Erx <> _rOK) then
        ErrorDlg('Adresse ' + AInt(Adr.V.AF.Adressnr),105);
    end
    else
      ErrorDlg('Adresse ' + AInt(Adr.V.AF.Adressnr),105);



    Erx # RecLink(106,841,1,_recNext | _recLock);
  END;

  // Material Ausfuehrung
  Erx # RecLink(201,841,2,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
    "Mat.AF.Kürzel" # aNewKuerzel;
    Erx # RekReplace(201,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('201',201);
    end;

    if(Mat.AF.Nummer > 999999999) then begin
      Erx # RecLink(201,841,2,_recNext | _recLock);
      CYCLE;
    end;

    Mat.Nummer # Mat.AF.Nummer;
    Erx # RecRead(200,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(201);
      "Mat.AusführungOben"  # BildeAFString(200,'1');
      "Mat.AusführungUnten" # BildeAFString(200,'2');
      RekRestore(vBuf);
      Erx # RekReplace(200,_recUnlock,'AUTO');
      if(Erx <> _rOK) then
        ErrorDlg('Material ' + AInt(Mat.AF.Nummer),200);
    end
    else begin
      "Mat~Nummer" # Mat.AF.Nummer;
      Erx # RecRead(210,1,0 | _recLock);
      if(Erx <= _rLocked) then begin
        vBuf # RekSave(201);
        RecBufCopy(210,200);
        "Mat~AusführungOben"  # BildeAFString(200,'1');
        "Mat~AusführungUnten" # BildeAFString(200,'2');
        RekRestore(vBuf);
        Erx # RekReplace(210,_recUnlock,'AUTO');
        if(Erx <> _rOK) then
          ErrorDlg('~Material ' + AInt(Mat.AF.Nummer),210);
      end
      else
        ErrorDlg('(~)Material ' + AInt(Mat.AF.Nummer),0);
    end;

    Erx # RecLink(201,841,2,_recNext | _recLock);
  END;

  // Materialstrukturliste
  Erx # RecLink(221,841,3,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN

    MSL.Nummer # MSL.AF.Nummer;
    Erx # RecRead(220,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(221);
      "MSL.Ausführung.Oben" # BildeAFString(220,'1');
      "MSL.Ausführung.Unten" # BildeAFString(220,'2');
      RekRestore(vBuf);
      Erx # RekReplace(220,_recUnlock,'AUTO');
      if(Erx <> _rOK) then
        ErrorDlg('220',220);
    end;

    Erx # RecLink(221,841,3,_recNext | _recLock);
  END;


  // Auftrags Ausfuehrung
  Erx # RecLink(402,841,4,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
    "Auf.AF.Kürzel" # aNewKuerzel;
    Erx # RekReplace(402,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('402',402);
    end;


    if(Auf.AF.Nummer > 999999999) then begin
      Erx # RecLink(402,841,4,_recNext | _recLock);
      CYCLE;
    end;

    Auf.P.Nummer   # Auf.AF.Nummer;
    Auf.P.Position # Auf.AF.Position;
    Erx # RecRead(401,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(402);
      Auf.P.AusfOben  # BildeAFString(401,'1');
      Auf.P.AusfUnten # BildeAFString(401,'2');
      RekRestore(vBuf);
      Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
      if(Erx <> _rOK) then
        ErrorDlg('Auftrag ' + AInt(Auf.AF.Nummer) + '/' + AInt(Auf.AF.Position),401);
    end
    else begin
      "Auf~P.Nummer"   # Auf.AF.Nummer;
      "Auf~P.Position" # Auf.AF.Position;
      Erx # RecRead(411,1,0 | _recLock);
      if(Erx <= _rLocked) then begin
        vBuf # RekSave(402);
        RecBufCopy(411,401);
        "Auf~P.AusfOben"  # BildeAFString(401,'1');
        "Auf~P.AusfUnten" # BildeAFString(401,'2');
        RekRestore(vBuf);
        Erx # RekReplace(411,_recUnlock,'AUTO');
        if(Erx <> _rOK) then
          ErrorDlg('~Auftrag ' + AInt(Auf.AF.Nummer) + '/' + AInt(Auf.AF.Position),411);
      end
      else
        ErrorDlg('(~)Auftrag ' + AInt(Auf.AF.Nummer) + '/' + AInt(Auf.AF.Position),0);
    end;


    Erx # RecLink(402,841,4,_recNext | _recLock);
  END;

  // Bestellungs Ausfuehrung
  Erx # RecLink(502,841,5,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
    "Ein.AF.Kürzel" # aNewKuerzel;
    Erx # RekReplace(502,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('502',502);
    end;

    if(Ein.AF.Nummer > 999999999) then begin
      Erx # RecLink(502,841,5,_recNext | _recLock);
      CYCLE;
    end;

    Ein.P.Nummer   # Ein.AF.Nummer;
    Ein.P.Position # Ein.AF.Position;
    Erx # RecRead(501,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(502);
      Ein.P.AusfOben  # BildeAFString(501,'1');
      Ein.P.AusfUnten # BildeAFString(501,'2');
      RekRestore(vBuf);
      Erx # Ein_Data:PosReplace(_recUnlock,'AUTO');
      if(Erx <> _rOK) then
        ErrorDlg('Bestellung ' + AInt(Ein.AF.Nummer) + '/' + AInt(Ein.AF.Position),501);
    end
    else begin
      "Ein~P.Nummer"   # Ein.AF.Nummer;
      "Ein~P.Position" # Ein.AF.Position;
      Erx # RecRead(511,1,0 | _recLock);
      if(Erx <= _rLocked) then begin
        vBuf # RekSave(502);
        RecBufCopy(511,501);
        "Ein~P.AusfOben"  # BildeAFString(501,'1');
        "Ein~P.AusfUnten" # BildeAFString(501,'2');
        RekRestore(vBuf);
        Erx # RekReplace(511,_recUnlock,'AUTO');
        if(Erx <> _rOK) then
          ErrorDlg('~Bestellung ' + AInt(Ein.AF.Nummer) + '/' + AInt(Ein.AF.Position),511);
      end
      else
        ErrorDlg('(~)Bestellung ' + AInt(Ein.AF.Nummer) + '/' + AInt(Ein.AF.Position),0);
    end;


    Erx # RecLink(502,841,5,_recNext | _recLock);
  END;

  // Wareneingang Ausfuehrung
  Erx # RecLink(507,841,6,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
   "Ein.E.AF.Kürzel" # aNewKuerzel;
    Erx # RekReplace(507,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('507',507);
    end;

    if(Ein.E.AF.Nummer > 999999999) then begin
      Erx # RecLink(507,841,6,_recNext | _recLock);
      CYCLE;
    end;

    Ein.E.Nummer     # Ein.E.AF.Nummer;
    Ein.E.Position   # Ein.E.AF.Position;
    Ein.E.Eingangsnr # Ein.E.AF.Eingang;
    Erx # RecRead(506,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(507);
      Ein.E.AusfOben  # BildeAFString(506,'1');
      Ein.E.AusfUnten # BildeAFString(506,'2');
      RekRestore(vBuf);
      Erx # RekReplace(506,_recUnlock,'AUTO');
    end
    else
      ErrorDlg('Wareneingang ' + AInt(Ein.E.AF.Nummer) + '/' + AInt(Ein.E.AF.Position),506);


    Erx # RecLink(507,841,6,_recNext | _recLock);
  END;

  // Sammelwareneingangspos Ausfuehrung
  Erx # RecLink(622,841,7,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
   "SWe.P.AF.Kürzel"  # aNewKuerzel;
    Erx # RekReplace(622,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('622',622);
    end;


    if(SWe.P.AF.Nummer > 999999999) then begin
      Erx # RecLink(622,841,7,_recNext | _recLock);
      CYCLE;
    end;

    SWe.P.Nummer    #  SWe.P.AF.Nummer;
    SWe.P.Position  #  SWe.P.AF.Position;
    Erx # RecRead(621,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(622);
      SWe.P.AusfOben  # BildeAFString(621,'1');
      SWe.P.AusfUnten # BildeAFString(621,'2');
      RekRestore(vBuf);
      Erx # RekReplace(621,_recUnlock,'AUTO');
    end
    else
      ErrorDlg('Sammelwareneingang ' + AInt(SWe.P.AF.Nummer) + '/' + AInt(SWe.P.AF.Position),621);

    Erx # RecLink(622,841,7,_recNext | _recLock);
  END;


  // BA Ausfuehrung
  Erx # RecLink(705,841,8,_recFirst | _recLock);
  WHILE(Erx <= _rLocked) DO BEGIN
   "BAG.AF.Kürzel"  # aNewKuerzel;
    Erx # RekReplace(705,_recUnlock,'AUTO');
    if(Erx <> _rOK) then begin
       ErrorDlg('705',705);
    end;

    if(BAG.AF.Nummer > 999999999) then begin
      Erx # RecLink(705,841,8,_recNext | _recLock);
      CYCLE;
    end;

    BAG.F.Nummer    # BAG.AF.Nummer;
    BAG.F.Position  # BAG.AF.Position;
    BAG.F.Fertigung # BAG.AF.Fertigung;
    Erx # RecRead(703,1,0 | _recLock);
    if(Erx <= _rLocked) then begin
      vBuf # RekSave(705);
      BAG.F.AusfOben  # BildeAFString(703,'1');
      BAG.F.AusfUnten # BildeAFString(703,'2');
      RekRestore(vBuf);
      Erx # RekReplace(703,_recUnlock,'AUTO');
    end
    else
      ErrorDlg('BA ' + AInt(BAG.AF.Nummer) + '/' + AInt(BAG.AF.Position),703);

    Erx # RecLink(705,841,8,_recNext | _recLock);
  END;

  TRANSOFF;

end;

//========================================================================
//  Import_TSR
//
//  GetAlphaUp
//  GetAlpha
//  GetInt
//  GetWord
//  GetNum
//  GetBool
//  GetDate
//  GetTime
//========================================================================
sub Import_TSR()
local begin
  Erx   : int;
  Ansprechpartner : int;
end;
begin
  Erx # DBAConnect(2,'X_','TCP:192.168.1.245','thyssen','thomas','','');
  if (Erx<>_rOK) then begin

    TODO('DB-Fehler!' + cnvAI(Erx));
    RETURN;
  end;

  TRANSON;

  Erx # RecRead(2814,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    RecBufClear(841);

    /*
    GetInt(,'');
    GetWord(,'');
    GetAlpha(,'');
    GetNum(,'');
    GetDate(,'');
    GetBool(,'');
    */

    GetWord(Obf.Nummer ,'Obf.Nummer');
    GetAlpha(Obf.Bezeichnung.L1 ,'Obf.Bezeichnung');
    GetAlpha(Obf.Bezeichnung.L2 ,'Obf.Bezeichnung.L2');

    Erx #  RekInsert(841,0,'MAN');

    Erx # RecRead(2814,1,_recNext);
  END;

  TRANSOFF;

  DBADisconnect(2)

  Msg(99,'OBF wurden importiert!',0,0,0);
end;


//========================================================================
//  BildeAFString
//
//========================================================================
SUB BildeAFString(
  aDatei : int;
  aSeite : alpha) : alpha
local begin
  vAKurz  : alpha(1000);
  vALang  : alpha(1000);
  vCount  : int;
  vLink   : int;
  vZiel   : int;
  vOff    : int;
  vErx    : int;
  vBAGFM  : int;
  vFilter : int;
  vTyp    : alpha;
end;
begin

  // Ankerfunkton?
  if (RunAFX('Obf.BildeAFString',aint(aDatei)+'|'+aSeite)<>0) then begin
    RETURN GV.Alpha.01;
  end;


  case aDatei of
    105 : begin
      vZiel   # 106
      vLink   # 1;
      vOff    # 3;
    end;

    210,200 : begin
      vZiel   # 201;
      vLink   # 11;
      vOff    # 2;
    end;

    250 : begin
      vZiel   # 257;
      vLink   # 27;
      vOff    # 2;
    end;
    
    411,401 : begin
      vZiel   # 402;
      vLink   # 11;
      vOff    # 3;
    end;

    511,501 : begin
      vZiel   # 502;
      vLink   # 12;
      vOff    # 3;
    end;

    506 : begin
      vZiel   # 507;
      vLink   # 13;
      vOff    # 4;
    end;

    621 : begin
      vZiel   # 622;
      vLink   # 10;
      vOff    # 4;
    end;

    703 : begin     // BA-Fertigung
      vZiel   # 705;
      vLink   # 8;
      vOff    # 4;
      vBAGFM  # 0;
    end;

    707 : begin     // BA-Fertigmeldung
      vZiel   # 705;
      vLink   # 13;
      vOff    # 4;
      vBAGFM  #  BAG.FM.Fertigmeldung;
    end;

    220 : begin
/***
      vZiel   # 221;  // alles anders
      vLink   # 11;
      vOff    # 4;
***/

      vTyp # "Set.Wie.Obf.Kürzen";
//      if (vTyp='') or (vTyp='A') then
//        if (RecLinkInfo(221,220,11,_RecCount)=1) then vTyp # 'K';

      vErx # RecLink(221,220,11,_recFirst);
      WHILE (vErx<=_rLocked) do begin

        if (MSL.AF.Seite=aSeite) then begin
          inc(vCount)
          vErx # RecLink(841,221,1,_recFirst);    // OBF holen
          if (vErx > _rLocked) then RecBufClear(841);
          if ("Obf.Kürzel"<>'') then begin
            if (vAKurz<>'') then vAKurz # vAKurz + ',';
            vAKurz # vAKurz + "Obf.Kürzel";
          end;
          if ("Obf.Bezeichnung.L1"<>'') then begin
            if (vALang<>'') then vALang # vALang + ',';

            vALang # vALang + "Obf.Bezeichnung.L1";
          end;
        end;

        vErx # RecLink(221,220,11,_recNext);
      END;

      if (vTyp='K') then RETURN StrCut(vAKurz,1,32);
      if (vTyp='L') then RETURN StrCut(vALang,1,32);
      if (vCount<=1) then RETURN StrCut(vALang,1,32)
      else RETURN StrCut(vAKurz,1,32);
    end;
  end;



  // BA-Filter?
  if (vZiel=705) then begin
    vFilter # RecFilterCreate(705,1);
    vFilter->RecFilterAdd(4,_FltAND,_FltEq, vBAGFM);
  end;


  vTyp # "Set.Wie.Obf.Kürzen";
//  if (vTyp='') or (vTyp='A') then
//    if (RecLinkInfo(vZiel,aDatei,vLink,_RecCount)=1) then vTyp # 'K';

  vErx # RecLink(vZiel, aDatei, vLink,_recFirst, vFilter);
  WHILE (vErx<=_rLocked) do begin

    if (d_AF_Seite=aSeite) then begin
      inc(vCount)
      if (d_AF_Kurz<>'') then begin
        if (vAKurz<>'') then vAKurz # vAKurz + ',';
        vAKurz # vAKurz + d_AF_Kurz+ d_AF_Zusatz;
      end;
      if (d_AF_Bezeichnung<>'') then begin
        if (vALang<>'') then vALang # vALang + ',';
        vALang # vALang + d_AF_Bezeichnung + d_AF_Zusatz;
      end;
    end;

    vErx # RecLink(vZiel, aDatei, vLink,_recNext, vFilter);
  END;

  if (vFilter<>0) then RecFilterDestroy(vFilter);

  if (vTyp='K') then RETURN StrCut(vAKurz,1,32);
  if (vTyp='L') then RETURN StrCut(vALang,1,32);
  if (vCount<=1) then RETURN StrCut(vALang,1,32)
  else RETURN StrCut(vAKurz,1,32);
end;


//========================================================================
//========================================================================