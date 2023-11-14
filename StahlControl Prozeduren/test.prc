@A-
/* ==== Business-Control ============================================== */
/*  Prozedur  TEST
 *
 *  Info
 *
 *      001 24.03.2003  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
var
  vI        # intl;
  vx,vy,vz  # num;
  vC        # alpha;
  vA,vB     # alpha;
  vdat      # date;
  vFirst    # logic;
  vDatei    # intl;
  vDummy    # alpha

/* ==== Anweisungsteil ================================================ */

debug;
RecReadFirst(200,1);
WHILE (Erg=6) or (Erg=4) do begin
  RecRead(200,1,y);
  MAt.Datum.VsbMeldung # $0;
  RecReplace(200,n);
  RecReadNext(200,1,n);
END;

RETURN;


FOR vDatei # 1 to 899 do begin               /* Alle möglichen Dateien       */
    vDummy # GetName(1,vDatei,0,0);           /* Auf Vorhandensein testen     */
    If (Erg<>6) then CYCLE;

    RecInsert(vDatei,n);
END;

return;

 

RecReadFirst(252,4);
WHILE (erg<>2) and (erg<>0) do begin

  if (Art.C.Adressnr=0) or (Art.C.Charge.Intern='') then begin
    RecDelete(252);
    RecRead(252,4,n);
    RecRead(252,1,n);
    CYCLE;
  end;

  if (Art.C.Charge.Intern='00000000') then begin
    RecRead(252,1,y);
    Art.C.Charge.Intern # 'X'+alpha(Art.C.Adressnr,5,0,n,y)+alpha(Art.C.Anschriftnr,2,0,n,y);
    RecReplace(252,n);
    if (erg<>6) then DEBUG;
   end;

  RecReadNExt(252,4,n);
END;



RecReadFirst(251,2);
WHILE (Erg<>2) and (erg<>0) do begin
  if (Art.R.Charge.Intern='00000000') then begin
    RecRead(251,1,y);
    Art.R.Charge.Intern # 'X'+alpha(Art.R.Adressnr,5,0,n,y)+alpha(Art.R.Anschrift,2,0,n,y);
    RecReplace(251,n);
    if (erg<>6) then DEBUG;
  end;

  RecReadNext(251,2,n);
END;

RETURN;

RecReadFirst(252,9);
WHILE (erg<>2) and (erg<>0) do begin

  vC # Art.C.Charge.Intern;
  if (vC='00000000') then
    vC # 'X'+alpha(Art.C.Adressnr,5,0,n,y)+alpha(Art.C.Anschriftnr,2,0,n,y);

  vA # Art.C.ArtikelNr;
  vB # vC;
  vX  # 0;
if (vA='01-094') then debug;
  WHILE (erg<>2) and (erg<>0) and 
    (vA=Art.C.Artikelnr) and (vB=vC) do begin

    if (vC<>'') and
      ((Art.C.Bestand<>0.0) or (Art.C.Reserviert<>0.0) or (Art.C.Bestellt<>0) or (Art.C.OffeneAuf<>0)) and
      (Art.C.Adressnr<>0) then vX # vX + 1;

    RecReadNext(252,9,n);

    vC # Art.C.Charge.Intern;
    if (vC='00000000') then
      vC # 'X'+alpha(Art.C.Adressnr,5,0,n,y)+alpha(Art.C.Anschriftnr,2,0,n,y);
  END;

  if (vX>1) then debug;
  
END;

RETURN;

vx # 16433.40;
vY # 26940.0;
vZ # vX / (vY / 1000.0);
vA # alpha(vZ,10,13);
debug;

RETURN;


RecReadFirst(404,1);
WHILE (Erg<>2) and (erg<>0) do begin

  if (Auf.A.Rechnungsnr<>0) and (Auf.A.MaterialNr<>0) then begin
    RecRead(404,1,y);
    Auf.A.EKPreisSummeW1 # 0.0;
    RecReplace(404,n);
  end;

  RecReadNext(404,1,n);
END;

RETURN;

ClrFile(201);
ClrFile(202);
ClrFile(203);
ClrFile(204);
ClrFile(205);

ClrFile(400);
ClrFile(401);
ClrFile(402);
ClrFile(403);
ClrFile(404);
ClrFile(405);
ClrFile(406);
ClrFile(407);
ClrFile(408);
ClrFile(409);

ClrFile(440);
ClrFile(441);

ClrFile(500);
ClrFile(501);
ClrFile(502);
ClrFile(503);
ClrFile(504);
ClrFile(505);
ClrFile(506);
ClrFile(507);

ClrFile(700);
ClrFile(701);
ClrFile(702);
ClrFile(703);
ClrFile(704);
ClrFile(705);
ClrFile(706);
ClrFile(707);
ClrFile(709);

ClrRec(700);
BAG.Nummer # 1;
BAG.Bemerkung # 'test';
RecInsert(700,n);

RETURN;


Mat.Nummer # 666;
RecRead(200,1,y);
:Mat.Löschmarker: # '';
RecReplace(200,n);
RecLink(200,14,n,n);
WHILE (Erg=6) do begin
  RecDelete(204);
  RecLink(200,14,n,n);
END;

BAG.Nummer # 238;
Recread(700,1,n);
RecLink(700,1,n,n);
WHILE (erg=6) do begin
  RecDelete(702);
  RecLink(700,1,n,n);
END;
RecLink(700,3,n,n);
WHILE (erg=6) do begin
  RecDelete(701);
  RecLink(700,3,n,n);
END;

RETURN;

