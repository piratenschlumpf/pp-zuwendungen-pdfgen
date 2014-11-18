#!/bin/bash

if [ "$1" != "zip" ]; then
	pdflatex einzel.tex
	pdflatex haeufig.tex
	pdflatex sammel.tex
	pdflatex sach.tex
fi

OK=1
if [ -f einzel.pdf ]; then 
	echo "Einzelbescheinigungen in einzel.pdf"
	[ "$1" != "zip" ] && open einzel.pdf
else
	OK=0
	echo "Fehler bei der PDF Generierung von einzel.tex"
fi
if [ -f haeufig.pdf ]; then 
	echo "Beitragsbescheinigungen in haeufig.pdf"
	[ "$1" != "zip" ] && open haeufig.pdf
else
	OK=0
	echo "Fehler bei der PDF Generierung von haeufig.tex"
fi
if [ -f sammel.pdf ]; then 
	echo "Sammelbescheinigungen in sammel.pdf"
	[ "$1" != "zip" ] && open sammel.pdf
else
	OK=0
	echo "Fehler bei der PDF Generierung von sammel.tex"
fi
if [ -f sach.pdf ]; then 
	echo "Sachbescheinigungen in sach.pdf"
	[ "$1" != "zip" ] && open sach.pdf
else
	OK=0
	echo "Fehler bei der PDF Generierung von sach.tex"
fi

if [ "$OK" == "1" ]; then
	rm -f konfiguration*.aux
	rm -f  {einzel,haeufig,sammel,sach,pp-zuwendungsbescheinigung-*}.{aux,log,out}
	rm -f ergebnis.zip
	zip -z ergebnis.zip {einzel,haeufig,sammel,sach}.pdf {spenden-alles,einzel,haeufig,sammel,sach,nullen}.csv schritt?.sh zahlInWort.sh do_*.sh konfiguration*.tex pp-zuwendungsbescheinigung-include-*.tex logo*.png README.txt <<EOT > /dev/null 
.
	!!! Bitte nach dem Auspacken die Datei README.txt lesen !!!
.
EOT

	rm -f {einzel,haeufig,sammel,sach,rest,nullen,beitrag,data}.csv konto-*.csv
	echo "Ergebnis in ergebnis.zip"
fi
