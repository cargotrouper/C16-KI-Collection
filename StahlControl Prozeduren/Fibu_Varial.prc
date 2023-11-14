@A+
//===== Business-Control =================================================
//
//  Prozedur    Fibu_Varial
//                    OHNE E_R_G
//  Info
//
//
//  27.11.2009  AI  Erstellung der Prozedur
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
//  Write(a,b)      : GV.Alpha.01 # Format(a,b,n);ExtWrite(1,Format(a,b,n));
//  Satzende        : ExtWrite(1, Char(10));
//  WriteN(a,b,c)   : GV.Alpha.01 # Alpha(a,b,c,n,y);ExtWrite(1,Alpha(a,b,c,n,y));
//  WriteZ(a,b,c)   : if a<0 then GV.Alpha.01 # Alpha(a*(-1),b,c,n,y)+'-' else Gv.Alpha.01 # Alpha(a,b,c,n,y)+'+';ExtWrite(1,Gv.Alpha.01);
//  WriteD(a)       : If a <> Date(0) then GV.Alpha.01 # Alpha(Year(a)-100,2,0,n,y)+Alpha(Month(a),2,0,n,y)+Alpha(Day(a),2,0,n,y) else Gv.Alpha.01 # '      ';ExtWrite(1,Gv.Alpha.01);

  WriteA(a,b) : FsiWrite(vFile, StrCut( Check(a),1,b));//+StrChar(13)+StrChar(10));
  WriteI(a,b) : FsiWrite(vFile, StrCut( cnvai(a,_FmtNumNoGroup|_FmtNumLeadZero),1,b));
  WriteN(a,b,c) : FsiWrite(vFile, cnvaf(a,_FmtNumNoGroup|_FmtNumLeadZero ,0,c,c+1+b));
  WriteD(a)   : FsiWrite(vFile, Cnvai(DateYear(a)-100,_FmtNumLeadZero,0,2) + Cnvai(DateMonth(a),_FmtNumLeadZero,0,2) +  Cnvai(DateDay(a),_FmtNumLeadZero,0,2));
  EOL         : FsiWrite(vFile, strchar(13)+strchar(10));
end;

//========================================================================
//  Check
//
//========================================================================
sub Check(
  aA  : alpha
) : alpha;
begin
//  aA # Str_ReplaceAll(aA, '"', StrChar(39));  // " -> '
  RETURN aA;
end;

/******
//========================================================================
//  Adressen_Export
//
//========================================================================
sub Adressen_Export(
  aKunde  : logic);
local begin
    vX              : int;
    vPostfach       : logic;
    vSetting        : logic;            /* Name Export-Datei aus Setting*/
    vDateiname      : alpha;            /* Name der Export-Datei        */
    vStapel         : int;
    vStapelpos      : int;
    vKreditlimit,
    vInternlimit,
    vWechselobligo  : float;
    vGegen          : int;

  vFile   : handle;
end;
begin

  vDateiname # 'L:\SC-XXSEQIPK';
  vDateiname # 'C:\TEST.TXT';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN;
  end;



                                        /* Kürzel der Applikation     1 */
    WriteA('AA',2);
                                        /* Firmennummer                 */
    WriteA('101',3);
                                        /* 1=Debitor/Kd,2=Kreditor/Lf   */
    If (aKunde) Then Begin
      WriteA('1',1)
      End
    Else begin
      WriteA('2',1);
    End;
                                        /* Kontonummer                  */
    If (aKunde) Then Begin
        If (Adr.KundenBuchNr <> 0)
            Then Begin WriteI(Adr.KundenBuchNr,8)
            End Else Begin WriteI(Adr.Kundennr,8); End;
    End Else Begin
        If (Adr.LieferantBuchNr <> 0)
            Then Begin WriteI(Adr.LieferantBuchNr,8)
            End Else Begin WriteI(Adr.Lieferantennr,8); End;
    End;
                                        /* Matchcode                  5 */
    WriteA(Adr.Stichwort,15);
                                        /* Datenschutz???               */
    WriteA('',3);
                                        /* ÄnderungsID                  */
    WriteA('',3);
                                        /* Gültig von                   */
    WriteA('',6);
                                        /* Gültig bis                   */
    WriteA('',6);
                                        /* letzte Buchung            10 */
    WriteA('',6);
                                        /* Löschdatum von???            */
    WriteA('',6);
                                        /* Löschtoleranz???             */
    WriteA('',3);
                                        /* Lösch KZ???                  */
    WriteA('',2);
                                        /* Sperrdatum Buch von???       */
    WriteA('',6);
                                        /* Sperrdatum bis???         15 */
    WriteA('',6);
                                        /* Sperr KZ???                  */
    WriteA('',2);
                                        /* Sperrdatum Mahn von???       */
    WriteA('',6);
                                        /* Sperrdatum bis???            */
    WriteA('',6);
                                        /* Sperr KZ???                  */
    WriteA('',2);
                                        /* Sperrdatum Zahl von???    20 */
    WriteA('',6);
                                        /* Sperrdatum bis???            */
    WriteA('',6);
                                        /* Sperr KZ???                  */
    WriteA('',2);
                                        /* Anschriftsverb_art           */
    WriteA('',1);
                                        /* Kontenart                    */
    WriteA('',1);
                                        /* Unter_OP_SZ               25 */
    WriteA('1',1);
                                        /* OP_Verwaltungssätze Kontoausz  */
    WriteA('1',1);
                                        /* Ford_Verbindl_SZ             */
    WriteA('0',1);
                                        /* Sachkonto FordVerb_SA        */
    WriteA('',1);
                                        /* Sachkonto FordVerb_NR        */
    WriteA('',8);
                                        /* Steuersatznr.             30 */
