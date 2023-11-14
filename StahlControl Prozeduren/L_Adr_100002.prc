@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Adr_100002
//                    OHNE E_R_G
//  Info
//        Liste: Adressen (selektiert)
//
//  05.05.2004  AI  Erstellung der Prozedur
//  12.04.2005  TM  Sel.Adr.von.KdNr bleibt immer leer!
//  25.05.2010  PW  Neuer Listenstil
//  05.06.2012  TM  Sperrkunden /-lieferantenselektion
//  12.04.2013  ST  Druck der ersten 5 Zeilen ohne Daten auskommentiert laut Projekt 1326/341
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    sub AusSel ();
//    sub Element (aName : alpha; aPrint : logic);
//    sub SeitenKopf (aSeite : int);
//    sub SeitenFuss (aSeite : int);
//    sub StartList (aSort : int; aSortName : alpha);
//=========================================================================
@I:Def_Global
@I:Def_List2
declare StartList (aSort : int; aSortName : alpha);

local begin
  lf_Empty  : handle;
  lf_Break  : handle;
  lf_Sel    : handle;
  lf_XML_H  : handle;
  lf_XML    : handle;
  lf_Header : handle;
  lf_Line1  : handle;
  lf_Line2  : handle;
  lf_Line3  : handle;
  lf_Line4  : handle;
  lf_Line5  : handle;
  lf_Line6  : handle;
  lf_Line7  : handle;
  lf_LineV1 : handle;
  lf_LineV2 : handle;

  gOrt      : logic;
  gPostfach : logic;
  gLand     : logic;
end;

define begin
  // MakeSelLine(text, name, convert, fldVon, fldBis, defVon, defBis)
  MakeSelLine(a,b,c,fV,fB,dV,dB) : begin if (fV!=dV or fB!=dB) then begin a#a+', '+b;if (fV!=dV) then begin a#a+' von '+c(fV) end if (fB!=dB) then begin a#a+' bis '+c(fB) end end end
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.Adr.von.KdNr      # 0;        // Kundennummer von
  Sel.Adr.bis.KdNr      # 9999999;  // Kundennummer bis
  Sel.Adr.von.LiNr      # 0;        // Lieferantennummer von
  Sel.Adr.bis.LiNr      # 9999999;  // Lieferantennummer bis
  Sel.Adr.von.FibuKd    # '';       // Fibu-Kunden-Nr von
  Sel.Adr.bis.FibuKd    # 'ZZZ';    // Fibu-Kunden-Nr bis
  Sel.Adr.von.FibuLi    # '';       // Fibu-Lieferanten-Nr von
  Sel.Adr.bis.FibuLi    # 'ZZZ';    // Fibu-Lieferanten-Nr bis
  Sel.Adr.von.Gruppe    # '';       // Gruppe von
  Sel.Adr.bis.Gruppe    # 'ZZZ';    // Gruppe bis
  Sel.Adr.von.Stichw    # '';       // Stichwort von
  Sel.Adr.bis.Stichw    # 'ZZZ';    // Stichwort bis
  Sel.Adr.von.ABC       # '';       // ABC von
  Sel.Adr.bis.ABC       # 'Z';      // ABC bis
  Sel.Adr.von.LKZ       # '';       // LKZ von
  Sel.Adr.bis.LKZ       # 'ZZZ';    // LKZ bis
  Sel.Adr.von.PLZ       # '';       // PLZ von
  Sel.Adr.bis.PLZ       # 'ZZZ';    // PLZ bis
  Sel.Adr.von.Vertret   # 0;        // nur Vertreter
  Sel.Adr.von.Sachbear  # '';       // nur Sachbearbeiter
  Sel.Adr.Briefgruppe   # '';       // Briefgruppe enthält
  Sel.Adr.nurMarkeYN    # false;    // nur markierte

  "Sel.Adr.SperrKdYN"   # false;    // nur gesperrte Kunden
  "Sel.Adr.!SperrKdYN"  # false;    // ohne gesperrte Kunden
  "Sel.Adr.SperrLiYN"   # false;    // nur gesperrte Lieferanten
  "Sel.Adr.!SperrLiYN"  # false;    // ohne gesperrte Lieferanten


  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sel.Mark.Adressen', here + ':AusSel');
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//=========================================================================
// AusSel
//        Rückkehr aus Selektionsmaske
//=========================================================================
sub AusSel ();
local begin
  vSortKey  : int;
  vSortName : alpha;
  vHdlDlg   : handle;
  vHdlLst   : handle;
