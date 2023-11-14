@A+
//===== Business-Control =================================================
//
//  Prozedur  Mat_Entstehung
//                  OHNE E_R_G
//  Info
//
//
//  16.10.2019  AH  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_global
@I:Def_Aktionen

//========================================================================
//  WriteLn
//
//========================================================================
sub WriteLn(aFile : int; aText : alpha(500));
begin
  aText # Lib_strings:Strings_DOS2WIN(aText);
  aText # aText + StrChar(13) + StrChar(10);
  FSIWrite(aFile, aText);
end;

//========================================================================
//========================================================================
sub IsAusBaFM(aMat : int) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(707);
  BAG.FM.Materialnr # aMat;
  Erx # RecRead(707,3,0);
  if (Erx>_rMultikey) then RETURN false;

  RecbufClear(701);
  if (BAG.FM.InputID=0) then RETURN true;
  Erx # RecLink(701,707,9,_recFirst); // Input holen
  if (Erx>_rLocked) then RecbufClear(701);

  RETURN true;
end;

//========================================================================
sub IsAusMatAkt(aMat : int) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(204);
  Mat.A.Entstanden # aMat;
  Erx # RecRead(204,6,0);
  if (Erx>_rNoRec) then RETURN false;
  if (Mat.A.Entstanden<>aMat) then RETURN false;
  
  RETURN true;
end;


//========================================================================
sub PrintMat(
  aFile   : int);
local begin
  vCol    : alpha;
  vA      : alpha(500);
  vKombi  : logic;
  vIstStk : int;
  vIstGew : float;
end;
begin
  vIstStk # Mat.Bestand.Stk;
  vIstGew # Mat.Bestand.Gew;
  Mat_B_Data:BewegungenRueckrechnen(1.1.1900);

//debug('id'+aint(Mat.Nummer)+' '+anum(Mat.Dicke, Set.Stellen.Dicke)+'x'+anum(Mat.Breite, Set.Stellen.Breite)+' '+anum(Mat.Bestand.Gew,0)+'kg');

  if (vIstGew<>Mat.Bestand.Gew) then begin
    vCol # 'gray';
  end
  else begin
    if (Mat.Status<=c_status_bisFrei) then
      vCol # 'green'
    if (Mat.Status>c_status_bisFrei) and (Mat.Status<c_Status_bestellt) then
      vCol # 'cyan';
    if (Mat.Status>=c_Status_bestellt) and (Mat.Status<=c_Status_bisEK) then
      vCol # 'blue';
    if ((Mat.Status>c_Status_bisEK) and (Mat.Status<c_Status_gesperrt)) or (Mat.Status=c_Status_inVLDAW) then
      vCol # 'yellow';
    if (Mat.Status>=c_Status_gesperrt) then
      vCol # 'red';
  end;

  vKombi # (Mat.Ursprung=0);

  vA # '';
  if (vKombi) then
    vA # '{rank="sink"; ';
  vA # vA + 'id'+aint(Mat.Nummer);
  vA # vA + ' [label="Mat.'+aint(Mat.Nummer)+' \n';

  // Knotendetails in eigener Funktion je nach Materialtyp zusammenstellen
  vA # vA + Mat_Stammbaum:_KnotenMaterialdetail(200, vIstStk, vIstGew) + '"';


  if ("Mat.Löschmarker"<>'') then
    vA # vA + ', style=filled, fillcolor=gray'
  else
    vA # vA + ', style=bold';
  vA # vA +', fontsize=14, color='+vCol;

  if (Mat.Status=c_Status_geliefert) then
    vA # vA + ', shape=invhouse'
  else
    vA # vA + ', shape=box';

  vA # vA + ']';
  if (vKombi) then
    vA # vA + '}';

  WriteLn(aFile, vA);
end;


//========================================================================
sub PrintAkt(aFile : int)
local begin
  Erx     : int;
  vAkt    : alpha;
  vA      : alpha(500);
  vSplit  : logic;
  vBARest : logic;
  vSplitC : int;
end;
begin
  vAkt # 'akt'+aint(Mat.A.Materialnr)+'_'+aint(Mat.A.Aktion);
  vSplit  # n;
  vBARest # n;
  vA # vAkt;
  vA # vA + ' [label="'+Str_Token(Mat.A.Bemerkung,' ',1);
  if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
    // MATPRD? qqwwee
    if (Mat.A.Aktionsnr<>0) then begin
      vA # vA + ' '+aint(Mat.A.Aktionsnr);
      if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+aint(Mat.A.Aktionspos);
      if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos2);
      if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos3);
    end;
    vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
    vA # vA + 'KOMBI';
  end
