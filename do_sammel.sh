#!/bin/bash

# sammel

FILE=sammel
cat << EOT > $FILE.tex
\include{konfiguration}
\include{konfiguration-\gliederung}
\include{pp-zuwendungsbescheinigung-include-document}

\begin{document}
\setlength{\parindent}{0em}		% vermeide einrueckung
\include{pp-zuwendungsbescheinigung-include-sammelbrief}
EOT

SAVEIFS="$IFS"
IFS=\;
ANZ=$(cat $FILE.csv | wc -l)
declare -i INDEX=0
cat $FILE.csv | while read LINE; do 
	INDEX=$((INDEX+1))
	echo -ne Baue Dokument fuer Sammelbescheinigungen... $INDEX / $ANZ\\r
	H=($LINE)
	Z=$(./zahlInWort.sh ${H[19]})
	. do_plz.sh
	echo "\\sammelbrief{${H[8]} ${H[7]}}{${H[9]}}{${ORT}}{$LAND}{${H[19]}}{$Z}{${H[21]}}{${H[0]}}" >> $FILE.tex
done
echo "\end{document}" >> $FILE.tex
echo ""
# echo "pdflatex $FILE.tex && open $FILE.pdf"