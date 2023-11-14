@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_datev
//                OHNE E_R_G
//  Info
//
//
//  04.11.2008  AI  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//  ERL_Export
//
//========================================================================
@I:Def_Global

define begin
  Datum(a)    : Cnvai(DateDay(a),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateYear(a)-100,_FmtNumLeadZero,0,2)
end;

local begin
  vNULL           : byte;
  vFile           : int;
  vBloecke        : int;
  vBlockPosition  : int;
  vPuffer         : alphA(250);
  vBuchung        : alpha(250);
end;

//========================================================================
//  Check
//
//========================================================================
sub Check(
  aA  : alpha
) : alpha;
begin
  aA # Str_ReplaceAll(aA, '"', StrChar(39));  // " -> '
  RETURN aA;
end;


//========================================================================
//  Flush
//
//========================================================================
sub Flush();
local begin
  vI  : int;
end;
begin
  if ((StrLen(vPuffer)+StrLen(vBuchung)) > 250) then begin
    FSIWrite(vFile, vPuffer);
    for vI # StrLen(vPuffer) loop inc(vI) while (vI<=255) do
      FSIWrite(vFile, vNULL);
    vPuffer  # vBuchung;
    vBloecke # vBloecke + 1;
    end
  else begin
    vPuffer # vPuffer + vBuchung;
  end;
end;


//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export()
local begin
  Erx           : int;
  vBeraternr    : alpha;
  vBeratername  : alpha;
  vMandant      : alpha;
  vDatentraeger : alpha;
  vNameKurz     : alpha;
  vAbrechnung   : alpha;

  vPfad         : alpha(200);
  vName         : alpha;
  vVonDat       : date;
  vBisDat       : date;
  vGegenkonto   : alpha;
  vSumme        : float;

  vCount        : int;
  vI            : int;
  vItem         : int;
  vMFile        : Int;
  vMID          : Int;
  vKdBuch       : int;
end;

