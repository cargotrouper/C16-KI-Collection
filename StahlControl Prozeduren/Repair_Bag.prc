@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Bag
//                  OHNE E_R_G
//  Info
//
//
//  05.05.2017  ST  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_Bag

define begin
end;


//========================================================================
//  Rebuild
//    call Repair_mat:RebuildErlInfo
//========================================================================
sub RebuildBagFirstFahren()
local begin
  Erx         : int;
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);


  vLine     : alpha(250);
  vProgress  : int;


  vNr : int;

  vAktResetList : int;
  vNode   : int;

  vBuf204     :  int;

  vCnt  : int;
end
begin


  Lib_Sel:QInt(var vQ,  'Mat.A.Entstanden', '=', 0);
  Lib_Sel:QAlpha(var vQ, 'Mat.A.Aktionstyp', '=', c_Akt_BA_UmlageMINUS);
  Lib_Sel:QInt(var vQ,  'Mat.A.Aktionsnr', '<>', 0);
  Lib_Sel:QAlpha(var vQ, 'Mat.A.Bemerkung', '=', c_AktBem_BA_Nullung+':'+c_BAG_Fahr);

  vSel # SelCreate(204, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  vProgress # Lib_Progress:Init( 'Ermittle Mat Aktionen', RecInfo( 204, _recCount, vSel ) );


  vAktResetList # CteOpen(_CteNode);


  debug('START mit #' + Aint(RecInfo( 204, _recCount, vSel )));
  FOR Erx # RecRead(204,vSel, _recFirst);
  LOOP Erx # RecRead(204,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

    if (!vProgress->Lib_Progress:Step()) then
      BREAK;

    // ......
    // Material Aktion gelesen
    // ......
    vLine # '';
    Lib_Strings:Append(var vLine, Aint(Mat.A.Materialnr),';');

    // BA Lesen
    Bag.P.Nummer    # Mat.A.Aktionsnr;
    Bag.P.Position  # Mat.A.Aktionspos;
    if (RecRead(702,1,0) <> _rOK) then begin
      Lib_Strings:Append(var vLine, 'BagP '+Aint(MAt.A.Aktionsnr) + '/' + Aint(Mat.A.Aktionspos) + ' nicht gefunden',';');
      debug(vLine);
      CYCLE;
    end else
      Lib_Strings:Append(var vLine, 'BagP '+Aint(Mat.A.Aktionsnr) + '/' + Aint(Mat.A.Aktionspos),';');

    // Echte "Einsätze" prüfen
    FOR   Erx # RecLink(701,702,2,_RecFirst)
    LOOP  Erx # RecLink(701,702,2,_RecNExt)
    WHILE Erx = _rOK DO BEGIN

      // Echter Neueinsazt ohne Vorgänger
      if (BAG.IO.Materialtyp = c_IO_Mat) AND (BAG.IO.VonID = 0) and (BAG.IO.Materialnr=Mat.A.materialnr) then begin
        Lib_Strings:Append(var vLine, 'Einsatz gefunden',';');

        Mat_Data:Read(Mat.A.Materialnr);
        // Aktion von Ursprungsmat entfernen

        vBuf204   # RekSave(204);

        // ... Neue Restkarte anlegen und Schrottnullen
        vNr # BA1_Mat_Data:BildeFahrRest(Mat.Nummer, BAG.P.Fertig.Dat, BAG.P.Fertig.Zeit);
        if (vNr<0) then begin
          Lib_Strings:Append(var vLine, 'Fehler bei BildeFahrRest' ,';');
          debug(vLine);
          CYCLE;
        end else
          Lib_Strings:Append(var vLine, Aint(vNr) ,';');

        RecRead(701,1,_RecLock);
        BAG.IO.MaterialRstNr # vNr;
        RekReplace(701);

        Mat_Subs:Verschrotten(false, '', c_Status_BAGRestFahren);

        // Aktion umbiegen
        RekRestore(vBuf204);

        inc(vCNt);
        vAktResetList->CteInsertItem(Aint(Mat.A.Materialnr)+'/'+Aint(Mat.A.Aktion),vCnt,Aint(vNr));

        Lib_Strings:Append(var vLine, 'OK' ,';');

      end else
        Lib_Strings:Append(var vLine, 'kein Einsatz ' + Aint(BAG.IO.Materialtyp)  + ' vonID ' + Aint(BAG.IO.VonID) + ' nicht gefunden',';');

      debug(vLine);

      // Nächster Input
    END;


    // Nächstes Materiral
  END;

  SelClose(vSel);
  SelDelete(200, vSelName);
  vSel # 0;

  debug('Biege Aktionen um : ' + Aint(CteInfo(vAktResetList,_CteCount)));
  vProgress->Lib_Progress:Reset('Aktualisiere MatAktionen',CteInfo(vAktResetList,_CteCount));
  FOR  vNode # vAktResetList->CteRead(_CteFirst);
  LOOP vNode # vAktResetList->CteRead(_CteNext, vNode);
  WHILE (vNode <> 0) DO BEGIN

    Mat.A.Materialnr # CnvIa(Str_Token(vNode->spName,'/',1));
    Mat.A.Aktion     # CnvIa(Str_Token(vNode->spName,'/',2));
    Erx # RecRead(204,1,_RecLock);
    if (Erx = _errOK) then begin
      Mat.A.Materialnr # CnvIa(vNode->spCustom);
      Mat.A.Aktionsmat # Mat.A.Materialnr ;
      RekReplace(204);
    end;

  END;

  vAktResetList->CteClose();

  vProgress->Lib_Progress:Term();

end;



//========================================================================