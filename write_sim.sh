#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/read_write_binary.sh"
source "$(dirname "$0")/read_write_json.sh"

# RATs
technologies="NG-RAN"

if [[ $# -ne 6 ]]; then
  echo "Usage: $0 \"IMSI\" \"MCC\" \"MNC\" "SPN" \"Ki\" \"Opc\""
  echo "Example: $0 \"240990123456789\" \"240\" \"99\" \"OperatorName\" \"00112233445566778899AABBCCDDEEFF\" \"00102030405060708090A0B0C0D0E0F0\""
  exit 1
fi

# Card
OUTPUT=$(pcsc_scan -t 1)
#echo -e "OUTPUT:\n$OUTPUT"
CARD=$(echo "$OUTPUT" | awk '/Possibly identified card/ {getline; getline; print}' | tr -d '[:space:]' | sed 's/\x1b\[[0-9;]*m//g')

if [[ "$CARD" != *SmartjacSMAOT100* ]]; then
  echo "Card not supported"
  exit 1
fi

echo "<<<<<< Garage SIM Programme(simpa)"
sleep 1

echo "<<<<<< Writing IMSI=$1 to SIM card"
OUTPUT=$(write_file_json "MF/ADF.USIM" "EF.IMSI" "{\"imsi\": \"$1\"}")
#echo -e "OUTPUT:\n$OUTPUT"

echo "<<<<<< Writing MCC=$2 and MNC=$3 with RATs=$technologies to SIM card"
OUTPUT=$(write_file_json "MF/ADF.USIM" "EF.HPLMNwAcT" "[{\"mcc\": \"$2\",\"mnc\": \"$3\",\"act\": [\"$technologies\"]},null]")
#echo -e "OUTPUT:\n$OUTPUT"

echo "<<<<<< Writing SPN=$4 to SIM card"
OUTPUT=$(write_file_json "MF/ADF.USIM" "EF.SPN" "{\"rfu\": 0, \"hide_in_oplmn\": false,\"show_in_hplmn\": false,\"spn\": \"$4\"}")
echo -e "OUTPUT:\n$OUTPUT"

echo "<<<<<< Writing Ki=$5 and OPc=$6 to SIM card"
OUTPUT=$(write_ki_opc $5 $6)
#echo -e "OUTPUT:\n$OUTPUT"