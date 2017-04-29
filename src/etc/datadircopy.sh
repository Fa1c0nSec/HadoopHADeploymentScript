#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure Data Directory Copy
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

CURRENT_HOST_IP=`LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}'`

#if [ ${CURRENT_HOST_IP} = ${MASTER1_IP} ]
#then
#	scp -r /data/ ${MASTER2_USRNAME}@${MASTER2_IP}:/data/
#	scp -r /data/ ${MASTER3_USRNAME}@${MASTER3_IP}:/data/
#elif [ ${CURRENT_HOST_IP} = ${MASTER2_IP} ]
#then
#	scp -r /data/ ${MASTER1_USRNAME}@${MASTER1_IP}:/data/
#	scp -r /data/ ${MASTER3_USRNAME}@${MASTER3_IP}:/data/
#elif [ ${CURRENT_HOST_IP} = ${MASTER3_IP} ]
#then
#	scp -r /data/ ${MASTER1_USRNAME}@${MASTER1_IP}:/data/
#	scp -r /data/ ${MASTER2_USRNAME}@${MASTER2_IP}:/data/
#else
#	echo "Your Network Valid IP Address is not in installrc file."
#	fahda_logerr "echo \"Your Network Valid IP Address is not in installrc file.\""
#	exit 1
#fi

function fahda_fn_scp_data_copy() {
	expectCmd=`which expect`
	fahda_loginfo "expectCmd=`which expect`"
	$expectCmd fahda_spawn_scp_data_dir_silent.sh
	fahda_loginfo "$expectCmd fahda_spawn_scp_data_dir_silent.sh"
}

function fahda_fn_spawn_expect_shell_dynamic_generator() {
	touch fahda_spawn_scp_data_dir_silent.sh
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
		echo "#!"${expectCmd} > fahda_spawn_scp_data_dir_silent.sh
		echo "set timeout 60" >> fahda_spawn_scp_data_dir_silent.sh
		echo "spawn scp -r /data/ "$curr_usrname"@"$curr_ip:/data >> fahda_spawn_scp_data_dir_silent.sh
		echo "while {1} {" >> fahda_spawn_scp_data_dir_silent.sh
		echo "  expect {" >> fahda_spawn_scp_data_dir_silent.sh
		echo "     eof                              {break}" >> fahda_spawn_scp_data_dir_silent.sh
		echo "     \"The authenticity of host\"       {send \"yes\r\"}" >> fahda_spawn_scp_data_dir_silent.sh
		echo "     \"Password:\"                      {send \""$curr_pwd"\r\"}" >> fahda_spawn_scp_data_dir_silent.sh
		echo "     \"*\]\"                            {send \"exit\\r\"}" >> fahda_spawn_scp_data_dir_silent.sh
		echo "   }" >> fahda_spawn_scp_data_dir_silent.sh
		echo "}" >> fahda_spawn_scp_data_dir_silent.sh
		echo "wait" >> fahda_spawn_scp_data_dir_silent.sh
		echo "close \$spawn_id" >> fahda_spawn_scp_data_dir_silent.sh
		sudo chmod +x fahda_spawn_scp_data_dir_silent.sh
		fahda_fn_scp_data_copy
	done
	
}

fahda_fn_spawn_expect_shell_dynamic_generator
fahda_loginfo "fahda_fn_spawn_expect_shell_dynamic_generator"


echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/scp_data_dir_copy.tag

echo -e "\033[32m ######################################## \033[0m"
echo -e "\033[32m #### Data Directory Copied Succeed. #### \033[0m"
echo -e "\033[32m ######################################## \033[0m"

sleep 10 

