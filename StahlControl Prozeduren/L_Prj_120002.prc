@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Prj_120002
//                    OHNE E_R_G
//  Info
//        Liste: Projektplan extern
//
//  26.09.2007  MS  Erstellung der Prozedur
//  06.02.2009  ST  Bezugsprojekt: "Resultiert aus" wird ggf. mitgedruckt
//  08.04.2010  PW  Neuer Listenstil
//  24.06.2019  AH  SubPositionen
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    sub Element (aName : alpha; aPrint : logic);
//    sub SeitenKopf (aSeite : int);
//    sub SeitenFuss (aSeite : int);
//    sub StartList (aSort : int; aSortName : alpha);
//=========================================================================
@I:Def_Global
@I:Def_List2
declare StartList (aSort : int; aSortName : alpha);

local begin
  lf_Empty   : handle;
  lf_Prj1    : handle;
  lf_Prj2    : handle;
  lf_Header  : handle;
  lf_Line    : handle;
  lf_Summe   : handle;
  lf_ZeitSum : handle;
  lf_MiscH   : handle;
  lf_Misc    : handle;
  lf_MiscE   : handle;
  lf_InternH : handle;
  lf_InternL : handle;
  lf_InternS : handle;
  lf_InternG : handle;
  lf_InternA : handle;
  lf_ZusatzK : handle;
  lf_ZusKSum : handle;

  vTxtHdl    : int;
  vLines     : int;
  vLine      : int;
  vHdl       : handle;
  vTree      : handle;
  vItem      : handle;
  vUser      : alpha;
  vMFile     : int;
  vMID       : int;
  vMark      : logic;
end;


define begin
  cSumGesZusatzKosten : 10
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  if (Mode=c_ModeList) and (gFile<>0) and (gZLList<>0) then RecRead(gFile,0,0,gZLList->wpdbrecid);

  StartList(0, '');
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element (aName : alpha; aPrint : logic);
local begin
  vA : alpha(500);
end;
begin
  case aName of
    'projekt-1' : begin
      if (aPrint) then begin
        LF_Text(1, 'Projekt: ' + CnvAI(Prj.Nummer) + ', ' + Prj.Stichwort);
        if (RecLink(100, 120, 1, _recFirst) <= _rLocked) then
          LF_Text(2, 'Adresse: ' + Adr.Stichwort);
        else
          LF_Text(2, 'Adresse: ' + CnvAI(Prj.Adressnummer));

        RETURN;
      end;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] # 110.0;
      list_Spacing[ 3] # 190.0;

      LF_Set(1, '#Projekt', n, 0);
      LF_Set(2, '#Adresse', n, 0);
    end;

    'projekt-2' : begin
      if (aPrint) then begin
//        LF_Text(1, 'Bemerkung: ' + Prj.Bemerkung);
        if (Prj.Termin.Start != 0.0.0) then begin
          if (Prj.Termin.Ende != 0.0.0) then
            LF_Text(2, 'Zeitraum: ' + DatS(Prj.Termin.Start) + ' - ' + DatS(Prj.Termin.Ende));
          else
            LF_Text(2, 'Zeitraum: von ' + DatS(Prj.Termin.Start));
        end
        else if (Prj.Termin.Ende != 0.0.0) then
          LF_Text(2, 'Zeitraum: bis ' + DatS(Prj.Termin.Ende));

        RETURN;
      end;

//      LF_Set(1, '#Bemerkung', n, 0);
      LF_Set(2, '#Zeitraum',  n, 0);
    end;

    'header' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] +  15.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 125.0;
      list_Spacing[ 4] # list_Spacing[ 3] +  25.0;
      list_Spacing[ 5] # 190.0;

      LF_Format(_LF_Underline | _LF_Bold);
      LF_Set(1, 'Nr.',         y, 0);
      LF_Set(2, 'Bezeichnung', n, 0);
      LF_Set(3, 'Ang./Aufwd.', y, 0);
      LF_Set(4, 'Berechnung',  y, 0);
    end;

    'line' : begin
      if (aPrint) then begin
        vA # aint(Prj.P.Position);
        if (Prj.P.SubPosition>0) then
          vA # vA + '/'+aint(Prj.P.SubPosition);
        LF_Text(1, vA);

        AddSum(1, Prj.P.Dauer.Angebot);
        AddSum(2, Prj.P.Dauer.Extern);

        RETURN;
      end;

