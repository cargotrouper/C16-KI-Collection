@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_120001
//                    OHNE E_R_G
//  Info        Projektplan mit Zeiten
//
//
//  25.09.2007  MS  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Print(aName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  StartList(0,'');  // Liste generieren

RETURN;

 /* RecBufClear(999);
  Sel.Art.Von.Typ   # ''; Sel.Art.bis.Typ # 'ZZZ';
  Sel.Adr.von.KdNr  # 0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.400004','L_Auf_400004:AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);*/

end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort : int;
  vSortName : alpha;
end;
begin
/**
  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
  vHdl2->WinLstDatLineAdd('Wunschtermin');
  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
**/
  StartList(vSort,vSortname);  // Liste generieren
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  Erx     : int;
  vI      : int;
  vTxtHdl : int;
  vA      : alpha(200);
end;
begin

  case (aName) of

    'Text_Beschreibung' : begin
      vTxtHdl # TextOpen(32);     // temp. Puffer erzeugen
      Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '1' ), vTxtHdl, 0 ,0, 0, 0); // Internen Text in Puffer laden


      // Puffer zeilenweise loopen
      FOR vI # 1  LOOP inc(vI) WHILE (vI<=TextInfo(vTxtHdl,_TextLines)) do begin
        vA # vTxtHdl->TextLineRead(vI,0);
        StartLine();
        Write(21,vA                           ,n , 0);
        EndLine();
      END

      vTxtHdl->TextClose();       // Puffer freigeben

    end;

    'Text_Intern' : begin
      vTxtHdl # TextOpen(32);     // temp. Puffer erzeugen

      Lib_Texte:TxtLoad5Buf( Lib_Texte:GetTextName( 122, Prj.P.Nummer, Prj.P.Position, '2' ), vTxtHdl, 0 ,0, 0, 0); // Externen Text in Puffer laden

      //  Puffer zeilenweise loopen
      FOR vI # 1  LOOP inc(vI) WHILE (vI<=TextInfo(vTxtHdl,_TextLines)) do begin
        vA # vTxtHdl->TextLineRead(vI,0);

        StartLine();
        Write(23,vA                           ,n , 0);
        EndLine();
      END

      vTxtHdl->TextClose();       // Puffer freigeben


    end;


    'Intern' : begin
      StartLine(_LF_Bold);
      Write(23,'Interner Text'                           ,n , 0);
      EndLine();
    end;


    'Beschreibung' : begin
      StartLine(_LF_Bold);
      Write(21,'Beschreibung'                           ,n , 0);
      Endline();

    end;


    'Leer' : begin
      StartLine();
      Endline();
    end;

    'Leer_Underline': begin
      StartLine(_LF_UnderLine + _LF_Bold);
      Endline();
    end;

    '120' : begin
      StartLine();
      Write(1,  ZahlI(Prj.Nummer)                                                 ,y , _LF_Int, 3.0);
      if (Prj.Adressnummer<>0) then begin
        Erx # RecLink(100,120,1,0);     // Adresse holen
        if (Erx<=_rLocked) then
          Write(2, Adr.Stichwort                                                  ,n , 0);
        Write(3,  Prj.Stichwort                                                   ,n , 0);
        Write(4,  Prj.Bemerkung                                                   ,n , 0);
        if (Prj.Termin.Start<>0.0.0) then
          Write(5,  DatS(Prj.Termin.Start)                                        ,n , _LF_Date);
        Write(6,  ' bis '                                                         ,n , 0);
        if (Prj.Termin.Ende<>0.0.0) then
          Write(7,  DatS(Prj.Termin.Ende)                                         ,n , _LF_Date);
        EndLine();
      end;
    end;

    '122_Kopf' : begin
      Startline();
      EndLine();

      Startline(/*_LF_UnderLine +*/_LF_Bold);
      Write(9, 'Posnr.'                                                         ,y , 0, 3.0);
      Write(10, 'Bezeichnung'                                                   ,n , 0);
      Write(11, 'geplant h'                                                       ,n , 0);
      Write(12, 'intern h'                                                        ,n , 0);
      Write(13, 'extern h'                                                        ,n , 0);
      Write(25, 'Erledigt'                                                      ,n , 0);
      EndLine();

    end;

    '122' : begin
      Startline();
      Write(9, ZahlI(Prj.P.Position)                                            ,y , _LF_Int, 3.0);
      Write(10, Prj.P.Bezeichnung                                               ,n , 0);
      Write(11, ZahlF(Prj.P.Dauer, 2)                                           ,n ,  _LF_Num);
      Write(12, ZahlF(Prj.P.Dauer.Intern, 2)                                    ,n ,  _LF_Num);
      Write(13, ZahlF(Prj.P.Dauer.Extern, 2)                                    ,n ,  _LF_Num);
      if ("Prj.P.Lösch.Datum"<>0.0.0) then
        Write(25, DatS("Prj.P.Lösch.Datum") + ' ' + "Prj.P.Lösch.User"          ,n , 0);
      Endline();

      Startline();
      Write(25, "Prj.P.Lösch.Grund"                                             ,n , 0);
      EndLine();

    end;


    '123_Kopf' : begin
      StartLine(/*_LF_UnderLine + _LF_Bold*/);
      Write(15, 'Datum'                                                         ,n , 0);
      Write(16, 'Zeit'                                                          ,n , 0);
      Write(17, 'Dauer h'                                                       ,n , 0);
      Write(18, 'User'                                                          ,n , 0);
      Write(19, 'Bemerkung'                                                     ,n , 0);
      Endline();
    end;

    '123' : begin
      Startline();
      Write(15, DatS(Prj.Z.Start.Datum)                                         ,n , _LF_Date);
      Write(16, cnvat(Prj.Z.Start.Zeit)                                         ,n , 0);
      Write(17, ZahlF(Prj.Z.Dauer, 2)                                           ,n , _LF_Num);
      Write(18, Prj.Z.User                                                      ,n , 0);
      Write(19, Prj.Z.Bemerkung                                                 ,n , 0);
      Endline();
    end;


  end; // case

