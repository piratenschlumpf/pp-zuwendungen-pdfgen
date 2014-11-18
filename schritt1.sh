#!/bin/bash

IN=spenden-alles.csv

YES=""
while [ "$1" != "" ]; do
	if [ "$1" == "-y" -o "$1" == "-j" -o "$1" == "-f" ]; then
		YES=yes
	else
		echo "Unknown option '$1'"
		exit
	fi
	shift
done

rm -f *.temp konto-*.csv

echo Pruefe Datei...
if [ ! -f $IN ]; then echo "Datei $IN fehlt. Bitte alle Spenden aus Buchungsperiode nach $IN exportieren. Encoding: Windows-1252/WinLatin1, Trennzeichen Semikolon, kein Hochkommatrennzeichen."; exit; fi

SAVEIFS="$IFS"
IFS=\;
HEADER=$(head -n 1 < $IN)
H=($HEADER)
if [ "${H[0]}" != "Ktokorrent" ]; then echo "1. Spalte in $IN ist nicht 'Ktokorrent'"; exit; fi
if [ "${H[1]}" != "Buchungsk" ];  then echo "2. Spalte in $IN ist nicht 'Buchungsk'"; exit; fi
if [ "${H[3]}" != "Periode" ];    then echo "4. Spalte in $IN ist nicht 'Periode'"; exit; fi
if [ "${H[4]}" != "Belegdatum" ]; then echo "5. Spalte in $IN ist nicht 'Belegdatum'"; exit; fi
if [ "${H[6]}" != "Betrag" ];     then echo "7. Spalte in $IN ist nicht 'Betrag'"; exit; fi
if [ "${H[15]}" != "Art" ];       then echo "16. Spalte in $IN ist nicht 'Art'"; exit; fi
if [ "${H[16]}" != "Storno" ];    then echo "17. Spalte in $IN ist nicht 'Storno'"; exit; fi

# Header ist in Ordnung, erwarte
# Ktokorrent;Buchungsk;Bezeichnung;Periode;Belegdatum;Buchungstext;Betrag;Name1;Name2;LieferStrasse;LieferPLZ;LieferOrt;LieferLand;USER_LV;Spende;Art;Storno;Bescheinigung

BODY=body.csv		# body = alle CSV Eintraege ohne die Header Zeile
SACH=sach.csv		# sach = alle ";Sach;" Spenden Eintraege
REST=rest.csv		# rest = body ohne sach = alle Nicht-Sachspenden Eintraege
BEITRAG=beitrag.csv	# = alle Mitgliedsbeitrags-Eintraege

echo Baue Daten-Dateien...
cat $IN | (read DUMMY; cat | sort -t \; -k 11 > $BODY)
# jetzt haben wir alle Daten ohne die Headerzeile in $BODY

# checks
T=temp.temp
T2=temp2.temp
cut -d ";" -f 2 < $BODY | sort | uniq > $T
L=$(cat $T|wc -l)
if [ $L -ne 1 ]; then echo "Mehr als ein Buchungskreis in Datei $IN, bitte beheben"; echo "Buchungskreise: $(cat $T)"; exit; fi
echo Pruefe Buchungskreise... ok

cut -d ";" -f 4 < $BODY | cut -b 1-4 | sort | uniq > $T
L=$(cat $T|wc -l)
if [ $L -ne 1 ]; then echo "Mehr als eine Periode in Datei $IN, bitte beheben"; echo "Perioden: $(cat $T)"; exit; fi
echo Pruefe Periode... ok
JAHR=$(cat $T)

grep ";NULL;" $BODY > $T
L=$(cat $T|wc -l)
if [ $L -ge 1 ]; then echo "Dateneintraege mit 'NULL' vorhanden, bitte beheben. Kontokorrenten: $(cut -d ";" -f 1 < $T)"; exit; fi
echo Pruefe ungueltige Daten/NULL-Zellen... ok

