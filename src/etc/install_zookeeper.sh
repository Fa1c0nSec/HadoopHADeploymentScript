#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure Zookeeper Installation
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

if [ -e /etc/fahda_installation_tag/environment_setup.tag ]
then
	echo "\033[41;37m Environment Verify Succeed. \033[0m"
else
	echo -e "\033[41;37m Environment has not configured yet, please verify environment first. \033[0m"
	exit 1
fi

if [ -e /etc/fahda_installation_tag/ssh_config.tag ]
then
	echo "\033[41;37m SSH Service has already configured. \033[0m"
else
	echo -e "\033[41;37m SSH Service has not configured yet, please configure ssh service first. \033[0m"
	exit 1
fi

if [ -e /etc/fahda_installation_tag/installation_jdk.tag ]
then
	echo "\033[41;37m JDK Installation has already finished. \033[0m"
else
	echo -e "\033[41;37m JDK Installation has not installed yet, please install jdk first. \033[0m"
	exit 1
fi

if [ -f  /etc/fahda_installation_tag/installation_zookeeper.tag ]
then 
	echo -e "\033[41;37m You have already configured Zookeeper Installation. \033[0m"
	fahda_loginfo "You have already configured Zookeeper Installation."	
	exit
fi

ZOOKEEPER_DOWNLOAD_URL="http://mirrors.hust.edu.cn/apache/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz"

function fahda_fn_installation_path_check() {
	if [ -d $INSTALLATION_PATH ]
	then
		echo "\033[41;37m Installation Path is exist, prepare to setup... \033[0m"
		fahda_loginfo "Installation Path is exist, prepare to setup..."
	else
		echo "\033[41;37m Installation Path does not exist, creating directory for installation... \033[0m"
		fahda_loginfo "Installation Path does not exist, creating directory for installation..."
		sudo mkdir -p $INSTALLATION_PATH
	fi
	echo "\033[41;37m Installation Path is ready for installation. prepare to install zookeeper... \033[0m"
	fahda_loginfo "Installation Path is ready for installation. prepare to install zookeeper..."
}

fahda_fn_installation_path_check
fahda_loginfo "fahda_fn_installation_path_check"

function fahda_fn_zookeeper_installation() {
	if [ -e $PWD/lib/zookeeper-3.4.9.tar.gz ]
	then
		sudo tar -zxvf $PWD/lib/zookeeper-3.4.9.tar.gz -C /data/dev/
		fahda_loginfo "sudo tar -zxvf $PWD/lib/zookeeper-3.4.9.tar.gz -C /data/dev/"
	else
		wget --no-cookies --no-check-certificate ${ZOOKEEPER_DOWNLOAD_URL}
		fahda_loginfo "wget --no-cookies --no-check-certificate ${ZOOKEEPER_DOWNLOAD_URL}"
		sudo tar -zxvf zookeeper-3.4.9.tar.gz -C /data/dev
		fahda_loginfo "sudo tar -zxvf zookeeper-3.4.9.tar.gz -C /data/dev"
	fi

	sudo cp -r /data/dev/zookeeper-3.4.9/conf/zoo_sample.cfg /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	fahda_loginfo "sudo cp -r /data/dev/zookeeper-3.4.9/conf/zoo_sample.cfg /data/dev/zookeeper-3.4.9/conf/zoo.cfg"
	
	sudo mkdir -p /data/dev/zookeeper-3.4.9/data
	fahda_loginfo "sudo mkdir -p /data/dev/zookeeper-3.4.9/data"
	sudo mkdir -p /data/dev/zookeeper-3.4.9/log
	fahda_loginfo "sudo mkdir -p /data/dev/zookeeper-3.4.9/log"
}

fahda_fn_zookeeper_installation
fahda_loginfo "fahda_fn_zookeeper_installation"

