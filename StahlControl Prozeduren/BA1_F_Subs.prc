@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_F_Subs
//
//  Info        OHNE E_R_G
//
//
//  16.07.2020  AH  Erstellung der Prozedur
//  12.08.2020  AH  ImportFert
//  22.06.2021  AH  ERX
//  24.01.2022  AH  Fix "_WeiterDurchPosSub1"
//  08.02.2022  AH  "ImportFert" mit Para aNix701Aendern
//
//  Subprozeduren
//  SUB WeiterDurchPos(aBAG : int; aPos1 : int; aFert : int; aPos2 : int) : logic
//  SUB ImportFert(aBAG : int; aPos1 : int; aPos2 : intM aFert2  : int; opt aNix701Aendern : logic) : logic
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
end;

//========================================================================
//  _WeiterDurchPosSub1
//
//========================================================================
sub _WeiterDurchPosSub1(
  aBAG  : int;
  aPos1 : int;        // Startpos
  aFert : int;
  aPos2 : int)        // nächste Pos.
  : alpha             // Errorcode
local begin
  Erx       : int;
  vPosAlt   : int;
  vTxt      : int;
  v701      : int;
  v701b     : int;
  v702      : int;
  vI        : int;
  vErrCode  : alpha(200);
  vID       : int;
end;
begin

  BAG.F.Nummer    # aBAG;
  BAG.F.Position  # aPos1;
  BAG.F.Fertigung # aFert;
  ErX # Recread(703,1,0);
  if (erx>_rLocked) then RETURN 'BAFert nicht gefunden!';

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos2;
  Erx # Recread(702,1,0);
  if (erx>_rLocked) then RETURN 'BAPos nicht gefunden!';
  
  // ZIEL-Pos prüfen -------------------------------------------------------
  if (BAG.P.Typ.VSBYN) then RETURN 'VSB darf man nicht tunneln!';
  if ("BAG.P.Löschmarker"<>'') then RETURN 'Die Zielpos. ist bereits gelöscht!';
  if (BAG.P.ZielVerkaufYN) then RETURN 'Die Zielpos. ist ein Verkaufsfahren und kann nicht eingefügt werden!';

  vI # RecLinkInfo(703,702,4,_recCount);
  if ("BAG.P.Typ.1In-1OutYN") then begin        // z.B. Walzen/Fahren/Obf/Check/Umlag
    if (vI=0) then RETURN 'Die Zielpos. hat keine Fertigungen!';
  end
  else if ("BAG.P.Typ.1In-yOutYN") then begin   // z.B. Spalten/QTeil
    if (vI=0) then RETURN 'Die Zielpos. hat keine Fertigungen!';
    if (vI>1) then RETURN 'Die Zielpos. hat mehrere Fertigungen/Ausbringungen!';
  end
  else if ("BAG.P.Typ.xIn-yOutYN") then begin   // z.B. Divers/Abcoil/Ablängen/ArtPrd/MatPrd/Splitten/Pack/Tafeln/Sägen/Split
    if (vI=0) then RETURN 'Die Zielpos. hat keine Fertigungen!';
  end
  else RETURN 'Unbekannter Ziel-Aktionstyp!';

  
  TRANSON;
  
  // Outputs der Fertigung Pos1 loopen...
  FOR Erx # RecLink(701,703,4,_recFirst)
  LOOP Erx # RecLink(701,703,4,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
      TRANSBRK;
      RETURN 'Das klappt nur bei Weiterbearbeitungen!';
    end;
    if (vPosAlt=0) then vPosAlt # BAG.IO.NachPosition;
    if (vPosAlt!=BAG.IO.NachPosition) then begin
      TRANSBRK;
      RETURN 'Die Ausbringungen haben unterschiedliche Weiterbearbeitungs-Pos.!';
    end;
    if (vTxt=0) then vTxt # Textopen(20);

    Erx # RecRead(701,1,_recLock);
    if (Erx=_rOK) then begin
      BAG.IO.NachPosition # aPos2;
      Erx # RekReplace(701);
    end;
