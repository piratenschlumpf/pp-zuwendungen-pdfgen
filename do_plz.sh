#!/bin/bash

declare -x ORT="${H[10]} ${H[11]}"
declare -x LAND=""

if [ "${H[12]}" != "DE" ]; then
	if [ "${H[12]}" = "FR" ]; then
		LAND="Frankreich / France"
	elif [ "${H[12]}" = "ES" ]; then
		LAND="Spanien / Espana"
	elif [ "${H[12]}" = "NL" ]; then
		LAND="Niederlande / Netherlands"
	elif [ "${H[12]}" = "DE" ]; then
		LAND="BE / Belgien"
	else 
		ORT="${H[12]} - ${H[10]} ${H[11]}"
	fi
fi
