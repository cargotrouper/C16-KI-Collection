@A-
/* ==== Business-Control ============================================== */
/*  Prozedur  old_LibTransferC16
*
*  Info
*      Funktionen für STD-C16-Transfers (NICHT SQL BULK!!!)
*
*      2023-08-02 AH  Erstellung der Prozedur
*/
/* ==== BC ============================================================ */

/* ==== Include ======================================================= */
define
  aint(a) # CutStr(alpha(a),y);
enddef

/* ==== Deklarationsteil ============================================== */
arg
    aDatei  #   intl;
    aCmd    #   alpha

var
    Dummy   #   alpha;
    vTds    #   intl;
    vFld    #   intl;
    vMaxFld #   intl;
    vX      #   intl;
    vY      #   intl;
    vFrei   #   intl;
    vFldName  # alpha;
    vFPath  #   alpha(250);
    vCount  #   intl;
    vA      #   alpha;
    vTransName   #   alpha

/* ==== Anweisungsteil ================================================ */
/*  Call('Lib_Debug:Dbg_Debug','AAA');*/

  vFPath      # GV.Alpha.01;
  vTransName  # GV.Alpha.02;

  /* -------------------------------------------------------------------- */
  if (aCMD='CREATE') then begin
    TransferDel(aDatei,vTransName);

    /* Summe der Felder ermittlen... */
    vTds # Info(1,aDatei,0,0,2);
    FOR vX # 1 to vTds do begin
        vFld # Info(2,aDatei,vX,0,3);
        FOR vY # 1 to vFld do begin
           vMaxFld # vMaxFld + 1;
        END;
    END;

    TransferCreate(aDatei,vTransName,'','','','','','');
    TransferDef(aDatei,vTransName,0, vMaxFld, vMaxFld,1,1,99999999);
    TransferDef(aDatei,vTransName,1,4,1,1,0,8);
    TransferDef(aDatei,vTransName,2,0, 126,0,0,0);      /* Transparent 253 */
    TransferDef(aDatei,vTransName,2,1,1,44,0,0);        /* Feldende    ;=59   CR=13*/

/*    TransferDef(vDatei,cTransName,2,2,3,13,13,10);      /* Satzende     */
/* 30.08.2018 AH */
    TransferDef(aDatei,vTransName,2,2,2,13,10,0);      /* Satzende     */

    TransferDef(aDatei,vTransName,2,3,0,0,0,0);         /* Dateiende    */

    vCount  # 1;

    /* Anlagedatum + User + TimeStamp*/
    FOR vX # 1 to vTds do begin
      vFld # Info(2,aDatei,vX,0,3);
      FOR vY # 1 to vFld do begin

        vFldname # GetName(3, aDatei, vX, vy); /* Feldname */
        
        /* "normales" Feld */
        TransferDef(aDatei,vTransName,4,vCount,vCount,aDatei,vX,vY);

        vCount # vCount + 1;
      END;

    END;

    RETURN;
  end;


  /* -------------------------------------------------------------------- */
  if (aCMD='EXPORT') then begin
    Transfer(aDatei,vTransName,'',vFPath,0,n,y,n);
    RETURN;
  end;


  /* -------------------------------------------------------------------- */
  if (aCMD='IMPORT') then begin
    ClrFile(aDatei);
    Transfer(aDatei,vTransName,'',vFPath,1,n,y,n);
/*    TransferDel(vDatei,cTransName);*/
    RETURN;
  end;


  /* -------------------------------------------------------------------- */
  if (aCMD='DELETE') then begin
    TransferDel(aDatei, vTransName);
  end;


/* ==== [END OF PROCEDURE] ============================================ */