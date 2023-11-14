@A+
/*===== Business-Control =================================================

Prozedur:   !Template2022

OHNE E_R_G

Info:
Welchen Zweck(en) dient die Prozedur? High-level Übersicht.

Historie:
2022-03-23  DS  Erstellung der Prozedur
2022-06-08  DS  High-Level Abriss dieser Änderung
2022-03-10  DS  Umstellung auf verbesserte/vereinfachte Version des neuen Fehlerausgabe-Konzepts
2023-06-20  DS  SFX.eineSonderfunktion erweitert mit neuem Fehlerausgabe-Konzept

Subprozeduren:

prozedurnameInCamelCase
__cleanup_fTemplate
fTemplate
__cleanup_fTemplateNested
fTemplateNested
__cleanup_fTemplateNesting
fTemplateNesting
_privateProzedur
AFX.eineAnkerfunktion
_backend_von_SFX.eineSonderfunktion
SFX.eineSonderfunktion

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================*/
@I:Def_Global
/*
WICHTIG!:
KEINE Includes außer Def_Global verwenden, und andere unvermeidliche
Includes (z.B. für Konstanten etc.).
Stattdessen Scoping nutzen, also z.B. Lib_Json:LoadJsonFromAlpha(vJsonString)
Gegenbeispiel:
Bitte nicht Lib_Json inkludieren um das "Lib_Json:" Präfix zu sparen!
Hintergrund: C16 kann Includes nicht auflösen zum Durchnavigieren
mittels CTRL + Doppelklick.
*/


/*========================================================================
Defines
========================================================================*/
define begin
  cName     : 'Wert der Konstante'  // Wozu dient dieses define?
  
  /*
  Alle in einer Prozedur verwendeten Dialoge sind als defines zu nennen und
  innerhalb der Prozedur über das define und nicht den Klarnamen anzusprechen.
  Bsp.: vDlg # Lib_GuiCom:AddChildWindow(gMDI, cDlgSearch, '');
  Vorteile:
  * Wenn ein Dialog umbenannt wird, muss man nur eine Stelle ändern.
  * Man kann leichter die Dialoge zum Prozedurcode finden und umgekehrt.
  */
  cDlgSearch : 'SFX.EcoDMS.Search'

end


/*========================================================================
2022-03-23  DS                                               1234/20/1

Wozu dient die Subprozedur? High-Level Abriss über Inputs, Output
und Einsatz-Szenarien. Was muss ich als Aufrufer wissen?
========================================================================*/
sub prozedurnameInCamelCase
(
  aString : alpha(256);                // Was ist die Rolle des Arguments?
) : alpha                                // Was sagt der Rückgabewert aus?
local begin
  Erx         : int;
  vReturn     : alpha(512);
end
begin
  vReturn # 'hallo ' + aString + '!';
  return vReturn;
end


/*========================================================================
2022-11-02  DS                                               1234/20/1

* Cleanup-Funktion zu fTemplate
* Name besteht immer aus '__cleanup_' + funktionsName für die aufgeräumt wird
* Bündelt sämtlichen Code, der an (potentiell zahlreichen) fehlschlagenden
  Stellen ausgeführt werden muss (z.b. jedes Mal wenn fTemplate einen
  nicht erwarteten Erx Wert aus einer von ihr gerufenen anderen Funktion
  erhält)
* Vermeidet damit unnötige Schreibarbeit
* Mehr Info: siehe Beispiel in fTemplate
========================================================================*/
sub __cleanup_fTemplate(
  aParam1 : logic;   // Parameter können den cleanup Aufruf konfigurierbar machen, falls erforderlich
  aParam2 : logic;   // ...
) // kein Rückgabewert
local begin
  vLocal : int;
end
begin
  // bei Transaktionen: frühestmöglich
  //TRANSBRK;
end


