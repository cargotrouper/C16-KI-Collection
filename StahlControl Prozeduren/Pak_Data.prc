@A+
//==== Business-Control ==================================================
//
//  Prozedur    Pak_Data
//                OHNE E_R_G
//  Info
//
//
//  15.02.2012  ST  Erstellung der Prozedur
//  31.03.2022  AH  ERX
//  14.04.2022  AH  Pak mit Inhaltangaben
//
//  Subprozeduren
//    SUB Delete(aLock : int; aGrund : alpha) : int;
//    SUB Refresh(opt aPaket : int) : int;
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
  vErgPak : int;
  Erx     : int;
end
begin
  // Positionen löschen
  WHILE(RecLink(281,280,1, _recFirst) = _rOK) DO BEGIN
    Pak_P_Data:Delete(aLock,aGrund);
  END;

  // Kopf löschen
  RecRead(280,1,_RecLock);
  "Pak.Löschmarker" # '*';
  Erx # RekReplace(280,aLock,'MAN');
  //Erx # RekDelete(280,aLock,aGrund);

  RETURN Erx;
end;


//========================================================================
//  sub Refresh(opt aPaket : int) : int;
//
//========================================================================
sub Refresh(opt aPaket : int) : int;
local begin
  Erx     : int;
  vErgPak : int;
  vGew    : float;
  vNetto  : float;
  vBrutto : float;
  vStk    : int;
end
begin

  if (aPaket <> 0) then begin
    Pak.Nummer # aPaket;
    if (RecRead(280,1,0) <> _rOK) then
      RETURN -1;
  end;

  // Positionen neu berechnen
  FOR   vErgPak # RecLink(281,280,1,_RecFirst)
  LOOP  vErgPak # RecLink(281,280,1,_RecNext)
  WHILE(vErgPak = _rOK) DO BEGIN

    // Material lesen
    Erx # Mat_Data:Read(Pak.P.MaterialNr);
    if (erx>=200) then begin
      vGew    # vGew + Mat.Bestand.Gew;
      vNetto  # vNetto + Mat.Gewicht.Netto;
      vBrutto # vBrutto + Mat.Gewicht.Brutto;
      vStk    # vStk + Mat.Bestand.Stk;
    end;
  END;

  RecRead(280,1,_RecLock);
  Pak.Gewicht       # vGew
  Pak.Inhalt.Stk    # vStk;
  Pak.Inhalt.Netto  # vNetto;
  Pak.Inhalt.Brutto # vBrutto;
  Erx # RekReplace(280,_RecUnlock,'MAN');
  RETURN Erx;
end;




//========================================================================