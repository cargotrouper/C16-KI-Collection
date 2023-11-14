@A+
//==== Business-Control ==================================================
//
//  Prozedur    GPl_P_List
//                OHNE E_R_G
//  Info
//
//
//  24.05.2007  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB GrenzAnalyse(var aMin : float; var aMax : float; aWert1 : float; aWert2: float);
//    SUB GrenzAllAnalysen();
//    SUB CheckAnalyse(aMin : float; aMax : float; aWert1 : float; aWert2: float) : logic;
//    SUB Verbuche(aMenge : float; aStk : int; aGew : float; aDel : logic) : logic
//    SUB EvtLstDataInit(aEvt : Event; aRecId : int);
//    SUB EvtLstSelect(aEvt : event; aRecID : int) : logic
//    SUB RecInit() : logic;
//    SUB RecSave(aNeu : logic) : logic;
//    SUB EvtDropEnter(	aEvt : event;	aDataObject : int;aEffect : int) : logic
//    SUB EvtDrop(aEvt : event;	aDataObject : int;aDataPlace : int; aEffect : int;aMouseBtn : int) : logic
//    SUB _Auf2GPlP(var aPos : int) : logic;
//    SUB InsertMarkAuf() : int;
//    SUB _Mat2GPlP(var aPos : int) : logic;
//    SUB InsertMarkMat() : int;
//    SUB Erledigen();
//
//========================================================================
@I:Def_Global
@I:Def_Rights
@I:Def_Aktionen

declare _Mat2GPlP(var aPos : int) : logic;
declare _Auf2GPlP(var aPos : int) : logic;

define begin
  cZListMat   : $ZL.GPL.P.Mat
  cZListAuf   : $ZL.GPL.P.Auf
end


//========================================================================
//  GrenzAnalyse
//
//========================================================================
sub GrenzAnalyse(
  var aMin  : float;
  var aMax  : float;
  aWert1    : float;
  aWert2    : float);
begin
  if (aWert1=aWert2) and (aWert1=0.0) then RETURN;
  if (aWert1>aMax) or (aWert2<aMin) then RETURN;
  if (aWert1>aMin) then aMin # aWert1;
  if (aWert2<aMax) then aMax # aWert2;
end;