cut -d ";" -f 1,11,13 < $BODY | sort | grep ";DE" | grep -v ";.....;" >$T
L=$(cat $T|wc -l)
if [ $L -ge 1 ]; then echo "Nicht-fuenfstellige PLZ vorhanden, bitte beheben."; echo "Tipp: Format der Zelle auf TEXT umstellen bei fuehrender Null Kontokorrenten:"; cut -d ";" -f 1 < $T | uniq | sort -n; exit; fi
echo Pruefe ungueltige deutsche PLZ... ok


cut -d ";" -f 17 < $BODY | sort | uniq > $T
L=$(cat $T|wc -l)
if [ $L -ne 1 ]; then 
	echo "WARNUNG: Stornodatensaetze in der Datei."; 
	if [ "$YES" != "yes" ]; then 
		echo -n "  Stornodatensaetze ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Stornodatensaetze... akzeptiert
	fi
else
	echo Pruege Stornodatensaetze... ok
fi

cut -d ";" -f 5 < $BODY | cut -b 7-10 | sort | uniq > $T
L=$(cat $T|wc -l)
if [ $L -ne 1 ]; then 
	echo "WARNUNG: Mehr als ein Belegjahr in der Datei."; 
	echo "  Spendenjahr/Periode: $JAHR"
	echo -n "  Belegjahre:"
	cat $T | while read L; do echo -n " $L"; done
	echo ""
	if [ "$YES" != "yes" ]; then 
		echo -n "  Belegjahre ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Verschiedene Belegjahre... akzeptiert
	fi
else
	echo Pruefe Belegjahr... ok
fi

cut -d ";" -f 16 < $BODY | sort | uniq > $T
L=$(cat $T|wc -l)
if [ $L -gt 4 ]; then echo "Mehr als 4 Spendenarten in der Datei, bitte beheben"; echo "Art: $(cat $T)"; exit; fi
grep Sach $T >/dev/null
if [ $? -eq 1 ]; then
	if [ "$YES" ]; then 
		echo "WARNUNG: Keine Sachspenden in der Datei."; 
	else
		echo -n "  Keine Sachspenden in der Datei. ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Keine Sachspenden... akzeptiert
	fi
#else
	# Sachspenden gefunden
fi
grep Geld $T >/dev/null
if [ $? -eq 1 ]; then
	if [ "$YES" ]; then 
		echo "WARNUNG: Keine Geldspenden in der Datei."; 
	else
		echo -n "  Keine Geldspenden in der Datei. ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Keine Geldspenden... akzeptiert
	fi
#else
	# Geldspenden gefunden
fi
grep Beitrag $T >/dev/null
if [ $? -eq 1 ]; then
	if [ "$YES" ]; then 
		echo "WARNUNG: Keine Beitragszahlungen in der Datei."; 
	else
		echo -n "  Keine Beitragszahlungen in der Datei. ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Keine Beitragszahlungen... akzeptiert
	fi
#else
	# Beitragszahlungen gefunden
fi
grep Verzicht $T >/dev/null
if [ $? -eq 1 ]; then
	if [ "$YES" ]; then 
		echo "WARNUNG: Keine Verzichtspenden in der Datei."; 
	else
		echo -n "  Keine Verzichtspenden in der Datei. ok (j/n) ? "
		read DUMMY
		[ "$DUMMY" != "j" ] && exit; 
		echo Keine Verzichtspenden... akzeptiert
	fi
#else
	# Verzichtspenden gefunden
fi
echo Pruefe Spendenarten... ok

echo ""
echo Pruefungen beendet, berechne Daten...

