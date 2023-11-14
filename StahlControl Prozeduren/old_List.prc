/* ==== Business-Control ============================================== */

/*  Prozedur  old_List
 *
 *  Beschreibung
 *
 *      001 03.08.2002  AI  Erstellung der Prozedur
 */

/* ==== Include ======================================================= */

/* ==== Deklarationsteil ============================================== */
arg
  aBefehl # alpha;
  aNr     # ints;
  aName   # alpha;
  aWert   # num

var
  vL      # intl;
  vX      # intl;
  vY      # ints;
  vA      # Alpha(250)

/* ==== Anweisungsteil ================================================ */

Case Sndx(aBefehl,1) of

  'TXT2PRINTER' do begin

    TextOpen(1,10);
    TextLoad(1,'*C:\Output.bcs',n);

    TextDelLine(1,TextLineCnt(1));
    vX # TextReplace(1,char(12),1,1,n,n,char(13)+char(12),0);
    vX # 1;
    vX # TextSearch(1,Char(13)+char(12),vX,1,n,n);
    WHILE (vX>0) do begin
      vA # TextGetLine(1,vX);
      if (Len(vA)>2) then begin
        TextPutLine(1,vX,Char(13)+Char(12));
        TextInsLine(1,vX+1,Copy(vA,3,len(vA)-2));
        vX # vX + 1;
      end;
      vX # vX + 1;
      vX # TextSearch(1,Char(13)+char(12),vX,1,n,n);
    END;

    TextSave(1,'~TMP.'+Alpha(UserID),n);
    TextClose(1);

    LoadPDV(aName);
    SetPdv(0,0,0,0);
    SetPdv(0,0,2,0);
    SetPdv(0,0,3,1);
    PrintOn;
    Text('~TMP.'+Alpha(UserID),y);
    PrintOff;
    LoadPDV('CLOSE');

    DelText('~TMP.'+Alpha(UserID));
    Erase('C:\Output.bcs');
  end;

  'LOADPDV' do begin
    LoadPDV(aName);
    SetPdv(0,0,2,0);
    SetPdv(0,0,3,1);
    if (aNr<>0) then SetPDV(aNr,0,0,0);
  end;

  'LFSTART' do begin
    SetListDev(aNr,n);
    LfStart(aNr,aName);
  end;

  'LFEND' do begin
    LfEnd;
    LoadPDV('CLOSE');
  end;

  'LFPRINT' do begin
    if (aName<>'') then Gv.Alpha.01 # aName;
    LfPrint(aNr);
  end;

  'SETSUM' do begin
    SetSum(aNr,aWert);
  end;

  'GETSUM' do begin
    aWert # Sum(aNr);
  end;

  'ADDSUM' do begin
    SetSum(aNr,Sum(aNr) + aWert);
  end;

  'LST.700002' do begin
   SetListDev(aNr,n);
   list(anr,aname,0,abefehl,n,n);
    LoadPDV('CLOSE');
  end

end;

/* ==== [END OF PROCEDURE] ============================================ */