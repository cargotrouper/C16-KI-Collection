@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Ein0002
//                    OHNE E_R_G
//  Info
//    Gibt eine Wareneingangsliste aus
//
//  17.02.2016  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  OpenJSON      : Lib_JSON:OpenJson
  AddJSONInt    : Lib_JSON:AddJSONInt
  AddJSONAlpha  : Lib_JSON:AddJSONAlpha
  AddJSONDate   : Lib_JSON:AddJSONDate
  AddJSONFloat  : Lib_JSON:AddJSONFloat
  AddJSONBool   : Lib_JSON:AddJSONBool
  SaveXLS       : F_SQL:SaveXLS
  Print         : F_SQL:Print
  FinishList    : F_SQL:FinishList

  dEingang  : Sel.Auf.RahmenYN
  dVSB      : Sel.Auf.AbrufYN
  dAusfall  : Sel.Auf.NormalYN

end;

declare StartList(aSort : alpha);

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  Sel.Auf.bis.Nummer     # 99999999;
  Sel.Auf.bis.Datum      # 31.12.2099;
  Sel.Auf.bis.WTermin    # 31.12.2099;
  Sel.Auf.bis.ZTermin    # 31.12.2099;
  Sel.Bis.Datum3         # 31.12.2099;
  Sel.Auf.bis.AufArt     # 999;
  Sel.Auf.bis.WGr        # 59999;
  Sel.Auf.bis.KostenSt   # 9999;

  dEingang               # y; // Eingänge
  dVSB                   # n; // VSB
  dAusfall               # n; // Ausfälle

  // ----------------------------------------------------------
  Sel.Auf.ObfNr2         # 999;
  Sel.Auf.bis.Dicke      # 999999.00;
  Sel.Auf.bis.Breite     # 999999.00;
  "Sel.Auf.bis.Länge"    # 999999.00;
  // ----------------------------------------------------------
  // nur Artikelnummer
  Sel.Auf.Artikelnr # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Ein0002',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Abmessung',             'Abmessung');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Bestellnr.',            'Bestellnr');
  Sel_Main:AddSort(gMdi, 'Lieferanten-Stichwort', 'Lieferant', true);
  Sel_Main:AddSort(gMdi, 'Qualität * Abmessung',  'Guete,Abmessung');
  Sel_Main:AddSort(gMdi, 'Eingangsdatum',         'Eingangsdatum');
  Sel_Main:AddSort(gMdi, 'VSB-Datum',             'VSBdatum');
  Sel_Main:AddSort(gMdi, 'Ausfalldatum',          'Ausfalldatum');
  gMDI->wpcaption # Lfm.Name;

//  vHdl # Winsearch(gMDI, 'rb.VSB');
//  vHdl->wpCheckState # _WinStateChkChecked;

  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
begin
  gSelected # 0;
  StartList(Sel.Sortierung);
end;


//========================================================================
//
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
  vVonEingang : date;
  vVonVSB     : date;
  vVonAusfall : date;
  vBisEingang : date;
  vBisVSB     : date;
  vBisAusfall : date;
end
begin
  if (dEingang=false) and (dVSB=false) and (dAusfall=false) then RETURN;

  if (Sel.Von.DAtum3=0.0.0) then Sel.Von.Datum3 # 1.1.1900;
  if (dEingang) then begin
    vVonEingang # Sel.Von.Datum3;
    vBisEingang # Sel.Bis.Datum3;
  end
  else begin
    vVonEingang # 31.12.2099;
    vBisEingang # 31.12.2099;
  end;
  if (dVSB) then begin
    vVonVSB # Sel.Von.Datum3;
    vBisVSB # Sel.Bis.Datum3;
  end
  else begin
    vVonVSB # 31.12.2099;
    vBisVSB # 31.12.2099;
  end;
  if (dAusfall) then begin
    vVonAusfall # Sel.Von.Datum3;
    vBisAusfall # Sel.Bis.Datum3;
  end
  else begin
    vVonAusfall # 31.12.2099;
    vBisAusfall # 31.12.2099;
  end;



  vForm   # 'Ein0002';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'VonBestellnummer', "Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisBestellnummer', "Sel.Auf.bis.Nummer");
  AddJsonDate(  vJSON,  'VonBestelldatum',  "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisBestelldatum',  "Sel.Auf.bis.Datum");
  AddJsonDate(  vJSON,  'VonWunschtermin',  "Sel.Auf.von.WTermin");
  AddJsonDate(  vJSON,  'BisWunschtermin',  "Sel.Auf.bis.WTermin");
  AddJsonDate(  vJSON,  'VonZusagetermin',  "Sel.Auf.von.ZTermin");
  AddJsonDate(  vJSON,  'BisZusagetermin',  "Sel.Auf.bis.ZTermin");
  AddJsonInt(   vJSON,  'VonVorgangsart',   "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisVorgangsart',   "Sel.Auf.bis.AufArt");
  AddJsonInt(   vJSON,  'VonWarengruppe',   "Sel.Auf.von.Wgr");
  AddJsonInt(   vJSON,  'BisWarengruppe',   "Sel.Auf.bis.Wgr");
  AddJsonInt(   vJSON,  'VonKostenstelle',  "Sel.Auf.von.Kostenst");
  AddJsonInt(   vJSON,  'BisKostenstelle',  "Sel.Auf.bis.Kostenst");
  AddJsonInt(   vJSON,  'NurLieferantenNr', "Sel.Auf.Lieferantnr");
  AddJsonAlpha( vJSON,  'NurSachbearbeiter',"Sel.Auf.Sachbearbeit");
  AddJsonAlpha( vJSON,  'NurVorgangstypen', "Sel.Auf.Vorgangstyp");
  AddJsonInt(   vJSON,  'NurProjektnummer', "Sel.Auf.Von.Projekt");
  // ---------------------------------------------------------
  AddJsonDate(  vJSON,  'VonEingangsdatum', vVonEingang);
  AddJsonDate(  vJSON,  'BisEingangsdatum', vBisEingang);
  AddJsonDate(  vJSON,  'VonVSBdatum',      vVonVSB);
  AddJsonDate(  vJSON,  'BisVSBdatum',      vBisVSB);
  AddJsonDate(  vJSON,  'VonAusfalldatum',  vVonAusfall);
  AddJsonDate(  vJSON,  'BisAusfalldatum',  vBisAusfall);
  // ---------------------------------------------------------
  AddJsonAlpha( vJSON,  'NurArtikelnummer', "Sel.Auf.Artikelnr");
  AddJsonAlpha( vJSON,  'NurGuetenstufe',   "Sel.Auf.Gütenstufe");
  AddJsonAlpha( vJSON,  'NurGuete',         "Sel.Auf.Güte");
  AddJsonFloat( vJSON,  'VonDicke',         "Sel.Auf.von.Dicke");
  AddJsonFloat( vJSON,  'BisDicke',         "Sel.Auf.bis.Dicke");
  AddJsonFloat( vJSON,  'VonBreite',        "Sel.Auf.von.Breite");
  AddJsonFloat( vJSON,  'BisBreite',        "Sel.Auf.bis.Breite");
  AddJsonFloat( vJSON,  'VonLaenge',        "Sel.Auf.von.Länge");
  AddJsonFloat( vJSON,  'BisLaenge',        "Sel.Auf.bis.Länge");
  // ----------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================