@A+
//==== Business-Control ==================================================
//
//  Prozedur    Rgt_Menudata
//                  OHNE E_R_G
//  Info
//    Disabeld die Menüeinträge je nach Recht
//
//  22.02.2003  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB NodeRemove(aDescrTree : int; aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_Rights

LOCAL begin
  vHdlMenu : int;
  vHdlTree : int;
  vtmp     : int;
end;

//========================================================================
//  NodeRemove
//
//========================================================================
sub NodeRemove(
  aDescrTree  : int;
  aName       : alpha
  );

begin
  vTmp # WinSearch(aDescrTree,aName);
  if (vTmp<>0) then WinTreeNodeRemove(vTmp);
end;


//========================================================================
//  MenuRemove
//
//========================================================================
sub MenuRemove(
  aMenu       : int;
  aName       : alpha
  );
begin
  vTmp # WinSearch(aMenu,aName);
  if (vTmp<>0) then WinMenuItemRemove(vTmp);
end;


//========================================================================
//
//
//========================================================================
MAIN (
       aDescrMenu : int;
       aDescrTree : int;
)
local begin
  vA  : alpha(1000);
  vI  : int;
end;
begin

  // OberPunkte
  //    Knotenpunkte
  //            Unterpunkte
//for vI # 330 loop inc (vI) while (vI<335) do
//  if Rechte[vI] then vA # vA + '+' else vA # vA + '.';
//debug(vA);

  // 17.12.2014
  MenuRemove(aDescrMenu,'Auf');
  NodeRemove(aDescrTree,'Auf');


// ---- Auftrag -----------------------------------------------------------
  if (!Rechte[Rgt_Mnu_Auftrag]) then begin
    MenuRemove(aDescrMenu,'Auftrag');
    NodeRemove(aDescrTree,'Auftrag');
  end;

  if (!Rechte[Rgt_Versand]) or (Set.LFS.mitVersandYN=n) then begin
    MenuRemove(aDescrMenu,'Versand');
    NodeRemove(aDescrTree,'Versand');
  end;

  if (!Rechte[Rgt_Versandpool]) or (Set.LFS.mitVersandYN=n) then begin
    MenuRemove(aDescrMenu,'Versandpool');
    NodeRemove(aDescrTree,'Versandpool');
  end;

// ---- Einkauf -----------------------------------------------------------
  if !Rechte[Rgt_Mnu_Einkauf] then begin
    MenuRemove(aDescrMenu,'Einkauf');
    NodeRemove(aDescrTree,'Einkauf');
  end
  else begin
    // ---- Hilfs- únd Betriebsstoffe ----
    if !Rechte[Rgt_HuB_Einkauf] then begin
      vHdlMenu # Winsearch(aDescrMenu,'HuB_EK');
      vHdlTree # WinSearch(aDescrTree,'Einkauf');

      if (vHdlMenu<>0) then vHdlMenu-> wpDisabled # true;
      NodeRemove(vHdlTree,'HuB.EK');
    end;
  end;

// ---- Produktion --------------------------------------------------------
  if !Rechte[Rgt_Mnu_Produktion] then begin
    MenuRemove(aDescrMenu,'Produktion');
    NodeRemove(aDescrTree,'Produktion');
  end
  else begin
    //MenuRemove(aDescrMenu,'Betrieb');
    //NodeRemove(aDescrTree,'Betrieb');
  end;

// ---- QS ----------------------------------------------------------------
  if !Rechte[Rgt_Mnu_QS] then begin
    MenuRemove(aDescrMenu,'QS');
    NodeRemove(aDescrTree,'QS');
  end
  else begin
    // ---- Workflow ----
    if !Rechte[Rgt_Workflow_Schema] or
      (StrFind(Set.Module,'W',0)=0) then begin
      MenuRemove(aDescrMenu,'WoF.Schema');
      NodeRemove(aDescrTree,'WoF.Schema');
    end;
    // ---- LfE ----
    if !Rechte[Rgt_LfErklaerungen] or
      (StrFind(Set.Module,'L',0)=0) then begin
      MenuRemove(aDescrMenu,'LfE');
      NodeRemove(aDescrTree,'LfE');
    end;
  end;

