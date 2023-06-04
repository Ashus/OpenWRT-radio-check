#!/bin/sh

# Universal radio check script by Ashus (2023)
# source: https://github.com/Ashus/OpenWRT-radio-check

. /usr/share/libubox/jshn.sh

check_and_restart_radio_iface() {
	local radio="$1"
	local iface="$2"
	
	check=$(iw dev $iface info|awk '/channel/{print $2}')
	
	if [[ -z $check ]]
	then
		logger -p notice -t radio_check "Wifi '$radio'/'$iface' restart because of DFS bug!"
		wifi down $radio
		sleep 2
		wifi up $radio
	else
		if [[ "$(uci get wireless.$radio.channel)" -ne $check ]]
		then
			logger -p notice -t radio_check "Wifi '$radio'/'$iface' restart because of channel!"
			wifi down $radio
			sleep 2
			wifi up $radio
		fi
	fi
}

wirelessconfig="$(ubus call network.wireless status)"
json_init
json_load "$wirelessconfig"
json_get_keys radios
for radio in $radios; do
	iface=$(jsonfilter -s "$wirelessconfig" -e "@.$radio.interfaces[0].ifname")
	check_and_restart_radio_iface "$radio" "$iface"
done