begin
  vBeraternr      # '0045761';
  vBeratername    # 'STEINERT';
  vMandant        # '32100';
  vDatentraeger   # '1  ';
  vNameKurz       # 'TS';

  if (gUsername<>'AH') then vPfad # 'S:\fibu\';
  else vPfad # 'C:\';


  if (Msg(450103,'',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdNo) then RETURN;


  // DATENDATEI --------------------------------------------------------------------------
  // DATENDATEI --------------------------------------------------------------------------
  // DATENDATEI --------------------------------------------------------------------------

  // DATEI öffnen....
  vName # 'DE001';
  vFile # FSIOpen(vPfad+vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vName,0,0,0);
    RETURN;
  end;


  vVonDat # 1.1.2033;
  vBisDat # 1.1.1990;
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
    if (Erl.StornoRechNr<>0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    If (Erl.Rechnungsdatum>vBisDat) then vBisDat # Erl.Rechnungsdatum;
    If (Erl.Rechnungsdatum<vVonDat) then vVonDat # Erl.Rechnungsdatum;

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  vAbrechnung # cnvai(vBisDat->vpmonth,_FmtNumNoGroup|_FmtNumLeadZero,0,4)+cnvai(vBisDat->vpyear,_FmtNumNoGroup|_FmtNumLeadZero,0,2);
  vBloecke    # 1;

  vPuffer # StrChar(29)                     //Vorlaufbeginn                 }
          + StrChar(24)                     //Kennung neuer Vorlauf         }
          + StrChar(49)                     //Versions-Nummer               }
          + StrFmt(vDatentraeger,3,_strEnd) //Datenträger-Nummer (frei) 001 }
          + '11'                            //Anwendungs-Nummer             }
          + StrFmt(vNamekurz,2,_StrEnd)     //Namenskürzel (frei)        HR }
          + StrFmt(vBeraternr,7,_StrEnd)    //Berater-Nummer                }
          + StrFmt(vMandant,5,_StrEnd)      //Mandant                       }
          + StrFmt(vAbrechnung,6,_StrEnd)   //Abrechnungs-Nummer        299 }
          + Datum(vVonDat)                  //Datum von                     }
          + Datum(vBisDat)                  //Datum bis                     }
          + '1  '                           //Primanota-Seite           001 }
          + '    '                          //Paßwort                       }
          + StrFmt(' ',16,_StrEnd)          //Anwendungsinfo                }
          + StrFmt(' ',16,_StrEnd)          //Input-Info                    }
          + 'y';                            //Satzende                      }


  // Umsätze loopen -----------------------------------------------------------------------
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
    if (Erl.StornoRechNr<>0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;


    vCount # vCount + 1;

    RecLink(100,450,5,_RecFirsT);         // Kunde holen
    vKdBuch # cnvia(Adr.KundenFibuNr);
    if (vKdBuch=0) then vKdBuch # Adr.KundenNr;


    Erx # RecLink(460,450,2,_recFirst);     // OP-holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(470,450,11,_recFirst);    // ~OP-holen
      if (Erx>_rLocked) then RecBufClear(470);
      RecBufCopy(470,470);
    end;

    Erx # RecLink(816,460,8,_recFirst);     // Zahlungsbed.-holen
    if (Erx>=_rLocked) then RecBufClear(816);

    Erx # RecLink(814,450,3,_recFirst);     // Währung holen
    if (Erx>=_rLocked) then RecBufClear(814);
    if (Wae.Fibu.Code='') then Wae.Fibu.Code # "Wae.Kürzel";



    If (vKdBuch<20000) then      /*Inland */
        vGegenkonto # '004400';
    If (vKdBuch>=20000) and (vKdBuch<30000) then  /* steuerfrei EG */
        vGegenkonto # '004125';
    If (vKdBuch>=30000) and (vKdBuch<40000) then  /* sonst.Ausland */
        vGegenkonto # '004120';
    If (vKdBuch>=40000) and (vKdBuch<50000) then  /* Verbund 16%/0% */
        If (Erl.Adr.Steuerschl=1) then vGegenkonto # '004401'
        else If (Erl.Adr.Steuerschl=10) then vGegenkonto # '004402'
        else vGegenkonto # '004000';
    If (vKdBuch>=50000) and (vKdBuch<99999) then
        If (Erl.Adr.Steuerschl=1) or (Erl.Adr.Steuerschl=10) then vGegenkonto # '004402'
        else vGegenkonto # '004010';

    vBuchung    # '+'+ANum(Erl.BruttoW1*100.0,0) // 10 Umsatz        }
                + 'a'+vGegenkonto                       // Gegenkonto    }
                + 'b'+AInt(Erl.Rechnungsnr);    // 6 Belegfeld 1   }

    if (OFP.Zieldatum<>0.0.0) then
                vBuchung # vBuchung
                    + 'c'+Datum(Ofp.Zieldatum);         // Belegfeld 2   }

    vBuchung # vBuchung
                + 'd'+Cnvai(DateDay(Erl.Rechnungsdatum),_FmtNumLeadZero,0,2) + Cnvai(DateMonth(Erl.Rechnungsdatum),_FmtNumLeadZero,0,2)
                + 'e'+AInt(vKdBuch)    // 5 Konto         }
                + StrChar(30)+Adr.Stichwort+StrChar(28);    // Text          }
    if (Adr.USIdentNr <> '') then
        vBuchung # vBuchung + StrChar(186)+StrCnv(Adr.USIdentNr,_StrLetter|_STrUpper)+StrChar(28);

    vBuchung    # vBuchung
                + 'o1'                         // Währung       }
                + 'y';                         // Satzende      }
    vSumme # vSumme + Erl.BruttoW1;

    FLUSH();

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;


  vBuchung    # 'x'
              + ANum(vSumme*100.0,0) // 12
              + 'yz';

  FLUSH();


  FSIWrite(vFile,vPuffer);
  for vI # StrLen(vPuffer) loop inc(vI) while (vI<=255) do
    FSIWrite(vFile, vNULL);
  vBlockposition # StrLen(vPuffer);
  FSIClose(vfile);            // Datei schliessen



  // VERWALTUNGSDATEI --------------------------------------------------------------------
  // VERWALTUNGSDATEI --------------------------------------------------------------------
  // VERWALTUNGSDATEI --------------------------------------------------------------------

  // DATEI öffnen....
  vName # 'DV01';
  vFile # FSIOpen(vPfad+vName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vName,0,0,0);
    RETURN;
  end;

  vPuffer # StrFmt(vDatentraeger,3,_StrEnd)
          +'   '
          + StrFmt(vBeraternr,7,_StrEnd)
          + StrFmt(vBeratername,9,_StrEnd)
          + ' '
          + StrChar(01)+StrChar(00)
          + StrChar(01)+StrChar(00)
          + StrFmt(' ',37,_StrEnd);
  FSIWrite(vFile,vPuffer);

  vPuffer # 'V'   /* * */
          + StrChar(01)+StrChar(00)
          + '11'
          + StrFmt(vNameKurz,2,_StrEnd)
          + StrFmt(vBeraternr,7,_Strend)
          + StrFmt(vMandant,5,_StrEnd)
          + StrFmt(vAbrechnung,6,_strBegin)       /* 299 */
          + '0000'
          + StrFmt(Datum(vVonDat),6,_StrBegin)
          + StrFmt(Datum(vBisDat),6,_StrBegin)
          + '001'                         /* 001 */
          + '    '
          + StrChar(vBloecke)+StrChar(0)
          + StrChar(vBlockposition-1)+StrChar(0)
          + StrChar(01)+StrChar(00)
          + '        '
          + ' '
          + '1';
  FSIWrite(vFile,vPuffer);
  FSIClose(vfile);            // Datei schliessen

  Msg(450102,cnvai(vCount)+'|'+vName,0,0,0);


  // als übergeben markieren --------------------------------------------------------------
/*
  TRANSON;
xx loop
    RecRead(450,1,_recLock);
    Erl.Fibudatum # Today;
    RekReplace(450,0,'AUTO');
xx
  TRANSOFF;
*/

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);
end;

//========================================================================