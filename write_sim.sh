#!/bin/bash

source "$(dirname "$0")/utils.sh"

# Path to pySim-shell.py
PYSIM_SHELL="../pysim/pySim-shell.py --noprompt"

# Set reader type (pcsc, osmocom, etc.)
READER="0"

echo "<<<<<< Garage SIM Programmer (SIMPa) >>>>>>"
sleep 1
echo "<<<<<< Writing SIM data...           >>>>>>"