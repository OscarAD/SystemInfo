#!/bin/sh
clear

if (( $EUID != 0 )); then
echo "Please run as root"
exit 0
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

echo "This script will show basic system information, use -d or --disk-usage"

elif [ $# -eq 0 ]; then

echo "*System Information*"
echo "Hostname: $(hostname)"
echo "Version: $((cat /etc/issue) | head -1)"
echo "Architecture: $(uname -m)"
echo "IP: `ifconfig eth0 | grep "inet addr:" | cut -d: -f2 | cut -d ' ' -f 1`" 
echo "User: $(whoami) (ID $(id -u))"
echo "Processes: `cat /proc/stat | grep procs_running | cut -d \  -f 2`"
echo "Users: `cat /etc/passwd |  cut -d:  -f1 | wc -w`"
echo "Cores:`cat /proc/cpuinfo | grep "cpu cores" | cut -d: -f2`"
echo "Total memory:`less /proc/meminfo | grep MemTotal | cut -d: -f2`"
echo "Installed packages: `rpm -qa | wc -l`"

else

echo "Enter right argument. For help/info pass -d or --help."

fi


if [ "$1" = "-d" ] || [ "$1" = "--disk-usage" ]; then
bash sysinfo.sh
awk -F":" '{print " User:" $1, " Home:" $6}' /etc/passwd | grep -v -E '(/usr|/var|/dev|/proc|/run|nobody|dbus|sbin)' | uniq > results.txt

mdir=`pwd`

awk -F":" '{print $3}' results.txt |  while read line; do

space=" "

cd $line
space=`du -s` 

cd $mdir

echo "Size:$space" >>size.txt

done

echo "Disk usage:"
paste results.txt size.txt | awk '{printf "%-20s %s\n", $1, $3}'| sort -n -k3| head -3

rm results.txt
rm size.txt

fi

exit 0
