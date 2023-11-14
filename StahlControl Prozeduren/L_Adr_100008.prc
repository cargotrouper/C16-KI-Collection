@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Adr_100001
//                    OHNE E_R_G
//  Info        Alle Adressen ausgeben
//
//
//  05.05.2004  AI  Erstellung der Prozedur
//  15.04.2010  MS  Anpassungen fuer Voelkel und Winkler Prj.
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//  SUB Seitenkopf(aSeite : int)
//  SUB Seitenfuss(aSeite : int)
//  SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  StartList(0,'');  // Liste generieren
end;


//========================================================================
//  Print
//
//========================================================================
Sub Print (aName : alpha);
local begin
  Erx   : int;
  disp : int;
end;
begin

  case aName of
    'Adressen' : begin
      StartLine();
      Write( 1, 'Anrede',                      n, 0);
      Write( 2, ':',                           n, 0);
      Write( 3, "Adr.Anrede",                  n, 0);
      Write( 5, 'AdressNr.',                   n, 0);
      Write( 6, ':',                           n, 0);
      Write( 7, ZahlI("Adr.Nummer"),           n, _LF_INT);
      Write( 9, 'Telefon1',                    n, 0);
      Write(10, ':',                           n, 0);
      Write(11, "Adr.Telefon1",                n, 0);
      EndLine();

      StartLine();
      Write( 1, 'Name',                        n, 0);
      Write( 2, ':',                           n, 0);
      Write( 3, "Adr.Name",                    n, 0);
      Write( 5, 'KundenNr.',                   n, 0);
      Write( 6, ':',                           n, 0);
      Write( 7, ZahlI("Adr.KundenNr"),         n, _LF_INT);
      Write( 9, 'Telefon2',                    n, 0);
      Write(10, ':',                           n, 0);
      Write(11, "Adr.Telefon2",                n, 0);
      EndLine();

      StartLine();
      Write( 1, 'Zusatz',                      n, 0);
      Write( 2, ':',                           n, 0);
      Write( 3, "Adr.Zusatz",                  n, 0);
      Write( 5, 'LieferantenNr.',              n, 0);
      Write( 6, ':',                           n, 0);
      Write( 7, ZahlI("Adr.LieferantenNr"),    n, _LF_INT);
      Write( 9, 'Telefax',                     n, 0);
      Write(10, ':',                           n, 0);
      Write(11, "Adr.Telefax",                 n, 0);
      EndLine();

      StartLine();
      Write( 1, 'Straße',                      n, 0);
      Write( 2, ':',                           n, 0);
      Write( 3, "Adr.Straße",                  n, 0);
      Write( 5, 'Stichwort',                   n, 0);
      Write( 6, ':',                           n, 0);
      Write( 7, "Adr.Stichwort",               n, 0);
      Write( 9, 'E-Mail',                      n, 0);
      Write(10, ':',                           n, 0);
      Write(11, "Adr.eMail",                   n, 0);
      EndLine();

      StartLine();
      disp # 0;
      if (Adr.PLZ != '') and (Adr.Ort != '') then begin
        disp # 1;
        Write( 1, 'PLZ/Ort',                   n, 0);
        Write( 2, ':',                         n, 0);
        Write( 3, "Adr.PLZ" +'/'+ "Adr.Ort",   n, 0);
      end
      else if (Adr.Postfach.PLZ != '') and (Adr.Postfach != '') then begin
        Write( 1, 'PLZ/Postfach',              n, 0);
        Write( 2, ':',                         n, 0);
        Write( 3, "Adr.Postfach.PLZ" + '/' + "Adr.Postfach", n, 0);
      end;
      Write( 5, 'Gruppe',                        n, 0);
      Write( 6, ':',                             n, 0);
      Write( 7, "Adr.Gruppe",                    n, 0);
      EndLine();

      StartLine();
      if (disp = 1) and (Adr.Postfach.PLZ != '') and (Adr.Postfach != '') then begin
        disp # 1;
        Write( 1, 'PLZ/Postfach',              n, 0);
        Write( 2, ':',                         n, 0);
        Write( 3, "Adr.Postfach.PLZ" + '/' + "Adr.Postfach", n, 0);
      end
      else begin
        disp # 0;
        Write( 1, 'Land',                      n, 0);
        Write( 2, ':',                         n, 0);
        Write( 3, "Adr.LKZ",                   n, 0);
      end;
      Write( 5, 'Sachbearbeiter',              n, 0);
      Write( 6, ':',                           n, 0);
      Write( 7, "Adr.Sachbearbeiter",          n, 0);
      EndLine();

      if (disp = 1) then begin
        StartLine();
        Write( 1, 'Land',                      n, 0);
        Write( 2, ':',                         n, 0);
        Write( 3, "Adr.LKZ",                   n, 0);
        EndLine();
      end;

      StartLine(_LF_UnderLine);
      EndLine();
    end;

    'Adressen_XML' : begin
      StartLine();
      Write( 1, "Adr.Anrede",                  n, 0);
      Write( 2, "Adr.Name",                    n, 0);
      Write( 3, "Adr.Zusatz",                  n, 0);
      Write( 4, "Adr.Straße",                  n, 0);
      Write( 5, "Adr.PLZ" + ' ' + "Adr.Ort",   n, 0);
      Write( 6, "Adr.Postfach.PLZ" + '/' + "Adr.Postfach", n, 0);
      Write( 7, "Adr.LKZ",                     n, 0);
      Write( 8, ZahlI("Adr.Nummer"),           n, _LF_INT);
      Write( 9, ZahlI("Adr.KundenNr"),         n, _LF_INT);
      Write(10, ZahlI("Adr.LieferantenNr"),    n, _LF_INT);
      Write(11, "Adr.Stichwort",               n, 0);
      Write(12, "Adr.Gruppe",                  n, 0);
      Write(13, "Adr.Sachbearbeiter",          n, 0);
      Write(14, "Adr.Telefon1",                n, 0);
      Write(15, "Adr.Telefon2",                n, 0);
      Write(16, "Adr.Telefax",                 n, 0);
      Write(17, "Adr.eMail",                   n, 0);

      Erx # RecLink(815, 100, 2, _recFirst); // EK LiB
      if(Erx > _rLocked) then
        RecBufClear(815);

      Erx # RecLink(816, 100, 3, _recFirst); // EK ZaB
      if(Erx > _rLocked) then
        RecBufClear(816);

      Write(18, ZahlI(Adr.EK.Zahlungsbed), n, _LF_Int);
      Write(19, ZaB.Kurzbezeichnung, n, 0);
      Write(20, ZahlI(Adr.EK.Lieferbed), n, _LF_Int);
      Write(21, LiB.Bezeichnung.L1, n, 0);


      Erx # RecLink(815, 100, 6, _recFirst); // VK LiB
      if(Erx > _rLocked) then
        RecBufClear(815);

      Erx # RecLink(816, 100, 7, _recFirst); // VK ZaB
      if(Erx > _rLocked) then
        RecBufClear(816);

      Write(22, ZahlI(Adr.VK.Zahlungsbed), n, _LF_Int);
      Write(23, ZaB.Kurzbezeichnung, n, 0);
      Write(24, ZahlI(Adr.VK.Lieferbed), n, _LF_Int);
      Write(25, LiB.Bezeichnung.L1, n, 0);
      EndLine();
    end;
  end;
