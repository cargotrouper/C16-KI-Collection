@A+
//===== Business-Control =================================================
//
//  Prozedur  Mat_Stammbaum
//                  OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  26.10.2010  AI  Anpassung an manuelle Schrottung
//  01.08.2012  AI  Kommissionsnummer wir dmit angedruckt
//  30.04.2013  ST  Darstellung der Knotendetails in sub ausgegliedert
//  16.06.2014  ST  Knotendarstellung, Coil = Standard, da Materialtyp kein Pflichtfeld mehr ist
//  15.10.2014  AH  MatSofortInAlbage
//  10.07.2015  AH  Splitten wird "einfach linear" dargestellt
//  06.06.2016  AH  Directory auf %temp%
//  09.08.2018  ST  Stammbaumdruck auf kombinierter Karte angepasst  Projekt 1849/18
//  05.04.2022  AH  Kombikarten zeigen kompletten Baum an, Markierungsfarbe
//  2022-06-28  AH  ERX
//  2022-12-20  AH  GesLänge kommt primär aus Mengenfeld
//
//  Subprozeduren
//  sub WriteLn(aFile : int; aText : alpha(500));
//  sub NimmMaterial(aNr : int; aFile : int);
//  sub Stammbaum();
//  sub _KnotenMaterialdetail() : alpha
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

define begin
  Trim(a) : StrAdj(AInt(a),_Strbegin)
  TrimF(a,b) : StrAdj(cnvaf(a,_Fmtnumnogroup,0,b),_Strbegin)
end;

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
//  CHeck
//
//========================================================================
sub Check(
  aWort : alpha;
  aTxt  : handle;
  aIns  : logic;
) : logic;
local begin
  vItem   : handle;
end;
begin

  aWort # '|'+aWort + '|';

  if (aIns=false) then begin
    RETURN (TextSearch(aTxt, 1,1, _TextSearchCI, aWort)=0);
  end;

  if (TextSearch(aTxt, 1,1, _TextSearchCI, aWort)>0) then RETURN false;
  TextAddLine(aTxt, aWort);

  RETURN true;
end;


//========================================================================
//  _KnotenMaterialdetail
//    Gibt den Detailbereich für ein Materialknoten je nach Materialtyp
//    zurück. z.B. Coilabmessung oder Rohrabmessung
//========================================================================
sub _KnotenMaterialdetail(
  aDatei  : int;
  aIstStk : int;
  aIstGew : float;
) : alpha
local begin
  vA            : alpha(1000);
  vGesLaeng     : float;
  vMMzuMOffset  : float;
