@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Pflichtfelder
//                          OHNE E_R_G
//  Info
//
//
//  23.03.2010  MS  Erstellung der Prozedur
//  07.06.2011  MS  Felder die sich auf einem INVISIBLE NB-Reiter befinden
//                  werden NICHT mehr beachtet
//  21.05.2013  AI  Auswahlfeld nur bei aktiven Feldern F9
//  27.01.2021  AH  Kann nun auch Customauswahlfelder als einzig erlaubter Inhalt prüfen
//  27.07.2021  AH  ERX
//  2023-07-20  AH  Kombi von Pflichtfeld + "leerem" Auswahlfeld möglich laut VBS
//
//  Subprozeduren
//    sub PflichtfeldVorhanden(aName : alpha;) : logic;
//    sub PflichtfelderListeFuellen(aName : alpha; opt aNurCust : logic);
//    sub PflichtfelderListeLoeschen()
//    sub NeuesPflichtfeld() : logic;
//    sub PflichtfeldLoeschen() : logic;
//    sub PflichtfeldZurListeHinzufuegen(): logic
//    sub PflichtfeldAusListeLoeschen() : logic;
//    sub PflichtfeldDatensatzAnlegen(aObj : int;) : logic;
//    sub PflichtfeldDatensatzLoeschen() : logic;
//    sub PflichtfelderEinfaerben()
//    sub PflichtfelderPruefen() : logic;
//    xsub PflichtfeldAusgefuellt(aObj : int; aMussBereich  : alpha) : logic;
//    xsub AuswahlFeldRichtigGefuellt(aObj : int; aMussBereich : alpha; aBenutzeLang : logic) : logic;
//
//
//    SUB SetStdAuswahlFeld(aName : alpha; aBereich : alpha; opt aSpezi : logic;): logic
//    SUB TypAuswahlFeld(aObj : int; opt aSpezi  : logic) : alpha
//
//========================================================================
@I:Def_Global
@I:Def_Rights

// Pflichtfeld loeschen ---
declare PflichtfeldLoeschen(var aListPflicht : int) : logic // kuemmert sich um das KOMPLETTE LOESCHEN
declare PflichtfeldDatensatzLoeschen() : logic; // loescht ein Pflichtfeld aus der DB
// ---------

// Pflichtfeld anlegen ---
declare NeuesPflichtfeld(var aListPflicht : int) : logic; // kuemmert sich um die KOMPLETTE NEUANLAGE
declare PflichtfeldDatensatzAnlegen(aObj : int;) : logic; // legt ein Pflichtfeld in der DB an
// ---------

// Liste ---
declare PflichtfelderListeFuellen(aName : alpha;var aListPflicht : int; var aListAuswahl : int; opt aNurCust : logic); // Liste erstellen und fuellen
declare PflichtfelderListeLoeschen(  var aListPflicht : int;  var aListAuswahl : int); // Liste "zerstoeren"

declare PflichtfeldZurListeHinzufuegen(var aListPflicht : int) : logic; // Feld zur Liste hinzufuegen
declare PflichtfeldAusListeLoeschen(var aListPflicht : int) : logic;  // Feld aus Liste loeschen
// ---------

declare PflichtfeldVorhanden(aName : alpha;) : logic; // guckt ob das Feld bereits ein Pflichtfeld ist

declare PflichtfelderPruefen() : logic; // ueberprueft alle Pflichtfelder vor dem speichern

// ------------
declare InsertFeld(var aList : int) : logic; // Feld zur Liste hinzufuegen


//========================================================================
sub SetCaption(
  aObj          : int;
  aDBFieldName  : alpha;
  aTyp          : int;
  aMaxLen       : int;
  aCap          : alpha(1000);
)
begin

  try begin
    // Laufzeitfehler abfangen
    ErrTryCatch(_ErrCnv, true);
    ErrTryCatch(_ErrValueOverflow, true);

    case (aTyp) of
      _TypeAlpha  : begin
        if (aObj<>0) then begin
          FldDefByName(aObj->wpdbFieldname, StrCut(aCap,1,aMaxLen));
          aObj->winupdate(_WinUpdFld2Obj);
        end
        else if (aDbFieldName<>'') then begin
          FldDefByName(aDbFieldname, StrCut(aCap,1,aMaxLen));
        end;
      end;
      _TypeByte   : begin end;
      _TypeDate   : begin end;
      _TypeFloat  : begin
        if (aObj<>0) then begin
          FldDefByName(aObj->wpdbFieldname, cnvfa(aCap));
          aObj->winupdate(_WinUpdFld2Obj);
        end
        else if (aDbFieldName<>'') then begin
          FldDefByName(aDbFieldname, cnvfa(aCap));
        end;
      end;
      _Typeint    : begin
        if (aObj<>0) then begin
          FldDefByName(aObj->wpdbFieldname, cnvia(aCap));
          aObj->winupdate(_WinUpdFld2Obj);
        end
        else if (aDbFieldName<>'') then begin
          FldDefByName(aDbFieldname, cnvia(aCap));
        end;
      end;
      _TypeWord   : begin
        if (aObj<>0) then begin
          FldDefByName(aObj->wpdbFieldname, cnvia(aCap));
          aObj->winupdate(_WinUpdFld2Obj);
        end
        else if (aDbFieldName<>'') then begin
          FldDefByName(aDbFieldname, cnvia(aCap));
        end;
      end;

      _WinTypeEdit      : if (aObj<>0) then aObj->wpcaption # aCap;
      _WinTypeIntEdit   : if (aObj<>0) then aObj->wpcaptionint # cnvia(aCap);
      _WinTypeDateEdit  : begin end;//if (aObj->wpcaptiondate <> 0.0.0000) then begin
      _WinTypeFloatEdit : if (aObj<>0) then aObj->wpcaptionfloat # cnvfa(aCap);
      _WinTypeTimeEdit  : begin end;//if (aObj->wpcaptiontime <> 0:0) then begin
    end;
  end;  // TRY
  if (ErrGet() != _ErrOk) then RETURN;
  
  
