@A+
//===== Business-Control =================================================
//
//  Prozedur  Adr_Subs
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  03.03.2010  MS  SetKundennr erweitert (ueber alle Datein die Kd.Nummern enthalten)
//  02.09.2016  AH  "LoopDataAndReplace" nutzt eine Selektion und replaced nicht jeden Satz
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB Delete : logic
//    SUB _SetData(aFelder : alpha; aNeuerInhalt : alpha; aZuErsetzenderInhalt : alpha);
//    SUB LoopDataAndReplace(aZieldatei : int;  aAusgangsdatei : int; aKeyOrVerknuepfung : int;  aFelder : alpha;  aNeuerInhalt : alpha; opt aZuErsetzenderInhalt  : alpha;) : logic;
//    SUB SetKundennr(aNeu : int) : logic;
//    SUB SetLieferantennr(aNeu : int);
//    SUB CalcIBAN(aLKZ : alpha; aBLZ : alpha; aKonto : alpha) : alpha;
//    SUB CheckIBAN(aIBAN : alpha) : logic;
//    SUB CheckBLZ(aBLZ : alpha; var aName : alpha; var aBIC : alpha ) : logic;
//
//========================================================================
@I:Def_Global
@I:C16_sysSOAPInc

define begin
  Lf_ChangeOrEnd(a,b,c,d,e) : vHdl->wpcaption # a; if (LoopDataAndReplace(b, c, d, e, AInt(aNeu), AInt(Adr.Lieferantennr)) = false) then begin TRANSBRK; vDia->WinClose(); RETURN false; end; inc(vI); vHdl2->wpProgressPos # vI;
end;

//========================================================================
//  Delete
//
//========================================================================
sub Delete() : logic
local begin
  Erx : int;
end;
begin
  if (Adr.Lieferantennr<>0) and (RecLinkInfo(200,100,17,_recCount)<>0) then begin
    Msg(100004,translate('Materialkarten'),0,0,0);
    RETURN false;
  end;
  if (Adr.Nummer<>0) and (RecLinkInfo(200,100,18,_recCount)<>0) then begin
    Msg(100004,translate('Materialkarten'),0,0,0);
    RETURN false;
  end;
  if (Adr.Kundennr<>0) and (RecLinkInfo(200,100,19,_recCount)<>0) then begin
    Msg(100004,translate('Materialkarten'),0,0,0);
    RETURN false;
  end;
  if (Adr.Nummer<>0) and (RecLinkInfo(254,100,20,_recCount)<>0) then begin
    Msg(100004,translate('Sonderpreise'),0,0,0);
    RETURN false;
  end;
  if (Adr.Nummer<>0) and (RecLinkInfo(404,100,21,_recCount)<>0) then begin
    Msg(100004,translate('Aktionen'),0,0,0);
    RETURN false;
  end;
  if (Adr.KundenNr<>0) and (RecLinkInfo(401,100,22,_recCount)<>0) then begin
    Msg(100004,translate('Auftragspositionen'),0,0,0);
    RETURN false;
  end;
  if (Adr.LieferantenNr<>0) and (RecLinkInfo(501,100,23,_recCount)<>0) then begin
    Msg(100004,translate('Einkaufspositionen'),0,0,0);
    RETURN false;
  end;
  if (Adr.KundenNr<>0) and (RecLinkInfo(450,100,25,_recCount)<>0) then begin
    Msg(100004,translate('Erlöse'),0,0,0);
    RETURN false;
  end;
  if (Adr.KundenNr<>0) and (RecLinkInfo(460,100,26,_recCount)<>0) then begin
    Msg(100004,translate('Offene Posten'),0,0,0);
    RETURN false;
  end;
  if (Adr.LieferantenNr<>0) and (RecLinkInfo(550,100,27,_recCount)<>0) then begin
    Msg(100004,translate('Verbindlichkeiten'),0,0,0);
    RETURN false;
  end;
  if (Adr.LieferantenNr<>0) and (RecLinkInfo(560,100,28,_recCount)<>0) then begin
    Msg(100004,translate('Eingangsrechnungen'),0,0,0);
    RETURN false;
  end;
  if (Adr.LieferantenNr<>0) and (RecLinkInfo(511,100,29,_recCount)<>0) then begin
    Msg(100004,translate('Einkaufspositionen'),0,0,0);
    RETURN false;
  end;
  if (Adr.LieferantenNr<>0) and (RecLinkInfo(120,100,30,_recCount)<>0) then begin
    Msg(100004,translate('Projekte'),0,0,0);
    RETURN false;
  end;

  if (Adr.Lieferantennr<>0) and (RecLinkInfo(252,100,57,_recCount)<>0) then begin
    Msg(100004,translate('Chargen'),0,0,0);
    RETURN false;
  end;
