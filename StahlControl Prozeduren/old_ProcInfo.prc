/* ==== Business-Control ============================================== */

/*  Prozedur  old_ProcInfo
 *
 *  Info
 *
 *      001 24.04.2004  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */

var
    vName       # alpha(20);            /* Name der aktuellen Prozedur  */
    vLine       # alpha(250);           /* aktuelle Prozedurzeile       */
    vProzeduren # intl;                 /* Anzahl der Prozeduren        */
    vZeilen     # intl;                 /* Anzahl der Zeilen            */
    vMaxZeilen  # intl;                 /* Längste Prozedurlänge        */
    vMaxZName   # alpha(20);            /* Längste Prozedur             */
    vBefehlsz   # intl;                 /* Anzahl der Befehlszeilen     */
    vLeerzeilen # intl;                 /* Anzahl der Leerzeilen        */
    vBytes      # intl;                 /* Größe gesamt                 */
    vCurBytes   # intl;                 /* Größe aktuelle Prozedur      */
    vMaxBytes   # intl;                 /* Größte Prozedurgröße         */
    vMaxBName   # alpha(20);            /* Größte Prozedur              */
    vComment    # logic;                /* innerhalb eines Kommentars   */
    i           # ints                  /* Schleifenzähler              */

/* ==== Anweisungsteil ================================================ */

TextOpen(1,16);                         /* Textpuffer öffnen            */

vName # ParaRead(8,0,'');               /* erste Prozedur lesen         */
vName # ParaRead(8,0,vName);
WHILE (Erg = 6) do begin
/*    Status('Prozedur '+vName+' ...');*/

    TextClr(1);                         /* Textpuffer leeren            */
    ProcLoad(1,vName,n);                /* Prozedur laden               */
    vProzeduren # vProzeduren + 1;      /* Werte hochzählen             */
    vZeilen     # vZeilen + TextLineCnt(1);
    vCurBytes   # 0;
    vComment    # n;
    for i # 1 to TextLineCnt(1) do begin
        vLine       # TextGetLine(1,i);
        vBytes      # vBytes    + Len(vLine) + 2;
        vCurBytes   # vCurBytes + Len(vLine) + 2;
        if Not(vComment) and (Scan(vLine,'/*')) and Not(Scan(vLine,'*/')) then
            vComment # y;
        if Not(vComment) and (Len(CutStr(vLine,n)) > 0) then begin
            if (Copy(CutStr(vLine,n),1,1) <> '/') then
                vBefehlsz # vBefehlsz + 1;
        end;
        if (Len(CutStr(vLine,n)) = 0) then
            vLeerzeilen # vLeerzeilen + 1;
        if (vComment) and (Scan(vLine,'*/')) then
            vComment # n;
    end;

    if (TextLineCnt(1) > vMaxZeilen) then begin
        vMaxZName   # vName;
        vMaxZeilen  # TextLineCnt(1);
    end;

    if (vCurBytes > vMaxBytes) then begin
        vMaxBName   # vName;
        vMaxBytes   # vCurBytes;
    end;

    vName # ParaReadNext(8,0,vName);    /* nächste Prozedur lesen       */
END;

TextClose(1);                           /* Textpuffer schließen         */

/*Status('');                            /* Meldungszeile löschen        */
RefreshAll;                             /* Bildschirm neu aufbauen      */

MsgBox('Prozeduren',
        'Der Datenraum '+DbName+' enthält:'+Char(13)+
        CutStr(Alpha(vProzeduren,4,0,n,n),y)+' Prozeduren mit insgesamt'+Char(13)+
        CutStr(Alpha(vZeilen,8,0,y,n),y)+' Zeilen und '+CutStr(Alpha(vBytes,8,0,y,n),y)+ ' Bytes,'+Char(13)+
        CutStr(Alpha(vBefehlsz,8,0,y,n),y)+' Befehlszeilen und '+CutStr(Alpha(vLeerzeilen,8,0,y,n),y)+' Leerzeilen.'+Char(13)+
        'Längste Prozedur: '+vMaxZName+', '+CutStr(Alpha(vMaxZeilen,8,0,y,n),y)+' Zeilen'+Char(13)+
        'Größte Prozedur: ' +vMaxBName+', '+CutStr(Alpha(vMaxBytes ,8,0,y,n),y)+' Bytes',
        1,0,0);

SetFKey(0);

/* ==== [END OF PROCEDURE] ============================================ */