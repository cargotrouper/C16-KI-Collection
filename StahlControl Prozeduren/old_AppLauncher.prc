/* ==== Business-Control ============================================== */

/*  Prozedur  old_AppLauncher
 *
 *  Info
 *
 *      001 24.03.2003  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */

/* ==== Anweisungsteil ================================================ */

if (Usergroup<>'USER') and (Usergroup<>'LIZENZ') then Call('App_Main');
SetBatch('&ES',y);

/* ==== [END OF PROCEDURE] ============================================ */