function fahda_fn_zookeeper_configuration() {
	fahda_zoo_cfg_ori_datadir="dataDir=\/tmp\/zookeeper"
	fahda_zoo_cfg_replace_datadir="dataDir=\/data\/dev\/zookeeper-3.4.9\/data"

	sed -i "s/${fahda_zoo_cfg_ori_datadir}/${fahda_zoo_cfg_replace_datadir}/g" /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	fahda_loginfo "sed -i "s/${fahda_zoo_cfg_ori_datadir}/${fahda_zoo_cfg_replace_datadir}/g" /data/dev/zookeeper-3.4.9/conf/zoo.cfg"

	fahda_zoo_cfg_logdatadir="dataLogDir=/data/dev/zookeeper-3.4.9/log"
	echo "${fahda_zoo_cfg_logdatadir}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	fahda_loginfo "echo "${fahda_zoo_cfg_logdatadir}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg"

	fahda_zoo_cfg_server_1="server.1=${MASTER1_IP}:2888:3888"
	fahda_zoo_cfg_server_2="server.2=${MASTER2_IP}:2888:3888"
	fahda_zoo_cfg_server_3="server.3=${MASTER3_IP}:2888:3888"
	echo "${fahda_zoo_cfg_server_1}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	echo "${fahda_zoo_cfg_server_2}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	echo "${fahda_zoo_cfg_server_3}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg
	fahda_zookeeper_path="PATH=/data/dev/zookeeper-3.4.9/bin:/data/dev/zookeeper-3.4.9/conf:\$PATH"
	fahda_loginfo "echo "${fahda_zoo_cfg_server_1}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg"
	fahda_loginfo "echo "${fahda_zoo_cfg_server_2}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg"
	fahda_loginfo "echo "${fahda_zoo_cfg_server_3}" >> /data/dev/zookeeper-3.4.9/conf/zoo.cfg"
	fahda_loginfo "fahda_zookeeper_path=\"PATH=/data/dev/zookeeper-3.4.9/bin:/data/dev/zookeeper-3.4.9/conf:\$PATH\""

	echo "${fahda_zookeeper_path}" >> /etc/profile
	source /etc/profile
	fahda_loginfo "source /etc/profile"

	CURRENT_HOST_IP=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`

	if [ ${CURRENT_HOST_IP} = ${MASTER1_IP} ]
	then
		echo "1" >> /data/dev/zookeeper-3.4.9/data/myid
		fahda_loginfo "echo "1" >> /data/dev/zookeeper-3.4.9/data/myid"
	elif [ ${CURRENT_HOST_IP} = ${MASTER2_IP} ]
	then
		echo "2" >> /data/dev/zookeeper-3.4.9/data/myid
		fahda_loginfo "echo "2" >> /data/dev/zookeeper-3.4.9/data/myid"
	elif [ ${CURRENT_HOST_IP} = ${MASTER3_IP} ]
	then
		echo "3" >> /data/dev/zookeeper-3.4.9/data/myid
		fahda_loginfo "echo "3" >> /data/dev/zookeeper-3.4.9/data/myid"
	else
		echo "Current Network Valid IP Address is not in installrc file."
		fahda_logerr "echo \"Current Network Valid IP Address is not in installrc file.\""
		exit 1
	fi
}

fahda_fn_zookeeper_configuration
fahda_loginfo "fahda_fn_zookeeper_configuration"

echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/installation_zookeeper.tag

echo -e "\033[32m ######################################### \033[0m"
echo -e "\033[32m #### Zookeeper Installation Succeed. #### \033[0m"
echo -e "\033[32m ######################################### \033[0m"
echo -e "\033[32m System reboot required, rebooting system... \033[0m"

function fahda_fn_execute_reboot() {
	expectCmd=`which expect`
	fahda_loginfo "expectCmd=`which expect`"
	$expectCmd fahda_spawn_reboot_silent.sh
	fahda_loginfo "$expectCmd fahda_spawn_reboot_silent.sh"
}

function fahda_fn_spawn_expect_shell_dynamic_generator() {
	touch fahda_spawn_reboot_silent.sh
	expectCmd=`which expect`
	comm_former="MASTER"
	latter_usrname="_USRNAME"
	latter_IP="_IP"
	latter_PWD="_PWD"
	for hostSerial in {1..3}
	do
		eval curr_usrname="$"${comm_former}${hostSerial}${latter_usrname}
		eval curr_ip="$"${comm_former}${hostSerial}${latter_IP}
		eval curr_pwd="$"${comm_former}${hostSerial}${latter_PWD}
		echo "#!"${expectCmd} > fahda_spawn_reboot_silent.sh
		echo "set timeout 60" >> fahda_spawn_reboot_silent.sh
		echo "spawn ssh -t -p 22 "$curr_usrname"@"$curr_ip" reboot" >> fahda_spawn_reboot_silent.sh
		echo "while {1} {" >> fahda_spawn_reboot_silent.sh
		echo "  expect {" >> fahda_spawn_reboot_silent.sh
		echo "     eof                              {break}" >> fahda_spawn_reboot_silent.sh
		echo "     \"password:\"                      {send \""$curr_pwd"\r\"}" >> fahda_spawn_reboot_silent.sh
		echo "     \"Password:\"                      {send \""$curr_pwd"\r\"}" >> fahda_spawn_reboot_silent.sh
		echo "     \"*\]\"                            {send \"exit\\r\"}" >> fahda_spawn_reboot_silent.sh
		echo "   }" >> fahda_spawn_reboot_silent.sh
		echo "}" >> fahda_spawn_reboot_silent.sh
		echo "wait" >> fahda_spawn_reboot_silent.sh
		echo "close \$spawn_id" >> fahda_spawn_reboot_silent.sh
		sudo chmod +x fahda_spawn_reboot_silent.sh
		fahda_fn_execute_reboot
	done
	
}

fahda_fn_spawn_expect_shell_dynamic_generator
fahda_loginfo "fahda_fn_spawn_expect_shell_dynamic_generator"

sleep 10 




