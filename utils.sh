#!/bin/bash

source "$(dirname "$0")/secrets.sh"

# Ensure ADM1 and ADM2 are set
if [[ -z "$ADM1" ]]; then
  echo "ADM1 is empty. Exiting."
  exit 1
fi

if [[ -z "$ADM2" ]]; then
  echo "ADM2 is empty. Exiting."
  exit 1
fi

# Ensure ADM1 and ADM2 are set
if [[ -z "$PREFIX_OPC" ]]; then
  echo "PREFIX_OPC is empty. Exiting."
  exit 1
fi

if [[ -z "$SUFFIX_OPC" ]]; then
  echo "SUFFIX_OPC is empty. Exiting."
  exit 1
fi

# Path to pySim-shell
PYSIM="../pysim/pySim-shell.py"

# Device path to your smart card reader (adjust as needed)
READER="0"

crc16_ccitt_hex() {
  local hex_input="$1"
  python3 -c "import libscrc; print(format(libscrc.ccitt_false(bytes.fromhex('$hex_input')), 'x'))"
}

decode_apdu_hex() {
   local hex_apdu="$1"
   local hex_decoded

   # Skip the first byte (length), then decode each nibble
   hex_decoded=""
   for ((i=2; i<${#hex_apdu}; i+=2)); do
      byte=${hex_apdu:$i:2}
      # High nibble first, then low nibble
      digit1=${byte:1:1}
      digit2=${byte:0:1}
      [[ "$digit1" != "F" ]] && hex_decoded+="$digit1"
      [[ "$digit2" != "F" ]] && hex_decoded+="$digit2"
   done

   echo "$hex_decoded"
}

encode_apdu_hex() {
  local hex_input="$1"

  # Ensure input is lowercase and remove spaces
  hex_input=$(echo "$hex_input" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

  # Validate hex input
  if ! [[ "$hex_input" =~ ^[0-9a-f]+$ ]]; then
    echo "Invalid hex input: $hex_input"
    return 1
  fi
  # Ensure input is even length
  if (( ${#hex_input} % 2 != 0 )); then
    echo "Hex input must have an even number of characters: $hex_input"
    return 1
  fi
  # Ensure input is not empty
  if [[ -z "$hex_input" ]]; then
    echo "Hex input cannot be empty"
    return 1
  fi
  # Ensure input is not too long
  if (( ${#hex_input} > 128 )); then
    echo "Hex input is too long (max 128 characters): $hex_input"
    return 1
  fi
  # Ensure input is not too short
  if (( ${#hex_input} < 2 )); then
    echo "Hex input is too short (min 2 characters): $hex_input"
    return 1
  fi

  local swapped=""
  for ((i=0; i<${#hex_input}; i+=2)); do
    local byte="${hex_input:i:2}"
    local high="${byte:0:1}"
    local low="${byte:1:1}"
    swapped+="${low}${high}"
  done

  local length=$(( ${#hex_input} / 2 ))
  local length_hex=$(printf "%02X" "$length")

  echo "${length_hex}${swapped}"
}