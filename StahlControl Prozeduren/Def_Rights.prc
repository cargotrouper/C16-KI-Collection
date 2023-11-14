@A+
//                    OHNE E_R_G
// ACHTUNG!!! Dieser Sourcecode wird vom Programm analysiert
// und in den Rechtemanager übernommen. Jedes Recht muss dafür
// in der Form :
// "Rgt"+"_"+"Name" ":" "Nr" "// Bemerkung"
// vorliegen, damit es richtig erkannt wird.
//
// LETZTE BENUTZTE RECHTENUMMER : 850
//
// Hauptmenürechte müssen in "R g t_Menudata" eingetragen werden!

define begin
  Rgt_Admin                        :   1 // Administrator
  Rgt_Adressen                     :   2 // Adressen
  Rgt_Adr_Anlegen                  :   3 // Adressen anlegen
  Rgt_Adr_Aendern                  :   4 // Adressen ändern
  Rgt_Adr_Loeschen                 :   5 // Adressen löschen
  Rgt_User                         :   6 // User
  Rgt_Usr_Anlegen                  :   7 // User anlegen
  Rgt_Usr_Aendern                  :   8 // User ändern
  Rgt_Usr_Loeschen                 :   9 // User löschen
  Rgt_Usr_Rechte                   :  10 // User Rechte vergeben
  Rgt_Usergruppen                  :  11 // Usergruppen
  Rgt_Usr_G_Anlegen                :  12 // Usergruppen anlegen
  Rgt_Usr_G_Aendern                :  13 // Usergruppen ändern
  Rgt_Usr_G_Loeschen               :  14 // Usergruppen löschen
  Rgt_Gruppen                      :  15 // Adressgruppen
  Rgt_Grp_Anlegen                  :  16 // Adressgruppen anlegen
  Rgt_Grp_Aendern                  :  17 // Adressgruppen ändern
  Rgt_Grp_Loeschen                 :  18 // Adressgruppen löschen
  Rgt_Anreden                      :  19 // Anreden
  Rgt_Anr_Anlegen                  :  20 // Anreden anlegen
  Rgt_Anr_Aendern                  :  21 // Anreden ändern
  Rgt_Anr_Loeschen                 :  22 // Anreden löschen
  Rgt_Lieferbed                    :  23 // Lieferbedingungen
  Rgt_LiB_Anlegen                  :  24 // Lieferbedingungen anlegen
  Rgt_LiB_Aendern                  :  25 // Lieferbedingungen ändern
  Rgt_LiB_Loeschen                 :  26 // Lieferbedingungen löschen
  Rgt_Zahlungsbed                  :  27 // Zahlungsbedingungen
  Rgt_ZaB_Anlegen                  :  28 // Zahlungsbedingungen anlegen
  Rgt_ZaB_Aendern                  :  29 // Zahlungsbedingungen ändern
  Rgt_ZaB_Loeschen                 :  30 // Zahlungsbedingungen löschen
  Rgt_Versandarten                 :  31 // Versandarten
  Rgt_VsA_Anlegen                  :  32 // Versandarten anlegen
  Rgt_VsA_Aendern                  :  33 // Versandarten ändern
  Rgt_VsA_Loeschen                 :  34 // Versandarten löschen
  Rgt_Verwiegungsarten             :  35 // Verwiegungsarten
  Rgt_VwA_Anlegen                  :  36 // Verwiegungsarten anlegen
  Rgt_VwA_Aendern                  :  37 // Verwiegungsarten ändern
  Rgt_VwA_Loeschen                 :  38 // Verwiegungsarten löschen
  Rgt_Einst_Schluessel             :  39 // Einstellungen - Schlüssel
  Rgt_Einst_Nummernkreise          :  40 // Einstellungen - Nummernkreise
  Rgt_Einst_Settings               :  41 // Einstellungen - Settings
  Rgt_Einst_Uebersetzung           :  42 // Einstellungen - Übersetzungen
  Rgt_Einst_Ausdrucke              :  43 // Einstellungen - Ausdrucke
  Rgt_Einst_Individuell            :  44 // Einstellungen - Idividuell
  Rgt_Usr_Gruppen                  :  45 // User Gruppe vergeben
  Rgt_Adr_Ansprechpartner          :  46 // Adressen-Ansprechpartner
  Rgt_Adr_Anschriften              :  47 // Adressen-Anschriften
  Rgt_Adr_A_Anlegen                :  48 // Adressen-Anschriften anlegen
  Rgt_Adr_A_Aendern                :  49 // Adressen-Anschriften ändern
  Rgt_Adr_A_Loeschen               :  50 // Adressen-Anschriften löschen
  Rgt_Adr_P_Anlegen                :  51 // Adressen-Ansprechpartner anlegen
  Rgt_Adr_P_Aendern                :  52 // Adressen-Ansprechpartner ändern
  Rgt_Adr_P_Loeschen               :  53 // Adressen-Ansprechpartner löschen
  Rgt_Adr_Kreditlimit              :  54 // Adressen-Kreditlimit
  Rgt_Adr_K_Anlegen                :  55 // Adressen-Anschriften anlegen
  Rgt_Adr_K_Aendern                :  56 // Adressen-Kreditlimit ändern
  Rgt_Adr_K_Loeschen               :  57 // Adressen-Kreditlimit löschen
  Rgt_Material                     :  58 // Material
  Rgt_Mat_Anlegen                  :  59 // Material anlegen
  Rgt_Mat_Aendern                  :  60 // Material ändern
  Rgt_Mat_Loeschen                 :  61 // Material löschen
  Rgt_Termine                      :  62 // Aktivitäten
  Rgt_TeM_Anlegen                  :  63 // Aktivität anlegen
  Rgt_TeM_Aendern                  :  64 // Aktivität ändern
  Rgt_TeM_Loeschen                 :  65 // Aktivität löschen
  Rgt_Abteilungen                  :  66 // Abteilungen
  Rgt_Abt_Anlegen                  :  67 // Abteilungen anlegen
  Rgt_Abt_Aendern                  :  68 // Abteilungen ändern
  Rgt_Abt_Loeschen                 :  69 // Abteilungen löschen
  Rgt_Ressourcengruppen            :  70 // Ressourcengruppe
  Rgt_Rso_Grp_Anlegen              :  71 // Ressourcengruppe anlegen
  Rgt_Rso_Grp_Aendern              :  72 // Ressourcengruppe ändern
  Rgt_Rso_Grp_Loeschen             :  73 // Ressourcengruppe löschen
  Rgt_IHA_Meldungen                :  74 // Instandhaltungsmeldungen
  Rgt_IHA_Mld_Anlegen              :  75 // Instandhaltungsmeldungen anlegen
  Rgt_IHA_Mld_Aendern              :  76 // Instandhaltungsmeldungen ändern
  Rgt_IHA_Mld_Loeschen             :  77 // Instandhaltungsmeldungen löschen
  Rgt_IHA_Ursachen                 :  78 // Instandhaltungsursachen
  Rgt_IHA_Urs_Anlegen              :  79 // Instandhaltungsursachen anlegen
  Rgt_IHA_Urs_Aendern              :  80 // Instandhaltungsursachen ändern
  Rgt_IHA_Urs_Loeschen             :  81 // Instandhaltungsursachen löschen
  Rgt_IHA_Massnahmen               :  82 // Instandhaltungsmaßnahmen
  Rgt_IHA_Mas_Anlegen              :  83 // Instandhaltungsmaßnahmen anlegen
  Rgt_IHA_Mas_Aendern              :  84 // Instandhaltungsmaßnahmen ändern
  Rgt_IHA_Mas_Loeschen             :  85 // Instandhaltungsmaßnahmen löschen
  Rgt_Ressourcen                   :  86 // Ressourcen
  Rgt_Rso_Anlegen                  :  87 // Ressourcen anlegen
  Rgt_Rso_Aendern                  :  88 // Ressourcen ändern
  Rgt_Rso_Loeschen                 :  89 // Ressourcen löschen
  Rgt_HuB                          :  90 // Hilfs & Betriebstoffe
  Rgt_HuB_Anlegen                  :  91 // HuB anlegen
  Rgt_HuB_Aendern                  :  92 // HuB ändern
  Rgt_HuB_Loeschen                 :  93 // HuB löschen
  Rgt_HuB_Preise                   :  94 // HuB-Preise
  Rgt_HuB_P_Anlegen                :  95 // HuB-Preise anlegen
  Rgt_HuB_P_Aendern                :  96 // HuB-Preise ändern
  Rgt_HuB_P_Loeschen               :  97 // HuB-Preise löschen
  Rgt_Rso_IHA                      :  98 // Ressourcen-IHA
  Rgt_Rso_IHA_Anlegen              :  99 // Ressourcen-IHA anlegen
  Rgt_Rso_IHA_Aendern              : 100 // Ressourcen-IHA ändern
  Rgt_Rso_IHA_Loeschen             : 101 // Ressourcen-IHA löschen
  Rgt_Rso_Wartungen                : 102 // Ressourcen-Wartungen
  Rgt_Rso_Wrt_Anlegen              : 103 // Ressourcen-Wartungen anlegen
  Rgt_Rso_Wrt_Aendern              : 104 // Ressourcen-Wartungen ändern
  Rgt_Rso_Wrt_Loeschen             : 105 // Ressourcen-Wartungen löschen
  Rgt_HuB_Einkauf                  : 106 // HuB-Einkauf
  Rgt_HuB_EK_Anlegen               : 107 // HuB-Einkaufskopf anlegen
  Rgt_HuB_EK_Aendern               : 108 // HuB-Einkaufskopf ändern
  Rgt_HuB_EK_Loeschen              : 109 // HuB-Einkaufskopf löschen
  Rgt_HuB_EK_Positionen            : 110 // HuB-Einkaufspositionen
  Rgt_HuB_EK_P_Anlegen             : 111 // HuB-Einkaufsposition anlegen
  Rgt_HuB_EK_P_Aendern             : 112 // HuB-Einkaufsposition ändern
  Rgt_HuB_EK_P_Loeschen            : 113 // HuB-Einkaufsposition löschen
  Rgt_HuB_EK_Eingaenge             : 114 // HuB-Einkaufseingänge
  Rgt_HuB_EK_E_Anlegen             : 115 // HuB-Einkaufseingänge anlegen
  Rgt_HuB_EK_E_Aendern             : 116 // HuB-Einkaufseingänge ändern
  Rgt_HuB_EK_E_Loeschen            : 117 // HuB-Einkaufseingänge löschen
  Rgt_Warengruppen                 : 118 // Warengruppen
  Rgt_Wgr_Anlegen                  : 119 // Warengruppen anlegen
  Rgt_Wgr_Aendern                  : 120 // Warengruppen ändern
  Rgt_Wgr_Loeschen                 : 121 // Warengruppen löschen
  Rgt_Termine_Anker                : 122 // Aktivitäten Anker
  Rgt_TeM_A_Anlegen                : 123 // Anker anlegen
  Rgt_TeM_A_Aendern                : 124 // Anker ändern
  Rgt_TeM_A_Loeschen               : 125 // Anker löschen
  Rgt_HuB_Lagerbewegung            : 126 // HuB Lagerbewegung
  Rgt_Rso_Ursachen                 : 127 // Ressourcen-Ursachen
  Rgt_Rso_Urs_Anlegen              : 128 // Ressourcen-Ursachen anlegen
  Rgt_Rso_Urs_Aendern              : 129 // Ressourcen-Ursachen ändern
  Rgt_Rso_Urs_Loeschen             : 130 // Ressourcen-Ursachen löschen
  Rgt_Rso_Massnahmen               : 131 // Ressourcen-Maßnahmen
  Rgt_Rso_Mas_Anlegen              : 132 // Ressourcen-Maßnahmen anlegen
  Rgt_Rso_Mas_Aendern              : 133 // Ressourcen-Maßnahmen ändern
  Rgt_Rso_Mas_Loeschen             : 134 // Ressourcen-Maßnahmen löschen
  Rgt_Rso_Ersatzteile              : 135 // Ressourcen-Ersatzteile
  Rgt_Rso_ErT_Anlegen              : 136 // Ressourcen-Ersatzteile anlegen
  Rgt_Rso_ErT_Aendern              : 137 // Ressourcen-Ersatzteile ändern
  Rgt_Rso_ErT_Loeschen             : 138 // Ressourcen-Ersatzteile löschen
  Rgt_Rso_Ressourcen               : 139 // Ressourcen-Reparatur Ressourcen
  Rgt_Rso_Rso_Anlegen              : 140 // Ressourcen-Reparatur Ressourcen anlegen
  Rgt_Rso_Rso_Aendern              : 141 // Ressourcen-Reparatur Ressourcen ändern
  Rgt_Rso_Rso_Loeschen             : 142 // Ressourcen-Reparatur Ressourcen löschen
  Rgt_Mnu_Auftrag                  : 143 // Menüpunkt Aufträge
  Rgt_Mnu_Einkauf                  : 144 // Menüpunkt Einkauf
  Rgt_Mnu_Produktion               : 145 // Menüpunkt Produktion
  Rgt_Mnu_QS                       : 146 // Menüpunkt QS
  Rgt_Mnu_Finanzen                 : 147 // Menüpunkt Finanzen
  Rgt_Mnu_Stammdaten               : 148 // Menüpunkt Stammdaten
  Rgt_Mnu_Vorgaben                 : 149 // Menüpunkt Vorgaben
  Rgt_Mnu_Extras                   : 150 // Menüpunkt Extras
  Rgt_Mnu_Datenbank                : 151 // Menüpunkt Datenbank
  Rgt_Mnu_Schluesseldateien        : 152 // Menüpunkt Schlüsseldateien
  Rgt_Mnu_Rechtesystem             : 153 // Menüpunkt Rechtesystem
  Rgt_Mnu_Einstellungen            : 154 // Menüpunkt Einstellungen
  Rgt_Mnu_Aktivitaeten             : 155 // Menüpunkt Aktivitäten
  Rgt_Mnu_Dokumentablage           : 156 // Menüpunkt Dokumentenablage
  Rgt_Mnu_Dka_Auftragsbest         : 157 // Menüpunkt Dokumentenablage Auftragsbest.
  Rgt_Mnu_Dka_Lieferscheine        : 158 // Menüpunkt Dokumentenablage Lieferscheine
  Rgt_Mnu_Dka_Rechnungen           : 159 // Menüpunkt Dokumentenablage Rechnungen
  Rgt_Mnu_Benutzerwechsel          : 160 // Menüpunkt Benutzerwechsel
  Rgt_Mnu_Passwortaendern          : 161 // Menüpunkt Passwortänderung
  Rgt_Mnu_DBInfo                   : 162 // Menüpunkt Datenbankinformationen
  Rgt_Mnu_Datenbankpflege          : 163 // Menüpunkt Datenbankpflege
  Rgt_Materialstatus               : 164 // Materialstatus
  Rgt_Mta_Anlegen                  : 165 // Materialstatus anlegen
  Rgt_Mta_Aendern                  : 166 // Materialstatus ändern
  Rgt_Mta_Loeschen                 : 167 // Materialstatus löschen
  Rgt_OffenePosten                 : 168 // Offene Posten
  Rgt_OfP_Anlegen                  : 169 // Offene Posten anlegen
  Rgt_OfP_Aendern                  : 170 // Offene Posten ändern
  Rgt_OfP_Loeschen                 : 171 // Offene Posten löschen
  Rgt_EKK                          : 172 // Einkaufskontrolle
  Rgt_EKK_Anlegen                  : 173 // Einkaufskontrolle anlegen
  Rgt_EKK_Aendern                  : 174 // Einkaufskontrolle ändern
  Rgt_EKK_Loeschen                 : 175 // Einkaufskontrolle löschen
  Rgt_ERe                          : 176 // Eingangsrechnung
  Rgt_ERe_Anlegen                  : 177 // Eingangsrechnung anlegen
  Rgt_ERe_Aendern                  : 178 // Eingangsrechnung ändern
  Rgt_ERe_Loeschen                 : 179 // Eingangsrechnung löschen
  Rgt_Formel                       : 180 // Formeln
  Rgt_For_Anlegen                  : 181 // Formel anlegen
  Rgt_For_Aendern                  : 182 // Formel ändern
  Rgt_For_Loeschen                 : 183 // Formel löschen
  Rgt_Fvariable                    : 184 // Variablen
  Rgt_Var_Anlegen                  : 185 // Variable anlegen
  Rgt_Var_Aendern                  : 186 // Variable ändern
  Rgt_Var_Loeschen                 : 187 // Variable löschen
  Rgt_Artikel                      : 188 // Artikel
  Rgt_Art_Anlegen                  : 189 // Artikel anlegen
  Rgt_Art_Aendern                  : 190 // Artikel ändern
  Rgt_Art_Loeschen                 : 191 // Artikel löschen
  Rgt_Mnu_Favoriten                : 192 // Favoriten
  Rgt_Zahlungsein                  : 193 // Zahlungseingänge
  Rgt_ZEi_Anlegen                  : 194 // Zahlungseingang anlegen
  Rgt_ZEi_Aendern                  : 195 // Zahlungseingang ändern
  Rgt_ZEi_Loeschen                 : 196 // Zahlungseingang löschen
  Rgt_OffenePostenZahl             : 197 // Offene Posten Zahlungen
  Rgt_OfP_Z_Anlegen                : 198 // Offene Posten Zahlungen anlegen
  Rgt_OfP_Z_Aendern                : 199 // Offene Posten Zahlungen ändern
  Rgt_OfP_Z_Loeschen               : 200 // Offene Posten Zahlungen löschen
  Rgt_VertreterVerbaende           : 201 // Vertreter und Verbände
  Rgt_Ver_Anlegen                  : 202 // Vertreter und Verbände anlegen
  Rgt_Ver_Aendern                  : 203 // Vertreter und Verbände ändern
  Rgt_Ver_Loeschen                 : 204 // Vertreter und Verbände löschen
  Rgt_Fixkosten                    : 205 // Fixkosten
  Rgt_FxK_Anlegen                  : 206 // Fixkosten anlegen
  Rgt_FxK_Aendern                  : 207 // Fixkosten ändern
  Rgt_FxK_Loeschen                 : 208 // Fixkosten löschen
  Rgt_Mnu_Kommandozeile            : 209 // Kommandozeile
  Rgt_Abmessungstol                : 210 // Abmessungstoleranzen
  Rgt_MTo_Anlegen                  : 211 // Abmessungstoleranz anlegen
  Rgt_MTo_Aendern                  : 212 // Abmessungstoleranz ändern
  Rgt_MTo_Loeschen                 : 213 // Abmessungstoleranz löschen
  Rgt_Qualitaeten                  : 214 // Qualitäten
  Rgt_MQu_Anlegen                  : 215 // Qualitäten anlegen
  Rgt_MQu_Aendern                  : 216 // Qualitäten ändern
  Rgt_MQu_Loeschen                 : 217 // Qualitäten löschen
  Rgt_QualitaetenMechanik          : 218 // Qualitätsmechaniken
  Rgt_MQu_M_Anlegen                : 219 // Qualitätsmechaniken anlegen
  Rgt_MQu_M_Aendern                : 220 // Qualitätsmechaniken ändern
  Rgt_MQu_M_Loeschen               : 221 // Qualitätsmechaniken löschen
  Rgt_Artikelgruppen               : 222 // Artikelgruppen
  Rgt_Agr_Anlegen                  : 223 // Artikelgruppen anlegen
  Rgt_Agr_Aendern                  : 224 // Artikelgruppen ändern
  Rgt_Agr_Loeschen                 : 225 // Artikelgruppen löschen
  Rgt_MathAlpabet                  : 226 // Formelalphabet
  Rgt_alp_Anlegen                  : 227 // Formelalphabet anlegen
  Rgt_alp_Aendern                  : 228 // Formelalphabet ändern
  Rgt_alp_Loeschen                 : 229 // Formelalphabet löschen
  Rgt_ArbPlanVorlage               : 230 // Arbeitsplanvorlage
  Rgt_Apv_Anlegen                  : 231 // Arbeitsplanvorlage anlegen
  Rgt_Apv_Aendern                  : 232 // Arbeitsplanvorlage ändern
  Rgt_Apv_Loeschen                 : 233 // Arbeitsplanvorlage löschen
  Rgt_ArbVorgabe                   : 234 // Arbeitsaktionvorgabe, Tätigkeit
  Rgt_Arb_Anlegen                  : 235 // Arbeitsaktionvorgabe anlegen
  Rgt_Arb_Aendern                  : 236 // Arbeitsaktionvorgabe ändern
  Rgt_Arb_Loeschen                 : 237 // Arbeitsaktionvorgabe löschen
  Rgt_Artplan                      : 238 // Artikelpläne
  Rgt_Apl_Anlegen                  : 239 // Artikelpläne anlegen
  Rgt_Apl_Aendern                  : 240 // Artikelpläne ändern
  Rgt_Apl_Loeschen                 : 241 // Artikelpläne löschen
  Rgt_Art_Lagerorte                : 242 // Artikel-Lagerorte
  Rgt_Art_L_Anlegen                : 243 // Artikel-Lagerorte anlegen
  Rgt_Art_L_Aendern                : 244 // Artikel-Lagerorte ändern
  Rgt_Art_L_Loeschen               : 245 // Artikel-Lagerorte löschen
  Rgt_Art_Chargen                  : 246 // Artikel-Chargen
  Rgt_Art_C_Anlegen                : 247 // Artikel-Chargen anlegen
  Rgt_Art_C_Aendern                : 248 // Artikel-Chargen ändern
  Rgt_Art_C_Loeschen               : 249 // Artikel-Chargen löschen
  Rgt_Art_Preise                   : 250 // Artikel-Preise
  Rgt_Art_P_Anlegen                : 251 // Artikel-Preise anlegen
  Rgt_Art_P_Aendern                : 252 // Artikel-Preise ändern
  Rgt_Art_P_Loeschen               : 253 // Artikel-Preise löschen
  Rgt_Art_Journal                  : 254 // Artikel-Journal
  Rgt_Art_J_Anlegen                : 255 // Artikel-Journal anlegen
  Rgt_Art_J_Aendern                : 256 // Artikel-Journal ändern
  Rgt_Art_J_Loeschen               : 257 // Artikel-Journal löschen
  Rgt_Einkauf                      : 258 // Einkauf
  Rgt_EK_Anlegen                   : 259 // Einkauf anlegen
  Rgt_EK_Aendern                   : 260 // Einkauf ändern
  Rgt_EK_Loeschen                  : 261 // Einkauf löschen
  Rgt_EK_Positionen                : 262 // Einkaufspositionen
  Rgt_EK_P_Anlegen                 : 263 // Einkaufsposition anlegen
  Rgt_EK_P_Aendern                 : 264 // Einkaufsposition ändern
  Rgt_EK_P_Loeschen                : 265 // Einkaufsposition löschen
  Rgt_EK_Aufpreise                 : 266 // Einkaufsaufpreise
  Rgt_EK_Z_Anlegen                 : 267 // Einkaufsaufpreis anlegen
  Rgt_EK_Z_Aendern                 : 268 // Einkaufsaufpreis ändern
  Rgt_EK_Z_Loeschen                : 269 // Einkaufsaufpreis löschen
  Rgt_EK_Wareneingang              : 270 // Einkaufswareneingänge
  Rgt_EK_E_Anlegen                 : 271 // Einkaufswareneingang anlegen
  Rgt_EK_E_Aendern                 : 272 // Einkaufswareneingang ändern
  Rgt_EK_E_Loeschen                : 273 // Einkaufswareneingang löschen
  Rgt_EK_Kalkulation               : 274 // Einkaufskalkulation
  Rgt_EK_K_Anlegen                 : 275 // Einkaufskalkulation anlegen
  Rgt_EK_K_Aendern                 : 276 // Einkaufskalkulation ändern
  Rgt_EK_K_Loeschen                : 277 // Einkaufskalkulation löschen
  Rgt_EK_Aktion                    : 278 // Einkaufsaktionen
  Rgt_EK_A_Anlegen                 : 279 // Einkaufsaktion anlegen
  Rgt_EK_A_Aendern                 : 280 // Einkaufsaktion ändern
  Rgt_EK_A_Loeschen                : 281 // Einkaufsaktion löschen
  Rgt_ERe_Z                        : 282 // Eingangsrechnung Zahlungen
  Rgt_ERe_Z_Anlegen                : 283 // Eingangsrechnung Zahlungen anlegen
  Rgt_ERe_Z_Aendern                : 284 // Eingangsrechnung Zahlungen ändern
  Rgt_ERe_Z_Loeschen               : 285 // Eingangsrechnung Zahlungen löschen
  Rgt_ZAu                          : 286 // Zahlungsausgang
  Rgt_ZAu_Anlegen                  : 287 // Zahlungsausgang anlegen
  Rgt_ZAu_Aendern                  : 288 // Zahlungsausgang ändern
  Rgt_ZAu_Loeschen                 : 289 // Zahlungsausgang löschen
  Rgt_Vbk_K                        : 290 // Verbindlichkeiten Kontierung
  Rgt_Vbk_K_Anlegen                : 291 // Verbindlichkeiten Kontierung anlegen
  Rgt_Vbk_K_Aendern                : 292 // Verbindlichkeiten Kontierung ändern
  Rgt_Vbk_K_Loeschen               : 293 // Verbindlichkeiten Kontierung löschen
  Rgt_Texte                        : 294 // Texte
  Rgt_Txt_Anlegen                  : 295 // Texte anlegen
  Rgt_Txt_Aendern                  : 296 // Texte ändern
  Rgt_Txt_Loeschen                 : 297 // Texte löschen
  Rgt_BDS                          : 298 // BDS Nummer
  Rgt_BDS_Anlegen                  : 299 // BDS Nummer anlegen
  Rgt_BDS_Aendern                  : 300 // BDS Nummer ändern
  Rgt_BDS_Loeschen                 : 301 // BDS Nummer löschen
  Rgt_Erloeskonten                 : 302 // Erlöskonten
  Rgt_Erl_K_Anlegen                : 303 // Erlöskontierung anlegen
  Rgt_Erl_K_Aendern                : 304 // Erlöskontierung ändern
  Rgt_Erl_K_Loeschen               : 305 // Erlöskontierung löschen
  Rgt_Auftragsarten                : 306 // Auftragsarten
  Rgt_AAr_Anlegen                  : 307 // Auftragsarten anlegen
  Rgt_AAr_Aendern                  : 308 // Auftragsarten ändern
  Rgt_AAr_Loeschen                 : 309 // Auftragsarten löschen
  Rgt_Etiketten                    : 310 // Etiketten
  Rgt_Eti_Anlegen                  : 311 // Etiketten anlegen
  Rgt_Eti_Aendern                  : 312 // Etiketten ändern
  Rgt_Eti_Loeschen                 : 313 // Etiketten löschen
  Rgt_Unterlagen                   : 314 // Unterlagen
  Rgt_ULa_Anlegen                  : 315 // Unterlagen anlegen
  Rgt_ULa_Aendern                  : 316 // Unterlagen ändern
  Rgt_ULa_Loeschen                 : 317 // Unterlagen löschen
  Rgt_Zeugnisse                    : 318 // Zeugnisse
  Rgt_Zeu_Anlegen                  : 319 // Zeugnisse anlegen
  Rgt_Zeu_Aendern                  : 320 // Zeugnisse ändern
  Rgt_Zeu_Loeschen                 : 321 // Zeugnisse löschen
  Rgt_Oberflaechen                 : 322 // Oberflächen
  Rgt_Obf_Anlegen                  : 323 // Oberflächen anlegen
  Rgt_Obf_Aendern                  : 324 // Oberflächen ändern
  Rgt_Obf_Loeschen                 : 325 // Oberflächen löschen
  Rgt_Aufpreise                    : 326 // Aufpreise
  Rgt_ApZ_Anlegen                  : 327 // Aufpreise anlegen
  Rgt_ApZ_Aendern                  : 328 // Aufpreise ändern
  Rgt_ApZ_Loeschen                 : 329 // Aufpreise löschen
  Rgt_BAG                          : 330 // Betriebsaufträge
  Rgt_BAG_Anlegen                  : 331 // Betriebsauftrag anlegen
  Rgt_BAG_Aendern                  : 332 // Betriebsauftrag ändern
  Rgt_BAG_Loeschen                 : 333 // Betriebsauftrag löschen
  Rgt_Auftrag                      : 334 // Auftrag
  Rgt_Auf_Anlegen                  : 335 // Auftrag anlegen
  Rgt_Auf_Aendern                  : 336 // Auftrag ändern
  Rgt_Auf_Loeschen                 : 337 // Auftrag löschen
  Rgt_Auf_Positionen               : 338 // Auftragspositionen
  Rgt_Auf_P_Anlegen                : 339 // Auftragsposition anlegen
  Rgt_Auf_P_Aendern                : 340 // Auftragsposition ändern
  Rgt_Auf_P_Loeschen               : 341 // Auftragsposition löschen
  Rgt_Auf_Aufpreise                : 342 // Auftragsaufpreise
  Rgt_Auf_Z_Anlegen                : 343 // Auftragsaufpreis anlegen
  Rgt_Auf_Z_Aendern                : 344 // Auftragsaufpreis ändern
  Rgt_Auf_Z_Loeschen               : 345 // Auftragsaufpreis löschen
  Rgt_Auf_Wareneingang             : 346 // Auftragswareneingänge
  Rgt_Auf_E_Anlegen                : 347 // Auftragswareneingang anlegen
  Rgt_Auf_E_Aendern                : 348 // Auftragswareneingang ändern
  Rgt_Auf_E_Loeschen               : 349 // Auftragswareneingang löschen
  Rgt_Auf_Kalkulation              : 350 // Auftragskalkulation
  Rgt_Auf_K_Anlegen                : 351 // Auftragskalkulation anlegen
  Rgt_Auf_K_Aendern                : 352 // Auftragskalkulation ändern
  Rgt_Auf_K_Loeschen               : 353 // Auftragskalkulation löschen
  Rgt_Auf_Aktion                   : 354 // Auftragsaktionen
  Rgt_Auf_A_Anlegen                : 355 // Auftragsaktion anlegen
  Rgt_Auf_A_Aendern                : 356 // Auftragsaktion ändern
  Rgt_Auf_A_Loeschen               : 357 // Auftragsaktion löschen
  Rgt_Lieferschein                 : 358 // Lieferscheine
  Rgt_LFS_Anlegen                  : 359 // Lieferschein anlegen
  Rgt_LFS_Aendern                  : 360 // Lieferschein ändern
  Rgt_LFS_Loeschen                 : 361 // Lieferschein löschen
  Rgt_LFS_Verbuchen                : 362 // Lieferschein verbuchen
  Rgt_LFS_Stornieren               : 364 // Lieferschein stornieren
  Rgt_LFS_Druck_LFS                : 365 // Lieferschein: Druck Lieferschein
  Rgt_LFS_Druck_VLDAW              : 366 // Lieferschein: Druck Verladeanweisung
  Rgt_Auf_Druck_AB                 : 367 // Auftrag: Druck Auftragsbestätigung
  Rgt_Auf_Druck_RE                 : 368 // Auftrag: Druck Rechnung
  Rgt_Projekte                     : 369 // Projekte
  Rgt_Prj_Anlegen                  : 370 // Projekt anlegen
  Rgt_Prj_Aendern                  : 371 // Projekt ändern
  Rgt_Prj_Loeschen                 : 372 // Projekt löschen
  Rgt_Erloese                      : 373 // Erlöse/Umsätze
  Rgt_Erl_Stornieren               : 374 // Erlös stornieren
  Rgt_Nummernkreise                : 375 // Nummernkreise
  Rgt_Nrs_Anlegen                  : 376 // Nummernkreis anlegen
  Rgt_Nrs_Aendern                  : 377 // Nummernkreis ändern
  Rgt_Nrs_Loeschen                 : 378 // Nummernkreis löschen
  Rgt_Bedarf                       : 379 // Bedarf
  Rgt_Bdf_Anlegen                  : 380 // Bedarf anlegen
  Rgt_Bdf_Aendern                  : 381 // Bedarf ändern
  Rgt_Bdf_Loeschen                 : 382 // Bedarf löschen
  Rgt_Jobs                         : 383 // Job-Server-Jobs
  Rgt_Job_Anlegen                  : 384 // Job-Server-Jobs anlegen
  Rgt_Job_Aendern                  : 385 // Job-Server-Jobs ändern
  Rgt_Job_Loeschen                 : 386 // Job-Server-Jobs löschen
  Rgt_EK_Druck_Best                : 387 // Einkauf: Druck Bestellung
  Rgt_Auf_Ang2Auf                  : 388 // Auftrag: Angebot in Auftrag umwandeln
  Rgt_Auf_Druck_Angebot            : 389 // Auftrag: Druck Angebot
  Rgt_ERe_Pruefen                  : 390 // Eingangsrechnung prüfen
  Rgt_Vbk                          : 391 // Verbindlichkeiten
  Rgt_Vbk_Anlegen                  : 392 // Verbindlichkeiten anlegen
  Rgt_Vbk_Aendern                  : 393 // Verbindlichkeiten ändern
  Rgt_Vbk_Loeschen                 : 394 // Verbindlichkeiten löschen
  Rgt_Auf_Korr_Menge               : 395 // Auftragsposition: Korrektur Menge
  Rgt_Auf_Korr_Termin              : 396 // Auftragsposition: Korrektur Termin
  Rgt_Art_AutoDispo                : 397 // Artikel: automatische Disposition
  Rgt_Bdf_Bestellen                : 398 // Bedarf: Bestellung generieren
  Rgt_Lagerplaetze                 : 399 // Lagerplätze
  Rgt_LPl_Anlegen                  : 400 // Lagerplätze anlegen
  Rgt_LPl_Aendern                  : 401 // Lagerplätze ändern
  Rgt_LPl_Loeschen                 : 402 // Lagerplätze löschen
  Rgt_Auf_Druck_Gut                : 403 // Auftrag: Druck Gutschrift
  Rgt_Auf_Druck_Bel                : 404 // Auftrag: Druck Belastung
  Rgt_Protokoll                    : 405 // Protokoll konfigurieren
  Rgt_Bdf_Anfragen                 : 406 // Bedarf: Anfrage generieren
  Rgt_Abl_Ein_Reorg                : 407 // Ablage: Bestellungen reorganisieren
  Rgt_Erl_Fibu                     : 408 // Erlöse: Fibu-Übergabe
  Rgt_KSt                          : 409 // Kostenstellen
  Rgt_KSt_Anlegen                  : 410 // Kostenstellen anlegen
  Rgt_KSt_Aendern                  : 411 // Kostenstellen ändern
  Rgt_KSt_Loeschen                 : 412 // Kostenstellen löschen
  Rgt_Arbeitsgaenge                : 413 // Arbeitsgänge
  Rgt_ArG_Anlegen                  : 414 // Arbeitsgänge anlegen
  Rgt_ArG_Aendern                  : 415 // Arbeitsgänge ändern
  Rgt_ARg_Loeschen                 : 416 // Arbeitsgänge löschen
  Rgt_Auf_Feinabrufe               : 417 // Auftrags-Feinabrufe
  Rgt_Auf_FA_Anlegen               : 418 // Auftrags-Feinabrufe anlegen
  Rgt_Auf_FA_Aendern               : 419 // Auftrags-Feinabrufe ändern
  Rgt_Auf_FA_Loeschen              : 420 // Auftrags-Feinabrufe löschen
  Rgt_Auf_Stueckliste              : 421 // Auftrags-Stückliste
  Rgt_Auf_SL_Anlegen               : 422 // Auftrags-Stückliste anlegen
  Rgt_Auf_SL_Aendern               : 423 // Auftrags-Stückliste ändern
  Rgt_Auf_SL_Loeschen              : 424 // Auftrags-Stückliste löschen
  Rgt_Auf_Reservierung             : 425 // Auftrags-Reservierungen
  Rgt_Auf_SL_RV_Anlegen            : 426 // Auftrags-Reservierungen anlegen
  Rgt_Auf_SL_RV_Aendern            : 427 // Auftrags-Reservierungen ändern
  Rgt_Auf_SL_RV_Loeschen           : 428 // Auftrags-Reservierungen löschen
  Rgt_Auf_BAGAbschluss             : 429 // Auftrag: Produktion gesamt abschließen
  Rgt_Auf_A_Berechnen              : 430 // Auftragsaktion: Berechnungsmarker
  Rgt_Auf_Matz                     : 431 // Auftrag: Material zuordnen
  Rgt_Prj_Stueckliste              : 432 // Projekte-Stückliste
  Rgt_Prj_SL_Anlegen               : 433 // Projekt-Stückliste anlegen
  Rgt_Prj_SL_Aendern               : 434 // Projekt-Stückliste ändern
  Rgt_Prj_SL_Loeschen              : 435 // Projekt-Stückliste löschen
  Rgt_Auf_ProjektSL                : 436 // Auftrag: Stückliste auf Projekt importieren
  Rgt_Mat_Aktion                   : 437 // Materialaktionen
  Rgt_Mat_A_Anlegen                : 438 // Materialaktion anlegen
  Rgt_Mat_A_Aendern                : 439 // Materialaktion ändern
  Rgt_Mat_A_Loeschen               : 440 // Materialaktion löschen
  Rgt_Mat_Splitten                 : 441 // Material: Karte splitten
  Rgt_EK_AusExcel                  : 442 // Einkauf: Exceldatei importieren
  Rgt_Auf_Einsatzmaterial          : 443 // Auftrags-Einsatzmaterial
  Rgt_Auf_EM_Anlegen               : 444 // Auftrags-Einsatzmaterial anlegen
  Rgt_Auf_EM_Einfuegen             : 445 // Auftrags-Einsatzmaterial einfügen
  Rgt_Auf_EM_Loeschen              : 446 // Auftrags-Einsatzmaterial löschen
  Rgt_Skizzen                      : 447 // Skizzen
  Rgt_Skz_Anlegen                  : 448 // Skizzen anlegen
  Rgt_Skz_Aendern                  : 449 // Skizzen ändern
  Rgt_Skz_Loeschen                 : 450 // Skizzen löschen
  Rgt_Rabatte                      : 451 // Rabatte
  Rgt_Rab_Anlegen                  : 452 // Rabatte anlegen
  Rgt_Rab_Aendern                  : 453 // Rabatte ändern
  Rgt_Rab_Loeschen                 : 454 // Rabatte löschen
  Rgt_Art_P_AUTO_edit              : 455 // Artikel-Preise Letzter/Durchschnitt ändern
  Rgt_OSt                          : 456 // Menüpunkt Onlinestatistik
  Rgt_Art_SL                       : 457 // Artikel-Stückliste
  Rgt_Art_SL_Anlegen               : 458 // Artikel-Stückliste anlegen
  Rgt_Art_SL_Aendern               : 459 // Artikel-Stückliste ändern
  Rgt_Art_SL_Loeschen              : 460 // Artikel-Stückliste löschen
  Rgt_Mat_Reservierung             : 461 // Materialreservierung
  Rgt_Mat_R_Anlegen                : 462 // Materialreservierung anlegen
  Rgt_Mat_R_Aendern                : 463 // Materialreservierung ändern
  Rgt_Mat_R_Loeschen               : 464 // Materialreservierung löschen
  Rgt_Adr_Verpackungen             : 465 // Adressen-Verpackungen
  Rgt_Adr_V_Anlegen                : 466 // Adressen-Verpackung anlegen
  Rgt_Adr_V_Aendern                : 467 // Adressen-Verpackung ändern
  Rgt_Adr_V_Loeschen               : 468 // Adressen-Verpackung löschen
  Rgt_Materialstruktur             : 469 // Materialstrukturliste
  Rgt_Msl_Anlegen                  : 470 // Materialstrukturliste anlegen
  Rgt_Msl_Aendern                  : 471 // Materialstrukturliste ändern
  Rgt_Msl_Loeschen                 : 472 // Materialstrukturliste löschen
  Rgt_Materialanalyse              : 473 // Analysen
  Rgt_Lys_Anlegen                  : 474 // Analysen anlegen
  Rgt_Lys_Aendern                  : 475 // Analysen ändern
  Rgt_Lys_Loeschen                 : 476 // Analysen löschen
  Rgt_Termine_Berichte             : 477 // Aktivitäten Berichte
  Rgt_TeM_B_Anlegen                : 478 // Aktivitäten Berichte anlegen
  Rgt_TeM_B_Aendern                : 479 // Aktivitäten Berichte ändern
  Rgt_TeM_B_Loeschen               : 480 // Aktivitäten Berichte löschen
  Rgt_OSt_Kunde                    : 481 // Onlinestatistik-Kunde
  Rgt_OSt_Artikel                  : 482 // Onlinestatistik-Artikel
  Rgt_OSt_AGr                      : 483 // Onlinestatistik-Artikelgruppe
  Rgt_OSt_WGr                      : 484 // Onlinestatistik-Warengruppe
  Rgt_OSt_Vertreter                : 485 // Onlinestatistik-Vertreter
  Rgt_OSt_Verband                  : 486 // Onlinestatistik-Verband
  Rgt_OSt_Unternehmen              : 487 // Onlinestatistik-Unternehmen
  Rgt_Adr_Serienedit               : 488 // Adressen Serienänderung
  Rgt_Art_Serienedit               : 489 // Artikel Serienänderung
  Rgt_Art_Excel_Export             : 490 // Artikel Excel-Export
  Rgt_Art_Excel_Import             : 491 // Artikel Excel-Import
  Rgt_Adr_Excel_Export             : 492 // Adresse Excel-Export
  Rgt_Adr_Excel_Import             : 493 // Adresse Excel-Import
  Rgt_Prj_WartungsAuf              : 494 // Projekt in Wartungsauftrag wandeln
  Rgt_Laender                      : 495 // Länder
  Rgt_Lnd_Anlegen                  : 496 // Länder anlegen
  Rgt_Lnd_Aendern                  : 497 // Länder ändern
  Rgt_Lnd_Loeschen                 : 498 // Länder löschen
  Rgt_Steuerschluessel             : 499 // Steuerschlüssel
  Rgt_StS_Anlegen                  : 500 // Steuerschlüssel anlegen
  Rgt_StS_Aendern                  : 501 // Steuerschlüssel ändern
  Rgt_Sts_Loeschen                 : 502 // Steuerschlüssel löschen
  Rgt_Waehrungen                   : 503 // Währungen
  Rgt_Wae_Anlegen                  : 504 // Währungen anlegen
  Rgt_Wae_Aendern                  : 505 // Währungen ändern
  Rgt_Wae_Loeschen                 : 506 // Währungen löschen
  Rgt_Auf_Fahrauftrag              : 507 // Auftrag: Fahrauftrag anlegen

  Rgt_BA_Abschluss                 : 508 // BA-Abschluss
  Rgt_BA_Fertigmelden              : 509 // BA fertigmelden

  Rgt_LFS_Druck_Freistell          : 510 // Lieferschein: Druck Freistellung

  Rgt_Anhaenge                     : 511 // Anhänge
  Rgt_Anh_Anlegen                  : 512 // Anhänge anlegen
  Rgt_Anh_Aendern                  : 513 // Anhänge ändern
  Rgt_Anh_Loeschen                 : 514 // Anhänge löschen

  Rgt_OSt_Aendern                  : 515 // Onlinestatistik ändern

  Rgt_Auf_A_Aendern2               : 516 // Auftragsaktion ändern (verbuchte)

  Rgt_Abl_Auf_Reorg                : 517 // Ablage: Aufträge Reorganisation
  Rgt_Abl_OfP_Reorg                : 518 // Ablage: Offene Posten Reorganisation

  Rgt_Grobplanung                  : 519 // Grobplanung
  Rgt_GPl_Anlegen                  : 520 // Grobplanung anlegen
  Rgt_GPl_Aendern                  : 521 // Grobplanung ändern
  Rgt_GPl_Loeschen                 : 522 // Grobplanung löschen

  Rgt_Auf_Gut_DFakt                : 523 // Auftrag: Gutschrift fakturieren

  Rgt_Einst_Skripte                : 524 // Einstellungen - Skripte

  Rgt_Betrieb_EtkDruck             : 525 // Betrieb: Etikettendruck
  Rgt_Betrieb_Liefersch            : 526 // Betrieb: Lieferscheinerfassung
  Rgt_Betrieb_Wareneing            : 527 // Betrieb: Wareneingang
  Rgt_Betrieb_Umlagern             : 528 // Betrieb: Umlagern

  Rgt_Adr_Scripte                  : 529 // Adressen-Scripte

  Rgt_Kalkulationen                : 530 // Kalkulation
  Rgt_Kal_Anlegen                  : 531 // Kalkulation anlegen
  Rgt_Kal_Aendern                  : 532 // Kalkulation ändern
  Rgt_Kal_Loeschen                 : 533 // Kalkulation löschen

  Rgt_Auf_A_Storno                 : 534 // Auftragsaktion: stornieren

  Rgt_Dickentoleranz               : 535 // Dickentoleranzen
  Rgt_Tol_D_Anlegen                : 536 // Dickentoleranzen anlegen
  Rgt_Tol_D_Aendern                : 537 // Dickentoleranzen ändern
  Rgt_Tol_D_Loeschen               : 538 // Dickentoleranzen löschen

  Rgt_SammelWE                     : 539 // Sammelwareneingänge
  Rgt_SWe_Anlegen                  : 540 // Sammelwareneingänge anlegen
  Rgt_SWe_Aendern                  : 541 // Sammelwareneingänge ändern
  Rgt_SWe_Loeschen                 : 542 // Sammelwareneingänge löschen

  Rgt_Prj_Positionen               : 543 // Projektpositionen
  Rgt_Prj_P_Anlegen                : 544 // Projektposition anlegen
  Rgt_Prj_P_Aendern                : 545 // Projektpositionen ändern
  Rgt_Prj_P_Loeschen               : 546 // Projektpositionen löschen

  Rgt_PrjZeiten                    : 547 // Zeiten
  Rgt_Prj_Z_Anlegen                : 548 // Zeiten anlegen
  Rgt_Prj_Z_Aendern                : 549 // Zeiten ändern
  Rgt_Prj_Z_Loeschen               : 550 // Zeiten löschen

  Rgt_BAG_FM                       : 551 // Betriebsauftrag-Fertigmeldung
  Rgt_BAG_FM_Anlegen               : 552 // Betriebsauftrag-Fertigmeldung anlegen
  Rgt_BAG_FM_Aendern               : 553 // Betriebsauftrag-Fertigmeldung ändern
  Rgt_BAG_Del_NachAbschluss        : 554 // Betriebsauftrag-Fertigmeldung löschen nach Abschluss

  Rgt_EK_E_VSB2WE                  : 555 // Einkaufswareneingang aus VSB anlegen

  Rgt_Prj_Wartung                  : 556 // Projekt-Wartung

  Rgt_DiB                          : 557 // Dispobestand
  Rgt_DiB_Aendern                  : 558 // Dispobestand ändern

  Rgt_Pakete                       : 559 // Pakete
  Rgt_Pak_Anlegen                  : 560 // Pakete anlegen
  Rgt_Pak_Aendern                  : 561 // Pakete ändern
  Rgt_Pak_Loeschen                 : 562 // Pakete löschen

  Rgt_Pak_Positionen               : 563 // Paket Positionen
  Rgt_Pak_P_Anlegen                : 564 // Paket Positionen anlegen
  Rgt_Pak_P_Aendern                : 565 // Paket Positionen ändern
  Rgt_Pak_P_Loeschen               : 566 // Paket Positionen löschen

  Rgt_Orte                         : 567 // Orte
  Rgt_Ort_Anlegen                  : 568 // Orte anlegen
  Rgt_Ort_Aendern                  : 569 // Orte ändern
  Rgt_Ort_Loeschen                 : 570 // Orte löschen

  Rgt_Auf_Bel_DFakt                : 571 // Auftrag: Belastung fakturieren

  Rgt_EK_LiefTauschen              : 572 // Einkauf: Lieferant austauschen

  Rgt_LFS_Druck_WZ                 : 573 // Lieferschein: Druck Werkszeugnis
  Rgt_LFS_Druck_LNW                : 574 // Lieferschein: Druck Liefernachweiß

  Rgt_Mat_Druck_WZ                 : 575 // Material: Druck Werkszeugnis

  Rgt_Rso_Kalendertage             : 576 // Ressourcen-Kalendertage
  Rgt_Rso_KalTag_Anlegen           : 577 // Ressourcen-Kalendertag anlegen
  Rgt_Rso_KalTag_Aendern           : 578 // Ressourcen-Kalendertag ändern
  Rgt_Rso_KalTag_Loeschen          : 579 // Ressourcen-Kalendertag löschen

  Rgt_BAG_Planung                  : 580 // Betriebsaufträge Feinplanung

  Rgt_LFS_Druck_VSB                : 581 // Lieferschein: Druck VSB-Meldung

  Rgt_Zei_Vorkasse                 : 582 // Zahlungseingang: Vorleistungen setzen

  Rgt_Auf_Druck_FM                 : 583 // Auftrag: Druck Fertigmeldung

  Rgt_Reklamationsarten            : 584 // Reklamationsarten
  Rgt_RekArt_Anlegen               : 585 // Reklamationsarten anlegen
  Rgt_RekArt_Aendern               : 586 // Reklamationsarten ändern
  Rgt_RekArt_Loeschen              : 587 // Reklamationsarten löschen

  Rgt_Zahlungsarten                : 588 // Zahlungsarten
  Rgt_ZhA_Anlegen                  : 589 // Zahlungsarten anlegen
  Rgt_ZhA_Aendern                  : 590 // Zahlungsarten ändern
  Rgt_ZhA_Loeschen                 : 591 // Zahlungsarten löschen

  Rgt_Vorgangsstatus               : 592 // Vorgangsstatus
  Rgt_Stt_Anlegen                  : 593 // Vorgangsstatus anlegen
  Rgt_Stt_Aendern                  : 594 // Vorgangsstatus ändern
  Rgt_Stt_Loeschen                 : 595 // Vorgangsstatus löschen

  Rgt_Fehlercodes                  : 596 // Fehlercodes
  Rgt_FhC_Anlegen                  : 597 // Fehlercodes anlegen
  Rgt_FhC_Aendern                  : 598 // Fehlercodes ändern
  Rgt_FhC_Loeschen                 : 599 // Fehlercodes löschen

  Rgt_Reklamationstexte            : 600 // Reklamationstexte
  Rgt_Rek8_Anlegen                 : 601 // Reklamationstexte anlegen
  Rgt_Rek8_Aendern                 : 602 // Reklamationstexte ändern
  Rgt_Rek8_Loeschen                : 603 // Reklamationstexte löschen

  Rgt_Rek_Positionen               : 604 // Reklamationspositionen
  Rgt_Rek_P_Anlegen                : 605 // Reklamationsposition anlegen
  Rgt_Rek_P_Aendern                : 606 // Reklamationsposition ändern
  Rgt_Rek_P_Loeschen               : 607 // Reklamationsposition löschen

  Rgt_Rek_Aktion                   : 608 // Reklamationsaktionen
  Rgt_Rek_A_Anlegen                : 609 // Reklamationsaktion anlegen
  Rgt_Rek_A_Aendern                : 610 // Reklamationsaktion ändern
  Rgt_Rek_A_Loeschen               : 611 // Reklamationsaktion löschen

  Rgt_Mat_Best_Aendern             : 612 // Material: Bestand ändern

  Rgt_ERe_Fibu                     : 613 // Eingangsrechnung: Fibu-Übergabe

  Rgt_Auf_P_Change_Artikel         : 614 // Auftragsposition: Artikel tauschen

  Rgt_Rechnungstypen               : 615 // Rechnungstypen
  Rgt_RTy_Anlegen                  : 616 // Rechnungstypen anlegen
  Rgt_RTy_Aendern                  : 617 // Rechnungstypen ändern
  Rgt_RTy_Loeschen                 : 618 // Rechnungstypen löschen

  Rgt_ZAu_Druck_Avis               : 619 // Zahlungsausgang: Druck Avis

  Rgt_Betrieb_Material             : 620 // Betrieb: Lagerübersicht
  Rgt_Betrieb_Fertigmelden         : 621 // Betrieb: BA fertigmelden

  Rgt_Abl_Mat_Reorg                : 622 // Ablage: Material Reorganisation
  Rgt_Abl_Bdf_Reorg                : 623 // Ablage: Bedarf Reorganisation
  Rgt_Abl_Mat_Restore              : 624 // Ablage: Material Wiederherstellung
  Rgt_Abl_Auf_Restore              : 625 // Ablage: Aufträge Wiederherstellung
  Rgt_Abl_OfP_Restore              : 626 // Ablage: Offene Posten Wiederherstellung
  Rgt_Abl_Ein_Restore              : 627 // Ablage: Bestellungen Wiederherstellung
  Rgt_Abl_Bdf_Restore              : 628 // Ablage: Bedarf Wiederherstellung

  Rgt_ZAu_Druck_Scheck             : 629 // Zahlungsausgang: Druck Scheck

  Rgt_Adr_Change_Stichwort         : 630 // Adressen ändern (Stichwort)
  Rgt_Adr_Change_Kundennr          : 631 // Adressen ändern (Kundennummer)
  Rgt_Adr_Change_Lieferantennr     : 632 // Adressen ändern (Lieferantennr)

  Rgt_Ein_P_Change_Artikel         : 633 // Einkaufsposition: Artikel tauschen

  Rgt_Auf_Change_Kundennr          : 634 // Auftrag: ändern Kundennummer
  Rgt_Auf_Change_Rechnungsempf     : 635 // Auftrag: ändern Rechnungsempfänger

  Rgt_Gegenkonten                  : 636 // Gegenkonten
  Rgt_GKo_Anlegen                  : 637 // Gegenkonten anlegen
  Rgt_GKo_Aendern                  : 638 // Gegenkonten ändern
  Rgt_GKo_Loeschen                 : 639 // Gegenkonten löschen

  Rgt_Mat_Neubewerten              : 640 // Material: neu bewerten
  Rgt_Obf_Change_Kuerzel           : 641 // Oberflächen: ändern Kürzel

  // ---- 2009-04-08 TM ----
  Rgt_Db_Updates                   : 642 // Datenbank Auf Updates Prüfen
  Rgt_Db_Historie                  : 643 // Datenbank Versionshistorie
  Rgt_Ex_Importe                   : 644 // Extras Datenimporte
  Rgt_Mat_Kommission               : 645 // Material: Kommission ändern
  Rgt_Auf_Mat_DFakt                : 646 // Auftrag: Material direkt fakturieren
  Rgt_Auf_Liefersch                : 647 // Auftrag: Lieferschein
  // ---- 2009-04-08 TM ----

  Rgt_OSt_Recalc                   : 648 // Erlöse: Statistik neu aufbauen

  Rgt_Zeittypen                    : 649 // Zeittypen
  Rgt_ZTy_Anlegen                  : 650 // Zeittypen anlegen
  Rgt_ZTy_Aendern                  : 651 // Zeittypen ändern
  Rgt_ZTy_Loeschen                 : 652 // Zeittypen löschen

  Rgt_BAG_Z_Anlegen                : 653 // BA Zeiteintrag anlegen
  Rgt_BAG_Z_Loeschen               : 654 // BA Zeiteintrag löschen

  Rgt_BAG_FM_Netto                 : 655 // Betriebsauftrag-Fertigmeldung: Nettoverwiegung
  Rgt_BAG_FM_Brutto                : 656 // Betriebsauftrag-Fertigmeldung: Bruttoverwiegung

  Rgt_Mat_EKPreise                 : 657 // Material: EK-Preise
  Rgt_Mat_EigenJN                  : 658 // Material: Eigenmaterial J/N

  Rgt_Adr_Info                     : 659 // Adressen-Info
  Rgt_Adr_Info_Auftrag             : 660 // Adressen-Info: Aufträge
  Rgt_Adr_Info_Aktionen            : 661 // Adressen-Info: Aktionen
  Rgt_Adr_Info_Umsatz              : 662 // Adressen-Info: Umsatz
  Rgt_Adr_Info_Erloes              : 663 // Adressen-Info: Erlöse
  Rgt_Adr_Info_Bestellung          : 664 // Adressen-Info: Bestellungen
  Rgt_Adr_Info_Verbindlichk        : 665 // Adressen-Info: Verbindlichkeiten
  Rgt_Adr_Info_Eingangsrech        : 666 // Adressen-Info: Eingangsrechnungen
  Rgt_Adr_Info_Termine             : 667 // Adressen-Info: Termine
  Rgt_Adr_Info_Protokoll           : 668 // Adressen-Info: Protokoll
  Rgt_Adr_Listen                   : 669 // Adressen-Listen

  Rgt_Adr_SperrKundeYN             : 670 // Adressen Kunde sperren
  Rgt_Adr_SperrLieferantYN         : 671 // Adressen Lieferant sperren

  Rgt_Lpl_InvTransfer              : 672 // Lagerplätze: Scannerdatei übertragen
  Rgt_Lpl_InvImport                : 673 // Lagerplätze: Scannerdatei importieren
  Rgt_Lpl_InvDelete                : 674 // Lagerplätze: vorherige Inventur löschen
  Rgt_Lpl_InvVerbuchen             : 675 // Lagerplätze: Inventur verbuchen

  Rgt_Versand                      : 676 // Versand
  Rgt_Vsd_Anlegen                  : 677 // Versand anlegen
  Rgt_Vsd_Aendern                  : 678 // Versand ändern
  Rgt_Vsd_Loeschen                 : 679 // Versand löschen

  Rgt_Versandpool                  : 680 // Versandpool
  Rgt_VsP_Anlegen                  : 681 // Versandpool anlegen
  Rgt_VsP_Aendern                  : 682 // Versandpool ändern
  Rgt_VsP_Loeschen                 : 683 // Versandpool löschen

  Rgt_BAG_Z_Edit                   : 684 // BA Zeiteintrag bearbeiten

  Rgt_BAG_FM_AF                    : 685 // Betriebsauftrag-Fertigmeldung: Ausführung angeben
  Rgt_BAG_FM_ABM_D                 : 686 // Betriebsauftrag-Fertigmeldung: Dicke angeben
  Rgt_BAG_FM_ABM_B                 : 687 // Betriebsauftrag-Fertigmeldung: Breite angeben
  Rgt_BAG_FM_ABM_L                 : 688 // Betriebsauftrag-Fertigmeldung: Länge angeben

  Rgt_Mat_Excel_Export             : 689 // Material Excel-Export

  Rgt_Mat_Lieferant                : 690 // Material: Lieferant sichtbar

  Rgt_Auf_MATZ_Konf_Abm            : 691 // Auftrag: Material zuordnen trotz Abmessungskonflikt

  Rgt_Mat_Kombinieren              : 692 // Material: Karte kombinieren

  Rgt_VSD_Verbuchen                : 693 // Versand verbuchen

  Rgt_Fin_Mat_LagerFremd            : 694 // Lagergeld-Fremd buchen
  Rgt_Fin_Mat_LagerKunde            : 695 // Lagergeld-Kunde buchen
  Rgt_Fin_Mat_Zinsen                : 696 // Zinsen buchen

  Rgt_Betrieb_abschliessen          : 697 // Betrieb: BA abschließen
  Rgt_Betrieb_Etk_Dialog            : 698 // Betrieb: BA Etiketten ändern
  Rgt_Etk_Anzahl                    : 699 // Etikettenanzahl ändern

  Rgt_Workflow_Schema               : 700 // Workflow-Schemata
  Rgt_WoF_Sch_Anlegen               : 701 // Workflow-Schemata anlegen
  Rgt_WoF_Sch_Aendern               : 702 // Workflow-Schemata ändern
  Rgt_Wof_Sch_Loeschen              : 703 // Workflow-Schemata löschen

  Rgt_Workflow                      : 704 // Workflow Zuordnungen

  Rgt_Vsa_Druck_LFA                 : 705 // Versandplanung: Druck Fahrauftrag
  Rgt_Vsa_Druck_Frachtbrief         : 706 // Versandplanung: Druck Frachtbrief
  Rgt_Vsa_Druck_LFS                 : 707 // Versandplanung: Druck Lieferschein

  Rgt_Art_Inventur                  : 708 // Artikel: Inventur

  Rgt_Controlling                   : 709 // Controlling
  Rgt_CON_Anlegen                   : 710 // Controlling anlegen
  Rgt_CON_Aendern                   : 711 // Controlling ändern
  Rgt_CON_Loeschen                  : 712 // Controlling löschen

  Rgt_BAG_FM_Tara                   : 713 // Tara bearbeiten

  Rgt_Art_Inv_Anlegen               : 714 // Inventur anlegen
  Rgt_Art_Inv_Aendern               : 715 // Inventur ändern
  Rgt_Art_Inv_Loeschen              : 716 // Inventur löschen
  Rgt_Art_Inv_Uebernahme            : 717 // Inventurübernahme

  Rgt_Auf_Versandpool               : 718 // Auftrag: theoretischen Versand beauftragen
  Rgt_BAG_Del_VorAbschluss          : 719 // Betriebsauftrag-Fertigmeldung löschen vor Abschluss

  Rgt_Einst_Servicedaten            : 720 // Einstellungen - Servicedaten
  Rgt_Einst_Protokoll               : 721 // Einstellungen - Protokoll

  Rgt_XML_Datenimporte              : 722 // XML Datenimporte

  Rgt_Erl_Abschlussdatum            : 723 // Erlöse: Abschlussdatum setzen

  Rgt_EK_E_Versandpool              : 724 // Einkaufswareneingang: an Versandpool übergeben
  Rgt_Mat_Versandpool               : 725 // Material: an Versandpool übergeben

  Rgt_BAG_P_Restore                 : 726 // Betriebsauftrag: Abschluss rückgängig machen

  Rgt_Betrieb_VW_Storno             : 727 // Betrieb: BA Verwiegung stornieren
  Rgt_Betrieb_LFS_Erfassung         : 728 // Betrieb: Lieferschein Erfassung

  Rgt_Serienedit                    : 729 // Serienänderung

  Rgt_Pflichtfelder_Anlegen         : 730 // Dialoge: Pflichtfelder anlegen
  Rgt_Pflichtfelder_Loeschen        : 731 // Dialoge: Pflichtfelder löschen
  Rgt_Pflichtfelder_Aendern         : 732 // Dialoge: Pflichtfelder ändern

  Rgt_Artikel_Zustaende             : 733 // Artikel-Zustände
  Rgt_Art_Zst_Anlegen               : 734 // Artikel-Zustände anlegen
  Rgt_Art_Zst_Aendern               : 735 // Artikel-Zustände ändern
  Rgt_Art_Zst_Loeschen              : 736 // Artikel-Zustände löschen

  Rgt_Betrieb_Waage_Netto           : 737 // Betrieb: Netto-Verwiegung
  Rgt_Betrieb_Ressourcen            : 738 // Betrieb: Maschinenbelegung
  Rgt_Betrieb_BA_Edit               : 739 // Betrieb: BA Einsatz ändern

  Rgt_Auf_Auf2Verpackung            : 740 // Auftrag: Kd-Verp.Vorschrift erzeugen

  Rgt_LFS_InterneKosten             : 741 // Lieferschein: Interne Kosten

  Rgt_SOA_Serviceinventar           : 742 // SOA Serviceinventar
  Rgt_SOA_Inv_Anlegen               : 743 // SOA Service anlegen
  Rgt_SOA_Inv_Aendern               : 744 // SOA Service ändern
  Rgt_SOA_Inv_Loeschen              : 745 // SOA Service löschen
  Rgt_SOA_Inv_Protokoll             : 746 // SOA Serviceprotokoll ansehen

  Rgt_Auf_Preise                    : 747 // Auftrag: Preise sichtbar
  Rgt_Ein_Preise                    : 748 // Einkauf: Preise sichtbar

  Rgt_Auf_A_Sperre                  : 749 // Auftragsaktion: Sperre umsetzen
  Rgt_Ein_Kommission                : 750 // Einkauf: Kommission entfernen

  Rgt_LFS_Druck_Avis                : 751 // Lieferschein: Druck Lieferavisierung

  Rgt_Filescanpfade                 : 752 // Filescanpfade
  Rgt_FSP_Anlegen                   : 753 // Filescanpfade anlegen
  Rgt_FSP_Aendern                   : 754 // Filescanpfade ändern
  Rgt_FSP_Loeschen                  : 755 // Filescanpfade löschen

  Rgt_Art_SL_Recalc                 : 756 // Artikel: Stückliste aktualisieren

  Rgt_Art_manuellerWE               : 757 // Artikel: manueller Wareneingang
  Rgt_Art_manuellePRD               : 758 // Artikel: manuelle Produktion

  Rgt_Ein_A_Sperre                  : 759 // Einkaufsaktion: Sperre umsetzen

  Rgt_Print_EMail                   : 760 // Drucken: als Mail verschicken
  Rgt_Print_Druckerwechsel          : 761 // Drucken: anderen Drucker wählen
  Rgt_Print_Outlook                 : 762 // Drucken: als Outlook-Mail verschicken
  Rgt_Print_FAX                     : 763 // Drucken: als Fax versenden
  Rgt_Print_PDF                     : 764 // Drucken: als PDF speichern

  Rgt_Mat_R_Reorg                   : 765 // Materialreservierung: alle abgelaufene löschen

  Rgt_Auf_P_PEH_Edit                : 766 // Auftragsposition: Editieren PEH
  Rgt_Ein_P_PEH_Edit                : 767 // Einkaufsposition: Editieren PEH

  Rgt_Betrieb_LFS_ErfassungVLDAW    : 768 // Betriebsmenü: Lieferscheinerfassung über Verladeanweisung
  Rgt_Betrieb_Pak_Material          : 769 // Betriebsmenü: Bundverpackung von Materialien

  Rgt_Auf_Protokoll                 : 770 // Auftrag: Protokoll
  Rgt_Ein_Protokoll                 : 771 // Einkauf: Protokoll

  Rgt_Adr_Info_Verkaeufe            : 772 // Adressen-Info: Verkäufe

  Rgt_OSt_AAr                       : 773 // Onlinestatistik-Auftragsart

  Rgt_Mat_Excel_Import              : 774 // Material Excel-Import

  Rgt_Schluesseldaten_Export        : 775 // Schlüsseldaten Export
  Rgt_Schluesseldaten_Import        : 776 // Schlüsseldaten Import


  Rgt_BAG_FM_Struktur              : 777 // Betriebsauftrag-Fertigmeldung: Struktur-/ArtikelNr. angeben
  Rgt_BAG_FM_VerwiegArt            : 778 // Betriebsauftrag-Fertigmeldung: Verwiegungsart angeben
  Rgt_BAG_FM_NB_Mess               : 779 // Betriebsauftrag-Fertigmeldung: Reiter Messwerte freigeben
  Rgt_BAG_FM_NB_Analyse            : 780 // Betriebsauftrag-Fertigmeldung: Reiter Analyse freigeben
  Rgt_BAG_FM_NB_Fehler             : 781 // Betriebsauftrag-Fertigmeldung: Reiter Fehler freigeben
  Rgt_BAG_FM_NB_Beistell           : 782 // Betriebsauftrag-Fertigmeldung: Reiter Beistellungen freigeben

  Rgt_Kasse                        : 783 // Kasse
  Rgt_Kas_Anlegen                  : 784 // Kasse anlegen
  Rgt_Kas_Aendern                  : 785 // Kasse ändern
  Rgt_Kas_Loeschen                 : 786 // Kasse löschen
  Rgt_Kassenbuch                   : 787 // Kassenbuch
  Rgt_Kas_B_Anlegen                : 788 // Kassenbuch anlegen
  Rgt_Kas_B_Aendern                : 789 // Kassenbuch ändern
  Rgt_Kas_B_Loeschen               : 790 // Kassenbuch löschen

  Rgt_Einst_Help                   : 791 // Einstellungen - Hilfedateien

  Rgt_Betrieb_Zeiten               : 792 // Betriebsmenü: Produktionszeiten verwalten

  Rgt_Msl_Excel_Export             : 793 // Materialstrukturliste Excel-Export
  Rgt_Msl_Excel_Import             : 794 // Materialstrukturliste Excel-Import

  Rgt_Faktura_ReDatum              : 795 // Auftrag: Druck Rechnung - Rechnungsdatum ändern

  Rgt_LfErklaerungen               : 796 // Lieferantenerklärungen
  Rgt_LfE_Anlegen                  : 797 // Lieferantenerklärungen anlegen
  Rgt_LfE_Aendern                  : 798 // Lieferantenerklärungen ändern
  Rgt_LfE_Loeschen                 : 799 // Lieferantenerklärungen löschen

  Rgt_LFS_Druck_LfE                : 800 // Lieferschein: Druck Lieferantenerklärung
  Rgt_Adr_Dok_Struktur             : 801 // Adress-Dokument-Struktur

  Rgt_Lfs_Change_Ziel              : 802 // Lieferschein: ändern Ziel

  Rgt_LFS_Daten_Export             : 803 // Lieferschein Daten-Export
  Rgt_LFS_Daten_Import             : 804 // Lieferschein Daten-Import

  Rgt_Art_Recalc                   : 805 // Artikel: Mengen neu summieren

  Rgt_Auf_Excel_Export             : 806 // Auftrag Excel-Export
  Rgt_Auf_Excel_Import             : 807 // Auftrag Excel-Import

  Rgt_Ein_Excel_Export             : 808 // Einkauf Excel-Export
  Rgt_Ein_Excel_Import             : 809 // Einkauf Excel-Import

  Rgt_Art_Aendern_Fuehrung         : 810 // Artikel ändern - Bestandsführungen

  Rgt_Mat_Filter                   : 811 // Material: Filtern

  Rgt_Betrieb_LFS_VLDAW_Freigabe  :  812 // Betriebsmenü: Lieferschein/VLDAW manuelle Freigabe

  Rgt_Kostenbuchung                : 813 // Kostenbuchung
  Rgt_Kos_Anlegen                  : 814 // Kostenbuchung anlegen
  Rgt_Kos_Aendern                  : 815 // Kostenbuchung ändern
  Rgt_Kos_Loeschen                 : 816 // Kostenbuchung löschen

  Rgt_Kos_Serienedit               : 817 // Kostenbuchung Serienänderung
  Rgt_Mat_Serienedit               : 818 // Material Serienänderung

  Rgt_Auf_Zbd_Aendern              : 819 // Auftrag: Fixierte Zahlungsbed. ändern

  Rgt_Kos_Excel_Export             : 820 // Kosten Excel-Export
  Rgt_Kos_Excel_Import             : 821 // Kosten Excel-Import

  Rgt_Mat_ToggleInvFlag            : 822 // Material: Inventurdruckhaken umsetzen

  Rgt_Adr_Text1_Aendern            : 823 // Adressen: Text1 ändern
  Rgt_Adr_Text2_Aendern            : 824 // Adressen: Text2 ändern
  Rgt_Adr_Text3_Aendern            : 825 // Adressen: Text3 ändern
  Rgt_Adr_Text4_Aendern            : 826 // Adressen: Text4 ändern
  Rgt_Adr_Text5_Aendern            : 827 // Adressen: Text5 ändern

  Rgt_LFS_Druck_LFA                : 828 // Lieferschein: Druck Lohnfahrauftrag

  Rgt_ERe_Excel_Export             : 829 // Eingangsrechnung Excel-Export
  Rgt_ERe_Excel_Import             : 830 // Eingangsrechnung Excel-Import

  Rgt_Ein_Ein2Verpackung            : 831 // Einkauf: Lf-Verp.Vorschrift erzeugen

  Rgt_Prj_Admin                    : 832 // Projekt-Admin

  Rgt_Termintypen                  : 833 // Termintypen
  Rgt_TTy_Anlegen                  : 834 // Termintyp anlegen
  Rgt_TTy_Aendern                  : 835 // Termintyp ändern
  Rgt_TTy_Loeschen                 : 836 // Termintyp löschen

  Rgt_BAG_Z_Kosten                 : 837 // BA Zeiteintrag Kosten

  Rgt_Dictionary                   : 838 // Dictionary

  Rgt_Lfs_Freigabe                 : 839 // Lieferschein: Freigabe

  Rgt_CuT                          : 840 // Customtabelle
  Rgt_CuT_Anlegen                  : 841 // Customtabelle anlegen
  Rgt_CuT_Aendern                  : 842 // Customtabelle ändern
  Rgt_CuT_Loeschen                 : 843 // Customtabelle löschen

  Rgt_VsP_Excel_Export             : 844 // Versandpool Excel-Export
  Rgt_VsP_Excel_Import             : 845 // Versandpool Excel-Import

  Rgt_Betrieb_Artikel              : 846 // Betrieb: Artikel
  
  Rgt_Dzo                           : 847 // Druckzonen
  Rgt_Dzo_Anlegen                   : 848 // Druckzonen anlegen
  Rgt_Dzo_Aendern                   : 849 // Druckzonen ändern
  Rgt_Dzo_Loeschen                  : 850 // Druckzonen löschen

  
  
  
  //Filter_Afx                       : y //Nur temporär SR/MR

end;