TODO('    WriteI(:Adr.Steuerschlüssel:,3);')
                                        /* Zahlungskondinr.             */
/*  WriteN(Adr.VK.Zahlungsbed,3,0); */
    WriteI(999,3);                      /* Individuell                  */
                                        /* Korr.Konto_SA                */
    WriteA('',1);
                                        /* Korr.Konto_NR                */
    WriteA('',8);
                                        /* Zentralzahlerkonto_SA        */
    WriteA('',1);
                                        /* Zentralzahlerkonto_NR     35 */
    WriteA('',8);
                                        /* Kontonummer extern           */
    If (aKunde)
        Then Begin WriteA(Adr.VK.Referenznr,15)
        End Else begin WriteA(Adr.EK.ReferenzNr,15); End;
                                        /* Konzern_Konto_SA             */
    WriteA('',1);
                                        /* Konzern_Konto_Nr             */
    WriteA('',8);
                                        /* neues_Konto_SA               */
    WriteA('',1);
                                        /* neues_Konto_Nr            40 */
    WriteA('',8);
                                        /* altes_Konto_SA               */
    WriteA('',1);
                                        /* altes_Konto_Nr               */
    WriteA('',8);
                                        /* Vetriebs_Einkaufs_Nr         */
    WriteA('',15);
                                        /* Profitcenter_SA              */
    WriteA('',1);
                                        /* Profitcenter_Nr           45 */
    WriteA('',8);
                                        /* Stammfiliale                 */
    WriteA('',4);
                                        /* Kunde_Lieferanten_Gruppe     */
    WriteA('',4);
                                        /* Branchen_Sz                  */
    WriteA('',4);
                                        /* Verkauf_Einkauf_Sz           */
    WriteA('',4);
                                        /* Verkaufsbezirk_KZ         50 */
    If (aKunde) Then Begin WriteI(Adr.Vertreter,5) End
                Else Begin WriteI(0,5); End;
                                        /* Sortierbegriff1              */
    WriteA('*',5);
                                        /* Sortierbegriff2              */
    WriteA('*',5);
                                        /* Sortierbegriff3              */
    WriteA('*',10);      /* Kreditnummer? */
                                        /* Sortierbegriff4              */
    WriteA('*',15);      /* Adr.DefiniertAlpha1? */
                                        /* Sachkonta_Sa              55 */
    WriteA('',1);
                                        /* Sachkonto_Nr                 */
    WriteA('',8);
                                        /* Sachkonto_FordVerb_VZ_SA     */
    WriteA('',1);
                                        /* Sachkonto_FordVerb_VZ_Nr     */
    WriteA('',8);
                                        /* Freistellung_Sz              */
    WriteA('',1);
                                        /* Steuernummer              60 */
    WriteA(Adr.Steuernummer, 25);

    EOL;


  FSIClose(vfile);            // Datei schliessen



/************************************************************************/
/************************************************************************/
/************************************************************************/

