@A+
//===== Business-Control =================================================
//
//  Prozedur  SOA_Sync_CmdActions
//                    OHNE E_R_G
//  Info
//    Enthält die Funktionen, die durch den Commandimport aufgerufen
//    werden
//
//  21.04.2017  ST  Erstellung der Prozedur
//
//  Subprozeduren
//
//    sub Ping(aPara : alpha; var aErrText : alpha)
//    sub MatUmlagern(aPara : alpha; var aErrText : alpha)
//
//========================================================================
@I:Def_Global


//vOK  # Call('SOA_Sync_CmdActions:'+vCommand, vArgs, var vErr);

//========================================================================
//  sub Ping(aPara : alpha; var aErrText : alpha)
//      Ermöglicht die Prüfung ob die Synchronisierung aktiv ist
//========================================================================
sub Ping(aPara : alpha; var aErrText : alpha)
begin
  aErrText # '';
  ErrSet(_rOK);
end;


//========================================================================
//  sub MatUmlagern(aPara : alpha; var aErrText : alpha)
//    Lagert die übergebenen Mateiralnummern auf den angegebenen Lagerplatz
//    um
//========================================================================
sub MatUmlagern(aPara : alpha; var aErrText : alpha)
local begin
  vLpl    : alpha;
  vMats   : alpha(4000);
  vMatCnt : int;

  i       : int;
  vMat    : alpha;
  vErrCnt : int;
end
begin
  if (aPara <> '') then begin
    vLpl  # Str_Token(aPara,'|',1);
    vMats # Str_Token(aPara,'|',2);

    TRANSON;

    vMatCnt # Lib_Strings:Strings_Count(vMats,';');
    if (vMatCnt = 0) AND (StrLen(vMats)>0) then
      vMatCnt # 1;

    FOR   i # 1
    LOOP  inc(i)
    WHILE i<=vMatCnt DO BEGIN
      vMat  # Str_Token(vMats,';',i);
      if (Mat_Data:SetInventur(CnvIa(vMat),vLpl, today, false) = false) then begin
        inc(vErrCnt);
        BREAK;
      end;
    END;

    if (vErrCnt > 0) then begin
      aErrText # 'Material ' + vMat + ' konnte nicht auf Lagerplatz ' + vLpl + ' umgelagert werden';
      TRANSBRK;
    end else
      TRANSOFF;

  end;

  ErrSet(_rOK);
end;




//========================================================================
//  sub LfsVerbucheVLDAW (aPara : alpha; var aErrText : alpha)
//      Verbucht eine VLDAW zu einem Lieferschein
//========================================================================
sub LfsVerbucheVLDAW(aPara : alpha; var aErrText : alpha)
local begin
  vLfs : int;
end
begin
  if (aPara = '') then begin
    aErrText # 'VLDAW nicht angegeben';
    ErrSet(_rOK);
    RETURN;
  end;

  Lfs.Nummer # CnvIa(aPara);
  if (RecRead(440,1,0) <> _rOK) then begin
    aErrText # 'VLDAW nicht lesebar';
    ErrSet(_rOK);
    RETURN;
  end;

  // Lieferschein Drucken und verbuchen
  if (Lfs_Data:Druck_LFS(true)) then
    Lfs_Data:Verbuchen(Lfs.Nummer, today, now, true);

  // irgendwas schiefgelaufen (Kredlim, Satzsperre etc)
  if (Errlist <> 0) then begin
    aErrText # 'Auslieferung gesperrt!';
    ErrSet(_rOK);
  end;
  ErrList # 0;

  aErrText # '';
  ErrSet(_rOK);
end;




//========================================================================
//  sub Printform(aPara : alpha; var aErrText : alpha)
//      Startet einen Dokumentendruck auf dem Server
//========================================================================
sub Printform(aPara : alpha; var aErrText : alpha)
local begin

end
begin



  aErrText # '';
  ErrSet(_rOK);
end;



//========================================================================