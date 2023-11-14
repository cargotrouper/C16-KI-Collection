@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Rso_PersId
//                      OHNE E_R_G
//  Info
//    Druckt eine Personal ID
//
//
//  30.11.2009  PW  Erstellung
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName ( var aSprache : alpha; var aAdr : int; ) : alpha;
//    sub SeitenKopf ( aSeite : int );
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================
@I:Def_Global

//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName ( var aSprache : alpha; var aAdr : int; ) : alpha;
begin
  aSprache # '';
  aAdr     # 0;
  RETURN CnvAI( gUserId, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 ); // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf ( aSeite : int );
begin
end;


//========================================================================
//  MAIN
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx   : int;
  vPrt  : handle;
end;
begin
  RecRead( 912, 1, 0 ); // Formulardaten lesen

  if (Lib_Print:FrmJobOpen( y, 0, 0, n, n, n, _prtDocDinA4, 'FALSE' ) < 0) then begin
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  FOR  Erx # RecRead( 160, 1, _recFirst );
  LOOP Erx # RecRead( 160, 1, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    if ( Rso.PersonalID = 0 ) then
      CYCLE;

    // Etikett 1
    Gv.Alpha.01 # 'Code39N' + StrCnv( Rso.Personal.Code, _strUpper );
    Gv.Alpha.02 # Rso.Bezeichnung1;
    Gv.Alpha.03 # '';
    Gv.Alpha.04 # '';
    Gv.Alpha.05 # '';
    Gv.Alpha.06 # '';

    // Etikett 2
    if ( RecRead( 160, 1, _recNext ) <= _rLocked ) then begin
      Gv.Alpha.03 # 'Code39N' + StrCnv( Rso.Personal.Code, _strUpper );
      Gv.Alpha.04 # Rso.Bezeichnung1;
    end;

    // Etikett 3
    if ( RecRead( 160, 1, _recNext ) <= _rLocked ) then begin
      Gv.Alpha.05 # 'Code39N' + StrCnv( Rso.Personal.Code, _strUpper );
      Gv.Alpha.06 # Rso.Bezeichnung1;
    end;

    // Etikettenformular
    vPrt # PrtFormOpen( _prtTypePrintForm, 'FRM.STD.Rso.PersId' );
    Lib_Print:LfPrint( vPrt );
  END;

  //Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

end;

//========================================================================