//========================================================================
//  GrenzAllAnalysen
//
//========================================================================
sub GrenzAllAnalysen();
begin
  GrenzAnalyse(var GPl.Auf.Streckgrenz1, var GPl.Auf.Streckgrenz2, Auf.P.Streckgrenze1, Auf.P.Streckgrenze2);
  GrenzAnalyse(var GPl.Auf.Zugfestig1,   var GPl.Auf.Zugfestig2,   Auf.P.Zugfestigkeit1, Auf.P.Zugfestigkeit2);
  GrenzAnalyse(var GPl.Auf.DehnungA1,    var GPl.Auf.DehnungA2,    Auf.P.DehnungA1, Auf.P.DehnungA2);
  GrenzAnalyse(var GPl.Auf.DehnungB1,    var GPl.Auf.DehnungB2,    Auf.P.DehnungB1, Auf.P.DehnungB2);
  GrenzAnalyse(var GPl.Auf.DehngrenzeA1, var GPl.Auf.DehngrenzeA2, Auf.P.DehngrenzeA1, Auf.P.DehngrenzeA2);
  GrenzAnalyse(var GPl.Auf.DehngrenzeB1, var GPl.Auf.DehngrenzeB2, Auf.P.DehngrenzeB1, Auf.P.DehngrenzeB2);
  GrenzAnalyse(var "GPl.Auf.Körnung1",   var "GPl.Auf.Körnung2",   "Auf.P.Körnung1", "Auf.P.Körnung2");
  GrenzAnalyse(var "GPl.Auf.Härte1",     var "GPl.Auf.Härte2",     "Auf.P.Härte1", "Auf.P.Härte2");
  GrenzAnalyse(var GPl.Auf.RauigkeitA1,  var GPl.Auf.RauigkeitA2,  Auf.P.RauigkeitA1, Auf.P.RauigkeitA2);
  GrenzAnalyse(var GPl.Auf.RauigkeitB1,  var GPl.Auf.RauigkeitB2,  Auf.P.RauigkeitB1, Auf.P.RauigkeitB2);
  GrenzAnalyse(var GPl.Auf.Chemie.C1,    var GPl.Auf.Chemie.C2,    Auf.P.Chemie.C1, Auf.P.Chemie.C2);
  GrenzAnalyse(var GPl.Auf.Chemie.Si1,   var GPl.Auf.Chemie.Si2,   Auf.P.Chemie.Si1,Auf.P.Chemie.Si2);
  GrenzAnalyse(var GPl.Auf.Chemie.Mn1,   var GPl.Auf.Chemie.Mn2,   Auf.P.Chemie.Mn1,Auf.P.Chemie.Mn2);
  GrenzAnalyse(var GPl.Auf.Chemie.P1,    var GPl.Auf.Chemie.P2,    Auf.P.Chemie.P1,Auf.P.Chemie.P2);
  GrenzAnalyse(var GPl.Auf.Chemie.S1,    var GPl.Auf.Chemie.S2,    Auf.P.Chemie.S1,Auf.P.Chemie.S2);
  GrenzAnalyse(var GPl.Auf.Chemie.Al1,   var GPl.Auf.Chemie.Al2,   Auf.P.Chemie.Al1, Auf.P.Chemie.Al2);
  GrenzAnalyse(var GPl.Auf.Chemie.Cr1,   var GPl.Auf.Chemie.Cr2,   Auf.P.Chemie.Cr1,Auf.P.Chemie.Cr2);
  GrenzAnalyse(var GPl.Auf.Chemie.V1,    var GPl.Auf.Chemie.V2,    Auf.P.Chemie.V1,Auf.P.Chemie.V2);
  GrenzAnalyse(var GPl.Auf.Chemie.Nb1,   var GPl.Auf.Chemie.Nb2,   Auf.P.Chemie.Nb1,Auf.P.Chemie.Nb2);
  GrenzAnalyse(var GPl.Auf.Chemie.Ti1,   var GPl.Auf.Chemie.Ti2,   Auf.P.Chemie.Ti1,Auf.P.Chemie.Ti2);
  GrenzAnalyse(var GPl.Auf.Chemie.N1,    var GPl.Auf.Chemie.N2,    Auf.P.Chemie.N1,Auf.P.Chemie.N2);
  GrenzAnalyse(var GPl.Auf.Chemie.Cu1,   var GPl.Auf.Chemie.Cu2,   Auf.P.Chemie.Cu1,Auf.P.Chemie.Cu2);
  GrenzAnalyse(var GPl.Auf.Chemie.Ni1,   var GPl.Auf.Chemie.Ni2,   Auf.P.Chemie.Ni1,Auf.P.Chemie.Ni2);
  GrenzAnalyse(var GPl.Auf.Chemie.Mo1,   var GPl.Auf.Chemie.Mo2,   Auf.P.Chemie.Mo1,Auf.P.Chemie.Mo2);
  GrenzAnalyse(var GPl.Auf.Chemie.B1,    var GPl.Auf.Chemie.B2,    Auf.P.Chemie.B1,Auf.P.Chemie.B2);
  GrenzAnalyse(var GPl.Auf.Chemie.Frei1, var GPl.Auf.Chemie.Frei2, Auf.P.Chemie.Frei1.1,Auf.P.Chemie.Frei1.2);
end;


//========================================================================
//  CheckAnalyse
//
//========================================================================
sub CheckAnalyse(
  aMin  : float;
  aMax  : float;
  aWert1    : float;
  aWert2    : float) : logic;
begin
  if (aWert1=aWert2) and (aWert1=0.0) then RETURN true;
  if (aWert1>aMax) or (aWert2<aMin) then RETURN false;
  RETURN true;
end;


//========================================================================
//  Verbuche
//            Transaktion muss OFFEN sein!!!
//========================================================================
sub Verbuche(
  aMenge  : float;
  aStk    : int;
  aGew    : float;
  aDel    : logic;
) : logic;
local begin
  Erx   : int;
  vTmp  : int;
end;
begin

  RecRead(600,1,_recLock);

  // MATERIAL??
  if (GPl.P.Typ=200) then begin

    GPl.Sum.Mat.Stk     # GPl.Sum.Mat.Stk + aStk;
    GPl.Sum.Mat.Gewicht # GPl.Sum.Mat.Gewicht + aGew;
    //GPl.Sum.Mat.Menge   # GPl.Sum.Mat.Menge + aMenge;

    // Material holen
    if (Mat_Data:Read(GPl.P.ID1)=0) then begin
      TRANSBRK;
      RETURN false;
    end;