end;
begin
  vMMzuMOffset  # 10000.0;

  // Materialkarte im Puffer als Ausgangspunkt für Prüfung
  RekLink(819, aDatei,1,0);   // Warengruppe lesen

  case (Wgr.Materialtyp) of

    // Tafel
    c_WGRTyp_Tafel : begin
        vA # vA + "Mat.Güte"+'  ';
        vA # vA + TrimF(Mat.Dicke,2)+' x '+TrimF(Mat.Breite,1);
        vA # vA + ' x '+TrimF("Mat.Länge",1);
        vA # vA + 'mm\n';
        if (Mat.Kommission<>'') then
          vA # vA + 'Kom.:'+Mat.KommKundenSWort+'('+Mat.Kommission+')\n';
        vA # vA + Trim(aIstStk)+' Stk     '+TrimF(aIstGew,0)+' kg';
        if (aIstStk<>Mat.Bestand.Stk) or (aIstGew<>Mat.Bestand.Gew) then
          vA # vA + '\n(Ursp.:'+Trim(Mat.Bestand.Stk)+' Stk     '+TrimF(Mat.Bestand.Gew,0)+' kg)';
    end;

    // Stab
    c_WGRTyp_Stab : begin
        vA # vA + "Mat.Güte"+'  ';
        vA # vA + TrimF(Mat.RAD,2);
        vA # vA + ' x '+TrimF("Mat.Länge",1);
        vA # vA + 'mm\n';
        if (Mat.Kommission<>'') then
          vA # vA + 'Kom.:'+Mat.KommKundenSWort+'('+Mat.Kommission+')\n';
        vA # vA + Trim(aIstStk)+' Stk     '+TrimF(aIstGew,0)+' kg';
        if (aIstStk<>Mat.Bestand.Stk) or (aIstGew<>Mat.Bestand.Gew) then
          vA # vA + '\n(Ursp.:'+Trim(Mat.Bestand.Stk)+' Stk     '+TrimF(Mat.Bestand.Gew,0)+' kg)';

        vGesLaeng # CnvFi(Mat.Bestand.Stk) * "Mat.Länge";
        /// 2022-12-20  AH
        if (Mat.MEH='m') then vGesLaeng # Mat.Bestand.Menge * 1000.0;
        if (vGesLaeng > vMMzuMOffset) then
          vA # vA + '    ' + TrimF(vGesLaeng/1000.0,0) +' m';
        else
          vA # vA + '    ' + TrimF(vGesLaeng,0) +' mm';
    end;

    // Rohr
    c_WGRTyp_Rohr : begin
        vA # vA + "Mat.Güte"+'  ';
        vA # vA + TrimF(Mat.RAD,2);
        vA # vA + ' x ' + TrimF(Mat.RID,2);
        vA # vA + ' x '+TrimF("Mat.Länge",1);
        vA # vA + 'mm\n';
        if (Mat.Kommission<>'') then
          vA # vA + 'Kom.:'+Mat.KommKundenSWort+'('+Mat.Kommission+')\n';
        vA # vA + Trim(aIstStk)+' Stk     '+TrimF(aIstGew,0)+' kg';
        if (aIstStk<>Mat.Bestand.Stk) or (aIstGew<>Mat.Bestand.Gew) then
          vA # vA + '\n(Ursp.:'+Trim(Mat.Bestand.Stk)+' Stk     '+TrimF(Mat.Bestand.Gew,0)+' kg)';

        vGesLaeng # CnvFi(Mat.Bestand.Stk) * "Mat.Länge";
        /// 2022-12-20  AH
        if (Mat.MEH='m') then vGesLaeng # Mat.Bestand.Menge * 1000.0;
        if (vGesLaeng > vMMzuMOffset) then
          vA # vA + '    ' + TrimF(vGesLaeng/1000.0,0) +' m';
        else
          vA # vA + '    ' + TrimF(vGesLaeng,0) +' mm';
    end;

    // Profil
    c_WGRTyp_Profil : begin
        vA # vA + "Mat.Güte"+'  ';
        vA # vA + TrimF(Mat.Dicke,2)+' x '+TrimF(Mat.Breite,2);
        vA # vA + ' x ' + TrimF(Mat.RAD,2);
        vA # vA + ' x '+ TrimF("Mat.Länge",1);
        vA # vA + 'mm\n';
        if (Mat.Kommission<>'') then
          vA # vA + 'Kom.:'+Mat.KommKundenSWort+'('+Mat.Kommission+')\n';
        vA # vA + Trim(aIstStk)+' Stk     '+TrimF(aIstGew,0)+' kg';
        if (aIstStk<>Mat.Bestand.Stk) or (aIstGew<>Mat.Bestand.Gew) then
          vA # vA + '\n(Ursp.:'+Trim(Mat.Bestand.Stk)+' Stk     '+TrimF(Mat.Bestand.Gew,0)+' kg)';

        vGesLaeng # CnvFi(Mat.Bestand.Stk) * "Mat.Länge";
        /// 2022-12-20  AH
        if (Mat.MEH='m') then vGesLaeng # Mat.Bestand.Menge * 1000.0;
        if (vGesLaeng > vMMzuMOffset) then
          vA # vA + '    ' + TrimF(vGesLaeng/1000.0,0) +' m';
        else
          vA # vA + '    ' + TrimF(vGesLaeng,0) +' mm';
    end;

    // COIL oder unbekannter Typ
    otherwise begin
    // COIL
        vA # vA + "Mat.Güte"+'  ';
        vA # vA + TrimF(Mat.Dicke,2)+' x '+TrimF(Mat.Breite,1);
        vA # vA + 'mm\n';
        if (Mat.Kommission<>'') then
          vA # vA + 'Kom.:'+Mat.KommKundenSWort+'('+Mat.Kommission+')\n';

        vA # vA + Trim(aIstStk)+' Stk     '+TrimF(aIstGew,0)+' kg';
        if (aIstStk<>Mat.Bestand.Stk) or (aIstGew<>Mat.Bestand.Gew) then
          vA # vA + '\n(Ursp.:'+Trim(Mat.Bestand.Stk)+' Stk     '+TrimF(Mat.Bestand.Gew,0)+' kg)';
    end;

  end; // case (Wgr.Materialtyp) of

  RETURN vA;
