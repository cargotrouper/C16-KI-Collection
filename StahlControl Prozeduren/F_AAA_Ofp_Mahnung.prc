@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_Ofp_Mahnung
//                      OHNE E_R_G
//  Info
//    Druckt eine Mahnung aus
//
//
//  03.05.2013  ST  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_Form

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elPosText          : int;

  elPostenUS          : int;
  elPosten            : int;
  elSumme             : int;

  elEnde              : int;
  elLeerzeile         : int;

gGesOffenerBetrag : float;
end;

//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
local begin
  vBuf100 : int;
end;
begin
  vBuf100 # RekSave(100);
  RecLink(100,460,4,0);   // Kunde holen
  aAdr      # Adr.Nummer;
  aSprache  # Adr.Sprache;

  RekRestore(vBuf100);
  RETURN  CnvAI(Ofp.Kundennummer,_FmtNumNoGroup | _FmtNumLeadZero,0,8)  // Dokumentennummer
                + CnvAd(Sysdate());                                              // Mahndatum
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx       : int;
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;

  vTextNr : int;
end;
begin

  // ERSTE SEITE??
  if (aSeite=1) then begin
    Form_Ele_Ofp:elMahnErsteSeite(var elErsteSeite);
    end
  else begin
    Form_Ele_Ofp:elMahnFolgeSeite(var elFolgeSeite);
  end;

  // Mahntext
  Erx # RecRead(837, 1, _recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (Txt.Bezeichnung = '@Mahntext-' + cnvAI(OfP.Mahnstufe + 1)) then
      vTextNr # Txt.Nummer;
    Erx # RecRead(837, 1, _recNext);
  END;
  vTxtName # '~837.'+CnvAI(vTextnr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  if(vTxtName <> '') then begin
    Form_Elemente:elPosText(var elPosText,vTxtName);
  end;

  // Überschriften
  Form_Ele_Ofp:elMahnPostenUS(var elPostenUS);
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  vNummer     : int;        // Dokumentennummer
  vFlag       : int;        // Datensatzlese option

  vMarked     : int;        // Descriptor für den Marierungsbaum
  vMarkedItem : int;        // Descriptor für markierten Eintrag

  vMahnTree    : int;       // Descriptor für die Sortierungsliste
  vMahnSortKey : alpha;     // "Sortierungsschlüssel" der Liste
  vMahnItem    : int;       // Descriptor für einen Offenen Posten

  vKunde       : int;       // Merker für Kundenwechsel
  vUeberfaellig : int;      // Differenz zwischen heutigem Tag und Zieldatum
  vAdresse     : int;       // Merker für Kundenanschrift

  // Markierungen
  vMFile              : int;
  vMID                : int;

end;
begin

  // nur aktuellen Ofp.Kunden mahnen
  vKunde # Ofp.Kundennummer;
  Erx # RecLink(100,460,4,_recFirst); // Kunde holen
  if (Erx > _rLocked) then
    RETURN;

  // Mahnungsliste fürs Sortieren erstellen
  vMahnTree # CteOpen(_CteTreeCI);
  if (vMahnTree = 0) then
    RETURN;

  /* Markierungen sortiert in eigene Liste schreiben */
  FOR vMarked # gMarkList->CteRead(_CteFirst);
  LOOP vMarked # gMarkList->CteRead(_CteNext,vMarked);
  WHILE (vMarked > 0) DO BEGIN
    Lib_Mark:TokenMark(vMarked,var vMFile,var vMID);

    if (vMFile <> 460) then
      CYCLE;

    RecRead(460,0,_RecId,vMID);

    if (OFp.Kundennummer=vKunde) then begin
      // gelesenen Eintrag in eigene Liste übergeben
      vMahnSortKey # CnvAi(Ofp.Kundennummer, _FmtNumNoGroup | _FmtNumLeadZero,0,10) +
                     CnvAi(100 - OfP.Mahnstufe, _FmtNumNoGroup | _FmtNumLeadZero,0,3);
      Sort_ItemAdd(vMahnTree,vMahnSortKey,460,vMID);

    end;
  END;

  // 1. Satz holen
  vMahnItem # Sort_ItemFirst(vMahntree)
  if (vMahnItem=0) then begin
    // Löschen der Liste
    Sort_KillList(vMahnTree);
    RETURN;
  end;

  RecRead(460,0,_RecId, vMahnItem->spID);



  // ------- KOPFDATEN -----------------------------------------------------------------------
  Erx # RecLink(101,100,12,_recFirst);  // Hauptanschrift holen
  if(Erx > _rLocked) then
    RecBufClear(101);

  // Job Öffnen + Page generieren
  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;


  form_FaxNummer  # Adr.A.Telefax;
  Form_EMA        # Adr.A.EMail;

  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  Form_Elemente:elSeitenFuss(var elSeitenFuss, false);

  Lib_Print:Print_Seitenkopf();

  FOR   vMahnItem # Sort_ItemFirst(vMahntree)
  loop  vMahnItem # Sort_ItemNext(vMahntree, vMahnItem)
  WHILE (vMahnItem <> 0) DO BEGIN

    RecRead(460,0,_RecId, vMahnItem->spID);

    if (Ofp.Mahnstufe = 0) then begin
      "OfP.MahngebührW1"  # 0.0;
      "OfP.Mahngebühr"    # 0.0;
    end;

    RekLink(814,460,7,0);   // Währung lesen

    Form_Ele_Ofp:elMahnPosten(var elPosten);

    gGesOffenerBetrag # gGesOffenerBetrag + OfP.Rest;
  END;
  Ofp.Rest # gGesOffenerBetrag;
  Form_Ele_Ofp:elSumme(var elSumme,gGesOffenerBetrag);


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  Form_Ele_Ofp:elMahnEnde(var elEnde);



  // -------- Druck beenden ----------------------------------------------------------------

  // Objekte entladen
  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );

  FreeElement(var elPosText        );
  FreeElement(var elPostenUS          );
  FreeElement(var elPosten            );
  FreeElement(var elSumme             );

  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile         );
  FreeElement(var elSeitenFuss        );

  Sort_KillList(vMahnTree);

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

end;



//========================================================================