/***/
    // alte Reservierung ggf. anpassen
    Erx # RecLink(203,200,13,_RecFirst);
    WHILE (Erx<=_rLocked) do begin

      If ("Mat.R.Trägertyp"=c_Akt_GPL) and ("Mat.R.TrägerNummer1"=GPL.P.Nummer) and ("Mat.R.Trägernummer2"=GPl.P.Position) then begin
        if (Mat_Rsv_Data:Entfernen()=false) then begin
          TRANSBRK;
          RETURN false;
        end;
        Erx # RecLink(203,200,13,0);
        Erx # RecLink(203,200,13,0);
        CYCLE;
      end;

      Erx # RecLink(203,200,13,_RecNext);
    END;
/****/

    if (aDel=n) then begin
/***/
      // neue Reservierung anlegen ***********************
      RecBufClear(203);
      Mat.R.Materialnr      # GPl.P.ID1;
      "Mat.R.Stückzahl"     # "GPl.P.Stückzahl";
      Mat.R.Gewicht         # GPl.P.Gewicht;
      "Mat.R.Trägertyp"     # c_Akt_GPL;
      "Mat.R.TrägerNummer1" # GPl.P.Nummer;
      "Mat.R.TrägerNummer2" # GPl.P.Position;
      if (Mat_Rsv_Data:Neuanlegen()=false) then begin
        TRANSBRK;
        RETURN false;
      end;
/***/
    end;

  end;


  // AUFTRAG??
  if (GPl.P.Typ=401) then begin
    GPl.Sum.Auf.Stk     # GPl.Sum.Auf.Stk + aStk;
    GPl.Sum.Auf.Gewicht # GPl.Sum.Auf.Gewicht + aGew;
    //GPl.Sum.Auf.Menge   # GPl.Sum.Auf.Menge + aMenge;

    // Analysen eingrenzen...
    GrenzAllAnalysen();

    // Auftragsposition anpassen
    vTmp #  Auf_Data:Read(GPl.P.ID1,GPl.P.ID2,n);
//debug('a');
    if (vTmp=401) then begin    // Auftrag im Bestand
//debug('b'+ anum(aMenge,0));
      RecRead(401,1,_recLock);
      Auf.P.GPl.Plan      # Auf.P.GPl.Plan      + aMenge;
      Auf.P.GPl.Plan.Stk  # Auf.P.GPl.Plan.Stk  + aStk;
      Auf.P.GPl.Plan.Gew  # Auf.P.GPl.Plan.Gew  + aGew;
      Erx # Auf_Data:PosReplace(_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
    end
    else if (vTmp=411) then begin   // Auftrag in Ablage
      RecRead(411,1,_recLock);
      "Auf~P.GPl.Plan"      # "Auf~P.GPl.Plan"      + aMenge;
      "Auf~P.GPl.Plan.Stk"  # "Auf~P.GPl.Plan.Stk"  + aStk;
      "Auf~P.GPl.Plan.Gew"  # "Auf~P.GPl.Plan.Gew"  + aGew;
      Erx # RekReplace(411,_recUnlock,'AUTO');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        Msg(001000+Erx,gTitle,0,0,0);
        RETURN false;
      end;
    end
    else begin    // Auftrag nicht gefunden?
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN false;
    end;
  end;

  Erx # RekReplace(600,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  EvtLstDataInit
//
//========================================================================
sub EvtLstDataInit(
  aEvt      : Event;
  aRecId    : int;
  Opt aMark : logic;
);
local begin
  vOK : logic;