end;



//========================================================================
//  _Knoten
//
//========================================================================
sub _Knoten(
  aDatei  : int;
  aName   : alpha;
  aFile   : handle;
  aIstStk : int;
  aIstGew : float;
  aMarked : logic);
local begin
  vA      : alpha(500);
  vCol    : alpha;
  vKombi  : logic;
end;
begin
/*
  if (Mat.Status<100) then
    vCol # 'green'
  if (Mat.Status>=100) and (Mat.Status<500) then
    vCol # 'cyan';
  if (Mat.Status>=500) and (Mat.Status<600) then
    vCol # 'blue';
  if ((Mat.Status>=600) and (Mat.Status<900)) or (Mat.Status=440) then
    vCol # 'yellow';
  if (Mat.Status>=900) then
    vCol # 'red';
*/

  if (aIstGew<>Mat.Bestand.Gew) then begin
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

  //vA # 'id'+Trim(Mat.Nummer);
  vKombi # (Mat.Ursprung=0);

  vA # '';
  if (vKombi) then
    vA # '{rank="sink"; ';
  vA # vA + 'id'+aName;
  vA # vA + ' [label="Mat.'+Trim(Mat.Nummer)+' \n';

  // Knotendetails in eigener Funktion je nach Materialtyp zusammenstellen
  vA # vA + _KnotenMaterialdetail(aDatei, aIstStk, aIstGew) + '"';


  if ("Mat.Löschmarker"<>'') then
    vA # vA + ', style=filled, fillcolor=gray'
  else
    vA # vA + ', style=bold';
  vA # vA +', fontsize=14, color='+vCol;
  if (aMarked) then vA # vA + ', fontcolor=orange'; // 05.04.2022 AH
  if (Mat.Status=c_Status_geliefert) then
    vA # vA + ', shape=invhouse'
  else
    vA # vA + ', shape=box';

  vA # vA + ']';
  if (vKombi) then
    vA # vA + '}';
  WriteLn(aFile, vA);

//debug('drucke '+aint(mat.nummer)+'  '+aint(mat.bestand.stk));
end;


//========================================================================
//  NimmMaterial
//
//========================================================================
sub NimmMaterial(
  aNr           : int;
  aFile         : handle;
  aTxt          : handle;
  opt aName     : alpha;
  opt aMarkMat  : int);
local begin
  Erx     : int;
  vBuf200 : handle;
  v200    : handle;
  vBuf210 : handle;
  vBuf204 : handle;
  vA      : alpha(500);
  //vA2     : alpha;
  vCol    : alpha;
  vOK     : logic;
  vNr     : int;
  vSplit  : logic;
  vSplitC : int;
  vI      : int;
  vName   : alpha;
  vIstGew : float;
  vIstStk : int;
  vBARest : logic;
  vDatei  : int;
  vAkt    : alpha;
end;
begin

  // shapes: invhouse

  // Backup
  vBuf200 # RekSave(200);
  vBuf210 # RekSave(210);

  // Karte holen