//      LF_Set(1, '@Prj.P.Position',      y, _LF_IntNG);
      LF_Set(1, '#Prj.P.Position',      y, 0);
      
      LF_Set(2, '@Prj.P.Bezeichnung',   n, 0);
      LF_Set(3, '@Prj.P.Dauer.Angebot', y, _LF_Num, 2);
      LF_Set(4, '@Prj.P.Dauer.Extern',  y, _LF_Num, 2);
    end;

    'summe' : begin
      if (aPrint) then begin
        LF_Sum(3, 1, 2);
        LF_Sum(4, 2, 2);

        RETURN;
      end;

      LF_Format(_LF_Overline | _LF_Bold);
      LF_Set(3, '#Dauer.Angebot', y, _LF_Num);
      LF_Set(4, '#Dauer.Extern',  y, _LF_Num);
    end;


    'zusatzkosten' : begin
      if (aPrint) then begin
        LF_Text(4, ANum(Prj.Z.ZusKosten, 2) + ' €');
        RETURN;
      end;


      LF_Format(_LF_Bold);
      LF_Set(1, '',         y, 0);
      LF_Set(2, '@Prj.Z.Bemerkung', n, 0);
      LF_Set(3, '', y, 0);
      LF_Set(4, '#Prj.Z.ZusKosten',  y, _LF_Wae);
    end;

    'zeiten-summe' : begin
      if (aPrint) then begin
        LF_Text(2, ANum(GetSum(2), 2) + ' Std.');
        RETURN;
      end;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 50.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 25.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 25.0;
      list_Spacing[ 5] # 190.0;

      LF_Format(_LF_Bold);
      LF_Set(1, 'Zeit Gesamt:'    , n, 0);
      LF_Set(2, '#Dauer.Extern',  y, _LF_Num);
    end;

    'zusatzkosten' : begin
      if (aPrint) then begin
        LF_Text(4, ANum(Prj.Z.ZusKosten, 2) + ' €');
        RETURN;
      end;


      LF_Format( _LF_Bold );
      LF_Set( 1, '',         y, 0 );
      LF_Set( 2, '@Prj.Z.Bemerkung', n, 0 );
      LF_Set( 3, '', y, 0 );
      LF_Set( 4, '#Prj.Z.ZusKosten',  y, _LF_Wae);
    end;

    'zeiten-summe' : begin
      if ( aPrint ) then begin
        LF_Text(2, ANum(GetSum(2), 2) + ' Std.');
        RETURN;
      end;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 50.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 25.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 25.0;
      list_Spacing[ 5] # 190.0;

      LF_Format(_LF_Bold );
      LF_Set( 1, 'Zeit Gesamt:'    , n, 0 );
      LF_Set( 2, '#Dauer.Extern',  y, _LF_Num );
    end;


    'zusatzkosten-summe' : begin
      if (aPrint) then begin
        LF_Text(2, ANum(GetSum(cSumGesZusatzKosten), 2) + ' €');
        RETURN;
      end;


      LF_Format(_LF_Bold);
      LF_Set(1, 'Zusatzkosten Gesamt:'    , n, 0);
      LF_Set(2, '#Prj.Z.ZusKosten'        , y, _LF_Wae);
    end;

    'misc-header' : begin
      if (aPrint) then
        RETURN;

      LF_Format(_LF_Bold);
      LF_Set(2, '@Gv.Alpha.01', n, 0);
    end;

    'misc' : begin
      if (aPrint) then
        RETURN;

      LF_Set(2, '@Gv.Alpha.01', n, 0);
    end;

    'misc-end' : begin
      if (aPrint) then
        RETURN;

      LF_Set(0, '##LINE##', n, 2);
    end;



    'intern-header' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      //list_Spacing[ 2] # list_Spacing[ 1] + 30.0; // 'Interne Dauer:
      list_Spacing[ 2] # list_Spacing[ 1] + 5.0; //
      list_Spacing[ 3] # list_Spacing[ 2] + 20.0- 10.0; // 'User',
      list_Spacing[ 4] # list_Spacing[ 3] + 15.0; // 'Pos.',
      list_Spacing[ 5] # list_Spacing[ 4] + 25.0- 10.0; // 'PLAN Dauer',
      list_Spacing[ 6] # list_Spacing[ 5] + 25.0-10.0; // 'IST Dauer',
      list_Spacing[ 7] # list_Spacing[ 6] + 65.0; // 'Bemerkung',
      list_Spacing[ 8] # list_Spacing[ 7] + 30.0; // 'Zusatzkosten',
      list_Spacing[ 9] # list_Spacing[ 8] + 20.0; // Datum
      list_Spacing[10] # list_Spacing[ 9] + 10.0; // Sum


      LF_Format(_LF_Underline | _LF_Bold);
      //LF_Set(1, 'Interne Dauer:', n, 0);
      LF_Set(2, 'User',           n, 0);
      LF_Set(3, 'Pos.',           y, 0);
      LF_Set(4, 'PLAN Dauer',     y, 0);
      LF_Set(5, 'IST Dauer',      y, 0);
      LF_Set(6, 'Bemerkung',      n, 0);
      LF_Set(7, 'Zusatzkosten',   y, 0);
      LF_Set(8, 'Datum'           ,y, 0);
      LF_Set(9, 'Sum'             ,y, 0);
    end;

    'intern-line' : begin
      if (aPrint) then begin
        vA # aint(Prj.Z.Position);
        if (Prj.Z.SubPosition>0) then
          vA # vA + '/'+aint(Prj.Z.SubPosition);
        LF_Text(3, vA);

        AddSum(3, Prj.Z.Dauer);
        AddSum(4, Prj.Z.Dauer.Plan);
        if(Prj.Z.ZusKosten <> 0.0) then begin
          LF_Text(6, ANum(Prj.Z.ZusKosten, 2) + ' €');
          AddSum(cSumGesZusatzKosten, Prj.Z.ZusKosten);
        end
        else begin
          LF_Text(6, '');
        end;
        LF_Text(9, aNum(GetSum(3),2));
        RETURN;
      end;

      LF_Set(2, '@Prj.Z.User',            n, 0);
      LF_Set(3, '@Prj.Z.Position',        y, _LF_IntNG);
      LF_Set(4, '@Prj.Z.Dauer.Plan',      y, _LF_Num, 2);
      LF_Set(5, '@Prj.Z.Dauer',           y, _LF_Num, 2);
      LF_Set(6, '@Prj.Z.Bemerkung',       n, 0);
      LF_Set(7, '#Prj.Z.ZusKosten',       y, _LF_Wae);
      LF_Set(8, '@Prj.Z.Start.Datum',       n, 0);
      LF_Set(9, '#sum',       n, 0);
    end;

    'intern-summe' : begin
      if (aPrint) then begin
        AddSum(5, GetSum(3));
        AddSum(6, GetSum(4));
        LF_Sum(4, 4, 2);
        LF_Sum(5, 3, 2);
        ResetSum(3);
        ResetSum(4);

        RETURN;
      end;

      LF_Set(4, '#Prj.Z.Dauer.Plan', y, _LF_Num);
      LF_Set(5, '#Prj.Z.Dauer', y, _LF_Num);
      LF_Set(0, '##LINE##',     n, 4, 6);
    end;

    'intern-gesamt' : begin
      if (aPrint) then begin
        LF_Sum(4, 6, 2);
        LF_Sum(5, 5, 2);
        LF_Text(7, ANum(GetSum(cSumGesZusatzKosten), 2) + ' €');
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(4, '#Prj.Z.Dauer.Plan', y, _LF_Num);
      LF_Set(5, '#Prj.Z.Dauer', y, _LF_Num);
      LF_Set(7, '#Prj.Z.ZusKosten', y, _LF_Wae);
    end;

    'intern-appendix' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] #   0.0;
      list_Spacing[ 2] # 190.0;
      LF_Set(1, '@Gv.Alpha.01', n, 0);
    end;
  end;
