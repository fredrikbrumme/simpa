#!/bin/bash

source "$(dirname "$0")/utils.sh"

# RATs
technologies="NG-RAN"

if [[ $# -ne 5 ]]; then
  echo "Usage: $0 \"IMSI\" \"MCC\" \"MNC\" \"Ki\" \"Opc\""
  echo "Example: $0 \"240993000005976\" \"241\" \"99\" \"00112233445566778899AABBCCDDEEFF\" \"00102030405060708090A0B0C0D0E0F0\""
  exit 1
fi

echo "<<<<<< Garage SIM Programmer (simpa)"
sleep 1

echo "<<<<<< Writing IMSI=$1 to SIM card"
OUTPUT=$(write_file_json "MF/ADF.USIM" "EF.IMSI" "{\"imsi\": \"$1\"}")
#echo -e "OUTPUT:\n$OUTPUT"

echo "<<<<<< Writing MCC=$2 and MNC=$3 to SIM card"
OUTPUT=$(write_file_json "MF/ADF.USIM" "EF.HPLMNwAcT" "[{\"mcc\": \"$2\",\"mnc\": \"$3\",\"act\": [\"$technologies\"]},null]")
#echo -e "OUTPUT:\n$OUTPUT"

#echo "<<<<<< Writing Ki=$4 and OPc=$5 to SIM card"
#