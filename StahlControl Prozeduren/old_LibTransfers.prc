@A-
/* ==== Business-Control ============================================== */
/*  Prozedur  old_LibTransfer
*
*  Info
/     Funktionen für SQL-BULK-TRANSFERS
*
*      001 08.03.2017  AH  Erstellung der Prozedur
*      002 16.04.2018  AH  Fix für Anlage_Datum
*      003 15.07.2021  AH  Fix für FLOAT im Bereich -100000000 bis 10000000
*      004 21.09.2021  ST  Protokolldaten Anlage, User für Dateibereich 700-711
*      005 2022-07-14  AH  TimeStamp
*/
/* ==== BC ============================================================ */

/* ==== Include ======================================================= */
define
  TextAddLine(a,b)    # TextInsLine(a,TextLineCnt(a)+1,b);
  aint(a) # CutStr(alpha(a),y);
enddef

/* ==== Deklarationsteil ============================================== */
arg
    aCMD    #   alpha

var
    vDatei  #   intl;
    Dummy   #   alpha;
    vTds    #   intl;
    vFld    #   intl;
    vMaxFld #   intl;
    vX      #   intl;
    vY      #   intl;
    vFrei   #   intl;
    vFldName  # alpha;
    vProc   #   alpha;
    vFPath  #   alpha(250);
    vCount  #   intl;
    vA      #   alpha
const
    cTransName  # 'AUTO_SQL'

/* ==== Anweisungsteil ================================================ */

  /* -------------------------------------------------------------------- */
  if (aCMD='CREATE') then begin
    vDatei  # GV.Int.01;
    vProc   # GV.Alpha.01;
    vFPath  # GV.Alpha.02;

    Sel.Anlage.Datum   # $0;
    Sel.Selektionsname # '';

    TransferDel(vDatei,cTransName);

    /* Summe der Felder ermittlen... */
    vTds # Info(1,vDatei,0,0,2);
    FOR vX # 1 to vTds do begin
        vFld # Info(2,vDatei,vX,0,3);
        FOR vY # 1 to vFld do begin

           Call('Lib_Transfers:FieldName',vDatei, vX, vY);
           vFldname # GV.Alpha.01;

           if (vFldName='') then CYCLE;
           vMaxFld # vMaxFld + 1;
        END;
    END;

    TextOpen(1,20); /* Prozedurcode */
    TextOpen(2,20); /* Formatfile   */
    TextAddLine(2, '12.0');
    TextAddLine(2, aint(vMaxFld));
    TextAddLine(2, '1 SQLCHAR 0 0 "\"" 0 FIRST_QUOTE ""');
    vCount # vCount + 1;

    TransferCreate(vDatei,cTransName,'','','','','Lib_Transfers2:'+vProc,'');
    TransferDef(vDatei,cTransName,0, vMaxFld+1+2+1 , vMaxFld+1+2+1 ,1,0,99999999);
    TransferDef(vDatei,cTransName,1,4,1,1,0,8);
/*    TransferDef(vDatei,cTransName,2,0, 253,0,0,0);      * Transparent 253 */
    TransferDef(vDatei,cTransName,2,1,1,13,0,0);        /* Feldende    ;=59   CR=13*/

/*    TransferDef(vDatei,cTransName,2,2,3,13,13,10);      /* Satzende     */
/* 30.08.2018 AH */
    TransferDef(vDatei,cTransName,2,2,2,13,10,0);      /* Satzende     */

    TransferDef(vDatei,cTransName,2,3,0,0,0,0);         /* Dateiende    */

    /* Übersetzungen */
    TransferDef(vDatei, cTransName, 5, 132, 228, 0,0,0); /* ä */
    TransferDef(vDatei, cTransName, 5, 148, 246, 0,0,0); /* ö */
    TransferDef(vDatei, cTransName, 5, 154, 220 ,0,0,0); /* ü */
    TransferDef(vDatei, cTransName, 5, 142, 196 ,0,0,0); /* Ä */
    TransferDef(vDatei, cTransName, 5, 153, 214 ,0,0,0); /* Ö */
    TransferDef(vDatei, cTransName, 5, 129, 252 ,0,0,0); /* Ü */
    TransferDef(vDatei, cTransName, 5, 225, 223 ,0,0,0); /* ß */
/*    TransferDef(vDatei, cTransName, 5,  34, 254 ,0,0,0); * " */

    /* 14.12.2018 CR/LF darf nicht Inhalt sein */
    TransferDef(vDatei, cTransName, 5, 13, 32 ,0,0,0); /* CR */
    TransferDef(vDatei, cTransName, 5, 10, 32 ,0,0,0); /* LF */


    TextAddLine(1,'sub '+vProc+'()');
    TextAddLine(1,'begin');

    vCount  # 1;
    vFrei   # 1;

    TransferDef(vDatei,cTransName,4,vCount,vCount,999,1,vFrei);     /* GUID immer 1. Feld */
    /* TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # GUID('+alpha(vDatei,3)+');'); 15.07.2021 */
    TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # ''00000000-0C16-0C16-0C16-0'+alpha(vDatei,3)+'''');
    TextAddLine(1, '     +cnvai(RecInfo('+Alpha(vDatei,3)+',_recID),_FmtNumHex|_FmtNumleadzero|_FmtNumleadzero,0,8);');
    
    vCount # vCount + 1;
    vFrei # vFrei + 1;

    /* Anlagedatum + User + TimeStamp*/
    if (vDatei=100) then begin
