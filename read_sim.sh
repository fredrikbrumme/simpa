#!/bin/bash

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/read_write_binary.sh"
source "$(dirname "$0")/read_write_json.sh"

echo "<<<<<< Garage SIM Programmer (simpa)"
sleep 1
echo "<<<<<< Reading SIM data..."

# Card + ATR
OUTPUT=$(pcsc_scan -t 1)
#echo -e "OUTPUT:\n$OUTPUT"
CARD=$(echo "$OUTPUT" | awk '/Possibly identified card/ {getline; getline; print}' | tr -d '[:space:]' | sed 's/\x1b\[[0-9;]*m//g')
ATR=$(echo "$OUTPUT" | grep 'ATR' | head -n 1 | sed 's/^ *ATR: *//') 

# ICCID
OUTPUT=$(read_file_json "MF" "EF.ICCID")
#echo -e "OUTPUT:\n$OUTPUT"
ICCID=$(echo "$OUTPUT" | jq -r '.iccid')

# IMSI
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.IMSI")
#echo -e "OUTPUT:\n$OUTPUT"
IMSI=$(echo "$OUTPUT" | jq -r '.imsi')

# MNC_LEN
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.AD")
#echo -e "OUTPUT:\n$OUTPUT"
MNC_LEN=$(echo "$OUTPUT" | jq -r '.mnc_len')

# SPN
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.SPN")
#echo -e "OUTPUT:\n$OUTPUT"
SPN=$(echo "$OUTPUT" | jq -r '.spn') 
HIDE_IN_OPLMN=$(echo "$OUTPUT" | jq -r '.hide_in_oplmn')
SHOW_IN_HPLMN=$(echo "$OUTPUT" | jq -r '.show_in_hplmn')

# HPLMNwAcT
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT")
#echo -e "OUTPUT:\n$OUTPUT"
HPLMN_MCC=$(echo "$OUTPUT" | jq -r 'map(select(. != null))[0].mcc')
HPLMN_MNC=$(echo "$OUTPUT" | jq -r 'map(select(. != null))[0].mnc')
HPLMN_ACT=$(echo "$OUTPUT" | jq -r 'map(select(. != null))[0].act' | tr -d '[:space:]')

# UST
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.UST")
#echo -e "OUTPUT:\n$OUTPUT"
SERVICES=$(echo "$OUTPUT" | jq -r 'to_entries[] | select(.value.activated == true) | .value.description')

# SUCI calculation by the USIM support
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.UST")
#echo -e "OUTPUT:\n$OUTPUT"
SERVICE125=$(echo "$OUTPUT" | jq -r 'to_entries[] | select(.value.activated == true) | .value.description' | grep "125")
if [[ -z "$SERVICE125" ]]; then
  SERVICE125="Not supported"
else
  SERVICE125=$(echo "$SERVICE125" | sed 's/125 //')
fi

# Printing results
echo "CARD:     $CARD"
echo "ATR:      $ATR"
echo "ICCID:    $ICCID"
echo "IMSI:     $IMSI"
echo "MNC_LEN:  $MNC_LEN"
#echo "SPN:      $SPN"
echo "SPN:      $SPN (hide_in_oplmn: $HIDE_IN_OPLMN, show_in_hplmn: $SHOW_IN_HPLMN)"
echo "HPLMN:    $HPLMN_MCC $HPLMN_MNC AcT: $HPLMN_ACT"
echo "SUCI:     SUCI by USIM $SERVICE125"
echo "Services: $(echo "$SERVICES" | wc -l)"
#echo ""
#echo "=== Services ==="
#echo "$SERVICES"