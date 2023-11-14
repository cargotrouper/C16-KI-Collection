@A+
//==== Business-Control ===================================================
//
//  Prozedur    L_Usr_800502
//
//  Info
//        Liste: Vorgaben / Rechte
//
//  11.07.2019  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    sub GetUserGroups(aUsername : alpha) : alpha
//    sub GetUserData(aUsername : alpha; aFeldname : alpha) : alpha
//    sub GetUserSfx(aUsername : alpha) : alpha
//    sub GetUserLfm(aUsername : alpha) : alpha
//    sub Element ( aName : alpha; aPrint : logic );
//    sub SeitenKopf ( aSeite : int );
//    sub SeitenFuss ( aSeite : int );
//    sub StartList ( aSort : int; aSortName : alpha );

//=========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Rights


declare StartList ( aSort : int; aSortName : alpha );

local begin
  lf_Empty  : handle;
  lf_Header : handle;
  lf_Line   : handle;
  
  lf_GrpHeader : handle;
  lf_LineGrpUser  : handle;
  lf_LineUserData : handle;
  
  lf_LineRgt     : handle;
  lf_LineSfx     : handle;
  lf_LineLfm     : handle;
    
  gListHeaders : int;
  gLineItems   : int;
  gListUserRights : int;
  
  vUsrR     : alpha( cMaxRights );
  vGrpR     : alpha( cMaxRights );
  
  v910 : int;
    
end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN
begin
  StartList( 0, '' );
end;


//=========================================================================
// sub GetUserGroups(aUsername : alpha) : alpha
//   Ermittelt alle Benutzergruppenzugehörigkeiten
//=========================================================================
sub GetUserGroups(aUsername : alpha) : alpha
local begin
  vUsrGroups : alpha(4000);
end;
begin
  Usr.Username # aUSername;
  RecRead(800,1,0);
  
  FOR   Erg # RecLink(802,800,1,_RecFirst)
  LOOP  Erg # RecLink(802,800,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    // Gruppe noch vorhanden?
    Grp.Name # "Usr.U<>G.Gruppe";
    if (RecRead(801,1,_RecTest) = _rOK) then
      Lib_Strings:Append(var vUsrGroups,"Usr.U<>G.Gruppe",',');
  END;

  RETURN StrCut(vUsrGroups,1,250);
end;



//=========================================================================
// sub GetUserData(aUsername : alpha) : alpha
//   Gibt ein Datenfeld aus der Benutzertabelle zurüc
//=========================================================================
sub GetUserData(aUsername : alpha; aFeldname : alpha) : alpha
local begin
  vRet : alpha(4000);
end;
begin
  Usr.Username # aUSername;
  RecRead(800,1,0);
  
  vRet # FldAlphaByName(aFeldname);
  RETURN StrCut(vRet,1,250);
end;




//=========================================================================
// sub GetUserSfx(aUsername : alpha) : alpha
//   Prüft alle Sonderfunkltionsberechtigungen für einen User
//=========================================================================
sub GetUserSfx(aUsername : alpha) : alpha
local begin
  vRet : alpha;
end
begin

  FOR   Erg # RecLink(924,922,1,_RecFirst)
  LOOP  Erg # RecLink(924,922,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    if (SFX.Usr.Username = aUsername) then begin
      vRet # 'U';
      BREAK;
    end;
  end;
 
  RETURN vRet;
end;


//=========================================================================
// sub GetUserLfm(aUsername : alpha) : alpha
//   Prüft alle Listenberechtigungen für einen User
//=========================================================================
sub GetUserLfm(aUsername : alpha) : alpha
local begin
  vRet : alpha;
  v911 : int;
end
begin

  v911 # RecBufCreate(911);

  FOR   Erg # RecLink(v911 ,v910,1,_RecFirst)
  LOOP  Erg # RecLink(v911 ,v910,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    if (v911->Lfm.Usr.Username = aUsername) then begin
      vRet # 'U';
      BREAK;
    end;
  end;
  
  RecBufDestroy(v911);
  
  RETURN vRet;
end;

