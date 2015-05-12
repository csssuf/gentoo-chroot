#!/bin/bash

set -euo pipefail

if [ ! $# -eq 1 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

if [ "$(id -u)" != "0" ]; then
	echo "Note: you will need to enter your sudo password when prompted, as you are not root."
	PREFIX="sudo "
else
	PREFIX=""
fi

if [ ! -d $1 ]; then
	echo "Error: Directory $1 doesn't exist."
	exit 1
fi

${PREFIX} umount $1/tmp
${PREFIX} umount $1/proc
${PREFIX} umount $1/sys

${PREFIX} umount $1/dev/{shm,pts,mqueue}
${PREFIX} umount $1/dev

echo -n "Destroy chroot files? (y/N) "
read destroy
case $destroy in
	[yY]*) ${PREFIX} rm -rf $1 ;;
	*) ;;
esac
