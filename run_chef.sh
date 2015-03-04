#!/bin/bash

# Stolen from PSU:
# https://wikispaces.psu.edu/display/clcmaclinuxwikipublic/First+Boot+Script

echo "Starting run: `date`" >> /var/log/chef_outset.log
echo "Waiting for network access" >> /var/log/chef_outset.log
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
/usr/sbin/scutil --set LocalHostName "$serial-sacredsf-org"
/usr/sbin/scutil --set ComputerName "$serial.sacredsf.org"

echo "Hostname: `/usr/sbin/scutil --get HostName`" >> /var/log/chef_outset.log
echo "LocalHostname: `/usr/sbin/scutil --get LocalHostName`" >> /var/log/chef_outset.log
echo "ComputerName: `/usr/sbin/scutil --get ComputerName`" >> /var/log/chef_outset.log


echo "Starting chef-client..." >> /var/log/chef_outset.log
/usr/bin/chef-client --force-logger -L /var/log/chef_outset.log -l debug --once --runlist "recipe[x509::munki2_client]"
echo "Finished chef-client." >> /var/log/chef_outset.log