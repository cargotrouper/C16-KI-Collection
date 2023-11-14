@A+
//===== Business-Control =================================================
//
//  Prozedur  Repair_Art
//                OHNE E_R_G
//  Info
//
//
//  17.03.2011  AI  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    SUB Lauf_vor_1.1111
//
//========================================================================
@I:Def_Global

define begin
  AddLine(a,b) :  TextLineWrite(a,TextInfo(a,_TextLines)+1,b,_TextLineInsert)
end;

//========================================================================
//  KillLEKohneAdr()
//
//  call Repair_Art:KillLEKohneAdr()
//      Löscht alle L-EK Preise ohne Adressnummer, aber mit Adressstw
//========================================================================
sub KillLEKohneAdr()  : int
local begin
  Erx       : int;
  vProgress : int;
  vCnt      : int;
  vVorher, vNachher : int;
end;
begin

  vVorher # RecInfo(254,_RecCount);
  vProgress # Lib_Progress:Init('Bereinige L-EK Preise',vVorher);

  debug('Art.P.ArtikelNr ; Art.P.Adressnr ; Art.P.AdrStichwort ; Art.P.Preistyp;Art.P.PreisW1');

  TRANSON;
  FOR   Erx # RecRead(254,1,_RecFirst);
  LOOP  Erx # RecRead(254,1,_RecNext);
  WHILE Erx <= _rLocked DO BEGIN
    if (vProgress->Lib_Progress:Step() = false) then begin
      TRANSBRK;
      vProgress->Lib_Progress:Term();
      RETURN -1;
    end;


    if (Art.P.ArtikelNr = '1309') then begin
    //  debugx('test');
    end;

    if (Art.P.Adressnr = 0) AND (Art.P.AdrStichwort <> '') AND (Art.P.Preistyp = 'L-EK') then begin

      debug(Art.P.ArtikelNr + ';' + Aint(Art.P.Adressnr) + ';' + Art.P.AdrStichwort+ ';' + Art.P.Preistyp + ';' + Anum(Art.P.PreisW1,2));

      // Löschen
      Erx # RekDelete(254,_RecUnlock, 'AUTO');
      if (Erx <> _rOK) then begin
        TRANSBRK;
        todo('Preis nicht Löschbar -> siehe Debug.txt');
        vProgress->Lib_Progress:Term();
        RETURN -1;
      end;

      RecRead(254,1,_RecPrev); //  Vorherigen Datensatz lesen

      inc(vCnt);

    end;

  END;
  TRANSOFF;
  vProgress->Lib_Progress:Term();
  vNachher # RecInfo(254,_RecCount);
  debug('Gelöschte Preise:' + aint(vCnt) + '   Vorher/Nachher:'+ Aint(vVorher) + '/' + Aint(vNachher));
  RETURN 1;
end;



//-
sub _RepairRef(
  aDatei    : int;
  aArtFld   : alpha;
  aCFld     : alpha;
  aAdrFld   : alpha;
  aAnschFld : alpha;
  aTxt      : int) : alpha;
local begin
  Erx       : int;
  vA,vB     : alpha(100);
  vI        : int;
  vBuf      : int;
  vCNeu     : alpha;
  vCount    : int;
end;
begin
debug('rep datei:'+aint(aDatei));
  vBuf # RecBufCreate(aDatei);

  Erx # RecRead(aDatei,1,_recFirst);
  WHILE (Erx<=_rLocked) and (vBuf<>0) do begin

    inc(vCount);

    RecbufCopy(aDatei,vBuf);
    // NÄCHSTEN Staz holen...
    Erx # RecRead(vBuf,1,_recNext);
    if (Erx>_rLockeD) then begin
      RecBufDestroy(vBuf);
      vBuf # 0;
    end;

