#!/bin/bash
mkdir /opt/cloud_init
cd /opt/cloud_init
read -p "please instert your link for download : " url
ImageName=`echo "$url" | awk -F/ '{print $6}'`


if [ ! -f /opt/cloud_init/$ImageName ]
then
	echo "Downloding ...."
	wget $url
else
	echo "file exist "
	echo "are you sure download again? "
	select i in yes no
	do
		ask=$REPLY
		if [ $ask -eq 1 ]
		then
			wget $url
		else
			echo "thanx"
		fi
			break
		done
fi

var1=$(echo $ImageName | cut -f1 -d.)

#Also install additional packages needed to manage cloud-images:

sudo apt-get install -y cloud-image-utils

#create snapshot and make it 10G
qemu-img create -b $ImageName -f qcow2 -F qcow2 snapshot-$var1.qcow2 10G

# show snapshot info
qemu-img info snapshot-$var1.qcow2


read -p "please instert your public ssh key : " pubsshkey

cat <<EOF >cloud_init.cfg
#cloud-config
hostname: abrnoc
fqdn: abrnoc.com
manage_etc_hosts: true
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/ubuntu
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - $pubsshkey
# only cert auth via ssh (console access can still login)
ssh_pwauth: false
disable_root: false
chpasswd:
  list: |
     ubuntu:linux
  expire: False

package_update: true
packages:
  - qemu-guest-agent
# written to /var/log/cloud-init-output.log
final_message: "The system is finally up, after $UPTIME seconds"
EOF



cat <<EOF > network_config_static.cfg
version: 2
ethernets:
  ens3:
     dhcp4: false
     # default libvirt network
     addresses: [ 192.168.122.158/24 ]
     gateway4: 192.168.122.1
     nameservers:
       addresses: [ 192.168.122.1,8.8.8.8 ]
       search: []
EOF


# insert network and cloud config into seed image
cloud-localds -v --network-config=network_config_static.cfg test1-seed.img cloud_init.cfg

# show seed disk just generated

qemu-img info test1-seed.img

read -p "plese insert your vm name : " vmname
virt-install --name $vmname \
  --virt-type kvm --memory 2048 --vcpus 2 \
  --boot hd,menu=on \
  --disk path=test1-seed.img,device=cdrom \
  --disk path=snapshot-$var1.qcow2,device=disk \
  --graphics vnc \
  --os-type Linux --os-variant ubuntu18.04 \
  --network network:default \
  --console pty,target_type=serial