//      Adr.Zusatz # StrCut(CUS.AWF.Kuerzel,1,aMaxLen);
//      aObj->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  IstKonform
//    prueft ob ein Feld konform geüllt ist
//========================================================================
sub IstKonform(
  aObj          : int;
  aDbFieldName  : alpha;
  aBereich      : alpha;
  aMussGefuellt : logic;
  aMussBereich  : logic;
  aBenutzeLang  : logic;) : logic;
local begin
  Erx     : int;
  vIsNull : logic;
  vA      : alpha;
  vInhalt : alpha;
  vOk     : logic;
  vTyp    : int;
  vMaxLen : int;
end;
begin
//debugx(aObj->wpnamE);
  vOK # false;

  try begin
    // Laufzeitfehler abfangen
    ErrTryCatch(_ErrNoFld, true); // Feld nicht vorhanden
    ErrTryCatch(_ErrPropinvalid, true); // Es wurde eine Eigenschaft angegeben, über die das Objekt nicht verfügt.
    ErrTryCatch(_ErrFldType, true); // Der Fehler kann bei der Benutzung eines Feldes der Datenstruktur oder der Zuweisung zu einer Variablen eines falschen Types auftreten.

//  try begin 03.02.2021 nach OBEN
    if (aDbFieldname<>'') then begin
      vA # aDbFieldName;
    end
    else begin
      if (aObj=0) then RETURN true;
      vA # aObj->wpDbFieldName; // Name des Objekt ermitteln
    end;

    vIsNull # true;
    if (vA <> '') then begin
      vTyp # FldInfobyName(vA, _FldType);
      case (vTyp) of // Feldinformationen über Feldname ermitteln und den Typ ermitteln
        _TypeAlpha  : begin
          vMaxLen # FldInfobyName(vA, _FldLen);
          if (FldAlphaByName(vA)<>'') then begin
            vInhalt # FldAlphaByName(vA);
            vIsNull # false;
          end;
        end;
        _TypeByte   : begin
          if (FldintbyName(vA)<>0) then begin
            vInhalt # aint(FldintbyName(vA));
            vIsNull # false;
          end;
        end;
        _TypeDate   : begin
          if (FlddateByName(vA)<>0.0.0000) then begin
            vInhalt # cnvad(FlddateByName(vA));
            vIsNull # false;
          end;
        end;
        _TypeFloat  : begin
          if (FldfloatByName(vA)<>0.0) then begin
            vInhalt # anum(FldfloatByName(vA),2);
//debugx(vInhalt);
            vIsNull # false;
          end;
        end;
        _Typeint    : begin
          if (FldIntByName(vA)<>0) then begin
            vInhalt # aint(FldIntByName(vA));
            vIsNull # false;
          end;
        end;
        _TypeTime   : begin
          if (FldTimebyName(vA)<>0:0) then begin
            vInhalt # cnvat(FldTimebyName(vA));
            vIsNull # false;
          end;
        end;
        _TypeWord   : begin
          if (FldWordByName(vA)<>0) then begin
            vInhalt # aint(FldWordByName(vA));
            vIsNull # false;
          end;
        end;
      end;
      
    end
    else begin
      vTyp # WinInfo(aObj, _Wintype);
      case (vTyp) of // Feldinformationen über Feldname ermitteln und den Typ ermitteln
        _WinTypeEdit      : if (aObj->wpcaption <> '') then begin
            vInhalt # aObj->wpcaption;
            vIsNull # false;
          end;
        _WinTypeIntEdit   : if (aObj->wpcaptionint <> 0) then begin
            vInhalt # aint(aObj->wpcaptionint);
            vIsNull # false;
          end;
        _WinTypeDateEdit  : if (aObj->wpcaptiondate <> 0.0.0000) then begin
            vInhalt # cnvad(aObj->wpcaptionDate);
            vIsNull # false;
          end;
        _WinTypeFloatEdit : if (aObj->wpcaptionfloat <> 0.0) then begin
            vInhalt # anum(aObj->wpcaptionFloat,2);
            vIsNull # false;
