@A+
//===== Business-Control =================================================
//
//  Prozedur    MTo_Data
//                    OHNE E_R_G
//  Info
//
//
//  10.09.2008  AI  Erstellung der Prozedur
//  05.08.2016  ST  Rundung bei ABM Toleranzen laut Setting 1326/500
//  10.08.2017  ST  "aNoGuiRefresh" für Nutzung ohne Verwaltung eingebaut
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

//========================================================================
//  BildeVorgabe
//
//========================================================================
sub BildeVorgabe(
  aFile   : int;
  aTyp    : alpha;
  opt aNoGuiRefresh : logic);
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vQ        : alpha(3000);
  vWert     : alpha;
end;
begin

  // Sonderfunktion?
  if (RunAFX('MTo.BildeVorgabe',cnvAI(aFile,_fmtnumnogroup|_FmtNumLeadZero,0,3)+aTyp)<>0) then RETURN;

  case aFile of
    /* Aufträge */
    401 : begin
      RecLink(819, 401, 1, _recFirst);
      vQ # '(MTo.Warengruppe = 0 OR MTo.Warengruppe = ' + AInt(Auf.P.Warengruppe) + ') AND ' +
           '(MTo.Werkstoffnr = '''' OR MTo.Werkstoffnr = ''' + Auf.P.Werkstoffnr + ''') AND '+
           '("MTo.Gütenstufe" = '''' OR "MTo.Gütenstufe" = ''' + "Auf.P.Gütenstufe" + ''')';

      if ("Auf.P.Dicke" <> 0.0) then begin
        vWert # cnvAF("Auf.P.Dicke", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("Mto.Von.Dicke" = 0.0 OR "MTo.Von.Dicke" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("Mto.Bis.Dicke" = 0.0 OR "MTo.Bis.Dicke" >= ' + vWert + ')';
      end;
      if ("Auf.P.Breite" <> 0.0) then begin
        vWert # cnvAF("Auf.P.Breite", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Breite" = 0.0 OR "MTo.Von.Breite" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Breite" = 0.0 OR "MTo.Bis.Breite" >= ' + vWert + ')';
      end;
      if ("Auf.P.Länge" <> 0.0) then begin
        vWert # cnvAF("Auf.P.Länge", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Länge" = 0.0 OR "MTo.Von.Länge" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Länge" = 0.0 OR "MTo.Bis.Länge" >= ' + vWert + ')';
      end;
      vQ # vQ + ' AND "MTo.Gültig.' + aTyp + 'YN"';

      // Selektion
      vSel # SelCreate(834, 1);
      Erx # vSel->SelDefQuery('', vQ);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      if (RecRead(834, vSel, _recFirst) <= _rLocked) then begin
        if (aTyp = 'Dicke') and ("Auf.P.Dicke" <> 0.0) then begin
          if ("MTo.DickeProzentYN") then begin
            "MTo.DickenTol.Bis" # "Auf.P.Dicke" * "MTo.DickenTol.Bis" / 100.0;
            "MTo.DickenTol.Von" # "Auf.P.Dicke" * "MTo.DickenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.DickenTol.Bis", "Set.Stellen.Dicke") + '/' + ANum("MTo.DickenTol.Von", "Set.Stellen.Dicke");
          "Auf.P.Dickentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Dicke");

        end;
        if (aTyp = 'Breite') and ("Auf.P.Breite" <> 0.0) then begin
          if ("MTo.BreiteProzentYN") then begin
            "MTo.BreitenTol.Bis" # "Auf.P.Breite" * "MTo.BreitenTol.Bis" / 100.0;
            "MTo.BreitenTol.Von" # "Auf.P.Breite" * "MTo.BreitenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.BreitenTol.Bis", "Set.Stellen.Breite") + '/' + ANum("MTo.BreitenTol.Von", "Set.Stellen.Breite");
          "Auf.P.Breitentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Breite");
        end;
        if (aTyp = 'Länge') and ("Auf.P.Länge" <> 0.0) then begin
          if ("MTo.LängeProzentYN") then begin
            "MTo.LängenTol.Bis" # "Auf.P.Länge" * "MTo.LängenTol.Bis" / 100.0;
            "MTo.LängenTol.Von" # "Auf.P.Länge" * "MTo.LängenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.LängenTol.Bis", "Set.Stellen.Länge") + '/' + ANum("MTo.LängenTol.Von", "Set.Stellen.Länge");
          "Auf.P.Längentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Länge");
        end;

        // Refresh
        if (aNoGuiRefresh = false) then begin
          $edAuf.P.Dickentol_Mat->WinUpdate(_winUpdFld2Obj);
          $edAuf.P.Breitentol_Mat->WinUpdate(_winUpdFld2Obj);
          $edAuf.P.Laengentol_Mat->WinUpdate(_winUpdFld2Obj);
        end;
      end;
      vSel->SelClose();
      SelDelete(834, vSelName);
    end;

    /* Bestellung */
    501 : begin
      RecLink(819, 501, 1, _recFirst);
      vQ # '(MTo.Warengruppe = 0 OR MTo.Warengruppe = ' + AInt(Ein.P.Warengruppe) + ') AND ' +
           '(MTo.Werkstoffnr = '''' OR MTo.Werkstoffnr = ''' + Ein.P.Werkstoffnr + ''') AND ' +
           '("MTo.Gütenstufe" = '''' OR "MTo.Gütenstufe" = ''' + "Ein.P.Gütenstufe" + ''')';

      if ("Ein.P.Dicke" <> 0.0) then begin
        vWert # cnvAF("Ein.P.Dicke", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("Mto.Von.Dicke" = 0.0 OR "MTo.Von.Dicke" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("Mto.Bis.Dicke" = 0.0 OR "MTo.Bis.Dicke" >= ' + vWert + ')';
      end;
      if ("Ein.P.Breite" <> 0.0) then begin
        vWert # cnvAF("Ein.P.Breite", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Breite" = 0.0 OR "MTo.Von.Breite" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Breite" = 0.0 OR "MTo.Bis.Breite" >= ' + vWert + ')';
      end;
      if ("Ein.P.Länge" <> 0.0) then begin
        vWert # cnvAF("Ein.P.Länge", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Länge" = 0.0 OR "MTo.Von.Länge" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Länge" = 0.0 OR "MTo.Bis.Länge" >= ' + vWert + ')';
      end;
      vQ # vQ + ' AND "MTo.Gültig.' + aTyp + 'YN"';

      // Selektion
      vSel # SelCreate(834, 1);
      Erx # vSel->SelDefQuery('', vQ);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      if (RecRead(834, vSel, _recFirst) <= _rLocked) then begin
        if (aTyp = 'Dicke') and ("Ein.P.Dicke" <> 0.0) then begin
          if ("MTo.DickeProzentYN") then begin
            "MTo.DickenTol.Bis" # "Ein.P.Dicke" * "MTo.DickenTol.Bis" / 100.0;
            "MTo.DickenTol.Von" # "Ein.P.Dicke" * "MTo.DickenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.DickenTol.Bis", "Set.Stellen.Dicke") + '/' + ANum("MTo.DickenTol.Von", "Set.Stellen.Dicke");
          "Ein.P.Dickentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Dicke");

        end;
        if (aTyp = 'Breite') and ("Ein.P.Breite" <> 0.0) then begin
          if ("MTo.BreiteProzentYN") then begin
            "MTo.BreitenTol.Bis" # "Ein.P.Breite" * "MTo.BreitenTol.Bis" / 100.0;
            "MTo.BreitenTol.Von" # "Ein.P.Breite" * "MTo.BreitenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.BreitenTol.Bis", "Set.Stellen.Breite") + '/' + ANum("MTo.BreitenTol.Von", "Set.Stellen.Breite");
          "Ein.P.Breitentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Breite");
        end;
        if (aTyp = 'Länge') and ("Ein.P.Länge" <> 0.0) then begin
          if ("MTo.LängeProzentYN") then begin
            "MTo.LängenTol.Bis" # "Ein.P.Länge" * "MTo.LängenTol.Bis" / 100.0;
            "MTo.LängenTol.Von" # "Ein.P.Länge" * "MTo.LängenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.LängenTol.Bis", "Set.Stellen.Länge") + '/' + ANum("MTo.LängenTol.Von", "Set.Stellen.Länge");
          "Ein.P.Längentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Länge");
        end;

        // Refresh
        if (aNoGuiRefresh = false) then begin
          $edEin.P.Dickentol_Mat->WinUpdate(_winUpdFld2Obj);
          $edEin.P.Breitentol_Mat->WinUpdate(_winUpdFld2Obj);
          $edEin.P.Laengentol_Mat->WinUpdate(_winUpdFld2Obj);
        end;
      end;
      vSel->SelClose();
      SelDelete(834, vSelName);
    end;

     // BA Fertigung
    703 : begin
      Erx # RecLink(819, 703, 5, _recFirst); // Warengruppe holen
      if(Erx > _rLocked) then
        RecBufClear(819);

      MQU.ErsetzenDurch     # "BAG.F.Güte";  // Güte holen (fuer Werkstoffnr)
      Erx # RecRead(832,5,0);
      if (Erx > _rMultikey) then begin
        "MQU.Güte2"         # "BAG.F.Güte";
        Erx # RecRead(832,3,0);
        if (Erx > _rMultikey) then begin
          RecBufClear(832);
          "MQU.Güte1"       # "BAG.F.Güte";
          Erx # RecRead(832,2,0);
          if (Erx > _rMultikey) then
            RecBufClear(832);
        end;
      end;

      vQ # '(MTo.Warengruppe = 0 OR MTo.Warengruppe = ' + AInt(BAG.F.Warengruppe) + ') AND ' +
           '(MTo.Werkstoffnr = '''' OR MTo.Werkstoffnr = ''' + MQu.Werkstoffnr + ''') AND ' +
           '("MTo.Gütenstufe" = '''' OR "MTo.Gütenstufe" = ''' + "BAG.F.Gütenstufe" + ''')';

      if ("BAG.F.Dicke" <> 0.0) then begin
        vWert # cnvAF("BAG.F.Dicke", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("Mto.Von.Dicke" = 0.0 OR "MTo.Von.Dicke" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("Mto.Bis.Dicke" = 0.0 OR "MTo.Bis.Dicke" >= ' + vWert + ')';
      end;
      if ("BAG.F.Breite" <> 0.0) then begin
        vWert # cnvAF("BAG.F.Breite", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Breite" = 0.0 OR "MTo.Von.Breite" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Breite" = 0.0 OR "MTo.Bis.Breite" >= ' + vWert + ')';
      end;
      if ("BAG.F.Länge" <> 0.0) then begin
        vWert # cnvAF("BAG.F.Länge", _fmtNumNoGroup | _fmtNumPoint);
        vQ    # vQ + ' AND ("MTo.Von.Länge" = 0.0 OR "MTo.Von.Länge" <= ' + vWert + ')';
        vQ    # vQ + ' AND ("MTo.Bis.Länge" = 0.0 OR "MTo.Bis.Länge" >= ' + vWert + ')';
      end;
      vQ # vQ + ' AND "MTo.Gültig.' + aTyp + 'YN"';

      // Selektion
      vSel # SelCreate(834, 1);
      Erx # vSel->SelDefQuery('', vQ);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      if (RecRead(834, vSel, _recFirst) <= _rLocked) then begin
        if (aTyp = 'Dicke') and ("BAG.F.Dicke" <> 0.0) then begin
          if ("MTo.DickeProzentYN") then begin
            "MTo.DickenTol.Bis" # "BAG.F.Dicke" * "MTo.DickenTol.Bis" / 100.0;
            "MTo.DickenTol.Von" # "BAG.F.Dicke" * "MTo.DickenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.DickenTol.Bis", "Set.Stellen.Dicke") + '/' + ANum("MTo.DickenTol.Von", "Set.Stellen.Dicke");
          "BAG.F.Dickentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Dicke");
          if (aNoGuiRefresh = false) then
            $edBAG.F.Dickentol->WinUpdate(_winUpdFld2Obj);
        end;
        if (aTyp = 'Breite') and ("BAG.F.Breite" <> 0.0) then begin
          if ("MTo.BreiteProzentYN") then begin
            "MTo.BreitenTol.Bis" # "BAG.F.Breite" * "MTo.BreitenTol.Bis" / 100.0;
            "MTo.BreitenTol.Von" # "BAG.F.Breite" * "MTo.BreitenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.BreitenTol.Bis", "Set.Stellen.Breite") + '/' + ANum("MTo.BreitenTol.Von", "Set.Stellen.Breite");
          "BAG.F.Breitentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Breite");
          if (aNoGuiRefresh = false) then
            $edBAG.F.Breitentol->WinUpdate(_winUpdFld2Obj);
        end;
        if (aTyp = 'Länge') and ("BAG.F.Länge" <> 0.0) then begin
          if ("MTo.LängeProzentYN") then begin
            "MTo.LängenTol.Bis" # "BAG.F.Länge" * "MTo.LängenTol.Bis" / 100.0;
            "MTo.LängenTol.Von" # "BAG.F.Länge" * "MTo.LängenTol.Von" / 100.0;
          end;

          vWert # ANum("MTo.LängenTol.Bis", "Set.Stellen.Länge") + '/' + ANum("MTo.LängenTol.Von", "Set.Stellen.Länge");
          "BAG.F.Längentol" # Lib_Berechnungen:Toleranzkorrektur(vWert, "Set.Stellen.Länge");
          if (aNoGuiRefresh = false) then
            $edBAG.F.Laengentol->WinUpdate(_winUpdFld2Obj);
        end;

      end;
      vSel->SelClose();
      SelDelete(834, vSelName);
    end;

  end; // case
end;

//========================================================================