end;

//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
  WriteTitel();
  StartLine();
  EndLine();

  if (aSeite = 1) then begin
    StartLine();
    EndLine();
    StartLine();
    EndLine();
  end;

  if (List_XML = false) then begin
    List_Spacing[ 1] #  0.0;
    List_Spacing[ 2] # List_Spacing[ 1] + 23.0;
    List_Spacing[ 3] # List_Spacing[ 2] +  3.0;
    List_Spacing[ 4] # List_Spacing[ 3] + 43.0;

    List_Spacing[ 5] # List_Spacing[ 4] +  2.0;
    List_Spacing[ 6] # List_Spacing[ 5] + 25.0;
    List_Spacing[ 7] # List_Spacing[ 6] +  3.0;
    List_Spacing[ 8] # List_Spacing[ 7] + 31.0;

    List_Spacing[ 9] # List_Spacing[ 8] +  2.0;
    List_Spacing[10] # List_Spacing[ 9] + 15.0;
    List_Spacing[11] # List_Spacing[10] +  3.0;
    List_Spacing[12] # 195.0;


    StartLine(_LF_Bold | _LF_UnderLine);
    Write( 3, 'Adresse',         n, 0);
    Write( 7, 'Nummern',         n, 0);
    Write(11, 'Tele/Fax/E-Mail', n, 0);
    EndLine();
  end
  else begin
    StartLine(_LF_Bold | _LF_Underline);
    Write( 1, 'Anrede',         n, 0);
    Write( 2, 'Name',           n, 0);
    Write( 3, 'Zusatz',         n, 0);
    Write( 4, 'Straße',         n, 0);
    Write( 5, 'PLZ/Ort',        n, 0);
    Write( 6, 'Postfach',       n, 0);
    Write( 7, 'Land',           n, 0);
    Write( 8, 'AdressNr',       n, 0);
    Write( 9, 'KundenNr',       n, 0);
    Write(10, 'LieferantenNr',  n, 0);
    Write(11, 'Stichwort',      n, 0);
    Write(12, 'Gruppe',         n, 0);
    Write(13, 'Sachbearbeiter', n, 0);
    Write(14, 'Telefon1',       n, 0);
    Write(15, 'Telefon2',       n, 0);
    Write(16, 'Telefax',        n, 0);
    Write(17, 'E-Mail',         n, 0);
    Write(18, 'Zahlungsbedingungen EK' , n, 0);
    Write(19, '' , n, 0);
    Write(20, 'Lieferbedingung EK' , n, 0);
    Write(21, '' , n, 0);
    Write(22, 'Zahlungsbedingungen VK' , n, 0);
    Write(23, '' , n, 0);
    Write(24, 'Lieferbedingung VK' , n, 0);
    Write(25, '' , n, 0);
    EndLine();
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
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx   : int;
  vSelName  : alpha;
  vSel      : int;
  vFlag     : int;
  vHdl      : int;
end;
begin
  ListInit(n); // KEIN Landscape

  // Mainloop der Datensätze
  FOR Erx # RecRead(100, 1, _recFirst);
  LOOP Erx # RecRead(100, 1, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN


    if (List_XML = n) then
      Print('Adressen');
    else
      Print('Adressen_XML');
  END;

  ListTerm();
end;

//========================================================================