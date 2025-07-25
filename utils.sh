#!/bin/bash

# Path to pySim-shell
PYSIM="../pysim/pySim-shell.py"

# Device path to your smart card reader (adjust as needed)
READER="0"

keep_last_json_block() {
    awk '
    BEGIN { temp=""; in_json=0; last="" }
    /^\{/ { temp = $0; in_json = 1; next }
    in_json {
        temp = temp "\n" $0
        if ($0 ~ /^\}/) {
            last = temp
            in_json = 0
        }
    }
    END { print last }
    '
}

fsdump_json() {
  local sim_path="$1"      # e.g. MF/ADF.USIM
  local file="$2"          # e.g. EF.IMSI
  local tmpfile

  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "select $sim_path"
    echo "fsdump --filename $file --json"
    echo "quit"
  } > "$tmpfile"

  $PYSIM -p $READER --script "$tmpfile" | keep_last_json_block
  rm -f "$tmpfile"
}

read_file_json() {
  local sim_path="$1"      # e.g. MF/ADF.USIM
  local file="$2"          # e.g. EF.IMSI
  local tmpfile

  tmpfile=$(mktemp /tmp/pysim_script.XXXXXX)

  {
    echo "select $sim_path"
    echo "select $file"
    echo "read_binary_decoded"
    echo "quit"
  } > "$tmpfile"



  $PYSIM -p $READER --script "$tmpfile" | keep_last_json_block

  rm -f "$tmpfile"
}

#fsdump_json "MF/ADF.USIM" "EF.IMSI"

#read_file_json "MF/ADF.USIM" "EF.IMSI"