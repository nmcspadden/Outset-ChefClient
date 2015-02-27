#!/bin/bash

# Stolen from PSU:
# https://wikispaces.psu.edu/display/clcmaclinuxwikipublic/First+Boot+Script

echo "Waiting for network access"
/usr/sbin/scutil -w State:/Network/Global/DNS -t 180
sleep 5

# Get the serial number
serial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
# If this is a VM in VMWare, Parallels, or Virtual Box, it might have weird serial numbers that Puppet doesn't like, so change it to something static
if [[ `system_profiler SPHardwareDataType | grep VMware` || `system_profiler SPHardwareDataType | grep VirtualBox` || `system_profiler SPEthernetDataType | grep "/0x1ab8/"` ]]; then
	# Remove any silly + or / symbols
	serial="${serial//[+\/]}"
fi

/usr/sbin/scutil --set HostName "$serial.sacredsf.org"
/usr/sbin/scutil --set LocalHostName "$serial.sacredsf.org"
/usr/sbin/scutil --set ComputerName "$serial.sacredsf.org"


/usr/bin/chef-client --runlist "recipe[x509::chef-ca]"