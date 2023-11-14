@A+
//===== Business-Control =================================================
//
//  Prozedur  Prj_Data
//                      OHNE E_R_G
//  Info
//
//
//  21.04.2006  AI  Erstellung der Prozedur
//  04.08.2008  PW  Selektionsquery
//  21.01.2010  PW  Austauschprojekt
//  13.07.2012  MS  Bei Auftragsanlader der Wartungen wird ggf. der Prj. Text als Fusstext uebernommen
//  26.04.2016  AH  Neu: CopyVorlage
//  22.08.2019  AH  Neu: Wartungslauf mit Datumsabfrage
//  25.01.2022  AH  Wartungslauf für negative Mengen erzeugt Aufpreise
//  16.03.2022  AH  ERX
//
//  Subprozeduren
//    SUB Wtg_naechsterTermin() : date;
//    SUB Wtg_Wartungslauf() : int;
//
//    sub ProjektExport ()
//    sub ProjektImport_LoadPosition ( vPos : handle )
//    sub ProjektImport ()
//    sub CopyVorlage(aNr : int);
//
//========================================================================
@I:Def_global
@I:Def_BAG

define begin
  // Austauschprojekte
  cAPPosMark : 1000
  cAPVersion : '1'

  getTimestamp ( d, t ) : ( ( CnvID( d ) - CnvID( 01.01.1970 ) ) * 86400 + CnvIT( t ) / 1000 )
  CnvInt ( x )          : CnvAI( x, _fmtInternal )
end;


//========================================================================
//  Wtg_naechsterTermin
//
//========================================================================
sub Wtg_naechsterTermin() : date;
local begin
  vDat    : date;
  vMin    : date;
  vKW     : word;
  vJahr   : word;
end;
begin
// datemake
// vmdaymodify, vmmonthmodify

  vMin # Prj.Termin.Start;

  if (Prj.Wartung.AME='') or (vMin=0.0.0) then RETURN 0.0.0;

  vDat # Prj.Wtg.LetztesDatum;

  if (vDat=0.0.0) then begin    // 1. Termin finden
    vDat # vMin;
    end
  else begin
    vMin # vDat
    vMin->vmdayModify(1);
  end;


  case (Prj.Wartungsinterval) of

    'KW' : begin
      Lib_Berechnungen:KW_Aus_datum(vDat,var vKW, var vJahr);
      Lib_Berechnungen:Mo_von_KW(vKW, vJahr, var vDat);
      if (Prj.Wartung.AME='A') then begin
      end;
      if (Prj.Wartung.AME='M') then begin
        vDat->vmdaymodify(2);
      end;
      if (Prj.Wartung.AME='E') then begin
        vDat->vmdaymodify(4);
      end;
      if (vDat<vMin) then vDat->vmdaymodify(7);
    end;

    'MO' : begin
      if (Prj.Wartung.AME='A') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # vMin->vpmonth;
        vDat->vpyear  # vMin->vpyear;
      end;
      if (Prj.Wartung.AME='M') then begin
        vDat->vpDay   # 15;
        vDat->vpMonth # vMin->vpmonth;
        vDat->vpyear  # vMin->vpyear;
      end;
      if (Prj.Wartung.AME='E') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # vMin->vpmonth;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(1);
        vDat->vmdaymodify(-1);
      end;
      if (vDat<vMin) then vDat->vmmonthmodify(1);
    end;

    'QU' : begin
      if (Prj.Wartung.AME='A') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # (((vMin->vpmonth-1) div 3)*3)+1;
        vDat->vpyear  # vMin->vpyear;
      end;
      if (Prj.Wartung.AME='M') then begin
        vDat->vpDay   # 15;
        vDat->vpMonth # (((vMin->vpmonth-1) div 3)*3)+1;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(1);
      end;
      if (Prj.Wartung.AME='E') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # (((vMin->vpmonth-1) div 3)*3)+1;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(3);
        vDat->vmdaymodify(-1);
      end;
      if (vDat<vMin) then vDat->vmmonthmodify(3);
    end;

    'SE' : begin
      if (Prj.Wartung.AME='A') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # (((vMin->vpmonth-1) div 6)*6)+1;
        vDat->vpyear  # vMin->vpyear;
      end;
      if (Prj.Wartung.AME='M') then begin
        vDat->vpDay   # 15;
        vDat->vpMonth # (((vMin->vpmonth-1) div 6)*6)+1;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(1);
      end;
      if (Prj.Wartung.AME='E') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # (((vMin->vpmonth-1) div 6)*6)+1;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(3);
        vDat->vmdaymodify(-1);
      end;
      if (vDat<vMin) then vDat->vmmonthmodify(3);
    end;

    'JA' : begin
/*
      if (Prj.Wartung.AME='A') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # 1;
        vDat->vpyear  # vMin->vpyear;
      end;
      if (Prj.Wartung.AME='M') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # vMin->vpmonth;
        vDat->vpyear  # vMin->vpyear;
        vDat->vmmonthmodify(6);
      end;
      if (Prj.Wartung.AME='E') then begin
        vDat->vpDay   # 1;
        vDat->vpMonth # 1;
        vDat->vpyear  # vMin->vpyear + 1;
        vDat->vmdaymodify(-1);
//        vDat->vmmonthmodify(12);
//        vDat->vmdaymodify(-1);
      end;
*/
      if (vDat<vMin) then vDat->vmmonthmodify(12);
    end;

  end;

  if (vDat>Prj.Termin.Ende) and (Prj.Termin.Ende<>0.0.0) then begin
    RETURN 0.0.0;
  end;

  RETURN vDat;
end;


//========================================================================
//  Wtg_Wartungslauf
//
//========================================================================
sub Wtg_Wartungslauf() : int;
local begin
  Erx       : int;
  vStichtag : date;
  vErg      : int;
  vAnz      : int;
  vSel      : int;
  vSelName  : alpha;
  vNeuKopf  : logic;
  vPos      : int;
  vWartDat  : date;
  vX        : float;

  vName     : alpha;
  vTxtHdl   : int;
  vI        : int;

  vQ  : alpha(4000);
  vQ1 : alpha(4000);
  vQ2 : alpha(4000);
  tErg : int;
  vProgress  : int;
