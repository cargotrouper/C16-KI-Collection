@A+
//===== Business-Control =================================================
//
//  Prozedur  _Procinfo
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB MakeProcInfo(aName : alpha)
//
//========================================================================
@I:Def_global

define begin
  Print(a) : TextLineWrite(vTxtHdl, Textinfo(vTxtHdl,_TextLines)+1,a,_TextLineInsert);
end;


//========================================================================
//  MakeProcInfo
//
//========================================================================
Sub MakeProcInfo(aName : alpha)
local begin
  vTxtHdl : int;
  vPrcHdl : int;

  vA      : alpha(1000);
  vB      : alpha(1000);
  vZ      : int;
  vMax    : int;
  vx,vy   : int;
  vC      : int;
  vOk     : logic;
end;
begin

  vTxtHdl # TextOpen(10);
  vPrcHdl # TextOpen(10);
  TextRead(vPrcHdl,aName,_TextProc);
  vMax # TextInfo(vPrcHdl,_TextLines);

  Print('Prozedur : '+aName);
  Print('');
  Print('//  Subprozeduren');

  vZ # 0;
  WHILE (vZ<vMax) do begin
    inc(vZ);
    vA # TextLineRead(vPrcHdl,vZ,0);
    vB # StrCnv(vA,_StrUpper);

    vOk # n;
    if (Strfind(vB,'SUB ',0)=1) then begin

      vB # '//    SUB ';
      vC # 0;
      vA # StrCut(vA,4,200);
      REPEAT
        vA # StrAdj(vA,_StrAll);
        vY # StrFind(vA,'//',0);
        if (vY=0) then vY # StrLen(vA)
        else vY # vY - 1;
        FOR vX # 1 loop inc(vX) while (vX<=vY) do begin
          if (StrCut(vA,vX,1)='(') then begin
            vC # vC + 1;
            if (vOK=n) then vOK # y;
            end
          else begin
            if (StrCut(vA,vX,1)=')') then vC # vC -1;
          end;
        END;

        vB # vB + StrCut(vA,1,vY);

        if (vC>0) or (vOK=n) then begin
          inc(vZ);
          vA # ''+TextLineRead(vPrcHdl,vZ,0);
        end;

      UNTIl (vC<=0) and (vOK);

      vB # Str_ReplaceAll(vB,';)',')');
      vB # Str_ReplaceAll(vB,';','° ');
      vB # Str_ReplaceAll(vB,'° ','; ');
      vB # Str_ReplaceAll(vB,':',' ° ');
      vB # Str_ReplaceAll(vB,' ° ',' : ');
      Print(vB);
    end;
  END;



  TextClose(vPrcHdl);
//  Txtwrite(vTxtHdl,'C:\debug\debug.txt',_TextExtern);
  Txtwrite(vTxtHdl,'',_TextClipboard);
  TextClose(vTxtHdl);
end;


//========================================================================
//
//
//========================================================================
MAIN
local begin
  vName : alpha;
end;
begin
  REPEAT
    vName # Prg_Para_Main:ParaAuswahl('Prozeduren',vName,'z');
    if (vName<>'') then MakeProcInfo(vName);
  UNTIl (vName='');
end;


//========================================================================