@A+
//===== Business-Control =================================================
//
//  Prozedur  Fibu_Navision
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//  SUB ErlExport();
//  SUB ErlExportThis();
//
//  SUB _ERe_ExportThis();
//  SUB ERe_Export();
//
//========================================================================
@I:Def_global

define begin
  Msg2(a) : WindialogBox(gFrmMain,'FIBU-Übergabe',a,_WinIcoError, 0 |_WinDialogAlwaysOnTop,1);

  Write(a)      : vString # vString + a + ';'
  WriteF(a,b,c) : vString # vString + cnvaf(a,_FmtNumNoGroup | _FmtNumPoint,0,c,b) + ';'
  WriteI(a,b)   : vString # vString + cnvai(a,_FmtNumNoGroup,0,b) + ';'
  WriteD(a)     : if (a>1.1.1900) then vString # vString + Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(a)+1900,_FmtNumLeadZero|_fmtnumnogroup,0,4)+';'
  Satzende      : begin FSIWrite(vFile , vString); vstring # ''; end;

  path          : 's:\transnav\'
end;

//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export();
begin
  Msg(99,'Übergabe erfolgt automatisch bei Rechnungsverbuchung!',0,0,0);
end;


//========================================================================
//  ErlExportThis
//
//========================================================================
sub ErlExportThis(aPara : alpha) : int;
local begin
    Erx     : int;
    vDateiname      : alpha;            /* Name der Export-Datei        */
    vFile           : int;
    vString         : alpha(1000);

    vWert           : float;
    vGewicht        : float;
