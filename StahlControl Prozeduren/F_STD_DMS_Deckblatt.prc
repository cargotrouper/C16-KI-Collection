@A+
//==== Business-Control ===================================================
//
//  Prozedur    F_STD_DMS_Dmsblatt
//                OHNE E_R_G
//  Info
//        Formular: Deckblätter für markierte Datensätze, Dateiunabhängig
//
//  19.07.2012  ST  Erstellung
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
//    sub SeitenKopf ( aSeite : int );
//    sub PrintForm (aDatei : int; aAufXNummer : alpha; aTitelText : alpha;  opt aFilename : alpha(4096));
//
//    MAIN (opt aFilename : alpha(4096))
//=========================================================================
@I:Def_Global
@I:Def_PrintLine

define begin
  cPos0  :  10.0 // Standardeinzug links
  cPos0r : 180.0 // Standardeinzug rechts
  cPosT1 :  40.0
end;

local begin
  vTopMargin : float;
end;

//=========================================================================
// GetDokName
//        Bestimmt den Namen eines Dokuments
//=========================================================================
sub GetDokName ( var aSprache : alpha; var aAdresse : int ) : alpha;
begin
  aSprache # '';
  aAdresse # 0;

  RETURN CnvAI( Auf.Nummer, _fmtNumNoGroup | _fmtNumLeadZero, 0, 8 );
end;


//=========================================================================
// SeitenKopf
//        Seitenkopf des Formulars
//=========================================================================
sub SeitenKopf ( aSeite : int );
begin

end;


//=========================================================================
// PrintForm
//        Hauptprozedur
//=========================================================================
sub PrintForm (aDatei : int; aAufXNummer : alpha; aTitelText : alpha; aBarcodeKz : alpha; opt aFilename : alpha(4096));
local begin
  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vTree       : int;
  vSort       : alpha;
  vPrintLine  : int;
  vNotFirst   : logic;
  vText       : alpha;
  i           : int;
  vLastAufAuf : int;
  vAufNr      : int;

end;
begin

  if (aDatei = 0) then
    aDatei # 401;

  PL_Create( vPrintLine );
  if (Lib_Print:FrmJobOpen( y, 0, 0, false, false, false ) < 0) then begin
    if (vPrintline <> 0) then PL_Destroy(vPrintline);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  vTopMargin    # form_RandOben;
  form_RandOben # 56693.0;  // 10mm
  form_RandOben # 113386.0; // 20mm
  form_RandOben # 226772.0; // 40mm
  form_RandOben # 453544.0; // 80mm ??

  // SORTIEREN
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  FOR  vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile = aDatei) then begin
      RecRead(aDatei,0,_RecId,vMID);
      vAufNr  # FldIntByName(aAufXNummer);
      vSort # CnvAi(vAufNr, _FmtNumNoGroup | _FmtNumLeadZero,0,10);
      Sort_ItemAdd(vTree,vSort,aDatei,vMid);
    end;
  END;

  // Projekt als je eine Seite drucken
  FOR   vItem # Sort_ItemFirst(vTree);
  LOOP  vItem # Sort_ItemNext(vTree, vItem);
  WHILE (vItem != 0) DO BEGIN
    RecRead(aDatei,0,_RecId,vItem->spId);

    vAufNr  # FldIntByName(aAufXNummer);

    if (vLastAufAuf = vAufNr) then
      CYCLE;

    Lib_Print:Print_Seitenkopf();

    // Projekt gelesen, dann drucken
    if ( vNotFirst ) then
      Lib_Print:Print_FF();
    vNotFirst # true;

    pls_fontSize # 30;
    pls_fontAttr # _winFontAttrB;

    // Status
    PL_Print( 'DMS-Deckblatt', cPosT1 );
    PL_PrintLine;
    PL_Print( aTitelText + ' ' + Aint(vAufNr), cPosT1 );
    PL_PrintLine;

    PL_PrintLine;
    vText # 'Code39N' + aBarcodeKz + StrAdj(CnvAi(vAufNr,_FmtNumLeadZero | _FmtNumNoGroup, 0, 8),_StrAll);
    lib_PrintLine:BarCode_C39(vText,cPosT1,100.0,30.0);
    PL_PrintLine;

    vLastAufAuf # vAufNr;

  END;

  Sort_KillList(vTree);


  /* Druck beenden */
  Usr.Username # UserInfo( _userName, CnvIA( UserInfo( _userCurrent ) ) );
  RecRead( 800, 1, 0 );
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
  //Lib_Print:FrmJobClose( !"Frm.DirektdruckYN" );

  if ( vPrintLine != 0 ) then
    PL_Destroy( vPrintLine );

end;


//=========================================================================
// MAIN
//        Einstiegspunkt
//=========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  vItem         : int;
  vMFile        : int;
  vMID          : int;
  vMarkCnt      : int;
  vKeyFeld      : alpha;
  vBereichsname : alpha;
  vBarcodeKz    : alpha;
end
begin

  vMarkCnt  # 0;
  FOR vItem # gMarkList->CteRead(_CteFirst);
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile = gFile) then begin
      inc(vMarkCnt);
      break;
    end;
  END;


  case gFile of
    120 : begin
        vKeyFeld # 'Prj.Nummer';
        vBereichsname # 'Projekt';
        vBarcodeKz    # 'P';
      end;

    400 : begin
      vKeyFeld # 'Auf.Nummer';
      vBereichsname # 'Auftrag'
      vBarcodeKz    # 'AUF';
    end;
    401 : begin
        vKeyFeld # 'Auf.P.Nummer';
        vBereichsname # 'Auftrag'
        vBarcodeKz    # 'AUF';
      end;
    410 : begin
        vKeyFeld # 'Auf~Nummer';
        vBereichsname # 'Auftrag'
        vBarcodeKz    # 'AUF';
      end;
    411 : begin
        vKeyFeld # 'Auf~P.Nummer';
        vBereichsname # 'Auftrag'
        vBarcodeKz    # 'AUF';
      end;

    500 : begin
      vKeyFeld # 'Ein.Nummer';
      vBereichsname # 'Bestellung'
      vBarcodeKz    # 'EIN';
    end;
    501 : begin
      vKeyFeld # 'Ein.P.Nummer';
      vBereichsname # 'Bestellung'
      vBarcodeKz    # 'EIN';
    end;

    700 : begin
        vKeyFeld # 'BAG.Nummer';
        vBereichsname # 'Betriebsauftrag'
        vBarcodeKz    # 'BAG';
      end;

    otherwise begin

      todo('DMS Deckblatt für Datei ' + aint(gFile));
      RETURN;
    end;
  end;

  // ggf. aktuelles Projekt markieren
  if (vMarkCnt = 0) then
    Lib_Mark:MarkAdd(gFile);

  Printform(gFile, vKeyFeld, vBereichsname, vBarcodeKz, aFilename);

  Lib_Mark:Reset(gFile);
end;

//=========================================================================
//=========================================================================
