#!/bin/sh
set -ex

BASEFOLDER=./vm/
VMNAME=lab4

test -f ubuntu-16.04.6-server-amd64.iso || curl http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso > ubuntu-16.04.6-server-amd64.iso

VBoxManage unregistervm --delete ${VMNAME} || true
VBoxManage closemedium disk ${BASEFOLDER}/${VMNAME}.vdi --delete || true

VBoxManage createhd --filename ${BASEFOLDER}/${VMNAME}.vdi --size 10240

VBoxManage createvm --name ${VMNAME} --ostype Ubuntu_64 --register --basefolder ${BASEFOLDER}
VBoxManage modifyvm ${VMNAME} \
	--cpus 1 --memory 2048 --vram 12 \
	--audio none \
	--nic1 nat --natpf1 'ssh,tcp,,12223,,22' --natpf1 'www,tcp,,12224,,80' \
	--vrde on --vrdeport 10002 \
	--boot1 disk --boot2 dvd 

VBoxManage storagectl ${VMNAME} --name sata1 --add sata --controller IntelAhci
VBoxManage storageattach ${VMNAME} --storagectl sata1 --port 0 --device 0 --type hdd --medium ${BASEFOLDER}/${VMNAME}.vdi

VBoxManage storagectl ${VMNAME} --name ide1 --add ide
VBoxManage storageattach ${VMNAME} --storagectl ide1 --port 0 --device 0 --type dvddrive --medium ubuntu-16.04.6-server-amd64.iso

VBoxManage unattended install ${VMNAME} --iso ubuntu-16.04.6-server-amd64.iso --script-template=seed.conf --post-install-template=/dev/null

VBoxHeadless --startvm ${VMNAME}


