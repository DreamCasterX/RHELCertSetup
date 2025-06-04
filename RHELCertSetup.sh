#!/usr/bin/env bash


# CREATOR: Mike Lu
# CHANGE DATE: 6/4/2025
__version__="1.0"


# Red Hat Enterprise Linux Hardware Certification Test Environment Setup Script
# Run this script after RHEL boot on both the SUT and TC

# Prerequisites for both SUT and TC:
# 1) Boot to GA ISO
#    a) Set up an admin account
#         - Root account : Allow SSH login
#         - User account : Enable administrator access
#         - Ensure kdump is enabled
#    b) Connect to Internet and register with Red-Hat partner account (optional)
# 2) Boot to OS 
#    a) Assign an IP to SUT & TC. Make sure you can ping SUT <-> TC successfully


# User-defined settings
TIME_ZONE='Asia/Taipei'


# GA kernel list
GA_KERNEL_8_10='4.18.0-553.el8_10'
GA_KERNEL_9_4='5.14.0-427.13.1.el9_4'
GA_KERNEL_9_5='5.14.0-503.11.1.el9_5'
GA_KERNEL_9_6='5.14.0-570.12.1.el9_6'
GA_KERNEL_10_0='6.12.0-55.9.1.el10_0'


# Color settings
green='\e[32m'
yellow='\e[93m'
nc='\e[0m'


# Ensure the user is running the script as root
if [ "$EUID" -ne 0 ]; then 

    # Copy the latest test result file to the current directory (Run as User)
    if [[ -d /var/rhcert/save ]]; then 
        XmlLog=`sudo ls -t /var/rhcert/save/*xml | head -1`
        XmlLogName=$(basename "$XmlLog")
        sudo cp $XmlLog ./ 2> /dev/null && echo -e "💾 "$XmlLogName" has been saved to the current directory$\n"
    fi
    echo "⚠️ Please run as root (sudo su) to start the installation."
    exit 1
fi

# Customize keyboard shortcut
USERNAME=$(logname)
OS_VERSION=`cat /etc/os-release | grep ^VERSION_ID= | awk -F= '{print $2}' | cut -d '"' -f2 | cut -d '.' -f1`
ID=`id -u $USERNAME`
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"

# Open Terminal (Ctrl+Alt+T)
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'     
if [[ $OS_VERSION == "10" ]]; then
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'ptyxis'
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'   
else
    sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal' 
fi
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<ctrl><alt>t' 

# Open Current folder (Super+E)
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Current folder' 
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nautilus .' 
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<super>e' 

# Open Settings (Super+I)
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Settings' 
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-control-center' 
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<super>i'


# Set proxy to automatic
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.system.proxy mode 'auto' 2> /dev/null


# Disable auto suspend/dim screen/screen blank/auto power-saver
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing" 2> /dev/null
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type "nothing" 2> /dev/null
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power idle-dim "false" 2> /dev/null
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.session idle-delay "0" > /dev/null 2> /dev/null
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery "false" 2> /dev/null


# Show battery percentage
sudo -H -u $USERNAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$ID/bus gsettings set org.gnome.desktop.interface show-battery-percentage "true" 2> /dev/null


# Enable SSH and disable firewall
! systemctl status sshd | grep 'running' > /dev/null && systemctl enable sshd && systemctl start sshd
systemctl status firewalld | grep 'running' > /dev/null && systemctl stop firewalld && systemctl disable firewalld

   
# Set time zone and reset NTP
CURRENT_TIME_ZONE=$(timedatectl status | grep "Time zone" | awk '{print $3}')
if [ "$CURRENT_TIME_ZONE" != "$TIME_ZONE" ]; then
    sudo timedatectl set-timezone $TIME_ZONE
    sudo ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
    sudo timedatectl set-ntp 0 && sleep 1 && timedatectl set-ntp 1
fi


# Ensure Internet is connected
CheckInternet() {
    nslookup "google.com" > /dev/null
    if [ $? != 0 ]; then 
        echo "❌ No Internet connection! Please check your network" && sleep 5 && exit 1
    fi
}
CheckInternet

