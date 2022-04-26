#!/bin/bash
# date: 2021/08/16
# auth: vera
# desc: fdisk mount umount


device=/dev/vdc
pv=${device}1
mnt=/data1


# lvm fdisk xfs
create_lvm(){
    yum install lvm2 -y &> /dev/null
    echo -e 'n\n\n\n\n\nt\n8e\nw\n' | sudo fdisk ${device}
    sudo pvcreate ${pv}
    
    ls /dev/mapper/ | grep vg0 || ls /dev/mapper/ |grep lv0
    if [ $? -eq 0 ];then
    echo -e "\033[31m vg0 or lv0 exists. \033[0m"
    exit 1
    fi
    
    sudo vgcreate vg0 ${pv}
    sudo lvcreate -n lv0 vg0 -l 100%VG
    sudo mkfs.xfs -n ftype=1 /dev/mapper/vg0-lv0
    
    ls ${mnt}
    if [ $? -eq 0 ];then
    echo -e "\033[31m ${mnt} exists. \033[0m"
    exit 1
    fi
    sudo mkdir -p ${mnt}
    
    cat /etc/fstab | grep vg0-lv0
    if [ $? != 0 ];then
    echo "/dev/mapper/vg0-lv0            ${mnt}               xfs        defaults              0 0" | sudo tee -a /etc/fstab
    fi
    sudo mount -a
    
    
    df -h | grep vg0
    if [ $? -eq 0 ];then
    echo -e "\033[31m vdb format to lvm successfully. \033[0m"
    fi
    
    df -h
}


remove_lvm(){
    umount ${mnt}
    sed -i '/\/dev\/mapper\/vg0-lv0/d' /etc/fstab 
    sudo lvreduce -l 100%VG /dev/vg0/lv0 
    echo -e "y\ny" | sudo vgremove /dev/vg0
    sudo pvremove ${pv}
    echo -e 'd\nw\n' | sudo fdisk ${device}
}


# create mkfs.ext4
create_mkfs(){
    # fs=ext4
    # sudo mkfs.ext4 ${device} 
    fs=xfs
    sudo mkfs.xfs -f -n ftype=1 ${device} 
    
    ls ${mnt}
    if [ $? -eq 0 ];then
    echo -e "\033[31m ${mnt} exists. \033[0m"
    exit 1
    fi
    sudo mkdir -p ${mnt}
    
    cat /etc/fstab | grep ${device}
    if [ $? != 0 ];then
    echo "${device}            ${mnt}               ${fs}        defaults              0 0" | sudo tee -a /etc/fstab
    fi
    sudo mount -a
    df -h
}


remove_mkfs(){
    sudo umount ${mnt}
    sed -i "/\/dev\/vdc/d" /etc/fstab 
    sudo rmdir ${mnt}    
    df -h
}


case $1 in
clvm)
    create_lvm;;
rlvm)
    remove_lvm;;
cfs)
    create_mkfs;;
rfs)
    remove_mkfs;;
*)
   echo "$0 clvm|rlvm|cfs|rfs"
esac