//=========================================================================
// Element
//        Seitenkopf der Liste
//=========================================================================
sub Element ( aName : alpha; aPrint : logic );
local begin
  vHeaderItems : int;
  vHeaderItem  : int;
  i : int;
  vVal    : alpha(250);
  vRgtItem  : int;
end
begin

  case aName of
   
    'empty' : begin
     if (aPrint) then RETURN;
    end;
  
    'header' : begin
      if ( aPrint ) then
        RETURN;

      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      
      List_Spacing[ 1] # 0.0;       // Bezeichnung
      FOR   i # 1;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        List_Spacing[ i] # 25.0;
      Lib_List2:ConvertWidthsToSpacings( i ); // Spaltenbreiten konvertieren
                 
      LF_Format( _LF_Underline | _LF_Bold );
      LF_Set( 1, 'Bezeichnung', y, 0 );
                
      i # 2;
      FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
      LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
      WHILE vHeaderItem <> 0 DO BEGIN
        LF_Set( i, vHeaderItem->spCustom + ' ' +vHeaderItem->spName, n, 0 );
        inc(i);
      END;
     
    end;
    

    'grpheader' : begin
      if ( aPrint ) then begin

        LF_Text( 1, GV.Alpha.01);
        i # 2;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          LF_Text( i, '');
          inc(i);
        END;
                
        RETURN;
      end;
                 
      LF_Format( _LF_Underline);
      
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
      
    end;
  
     

    'line' : begin
      if ( aPrint ) then begin

        vVal # 'TEST';

        LF_Text( 1, GV.Alpha.01);
        i # 2;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          LF_Text( i, vVal);
          inc(i);
        END;

                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
      
    end;
  
  
    'lineGrpUser' : begin
      if ( aPrint ) then begin

        vVal # '';

        LF_Text( 1, GV.Alpha.01);
        i # 1;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          inc(i);
          if (vHeaderItem->spCustom <> 'USR') then begin
            LF_Text( i, '');
            CYCLE;
          end;
          
          // User lesen und Gruppen anhängen
          vVal # GetUserGroups(vHeaderItem->spName);
          LF_Text( i, vVal);
        END;

                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
    end;
    
    'lineUserData' : begin
      if ( aPrint ) then begin

        vVal # '';

        LF_Text( 1, GV.Alpha.01);
        i # 1;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          inc(i);
          if (vHeaderItem->spCustom <> 'USR') then begin
            LF_Text( i, '');
            CYCLE;
          end;
          
          // User lesen und Gruppen anhängen
          vVal # GetUserData(vHeaderItem->spName,GV.Alpha.02);
          LF_Text( i, vVal);
        END;
                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
    end;
 
   
   'lineRgt' : begin
      if ( aPrint ) then begin

        vVal # '';

        LF_Text( 1, GV.Alpha.01);
        i # 1;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          inc(i);
          
          // Benutzer ist gelesen
          vVal # '';
          vRgtItem  # gListUserRights->CteRead(_RecFirst | _CteSearch,0,vHeaderItem->spName);
  
          vUsrR # vRgtItem->spCustom;
          vGrpR # vRgtItem->spValueAlpha;

          
          if ( StrCut( vUsrR, Gv.Int.01, 1 ) = '+' ) then
            vVal # 'U';
                    
          if (StrCut ( vGrpR, Gv.Int.01, 1 ) = '+' ) then
            vVal # 'G';


          if ( StrCut( vUsrR, Gv.Int.01, 1 ) = '-' ) then
            vVal # 'X';
          
          LF_Text( i, vVal);
        END;

                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
    end;
   
  
   'lineSFX' : begin
      if ( aPrint ) then begin

        vVal # '';

        LF_Text( 1, GV.Alpha.01);
        i # 1;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          inc(i);
          if (vHeaderItem->spCustom <> 'USR') then begin
            LF_Text( i, '');
            CYCLE;
          end;
          
          // User lesen prüfen ob Recht vorhanden
          vVal # GetUserSfx(vHeaderItem->spName);
          LF_Text( i, vVal);
        END;
                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
    end;
    

   'lineLfm' : begin
      if (aPrint) then begin

        vVal # '';

        LF_Text( 1, GV.Alpha.01);
        i # 1;
        FOR   vHeaderItem # gListHeaders->CteRead(_RecFirst);
        LOOP  vHeaderItem # gListHeaders->CteRead(_RecNext,vHeaderItem);
        WHILE vHeaderItem <> 0 DO BEGIN
          inc(i);
          if (vHeaderItem->spCustom <> 'USR') then begin
            LF_Text( i, '');
            CYCLE;
          end;
          
          // User lesen prüfen ob Recht vorhanden
          vVal # GetUserLfm(vHeaderItem->spName);
          LF_Text( i, vVal);
        END;
                
        RETURN;
      end;
                 
      LF_Set( 1, '#', n, 0 );
      vHeaderItems # gListHeaders->CteInfo(_CteCount);
      FOR   i # 2;
      LOOP  inc(i)
      WHILE i <= vHEaderItems DO
        LF_Set( i, '#', n, 0 );
    end;

  end;
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf der Liste
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin
  WriteTitel();
  Gv.Alpha.01 # 'Legende: GRP = Gruppe    USR = Benutzer   G = Recht aus Gruppe   U = Recht aus Benutzer    X = Recht entzogen';
  LF_Print( lf_GrpHeader );
  LF_Print( lf_Empty );
  
  LF_Print( lf_Empty );
  LF_Print( lf_Header );