/*
if (aDatei=701) and (vCount>100) then begin
  debug(aint(bag.io.nummer));
  vCount # 0;
end;
*/

    if (FldAlphaByName(aArtFld)<>'') then begin
      vA # 'FLIP:'+FldAlphaByName(aArtFld)+'|';
      vA # vA + FldAlphabyName(aCFld)+'|';
      vA # vA + aint(FldIntByName(aAdrFld))+'|';
      vA # vA + aint(FldWordByName(aAnschFld));
      vI # TextSearch(aTxt, 1,1, 0, vA);
      if (vI<>0) then begin
        vB # TextLineRead(aTxt,vI,0);
        vCNeu # Str_Token(vB,'~ZIEL:',2);
        if (vcNeu<>'') then begin
debug('flippen: '+fldalphabyname(aCFld)+' ---> '+vCneu);
          RecRead(aDatei,1,_recLock);
          FldDefByName(aCFld, vCNeu);
          Erx # RekReplace(aDatei,_recUnlock,'AUTO');
          if (Erx<>_rOK) then RETURN 'Datei '+aint(aDatei)+' nicht anpassbar!';
        end;
      end;
    end;

    // zum nächsten Satz...
    if (vBuf<>0) then begin
      RecBufCopy(vBuf,aDatei);
      Erx # RecRead(aDatei,1,0);
    end;
  END;

  if (vBuf<>0) then RecBufDestroy(vBuf);

  RETURN '';
end;


//========================================================================
//  Lauf_VOR_1.1111
//
//call repair_art:Lauf_vor_1.1111
//========================================================================
SUB Lauf_vor_1.1111
local begin
  Erx         : int;
  vTxt        : int;
  vA          : alpha(100);
  vI          : int;
  vNr         : int;
  vCNeu       : alpha;
  vVersionNeu : float;
  vErr        : alpha;
  vID         : int;
  vBuf252     : int;
  vBuf253     : int;
end;
begin

  vTxt # TextOpen(10);
  TextRead(vTxt, '!Version',0);
  vA # TextLineRead(vTxt,1,0);
  vVersionNeu # cnvfa(vA,_FmtNumPoint);
  TextClose(vTxt);

  if (vVersionNeu>=1.1111) then begin
    Msg(99,'Der Lauf kommt zu spät!! Der muss VOR der Verison 1.1111 gestartet werden!',0,0,0);
    RETURN;
  end;


  // START ----------------------
  vTxt # TextOpen(10);
  TextClear(vTxt);
  vBuf252 # RecBufCreate(252);

//TRANSON;


  // Chargen loopen...
  Erx # Recread(252,1,_recFirst);
  WHILE (Erx<=_rLocked) and (vErr='') do begin

    RecbufCopy(252,vBuf252);
    // NÄCHSTEN Staz holen...
    Erx # RecRead(vBuf252,1,_recNext);
    if (Erx>_rLockeD) then RecBufClear(vBuf252);


    vID # RecInfo(252,_recId);
//debug('ID '+aint(vID));

    Erx # RecLink(250,252,1,_recFirst);   // Artikel holen
    if (Erx>_rLockeD) then begin
//      vErr # 'Artikel '+Art.C.Artikelnr+' zu Charge nicht gefunden!';
//      BREAK;
debug('Artikel '+Art.C.Artikelnr+' zu Charge nicht gefunden!');
      RekDelete(252,0,'MAN');
debug('kill !');
      end

    else begin

      // Basischarge? -> überspringen
      if (Art.C.Adressnr=0) and (Art.C.Charge.Intern='') then begin
        Erx # Recread(252,1,_recNext);
        CYCLE;
      end;


      // KOMISCH???
      if (Art.C.Charge.Intern<>'') and ("Art.ChargenführungYN"=n) then begin
//          vErr # 'Bei ARtikel '+art.c.artikelnr+' der KEINE Chargenführung hat, exisitern Chargen!??!??';
//          BREAK;
debug('Artikel '+Art.C.Artikelnr+' hat CHARGEN obwohl keine Chargenführung! HAKEN wird gesetzt!!!');
        RecRead(250,1,_recLock);
        "Art.ChargenführungYN"  # y;
        RekReplace(250,_recUnlock,'AUTO');