end
begin

  if (Set.Fibu.Pfad='') then RETURN _rOK;
  if (Strcut(Set.Fibu.Pfad, StrLen(Set.Fibu.Pfad) ,1)<>'\') then
    Set.Fibu.Pfad # Set.Fibu.Pfad + '\';

  vDateiname # Set.Fibu.Pfad+'SC-R'+cnvai(Erl.Rechnungsnr)+'.TXT';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN _rOK;
  end;


  FsiSeek(vFile, FSISize(vFile));

  RecRead(450,1,0);

  if (Erl.Rechnungsdatum=0.0.0) then Erl.Rechnungsdatum # today;
  if (Erl.Zieldatum=0.0.0) then Erl.Zieldatum # today;

  vGewicht # 0.0;
  Erx # RecLink(451,450,1,_RecFirst);     // Konten loopen
  WHILE (Erx<=_rLocked) do begin
    vGewicht # vGewicht + Erl.K.Gewicht;
    Erx # RecLink(451,450,1,_RecNext);
  END;

  Erx # RecLink(100,450,5,_recFirst);     // Kunde holen


  Write('S');                           // Type S,P,ST,SP,PT,PP,SL
  Write('');                            // Credit (Gutschrift=Y)
  Write(Adr.Briefgruppe)                // Customer-no.

  case "Erl.Adr.Steuerschl" of          // VAT 1-Inl./0-Ausl/2-EG
  1 : WritE('!');                       // Inland
  2 : Write('2')                        // EG
  otherwise
      Write('0')                        // Ausland
  end;

  WriteI(Erl.Rechnungsnr,10);           // Invoice-no.
  WriteI(Auf.Nummer,10);                // Commission       ---- ???
  WriteD(Erl.Rechnungsdatum);           // Posting Date
  WriteD(Erl.Zieldatum);                // Due Date
  WriteF(vGewicht,20,0);                // Quantity
  WriteF(Erl.BruttoW1*100.0,20,0);      // Amount incl.VAT

  Write('EUR');                         // Currency Code
                                        // Unit Cost
  if (vGewicht=0.0) then
      Write('')
  else
      WriteF( (Erl.NettoW1/vGewicht)*1000.0*100.0 ,20,0);


  Write(StrChar(13)+StrChar(10));       // [CR]+[LineFeed]
  SatzEnde;



/***
  vOffset # 999;
  Auf.Nummer # Ums.Auftragsnr;
  Erx # RecRead(400,1,n);
  If Erx<>6 then begin
      AuA.Nummer # Ums.Auftragsnr;
      Erx # RecRead(410,1,n);
      If Erx=6 then vOffset # 10;
      end
  else begin
      vOffset # 0;
  end;
  if vOffset=999 then begin
      ExtClose(1);
      RETURN;
  end;
***/

  Erx # RecLink(451,450,1,_RecFirst);     // Konten loopen
  WHILE (Erx<=_rLocked) do begin

    if (Erl.K.Auftragspos=0) then begin
      Erx # RecLink(451,450,1,_RecNext)
      CYCLE;
    end;

    Erx # Reclink(401,451,8,_recFirst);   // AufPos holen
    if (Erx>_rLocked) then begin
      Erx # Reclink(411,451,9,_recFirst); // ~AufPos holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(451,450,1,_RecNext)
        CYCLE;
      end;
      RecBufCopy(411,401);
    end;


    Erx # RecLink(405,401,7,_RecFirst);
    WHILE (Erx<=_rLocked) do begin          // Vorkalkulationen loopen

                                            // Type S,P,ST,SP,PT,PP,SL
      Case StrCnv(StrCut(Auf.K.Bezeichnung,1,1),_Strupper) of
      'T' : Write('ST');
      'A' : Write('SP')
      otherwise begin
          Erx # RecLink(405,401,7,_RecNext);
          CYCLE;
          end
      end;

      Write('');                            // Credit (Gutschrift=Y)
      Write(Adr.Briefgruppe);               // Customer-no.

      case "Erl.Adr.Steuerschl" of          // VAT 1-Inl./0-Ausl/2-EG
      1 : WritE('!');                       // Inland
      2 : Write('2')                        // EG
      otherwise
          Write('0')                        // Ausland
      end;

      WriteI(Erl.Rechnungsnr,10);           // Invoice-no.
      WriteI(Auf.Nummer,10);                // Commission
      WriteD(Erl.Rechnungsdatum);           // Posting Date
      WriteD(Erl.Zieldatum);                // Due Date
      WriteF(Erl.K.Gewicht,20,0);           // Quantity

      Wae_Umrechnen(Auf.K.Preis, "Auf.Währung", var Auf.K.Preis, 1);
      if (Auf.K.PEH<>0) then
        vWert # Erl.K.Gewicht * Auf.K.Preis / cnvfi(Auf.K.PEH);

      WriteF(vWert*100.0,20,0);             // Amount incl.VAT
      Write('EUR');                         // Currency Code
                                            // Unit Cost
      if (Erl.K.Gewicht=0.0) then
          Write('')
      else
          Writef(Auf.K.Preis*100.0,20,0);


      Write(StrChar(13)+StrChar(10));       // [CR]+[LineFeed]
      SatzEnde;


      Erx # RecLink(405,401,7,_RecNExt);
    END;    // Vorkalkulation


    Erx # RecLink(451,450,1,_RecNext);
  END;  // Konten


  FSIClose(vfile);            // Datei schliessen

  RETURN _rOK;
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================
//========================================================================


//========================================================================
//  _ERe_ExportThis
//
//========================================================================
sub _ERe_ExportThis();
local begin
    Erx     : int;
    vDateiname      : alpha;            /* Name der Export-Datei        */
    vFile           : int;
    vString         : alpha(1000);

    vWert           : float;
    vGewicht        : float;
end
begin
/**/
  if (RecLinkInfo(551,560,3,_reccount)=0) then begin
    Msg2('Rechnung '+cnvai(ERe.Nummer)+' hat KEINE Kontierung !');
    RETURN;
  end;
/***/

  vDateiname # Set.Fibu.Pfad +'SC-ER'+cnvai(ERe.Nummer)+'.TXT';
//if (user='THOMAS') then vDateiname # 'c:\SC-ER'+CutStr(Alpha(ERD.Nummer,8,0),y)+'.TXT';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN;
  end;

  FsiSeek(vFile, FSISize(vFile));


  Erx # RecLink(100,560,5,_RecFirst);   // Lieferant holen

  case ERe.Rechnungstyp of
  8 : Write('PP');
  7 : Write('PT')
  otherwise Write('P')
  end;

  Write('');                      // Credit (Gutschrift=Y)        */
  Write(ADr.Briefanrede);         // Customer-no.                 */

  case "Adr.Steuerschlüssel" of   // VAT
  1 : Write('1');                 // Inland
  2 : Write('2')                  // EG
  otherwise
      Write('0')                  // Ausland
  end;

/*        Write(Nummer(ERD.Nummer,10,0));*/
  Write('');                      // Invoice-no.

/*        Write(Nummer(ERD.K.Gegenkonto,10,0));*/
/*        Write(ERD.Bestellnummer);*/
  Write('');                      // Commission

  WriteD(ERe.Anlage.Datum);       // Posting Date
  WriteD(ERe.Rechnungsdatum);     // Due Date
  WriteF(ERe.Gewicht,20,0);       // Quantity

  vWert # ERe.BruttoW1;// + ((ERe.NettobetragW1 * Ste.Prozent)/100);

  WriteF(vWert*100.0,20,0);       // Amount incl.VAT
  Write('EUR');                   // Currency Code

                                  // Unit Cost
/*        Write(Nummer((ERD.K.BetragW1/ERD.K.Gewicht)*1000*100,20,0));*/
  if (ERe.Gewicht=0.0) then ERe.Gewicht # 1.0;
  WriteF((ERe.NettoW1/ERe.Gewicht)*1000.0*100.0,20,0);

  Write(ERe.Rechnungsnr);         // Renummer
  Write('');                      // Aufnummer

  Write(StrChar(13)+StrChar(10)); // [CR]+[LineFeed]
  SatzEnde;


  FSIClose(vfile);            // Datei schliessen

end;


//========================================================================
//  ERe_Export
//
//========================================================================
sub ERe_Export();
local begin
  Erx     : int;
  vItem   : int;
  vMFIle  : int;
  vMID    : int;
end;
begin

  Erx # Msg(99,'Alle markierten Eingangsrechnugen exportieren?!',_WinIcoQuestion,_WinDialogYesNo,1);
  if (Erx<>_WinIdYes) then RETURN;

  if (Set.Fibu.Pfad='') then RETURN;
  if (Strcut(Set.Fibu.Pfad, StrLen(Set.Fibu.Pfad) ,1)<>'\') then
    Set.Fibu.Pfad # Set.Fibu.Pfad + '\';

  // Prüflauf....
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(560,0,0,vMID);              // Satz holen
    Erx # RecLink(550,560,2,_recFirsT); // Verbindlichkeit holen

    if (Erx<>_rOK) or (ERe.InOrdnung=n) or (ERe.JobAusstehendJN) then begin
      WindialogBox(gFrmMain,'FIBU-Übergabe','Die markierte Eingangsrechaung '+cnvai(ERe.Nummer)+' ist NICHT freigegeben!'+strchar(13)+'Übergabe abgebrochen!',_WinIcoError, 0 |_WinDialogAlwaysOnTop,1);
      RETURN;
    end;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  // Übergabelauf...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(560,0,0,vMID);            // Satz holen
    Erx # RecLink(550,560,2,_recFirsT); // Verbindlichkeit holen

    _ERe_ExportThis();

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;




  if (WindialogBox(gFrmMain,'FIBU-Übergabe','Übergabe abgeschlossen!'+Strchar(13)+'Die markierte Datensätze als gelöscht kennzeichnen?',_WinIcoQuestion, _WinDialogYesNo |_WinDialogAlwaysOnTop,1)<>_WinIDYes) then begin
    RETURN;
  end;


  // Löschlauf...
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>560) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(560,0,0,vMID);              // Satz holen
    Erx # RecLink(550,560,2,_recFirsT); // Verbindlichkeit holen

    RecRead(560,1,_recLock);
    "VBk.FibuDatum" # today;
    RekReplace(560,_RecUnlock,'AUTO');

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  Msg(999998,'',0,0,0);

end;

//========================================================================
//========================================================================

/****
    Prozedur    X.FBS.CMC.ER
    path            # 's:\transnav\';
    nur markierte ">"
???>>>
    if RecLinkCount(550,5)=0 then begin
        MsgBox('Fibu-Übergabe','Rechnung '+Alpha(ERD.Nummer,8,0)+' hat KEINE Kontierung !',1,0,0);
        SetFkey(0);
        RecReadNext(550,1,n);
        CYCLE;
    end;
<<<???

    vDateiname # Path +'SC-ER'+CutStr(Alpha(ERD.Nummer,8,0),y)+'.TXT';
if (user='THOMAS') then vDateiname # 'c:\SC-ER'+CutStr(Alpha(ERD.Nummer,8,0),y)+'.TXT';

exopen,,,
    ExtMove(1,ExtSize(1));


    RecLink(550,2,n,n);                 /* Lieferant holen              */
    RecLink(550,4,n,n);                 /* Steuerschluessel holen       */

        case ERD.Rechnungstyp of
            8 do Write('PP');
            7 do Write('PT')
            otherwise Write('P')
        end;
                                        /* Credit (Gutschrift=Y)        */
        Write('');
                                        /* Customer-no.                 */
        Write(Adr.DefiniertAlpha1);
                                        /* VAT                          */
        case :Ums.Steuerschlüssel: of
        1 do                            /* Inland */
            Write('1');
        2 do                            /* EG */
            Write('2')
        otherwise                       /* Ausland */
            Write('0')
        end;
                                        /* Invoice-no.                  */
        Write('');
                                        /* Commission                   */
        Write('');
                                        /* Posting Date                 */
        Write(Datum(ERD.Anlagedatum));
                                        /* Due Date                     */
        Write(Datum(ERD.Rechnungsdatum));
                                        /* Quantity                     */
        Write(Nummer(ERD.Gewicht,20,0));

        vWert # ERD.NettobetragW1 + ((ERD.NettobetragW1 * Ste.Prozent)/100);
                                        /* Amount incl.VAT              */
        Write(Nummer(vWert*100,20,0));
                                        /* Currency Code                */
        Write('EUR');
                                        /* Unit Cost                    */
        Write(Nummer((ERD.NettoBetragW1/ERD.Gewicht)*1000*100,20,0));
                                        /* Renummer                     */
        Write(ERD.Rechnungsnr);
                                        /* Aufnummer                    */
        Write('');
                                        /* [CR]+[LineFeed]              */
        ExtWrite(1,Char(13)+Char(10));

Fertig:
    :ERD.Fibu.Übergabe: # today;
    ERD.Markierung # '*';

****/