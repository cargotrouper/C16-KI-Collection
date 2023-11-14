// Namespace:ORDNERNAME
// Dateinummer | neuer Tabellenname | Prefix zum Abschneiden der Feldnamen | "TIEFE" in BL
// QUIT = Ende der Abarbeitung
Namespace:Adresse
100   |Adresse                    |Adr.
101   |Adr_Anschrift              |Adr.A.
102   |Adr_Ansprechpartner        |Adr.P.
103   |Adr_Kreditlimit            |Adr.K.
105   |Adr_Verpackung             |Adr.V.
106   |Adr_Vpg_Ausfuehrung        |Adr.V.AF.
107   |Kontaktdaten               |Adr.Ktd.
//109   |Adr_Scripte

110   |Vertreter                  |Ver.
111   |Ver_Provision              |Ver.P.

Namespace:Projekt
120   |Projekt                    |Prj.
121   |Proj_Stueckliste           |Prj.SL.
122   |Proj_Position              |Prj.P.
123   |Proj_Zeit                  |Prj.Z.

Namespace:Lieferantenerklaerung
130   |Lieferantenerklaerung      |LfE.
131   |LfE_Struktur               |LfE.S.

Namespace:Ressource
160   |Ressource                  |Rso.
161   |Rso_Zusatztabelle          |Rso.Tab.
163   |Rso_Kalender               |Rso.Kal.
164   |Rso_Kal_Tag                |Rso.Kal.Tag.
165   |Rso_Instandhaltung         |Rso.IHA.
166   |Rso_IHA_Ursache            |Rso.Urs.
167   |Rso_IHA_Massnahme          |Rso.Maß.
168   |Rso_IHA_Ersatzteil         |Rso.ErT.
169   |Rso_IHA_Ressource          |Rso.Rso.
170   |Rso_Reservierung           |Rso.R.
171   |Rso_R_Verbindung           |Rso.R.V.

Namespace:Hilfsstoff
180   |Hilfsstoff                 |HuB.
181   |HuB_Preis                  |HuB.P.
182   |HuB_Journal                |HuB.J.
190   |HuB_Einkauf                |HuB.EK.
191   |HuB_EK_Position            |HuB.EK.P.
192   |HuB_EK_Wareneingang        |HuB.EK.E.

Namespace:Material
200   |Material                   |Mat.
201   |Mat_Ausfuehrung            |Mat.AF.
202   |Mat_Bestandsbuch           |Mat.B.
203   |Mat_Reservierung           |Mat.R.
204   |Mat_Aktion                 |Mat.A.
//205   |Mat.Lagerprotokoll         |Mat.

210   |Materialablage             |Mat~

220   |Materialstruktur           |MSL.
221   |MSL_Ausfuehrung            |MSL.AF.
230   |Analyse                    |Lys.K.
231   |Analyse_Position           |Lys.
240   |Dispobestand               |DiB.

Namespace:Artikel
250   |Artikel                      |Art.
251   |Art_Reservierung             |Art.R.
252   |Art_Charge                   |Art.C.
253   |Art_Lagerjournal             |Art.J.
254   |Art_Preis                    |Art.P.
255   |Art_Stueckliste              |Art.SLK.
256   |Art_SL_Position              |Art.SL.
257   |Art_Ausfuehrungen            |Art.AF.
259   |Art_Inventur                 |Art.Inv.

Namespace:Versand
280   |Paket                        |Pak.
281   |Pak_Position                 |Pak.P.

Namespace:Reklamation
300   |Reklamation                  |Rek.
301   |Rek_Position                 |Rek.P.
302   |Rek_Aktion                   |Rek.A.
303   |Rek_Charge                   |Rek.P.C.
310   |Rek_8_Text                   |Rek.8.

Namespace:Auftrag
400   |Auftrag                      |Auf.
401   |Auf_Position                 |Auf.P.
402   |Auf_Ausfuehrung              |Auf.AF.
403   |Auf_Aufpreis                 |Auf.Z.
404   |Auf_Aktion                   |Auf.A.
405   |Auf_Kalkulation              |Auf.K.
//406   |Auf_Einteilung             |
//407   |Auf_Verpackung             |
//408   |Auf_Feinabrufe             |
409   |Auf_Stueckliste             |Auf.SL.

410   |Auftragsablage               |Auf~
411   |Auf_Positionsablage          |Auf~P.

