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
				INIT_PATH="/etc/runit/sv" ;;
			void)
				INIT_PATH="/etc/sv" ;;
		esac
		SERVICE_FOLDER="nosystemd-swap"
		cp -rv ./runit ${INIT_PATH}/${SERVICE_FOLDER}
		;;
	dinit)
		INIT_PATH="/etc/dinit.d"
		SERVICE_FOLDER="nosystemd-swap-config"
		mkdir -p ${INIT_PATH}/${SERVICE_FOLDER}
		cp -v ./dinit/nosystemd-swap "${INIT_PATH}/"
 		;;
esac

CONF="${INIT_PATH}/${SERVICE_FOLDER}/swap.conf"

cp -v ./swap.conf "${CONF}"
