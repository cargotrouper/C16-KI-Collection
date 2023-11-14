@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Script
//                OHNE E_R_G
//  Info
//
//
//  19.07.2007  AI  Erstellung der Prozedur
//  10.08.2013  AH  PDFCreator
//  15.08.2016  ST  Aufruf "ShowPDF" als Form oder Report erweitert
//  18.12.2018  ST  Druck über SOA erstellt Jobservereinträge zum Drucken
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//  SUB CheckForm(aAdr : int; aNr : int; aName : alpha) : logic
//  SUB Cmd_Print()
//  SUB Run(aNr : int)
//
//========================================================================
@I:Def_Global
//@I:SFX_BSP_WebApp

//========================================================================

//========================================================================
// Check
//
//========================================================================
sub Check(
  aAdr    : int;
  aNr     : int;
  aName   : alpha;
) : logic
local begin
  vErg : int;
end;
begin

  // keine Adresscripte? **********************
  if (aAdr=0) then begin
    if (aNr<>0) then begin
      Scr.Nummer # aNr;
      vErg # RecRead(920,1,0);
      end
    else begin
      Scr.Name # aName;
      vErg # RecRead(920,2,0);
    end;
    if (vErg>_rMultikey) then RETURN false;
    RETURN true;
  end;


  // Adresscirpte ******************************
  RecbufClear(109);
  Adr.Scr.Adressnr  # aAdr;
  Adr.Scr.Name      # aName;
  vErg # RecRead(109,1,0);
  if (vErg>_rMultikey) then RETURN false;
  Scr.Nummer # Adr.Scr.Scriptnummer;
  RETURN true;

end;


//========================================================================
// Cmd_Print
//    Formular sagt ob, DirketDruck oder Vorschau !!!!
//========================================================================
sub Cmd_Print();
local begin
  Erx         : int;
  vDokSprache : alpha;
  vDokAdr     : int;
  vAnzahl     : int;
  vVS,vDD     : logic;
  vTmp        : int;
  vBonus      : handle;