//debugx(vInhalt);
          end;
        _WinTypeTimeEdit  : if (aObj->wpcaptiontime <> 0:0) then begin
            vInhalt # cnvat(aObj->wpcaptionTime);
            vIsNull # false;
          end;
      end;
    end;
  end;  // TRY
  if (ErrGet() != _ErrOk) then RETURN false;


  if (vIsNull) and (aMussGefuellt) then RETURN false;   // Leer, aber ein Muss !
 
  if (aMussBereich=false) then RETURN true;

  if (vIsNull) then RETURN true;                        // Leer, aber kein Muss!
//debugx(aObj->wpname+'('+vInhalt+') soll sein aus '+aBereich);
  // Über Kürzel suchen?
  if (StrLen(vInhalt)<=3) then begin
    CUS.AWF.Bereich # aBereich;
    CUS.AWF.Kuerzel # vInhalt;
    Erx # RecRead(932,3,0);
    if (Erx<=_rMultikey) then begin
      if (aBenutzeLang) then SetCaption(aObj, vA, vTyp, vMaxLen, CUS.AWF.Begriff)
      else SetCaption(aObj, vA, vTyp, vMaxLen, CUS.AWF.Kuerzel);
      RETURN true;
    end;
  end;

  // Über Langebegriff suchen...
  CUS.AWF.Bereich # aBereich;
  CUS.AWF.Begriff # vInhalt;
  Erx # RecRead(932,2,0);
  if (Erx<=_rMultikey) then begin
    if (aBenutzeLang=false) then SetCaption(aObj, vA, vTyp, vMaxLen, CUS.AWF.Kuerzel)
    else SetCaption(aObj, vA, vTyp, vMaxLen, CUS.AWF.Begriff);
    RETURN true;
  end;

  RETURN false;

end;


//========================================================================
sub Aktualisiere907(aRecId : int)
local begin
  Erx   : int;
  vObj  : int;
  vA    : alpha(1000);
  vTyp  : int;
end;
begin
//debugx(Dia.Pf.Pflichtfeld);
  if (gMDI=0) then RETURN;
  vObj # gMdi->WinSearch(Dia.Pf.Pflichtfeld); // Objekt anhand des Namens holen
  if (vObj=0) then begin
    RETURN;
  end;
//debugx('');
  vA # vObj->wpDbFieldName; // Name des Objekt ermitteln
  if (vA = '') then begin
    RETURN;
  end;
  /***
  vTyp # FldInfobyName(vA, _FldType);
  case (vTyp) of // Feldinformationen über Feldname ermitteln und den Typ ermitteln
    _TypeAlpha  : begin
      vA # 'A:'+vA;
    end;
    _TypeByte   : begin
      vA # 'B:'+vA;
    end;
    _TypeDate   : begin
      vA # 'D:'+vA;
    end;
    _TypeFloat  : begin
      vA # 'F:'+vA;
    end;
    _Typeint    : begin
      vA # 'I:'+vA;
    end;
    _TypeTime   : begin
      vA # 'T:'+vA;
    end;
    _TypeWord   : begin
      vA # 'W:'+vA;
    end;
    otherwise vA # '';
  end;
***/
//debugx('set '+vA);
  Erx # RecRead(907, 0, 0, arecid);
  if (Erx<=_rLocked) then begin
    Erx # RecRead(907, 1, _reCLock);
    Dia.Pf.DbFieldName # vA;
    Erx # RekReplace(907,0);    // 2023-07-20 AH war RecReplace!!
  end;
end;


//========================================================================
//  PflichtfeldVorhanden
//    guckt ob das Focusierte Feld bereits ein Pflichtfeld ist
//
//========================================================================
sub PflichtfeldVorhanden(aName : alpha;) : logic;
local begin
  Erx : int;
end;
begin
  RecBufClear(907); // Datemsatzpuffer der Pflichtfelddatei leeren

  if(gMdi = 0) or (aName = '') then // Fenster vorhanden? Feld angegeben?
    RETURN false;

  // Felder belgen
  Dia.Pf.Name # gMdi -> wpname;
  Dia.Pf.Pflichtfeld # aName;

  Erx # RecRead(907, 1, 0); // nach fokussiertem Feld in der Pflichtfeld Datei suchen
  if(Erx <= _rLocked) then
    RETURN true;

  RecBufClear(907); // Datemsatzpuffer der Pflichtfelddatei leeren
  RETURN false;
end;


//========================================================================
//  PflichtfelderListeFuellen
//    erstellt zu einem Dialog eine Liste und fuellt
//    diese mit den vom Benutzer definierten Pflichtfeldern
//========================================================================
sub PflichtfelderListeFuellen(
  aName             : alpha;
  var aListPflicht  : int;
  var aListAuswahl  : int;
  opt anurCust      : logic)
local begin
  Erx     : int;
  vList   : int;
  vHdl2   : int;
  vI      : int;
  vBuf906 : int;
