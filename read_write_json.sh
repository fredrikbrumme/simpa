#!/bin/bash

source "$(dirname "$0")/utils.sh"

read_file_json() {
  local sim_path="$1"      # e.g. MF/ADF.USIM
  local file="$2"          # e.g. EF.IMSI
  local output_marker="OUTPUT_MARKER"
  local tmpfile

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "select $sim_path"
    echo "select $file"
    echo "echo \"$output_marker\""
    echo "read_binary_decoded"
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands and extract the output
  $PYSIM -p $READER --script "$tmpfile" | awk "/$output_marker/ {found=1; next} found"
  rm -f "$tmpfile"
}

write_file_json() {
  local sim_path="$1"    # e.g. MF/ADF.USIM
  local file="$2"        # e.g. EF.IMSI
  local jsondata=$3      # JSON data to write
  local tmpfile

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "select $sim_path"
    echo "select $file"
    echo "update_binary_decoded '$jsondata'"
    echo "quit"
  } > "$tmpfile"

   # Run the pysim commands
  $PYSIM -p $READER --script "$tmpfile"
  rm -f "$tmpfile"
}

#read_file_json "MF/ADF.USIM" "EF.IMSI"
#write_file_json "MF/ADF.USIM" "EF.IMSI" '{"imsi": "123456789123456"}'
#write_file_json "SMF/ADF.USIM" "EF.IMSI" '{"imsi": "240993000005976"}'

#read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT"

#read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT"
#write_file_json "MF/ADF.USIM" "EF.HPLMNwAcT" '[{"mcc": "240","mnc": "99","act": ["NG-RAN"]},null]'

