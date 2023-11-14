@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Art_250505
//                        OHNE E_R_G
//  Info        Lagerjournal drucken MARKIERT
//
//
//  09.03.2009  MS  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartFormular(opt aFilename : alpha(4096));
//
//    MAIN (opt aFilename : alpha(4096))
//
//========================================================================

@I:Def_Global
@I:Def_PrintLine

define begin
  /*

  cPos0     :  10.0
  cPos1     :  30.0
  cPos2     :  50.0
  cPos3     :  70.0
  cPos4     : 110.0
  cPos5     : 120.0
  cPos6     : 140.0
  cPos7     : 160.0

  */
  cPos0 :  0.0
  cPos1 :  cPos0 + 25.0
  cPos2 :  cPos1 + 15.0
  cPos3 :  cPos2 + 30.0
  cPos4 :  cPos3 + 15.0
  cPos5 :  cPos4 + 10.0
  cPos6 :  cPos5 + 10.0
  cPos7 :  cPos6 + 5.0
  cPos8 :  cPos7 + 25.0
  cPos9 :  cPos8 + 25.0

  cPosKopf1 :   0.0
  cPosKopf2 :  55.0
  cPosKopf3 : 140.0
end;

local begin
  gSeite   : int;
  gSumOut  : float;
  gSumIn   : float;
  gGesOut  : float;
  gGesIn   : float;
  gEK      : float;

  gTree    : int;
  gItem    : int;
  gSortKey : alpha;
end;

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
  RETURN '';      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vText : alpha(1000);
  vItem : int;
  vMFile,vMID   : int;
end;
begin

  //WriteTitel();
  gSeite # gSeite + 1;

  // ERSTE SEITE *******************************
  if (aSeite=1) then begin
    gItem # Sort_ItemFirst(gTree);
    if(gItem <> 0) then
      RecRead(CnvIA(gItem->spCustom),0,0,gItem->spID);    // Custom=Dateinr, ID=SatzID
  end; // 1.Seite

  pls_FontSize # 18;
  Pl_Print('Lagerjournal'  ,cPos0);
  pls_FontSize # 9;
  PL_Print('Datum: ' + cnvAD(today,_FmtInternal) + '   ' +'Seite: ' + cnvAI(gSeite,_FmtInternal),cPosKopf3);
  PL_PrintLine;
  PL_PrintLine;

  pls_FontAttr # _WinFontAttrBold;
  pls_FontSize # 12;
  PL_Print('Artikel: ' + Art.Nummer,cPosKopf1);
  PL_Print(cnvAD(Sel.von.Datum) + ' bis ' + cnvAD(Sel.bis.Datum),cPosKopf2);
  PL_PrintLine;
  pls_FontAttr # _WinFontAttrNormal;
  PL_Print(Art.Bezeichnung1,cPosKopf1);
  PL_PrintLine;
  PL_Print(Art.Bezeichnung2,cPosKopf1);
  PL_PrintLine;
  PL_Print(Art.Bezeichnung3,cPosKopf1);
  PL_PrintLine;


  pls_FontSize # 9;
  if (Form_Mode<>'FUSS') then begin
    PL_Print('Anlage Datum' ,cPos0);
    PL_Print('Zeit' ,cPos1);
    PL_Print('User' ,cPos2);
    PL_Print_R('Menge/' + Art.MEH,cPos3);
    PL_Print('Bemerkung' ,cPos4);
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(-10.0,210.0);
  end;

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  if(form_Mode = 'Journal') then begin
    PL_PrintLine;
    Lib_Print:Print_LinieEinzeln(-10.0,210.0);
    pls_FontSize # 10;
    PL_Print('weiter auf der nächsten Seite' , 73.5);
    PL_PrintLine;
  end;
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  vTxtHdl : int;
end;
begin

    case (aName) of
      'Journal' : begin
        PL_Print(cnvAD(Art.J.Anlage.Datum)                    ,cPos0);
        PL_Print(cnvAT(Art.J.Anlage.Zeit)                     ,cPos1);
        PL_Print(Art.J.Anlage.User                            ,cPos2);
        PL_Print_R(ANum(Art.J.Menge,2) + ' ' + Art.MEH   ,cPos3);
        PL_Print(Art.J.Bemerkung                              ,cPos4);
        PL_PrintLine;
        if(Art.J.Menge > 0.0) then begin
          gSumIn # gSumIn + Art.J.Menge;
          gGesIn # gGesIn + Art.J.Menge*Art.P.Preis/cnvFI(Art.P.PEH);
        end
        else begin
          gSumOut # gSumOut + Art.J.Menge;
          gGesOut # gGesOut + Art.J.Menge*Art.P.Preis/cnvFI(Art.P.PEH);
        end;

       end;

       'Summe' : begin
         PL_PrintLine;
         Lib_Print:Print_LinieEinzeln(-10.0,210.0);
         PL_Print('Ausgang:',cPos1);
         PL_Print_R(ANum(gSumOut,-1) + ' ' + Art.MEH, cPos3);
         PL_PrintLine;
         PL_Print('Eingang:',cPos1);
         PL_Print_R(ANum(gSumIn,-1) + ' ' + Art.MEH, cPos3);
         PL_PrintLine;
         PL_Print('Differenz:',cPos1);
         PL_Print_R(ANum(gSumIn + gSumOut,-1) + ' ' + Art.MEH, cPos3);
         PL_PrintLine;
         gSumIn  # 0.0;
         gSumOut # 0.0;
         gGesIn  # 0.0;
         gGesOut # 0.0;
       end;
  end;
