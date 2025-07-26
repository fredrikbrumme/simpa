#!/bin/bash

source "$(dirname "$0")/utils.sh"

# Path to pySim-shell.py
PYSIM_SHELL="../pysim/pySim-shell.py --noprompt"

# Set reader type (pcsc, osmocom, etc.)
READER="0"

echo "<<<<<< Garage SIM Programmer (SIMPa) >>>>>>"
sleep 1
echo "<<<<<< Reading SIM data...           >>>>>>"

# Card
# ATR
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

# HPLMNwAcT
OUTPUT=$(read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT")
#echo -e "OUTPUT:\n$OUTPUT"
HPLMN=$(echo "$OUTPUT" | jq -r '.hplmn')

#print_card_type 

# Printing results 
echo "CARD:    $CARD"
echo "ATR:     $ATR"
echo "ICCID:   $ICCID"
echo "IMSI:    $IMSI"
echo "MNC_LEN: $MNC_LEN"
echo "SPN:     $SPN"
echo "HPLMN:   $HPLMN"