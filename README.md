# simpa
SIM Programmer using pysim

# Requirements
- [pysim](https://osmocom.org/projects/pysim/wiki)
- jq

# Setup
```
sudo apt install pcsc-tools
```
Passwords (pin) for ADM1 and ADM2 stored in local file ./secrets.sh 
```
cat << 'EOF' > secrets.sh
#!/bin/bash

ADM1="1234"
ADM2="5678"
PREFIX_OPC="1234"
SUFFIX_OPC="5678"
EOF
```
# read SIM
```
./read_sim.sh
```
# write SIM
```
./write_sim.sh "123456789123456"
```

