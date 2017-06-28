#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure Environment Verify
#
#  Licensed under the GNU General Public License, Version 3.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.gnu.org/licenses
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
NAMEHOST=$HOSTNAME
if [  -e $PWD/lib/fahda-log.sh ]
then	
	source $PWD/lib/fahda-log.sh
else
	echo -e "\033[41;37m $PWD/fahda-log.sh is not exist. \033[0m"
	exit 1
fi

if [  -e $PWD/lib/installrc ]
then	
	source $PWD/lib/installrc 
else
	echo -e "\033[41;37m $PWD/lib/installr is not exist. \033[0m"
	exit 1
fi

if [ -f  /etc/fahda_installation_tag/environment_setup.tag ]
then 
	echo -e "\033[41;37m You have already checked with System Environment. \033[0m"
	fahda_loginfo "You have already checked with System Environment."	
	exit
fi

function fahda_fn_check_os_version() {
	if [ -e /usr/bin/lsb_release ]
	then
		OS_DSBID=`lsb_release -i | awk -F ':' '{print $2}' | sed 's/[[:space:]]//g'`
		fahda_loginfo "OS_DSBID=lsb_release -i | awk -F \':\' \'{print \$2}\' | sed \'s\/[[:space:]]\/\/g\'\`"
		OS_CODENAME=`lsb_release -c | awk -F ':' '{print $2}' | sed 's/[[:space:]]//g'`
		fahda_loginfo "OS_CODENAME=lsb_release -c | awk -F \':\' \'{print \$2}\' | sed \'s/[[:space:]]\/\/g\'\`"
	else
		echo -e "\033[41;37m Scripts ONLY can be run on Debian Linux LSBs. \033[0m"
		fahda_logerr "Scripts ONLY can be run on Debian Linux LSBs."
		exit 1
	fi

	if [ ${OS_CODENAME} = xenial ]
	then
		echo -e "\033[41;37m Process Operating System is Ubuntu Linux 16.04 LTS Xenial \033[0m"
		fahda_loginfo "echo \"Process Operating System is Ubuntu Linux 16.04 LTS Xenial\""
	elif [ ${OS_CODENAME} = trusty ]
	then
		echo -e "\033[41;37m Process Operating System is Ubuntu Linux 14.04 LTS Trusty \033[0m"
		fahda_loginfo "echo \"Process Operating System is Ubuntu Linux 14.04 LTS Trusty\""
	elif [ ${OS_CODENAME} = precise ]
	then
		echo -e "\033[41;37m Process Operating System is Ubuntu Linux 12.04 LTS Precise \033[0m"
		fahda_loginfo "echo \"Process Operating System is Ubuntu Linux 12.04 LTS Precise\""
	else
		echo -e "\033[41;37m Please ensure your OS is Debian Linux LSBs. \033[0m"
		fahda_logerr "echo \"Please ensure your OS is Debian Linux LSBs.\""
		exit 1
	fi
}

fahda_fn_check_os_version

mv /etc/hosts /etc/hosts.bak
fahda_loginfo "mv /etc/hosts /etc/hosts.bak"
cp -r $PWD/lib/hosts /etc/hosts
fahda_loginfo "cp -r $PWD/lib/hosts /etc/hosts"

CURRENT_HOST_IP=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`

if [ ${CURRENT_HOST_IP} = ${MASTER1_IP} ]
then
	CURRENT_HOST_NAME=master1
	hostnamectl set-hostname ${CURRENT_HOST_NAME}
	fahda_loginfo "hostnamectl set-hostname ${CURRENT_HOST_NAME}"
elif [ ${CURRENT_HOST_IP} = ${MASTER2_IP} ]
then
	CURRENT_HOST_NAME=master2
	hostnamectl set-hostname ${CURRENT_HOST_NAME}
	fahda_loginfo "hostnamectl set-hostname ${CURRENT_HOST_NAME}"
elif [ ${CURRENT_HOST_IP} = ${MASTER3_IP} ]
then
	CURRENT_HOST_NAME=master3
	hostnamectl set-hostname ${CURRENT_HOST_NAME}
	fahda_loginfo "hostnamectl set-hostname ${CURRENT_HOST_NAME}"
else
	echo "Your Network Valid IP Address is not in installrc file."
	fahda_logerr "echo \"Your Network Valid IP Address is not in installrc file.\""
	exit 1
fi

ping -c 4 ${CURRENT_HOST_NAME}
fahda_loginfo "ping -c 4 ${CURRENT_HOST_NAME}"

sudo apt-get -y update && sudo apt-get -y dist-upgrade
fahda_loginfo "sudo apt-get update && sudo apt-get dist-upgrade"

sudo mkdir -p /etc/fahda_installation_tag/
echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/environment_setup.tag

echo -e "\033[32m ##################################### \033[0m"
echo -e "\033[32m #### Environment Verify Succeed. #### \033[0m"
echo -e "\033[32m ##################################### \033[0m"

sleep 10 