end;


//=========================================================================
// SeitenFuss
//        Seitenfuß der Liste
//=========================================================================
sub SeitenFuss ( aSeite : int );
begin
end;


//=========================================================================
// StartList
//        Listenstart
//=========================================================================
sub StartList ( aSort : int; aSortName : alpha );
local begin
  vTree  : handle;
  vItem  : handle;
  vText  : handle;
  vLines : int;
  vLine  : int;
  vA     : alpha(250);
  vX     : int;
  
  vHeaderItem : int;
  
  vRgt : alpha(4000);
  vRgtItem  : int;
  
  vProgress : int;
  vMax      :  int;
end;
begin
  // Rechtepuffer aufbauen
  vTree  # CteOpen( _cteTreeCI );
  vText  # TextOpen( 3 );
  vText->TextRead( 'Def_Rights', _textProc );
  vLines # vText->TextInfo( _textLines );

  vMax # vLines;
  vProgress # Lib_Progress:Init('Ermittle Rechteliste (1/7)',vMax,true);

  FOR  vLine # 0;
  LOOP vLine # vLine + 1;
  WHILE ( vLine < vLines ) DO BEGIN
    vProgress->Lib_Progress:Step();
    
    vA # vText->TextLineRead( vLine, 0 );
    if ( StrFind( StrCnv( vA, _strUpper ), 'RGT_', 0 ) != 0 ) then begin
      vX # StrFind( vA, ':', 0 );
      vX # CnvIA( StrCut( vA, vX + 1, StrFind( vA, '//', 0 ) - vX ) );
      vA # StrCut( vA, StrFind( vA, '//', 0 ) + 3, StrLen( vA ) );
      Sort_ItemAdd( vTree, vA + '|', 999, vX );
    end;
  END;
  vText->TextClose();
  
 
  gListUserRights # CteOpen(_CteList);
  gListHeaders  # CteOpen(_CteList);

  // -------------------------------------------------------------------
  // Gruppenstrukturen aufbauen
  // -------------------------------------------------------------------
  vMax # RecInfo(801,_RecCount);
  vProgress->Lib_Progress:Reset('Ermittle Gruppenstrukturen (2/7)',vMax);
  FOR   Erg # RecRead(801,1,_RecFirst)
  LOOP  Erg # RecRead(801,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    vProgress->Lib_Progress:Step();
    
    vHeaderItem # CteOpen(_CteNode);
    vHeaderItem->spName   #  Usr.Grp.Gruppenname;
    vHeaderItem->spID     #  RecInfo(801,_RecID);
    vHeaderItem->spCustom #  'GRP';
    gListHeaders->CteInsert(vHeaderItem);
    
    // Rechte für Gruppe ermitteln
    vRgt  # Usr.Grp.Rights1 + Usr.Grp.Rights2 + Usr.Grp.Rights3 + Usr.Grp.Rights4;
    vRgtItem  # CteOpen(_CteNode);
    vRgtItem->spName # vHeaderItem->spName;
    vRgtItem->spID     #  RecInfo(801,_RecID);
    vRgtItem->spCustom #  'GRP';
    vRgtItem->spValueAlpha #  vRgt;
    gListUserRights->CteInsert(vRgtItem);
  END;
  

  // -------------------------------------------------------------------
  // Userstrukturen aufbauen
  // -------------------------------------------------------------------
  vMax # RecInfo(801,_RecCount);
  vProgress->Lib_Progress:Reset('Ermittle Benutzerstrukturen (3/7)',vMax);
  FOR   Erg # RecRead(800,1,_RecFirst)
  LOOP  Erg # RecRead(800,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    vProgress->Lib_Progress:Step();
    
    vHeaderItem # CteOpen(_CteNode);
    vHeaderItem->spName   #  Usr.Username;
    vHeaderItem->spID     #  RecInfo(800,_RecID);
    vHeaderItem->spCustom #  'USR';
    gListHeaders->CteInsert(vHeaderItem);
    
    // Rechte für USer ermitteln
    vGrpR # '';
    vUsrR # Usr.Rights1 + Usr.Rights2 + Usr.Rights3 + Usr.Rights4;
    FOR  Erg # RecLink( 802, 800, 1, _recFirst );
    LOOP Erg # RecLink( 802, 800, 1, _recNext );
    WHILE ( Erg <= _rLocked ) DO BEGIN
      RecLink( 801, 802, 1, 0 );
      vGrpR # Usr_R_Main:AddRightString( vGrpR, Usr.Grp.Rights1 + Usr.Grp.Rights2 + Usr.Grp.Rights3 + Usr.Grp.Rights4,cMaxRights);
    END;
    
    WHILE StrLen( vUsrR ) < cMaxRights DO
      vUsrR # vUsrR + '.';
    WHILE StrLen( vGrpR ) < cMaxRights DO
      vGrpR # vGrpR + '.';

        
    vRgtItem  # CteOpen(_CteNode);
    vRgtItem->spName # vHeaderItem->spName;
    vRgtItem->spID     #  RecInfo(800,_RecID);
    vRgtItem->spCustom #  vUsrR;
    vRgtItem->spValueAlpha #  vGrpR;
    
    gListUserRights->CteInsert(vRgtItem);
  END;
 
 
  /* Druckelemente */
  lf_Empty       # LF_NewLine( 'empty' );
  lf_Header      # LF_NewLine( 'header' );
  lf_GrpHeader   # LF_NewLine( 'grpheader' );
  lf_Line        # LF_NewLine( 'line' );
  lf_LineGrpUser # LF_NewLine( 'lineGrpUser' );
  lf_LineUserData # LF_NewLine( 'lineUserData' );
  lf_LineRgt     # LF_NewLine( 'lineRgt' );
  lf_LineSFX     # LF_NewLine( 'lineSFX' );
  lf_LineLfm     # LF_NewLine( 'lineLfm' );
  
   
  /* Listenanzeige */
  gFrmMain->WinFocusSet();
  LF_Init( false );
  
  
  // -------------------------------------------------------------------
  // Gruppenuser ausgeben
  vProgress->Lib_Progress:Reset('Ausgabe Gruppenzugehörigkeiten (4/7)',0);
  Gv.Alpha.01 # 'Gruppenzugehörigkeiten';
  LF_Print( lf_LineGrpUser );
    
  Gv.Alpha.01 # 'Abteilung';
  Gv.Alpha.02 # 'Usr.Abteilung';
  LF_Print( lf_LineUserData);

  Gv.Alpha.01 # 'Funktion';
  Gv.Alpha.02 # 'Usr.Funktion';
  LF_Print( lf_LineUserData);
  
  LF_Print( lf_Empty );
  LF_Print( lf_Empty );
  
  // -------------------------------------------------------------------
  // Alle Programmrechte ausgeben
  Gv.Alpha.01 # 'Stahl Control Standardberechtigungen';
  LF_Print( lf_GrpHeader );
  
  vMax # CteInfo(vTree,_CteCount);
  vProgress->Lib_Progress:Reset('Ausgabe Programmrechte (5/7)',vMax);
  FOR  vItem # Sort_ItemFirst( vTree );
  LOOP vItem # Sort_ItemNext( vTree, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    vProgress->Lib_Progress:Step();
    
    Gv.Alpha.01 # StrCut( vItem->spName, 1, StrFind( vItem->spName, '|', 0 ) - 1 );
    Gv.Int.01   # vItem->spId;
    LF_Print( lf_LineRgt );
  END;

  // -------------------------------------------------------------------
  // Sonderfunktionen ausdrucken
  LF_Print( lf_Empty );
  LF_Print( lf_Empty );

  Gv.Alpha.01 # 'Sonderfunktionen';
  LF_Print( lf_GrpHeader );
  vMax # RecInfo(922,_RecCount);
  vProgress->Lib_Progress:Reset('Ausgabe Sonderfunktionen (6/7)',vMax);
  FOR   Erg # RecRead(922,1,_RecFirst);
  LOOP  Erg # RecRead(922,1,_RecNext);
  WHILE Erg = _rOK DO BEGIN
    vProgress->Lib_Progress:Step();
  
    if  (SFX.EinzelrechtYN = false) then
      CYCLE;
  
    Gv.Alpha.01  # '';
    Lib_Strings:Append(var GV.ALpha.01,SFX.Bereich,'/')
    Lib_Strings:Append(var GV.ALpha.01,SFX.Hauptmenuname,'/')
    Lib_Strings:Append(var GV.ALpha.01,SFX.Name,'/')
        
    LF_Print( lf_LineSfx );
  END
   
  // -------------------------------------------------------------------
  // Alle Reports mit Berechtigungen ausdrucken

  vMax # RecInfo(922,_RecCount);
  vProgress->Lib_Progress:Reset('Ausgabe Reports (7/7)',vMax);
  LF_Print( lf_Empty );
  LF_Print( lf_Empty );
  Gv.Alpha.01 # 'Reports mit Berechtigungen';
  LF_Print( lf_GrpHeader );
  
  v910 # RecBufCreate(910);
  FOR   Erg # RecRead(v910,1,_RecFirst);
  LOOP  Erg # RecRead(v910,1,_RecNext);
  WHILE Erg = _rOK DO BEGIN
    vProgress->Lib_Progress:Step();
  
    if  (v910->Lfm.InaktivYN = true) OR (v910->Lfm.EinzelrechtYN = false) then
      CYCLE;
  
    Gv.Alpha.01  # '';
    Lib_Strings:Append(var GV.ALpha.01,v910->Lfm.Bereich,'/');
    Lib_Strings:Append(var GV.ALpha.01,Aint(v910->Lfm.Nummer),'/');
    Lib_Strings:Append(var GV.ALpha.01,v910->Lfm.Name,'/');
        
    LF_Print( lf_LineLfm );
  END;

  vProgress->Lib_Progress:Term();
  
  /* Cleanup */
  gListHeaders->CteClose();
  gLineItems->CteClose();
  gListUserRights->CteClose();
  
  LF_Term();
  LF_FreeLine( lf_Empty );
  LF_FreeLine( lf_Header );
  LF_FreeLine( lf_Line );
  LF_FreeLine( lf_LineGrpUser );
  LF_FreeLine( lf_LineRgt);
  LF_FreeLine( lf_LineSfx);
  LF_FreeLine( lf_LineLfm);
  LF_FreeLine( lf_GrpHeader);
  LF_FreeLine( lf_LineUserData);
  Sort_KillList( vTree );
end;

//=========================================================================
//=========================================================================