end;
begin

  RecBufClear(200);
  RecBufClear(401);

  // Material?
  if (GPl.P.Typ=200) then begin
    Mat_Data:Read(GPl.P.ID1);

    if ("GPl.P.Löschmarker"<>'') then begin
      if (aMark=n) then
        Lib_GuiCom:ZLColorLine(aEvt:Obj,Set.Col.RList.Deletd);
    end;

  end;

  // Auftrag?
  if (GPl.P.Typ=401) then begin
    Auf_Data:Read(GPl.P.ID1,GPl.P.ID2,n);

    if ("GPl.P.Löschmarker"<>'') then begin
      if (aMark=n) then begin
        Lib_GuiCom:ZLColorLine(aEvt:Obj,Set.Col.RList.Deletd);
        RETURN;
      end;
    end;


    vOK # y;
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Streckgrenz1, GPl.Auf.Streckgrenz2, Auf.P.Streckgrenze1, Auf.P.Streckgrenze2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Zugfestig1,  GPl.Auf.Zugfestig2,   Auf.P.Zugfestigkeit1, Auf.P.Zugfestigkeit2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.DehnungA1,   GPl.Auf.DehnungA2,    Auf.P.DehnungA1, Auf.P.DehnungA2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.DehnungB1,   GPl.Auf.DehnungB2,    Auf.P.DehnungB1, Auf.P.DehnungB2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.DehngrenzeA1,GPl.Auf.DehngrenzeA2, Auf.P.DehngrenzeA1, Auf.P.DehngrenzeA2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.DehngrenzeB1,GPl.Auf.DehngrenzeB2, Auf.P.DehngrenzeB1, Auf.P.DehngrenzeB2);
    if (vOK) then vOK # CheckAnalyse("GPl.Auf.Körnung1",  "GPl.Auf.Körnung2",   "Auf.P.Körnung1", "Auf.P.Körnung2");
    if (vOK) then vOK # CheckAnalyse("GPl.Auf.Härte1",    "GPl.Auf.Härte2",     "Auf.P.Härte1", "Auf.P.Härte2");
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.RauigkeitA1, GPl.Auf.RauigkeitA2,  Auf.P.RauigkeitA1, Auf.P.RauigkeitA2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.RauigkeitB1, GPl.Auf.RauigkeitB2,  Auf.P.RauigkeitB1, Auf.P.RauigkeitB2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.C1,   GPl.Auf.Chemie.C2,    Auf.P.Chemie.C1, Auf.P.Chemie.C2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Si1,  GPl.Auf.Chemie.Si2,   Auf.P.Chemie.Si1,Auf.P.Chemie.Si2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Mn1,  GPl.Auf.Chemie.Mn2,   Auf.P.Chemie.Mn1,Auf.P.Chemie.Mn2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.P1,   GPl.Auf.Chemie.P2,    Auf.P.Chemie.P1,Auf.P.Chemie.P2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.S1,   GPl.Auf.Chemie.S2,    Auf.P.Chemie.S1,Auf.P.Chemie.S2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Al1,  GPl.Auf.Chemie.Al2,   Auf.P.Chemie.Al1, Auf.P.Chemie.Al2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Cr1,  GPl.Auf.Chemie.Cr2,   Auf.P.Chemie.Cr1,Auf.P.Chemie.Cr2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.V1,   GPl.Auf.Chemie.V2,    Auf.P.Chemie.V1,Auf.P.Chemie.V2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Nb1,  GPl.Auf.Chemie.Nb2,   Auf.P.Chemie.Nb1,Auf.P.Chemie.Nb2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Ti1,  GPl.Auf.Chemie.Ti2,   Auf.P.Chemie.Ti1,Auf.P.Chemie.Ti2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.N1,   GPl.Auf.Chemie.N2,    Auf.P.Chemie.N1,Auf.P.Chemie.N2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Cu1,  GPl.Auf.Chemie.Cu2,   Auf.P.Chemie.Cu1,Auf.P.Chemie.Cu2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Ni1,  GPl.Auf.Chemie.Ni2,   Auf.P.Chemie.Ni1,Auf.P.Chemie.Ni2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Mo1,  GPl.Auf.Chemie.Mo2,   Auf.P.Chemie.Mo1,Auf.P.Chemie.Mo2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.B1,   GPl.Auf.Chemie.B2,    Auf.P.Chemie.B1,Auf.P.Chemie.B2);
    if (vOK) then vOK # CheckAnalyse(GPl.Auf.Chemie.Frei1,GPl.Auf.Chemie.Frei2, Auf.P.Chemie.Frei1.1,Auf.P.Chemie.Frei1.2);

    if (aMark=n) then begin
      if (vOK=false) then Lib_GuiCom:ZLColorLine(cZListAuf, RGB(250,0,0) );
    end;

  end;

end;


//========================================================================
//  EvtLstSelect
//                Zeilenauswahl von RecList/DataList
//========================================================================
sub EvtLstSelect(
  aEvt                  : event;        // Ereignis
  aRecID                : int;
) : logic
local begin
  vHdl  : int;
end;
begin

  if (arecid=0) then RETURN true;
  RecRead(601,0,_recid,aRecID);

//  if (GPl.P.Typ=401) then begin
//    Auf_Data:Read(GPl.P.ID1,GPl.P.ID2,n);
  GPl_Main:refreshmode(y);

end;