vDateiname # 'L:\SC-XXSEQIKO';
vDateiname # 'C:\TEST2.TXT';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN;
  end;


    RecBufClear(104);
    If (aKunde) Then RecLink(100,32,n,n);   /* Kreditlimit holen        */
    if (Erx<>6) and (Erx<>3) then RecBufClear(104);
    If (Adr.Kreditnr = Adr.Kundennummer) Then Begin
        vKreditlimit # Adr.K.Kreditvers;
        vInternlimit # Adr.K.Internlimit;
        If (vInternlimit = 0) Then vInternlimit # vKreditlimit;
        vWechselobligo # 0;
    End Else Begin
        If not(sndx(Adr.DefiniertAlpha1, 3) = 'EDE') Then Begin
            vKreditlimit # 2;
            vInternlimit # 2;
        End Else Begin
            vKreditlimit # 3;
            vInternlimit # 3;
        End;
        vWechselobligo # Adr.Kreditnr;
    End;


                                        /* Kürzel der Applikation    01 */
    Write('AA',2);
                                        /* Firmennummer                 */
    Write('101',3);
                                        /* 1=Debitor/Kd,2=Kreditor/Lf   */
    If (aKunde) Then Begin Write('1',1) End Else Begin Write('2',1); End;
                                        /* Kontonummer                  */
    /* WriteN(Adr.KdBuchungsnr,8,0); */
    If (aKunde) Then Begin
        If (Adr.KdBuchungsnr <> 0)
            Then Begin WriteN(Adr.KdBuchungsnr,8,0)
            End Else begin WriteN(Adr.Kundennummer,8,0); End;
    End Else Begin
        If (Adr.LfBuchungsnr <> 0)
            Then Begin WriteN(Adr.LfBuchungsnr,8,0) End
            Else Begin WriteN(Adr.Lieferantennr,8,0); End;
    End;
                                        /* Belegnummer               05 */
    WriteN(0,11,0);
                                        /* Matchcode                    */
    Write('*',15);
                                        /* Datenschutzklasse            */
    Write('',3);
                                        /* Änderungs_ID                 */
    Write('',3);
                                        /* Format_KZ                    */
    Write('',3);
                                        /* Anrede_KZ                 10 */
    Write('',4);
    If (Adr.Post.Name <> '') Then Begin
        Adr.Haus.Anrede # Adr.Post.Anrede;
        Adr.Haus.Name   # Adr.Post.Name;
        Adr.Haus.Zusatz # Adr.Post.Zusatz;
        Adr.Haus.Ort    # Adr.Post.Ort;
        Adr.Haus.Land   # Adr.Post.Land;
        If Scan(sndx(:Adr.Post.Straße:, 1), 'POSTFACH') Then Begin
            vPostfach # y;
            If (Len(:Adr.Post.Straße:) > 9)
                Then :Adr.Post.Straße:  # copy(:Adr.Post.Straße:, 10, Len(:Adr.Post.Straße:) - 9)
                Else :Adr.Post.Straße:  # '';
        End Else Begin
            vPostfach # n;
            :Adr.Haus.Straße:   # :Adr.Post.Straße:;
            Adr.Haus.PLZ        # Adr.Post.PLZ;
            ClrTds(100, 2);
        End;
    End Else ClrTds(100, 2);
                                        /* Name1                        */
    Write(Adr.Haus.Name,40);
                                        /* Name2                        */
    Write(Adr.Haus.Zusatz,40);
                                        /* Abteilung-Empfänger          */
    Write('',40);
                                        /* PLZ-Postfach                 */
    Write(Adr.Post.PLZ,10);
                                        /* Postfach                  15 */
    Write(:Adr.Post.Straße:,10);
                                        /* Strasse                      */
    Write(:Adr.Haus.Straße:,40);
                                        /* PLZ                          */
    Write(Adr.Haus.PLZ,10);
                                        /* Ort1                         */
    Write(Adr.Haus.Ort,40);
                                        /* Ort2                         */
    Write(Adr.Haus.Land,40);
                                        /* Postamt                   20 */
    Write(Adr.Post.Ort,40);
                                        /* Staaten_KZ                   */
    Write('*',3);
                                        /* Länder_KZ                    */
    /* Write(Adr.Haus.LKZ,3); */
    Write('*',3);
                                        /* Sprachschlüssel              */
    Write('00',2);
                                        /* Währungsnummer               */
    Write('000',3);
                                        /* Kurzanschrift            25  */
    /* Write(CutStr(Format(Adr.Haus.Name,10,n),n)+' '+Adr.Haus.Ort,20); */
    Write('*',20);
                                        /* Briefanrede                  */
    Write(Adr.Briefanrede,50);
                                        /* Telefon2                     */
    Write(Adr.Telefon2,20);
                                        /* Telefon1                  28 */
    Write(Adr.Telefon1,20);
                                        /* Telex                    28a */
    Write(Adr.Telex,20);
                                        /* FAX                          */
    Write(Adr.Telefax,20);
                                        /* Teletext                  30 */
    Write('',20);
                                        /* BTX                          */
    Write('',20);
                                        /* Mailbox                      */
    Write('',20);
    If (Len(Adr.UStIdentNr) >= 3) Then Begin
                                        /* UstID_Land_KZ                */
        Write(Adr.UStIdentNr,2);
                                        /* UstID_Nr                     */
        Write(copy(Adr.UStIdentNr, 3, Len(Adr.UStIdentNr)-2),13);
    End Else Begin
                                        /* UstID_Land_KZ                */
        Write('',2);
                                        /* UstID_Nr                     */
        Write('',13);
    End;
                                        /* Werksleistung             35 */
    Write('',1);
                                        /* Dreicksgeschäft_KZ           */
    Write('',1);
                                        /* BBN_BBS_Nr                   */
    Write('',13);
                                        /* Kreditlimit                  */
    WriteN(vInternlimit,11,0);
    /* WriteN(Adr.K.Internlimit,11,0); */
                                        /* Versicherungslimit           */
    WriteN(vKreditlimit,11,0);
    /* WriteN(Adr.K.Kreditvers,11,0); */
                                        /* Konzernlimit              40 */
    Write('',11);
                                        /* Wechselobligo                */
    If (vWechselobligo = 0)
        Then Begin Write('', 11); End
        Else Begin WriteN(vWechselobligo,11,0); End;
                                        /* Versicherung                 */
    Write(Adr.K.Versicherer,10);
                                        /* Vertragsart                  */
    Write('*',10);
                                        /* Vertragsnummer               */
    Write(Adr.K.Versicherer,25);
    /* Write(Adr.K.Referenznr,25); */
                                        /* Mahngruppe                45 */
    Write('',2);
                                        /* Mahnung_Fax_SZ               */
    Write('',1);
                                        /* Mahnungsart                  */
    Write('1',1);
                                        /* Finanzdispogruppe            */
    Write('',2);
                                        /* Mahninfo1                    */
    Write('',2);
                                        /* Mahninfo2                 50 */
    Write('',2);
                                        /* Zinsart                      */
    Write('',1);
                                        /* Zinsgruppe                   */
    Write('',2);
                                        /* letztes Zinsdatum            */
    Write('',6);
                                        /* nächstes Zinsdatum           */
    Write('',6);
                                        /* Zahlungs_Schlüsselziffer  55 */
    Write('',2);
                                        /* Abw_Bank_Personenkonto_satzart */
    Write('',1);
                                        /* Abw_Bank_Personenkonto_nr    */
    Write('',8);
                                        /* Abw_Bank_Kontoinhaber        */
    Write('',40);
                                        /* Zahlung_vorg_Bank            */
    Write('*',3);
                                        /* Zahlgruppe                60 */
    Write('',2);
                                        /* Bundesbank_Melde_Sz          */
    Write('',2);
                                        /* PBC_ESR_NR_CH                */
    Write('',10);
                                        /* Bank1_Land                   */
    Write('*',3);
                                        /* BLZ1                         */
    Write(Adr.Bank1.BLZ,15);
                                        /* Bank1_Kontonr             65 */
    Write(Adr.Bank1.Kontonr,25);
                                        /* Bank1_Bezeichnung            */
    If (Adr.Bank1.BLZ <> '') and (Adr.Bank1.Name = '') Then Begin
        BLZ.Bankleitzahl # NumI(Adr.Bank1.BLZ);
        RecRead(834, 3, n);
        WHILE (Erx <> 0) and (Erx <> 2) and (BLZ.Bankleitzahl = NumI(Adr.Bank1.BLZ)) and (BLZ.EigeneBLZ = n)
        DO RecReadNext(834, 3, n);
        If (Erx = 0) or (Erx = 1) or (BLZ.Bankleitzahl <> NumI(Adr.Bank1.BLZ))
            Then ClrRec(834)
            Else Adr.Bank1.Name # :BLZ.NDLSTWfürBtx&EZÜ:;
    End;
    Write(Adr.Bank1.Name,40);
                                        /* Bank2_Land                   */
    Write('*',3);
                                        /* BLZ2                         */
    Write(Adr.Bank2.BLZ,15);
                                        /* Bank2_Kontonr                */
    Write(Adr.Bank2.Kontonr,25);
                                        /* Bank2_Bezeichnung         70 */
    If (Adr.Bank2.BLZ <> '') and (Adr.Bank2.Name = '') Then Begin
        BLZ.Bankleitzahl # NumI(Adr.Bank2.BLZ);
        RecRead(834, 3, n);
        WHILE (Erx <> 0) and (Erx <> 2) and (BLZ.Bankleitzahl = NumI(Adr.Bank2.BLZ)) and (BLZ.EigeneBLZ = n)
        DO RecReadNext(834, 3, n);
        If (Erx = 0) or (Erx = 2) or (BLZ.Bankleitzahl <> NumI(Adr.Bank2.BLZ))
            Then ClrRec(834)
            Else Adr.Bank2.Name # :BLZ.NDLSTWfürBtx&EZÜ:;
    End;
    Write(Adr.Bank2.Name,40);
                                        /* Bank3_Land                   */
    Write('*',3);
                                        /* Bank3_Typ                    */
    Write('*',10);
                                        /* BLZ3                         */
    Write('*',15);
                                        /* Bank3_Kontonr                */
    Write('*',25);
                                        /* Bank3_Name1               75 */
    Write('*',40);
                                        /* Bank3_Name2                  */
    Write('*',40);
                                        /* Bank3_Strasse                */
    Write('*',40);
                                        /* Bank3_Ort                    */
    Write('*',40);
                                        /* Zahlinfo1                    */
    Write('',2);
                                        /* Zahlinfo2                 80 */
    Write('',2);
                                        /* AZV_Land                     */
    Write('',3);
                                        /* AZV_Zahlungsart              */
    Write('',2);
                                        /* AVZ_Weisungschlüssel         */
    Write('',2);
                                        /* AVZ_Kostenverrechnung        */
    Write('',2);
                                        /* AVZ_Dienstleistung        85 */
    Write('',3);
                                        /* Betrag_EW_Euro               */
    Write('J',1);
                                        /* IBAN_Nr                      */
    Write('*',35);
                                        /* Vers_Anteil                  */
    Write('',2);
                                        /* Limits_bis_datum             */
    Write('',6);
                                        /* eMail                        */
    Write(Adr.eMail,40);
                                        /* SZ_Refefax                91 */
    Write('',1);

    SatzEnde;