// ---- Finanzen ----------------------------------------------------------
  if !Rechte[Rgt_Mnu_Finanzen] then begin
    MenuRemove(aDescrMenu,'Finanzen');
    NodeRemove(aDescrTree,'Finanzen');
  end
  else begin

    // ---- Eingangsrechnungen ----
    if !Rechte[Rgt_ERe] then begin
      MenuRemove(aDescrMenu,'Eingangsrechnung');
      NodeRemove(aDescrTree,'Eingangsrechnung');
    end;

    // ---- Einkaufskontrolle ----
    if !Rechte[Rgt_EKK] then begin
      MenuRemove(aDescrMenu,'EKK');
      NodeRemove(aDescrTree,'EKK');
    end;

    // ---- Lagergeld-Fremd ----
    if !Rechte[Rgt_Fin_Mat_LagerFremd] then begin
      MenuRemove(aDescrMenu,'Mat.Lagergeld.Fremd');
      NodeRemove(aDescrTree,'Mat.Lagergeld.Fremd');
    end;

    // ---- Lagergeld-Kunde ----
    if !Rechte[Rgt_Fin_Mat_LagerKunde] then begin
      MenuRemove(aDescrMenu,'Mat.Lagergeld.Kunde');
      NodeRemove(aDescrTree,'Mat.Lagergeld.Kunde');
    end;

    // ---- Zinsen ----
    if !Rechte[Rgt_Fin_Mat_Zinsen] then begin
      MenuRemove(aDescrMenu,'Mat.Zinsen');
      NodeRemove(aDescrTree,'Mat.Zinsen');
    end;

    // ---- Offene Posten ----
    if !Rechte[Rgt_OffenePosten] then begin
      MenuRemove(aDescrMenu,'OffenePosten');
      NodeRemove(aDescrTree,'OffenePosten');
    end;

    // ---- Zahlungseingänge ----
    if !Rechte[Rgt_Zahlungsein] then begin
      MenuRemove(aDescrMenu,'Zahlungsein');
      NodeRemove(aDescrTree,'Zahlungsein');
    end;

    // ---- Fixkosten ----
    if !Rechte[Rgt_FixKosten] then begin
      MenuRemove(aDescrMenu,'FixKosten');
      NodeRemove(aDescrTree,'FixKosten');
    end;

    // ---- Kasse ----
    if !Rechte[Rgt_Kasse] then begin
      MenuRemove(aDescrMenu,'Kasse');
      NodeRemove(aDescrTree,'Kasse');
    end;

    // ---- Controlling ----
    if !Rechte[Rgt_Controlling] or
      (StrFind(Set.Module,'C',0)=0) then begin
      MenuRemove(aDescrMenu,'Controlling');
      NodeRemove(aDescrTree,'Controlling');
    end;
  end;

// ---- Stammdaten --------------------------------------------------------
  if !Rechte[Rgt_Mnu_Stammdaten] then begin
    MenuRemove(aDescrMenu,'Stammdaten');
    NodeRemove(aDescrTree,'Stammdaten');
  end
  else begin
    // ---- Adressen ----
    if !Rechte[Rgt_Adressen] then begin
      MenuRemove(aDescrMenu,'Adressen');
      NodeRemove(aDescrTree,'Adressen');
    end;

    // ---- Vertreter & Verbände ----
    if !Rechte[Rgt_VertreterVerbaende] then begin
      MenuRemove(aDescrMenu,'VertreterVerbaende');
      NodeRemove(aDescrTree,'VertreterVerbaende');
    end;

    // ---- Hilfs- und Betriebsstoffe ----
    if !Rechte[Rgt_HuB] then begin
      MenuRemove(aDescrMenu,'HuB');
      NodeRemove(aDescrTree,'HuB');
    end;

    // ---- Material ----
    if !Rechte[Rgt_Material] then begin
      MenuRemove(aDescrMenu,'Material');
      NodeRemove(aDescrTree,'Material');
    end;

    // ---- Ressourcen ----
    if !Rechte[Rgt_Ressourcen] then begin
      MenuRemove(aDescrMenu,'Ressourcen');
      NodeRemove(aDescrTree,'Ressourcen');
    end;

    // ---- Mathematik ----
    if !Rechte[Rgt_Formel] then begin
      MenuRemove(aDescrMenu,'Mathematik');
      NodeRemove(aDescrTree,'Mathematik');
    end;
  end;

