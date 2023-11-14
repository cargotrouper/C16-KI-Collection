@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Prj_120005
//                    OHNE E_R_G
//  Info
//        Liste: Projekte Wartung
//
//  29.10.2007  MS  Erstellung der Prozedur
//  14.04.2010  PW  Neuer Listenstil
//  2022-06-28  AH  ERX
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

define begin
  cGesSumEK     : 1
  cGesSumVK     : 2
  cGesSumRohgew : 3
end;

local begin
  lf_Empty          : handle;
  lf_Sel            : handle;
  lf_Header         : handle;
  lf_Line           : handle;
  lf_Summe          : handle;

  vArtEKPreis       : float;
  vArtVKPreis       : float;
  vArtRohgew        : float;
  vArtEKSumPreis    : float;
  vArtVKSumPreis    : float;
  vArtRohgewSum     : float;

  vNaechstWartDatum : date;

  vSelDat12         : date;
end;

//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  Sel.von.Datum   # 0.0.0; // Datum von
  vSelDat12       # today; // Datum bis
  vSelDat12       ->  vmMonthModify(12);
  Sel.bis.Datum   # vSelDat12;
  Sel.Adr.von.LKZ # ''; // Wartungsintervall

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'Sel.LST.120005', here + ':AusSel');
  gMDI->wpCaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//=========================================================================
// AusSel
//        Seitenkopf der Liste
//=========================================================================
sub AusSel ();
begin
  Sel.Adr.von.LKZ # StrCnv(Sel.Adr.von.LKZ, _strUpper);
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
    'sel' : begin
      if (aPrint) then begin
        vA # 'Selektion: ';
        if (Sel.von.Datum != 0.0.0) then
          vA # vA + 'Datum von ' + CnvAD(Sel.von.Datum) + ' bis ' + CnvAD(Sel.bis.Datum);
        else
          vA # vA + 'Datum bis ' + CnvAD(Sel.bis.Datum);

        if (Sel.Adr.von.LKZ != '') then
          vA # vA + ', Wartungsintervall: ' + Sel.Adr.von.LKZ;

        LF_Text(1, vA);
        RETURN;
      end;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 300.0;

      pls_fontAttr # pls_fontAttr | _winFontAttrItalic;
      LF_Set(1, '#Selektion', n, 0);
      pls_fontAttr # pls_fontAttr ^ _winFontAttrItalic;
    end;

    'header' : begin
      if (aPrint) then
        RETURN;

      list_Spacing[ 1] # 0.0;
      list_Spacing[ 2] # list_Spacing[ 1] + 15.0;// 'Nr.',
      list_Spacing[ 3] # list_Spacing[ 2] + 40.0;// 'Adresse',
      list_Spacing[ 4] # list_Spacing[ 3] + 40.0;// 'Artikel',
      list_Spacing[ 5] # list_Spacing[ 4] + 20.0;// 'Stk',
      list_Spacing[ 6] # list_Spacing[ 5] + 20.0;// 'VK',
      list_Spacing[ 7] # list_Spacing[ 6] + 23.0;// 'VK Summe',
      list_Spacing[ 8] # list_Spacing[ 7] + 20.0;// 'EK',
      list_Spacing[ 9] # list_Spacing[ 8] + 23.0;// 'EK Summe',
      list_Spacing[10] # list_Spacing[ 9] + 20.0;// 'Rohgew.',
      list_Spacing[11] # list_Spacing[10] + 15.0;// 'Wart.',
      list_Spacing[12] # list_Spacing[11] + 20.0;// 'letzter Auf.',
      list_Spacing[13] # list_Spacing[12] + 20.0;// 'nächster Auf.',
      list_Spacing[14] # list_Spacing[13] + 30.0;//
      list_Spacing[15] # list_Spacing[14] + 30.0;//

      LF_Format(_LF_Underline | _LF_Bold);
      LF_Set(1,  'Nr.',           y, 0);
      LF_Set(2,  'Adresse',       n, 0);
      LF_Set(3,  'Artikel',       n, 0);
      LF_Set(4,  'Stk',           y, 0);
      LF_Set(5,  'VK',            y, 0);
      LF_Set(6,  'VK Summe',      y, 0);
      LF_Set(7,  'EK',            y, 0);
      LF_Set(8,  'EK Summe',      y, 0);
      LF_Set(9,  'Rohgew.',       y, 0);
      LF_Set(10, 'Wart.',         n, 0);
      LF_Set(11, 'letzter Auf.',  y, 0);
      LF_Set(12, 'nächster Auf.', y, 0);
    end;

    'line' : begin
      if (aPrint) then begin
        if (Prj.SL.Nummer != 0) then begin
          if (RecLink(250, 121, 2, _recFirst) > _rLocked) then
            RecBufClear(250);
        end;


        vArtEKSumPreis  # vArtEKPreis * cnvFI("Prj.SL.Stückzahl");
        vArtVKSumPreis  # vArtVKPreis * cnvFI("Prj.SL.Stückzahl");

        vArtRohgew      # vArtVKPreis - vArtEKPreis;
        vArtRohgewSum   # vArtVKSumPreis - vArtEKSumPreis;

        if (RecLink(100, 120, 1, _recFirst) <= _rLocked) then
          LF_Text(2, Adr.Stichwort);
        else
          LF_Text(2, CnvAI(Prj.Adressnummer));


        LF_Text(5, ANum(vArtVKPreis, 2));
        LF_Text(6, ANum(vArtVKSumPreis, 2));
        LF_Text(7, ANum(vArtEKPreis, 2));
        LF_Text(8, ANum(vArtEKSumPreis, 2));
        LF_Text(9, ANum(vArtRohgewSum, 2));
        LF_Text(12, DatS(vNaechstWartDatum));


        AddSum(cGesSumEK    , vArtEKSumPreis);
        AddSum(cGesSumVK    , vArtVKSumPreis);
        AddSum(cGesSumRohgew, vArtRohgewSum);

        RETURN;
      end;

      LF_Set(1, '@Prj.Nummer',             y, _LF_IntNG);
      LF_Set(2, '#Adresse',                n, 0);
      LF_Set(3, '@Art.Stichwort',          n, 0);
      LF_Set(4, '@Prj.SL.Stückzahl',       y, _LF_Int);
      LF_Set(5, '#vArtVKPreis',            y, _LF_Wae);
      LF_Set(6, '#vArtVKSum',              y, _LF_Wae);
      LF_Set(7, '#vArtEKPreis',            y, _LF_Wae);
      LF_Set(8, '#vArtEKSum',              y, _LF_Wae);
      LF_Set(9, '#vArtRohgew',             y, _LF_Wae);
      LF_Set(10, '@Prj.Wartungsinterval',   n, 0);
      LF_Set(11, '@Prj.Wtg.LetztesDatum',   y, 0);
      LF_Set(12, '#vNaechstWartDatum',      y, 0);
    end;

    'summe' : begin
      if (aPrint) then begin
        LF_Sum(6, cGesSumVK, 2);
        LF_Sum(8, cGesSumEK, 2);
        LF_Sum(9, cGesSumRohgew, 2);

        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(6, '#vArtVKPreis',            y, _LF_Wae);
      LF_Set(8, '#vArtEKPreis',            y, _LF_Wae);
      LF_Set(9, '#vArtRohgew',            y, _LF_Wae);
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
  vTree     : handle;
  vItem     : handle;