//        else if (Mat.A.Aktionstyp=c_Akt_Schrott) or (BAG.P.Aktion2 <> '') then begin  13.09.2017
  else if (Mat.A.Aktionstyp=c_Akt_Schrott) then begin
    if (Mat.A.Aktionsnr<>0) then vA # vA + ' '+aint(Mat.A.Aktionsnr);
    if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+aint(Mat.A.Aktionspos);
    if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos2);
    if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos3);
    vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
  end
  else if (Mat.A.Aktionstyp=c_Akt_BA_Rest) or (Mat.A.Aktionstyp=c_Akt_BA_Fertig) then begin
    if (Mat.A.Aktionsnr<>0) then vA # vA + ' '+aint(Mat.A.Aktionsnr);
    if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+aint(Mat.A.Aktionspos);
    if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos2);
    if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+aint(Mat.A.Aktionspos3);
    vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';

    BAG.P.Nummer    # Mat.A.Aktionsnr
    BAG.P.Position  # Mat.A.Aktionspos
    Erx # RecRead(702, 1, 0); // BA.Pos holen
    if (Erx > _rLocked) then  RecBufClear(702);
    if (Mat.A.Aktionstyp=c_Akt_BA_Rest) then begin
      vBARest # y;
      vA # vA + BAG.P.Aktion2;
    end
    else begin
//qqwwee            if (BAG.P.Aktion=c_BAG_MatPrd) then
//              vA # vA + 'KOMBI'
//            else
        vA # vA + BAG.P.Aktion2;
    end;
  end
  else begin
    vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
    vA # vA + 'SPLITTUNG';
    vSplitC # vSplitC + 1;
    vSplit # Y;
  end;
  vA # vA +'", fontsize=10, shape=ellipse];';
  WriteLn(aFile,vA);

  vA # 'id'+aint(Mat.A.Materialnr)+' -> '+vAkt;
  vA # vA + ' [arrowhead=none];';
  WriteLn(aFile, vA);

  vA # vAkt+' -> id'+aint(Mat.A.Entstanden);
  vA # vA +';';
  WriteLn(aFile, vA);
end;


//========================================================================
sub PrintFM(aFile : int)
local begin
  Erx     : int;
  vAkt    : alpha;
  vA      : alpha(500);
end;
begin
  vAkt # 'akt'+aint(BAG.FM.Nummer)+'_'+aint(BAG.FM.Position)+'_'+aint(BAG.FM.Fertigung)+'_'+aint(BAG.FM.Fertigmeldung);

  Erx # RecLink(702,707,2,_recFirst);   // BA-Position holen

  vA # vAkt;
  vA # vA + ' [label="'+BAG.P.Bezeichnung;
  vA # vA + ' '+aint(BAG.FM.Nummer)+'/'+aint(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung);
  vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(BAG.FM.Anlage.Datum)+'\n';

  vA # vA +'", fontsize=10, shape=ellipse];';
  WriteLn(aFile,vA);

  vA # 'id'+aint(BAG.IO.Materialnr)+' -> '+vAkt;
  vA # vA + ' [arrowhead=none];';
  WriteLn(aFile, vA);

  vA # vAkt+' -> id'+aint(BAG.FM.Materialnr);
  vA # vA +';';
  WriteLn(aFile, vA);
end;


//========================================================================
sub Inner(
  aFile : int;
  aMat  : int) : logic;
local begin
  Erx   : int;
  vMat  : int;
end;
begin
  if (aMat=0) then RETURN false;
 
  vMat # aMat;
  REPEAT

    Erx # Mat_Data:Read(vMat);
    if (Erx<200) then BREAK;

    PrintMat(aFile);

    if (Mat.Nummer=Mat.Ursprung) then BREAK;

    if (IsAusBaFM(vMat)) then begin
      PrintFM(aFile);
      if (BAG.IO.Materialnr=0) then BREAK;
      if (BAG.IO.Materialnr=vMat) then BREAK;
      vMat # BAG.IO.Materialnr;
      CYCLE;
    end;
    
    if (IsAusMatAkt(vMat)) then begin
      PrintAkt(aFile);
      if (Mat.A.Materialnr=vMat) then BREAK;
      vMat # Mat.A.Materialnr;
      CYCLE;
    end;

    BREAK;
  UNTIL (2=1);
  
end;


//========================================================================
//========================================================================
sub Entstehung(aMat : int) : logic
local begin
  v200      : int;
  vBildname : alpha(500);
  vTextname : alpha(500);
  vA        : alpha(500);
  vB        : alpha(500);
  vFile     : int;
  vOK       : logic;
end;
begin

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');

  // Ankerfunktion?
//  if (RunAFX('Mat.Stammbaum','')<>0) then RETURN;

  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

  vFile # FSIOpen(vTextName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile=0) then RETURN false;
  
  v200 # RekSave(200);
  APPOFF();

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="MATERIALSTAMMBAUM '+aint(Mat.Nummer)+vA+'"');
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  Writeln(vFile, 'nodesep=0.05');

  Inner(vFile, aMat);

  WriteLn(vFile,'');
  WriteLn(vFile, '}');
  FSIClose(vFile);
    
  APPON();
  RekRestore(v200);

  SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);

  // externes Bild anzeigen
  Dlg_Bild('*'+vBildName);

end;

//========================================================================