Namespace:Versand
440   |Lieferschein                 |Lfs.
441   |Lfs_Position                 |Lfs.P.

Namespace:Finanzen
450   |Erloes                       |Erl.
451   |Erl_Konto                    |Erl.K.
460   |OffenerPosten                |OfP.
461   |OfP_Zahlung                  |OfP.Z.
465   |Zahlungseingang              |Zei.
//470   |OfP~OffenePosten           |

Namespace:Bestellung
500   |Einkauf                      |Ein.
501   |Ein_Position                 |Ein.P.
502   |Ein_Ausfuehrung              |Ein.AF.
503   |Ein_Aufpreis                 |Ein.Z.
504   |Ein_Aktion                   |Ein.A.
505   |Ein_Kalkulation              |Ein.K.
506   |Ein_Wareneingang             |Ein.E.
507   |Ein_E_Ausfuehrung            |Ein.E.AF.

510   |Einkaufsablage               |Ein~
511   |Ein_Positionsablage          |Ein~P.

Namespace:Bestellung
540   |Bedarf                       |Bdf.
541   |Bdf_Aktion                   |Bdf.A.
//545   |Bdf~Bedarf                 |

Namespace:Finanzen
550   |Verbindlichkeit              |Vbk.
551   |Vbk_Konto                    |Vbk.K.
555   |Einkaufkontrolle             |EKK.
558   |Fixkosten                    |FxK.
560   |Eingangsrechnung             |ERe.
561   |ERe_Zahlung                  |ERe.Z.
565   |Zahlungsausgang              |ZAu.
570   |Kasse                        |Kas.
571   |Kassenbuch                   |Kas.B.
572   |Kassenbuchposition           |Kas.B.P.
580   |Kostenkopf                   |Kos.K.
581   |Kosten                       |Kos.

Namespace:Betriebsauftrag
600   |Grobplanung                  |GPl.
601   |GPl_Position                 |GPl.P.

Namespace:Bestellung
620   |Sammelwareneingang         |SWe.
621   |SWe_Position               |SWE.P.
622   |SWe_Pos_Ausfuehrung        |SWE.P.AF.

Namespace:Versand
650   |Versand                    |Vsd.
651   |Vsd_Position               |Vsd.P.
655   |Versandpooleintrag         |VsP.
//656   |VsP~Versandpool            |

Namespace:Betriebsauftrag
700   |Betriebsauftrag            |BAG.
701   |BAG_InputOutput            |BAG.IO.
702   |BAG_Position               |BAG.P.
703   |BAG_Fertigung              |BAG.F.
704   |BAG_Verpackung             |BAG.VPG.
705   |BAG_Ausfuehrung            |BAG.AF.
706   |BAG_Arbeitsschritt         |BAG.AS.
707   |BAG_Fertigmeldung          |BAG.FM.
708   |BAG_FM_Beistellung         |BAG.FM.B.
709   |BAG_Zeit                   |BAG.Z.
710   |BAG_FM_Fehler              |BAG.FM.Fh.
711   |BAG_Positionszusatz        |BAG.PZ.

//770   |Mathematik_Hilfsvar        |
//771   |Mathematik_Werte           |
//772   |Mathematik_Variablen       |
//773   |Mathematik_Formeln         |
//774   |Mathematik_For2(773)       |
//775   |Mathematik_W2(771)         |
//776   |Mathematik_Funktwert       |
//777   |Mathematik                 |
//778   |Mathematik_2(777)          |
//779   |Mathematik_Var2(772)       |

Namespace:C16
800   |C16_Benutzer                 |Usr.
//801   |c16_Benutzergruppe               |Usr.Grp.
//802   |Usr_User<>Gruppen          |Usr.U<>G.
//803   |Usr_Favorit                  |Usr.Fav.