end;

//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
  WriteTitel();     // Drucke grosse Überschrift

  StartLine();
  EndLine();
  if (aSeite=1) then begin
    List_Spacing[ 1]  #  0.0;
    List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;
    List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
    List_Spacing[ 4]  # List_Spacing[ 3] + 30.0;
    List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
    List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
    List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;
    List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
    List_Spacing[ 9]  # List_Spacing[ 1]
    List_Spacing[10]  # List_Spacing[ 9] + 25.0;
    List_Spacing[11]  # List_Spacing[10] + 25.0;
    List_Spacing[12]  # List_Spacing[11] + 20.0;
    List_Spacing[13]  # List_Spacing[12] + 17.0;

    List_Spacing[15]  # List_Spacing[ 1] + 40.0;
    List_Spacing[16]  # List_Spacing[15] + 20.0;
    List_Spacing[17]  # List_Spacing[16] + 15.0;
    List_Spacing[18]  # List_Spacing[17] + 15.0;
    List_Spacing[19]  # List_Spacing[18] + 15.0;
    List_Spacing[20]  # List_Spacing[ 2]
    List_Spacing[21]  # List_Spacing[20] + 0.0;
    List_Spacing[22]  # List_Spacing[21] + 120.0;
    List_Spacing[23]  # List_Spacing[20] + 0.0;
    List_Spacing[24]  # List_Spacing[21] + 120.0;
    List_Spacing[25]  # List_Spacing[13] + 30.0;



  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Projektnr.'                                                       ,y , 0, 3.0);
  Write(2, 'Adresse'                                                          ,n , 0);
  Write(3, 'Stichwort'                                                        ,n , 0);
  Write(4, 'Bemerkung'                                                        ,n , 0);
  Write(5, 'Zeitraum'                                                         ,n , 0);
  Write(6, ''                                                                 ,y , 0);
  Write(7, ''                                                                 ,y , 0, 3.0);
  Write(8, ''                                                                 ,n , 0);
  Endline();

  end;
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx       : int;
  vSelName  : alpha;
  vSel      : int;
  vFlag     : int;
end;
begin

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(n);    // starte Landscape

  /*vFlag # _RecFirst;
  WHILE (RecRead(120,1,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;*/


      Print('120');



   vFlag # _RecFirst;
   WHILE (RecRead(122,1,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Print('122_Kopf');

    Print('122');

    Print('Leer');

    Print('Beschreibung');

    Print('Text_Beschreibung');

    Print('Leer');

    Print('Intern');

    Print('Text_Intern');

    Print('Leer');

    Print('Leer');

    Print('123_Kopf');

    Erx # RecLink(123,122,1,_recFirst);  // Zeiten loopen
    WHILe (Erx<=_rLocked) do begin

      Print ('123');

      Print('Leer');


   Erx # RecLink(123,122,1,_recNext);




    end;  // loop 123
    end;  // loop 122


  ListTerm(); // Ende der Liste
end;

//========================================================================