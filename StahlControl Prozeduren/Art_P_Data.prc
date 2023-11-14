@A+
//===== Business-Control =================================================
//
//  Prozedur    Art_P_Data
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  16.09.2013  AH  Bugfix: "SetzePreis" hat Adressnummer nicht eingetragen
//  02.12.2014  AH  Edit: "SetzePreis" mit Datum
//  08.05.2018  AH  Edit: "FindePreis"
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB Replace(aLock : int; aTyp : alpha) : int;
//    SUB INsert(aLock : int; aTyp : alpha) : int;
//    SUB SetzePreis(aName : alpha; aPreis : float; aAdr : int; optaPEH : int; optaMEH : alpha; opt aDat  : date;);
//    SUB LiesPreis(aName : alpha; aAdr : int) : logic;
//    SUB FindePreis(aTyp : alpha; aAdr : int; aMenge : float; aMEH : alpha; aWae : int; opt aRef : alpha) : logic;
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//  Replace
//
//========================================================================
SUB Replace(aLock : int; aTyp : alpha) : int;
local begin
  vBuf250 : int;
  vBuf254 : int;
  Erx     : int;
  Erx2    : int;
end;
begin
  vBuf254 # Reksave(254);
  RecRead(vBuf254,1,0);

  Erx # RekReplace(254,aLock,aTyp);

  if (vBuf254->Art.P.PReis<>Art.p.preis) and
    (erx=_rOK) and (Art.P.PreisTyp='EK') then begin

    vBuf250 # RecBufCreate(250);
    Erx2 # RecLink(vBuf250,254,2,_recFirsT);   // ARtikel holen
    if (erx2<=_rLocked) and (vBuf250->"Art.SLRefreshNötigYN"=n) and
      (vBuf254->Art.P.Preis<>Art.P.Preis) then begin
      RecRead(vBuf250,1,_recLock);
      vBuf250->"Art.SLRefreshNötigYN" # y;
      RekReplace(vBuf250,0,'AUTO');
    end;
    RecBufDestroy(vBuf250);
  end;

  RecBufDestroy(vBuf254);

  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Insert
//
//========================================================================
SUB Insert(aLock : int; aTyp : alpha) : int;
local begin
  vBuf250 : int;
  Erx     : int;
  Erx2    : int;
end;
begin
  Erx # RekInsert(254,aLock,aTyp);

  if (erx=_rOK) and (Art.P.PreisTyp='EK') then begin
    vBuf250 # RecBufCreate(250);
    Erx2 # RecLink(vBuf250,254,2,_recFirsT);   // ARtikel holen
    if (erx2<=_rLocked) and (vBuf250->"Art.SLRefreshNötigYN"=n) then begin
      RecRead(vBuf250,1,_recLock);
      vBuf250->"Art.SLRefreshNötigYN" # y;
      RekReplace(vBuf250,0,'AUTO');
    end;
    RecBufDestroy(vBuf250);
  end;

  Erg # Erx; // TODOERX
  RETURN Erx;
end;


//========================================================================
//  SetzePreis
//      setzt den Preis in HAUSWÄHRUNG in die Preisdatei
//========================================================================
sub SetzePreis(
  aName     : alpha;
  aPreis    : float;
  aAdr      : int;
  opt aPEH  : int;
  opt aMEH  : alpha;
  opt aDat  : date;
);
local begin
  v100      : int;
  Erx       : int;
end;
begin
//todo('setze:'+aName+' : '+cnvaf(aPreis));
  if (aName='¥-EK') then aName # 'Ø-EK';
  if (aName='¾-EK') then aName # 'Ø-EK';

  RecBufClear(254);
  Art.P.ArtikelNr     # Art.Nummer;
  Art.P.Preistyp      # aName;
  // gezielt eine Adresse oder keine
  if (aAdr>=0) then begin
    Art.P.Adressnr      # aAdr;
    Erx # RecRead(254,4,0);
  end
  else begin  // beliebige Adresse
    Erx # RecRead(254,5,0);
  end;
  if (Erx<=_rMultikey) then begin
    Erx # RecRead(254,1,_RecLock);
    Art.P.Preis     # aPreis;
    Art.P.PreisW1   # aPreis;
    if (aDat<>0.0.0) then Art.P.Datum.Von # aDat;
    Replace(_recUnlock,'AUTO');
  end
  else begin
    RecBufClear(254);
    Art.P.ArtikelNr     # Art.Nummer;
    Art.P.Preistyp      # aName;
    Art.P.ArtStichwort  # Art.Stichwort;
    "Art.P.Währung"     # 1;
    Art.P.Preis         # aPreis;
    Art.P.PreisW1       # aPreis;
    if (aPEH<>0) then
      Art.P.PEH         # aPEH
    else
      Art.P.PEH         # Art.PEH;
    if (aMEH<>'') then
      Art.P.MEH         # aMEH
    else
      Art.P.MEH           # Art.MEH;
    if (aAdr>0) then begin
      v100 # RecBufCreate(100);
      v100->Adr.Nummer # aAdr;
      RecRead(v100,1,0);
      Art.P.Adressnr      # aAdr;
      Art.P.AdrStichwort  # v100->Adr.Stichwort;
      RecBufDestroy(v100);
    end;
    if (aDat<>0.0.0) then Art.P.Datum.Von # aDat;

    Art.P.Nummer        # 0;
    REPEAT
      Art.P.Nummer # Art.P.Nummer + 1;
      Erx # Insert(0,'AUTO');
    UNTIL (Erx=_rOK) or (Art.P.Nummer=30000);
  end;