end;
begin
  gSelected # 0;
  
  vHdlDlg # WinOpen('Lfm.Sortierung', _winOpenDialog);
  vHdlLst # vHdlDlg->WinSearch('Dl.Sort');
  vHdlLst->WinLstDatLineAdd('Kundennummer'); // key 1
  vHdlLst->WinLstDatLineAdd('Lieferantenummer'); // key 2
  vHdlLst->WinLstDatLineAdd('Name'); // key 3
  vHdlLst->WinLstDatLineAdd('Stichwort'); // key 4
  vHdlLst->wpCurrentInt # 1;
  vHdlDlg->WinDialogRun(_winDialogCenter, gMdi);
  vHdlLst->WinLstCellGet(vSortName, 1, _winLstDatLineCurrent);
  vHdlDlg->WinClose();

  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;

  vSortKey  # gSelected;
  gSelected # 0;
  StartList(vSortKey, vSortName);
end;


//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element (aName : alpha; aPrint : logic);
local begin
  vA : alpha(500);
  vB : alpha(500);
end;
begin
  case aName of
    'sel' : begin
      if (aPrint) then begin
        vA # '';
        MakeSelLine(vA, 'Kundennummer', AInt, Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr, 0, 9999999);
        MakeSelLine(vA, 'Lieferantennummer', AInt, Sel.Adr.von.LiNr, Sel.Adr.bis.LiNr, 0, 9999999);
        MakeSelLine(vA, 'Fibu-Kundennr.',, Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd, '', 'ZZZ');
        MakeSelLine(vA, 'Fibu-Lieferantennr.', , Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi, '', 'ZZZ');
        MakeSelLine(vA, 'Gruppe',, Sel.Adr.von.Gruppe, Sel.Adr.bis.Gruppe, '', 'ZZZ');
        MakeSelLine(vA, 'Stichwort',, Sel.Adr.von.Stichw, Sel.Adr.bis.Stichw, '', 'ZZZ');
        MakeSelLine(vA, 'ABC',, Sel.Adr.von.ABC, Sel.Adr.bis.ABC, '', 'Z');
        MakeSelLine(vA, 'LKZ',, Sel.Adr.von.LKZ, Sel.Adr.bis.LKZ, '', 'ZZZ');
        MakeSelLine(vA, 'PLZ',, Sel.Adr.von.PLZ, Sel.Adr.bis.PLZ, '', 'ZZZ');

        if (Sel.Adr.von.Vertret != 0) then
          vA # vA + ', nur Vertreter ' + CnvAI(Sel.Adr.von.Vertret);
        if (Sel.Adr.Briefgruppe != '') then
          vA # vA + ', Briefgruppe enhält "' + Sel.Adr.Briefgruppe + '"';
        if (Sel.Adr.nurMarkeYN) then
          vA # vA + ', nur markierte';

        LF_Text(1, 'Selektion: ' + StrCut(vA, 3, StrLen(vA)));

        RETURN;
      end;

      list_Spacing[ 2] # 190.0;
      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set(1, '#Selektion', n, 0);
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'break' : begin
      if (!aPrint) then begin
        LF_Format(_LF_Underline);
        LF_Set(1, ' ', n, 0);
      end;
    end;

    'xml-header' : begin
      if (aPrint) then
        RETURN;

      LF_Format(_LF_Underline | _LF_Bold);
      LF_Set(1, 'Anrede',         n, 0);
      LF_Set(2, 'Name',           n, 0);
      LF_Set(3, 'Zusatz',         n, 0);
      LF_Set(4, 'Straße',         n, 0);
      LF_Set(5, 'PLZ/Ort',        n, 0);
      LF_Set(6, 'Postfach',       n, 0);
      LF_Set(7, 'LKZ',            n, 0);
      LF_Set(8, 'AdressNr.',      n, 0);
      LF_Set(9, 'KundenNr.',      n, 0);
      LF_Set(10, 'LieferantenNr.', n, 0);
      LF_Set(11, 'Stichwort',      n, 0);
      LF_Set(12, 'Gruppe',         n, 0);
      LF_Set(13, 'Sachbearbeiter', n, 0);
      LF_Set(14, 'Telefon1',       n, 0);
      LF_Set(15, 'Telefon2',       n, 0);
      LF_Set(16, 'Telefax',        n, 0);
      LF_Set(17, 'E-Mail',         n, 0);
      LF_Set(18, 'Vertreter',      n, 0);
      LF_Set(19, 'Verband',        n, 0);
      LF_Set(20, 'RefNr.',         n, 0);
    end;

    'xml' : begin
      if (aPrint) then begin
        LF_Text(5, Adr.PLZ + ' ' + Adr.Ort);
        LF_Text(6, Adr.Postfach.PLZ + '/' + Adr.Postfach);

        // Vertreter
        if (RecLink(110, 100, 15, _recFirst) > _rLocked) then
          RecBufClear(110);
        LF_Text(18, AInt(Ver.Nummer) + ', ' + Ver.Stichwort);

        // Verband
        if (RecLink(110, 100, 16, _recFirst) > _rLocked) then
          RecBufClear(110);
        LF_Text(19, AInt(Ver.Nummer) + ', ' + Ver.Stichwort);
        LF_Text(20, Adr.VerbandRefNr);

        RETURN;
      end;

      LF_Set(1, '@Adr.Anrede',         n, 0);
      LF_Set(2, '@Adr.Name',           n, 0);
      LF_Set(3, '@Adr.Zusatz',         n, 0);
      LF_Set(4, '@Adr.Straße',         n, 0);
      LF_Set(5, '#Adr.Ort',            n, 0);
      LF_Set(6, '#Adr.Postfach',       n, 0);
      LF_Set(7, '@Adr.LKZ',            n, 0);
      LF_Set(8, '@Adr.Nummer',         n, _LF_IntNG);
      LF_Set(9, '@Adr.KundenNr',       n, _LF_IntNG);
      LF_Set(10, '@Adr.LieferantenNr',  n, _LF_IntNG);
      LF_Set(11, '@Adr.Stichwort',      n, 0);
      LF_Set(12, '@Adr.Gruppe',         n, 0);
      LF_Set(13, '@Adr.Sachbearbeiter', n, 0);
      LF_Set(14, '@Adr.Telefon1',       n, 0);
      LF_Set(15, '@Adr.Telefon2',       n, 0);
      LF_Set(16, '@Adr.Telefax',        n, 0);
      LF_Set(17, '@Adr.eMail',          n, 0);
      LF_Set(18, '#Vertreter',          n, 0);
      LF_Set(19, '#Verband',            n, 0);
      LF_Set(20, '#RefNr.',             n, 0);
    end;

    'header' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 4] # list_Spacing[ 2] + 60.0;
      list_Spacing[ 6] # list_Spacing[ 4] + 70.0;

      LF_Format(_LF_Underline | _LF_Bold);
      LF_Set(1, 'Adresse',      n, 0);
      LF_Set(2, 'Daten',        n, 0);
      LF_Set(4, 'Kontaktdaten', n, 0);
    end;

    'line1' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 30.0;
      list_Spacing[ 4] # 190.0;

      LF_Set(1, '@Adr.Anrede',         n, 0);
      LF_Set(2, 'Stichwort:',          n, 0);
      LF_Set(3, '@Adr.Stichwort',      n, 0);
    end;

    'line2' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 60.0;
      list_Spacing[ 3] # list_Spacing[ 2] + 30.0;
      list_Spacing[ 4] # list_Spacing[ 3] + 30.0;
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;
      list_Spacing[ 6] # list_Spacing[ 5] + 50.0;

      LF_Set(1, '@Adr.Name',           n, 0);
      LF_Set(2, 'AdressNr.:',          n, 0);
      LF_Set(3, '@Adr.Nummer',         n, 0);
      LF_Set(4, 'Telefon 1:',          n, 0);
      LF_Set(5, '@Adr.Telefon1',       n, 0);
    end;

    'line3' : begin
      if (aPrint) then
        RETURN;

      LF_Set(1, '@Adr.Zusatz',         n, 0);
      LF_Set(2, 'KundenNr.',           n, 0);
      LF_Set(3, '@Adr.KundenNr',       n, 0);
      LF_Set(4, 'Telefon 2:',          n, 0);
      LF_Set(5, '@Adr.Telefon2',       n, 0);
    end;

    'line4' : begin
      if (aPrint) then
        RETURN;

      LF_Set(1, '@Adr.Straße',         n, 0);
      LF_Set(2, 'LieferantenNr.:',     n, 0);
      LF_Set(3, '@Adr.LieferantenNr',  n, 0);
      LF_Set(4, 'Telefax:',            n, 0);
      LF_Set(5, '@Adr.Telefax',        n, 0);
    end;

    'line5' : begin
      if (aPrint) then begin
        if (gOrt) or (!gPostfach) then begin
          LF_Text(1, Adr.PLZ + ' ' + Adr.Ort);
          gOrt # false;
        end
        else begin
          LF_Text(1, 'Postfach: ' + Adr.Postfach.PLZ + ' ' + Adr.Postfach);
          gPostfach # false;
        end;

        RETURN;
      end;

      LF_Set(1, '#PLZ/Ort',            n, 0);
      LF_Set(2, 'Gruppe:',             n, 0);
      LF_Set(3, '@Adr.Gruppe',         n, 0);
      LF_Set(4, 'E-Mail:',             n, 0);
      LF_Set(5, '@Adr.eMail',          n, 0);
    end;

    'line6' : begin
      if (aPrint) then begin
        if (gPostfach) then begin
          LF_Text(1, 'Postfach: ' + Adr.Postfach.PLZ + ' ' + Adr.Postfach);
          gPostfach # false;
        end
        else begin
          LF_Text(1, Lnd.Name.L1);
          gLand # false;
        end;

        RETURN;
      end;

      LF_Set(1, '#PLZ/Ort/Land',       n, 0);
      LF_Set(2, 'Sachbearbeiter:',     n, 0);
      LF_Set(3, '@Adr.Sachbearbeiter', n, 0);
      LF_Set(4, 'USt.Id-Nr.:',             n, 0);
      LF_Set(5, '@Adr.USIdentNr',          n, 0);
    end;

    'line7' : begin
      if (aPrint) then
        RETURN;

      LF_Set(1, '@Lnd.Name.L1',        n, 0);
    end;

    'lineVertreter' : begin
      if (aPrint) then begin
        if (RecLink(110, 100, 15, _recFirst) > _rLocked) then
          RecBufClear(110);

        LF_Text(3, AInt(Ver.Nummer) + ', ' + Ver.Stichwort);

        RETURN;
      end;

      LF_Set(2, 'Vertreter:', n, 0);
      LF_Set(3, '#Vertreter', n, 0);
    end;

    'lineVerband' : begin
      if (aPrint) then begin
        if (RecLink(110, 100, 16, _recFirst) > _rLocked) then
          RecBufClear(110);

        LF_Text(3, AInt(Ver.Nummer) + ', ' + Ver.Stichwort);
        LF_Text(5, Adr.VerbandRefNr);

        RETURN;
      end;

      LF_Set(2, 'Verband:', n, 0);
      LF_Set(3, '#Verband', n, 0);
      LF_Set(4, 'RefNr.:',  n, 0);
      LF_Set(5, '#RefNr',   n, 0);
    end;
  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf (aSeite : int);
