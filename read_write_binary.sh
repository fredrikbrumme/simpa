#!/bin/bash

source "$(dirname "$0")/utils.sh"

CLA="00"
INS_READ_BINARY="B0"
INS_UPDATE_BINARY="D6"
INS_SELECT="A4"

# Smartjac Ki
FID_KI="6ffc"     # FID for Ki
P1_SELECT_KI="00"
P2_SELECT_KI="0C" # No response
LE_SELECT_KI="02"

P1_READ_KI="00"
P2_READ_KI="00"
LE_READ_KI="12" # Length of Ki + Checksum = 18 bytes

P1_UPDATE_KI="00"
P2_UPDATE_KI="00"
LE_UPDATE_KI="12" # Length of Ki + Checksum = 18 bytes

# Smartjac OPc
FID_OPC="6ffd"     # FID for OPc
P1_SELECT_OPC="00"
P2_SELECT_OPC="0C" # No response
LE_SELECT_OPC="02"

P1_READ_OPC="00"
P2_READ_OPC="00"
LE_READ_OPC="68" # Length of OPc + rotation/constants = 104 bytes 

P1_UPDATE_OPC="00"
P2_UPDATE_OPC="00"
LE_UPDATE_OPC="68" # Length of OPc + rotation/constants = 104 bytes

read_ki_raw() {
  local output_marker="OUTPUT_MARKER"
  local tmpfile
  local raw_data

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "verify_adm --pin-is-hex --adm-type ADM2 $ADM2"
    echo "select MF/ADF.USIM"
    echo "apdu \"$CLA$INS_SELECT$P1_SELECT_KI$P2_SELECT_KI$LE_SELECT_KI$FID_KI\"" # Select Ki
    echo "echo \"$output_marker\""
    echo "apdu \"$CLA$INS_READ_BINARY$P1_READ_KI$P2_READ_KI$LE_READ_KI\"" # Read Ki
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands
  raw_data=$($PYSIM -p $READER --script "$tmpfile" | awk "/$output_marker/ {found=1; next} found" | sed 's/.*RESP:[[:space:]]*//')
  echo $raw_data
  rm -f "$tmpfile"
}

read_opc_raw() {
  local output_marker="OUTPUT_MARKER"
  local tmpfile
  local raw_data

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "verify_adm --pin-is-hex --adm-type ADM2 $ADM2"
    echo "select MF/ADF.USIM"
    echo "apdu \"$CLA$INS_SELECT$P1_SELECT_OPC$P2_SELECT_OPC$LE_SELECT_OPC$FID_OPC\"" # Select Opc
    echo "echo \"$output_marker\""
    echo "apdu \"$CLA$INS_READ_BINARY$P1_READ_OPC$P2_READ_OPC$LE_READ_OPC\"" # Read Opc
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands
  raw_data=$($PYSIM -p $READER --script "$tmpfile" | awk "/$output_marker/ {found=1; next} found" | sed 's/.*RESP:[[:space:]]*//')
  echo $raw_data
  rm -f "$tmpfile"
}

write_ki_opc() {
  local ki="$1"
  local opc="$2"
  local tmpfile
  local output_marker="OUTPUT_MARKER"
  local checksum_ki=$(crc16_ccitt_hex "$ki")
  local checksum_opc=$(crc16_ccitt_hex "$opc")

  # Create a temporary script file for pySim-shell
  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "verify_adm --pin-is-hex --adm-type ADM1 $ADM1"
    echo "verify_adm --pin-is-hex --adm-type ADM2 $ADM2"
    echo "select MF/ADF.USIM"
    echo "echo \"$output_marker\""
    # Ki
    echo "apdu \"$CLA$INS_SELECT$P1_SELECT_KI$P2_SELECT_KI$LE_SELECT_KI$FID_KI\"" # Select Ki
    echo "apdu \"$CLA$INS_UPDATE_BINARY$P1_UPDATE_KI$P2_UPDATE_KI$LE_UPDATE_KI$ki$checksum_ki\"" # Write Ki
    # OPc
    echo "apdu \"$CLA$INS_SELECT$P1_SELECT_OPC$P2_SELECT_OPC$LE_SELECT_OPC$FID_OPC\"" # Select OPc
    echo "apdu \"$CLA$INS_UPDATE_BINARY$P1_UPDATE_OPC$P2_UPDATE_OPC$LE_UPDATE_OPC$PREFIX_OPC$opc$checksum_opc$SUFFIX_OPC\"" # Write OPc
    echo "quit"
  } > "$tmpfile"

  # Run the pysim commands
  $PYSIM -p $READER --script "$tmpfile" | awk "/$output_marker/ {found=1; next} found"
  rm -f "$tmpfile"
}