/* ==== Business-Control ============================================== */

/*  Prozedur  old_StartTransfer
 *
 *  Info
 *
 *      001 16.01.2008  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
arg
  aDatei  # ints;
  aName   # alpha;
  aSel    # alpha;
  aFile   # alpha(250);
  aMode   # ints

/* ==== Anweisungsteil ================================================ */

Transfer(aDatei, aName, aSel, aFile, aMode, n,n,n);

/* ==== [END OF PROCEDURE] ============================================ */