//debug('kill !');
      end;


      // MIR CHARGENFÜHRUNG
      if ("Art.ChargenführungYN") then begin

        if (Art.C.Adressnr=0) or (Art.C.Charge.intern='') then begin
          RekDelete(252,0,'MAN');
//  debug('kill !');
          end
        else begin
          vA # 'OK:'+Art.C.Artikelnr+'|'+Art.C.Charge.Intern;
          vI # TextSearch(vTxt, 1,1, 0, vA);
          if (vI=0) then begin // gibt nicht
            vA # 'OK:'+Art.C.Artikelnr+'|'+Art.C.Charge.Intern+'|'+aint(Art.C.Adressnr)+'|'+aint(Art.C.Anschriftnr);
            AddLine(vTxt,vA); // alles so lassen!
//debug(vA);
            end
          else begin  // gibts schon!!!
            vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
            if (vNr<>0) then Lib_Nummern:SaveNummer()
            else begin
              vErr # 'Charngenummer nicht bestimmbar!'
              BREAK;
            end;
            vCNeu # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
            vA # 'FLIP:'+Art.C.Artikelnr+'|'+Art.C.Charge.Intern+'|'+aint(Art.C.Adressnr)+'|'+aint(Art.C.Anschriftnr);
            vA # vA + '~ZIEL:'+vCNeu;
            AddLine(vTxt,vA);
debug(vA);
            // umbenennen...
            RecRead(252,1,_recLock);
            Art.C.Charge.Intern # vCNeu;
            Erx # RekReplace(252,_recUnlock,'AUTO');
            if (Erx<>_rOK) then begin
              vErr # 'neue Charge existiert bereits!!!';
              BREAK;
            end;
          end;

        end;

        end
      else begin
      // OHNE CHARGENFÜHRUNG
        vNr # Lib_Nummern:ReadNummer('Artikel-Charge');
        if (vNr<>0) then Lib_Nummern:SaveNummer()
        else begin
          vErr # 'Charngenummer nicht bestimmbar!'
          BREAK;
        end;
        vCNeu # CnvAI(vNr,_FmtNumLeadZero | _FmtNumNoGroup,0,8);
        vA # 'C:'+Art.C.Artikelnr+'|'+Art.C.Charge.Intern+'|'+aint(Art.C.Adressnr)+'|'+aint(Art.C.Anschriftnr);
        vA # vA + ' ZIEL:'+vCNeu;
        AddLine(vTxt,vA);
//debug(vA);
        // umbenennen...
        RecRead(252,1,_recLock);
        Art.C.Charge.Intern # vCNeu;
        Erx # RekReplace(252,_recUnlock,'AUTO');
        if (Erx<>_rOK) then begin
          vErr # 'neue Charge existiert bereits!!!';
          BREAK;
        end;

      end;

    end;  // ...Artikel gefunden


    // zum nächsten Satz...
    if (vBuf252->Art.C.Artikelnr='') then begin
      Erx # _rNorec
      end
    else begin
      RecBufCopy(vBuf252,252);
      Erx # RecRead(252,1,0);
    end;
  END;

  // Referenzen setzen...
