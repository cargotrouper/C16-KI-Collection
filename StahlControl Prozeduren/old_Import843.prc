/* ==== Business-Control ============================================== */

/*  Prozedur  old_Import843
 *
 *  Beschreibung
 *
 *      001 03.08.2002  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */

/* ==== Anweisungsteil ================================================ */

Apl.L.Key2 # Apl.L.Key1 mod 100;
Apl.L.Key1 # Apl.L.Key1 div 100;
Apl.L.Menge.MEH # 'kg';
if ApL.L.ObfZusatz='0' then ApL.L.Obfzusatz # '';

SetResult(y);

/* ==== [END OF PROCEDURE] ============================================ */