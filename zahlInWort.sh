#!/bin/bash

if [ "$1" == "" ]; then
	echo Zahl als Parameter angeben
	echo Beispiel: $0 123.456,70
	exit
fi

if [ "$1" == "test" -o "$1" == "-test" ]; then
	[ "$($0 11,01)" == "elf 1/100" ] || echo FAIL on 11
	[ "$($0 16,1)" == "sechzehn 10/100" ] || echo FAIL on 11
	[ "$($0 11000)" == "elftausend 0/100" ] || echo FAIL on 11000
	[ "$($0 20030)" == "zwanzigtausenddreizig 0/100" ] || echo FAIL on 20030
	[ "$($0 20030040)" == "zwanzigmillionendreizigtausendvierzig 0/100" ] || echo FAIL on 20.030.040
	[ "$($0 1030040)" == "einemilliondreizigtausendvierzig 0/100" ] || echo FAIL on 1.030.040
	[ "$($0 17.000.011,42)" == "siebzehnmillionenelf 42/100" ] || echo FAIL on 1.030.040
	echo "Finished all tests"
	exit
fi

BETRAG=$1

# deutsche betraege: tausender trennpunkt entfernen
BETRAG=$(echo $BETRAG|sed -e "s/\.//g")
# deutsches komma durch den bash dezimalpunkt ersetzen
BETRAG=$(echo $BETRAG|sed -e "s/,/\./g")

# cent
BETRAG_FRAC=$(bc <<< "$BETRAG * 100 % 100")
# jetzt noch ggf. den dezimalpunkt raustrennen
BETRAG_FRAC=$(printf "%.0f" $BETRAG_FRAC)

# euro
BETRAG_INT=$(bc <<< "$BETRAG - $BETRAG % 1")
# jetzt noch ggf. den dezimalpunkt raustrennen
BETRAG_INT=$(printf "%.0f" $BETRAG_INT)

# ============================
# jetzt haben wir INT und FRAC
# ============================

ZAHLINWORT=""
if [ $BETRAG_INT == 0 ]; then
  ZAHLINWORT="Null"
else
	REST=$BETRAG_INT
	declare -i TAUSENDER=0
	while [ "$REST" != "" ]; do
		EINER=${REST: -1:1}
		ZEHNER=${REST: -2:1}
		HUNDERTER=${REST: -3:1}
		# echo $HUNDERTER $ZEHNER $EINER

		if [ "$HUNDERTER" == "1" ]; then
			H="einhundert"
		elif [ "$HUNDERTER" == "2" ]; then
			H="zweihundert"
		elif [ "$HUNDERTER" == "3" ]; then
			H="dreihundert"
		elif [ "$HUNDERTER" == "4" ]; then
			H="vierhundert"
		elif [ "$HUNDERTER" == "5" ]; then
			H="fünfhundert"
		elif [ "$HUNDERTER" == "6" ]; then
			H="sechshundert"
		elif [ "$HUNDERTER" == "7" ]; then
			H="siebenhundert"
		elif [ "$HUNDERTER" == "8" ]; then
			H="achthundert"
		elif [ "$HUNDERTER" == "9" ]; then
			H="neunhundert"
		else
			H=""
		fi
		if [ "$ZEHNER" == "1" ]; then
			Z="zehn"
		elif [ "$ZEHNER" == "2" ]; then
			Z="undzwanzig"
		elif [ "$ZEHNER" == "3" ]; then
			Z="unddreizig"
		elif [ "$ZEHNER" == "4" ]; then
			Z="undvierzig"
		elif [ "$ZEHNER" == "5" ]; then
			Z="undfünfzig"
		elif [ "$ZEHNER" == "6" ]; then
			Z="undsechzig"
		elif [ "$ZEHNER" == "7" ]; then
			Z="undsiebzig"
		elif [ "$ZEHNER" == "8" ]; then
			Z="undachtzig"
		elif [ "$ZEHNER" == "9" ]; then
			Z="undneunzig"
		else
			Z=""
		fi
		if [ "$EINER" == "1" ]; then
			E="ein"
		elif [ "$EINER" == "2" ]; then
			E="zwei"
		elif [ "$EINER" == "3" ]; then
			E="drei"
		elif [ "$EINER" == "4" ]; then
			E="vier"
		elif [ "$EINER" == "5" ]; then
			E="fünf"
		elif [ "$EINER" == "6" ]; then
			E="sechs"
		elif [ "$EINER" == "7" ]; then
			E="sieben"
		elif [ "$EINER" == "8" ]; then
			E="acht"
		elif [ "$EINER" == "9" ]; then
			E="neun"
		else
			E=""
		fi
		Z="$E$Z"
		if [ "$Z" == "einzehn" ]; then Z="elf"
		elif [ "$Z" == "zweizehn" ]; then Z="zwölf"
		elif [ "$Z" == "sechszehn" ]; then Z="sechzehn"
		elif [ "$Z" == "siebenzehn" ]; then Z="siebzehn"
		fi
		H="$H$Z"
		if [ $TAUSENDER == 1 -a "$H" != "" ]; then H="${H}tausend"; fi
		if [ $TAUSENDER == 2 -a "$H" != "" ]; then
			if [ "$Z" == "ein" ]; then H="${H}emillion"
			else H="${H}millionen"
			fi
		fi
		if [ $TAUSENDER == 3 -a "$H" != "" ]; then
			if [ "$Z" == "ein" ]; then H="${H}emilliarde"
			else H="${H}milliarden"
			fi
		fi
		
		#
		LEN=${#H}
		if [ $LEN -gt 3 ]; then 
			if [ "${H:0:3}" == "und" ]; then 
				H="${H:3}"
			fi
		fi

		# finally:
		ZAHLINWORT="${H}${ZAHLINWORT}"
	
		# now shift by 3 - divide by 1000
		LEN=${#REST}
		if [ $LEN -lt 3 ]; then break; fi
		REST=${REST:0:$((${#REST}-3))}
		TAUSENDER=$((TAUSENDER+1))
	done
fi
echo "$ZAHLINWORT $BETRAG_FRAC/100"
