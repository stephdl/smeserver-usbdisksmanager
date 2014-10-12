#!/bin/bash
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root:/root/save.sh:/usr/local/bin:/sbin/e-smith
##. /etc/profile
##. /root/.bash_profile
DATEHEURE=`date +'%Y-%m-%d %H:%M:%S'`
#IFS="^M"
status_mediaG=$(/sbin/e-smith/db configuration getprop usbdisks status_mediaG)
status_mediaG=${status_mediaG:-'disabled'}
status_mediaU=$(/sbin/e-smith/db configuration getprop usbdisks status_mediaU)
status_mediaU=${status_mediaU:-'disabled'}
rm -f  /tmp/lecteurs

interdit=('/boot' '/etc'  '/lib' '/mnt' '/package' '/service' '/tmp' '/command'  '/home'   '/proc' \
 '/sbin' '/srv' '/usr' '/bin'  '/dev' '/initrd'  '/media' '/root' '/selinux' '/sys' '/var')
# liste des disques a surveiller + enable
db confusbdisks keys > /tmp/usbdisks_keys

##### les disuqes � surveiller 
for  UUID in $( cat /tmp/usbdisks_keys )     # pour chaque entr�e de usbdisks
do


 status=$( /sbin/e-smith/db confusbdisks getprop $UUID status )
#####auto mount_to
 if  [ $status == "enabled" ]  # si actif

 then
 montage=$(/sbin/e-smith/db confusbdisks getprop $UUID mountto)
 #verifier si ce montage est autoris�
  autorise=$(echo ${interdit[@]}|grep $montage)
  if [ -z "$autorise" ] && [ -e "$montage" ] 
   then # si le montage n'est pas sur un interdit  et existe
      ##echo  "OK $UUID "$montage
      ##echo  "OK $UUID "$(/sbin/e-smith/db confusbdisks getprop $UUID status)
      # est il connect�
      connected=$(blkid -t UUID=$UUID)
      if [ -z "$connected" ] # pas connect�
         then
              echo "$UUID : pas connect�"
         else #connect�
	 
             device=$(blkid -t UUID=$UUID |cut -f1 -d:)
             mounted=$(mount|grep "$device on $montage")
             if  [ -z "$mounted" ] # pas mont�
                 then
                      # UUID pas support� pour vfat
		      options=$(/sbin/e-smith/db confusbdisks getprop $UUID options) 
		      options=${options:-"pamconsole,exec,noauto,managed"}
		      #monter=$(mount -U $UUID  $montage -o pamconsole,exec,noauto,managed)
		      monter=$(mount $device -t auto  $montage -o $options)
                      if [ -n "$monter" ]
                         then
                             echo "echec montage : $UUID"
                      fi
                 else   #mont�
                     echo "$UUID : d�j� mont� rien � faire"
             fi # fin pas mont�
      fi # fin pas connect�
   else # si n'est pas autoris� ou existe pas
      echo "$UUID : $montage interdit ou inexistant"
  fi # fin de montage autoris�
 else # si inactiv�
  echo "$UUID => disabled rien � faire"
 fi
 
 
#####auto mount  media
 if [ $status_mediaG == "enabled" ] 
  then
  status_media=""
  status_media=$(/sbin/e-smith/db confusbdisks getprop $UUID status_media)
  status_media=${status_media:-"disabled"}
  if [ $status_media == "enabled" ] # si montage actif  pour ce disque
    then
      connected=$(blkid -t UUID=$UUID)
      if [ -z "$connected" ] # pas connect�
         then
              echo "$UUID : pas connect�"
         else #connect�
             device=$(blkid -t UUID=$UUID |cut -f1 -d:)
	     mounted=$(mount|grep "$device on /media")
             if  [ -z "$mounted" ] # pas mont�
                 then
                      # UUID pas support� pour vfat
		      monter=$(mount $device)
                      if [ -n "$monter" ]
                         then
                             echo "echec montage media : $UUID"
                      fi
                 else   #mont�
                     echo "$UUID : d�j� mont� en media rien � faire"
             fi # fin pas mont�
      fi # fin pas connect�    
  fi # si montage actif pour ce disque
 fi # si pas desactiv� globalement
 

 # ecriture  des lecteur connect�s

      connected=$(blkid -t UUID=$UUID)
      if [ -n "$connected" ] #
        then
	device=$(blkid -t UUID=$UUID |cut -f1 -d:)
        echo $device >>/tmp/lecteurs
      fi

done


# montage des disques non d�clar�s en auto dans media

if [ $status_mediaU == "enabled" ]
    then
    echo "on monte les disques "
    
    cat /etc/fstab |grep "/media/"|grep -v "/media/cd"|grep -v "/media/dvd"|cut -f1 -d" ">/tmp/usbdisks_mediaU
    for  LECTEUR in $( cat /tmp/usbdisks_mediaU )     # pour chaque entr�e de usbdisks
	do    
	present=$(cat /tmp/usbdisks_mediaU|grep $LECTEUR)
	if [ -z $present ]
	    then
	    #echo $LECTEUR
	    repertoire=$(cat /etc/fstab |grep "$LECTEUR"|awk '{print $2}')
	    #echo $repertoire
	    if [ -d $repertoire ]
		then
		mount $repertoire
	    fi
	    else
	    echo "$LECTEUR appartient � une regle connu on ne touche pas"    
	fi
	
	
    done
fi