//========================================================================
//  RecInit
//          Feldvorbelegung bei Neuanlage
//========================================================================
sub RecInit() : logic;
begin
  RETURN true;
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave(aNeu : logic) : logic;
local begin
  Erx     : int;
  vBuf601 : int;
  vStk    : int;
  vGew    : float;
  vMenge  : float;
end;
begin

  vBuf601 # Reksave(601);

  // Ursprungs-Werte holen
  RecRead(601,1,0);
  vStk    # "GPl.P.Stückzahl";
  vGew    # GPl.P.Gewicht;
  vMenge  # GPl.P.Menge;

  RekRestore(vBuf601);

  TRANSON;
  RecRead(601,1,_recLock|_RecNoLoad);
  Erx # RekReplace(601,_recUnlock,'MAN');
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Msg(001000+Erx,gTitle,0,0,0);
    RETURN false;
  end;

  // verbuchen und TRANSOFF
  if (Verbuche(GPl.P.Menge - vMenge, "GPl.P.Stückzahl" - vStk, GPl.P.Gewicht - vGew,n )=false) then RETURN false;

  GPl_Main:RefreshifM()
  RETURN true;
end;


//========================================================================
//  EvtDropEnter
//                Targetobjekt mit Maus "betreten"
//========================================================================
sub EvtDropEnter(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aEffect      : int       // Rückgabe der erlaubten Effekte
) : logic
local begin
  vA      : alpha;
  vFile   : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    if ((vFile=200) and (aEvt:Obj=cZListMat)) or
      ((vFile=401) and (aEvt:Obj=cZListAuf)) then begin
      aEffect # _WinDropEffectCopy | _WinDropEffectMove;
      RETURN (true);
    end;
	end;
	
  RETURN false;
end;


//========================================================================
//  EvtDrop
//            komplettes D&D durchführen
//========================================================================
sub EvtDrop(
	aEvt         : event;    // Ereignis
	aDataObject  : int;      // Drag-Datenobjekt
	aDataPlace   : int;      // DropPlace-Objekt
	aEffect      : int;      // Eingabe: vom Benutzer gewählter Effekt, Ausgabe: durchgeführter Effekt
	aMouseBtn    : int       // Verwendete Maustasten
) : logic
local begin
  vA      : alpha;
  vFile   : int;
  vID     : int;
  vPos    : int;
end;
begin

  if (aDataObject->wpFormatEnum(_WinDropDataText)) then begin
    vA    # StrFmt(aDataObject->wpName,30,_strend);
    vFile # Cnvia(StrCut(vA,1,3));
    vID   # Cnvia(StrCut(vA,5,15));
    if (vID=0) then RETURN false;

    case vFile of

      200 : begin
//        Winfocusset( WinInfo(aEvt:obj, _WinFrame) );
        WinUpdate(WinInfo(aEvt:obj, _WinFrame), _WinUpdActivate );
        RecRead(vFile,0,_RecId,vID);    // Satz holen

        RecRead(600,1,_recLock);
        vPos # 0;
        _Mat2GPLp(var vPos);
        RekReplace(600,_recUnlock,'AUTO');
        GPl_Main:RefreshIfm();

        RETURN true;
      end;


      401 : begin
        Winfocusset( WinInfo(aEvt:obj, _WinFrame) );
        RecRead(vFile,0,_RecId,vID);    // Satz holen

        RecRead(600,1,_recLock);
        vPos # 0;
        _Auf2GPlP(var vPos);
        RekReplace(600,_recUnlock,'AUTO');
        GPl_Main:RefreshIfm();

        RETURN true;
      end;

    end;

  end;

	RETURN (false);
end


//========================================================================
//  RecDel
//          Satz soll gelöscht werden
//========================================================================
sub RecDel()
local begin
  Erx     : int;
  vTmp    : int;
