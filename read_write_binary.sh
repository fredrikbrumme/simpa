#!/bin/bash

source "$(dirname "$0")/utils.sh"

read_imsi_raw() {
  local magic_string="MAGIC_STRING_MARKER"
  local tmpfile
  local raw_data

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    #echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "select MF/ADF.USIM"
    echo "apdu \"00A4000C026F07\"" # select EF_IMSI
    echo "echo \"$magic_string\""
    echo "apdu \"00B0000009\"" # read 9 bytes
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands
  raw_data=$($PYSIM -p $READER --script "$tmpfile" | awk "/$magic_string/ {found=1; next} found" | sed 's/.*RESP:[[:space:]]*//')
  echo $raw_data
  rm -f "$tmpfile"
}

write_ki_opc() {
  local ki="$1"    # e.g. Ki
  local opc="$2"   # e.g. OPc
  local tmpfile

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands
  $PYSIM -p $READER --script "$tmpfile" | sed -n 's/.*RESP:[[:space:]]*\([0-9A-Fa-f]*\).*/\1/p'
  rm -f "$tmpfile"
}

read_imsi_raw

#imsi=$(decode_apdu_hex "081020304050607080")
#echo "$imsi"

#write_ki_opc "00112233445566778899AABBCCDDEEFF" "00102030405060708090A0B0C0D0E0F0"
#fsdump_json "MF/ADF.USIM" "EF.IMSI"


