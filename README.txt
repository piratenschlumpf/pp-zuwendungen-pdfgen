pp-zuwendungen-pdfgen
=====================

Spendenbescheinigungen PDF Generation Package
==============================================================================
Download von https://github.com/piratenschlumpf/pp-zuwendungen-pdfgen

Dieses Paket enthaelt Scripte um automatisiert Spendenbescheinigungen 
fuer die Piratenpartei Deutschland und Untergliederungen erstellen
zu koennen. Benoetigt dazu wird:

 * MacOSX (=Apple) als Betriebsystem. Funktioniert mglw. auch auf Linux.
 * Installiertes LaTeX
 * Ein Buchhaltungsextrakt von der Bundesbuchhaltung (von Irmgard)
  * Bei Bedarf: Scan der Schatzmeisterunterschrift als .PNG sowie
    Anmeldungung des Verfahrens beim Finanzamt gemaes EStR R 10b.1 Absatz 4.

Hilfe zur Installation von LaTeX unter Mac:
	* http://www.latexbuch.de/latex-apple-mac-os-x-installieren/

Empfohlene Downloads:
	* MacTeX.pkg und MacTeXtras.zip von http://www.tug.org/mactex/

Anleitung:
==========
1.	Die .xls(x) Datei der Bundesbuchhaltung oeffenen, Tabelle "alles" waehlen.
2.	Als "CSV" Datei speichern, hier in dieses Verzeichnis unter dem Namen
		spenden-alles.csv
	(Die existierende Datei ist ein Beispiel, sie kann ueberschrieben werden)
	Wird die Bestaetigung von Mitgliedsbeitraegen nicht gewuenscht, dann
	  solche Eintraege aus der XLS/CSV Datei loeschen.
	Bei Speichern waehlen: 
		Encoding: Windows-1252/WinLatin1
		Trennzeichen Semikolon
		kein Hochkommatrennzeichen.
3. Datei "konfiguration.tex" anpassen. Dort wird die Gliederung definiert.
   Beispiel: "lvnrw" angegeben -> weitere Details in konfiguration-lvnrw.tex
4. Datei "konfiguration-[GLIEDERUNG].tex" anpassen.
   Jede Gliederung hat ihre eigene Konfigurationsdatei, bitte dort anpassen.
5. Scriptschritte Eins bis Drei ausfuehren:
6. Terminal oeffnen, ins Verzeichnis navigieren, folgendes eintippen

	./schritt1.sh

   Falls sich das Script beschwert: Fehler beheben, erneut laufen lassen.
   
7. Die Anweisungen befolgen, insbesondere die Sachspendendatei pruefen und 
   anpassen damit die Sachspenden 

	./schritt2.sh
	
8. Jetzt die PDF generierten:

	./schritt3.sh
	
9. einzel.pdf, sach.pdf, sammel.pdf drucken und gluecklich sein.
   Beachte: sammel.pdf enthaelt jeweils 2 Seiten pro Spendenbescheinigung.
            Duplex-Drucker empfohlen um Vor- und Rueckseite zu bedrucken.

Erstellt von @piratenschlumpf
Kontakt: piratenschlumpf at gmail.com 
Support: https://github.com/piratenschlumpf/pp-zuwendungen-pdfgen/issues