end;
begin

  if ("GPl.P.Löschmarker"<>'') then RETURN;

  // Diesen Eintrag wirklich löschen?
  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdYes) then begin

    TRANSON;

    Erx # RekDelete(601,0,'MAN');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      Msg(001000+Erx,gTitle,0,0,0);
      RETURN;
    end;

    // Verbuchen und TRANSOFF
    if (Verbuche(0.0-GPl.P.Menge, 0-"GPl.P.Stückzahl", 0.0-GPl.P.Gewicht,y )=false) then RETURN;

    RecRead(601,1,0);

    // Analysen neu errechnen...
    RecRead(600,1,_recLock);

    GPl.Auf.Streckgrenz1  # 0.0;
    GPl.Auf.Zugfestig1    # 0.0;
    GPl.Auf.DehnungA1     # 0.0;
    GPl.Auf.DehnungB1     # 0.0;
    GPl.Auf.DehngrenzeA1  # 0.0;
    GPl.Auf.DehngrenzeB1  # 0.0;
    "GPl.Auf.Körnung1"    # 0.0;
    "GPl.Auf.Härte1"      # 0.0;
    GPl.Auf.RauigkeitA1   # 0.0;
    GPl.Auf.RauigkeitB1   # 0.0;
    GPl.Auf.Chemie.C1     # 0.0;
    GPl.Auf.Chemie.Si1    # 0.0;
    GPl.Auf.Chemie.Mn1    # 0.0;
    GPl.Auf.Chemie.P1     # 0.0;
    GPl.Auf.Chemie.S1     # 0.0;
    GPl.Auf.Chemie.Al1    # 0.0;
    GPl.Auf.Chemie.Cr1    # 0.0;
    GPl.Auf.Chemie.V1     # 0.0;
    GPl.Auf.Chemie.Nb1    # 0.0;
    GPl.Auf.Chemie.Ti1    # 0.0;
    GPl.Auf.Chemie.N1     # 0.0;
    GPl.Auf.Chemie.Cu1    # 0.0;
    GPl.Auf.Chemie.Ni1    # 0.0;
    GPl.Auf.Chemie.Mo1    # 0.0;
    GPl.Auf.Chemie.B1     # 0.0;
    GPl.Auf.Chemie.Frei1  # 0.0;

    GPl.Auf.Streckgrenz2  # 9999.0;
    GPl.Auf.Zugfestig2    # 9999.0;
    GPl.Auf.DehnungA2     # 9999.0;
    GPl.Auf.DehnungB2     # 9999.0;
    GPl.Auf.DehngrenzeA2  # 9999.0;
    GPl.Auf.DehngrenzeB2  # 9999.0;
    "GPl.Auf.Körnung2"    # 9999.0;
    "GPl.Auf.Härte2"      # 9999.0;
    GPl.Auf.RauigkeitA2   # 9999.0;
    GPl.Auf.RauigkeitB2   # 9999.0;
    GPl.Auf.Chemie.C2     # 9999.0;
    GPl.Auf.Chemie.Si2    # 9999.0;
    GPl.Auf.Chemie.Mn2    # 9999.0;
    GPl.Auf.Chemie.P2     # 9999.0;
    GPl.Auf.Chemie.S2     # 9999.0;
    GPl.Auf.Chemie.Al2    # 9999.0;
    GPl.Auf.Chemie.Cr2    # 9999.0;
    GPl.Auf.Chemie.V2     # 9999.0;
    GPl.Auf.Chemie.Nb2    # 9999.0;
    GPl.Auf.Chemie.Ti2    # 9999.0;
    GPl.Auf.Chemie.N2     # 9999.0;
    GPl.Auf.Chemie.Cu2    # 9999.0;
    GPl.Auf.Chemie.Ni2    # 9999.0;
    GPl.Auf.Chemie.Mo2    # 9999.0;
    GPl.Auf.Chemie.B2     # 9999.0;
    GPl.Auf.Chemie.Frei2  # 9999.0;

    Erx # RecLink(601,600,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      if (GPL.P.Typ=401) then begin
        vTmp #  Auf_Data:Read(GPl.P.ID1,GPl.P.ID2,n);
        if (vTmp=411) then RecbufCopy(411,401);
        if (vTmp=411) or (vTmp=401) then begin
          GrenzAllAnalysen();
        end;
      end;
      Erx # RecLink(601,600,1,_recNext);
    END;
    RekReplace(600,_recUnlock,'AUTO');

    GPl_Main:RefreshIfm();
  end;

end;


//========================================================================
//  _Mat2GPlP
//
//========================================================================
sub _Mat2GPlP(var aPos : int) : logic
local begin
  Erx     : int;
  vBuf200 : handle;
  vBuf203 : handle;
  vBuf401 : handle;
