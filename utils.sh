#!/bin/bash

source "$(dirname "$0")/passwords.sh"

# Ensure ADM1 and ADM2 are set
if [[ -z "$ADM1" ]]; then
  echo "ADM1 is empty. Exiting."
  exit 1
fi

if [[ -z "$ADM2" ]]; then
  echo "ADM2 is empty. Exiting."
  exit 1
fi

# Path to pySim-shell
PYSIM="../pysim/pySim-shell.py"

# Device path to your smart card reader (adjust as needed)
READER="0"

read_file_json() {
  local sim_path="$1"      # e.g. MF/ADF.USIM
  local file="$2"          # e.g. EF.IMSI
  local magic_string="MAGIC_STRING_MARKER"
  local tmpfile

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "select $sim_path"
    echo "select $file"
    echo "echo \"$magic_string\""
    echo "read_binary_decoded"
    echo "quit"
  } > "$tmpfile"

  # Run the pysim command and filter the output read_binary_decoded
  $PYSIM -p $READER --script "$tmpfile" | awk "/$magic_string/ {found=1; next} found"
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

#fsdump_json "MF/ADF.USIM" "EF.IMSI"
#read_file_json "MF/ADF.USIM" "EF.IMSI"
#read_file_json "MF/ADF.USIM" "EF.HPLMNwAcT"
#write_file_json "MF/ADF.USIM" "EF.IMSI" '{"imsi": "123456789123456"}'
#write_file_json "MF/ADF.USIM" "EF.IMSI" '{"imsi": "240993000005976"}'