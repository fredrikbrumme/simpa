#!/bin/bash

source "$(dirname "$0")/utils.sh"

# Path to pySim-shell.py
PYSIM_SHELL="../pysim/pySim-shell.py --noprompt"

# Set reader type (pcsc, osmocom, etc.)
READER="0"

if [[ -z "$1" ]]; then
  echo "Usage: $0 \"IMSI\""
  echo "Example: $0  \"240993000005976\""
  exit 1
fi

echo "<<<<<< Garage SIM Programmer (SIMPa)"
sleep 1

echo "<<<<<< Writing IMSI=$1 to SIM card..."
write_file_json "MF/ADF.USIM" "EF.IMSI" "{\"imsi\": \"$1\"}"