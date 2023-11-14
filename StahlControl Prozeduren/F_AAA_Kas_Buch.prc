@A+
//===== Business-Control =================================================
//
//  Prozedur    F_AAA_Kas_Buch
//                  OHNE E_R_G
//  Info
//    Druckt ein Kassenbuch
//
//
//  07.01.2013  AI  Erstellung der Prozedur
//  04.03.2015  ST  Abbruch der Druckerausgabe/Vorschau integriert
//  12.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB GetDokName(var aSprache : alpha; var aAdr : int) : alpha;
//    SUB SeitenKopf();
//    SUB SeitenFuss(aSeite : int);
//
//    MAIN (opt aFilename : alpha(4096))
//========================================================================
@I:Def_Global
@I:Def_Form

local begin
  // Druckelemente...
  elErsteSeite        : int;
  elFolgeSeite        : int;
  elSeitenFuss        : int;

  elPostenUS          : int;
  elPosten            : int;

  elEnde              : int;
  elLeerzeile         : int;
end;


//========================================================================
//  GetDokName
//            Bestimmt den Namen eines Doks anhand von DB-Feldern
//            ZWINGEND nötig zum Checken, ob ein Form. bereits existiert!
//========================================================================
sub GetDokName(
  var aSprache  : alpha;
  var aAdr      : int;
  ) : alpha;
begin
  aAdr      # Set.EigeneAdressnr;
  aSprache  # Set.Sprache1.Kurz;

  RETURN CnvAI(Kas.B.Kassennr,_FmtNumNoGroup | _FmtNumLeadZero,0,8); // Dokumentennummer
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  vTxtName    : alpha;
  vText       : alpha(500);
  vText2      : alpha(500);
  vBesteller  : alpha;
end;
begin

  // ERSTE SEITE??
  if (aSeite=1) then begin
    Form_Ele_Kas:elBuchErsteSeite(var elErsteSeite);
    end
  else begin
    Form_Ele_Kas:elBuchFolgeSeite(var elFolgeSeite);
  end;

  Form_Ele_Kas:elBuchPostenUS(var elPostenUS);

end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
  form_Elemente:elSeitenFuss(var elSeitenFuss, true);
end;


//========================================================================
//  Main
//
//========================================================================
MAIN (opt aFilename : alpha(4096))
local begin
  Erx       : int;
  // Datenspezifische Variablen
  vCount              : int;
  vAusgang            : float;
  vEingang            : float;
  vMwStSatz1          : float;
  vMwStWert1          : float;
  vMwStSatz2          : float;
  vMwStWert2          : float;
end;
begin

  // ------ Druck vorbereiten ----------------------------------------------------------------
  RekLink(100,903,1,_RecFirst);   // eigene Adresse holen
  RekLink(812,100,10,_recfirst);  // Land holen
  RekLink(814,100,5,_recfirst);   // Währung holen

//Kas.b.Start.Datum # 1.5.2012;
//Kas.b.Ende.Datum # 7.5.2012;
  vMwStSatz1 # -1.0;
  vMwStSatz2 # -1.0;

  // Job Öffnen + Page generieren
  if (  Lib_Print:FrmJobOpen(true, 0,0, false, false, false) < 0) then begin
    RETURN;
  end;


  Form_DokName # GetDokName(var Form_DokSprache, var form_DokAdr);
  Lib_Form:LoadStyleDef(Frm.Style);

  // Seitenfuss vorbereiten
  Form_Elemente:elSeitenFuss(var elSeitenFuss, false);

  Lib_Print:Print_Seitenkopf();


  // Übertrag drucken...
  RecbufClear(854);
  RecBufClear(572);
  Kas.B.P.Bemerkung # Translate('Anfangssaldo');
  Kas.B.P.Saldo     # Kas.B.Start.Saldo;
  Form_Ele_Kas:elBuchPosten(var elPosten);


  // Posten loopen...
  FOR Erx # RecLink(572,571,2,_Recfirst)
  LOOP Erx # RecLink(572,571,2,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    inc(vCount);

    RekLink(854,572,1,_recFirst);   // Gegenkonto holen

    Form_Ele_Kas:elBuchPosten(var elPosten);

    vAusgang # vAusgang + Kas.B.P.Ausgang;
    vEingang # vEingang + Kas.B.P.Eingang;

    if (Kas.B.P.Steuer<>0.0) then begin
      StS.Nummer # ("Kas.B.P.Steuerschl" * 100) + "Adr.Steuerschlüssel";
      Erx # RecRead(813,1,0);   // Steuerschluessel holen
      if (Erx<= _rLocked) then begin
        if (vMwstSatz1=-1.0) then begin
          vMwstSatz1 # StS.Prozent;
          vMwstWert1 # Kas.B.P.Steuer;
          end
        else if (vMwstSatz1=StS.Prozent) then begin
          vMwstWert1 # vMwstWert1 + Kas.B.P.Steuer;
          end
        else if (vMwstSatz2=-1.0) then begin
          vMwstSatz2 # StS.Prozent;
          vMwstWert2 # Kas.B.P.Steuer;
          end
        else if (vMwstSatz2=StS.Prozent) then begin
          vMwstWert2 # vMwstWert2 + Kas.B.P.Steuer;
        end;
      end;
    end;

  END;  // nächste Karte
  RecBufClear(572);
  Kas.B.P.Ausgang # vAusgang;
  Kas.B.P.Eingang # vEingang;

  Gv.Num.01 # vMwStSatz1;
  GV.Num.02 # vMwStWert1;
  Gv.Num.03 # vMwStSatz2;
  GV.Num.04 # vMwStWert2;


  // ------- FUßDATEN --------------------------------------------------------------------------
  Form_Mode # 'FUSS';

  Form_Ele_Kas:elBuchEnde(var elEnde);

  // -------- Druck beenden ----------------------------------------------------------------

  // Objekte entladen
  FreeElement(var elErsteSeite        );
  FreeElement(var elFolgeSeite        );

  FreeElement(var elPostenUS          );
  FreeElement(var elPosten            );

  FreeElement(var elEnde              );
  FreeElement(var elLeerzeile         );
  FreeElement(var elSeitenFuss        );

  // letzte Seite & Job schließen, ggf. mit Vorschau + Archiv
  Lib_Print:FrmJobClose(!"Frm.DirektdruckYN", n, n, aFilename);

end;



//========================================================================