end;
begin
  RecBufClear(907); // Datemsatzpuffer der Pflichtfelddatei leeren

  if(aName = '') then // Dialogname angegeben?
    RETURN;

  if (aNurCust=falsE) then
    aListPflicht # CteOpen(_CteList); // Liste erzeugen

  vBuf906 # RekSave(906);

  Dia.Name # aName;
  Erx # RecLink(907,906,1,_recfirst);
  WHILE (Erx<=_rLocked) do begin

    if (aNurCust=false) and (Dia.Pf.Nachricht<>'') then
      InsertFeld(var aListPflicht); // Pflichtfeld zur Liste hinzufuegen

    if (Dia.Pf.CstAusBereich<>'') then
      InsertFeld(var aListAuswahl);  // Customauswahlfeld zur Liste hinzufuegen

    Erx # RecLink(907,906,1,_recNext);
  END;

  RekRestore(vBuf906);
end;


//========================================================================
//  PflichtfelderListeLoeschen
//    loescht Liste der Pflictfelder beim schließen des Fensters
//========================================================================
sub PflichtfelderListeLoeschen(
  var aListPflicht : int;
  var aListAuswahl : int;
)
begin
  if (aListPflicht<> 0) then begin
    Lib_Ramsort:KillList(aListPflicht);  // Liste "zerstoeren"
    aListPflicht # 0;;
  end;
  if (aListAuswahl<>0) then begin
    Lib_Ramsort:KillList(aListAuswahl);  // Liste "zerstoeren"
  end;;
end;


//========================================================================
//  NeuesPflichtfeld
//    fuegt ein Feld zu den Pflichtfeldern hinzu
//========================================================================
sub NeuesPflichtfeld(var aListPflicht : int) : logic;
local begin
  vObj : int;
end;
begin
  // Objekt mit Eingabefokus ermitteln
  vObj # WinFocusGet();
  if(PflichtfeldDatensatzAnlegen(vObj) = false) then // Pflichtfeld in der Datenbank anlegen
    RETURN false;

  if (InsertFeld(var aListPflicht) = false) then // Pflichtfeld zur Liste hinzufuegen
    RETURN false;

  RETURN true;
end;


//========================================================================
//  PflichtfeldLoeschen
//    entfernt ein Feld aus den Pflichtfeldern
//========================================================================
sub PflichtfeldLoeschen(var aListPflicht : int) : logic;
local begin
  vObj : int;
end;
begin

  vObj # WinFocusGet(); // Objekt mit Eingabefokus ermitteln
  if(PflichtfeldDatensatzLoeschen() = false) then // Pflichtfeld aus Datenbank loeschen
    RETURN false;

  if(PflichtfeldAusListeLoeschen(var aListPflicht) = false) then // Pflichtfeld aus Liste entfernen
    RETURN false;

  vObj -> wpColBkg # _WinColWindow; // "standard" Hintergrundfarbe

  RETURN true;
end;


//========================================================================
//  PflichtfeldAusListeLoeschen
//    loescht ein Pflichtfeld aus der Liste w_Pflichtfeld
//========================================================================
sub PflichtfeldAusListeLoeschen(
  var aListPflicht : int;
) : logic;
local begin
  vItem : int;
end;
begin

  vItem # aListPflicht -> CteRead(_CteFirst | _CteSearch, 0, Dia.Pf.Pflichtfeld); // Feld in Liste suchen
  if(vItem = 0) then
    RETURN false;

  if (aListPflicht -> CteDelete(vItem) = false) then // Feld aus Liste loeschen
    RETURN false;

  RETURN true;
end;


//========================================================================
//  PflichtfeldDatensatzAnlegen
//    legt ein neues Pflichtfeld in der (907)Dia.Pflichtfelder an
//========================================================================
sub PflichtfeldDatensatzAnlegen(aObj : int;) : logic;
local begin
  Erx : int;
end;
begin
    RecBufClear(907);
    if(gMdi <> 0) then
      Dia.Pf.Name        # gMdi->wpname;  // mit Namen des Fenster belgen

    if(aObj <> 0) then
      Dia.Pf.Pflichtfeld # aObj->wpname;  // mit Namen des Feldes belegen
    //Dia.Pf.Nachricht   # Dia.Pf.Pflichtfeld + ' AUTO ANGELEGT ' + cnvAD(today) + ' um ' + cnvAT(now);

    Dia.Pf.Anlage.Datum # today;
    Dia.Pf.Anlage.Zeit  # now;
    Dia.Pf.Anlage.User  # gUsername;

    Erx # RekInsert(907, 0, 'AUTO');
    if(Erx <> _rOK) then
      RETURN false;

    RETURN true;
end;


//========================================================================
//  PflichtfeldDatensatzLoeschen
//    loescht ein Pflichtfeld in der (907)Dia.Pflichtfelder an
//========================================================================
sub PflichtfeldDatensatzLoeschen() : logic;
local begin
  Erx : int;
end;
begin
  Erx # RekDelete(907, 0, 'MAN'); // Pflichtfeld aus der Datenbank entfernen
  if(Erx <> _rOK) then
    RETURN false;

  RETURN true;
end;


