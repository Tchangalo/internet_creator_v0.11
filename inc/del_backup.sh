#!/bin/bash

provider=$1
first_router=$2
last_router=$3

C='\033[0;94m'
G='\033[0;32m'
L='\033[38;5;135m'
NC='\033[0m'

if [ -z "$provider" ] || [ -z "$first_router" ] || [ -z "$last_router" ]; then
    echo -e "${R}Error: At least one variable empty!${NC}"
    exit 1
fi

if [[ $(df -T / | awk 'NR==2 {print $2}') == "zfs" ]]; then	
	for i in $(seq $first_router $last_router); do
		vm_id=${provider}0${provider}0$(printf '%02d' $i)
		img_dir="/dev/zvol/rpool/data"
		# Check, if image with VMID exists in img_dir
		if ! ls "$img_dir" | grep -q "^vm-${vm_id}-disk-"; then
			echo -e "${R}Error: VM $vm_id does not exist!${NC}"
			exit 1
		fi
		if [[ "$i" == "$first_router" ]]; then
			echo -e "${C}Deleting ALL existing backups${NC}"
			if [[ -d "/var/lib/vz/dump" ]]; then
        		sudo rm -rf /var/lib/vz/dump
    		fi
			sudo mkdir -p /var/lib/vz/dump	
		fi
		echo -e "${C}Backing up router ${vm_id}${NC}"
		sudo vzdump ${provider}0${provider}00$i --dumpdir /var/lib/vz/dump --mode snapshot --compress zstd
	done
else
	for i in $(seq $first_router $last_router); do
		vm_id=${provider}0${provider}0$(printf '%02d' $i)
		img_dir="/var/lib/pve/local-btrfs/images"
		if ! ls "$img_dir" | grep -q "^${vm_id}.*"; then
			echo -e "${R}Error: VM $vm_id does not exist!${NC}"
			exit 1
		fi
		if [[ "$i" == "$first_router" ]]; then
			echo -e "${C}Deleting ALL existing backups${NC}"
			if [[ -d "/var/lib/pve/local-btrfs/dump" ]]; then
        		sudo rm -rf /var/lib/pve/local-btrfs/dump
    		fi
			sudo mkdir -p /var/lib/pve/local-btrfs/dump
		fi
		echo -e "${C}Backing up router ${vm_id}${NC}"
		sudo vzdump ${provider}0${provider}00$i --dumpdir /var/lib/pve/local-btrfs/dump --mode snapshot --compress zstd
	done
fi

if [[ $first_router == $last_router ]]; then
	echo -e "${G}Deletion of ALL existing backups and backup of router ${L}p${provider}r${first_router}v${G} executed successfully!${NC}"
else
	echo -e "${G}Deletion of ALL existing backups and backups of routers ${L}p${provider}r${first_router}v${G} to ${L}p${provider}r${last_router}v${G} executed successfully!${NC}"
fi