// ---- Vorgaben ----------------------------------------------------------
  if !Rechte[Rgt_Mnu_Vorgaben] then begin
    MenuRemove(aDescrMenu,'Vorgaben');
    NodeRemove(aDescrTree,'Vorgaben');
  end
  else begin
    // ---- Schlüsseldateien  ----
    if !Rechte[Rgt_Mnu_Schluesseldateien] then begin
      MenuRemove(aDescrMenu,'Schluesseldateien');
      NodeRemove(aDescrTree,'Schluesseldateien');
    end
    else begin
      // ---- Abteilungen
      if !Rechte[Rgt_Abteilungen] then begin
        MenuRemove(aDescrMenu,'Abteilungen');
        NodeRemove(aDescrTree,'Abteilungen');
      end;

      // ---- Anreden
      if !Rechte[Rgt_Anreden] then begin
        MenuRemove(aDescrMenu,'Anreden');
        NodeRemove(aDescrTree,'Anreden');
      end;

      // ---- Auftragsarten
      if !Rechte[Rgt_Auftragsarten] then begin
        MenuRemove(aDescrMenu,'Auftragsarten');
        NodeRemove(aDescrTree,'Auftragsarten');
      end;

      // ---- BDS
      if !Rechte[Rgt_BDS] then begin
        MenuRemove(aDescrMenu,'bds');
        NodeRemove(aDescrTree,'bds');
      end;

      // ---- Etiketten
      if !Rechte[Rgt_Etiketten] then begin
        MenuRemove(aDescrMenu,'Etiketten');
        NodeRemove(aDescrTree,'Etiketten');
      end;

      // ---- Gruppen
      if !Rechte[Rgt_Gruppen] then begin
        MenuRemove(aDescrMenu,'Gruppen');
        NodeRemove(aDescrTree,'Gruppen');
      end;

      // ---- Instandhaltungsmaßnahmen
      if !Rechte[Rgt_IHA_Massnahmen] then begin
        MenuRemove(aDescrMenu,'IHA.Massnahmen');
        NodeRemove(aDescrTree,'IHA.Massnahmen');
      end;

      // ---- Instandhaltungsmeldungen
      if !Rechte[Rgt_IHA_Meldungen] then begin
        MenuRemove(aDescrMenu,'IHA.Meldungen');
        NodeRemove(aDescrTree,'IHA.Meldungen');
      end;

      // ---- Instandhaltungsursachen
      if !Rechte[Rgt_IHA_Ursachen] then begin
        MenuRemove(aDescrMenu,'IHA.Ursachen');
        NodeRemove(aDescrTree,'IHA.Ursachen');
      end;

      // ---- Länder
      if !Rechte[Rgt_Laender] then begin
        MenuRemove(aDescrMenu,'Laender');
        NodeRemove(aDescrTree,'Laender');
      end;

      // ---- Lieferbedingungen
      if !Rechte[Rgt_Lieferbed] then begin
        MenuRemove(aDescrMenu,'Lieferbedingungen');
        NodeRemove(aDescrTree,'Lieferbedingungen');
      end;

      // ---- Materialstati
      if !Rechte[Rgt_Materialstatus] then begin
        MenuRemove(aDescrMenu,'Materialstatus');
        NodeRemove(aDescrTree,'Materialstatus');
      end;

      // ---- Ressourcengruppen
      if !Rechte[Rgt_Ressourcengruppen] then begin
        MenuRemove(aDescrMenu,'Ressourcengruppen');
        NodeRemove(aDescrTree,'Ressourcengruppen');
      end;

      // ---- Steuerschlüssel
      if !Rechte[Rgt_Steuerschluessel] then begin
        MenuRemove(aDescrMenu,'Steuerschluessel');
        NodeRemove(aDescrTree,'Steuerschluessel');
      end;

      // ---- Unterlagen
      if !Rechte[Rgt_Unterlagen] then begin
        MenuRemove(aDescrMenu,'Unterlagen');
        NodeRemove(aDescrTree,'Unterlagen');
      end;

      // ---- Versandarten
      if !Rechte[Rgt_Versandarten] then begin
        MenuRemove(aDescrMenu,'Versandarten');
        NodeRemove(aDescrTree,'Versandarten');
      end;

      // ---- Verwiegungsarten
      if !Rechte[Rgt_Verwiegungsarten] then begin
        MenuRemove(aDescrMenu,'Verwiegungsarten');
        NodeRemove(aDescrTree,'Verwiegungsarten');
      end;

      // ---- Währungen
      if !Rechte[Rgt_Waehrungen] then begin
        MenuRemove(aDescrMenu,'Waehrungen');
        NodeRemove(aDescrTree,'Waehrungen');
      end;

      // ---- Warengruppen
      if !Rechte[Rgt_Warengruppen] then begin
        MenuRemove(aDescrMenu,'Warengruppen');
        NodeRemove(aDescrTree,'Warengruppen');
      end;

      // ---- Zahlungsbedingungen
      if !Rechte[Rgt_Zahlungsbed] then begin
        MenuRemove(aDescrMenu,'Zahlungsbedingungen');
        NodeRemove(aDescrTree,'Zahlungsbedingungen');
      end;

      // ---- Zeignisse
      if !Rechte[Rgt_Zeugnisse] then begin
        MenuRemove(aDescrMenu,'Zeugnisse');
        NodeRemove(aDescrTree,'Zeugnisse');
      end;
    end;

    // ---- Rechtesystem ----
    if !Rechte[Rgt_Mnu_Rechtesystem] then begin
      MenuRemove(aDescrMenu,'Rechtesystem');
      NodeRemove(aDescrTree,'Rechtesystem');
    end;

    // ---- Einstellungen ----
    if !Rechte[Rgt_Mnu_Einstellungen] then begin
      MenuRemove(aDescrMenu,'Einstellungen');
      NodeRemove(aDescrTree,'Einstellungen');
    end
    else begin // ---- Untermenues Einstellungen ----

      // ---- Schlüssel ----
      if !Rechte[Rgt_Einst_Schluessel] then begin
        MenuRemove(aDescrMenu,'Schluessel');
        NodeRemove(aDescrTree,'Schluessel');
      end;

      // ---- Nummernkreise ----
      if !Rechte[Rgt_Einst_Nummernkreise] then begin
        MenuRemove(aDescrMenu,'Nummernkreise');
        NodeRemove(aDescrTree,'Nummernkreise');
      end;

      // ---- Settings ----
      if !Rechte[Rgt_Einst_Settings] then begin
        MenuRemove(aDescrMenu,'Settings');
        NodeRemove(aDescrTree,'Settings');
      end;

      // ---- Übersetzungen ----
      if !Rechte[Rgt_Einst_Uebersetzung] then begin
        MenuRemove(aDescrMenu,'Uebersetzungen');
        NodeRemove(aDescrTree,'Uebersetzungen');
      end;

      // ---- Ausdrucke ----
      if !Rechte[Rgt_Einst_Ausdrucke] then begin
        MenuRemove(aDescrMenu,'Ausdrucke');
        NodeRemove(aDescrTree,'Ausdrucke');
      end;

      // ---- Individuell ----
      if !Rechte[Rgt_Einst_Individuell] then begin
        MenuRemove(aDescrMenu,'Individuell');
        NodeRemove(aDescrTree,'Individuell');
      end;

      // ---- Skripte ----
      if !Rechte[Rgt_Einst_Skripte] then begin
        MenuRemove(aDescrMenu,'Skripte');
        NodeRemove(aDescrTree,'Skripte');
      end;

      // ---- Serviceinventar ----
      if !Rechte[Rgt_SOA_Serviceinventar] then begin
        MenuRemove(aDescrMenu,'Serviceinventar');
        NodeRemove(aDescrTree,'Serviceinventar');
      end;

      // ---- Protokoll ----
      if !Rechte[Rgt_Einst_Protokoll] then begin
        MenuRemove(aDescrMenu,'Protokoll');
        NodeRemove(aDescrTree,'Protokoll');
      end;
    end;

    // ---- Texte  ----
    if !Rechte[Rgt_Texte] then begin
      MenuRemove(aDescrMenu,'Texte');
      NodeRemove(aDescrTree,'Texte');
    end;

    // ---- Adr.Dokument-Struktur  ----
    if !Rechte[Rgt_Adr_Dok_Struktur] then begin
      MenuRemove(aDescrMenu,'Adr.Dok.Struktur');
      NodeRemove(aDescrTree,'Adr.Dok.Struktur');
    end;
  end;