//========================================================================
//  PflichtfelderEinfaerben
//    markiert Pflichtfelder farbig
//========================================================================
sub PflichtfelderEinfaerben()
local begin
  vItem : int;
  vObj  : int;
  vMuss : alpha;
  vHdl  : int;
end;
begin

  // gucken ob das Fenster im richtigen Modus ist
  if (Mode <> c_ModeNew) and (Mode <> c_ModeEdit) and (Mode <> c_ModeNew2) and (Mode <> c_ModeEdit2) then
    RETURN;

  FOR   vItem # Lib_RamSort:ItemFirst(w_Pflichtfeld)      // 1 Element der Liste lesen
  LOOP  vItem # Lib_RamSort:ItemNext(w_Pflichtfeld, vItem)// naechstes Elemtent lesen
  WHILE (vItem <> 0) do begin
    // Datensatz holen
//    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);
    Dia.Pf.Pflichtfeld    # vItem->spname;
    Dia.Pf.CstausBereich  # Str_Token(StrCut(vItem->spcustom,2,100),'|',1);
    Dia.Pf.BenutzeLangT   # Str_Token(vItem->spcustom,'|',2)='1';
    Dia.Pf.KeinFreitext   # Str_Token(vItem->spcustom,'|',3)='1';
    Dia.Pf.LeerErlaubt    # Str_Token(vItem->spcustom,'|',4)='1';
    Dia.Pf.DbFieldName    # Str_Token(vItem->spcustom,'|',5);
    Dia.Pf.Nachricht      # Str_Token(vItem->spcustom,'|',6);
    if (Dia.Pf.DbFieldName='') then begin
      Aktualisiere907(vItem->spid);
    end;

    vObj # gMdi->WinSearch(Dia.Pf.Pflichtfeld); // Objekt anhand des Namens holen

    if (vObj = 0) then // Feldgefunden?
      CYCLE;

    if (vObj->wpdisabled = true) or (vObj->wpreadonly) then // Feld diasabled oder ReadOnly?
      CYCLE;