RecReadFirst(700,1);
WHILE (Erg<>2) and (Erg<>0) do begin
  RecLock(700,1);
  :BAG.Löschmarker: # '';
  BAG.Fertig.Datum # $0;
  BAG.Fertig.Zeit # %0;
  BAG.Fertig.User # '';
  RecReplace(700,n);
  RecReadNext(700,1,n);
END;

Call('test+2');

debug;

RETURN;

RecReadFirst(450,1);
WHILE (erg<>0) and (erg<>2) do begin

  vX # 0;
  vY # 0;
  vFirst # y;
  RecLink(450,1,n,n);
  WHILE (erg=3) or (erg=6) do begin

    if (Erl.K.Auftragspos=0) then begin
      RecLinkNext(450,1,n);
      CYCLE;
    end;

    vX # vX + Erl.K.Betrag;
    if (Erl.K.Bemerkung='Grundpreis') then vY # Erl.K.Menge;

    RecLinkNext(450,1,n);
  END;


  RecLink(450,4,n,n);   /* Aktionen loopen */
  WHILE (erg=3) or (erg=6) do begin

    RecLink(404,1,n,n);     /* Pos. holen */
    if (Erg<>3) and (erg<>6) then begin
      RecLink(404,7,n,n);   /* Pos.Ablage holen */
      if (Erg<>3) and (erg<>6) then begin
        debug;
          RecLinkNext(451,7,n);
          CYCLE;
        end
      else begin
        RecCopy(411,401);
      end;
    end;

/*if (Erl.Rechnungsnr=2533) then debug;*/

    RecRead(404,1,y);
    if (Erl.K.Menge=0) then
      vZ # 0
    else
      vZ # Fix(vX / vY * Auf.A.Menge.Preis, 2);
    Auf.A.Rechnungspreis  # vZ;
    Auf.A.RechPreisW1     # Fix(Auf.A.Rechnungspreis / :Erl.Währungskurs: ,2);
    RecReplace(404,n);

    RecLinkNext(450,4,n);
  END;


  RecReadNext(450,1,n);
END;


RETURN;

FOR vX # 1 to 998 do begin
    vA # GetName(1,vX,0,0);
    If (Erg<>6) then CYCLE;
    If (vX=251) or (vX=406) or (vX=770) then CYCLE;

    Msg(alpha(vX),n,n);

    RecReadFirst(vX,1);
    WHILE (erg<>0) and (erg<>2) do begin
      if (erg=3) then debug;
      RecReadNext(vX,1,n);
    END;

END;

RETURN;


RecReadFirst(250,1);
WHILE (Erg<>2) and (erg<>0) do begin
  ClrRec(255);
  Art.SLK.Artikelnr # Art.Nummer;
  Art.SLK.Nummer    # 1;
  RecInsert(255,n);

  RecReadNext(250,1,n);
END;
RETURN;

RecReadFirst(103,1);
WHILE (Erg<>2) and (erg<>0) do begin
  if (:Adr.K.Währung:=0) then begin
    RecLock(130,1);
    :Adr.K.Währung: # 1;
    RecReplace(103,n);
  end;
  RecReadNext(103,1,n);
END;

RETURN;


ClrRec(100);
Adr.Stichwort # 'BSS';
RecRead(100,4,n);
vX # ErgX;

vX # vX;

RETURN;


RecLink(254,2,n,n);
if (erg<>6) then begin
DEBUG;
  SetResult(n);
  RETURN;
end;

Art.P.Nummer # RecLinkCount(250,6)+1;
SetResult(y);
RETURN;


RecReadFirst(401,1);
RecRead(401,1,n);
WHILE (Erg=6) do begin

  RecLink(401,1,n,n);

  RecLock(401,1);
  Auf.P.Wgr.Dateinr # Wgr.Dateinummer;
  if (Wgr.Dateinummer=250) then begin
    RecLink(401,2,n,n);
    if (:Art.ChargenführungYN:) then Auf.P.Wgr.Dateinr # 252;
  end;
  RecReplace(401,n);

  RecReadNext(401,1,n);
END;


RecReadFirst(501,1);
RecRead(501,1,n);
WHILE (Erg=6) do begin

  RecLink(501,1,n,n);

  RecLock(501,1);
  Ein.P.Wgr.Dateinr # Wgr.Dateinummer;
  if (Wgr.Dateinummer=250) then begin
    RecLink(501,2,n,n);
    if (:Art.ChargenführungYN:) then Ein.P.Wgr.Dateinr # 252;
  end;
  RecReplace(501,n);

  RecReadNext(501,1,n);
END;

RETURN;


ClrRec(200);
FOR vX # 10000 TO 20000 do begin
  Mat.nummer # vX;

  if (random < 0.3) then
    :Mat.Löschmarker: # '*'
  else
    :Mat.Löschmarker: # '';

  RecDelete(200);
/*  RecInsert(200,n);*/
END;

RETURN;

ClrFile(400);
ClrFile(401);
ClrFile(402);
ClrFile(403);
ClrFile(404);
ClrFile(405);
ClrFile(407);
ClrFile(408);
ClrFile(409);

ClrFile(500);
ClrFile(501);
ClrFile(502);
ClrFile(503);
ClrFile(504);
ClrFile(505);
ClrFile(506);

ClrFile(555);

/***
ClrFile(252);
ClrFile(253);

ClrFile(254);
****/

RETURN;

RecReadFirst(250,1);
RecRead(250,1,n);
WHILE (erg<>0) and (erg<>2) do begin
  ClrRec(252);
  Art.C.ArtikelNr # Art.Nummer;
  RecInsert(252,n);

  RecReadNext(250,1,n);
END;

/* ==== [END OF PROCEDURE] ============================================ */