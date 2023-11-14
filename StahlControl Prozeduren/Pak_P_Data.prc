@A+
//==== Business-Control ==================================================
//
//  Prozedur    Pak_P_Data
//                    OHNE E_R_G
//  Info
//
//
//  15.02.2012  ST  Erstellung der Prozedur
//  05.07.2018  ST  ggf. Paketnummern in Weiterverarbeitungen entfernen  Projekt 1810/39:
//  16.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB Delete(aLock : int; aGrund : alpha) : int;
//    SUB UpdateMaterial(aMaterial   : int;opt aPaket : int;) : int;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aLock   : int;
  aGrund  : alpha;
) : int;
local begin
  vErg : int;
end
begin
  // Falls Material vorhanden ist und die Paketnummer übereinstimmt,
  // Paketnummer lösen
  Mat.Nummer # Pak.P.MaterialNr;
  if (RecRead(200,1,0) = _rOK) then begin
    if (Mat.PaketNr = Pak.P.Nummer) then begin
      RecRead(200,1,_RecLock);
      Mat.PaketNr # 0;
      Mat_data:Replace(_recunlock,'MAN');  // 26.08.2014 war RekReplace(200,_RecUnlock,'MAN');
    end;
  end;


  // ST 2018-07-05 Projekt 1810/39: ggf. Paketnummern in Weiterverarbeitungen entfernen
  Mat.Paketnr # Pak.P.Nummer;
  WHILE (RecRead(200,36,0) <= _rMultikey) AND (Mat.Paketnr = Pak.P.Nummer) DO BEGIN
    RecRead(200,1,_RecLock);
    Mat.PaketNr # 0;
    Mat_data:Replace(_recunlock,'MAN');
  END;
  
  vErg # RekDelete(281,aLock,aGrund);

  // Gesamtpaket neu berechnen
  Pak_Data:Refresh();

  RETURN vErg;
end;


//========================================================================
//  UpdateMaterial
//    Aktualisiert die Paketnummer an einem Material
//========================================================================
sub UpdateMaterial(
  aMaterial   : int;
  opt aPaket : int;
) : int;
local begin
  Erx : int;
end;
begin

  if (aPaket <> 0) then
    Pak.P.Nummer # aPaket;

  // Falls Material vorhanden ist und die Paketnummer übereinstimmt,
  // Paketnummer lösen
  Mat.Nummer # aMaterial;
  Erx # RecRead(200,1,_RecLock);
  if (Erx = _rOK) then begin
    Mat.PaketNr # Pak.P.Nummer;
    Mat_data:Replace(_recunlock,'MAT');  // 26.08.2014 war RekReplace(200,_RecUnlock,'MAT');
  end;

  RETURN Erx;
end;


//========================================================================