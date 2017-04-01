#!/bin/bash

# simple backup script for the office PC
bkupdir=/home/user/backup
otherdir=(
    "/home/user/Downloads/"
    "/home/user/pictures/"
    "/home/user/documents/"
    "/home/user/workspace/"
)
thisbkupdir=`date +%Y.%m.%d`
activeUser=`whoami`
remotedir=/srv/samba/fileserver/bkup/computers/office_pc_arch/$thisbkupdir

if [ ! -d "$bkupdir" ]; then
	mkdir $bkupdir;
fi

if [ ! -d "$bkupdir/$thisbkupdir" ]; then
    mkdir "$bkupdir/$thisbkupdir";
fi

cd "$bkupdir/$thisbkupdir"

sudo -s <<EOF
rsync -aAXv --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} / .
tar cvfz "rsyncbkup.tgz" *
find . -not -name "*tgz" -delete
chmod 777 "rsyncbkup.tgz"
chown -R $activeUser:$activeUser ..
EOF

for i in ${otherdir[*]}; do
    tarfile=`echo $i | cut -d "/" -f4`
    tarfile="$tarfile.tgz"
    tar cvfz "$tarfile" "$i"
done

tar cvf "backup.$thisbkupdir.tar" *
rm *.tgz

ssh sysop@fileserver mkdir -p $remotedir
scp "backup.$thisbkupdir.tar" sysop@fileserver:$remotedir