/**
  Mat.Nummer # aNr;
  Erx # RecRead(200,1,0);
  if (Erx>_rLocked) then begin
    RekRestore(vBuf200);
    RETURN;
  end;
*/
  vDatei # Mat_Data:Read(aNr);
  if (vDatei<200) then begin
    RekRestore(vBuf200);
    RekRestore(vBuf210);
    RETURN;
  end;

  if (Check(aint(Mat.Nummer), aTxt,y)=false) then begin
    RekRestore(vBuf200);
    RekRestore(vBuf210);
    RETURN;
  end;

  vBuf204 # RekSave(204);

  vIstGew # Mat.Bestand.Gew;
  vIstStk # Mat.Bestand.Stk;

  // Bestandsbuch einrechnen, wenns KEIN Fahr-BA...
  FOR Erx # RecLink(202,vDatei,12,_RecFirst)    // Bestandsbuch loopen
  LOOP Erx # RecLink(202,200,12,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    vOK # n;
//    if ("Mat.B.Trägertyp"<>'') and ("Mat.B.Trägertyp"<>c_Akt_Schrott) then vOK # y;
    if ("Mat.B.Trägertyp"<>'') then vOK # y;
/***
    if (vOK) and
      (("Mat.B.Stückzahl"<>0) or (Mat.B.gewicht<>0.0)) and
      (("Mat.B.Trägertyp"=c_Akt_BA_Einsatz) or
        ("Mat.B.Trägertyp"=c_Akt_BA_Fertig)) then begin
//      (Mat.B.Bemerkung=*vA2) then begin
      vOK # n;
//      BAG.P.Nummer    # cnvia(Str_token(MAt.B.Bemerkung,'/',1));
//      BAG.P.Position  # cnvia(Str_token(MAt.B.Bemerkung,'/',2));
      BAG.P.Nummer    # "Mat.B.TrägerNummer1";
      BAG.P.Position  # "Mat.B.TrägerNummer2";
      if (BAG.P.Nummer>0) and (BAG.P.Position>0) then begin
        Erx # RecRead(702,1,0);   // BA-Position holen
        if (BAG.P.Aktion=c_BAG_Fahr09) or ("Mat.B.Trägertyp"=c_Akt_BA_Einsatz) then begin
          vOK # y;
        end;
      end;
    end;
***/
    if (vOK) then begin
      Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
      Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
    end;

  END;


  if (aName<>'') then vName # aName;
  vName # Trim(Mat.Nummer);

  _Knoten(vDatei, vName, aFile, vIstStk, vIstGew, Mat.Nummer=aMarkMat);


  // Aktion loopen
  FOR Erx # RecLink(204,vDatei,14,_recFirst)
  LOOP Erx # RecLink(204,vDatei,14,_recNext);
  WHILE (Erx=_rOK) do begin

/*** 13.09.2017
    BAG.P.Nummer    # Mat.A.Aktionsnr
    BAG.P.Position  # Mat.A.Aktionspos
    Erx # RecRead(702, 1, 0); // BA.Pos holen
    if(Erx > _rLocked) then  RecBufClear(702);
***/
    // Folgekarten??
    if (Mat.A.Entstanden<>0) then begin

//      if (Check(aint(Mat.A.Entstanden),aTxt,n)) then begin
      if (Check(aint(Mat.A.Materialnr)+'->'+aint(Mat.A.Entstanden),aTxt,y)=false) then CYCLE;

      vAkt # 'akt'+Trim(Mat.A.Materialnr)+'_'+Trim(Mat.A.Aktion);
begin
        vSplit  # n;
        vBARest # n;
        vA # vAkt;
        vA # vA + ' [label="'+Str_Token(Mat.A.Bemerkung,' ',1);
        if (Mat.A.Aktionstyp=c_Akt_Mat_Kombi) then begin
          // MATPRD? qqwwee
          if (Mat.A.Aktionsnr<>0) then begin
            vA # vA + ' '+Trim(Mat.A.Aktionsnr);
            if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+Trim(Mat.A.Aktionspos);
            if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos2);
            if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos3);
          end;
          vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
          vA # vA + 'KOMBI';
        end
