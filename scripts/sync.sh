#!/bin/bash
# name me /root/sync.sh and run me under root (sudo su) user with: screen -d -m /root/sync.sh

# insert simulated flash drive
modprobe g_mass_storage file=~/FlashDrive.bin ro=y removable=y

# mount simulated flash drive 1st partition contents locally for rclone
# to find partition offset: fdisk -l ~/FlashDrive.bin and multiply start sector by 512
mount -o offset=1024 ~/FlashDrive.bin ~/FlashDrive

# run forever
while true
do
  NOCHANGES=`rclone -v sync gdrive: ~/FlashDrive/ 2>&1 | grep -c "Transferred:          0 Bytes"`
  sync # !!! syncs rclone changes to simulated flash drive avoiding memory cache of new files
  if [$NOCHANGES -gt 0]
  then
        # unchanged
        echo "$(date) unchanged"
        sleep 2 # TODO: adjust seconds to not to poll Google Drive API too often.
  else
        # changed - reinsert simulated flash drive
        echo "$(date) new files added!"
        rmmod g_mass_storage
        modprobe g_mass_storage file=~/FlashDrive.bin ro=y removable=y
  fi
done
