#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure Hadoop Installation
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

if [ -e /etc/fahda_installation_tag/installation_zookeeper.tag ]
then
	echo "\033[41;37m Zookeeper Installation has already finished. \033[0m"
else
	echo -e "\033[41;37m Zookeeper Installation has not installed yet, please install zookeeper first. \033[0m"
	exit 1
fi

if [ -f  /etc/fahda_installation_tag/installation_hadoop.tag ]
then 
	echo -e "\033[41;37m You have already configured Hadoop Installation. \033[0m"
	fahda_loginfo "You have already configured Hadoop Installation."	
	exit
fi

HADOOP_DOWNLOAD_URL="http://apache.fayea.com/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz"

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
	echo "\033[41;37m Installation Path is ready for installation. prepare to install hadoop... \033[0m"
	fahda_loginfo "Installation Path is ready for installation. prepare to install hadoop..."
}

fahda_fn_installation_path_check
fahda_loginfo "fahda_fn_installation_path_check"

function fahda_fn_hadoop_installation() {
	if [ -e $PWD/lib/hadoop-2.8.0.tar.gz ]
	then
		sudo tar -zxvf $PWD/lib/hadoop-2.8.0.tar.gz -C /data/dev/
		fahda_loginfo "sudo tar -zxvf $PWD/lib/hadoop-2.8.0.tar.gz -C /data/dev/"
	else
		wget --no-cookies --no-check-certificate ${HADOOP_DOWNLOAD_URL}
		fahda_loginfo "wget --no-cookies --no-check-certificate ${HADOOP_DOWNLOAD_URL}"
		sudo tar -zxvf hadoop-2.8.0.tar.gz -C /data/dev
		fahda_loginfo "sudo tar -zxvf hadoop-2.8.0.tar.gz -C /data/dev"
	fi

	sudo rm -rf /data/dev/hadoop-2.8.0/etc/hadoop/
	fahda_loginfo "sudo rm -rf /data/dev/hadoop-2.8.0/etc/hadoop/"
	sudo cp -r $PWD/etc/hadoop /data/dev/hadoop-2.8.0/etc/hadoop/
	fahda_loginfo "sudo cp -r $PWD/etc/hadoop /data/dev/hadoop-2.8.0/etc/hadoop/"
}

fahda_fn_hadoop_installation
fahda_loginfo "fahda_fn_hadoop_installation"

function fahda_fn_hadoop_configuration() {
	sed -i "s/10.49.84.234/${MASTER1_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml
	fahda_loginfo "sed -i \"s/10.49.84.234/${MASTER1_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml"	
	sed -i "s/10.49.85.70/${MASTER2_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.70/${MASTER2_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml"
	sed -i "s/10.49.85.76/${MASTER3_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.76/${MASTER3_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/hdfs-site.xml"
	sed -i "s/10.49.84.234/${MASTER1_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml
	fahda_loginfo "sed -i \"s/10.49.84.234/${MASTER1_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml"	
	sed -i "s/10.49.85.70/${MASTER2_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.70/${MASTER2_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml"
	sed -i "s/10.49.85.76/${MASTER3_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.76/${MASTER3_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/core-site.xml"
	sed -i "s/10.49.84.234/${MASTER1_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml
	fahda_loginfo "sed -i \"s/10.49.84.234/${MASTER1_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml"
	sed -i "s/10.49.85.70/${MASTER2_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.70/${MASTER2_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml"
	sed -i "s/10.49.85.76/${MASTER3_IP}/g" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml
	fahda_loginfo "sed -i \"s/10.49.85.76/${MASTER3_IP}/g\" /data/dev/hadoop-2.8.0/etc/hadoop/yarn-site.xml"
}

fahda_fn_hadoop_configuration
fahda_loginfo "fahda_fn_hadoop_configuration"

echo "export HADOOP_HOME=\"/data/dev/hadoop-2.8.0/\"" >> /etc/profile
fahda_loginfo "echo \"export HADOOP_HOME=\"/data/dev/hadoop-2.8.0/\"\" >> /etc/profile"
echo "export PATH=\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$PATH" >> /etc/profile
fahda_loginfo "echo \"export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH\" >> /etc/profile"
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> /etc/profile
fahda_loginfo "echo \"export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native\" >> /etc/profile"
echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib\"" >> /etc/profile
fahda_loginfo "echo \"export HADOOP_OPTS=\"-Djava.library.path=$HADOOP_HOME/lib\"\" >> /etc/profile"
source /etc/profile
fahda_loginfo "source /etc/profile"


echo `date "+%Y-%m-%d %H:%M:%S"` > /etc/fahda_installation_tag/installation_hadoop.tag

echo -e "\033[32m ###################################### \033[0m"
echo -e "\033[32m #### Hadoop Installation Succeed. #### \033[0m"
echo -e "\033[32m ###################################### \033[0m"

sleep 10 