end;
begin

  if ("Mat.Löschmarker"='*') then RETURN false;
  if (Mat.Status>c_Status_bisfrei) then RETURN false;

  RecBufClear(601);
  GPl.P.Nummer      # GPl.Nummer;
  GPl.P.Typ         # 200;
  GPl.P.ID1         # Mat.Nummer;
  GPl.P.MEH         # 'kg';

  "GPl.P.Stückzahl" # "Mat.Verfügbar.Stk";
  GPl.P.Gewicht     # "Mat.Verfügbar.Gew";
  GPl.P.Menge       # GPl.P.Gewicht;

  GPl.Anlage.Datum  # Today;
  GPl.Anlage.Zeit   # Now;
  GPl.Anlage.User   # gUserName;

  // auf Existenz prüfen
  Erx # RecRead(601,3,_RecTest);
  if (Erx<=_rMultiKey) then begin    // bekannt, dann überspringen
//debug('EXIST:'+aint(Mat.Nummer));
    RETURN false;
  end;

  vBuf200 # RekSave(200);
  vBuf203 # RekSave(203);
  vBuf401 # RekSave(401);

  TRANSON;

  REPEAT
    aPos # aPos + 1;
    GPl.P.Position    # aPos;
    Erx # RekInsert(601,0,'MAN');
  UNTIL (erx=_rOK);

  // Verbuchen und TRANSOFF
  if (Verbuche(GPl.P.Menge, "GPl.P.Stückzahl", GPl.P.Gewicht,n)=false) then begin
    RecRead(600,1,_recunlock);
    RekRestore(vBuf200);
    RekRestore(vBuf203);
    RekRestore(vBuf401);
    RETURN false;
  end;

  // Materialreservierungen loopen...
  Erx # RecLink(203,200,13,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(401,203,2,_recFirst);   // Auftragspos holen
    if (Erx<=_rLocked) then begin
      _Auf2GPlP(var aPos);
    end;
    Erx # RecLink(203,200,13,_recNext);
  END;


  RekRestore(vBuf200);
  RekRestore(vBuf203);
  RekRestore(vBuf401);
  RETURN true;
end;


//========================================================================
//  InsertMarkMat
//          importiert markierte Materialien in die Planung
//========================================================================
sub InsertMarkMat() : int;
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vPos    : int;
  vCount  : Int;
end;
begin


  vCount # 0;
  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>200) then begin // passt nicht?
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;
    inc(vCount);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vCount=0) then begin
//    Msg(997006,'', _WinIcoInformation, _WinDialogOk,0)
    RETURN 0;
  end;


  RecRead(600,1,_RecLock);
  vPos # 0;
  vCount # 0;
  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>200) then begin // passt nicht?
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    inc(vCount);

    RecRead(vMFile,0,_RecId,vMID);    // Satz holen

    _Mat2GPlP(var vPos);

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RekReplace(600,_recUnlock,'AUTO');

  if (Msg(997005,'', _WinIcoQuestion, _WinDialogYesNo,0)=_WinIdYes) then begin
    Lib_Mark:Reset(200)
//    if(gFrmMain->WinSearch('Mat.Verwaltung') > 0) then begin
    if (gMDIMat<>0) then begin
      gMdiMat->WinFocusSet(true); // Focus auf Materialfenster
      $ZL.Material->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect); // Material ZL updaten
      gMdiBAG->WinFocusSet(true); // Focus wieder auf Grobplanung
    end;
  end;

  RETURN vCount;
end;


//========================================================================
//  _Auf2GPlP
//
//========================================================================
sub _Auf2GPlP(var aPos : int) : logic;
local begin
  Erx     : int;
  vBuf200 : handle;
  vBuf203 : handle;
  vBuf401 : handle;
  vBuf601 : int;
end;
begin

  if ("Auf.P.Löschmarker"='*') then RETURN false;
  Erx # RecLink(400,401,3,_RecFirst);   // Kopf holen
  if (Erx<>_rOK) then RETURN false;
  if (Auf.Vorgangstyp<>c_AUF) or (Auf.LiefervertragYN) then RETURN false;

  RecBufClear(601);
  GPl.P.Nummer      # GPl.Nummer;
  GPl.P.Typ         # 401;
  GPl.P.ID1         # Auf.P.Nummer;
  GPl.P.ID2         # Auf.P.Position;
  GPl.P.MEH         # 'kg';

  "GPl.P.Stückzahl" # Auf.P.Prd.Rest.Stk - Auf.P.GPl.Plan.Stk;
  GPl.P.Gewicht     # Auf.P.Prd.Rest.Gew - Auf.P.GPl.Plan.Gew;
  GPl.P.Menge       # Auf.P.Prd.Rest - Auf.P.GPl.Plan;

  GPl.P.Anlage.Datum  # Today;
  GPl.P.Anlage.Zeit   # Now;
  GPl.P.Anlage.User   # gUserName;

  // auf Existenz prüfen
  vBuf601 # RekSave(601);
  Erx # RecRead(vBuf601,3,0);
  WHILE (Erx<=_rMultikey) and (GPL.P.Typ=vBuf601->GPl.P.Typ) and
    (GPl.P.ID1=vBuf601->GPl.P.ID1) and
    (GPL.P.ID2=vBuf601->GPl.P.ID2) do begin
    if (GPl.P.Nummer=vBuf601->GPl.P.Nummer) then begin
