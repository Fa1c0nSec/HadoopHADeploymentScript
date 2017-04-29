#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure Detail Logging
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

function fahda_loginfo() {
	DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
	USER_N=`whoami`
	echo "${DATE_N} ${USER_N} execute $0 [INFO] $@" >> /var/log/hadoop-2.8.0-ha.log
}

function fahda_logerr() {
	DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
	USER_N=`whoami`
	echo -e "${DATE_N} ${USER_N} execute $0 [ERROR] $@ "  >> /var/log/hadoop-2.8.0-ha.log
}

function fahda_fn_log() {
	if [  $? -eq 0  ]
	then
		fahda_loginfo "$@ sucessed."
		echo -e "\033[32m $@ sucessed. \033[0m"
	else
		fahda_logerr "$@ failed."
		echo -e "\033[41;37m $@ failed. \033[0m"
		exit
	fi
}



