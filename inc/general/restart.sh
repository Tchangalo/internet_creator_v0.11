#!/bin/bash

provider=$1
first_router=$2
last_router=$3
start_delay=$4

C='\033[0;94m'
R='\033[91m'
NC='\033[0m'

if [ -z "$provider" ] || [ -z "$first_router" ] || [ -z "$last_router" ] || [ -z "$start_delay" ]; then
    echo -e "${R}Error: At least one variable is empty!${NC}"
    exit 1
fi

for i in $(seq $first_router $last_router); do 
   sudo qm shutdown ${provider}0${provider}00$i
   sudo qm start ${provider}0${provider}00$i
   sleep $start_delay
done

# if [[ $first_router == $last_router ]]; then
# 	echo -e "${C}Restart of router p${provider}r${first_router}v executed successfully!${NC}"
# else
# 	echo -e "${C}Restart of routers p${provider}r${first_router}v to p${provider}r${last_router}v executed successfully!${NC}"
# fi