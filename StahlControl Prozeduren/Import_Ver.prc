@A+
//===== Business-Control =================================================
//
//  Prozedur    Import_Ver
//                  OHNE E_R_G
//  Info
//
//
//  23.11.2008  MS  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//
//
//========================================================================
@I:Def_Global

define begin
  GetAlphaUp(a,b) : a # strcnv(FldAlphabyName('X_'+b),_StrUpper);
  GetAlpha(a,b)   : a # FldAlphabyName('X_'+b);
  GetInt(a,b)     : a # FldIntbyName('X_'+b);
  GetWord(a,b)    : a # FldWordbyName('X_'+b);
  GetNum(a,b)     : a # FldFloatbyName('X_'+b);
  GetBool(a,b)    : a # FldLogicbyName('X_'+b);
  GetDate(a,b)    : a # FldDatebyName('X_'+b);
  GetTime(a,b)    : a # FldTimebyName('X_'+b);
end;

//========================================================================
// call Import_Ver:Import_MTD
//    Metal-Traders Düsseldorf
//========================================================================
sub Import_MTD()
local begin
  Erx       : int;
  vNr       : int;
  vFile     : int;
  vMax      : int;
  vPos      : int;
  vA        : alpha(4000);
  vName     : alpha;
  vNummer   : int;
  vKundenNr : int;
  vLiefNr   : int;
  vClear    : logic;
end;
begin

  vClear # false;

  if (Msg(99,'Wollen Sie Vertreter leeren?',_WinIcoQuestion,_WinDialogYesNo,2) = _winidYes) then
    vClear # true;
  vName # Lib_FileIO:FileIO(_WinComFileOpen,gMDI, '', 'CSV-Dateien|*.csv');

  if(vName <> '') then begin

    vFile # FSIOpen(vName, _FsiStdRead);
    if (vFile<=0) then begin
      Msg(99,'Datei nicht lesbar: ' + vName,0,0,0);
      RETURN;
    end;

    if(vClear) then begin
      // Vertreter   LÖSCHEN
      Lib_Rec:ClearFile(110);         // Vertreterverbände
      Lib_Rec:ClearFile(111);         // Provisionstabelle
    end;

    vMax # FsiSize(vFile);
    vPos # FsiSeek(vFile);


    WHILE (vPos<vMax) do begin
      RecRead(110,1,_RecLast);
      vNummer # Ver.Nummer + 1;


      RecBufClear(110);
      RecBufClear(103);

      FSIMark(vFile, 59);   /* ; */
      FSIRead(vFile, vA);
      vKundenNr # cnvIA(vA);                                                  /*1  KundenNr*/
      FSIRead(vFile, vA);
      vLiefNr # cnvIA(vA);                                                    /*2  LiefNr*/
      if(vKundenNr <> 0) then begin
        Adr.KundenNr # vKundenNr;
        Erx # RecRead(100, 2, 0); // Adresse ueber KundenNr lesen
        if(Erx > _rMultiKey) then
          RecBufClear(100);
      end
      else if (vLiefNr <> 0) then begin
        Adr.LieferantenNr # vLiefNr;
        Erx # RecRead(100, 3, 0); // Adresse ueber LieferantenNr lesen
        if(Erx > _rMultiKey) then
          RecBufClear(100);
      end;
      if(Adr.Nummer <> 0) then
        Ver.Adressnummer # Adr.Nummer;

      FSIRead(vFile, vA);
      Ver.Stichwort #  StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 20);        /*3  Stichwort*/
      FSIRead(vFile, vA);
      Ver.Name # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);              /*4  Name*/
      FSIRead(vFile, vA);
      "Ver.Straße" # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);          /*5  Straße*/
      FSIRead(vFile, vA);
      Ver.PLZ # StrCut(vA,1 , 8);                                             /*6  PLZ  */
      FSIRead(vFile, vA);
      Ver.Ort # StrCut(Lib_Strings:Strings_WIN2DOS(vA), 1, 40);               /*7  Ort*/
      FSIRead(vFile, vA);
      Ver.LKZ # StrCut(vA, 1, 3);                                             /*8  LKZ*/
      FSIRead(vFile, vA);
//      "Ver.Steuerschlüssel" # cnvIA(vA);                                      /*9 Steuerschl*/
      FSIMark(vFile, 13);   /* CR */
      FSIRead(vFile, vA);    /*10 SPRACHE?*/
      //letzter
      //# vA;

      FSIMark(vFile, 10);   /* LF */
      FSIRead(vFile, vA);

      // Daten anlegen:
      Ver.Nummer # vNummer;
      RekInsert(110, 0, 'AUTO');

      vPos # FsiSeek(vFile);
    END;

    FSIClose(vFile);

    Msg(99,'Vertreter wurden importiert!',0,0,0);
  end;
end;
