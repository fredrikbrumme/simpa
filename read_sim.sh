#!/bin/bash

source "$(dirname "$0")/utils.sh"

# Path to pySim-shell.py
PYSIM_SHELL="../pysim/pySim-shell.py --noprompt"

# Set reader type (pcsc, osmocom, etc.)
READER="0"

print_card_type() {
  pcsc_scan -t 2 | grep -v '^$' | tail -n 6 
}

# ATR
OUTPUT=$(pcsc_scan -t 1)
#echo "OUTPUT: $OUTPUT"
ATR=$(grep 'ATR' <<< "$OUTPUT" | head -n 1 | sed 's/^ *ATR: *//') 

# ICCID
OUTPUT=$(read_file_json "MF" "EF.ICCID")
#echo -e "OUTPUT:\n$OUTPUT"
ICCID=$(echo "$OUTPUT" | jq -r '.iccid')

# IMSI
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.IMSI")
#echo -e "OUTPUT:\n$OUTPUT"
IMSI=$(echo "$OUTPUT" | jq -r '.imsi')

# AD
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.AD")
#echo -e "OUTPUT:\n$OUTPUT"
MNC_LEN=$(echo "$OUTPUT" | jq -r '.mnc_len')

# SPN
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.SPN")
#echo -e "OUTPUT:\n$OUTPUT"
SPN=$(echo "$OUTPUT" | jq -r '.spn') 

# HPLMNwAcT
HPLMN=$(read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT")

#print_card_type 

# Printing results 
echo "<<<<<< Garage SIM Info >>>>>>"
#echo "Vendor: $(print_card_type)"
echo "ATR:     $ATR"
echo "ICCID:   $ICCID"
echo "IMSI:    $IMSI"
echo "MNC_LEN: $MNC_LEN"
echo "SPN:     $SPN"
#echo "HPLMN:  $HPLMN"