// ---- Extras ------------------------------------------------------------
  if !Rechte[Rgt_Mnu_Extras] then begin
    MenuRemove(aDescrMenu,'Extras');
    NodeRemove(aDescrTree,'Extras');
  end
  else begin
    // ---- Termine ----
    if !Rechte[Rgt_Termine] then begin
      MenuRemove(aDescrMenu,'Termine');
      NodeRemove(aDescrTree,'Termine');
    end;

    // ---- Aktivitaeten ----
    if !Rechte[Rgt_Mnu_Aktivitaeten] then begin
      MenuRemove(aDescrMenu,'Aktivitaeten');
      NodeRemove(aDescrTree,'Aktivitaeten');
    end;

    // ---- Inventur ----
    if !Rechte[Rgt_Art_Inventur] then begin
      MenuRemove(aDescrMenu,'Inventur');
      NodeRemove(aDescrTree,'Inventur');
    end;

    // ---- Dokumentablage ----
    if !Rechte[Rgt_Mnu_Dokumentablage] then begin
      MenuRemove(aDescrMenu,'Dokumentablage');
      NodeRemove(aDescrTree,'Dokumentablage');
    end
    else begin
      // ---- Auftragsbestätigung
      if !Rechte[Rgt_Mnu_Dka_Auftragsbest] then begin
        MenuRemove(aDescrMenu,'DokumentAufBe');
        NodeRemove(aDescrTree,'DokumentAufBe');
      end;

      // ---- Lieferscheine
      if !Rechte[Rgt_Mnu_Dka_Lieferscheine] then begin
        MenuRemove(aDescrMenu,'DokumentLFS');
        NodeRemove(aDescrTree,'DokumentLFS');
      end;

      // ---- Rechnungen
      if !Rechte[Rgt_Mnu_Dka_Rechnungen] then begin
        MenuRemove(aDescrMenu,'DokumentRech');
        NodeRemove(aDescrTree,'DokumentRech');
      end;
    end;

    // ---- Kommandozeile ----
    if !Rechte[Rgt_Mnu_Kommandozeile] then begin
      MenuRemove(aDescrMenu,'Kommandozeile');
      NodeRemove(aDescrTree,'Kommandozeile');
    end;


    // ---- Datenimporte ----
    if !Rechte[Rgt_XML_Datenimporte] then begin
      MenuRemove(aDescrMenu,'XML');
      NodeRemove(aDescrTree,'XML');
    end;
  end;