//        else if (Mat.A.Aktionstyp=c_Akt_Schrott) or (BAG.P.Aktion2 <> '') then begin  13.09.2017
        else if (Mat.A.Aktionstyp=c_Akt_Schrott) then begin
          if (Mat.A.Aktionsnr<>0) then vA # vA + ' '+Trim(Mat.A.Aktionsnr);
          if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+Trim(Mat.A.Aktionspos);
          if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos2);
          if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos3);
          vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
        end
        else if (Mat.A.Aktionstyp=c_Akt_BA_Rest) or (Mat.A.Aktionstyp=c_Akt_BA_Fertig) then begin
          if (Mat.A.Aktionsnr<>0) then vA # vA + ' '+Trim(Mat.A.Aktionsnr);
          if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+Trim(Mat.A.Aktionspos);
          if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos2);
          if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos3);
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

        vA # 'id'+vName+' -> '+vAkt;
        vA # vA + ' [arrowhead=none];';
        WriteLn(aFile, vA);

        vA # vAkt+' -> id'+Trim(Mat.A.Entstanden);
        vA # vA +';';
        WriteLn(aFile, vA);

        // Rekursion:
        NimmMaterial(Mat.A.Entstanden, aFile, aTxt, vName, aMarkMat)
      end;
    end;


    // Vorgängerkarten???
    if (Mat.A.Materialnr<>Mat.A.Aktionsmat) and
        ((Mat.A.Aktionstyp=c_Akt_Mat_Kombi)) then begin
//qqwwee         (Mat.A.Aktionstyp=c_Akt_BA_Fertig and Mat.A.Entstanden=0) ) then begin

      if (Check(aint(Mat.A.Aktionsmat)+'->'+aint(Mat.A.Materialnr),aTxt,y)=false) then CYCLE;

      vAkt # 'akt'+Trim(Mat.A.Materialnr)+'_'+Trim(Mat.A.Aktion);
      vA # vAkt;
      vA # vA + ' [label="'+Str_Token(Mat.A.Bemerkung,' ',1);
      if (Mat.A.Aktionsnr<>0) then vA # vA + ' '+Trim(Mat.A.Aktionsnr);
      if (Mat.A.AktionsPos<>0) then vA # vA+ '/'+Trim(Mat.A.Aktionspos);
      if (Mat.A.AktionsPos2<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos2);
      if (Mat.A.AktionsPos3<>0) then vA # vA+'/'+Trim(Mat.A.Aktionspos3);
      vA # vA + '   '+Lib_Berechnungen:KurzDatum_aus_Datum(Mat.A.Aktionsdatum)+'\n';
      //if (BAG.P.Aktion2 <> '') then vA # vA + BAG.P.Aktion2;
      //else
//        if (Mat.A.Aktionstyp=c_Akt_BA_Fertig and Mat.A.Entstanden=0) then
//          vA # vA + Str_token(Mat.A.Bemerkung,' ',2)
//        else
      vA # vA + 'KOMBI';

      vA # vA +'", fontsize=10, shape=ellipse];';
      WriteLn(aFile,vA);

      vA # 'id'+Trim(Mat.A.AktionsMat)+' -> '+vAkt;
      vA # vA + ' [arrowhead=none];';
      WriteLn(aFile, vA);

      vA # vAkt+' -> id'+Trim(Mat.A.Materialnr);
      vA # vA +';';
      WriteLn(aFile, vA);

      // Rekursion:
      v200 # RekSave(vDatei);
      Erx # Mat_Data:Read(Mat.A.Aktionsmat);
      if (Erx=200) then begin
        if (Mat.Ursprung<>0) then vNr # Mat.Ursprung else vNr # Mat.Nummer;
      end
      else begin
        if ("Mat~Ursprung"<>0) then vNr # "Mat~Ursprung" else vNr # "Mat~Nummer";
      end;
      RekRestore(v200);
      NimmMaterial(vNr, aFile, aTxt, '', aMarkMat);
    end;

  END;

  // Restore
  RekRestore(vBuf200);
  RekRestore(vBuf210);
  RekRestore(vBuf204);