Namespace:Schluesseldatei
810   |Gruppe                       |Grp.       |0
811   |Anrede                       |Anr.       |0
812   |Land                         |Lnd.       |1
813   |Steuerschluessel             |Sts.       |1
814   |Waehrung                     |Wae.       |0
815   |Lieferbedingung              |Lib.       |0
816   |Zahlungsbedingung            |ZAb.       |0
817   |Versandart                   |vSa.       |0
818   |Verwiegungsart               |VWa.       |0
819   |Warengruppe                  |Wgr.       |2
820   |Materialstatus               |Mat.Sta.   |0
821   |Abteilung                    |Abt.       |0
822   |Ressourcengruppe             |Rso.Grp.   |1
823   |IHA_Meldung                  |IHA.Mld.   |0
824   |IHA_Ursache                  |IHA.Urs.   |0
825   |IHA_Massnahme                |IHA.Maß.   |0
826   |Artikelgruppe                |AGr.       |0
//827   |Math.Alphabet              |
828   |Arbeitsgang                  |ArG.       |3
829   |Skizze                       |Skz.       |0
830   |Kalkulation                  |Kal.       |3
831   |Kal_Position                 |Kal.P.     |2
832   |Guete                        |MQu.       |1
833   |Guetenmechanik               |MQu.M.     |1
834   |Abmessungstoleranz           |MTo.       |3
835   |Auftragsart                  |AAr.       |2
836   |BDSNummer                    |BDS.       |0
837   |Textbausteine                |Txt.       |2
838   |Unterlage                    |ULa.       |0
839   |Zeugnis                      |Zeu.       |0
840   |Etikett                      |Eti.       |0
841   |Oberflaeche                  |Obf.       |0
842   |Aufpreis                     |ApL.       |1
843   |Aufpreis_Position            |ApL.L.     |2
// ACHTUNG AUs Lagerplatz wird Stellplatz wegen INMET elenden ODBC
844   |Stellplatz                   |LPl.       |0
845   |Dickentoleranz               |Tol.D.     |0
846   |Kostenstelle                 |KSt.       |0
847   |Ort                          |Ort.       |1
848   |Guetenstufe                  |MQu.S.     |0
849   |Reklamationsart              |Rek.Art.   |0
850   |Projektstatus                |Stt.       |0
851   |Fehlercode                   |FhC.       |0
852   |Zahlungsart                  |ZhA.       |0
853   |Rechnungstyp                 |RTy        |0
854   |Gegenkonto                   |GKo.       |1
855   |Zeittyp                      |ZTy.       |0
856   |Artikelzustand               |Art.Zst.   |0

Namespace:Statistik
890   |OnlineStatistik              |OSt.
//891   |OSt_Stack                    |
892   |OSt_Extended                 |OSt.E.
899   |Statistik                    |Sta.
//900   Help
//901   |Prg.Keys                   |
//902   |Prg.Nummernkreise          |
//903   |Prg.Settings               |
//904   |Prg.šbersetzung            |
//905   |Job.Jobserver              |
//906   |Dia.Dialoge                |
//907   |Dia.Pflichtfelder          |
//908   |Job.Fehlermeldungen        |
//909   |FSP.Filescanpfade          |
//910   |Lfm.Listenformate          |
//911   |Lfm.UserAllowed            |
//912   |Frm.Formulare              |
//915   |Dok.Dokumente              |

//916   |Anh.Anhang                |

//920   |Scr.Scripte                |
//921   |Scr.Befehle                |

//922   |SFX.Sonderfunktion         |
//923   |AFX.Ankerfunktion          |
//924   |SFX.UserAllowed            |

//930   |CUS.Felderpool             |
//931   |CUS.Felder                 |
//932   |CUS.Auswahlfelder          |

//940   |WoF.Schema                 |
//941   |WoF.Aktivit„ten            |
//942   |WoF.Bedingungen            |

//950   |Con.Controlling            |

//960   |SOA.Serviceinventar        |
//961   |SOA.UsersAllowed           |
//965   |SOA.Protokoll              |

//980   |TeM.Termine                |
//981   |TeM.Anker                  |
//982   |TeM.Bericht                |
//989   |TeM.Events                 |

//990   |PtD.Protokolldatei         |
//991   |PtD.Loeschung              |
//992   |PtD.Jobserver              |
//995   |Log.Changelog              |

//998   |Sel.Selektion              |
//999   |GV.Global                  |
QUIT
MULTILINK 100 12:Anschriften
MULTILINK 100 13:Ansprechpartner
MULTILINK 100 74:Kontaktdaten
MULTILINK 100 33:Verpackungen