# Check the latest update of this script
UpdateScript() {
    release_url=https://api.github.com/repos/DreamCasterX/RHELCertSetup/releases/latest
    new_version=$(curl -s "${release_url}" | grep '"tag_name":' | awk -F\" '{print $4}')
    release_note=$(curl -s "${release_url}" | grep '"body":' | awk -F\" '{print $4}')
    tarball_url="https://github.com/DreamCasterX/RHELCertSetup/archive/refs/tags/${new_version}.tar.gz"
    if [[ $new_version != $__version__ ]]; then
        echo -e "⭐️ New version found!\n\nVersion: $new_version\nRelease note:\n$release_note"
        sleep 2
        echo -e "\nDownloading update..."
        pushd "$PWD" > /dev/null 2>&1
        curl --silent --insecure --fail --retry-connrefused --retry 3 --retry-delay 2 --location --output ".RHELCertSetup.tar.gz" "${tarball_url}"
        if [[ -e ".RHELCertSetup.tar.gz" ]]; then
            tar -xf .RHELCertSetup.tar.gz -C "$PWD" --strip-components 1 > /dev/null 2>&1
            rm -f .RHELCertSetup.tar.gz
            rm -f README.md
            popd > /dev/null 2>&1
            sleep 3
            sudo chmod 755 RHELCertSetup.sh
            echo -e "Successfully updated! Please run RHELCertSetup.sh again.\n\n" ; exit 1
        else
            echo -e "\n❌ Error occurred while downloading" ; exit 1
        fi 
    fi
}
UpdateScript


# Disable OCSP stapling (workaround for not being able to utilize NTP) 
cat /var/log/rhsm/rhsm.log | grep "Clock skew detected" > /dev/null
if [ $? == 0 ]; then 
    REPOS=$(awk '/^\[/ {gsub(/[\[\]]/, "", $0); printf("--repo %s ", $0)}'  /etc/yum.repos.d/redhat.repo)
    sudo subscription-manager repo-override --add sslverifystatus:0 $REPOS   # Revert: sudo subscription-manager repo-override --remove-all
fi

  
# Get system type from user
echo "╭─────────────────────────────────────────────────────────╮"
[[ $OS_VERSION == [89] ]] && echo "│    RHEL $OS_VERSION System Certification Test Environment Setup   │" || echo "│    RHEL $OS_VERSION System Certification Test Environment Setup  │"
echo "╰─────────────────────────────────────────────────────────╯"
KERNEL=$(uname -r)
CPU_info=`grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2`
MEM_info=`sudo dmidecode -t memory | grep -i size | grep -v "No Module Installed" | awk '{sum += $2} END {print sum " GB"}'`
storage_info=`sudo parted -l | grep "Disk /dev/" | grep -v "loop" | awk '{sum += $3} END {print sum " GB"}'`
product_name=`cat /sys/class/dmi/id/product_name`
echo
echo -e "Product Name: ${yellow}"$product_name"${nc}"
echo -e "CPU:${yellow}"$CPU_info"${nc}"
echo -e "DIMM: ${yellow}"$MEM_info"${nc}"
echo -e "Storage: ${yellow}"$storage_info"${nc}"
echo -e "Kernel: ${yellow}"$KERNEL"${nc}"
echo
echo "Are you setting up a SUT or TC?"
read -p "(s)SUT   (t)TC: " TYPE
while [[ "$TYPE" != [SsTt] ]]; do 
    read -p "(s)SUT   (t)TC: " TYPE
done 


# Check system registration status
if rhc status | grep -w 'Not connected to Red Hat Subscription Management' > /dev/null; then
    echo
    echo "----------------------"
    echo "REGISTERING  SYSTEM..."
    echo "----------------------"
    echo
    ! rhc connect && exit 1
    subscription-manager refresh
fi
echo -e "\n${green}Done!${nc}\n" 
       
    
# Enable the Red Hat Enterprise Linux Repositories
echo
echo "-----------------"
echo "ENABLING REPOS..."
echo "-----------------"
echo
cert="cert-1-for-rhel-$OS_VERSION-$(uname -m)-rpms"
baseos="rhel-$OS_VERSION-for-$(uname -m)-baseos-rpms"
baseos_debug="rhel-$OS_VERSION-for-$(uname -m)-baseos-debug-rpms"
appstream="rhel-$OS_VERSION-for-$(uname -m)-appstream-rpms"
appstream_debug="rhel-$OS_VERSION-for-$(uname -m)-appstream-debug-rpms"
for repo in $cert $baseos $baseos_debug $appstreamo $appstream_debug; do
    if ! dnf repolist | grep "$repo" > /dev/null; then
        subscription-manager repos --enable=$repo || { echo "❌ Enabling $repo failed$, please check"; exit 1; }
    fi
done    
echo -e "\n${green}Done!${nc}\n" 


# Install the certification software on SUT & TC
echo
echo "------------------------------------"
echo "INSTALLING CERTIFICATION SOFTWARE..."
echo "------------------------------------"
echo
dnf install -y redhat-certification && dnf install -y redhat-certification-hardware --allowerasing || { echo "❌ Installing hardware test suite package failed!"; exit 1; }
echo -e "\n${green}Done!${nc}\n" 


# Install the Cockpit on TC only
if [[ "$TYPE" == [Tt] ]]; then
    echo
    echo "-----------------------------------"
    echo "INSTALLING COCKPIT RPM ON SERVER..."
    echo "-----------------------------------"
    echo
    dnf install -y redhat-certification-cockpit || { echo "❌ Installing Cockpit RPM failed!"; exit 1; }
fi
echo -e "\n${green}Done!${nc}\n" 


# Install GA kernel 
echo
echo "---------------------------------"
echo "ENSURING PROPER KERNEL VERSION..."
echo "---------------------------------"
echo
RELEASE=$(cat /etc/redhat-release | cut -d ' ' -f6)
case $OS_VERSION in
"8")
    if [[ "$RELEASE" == "8.10" && "$KERNEL" != "$GA_KERNEL_8_10.$(uname -m)" ]]; then 
        dnf remove -y kernel kernel-debug kernel-debuginfo
        dnf install -y kernel-$GA_KERNEL_8_10 kernel-debug-$GA_KERNEL_8_10 kernel-debuginfo-$GA_KERNEL_8_10 --skip-broken
    fi
    ;;
"9")
    if [[ "$RELEASE" == "9.4" && "$KERNEL" != "$GA_KERNEL_9_4.$(uname -m)" ]]; then
        dnf remove -y kernel kernel-debug kernel-debuginfo
        dnf install -y kernel-$GA_KERNEL_9_4 kernel-debug-$GA_KERNEL_9_4 kernel-debuginfo-$GA_KERNEL_9_4 --skip-broken
    elif [[ "$RELEASE" == "9.5" && "$KERNEL" != "$GA_KERNEL_9_5.$(uname -m)" ]]; then
        dnf remove -y kernel kernel-debug kernel-debuginfo
        dnf install -y kernel-$GA_KERNEL_9_5 kernel-debug-$GA_KERNEL_9_5 kernel-debuginfo-$GA_KERNEL_9_5 --skip-broken
    elif [[ "$RELEASE" == "9.6" && "$KERNEL" != "$GA_KERNEL_9_6.$(uname -m)" ]]; then
        dnf remove -y kernel kernel-debug kernel-debuginfo
        dnf install -y kernel-$GA_KERNEL_9_6 kernel-debug-$GA_KERNEL_9_6 kernel-debuginfo-$GA_KERNEL_9_6 --skip-broken
    fi
    ;;