end;


//========================================================================
//  Stammbaum
//
//========================================================================
sub Stammbaum();
local begin
  Erx       : int;
  vMatBak   : int;
  vA        : alpha(500);
  vB        : alpha(500);
  vFile     : int;
  vOK       : logic;
  vBildname : alpha(500);
  vTextname : alphA(500);
  vTxt      : handle;
end;
begin

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');
  FsiPathCreate(_Sys->spPathTemp+'StahlControl\Visualizer');

  // Ankerfunktion?
  if (RunAFX('Mat.Stammbaum','')<>0) then RETURN;

//  vBildName # Set.Graph.Workpfad+gUserName+'.jpg';
//  vTextName # Set.Graph.Workpfad+gUserName+'.txt';
  vBildName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.jpg';
  vTextName # _Sys->spPathTemp+'StahlControl\Visualizer\'+gUserName+'.txt';

  vFile # FSIOpen(vTextName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile=0) then RETURN;

  APPOFF();

  vMatBak # Mat.Nummer;

  // KOMBIKARTE?
  if (Mat.Ursprung = 0) then begin
    // ST 2018-08-09: Start auf Kombinierter Karte, dann erste Kombi lesen
    FOR   Erx # RecLink(204, 200, 14, _recFirst)
    LOOP  Erx # RecLink(204, 200, 14, _recNExt)
    WHILE Erx <= _rLOcked DO BEGIN
      if (Mat.A.Aktionstyp <> c_Akt_Mat_Kombi) then
        CYCLE;
        
      Mat.Nummer # Mat.A.Aktionsmat;
      RecRead(200, 1, 0);
    END;
  
  end;

// 05.04.2022 AH: auch bei KOMBIKARTE "hoch" ansetzen...
//  else begin
    // workaround, möglichst hohen Knoten (hohes Ausgangsmaterial) finden
    WHILE (true) DO BEGIN
      if (Mat.Ursprung>0) then begin
        Mat.Nummer # Mat.Ursprung;
        BREAK;
      end;
           
      if (RecLink(204, 200, 14, _recFirst) <= _rLocked) and (Mat.Nummer != Mat.A.Aktionsmat) then begin
        Mat.Nummer # Mat.A.Aktionsmat;
        RecRead(200, 1, 0);
      end
      else begin
        Mat.Nummer # "Mat.Vorgänger";
        BREAK;
      end;
    END;
//  end;

  Mat_Data:Read(Mat.Nummer);

  WriteLn(vFile, 'Digraph G {');
  WriteLn(vFile, 'label="MATERIALSTAMMBAUM '+trim(Mat.Nummer)+vA+'"');
  Writeln(vFile, 'fontsize=20');
  WriteLn(vFile, 'labelloc="t"');
  Writeln(vFile, 'nodesep=0.05');
//  WriteLn(vFile, 'size="6,6";');
//  WriteLn(vFile, 'labeljust="l"');


  vTxt # TextOpen(20);
  NimmMaterial(Mat.Nummer,vFile,vTxt, '', vMatBak);
  TextClose(vTxt);

  WriteLn(vFile,'');

  WriteLn(vFile, '}');
  FSIClose(vFile);

  Mat.Nummer # vMatBak;
  RecRead(200,1,0);

  APPON();

//  SysExecute('c:\graph\dot.exe','-Tjpg -oc:\graph\Graph.jpg c:\graph\graph.txt',_execminimized|_execwait);
//  SysExecute(set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
  SysExecute(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei,'-Tjpg -o'+vBildName+' '+vTextName,_execminimized|_execwait);
//debug(Set.Graph.Workpfad+'graphviz\'+set.Graph.Exe.Datei+' -Tjpg -o'+vBildName+' '+vTextName);

  // externes Bild anzeigen
  Dlg_Bild('*'+vBildName);

end;

//========================================================================