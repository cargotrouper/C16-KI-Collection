@A+
//===== Business-Control =================================================
//
//  Prozedur    Dlg_Stichwort
//                    OHNE E_R_G
//  Info
//
//
//  16.08.2006  AI Erstellung der Prozedur
//  01.11.2021  AH auch Artikelnummer-Ändern möglich
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    Sub EvtInit(aEvt  : event;) : logic
//    Sub EvtClicked(aEvt : event;) : logic
//    MAIN(aText : alpha; aFeldName : alpha) : alpha
//========================================================================
@I:Def_Global

define begin
  ErrorDlg(a) : begin TRANSBRK; Msg(999999,a+' konnte nicht gespeichert werden!',0,0,0); RETURN true; end;
end;

//========================================================================
//  EvtInit
//
//========================================================================
Sub EvtInit(
  aEvt  : event;
) : logic
begin
   $edText->WinFocusSet(true);
end;


//========================================================================
//========================================================================
sub _PrimKeyContents(
  aDatei    : int;
  aFeldname : alpha) : logic
local begin
  vA    : alpha;
  vI,vJ : int;
  vTds  : int;
  vFld  : int;
end;
begin
  aFeldname # StrCnv(aFeldname,_StrUpper);

  // PRIMARY KEY ***************************************************
  vJ # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
    vFld # KeyFldInfo(aDatei,1,vI,_KeyFldNumber);
    vTds # KeyFldInfo(aDatei,1, vI, _KeyFldSbrNumber);
    vA # FldName(aDatei, vTds, vFld);
    if (vA=^aFeldName) then RETURN true;
  END;
  
  RETURN false;
end;


//========================================================================
// ReplaceAlphaPerSel
//========================================================================
sub ReplaceAlphaPerSel(
  aDatei    : int;
  aFeldname : alpha;
  aAlt      : alpha;
  aNeu      : alpha;
  aProgress : int;
) : logic;
local begin
  vQ        : alpha(4000);
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vAnz      : int;
end;
begin
  Lib_Sel:QAlpha(var vQ, '"'+aFeldName+'"',  '=', aAlt);
//debugx(vQ);
  if (_PrimKeyContents(aDatei,aFeldname)) then begin
//debugx('im primkey!!!');
    vSel # SelCreate(aDatei, 0);
//    vSel->SelAddSortFld(1,2,0);
  end
  else begin
//debugx('nix primkey');
    vSel # SelCreate(aDatei, 1);
  end;

  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);
    
  if (aProgress<>0) then Lib_Progress:SetMax(aProgress, RecInfo(aDatei, _recCount, vSel));
//debugx(aint(aDatei)+' count:'+aint(RecInfo(aDatei, _recCount, vSel)));
  FOR Erx # RecRead(aDatei ,vSel, _recFirst | _recLock)
  LOOP Erx # RecRead(aDatei, vSel, _recNext | _recLock)
  WHILE (Erx <= _rLocked) DO BEGIN
//debugx('KEY252');
//    inc(vAnz);
//if (vAnz>10) then BREAK;
    if (aProgress<>0) then aProgress->Lib_Progress:Step()
    FldDefByName(aFeldname, aNeu);
    Erx # RekReplace(aDatei, _recUnlock, 'AUTO');
//debugx('KEY'+aint(aDatei)+' replace '+aint(erx));
    if(Erx <> _rOK) then begin
      SelClose(vSel);
      SelDelete(aDatei, vSelName);
      RETURN false; // konnte geaenderten Datensatz nicht speichern
    end;
  END;
  SelClose(vSel);
  SelDelete(aDatei, vSelName);

  RETURN true;
end;


//========================================================================
// EvtClicked
//
//========================================================================
Sub EvtClicked(
  aEvt      : event;
) : logic
local begin
  Erx         : int;
  vRecFlag    : int;
  vReplace    : logic;
  vA          : alpha;
  vDia        : int;
  vHdl, vHdl2 : int;
  vMax        : int;
  vNeu, vAlt  : alpha;
  vOK         : Logic;
