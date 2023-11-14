@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_AdrExportTobit
//                    OHNE E_R_G
//
//  01.05.2007  NH  Erstellung der Prozedur
//
//
//
//  Subprozeduren
//    Export(vFilename : alpha;): logic;  //Exportiert die Adressdatei in den Tobit-Adress-Ordner
//
//========================================================================

define begin
end;

//========================================================================

sub Export(): logic;
local begin
  vText   : alpha(300);
  vFile   : int;
  vErg    : int;
  vFlag   : int;
  vCount  : int;
end;
begin

    vCount #0;
    //'Angezeigter Name; Fax; Vorname; 2. Vorname; Nachname; Anrede; Titel;Geburtstag; Firma; Straße; PLZ; Stadt; Land; Bundesland; Web-Site; Geschäftlich; Privat; Mobil; 2. Fax; eMail; Voice-Box;SMS/Pager; Zusatz; Kategorien; 2. eMail'
    vFile # FSIOpen(Set.Tobit.AdrUp.Pfad + '\Adressen.nmr',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      vText # '[ANSI]'+ strchar(13) + strchar(10)+'[DEL]'+ strchar(13) + strchar(10)+'[DEFAULT=2]'+ strchar(13) + strchar(10)
      vFlag # _RecFirst;
      WHILE (RecRead(100,1,vFlag) <= _rLocked ) DO BEGIN
        if (vFlag=_RecFirst) then vFlag # _RecNext;
        vText # Adr.Stichwort + ';' + Adr.Telefax + ';;;;;;;;;;;;;;;;;;' +  Adr.eMail + ';;;;;'
        vText # vText + strchar(13) + strchar(10);

  /*      vText # Adr.Stichwort + vT + Adr.Telefax + vT + '' + vT + '' + Adr.Name + vT + Adr.Anrede + vT + Adr.Zusatz + vT + '' + vT + Adr.Name + vT + "Adr.Straße"
        vText # vText + vT + Adr.PLZ + vT + Adr.Ort + vT + Adr.LKZ + vT + '' + vT + Adr.Website + vT + '' + vT + '' + vT + '' + vT + '' + vT + Adr.eMail + vT + '' + vT + '' + vT + Adr.Bemerkung + vT + vT + vT
        vText # vText + strchar(13) + strchar(10);*/
        vCount # vCount + 1
        FsiWrite(vFile, vText);
      END;
      FsiClose(vFile);
    end;
    gv.int.01 # vCount;
  return true;
end;

sub ExportP(): logic;
local begin
  vText   : alpha(300);
  vFile   : int;
  vErg    : int;
  vFlag   : int;
  vCount  : int;
end;
begin

    vCount #0;
    //'Angezeigter Name; Fax; Vorname; 2. Vorname; Nachname; Anrede; Titel;Geburtstag; Firma; Straße; PLZ; Stadt; Land; Bundesland; Web-Site; Geschäftlich; Privat; Mobil; 2. Fax; eMail; Voice-Box;SMS/Pager; Zusatz; Kategorien; 2. eMail'
    vFile # FSIOpen(Set.Tobit.AdrUp.Pfad + '\Adressen.nmr',_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiAppend);
    if (vFile>0) then begin
      vText # '[ANSI]'+ strchar(13) + strchar(10)+'[DEL]'+ strchar(13) + strchar(10)+'[DEFAULT=2]'+ strchar(13) + strchar(10)
      vFlag # _RecFirst;
      WHILE (RecRead(102,1,vFlag) <= _rLocked ) DO BEGIN
        if (vFlag=_RecFirst) then vFlag # _RecNext;
        reclink(100,102,1,_RecFirst);
        vText # Adr.P.Stichwort + ';' + Adr.P.Telefax + ';' + Adr.P.Vorname + ';;' + Adr.P.Name + ';' + Adr.P.Briefanrede + ';' + Adr.P.Titel + ';;' + Adr.Stichwort + ';;;;;;;;' + Adr.P.Telefon + ';;;' +  Adr.P.eMail + ';;;;;'
        vText # vText + strchar(13) + strchar(10);

  /*    vText # Adr.Stichwort + vT + Adr.Telefax + vT + '' + vT + '' + Adr.Name + vT + Adr.Anrede + vT + Adr.Zusatz + vT + '' + vT + Adr.Name + vT + "Adr.Straße"
        vText # vText + vT + Adr.PLZ + vT + Adr.Ort + vT + Adr.LKZ + vT + '' + vT + Adr.Website + vT + '' + vT + '' + vT + '' + vT + '' + vT + Adr.eMail + vT + '' + vT + '' + vT + Adr.Bemerkung + vT + vT + vT
        vText # vText + strchar(13) + strchar(10);*/
        vCount # vCount + 1
        FsiWrite(vFile, vText);
      END;
      FsiClose(vFile);
    end;
    gv.int.01 # vCount;
  return true;
end;

//========================================================================