end;
begin

  vStichtag # today;
  if (Dlg_Standard:Datum('Wartung zu Termin',var vStichtag, today)=false) then RETURN 0;

  // ehemals Selektion 120 WARTUNGSLAUF
  vQ  # '';
  vQ1 # '';
  vQ2 # '';

  Lib_Sel:QAlpha( var vQ, '"Prj.Löschmarker"', '=', '' );
  Lib_Sel:QAlpha( var vQ, '"Prj.Wartung.AME"', '!=', '' );
  Lib_Sel:QInt( var vQ, 'Prj.Adressnummer', '!=', 0 );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ  # vQ + ' LinkCount(Adr) > 0 AND LinkCount(Stk) > 0 ';
  Lib_Sel:QInt( var vQ1, 'Adr.KundenNr', '>', 0 );
  Lib_Sel:QInt( var vQ2, 'Prj.SL.Nummer', '>', 0 );

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 120, 2 );
  vSel->SelAddLink( '', 100, 120, 1, 'Adr');
  vSel->SelAddLink( '', 121, 120, 2, 'Stk');
  tErg # vSel->SelDefQuery( '',    vQ );
  if (tErg != 0) then Lib_Sel:QError(vSel);
  tErg # vSel->SelDefQuery( 'Adr', vQ1 );
  if (tErg<>0) then Lib_Sel:QError(vSel);
  tErg # vSel->SelDefQuery( 'Stk', vQ2 );
  if (tErg<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  TRANSON;

  RecBufClear(100);

  vProgress # Lib_Progress:Init( 'Projekte', RecInfo( 120, _recCount, vSel ) );

  // Projekte loopen
  vErg # RecRead(120,vSel,_RecFirst);
  WHILE (vErg<=_rLocked ) DO BEGIN

    if (vProgress>0) then vProgress->Lib_Progress:Step();

    // schon fällig? Nein -> nächste holen
    vWartDat # Wtg_naechsterTermin();
    if (vWartDat>vStichtag) then begin
      vErg # RecRead(120,vSel,_RecNext);
      CYCLE;
    end;

    if (vErg=_rLocked) then begin // gesperrt??? ABBRUCH
      vAnz # -172;
      BREAK;
    end;

    vNeuKopf # n;

    // neuer Kunde??
    if (Prj.Adressnummer<>Adr.Nummer) then begin
      Erx # RecLink(100,120,1,_recFirst);   // Adresse holen
      if (Erx>_rLocked) then begin          // unbekannt??? ABBRUCH
        vAnz # -182;
        BREAK;
      end;
      if (Adr.Kundennr=0) then begin    // kein Kunde??? ABBRUCH
        vAnz # -186;
        BREAK;
      end;
      if (Adr.SperrKundeYN) then begin  // gesperrt??? ABBRUCH
        vAnz # -190;
        BREAK;
      end;

      vPos # 1;

      // AUFTRAGSKOPF anlegen **********************************************
      RecBufClear(400);

      Auf.Nummer # Lib_Nummern:ReadNummer('Auftrag');
      if (Auf.Nummer<>0) then Lib_Nummern:SaveNummer()
      else begin
        vAnz # -208;
        BREAK;
      end;
      Auf.Datum             # today;
      Auf.Sachbearbeiter    # gUserName;
      Auf.Vorgangstyp       # c_AUF;

      Auf.Kundennr          # Adr.Kundennr;
      Auf.KundenStichwort   # Adr.Stichwort;
      Auf.P.Kundennr        # Auf.Kundennr;
      Auf.P.KundenSW        # Auf.KundenStichwort;
      Auf.Lieferadresse     # Adr.Nummer;
      Auf.LieferAnschrift   # 1;
      Auf.RechnungsEmpf     # Auf.Kundennr;
      Auf.RechnungsAnschr   # 1;
      
      // 10.01.2017 AH:
      if ("Adr.VK.ReEmpfänger"<>0) then begin
        Auf.RechnungsEmpf     # "Adr.Vk.ReEmpfänger";
        Auf.RechnungsAnschr   # Adr.VK.ReAnschrift;
      end;

      "Auf.Währung"         # "Adr.VK.Währung";
      Auf.Lieferbed         # Adr.VK.Lieferbed;
      Auf.Zahlungsbed       # Adr.VK.Zahlungsbed;
      Auf.Versandart        # Adr.VK.Versandart;
      Auf.Sprache           # Adr.Sprache;
      Auf.AbmessungsEH      # Adr.AbmessungEH;
      Auf.GewichtsEH        # Adr.GewichtEH;
      "Auf.Steuerschlüssel" # "Adr.Steuerschlüssel";
      Auf.Vertreter         # Adr.Vertreter;

      /* Fußtext */
      RecBufClear( 837 );
      vTxtHdl # TextOpen( 32 );
      vName   # '~120.'+CnvAI(Prj.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
      TextRead(vTxtHdl, vName, 0);
      if((TextInfo(vTxtHdl, _textSize) <> 0) and (TextInfo(vTxtHdl, _TextLines) > 0)) then begin // Prj. vorhanden?
        Lib_Texte:TxtLoadLangBuf(vName, vTxtHdl, Auf.Sprache);
        if ((TextInfo(vTxtHdl, _textSize) + TextInfo(vTxtHdl, _textLines)) = 0) then
          TxtDelete('~401.' + CnvAI( Auf.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ) + '.F', 0);
        else begin
          TxtWrite( vTxtHdl, '~401.' + CnvAI( Auf.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ) + '.F', _textUnlock );
        end;
      end
      else if ( Adr.VK.Fusstext != 0 ) then
        Txt.Nummer # Adr.VK.Fusstext;
      else if ( Set.Auf.Fusstext != 0 ) then
        Txt.Nummer # Set.Auf.Fusstext;
      if ( Txt.Nummer != 0 ) then begin
        if ( RecRead( 837, 1, 0 ) < _rLocked ) then begin
          vName   # '~401.' + CnvAI( Auf.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ) + '.F';
          Lib_Texte:TxtLoadLangBuf( '~837.' + CnvAI( Txt.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ), vTxtHdl, Auf.Sprache );
          if ( ( TextInfo( vTxtHdl, _textSize ) + TextInfo( vTxtHdl, _textLines ) ) = 0 ) then
            TxtDelete( vName, 0 );
          else begin
            TxtWrite( vTxtHdl, vName, _textUnlock );
          end;
        end;
      end;
      TextClose(vTxtHdl);


      Erx # RekInsert(400,0,'AUTO');
      if (erx<>_rOK) then begin
        vAnz # -234;
        BREAK;
      end;

//debug('Kopf für '+Adr.Stichwort);
      vAnz # vAnz + 1;
      vNeuKopf # y;
    end;


    // AUFIRAGSPOSITIONEN anlegen ******************************************

    Erx # RecLink(121,120,2,_recFirst); // Stückliste loopen
    WHILE (Erx<=_rLocked) and (vAnz>=0) do begin

      RecLink(250,121,2,_recFirst);   // Artikel holen

if (Prj.SL.Menge<0.0) then begin
      RecBufClear(403);
      Auf.Z.Nummer          # Auf.Nummer;
      Auf.Z.Position        # 0;
      "Auf.Z.Schlüssel"     # '';
      Auf.Z.Bezeichnung     # Prj.SL.VpgText1;
      Auf.Z.Menge           # Prj.SL.Menge;
      Auf.Z.MEH             # Prj.SL.MEH;
      Auf.Z.PEH             # 1;
      Auf.Z.SichtbarYN      # y;
      Auf.Z.Vpg.OKYN        # y;
      Auf.Z.FormelFunktion  # '';
      Auf.Z.Vpg.Artikelnr   # Prj.SL.ArtikelNr;

      if (Art_P_Data:FindePreis('VK', Adr.Nummer, 1.0, '', 1)) then begin
        Auf.Z.MEH        # Art.P.MEH;
        Auf.Z.PEH        # Art.P.PEH;
        Auf.Z.Preis       # Art.P.PreisW1;
      end
      else begin
debugx('preisfail bei '+Art.Nummer+' '+aint(Adr.Nummer));
        vAnz # -397;
        BREAK;
      end;

      Auf.Z.Warengruppe     # Art.Warengruppe;
      Auf.Z.Anlage.Datum  # today;
      Auf.Z.Anlage.Zeit   # Now;
      Auf.Z.Anlage.User   # gUserName;
      Auf.Z.lfdNr         # 0;
      REPEAT
        Auf.Z.lfdNr       # Auf.Z.lfdNr + 1;
        Erx # RekInsert(403,0,'AUTO');
      UNTIL (Erx=_rOK);
      Erx # RecLink(121,120,2,_recNext);
      CYCLE;
end;

      RecBufClear(401);
      Auf.P.Kundennr      # Auf.Kundennr;
      Auf.P.KundenSW      # Auf.KundenStichwort;
      Auf.P.MEH.Preis     # Art.MEH;
      Auf.P.PEH           # Art.PEH;
      Auf.P.MEH.Wunsch    # Auf.P.MEH.Preis;
      Auf.P.Warengruppe   # Art.Warengruppe;
      Auf.P.Termin1Wunsch # vWartDat;
      RecLink(819,401,1,_RecFirst);   // Warengruppe holen
      Auf.P.Wgr.Dateinr   # Wgr.Dateinummer;
      if ("Art.ChargenführungYN") then Auf.P.Wgr.Dateinr # Wgr_Data:WennArtDannCharge(Auf.P.Wgr.Dateinr);
      Auf.P.ArtikelTyp    # Art.Typ;

      Auf.P.Auftragsart   # 1; // ?????????????????????
      Auf.P.Termin1W.Art  # 'DA';
      Auf.P.Best.Nummer   # Auf.Best.Nummer;
      Auf.P.Nummer        # Auf.Nummer;
      Auf.P.Projektnummer # Prj.Nummer;

      Auf.P.ArtikelNr     # Prj.SL.Artikelnr;
      Auf.P.Bemerkung     # Prj.SL.Bemerkung;
      Auf.P.ArtikelSW     # Art.Stichwort;
      Auf.P.Sachnummer    # Art.Sachnummer;
      Auf.P.Menge.Wunsch  # Prj.SL.Menge;
      Auf.P.MEH.Einsatz   # Art.MEH;
      Auf.P.MEH.Wunsch    # Art.MEH;
      Auf.P.Menge         # Prj.SL.Menge;
      "Auf.P.Stückzahl"   # "Prj.SL.Stückzahl";
      Auf.P.Gewicht       # Prj.SL.Gewicht;
      Auf.P.PEH           # Art.PEH;
      Auf.P.MEH.Preis     # Art.MEH;

      /* Positionstext */
      vName   # '~401.' + CnvAI( Auf.P.Nummer, _fmtNumLeadZero | _fmtNumNoGroup, 0, 8 ) + '.' + CnvAI( vPos, _fmtNumLeadZero | _fmtNumNoGroup, 0, 3 );
      vTxtHdl # TextOpen( 32 );
      vI      # 1;
      if ( Prj.SL.VpgText1 != '' ) then begin
        vTxtHdl->TextLineWrite( vI, Prj.SL.VpgText1, _textLineInsert );
        vI # vI + 1;
      end;
      if ( Prj.SL.VpgText2 != '' ) then begin
        vTxtHdl->TextLineWrite( vI, Prj.SL.VpgText2, _textLineInsert );
        vI # vI + 1;
      end;
      if ( Prj.SL.VpgText3 != '' ) then begin
        vTxtHdl->TextLineWrite( vI, Prj.SL.VpgText3, _textLineInsert );
        vI # vI + 1;
      end;
      if ( Prj.SL.VpgText4 != '' ) then begin
        vTxtHdl->TextLineWrite( vI, Prj.SL.VpgText4, _textLineInsert );
        vI # vI + 1;
      end;
      if ( Prj.SL.VpgText5 != '' ) then begin
        vTxtHdl->TextLineWrite( vI, Prj.SL.VpgText5, _textLineInsert );
        vI # vI + 1;
      end;
      if ( ( TextInfo( vTxtHdl, _textSize ) + TextInfo( vTxtHdl, _textLines ) ) = 0 ) then
        TxtDelete( vName, 0 );
      else begin
        TxtWrite( vTxtHdl, vName, _textUnlock );
        Auf.P.TextNr1 # 401;
        Auf.P.TextNr2 # 0;
      end;


      if (Art_P_Data:FindePreis('VK', Adr.Nummer, 1.0, '', 1)) then begin
        Auf.P.MEH.Preis      # Art.P.MEH;
        Auf.P.PEH            # Art.P.PEH;
        Auf.P.Grundpreis     # Art.P.PreisW1;
      end
      else begin
debugx('preisfail bei '+Art.Nummer+' '+aint(Adr.Nummer));
        vAnz # -289;
        BREAK;
      end;

      Auf.P.Prd.Rest      # Auf.P.Menge - Auf.P.Prd.LFS;
      Auf.P.Prd.Rest.Stk  # "Auf.P.Stückzahl" - Auf.P.Prd.LFS.Stk;
      if (Auf.P.Prd.Rest<0.0) then Auf.P.Prd.Rest # 0.0;
      if (Auf.P.Prd.Rest.Stk<0) then Auf.P.Prd.Rest.Stk # 0;

      "Auf.P.GesamtwertEKW1"  # 0.0;
      if (Art_P_Data:FindePreis('L-EK', 0, 1.0, '', 1)=false) then
        if (Art_P_Data:FindePreis('Ø-EK', 0, 1.0, '', 1)=false) then
          Art_P_Data:FindePreis('EK', 0, 1.0, '', 1);

      Art_Data:BerechneFelder(var "Auf.P.Stückzahl", var Auf.P.Gewicht, var vX, Art.P.MEH);

      if (Art.P.PEH<>0) then
        "Auf.P.GesamtwertEKW1"  # Art.P.PreisW1 * vX / cnvfi(Art.P.PEH);


      Auf.P.Position    # vPos;
      Auf.P.Best.Nummer # cnvai(Auf.P.Position,_FmtNumLeadZero,0,2);

      Erx # Auf_Data:PosInsert(0,'AUTO');
      if (erx<>_rOK) then begin
        vAnz # -302;
        BREAK;
      end;
      RecRead(401,1,_recLock);
      Auf.P.Gesamtpreis # Auf_data:SumGesamtpreis(Auf.P.Menge, "Auf.P.Stückzahl" , Auf.P.Gewicht);
      Auf_Data:PosReplace(_recUnlock,'AUTO');

/******
      // Auftrag reservieren ***********************************************
      if (Auf.P.Wgr.Dateinr>=250) and (Auf.P.Wgr.Dateinr<=259) and (Auf.Vorgangstyp=cAUF) and
        (Auf.AbrufYN=n) then begin

        RecLink(250,401,2,_RecFirst);   // Artikel holen

        RecBufClear(252);
        Art.C.ArtikelNr     # Auf.P.ArtikelNr;
        Art.C.Dicke         # Auf.P.Dicke;
        Art.C.Breite        # Auf.P.Breite;
        "Art.C.Länge"       # "Auf.P.Länge";
        Art.C.RID           # Auf.P.RID;
        Art.C.RAD           # Auf.P.RAD;
        Art_Data:Auftrag(Auf.P.Menge);
        if (Auf.P.ArtikelTyp=c_art_PRD) then begin
          Erx # RecLink(409,401,15,_recFirst);
          WHILE (Erx<=_rLocked) do begin
            RecBufClear(252);
            Art.C.ArtikelNr     # Auf.SL.ArtikelNr;
            Art.C.Dicke         # Auf.SL.Dicke;
            Art.C.Breite        # Auf.SL.Breite;
            "Art.C.Länge"       # "Auf.SL.Länge";
            Art.C.RID           # Auf.P.RID;
            Art.C.RAD           # Auf.P.RAD;
            Art_Data:Auftrag(Auf.SL.Menge);
            Erx # RecLink(409,401,15,_recNext);
          END;
        end;

        // sofort MATZ/Reservierungen anlegen
        if (Auf.P.Wgr.DateiNr=250) then begin
          RecLink(250,401,2,_RecFirst);   // Artikel holen
          if (Art.Typ=c_art_HDL) then
            Auf_Data:MatzArt(n,n,Auf.P.Menge - Auf.P.Prd.VSB - Auf.P.Prd.VSAuf - Auf.P.Prd.LFS);
        end;
      end;
*****/


//debug('Pos '+cnvai(vPos)+' anlegen');
      vPos # vPos + 1;


      if (Auf.P.Menge<=0.0) then begin
        vAnz # -519;
        Error(99,'Keine Menge in der Projektstückliste '+aint(Prj.Nummer));
      end;

      // DEFAKT
      if (Auf_Data_Buchen:DFaktArtC(Art.Nummer,0,0,'',n, Auf.P.Menge, "Auf.P.Stückzahl", Auf.P.Menge, vWartDat)=false) then begin
        vAnz # -351;
        BREAK;
      end;

      Erx # RecLink(121,120,2,_recNext);
    END;

    if (vAnz<0) then BREAK;



    // Datum im Wartung vermerken ******************************************
    RecRead(120,1,_recLock);
    Prj.Wtg.LetztesDatum # vStichtag;//today;
    Erx # RekReplace(120,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      vAnz # -318;
      BREAK;
    end;

    vErg # RecRead(120,vSel,_Recnext);
  END;

  if (vProgress>0) then vProgress->Lib_Progress:Term();


  if (vAnz<0) then begin
    TRANSBRK;
    ErrorOutPut;
  end
  else begin
    TRANSOFF;
  end;

  SelClose(vSel);
  SelDelete(120,vSelName);

  RETURN vAnz;
end;



//=========================================================================
// Austauschprojekt Subprozeduren [21.01.2010/PW]
//=========================================================================

//=========================================================================
// ProjektExport
//        Export von Austauschprojekt und zugehörigen Projektpunkten
//=========================================================================
sub ProjektExport ()
local begin
  Erx     : int;
  vFile  : alpha(255);
  vDoc   : handle;
  vPrj   : handle;
  vPos   : handle;
  vNode  : handle;

  vText  : int;
  vLines : int;
  vI     : int;
  vLine  : alpha(250);

  vNumPos : int; // Anzahl exportierter Positionen
  vNumUpd : int; // Anzahl exportierter Positionsinformationen
end
begin
  // Projekt lesen
  Erx # RecRead( 120, 1, 0 );
  if ( Erx > _rLocked ) then
    RETURN;

  // Austauschmarkierung setzen
  if ( !Prj.AustauschYN ) then begin
    RecRead( 120, 1, _recLock )
    Prj.AustauschYN # true;
    RekReplace( 120,_recUnlock, 'MAN' );
  end;

  /* Dateiauswahl */
  vFile # Lib_FileIO:FileIO( _winComFileSave, gMDI, '', 'XML Dateien|*.xml' );
  if ( vFile = '' ) then
    RETURN;

  if ( StrCnv( StrCut( vFile, StrLen( vFile ) - 3, 4 ), _strLower ) != '.xml' ) then
    vFile # vFile + '.xml'

  /* XML Initialisierung */
  vDoc       # CteOpen( _cteNode );
  vDoc->spId # _xmlNodeDocument;
  vDoc->CteInsertNode( '', _xmlNodeComment, ' Stahl Control 2010 - Austauschprojekt ' );

  /* Projektdaten */
  vPrj # vDoc->Lib_XML:AppendNode( 'austauschprojekt' );
  vPrj->Lib_XML:AppendAttributeNode( 'version', cAPVersion );
  vPrj->Lib_XML:AppendAttributeNode( 'num', CnvInt( Prj.Nummer ) );

  if ( Prj.AustauschPrjNr != 0 ) then begin
    vPrj->Lib_XML:AppendAttributeNode( 'id', CnvInt( getTimestamp( Prj.Anlage.Datum, Prj.Anlage.Zeit ) ) );
    vPrj->Lib_XML:AppendAttributeNode( 'ref', CnvInt( Prj.AustauschPrjNr ) );
  end;

  vNode # vPrj->Lib_XML:AppendNode( 'daten' );
  vNode->Lib_XML:AppendAttributeNode( 'stichwort', Prj.Stichwort );
  vNode->Lib_XML:AppendAttributeNode( 'priorität', CnvInt( "Prj.Priorität" ) );

  if ( Prj.Termin.Start != 0.0.0 ) or ( Prj.Termin.Ende != 0.0.0 ) then begin
    vNode # vPrj->Lib_XML:AppendNode( 'zeitraum' );
    vNode->Lib_XML:AppendAttributeNode( 'von', CnvAD( Prj.Termin.Start, _fmtInternal ) );
    vNode->Lib_XML:AppendAttributeNode( 'bis', CnvAD( Prj.Termin.Ende, _fmtInternal ) );
  end;

  /* Projektpositionen */
  vPrj->CteInsertNode( '', _xmlNodeComment, ' Projektpositionen ' );
  FOR  Erx # RecLink( 122, 120, 4, _recFirst );
  LOOP Erx # RecLink( 122, 120, 4, _recNext );
  WHILE ( Erx <= _rLocked ) DO BEGIN
    // TODO Austauschprojekte können Unter-Austauschprojekte haben, die den
    //   gesamten Bereich bekommen müssen; dabei dann auch cAPPosMark dynamisch
    //   anpassen, da jedes Austauschprojekt einen eigenen Positionsnummern-
    //   bereich haben muss. Dieser Bereich wird beim Export auch in
    //   Unterprojekte exportiert und dient beim Import als Zielbereich.
    if ( Prj.AustauschPrjNr != 0 ) then begin // Austauschprojekt
      if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then
        CYCLE;

      // Bei Originaldatensätzen nur Kundeninformationstext berücksichtigen
      if ( Prj.P.Position < cAPPosMark ) then begin
        vPos # vPrj->Lib_XML:AppendNode( 'positionsinfo' );
        vPos->Lib_XML:AppendAttributeNode( 'pos', CnvInt( Prj.P.Position ) );

        // Interne Information
        vText  # TextOpen( 32 );
        Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2', Prj.P.SubPosition), vText, 0, 0, 0, 0 );
        vLines # vText->TextInfo( _textLines );

        FOR  vI # 1;
        LOOP vI # vI + 1;
        WHILE ( vI <= vLines ) DO BEGIN
          vLine # vText->TextLineRead( vI, 0 );
          vLine  # Str_ReplaceAll( vLine, StrChar(31), '' );
          vNode # vPos->Lib_XML:AppendNode( 'line', vLine );
          vNode->Lib_XML:AppendAttributeNode( 'lf', CnvInt( vText->TextInfo( _textNoLineFeed ) ) );
        END;
        vText->TextClose();

        vNumUpd # vNumUpd + 1;
        CYCLE;
      end
    end;

    vNumPos # vNumPos + 1;
    vPos # vPrj->Lib_XML:AppendNode( 'position' );
    vPos->Lib_XML:AppendAttributeNode( 'pos', CnvInt( Prj.P.Position ) );

    if ( Prj.P.AustauschId != 0 ) then begin
      vPos->Lib_XML:AppendAttributeNode( 'refid',  CnvInt( Prj.P.AustauschId ) );
      vPos->Lib_XML:AppendAttributeNode( 'refpos', CnvInt( Prj.P.AustauschPos ) );
    end;

    vNode # vPos->Lib_XML:AppendNode( 'daten' );
    vNode->Lib_XML:AppendAttributeNode( 'priorität', CnvInt( "Prj.P.Priorität" ) );
    vNode->Lib_XML:AppendAttributeNode( 'status', CnvInt( Prj.P.Status ) );
    vNode->Lib_XML:AppendAttributeNode( 'wiedervorlage', Prj.P.WiedervorlUser );

    vNode # vPos->Lib_XML:AppendNode( 'dauer' );
    vNode->Lib_XML:AppendAttributeNode( 'angebot', CnvAF( Prj.P.Dauer.Angebot, _fmtInternal ) );
    vNode->Lib_XML:AppendAttributeNode( 'extern', CnvAF( Prj.P.Dauer.Extern, _fmtInternal ) );

    if ( Prj.P.Datum.Start != 0.0.0 ) and ( Prj.P.Datum.Ende != 0.0.0 ) then begin
      vNode # vPos->Lib_XML:AppendNode( 'zeitraum' );
      vNode->Lib_XML:AppendAttributeNode( 'von', CnvAD( Prj.P.Datum.Start, _fmtInternal ) );
      vNode->Lib_XML:AppendAttributeNode( 'bis', CnvAD( Prj.P.Datum.Ende, _fmtInternal ) );
    end;

    if ( Prj.P.zuProjekt != 0 ) or ( Prj.P.ReferenzNr != '' ) then begin
      vNode # vPos->Lib_XML:AppendNode( 'referenz', Prj.P.Referenznr );
      if ( Prj.P.zuProjekt != 0 ) then begin
        vNode->Lib_XML:AppendAttributeNode( 'nummer', CnvInt( Prj.P.zuProjekt ) );
        vNode->Lib_XML:AppendAttributeNode( 'position', CnvInt( Prj.P.zuPosition ) );
      end;
    end;

    vNode # vPos->Lib_XML:AppendNode( 'text' );
    vNode->Lib_XML:AppendAttributeNode( 'bezeichnung', Prj.P.Bezeichnung );

    // Positionstext
    vText # TextOpen( 32 );
    Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' ), vText, 0, 0, 0, 0 );
    vLines # vText->TextInfo( _textLines );

    FOR  vI # 1;
    LOOP vI # vI + 1;
    WHILE ( vI <= vLines ) DO BEGIN
      vLine  # vText->TextLineRead( vI, 0 );
      vLine  # Str_ReplaceAll( vLine, StrChar(31), '' );
      Lib_XML:AppendAttributeNode( vNode->Lib_XML:AppendNode( 'line', vLine ), 'lf', CnvAI( vText->TextInfo( _textNoLineFeed ) ) );
    END;
    vText->TextClose();

    vNode # vPos->Lib_XML:AppendNode( 'anlage' );
    vNode->Lib_XML:AppendAttributeNode( 'datum', CnvAD( Prj.P.Anlage.Datum, _fmtInternal ) );
    vNode->Lib_XML:AppendAttributeNode( 'zeit', CnvAT( Prj.P.Anlage.Zeit ) );
    vNode->Lib_XML:AppendAttributeNode( 'user', Prj.P.Anlage.User );

    if ( "Prj.P.Lösch.Datum" != 0.0.0 ) then begin
      vNode # vPos->Lib_XML:AppendNode( 'loeschdaten', "Prj.P.Lösch.Grund" );
      vNode->Lib_XML:AppendAttributeNode( 'datum', CnvAD( "Prj.P.Lösch.Datum", _fmtInternal ) );
      vNode->Lib_XML:AppendAttributeNode( 'user', "Prj.P.Lösch.User" );
    end;
  END;

  /* XML Abschluss */
  // ST 2011-08-16: Umstellung auf UTF8 Export
  // vDoc->XmlSave( vFile, _xmlSaveDefault );
  vDoc->XmlSave(vFile,_XmlSaveDefault,0, _CharsetUTF8);

  vDoc->CteClear( true );
  vDoc->CteClose();

  if ( Prj.AustauschPrjNr = 0 ) then
    Msg( 120100, vFile + '|' + CnvAI( vNumPos ), 0, 0, 0 );
  else
    Msg( 120101, vFile + '|' + CnvAI( vNumPos + vNumUpd ) + '|' + CnvAI( vNumPos ), 0, 0, 0 );
end;


//=========================================================================
// ProjektImport_LoadPosition
//        Positionsnode parsen und Buffer füllen
//=========================================================================
sub ProjektImport_LoadPosition ( vPos : handle )
local begin
  vNode : handle;
  vLine : handle;
  vText : int;
  vI    : int;
end;
begin
  Prj.P.AustauschId  # CnvIA( vPos->Lib_XML:GetAttributeValue( 'refid' ) );
  Prj.P.AustauschPos # CnvIA( vPos->Lib_XML:GetAttributeValue( 'refpos' ) );

  vNode # vPos->Lib_XML:GetChildNode( 'daten' );
  "Prj.P.Priorität"    # CnvIA( vNode->Lib_XML:GetAttributeValue( 'priorität' ) );
  Prj.P.Status         # CnvIA( vNode->Lib_XML:GetAttributeValue( 'status' ) );
  Prj.P.WiedervorlUser # vNode->Lib_XML:GetAttributeValue( 'wiedervorlage' );

  vNode # vPos->Lib_XML:GetChildNode( 'dauer' );
  Prj.P.Dauer.Angebot  # CnvFA( vNode->Lib_XML:GetAttributeValue( 'angebot' ) );
  Prj.P.Dauer.Extern   # CnvFA( vNode->Lib_XML:GetAttributeValue( 'extern' ) );

  vNode                # vPos->Lib_XML:GetChildNode( 'zeitraum' );
  if ( vNode != 0 ) then begin
    Prj.P.Datum.Start  # CnvDA( vNode->Lib_XML:GetAttributeValue( 'von' ) );
    Prj.P.Datum.Ende   # CnvDA( vNode->Lib_XML:GetAttributeValue( 'bis' ) );
  end
  else begin
    Prj.P.Datum.Start  # 0.0.0;
    Prj.P.Datum.Ende   # 0.0.0;
  end;

  vNode                # vPos->Lib_XML:GetChildNode( 'referenz' );
  if ( vNode != 0 ) then begin
    Prj.P.Referenznr   # vNode->Lib_XML:GetTextValue();
    Prj.P.zuProjekt    # CnvIA( vNode->Lib_XML:GetAttributeValue( 'nummer' ) );
    Prj.P.zuPosition   # CnvIA( vNode->Lib_XML:GetAttributeValue( 'position' ) );
  end
  else begin
    Prj.P.Referenznr   # '';
    Prj.P.zuProjekt    # 0;
    Prj.P.zuPosition   # 0;
  end;

  vNode                # vPos->Lib_XML:GetChildNode( 'text' );
  Prj.P.Bezeichnung    # vNode->Lib_XML:GetAttributeValue( 'bezeichnung' );

  // Positionstext
  vText # TextOpen( 32 );
  FOR  begin vLine # vNode->CteRead( _cteChildList | _cteFirst );       vI # 1;      end;
  LOOP begin vLine # vNode->CteRead( _cteChildList | _cteNext, vLine ); vI # vI + 1; end;
  WHILE ( vLine != 0 ) DO BEGIN
    vText->TextLineWrite( vI, vLine->Lib_XML:GetTextValue(), _textLineInsert | ( _textNoLineFeed * CnvIA( vLine->Lib_XML:GetAttributeValue( 'lf' ) ) ) );
  END;
  Lib_Texte:TxtSave5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1', Prj.P.SubPosition ), vText, 0, 0, 0, 0 );
  vText->TextClose();

  // Anlage- & Löschinformationen
  vNode                # vPos->Lib_XML:GetChildNode( 'anlage' );
  if ( vNode != 0 ) then begin
    Prj.P.Anlage.Datum   # CnvDA( vNode->Lib_XML:GetAttributeValue( 'datum' ) );
    Prj.P.Anlage.Zeit    # CnvTA( vNode->Lib_XML:GetAttributeValue( 'zeit' ) );
    Prj.P.Anlage.User    # vNode->Lib_XML:GetAttributeValue( 'user' );
  end;

  vNode                # vPos->Lib_XML:GetChildNode( 'loeschdaten' );
  if ( vNode != 0 ) then begin
    "Prj.P.Lösch.Datum"  # CnvDA( vNode->Lib_XML:GetAttributeValue( 'datum' ) );
    "Prj.P.Lösch.User"   # vNode->Lib_XML:GetAttributeValue( 'user' );
    "Prj.P.Lösch.Grund"  # vNode->Lib_XML:GetTextValue();
  end;
end;

//=========================================================================
// ProjektImport
//        Import von Austauschprojekt und zugehörigen Projektpunkten
//=========================================================================
sub ProjektImport ()
local begin
  Erx     : int;
  vFile   : alpha(255);
  vDoc    : handle;
  vPrj    : handle;
  vPos    : handle;
  vNode   : handle;

  vList   : handle;
  vText   : handle;
  vI      : int;

  vPrjNum : int;
  vPrjPos : int;
  vPrjId  : int;
  vPrjRef : int;

  vNumPos : int; // Anzahl neu angelegter Positionen
  vNumUpd : int; // Anzahl aktualisierter Positionen
end
begin
  /* Dateiauswahl */
  vFile # Lib_FileIO:FileIO( _winComFileOpen, gMDI, '', 'XML Dateien|*.xml' );
  if ( vFile = '' ) then
    RETURN;

  /* XML Initialisierung */
  vDoc # CteOpen( _cteNode );
  if ( vDoc->XmlLoad( vFile ) != _errOk ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();

    Msg( 120102, ' (' + XmlError( _xmlErrorText ) + ')', 0, 0, 0 );
    RETURN;
  end;

  vPrj # vDoc->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'austauschprojekt' );
  if ( vPrj = 0 ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();

    Msg( 120102, '', 0, 0, 0 );
    RETURN;
  end;

  // Dateiversion
  if ( vPrj->Lib_XML:GetAttributeValue( 'version' ) < cAPVersion ) then begin
    vDoc->CteClear( true );
    vDoc->CteClose();

    Msg( 120109, '', 0, 0, 0 );
    RETURN;
  end;

  /* Projekt */
  vPrjNum # CnvIA( vPrj->Lib_XML:GetAttributeValue( 'num' ) );
  vPrjId  # CnvIA( vPrj->Lib_XML:GetAttributeValue( 'id' ) );
  vPrjRef # CnvIA( vPrj->Lib_XML:GetAttributeValue( 'ref' ) );

  // Referenzprojekt suchen
  Prj.Nummer # vPrjRef;
  if ( Prj.Nummer != 0 ) and ( RecRead( 120, 1, 0 ) <= _rLocked ) then begin // Referenzprojekt existiert
    if ( !Prj.AustauschYN ) or ( Prj.AustauschPrjNr != 0 ) then begin
      vDoc->CteClear( true );
      vDoc->CteClose();

      Msg( 120107, CnvAI( Prj.Nummer ), 0, 0, 0 );
      RETURN;
    end;

    /* Projektpositionen erstellen */
    TRANSON;
    FOR  vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'position' );
    LOOP vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteNext, vPos, 'position' );
    WHILE ( vPos != 0 ) DO BEGIN
      if ( vPos->spId != _xmlNodeElement ) then
        CYCLE;

      vPrjPos # CnvIA( vPos->Lib_XML:GetAttributeValue( 'pos' ) );
      if ( vPrjPos <= cAPPosMark ) then
        CYCLE;

      // Position überspringen, falls bereits importiert
      FOR  Erx # RecLink( 122, 120, 4, _recFirst );
      LOOP Erx # RecLink( 122, 120, 4, _recNext );
      WHILE ( Erx <= _rLocked ) DO BEGIN
        if ( Prj.P.AustauschID = vPrjId ) and ( Prj.P.AustauschPos = vPrjPos ) then
          BREAK;
        // TODO Statt Abbruch, Update, falls Werte aktualisiert wurden?
      END;
      if ( Erx <= _rLocked ) then
        CYCLE;

      // neue Projektposition ermitteln
      if ( RecLink( 122, 120, 4, _recLast ) > _rLocked ) then
        vI # 1;
      else
        vI # Prj.P.Position + 1;
      RecBufClear( 122 );

      Prj.P.Nummer       # vPrjRef;
      Prj.P.Position     # vI;
      ProjektImport_LoadPosition( vPos );
      Prj.P.AustauschId  # vPrjId;
      Prj.P.AustauschPos # vPrjPos;

      Erx # RekInsert( 122, 0, 'MAN' );
      if ( Erx != _rOk ) then begin
        TRANSBRK;
        vDoc->CteClear( true );
        vDoc->CteClose();

        Msg( 001000 + Erx, 'Projektimport (Position ' + CnvAI( vPrjPos ) + ')', 0, 0, 0 );
        RETURN;
      end;

      vNumPos # vNumPos + 1;
      Lib_Mark:MarkAdd( 122, true, true );
    END;

    /* Projektinformationen hinzufügen */
    FOR  vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'positionsinfo' );
    LOOP vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteNext, vPos, 'positionsinfo' );
    WHILE ( vPos != 0 ) DO BEGIN
      if ( vPos->spId != _xmlNodeElement ) or ( vPos->spChildCount = 0 ) then
        CYCLE;

      Prj.P.Nummer   # vPrjRef;
      Prj.P.Position # CnvIA( vPos->Lib_XML:GetAttributeValue( 'pos' ) );
      if ( RecRead( 122, 1, 0 ) > _rLocked ) then
        CYCLE;

      vPrjPos # CnvIA( vPos->Lib_XML:GetAttributeValue( 'pos' ) );
      vText   # TextOpen( 32 );
      Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, vPrjRef, vPrjPos, '1' ), vText, 0, 0, 0, 0 );

      vI # vText->TextInfo( _textLines );
      vText->TextLineWrite( vI + 1, '', _textLineInsert );
      vText->TextLineWrite( vI + 2, 'AP-Kundenupdate vom ' + CnvAD( today ) + ':', _textLineInsert );
      vI # vI + 3;

      FOR  vNode # vPos->CteRead( _cteChildList | _cteFirst );
      LOOP vNode # vPos->CteRead( _cteChildList | _cteNext, vNode );
      WHILE ( vNode != 0 ) DO BEGIN
        vText->TextLineWrite( vI, vNode->Lib_XML:GetTextValue(), _textLineInsert | ( _textNoLineFeed * CnvIA( vNode->Lib_XML:GetAttributeValue( 'lf' ) ) ) );
        vI # vI + 1;
      END;
      Lib_Texte:TxtSave5Buf( Lib_Texte:GetTextName( 122, vPrjRef, vPrjPos, '1' ), vText, 0, 0, 0, 0 );
      vText->TextClose();

      vNumUpd # vNumUpd + 1;
      Lib_Mark:MarkAdd( 122, true, true );
    END;
    TRANSOFF;

    /* XML Abschluss */
    vDoc->CteClear( true );
    vDoc->CteClose();

    Msg( 120108, CnvAI( vPrjRef ) + '|' + CnvAI( vNumPos ) + '|' + CnvAI( vNumUpd ), 0, 0, 0 );
    RETURN;
  end;

  // Referenzprojekt exisiert nicht, oder ist anderweitig inkompatibel mit der Austauschdatei
  if ( vPrjRef != 0 ) then begin
    if ( Msg( 120110, '', 0, 0, 0 ) != _winIdYes ) then begin
      vDoc->CteClear( true );
      vDoc->CteClose();
      RETURN;
    end;
  end;

  /* Austauschprojekt erstellen / aktualisieren */
  vPrjRef # 0;
  Prj.AustauschPrjNr # vPrjNum;
  Erx # RecRead( 120, 5, 0 );

  if ( Erx <= _rMultiKey ) then begin // mindestens ein Austauschprojekt ist vorhanden
    vList # CteOpen( _cteList );
    vList->Lib_Ramsort:Add( 'Neues Austauschprojekt anlegen', 0 );
    FOR  Erx # RecRead( 120, 5, 0 );
    LOOP Erx # RecRead( 120, 5, _recNext );
    WHILE ( Erx <= _rMultiKey ) and ( Prj.AustauschPrjNr = vPrjNum ) DO BEGIN
      vList->Lib_Ramsort:Add( CnvAI( Prj.Nummer ) + ': ' + Prj.Stichwort, RecInfo( 120, _recId ) );
    END;

    // Auswahl
    vI # vList->Lib_Ramsort:GetByIndex( Dlg_Standard:Auswahl( vList, 0, 'Bitte wählen Sie das Zielprojekt...' ) );
    if ( vI <= 0 ) then begin
      vList->CteClear( true );
      vList->CteClose();

      vDoc->CteClear( true );
      vDoc->CteClose();
      RETURN;
    end

    if ( vI->spId != 0 ) then begin
      RecRead( 120, 0, _recId, vI->spId );
      vPrjRef # Prj.Nummer;
    end;

    vList->CteClear( true );
    vList->CteClose();
  end;

  if ( vPrjRef = 0 ) then begin // neues Austauschprojekt anlegen
    // Projektnummer ermitteln
    Prj.Nummer # Lib_Nummern:ReadNummer( 'Projekt' );
    if ( Prj.Nummer != 0 ) then begin
      vPrjRef # 0;
      Dlg_Standard:Anzahl( 'Neue Projektnummer', var vPrjRef, Prj.Nummer );
      if ( vPrjRef = Prj.Nummer ) then
        Lib_Nummern:SaveNummer();
      else
        Lib_Nummern:FreeNummer();
    end
    else
      Dlg_Standard:Anzahl( 'Neue Projektnummer', var vPrjRef, 0 );

    if ( vPrjRef = 0 ) then begin
      vDoc->CteClear( true );
      vDoc->CteClose();
      RETURN;
    end;

    Prj.Nummer # vPrjRef;
    if ( RecRead( 120, 1, 0 ) <= _rLocked ) then begin
      vDoc->CteClear( true );
      vDoc->CteClose();

      Msg( 120103, CnvAI( vPrjRef ), 0, 0, 0 );
      RETURN;
    end;

    /* Projekt anlegen */
    RecBufClear( 120 );
    Prj.Nummer         # vPrjRef; // ermittelte Projektnummer
    Prj.AustauschPrjNr # vPrjNum; // Referenzprojekt

    // Projektdaten
    vNode # vPrj->Lib_XML:GetChildNode( 'daten' );
    Prj.Stichwort       # vNode->Lib_XML:GetAttributeValue( 'stichwort' );
    "Prj.Priorität"     # CnvIA( vNode->Lib_XML:GetAttributeValue( 'priorität' ) );

    // Zeitraum
    vNode               # vPrj->Lib_XML:GetChildNode( 'zeitraum' );
    if ( vNode != 0 ) then begin
      Prj.Termin.Start  # CnvDA( vNode->Lib_XML:GetAttributeValue( 'von' ) );
      Prj.Termin.Ende   # CnvDA( vNode->Lib_XML:GetAttributeValue( 'bis' ) );
    end
    else begin
      Prj.Termin.Start  # 0.0.0;
      Prj.Termin.Ende   # 0.0.0;
    end;

    // Anlageinformationen
    Prj.Anlage.Datum    # today;
    Prj.Anlage.Zeit     # now;
    Prj.Anlage.User     # gUsername;

    /* Daten speichern */
    TRANSON;
    Erx # RekInsert( 120, 0, 'MAN' );
    if ( Erx != _rOk ) then begin
      TRANSBRK;
      vDoc->CteClear( true );
      vDoc->CteClose();

      Msg( 001000 + Erx, 'Projektimport', 0, 0, 0 );
      RETURN;
    end;

    // Projektposition cAPPosMark als Markierung anlegen
    RecBufClear( 122 );
    Prj.P.Nummer         # vPrjRef;
    Prj.P.Position       # cAPPosMark;
    Prj.P.Bezeichnung    # 'Austauschprojekt';
    Prj.P.WiedervorlUser # gUsername;
    Prj.P.Anlage.Datum   # today;
    Prj.P.Anlage.Zeit    # now;
    Prj.P.Anlage.User    # Prj.Anlage.User;
    "Prj.P.Lösch.Datum"  # today;
    "Prj.P.Lösch.User"   # gUsername;
    "Prj.P.Lösch.Grund"  # 'Austauschprojektmarkierung';
    RekInsert( 122, 0, 'MAN' );

    TRANSOFF;
    vNumUpd # -1; // als neues Projekt markieren
  end;

  /* Projektpositionen */
  TRANSON;
  FOR  vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteFirst, 0, 'position' );
  LOOP vPos # vPrj->CteRead( _cteChildList | _cteSearch | _cteNext, vPos, 'position' );
  WHILE ( vPos != 0 ) DO BEGIN
    if ( vPos->spId != _xmlNodeElement ) then
      CYCLE;

    vPrjPos # CnvIA( vPos->Lib_XML:GetAttributeValue( 'pos' ) );
    RecBufClear( 122 );
    Prj.P.Nummer   # vPrjRef;
    Prj.P.Position # vPrjPos;

    if ( RecRead( 122, 1, _recTest ) > _rLocked ) then begin
      vPos->ProjektImport_LoadPosition();
      Erx # RekInsert( 122, 0, 'MAN' );
      Lib_Mark:MarkAdd( 122, true, true );

      if ( Erx != _rOk ) then begin
        TRANSBRK;
        vDoc->CteClear( true );
        vDoc->CteClose();

        Msg( 001000 + Erx, 'Projektimport (Position ' + CnvAI( vPrjPos ) + ')', 0, 0, 0 );
        RETURN;
      end;

      // Übernahmemarkierung berücksichtigen
      if ( vNumUpd != -1 ) and ( Prj.P.AustauschId != 0 ) and ( Prj.P.AustauschId = getTimestamp( Prj.Anlage.Datum, Prj.Anlage.Zeit ) ) then begin
        Prj.P.Position # Prj.P.AustauschPos;
        if ( RecRead( 122, 1, _recLock ) = _rOk ) then begin
          "Prj.P.Lösch.Datum" # today;
          "Prj.P.Lösch.User"  # gUsername;
          "Prj.P.Lösch.Grund" # 'AP: In Pos ' + CnvAI( vPrjPos ) + ' übernommen.'
          RekReplace( 122, _recUnlock, 'MAN' );
          vNumUpd # vNumUpd + 1;
        end;
      end;
    end
    else begin // existierende Position aktualisieren
      RecRead( 122, 1, _recLock );
      vPos->ProjektImport_LoadPosition();
      Erx # RekReplace( 122, _recUnlock, 'MAN' );

      if ( Erx != _rOk ) then begin
        TRANSBRK;
        vDoc->CteClear( true );
        vDoc->CteClose();

        Msg( 001000 + Erx, 'Projektimport (Position ' + CnvAI( vPrjPos ) + ')', 0, 0, 0 );
        RETURN;
      end;

      // Interne Info löschen
      TxtDelete( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' ), 0 );
    end;
    vNumPos # vNumPos + 1;
  END;
  TRANSOFF;

  /* XML Abschluss */
  vDoc->CteClear( true );
  vDoc->CteClose();

  if ( vNumUpd = -1 ) then
    Msg( 120104, CnvAI( vPrjRef ) + '|' + CnvAI( vNumPos ), 0, 0, 0 );
  else
    Msg( 120105, CnvAI( vPrjRef ) + '|' + CnvAI( vNumPos ) + '|' + CnvAI( vNumUpd ), 0, 0, 0 );
end;


//=========================================================================
//  CopyVorlage
//
//=========================================================================
sub CopyVorlage(aNr : int);
local begin
  Erx     : int;
  vNr     : int;
  vName   : alpha;
  vName2  : alpha;
end;
begin

  Prj.Nummer # aNr;
  Erx # RecRead(120,1,0);
  if (Erx>_rLockeD) or (Prj.VorlageYN=false) then RETURN;

  if (Msg(120017,aint(aNr),_WinIcoQuestion, _WinDialogYesNo, 2)<>_winidyes) then RETURN;

  APPOFF();

  Prj.Nummer # aNr;
  Erx # RecRead(120,1,0);
  if (Erx>_rLockeD) or (Prj.VorlageYN=false) then begin
    APPON();
    RETURN;
  end;

  TRANSON;

  vNr # Lib_Nummern:ReadNummer('Projekt');
  if (vNr=0) then begin
    TRANSBRK;
    APPON();
    Msg(999999,'1177',0,0,0);
    RETURN;
  end;
  Lib_Nummern:SaveNummer()

  // Stückliste kopieren...
  FOR Erx # RecLink(121,120,2,_RecFirst)
  LOOP Erx # RecLink(121,120,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    Prj.SL.Nummer       # vNr;
    Erx # RekInsert(121);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Msg(001000+Erx,'Stückliste',0,0,0);
      RETURN;
    end;

    Prj.SL.Nummer # aNr;
    RecRead(121,1,0);
  END;


  // Positionen kopieren...
  FOR Erx # RecLink(122,120,4,_RecFirst)
  LOOP Erx # RecLink(122,120,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    Prj.P.Nummer        # vNr;
    Prj.P.Anlage.Datum  # today;
    Prj.P.Anlage.Zeit   # now;
    Prj.P.Anlage.User   # gUsername;
    "Prj.P.Lösch.Datum" # 0.0.0;
    "Prj.P.Lösch.Zeit"  # 0:0;
    "Prj.P.Lösch.User"  # '';
    "Prj.P.Lösch.Grund" # '';

    Erx # RekInsert(122);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Msg(001000+Erx,'Positionen',0,0,0);
      RETURN;
    end;

    vName   # Lib_Texte:GetTextName( 122, aNr, Prj.P.Position, '1', Prj.P.SubPosition);
    vName2  # Lib_Texte:GetTextName( 122, vNr, Prj.P.Position, '1', Prj.P.SubPosition );
    TxtCopy(vName, vName2, 0);
    vName   # Lib_Texte:GetTextName( 122, aNr, Prj.P.Position, '2', Prj.P.SubPosition );
    vName2  # Lib_Texte:GetTextName( 122, vNr, Prj.P.Position, '2', Prj.P.SubPosition );
    TxtCopy(vName, vName2, 0);

    RunAFX('Prj.P.RecSave.Post','');

    Prj.P.Nummer # aNr;
    RecRead(122,1,0);
  END;


  // Zeiten kopieren...
  FOR Erx # RecLink(123,120,5,_RecFirst)
  LOOP Erx # RecLink(123,120,5,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    Prj.Z.Nummer        # vNr;
    Prj.Z.Anlage.Datum  # today;
    Prj.Z.Anlage.Zeit   # now;
    Prj.Z.Anlage.User   # gUsername;
    Erx # RekInsert(123);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      Msg(001000+Erx,'Zeiten',0,0,0);
      RETURN;
    end;

    Prj.Z.Nummer # aNr;
    RecRead(123,1,0);
  END;

  vName   # '~120.'+CnvAI(aNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  vName2  # '~120.'+CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
  TxtCopy(vName, vName2, 0);

  // Porjektkopf anlegen...
  Prj.Nummer        # vNr;
  Prj.VorlageYN     # n;
  Prj.Anlage.Datum  # today;
  Prj.Anlage.Zeit   # now;
  Prj.Anlage.User   # gUsername;
  Erx # RekInsert(120);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    APPON();
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN;
  end;

  TRANSOFF;

  APPON();

  App_Main:refresh();

  Msg(120018,aint(vNr),0,0,0);

end;


//=========================================================================
//=========================================================================