end;
begin
//debugstamp(gUsername+': START');
  Erx # Lib_Dokumente:RekReadFrm(Scr.B.2.Bereich, Scr.B.2.FormName);
  if (Erx>_rLocked) then RETURN;

  try begin
    ErrTryIgnore(_rlocked,_rNoRec);
    ErrTryCatch(_ErrNoProcInfo,y);
    ErrTryCatch(_ErrNoSub,y);
    gPDFTitel   # '';
    gPDFName    # '';
    gPDFDMS     # '';
    gPDFDMSPath # '';
    Call(Frm.Prozedur+':GetDokName', var vDokSprache, var vDokAdr);
  end;
  if (ErrGet()<>_ErrOK) AND (gUsergroup <> 'SOA_SERVER') then begin
    Todo('Druckprozedur '+Frm.Prozedur);
    RETURN;
  end;

  // Sprache bestimmen

  WinEvtProcessSet(_WinEvtTimer,false);

  if (Scr.B.2.Kopien=0) then Scr.B.2.Kopien # Frm.Kopien;
  if (Scr.B.2.Kopien=0) then Scr.B.2.Kopien # 1;

  vVS       # Scr.B.2.VorschauYN;//Frm.VorschauYN;
  vDD       # Scr.B.2.DirektDrckYN;//Frm.DirektDruckYN;

  Frm.Kopien # Scr.B.2.Kopien;    // Lib_Print nimmt Anzahl aus Frm.Kopien

  // exisitiert eine Formularprozedur in der Sprache?
  if (vDokSprache<>'D') then begin
    vTmp # textopen(1);
    Erx # Textread(vTmp, Frm.Prozedur+'_'+vDokSprache, _TextNoContents | _TextProc);
    vTmp->textclose();
    if (Erx<>_rOK) then vDokSprache # 'D';
  end;



  //pdfCREATOR
  if (Set.PDF.Creator<>'') and (Set.PDF.CreatorPAth<>'') then begin

    Frm.VorschauYN          # n;
    "Frm.DirektdruckYN"     # y;    // KEINE C16-VORSCHAU MEHR
    Frm.Markierung          # Scr.B.2.Markierung;
    if (Scr.B.2.Drucker<>'') then
      Frm.Drucker           # Scr.B.2.Drucker;
    if (Scr.B.2.Schacht<>'') then
      Frm.Schacht           # Scr.B.2.Schacht;
    if (Scr.B.2.Ausgabeart<>'') then
      Frm.Ausgabeart        # Scr.B.2.Ausgabeart;
    Frm.SpeichernYN         # Scr.B.2.SpeichernYN;
    if (vDokSprache<>'D') then
      Frm.Prozedur # Frm.Prozedur+'_'+vDokSprache;

    Frm.Schacht             # '';
    Frm.Drucker             # Set.PDF.Creator;
    gPDFName                # aint(gUserid);

    // Formular generieren + ggf. Druck
    vBonus # VarInfo(WindowBonus);
    APPOFF();
    Call(Frm.Prozedur);
    APPON();
    if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
    gFrmMain->Winupdate(_WinUpdActivate);

    if (vDD) then begin
      Dlg_PDFPreview:DirekterDruck(Set.PDF.CreatorPath+gPDFname+'.pdf', Frm.Kopien, Frm.Drucker, 0, Frm.Schacht);
    end;
    if (vVS) then begin
      Dlg_PDFPreview:ShowPDF(Set.PDF.CreatorPath+gPDFname+'.pdf', true,Dok.EMail,Dok.FAX,0,1, gPDFTitel);
    end;

    FSIDelete(Set.PDF.CreatorPath+gPDFname+'.pdf');
  end
  else begin

    // DIREKT DRUCKEN ****************************
    if (vDD) then begin
      Frm.VorschauYN          # n;
      "Frm.DirektdruckYN"     # y;    // KEINE C16-VORSCHAU MEHR
      Frm.Markierung          # Scr.B.2.Markierung;
      if (Scr.B.2.Drucker<>'') then
        Frm.Drucker           # Scr.B.2.Drucker;
      if (Scr.B.2.Schacht<>'') then
        Frm.Schacht           # Scr.B.2.Schacht;
      if (Scr.B.2.Ausgabeart<>'') then
        Frm.Ausgabeart        # Scr.B.2.Ausgabeart;
      Frm.SpeichernYN         # Scr.B.2.SpeichernYN;
      // Formular generieren + ggf. Druck
      if (vDokSprache<>'D') then
        Frm.Prozedur # Frm.Prozedur+'_'+vDokSprache;
      vBonus # VarInfo(WindowBonus);
      APPOFF();
      Call(Frm.Prozedur);
      APPON();
      if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
  //    END;
    end; // DRUCKEN


    // VORSCHAU ANZEIGEN *************************
    if (vVS) then begin
      Frm.DirektDruckYN # n;
      Frm.VorschauYN    # y;
      Frm.Markierung          # Scr.B.2.Markierung;
      Frm.SpeichernYN         # Scr.B.2.SpeichernYN;

      if (Scr.B.2.Drucker<>'') then
        Frm.Drucker           # Scr.B.2.Drucker;
      if (Scr.B.2.Schacht<>'') then
        Frm.Schacht           # Scr.B.2.Schacht;
      if (Scr.B.2.Ausgabeart<>'') then
        Frm.Ausgabeart        # Scr.B.2.Ausgabeart;

      // Formular generieren + ggf. Druck
      if (vDokSprache<>'D') then
        Frm.Prozedur # Frm.Prozedur+'_'+vDokSprache;

      vBonus # VarInfo(WindowBonus);
      APPOFF();
      Call(Frm.Prozedur);
      APPON();
      if (vBonus<>0) then VarInstance(WindowBonus, vBonus);
      gFrmMain->Winupdate(_WinUpdActivate);
    end;  // VORSCHAU

  end;


  WinEvtProcessSet(_WinEvtTimer,true);

//debugstamp(gUsername+': ENDE');
end;


//========================================================================
// Run
//
//========================================================================
sub Run(
  aNr     : int;
) : logic
local begin
  Erx : int;
end;
begin

  if (gUsergroup = 'SOA_SERVER') then begin
    Lib_Dokumente:AddDokumentToJobServerQueue(aNr);
    RETURN true;
  end;

  Scr.Nummer # aNr;
  Erx # RecRead(920,1,0);
  if (Erx>=_rMultiKey) then RETURN false;

  if (Scr.Prozedurname<>'') then begin
    try begin
      ErrTryIgnore(_rlocked,_rNoRec);
      ErrTryCatch(_ErrNoProcInfo,y);
      ErrTryCatch(_ErrNoSub,y);
      Call(Scr.Prozedurname);
    end;
    if (ErrGet()<>_ErrOK) then begin
      Todo('Prozedur '+Scr.Prozedurname);
      RETURN false;
    end;
    RETURN true;
  end;


  Erx # RecLink(921,920,1,_RecFirst);   // Befehle loopen
  WHILE (Erx<=_rLocked) do begin

    Case Scr.B.Befehl of

      'PRINT' : Cmd_Print();

      'CALL'  : begin
        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          if (Call(Scr.B.Prozedurname)=false) then begin
            Msg(921000,'',0,0,0);
            RETURN false;
          end;
        end;
        if (ErrGet()<>_ErrOK) then begin
          Todo('Prozedur '+Scr.B.Prozedurname);
          RETURN false;
        end;

      end;

    end;

    RecRead(912,1,0);   // Formular restoren

    Erx # RecLink(921,920,1,_RecNext);
  END;

  RETURN true;
end;

//========================================================================
