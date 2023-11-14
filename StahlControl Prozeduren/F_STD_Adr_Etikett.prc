@A+
//===== Business-Control =================================================
//
//  Prozedur    F_STD_Adr_Etikett
//                    OHNE E_R_G
//  Info        Druckt ein Etikett zu einer Adresse
//
//
//  30.09.2010  MS  Aenderung auf Lagerplatz
//  03.08.2012  ST  Erweiterung: Arg Dateiname für auto Dateierstellung
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB NachGVAlphas(aInhalt1 : alpha; aZ : int);
//
//    MAIN (opt aFilename : alpha(4096))
//
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
  aAdr      # Adr.Nummer;
  aSprache  # '';
end;


//========================================================================
//  NachGVAlphas
//
//========================================================================
sub NachGVAlphas(
  aInhalt1  : alpha;
  aZ        : int);
begin
  FldDef(999, 1, aZ,aInhalt1);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx           : int;
  // Datenspezifische Variablen
  vErx,i          : int;
  vHdl            : int;       // Descriptor für Textfelder d. Ausgabe Elementes
  vPrt            : int;        // Descriptor für Ausgabe Elemende
  vHeader         : int;
  vFooter         : int;
  vAnzahl         : int;
  vID             : int;

  vMFile,vMID     : int;
  vItem           : handle;
  vPos            : int;
end;
begin


    // ------ Druck vorbereiten ----------------------------------------------------------------

    // Markierte Positionen in Selektion rein, um nach Position zu sortieren
    vItem # gMarkList->CteRead(_CteFirst);
    if(vItem > 0) then begin
      FOR vItem # gMarkList->CteRead(_CteFirst);
      LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
      WHILE (vItem > 0) do begin
        Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
        if (vMFile = 100) then
          RecRead(100, 0, _RecId, vMID);

        RecBufClear(999);

        vPos # 1;
        if(Adr.Anrede <> '') then begin
          NachGVAlphas(Adr.Anrede, vPos);
          vPos # vPos + 1;
        end;

        if(Adr.Name <> '') then begin
          NachGVAlphas(Adr.Name, vPos);
          vPos # vPos + 1;
        end;

         if(Adr.Zusatz <> '') then begin
          NachGVAlphas(Adr.Zusatz, vPos);
          vPos # vPos + 1;
        end;

        if("Adr.Straße" <> '') then begin
          NachGVAlphas("Adr.Straße", vPos);
          vPos # vPos + 1;
        end;

        if(Adr.Ort <> '') then begin
          NachGVAlphas(Adr.PLZ + ' ' + Adr.Ort, vPos);
          vPos # vPos + 1;
        end;

        if(Adr.LKZ <> '') then begin
          Erx # RecLink(812, 100, 10, _recFirst);   // Land holen
          if(Erx > _rLocked) then
            RecBufClear(812);
          if("Lnd.kürzel" <> 'D') then begin
            NachGVAlphas(Lnd.Name.L1, vPos);
            vPos # vPos + 1;
          end;
        end;

        if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_EtikettA5querAufA4Hoch', 'FALSE') < 0) then begin
          RETURN;
        end;


        Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);
        form_RandOben   # 0.0;
        form_RandUnten  # 0;

        vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.Adresse');
        Lib_Print:LfPrint(vPrt);
        //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
        Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
      END;
    end
    else begin
      if (Mode=c_ModeList) then
        Erx # RecRead(100, 0, _recLock, gZLList->wpdbrecid);

      RecBufClear(999);

      vPos # 1;
      if(Adr.Anrede <> '') then begin
        NachGVAlphas(Adr.Anrede, vPos);
        vPos # vPos + 1;
      end;

      if(Adr.Name <> '') then begin
        NachGVAlphas(Adr.Name, vPos);
        vPos # vPos + 1;
      end;

       if(Adr.Zusatz <> '') then begin
        NachGVAlphas(Adr.Zusatz, vPos);
        vPos # vPos + 1;
      end;

      if("Adr.Straße" <> '') then begin
        NachGVAlphas("Adr.Straße", vPos);
        vPos # vPos + 1;
      end;

      if(Adr.Ort <> '') then begin
        NachGVAlphas(Adr.PLZ + ' ' + Adr.Ort, vPos);
        vPos # vPos + 1;
      end;

      if(Adr.LKZ <> '') then begin
        Erx # RecLink(812, 100, 10, _recFirst);   // Land holen
        if(Erx > _rLocked) then
          RecBufClear(812);
        if("Lnd.kürzel" <> 'D') then begin
          NachGVAlphas(Lnd.Name.L1, vPos);
          vPos # vPos + 1;
        end;
      end


      if (Lib_Print:FrmJobOpen(y,0,0,n,n,n,'STD_EtikettA5querAufA4Hoch', 'FALSE') < 0) then begin
        RETURN;
      end;


      Form_DokName # GetDokName(var Form_DokSprache, var Form_DokAdr);
      form_RandOben   # 0.0;
      form_RandUnten  # 0;

      vPrt  # PrtFormOpen(_PrtTypePrintForm,'FRM.STD.Etikett.Adresse');
      Lib_Print:LfPrint(vPrt);
      //Lib_Print:FrmJobClose(!"Frm.DirektdruckYN");
      Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);
    end;
end;



//========================================================================