ExtClose(1);
RecRead(100, 1, n);
******/

//========================================================================
//  Erl_Export
//
//========================================================================
sub Erl_Export() : logic;
local begin
  Erx     : int;
  vDateiname  : alpha;
  vFile       : handle;
  vStapel     : int;
  vLfdNr      : int;
  vStapelPos  : int;
  vItem       : handle;
  vMFile      : int;
  vMID        : int;
  vCount      : int;
  vA          : alpha;
  vN          : float;
  vI          : int;

  vMyUstID    : alpha;
  vFirma      : alpha;
  vAppli      : alpha;
  vSachKonto  : int;
end;
begin
  vFirma  # '101';
  vAppli  # 'AA';


  Adr.Nummer # Set.EigeneAdressnr;
  Erx # RecRead(100,1,0);   // eigene Adresse holen
  if (Erx>_rLockeD) then RETURN false;
  vMyUstID # Adr.USIdentNr;


  vDateiname # 'C:\TEST_XXSEQINP.TXT';
//vDateiname # 'L:\XXSEQINPA.TXT';

  vFile # FSIOpen(vDateiName,_FsiAcsRW|_FsiDenyRW|_FsiCreate|_FsiTruncate);
  if (vFile<=0) then begin
    Msg(450104,vDateiName,0,0,0);
    RETURN false;
  end;

  vStapel # Lib_Nummern:ReadNummer('FIBU_STAPELNUMMER');
  if (vStapel<>0) then Lib_Nummern:SaveNummer()
  else begin
    FSIClose(vFile);            // Datei schliessen
    RETURN false;
  end;

  vLfdNr      # 0;
  vStapelPos  # 0;



  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>450) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    RecRead(450,0,0,vMID);          // Satz holen
    if (Erl.StornoRechNr<>0) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    // KEINE Lieferantenerlöse...
    Erx # RecLink(451,450,1,_RecFirst);   // 1.Erloeskonto holen
    if (Erx<=_rLocked) then begin
      Auf.Nummer # Erl.K.Auftragsnr;
      Erx # RecRead(400,1,0);             // Auftrag holen
      if (Erx > _rLocked) then begin
        "Auf~Nummer" # Erl.K.Auftragsnr;
        Erx # RecRead(410,1,0);             // Auftrag holen
        if (Erx > _rLocked) then RecBufClear(400)
        else RecbufCopy(410,400);
      end;
      if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;
    end;


    vCount # vCount + 1;


    vlfdNr # vlfdNr + 1;

    Erx # RecLink(100,450,8,_recFirst);       // Rechnungsempfänger holen
    if (cnvia(Adr.KundenFibuNr)=0) then Adr.KundenFibuNr # aint(Adr.Kundennr);
    //Erx # RecLink(813,450,10,_recFirst);      // Adr-Steuerschluessel holen
    Erx # RecLink(816,450,15,_recFirst);      // Zahlungsbed. holen

    Erx # RecLink(451,450,1,_recFirst);       // 1. Erlös holen
    if (Erx>_rLocked) then RecBufCleaR(451);
    Erx # RecLink(813,451,10,_recFirst);      // Steuerschluessel holen
    if (Erx>_rLocked) then RecBufCleaR(813);


                                        // Kürzel der Applikation
    WriteA(vAppli,2);
                                        // Firmennummer
    WriteA(vFirma,3);
                                        // Periode
    vA # AInt(( Erl.Rechnungsdatum->vpyear * 100) + Erl.Rechnungsdatum->vpMonth);
    WriteA(vA,6);
                                        // Erfassdatum
    WriteD(today);
                                        // Stapelnummer
    WriteI(vStapel,6);
                                        // lfd.Nummer
    WriteI(vlfdNr,5);
                                        // Transakt.Nummer
    WriteA('',5);           //vStapelPos,5);
                                        // Gegenbuchungstyp MEHRERE
    WriteA('DIV',3);
                                        // BuchungsID
    WriteA('   ',3);
                                        // Debitor=1/Kreditor=2
    WriteA('1',1);
                                        // Konto
    WriteI(cnvia(Adr.KundenFibuNr),8);
                                        // Sachkonto=0
    WriteA('0',1);
                                        // Gegenkonto -> DIV
    WriteI(0,8);
                                        // ???
    WriteA('',3);
                                        // Von Betrieb
    WriteA('0000',4);
                                        // An Betrieb
    WriteA('0000',4);
                                        // Belegnummer
    WriteI(Erl.Rechnungsnr,11);
                                        // Unter Beleg
    WriteA('',3);
                                        // Datum
    WriteD(Erl.Rechnungsdatum);
                                        // (20.) Valuta
    WriteA('',6);
                                        // SOll,HAben,AusRe,EinRe,AusGut
                                        // EinGut
    If (Erl.NettoW1 < 0.0) then begin
      WriteA('AG',3)
      end
    else begin
      WriteA('AR',3);
    end;
                                        // ???
    WriteA('',3);
                                        // ???
    WriteA('',3);
                                        // Herkunft
    WriteA('SCRechnung',10);
                                        // Soll=1/Haben=2

    If (Erl.NettoW1 < 0.0) then begin
      WriteA('2',1)
      end
    else begin
      WriteA('1',1);
    end;
                                        // ??
    WriteA('',1);
                                        // (27.) Betrag EW
    WriteN(Erl.BruttoW1,11,2);
                                        // Steuer EW
    WriteN((-1.0)*Erl.SteuerW1,11,2);
                                        // Skonto
