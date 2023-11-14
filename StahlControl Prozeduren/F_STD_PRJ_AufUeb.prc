@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_PRJ_AufUeb
//                OHNE E_R_G
//  Info        Druckt eine Aufgaben-Übersicht der Projekte
//
//
//  10.09.2008  MS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global
@I:Def_PrintLine
define begin
  cPos0   :  10.0   // Anschrift

  cPos1   :  12.0   // Start (0 Wert), Pos
  cPos2   :  20.0
  cPos3   :  180.0

  cPosKopf1 : 120.0
  cPosKopf2 : 155.0
  xcPosKopf3 : 35.0  // Feld Lieferanschrift
end;

local begin
  TextIntern  : alpha;
  TextExtern  : alpha;

  PrintIntern  : logic;
  PrintExtern  : logic;
end;

declare StartFormular(opt aFilename : alpha(4096));

//========================================================================
//  GetDokName
//
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(Prj.Nummer ,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vText : alphA(1000);
end;
begin

  RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if (aSeite=1) then begin
    form_FaxNummer  # Adr.A.Telefax;
    Form_EMA        # Adr.A.EMail;
  end;

  // SCRIPTLOGIK
//  if (Scr.B.Nummer<>0) then HoleEmpfaenger();


  // ERSTE SEITE *******************************
  if (aSeite=1) then begin

  end; // 1.Seite


  if (Form_Mode<>'FUSS') then begin
    /*
    pls_Inverted  # y;
    pls_FontSize  # 10;
    PL_Drawbox(cPos0-1.0,cPos3+1.0,_WinColblack, 5.0);
    PL_PrintLine;
    */

    pls_FontSize  # 14;
    PL_Print('Prj. ' + AInt(Prj.Nummer) + '         ' +  Prj.Stichwort ,cPos0);
    PL_PrintLine;

  end;



end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  Erx     : int;
  vTxtHdl : int;
end;
begin

    case (aName) of

      'PrjTxtIntern' : begin
        Lib_Print:Print_Text(TextIntern,1,cPos0,cPos3);
      end;

      'CheckTxt' : begin
        vTxtHdl # TextOpen(32);     // temp. Puffer erzeugen

        TextExtern # Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' );
        TextRead(vTxtHdl,TextExtern,0);
        Erx # TextInfo(vTxtHdl,_TextLines);
        if (Erx > 5) then
          PrintExtern # TRUE;

        TextIntern # Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' );
        TextRead(vTxtHdl,TextIntern,0);
        Erx # TextInfo(vTxtHdl,_TextLines);
        if (Erx > 5) then
          PrintIntern # TRUE;

        TextClose(vTxtHdl);
      end;


      'PrjTxtExtern' : begin
        Lib_Print:Print_Text(TextExtern,1,cPos0,cPos3);
      end;

      'LinieEinzelnt' : begin
        Lib_Print:Print_LinieEinzeln();
      end;

      'LinieDoppelt' : begin
        //PL_PrintLine;
        Lib_Print:Print_LinieDoppelt();
        //PL_PrintLine;
        //PL_PrintLine;
      end;


  end;
end;
//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
end;
begin

  RecBufClear(998);

  if (aFilename = '') then begin
    gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Prj.AufUeb',here+':StartFormular',y);
    Lib_GuiCom:RunChildWindow(gMDI);
  end else begin

    // alle WVs
    StartFormular(aFilename);
  end;


end;

//========================================================================
//  StartFormular
//
//========================================================================
sub StartFormular(opt aFilename : alpha(4096));
local begin
  Erx         : int;
  vSel        : int;
  vSelName    : alpha;

  vNummer     : int;        // Dokumentennummer
  vPL         : int;        // Printline

  vHdl        : int;        // Elementdescriptor

  vHeader     : int;
  vFooter     : int;

  vSum        : float;
  vTxtName    : alpha;

  vAufwand    : logic;

  vQ          : alpha(4000);
end;
begin

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Header und Footer EINMALIG vorher laden
  vHeader # 0;//PrtFormOpen(_PrtTypePrintForm,'FRM.PRJ.MitBild.Kopf');
  vFooter # 0;//PrtFormOpen(_PrtTypePrintForm,'');

  // Job Öffnen + Page srstellen
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,y,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(form_Dokname);

  // Adresse lesen
  RecLink(100,120,1,_RecFirst);

  // Seitenkopf drucken
  Lib_Print:Print_Seitenkopf();

// -------- Druck starten ----------------------------------------------------------------

  vQ # '';

  Lib_Sel:QInt(var vQ, 'Prj.P.Nummer', '=', Prj.Nummer);
  Lib_Sel:QAlpha(var vQ, 'Prj.P.Lösch.Grund' , '=' , '');

  if(Sel.Adr.von.Sachbear <> '') then
    Lib_Sel:QenthaeltA (var vQ, 'Prj.P.WiedervorlUser', Sel.Adr.von.Sachbear);

  // Selektion starten...
  vSel # SelCreate(122, 1 );
  Erx # vSel->SelDefQuery( '', vQ);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // Positionen drucken
  Erx # RecRead(122,vSel,_RecFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN

      Print('CheckTxt');

      pls_FontAttr  # _winfontattrb;
      //PL_PrintLine;
      //PL_PrintLine;
      if ( (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y) < PrtUnitLog(40.0 + (12.0 * 2.0),_PrtUnitMillimetres)) then
        Lib_Print:Print_FF()
      PL_Print(AInt(Prj.P.Position) + ') ' + Prj.P.Bezeichnung,cPos0);
      PL_PrintLine;
      //PL_PrintLine;
      pls_FontAttr  # _winfontattrn;


      if(PrintExtern <> FALSE) and (PrintIntern <> FALSE) then begin
        // Genug Platz für GESAMTEN MFG-Text? -> Sonst neue Seite!!!
        if ( (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y) < PrtUnitLog(40.0 + (12.0 * 2.0),_PrtUnitMillimetres)) then
          Lib_Print:Print_FF();
        Print('PrjTxtExtern');
        Print('LinieEinzelnt');
        Print('PrjTxtIntern');
      end else if (PrintExtern <> FALSE) and (PrintIntern = FALSE) then begin
        if ( (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y) < PrtUnitLog(40.0 + (12.0 * 2.0),_PrtUnitMillimetres)) then
          Lib_Print:Print_FF();
        Print('PrjTxtExtern');
      end else if (PrintExtern = FALSE) and (PrintIntern <> FALSE) then begin
        if ( (form_Page->ppBoundMax:y - form_Page->ppBoundAdd:y) < PrtUnitLog(40.0 + (12.0 * 2.0),_PrtUnitMillimetres)) then
          Lib_Print:Print_FF();
        Print('PrjTxtIntern');
      end;

      Print('LinieDoppelt');

      PrintIntern # FALSE;
      PrintExtern # FALSE;

      Erx # RecRead(122,vSel,_RecNext);
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(122, vSelName);


  form_Mode # 'FUSS';

  PL_PrintLine;

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschaut
  // Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;


//========================================================================