grep ";Sach;" $BODY > $T
ANZ=$(cat $T | wc -l)
declare -i INDEX=0
> $SACH
cat $T | while read LINE; do 
	INDEX=$((INDEX+1))
	echo -ne Filtere Sachspenden... $INDEX / $ANZ\\r
	H=($LINE)
	S=$(echo ${H[5]} | sed -e "s/Sachspenden//g" | sed -e "s/Sachspende//g" | sed -e "s/Spenden//g" | sed -e "s/Spende//g"  | sed -e "s/SACHSPENDEN//g" | sed -e "s/SACHSPENDE//g" | sed -e "s/SPENDEN//g" | sed -e "s/SPENDE//g" | sed -e 's/#[0-9]*//g' | sed -e "s/  / /g" | sed -e "s/^ //g" | sed -e "s/ $ //g")
	if [ "$S" == "" ]; then
		echo "$LINE;${H[5]};${H[5]}" >> $SACH
	else
		echo "$LINE;$S;${H[5]}" >> $SACH
	fi
done
# sort by Name
sort -t \; -k 8 $SACH > $T; mv $T $SACH
echo ""

grep -v ";Sach;" $BODY > $REST
grep ";Beitrag;" $BODY > $BEITRAG


cut -d ";" -f 7 < $BEITRAG > $T
cat $T|sort|uniq|while read C; do N=$(grep "^$C$" $T|wc -l); echo $N $C; done > $T2
MB=$(sort -n < $T2|tail -n 1|cut -b 10-)
ANZ=$(sort -n < $T2|tail -n 1|cut -b 1-9)
echo "Haeufigster Mitgliedsbeitrag: $MB  (Vorkommen: $ANZ)"
#
#echo jetzt alle Mitglieder rausfiltern, die nur MB gezahlt haben und in der Summe 48,00
#echo das ist quatsch weil eh nicht inhaltsgleich - das datum bei jedem anders.
#echo also machen wir lieber alle die nur MB haben.

cut -d ";" -f 1 < $REST |sort > $T
uniq -u $T > einzel.temp
uniq -d $T > sammel.temp

echo Sach-Bescheinigungliste in $SACH, Eintraege: $(cat $SACH | wc -l)
echo EinzelKontokorrenten in einzel.temp, Eintraege: $(cat einzel.temp | wc -l)
echo SammelKontokorrenten in sammel.temp, Eintraege: $(cat sammel.temp | wc -l)

#grep    ";Beitrag;" < $REST | cut -d ";" -f 1|sort|uniq > hat_mb.temp
#grep -v ";Beitrag;" < $REST | cut -d ";" -f 1|sort|uniq > hat_spenden.temp
#> nur_mb.temp
#> sammel.temp
#cat hat_mb.temp | while read KONTOKORRENT; do
#	grep "^${KONTOKORRENT}$" hat_spenden.temp >/dev/null 
#	if [ $? -eq 0 ]; then                       
#		# grep return = 0 wenn es ein match gab
#		echo $KONTOKORRENT >> sammel.temp
#	else
#		echo $KONTOKORRENT >> nur_mb.temp
#	fi
#done

# Berechnung des einzel.csv
ANZ=$(cat einzel.temp | wc -l)
declare -i INDEX=0
> einzel.csv
> haeufig.csv
cat einzel.temp | while read KONTOKORRENT; do
	INDEX=$((INDEX+1))
#	echo -ne Berechnung von Listen fuer Mitgliedsbeitrag und Sammelbescheinigungen... $INDEX / $ANZ\\r
	echo -ne Berechnung Liste fuer Einzelbescheinigungen... $INDEX / $ANZ\\r
	# grep "^${KONTOKORRENT};" $REST >> einzel.csv
	LINE=$(grep "^${KONTOKORRENT};" $REST)
	IFS=\;
	H=($LINE)
	if [ "${H[15]}" == "Beitrag" -a "${H[12]}" == "DE" -a ${H[6]} == $MB ]; then
		echo "$LINE" >> haeufig.csv
	else
		echo "$LINE" >> einzel.csv
	fi
