# simpa
SIM Programmer using pysim

# Requirements
- pysim
- jq

Passwords (pin) for ADM1 and ADM2 stored in local file ./passwords.sh 
```
cat << 'EOF' > passwords.sh
#!/bin/bash

ADM1="1234"
ADM2="5678"
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