//if (IstKonform(vObj, Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, True, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then  2023-07-20  AH : VBS
  if (IstKonform(vObj,  Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, Dia.Pf.LeerErlaubt=false, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then
      vObj->wpColBkg # _WinColLightYellow;
    else // Feld ausgefuellt
      vObj->wpColBkg # _WinColWindow; // "standard" Hintergrundfarbe
  END;


  // Auswahlfelder FALSCH befüllt?
  if (w_Obj4Auswahl<>0) then begin

    FOR   vItem # w_Obj4Auswahl->CteRead(_CteFirst)
    LOOP  vItem # w_Obj4Auswahl->CteRead(_CteNext, vItem)
    WHILE (vItem <> 0) do begin
      if (vItem->spID=0) then CYCLE;
      // Datensatz holen
//      Erx # RecRead(907, 0, 0, vItem->spID);
      Dia.Pf.Pflichtfeld    # vItem->spname;
      Dia.Pf.CstausBereich  # Str_Token(StrCut(vItem->spcustom,2,100),'|',1);
      Dia.Pf.BenutzeLangT   # Str_Token(vItem->spcustom,'|',2)='1';
      Dia.Pf.KeinFreitext   # Str_Token(vItem->spcustom,'|',3)='1';
      Dia.Pf.LeerErlaubt    # Str_Token(vItem->spcustom,'|',4)='1';
      Dia.Pf.DbFieldName    # Str_Token(vItem->spcustom,'|',5);
      Dia.Pf.Nachricht      # Str_Token(vItem->spcustom,'|',6);
      if (Dia.Pf.DbFieldName='') then begin
        Aktualisiere907(vItem->spid);
      end;

      if (Dia.Pf.KeinFreitext=false) then CYCLE;

      vObj # gMdi->WinSearch(Dia.Pf.Pflichtfeld); // Objekt anhand des Namens holen
      if (vObj = 0) then // Feldgefunden?
        CYCLE;
      if (vObj->wpdisabled = true) or (vObj->wpreadonly) then // Feld disabled oder readonly?
        CYCLE;
      vHdl # vObj -> WinInfo(_WinParent, 0, _WinTypeNotebookPage);                          // bei deaktivierter oder unsichtbarem NB
      if((vHdl -> wpdisabled = true) or (vHdl -> wpVisible = false)) and (vHdl <> 0) then   // nicht pruefen
        CYCLE;

      if (IstKonform(vObj,  Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, Dia.Pf.LeerErlaubt=false, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then
        vObj->wpColBkg # _WinColLightYellow;
      else // Feld ausgefuellt
        vObj->wpColBkg # _WinColWindow; // "standard" Hintergrundfarbe

  //debug('NB-Name: ' + vHdl -> wpname + '    DISABLED: ' + AInt(cnvIL(vHdl -> wpdisabled)) + '     VISIBLE: ' + AInt(cnvIL(vHdl -> wpVisible)));
    END;
 
  end;

end;


//========================================================================
//  PflichtfelderPruefenVorSpeichern
//    prueft ALLE Pflichtfelder vor dem Speichern des Datensatzes
//========================================================================
sub _PruefenVorSpeichern(
  aListPflicht  : int;
  aListAuswahl  : int;
) : logic;
local begin
  vA            : alpha;
  vItem         : int;
  vOk           : logic;
  vObj          : int;
  vHdl          : int;
end;
begin
  FOR   vItem # Lib_RamSort:ItemFirst(aListPflicht)       // 1 Element der Liste lesen
  LOOP  vItem # Lib_RamSort:ItemNext(aListPflicht, vItem) // naechstes Elemtent lesen
  WHILE (vItem <> 0) do begin
  
    // Datensatz holen
//    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);
    Dia.Pf.Pflichtfeld    # vItem->spname;
    Dia.Pf.CstausBereich  # Str_Token(StrCut(vItem->spcustom,2,100),'|',1);
    Dia.Pf.BenutzeLangT   # Str_Token(vItem->spcustom,'|',2)='1';
    Dia.Pf.KeinFreitext   # Str_Token(vItem->spcustom,'|',3)='1';
    Dia.Pf.LeerErlaubt    # Str_Token(vItem->spcustom,'|',4)='1';
    Dia.Pf.DbFieldName    # Str_Token(vItem->spcustom,'|',5);
    Dia.Pf.Nachricht      # Str_Token(vItem->spcustom,'|',6);

    vObj # gMdi->WinSearch(Dia.Pf.Pflichtfeld); // Objekt anhand des Namens holen

    if(vObj>0) then begin// Feldgefunden?
      if (vObj->wpdisabled = true) or (vObj->wpreadonly) then // Feld disabled oder readonly?
        CYCLE;
      vHdl # vObj -> WinInfo(_WinParent, 0, _WinTypeNotebookPage);                          // bei deaktivierter oder unsichtbarem NB
      if((vHdl -> wpdisabled = true) or (vHdl -> wpVisible = false)) and (vHdl <> 0) then   // nicht pruefen
        CYCLE;
    //debug('NB-Name: ' + vHdl -> wpname + '    DISABLED: ' + AInt(cnvIL(vHdl -> wpdisabled)) + '     VISIBLE: ' + AInt(cnvIL(vHdl -> wpVisible)));
    end;
    
//    if (PflichtfeldAusgefuellt(vObj, Dia.Pf.CstAusBereich) = false) then begin // Feld nicht ausgefuellt
//if (IstKonform(vObj,  Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, True, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then begin  2023-07-20  AH : VBS
if (IstKonform(vObj,  Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, Dia.Pf.LeerErlaubt=false, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then begin
      if(Dia.Pf.Nachricht <> '') then // falls nicht ausgefuellt Pfeldbezogene Nachricht ausgeben
        Msg(99,Dia.Pf.Nachricht, 0, 0, 0);
      else
        Msg(001200, Dia.Pf.Pflichtfeld, 0, 0, 0);

      if (vObj>0) then begin
        vHdl # vObj -> WinInfo(_WinParent, 0, _WinTypeNotebookPage); // Notebookpage ermitteln
        if(vHdl <> 0) then
          $NB.Main->wpcurrent # vHdl->wpname; // und ggf. setzen

        vObj->WinFocusSet(true); // Focus auf das Feld setzen
      end;
      RETURN false
    end;

  END;


  if (aListAuswahl=0) then RETURN true;;

  FOR   vItem # aListAuswahl->CteRead(_CteFirst)
  LOOP  vItem # aListAuswahl->CteRead(_CteNext, vItem)
  WHILE (vItem <> 0) do begin
    if (vItem->spID=0) then CYCLE;

    // Datensatz holen
//    Erx # RecRead(907, 0, 0, vItem->spID);
//      Erx # RecRead(907, 0, 0, vItem->spID);
    Dia.Pf.Pflichtfeld    # vItem->spname;
    Dia.Pf.CstausBereich  # Str_Token(StrCut(vItem->spcustom,2,100),'|',1);
    Dia.Pf.BenutzeLangT   # Str_Token(vItem->spcustom,'|',2)='1';
    Dia.Pf.KeinFreitext   # Str_Token(vItem->spcustom,'|',3)='1';
    Dia.Pf.LeerErlaubt    # Str_Token(vItem->spcustom,'|',4)='1';
    Dia.Pf.DbFieldName    # Str_Token(vItem->spcustom,'|',5);
    Dia.Pf.Nachricht      # Str_Token(vItem->spcustom,'|',6);
    if (Dia.Pf.KeinFreitext=false) then CYCLE;

    vObj # gMdi->WinSearch(Dia.Pf.Pflichtfeld); // Objekt anhand des Namens holen
    if(vObj <> 0) then begin// Feldgefunden?
      if (vObj->wpdisabled = true) or (vObj->wpreadonly) then // Feld disabled oder readonly?
        CYCLE;
      vHdl # vObj -> WinInfo(_WinParent, 0, _WinTypeNotebookPage);                          // bei deaktivierter oder unsichtbarem NB
      if((vHdl -> wpdisabled = true) or (vHdl -> wpVisible = false)) and (vHdl <> 0) then   // nicht pruefen
        CYCLE;
      end;

//debug('NB-Name: ' + vHdl -> wpname + '    DISABLED: ' + AInt(cnvIL(vHdl -> wpdisabled)) + '     VISIBLE: ' + AInt(cnvIL(vHdl -> wpVisible)));

//    if (AuswahlFeldRichtigGefuellt(vObj, Dia.Pf.CstAusBereich, Dia.Pf.BenutzeLangT) = false) then begin // Feld nicht ausgefuellt
    if (IstKonform(vObj,  Dia.Pf.DbFieldName, Dia.Pf.CstAusBereich, Dia.Pf.LeerErlaubt=false, Dia.Pf.KeinFreitext, Dia.Pf.BenutzeLangT)=false) then begin
      if(Dia.Pf.Nachricht <> '') then // falls nicht ausgefuellt Pfeldbezogene Nachricht ausgeben
        Msg(99,Dia.Pf.Nachricht, 0, 0, 0);
      else
        Msg(001200, Dia.Pf.Pflichtfeld, 0, 0, 0);

      if (vObj>0) then begin
        vHdl # vObj -> WinInfo(_WinParent, 0, _WinTypeNotebookPage); // Notebookpage ermitteln
        if(vHdl <> 0) then
          $NB.Main->wpcurrent # vHdl->wpname; // und ggf. setzen
        vObj->WinFocusSet(true); // Focus auf das Feld setzen
      end;

      RETURN false
    end;

  END;

  RETURN true
end;


//========================================================================
//  PflichtfelderPruefenVorSpeichern
//    prueft ALLE Pflichtfelder vor dem Speichern des Datensatzes
//========================================================================
sub PflichtfelderPruefenVorSpeichern(
  opt aDialog : alpha;
) : logic;
local begin
  vListPflicht  : int;
  vListAuswahl  : int;
  vOK           : logic;
  vBuf          : int;
end;
begin
  if (aDialog<>'') then begin
    vBuf # Lib_MoreBufs:GetBuf(231, '');
    if (vBuf<>0) then RecbufCopy(vBuf,231);
    aDialog # Lib_GuiCom:GetAlternativeName(aDialog);
//debugx(aDialog);
    PflichtfelderListeFuellen(aDialog, var vListPflicht, var vListauswahl);
    vOK # _PruefenVorSpeichern(vListPflicht, vListAuswahl);
    PflichtfelderListeLoeschen(var vListPflicht, var vListauswahl);
  end
  else begin
    vOK # _PruefenVorSpeichern(w_Pflichtfeld, w_Obj4Auswahl);
  end;
    
  RETURN vOK;
end;
  

//========================================================================
//  AddToContext
//
//========================================================================
sub AddToContext(aMdi : int;);
local begin
  vContext : int;
  vFrame : int;
  vObj : int;
end;
begin
  RETURN;
  // Rechtecheck
  //if(Rechte[Rgt_Pflichtfelder_Anlegen] = false) then
    //RETURN;

  // Context vorhanden?
  if (aMdi = 0) then
    RETURN;

debug('Hab ein Fenster!');

  vFrame # aMdi -> WinInfo(_WinFrame);
  FOR vObj # vFrame -> WinInfo(_WinFirst);
  LOOP vObj # vFrame -> WinInfo(_WinNext);
  WHILE(vObj <> 0) DO BEGIN
    debug(vObj -> wpname);
  END;

debug('FRAME: ' + AInt(vFrame));
  vContext # vFrame -> WinInfo(_WinContextMenu);

  if(vContext = 0) then
    RETURN;

debug('Hab das Context-Menu! ' + vContext->wpname);


  vContext->WinMenuItemAdd('PF', '&Pflichtfeld', 0);
end;


//========================================================================
//  SetzeContextInFenstern
//    NICHT AKTIV
//========================================================================
sub SetzeContextInFenstern(aMdi : int;);
local begin
  vHdl        : handle;
  vStoDir     : int;
  vStoObjName : alpha;
  vStoObj     : handle;
end;
begin

  // Dialoge durchlaufen und bearbeiten
  vStoDir # StoDirOpen(0, 'Dialog');
  FOR  vStoObjName # vStoDir->StoDirRead(_stoFirst); // erster Dialog
  LOOP vStoObjName # vStoDir->StoDirRead(_stoNext, vStoObjName); // naechster Dialog
  WHILE (vStoObjName <> '') DO BEGIN
    if (StrCut(vStoObjName, 0, 8) = 'AppFrame')
    or (StrCut(vStoObjName, 0, 4) = 'Math')
    or (StrCut(vStoObjName, 0, 6) = 'AF_Frm')
    or (StrCut(vStoObjName, 0, 12) = 'Mdi.Tastatur') then
      CYCLE;


    // Dialog oeffnen
    debug('[Dialog] Öffne ' + vStoObjName + ' als MDI...');
    vHdl # WinOpen(vStoObjName, _winOpenLock);
    if (vHdl<= 0) then begin
      debug('[Dialog] Öffne ' + vStoObjName + ' als Dialog...');
      vHdl # WinOpen(vStoObjName, _winOpenDialog | _winOpenLock);
      if (vHdl<= 0) then begin
        debug('[Dialog] ***** Fehler beim Öffnen von ' + vStoObjName + ' (' + CnvAI(ErrGet()) + ')');
        CYCLE;
      end;
    end;

    // Dialog editieren
    if(vHdl -> wpMenuNameCntxt <> '') then
      vHdl->wpMenuNameCntxt # 'std.Kontext';

    //if(vHdl->_WinEvtMenuInitPopup


    // Dialog speichern
    if (vHdl->WinSave(_winSaveOverwrite) <> _errOk) then
      debug('[Dialog] Fehler beim Speichern von ' + vStoObjName);
    vHdl->WinClose();
  END;
  vStoDir->StoClose();
end;


//========================================================================
//  InsertFeld
//    fuegt ein Feld in eine Liste ein
//========================================================================
sub InsertFeld(var aList : int): logic
local begin
  vItem : int;
  vA    : alpha(1000);
end
begin
  // Anlegen eines neuen Item Elements
  vItem # CteOpen(_CteItem);
  if (vItem = 0) then
    RETURN false;

  if (aList=0) then
    aList # CteOpen(_CteTree); // TREE erzeugen

  vA # '#'+Dia.Pf.CstAusBereich+'|'+abool(Dia.Pf.BenutzeLangT)+'|'+abool(Dia.Pf.KeinFreitext)+'|'+aBool(Dia.Pf.LeerErlaubt)+'|'+Dia.Pf.DbFieldName+'|'+Dia.Pf.Nachricht;

  // Eigenschaften des Objekts setzen
  vItem->spName # Dia.Pf.Pflichtfeld;
  vItem->spID # RecInfo(907, _recID);
  vItem->spCustom # vA;

  if (CteInsert(aList, vItem) = false) then // Anhaengen des Elements in die Liste
    RETURN false

  RETURN true;
end;


//========================================================================
//  SetStdAuswahlFeld
//
//========================================================================
sub SetStdAuswahlFeld(
  aName       : alpha;
  aBereich    : alpha;
  opt aSpezi  : logic;
): logic
local begin
  vItem : int;
end
begin
  // Anlegen eines neuen Item Elements
  vItem # CteOpen(_CteItem);
  if (vItem = 0) then
    RETURN false;

  // Eigenschaften des Objekts setzen
  vItem->spName # aName;
  //  KEINE RECID SETZEN per vItem->spID # RecInfo(907, _recID);

  // Spezi sind Felder, die durch eine besondere Bedingung AUSWÄHLBAR werden
  // diese bekommen ein § vorweg und werden über die APP_MAIN NICHT rot, sondern
  // müssen in der xxx_Main extra eingefärbt werden -> siehe Auf_P_Main:Focusinit
  if (aSpezi) then
    vItem->spCustom # '§'+aBereich
  else
    vItem->spCustom # aBereich;

  if (w_Obj4Auswahl=0) then
    w_Obj4Auswahl # CteOpen(_CteTree); // TREE erzeugen
//debugx('add '+vItem->spname+'/'+vItem->spCustom);
  if (CteInsert(w_Obj4Auswahl, vItem) = false) then // Anhaengen des Elements in die Liste
    RETURN false

  RETURN true;
end;


//========================================================================
//  TypAuswahlFeld
//
//========================================================================
sub TypAuswahlFeld(
  aObj        : int;
  opt aSpezi  : logic) : alpha
local begin
  vItem : int;
end
begin

  // gar keine Auswahlfelder vorhanden? -> Ende
  if (aObj=0) or (w_Obj4Auswahl=0) then RETURN '';

  vItem # w_Obj4Auswahl->CteRead(_CteFirst | _CteSearchCI, 0, aObj->wpname);      // 2022-06-27 AH : CaseINsensitive
//debugx(aint(vItem)+' von '+aint(CteInfo(w_Obj4Auswahl,_ctecount)  ));
  // kein Auwahlobjekt - > Ende
  if (vItem=0) then RETURN '';

  // ist ein SPEZI-Auswahlfeld?
  if (StrCut(vItem->spcustom,1,1)='§') then RETURN '';

  // 21.05.2013 nur bei aktiven Feldern F9
  if (aObj->wpColBkg=c_ColInactive) then RETURN '';

  Dia.Pf.Pflichtfeld  # vItem->spname;
  Dia.Pf.BenutzeLangT # Str_Token(vItem->spcustom,'|',2)='1';
  Dia.Pf.KeinFreitext # Str_Token(vItem->spcustom,'|',3)='1';
  Dia.Pf.LeerErlaubt  # Str_Token(vItem->spcustom,'|',4)='1';
  Dia.Pf.DbFieldName  # Str_Token(vItem->spcustom,'|',5);
  Dia.Pf.Nachricht    # Str_Token(vItem->spcustom,'|',6);

  RETURN Str_Token(vItem->spcustom,'|',1);
end;

//========================================================================