done
# sort by PLZ
sort -t \; -k 11 haeufig.csv > $T; mv $T haeufig.csv
# sort by Name
sort -t \; -k 8 einzel.csv > $T; mv $T einzel.csv

echo ""
echo Einzel-Bescheinigungliste in einzel.csv, Eintraege: $(cat einzel.csv | wc -l)
echo Haeufigster Beitrag-Liste in haeufig.csv, Eintraege: $(cat haeufig.csv | wc -l)

# Berechnung der Sammeldaten
ANZ=$(cat sammel.temp | wc -l)
declare -i INDEX=0
> sammel.csv
> nullen.csv
cat sammel.temp | while read KONTOKORRENT; do
	IFS="$SAVEIFS"
	INDEX=$((INDEX+1))
#	echo -ne Berechnung von Listen fuer Mitgliedsbeitrag und Sammelbescheinigungen... $INDEX / $ANZ\\r
	echo -ne Berechnung Liste fuer Sammelbescheinigungen... $INDEX / $ANZ\\r
	# grep "^${KONTOKORRENT};" $REST >> sammel.csv
	declare -x SUMME="0,00"
	for BETRAG in $(grep "^$KONTOKORRENT;" $REST | cut -d ";" -f 7); do 
		# tausendertrennzeichen entfernen
		BETRAG=$(echo $BETRAG | sed -e "s/\.//g")
		# summieren
		SUMME=$(echo ${SUMME}+${BETRAG} | sed -e "s/,/\./g" | bc | sed -e "s/\./,/g")
	done
	if [ $SUMME == 0 ]; then
		echo $KONTOKORRENT >> nullen.csv
	else
		echo "$(grep "^${KONTOKORRENT};" $REST | head -n 1 );$KONTOKORRENT;${SUMME};$(./zahlInWort.sh $SUMME);1.1.$JAHR bis 31.12.$JAHR" >> sammel.csv
		# write out all lines
		# Ktokorrent;Buchungsk;Bezeichnung;Periode;Belegdatum;Buchungstext;Betrag;Name1;Name2;LieferStrasse;LieferPLZ;LieferOrt;LieferLand;USER_LV;Spende;Art;Storno;Bescheinigung
		# Wird zu: Ktokorrent;Belegdatum;Betrag;Spende;Art;Spendenart;Verzicht
		echo "Ktokorrent;Belegdatum;Betrag;Art;Spendenart;Verzicht" > konto-$KONTOKORRENT.csv
		grep "^$KONTOKORRENT;" $REST | while read LINE; do
			IFS=\;
			H=($LINE)
			if [ "${H[15]}" == "Verzicht" ]; then X=Ja; else X=Nein; fi
			if [ "${H[15]}" == "Beitrag" ]; then Y=Mitgliedsbeitrag; else Y=Geldzuwendung; fi
		echo "${H[0]};${H[4]};${H[6]};${H[15]};${Y};${X}" >> konto-$KONTOKORRENT.csv
		done
	fi
done
# sort by Name
sort -t \; -k 8 nullen.csv > $T; mv $T nullen.csv
sort -t \; -k 8 sammel.csv > $T; mv $T sammel.csv
echo ""
echo Sammel-Bescheinigungliste in sammel.csv, Eintraege: $(cat sammel.csv | wc -l)
echo Kontokorrenten mit Summe0 in nullen.csv, Eintraege: $(cat nullen.csv | wc -l)

echo ""
# ende
# aufraeumen
rm -f temp.temp temp2.temp
#echo rm $BODY \*.temp konto-\*.csv
#echo rm $SACH 
#echo ""
echo "WICHTIG: In Datei $SACH vorletzte gegen letzte Spalte pruefen."
echo "         Ggf. vorletzte Spalte korrigieren oder loeschen!"
echo "         Die vorletzte Spalte wird als Sachspendenbezeichnung gedruckt!"
echo ""
echo "Danach: Rufe das script ./schritt2.sh zur TeX Generierung auf."
