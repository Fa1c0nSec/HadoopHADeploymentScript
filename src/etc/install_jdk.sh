#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure JDK Installation
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

if [ -f  /etc/fahda_installation_tag/installation_jdk.tag ]
then 
	echo -e "\033[41;37m You have already configured JDK Installation. \033[0m"
	fahda_loginfo "You have already configured JDK Installation."	
	exit
fi

JDK_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz"

if [ -d $INSTALLATION_PATH ]
then
	echo "\033[41;37m Installation Path is exist, prepare to setup... \033[0m"
	fahda_loginfo "Installation Path is exist, prepare to setup..."
else
	echo "\033[41;37m Installation Path does not exist, creating directory for installation... \033[0m"
	fahda_loginfo "Installation Path does not exist, creating directory for installation..."
	sudo mkdir -p $INSTALLATION_PATH
fi
echo "\033[41;37m Installation Path is ready for installation. prepare to install jdk... \033[0m"
fahda_loginfo "Installation Path is ready for installation. prepare to install jdk..."

if [ -e $PWD/lib/jdk-8u121-linux-x64.tar.gz ]
then
	sudo tar -zxvf $PWD/lib/jdk-8u121-linux-x64.tar.gz -C /data/dev/
	fahda_loginfo "sudo tar -zxvf $PWD/lib/jdk-8u121-linux-x64.tar.gz -C /data/dev/"
else
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_DOWNLOAD_URL}
	fahda_loginfo "wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${JDK_DOWNLOAD_URL}"
	sudo tar -zxvf jdk-8u121-linux-x64.tar.gz -C /data/dev
	fahda_loginfo "sudo tar -zxvf jdk-8u121-linux-x64.tar.gz -C /data/dev"
fi

function fahda_fn_profile_configure() {
	EXPORT_JAVA_HOME="export JAVA_HOME=/data/dev/jdk1.8.0_121"
	EXPORT_JRE_HOME="export JRE_HOME=\${JAVA_HOME}/jre"
	EXPORT_CLASSPATH="export CLASSPATH=.:\${JAVA_HOME}/lib/tools.jar:\${JAVA_HOME}/lib/dt.jar"
	EXPORT_PATH="export PATH=\${JAVA_HOME}/bin:\$PATH"
	echo ${EXPORT_JAVA_HOME} >> /etc/profile
	echo ${EXPORT_JRE_HOME} >> /etc/profile
	echo ${EXPORT_CLASSPATH} >> /etc/profile
	echo ${EXPORT_PATH} >> /etc/profile
}

fahda_fn_profile_configure
fahda_loginfo "fahda_fn_profile_configure"
source /etc/profile
fahda_loginfo "source /etc/profile"
java -version
fahda_loginfo "java -version"

echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/installation_jdk.tag

echo -e "\033[32m ################################### \033[0m"
echo -e "\033[32m #### JDK Installation Succeed. #### \033[0m"
echo -e "\033[32m ################################### \033[0m"

sleep 10 




