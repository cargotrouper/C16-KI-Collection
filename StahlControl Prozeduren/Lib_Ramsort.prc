@A+
//==== Business-Control ===================================================
//
//  Prozedur    Lib_Ramsort
//                      OHNE E_R_G
//  Info
//        CteTree
//
//  05.02.2003  AI  Erstellung der Prozedur
//  03.08.2010  PW  Überarbeitung
//  10.11.2010  MS  ItemAdd aKey auf 250 Zeichen erweitert
//
//  Subprozeduren
//    sub ItemAdd ( aCteList : int; aKey : alpha; aFile : int; aId : int ) : logic;
//    sub ItemFirst ( aCteList : int ) : int;
//    sub ItemLast ( aCteList : int ) : int;
//    sub ItemPrev ( aCteList : int; aCteItem : int ) : int;
//    sub ItemNext ( aCteList : int; aCteItem : int ) : int;
//    sub KillList ( aCteList : int );
//    sub Add ( aCteList : handle; aName : alpha; aId : int; opt aCustom : alpha ) : handle;
//    sub GetByIndex ( aCteList : handle; aIndex : int; opt aNodeFlags : int ) : handle;
//=========================================================================
@I:Def_Global


//=========================================================================
// ItemAdd
//        Fügt Datensatz-Item zur Liste hinzu
//=========================================================================
sub ItemAdd (aCteList : int; aKey : alpha(250); aFile : int; aId : int) : logic;
local begin
  vItem : handle;
end
begin
  vItem # CteOpen( _cteItem );
  if ( vItem = 0 ) then
    RETURN false;

  vItem->spName   # aKey + CnvAI( vItem, _fmtNumHex | _fmtNumLeadZero, 0, 8 );
  vItem->spCustom # CnvAI( aFile );
  vItem->spId     # aId;

  // Einsortieren
  if ( aCteList->CteInsert( vItem ) ) then
    RETURN true;
  else
    RETURN false;
end;


//=========================================================================
// ItemFirst
//        Gibt erstes Element der Liste zurück
//=========================================================================
sub ItemFirst ( aCteList : int ) : int;
begin
  RETURN aCteList->CteRead( _cteFirst );
end;


//=========================================================================
// ItemLast
//        Gibt letztes Element der Liste zurück
//=========================================================================
sub ItemLast ( aCteList : int ) : int;
begin
  RETURN aCteList->CteRead( _cteLast );
end;


//=========================================================================
// ItemPrev
//        Gibt vorheriges Element der Liste zurück
//=========================================================================
sub ItemPrev ( aCteList : int; aCteItem : int ) : int;
begin
  RETURN aCteList->CteRead( _ctePrev, aCteItem );
end;


//=========================================================================
// ItemNext
//        Gibt nächstes Element der Liste zurück
//=========================================================================
sub ItemNext ( aCteList : int; aCteItem : int ) : int;
begin
  RETURN aCteList->CteRead( _cteNext, aCteItem );
end;


//=========================================================================
// KillList
//        Entfernt die Liste und gibt den Speicher frei
//=========================================================================
sub KillList ( aCteList : int );
begin
  if (aCTEList=0) then RETURN;
  aCteList->CteClear( true );
  aCteList->CteClose();
end;


//=========================================================================
// Add
//        Fügt benutzerdefiniertes Item zur Liste hinzu
//=========================================================================
sub Add ( aCteList : handle; aName : alpha; aId : int; opt aCustom : alpha ) : handle;
local begin
  vItem : handle;
end
begin
  vItem # CteOpen( _cteItem );
  if ( vItem = 0 ) then
    RETURN 0;

  vItem->spName   # aName;
  vItem->spId     # aId;
  vItem->spCustom # aCustom;

  // Einsortieren
  if ( aCteList->CteInsert( vItem ) ) then
    RETURN vItem;
  else
    RETURN 0;
end;


//=========================================================================
// GetByIndex
//        Gibt das Element an der angegebenen Position zurück
//=========================================================================
sub GetByIndex ( aCteList : handle; aIndex : int; opt aNodeFlags : int ) : handle;
local begin
  vItem : handle;
end
begin
  if ( aIndex <= 0 ) then
    RETURN aIndex;

  FOR  vItem # aCteList->CteRead( aNodeFlags | _cteFirst );
  LOOP vItem # aCteList->CteRead( aNodeFlags | _cteNext, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    aIndex # aIndex - 1;
    if ( aIndex <= 0 ) then
      RETURN vItem;
  END;

  RETURN 0;
end;

//=========================================================================
//=========================================================================