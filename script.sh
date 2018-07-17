#!/bin/bash

host="http://127.0.0.1:13002/wallet/v1"

TIMEFORMAT=%R

balance() {
	data="{ \"blockchain\": \"mongo\", \"account-id\": \"foobar${RANDOM}\" }"
	api="$host/balance"

	dfile="$(mktemp)"

	echo "$data" > "$dfile"
	echo -e "$(date +%F_%H:%M:%S)"
	echo "data: $data"

	{ time (curl -s -X POST \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' -d @$dfile "$api") ; } 2>> balance-times.csv

	rm -f "$dfile"
}

listall() {
	data="{ \"blockchain\": \"mongo\" }"
	api="$host/transactions/list"

	dfile="$(mktemp)"

	echo "$data" > "$dfile"
	echo -e "$(date +%F_%H:%M:%S)"
	echo "data: $data"

	{ time (curl -s -X POST \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' -d @$dfile "$api") ; } 2>> listall-times.csv

	rm -f "$dfile"
}

listacc() {
	data="{ \"blockchain\": \"mongo\", \"account-id\": \"foobar${RANDOM}\"  }"
	api="$host/transactions/list"

	dfile="$(mktemp)"

	echo "$data" > "$dfile"
	echo -e "$(date +%F_%H:%M:%S)"
	echo "data: $data"

	{ time (curl -s -X POST \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' -d @$dfile "$api") ; } 2>> listacc-times.csv

	rm -f "$dfile"
}

maketx() {
	data="{ \"blockchain\": \"mongo\", \"from-id\": \"foobar${RANDOM}\", \"to-id\": \"foobar${RANDOM}\", \"amount\": \"10\" }"
	api="$host/transactions/new"

	dfile="$(mktemp)"

	echo "$data" > "$dfile"
	echo -e "$(date +%F_%H:%M:%S)"	
	echo "data: $data"

	{ time  (curl -s -X POST \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' -d @$dfile "$api") ; } 2>> maketx-times.csv

	rm -f "$dfile"
}


[ -z "$1" ] && {
	cat <<EOF
usage: $(basename $0) [func]

available functions:

EOF
grep '() {$' $(basename $0) | awk -F '(' '{print $1}'
	exit 1
}

for i in $@; do
	if [ "$i" = -p ]; then
		parallel=1
	fi
done

[ -z "$NUM" ] && NUM=10

for i in $(seq 0 $NUM); do
	if [ -n "$parallel" ]; then
		$1 &
	else
		$1
	fi
done