begin
  WriteTitel();
  LF_Print(lf_Empty);

  if (aSeite = 1) then begin
    LF_Print(lf_Sel);
    LF_Print(lf_Empty);
  end;

  if (list_XML) then
    LF_Print(lf_XML_H);
  else
    LF_Print(lf_Header);
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
  Erx       : int;
  vPrgr     : handle;
  vSel      : int;
  vSelName  : alpha;
  vSelQ     : alpha(1000);
  vItem     : handle;
  vMFile    : int;
  vMId      : int;
  vLastLfS  : alpha;
end;
begin

  // Sortierung
  if (aSort = 1) then // Kundennummer
    aSort # 2;
  else if (aSort = 2) then // Lieferantennummer
    aSort # 3;
  else if (aSort = 3) then // Name
    aSort # 6;
  else if (aSort = 4) then // Stichwort
    aSort # 4;
  else
    RETURN;

  /* Selektion */
  if (Sel.Adr.von.KdNr != 0) or (Sel.Adr.bis.KdNr != 9999999) then
    Lib_Sel:QVonBisI(var vSelQ, 'Adr.Kundennr', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr);
  if (Sel.Adr.von.LiNr != 0) or (Sel.Adr.bis.LiNr != 9999999) then
    Lib_Sel:QVonBisI(var vSelQ, 'Adr.LieferantenNr', Sel.Adr.von.LiNr, Sel.Adr.bis.LiNr);
  if (Sel.Adr.von.FibuKd != '') or (Sel.Adr.bis.FibuKd != 'ZZZ') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.KundenFibuNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd);
  if (Sel.Adr.von.FibuLi != '') or (Sel.Adr.bis.FibuLi != 'ZZZ') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.LieferantFibuNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi);

  if (Sel.Adr.von.Gruppe != '') or (Sel.Adr.bis.Gruppe != 'zzz') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.Gruppe', Sel.Adr.von.Gruppe, Sel.Adr.bis.Gruppe);

  if (Sel.Adr.von.Stichw != '') or (Sel.Adr.bis.Stichw != 'zzz') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.Stichwort', Sel.Adr.von.Stichw, Sel.Adr.bis.Stichw);
  if (Sel.Adr.von.ABC != '') or (Sel.Adr.bis.ABC != 'z') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.ABC', Sel.Adr.von.ABC, Sel.Adr.bis.ABC);
  if (Sel.Adr.von.LKZ != '') or (Sel.Adr.bis.LKZ != 'zzz') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.LKZ', Sel.Adr.von.LKZ, Sel.Adr.bis.LKZ);
  if (Sel.Adr.von.PLZ != '') or (Sel.Adr.bis.PLZ != 'zzz') then
    Lib_Sel:QVonBisA(var vSelQ, 'Adr.PLZ', Sel.Adr.von.PLZ, Sel.Adr.bis.PLZ);

  if (Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt(var vSelQ, 'Adr.Vertreter', '=', Sel.Adr.von.Vertret);
  if (Sel.Adr.von.Sachbear != '') then
    Lib_Sel:QAlpha(var vSelQ, 'Adr.Sachbearbeiter', '=', Sel.Adr.von.Sachbear);

  if (Sel.Adr.Briefgruppe != '') then
    Lib_Sel:QenthaeltA(var vSelQ, 'Adr.Briefgruppe', Sel.Adr.Briefgruppe);

  // ---- NEU: Sperrkunden- / -lieferantenselektion ----
  if ("Sel.Adr.SperrKdYN" = false and "Sel.Adr.!SperrKdYN" = true) then
    Lib_Sel:QLogic(var vSelQ, 'Adr.SperrKundeYN', true);

  if ("Sel.Adr.SperrKdYN" = true and "Sel.Adr.!SperrKdYN" = false) then
    Lib_Sel:QLogic(var vSelQ, 'Adr.SperrKundeYN', false);

  if ("Sel.Adr.SperrLiYN" = false and "Sel.Adr.!SperrLiYN" = true) then
    Lib_Sel:QLogic(var vSelQ, 'Adr.SperrLieferantYN', true);

  if ("Sel.Adr.SperrLiYN" = true and "Sel.Adr.!SperrLiYN" = false) then
    Lib_Sel:QLogic(var vSelQ, 'Adr.SperrLieferantYN', false);
  // ---- NEU: Sperrkunden- / -lieferantenselektion ----

  vSel # SelCreate(100, aSort);
  vSel->SelDefQuery('', vSelQ);
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  // Nachselektion: nur markierte
  if (Sel.Adr.nurMarkeYN) then
    Lib_Sel:IntersectMark(var vSel, var vSelName, 100, aSort);

  /* Druckelemente */
  lf_Empty  # LF_NewLine('');
  lf_Break  # LF_NewLine('break');
  lf_Sel    # LF_NewLine('sel');
  lf_Header # LF_NewLine('header');
  lf_XML_H  # LF_NewLine('xml-header');
  lf_XML    # LF_NewLine('xml');
  lf_Line1  # LF_NewLine('line1');
  lf_Line2  # LF_NewLine('line2');
  lf_Line3  # LF_NewLine('line3');
  lf_Line4  # LF_NewLine('line4');
  lf_Line5  # LF_NewLine('line5');
  lf_Line6  # LF_NewLine('line6');
  lf_Line7  # LF_NewLine('line7');
  lf_LineV1 # LF_NewLine('lineVertreter');
  lf_LineV2 # LF_NewLine('lineVerband');

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init(false);

  vPrgr # Lib_Progress:Init('Listengenerierung', RecInfo(100, _recCount, vSel));

/* ST 2013-04-12: Auskommentiert laut Projekt 1326/341
  LF_Print(lf_Line1);
  LF_Print(lf_Line2);
  LF_Print(lf_Line3);
  LF_Print(lf_Line4);
  LF_Print(lf_Line5);
  LF_Print(lf_Line6);
*/
  FOR  Erx # RecRead(100, vSel, _recFirst);
  LOOP Erx # RecRead(100, vSel, _recNext);
  WHILE (Erx <= _rLocked) and (vPrgr->Lib_Progress:Step()) DO BEGIN

    // Land
    if (RecLink(812, 100, 10, _recFirst) > _rLocked) then
      RecBufClear(812);

    if (list_XML) then
      LF_Print(lf_XML);
    else begin
      if (Adr.Ort != '') then
        gOrt # true;
      if (Adr.Postfach != '') then
        gPostfach # true;
      gLand # true;

      LF_Print(lf_Line1);
      LF_Print(lf_Line2);
      LF_Print(lf_Line3);
      LF_Print(lf_Line4);
      LF_Print(lf_Line5);
      LF_Print(lf_Line6);

      if (gLand) then
        LF_Print(lf_Line7);

      if (Adr.Vertreter != 0) then
        LF_Print(lf_LineV1);

      if (Adr.Verband != 0) then
        LF_Print(lf_LineV2);

      LF_Print(lf_Break);
    end;
  END;

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  vSel->SelClose();
  SelDelete(100, vSelName);

  LF_Term();
  LF_FreeLine(lf_Empty);
  LF_FreeLine(lf_Break);
  LF_FreeLine(lf_Sel);
  LF_FreeLine(lf_XML_H);
  LF_FreeLine(lf_XML);
  LF_FreeLine(lf_Header);
  LF_FreeLine(lf_Line1);
  LF_FreeLine(lf_Line2);
  LF_FreeLine(lf_Line3);
  LF_FreeLine(lf_Line4);
  LF_FreeLine(lf_Line5);
  LF_FreeLine(lf_Line6);
  LF_FreeLine(lf_Line7);
  LF_FreeLine(lf_LineV1);
  LF_FreeLine(lf_LineV2);
end;

//=========================================================================
//=========================================================================