//  if (Adr.LieferantenNr<>0) and (RecLinkInfo(830,100,31,_recCount)<>0) then begin
//    Msg(100004,translate('Rabatte'),0,0,0);
//    RETURN;
//  end;

  TRANSON;
  // Anschriften löschen
  Erx # RecLink(101,100,12,_recFirst);
  WHILE (Erx=_rOK) do begin
    Erx # RekDelete(101,0,'MAN');
    if (erx<>_rok) then begin
      TRANSBRK;
      RETURN false;
    end;
    Erx # RecLink(101,100,12,_recFirst);
  END;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Partner löschen
  Erx # RecLink(102,100,13,_recFirst);
  WHILE (Erx=_rOK) do begin
    Erx # RekDelete(102,0,'MAN');
    if (erx<>_rok) then begin
      TRANSBRK;
      RETURN false;
    end;
    Erx # RecLink(102,100,13,_recFirst);
  END;
  if (Erx=_rLocked) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Kreditlimit löschen
  if (Adr.Kreditlimit<>0) and (RecLink(103,100,14,_recFirst)<=_rOK) then begin
    if (RecLinkInfo(100,103,1,_recCOunt)<=1) then begin
      RekDelete(103,0,'MAN');
    end;
  end;

  Erx # RekDelete(100,0,'MAN');
  if (erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  _SetData   MS 03.03.2010
//    subfunktion von LoopDataAndReplace
//========================================================================
sub _SetData(
  aFelder               : alpha;
  aNeuerInhalt          : alpha;
  aZuErsetzenderInhalt  : alpha) : logic;
local begin
  vI : int;
  vFeldname : alpha;
  vOk : logic;
end;
begin
   vFeldName # '';

   FOR vI # 1;
   LOOP inc(vI);
   WHILE(vI <= Lib_Strings:Strings_Count(aFelder, ';')) DO BEGIN
    vFeldName # Lib_Strings:Strings_Token(aFelder, ';', vI); // Feldnamen ermitteln
    case FldInfoByName(vFeldName, _FldType) of
      _TypeAlpha  : begin
        if (((FldAlphaByName(vFeldName) = aZuErsetzenderInhalt) and (aZuErsetzenderInhalt <> '')))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, aNeuerInhalt);
          vOK # y;
        end;
      end;

      _TypeWord   : begin
        if ((FldWordByName(vFeldName) = cnvIA(aZuErsetzenderInhalt)) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvIA(aNeuerInhalt));
          vOK # y;
        end;
      end;

      _TypeInt    : begin
        if ((FldIntByName(vFeldName) = cnvIA(aZuErsetzenderInhalt)) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvIA(aNeuerInhalt));
          vOK # y;
        end;
      end;

      _TypeFloat  : begin
        if ((FldFloatByName(vFeldName) = cnvFA(aZuErsetzenderInhalt)) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvFA(aNeuerInhalt));
          vOK # y;
        end;
      end;

      _TypeDate   : begin
        if ((FldDateByName(vFeldName) = cnvDA(aZuErsetzenderInhalt)) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvDA(aNeuerInhalt));
          vOK # y;
        end;
      end;

      _TypeTime   : begin
       if ((FldTimeByName(vFeldName) = cnvTA(aZuErsetzenderInhalt)) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvTA(aNeuerInhalt));
          vOK # y;
        end;
      end;

      _TypeLogic  : begin
        if ((FldLogicByName(vFeldName) = cnvLI(cnvIA(aZuErsetzenderInhalt))) and (aZuErsetzenderInhalt <> ''))
          or (aZuErsetzenderInhalt = '') then begin
          FldDefByName(vFeldName, cnvLI(cnvIA(aNeuerInhalt)));
          vOK # y;
        end;
      end;
    end; // case

   END;

  RETURN vOK;
end;


//========================================================================
//  LoopDataAndReplace  MS 03.03.2010
//  04.03.2010 MS: diese Funktion werde ich nochmal ueberarbeiten
//========================================================================
sub LoopDataAndReplace(
  aZieldatei                : int;
  aAusgangsdatei            : int;
  aKeyOrVerknuepfung        : int;
  aFelder                   : alpha;
  aNeuerInhalt              : alpha;
  opt aZuErsetzenderInhalt  : alpha;
  opt aProgress             : int;
) : logic;
local begin
  Erx       : int;
  vI        : int;
  vFeldname : alpha;
  vBuf      : int;
  vAnz      : int;

  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
