@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_PRJ_Eti
//                        OHNE E_R_G
//  Info
//
//
//  07.04.2003  FR  Erstellung der Prozedur
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================

@I:Def_Global


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # 0;
  aSprache  # '';
  RETURN CnvAI(Prj.SL.Nummer ,_FmtNumNoGroup | _FmtNumLeadZero,0,8);      // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx         : int;
  vSammel     : logic;      // Flag für Sammeletikett

  vNummer     : int;        // Dokumentennummer

  vHdl        : int;        // Elementdescriptor

  vHeader     : int;
  vFooter     : int;

  vFlag       : int;        // Datensatzlese option
  vPrt        : int;        // Printelementdeskriptor

  vTree       : int;
  vItem       : int;
end;
begin

  // Header und Footer EINMALIG vorher laden
  vHeader # PrtFormOpen(_PrtTypePrintForm,'');
  vFooter # PrtFormOpen(_PrtTypePrintForm,'');

  // Job Öffnen + Page srstellen
  if (Lib_Print:FrmJobOpen(y, vHeader, vFooter,n,n,n,'RSL_Etikett1') < 0) then begin
    RETURN;
  end;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  form_RandOben   # 0.0;
  form_RandUnten  # 0;

  // Dokumentendialog initialisieren
  Lib_Print:FrmPrintDialog(form_Dokname);


  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen
  Erx # RecLink(121,120,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(250,121,2,_recFirst); // Artikel holen
    if (Erx>_rLocked) then RecBufClear(250);
    Sort_ItemAdd(vTree, cnvaf(Art.Dicke,_FmtNumLeadZero,0,2,15)+cnvaf("Art.Länge",_FmtNumLeadZero,0,2,15), 121, RecInfo(121,_RecId));
    Erx # RecLink(121,120,2,_recNext);
  END;


  // Adresse holen
  RecLink(100,120,1,_RecFirst);

  vSammel # false;

  // Positionen drucken
  vItem # Sort_ItemFirst(vTree);
  WHILE (vItem>0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);


    if (Prj.SL.Etikettentyp = 0) then Prj.SL.Etikettentyp # 1;

    // Etikettentyp prüfen
    if (Prj.SL.Etikettentyp = 1) then begin
      vPrt # PrtFormOpen(_PrtTypePrintForm, 'FRM.PRJ.Etikett.Baustahl');
      end
    else if (Prj.SL.Etikettentyp = 2) then begin
      // Sammeletiketten werden zum Schluss ausgegeben
      vSammel # true; // Flag setzen: Sammeletiketten sind vorhanden
      vItem # Sort_ItemNext(vTree,vItem);
      CYCLE;
      end;
    else if (Prj.SL.Etikettentyp = 3) then begin
      vPrt # PrtFormOpen(_PrtTypePrintForm, 'FRM.PRJ.Etikett.Korb');
    end;

    // Bilddatei laden, falls Skizze vorhanden (für Typ 1 und 3)
    if (Prj.SL.Etikettentyp = 1 or Prj.SL.Etikettentyp = 3) then begin
      vHdl # PrtSearch(vPrt,'PrtSkizze');

      Erx # RecLink(829,121,4,_RecFirst);
      if (Erx <= _rLocked) then
        vHdl->wpCaption # '*' + Skz.Dateiname;
      else
        vHdl->wpCaption # '';
    end;

    // Etikett drucken
    Lib_Print:LFPrint(vPrt);


    vItem # Sort_ItemNext(vTree,vItem);
  END;


  if (vSammel = true) then begin
    // Kopf des Sammeletiketts ausgeben
    vPrt # PrtFormOpen(_PrtTypePrintForm, 'FRM.PRJ.Etikett.Sammel');
    Lib_Print:LfPrint(vPrt);

    // Positionen drucken
    vItem # Sort_ItemFirst(vTree);
    WHILE (vItem>0) do begin
      // Datensatz holen
      RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);


      // Andere Etiketten verwerfen
      if (Prj.SL.Etikettentyp != 2) then begin
        vItem->CteClose();
        vItem # Sort_ItemFirst(vTree);
        CYCLE;
      end;

      vPrt # PrtFormOpen(_PrtTypePrintForm, 'FRM.PRJ.Etikett.Sammel.Pos');
      Lib_Print:LfPrint(vPrt);

      vItem->CteClose();
      vItem # Sort_ItemFirst(vTree);
    END;
    end
  else begin

    // Baum löschen
    vItem # Sort_Itemfirst(vTree);
    WHILE (vItem>0) do begin
      vItem->CteClose();
      vItem # Sort_ItemFirst(vTree);
    END;

  end;


  // Löschen der Liste
  Sort_KillList(vTree);


  // letzte Seite & Job schließen, ggf. mit Vorschau
  //  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);


  // Objekte entladen
  if (vHeader<>0) then vHeader->PrtFormClose();
  if (vFooter<>0) then vFooter->PrtFormClose();

end;

//========================================================================