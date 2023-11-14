/* ==== Business-Control ============================================== */

/*  Prozedur  old_Sel_Proccompiler
 *
 *  Info
 *
 *      001 18.06.2004  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
define
  TAdd(a)  #   TextInsLine(1,TextLineCnt(1)+1,a);
enddef

arg
  aProc       # alpha;
  aErg        # intl

var
  vErg        # ints;
  vBedingung  # alpha

/* ==== Anweisungsteil ================================================ */

TextOpen(1,10);

tAdd('@'+'A+');
Tadd('/* automatische Prozedur */');
Tadd('');

Tadd('MAIN : logic;');
TAdd('begin');
Tadd('');

vBedingung # 'StrFind(Art.Stichwort,'+char(39)+'B'+char(39)+',0)<>0';
Tadd('  if !('+vBedingung+') then RETURN false;');
Tadd('');

Tadd('');
TAdd('  RETURN true;');
TAdd('end');

ProcSave(1,aProc,n);

TextClose(1);

/* Compilieren */
aErg # ProcCompile(aProc);
if (aErg<>0) then DelText(aProc);

/* ==== [END OF PROCEDURE] ============================================ */