end;
begin

  if(aZieldatei = 0) or (aKeyOrVerknuepfung = 0) or (aFelder = '') then
    RETURN false;

  if (StrCut(aFelder, StrLen(aFelder), 1) <> ';') then // benoetigt fuer _SetData
    aFelder # aFelder + ';';

  if (aAusgangsdatei = 0) then begin // per Schluessel in Datei lesen

    // 02.09.2016 AH: Umbau auf Selektion
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI <= Lib_Strings:Strings_Count(aFelder, ';')) DO BEGIN
      vFeldName # Lib_Strings:Strings_Token(aFelder, ';', vI);
      Lib_Sel:QInt(var vQ, '"'+vFeldName+'"',  '=', cnvia(aZuErsetzenderInhalt), 'OR');
    END;

    vSel # SelCreate(aZielDatei, Max(aKeyOrVerknuepfung,1));
    Erx # vSel->SelDefQuery('', vQ);
    if (Erx<>0) then Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);
    
    if (aProgress<>0) then Lib_Progress:SetMax(aProgress, RecInfo(aZielDatei, _recCount, vSel));
    
    FOR Erx # RecRead(aZielDatei ,vSel, _recFirst | _recLock)
    LOOP Erx # RecRead(aZielDatei, vSel, _recNext | _recLock)
    WHILE (Erx <= _rLocked) DO BEGIN
      if (aProgress<>0) then aProgress->Lib_Progress:Step()
      if (_SetData(aFelder, aNeuerInhalt, aZuErsetzenderInhalt)) then begin; // Feld(er) mit neuem Inhalt belegen
        Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
        if(Erx <> _rOK) then
          RETURN false; // konnte geaenderten Datensatz nicht speichern
        inc(vAnz);
      end
      else begin
        RecRead(aZielDatei, 1, _recUnlock);
      end;
    END;
    SelClose(vSel);
    SelDelete(aZielDatei, vSelName);

/**
    FOR  Erx # RecRead(aZieldatei, aKeyOrVerknuepfung, _recFirst | _recLock);
    LOOP Erx # RecRead(aZieldatei, aKeyOrVerknuepfung, _recNext | _recLock);
    WHILE(Erx = _rOK) DO BEGIN

      if (_SetData(aFelder, aNeuerInhalt, aZuErsetzenderInhalt)) then begin; // Feld(er) mit neuem Inhalt belegen
        Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
        if(Erx <> _rOK) then
          return false; // konnte geaenderten Datensatz nicht speichern
        inc(vAnz);
      end
      else begin
        RecRead(aZielDatei, 1, _recUnlock);
      end;
    END;
**/

  end
  else if ((aAusgangsdatei <> 0) and (aZuErsetzenderInhalt <> '')) then begin // ueber eine Verknuepfung in Datei lesen
    FOR Erx # RecLink(aZieldatei, aAusgangsdatei, aKeyOrVerknuepfung, _recFirst | _recLock);
    LOOP Erx # RecLink(aZieldatei, aAusgangsdatei, aKeyOrVerknuepfung, _recFirst | _recLock);
    WHILE(Erx = _rOK) DO BEGIN

      if (aProgress<>0) then aProgress->Lib_Progress:Step()
      if (_SetData(aFelder, aNeuerInhalt, aZuErsetzenderInhalt)) then begin; // Feld(er) mit neuem Inhalt belegen
        Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
        if(Erx <> _rOK) then
          return false; // konnte geaenderten Datensatz nicht speichern
        inc(vAnz);
      end
      else begin
        RecRead(aZielDatei, 1, _recUnlock);
      end;

    END;
  end;

  if(Erx = _rLocked) then // konnte einen Datensatz nicht aendern
    RETURN false;

//debugx(aint(aZieldatei)+' : '+aint(vAnz));
  RETURN true;
end;


//========================================================================
//  SetKundennr
//
//========================================================================
sub SetKundennr(aNeu : int) : logic;
local begin
  Erx         : int;
  vI          : int;
  vMax        : int;
  vPos        : int;
  vSize       : int;
  vDia        : int;
  vHdl,vHdl2  : int;
  vBuf100     : int;