//  WriteZ(OFP.SkontoW1,11,2);*/
    WriteA('',15);
                                        // Steuerschluessel
    WriteA(Sts.Fibu.Code,3);
                                        // ???
    WriteA('',5);
                                        // Steuerprozent
    WriteN(Sts.Prozent,3,2);
                                        // Entgelt
    WriteN((-1.0)*Erl.NettoW1,11,2);
                                        // ???
    WriteA('',1);
                                        // USt-Id eigen
    WriteA(vMyUstID,15);
                                        // USt-Id Kunde
    WriteA(Adr.USIdentNr,15);
                                        // ???
    WriteA('',1);
                                        // (38.) ???
    WriteA('',1);
/***
                                        // Betrag FW
    WriteZ(0.0,11,2);
                                        // Steuer FW
    WriteZ(0.0,11,2);
                                        // Skonto FW
    WriteZ(0.0,11,2);
                                        // Währungsnummer
    WriteN(0.0,3,0);
                                        // Kurs
    Write('',8);
                                        // Einheit
    Write('',1);
                                        // Währungsbez.
    Write('',3);
***/

    WriteA('',60);
                                        // Sachkonto=0
    WriteA('0',1);
                                        // ???
    WriteA('',8);
                                        // ???
    WriteA('',1);
                                        // OP-Text
    WriteA('Rechnung StahlControl',25);
                                        // ??
    WriteA('',20);
                                        // ??
    WriteA('',50);
                                        // kein Zusatztext=0
    WriteA('0',1);
                                        // Mengen
    WriteA('',72);
                                        // Zahlkondi.  67
    WriteA('999',3);
                                        // Skonto 1 Tage
    vI # Cnvid(Erl.Skontodatum) - cnvid(Erl.Rechnungsdatum);
    WriteI(vI,3);
                                        // Skonto 1 %
    WriteN(Erl.SkontoProzent,2,2);
                                        // Skonto 2 Tage
    WriteN(0.0,3,0);
                                        // Skonto 2 %
    WriteN(0.0,2,2);
                                        // Netto Fällig Tage
    vI # Cnvid(Erl.Zieldatum) - cnvid(Erl.Rechnungsdatum);
    WriteI(vI,4);
                                        // Skonto1  Fällig Datum
    if (Erl.Skontodatum=0.0.0) then Erl.Skontodatum # Erl.Rechnungsdatum;
    WriteD(Erl.Skontodatum);
                                        // Skonto2  Fällig Datum
    WriteA('',6);
                                        // (75.) Netto    Fällig Datum
    if (Erl.Zieldatum=0.0.0) then Erl.Zieldatum # Erl.Rechnungsdatum;
    WriteD(Erl.Zieldatum);
                                        // Skontofähiger betrag
    WriteA('',15);
                                        // Skonto1 Betrag
    vN # Rnd(Erl.NettoW1 * Erl.Skontoprozent / 100.0,2)
    WriteN((-1.0)*vN,11,2);
                                        // Skonto2 Betrag
    WriteA('',15);
                                        // ????
    WriteA('',36);
                                        // AufNummer
    WriteA('',15);
                                        // AufDatum
    WriteA('',6);
                                        // LFSNr
    WriteA('',15);
                                        // LfsDatum
    WriteA('',6);
                                        // Mahnstufe
    WriteA('',1);
                                        // Datum letzte Mahnung
    WriteA('',6);
                                        // (93.) ???
    WriteA('',1);

    EOL;


    // Konten loopen..............................
    Erx # RecLink(451,450,1,_recFirst);
    WHILE (Erx<=_rLocked) do begin
      Erx # RecLink(813,451,10,_recFirst);      // Steuerschluessel holen

      vlfdNr # vlfdNr + 1;

                                      // K?rzel der Applikation
      WriteA(vAppli,2);
                                      // Firmennummer
      WriteA(vFirma,3);
                                      // Periode
      vA # AInt(( Erl.Rechnungsdatum->vpyear * 100) + Erl.Rechnungsdatum->vpMonth);
      WriteA(vA,6);
                                      // Erfassdatum
      WriteD(today);
                                      // Stapelnummer
      WriteI(vStapel,6);
                                      // lfd.Nummer
      WriteI(vlfdNr,5);
                                      // Transakt.Nummer
      WriteI(vStapelPos,5);
                                      // Gegenbuchungstyp
      WriteA('SAB',3);
                                      // BuchungsID
      WriteA('',3);
                                      // Sachkonto=0
      WriteA('0',1);
                                      // Sachkonto
      vSachkonto # "Erl.K.Erlöskonto";
      WriteI(vSachkonto,8);
                                      // 1=deb,2=kred,0=???
      WriteA('0',1);
                                      // Gegenkonto
      WriteI(0,8);
                                      // (14.) ???
      WriteA('',3);
                                      // Von Betrieb
      WriteA('0000',4);
                                      // An Betrieb
      WriteA('0000',4);
                                      // Belegnummer
      WriteI(Erl.Rechnungsnr,11);
                                      // Unter Beleg
      WriteA('',3);
                                      // Datum
      WriteD(Erl.Rechnungsdatum);
                                      // Valuta
      WriteA('',6);
                                      // SOll,HAben,AusRe,EinRe,AusGut
                                      // EinGut
      If (Erl.NettoW1 < 0.0) then begin
        WriteA('AG',3)
        end
      else begin
        WriteA('AR',3);
      end;
                                      // ???
      WriteA('',3);
                                      // ???
      WriteA('',3);
                                      // Herkunft
      WriteA('SCRechnung',10);
                                      // Soll=1/Haben=2
      If (Erl.NettoW1 < 0.0) then begin
        WriteA('1',1)
        end
      else begin
        WriteA('2',1);
      end;
                                      // ??
      WriteA('',1);
                                      // Betrag EW
      WriteN((-1.0)*Erl.K.BetragW1,11,2);
                                      // Steuer EW
      WriteA('',15);
                                      // Skonto
      WriteA('',15);
                                      // Steuerschluessel
      WriteI(0,3);
                                      // ???
      WriteA('',59);
