#!/bin/bash

# einzel

FILE=einzel
cat << EOT > $FILE.tex
\include{konfiguration}
\include{konfiguration-\gliederung}
\include{pp-zuwendungsbescheinigung-include-document}

\begin{document}
\setlength{\parindent}{0em}		% vermeide einrueckung
\include{pp-zuwendungsbescheinigung-include-einzelbrief}
EOT

SAVEIFS="$IFS"
IFS=\;
ANZ=$(cat $FILE.csv | wc -l)
declare -i INDEX=0
cat $FILE.csv | while read LINE; do 
	INDEX=$((INDEX+1))
	echo -ne Baue Dokument fuer Einzelbescheinigungen... $INDEX / $ANZ\\r
	H=($LINE)
	if [ "${H[15]}" == "Verzicht" ]; then X=1; else X=0; fi
	Z=$(./zahlInWort.sh ${H[6]})
	. do_plz.sh
	echo "\\einzelbrief{${H[8]} ${H[7]}}{${H[9]}}{${ORT}}{$LAND}{${H[6]}}{$Z}{${H[4]}}{$X}" >> $FILE.tex
done
echo "\end{document}" >> $FILE.tex
echo ""

FILE=haeufig
cat << EOT > $FILE.tex
\include{konfiguration}
\include{konfiguration-\gliederung}
\include{pp-zuwendungsbescheinigung-include-document}

\begin{document}
\setlength{\parindent}{0em}		% vermeide einrueckung
\include{pp-zuwendungsbescheinigung-include-einzelbrief}
EOT

SAVEIFS="$IFS"
IFS=\;
ANZ=$(cat $FILE.csv | wc -l)
declare -i INDEX=0
cat $FILE.csv | while read LINE; do 
	INDEX=$((INDEX+1))
	echo -ne Baue Dokument fuer Infopostbescheinigungen... $INDEX / $ANZ\\r
	H=($LINE)
	if [ "${H[15]}" == "Verzicht" ]; then X=1; else X=0; fi
	Z=$(./zahlInWort.sh ${H[6]})
	. do_plz.sh
	echo "\\einzelbrief{${H[8]} ${H[7]}}{${H[9]}}{${ORT}}{$LAND}{${H[6]}}{$Z}{${H[4]}}{$X}" >> $FILE.tex
done
echo "\end{document}" >> $FILE.tex
echo ""
# echo "pdflatex $FILE.tex && open $FILE.pdf"