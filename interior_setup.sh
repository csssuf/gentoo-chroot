#!/bin/bash

set -euo pipefail

env-update
source /etc/profile
emerge --sync
echo -n "Set new root password? (y/N) "
read newpw
case $newpw in
	[yY]*) passwd ;;
	*) ;;
esac
echo "Done."