/***
                                      // Betrag FW
      WriteZ(0.0,11,2);
                                      // Steuer FW
      WriteZ(0.0,11,2);
                                      // Skonto FW
      WriteZ(0.0,11,2);
                                      // W"hrungsnummer
      WriteN(0.0,3,0);
                                      // Kurs
      Write('',8);
                                      // Einheit
      Write('',1);
                                      // W"hrungsbez
      Write('',3);
***/
      WriteA('',60);
                                      // Sachkonto=0
      WriteA('',1);
                                      // ???
      WriteA('',8);
                                      // ???
      WriteA('',1);
                                      // OP-Text
      WriteA('',25);
                                      // ??
      WriteA('',20);
                                      // ??
      WriteA('',50);
                                      // (52.) kein Zusatztext=0
      WriteA('0',1);
                                      // Mengen
      WriteA('',15);
                                      // Mengen-KZ                    */
      WriteA('',3);
                                      // ???                          */
      WriteA('',54);
                                      // ???                          */
      WriteA('',86);
                                      // ???                          */
      WriteA('',36);
                                      // ???                          */
      WriteA('',50);

      EOL;

      Erx # RecLink(451,450,1,_recNext);
    END;

    vStapelPos # vStapelPos + 1;
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  FSiClose(vFile);

  Msg(450102,cnvai(vCount)+'|'+vDateiName,0,0,0);

  gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecID | _WinLstRecDoSelect);

  //* Buchungen sperren **/
//  vDateiname # 'Z:\LOG\Ausgaben\' + DbName + '-FIBU.LCK';
//  ExtOpen(1, vDateiname, y, y, 2, 4);
//  ExtWrite(1, Alpha(vStapel));
//  Satzende;
//  ExtClose(1);

end;

