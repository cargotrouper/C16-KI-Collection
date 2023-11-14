/* ==== Business-Control ============================================== */

/*  Prozedur  D_ArcFlow_Eit
/                    OHNE E_R_G
 *  Info
 *
 *      001 21.11.2007  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
arg
  aWert # alpha;
  aText # alpha;
  aAnz  # intl

/* ==== Anweisungsteil ================================================ */

LoadPDV('!DATAMAX-ETIKETTEN');

TextOpen(1,1);
TextInsLine(1,1,Char(2)+'L');
TextInsLine(1,2,'D11');
TextInsLine(1,3,'1E0000000250025'+aWert);
if (aText<>'') then
  TextInsLine(1,4,'121100000100050'+aText);
TextInsLine(1,5,'E');

PrintOn;
WHILE (aAnz>0) do begin
  TextPrint(1);
  aAnz # aAnz - 1;
END;

PrintOff;
TextClose(1);

LoadPDV('CLOSE');

/* ==== [END OF PROCEDURE] ============================================ */