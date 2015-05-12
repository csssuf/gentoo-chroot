#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
	echo "Usage: $0 <directory> [make.conf]" 1>&2
	exit 1
fi

if [ "$(id -u)" != "0" ]; then
	echo "Note: you will need to enter your sudo password when prompted, as you are not root."
	PREFIX="sudo "
else
	PREFIX=""
fi

if [ ! -d $1 ]; then
	echo -n "Directory $1 doesn't exist. Create it now? (y/N) "
	read create
	case $create in
		[yY]*) ${PREFIX} mkdir -p $1 ;;
		*) exit 1 ;;
	esac
fi

pushd $(pwd)
cd $1

url="http://distfiles.gentoo.org/releases/amd64/autobuilds/$(curl http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt | tail -n1 | cut -d' ' -f 1)"
filename=$(echo -n $url | cut -d'/' -f 8)
${PREFIX} wget $url
${PREFIX} wget http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2
${PREFIX} tar xvjpf $filename -C $1
${PREFIX} tar xvjf portage-latest.tar.bz2 -C $1/usr

popd

${PREFIX} mount -o rbind /dev $1/dev
${PREFIX} mount -t proc none $1/proc
${PREFIX} mount -o bind /sys $1/sys
${PREFIX} mount -o bind /tmp $1/tmp

if [ $# -eq 2 ]; then
	${PREFIX} cp $2 $1/etc/portage/make.conf
else
	${PREFIX} bash -c "cat /etc/portage/make.conf | grep -v layman | grep -v PORTDIR_OVERLAY > $1/etc/portage/make.conf"
fi
${PREFIX} cp /etc/resolv.conf $1/etc/resolv.conf
${PREFIX} cp interior_setup.sh $1/root/

${PREFIX} chroot $1 /root/interior_setup.sh

echo -n "Enter chroot? (Y/n) "
read enter
case $enter in
	[nN]*) exit ;;
	*) chroot $1 /bin/bash ;;
esac
