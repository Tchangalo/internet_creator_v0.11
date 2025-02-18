#!/bin/bash

if [[ $(df -T / | awk 'NR==2 {print $2}') == "zfs" ]]; then
    qm create 2000 --name "pfSense2" --ostype other --memory 1536 --cpu host --cores 2 --scsihw virtio-scsi-pci --virtio0 local-zfs:8,discard=on --net0 virtio,bridge=vmbr0,macaddr="00:24:18:0A:2B:DE"
    qm set 2000 --ide2 /var/lib/vz/template/iso/pfSense-CE-2.7.2-RELEASE-amd64.iso,media=cdrom
else
    qm create 2000 --name "pfSense2" --ostype other --memory 1536 --cpu host --cores 2 --scsihw virtio-scsi-pci --virtio0 local-btrfs:8,discard=on --net0 virtio,bridge=vmbr0,macaddr="00:24:18:0A:2B:DE"
    qm set 2000 --ide2 /var/lib/pve/local-btrfs/template/iso/pfSense-CE-2.7.2-RELEASE-amd64.iso,media=cdrom
fi

qm set 2000 --boot order=ide2