//call repair_art:Lauf_vor_1.1111
  if (vErr='') then vErr # _RepairRef(708, 'BAG.FM.B.Artikelnr', 'BAG.FM.B.Art.Charge', 'BAG.FM.B.Art.Adresse', 'BAG.FM.B.Art.Anschr', vTxt);
  if (vErr='') then vErr # _RepairRef(701, 'BAG.IO.Artikelnr', 'BAG.IO.Charge', 'BAG.IO.Lageradresse', 'BAG.IO.Lageranschr', vTxt);
  if (vErr='') then vErr # _RepairRef(655, 'VsP.Artikelnr', 'VSP.Art.Charge', 'VSP.Art.Adresse', 'VSP.Art.Anschrift', vTxt);
  if (vErr='') then vErr # _RepairRef(656, 'VsP~Artikelnr', 'VSP~Art.Charge', 'VSP~Art.Adresse', 'VSP~Art.Anschrift', vTxt);

  if (vErr='') then vErr # _RepairRef(251, 'Art.R.Artikelnr', 'Art.R.Charge.Intern', 'Art.R.Adressnr', 'Art.R.Anschrift', vTxt);

  if (vErr='') then vErr # _RepairRef(252, 'Art.C.Artikelnr', 'Art.C.Charge.Vorgäng', 'Art.C.Adressnr', 'Art.C.Anschriftnr', vTxt);
  if (vErr='') then vErr # _RepairRef(253, 'Art.J.Artikelnr', 'Art.J.Charge', 'Art.J.Adressnr', 'Art.J.Anschriftnr', vTxt);
  if (vErr='') then vErr # _RepairRef(253, 'Art.J.Ziel.Artikelnr', 'Art.J.Ziel.Charge', 'Art.J.Ziel.Adressnr', 'Art.J.Ziel.Anschrift', vTxt);
  if (vErr='') then vErr # _RepairRef(259, 'Art.Inv.Artikelnr', 'Art.Inv.Charge.Int', 'Art.Inv.Adressnr', 'Art.Inv.Anschrift', vTxt);
  if (vErr='') then vErr # _RepairRef(281, 'Pak.P.Artikelnr', 'Pak.P.Art.Charge', 'Pak.P.Art.Adresse', 'Pak.P.Art.Anschrift', vTxt);

//  if (vErr='') then vErr # _RepairRef(899, 'Sta.Lfs.Artikelnr', 'Sta.Lfs.Art.Charge', 'Ein.E.Lageradresse', 'Ein.E.Lageranschrift', vTxt);
//  if (vErr='') then vErr # _RepairRef(301, 'Ein.E.Artikelnr', 'Ein.E.Charge', 'Ein.E.Lageradresse', 'Ein.E.Lageranschrift', vTxt);

  if (vErr='') then vErr # _RepairRef(404, 'Auf.A.Artikelnr', 'Auf.A.Charge', 'Auf.A.Charge.Adresse', 'Auf.A.charge.Anschr', vTxt);

  if (vErr='') then vErr # _RepairRef(506, 'Ein.E.Artikelnr', 'Ein.E.Charge', 'Ein.E.Lageradresse', 'Ein.E.Lageranschrift', vTxt);
//  if (vErr='') then vErr # _RepairRef(540, 'Bdf.Artikelnr', 'Bdf.Charge', 'Ein.E.Lageradresse', 'Ein.E.Lageranschrift', vTxt);
  if (vErr='') then vErr # _RepairRef(621, 'Swe.P.Artikelnr', 'Swe.P.Charge', 'Swe.P.Lageradresse', 'SWe.P.Lageranschrift', vTxt);

//TRANSBRK; TODO('TRANSBRK');
//TRANSOFF;

  RecBufDestroy(vBuf252);


  // LAGERJOURNAL REPARIEREN...
  TextClear(vTxt);
  Erx # RecRead(253,1,_recfirsT);
  WHILE (Erx<=_rLockeD) do begin

    REPEAT
      vA # Art.J.ArtikelNr+'|'+Art.J.Charge+'|'+cnvad(Art.J.Datum)+'|'+aint(Art.J.lfdNr);
      vI # TextSearch(vTxt, 1,1, 0, vA);
      if (vI<>0) then begin // gibt schon
        vBuf253 # RekSave(253);
        RekDelete(253,0,'MAN');
        REPEAT
          inc(Art.J.lfdNr);
          Erx # RekInsert(253,0,'AUTO');
        UNTIL (Erx=_rOK);
  debug('neue nummer');
        RekRestore(vBuf253);
        BREAK;
        end
      else begin
        AddLine(vTxt,vA); // alles so lassen!
      end;
    UNTIL (vI=0);

    if (vI=0) then begin
      Erx # RecRead(253,1,_recNext);
      end
    else begin
      Erx # recread(253,1,0);
      Erx # recread(253,1,0);
    end;
  END;



  if (vErr<>'') then
    Msg(99,vErr,0,0,0)
  else
    Msg(999998,'',0,0,0);   // Erfolg

  TextClose(vTxt);

end;


//========================================================================