#!/bin/bash

# The install script for nosystemd-swap. 
# Currently supports runit, OpenRC, s6, and dinit.

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
		distro="$(grep -m 1 "^ID=" /etc/os-release | sed 's/^ID=//; s/\"//g')"
		case "${distro}" in
			artix)
				INIT_PATH="/etc/runit/sv" ;;
			void | devuan)
				INIT_PATH="/etc/sv" ;;
		esac
		SERVICE_FOLDER="nosystemd-swap"
		CONF="${INIT_PATH}/${SERVICE_FOLDER}/swap.conf"

		cp -rv ./runit ${INIT_PATH}/${SERVICE_FOLDER}
		;;
	dinit)
		INIT_PATH="/etc/dinit.d"
		CONF_FOLDER="nosystemd-swap-config"
		CONF="${INIT_PATH}/${CONF_FOLDER}/swap.conf"

		mkdir -p ${INIT_PATH}/${CONF_FOLDER}
		cp -v ./dinit/nosystemd-swap "${INIT_PATH}/"
 		;;
	openrc)
		INIT_PATH="/etc/init.d"
		CONF_FOLDER="/etc/conf.d/nosystemd-swap-config"
		CONF="${CONF_FOLDER}/swap.conf"

		mkdir -p ${CONF_FOLDER}
		cp -v ./openrc/nosystemd-swap "${INIT_PATH}/"
		;;
	s6)
		INIT_PATH="/etc/s6/sv"
		SERVICE_FOLDER="nosystemd-swap"
		CONF_FOLDER="/etc/s6/config"
		CONF="${CONF_FOLDER}/swap.conf"

		cp -rv ./s6 ${INIT_PATH}/${SERVICE_FOLDER}
		;;
esac

cp -v ./swap.conf "${CONF}"
