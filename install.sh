#!/bin/bash

# The install script for nosystemd-swap. Currently only the runit and dinit init systems are supported. 
# Support for openrc and s6 will come in the near future.

# Make sure that this script is run with root permissions since it needs to copy over files to root-protected directories
if [ "$UID" != "0" ]; then
	echo "Be sure to run this script with root permissions! (either with sudo or doas)"
	exit 1
fi

cp -v ./nosystemd-swap /usr/bin/

# Find what the current init system is
INIT_SYSTEM="$(readlink /sbin/init | sed 's/-init//')"

case "${INIT_SYSTEM}" in
	runit)
		distro="$(grep -m 1 "ID=" /etc/os-release | sed 's/ID=//')"
		case "${distro}" in
			artix)
				CONF_PATH="/etc/runit/sv/" ;;
			void)
				CONF_PATH="/etc/sv/" ;;
		esac
		cp -rv ./runit "${CONF_PATH}/nosystemd-swap"
		;;
	dinit)
		CONF_PATH="/etc/dinit.d/"
		cp -rv ./dinit/* "${CONF_PATH}/nosystemd-swap"/
 		;;
esac

CONF="${CONF_PATH}/nosystemd-swap/swap.conf"

cp -v ./swap.conf "${CONF}"