end



//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
end;
begin
  F_STD_Art_250008:StartFormular(aFilename);
end;

//========================================================================
//  StartFormular
//
//========================================================================
sub StartFormular(opt aFilename : alpha(4096));
local begin
  Erx           : int;
  vSel          : int;
  vSelName      : alpha;
  vNummer       : int;        // Dokumentennummer
  vPL           : int;        // Printline
  vHdl          : int;        // Elementdescriptor
  vHeader       : int;
  vFooter       : int;
  vSum          : float;
  vTxt          : alpha;
  vFlag         : int;        // Datensatzlese option
  vItem         : int;
  vItemMark     : int;
  vKey          : int;
  vMFile,vMID   : int;
  vDat1, vDat2  : date;

  vSortKey      : alpha;
  vQ            : alpha(4000);
  vFirst        : logic;
end;
begin

  // universelle PrintLine generieren
  PL_Create(vPL);

  // Header und Footer EINMALIG vorher laden
  vHeader # 0;//PrtFormOpen(_PrtTypePrintForm,'FRM.PRJ.MitBild.Kopf');
  vFooter # 0;//PrtFormOpen(_PrtTypePrintForm,'');

  Sel.bis.Datum # today;
  if (Dlg_Standard:DatumVonBis('Bewegungszeitraum von '/*+Art.Nummer*/,var Sel.von.Datum, var Sel.bis.Datum,0.0.0,today)=false) then RETURN;

  // Job Öffnen + Page srstellen
  if (Lib_Print:FrmJobOpen(y,vHeader , vFooter,n,n,n) < 0) then begin
    if (vPL <> 0) then PL_Destroy(vPL);
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(Form_Dokname);

  gTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vTxt   # '0';
  vItemMark # gMarkList->CteRead(_CteFirst);
  // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
  WHILE (vItemMark > 0) do begin
    Lib_Mark:TokenMark(vItemMark,var vMFile,var vMID);
    if (vMFile = 250) then begin
      Erx # RecRead(250,0,_RecId,vMID); // Markierten Datensatz lesen

      // Gucken ob ein Datensatz in den Datumsbereich passt
      Erx # RecLink(253,250,5,_recFirst);
      WHILE (Erx <= _rLocked ) DO BEGIN
        if(Art.J.Anlage.Datum >= Sel.von.Datum) and (Art.J.Anlage.Datum <= Sel.bis.Datum) then begin
          vTxt # '>0';
          BREAK;
        end;
        Erx # RecLink(253,250,5,_recNext);
      END;

      if(vTxt = '0') then begin  // kein passender gefunden
        vItemMark  # gMarkList->CteRead(_CteNext,vItemMark);
        CYCLE;
      end;

      gSortKey # StrFmt(Art.Nummer,20,_StrBegin);

      Sort_ItemAdd(gTree,gSortKey,250,RecInfo(250,_RecId));
    end;
    vTxt   # '0';
    vItemMark  # gMarkList->CteRead(_CteNext,vItemMark);
  END;



  // Seitenkopf drucken
  Lib_Print:Print_Seitenkopf();

// -------- Druck starten ----------------------------------------------------------------


  vFirst # true;

  // Durchlaufen und
  FOR   gItem # Sort_ItemFirst(gTree)
  loop  gItem # Sort_ItemNext(gTree,gItem)
  WHILE (gItem != 0) do begin

    // Datensatz holen
    RecRead(CnvIA(gItem->spCustom),0,0,gItem->spID);    // Custom=Dateinr, ID=SatzID

      if(vFirst = false) then begin
        Lib_Print:Print_FF();
      end;

      // Lagerjournal loopen
      Erx # RecLink(253,250,5,_recFirst);
      WHILE (Erx <= _rLocked ) DO BEGIN
        if(Art.J.Anlage.Datum >= Sel.von.Datum) and (Art.J.Anlage.Datum <= Sel.bis.Datum) then begin
          form_Mode # 'Journal';
          Print('Journal');        // Artikel drucken
        end;
        Erx # RecLink(253,250,5,_recNext);
      END;

      form_Mode # 'EOJournal';
      //gSeite    # 0;


    Print('Summe');

    vFirst # false;
  END;

  // Löschen der Liste
  Sort_KillList(gTree);

  form_Mode # 'FUSS';

// -------- Druck beenden ----------------------------------------------------------------

  // letzte Seite & Job schließen, ggf. mit Vorschaut
  //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

  // Objekte entladen
  if (vPL<>0) then PL_Destroy(vPL);
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;


//========================================================================