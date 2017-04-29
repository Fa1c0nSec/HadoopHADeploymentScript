#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure SSH Service Configuration
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
	echo -e "\033[41;37m Environment Verify Succeed. \033[0m"
else
	echo -e "\033[41;37m Environment has not configured yet, please verify environment first. \033[0m"
	exit 1
fi

if [ -f  /etc/fahda_installation_tag/ssh_config.tag ]
then 
	echo -e "\033[41;37m You have already configured SSH Service. \033[0m"
	fahda_loginfo "You have already configured SSH Service."	
	exit
fi

sudo apt-get install ssh
fahda_loginfo "sudo apt-get install ssh"
sudo apt-get install expect
fahda_loginfo "sudo apt-get install expect"
ps -le | grep ssh
fahda_loginfo "ps -le | grep ssh"
sed -i "s/without-password/yes/g" /etc/ssh/sshd_config
fahda_loginfo "sed -i "s/without-password/yes/g" /etc/ssh/sshd_config"
sudo ufw disable
fahda_loginfo "sudo ufw disable"

function fahda_fn_ssh_keygen() {
	if [ -d ~/.ssh ]
	then
		echo -e "\033[41;37m SSH Key Generating... \033[0m"
	else
		mkdir -p ~/.ssh/
		fahda_loginfo "mkdir -p ~/.ssh/"
	fi
	sudo rm -rf ~/.ssh/id_rsa
	sudo ssh-keygen -t rsa -b 4096 -C "i@fa1c0n.com" -P '' -f ~/.ssh/id_rsa -q
	fahda_loginfo "sudo ssh-keygen -q -t rsa -b 4096 -C \"i@fa1c0n.com\" -P '' -f ~/.ssh/id_rsa"
}

fahda_fn_ssh_keygen
fahda_loginfo "fahda_fn_ssh_keygen"

function fahda_fn_ssh_copy_id() {
	expectCmd=`which expect`
	fahda_loginfo "expectCmd=`which expect`"
	$expectCmd fahda_spawn_ssh_copy_id_silent_configuration.sh
	fahda_loginfo "$expectCmd fahda_spawn_ssh_copy_id_silent_configuration.sh"
}

function fahda_fn_spawn_expect_shell_dynamic_generator() {
	touch fahda_spawn_ssh_copy_id_silent_configuration.sh
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
		echo "#!"${expectCmd} > fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "set timeout 60" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "spawn ssh-copy-id "$curr_ip >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "while {1} {" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "  expect {" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "     eof                              {break}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "     \"The authenticity of host\"       {send \"yes\r\"}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "     \"password:\"                      {send \""$curr_pwd"\r\"}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "     \"Password:\"                      {send \""$curr_pwd"\r\"}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh 
		echo "     \"*\]\"                            {send \"exit\\r\"}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "   }" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "}" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "wait" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		echo "close \$spawn_id" >> fahda_spawn_ssh_copy_id_silent_configuration.sh
		sudo chmod +x fahda_spawn_ssh_copy_id_silent_configuration.sh
		fahda_fn_ssh_copy_id
	done
	
}

fahda_fn_spawn_expect_shell_dynamic_generator
fahda_loginfo "fahda_fn_spawn_expect_shell_dynamic_generator"

echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/ssh_config.tag

echo -e "\033[32m ############################################ \033[0m"
echo -e "\033[32m #### SSH Service Configuration Succeed. #### \033[0m"
echo -e "\033[32m ############################################ \033[0m"

sleep 10 

