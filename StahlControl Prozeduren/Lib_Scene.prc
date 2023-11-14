@A+
/*===== Business-Control =================================================

Prozedur:   Lib_Scene

OHNE E_R_G

Info:
Funktionen für Daten-Szenarien

Historie:
2023-08-02  AH  Erstellung der Prozedur
2023-08-08  AH  Patch für leere Tabellen

Subprozeduren:

  sub Load()
  sub Save()
========================================================================*/
@I:Def_Global

/*========================================================================
Defines
========================================================================*/
define begin
  cPath       : 'C:\Workspaces\Repos\Scenario\'
  cTransName  : 'AUTO_SZENE'
end


//========================================================================
//========================================================================
sub BuildC16Transfer(
  aDatei  : int;
  aTName  : alpha;
  );
begin
  GV.Alpha.02 # aTName;
  CallOld('old_LibTransfersC16',aDatei, 'CREATE');
end;


//========================================================================
//========================================================================
sub ExportC16Transfer(
  aDatei  : int;
  aTName  : alpha;
  aPath   : alpha(250);
  );
begin
  GV.Alpha.01 # aPath;
  GV.Alpha.02 # aTName;
  CallOld('old_LibTransfersC16',aDatei, 'EXPORT');
end;


//========================================================================
//========================================================================
sub ImportC16Transfer(
  aDatei  : int;
  aTName  : alpha;
  aPath   : alpha(250));
begin
  GV.Alpha.01 # aPath;
  GV.Alpha.02 # aTName;
  CallOld('old_LibTransfersC16',aDatei, 'IMPORT');
end;


/*========================================================================
2023-08-02  AH
========================================================================*/
sub ExportTable(
  aDlg    : int;
  aPfad   : alpha(4000);
  aDatei  : int)
  : alpha       // Fehlertext
local begin
  Erx         : int;
  vErr        : alpha(1000);
end
begin
  if (FileInfo(aDatei,_FileExists)=0) then RETURN 'no Table';
  
  Lib_FileIO:CreateFullpath(aPfad);
  aPfad # aPfad + '\'+aint(aDatei)+'.txt';

  Lib_Progress:Reset(aDlg, 'Export '+aint(aDatei)+'...', 999);

  // Transfer aufbauen...
//  Lib_Transfers:DeleteTransfer(aDatei, 'AUTO_SQL');
  BuildC16Transfer(aDatei,cTransname);

  FsiDelete(aPfad);
  if (RecInfo(aDatei,_RecCount)>0) then
    ExportC16Transfer(aDatei, cTransName, aPfad);
end;


/*========================================================================
2023-08-02  AH
========================================================================*/
sub ImportTable(
  aPfad   : alpha(4000);
  aDatei  : int;
  )
  : alpha       // Fehlertext
local begin
  Erx         : int;
  vErr        : alpha(1000);
end
begin
  if (FileInfo(aDatei,_FileExists)=0) then RETURN 'no Table';

  aPfad # aPfad + '\'+aint(aDatei)+'.txt';

  // Transfer aufbauen...
// BuildC16Transfer(aDatei);
  RekDeleteAll(aDatei);
  if (Lib_FileIO:FileExists(aPFad)) then
    ImportC16Transfer(aDatei, cTransname, aPfad);
  
  if (Lib_Odbc:ScriptOneTable(aDatei,TRUE)) then begin
    if (Lib_Odbc:SyncOneTable(aDatei,TRUE)) then begin
    end;
  end;
end;


/*========================================================================
2023-08-07  AH
  Call Lib_Scene:Save
========================================================================*/
sub Save()
local begin
  vDlg    : int;
  vI      : int;
  vMax    : int;
  vSzene  : alpha(4000);
  vPfad   : alpha(4000);
  vA      : alpha;
end;
begin

  if (Lib_SFX:Check_AFX('Scene')=false) then begin
    Msg(99,'AFX "SZENE" muss gesetzt sein!',0,0,0);
    RETURN;
  end;
  vPfad # cPath+Set.Installname;
  if (Call(AFX.Prozedur, var vPfad, var vSzene)=false) then RETURN;

  vDlg # Lib_Progress:Init('Szenarien Export...', 999, true);

  vMax # Lib_Strings:Strings_Count(vSzene,',') + 1;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    vA # Str_Token(vSzene,',',vI);
    if (vA='') then CYCLE;
    ExportTable(vDlg, vPfad, cnvia(vA));
  END;

  Lib_Progress:Term(vDlg);
end


/*========================================================================
2023-08-07  AH
  Call Lib_Scene:Load
========================================================================*/
sub Load()
local begin
  vI      : int;
  vMax    : int;
  vSzene  : alpha(4000);
  vPfad   : alpha(4000);
  vA      : alpha;
end;
begin

  if (Lib_SFX:Check_AFX('Scene')=false) then begin
    Msg(99,'AFX "SZENE" muss gesetzt sein!',0,0,0)
    RETURN;
  end;
  vPfad # cPath+Set.Installname;
  if (Call(AFX.Prozedur, var vPfad, var vSzene)=false) then RETURN;
  
  vMax # Lib_Strings:Strings_Count(vSzene,',') + 1;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=vMax) do begin
    vA # Str_Token(vSzene,',',vI);
    if (vA='') then CYCLE;
    ImportTable(vPfad, cnvia(vA));
  END;

  // 2023-08-21 AH:
  if (Lib_Odbc:ScriptOneTable(1000,TRUE)) then begin
    if (Lib_Odbc:SyncOneTable(1000,TRUE)) then begin
    end;
  end;

end


/*========================================================================
2023-08-07  AH
  DEMO
========================================================================*/
sub TestSzene(
  var aPath   : alpha;
  var aSzene  : alpha;
  ) : logic
begin
  aSzene # '';
  aSzene # aSzene + '200,201,202,203,210,';                     // Material
  aSzene # aSzene + '400,401,402,403,404,405,410,411,';         // Auftrag
  aSzene # aSzene + '440,441,';                                 // Lieferscheine
  aSzene # aSzene + '450,451,460,461,465,470,';                 // Erlöse + OPs
  aSzene # aSzene + '500,501,502,503,504,505,506,507,510,511,'; // Bestellung
//  aSzene # aSzene + '700,701,702,703,704,705,706,707,708,709,710,711,'; // BAG

  aSzene # aSzene + '901,';                                     // Nummernkreise
  
  RETURN true;
end;


//========================================================================