MULTILINK 100 17:MaterialienByLieferant
MULTILINK 100 18:MaterialienByLageradresse
MULTILINK 100 19:MaterialienByKommissionskunde
MULTILINK 100 20:Art_Preise
MULTILINK 100 21:Auf_Aktionen
MULTILINK 100 22:Auf_PositionenByKunde
MULTILINK 100 23:Ein_PositionenByLieferant
MULTILINK 100 24:EinkaufskontrollenByLieferant
MULTILINK 100 25:ErloeseByKunde
MULTILINK 100 26:OffenePostenByKunde
MULTILINK 100 27:VerbindlichkeitenByLieferant
MULTILINK 100 28:EingangsrechnungenByLieferant
MULTILINK 100 29:x
MULTILINK 100 30:ProjekteByAdresse
MULTILINK 100 34:MatReservierungByKunde
MULTILINK 100 35:ArtChargenByLageradresse
MULTILINK 100 36:BedarfeByLieferant
MULTILINK 100 37:ZahlungseingaengeByKunde
MULTILINK 100 38:ZahlungsausgaengeByLieferant
MULTILINK 100 39:BAG_PositionenByLieferant
MULTILINK 100 40:StatistikKundeByKunde
MULTILINK 100 41:Ver_ProvisionenByKunde
MULTILINK 100 42:Lieferscheine
MULTILINK 100 44:SammelwareneingaengeByLieferant
MULTILINK 100 45:AuftrageByKunde
MULTILINK 100 46:AuftraegeByRechnungsempfaenger
MULTILINK 100 47:ErloeseByRechnungsempfaenger
MULTILINK 100 48:BAG_FertigungenByKunde
MULTILINK 100 49:ReklamationByKunde
MULTILINK 100 50:MaterialstrukturenByKunde
MULTILINK 100 51:Ein_PositionenByKommissionskunde
MULTILINK 100 52:StatistikenByKunde
MULTILINK 100 53:Bdf_AktionenByLieferant
MULTILINK 100 54:EinkaeufeByLieferant
MULTILINK 100 55:EinkaeufeByRechnungsempfaenger
MULTILINK 100 56:AnalysenByLieferant
MULTILINK 100 57:Art_ChargenByLieferant
MULTILINK 100 58:Ein_KalkulationenByLieferant
MULTILINK 100 59:Auf_KalkulationenByLieferant
MULTILINK 100 60:Kal_PositionenByLieferant
MULTILINK 100 61:ReklamationenByLieferant
MULTILINK 100 62:Ein_WareneingaengeByLieferant
MULTILINK 100 63:MaterialstrukturenByLieferant
MULTILINK 100 64:SWe_PositionenByLieferant
MULTILINK 100 65:VersandpooleintraegeBySpediteur
MULTILINK 100 66:VersendungenBySpediteur
MULTILINK 100 67:VersendungenByKunde
MULTILINK 100 68:HuB_PreiseByLieferant
MULTILINK 100 69:HuB_EnkauefeByLieferant
MULTILINK 100 70:Rek_PositionenByVerursacher
MULTILINK 100 71:x
MULTILINK 100 72:x

MULTILINK 101  3:MatterialienByLageradresse
MULTILINK 101  4:Art_ChargenByLageradresse
MULTILINK 101  5:BAG_PositionenByZieladresse
MULTILINK 101  8:Kontaktdaten

MULTILINK 102  2:Kontaktdaten

MULTILINK 103  1:Adressen

MULTILINK 105  1:Ausfuehrungen
MULTILINK 105  6:Materialstrukturen

MULTILINK 110  2:Provisionen
MULTILINK 110  4:Adressen
MULTILINK 110  5:Kontaktdaten

MULTILINK 120  2:Stuecklisteneintraege
MULTILINK 120  3:x
MULTILINK 120  4:Positionen
MULTILINK 120  5:Zeiten
MULTILINK 120  6:Erl_Konten
MULTILINK 120  7:Auf_Positionen
MULTILINK 120  8:x
MULTILINK 120  9:Ein_Positionen
MULTILINK 120 10:x
MULTILINK 120 11:Materialien
MULTILINK 120 12:x

MULTILINK 122  1:Zeiten

MULTILINK 160  1:Instandhaltungen
MULTILINK 160  6:Kalender
MULTILINK 160  7:Zusatztabelleneintraege
MULTILINK 160  8:BAG_Position

MULTILINK 165  1:Ursachen

MULTILINK 166  1:Massnahmen

MULTILINK 167  1:Ersatzteile
MULTILINK 167  2:IHA_Resssourcen

MULTILINK 180  1:Preise
MULTILINK 180  2:Journaleintraege

MULTILINK 190  1:Positionen

