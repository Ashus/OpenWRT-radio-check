# OpenWRT-radio-check
A script that checks if OpenWRT wi-fi radio is still working and restarts it if neccessary.

*original checker logic taken from https://github.com/NilsRo/Openwrt-radio-check*
 
## Installation
SSH to your device and run the following commands:

    # download script (required)
    cd /etc/
    wget https://raw.githubusercontent.com/Ashus/OpenWRT-radio-check/main/radio-check.sh
    chmod +x radio-check.sh
    
    # enable cron (required)
    echo "*/15 * * * * /etc/radio-check.sh" >> /etc/crontabs/root
    /etc/init.d/cron reload
    
    # persist on upgrades (suggested)
    echo "/etc/radio-check.sh" >> /etc/sysupgrade.conf
    
    # change cron loglevel to Warnings only (suggested)
    uci set system.@system[0].cronloglevel='9'
    uci commit


## Notes
* Tested to be working well with OpenWRT version 22.03.x on 5 different hardware configurations.
* The script will check if the channel used by a radio matches the configured channel. So with DFS it will detect a fallback to channel 36 and also if wifi is turned off completely. If any of this is detected, radio is restarted to get it working again. With DFS channels this means the initial 1-minute wait for DFS check is initiated.
* Pay close attention to configuring the wi-fi radios. If you set something that can't be satisfied (wide channel close to the range edge, etc.), review your syslog and fix it before using this.
* This script will not work correctly if you use auto channel or with a list, please use a static channel configuration on all radios.
* You might want to lower cron loglevel in syslog to prevent this check to spam your syslog on every execution. Any case of wi-fi restart will be logged there anyway.
* The original version was fixed to radio0 and wlan0. This improved one gets the interface and radio names from system and iterates through them fixing all at once. Obviously it might not be of much use on 2.4 GHz range, but if you have a device with more 5 GHz radios or 6 GHz, it should work on them out of the box as well.
* This script is neccessary with OpenWRT as the version today will not try and switch back to DFS channel automatically and sometimes it simply hangs.