end;


//=========================================================================
// Position
//
//=========================================================================
sub Position () : logic;
local begin
  Erx : int;
end;
begin

//    if (((Prj.P.Dauer.Extern = 0.0) or ("Prj.P.Lösch.Datum" != 0.0.0)) and (vMark = false)) then
//      RETURN false;
    if (Prj.P.Status<188) or (Prj.P.Status>196) then RETURN false;
    if (Prj.P.Dauer.Extern = 0.0) or ("Prj.P.Lösch.Datum" != 0.0.0) then RETURN false;

    LF_Print(lf_Line);

    if (Prj.P.zuProjekt > 0) and (Prj.P.zuPosition > 0) then begin
      Gv.Alpha.01 # 'Resultiert aus Projekt ' + AInt(Prj.P.zuProjekt) + '/' + AInt(Prj.P.zuPosition);
      LF_Print(lf_Misc);
    end;

    // Text
    Lib_Texte:TxtLoad5Buf(Lib_Texte:GetTextName(122, Prj.P.Nummer, Prj.P.Position, '1', Prj.P.SubPosition), vTxtHdl, 0, 0, 0, 0);
    vLines # vTxtHdl->TextInfo(_textLines);

    if (vLines > 0) then begin
      Gv.Alpha.01 # 'Beschreibung';
      LF_Print(lf_Empty);
      LF_Print(lf_MiscH);

      FOR  vLine # 1;
      LOOP vLine # vLine + 1;
      WHILE (vLine <= vLines) DO BEGIN
        Gv.Alpha.01 # vTxtHdl->TextLineRead(vLine, 0);
        LF_Print(lf_Misc);
      END;

      FOR  Erx # RecLink(123, 122, 1, _recFirst); // Zusatzkosten
      LOOP Erx # RecLink(123, 122, 1, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        if(Prj.Z.ZusKosten <> 0.0) then begin
          LF_Print(lf_ZusatzK);
          AddSum(cSumGesZusatzKosten, Prj.Z.ZusKosten);
        end;
      END;

      LF_Print(lf_MiscE);
    end;

    if (!list_XML) then begin
      FOR  Erx # RecLink(123, 122, 1, _recFirst); // Zeiten loopen
      LOOP Erx # RecLink(123, 122, 1, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        Sort_ItemAdd(vTree, Prj.Z.User + '|' + CnvAI(Prj.Z.Position, _fmtNumNoGroup | _fmtNumLeadZero, 0, 3)+'|'+CnvAI(Prj.Z.SubPosition, _fmtNumNoGroup | _fmtNumLeadZero, 0, 3), 123, RecInfo(123, _recId));
      END;
    end;

    RETURN true;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf (aSeite : int);