/****
//========================================================================
//  Export_Verbindlichkeiten
//
//========================================================================
sub Export_Verbindlichkeiten();
begin
ReadSetting('SAP','STARTDATUM');
StrDate(Setting, vStartDatum);

ReadSetting('FIBU','EXPORTDATEI AR');
vDateiname # Setting;

vDateiname # 'C:\XXSEQINP.TXT';
vDateiname # 'L:\XXSEQINPE.TXT';


ExtOpen(1,vDateiname,y,y,1,1);
if (ExtErr <> 0) then begin
    Msg2Box 'Fibu-ÜbErxabe',
            'Export-Datei konnte nicht erstellt werden!',
            MBS_FEHLER, MBB_ABBRUCH, 1);
    SetFKey(0);
    return;
end;
ExtMove(1,ExtSize(1));


ReadSetting('FIBU','STAPELNUMMER');
vStapel # Num(Setting);
Setting # Alpha(vStapel+1,8,0);
SaveSetting;

vLfdNr      # 0;
vStapelPos  # 0;

RecReadFirst(550,1);
RecRead(550,1,n);
WHILE (Erx=6) do begin

    if ERD.Markierung <> '>' then begin
        RecReadNext(550,1,N);
        CYCLE;
    end;
    If (ERD.Rechnungsdatum >= vStartDatum) Then Begin
        RecReadNext(550, 1, n);
        CYCLE;
    End;

    vlfdNr # vlfdNr + 1;

    RecLink(550,:ERD->Lieferant:,n,n);          /* Lieferant holen              */
    RecLink(550,:ERD->Steuerschlüssel:,n,n);    /* Steuerschluessel holen       */

                                        /* Applik_KZ                   1 */
    Write('AA',2);
                                        /* Firmennummer                2 */
    Write('101',3);
                                        /* Periode                     3 */
    Write(Alpha( (Year(ERD.Rechnungsdatum) +1900) *100 + Month(ERD.Rechnungsdatum),6,0),6);
                                        /* Erfassdatum                 4 */
    WriteD(today);
                                        /* Stapelnummer                5 */
    WriteN(vStapel,6,0);
                                        /* lfd.Nummer                  6 */
    WriteN(vlfdNr,5,0);
                                        /* Xransakt.Nummer             7 */
    WriteN(vStapelPos,5,0);
                                        /* Gegenbuchungstyp            8 */
    Write('DIV',3);
                                        /* BuchungsID                  9 */
    Write('   ',3);
                                        /* Debitor=1/Kreditor=2        10 */
    Write('2',1);
                                        /* Konto                       11 */
    WriteN(ERD.Lieferantennr,8,0);
                                        /* Sachkonto=0                 12 */
    Write('0',1);
                                        /* Gegenkonto                  13 */
    WriteN(0.0,8,0);
                                        /* ???                         14 */
    Write('',3);
                                        /* Von Betrieb                 15 */
    Write('0000',4);
                                        /* An Betrieb                  16 */
    Write('0000',4);
                                        /* Belegnummer                 17 */
    WriteN(ERD.Nummer,11,0);
                                        /* Unter Beleg                 18 */
    Write('',3);
                                        /* Datum                       19 */
    WriteD(ERD.Rechnungsdatum);
                                        /* Valuta                      20 */
    WriteD(ERD.Valuta);
                                        /* SOll,HAben,AusRe,EinRe,AusGut*/
                                        /* EinGut                       */
    If ERD.NettobetragW1 < 0 then begin
        Write('EG',3)
    end else begin
        Write('ER',3);
    end;

                                        /* ???                          */
    Write('',3);
                                        /* ???                          */
    Write('',3);
                                        /* Herkunft                     */
    Write('SCRechnung',10);
                                        /* Soll=1/Haben=2               */
    If ERD.NettobetragW1 < 0 then begin
        Write('1',1)
    end else begin
        Write('2',1);
    end;
                                        /* ??                           */
    Write('',1);
                                        /* Betrag EW                    */
    WriteZ((-1)*ERD.BruttobetragW1,11,2);
                                        /* Steuer EW                    */
    WriteZ(ERD.SteuerbetragW1,11,2);
                                        /* Skonto                       */
/*  WriteZ(OFP.SkontoW1,11,2);**/
    Write('',15);
                                        /* Steuerschluessel             */
    WriteN(:ERD.Steuerschlüssel:,3,0);
                                        /* ???                          */
    Write('',5);
                                        /* Steuerprozent                */
    WriteN(ERD.Steuerprozent,3,2);
                                        /* Entgelt                      */
    WriteZ((-1)*ERD.NettobetragW1,11,2);
                                        /* ???                          */
    Write('',1);
                                        /* USt-Id eigen                 */
    Write('DE 115508817',15);
                                        /* USt-Id Lieferant             */
    Write(Adr.UStIdentNr,15);
                                        /* ??                           */
    Write('',1);
                                        /* ?? 38                        */
    Write('',1);
/****
                                        /* Betrag FW                    */
    WriteZ(0.0,11,2);
                                        /* Steuer FW                    */
    WriteZ(0.0,11,2);
                                        /* Skonto FW                    */
    WriteZ(0.0,11,2);
                                        /* W"hrungsnummer               */
    WriteN(0.0,3,0);
                                        /* Kurs                         */
    Write('',8);
                                        /* Einheit                      */
    Write('',1);
                                        /* W"hrungsbez.                 */
    Write('',3);
***/
    Write('',60);
                                        /* Sachkonto=0                  */
    Write('0',1);
                                        /* ???                          */
    Write('',8);
                                        /* ???                          */
    Write('',1);
                                        /* OP-Text                      */
    Write(ERD.Rechnungsnr,25);
                                        /* ??                           */
    Write('',20);
                                        /* ??                           */
    Write('',50);
                                        /* kein Zusatztext=0            */
    Write('0',1);
                                        /* Mengen                       */
    Write('',72);
                                        /* Zahlkondi.  67               */
    Write('999',3);
                                        /* Skonto 1 Tage                */
    Write('',3);
                                        /* Skonto 1 %                   */
    WriteN(ERD.Skontoprozent,2,2);
                                        /* Skonto 2 Tage                */
    WriteN(0.0,3,0);
                                        /* Skonto 2 %                   */
    WriteN(0.0,2,2);
                                        /* Netto F"llig Tage            */
    write('',4);
                                        /* Skonto1  F"llig Datum        */
    WriteD(ERD.Skontodatum);
                                        /* Skonto2  F"llig Datum        */
    Write('',6);
                                        /* Netto    F"llig Datum        */
    WriteD(ERD.Zieldatum);
                                        /* Skontof"higer betrag         */
    Write('',15);
                                        /* Skonto1 Betrag               */
    WriteZ(ERD.SkontobetragW1,11,2);
                                        /* Skonto2 Betrag               */
    Write('',15);
                                        /* ????                         */
    Write('',36);
                                        /* AufNummer                    */
    Write(ERD.Bestellnummer,15);/**/