end;
begin
  if (Adr.Kundennr=0) then RETURN false;

  vBuf100 # RekSave(100);
  vBuf100->Adr.Kundennr # aNeu;
  if(RecRead(vBuf100, 2, _recTest) <= _rMultiKey) then begin
    RecBufDestroy(vBuf100);
    Msg(100000, '', 0, 0, 0);
    RETURN true;
  end;
  RecBufDestroy(vBuf100);

  vMax # 25;
  vI # 1;

  vDia  # WinOpen('Dlg.Progress',_WinOpenDialog);
  vHdl  # Winsearch(vDia,'Label1');
  vHdl2 # Winsearch(vDia,'Progress');
  vHdl2->wpProgressPos # vI;
  vHdl2->wpProgressMax # vMax;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

  TRANSON;

  vHdl->wpcaption # 'Vertreter';
  if(LoopDataAndReplace(111, 100, 41, 'Ver.P.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK;
    vDia->WinClose();
    RETURN false;
  end; //  111                 // Vertreter ProvTab

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Material';
  if(LoopDataAndReplace(200, 0, 1, 'Mat.KommKundennr;Mat.VK.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK;
    vDia->WinClose();
    RETURN false;
  end; //  200 x 2             // Material

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # '(~)Material';
  if(LoopDataAndReplace(210, 0, 1, 'Mat~KommKundennr;Mat~VK.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  210 x 2             // (~)Material

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Mat.Res';
  if(LoopDataAndReplace(203, 100, 34, 'Mat.R.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  203                 // Mat.Res

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Materialstruktur';
  if(LoopDataAndReplace(220, 100, 50, 'MSL.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  220                 // Materialstruktur

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Reklamation';
  if(LoopDataAndReplace(300, 100, 49, 'Rek.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  300                 // Reklamation

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Rek.Pos';
  if(LoopDataAndReplace(301, 0, 1, 'Rek.P.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  301                 // Rek.Pos

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Auftragskopf';
  if(LoopDataAndReplace(400, 100, 45, 'Auf.Kundennr;Auf.Rechnungsempf', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  400 x 2             // Auftragskopf
  if(LoopDataAndReplace(400, 100, 46, 'Auf.Kundennr;Auf.Rechnungsempf', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  400 x 2             // Auftragskopf

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # '(~)Auftragskopf';
  if(LoopDataAndReplace(410, 0, 1, 'Auf~Kundennr;Auf~Rechnungsempf', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  410 x 2             // (~)Auftragskopf

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Auftragspos';
  if(LoopDataAndReplace(401, 100, 22, 'Auf.P.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  401                 // Auftragspos

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # '(~)Auftragspos';
  if(LoopDataAndReplace(411, 100, 71, 'Auf~P.Kundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  411                 // (~)Auftragspos

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Lfs';
  if(LoopDataAndReplace(440, 100, 42, 'Lfs.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  440                 // Lfs

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Lfs.Pos';
  if(LoopDataAndReplace(441, 0, 1, 'Lfs.P.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  441                 // Lfs.Pos

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Erlöse';
  if(LoopDataAndReplace(450, 100, 25, 'Erl.Kundennummer;Erl.Rechnungsempf', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  450 x 2             // Erloese
  if(LoopDataAndReplace(450, 100, 47, 'Erl.Kundennummer;Erl.Rechnungsempf', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  450 x 2             // Erloese

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Erl.Konto';
  if(LoopDataAndReplace(451, 0, 1, 'Erl.K.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  451                 // Erl.Konto

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Ofp';
  if(LoopDataAndReplace(460, 100, 26, 'OfP.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  460                 // Ofp

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Zahlungseingang';
  if(LoopDataAndReplace(465, 100, 37, 'ZEi.Kundennummer', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  465                 // Zahlungseingang

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Einkaufspos';
  if(LoopDataAndReplace(501, 0, 1, 'Ein.P.KommiKunde', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  501                 // Einkaufspos
  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # '(~)Einkaufspos';
  if(LoopDataAndReplace(511, 0, 1, 'Ein~P.KommiKunde', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  511                 // (~)Einkaufspos

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Versand';
  if(LoopDataAndReplace(650, 100, 67, 'Vsd.SelbstabholKdNr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  650                 // Versand
  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Versandpool';
  if(LoopDataAndReplace(651, 0, 1, 'VsP.AuftragsKundennr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  655                 // Versandpool

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'BA.Fertigung';
  if(LoopDataAndReplace(703, 100, 48, 'BAG.F.ReservFürKunde', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  703                 // BA.Fertigung

  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Statistik';
  if(LoopDataAndReplace(899, 0, 1, 'Sta.Re.Empf.KdNr;Sta.Auf.Kunden.Nr', AInt(aNeu), AInt(Adr.Kundennr)) = false) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end; //  899 x 2             // Statistik


  PtD_Main:Memorize(100); // alten Stand merken
  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Finalisiere';
  Erx # RecRead(100, 1, _recLock);
  if(Erx <> _rOK) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end;
  Adr.Kundennr # aNeu;
  Erx # RekReplace(100, _recUnlock, 'AUTO');
  if(Erx <> _rOK) then begin
    TRANSBRK; vDia->WinClose();
    return false;
  end;
  PtD_Main:Compare(100); // vergleichen und ggf. ins Protokoll schreiben

  if (vDia->WinDialogResult() = _WinIdCancel) then begin
    vDia->WinClose();
    TRANSBRK;
    return true;
  end;

  TRANSOFF;

  vDia->WinClose();
  return true;
end;

/****
//========================================================================
//  SetLieferantennr
//
//========================================================================
sub SetLieferantennr(aNeu : int) : logic;
local begin
  vI  : int;
end;
begin
  // Datenbanklinks, Stand 05.11.2009
  vI # vI + RecLinkInfo(181,100,68,_recCount); // HuB Preise
  vI # vI + RecLinkInfo(190,100,69,_recCount); // HuB EK Lieferant
//  191
  vI # vI + RecLinkInfo(200,100,17,_recCount); // Mat
//  210
  vI # vI + RecLinkInfo(220,100,63,_recCount); // MSL.Lf
  vI # vI + RecLinkInfo(230,100,56,_recCount); // Lys.K
  vI # vI + RecLinkInfo(252,100,57,_recCount); // Art.C
  vI # vI + RecLinkInfo(300,100,61,_recCount); // Reklamation.Lf
//  301
  vI # vI + RecLinkInfo(405,100,59,_recCount); // Auf.K
  vI # vI + RecLinkInfo(500,100,54,_recCount); // Ein.Lf
  vI # vI + RecLinkInfo(500,100,55,_recCount); // Ein.Besitzer
//  510
//  510
  vI # vI + RecLinkInfo(501,100,23,_recCount); // Ein.P
//  511
  vI # vI + RecLinkInfo(505,100,58,_recCount); // Ein.K
  vI # vI + RecLinkInfo(506,100,62,_recCount); // Wareneingang.Lf
  vI # vI + RecLinkInfo(540,100,36,_recCount); // Bdf
  vI # vI + RecLinkInfo(541,100,53,_recCount); // Bdf.A.Lf
  vI # vI + RecLinkInfo(550,100,27,_recCount); // Verbindlichkeit (VBK)
  vI # vI + RecLinkInfo(555,100,24,_recCount); // EKK
  vI # vI + RecLinkInfo(560,100,28,_recCount); // Eingangsrechnung
  vI # vI + RecLinkInfo(565,100,38,_recCount); // Zahlungsausgang
  vI # vI + RecLinkInfo(620,100,44,_recCount); // SammelWE
  vI # vI + RecLinkInfo(621,100,64,_recCount); // SWe.Lf
  vI # vI + RecLinkInfo(650,100,66,_recCount); // Versand
  vI # vI + RecLinkInfo(655,100,65,_recCount); // Versandpool
  vI # vI + RecLinkInfo(702,100,39,_recCount); // BAG.Position
  vI # vI + RecLinkInfo(831,100,60,_recCount); // Kal.P

  if ( vI > 0 ) then begin
    Msg( 100011, '', 0, 0, 0 );
    RETURN false;
    end
  else begin
    RecRead( 100, 1, _recLock );
    Adr.Lieferantennr # aNeu;
    if ( RecRead( 100, 3, _recTest ) <= _rMultiKey ) then begin
      Msg( 100001, '', 0, 0, 0 );
      RETURN false;
    end

    if ( RekReplace( 100, _recUnlock ) != _rOk ) then begin
      Msg( 999999, 'Änderungen können nicht vorgenommen werden.', 0, 0, 0 );
      RETURN false;
    end;

    RETURN true;
  end;
end;
***/

//========================================================================
//  SetLieferantennr
//
//========================================================================
sub SetLieferantennr(aNeu : int) : logic;
local begin
  Erx         : int;
  vI          : int;
  vMax        : int;
  vPos        : int;
  vSize       : int;
  vDia        : int;
  vHdl,vHdl2  : int;
  vBuf100     : int;
  vOK         : logic;
end;
begin
  if (Adr.Lieferantennr=0) then RETURN false;

  vBuf100 # RekSave(100);
  vBuf100->Adr.Lieferantennr # aNeu;
  if(RecRead(vBuf100, 3, _recTest) <= _rMultiKey) then begin
    RecBufDestroy(vBuf100);
    Msg(100001, '', 0, 0, 0);
    RETURN true;
  end;
  RecBufDestroy(vBuf100);


  vMax  # 30;
  vI    # 1;

  vDia  # WinOpen('Dlg.Progress',_WinOpenDialog);
  vHdl  # Winsearch(vDia,'Label1');
  vHdl2 # Winsearch(vDia,'Progress');
  vHdl2->wpProgressPos # vI;
  vHdl2->wpProgressMax # vMax;
  vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

  TRANSON;

  LF_ChangeOrEnd('Hilfs & Betriebsstoffe - Preise', 181,100,68,'HuB.P.Lieferant');
  LF_ChangeOrEnd('Hilfs & Betriebsstoffe - Einkauf', 190,100,69,'HuB.EK.Lieferant');
  LF_ChangeOrEnd('Hilfs & Betriebsstoffe - Einkauf', 191,  0, 1,'HuB.EK.P.Lieferant');
  LF_ChangeOrEnd('Material', 200,100,17,'Mat.Lieferant');
  LF_ChangeOrEnd('Materialablage', 210,  0,1,'Mat~Lieferant');
  LF_ChangeOrEnd('Materialstruktur', 220,100,63,'MSL.Lieferantennr');
  LF_ChangeOrEnd('Analyse', 230,100,56,'Lys.K.Lieferant');
  LF_ChangeOrEnd('Artikel', 252,100,57,'Art.C.Lieferantennr');
  LF_ChangeOrEnd('Reklamationen', 300,100,61,'Rek.Lieferantennr');
  //LF_ChangeOrEnd('Reklamationspositionen', 301,  0,1,'Rek.P.Lieferantennr');
  Erx # RecRead(301,1,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecRead(301,1,_RecLock);
    if (Rek.P.Lieferantennr=Adr.Lieferantennr) then
      Rek.P.Lieferantennr # aNeu;
    if (Rek.P.Verursacher=1) and (Rek.P.Verursachernr=Adr.Lieferantennr) then
      Rek.P.Verursachernr # Adr.Lieferantennr;
    Erx # RekReplace(301,1,'AUTO');
    Erx # RecRead(301,1,_recNext);
  END;

  LF_ChangeOrEnd('Auftragskalulationen', 405,100,59,'Auf.K.Lieferantennr');
  LF_ChangeOrEnd('Bestellungen', 500,100,54,'Ein.Lieferantennr');
  LF_ChangeOrEnd('Bestellungen-Besitzer', 500,100,55,'Ein.Rechnungsempf');
  LF_ChangeOrEnd('Bestellungenablage', 510,  0,1 ,'Ein~Lieferantennr');
  LF_ChangeOrEnd('Bestellungenablage-Besitzer', 510,  0, 1,'Ein~Rechnungsempf');
  LF_ChangeOrEnd('Bestellposition', 501,100,23,'Ein.P.Lieferantennr');
  LF_ChangeOrEnd('Bestellpositionablage', 511,100,29,'Ein~P.Lieferantennr');
  LF_ChangeOrEnd('Bestellkalkulation', 505,100,58,'Ein.K.LieferantenNr');
  LF_ChangeOrEnd('Wareneingang', 506,100,62,'Ein.E.Lieferantennr');
  LF_ChangeOrEnd('Bedarf', 540,100,36,'Bdf.Lieferant.Wunsch');
  LF_ChangeOrEnd('Bedarf', 545,  0, 1,'Bdf~Lieferant.Wunsch');
  LF_ChangeOrEnd('Bedarfaktion', 541,100,53,'Bdf.A.Lieferant');
  LF_ChangeOrEnd('Verbindlichkeiten', 550,100,27,'Vbk.Lieferant');
  LF_ChangeOrEnd('Einkaufskontrolle', 555, 100,24,'EKK.Lieferant');
  LF_ChangeOrEnd('Eingangsrechnung', 560, 100,28,'ERe.Lieferant');
  LF_ChangeOrEnd('Zahlungsausgang', 565, 100,38,'ZAu.Lieferant');
  LF_ChangeOrEnd('Sammelwareneingang', 620, 100,44,'SWe.Lieferant');
  LF_ChangeOrEnd('Sammelwareneingang-Positionen', 621, 100,64,'SWe.P.Lieferantennr');
  LF_ChangeOrEnd('Versand', 650, 0, 1,'Vsd.Spediteurnr');
  LF_ChangeOrEnd('Versandpool', 655, 0, 3,'VsP.Spediteurnr');
  LF_ChangeOrEnd('Versandpoolablage', 655, 0, 3,'VsP~Spediteurnr');
  LF_ChangeOrEnd('BAG', 702, 100,39,'BAG.P.ExterneLiefNr');
  LF_ChangeOrEnd('Vorkalkulationen', 831, 100,60,'Kal.P.LieferantenNr');

  PtD_Main:Memorize(100); // alten Stand merken
  inc(vI);
  vHdl2->wpProgressPos # vI;
  vHdl->wpcaption # 'Adressen';
  Erx # RecRead(100, 1, _recLock);
  if(Erx <> _rOK) then begin
    TRANSBRK;
    vDia->WinClose();
    RETURN false;
  end;
  Adr.Lieferantennr # aNeu;
  Erx # RekReplace(100, _recUnlock, 'AUTO');
  if(Erx <> _rOK) then begin
    TRANSBRK;
    vDia->WinClose();
    RETURN false;
  end;
  PtD_Main:Compare(100); // vergleichen und ggf. ins Protokoll schreiben

  if (vDia->WinDialogResult() = _WinIdCancel) then begin
    vDia->WinClose();
    TRANSBRK;
    RETURN true;
  end;

  TRANSOFF;

  vDia->WinClose();
  RETURN true;
end;


//========================================================================
//  CaclIBAN
//
//========================================================================
sub CalcIBAN(
  aLKZ    : alpha;
  aBLZ    : alpha;
  aKonto  : alpha;
  ) : alpha;
local begin
  tSOAP         : int;
  tSOAPBody     : int;
  tSOAPElement  : int;
  tErr          : int;
  vBez  : alpha(1000);
  vPlz  : alpha(1000);
  vOrt  : alpha(1000);
  vBIC  : alpha(1000);

  vA      : alpha;
  vBig    : bigint;
  vBLZ    : alpha;
  vKonto  : alpha;
  vBBan   : alpha;
  vLKZ    : alpha;
  vI      : int;
  vCheckS : alpha;
  vLKZAlp : alpha;
  vPZ     : alpha;
  vIBAN   : alpha;
end;
begin

  vLKZ    # aLKZ;
  vLKZ    # StrCnv(vLKZ,_Strupper);

  // NUR für Deustchland!
  if (vLKZ='D') then vLKZ # 'DE';
  if (vLKZ<>'DE') then RETURN '';


  vBig    # cnvba(aBLZ);
  vBLZ    # cnvab(vBig, _FmtNumNoGroup);

  vBig    # cnvba(aKonto);
//          1234567890
  if (vBig<10000000000\b) then
    vKonto  # cnvab(vBig, _FmtNumNoGroup|_FmtNumLeadZero,0,10)
  else
    vKonto  # cnvab(vBig, _FmtNumNoGroup);

  vBBan   # vBLZ+vKonto;
//debug('BBAN:'+vBBAN);

  vLKZAlp # '';
  FOR vI # 1 loop inc(vI) while (vI<=StrLen(vLKZ)) do
    vLKZAlp # vLKZAlp + cnvai(StrToChar(vLKZ, vI) - 64 + 9 );

  vLKZAlp # vLKZalp + '00';
//debug('num LKZ:'+vLKZAlp);

  vCheckS # vBBAN + vLKZAlp;
  vI # Lib_Berechnungen:StrModulo(vCheckS, 97);
//debug('mod:'+aint(vI));

  vPZ # cnvai(98 - vI,_FmtNumNoGroup|_FmtNumLeadZero,0,2);
//debug('PZ:'+vPZ);

  vIBAN # vLKZ+vPZ+vBBAN;

//todo('IBAN=LKZ+PZ+BBAN: '+vIBAN);

  vIBAN # StrIns(vIBAN,' ',5);
  vIBAN # StrIns(vIBAN,' ',10);
  vIBAN # StrIns(vIBAN,' ',15);
  vIBAN # StrIns(vIBAN,' ',20);
  vIBAN # StrIns(vIBAN,' ',25);

  RETURN vIBAN;
end;


//========================================================================
//  CheckIBAN
//
//========================================================================
sub CheckIBAN(aIBAN : alpha) : logic
local begin
  vLKZAlp : alpha;
  vPZ     : alpha;
  vI      : int;
  vIBAN   : alpha;
end;
begin

  vIBAN   # StrADJ(aIBAN, _StrALL|_StrUpper);
  vI # StrToChar(vIBAN, 1) - 64 + 9;
  if (vI>=10) and (vI<=25+10) then begin
    vLKZAlp # cnvai(StrToChar(vIBAN, 1) - 64 + 9 );

    vI # StrToChar(vIBAN, 2) - 64 + 9;
    if (vI>=10) and (vI<=25+10) then begin

      vLKZAlp # vLKZAlp + cnvai(StrToChar(vIBAN, 2) - 64 + 9 );

      vPZ     # StrCut(vIBAN, 3, 2);

      vIBAN   # StrCut(vIBAN,5,200)+vLKZAlp+vPZ;

      vI # Lib_Berechnungen:StrModulo(vIBAN, 97);
    end;
  end;

  // alles ok
  if (vPZ<>'') and (vI=1) then begin
    Msg(100016,aIBAN,0,0,0);
    RETURN true;
  end;


  Msg(100015,aIBAN,0,0,0);
  RETURN false;
end;


//========================================================================
//  CheckBLZ
//
//========================================================================
sub CheckBLZ(
  aBLZ      : alpha;
  var aName : alpha;
  var aBIC  : alpha;
  ) : logic;
local begin
  vSOAP         : int;
  vSOAPBody     : int;
  vSOAPElement  : int;
  vErr          : int;
  vBez          : alpha(1000);
  vPlz          : alpha(1000);
  vOrt          : alpha(1000);
  vBIC          : alpha(1000);
  vI            : int;
end;
begin

  vI # cnvia(aBLZ);
  try begin
    // Initialisierung: SOAP-Client-Instanz anlegen
    vSOAP # C16_SysSOAP:Init(
      // Serveradresse
      'http://www.thomas-bayer.com/axis2/services/BLZService',
      // Namensraum
      'http://thomas-bayer.com/blz/');

    // Anfragekörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RqsBody();
    // Wert hinzufügen
    vSOAPBody->C16_SysSOAP:ValueAddInt('blz', vI);
    // Anfrage versenden und Antwort empfangen
    vSOAP->C16_SysSOAP:Request('getBank', '""');
    // Antwortkörper ermitteln
    vSOAPBody # vSOAP->C16_SysSOAP:RspBody();
    // Element ermitteln
    vSOAPElement # vSOAPBody->C16_SysSOAP:ElementGet('details');
    if (vSOAPElement > 0) then begin
      // Werte ermitteln
      vSOAPElement->C16_SysSOAP:ValueGetString('bezeichnung', var vBez);
      vSOAPElement->C16_SysSOAP:ValueGetString('bic', var vBIC);
      vSOAPElement->C16_SysSOAP:ValueGetString('ort', var vOrt);
      vSOAPElement->C16_SysSOAP:ValueGetString('plz', var vPLZ);
    end;
  end;

  // Fehler ermitteln
  vErr # ErrGet();
  // Kein Fehler aufgetreten
  if (vErr = _ErrOK) then begin
/***
    // Werte ausgeben
    WinDialogBox(0, 'getBank()',
      'Bezeichnung: ' + vBez + cCRLF +
      'BIC: ' + vBIC + cCRLF +
      'Ort: ' + vOrt + cCRLF +
      'PLZ: ' + vPLZ,
      _WinIcoInformation, _WinDialogOK, 1
    );
***/
//vBez # vOrt;
//debug(vBez);
  //  vBic  # Lib_Strings:Strings_XML2DOS(vBIC);
  //  vBez  # Lib_Strings:Strings_XML2DOS(vBez);
    vBic  # StrCnv(vBic,_StrFromUTF8);
    vBez  # StrCnv(vBez,_StrFromUTF8);
    aBIC  # StrCut(vBIC,1,16);
    aName # StrCut(vBez,1,32);
    end;
/***
  // Fehler aufgetreten
  else begin
    // SOAP-Fehler
    if (vErr = _Err.SOAPFault) then begin
      // SOAP-Fehler ausgeben
      WinDialogBox(0, 'getBank()',
        'SOAP-Fehler: ' + tSOAP->C16_SysSOAP:RspFaultCode() + cCRLF +
        tSOAP->C16_SysSOAP:RspFaultReason(),
        _WinIcoError, _WinDialogOK, 1
      );
      end
    // Allgemeiner Fehler
    else begin
      // Fehler ausgeben
      WinDialogBox(0, '', 'Fehler: ' + CnvAI(tErr),
        _WinIcoError, _WinDialogOK, 1
      );
    end;
  end;
***/

  // Terminierung: SOAP-Client-Instanz freigeben
  if (vSOAP > 0) then vSOAP->C16_SysSOAP:Term();

  RETURN (vErr=_ErrOK);
end;


//========================================================================