begin
  WriteTitel(' ' + CnvAI(Prj.Nummer));
  LF_Print(lf_Empty);
  LF_Print(lf_Prj1);
  LF_Print(lf_Prj2);
  LF_Print(lf_Empty);

  if (form_Footer != 0) then
    LF_Print(lf_Header);
  else
    LF_Print(lf_InternH);
end;


//=========================================================================
// SeitenFuss
//        Seitenfuß der Liste
//=========================================================================
sub SeitenFuss (aSeite : int);
begin
end;


//=========================================================================
// StartList
//        Listenstart
//=========================================================================
sub StartList (aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  v120        : int;
  vNurOffene  : logic;
end;
begin
  v120 # RekSave(120);
  vNurOffene  # Msg(99,'Nur offene Zeiten?',_WinIcoQuestion,_WinDialogYesNo,1)=_winidyes;
  RekRestore(v120);
  
  /* Druckelemente */
  lf_Empty   # LF_NewLine('');
  lf_Prj1    # LF_NewLine('projekt-1');
  lf_Prj2    # LF_NewLine('projekt-2');
  lf_Header  # LF_NewLine('header');
  lf_ZusatzK # LF_NewLine('zusatzkosten');
  lf_Line    # LF_NewLine('line');
  lf_Summe   # LF_NewLine('summe');
  lf_MiscH   # LF_NewLine('misc-header');
  lf_Misc    # LF_NewLine('misc');
  lf_MiscE   # LF_NewLine('misc-end');
  lf_ZeitSum # LF_NewLine('zeiten-summe');
  lf_ZusKSum # LF_NewLine('zusatzkosten-summe');
  lf_InternH # LF_NewLine('intern-header');
  lf_InternL # LF_NewLine('intern-line');
  lf_InternS # LF_NewLine('intern-summe');
  lf_InternG # LF_NewLine('intern-gesamt');
  lf_InternA # LF_NewLine('intern-appendix');

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init(false);

  vTree   # CteOpen(_cteTreeCI);
  vTxtHdl # TextOpen(32);

  vMark   # false;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext, vItem);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
    if (vMFile <> 122) then
      CYCLE;
    vMark # true;
    BREAK;
  END;

  if (vMark = false) then begin
    FOR  Erx # RecLink(122, 120, 4, _recFirst); // Positionen loopen...
    LOOP Erx # RecLink(122, 120, 4, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      if (Position() = false) then
        CYCLE;
    END;
  end
  else begin
    FOR vItem # gMarkList->CteRead(_CteFirst);
    LOOP vItem # gMarkList->CteRead(_CteNext, vItem);
    WHILE (vItem > 0) DO BEGIN
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile <> 122) then
        CYCLE;
      RecRead(122, 0, _RecId, vMID);
      if(Prj.Nummer <> Prj.P.Nummer) then
        CYCLE;

      if(Position() = false) then
        CYCLE;
    END;
  end;
  vTxtHdl->TextClose();

  LF_Print(lf_Empty);
  LF_Print(lf_Summe);

  LF_Print(lf_Empty);
  LF_Print(lf_Empty);
  LF_Print(lf_ZeitSum);
  if(GetSum(cSumGesZusatzKosten) <> 0.0) then // Summe der Zusatzkosten falls welche vorhanden
    LF_Print(lf_ZusKSum);

  if (!list_XML) then begin
    ResetSum(cSumGesZusatzKosten);
    vHdl # form_Footer;
    form_Footer # 0;
    Lib_Print:Print_FF();
    form_Footer # vHdl;

    FOR  vItem # Sort_ItemFirst(vTree);
    LOOP vItem # Sort_ItemNext(vTree, vItem);
    WHILE (vItem != 0) DO BEGIN
      RecRead(CnvIA(vItem->spCustom), 0, 0, vItem->spId);

      if (vNurOffene) and (Prj.Z.ZuAuftragsnr<>0) then CYCLE;

      if (vUser != Prj.Z.User) then begin
        if (vUser != '') then
          LF_Print(lf_InternS);

        LF_Print(lf_Empty);
        vUser # Prj.Z.User;
      end;

      LF_Print(lf_InternL);
    END;

    if (vUser != '') then
      LF_Print(lf_InternS);

    LF_Print(lf_Empty);
    LF_Print(lf_InternG);

    // Appendix
    Gv.Alpha.01 # Set.Prj.Cust1 + ': ' + ANum(Prj.Cust.Wert1, 2);
    LF_Print(lf_Empty);
    LF_Print(lf_Empty);

    LF_Print(lf_InternA);
  end;


  /* Cleanup */
  LF_Term();
  LF_FreeLine(lf_Empty);
  LF_FreeLine(lf_Prj1);
  LF_FreeLine(lf_Prj2);
  LF_FreeLine(lf_Header);
  LF_FreeLine(lf_Line);
  LF_FreeLine(lf_Summe);
  LF_FreeLine(lf_MiscH);
  LF_FreeLine(lf_Misc);
  LF_FreeLine(lf_MiscE);
  LF_FreeLine(lf_InternH);
  LF_FreeLine(lf_InternL);
  LF_FreeLine(lf_InternS);
  LF_FreeLine(lf_InternG);
  LF_FreeLine(lf_InternA);
  LF_FreeLine(lf_ZusatzK);
  LF_FreeLine(lf_ZusKSum);
  LF_FreeLine(lf_ZeitSum);
  Sort_KillList(vTree);
end;

//=========================================================================
//=========================================================================