"10")
    if [[ "$RELEASE" == "10.0" && "$KERNEL" != "$GA_KERNEL_10_0.$(uname -m)" ]]; then 
        dnf remove -y kernel kernel-debug kernel-debuginfo
        dnf install -y kernel-$GA_KERNEL_10_0 kernel-debug-$GA_KERNEL_10_0 kernel-debuginfo-$GA_KERNEL_10_0 --skip-broken
    fi
    ;;

esac
[[ $? = 0 ]] && echo -e "\n${green}Done!${nc}\n" || { echo -e "❌ Failed to install GA kernel"; exit 1; }


# Enable the cockpit.socket on TC
if [[ "$TYPE" == [Tt] ]]; then
    echo
    echo "--------------------------"
    echo "ENABLING COCKPIT SOCKET..."
    echo "--------------------------"
    echo
    systemctl enable --now cockpit.socket || { echo "❌ Enabling cockpit socket failed"; exit 1; }
    systemctl start cockpit || { echo "❌ Starting Cockpit failed"; exit 1; }

    # Disable close lid suspend on Server
    sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf && systemctl restart systemd-logind.service
fi
echo -e "\n${green}Done!${nc}\n" 


# Update system except for the kernel
echo
echo "------------------------------"
echo "UPDATING THE LATEST PACKAGE..."
echo "------------------------------"
echo
dnf update -y --exclude=kernel* || { echo "❌ Updating system failed"; sleep 5 && exit 1; }
echo -e "\n${green}Done!${nc}\n" 


# Disable automatic software updates
systemctl stop packagekit
systemctl mask packagekit
[[ $? = 0 ]] && echo -e "\n${green}Done!${nc}\n" || { echo -e "❌ Failed to disable software update"; exit 1; }

echo
echo "--------------------------------------"
echo "✅ RHEL CERTIFICATION SETUP COMPLETED"
echo "---------------------------------------"
echo
echo "System will automatically reboot after 5 seconds..."
echo
read -p "Is it okay to continue (y/n)? " ans
while [[ "$ans" != [YyNn] ]]; do 
    read -p "Is it okay to continue (y/n)? "ans
done     
[[ "$ans" == [Nn] ]] && exit 1
for n in {5..1}s; do printf "\r$n"; sleep 1; done
echo
reboot now

exit