//todo('EXIST:'+aint(vBuf601->GPl.P.nummer)+'/'+aint(vBuf601->GPL.p.position));
      RecBufDestroy(vBuf601);
      RETURN false;
    end;
    Erx # RecRead(vBuf601,3,_RecNext);
  END;
  RecBufDestroy(vBuf601);

  vBuf200 # RekSave(200);
  vBuf203 # RekSave(203);
  vBuf401 # RekSave(401);

  TRANSON;
//if (auf.p.nummer=100544) then "Gpl.P.löschmarker" # '*';
  REPEAT
    aPos # aPos + 1;
    GPl.P.Position    # aPos;
    Erx # RekInsert(601,0,'MAN');
  UNTIL (erx=_rOK);

  // Verbuchen und TRANSOFF
  if (Verbuche(GPl.P.Menge, "GPl.P.Stückzahl", GPl.P.Gewicht,n)=false) then begin
    RecRead(600,1,_recunlock);
    RekRestore(vBuf200);
    RekRestore(vBuf203);
    RekRestore(vBuf401);
    RETURN false;
  end;

  // Materialreservierungen loopen...
  Erx # RecLink(203,401,18,_recFirst);
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(200,203,1,_recFirst);   // Material holen
    if (Erx<=_rLocked) then begin
      _Mat2GPlP(var aPos);
    end;
    Erx # RecLink(203,401,18,_recNext);
  END;

  RekRestore(vBuf200);
  RekRestore(vBuf203);
  RekRestore(vBuf401);
  RETURN true;
end;


//========================================================================
//  InsertMarkAuf
//          importiert markierte Aufräge in die Planung
//========================================================================
sub InsertMarkAuf() : int;
local begin
  vItem   : int;
  vMFile  : int;
  vMID    : int;
  vPos    : int;
  vCount  : int;
end;
begin

  vCount # 0;
  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>401) then begin // passt nicht?
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;
    inc(vCount);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  if (vCount=0) then begin
//    Msg(997006,'', _WinIcoInformation, _WinDialogOk,0)
    RETURN 0;
  end;


  RecRead(600,1,_RecLock);
  vCount # 0;
  // Ermittelt das erste Element der Liste (oder des Baumes)
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin    // Markierungen loopen
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);

    if (vMFile<>401) then begin // passt nicht?
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    inc(vCount)

    RecRead(vMFile,0,_RecId,vMID);    // Satz holen

    _Auf2GPlP(var vPos);

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  RekReplace(600,_recUnlock,'AUTO');

  if (Msg(997005,'', _WinIcoQuestion, _WinDialogYesNo,0)=_WinIdYes) then begin
    Lib_Mark:Reset(401);
//    if (gFrmMain->WinSearch('Auf.P.Verwaltung') > 0) then begin
    if (gMDIAuf<>0) then begin
      gMdiAuf->WinFocusSet(true); // Focus auf Materialfenster
      $ZL.AufPositionen->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect); // Material ZL updaten
      gMdiBAG->WinFocusSet(true); // Focus wieder auf Grobplanung
    end;
  end;

  RETURN vCount;
end;


//========================================================================
//  Erledigen
//          Setzt den Löschmarker und verbucht das
//========================================================================
sub Erledigen()
local begin
  vTmp : int;
end;
begin

  if ("GPl.P.Löschmarker"<>'') then RETURN;

  TRANSON;

  RecRead(601,1,_recLock);
  "GPl.P.Löschmarker" # '*';
  RekReplace(601,_recUnlock,'MAN');

  // Verbuchen und TRANSOFF
  if (Verbuche(0.0-GPl.P.Menge, 0-"GPl.P.Stückzahl", 0.0-GPl.P.Gewicht,y )=false) then RETURN;

end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================