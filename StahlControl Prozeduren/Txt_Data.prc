@A+
//===== Business-Control =================================================
//
//  Prozedur  Txt_Data
//                    OHNE E_R_G
//  Info
//
//
//  12.02.2009  AI  Erstellung der Prozedur
//  01.03.2010  AI  Textbedingung und Parameter genau umkehren
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//  sub Automatisch(aDatei    : int; aGStufe   : alpha; aGuete    : alpha; aWgr      : int; aAdr      : int) : int;
//
//========================================================================
@I:Def_Global

//========================================================================
//  Automatisch
//
//========================================================================
sub Automatisch(
  aDatei    : int;
  aGStufe   : alpha;
  aGuete    : alpha;
  aWgr      : int;
  aAdr      : int
) : int;
local begin
  Erx       : int;
  vBereich  : alpha;
  vGOK      : logic;
  vSOK      : logic;
  vWOK      : logic;
  vKOK      : logic;
  vI        : int;
  vMin      : int;
  vTexte    : int[15];
end;
begin

  if (aDatei=401) then
    if (Auf.Vorgangstyp=c_ANG) then
      vBereich # 'A'
    else
      vBereich # 'V';

  if (aDatei=501) then
      vBereich # 'E';

  vMin # 999;

  Erx # RecRead(837,1,_recFirst);   // Texte loopen
  WHILE (Erx<=_rLocked) do begin
    // falsche Bereiche überspringen
    if (StrFind(Txt.Bereichstring,vBereich,1)=0) then begin
      Erx # RecRead(837,1,_recNext);
      CYCLE;
    end;

    vKOK # n;
    vGOK # n;
    vSOK # n;
    vWOK # n;

    // AI 01.03.2010 alles genau umgekehrt
    // wenn im Text vorgabe ist, aber Parameter nicht passen -> überspringen
    if (("Txt.bei.Gütenstufe"<>'') and (aGStufe<>"Txt.bei.Gütenstufe")) or
      (("Txt.bei.Güte"<>'') and (aGuete<>"Txt.bei.Güte")) or
      ((Txt.bei.Warengruppe<>0) and (aWgr<>Txt.bei.Warengruppe)) or
      ((Txt.bei.Adressnr<>0) and (aAdr<>Txt.bei.Adressnr)) then begin
      Erx # RecRead(837,1,_recNext);
      CYCLE;
    end;

    if (aGStufe<>'') and ("Txt.bei.Gütenstufe"<>'') then  vSOK # y;
    if (aGuete<>'') and ("Txt.bei.Güte"<>'') then         vGOK # y;
    if (aWgr<>0) and (Txt.bei.Warengruppe<>0) then        vWOK # y;
    if (aAdr<>0) and (Txt.bei.Adressnr<>0) then           vKOK # y;

    vI # 0;
    if (vKOK) then begin
      if (vWOK) and (vSOK) and (vGOK) then   vI # 1;
      if (vWOK) and (vSOK) and (!vGOK) then  vI # 2;
      if (vWOK) and (!vSOK) and (vGOK) then  vI # 3;
      if (!vWOK) and (vSOK) and (vGOK) then  vI # 4;
      if (!vWOK) and (!vSOK) and (vGOK) then vI # 5;
      if (vWOK) and (!vSOK) and (!vGOK) then vI # 6;
      if (!vWOK) and (vSOK) and (!vGOK) then vI # 7;
      end
    else begin
      if (vWOK) and (vSOK) and (vGOK) then   vI # 8;
      if (vWOK) and (vSOK) and (!vGOK) then  vI # 9;
      if (vWOK) and (!vSOK) and (vGOK) then  vI # 10;
      if (!vWOK) and (vSOK) and (vGOK) then  vI # 11;
      if (!vWOK) and (!vSOK) and (vGOK) then vI # 12;
      if (vWOK) and (!vSOK) and (!vGOK) then vI # 13;
      if (!vWOK) and (vSOK) and (!vGOK) then vI # 14;
    end;

    if (vI<>0) then begin
      vTexte[vI] # Txt.Nummer;
      if (vMin>vI) then vMin # vI;
    end;

    Erx # RecRead(837,1,_recNext);
  END;

  if (vMin<>999) then RETURN vTexte[vMin];

  RETURN 0;

end;


//========================================================================