#!/bin/bash

# wenn MACH_KREUZE auf 1 steht, dann werden die zwei 
# Kreuze bei den Sachbestaetigungen automatisch gemacht
# andernfalls setze MACH_KREUZE auf 0.
MACH_KREUZE=1

# sach

FILE=sach
cat << EOT > $FILE.tex
\include{konfiguration}
\include{konfiguration-\gliederung}
\include{pp-zuwendungsbescheinigung-include-document}

\begin{document}
\setlength{\parindent}{0em}		% vermeide einrueckung
\include{pp-zuwendungsbescheinigung-include-sachbrief}
EOT

SAVEIFS="$IFS"
IFS=\;
ANZ=$(cat $FILE.csv | wc -l)
declare -i INDEX=0
cat $FILE.csv | while read LINE; do 
	INDEX=$((INDEX+1))
	echo -ne Baue Dokument fuer Sachbescheinigungen... $INDEX / $ANZ\\r
	H=($LINE)
	if [ "${H[15]}" == "Verzicht" ]; then X=1; else X=0; fi
	Z=$(./zahlInWort.sh ${H[6]})
	D=$(echo "${H[18]}" | sed -e "s/_/\\\\_/g" | sed -e "s/\^/\\\\^/g" | sed -e "s/{/\\\\{/g" | sed -e "s/}/\\\\}/g")
	. do_plz.sh
	echo "\\sachbrief{${H[8]} ${H[7]}}{${H[9]}}{${ORT}}{$LAND}{${H[6]}}{$Z}{${H[4]}}{${D}}{$MACH_KREUZE}" >> $FILE.tex
done
echo "\end{document}" >> $FILE.tex
echo ""
# echo "pdflatex $FILE.tex && open $FILE.pdf"