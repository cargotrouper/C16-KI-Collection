@A+
//==== Business-Control ==================================================
//
//  Prozedur    TeM_Ank_Create
//                        OHNE E_R_G
//  Info
//
//
//  28.06.2003  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Show_List(aDatei : int)
//    SUB Hide_List_100()
//    SUB Hide_List_102()
//    SUB Hide_List_120()
//    SUB Hide_List_200()
//    SUB Hide_List_800()
//    SUB Save_Ank()
//
//========================================================================
@I:Def_Global


//========================================================================
//  Insert
//
//========================================================================
//sub Insert(
//  aDatei : int);
//begin
//end;

/****** TESTWEISE 20.08.2009 AI

LOCAL begin
  lAdressAnspr  : logic;
  tErgFromDiag  : int;
  tAuswahllist  : int;

  tBereich      : alpha(20);
  iID1          : int;
  iID2          : int;
  iDatei        : int;
end;

//========================================================================
//  ShowList
//
//========================================================================
sub Show_List(
  aDatei : int;
)
local begin
  vA    : alpha;
end;
begin

  case aDatei of
     // Adressen
     100 : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung','TeM_Ank_Create:Hide_List_100');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;  // 100

    // Ansprechpartner
    102 : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.P.Verwaltung','TeM_Ank_Create:Hide_List_102');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;  // 102

    // Projekte
    120 : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Prj.Verwaltung','TeM_Ank_Create:Hide_List_120');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;  // 120

    // Material
    200 : begin
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung','TeM_Ank_Create:Hide_List_200');
      Lib_GuiCom:RunChildWindow(gMDI);
    end; // 200

    // User
    800 : begin
//      $ZL.TeM.Anker->wpdisabled # true;
      gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Usr.Verwaltung','TeM_Ank_Create:Hide_List_800');
      Lib_GuiCom:RunChildWindow(gMDI);
    end;  // 800

  end;    // Case
end;


//========================================================================
// Hide_List_xxx() beim Verlassen der Auswahlverwaltungen
// iID1, iID2, iDatei, tBereich werden hier für Weiterbearbeitungen gefüllt
//========================================================================
// Adressen
sub Hide_List_100()
begin
  Lib_GuiCom:SetWindowState($TeM.A.Verwaltung,true);// gesamtes Fenster aktivieren
  $ZL.TeM.Anker->wpdisabled # false;                // Zugriffliste wieder aktivieren
  $ZL.TeM.Anker->WinFocusSet(true);
  if (gSelected<>0) then begin

    // Feldübernahme
    iID1      # Adr.Nummer;
    iID2      # 0;
    tBereich  # 'ADR';
    iDatei    # 100;

    gSelected # 0;

    Call('TeM_Ank_Create:Save_Ank');  // Zum Speichern übergeben
  end;
end;

// Ansprechpartner
sub Hide_List_102()
begin
  $ZL.TeM.Anker->wpdisabled # false;                // Zugriffliste wieder aktivieren
  Lib_GuiCom:SetWindowState($TeM.A.Verwaltung,true);// gesamtes Fenster aktivieren
  if (gSelected<>0) then begin

    // Feldübernahme
    iID1      # Adr.P.Adressnr;
    iID2      # Adr.P.Nummer;
    tBereich  # 'ANP';
    iDatei    # 102;

    gSelected # 0;

    Call('TeM_Ank_Create:Save_Ank');  // Zum Speichern übergeben
  end;

end;


// Projekte
sub Hide_List_120()
begin
  $ZL.TeM.Anker->wpdisabled # false;                // Zugriffliste wieder aktivieren
  Lib_GuiCom:SetWindowState($TeM.A.Verwaltung,true);// gesamtes Fenster aktivieren
  if (gSelected<>0) then begin

    // Feldübernahme
    iID1      # Prj.Nummer;
    iID2      # 0;
    tBereich  # 'PRJ';
    iDatei    # 120;

    gSelected # 0;

    Call('TeM_Ank_Create:Save_Ank');  // Zum Speichern übergeben
  end;

end;

// Material
sub Hide_List_200()
begin
  $ZL.TeM.Anker->wpdisabled # false;                // Zugriffliste wieder aktivieren
  Lib_GuiCom:SetWindowState($TeM.A.Verwaltung,true);// gesamtes Fenster aktivieren
  if (gSelected<>0) then begin

    RecRead(200,0,_RecId,gSelected);
    // Feldübernahme
    iID1      # Mat.Nummer;
    iID2      # 0;
    tBereich  # 'MAT';
    iDatei    # 200;

    gSelected # 0;

    Call('TeM_Ank_Create:Save_Ank');  // Zum Speichern übergeben
  end;

end;

// User
sub Hide_List_800()

begin
  $ZL.TeM.Anker->wpdisabled # false;                // Zugriffliste wieder aktivieren
  Lib_GuiCom:SetWindowState($TeM.A.Verwaltung,true);// gesamtes Fenster aktivieren
  if (gSelected<>0) then begin

    // Feldübernahme
    iID1      # 0;
    iID2      # 0;
    tBereich  # Usr.Username;
    iDatei    # 800;

    gSelected # 0;


    Call('TeM_Ank_Create:Save_Ank');  // Zum Speichern übergeben

  end;
end;


//========================================================================
//  Save_Ank
//  Sichert den Anker
//========================================================================
sub Save_Ank()
begin

  TeM.A.Nummer      # TeM.Nummer;   // Nummer von Aktivität
  TeM.A.ID1         # iID1;         // 2.Teil vom Code
  TeM.A.ID2         # iID2;         // 3.Teil vom Code

                                    // Code
  if (iID1 = 0) AND (iID2 = 0) then
    TeM.A.Code        # tbereich      // Code für Useranker
  else
    TeM.A.Code        # tBereich + StrFmt(CnvAi(iID1,_FmtNumNoGroup | _FmtNumLeadZero),8,_StrBegin) +
                             '/' + StrFmt(CnvAi(iID2,_FmtNumNoGroup | _FmtNumLeadZero),3,_StrBegin);

  TeM.A.Start.Datum # TeM.Start.Von.Datum;
  TeM.A.Start.Zeit  # TeM.Start.Von.Zeit;

  TeM.A.Berichtsnr  # 0;            // Werden erst später angelegt

  RekInsert(981,0,'MAN');

  // hier Zurück in die Auswahlliste springen
  mode # c_ModeList;
  Call('App_Main:RefreshMode');
  $NB.Main->wpCurrent # 'NB.List';
end;


//========================================================================
//  MAIN
//
//========================================================================
MAIN begin
  // Abfrage des Ankertypes
  tErgFromDiag # WinDialog('TeM.Anker.Auswahl',_WinDialogCenter);

  IF !(tErgFromDiag = _WinIdClose) then begin
    // gSelected wird mit der Dateinummer des auswählten Punktes gefüllt
    TeM.A.Datei # gSelected;
    gSelected # 0;

    // Liste je nach Auswahl aufrufen
    // Zu verankernde Position auswählen
    CASE (TeM.A.Datei) OF
      100 : Call('TeM_Ank_Create:Show_List',100);     // Adressen
      102 : Call('TeM_Ank_Create:Show_List',102);     // Ansprechpartner
      120 : Call('TeM_Ank_Create:Show_List',120);     // Projekte
      200 : Call('TeM_Ank_Create:Show_List',200);     // Material
      800 : Call('TeM_Ank_Create:Show_List',800);     // User
    END;
  End;
end;
*******/


//========================================================================