@A-
/* ==== Business-Control ============================================== */
/*  Prozedur    old_autoTransfer
 *
 *  Argumente
 *
 *  Beschreibung
 *
 *  Seiteneffekte
 *
 *      001 01.01.2000  AI  Erstellung der Prozedur
 */
/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */

arg
  aDatei  # intl;
  aimport # logic;
  aPfad   # alpha(250)

var
    vTds    #   intl;
    vFld    #   intl;
    vAnz    #   intl;
    vX      #   intl;
    vY      #   intl;
    vZ      #   intl;

    vName   #   alpha;
    vSize   #   intl


const
    cTransName  # 'FULL_EXPORT'

/* ==== Anweisungsteil ================================================ */

vTds # Info(1,aDatei,0,0,2);
vAnz # 0;
FOR vX # 1 to vTds do begin
    vAnz # vAnz + Info(2,aDatei,vX,0,3);
END;
if (vAnz=0) then RETURN;

if (aPfad='') then
  vName # 'C:\debug\'+alpha(aDatei,3,0,n,y)+'.TXT'
else
  vName # aPfad;


TransferCreate(aDatei,cTransName,'','','','','','');

TransferDef(aDatei,cTransName,0, vAnz , vAnz ,1,0,99999999);

TransferDef(aDatei,cTransName,1,2,1,1,0,8);

TransferDef(aDatei,cTransName,2,0,174,0,0,0);       /* Transparent  */
TransferDef(aDatei,cTransName,2,1,1,179,0,0);       /* Feldende     */
TransferDef(aDatei,cTransName,2,2,2,13,10,0);       /* Satzende     */
TransferDef(aDatei,cTransName,2,3,0,0,0,0);         /* Dateiende    */

vZ # 0;
FOR vX # 1 to vTds do begin
    vFld # Info(2,aDatei,vX,0,3);
    FOR vY # 1 to vFld do begin
        vZ # vZ + 1;
        TransferDef(aDatei,cTransName,4,vZ,vZ,aDatei,vX,vY);
    END;
END;

if (aImport=n) then begin
  /* EXPORT */
  Transfer(aDatei,cTransName,'',vName, 0,n,y,n);
  end
else begin
  /* IMPORT */
  ClrFile(aDatei);

  ExtOpen(1,vName,n,n,0,4);
  vSize #  ExtSize(1);
  ExtClose(1);

  if (vSize>2) then
    Transfer(aDatei,cTransName,'',vName, 1,n,y,n);
end;

TransferDel(aDatei,cTransName);

/* ==== [END OF PROCEDURE] ============================================ */