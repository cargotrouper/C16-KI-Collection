/* ==== Business-Control ============================================== */

/*  Prozedur  _import
 *
 *  Info
 *
 *      001 24.03.2003  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
var
  vx,vy,vz  # intl;
  vA        # alpha;
  vdat      # date

/* ==== Anweisungsteil ================================================ */

case num(Art.MEH) of

  1 do Art.MEH # 'Stk';
  2 do Art.MEH # 'kg';
  3 do Art.MEH # 'm';
  4 do Art.MEH # 'g';
  5 do Art.MEH # 'mg';
  6 do Art.MEH # '1/2kg';
  7 do Art.MEH # '750g'

end;


SetResult(y);

/* ==== [END OF PROCEDURE] ============================================ */