//debug('Oben KEY701 -> '+aint(aPos2));
//debugx('COUNT701');
    // Update als "neuer INPUT"
    if (erx<>_rOK) or (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TextClose(vTxt);
      TRANSBRK;
      RETURN 'Output nicht updatebar!';
    end;
//debugx('nachher KEY701 :'+aint(BAG.IO.NachPosition)+'/'+aint(BAG.IO.NachFertigung)+'/'+aint(BAG.IO.NachID));

    v701 # RekSave(701);
    v702 # RekSave(702);
//debugx('COUNT701');
    Erx # RecLink(702,701,4,_recFirst);   // Nach Pos/Zwischenpos holen
//debugx('KEY702 ->Outputs');

    // Outpupts der ZWISCHENPOS loopen
//debugx('KEY702');
    FOR Erx # RecLink(701,702,3,_recFirst)
    LOOP Erx # RecLink(701,702,3,_recNext)
    WHILE (erx<=_rLocked) do begin
//debugx('KEY701');
      if (TextSearch(vTxt, 1,1, 0, 'IO'+aint(BAG.IO.Nummer)+'|')>0) then CYCLE;
      // nur NEUE Outputs
      TextAddLine(vTxt, 'IO'+aint(BAG.IO.Nummer)+'||');
//debug('Unten KEY701 -> '+aint(vPosAlt));
//CYCLE;
      RecRead(701,1,_RecLock);
      BAG.IO.NachBAG      # BAG.Nummer;
      BAG.IO.NachPosition # vPosAlt;
      RekReplace(701);
//debugx('mod KEY701 Von/nach '+aint(BAG.IO.VonID)+'/'+aint(BAG.IO.NachID));
      if (vID=0) then vID # BAG.IO.ID;
      v701b # RekSave(701);
      if (BAG.IO.NachID<>0) then begin
        BAG.IO.ID # BAG.IO.NachID;
        Erx # RecRead(701,1,_RecLock);
        if (erx<=_rLocked) then begin
          BAG.IO.VonID # v701b->BAG.IO.ID;
          RekReplace(701);
        end;
      end;

      RekRestore(v701b);
    END;
    
    // 24.01.2022 AH: NachPos 3 holen und dort ggf. die VonID anpassen
    Erx # RecLink(702,701,4,_recFirst);
    if (erx<=_rLocked) then begin
      Erx # RecLink(701,702,3,_recFirst);
      if (erx<=_rLocked) and (BAG.IO.vonID<>0) then begin
        RecRead(701,1,_recLock);
        BAG.IO.VonID # vID;
        RekReplace(701);
//debugx('mod KEY701 Von/nach '+aint(BAG.IO.VonID)+'/'+aint(BAG.IO.NachID));
      end;
    end;

    // Update der Pos.
    if (BA1_F_Data:UpdateOutput(702,n)=false) then begin
      TextClose(vTxt);
      TRANSBRK;
      RekRestore(v701);
      RekRestore(v702);
      RETURN 'Output nicht updatebar!!';
    end;

    RekRestore(v701);
    RekRestore(v702);
  END;  // FertOutput

  TRANSOFF;

  TextClose(vTxt);

  BA1_P_Data:UpdateSort();

  RETURN '';
end;


//========================================================================
//  WeiterDurchPos
//      an aktueller Fertigung eine ANDERE Pos anhängen und weiter mit vorhandener Kette
//========================================================================
sub WeiterDurchPos(
  aBAG  : int;
  aPos1 : int;        // Startpos
  aFert : int;
  aPos2 : int)        // nächste Pos.
  : logic
local begin
  Erx       : int;
  v701Ur    : int;
  v702Ur    : int;
  v703Ur    : int;
  vErrCode  : alpha(200);
end;
begin
//lib_debug:STartBluemode();

  BAG.Nummer      # aBAG;
  Erx # RecRead(700,1,0);
  if (erx>_rLocked) then begin
    Msg(99,'BA nicht gefunden!',0,0,0);
    RETURN false;
  end;

  v701Ur # RekSave(701);
  v702Ur # RekSave(702);
  v703Ur # RekSave(703);

  vErrCode # _WeiterDurchPosSub1(aBAG, aPos1, aFert, aPos2);
  
  RekRestore(v701Ur);
  RekRestore(v702Ur);
  RekRestore(v703Ur);
  if (vErrCode<>'') then
    Msg(99,vErrCode,0,0,0);
  
  RETURN (vErrCode='');
end;


//========================================================================
//  ImportFert
//      andere Fertigung in Position holen
//========================================================================
sub ImportFert(
  aBAG    : int;
  aPos1   : int;  // ZIEL
  aPos2   : int;  // VON
  aFert2  : int;
  opt aNix701Aendern : logic) : logic
local begin
  Erx     : int;
  v701    : int;
  v702    : int;
  vTxt    : int;
  vFert   : int;
  v701Ur  : int;
  v702Ur  : int;
  v703Ur  : int;
  vInput  : int;
end;
begin
//lib_debug:STartBluemode();

  BAG.Nummer      # aBAG;
  Erx # RecRead(700,1,0);
  if (Erx>_rLocked) then begin
    Msg(99,'BA nicht gefunden!',0,0,0);
    RETURN false;
  end;

  v701Ur # RekSave(701);
  v702Ur # RekSave(702);
  v703Ur # RekSave(703);

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos2;    // VON
  Erx # Recread(702,1,0);
  if (erx>_rLocked) then begin
    RekRestore(v701Ur);
    RekRestore(v702Ur);
    RekRestore(v703Ur);
    Msg(99,'BAPos2 nicht gefunden!',0,0,0);
    RETURN false;
  end;
  v702 # RekSave(702);

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos1;    // ZIEL laden
  Erx # Recread(702,1,0);
  if (erx>_rLocked) then begin
    RecBufDestroy(v702);
    RekRestore(v701Ur);
    RekRestore(v702Ur);
    RekRestore(v703Ur);
    Msg(99,'BAPos1 nicht gefunden!',0,0,0);
    RETURN false;
  end;
  if (BAG.P.Aktion<>v702->BAG.P.Aktion) then begin
    RecBufDestroy(v702);
    RekRestore(v701Ur);
    RekRestore(v702Ur);
    RekRestore(v703Ur);
    Msg(99,'Unterschiedliche Arbeitsgänge!',0,0,0);
    RETURN false;
  end;
  // Input "suchen"
  Erx # RecLink(701,702,2, _recFirst);
  if (erx<=_rLocked) then vInput # BAG.Io.ID;

  Erx # RecLink(703,702,4,_recLast);  // letzte Ziel-Fertigung
  if (erx<=_rLocked) then vFert # BAG.F.Fertigung + 1
  else vFert # 1;

  BAG.F.Nummer    # aBAG;
  BAG.F.Position  # aPos2;
  BAG.F.Fertigung # aFert2;   // VON laden
  Erx # Recread(703,1,0);
  if (erx>_rLocked) then begin
    RecBufDestroy(v702);
    RekRestore(v701Ur);
    RekRestore(v702Ur);
    RekRestore(v703Ur);
    Msg(99,'BAFert nicht gefunden!',0,0,0);
    RETURN false;
  end;

  TRANSON;
  
  // Outputs aus der Fertigung umbiegen...
  FOR Erx # RecLink(701,703,4,_recFirst)
  LOOP Erx # RecLink(701,703,4,_recFirst)
  WHILE (erx<=_rLocked) do begin
    RecRead(701,1,_RecLock);
    BAG.IO.VonPosition  # aPos1;
    BAG.IO.VonFertigung # vFert;
//debugx('aus '+aint(BAG.IO.VonID)+' wird '+aint(vInput));
    if (aNix701Aendern=false) then
      BAG.IO.VonID # vInput;    // 22.06.2021
    RekReplace(701);
  END;
  RecRead(703,1,_recLock);
  BAG.F.Position  # aPos1;
  BAG.F.Fertigung # vFert;
  RekReplace(703);

  RecBufDestroy(v702);
    
  TRANSOFF;

  BA1_P_Data:UpdateSort();
    
  RekRestore(v701Ur);
  RekRestore(v702Ur);
  RekRestore(v703Ur);

  RETURN true;
end;



//========================================================================