MULTILINK 191  1:Eingaenge

MULTILINK 200 11:Ausfuehrungen
MULTILINK 200 12:Bestandsbucheintraege
MULTILINK 200 13:Reservierungen
MULTILINK 200 14:Aktionen
MULTILINK 200 20:Ein_Wareneingaenge
MULTILINK 200 22:Auf_PositionenByAngebotsmaterial
MULTILINK 200 24:Auf_Aktionen
MULTILINK 200 27:Lfs_Positionen
MULTILINK 200 28:BAG_Fertigmeldungen
MULTILINK 200 29:BAG_Inputs
MULTILINK 200 32:Einkaufskontrolleintraege

MULTILINK 210 11:x
MULTILINK 210 12:x
MULTILINK 210 13:x
MULTILINK 210 14:x
MULTILINK 210 20:x
MULTILINK 210 22:x
MULTILINK 210 24:x
MULTILINK 210 27:x
MULTILINK 210 28:x
MULTILINK 210 29:x
MULTILINK 210 32:x

MULTILINK 220  8:Auf_Positionen
MULTILINK 220  9:Ein_Positionen
MULTILINK 220 10:Materialien
MULTILINK 220 11:Ausfuehrungen

MULTILINK 230  1:Positionen

MULTILINK 250  1:Stuecklisten
MULTILINK 250  2:SL_PositionenByEinsatz
MULTILINK 250  3:Auf_Positionen
MULTILINK 250  4:Chargen
MULTILINK 250  5:Journaleintraege
MULTILINK 250  6:Preise
MULTILINK 250  7:Auf_StuecklisteByProdukt
MULTILINK 250  8:Materialien
MULTILINK 250  9:Aufpreise
MULTILINK 250 12:Ein_Positionen
MULTILINK 250 13:Auf_Aktionen
MULTILINK 250 14:Bedarfe
MULTILINK 250 17:BAG_InputOutputByEinsatz
MULTILINK 250 18:x
MULTILINK 250 19:Reservierungen
MULTILINK 250 20:Ein_Wareneingaenge
MULTILINK 250 21:Inventuren
MULTILINK 250 24:x

MULTILINK 252  2:Auf_Aktionen
MULTILINK 252  5:Journaleintraege
MULTILINK 252  8:Inventuren
MULTILINK 252 10:Reservierungen

MULTILINK 255  2:Positionen

MULTILINK 280  1:Positionen

MULTILINK 300  1:Positionen
MULTILINK 300 11:x

MULTILINK 301  2:Aktionen
MULTILINK 301 10:Benutzer
MULTILINK 301 13:Ein_Wareneingaenge

MULTILINK 400  9:Positionen
MULTILINK 400 13:Aufpreise
MULTILINK 400 14:Kalkulation
MULTILINK 400 15:Aktionen
MULTILINK 400 16:Ausfuehrungen
MULTILINK 400 18:Stueckliste
MULTILINK 400 22:x
MULTILINK 400 23:PositionenByRahmen

MULTILINK 401  6:Aufpreise
MULTILINK 401  7:Kalkulationen
MULTILINK 401 11:Ausfuehrungen
MULTILINK 401 12:Aktionen
MULTILINK 401 15:Stueckliste
MULTILINK 401 17:MaterialienByKommission
MULTILINK 401 18:Mat_Reservierungen
MULTILINK 401 19:Erl_Konten
MULTILINK 401 20:x
MULTILINK 401 21:Materialstrukturen

MULTILINK 409  4:Aktionen

MULTILINK 410  9:x
MULTILINK 410 13:x
MULTILINK 410 14:x
MULTILINK 410 15:x
MULTILINK 410 16:x
MULTILINK 410 18:x
MULTILINK 410 22:x
MULTILINK 410 23:x

MULTILINK 411  6:x
MULTILINK 411  7:x
MULTILINK 411 11:x
MULTILINK 411 12:x
MULTILINK 411 15:x
MULTILINK 411 17:x
MULTILINK 411 18:x
MULTILINK 411 19:x
MULTILINK 411 20:x
MULTILINK 411 21:x

MULTILINK 440  4:Positionen
MULTILINK 440  5:x

MULTILINK 450  1:Konten
MULTILINK 450  4:Auf_Aktionen
MULTILINK 450  9:Gegenkonten
MULTILINK 450 13:Materialien
MULTILINK 450 14:MaterialienAblage