/*========================================================================
2022-11-02  DS                                               1234/20/1

Wozu dient die Subprozedur? High-Level Abriss über Inputs, Output
und Einsatz-Szenarien. Was muss ich als Aufrufer wissen?

Dies ist ein Template für jede Art von Funktion, die einen Erx Wert
zurückgibt. Gemäß unseren Überlegungen in
http://vm_tfs:8080/tfs/DefaultCollection/Dokumente/_git/BCS?path=%2FCodinghandbuch%2Ffehlerbehandlung.md&version=GBmaster&_a=preview
sollte jede Funktion in der ein Fehler auftreten kann einen Erx Wert
zurückgeben. Das beinhaltet insb. Funktionen mit...
* ...Datenoperationen (RecRead...)
* ...Aufrufen an andere Erx-zurückgebende Funktionen
* ...anderem Code der fehlschlagen kann (Dateien öffnen, durch ein Argument teilen etc.)
* ...Verwendung externer Software, z.B. Web APIs die aufgerufen werden, wobei wiederum
     Fehler zurückgegeben/entstehen können.
Die Funktion demonstriert wie wir Argumente strukturieren und wie wir
Fehler behandeln.
Ziel ist es, ein wiederholbares Schema zu etablieren, das u.A. den
Einstieg in Fremdcode erleichtert, und über die Jahre etablierte
best practices aus der C16 Programmierung zu verwenden.
========================================================================*/
sub fTemplate(
  // Pflicht-Argument:
  Verbosity   : int;    // Pflicht-Argument: siehe Lib_Error:_complain
  // Eigene Argumente:...
  buf123      : handle; // ...als erstes kommen ALLE innerhalb der Fkt als geladen angenommene Tabellen in Form von RecBuffern, die auf den als geladen angenommenen Datensatz zeigen.
                        //    Alle Variablen dieser Art heißen buf, gefolgt von der Tabellennummer. So sieht der Aufrufer von fTemplate auf den ersten Blick welche Daten er laden muss,
                        //    damit fTemplate korrekt arbeitet (in diesem Beispiel nur Tabelle 123).
                        //    Der Aufrufer weiß dann auch, dass er dazu verpflichtet ist, vor Aufruf von fTemplate den richtigen Datensatz der Tabelle zu laden,
                        //    UND ZWAR IN DEN BUFFER!;
  var outArg1 : alpha;  // ...es folgen "var out*" für eine beliebige Anzahl an Ausgaben (denn da immer ein Erx zurückgegeben wird, kann Ausgabe nur über diese erfolgen);
  aArg2       : int;    // ...dann folgen normale "a*" Argumente, wie gehabt;
  opt optArg3 : logic;  // ...und zuletzt optionale Argumente als "opt opt*" Argumente;
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  vSomeLocalVar : int;
end
begin

  // Beispiel Datenoperation:
  //Erx # RecRead(...);
  // zur Demonstration, Erx selbst auf Fehler setzen:
  Erx # _ErrRange;
  
  // Fehlerprüfungen und -behandlungen haben immer Schachtelungstiefe 1 und enden mit return eines Erx-Wertes.
  // Insbesondere gibt es keinen else Block, denn das return macht qausi den Rest des Codes zum else Block.
  // So vermeiden wir tief verschachtelten, unübersichtlichen Spagehtti-Code und "Lemming-Treppen" die nur aus "end"s bestehen
  if Erx <> _ErrOK then
  begin
    // Der "Dreiklang" zur Fehlerbehandlung:
    // 1. Immer als erstes die zugehörige __cleanup_* Funktion aufrufen (vor Ausgaben, damit TRANSBRK frühestmöglich durchgeführt wird)
    __cleanup_fTemplate(true, false);
    
    // 2. Ausgabe des Fehlers per complain Makro
    Erm # 'Freier Fehlertext: Hier beschreibt der Programmierer für einen normalen Nutzer (!), was schief gelaufen ist.' + cCrlf2 +
      'Die für Entwickler relevante Information wird automatisch gesammelt und nur für Entwickler angezeigt.';
    complain(Verbosity, Erm); // entweder erhaltene Verbosity reinreichen, oder z.B. Konstante übergeben um es nicht dem Aufrufer zu überlassen
    
    // 3. Erx zurückgeben:
    //    * bei C16 Fehlern, Original-Erx rausreichen
    //    * bei Nicht-C16 Fehlern im STD, cErxSTD rausreichen
    //    * bei Nicht-C16 Fehlern in SFX/AFX, cErxSFX rausreichen
    return Erx;
  end
  
end


/*========================================================================
2022-11-04  DS                                               1234/20/1

siehe fTemplateNesting.
========================================================================*/
sub __cleanup_fTemplateNested() begin end

sub fTemplateNested(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:...
  // keine, da Minimal-Beispiel
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  vMyOperationFailed : logic;
end
begin

  // angenommen, ich frage hier eine Webschnittstelle ab, und etwas läuft schief,
  // oder irgendwelcher anderer Code schlägt fehl:
  vMyOperationFailed # true;
  
  // Resultate des eigenen Code in terms of Erx auswerten.
  // Erx MUSS UNBEDINGT vor complain Makro gesetzt werden, damit dieses den echten Erx Wert mitbekommt!
  if vMyOperationFailed then
  begin
    // da der Fehlschlag nicht aus einer C16-built-in Funktion stammt, und da wir hier im STD sind, handelt es sich um einen Fehler im SC STD:
    Erx # cErxSTD;
  end
  
  // Prüfe auf Fehler
  if Erx <> _ErrOK then
  begin
    
    __cleanup_fTemplateNested();
    
    Erm # 'Hier beschwert sich die verschachtelt aufgerufene Funktion fTemplateNested über einen in ihrem Kontext aufgetretenen Fehler.';
    complain(Verbosity, Erm); // entweder erhaltene Verbosity reinreichen, oder z.B. Konstante übergeben um es nicht dem Aufrufer zu überlassen
    
    return Erx;
  end
  
end


/*========================================================================
2022-11-04  DS                                               1234/20/1

fTemplateNesting demonstriert, wie eine andere Erx-liefernde Funktion,
(nämlich fTemplateNested), verschachtelt in fTemplateNesting aufgerufen
wird.

Dies demonstriert auch den error trace über den sich Entwickler
Fehler-Information aus den Tiefen des CallStacks beschaffen können.
========================================================================*/
sub __cleanup_fTemplateNesting() begin end

sub fTemplateNesting(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:...
  // keine, da Minimal-Beispiel
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  // keine, da Minimal-Beispiel
end
begin

  // nested Aufruf:
  Erx # fTemplateNested(Verbosity);
  
  if Erx <> _ErrOK then
  begin
    
    __cleanup_fTemplateNesting();
    
    Erm # 'Hier beschwert sich die rufende Funktion fTemplateNesting über einen von fTemplateNested erhaltenen Fehler.';
    complain(Verbosity, Erm); // entweder erhaltene Verbosity reinreichen, oder z.B. Konstante übergeben um es nicht dem Aufrufer zu überlassen
    
    // im nested Fall wird das erhaltene Erx rausgereicht, so dass immer das Erx des ersten Fehlers beim Aufrufer landet.
    return Erx;
  end
  
end


/*========================================================================
2022-06-08 DS                                               1234/20/1

"Private" Prozedur: Der underscore '_' zu Beginn des Prozedurnamens soll
andere Devs darauf hinweisen, dass diese Prozedur höchstwahrscheinlich
nur innerhalb dieser Prozedur von Nutzen ist und nicht für den Aufruf
aus externen Prozeduren bestimmt.
========================================================================*/
sub _privateProzedur
(
) : alpha
begin
  return 'Ich sollte nur innerhalb der Prozedur "' + __PROC__ + '" aufgerufen werden.';
end


/*========================================================================
2022-06-08  DS                                               1234/20/1


### todo ###
Hier fehlt noch ein Beispiel / Template Code für die korrekte Anwendung
des neuen Fehlerbehandlungs-Konzepts im Rahmen der AFX.
Bei Fragen DS fragen, oder an !Template2022:SFX.eineSonderfunktion
orientieren, denn dort gibt es schon ein Beispiel, allerdings für SFX.
Bei AFX funktioniert es analog zu SFX, mit dem Unterschied, dass AFX
  1. einen Rückgabewert haben und
  2. dieser eine AFX-spezifische Bedeutung hat.
### /todo ###

Doku:
Ankerfunktionen sind mit Präfix "AFX." zu kennzeichnen. Danach geht es
wie gewohnt in Camelcase weiter.

Im Funktionskopf ist zu erfassen, wie die Anker an der Aufrufstelle
heißen, also für welche Werte in der Spalte "Name" in der Tabelle
die man über

Vorgaben -> Einstellungen -> Individuell -> Ankerfunktionen

erreicht, diese Ankerfunktion in der Spalte "Prozedur" gesetzt werden
kann.
========================================================================*/
sub AFX.eineAnkerfunktion
(
  vAlpha : alpha(4096); // Anker die per RunAFX aufgerufen werden, müssen genau einen alpha entgegennehmen, siehe auch Beispiele in MAIN
) : int  // Anker die per RunAFX aufgerufen werden, müssen int zurückgeben, siehe auch Beispiele in MAIN
begin
  ErrSet(_rOK); // Anker müssen Fehlerwert vor return immer resetten
  return -200;
end





/*========================================================================
2023-06-20  DS                                               2436/407

simple DEMO backend Funktion zu SFX.eineSonderfunktion, die nicht
viel Aufregendes macht, aber strukturell aufgebaut ist wie eine echte
backend Funktion.

backend Funktionen dienen zur Trennung von frontend (GUI, Nutzerinteraktion)
und der eigentlichen (GUI-losen) Funktionalität des backends.
Das heisst backend Funktionen sollten...
...auch abseits der von SFXen bereitgestellten GUI aufgerufen werden können,
...keine GUI und keine Nutzerinteraktion aufweisen und
...jeweils einen abgeschlossenen Vorgang als Funktion implementieren.
========================================================================*/
sub _backend_von_SFX.eineSonderfunktion(
  // Pflicht-Argument:
  Verbosity   : int;
  // Eigene Argumente:
  var "outMat.Güte" : alpha;  // da backend-Funktionen keine GUI haben, haben stattdessen oft Ausgabe-Argumente um Dinge nach draußen zu liefern. In diesem Beispiel die Güte des Materials.
  aMat.Nummer : int;          // Diese Beispiel-backend-Funktion liefert zur übergebenen Material-Nummer dessen Güte im out-Argument
) : int // Pflicht-Ausgabe: Erx-ish
local begin
  // Pflicht-locals
  Erx     : int;          // lokales Erx für Ausgaben anderer Funktionen und Datenoperationen, siehe Lib_Error:_complain
  Erm     : alpha(4096);  // Fehlernachricht (ErrorMessage Erm), siehe Lib_Error:_complain
  // ab hier reguläre Variablen
  v200    : handle;
end
begin

  "outMat.Güte" # '';

  v200 # RecBufCreate(200);
  v200->Mat.Nummer # aMat.Nummer;
  Erx # RecRead(v200, 1, 0);
  
  // Prüfe auf Fehler
  if Erx <> _ErrOK then
  begin
    
    //ggf. __cleanup_...;   // meist nur bei komplexeren backend Funktionen
    
    Erm # 'Hier beschwert sich backend_von_SFX.eineSonderfunktion über einen in ihrem Kontext aufgetretenen Fehler.';
    complain(Verbosity, Erm);
    
    return Erx;
  end
  
  // Erfolgsfall:
  "outMat.Güte" # v200->"Mat.Güte";
  return _ErrOK;
  
end


/*========================================================================
2022-06-08  DS                                               1234/20/1

Sonderfunktionen analog zu Ankerfunktionen (s.o.) aber mit Präfix "SFX."

Die Tabelle um Sonderfunktionen in SC zu konfigurieren, erreicht man über:
Vorgaben -> Einstellungen -> Individuell -> Sonderfunktionen

Damit kann man z.B. konfigurieren, dass diese Funktion im Menu
"Sonderfunktionen" einer bestimmten Verwaltung auftaucht. Dazu sollte man
sich am besten an den schon bestehenden Einträgen in SC in der o.g. Tabelle
für die Sonderfunktionen orientieren und viel copy-pasten.
Da das Befüllen der Felder in manchen Fällen (z.B. bei Kunden mit viel
Customizing) nicht ganz intuitiv ist, hier noch einige Hinweise zur
Bedeutung der Felder und zu möglichen Besonderheiten:
* Nummer:
  Kann frei gewählt werden, muss nur eindeutig sein. Manche Kunden, z.B.
  solche mit vielen SFX an der Material-Verwaltung verwenden z.B.
  die zugehörige Tabellennummer 200 als Präfix und nutzen dann
  weitere dreistellige Nummern für die Eindeutigkeit. Es ist also
  nicht zwingend erforderlich, als Nummer 200 einzutragen für den
  Materialbereich, sondern bei mehreren SFX ist es sinnvoller
  200001, 200002 etc. zu verwenden, also die 200 vor eine Index-Nummer
  zu präfixen
* Bereich:
  Dies ist der schwierigste Teil, denn nur von diesem Eintrag hängt ab,
  ob SC die SFX korrekt an das Menu einer Verwaltung anhängen kann,
  oder nicht. Im Normalfall (z.B. im STD) reicht  die Angabe des
  Präfix der Verwaltung für die die SFX im Menu Sonderfunktionen angezeigt
  werden soll. Im Fall der Mat.Verwaltung des STD wäre der Wert für Bereich
  also "Mat".
  Komplizierter wird es, wenn Kunden custom Verwaltungen haben. Dies kann unter
  Vorgaben -> Einstellungen -> Individuell -> Dialoge
  überprüft werden.
  Wenn nun ein Kunde zu einer STD Verwaltung (linke Spalte der Dialoge-Tabelle)
  einen custom Dialog gesetzt hat (rechte Spalte der Dialoge-Tabelle), dann gilt
  es, die entsprechende Prozedur zum Dialog der rechten Spalte zu finden.
  Deren Name kann sich vom Dialog-Namen in mehr als nur "." vs. "_"
  unterscheiden und endet oft im suffix "_Main".
  Beispiel:
  Prozedur zur custom Mat.Verwaltung bei Holzrichter: "SFX_Mat_Rohr_Main".
  Dann muss bei diesem Kunden unter "Bereich" der Wert "SFX_Mat_Rohr", also
  ohne das Suffix "_Main" eingetragen werden.
  Ob es geklappt hat, kann man sofort (ohne Neustart von SC) prüfen, indem
  man die entsprechende Verwaltung öffnet, und schaut ob die SFX im
  Menu Sonderfunktionen (und dieses Menu selbst) erscheint.
* Hauptmenu:
  ???
* Reihenfolge:
  dient zur Anordnung der SFXen im Menu Sonderfunktionen
* Menüname:
  Der Name der für die SFX im Menu Sonderfunktionen angezeigt wird
* Hotkey:
  wie der Name schon sagt
* Prozedur:
  Die als SFX zu rufende Prozedur. Sie muss die im Folgenden genannten
  Bedingungen/Aufgaben erfüllen.


Aufgaben einer SFX sind:
- Eine SFX ist ein in sich abgeschlossener Einsprungpunkt aus der GUI,
  der bestimmte Funktionalitäten BEREITSTELLT, indem die SFX die backend-
  Funktionen aufruft, die die gewünschte Funktionalität IMPLEMENTIERTEN.
- Dass SFX abgeschlossen sind, bedeutet dass...
  1. ...eine SFX keine eingehenden Argumente hat (siehe Kommentar zu
     vMat.Nummer im folgenden Code für Möglichkeiten wie man dennoch
     Information übergeben kann)
  2. ...die SFX sich selbst abschließend um sämtliche Fehlerbehandlung und
     insb. um die Fehlerausgabe in der GUI der kümmert (mittels
     ErrorOutputWithDisclaimerPre und ErrorOutputWithDisclaimerPost,
     siehe Codebeispiel unten)
  3. ...die SFX keinen Rückgabewert hat, denn um sämtliche Fehlerbehandlung
     und Fehlerausgaben wurde sich gemäß 2. bereits gekümmert.
     Außerdem gibt es außerhalb der SFX in der GUI nichts und niemanden,
     der den Rückgabewert entgegennehmen könnte, denn die SFX ist wie gesagt
     ein EINSPRUNGpunkt
- Hauptaufgabe einer SFX ist es, GUI und Nutzerinteraktion zu regeln,
  d.h. den user-facing gluecode zwischen den ggf. mehreren
  einzelnen Aufrufen an backend-Funktionen zu realisieren.

NICHT Aufgaben einer SFX sind:
- die eigentliche Implementierung der bereitgestellten Funktionalität.
  Das ist Aufgabe der von der SFX gerufenen backend-Funktionen,
  siehe auch Doku zu !Template2022:_backend_von_SFX.eineSonderfunktion
- Durch diese Separationen kann man backend-Funktionen auch ohne GUI
  (zB im Job-Server oder anderen SFX/AFX) wiederverwenden, so dass
  der GUI-lose Job-Server und auch die GUI-nutzenden SFX dieselbe
  Implementierung der eigentlichen Funktionalität nutzen können.
========================================================================*/
sub SFX.eineSonderfunktion
(
  // SFX haben NIEMALS eingehende Argumente, denn sie sind abgeschlossene Einsprungpunkte, die lediglich per Klick aufgerufen werden.
) // Entsprechend ihrer Abgeschlossenheit haben sie auch keinen Ausgabewert. Sie kümmern sich selbst um sämtliche Fehlerbehandlung und Fehlerausgabe und geben nichts zurück.
local begin
  // Pflicht-locals
  Erx         : int;
  Erm         : alpha(8192);
  Description : alpha(512);   // zur Beschreibung was diese SFX tut
  Verbosity   : int;          // um Verbosity der gerufenen backend Funktionen zu kontrollieren
  // ab hier reguläre Variablen
  vMat.Nummer : int;
  "vMat.Güte" : alpha;
end
begin

  // Parameter der backend Funktionen kommen nicht aus Argumenten der SFX, da SFX keine Argumente haben.
  // Sie können aber z.B. aus Feldpuffern kommen, die im jeweiligen Aufrufkontext der SFX als geladen
  // angenommenen werden dürfen (z.B. wenn eine SFX im Kontext der Materialverwaltung aufgerufen wird,
  // darf das Material als geladen angenommen werden).
  // Oder sie werden (wie in diesem Beispiel) als Konstanten gesetzt:
  vMat.Nummer # 3099;
  

  // Verbosity der gerufenen backend-Funktionen festlegen:
  Verbosity # cVerbPost;  // siehe Def_Global für mehr mögliche Werte

  // SFX muss self-contained sein, d.h. sie muss sich auch End2End um Fehlerstack kümmern:
  Description # 'Template einer Sonderfunktion (SFX) ...hier menschenverständlich beschreiben was die SFX tut...';
  ErrorOutputWithDisclaimerPre(Description);
  
  // DEMO backend Funktion aufrufen, die die eigentliche Nutz-Funktionalität implementiert:
  // (in diesem Beispiel das Holen der Güte einer gegebenen Mat.Nummer)
  Erx # _backend_von_SFX.eineSonderfunktion(
    Verbosity,
    var "vMat.Güte",
    vMat.Nummer
  );
  if Erx <> _ErrOK then
  begin
    // Fehlerfall behandeln:
    
    // Hierzu DARF benutzt werden:
    Erm # 'Hier beschwert sich SFX.eineSonderfunktion selbst über einen bis in ihren Kontext durchgeschlagenen Fehler.';
    complain(Verbosity, Erm);
    // Außerdem können abhängig von Erx jeweils andere Codepfade verwendet werden als bei _ErrOK.
    
    // Hierzu DARF NICHT benutzt werden:
    // KEIN return (denn weiter unten muss ich die SFX selbst um ihre Fehlerausgaben kümmern,
    //              und weiter unten wird das auch im Fehlerfall notwendige ErrSet(_ErrOK); aufgerufen)
  end
  else
  begin
    // Erfolgsfall behandeln:
    // (z.B. kann es im Erfolgsfall in einem anderen Codepfad mit anderen backend-Funktionen weitergehen)
    // In diesem Beispiel wird der Erfolgsfall durch eine GUI-Ausgabe behandelt:
    MsgInfo(99, 'Güte des geladenen Materials mit Mat.Nr ' + aint(vMat.Nummer) + ': ' + "vMat.Güte");
  end
  
  // Es können hier natürlich auch mehr als nur eine backend-Funktion aufgerufen werden.
  // Die SFX fungiert also als GUI-nutzender, customer-facing gluecode zwischen den backend-Funktionen,
  // und kann zum Beispiel in Abhängigkeit der Erx-Werte der backend-Funktionen unterschiedliche
  // Code-Pfade einschlagen, den Nutzer per Dialog um Eingaben bitten, Fehler oder Erfolge ausgeben etc.

    
  // SFX muss self-contained sein, d.h. sie muss sich auch End2End um Fehlerstack kümmern:
  // (Fehlermeldungen zu Misserfolgen werden je nach Verbosity hierdurch gesammelt ausgegeben).
  ErrorOutputWithDisclaimerPost(Description);
  
  // Am Ende muss in JEDEM (auch im Fehler-)Fall "ErrSet(_ErrOK)" gerufen werden,
  // denn es wird von jeder SFX verlangt, dies zu tun. Denn wenn der durch ErrSet
  // gesetzte Fehlerwert ungleich _ErrOK ist, geht die SC Logik davon aus, dass
  // die SFX nicht vorhanden ist.
  // Kurz: SFX müssen immer den globalen C16 Fehlercode zurücksetzen:
  ErrSet(_ErrOK);
  
end


/*========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================*/
MAIN()
local begin
  Erx     : int;
  vDescription : alpha(512);
  // hier ausnahmsweise generische Variablennamen die in Beispielen wiederverwendet werden
  vAlpha  : alpha;
  vInt    : int;
  vLogic  : logic;
  // buffer zum Übergeben von Datensätzen an Funktionen
  vBuf    : handle;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  // ...und setzen
  gUserName # 'ME';
  
  // Erforderlich damit Lib_SFX:* Funktionen bei standalone Ausführung (STRG+T) funktionieren (nicht nötig innerhalb von laufendem SC (STRG+R))
  Lib_SFX:InitAFX();
  
  // Logging initialisieren (wird bei normalem SC Betrieb durch App_Main:EvtCreated() gemacht)
  Lib_Logging:InitLogging();
  
  /*
  Jede sub für die das sinnvoll ist (Ausnahmen können z.B. private Prozeduren
  sein oder Prozeduren die massiv auf die GUI angewiesen sind) bekommt ein
  self-contained Benutzungsbeispiel als Blockkommentar in dieser MAIN Methode,
  damit andere Devs später zum Testen von Änderungen oder zum Ausprobieren nur
  noch die Blockkommentar-"Klammern" entfernen und CTRL + T drücken müssen.
  
  Bei GUI Funktionen empfieht es sich, diese in einen Frontend- und einen
  Backend Teil mit der eigentlichen logic zu splitten und zumindest für den
  Backend-Part ein Benutzungsbeispiel beizulegen.
  
  Das beschleunigt auch die Erst-Entwicklung (spart jedesmal SC zu starten)
  und steigert die Wiederverwendbarkeit der Backend-Logic.
  */
  
  
  /*
  vAlpha # prozedurnameInCamelCase('welt');
  DebugM('Ausgabe von prozedurnameInCamelCase(): ' + vAlpha);
  */
  
  
  /*
  vDescription # 'Beispiel-Aufruf einer Erx-zurückgebenden Funktion'
  ErrorOutputWithDisclaimerPre(vDescription);
  
  vBuf # RecBufCreate(123);
  RecRead(vBuf, 1, _RecFirst);
  
  Erx # fTemplate(
    // Pflicht-Argument verbosity:
    cVerbPost,  // Fehler AM ENDE auf Bildschirm ausgeben
    // eigentliche Argumente der Funktion
    vBuf,
    var vAlpha,
    42,
    true
  )
  DebugM('Ausgabe von fTemplate(): Erx=' + aint(Erx));
  showErrorTrace();  // nur in DEV aktiv
  ErrorOutputWithDisclaimerPost(vDescription);
  */
  
  
  /*
  vDescription # 'Beispiel-Aufruf einer VERSCHACHTELTEN Erx-zurückgebenden Funktion'
  ErrorOutputWithDisclaimerPre(vDescription);
  Erx # fTemplateNesting(cVerbInstant);
  DebugM('Ausgabe von fTemplateNesting(): Erx=' + aint(Erx));
  showErrorTrace();   // nur in DEV aktiv
  ErrorOutputWithDisclaimerPost(vDescription);
  */
  
  
  /*
  vAlpha # _privateProzedur();
  DebugM('Ausgabe von _privateProzedur(): ' + vAlpha);
  */
  
  
  /*
  // Codebeispiel (hier nicht ausführbar, es geht hier nur um das pattern des Aufrufens)
  // für eine Ankerfunktion die per RunAFX() aufgerufen wird
  // * dann nur ein alpha Argument möglich (z.B. mit pipe-separated Argumenten)
  // * dann muss Return-Value zwangsläufig int sein
  // Ankerfunktion?
  vA # aint(aBereich)+'|'+aFormular+'|'+aName+'|'+aSprache+'|'+aFax+'|'+aEMail+'|'+aFilename;
  if (RunAFX('DMS.Insert',vA)<0) then RETURN;
  */
  
  
  /*
  // Codebeispiel für eine Ankerfunktion die mit Call() aufgerufen wird
  // * dann beliebige Argumente möglich (inkl. var)
  // * dann beliebiger Typ als Return-Value möglich
  if Lib_SFX:Check_AFX('AppHost.URL') and AFX.Prozedur <> '' then
  begin
    vAlpha # Call(AFX.Prozedur);
  end
  DebugM('Ausgabe der AFX hinter AppHost.URL(): ' + vAlpha);
  */

  
  // SFX (Sonderfunktionen) haben weder Eingabeparameter, noch einen Rückgabewert.
  // Sie kümmern sich selbst um alle user-facing Ausgaben.
  SFX.eineSonderfunktion();
  
 

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end


//========================================================================