/*      TransferDef(vDatei,cTransName,4,vCount+1,vCount+1,vDatei,6,1);  /* Anlagedatum */
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 6, 1)+'");');  /* Alagedatum =100,6,1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,6,3);  /* Anlageuser =100,6,3*/
      vCount # vCount + 1;
    end
    else if (vDatei=120) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");');    /* Anlagedatum = 120,1,1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser */
      vCount # vCount + 1;
    end
    else if (vDatei=122) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");');    /* Anlagedatum = 120,1,1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser */
      vCount # vCount + 1;
    end
    else if (vDatei=200) then begin
/*      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,6,1);  /* Anlagedatum */
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 6, 1)+'");');
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,6,3);  /* Anlageuser */
      vCount # vCount + 1;
    end
    else if (vDatei=280) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");');
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser */
      vCount # vCount + 1;
    end
    /* MUSTER */
    else if (vDatei=702) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 4, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,4,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=700) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=701) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 5, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,5,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=703) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 4, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,4,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=707) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 4, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,4,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=709) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=710) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else if (vDatei=711) then begin
      TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
      TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, 2, 1)+'");'); /* Anlagedatum = Datei/4/1 */
      vFrei # vFrei + 1;
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,2,3);  /* Anlageuser = Datei/4/3 */
      vCount # vCount + 1;
    end
    else begin
      TransferDef(vDatei,cTransName,4,vCount,vCount,998,1,5);     /* Anlagedatum */
      vCount # vCount + 1;
      TransferDef(vDatei,cTransName,4,vCount,vCount,998,1,3);     /* Anlageuser */
      vCount # vCount + 1;
    end;

/* 2022-07-14 AH */
    TransferDef(vDatei,cTransName,4,vCount,vCount, 999,9,1);
    TextAddLine(1, '  '+GetName(3,999,9,1)+' # RecInfo('+aint(vDatei)+', _recModified);');    /* TimeStamp */
    vCount # vCount + 1;


    TextAddLine(2, '2 SQLCHAR 0 0 "\";\"" 1 RecID ""');

    FOR vX # 1 to vTds do begin
      vFld # Info(2,vDatei,vX,0,3);
      FOR vY # 1 to vFld do begin

        Call('Lib_Transfers:FieldName',vDatei, vX, vY);
        vFldname # GV.Alpha.01;

        if (vFldName='') then CYCLE;

        /* Alpha? */
        if (FldType(vDatei, vX, vY)=1) then begin
          TextAddLine(2, aint(vCount+1)+' SQLCHAR 0 255 "\";\"" '+aint(vCount)+' '+vFldName+' Latin1_General_CI_AS')
        end
        else begin
          TextAddLine(2, aint(vCount+1)+' SQLCHAR 0 255 "\";\"" '+aint(vCount)+' '+vFldName+' ""');
        end;

        /* datum? */
        if (FldType(vDatei, vX, vY)=2) then begin
          TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
          TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Datum("'+GetName(3, vDatei, vX, vY)+'");');
          vFrei # vFrei + 1;
        end
        /* Zeit? */
        else if (FldType(vDatei, vX, vY)=11) then begin
          TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
          TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Zeit("'+GetName(3, vDatei, vX, vY)+'");');
          vFrei # vFrei + 1;
        end
        /* Bool? */
        else if (FldType(vDatei, vX, vY)=10) then begin
          TransferDef(vDatei,cTransName,4,vCount,vCount, 999,1,vFrei);
          TextAddLine(1, '  '+GetName(3,999,1,vFrei)+' # Bool("'+GetName(3, vDatei, vX, vY)+'");');
          vFrei # vFrei + 1;
        end
        /* Float? */
        else if (FldType(vDatei, vX, vY)=9) then begin /* 15.07.2021 */
          TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,vX,vY);
          vA # '"'+GetName(3,vDatei,vX,vY)+'"';
          TextAddLine(1, '  if '+vA+'>0.0 then '+vA+' # Min('+vA+', 100000000000.0)');
          TextAddLine(1, '  else '+vA+' # Max('+vA+', -100000000000.0);');
        end
        else begin
          /* "normales" Feld */
          TransferDef(vDatei,cTransName,4,vCount,vCount,vDatei,vX,vY);
        end;

        vCount # vCount + 1;

      END;

    END;

/* OBSOLETE
    TextSave(2, '*'+vFPath+'_FMT.txt', n);
*/
    TextClose(2);

    TextAddLine(1,'end;');
    TextSave(1, '!AutoTransferProc', n);
/*    ClipBoardWrite(1, 0);*/
    TextClose(1);
  end;  /* CMD CREATE */




  /* -------------------------------------------------------------------- */
  if (aCMD='EXPORT') then begin
    vDatei # GV.Int.01;
    Transfer(vDatei,cTransName,'',GV.Alpha.01,0,n,y,n);
{***
    /* IMPORT */
    ClrFile(vDatei);
    Transfer(vDatei,cTransName,'','C:\'+alpha(vDatei,3,0,n,y)+'.TXT',1,n,y,n);
    TransferDel(vDatei,cTransName);/**/
***}
  end;


  if (aCMD='DELETE') then begin
    vDatei  # GV.Int.01;
    TransferDel(vDatei, GV.Alpha.01);
  end;

/* ==== [END OF PROCEDURE] ============================================ */