MULTILINK 451  7:Auf_Aktionen

MULTILINK 460  1:Zahlungen
MULTILINK 460  3:Erl_Konten
MULTILINK 460 10:x

MULTILINK 465  1:Zahlungen

MULTILINK 500  9:Positionen
MULTILINK 500 13:Aufpreise
MULTILINK 500 14:Kalkulationen
MULTILINK 500 15:Aktionen
MULTILINK 500 16:Ausfuehrungen
MULTILINK 500 18:PositionenByRahmen

MULTILINK 501  7:Aufpreise
MULTILINK 501  8:Kalkulationen
MULTILINK 501 12:Ausfuehrungen
MULTILINK 501 14:Wareneingaenge
MULTILINK 501 15:Aktionen
MULTILINK 501 21:Materialstrukturen

MULTILINK 506 13:Ausfuehrung

MULTILINK 510  9:x
MULTILINK 510 13:x
MULTILINK 510 14:x
MULTILINK 510 15:x
MULTILINK 510 16:x
MULTILINK 510 18:x

MULTILINK 511  7:x
MULTILINK 511  8:x
MULTILINK 511 12:x
MULTILINK 511 14:x
MULTILINK 511 15:x
MULTILINK 511 21:x

MULTILINK 540  1:Aktionen

MULTILINK 550  1:Konten
MULTILINK 550  6:Einkaufskontrolleintraege

MULTILINK 551  6:Einkaufskontrolleintraege

MULTILINK 555 10:Vbk_Konten

MULTILINK 560  1:ERe_Zahlungen
MULTILINK 560  3:Vbk_Konten
MULTILINK 560  4:Einkaufskontrolleintraege

MULTILINK 565  1:ERe_Zahlungen

MULTILINK 570  1:Buecher
MULTILINK 570  2:Kas_B_Posotionen

MULTILINK 571  2:Kas_B_Positionen

MULTILINK 580  1:Kos_Buchungen

MULTILINK 600  1:Positionen

MULTILINK 620  1:Positionen

MULTILINK 621 10:Ausfuehrungen

MULTILINK 650  3:Positionen

MULTILINK 655  6:Vsd_Positionen
MULTILINK 655  7:Auf_Aktionen

MULTILINK 700  1:Position
MULTILINK 700  2:Verpackungen
MULTILINK 700  3:InputOutputs
MULTILINK 700  4:x
MULTILINK 700  5:Fertigmeldungen
MULTILINK 700  6:Fergigungen

MULTILINK 701 12:Fertigmeldungen
MULTILINK 701 13:Lfs_Positionen
MULTILINK 701 15:Lfs_NachfolgerPositionen
MULTILINK 701 20:Fertigmeldungsbrueder

MULTILINK 702  2:Inputs
MULTILINK 702  3:Outputs
MULTILINK 702  4:Fertigungen
MULTILINK 702  5:Fertigmeldungen
MULTILINK 702  6:Zeiten
MULTILINK 702  9:Arbeitschritte
MULTILINK 702 14:Lieferscheine
MULTILINK 702 18:OutputFert
MULTILINK 702 19:Beistellungen
MULTILINK 702 20:Positionszusaetze

MULTILINK 703  3:Inputs
MULTILINK 703  4:Outputs
MULTILINK 703  8:Ausfuehrungen
MULTILINK 703 10:Fertigmeldungen

MULTILINK 704  3:Fertigungen

MULTILINK 707  4:Zeiten
MULTILINK 707  5:Outputs
MULTILINK 707 10:Fehler
MULTILINK 707 12:Beistellungen
MULTILINK 707 13:Ausfuehrungen

MULTILINK 800  2:Kontaktdaten

MULTILINK 822  1:Ressource

MULTILINK 830  1:Positionen

MULTILINK 832  1:Guetenmechaniken

MULTILINK 841  1:Adr_Verpackungsausfuehrungen
MULTILINK 841  2:Mat_Ausfuehrungen
MULTILINK 841  3:MSL_Ausfuehrungen
MULTILINK 841  4:Auf_Ausfuehrungen
MULTILINK 841  5:Ein_Ausfuehrungen
MULTILINK 841  6:Ein_Wareneingangsausfuehrungen
MULTILINK 841  7:SWe_Positionsausfuehrungen
MULTILINK 841  8:BAG_Ausfuehrungen

MULTILINK 842  1:Positionen