end;
begin

  // ARTIKEL-NUMMER *******************************************************
  if (aEvt:Obj->wpCustom='Art.Nummer') then begin

    vAlt # Art.C.ArtikelNr; // aus Puffer!
    vNeu # $edText->wpCaption;

    if (Strlen(vNeu)>40) then begin
      RETURN false;
    end;


    vMax # 60;
    vDia  # WinOpen('Dlg.Progress',_WinOpenDialog);
    vHdl  # Winsearch(vDia,'Label1');
    vHdl2 # Winsearch(vDia,'Progress');
    vHdl2->wpProgressPos # 1;
    vHdl2->wpProgressMax # vMax;
    vDia->WinDialogRun(_WinDialogAsync | _WinDialogCenter);

    TRANSON;

    REPEAT
      vHdl->wpcaption # 'Chargen';
      if (ReplaceAlphaPerSel(252, 'Art.C.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;

      vHdl->wpcaption # 'Preise';
      if (ReplaceAlphaPerSel(254, 'Art.P.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrag A';
      if (ReplaceAlphaPerSel(401, 'Auf.P.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrag B';
      if (ReplaceAlphaPerSel(401, 'Auf.P.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrag C';
      if (ReplaceAlphaPerSel(411, 'Auf~P.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrag D';
      if (ReplaceAlphaPerSel(411, 'Auf~P.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Einkauf A';
      if (ReplaceAlphaPerSel(501, 'Ein.P.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Einkauf B';
      if (ReplaceAlphaPerSel(501, 'Ein.P.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Einkauf C';
      if (ReplaceAlphaPerSel(511, 'Ein~P.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Einkauf D';
      if (ReplaceAlphaPerSel(511, 'Ein~P.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;

      vHdl->wpcaption # 'Bedarf A';
      if (ReplaceAlphaPerSel(540, 'Bdf.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Bedarf B';
      if (ReplaceAlphaPerSel(545, 'Bdf~Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;

      vHdl->wpcaption # 'Adress Verpackung';
      if (ReplaceAlphaPerSel(105, 'Adr.V.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Prj.Stückliste';
      if (ReplaceAlphaPerSel(121, 'Prj.SL.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Prj.Zeiten';
      if (ReplaceAlphaPerSel(123, 'Prj.Z.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Rso.Ersatzteile';
      if (ReplaceAlphaPerSel(168, 'Rso.ErT.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Material A';
      if (ReplaceAlphaPerSel(200, 'Mat.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Material B';
      if (ReplaceAlphaPerSel(210, 'Mat~Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Struktur A';
      if (ReplaceAlphaPerSel(220, 'MSL.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Stuktur B';
      if (ReplaceAlphaPerSel(220 , 'MSL.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Artikeljournal A';
      if (ReplaceAlphaPerSel(253, 'Art.J.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Artikeljournal B';
      if (ReplaceAlphaPerSel(253 ,'Art.J.Ziel.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;

      vHdl->wpcaption # 'Artikel SLK';
      if (ReplaceAlphaPerSel(255, 'Art.SLK.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Artikelstückliste A';
      if (ReplaceAlphaPerSel(256, 'Art.SL.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Artikelstückliste B';
      if (ReplaceAlphaPerSel(256, 'Art.SL.Input.ArtNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Artikelinventur';
      if (ReplaceAlphaPerSel(259, 'Art.Inv.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Pakete';
      if (ReplaceAlphaPerSel(281, 'Pak.P.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Reklalamtion';
      if (ReplaceAlphaPerSel(301, 'Rek.P.Artikel', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Reklamation Charge';
      if (ReplaceAlphaPerSel(303, 'Rek.P.C.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrags-Aufpreis';
      if (ReplaceAlphaPerSel(403, 'Auf.Z.Vpg.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrags-Aktion';
      if (ReplaceAlphaPerSel(404, 'Auf.A.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Auftrag-Stückliste';
      if (ReplaceAlphaPerSel(409, 'Auf.SL.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Lieferschein';
      if (ReplaceAlphaPerSel(441, 'Lfs.P.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Erlös';
      if (ReplaceAlphaPerSel(451, 'Erl.K.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Bestellaktion';
      if (ReplaceAlphaPerSel(504, 'Ein.A.ArtikelNr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Wareneingang';
      if (ReplaceAlphaPerSel(506, 'Ein.E.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Einkaufskontrolle';
      if (ReplaceAlphaPerSel(555, 'EKK.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Sammelwareneingang';
      if (ReplaceAlphaPerSel(621, 'SWe.P.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Versandpool A';
      if (ReplaceAlphaPerSel(655, 'VsP.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Versandpool B';
      if (ReplaceAlphaPerSel(656, 'Vsp~Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'BAG-Input';
      if (ReplaceAlphaPerSel(701, 'BAG.IO.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'BAG-Fertigung';
      if (ReplaceAlphaPerSel(703, 'BAG.F.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'BAG-Fertigmeldung';
      if (ReplaceAlphaPerSel(707, 'BAG.FM.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'BAG-Beistellung';
      if (ReplaceAlphaPerSel(708, 'BAG.FM.B.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Warengruppe';
      if (ReplaceAlphaPerSel(819, 'Wgr.Schrottartikel', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Unterlage';
      if (ReplaceAlphaPerSel(838, 'ULa.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Aufpreise A';
      if (ReplaceAlphaPerSel(843, 'ApL.L.Vpg.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Aufpreise B';
      if (ReplaceAlphaPerSel(843, 'ApL.L.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;   // KÜRZER!!???
      vHdl->wpcaption # 'Onlinestatistik';
      if (ReplaceAlphaPerSel(890, 'Ost.Name', 'ART:'+vAlt, 'ART:'+vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Onlinestack';
      if (ReplaceAlphaPerSel(891, 'OSt.S.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Statistik A';
      if (ReplaceAlphaPerSel(899, 'Sta.Lfs.Artikelnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Statistik B';
      if (ReplaceAlphaPerSel(899, 'Sta.Auf.Strukturnr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Statistik C';
      if (ReplaceAlphaPerSel(899, 'Sta.Auf.Artikel.Nr', vAlt, vNeu, vDia) = false) then BREAK;
      vHdl->wpcaption # 'Controlling';
      if (ReplaceAlphaPerSel(950, 'Con.Artikelnummer', vAlt, vNeu, vDia) = false) then BREAK;

      // FINALE: Artikel ändern
      vHdl->wpcaption # 'Artikel';
      Art.Nummer # vAlt;
      RecRead(250,1,_RecLock);
      Art.Nummer # vNeu;
      if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then BREAK;

      vOK # true;  // ERFOLG !!!
    UNTIL (1=1);
    if (vOK=false) then begin
      vA # vHdl->wpcaption;
      TRANSBRK;
      vDia->WinClose();
      Msg(99,'Error bei '+vA,0,0,0);
      RETURN false;
    end;

    TRANSOFF;
    vDia->WinClose();
    Msg(999998,'',0,0,0);
    RETURN true;
  end;
  

  // ARTIKEL-SACHNUMMER****************************************************
  if (aEvt:Obj->wpCustom='Art.Sachnummer') then begin
    if (Strlen($edText->wpCaption)>20) then begin
      RETURN false;
    end;
    TRANSON;

    // Artikel ändern
    RecRead(250,1,_RecLock);
    Art.Sachnummer # $edText->wpCaption;
    if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Artikel');

    // Auftrag
    Erx # RecLink(401,250,3,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Auf.P.Sachnummer # Art.Sachnummer;
      if (Auf_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Auf.Position');
      Erx # RecLink(401,250,3,_recNext|_recLock);
    END;
    Erx # RecLink(411,250,24,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Auf~P.Sachnummer" # Art.Sachnummer;
      if (RekReplace(411,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('~Auf.Position');
      Erx # RecLink(411,250,24,_recNext|_recLock);
    END;

    // Einkauf
    Erx # RecLink(501,250,12,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Ein.P.Sachnummer # Art.Sachnummer;
      if (Ein_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Ein.Position');
      Erx # RecLink(501,250,12,_recNext|_recLock);
    END;
    Erx # RecLink(511,250,18,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Ein~P.Sachnummer" # Art.Sachnummer;
      if (RekReplace(511,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Ein.Position');
      Erx # RecLink(511,250,18,_recNext|_recLock);
    END;

    TRANSOFF;
    $Dlg.Stichwort->WinClose();
    Msg(999998,'',0,0,0);
    RETURN true;
  end;


  // ARTIKEL-KATALOGNR*****************************************************
  if (aEvt:Obj->wpCustom='Art.Katalognr') then begin
    if (Strlen($edText->wpCaption)>40) then begin
      RETURN false;
    end;
    TRANSON;

    // Artikel ändern
    RecRead(250,1,_RecLock);
    Art.Katalognr # $edText->wpCaption;
    if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Artikel');

    // Auftrag
    Erx # RecLink(401,250,3,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Auf.P.Katalognr # Art.Katalognr;
      if (Auf_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Auf.Position');
      Erx # RecLink(401,250,3,_recNext|_recLock);
    END;
    Erx # RecLink(411,250,24,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Auf~P.Katalognr" # Art.Katalognr;
      if (RekReplace(411,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('~Auf.Position');
      Erx # RecLink(411,250,24,_recNext|_recLock);
    END;

    // Einkauf
    Erx # RecLink(501,250,12,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Ein.P.Katalognr # Art.Katalognr;
      if (Ein_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Ein.Position');
      Erx # RecLink(501,250,12,_recNext|_recLock);
    END;
    Erx # RecLink(511,250,18,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Ein~P.Katalognr" # Art.Katalognr;
      if (RekReplace(511,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Ein.Position');
      Erx # RecLink(511,250,18,_recNext|_recLock);
    END;

    TRANSOFF;
    $Dlg.Stichwort->WinClose();
    Msg(999998,'',0,0,0);
    RETURN true;
  end;


  // ARTIKEL-STICHWORT ****************************************************
  if (aEvt:Obj->wpCustom='Art.Stichwort') then begin
    if (Strlen($edText->wpCaption)>40) then begin
      RETURN false;
    end;

    TRANSON;

    // Artikel ändern
    RecRead(250,1,_RecLock);
    Art.Stichwort # $edText->wpCaption;
    if (RekReplace(250,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Artikel');


    // Chargen
    Erx # RecLink(252,250,4,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Art.C.ArtStichwort # Art.Stichwort;
      if (RekReplace(252,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Chargen');
      Erx # RecLink(252,250,4,_recNext|_recLock);
    END;

    // Preise
    Erx # RecLink(254,250,6,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Art.P.ArtStichwort # Art.Stichwort;
      if (RekReplace(254,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Preise');
      Erx # RecLink(254,250,6,_recNext|_recLock);
    END;

    // Auftrag
    Erx # RecLink(401,250,3,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Auf.P.ArtikelSw # Art.Stichwort;
      if (Auf_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Auf.Position');
      Erx # RecLink(401,250,3,_recNext|_recLock);
    END;
    Erx # RecLink(411,250,24,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Auf~P.ArtikelSw" # Art.Stichwort;
      if (RekReplace(411,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('~Auf.Position');
      Erx # RecLink(411,250,24,_recNext|_recLock);
    END;

    // Einkauf
    Erx # RecLink(501,250,12,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Ein.P.ArtikelSW # Art.Stichwort;
      if (Ein_Data:PosReplace(_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Ein.Position');
      Erx # RecLink(501,250,12,_recNext|_recLock);
    END;
    Erx # RecLink(511,250,18,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Ein~P.ArtikelSW" # Art.Stichwort;
      if (RekReplace(511,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('~Ein.Position');
      Erx # RecLink(511,250,18,_recNext|_recLock);
    END;

    // Bedarf
    Erx # RecLink(540,250,14,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      Bdf.ArtikelStichwort # Art.Stichwort;
      if (RekReplace(540,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Bedarf');
      Erx # RecLink(540,250,14,_recNext|_recLock);
    END;
    Erx # RecLink(545,250,15,_recFirst|_recLock);
    WHILE (Erx<=_rlocked) DO BEGIN
      "Bdf~ArtikelStichwort" # Art.Stichwort;
      if (RekReplace(545,_RecUnlock,'AUTO') <> _rOk) then ErrorDlg('Bedarf');
      Erx # RecLink(545,250,15,_recNext|_recLock);
    END;

    TRANSOFF;
    $Dlg.Stichwort->WinClose();
    Msg(999998,'',0,0,0);
    RETURN true;
  end;




  // ADRESS-STICHWORT *****************************************************
  if (aEvt:Obj->wpCustom='Adr.Stichwort') then begin
    if (Strlen($edText->wpCaption)>20) then begin
      RETURN false;
    end;

    TRANSON;

    vA # $edText->wpcaption;

    APPOFF();
    vA # Adr_Data:SetStichwort(vA);
    APPON();

    if (vA<>'') then begin
      TRANSBRK;
      Msg(999999,vA+' konnte nicht gespeichert werden!',0,0,0);
      RETURN true;
    end;

    TRANSOFF;
    $Dlg.Stichwort->WinClose();
    Msg(999998,'',0,0,0);
    RETURN true;
  end; //IF

  RETURN false;

end;


//========================================================================
// Main
//
//========================================================================
MAIN(
  aText     : alpha;
  aFeldName : alpha;
  aTitel    : alpha;
) : alpha
local begin
  vID   : int;
  vHdl  : int;
  vHdl2 : int;
end;
begin
//  vId # WinDialog('Adr.Dlg.Stichwort',_WinDialogCenterScreen);
  vHdl    # WinOpen('Dlg.Stichwort',_WinOpenDialog);
  vHdl2 # vHdl->winsearch('edText');
  if (vHdl2<>0) then begin
    vHdl2->wpcaption      # aText;
    vHdl2->wpDbFieldName  # aFeldName;
  end;
  vHdl2 # vHdl->winsearch('Label.Titel');
  if (vHdl2<>0) then vHdl2->wpcaption # aTitel;

  vHdl2 # vHdl->winsearch('OK');
  if (vHdl2<>0) then vHdl2->wpcustom # aFeldName;

  vId # vHdl->WinDialogRun(_WinDialogCenter);

  vHdl2 # vHdl->winsearch('edText');
  if (vHdl2<>0) then aText # vHdl2->wpcaption;
  vHdl->WinClose();

  If (vId = _WinIdOk) then RETURN aText
  else RETURN '';
end;

//========================================================================