end;


//========================================================================
//  LiesPreis
//      liest den Preisdatensatz aus der Preisdatei
//========================================================================
sub LiesPreis(aName : alpha; aAdr : int) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(254);
  Art.P.ArtikelNr     # Art.Nummer;
  Art.P.Preistyp      # aName;
  if (aAdr>=0) then begin
    Art.P.Adressnr      # aAdr;
    Erx # RecRead(254,4,0);
    if (Erx<=_rMultiKey) then begin
      if (art.P.PEH=0) then Art.P.PEH # 1;
      RETURN true;
    end
    else begin
      RecBufClear(254);
      if (art.P.PEH=0) then Art.P.PEH # 1;
      RETURN false;
    end;
  end
  else begin    // beliebiger Lieferant...
    Erx # RecRead(254,5,0);
    if (Erx<=_rMultiKey) then begin
      if (art.P.PEH=0) then Art.P.PEH # 1;
      RETURN true;
    end
    else begin
      RecBufClear(254);
      if (art.P.PEH=0) then Art.P.PEH # 1;
      RETURN false;
    end;

  end;

end;


//========================================================================
// FindePreis
//
//========================================================================
sub FindePreis(
  aTyp      : alpha;
  aAdr      : int;
  aMenge    : float;
  aMEH      : alpha;
  aWae      : int;
  opt aRef  : alpha) : logic;
local begin
  vSelName  : alpha;
  vSel      : int;
  vFound    : logic;
  vQ        : alpha(4000);
  Erx       : int;
end;
begin
//debug('suchepreis:'+Art.Nummer+' '+aTyp+'_'+aMEH+'_'+cnvai(aAdr)+'_'+cnvai(awae)+'_'+cnvaf(aMenge));
//d  if (aTyp='Ø-EK') then aTyp # 'Ù-EK';
  if (aTyp='Ù-EK') then aTyp # 'Ø-EK';

/***
  Gv.Alpha.01 # aTyp;
  Gv.Alpha.02 # aMEH;
  Gv.int.01   # aAdr;
  Gv.int.02   # aWae;
  Gv.Num.01   # aMenge;
***/
  // ehemals Selektion 254 FindePreis
  vQ # '(Art.P.ArtikelNr = '''+Art.Nummer+''') AND ( Art.P.Datum.Bis = 0.0.0 OR Art.P.Datum.Bis >= ' + CnvAD( today, _fmtInternal ) + ' )';
  if ( aTyp != '' ) then begin
    if (StrLen(aTyp)<5) then
      Lib_Sel:QEnthaeltA( var vQ, 'Art.P.Preistyp', aTyp )
    else
      Lib_Sel:QAlpha( var vQ, 'Art.P.Preistyp', '=^', aTyp );
  end;
  if ( aAdr != 0 ) then
    vQ # vQ + ' AND ( Art.P.Adressnr = 0 OR Art.P.Adressnr = ' + AInt( aAdr ) + ' )';
  if ( aWae != 0 ) then
    Lib_Sel:QInt( var vQ, '"Art.P.Währung"', '=', aWae );
  if ( aMEH != '' ) then
    Lib_Sel:QAlpha( var vQ, 'Art.P.MEH', '=', aMEH );
//  if ( GV.Num.01 != 0.0 ) then
    Lib_Sel:QFloat( var vQ, 'Art.P.abMenge', '<=', aMenge );
  Lib_Sel:QDate( var vQ, 'Art.P.Datum.Von', '<=', today );
  if  (aRef<>'') then
    Lib_Sel:QAlpha(var vQ, 'Art.P.AdressArtNr', '=', aRef);


  // Selektion bauen, speichern und öffnen
  vSel # SelCreate(254, 0 ); //3             Art.P.Adressnr
  if (aAdr<>0) then
    vSel->SelAddSortFld(1, FldInfoByName('Art.P.Adressnr',_FldNumber));   // AdressNr falls allgemeiner und spezieller Preis existiert
  vSel->SelAddSortFld(1, FldInfoByName('Art.P.abMenge',_FldNumber));      // Menge
  vSel->SelAddSortFld(1, FldInfoByName('Art.P.Datum.Von',_FldNumber));    // Datum
  Erx # vSel->SelDefQuery( '', vQ );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
//  Winsleep(100);
  vSelName # Lib_Sel:SaveRun( var vSel, 0, y);

  Erx # RecRead(254,vSel,_RecLast);
  if (Erx<=_rLocked ) then vFound # y;
  // Selektion löschen
  SelClose(vSel);
  SelDelete(254,vSelName);
  vSel # 0;
  Art.P.Preis # Rnd(Art.P.Preis,2);
  Art.P.PreisW1 # Rnd(Art.P.PreisW1,2);
  if (Art.P.PEH=0) then Art.P.PEH # 1;

  // nichts gefunden?
  if (vFound=n) then begin
    RecBufClear(254);
    RETURN falsE;
  end;
//debug('found:'+cnvaf(art.p.Preis));
  RETURN true;

end;



//========================================================================
//=============================================================================