#!/bin/bash

## This is an example combined script for all events that ES triggers
## options separated with , are secondary arguments e.g (arg1; arg2; arg3)
## options separated with ; are single argument to choose from e.g (arg1, arg1, arg1)
#
# start
# game-start (rom, basename, name)
# game-end
# system-selected (name)
# game-selected (system-name, game-path, name)
# screensaver-start (screensaver_behavior)
# screensaver-stop
# theme-changed (new-theme, old-theme)
# sleep
# wake
# config-changed
# controls-changed
# settings-changed
# quit (and any one of these as second argument: restart; reboot; shutdown; nand; retroarch)


. /etc/profile

EVENT=${1}
shift

event_start() {
    echo "Started ES"
    }

event_game_start() {
    echo "Started game rom: ${1} basename ${2} name ${3}"
    }

event_screensaver_start() {
    echo "Starting Screen saver ${1}"
    }

event_quit(){
    case "${1}" in
		"restart")
		systemctl restart emustation
		;;	
    "reboot")
    echo "Rebooting!"
    ;;
    "shutdown")
		event_quit_shutdown
    ;;
    *)
    echo "Just quitting!"
		;;
		esac
}

event_quit_shutdown () {
	echo "Shutting down!"
	touch /tmp/shutdown.please
	systemctl stop emustation
	systemctl stop retroarch
	systemctl poweroff	
}

case "${EVENT}" in
    "start")
	event_start
	;;
    "game-start")
	event_game_start ${1} ${2} ${3}
	;;
    "screensaver-start")
    event_screensaver_start ${1}
	;;
    "quit")
    event_quit ${1} ${2} ${3}
	;;
    # and so and and so fort
    *)
	exit 1
esac

## You could also do something like this:

# event_${1} ${2} ${3} ${4}

## To call the event directly, but you need error checking.

exit 0