end;
begin
  /* Selektion */
  if (Sel.Adr.von.LKZ != '') then
    Lib_Sel:QAlpha(var vSelQ, 'Prj.Wartungsinterval', '=', Sel.Adr.von.LKZ);

  vSel # SelCreate(120, 1);
  vSel->SelDefQuery('', vSelQ);
  vSel->Lib_Sel:QError();
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  /* Datenbaum */
  REPEAT BEGIN
    vPrgr # Lib_Progress:Init('Sortierung', RecInfo(120, _recCount, vSel));
    vTree # CteOpen(_cteTreeCI);

    FOR  Erx # RecRead(120, vSel, _recFirst);
    LOOP Erx # RecRead(120, vSel, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      if (!vPrgr->Lib_Progress:Step()) then
        BREAK;
      vNaechstWartDatum # Prj_Data:Wtg_NaechsterTermin();
      if(vNaechstWartDatum < Sel.von.Datum) or (vNaechstWartDatum > Sel.bis.Datum) then // Datum - "Selektion"
        CYCLE;

      FOR  Erx # RecLink(121, 120, 2, _recFirst);
      LOOP Erx # RecLink(121, 120, 2, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIN
        Sort_ItemAdd(vTree, Prj.Adressstichwort + Prj.SL.Artikelnr, 121, RecInfo(121, _recId));
      END;
    END;

    vSel->SelClose();
    SelDelete(122, vSelName);

    if (Erx <= _rLocked) then begin
      Sort_KillList(vTree);
      RETURN;
    end;
  END UNTIL (true);


  /* Druckelemente */
  lf_Empty  # LF_NewLine('');
  lf_Sel    # LF_NewLine('sel');
  lf_Header # LF_NewLine('header');
  lf_Line   # LF_NewLine('line');
  lf_Summe  # LF_NewLine('summe');

  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init(true);

  REPEAT BEGIN
    vPrgr->Lib_Progress:Reset('Listengenerierung', CteInfo(vTree, _cteCount));

    FOR  vItem # Sort_ItemFirst(vTree);
    LOOP vItem # Sort_ItemNext(vTree, vItem);
    WHILE (vItem != 0) DO BEGIN
      if (!vPrgr->Lib_Progress:Step()) then
        BREAK;

      RecRead(CnvIA(vItem->spCustom), 0, 0, vItem->spId); // Prj. Stueckliste
      Erx # RecLink(120, 121, 1, _recFirst); // Projekt
      if(Erx > _rLocked) then
        RecBufClear(120);
      Erx # RecLink(250, 121, 2, _recFirst); // Artikel
      if(Erx > _rLocked) then
        RecBufClear(250);

      vNaechstWartDatum # Prj_Data:Wtg_NaechsterTermin();
      vArtEKPreis   # 0.0;
      vArtVKPreis   # 0.0;

      if (Art_P_Data:LiesPreis('EK', 0)) then // allgemeiner EK
        vArtEKPreis # Art.P.Preis;

      if (Art_P_Data:LiesPreis('VK', Prj.Adressnummer)) then // spezieller VK
        vArtVKPreis # Art.P.Preis;
      else if (Art_P_Data:LiesPreis('VK', 0)) then // allgemeiner VK
        vArtVKPreis # Art.P.Preis;
/*
      if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != 0.0.0) then begin
        if (vNaechstWartDatum >= Sel.von.Datum) and (vNaechstWartDatum <= Sel.bis.Datum) then
          LF_Print(lf_Line);
      end
      else
*/
        LF_Print(lf_Line);
    END;

    if (vItem != 0) then
      BREAK;

    LF_Print(lf_Summe);
  END UNTIL (true);

  /* Cleanup */
  vPrgr->Lib_Progress:Term();
  Sort_KillList(vTree);

  LF_Term();
  LF_FreeLine(lf_Empty);
  LF_FreeLine(lf_Sel);
  LF_FreeLine(lf_Header);
  LF_FreeLine(lf_Line);
  LF_FreeLine(lf_Summe);
end;

//=========================================================================
//=========================================================================