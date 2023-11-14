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

case num(Art.SL.MEH) of

  1 do Art.SL.MEH # 'Stk';
  2 do Art.SL.MEH # 'kg';
  3 do Art.SL.MEH # 'm';
  4 do Art.SL.MEH # 'g';
  5 do Art.SL.MEH # 'mg';
  6 do Art.SL.MEH # '1/2kg';
  7 do Art.SL.MEH # '750g'

end;

/* SL-Kopf anlegen? */
ClrRec(255);
Art.SLK.Artikelnr # Art.SL.Artikelnr;
Art.SLK.Nummer    # 1;
RecTest(255,1);
if (erg<>6) then begin
  Art.SLK.Name      # 'Standard';
  Art.SLK.Bemerkung # 'aus Altsystem';
  RecInsert(255,n);
end;


Art.SL.Nummer       # 1;
Art.SL.lfdNr        # 1;
Art.SL.Typ          # 250;
Art.SL.Kosten.StdYN # y;
Art.SL.Anlage.Datum # today;
Art.SL.Anlage.Zeit  # clock(y);
Art.SL.Anlage.User  # 'ALTSYSTEM';

SetResult(y);

/* ==== [END OF PROCEDURE] ============================================ */