/*    Write('',15);*/
                                        /* AufDatum                     */
/*    WriteD(ERD.Rechnungsdatum);**/
    Write('',6);
                                        /* LFSNr                        */
    Write('',15);
                                        /* LfsDatum                     */
    Write('',6);
                                        /* Mahnstufe                    */
    Write('',1);
                                        /* Datum letzte Mahnung         */
    Write('',6);
                                        /* ???                          */
    Write('',1);

    SatzEnde;


/*{
    RecLink(450,1,n,n);                 /* Erlöse durchlaufen           */
    WHILE (Erx=6) do begin
*/
        vlfdNr # vlfdNr + 1;

                                        /* Kürzel der Applikation       */
        Write('AA',2);
                                        /* Firmennummer                 */
        Write('101',3);
                                        /* Periode                      */
        Write(Alpha((Year(ERD.Rechnungsdatum)+1900)*100 + Month(ERD.Rechnungsdatum),6,0),6);
                                        /* Erfassdatum                  */
        WriteD(today);
                                        /* Stapelnummer                 */
        WriteN(vStapel,6,0);
                                        /* lfd.Nummer                   */
        WriteN(vlfdNr,5,0);
                                        /* Xransakt.Nummer              */
        WriteN(vStapelPos,5,0);
                                        /* Gegenbuchungstyp             */
        Write('SAB',3);
                                        /* BuchungsID                   */
        Write('',3);
                                        /* Sachkonto=0                  */
        Write('0',1);
                                        /* Sachkonto                    */
        vGegen # 0;
        case :ERD.Steuerschlüssel: of
             3      do If (Year(ERD.Rechnungsdatum) <= 106)
                        Then vGegen # 3140
                        Else vGegen # 3145;
             4      do vGegen # 3200;
            10, 11  do vGegen # 3425;
            16      do If (Year(ERD.Rechnungsdatum) <= 106)
                        Then vGegen # 3400
                        Else vGegen # 3340;
            29      do vGegen # 3400
            otherwise debug
        end;
        WriteN(vGegen,8,0);

                                        /* 1=deb,2=kred,0=nichts        */
        Write('0',1);
                                        /* Gegenkonto                   */
        WriteN(0.0,8,0);
                                        /* ???                          */
        Write('',3);
                                        /* Von Betrieb                  */
        Write('0000',4);
                                        /* An Betrieb                   */
        Write('0000',4);
                                        /* Belegnummer                  */
        WriteN(ERD.Nummer,11,0);
                                        /* Unter Beleg                  */
        Write('',3);
                                        /* Datum                        */
        WriteD(ERD.Rechnungsdatum);
                                        /* Valuta                       */
        WriteD(ERD.Valuta);
                                        /* SOll,HAben,AusRe,EinRe,AusGut*/
                                        /* EinGut                       */
        If ERD.NettobetragW1 < 0 then begin
            Write('EG',3)
        end else begin
            Write('ER',3);
        end;

                                        /* ???                          */
        Write('',3);
                                        /* ???                          */
        Write('',3);
                                        /* Herkunft                     */
        Write('SCRechnung',10);
                                        /* Soll=1/Haben=2               */
        If ERD.NettobetragW1 < 0 then begin
            Write('2',1)
        end else begin
            Write('1',1);
        end;
                                        /* ??                           */
        Write('',1);
                                        /* Betrag EW                    */
        WriteZ(ERD.NettobetragW1,11,2);
                                        /* Steuer EW                    */
        Write('',15);
                                        /* Skonto                       */
        Write('',15);
                                        /* Steuerschluessel             */
        WriteN(0,3,0);
                                        /* ???                          */
        Write('',59);
/***
                                        /* Betrag FW                    */
        WriteZ(0.0,11,2);
                                        /* Steuer FW                    */
        WriteZ(0.0,11,2);
                                        /* Skonto FW                    */
        WriteZ(0.0,11,2);
                                        /* W"hrungsnummer               */
        WriteN(0.0,3,0);
                                        /* Kurs                         */
        Write('',8);
                                        /* Einheit                      */
        Write('',1);
                                        /* W"hrungsbez.                 */
        Write('',3);
***/
        Write('',60);
                                        /* Sachkonto=0                  */
        Write('',1);
                                        /* ???                          */
        Write('',8);
                                        /* ???                          */
        Write('',1);
                                        /* OP-Text                      */
        Write('',25);
                                        /* ??                           */
        Write('',20);
                                        /* ??                           */
        Write('',50);
                                        /* kein Zusatztext=0            */
        Write('0',1);
                                        /* Mengen                       */
        Write('',15);
                                        /*                              */
        Write('',3);
                                        /* ???                          */
        Write('',226);

        SatzEnde;

/*        RecLinkNext(450,1,n);*/

/*    END;**/


    vStapelPos # vStapelPos + 1;

    RecReadNext(550,1,n);
END;

ExtClose(1);


end;
***/

//========================================================================