// ---- Datenbank ---------------------------------------------------------

  if !Rechte[Rgt_Mnu_Datenbank] then begin
    MenuRemove(aDescrMenu,'Datenbank');
    NodeRemove(aDescrTree,'Datenbank');
  end
  else begin
    // ---- Benutzer wechseln ----
    if !Rechte[Rgt_Mnu_Benutzerwechsel] then begin
      MenuRemove(aDescrMenu,'Benutzerwechsel');
      NodeRemove(aDescrTree,'Benutzerwechsel');
    end;

      // ---- Passwort ändern ----
    if !Rechte[Rgt_Mnu_Passwortaendern] then begin
      MenuRemove(aDescrMenu,'Passwortaendern');
      NodeRemove(aDescrTree,'Passwortaendern');
    end;

    // ---- Info ----
    if !Rechte[Rgt_Mnu_DBInfo] then begin
      MenuRemove(aDescrMenu,'DB.Info');
      NodeRemove(aDescrTree,'DB.Info');
    end;

    // ---- Datenbankpflege ----
    if !Rechte[Rgt_Mnu_Datenbankpflege] then begin
      MenuRemove(aDescrMenu,'Pflege');
      NodeRemove(aDescrTree,'Pflege');
    end;
  end;

// ---- Favoriten ---------------------------------------------------------
  if !Rechte[Rgt_Mnu_Favoriten] then
    NodeRemove(aDescrTree,'Favoriten');

/*
  // Prefab

  // ----  ------------------------------------------------------------------
  if !Rechte[Rgt_] then begin
    WinMenuItemRemove(WinSearch(aDescrMenu,''));
  end
  else begin
    // ---- ----
    if !Rechte[Rgt_] then begin
      WinMenuItemRemove(WinSearch(aDescrMenu,''));
    end
    else begin
      // ----
      if !Rechte[Rgt_] then begin
        WinMenuItemRemove(WinSearch(aDescrMenu,''));
      end;
    end;
  end;
*/

end;

//========================================================================


