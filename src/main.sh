#!/bin/bash
#
#  Copyright 2017 Fa1c0n. All Rights Reserved.
#  
#  Project Application: Hadoop 2.8.0 HA Deployment Script
#  Contact: i@fa1c0n.com
#  Github: https://github.com/Fa1c0nSec
#  Current File: Hadoop HA Setup Procedure MainCall
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
reset
DEPLOY_PATH=$PWD
if [ -e $PWD/lib/fahda-log.sh ]
then
	source $PWD/lib/fahda-log.sh
else
	echo -e "\033[31;37m $PWD/lib/fahda-log.sh is not exist. \033[0m"
	exit 1
fi

# InstallRC Variables
if [ -e $PWD/lib/installrc ]
then
	source $PWD/lib/installrc
else
	echo -e "\033[31;37m $PWD/lib/installr is not exist. \033[0m"
	exit 1
fi

USER_N=`whoami`

if [ ${USER_N} = root ]
then
	fahda_loginfo "Script Executed by root."
else
	fahda_logerr "Script Executed by ${USER_N}"
	echo -e "\033[31;37m You must ensure script executed by root. \033[0m"
	exit 1
fi

function fahda_fn_install_hadoop_controller() {
	cat << EOF
	+------------------------------------------------+
	|              Hadoop HA Installation            |
	|------------------------------------------------|
	|           Script Development : Fa1c0n          |
	|------------------------------------------------|
	|           1) Environment Configuration         |
	|           2) SSH Service Configuration         |
	|               3) JDK Installation              |
	|             4) ZooKeeper Installation          |
	|               5) Hadoop Installation           |
	|	      6) Zookeeper Service Start	 |
        |        7) Hadoop First Initialize (master1)    |
	|              8) Hadoop Service Start           |
	|	   9) Data Directory Copy(DISABLED)      |
	|                     10) EXIT                   |
	+------------------------------------------------+
EOF
	read -p "Please Input Selection Number: " inpsel
	case ${inpsel} in
		1)
			source $PWD/etc/environment_setup.sh
			fahda_loginfo "source $PWD/etc/environment_setup.sh"
			fahda_fn_install_hadoop_controller
		;;
		2)
			source $PWD/etc/ssh-config.sh
			fahda_loginfo "source $PWD/etc/ssh-config.sh"
			fahda_fn_install_hadoop_controller
		;;
		3)
			source $PWD/etc/install_jdk.sh
			fahda_loginfo "source $PWD/etc/install_jdk.sh"
			fahda_fn_install_hadoop_controller
		;;
		4)
			source $PWD/etc/install_zookeeper.sh
			fahda_loginfo "source $PWD/etc/install_zookeeper.sh"
			fahda_fn_install_hadoop_controller
		;;
		5)
			source $PWD/etc/install_hadoop.sh
			fahda_loginfo "source $PWD/etc/install_hadoop.sh"
			fahda_fn_install_hadoop_controller
		;;
		6)
			/data/dev/zookeeper-3.4.9/bin/zkServer.sh start
			fahda_loginfo "/data/dev/zookeeper-3.4.9/bin/zkServer.sh start"
			echo -e "\033[32m ########################################## \033[0m"
			echo -e "\033[32m #### Zookeeper Service Start Succeed. #### \033[0m"
			echo -e "\033[32m ########################################## \033[0m"
			fahda_fn_install_hadoop_controller
		;;
		7)
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start journalnode
			/data/dev/hadoop-2.8.0/bin/hdfs zkfc -formatZK
			/data/dev/hadoop-2.8.0/bin/hadoop namenode -format
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemon.sh start namenode
			ssh -t -p 22 ${MASTER2_USRNAME}@${MASTER2_IP} /data/dev/hadoop-2.8.0/bin/hdfs namenode -bootstrapStandby
			ssh -t -p 22 ${MASTER2_USRNAME}@${MASTER2_IP} /data/dev/hadoop-2.8.0/sbin/hadoop-daemon.sh start namenode
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start datanode
			/data/dev/hadoop-2.8.0/sbin/start-yarn.sh
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start zkfc
			echo -e "\033[32m ########################################### \033[0m"
			echo -e "\033[32m #### Hadoop First Initialized Succeed. #### \033[0m"
			echo -e "\033[32m ########################################### \033[0m"
			fahda_fn_install_hadoop_controller
		;;
		8)
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start journalnode
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemon.sh start namenode
			ssh -t -p 22 ${MASTER2_USRNAME}@${MASTER2_IP} /data/dev/hadoop-2.8.0/bin/hdfs namenode -bootstrapStandby
			ssh -t -p 22 ${MASTER2_USRNAME}@${MASTER2_IP} /data/dev/hadoop-2.8.0/sbin/hadoop-daemon.sh start namenode
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start datanode
			/data/dev/hadoop-2.8.0/sbin/start-yarn.sh
			/data/dev/hadoop-2.8.0/sbin/hadoop-daemons.sh start zkfc
			echo -e "\033[32m ####################################### \033[0m"
			echo -e "\033[32m #### Hadoop Service Start Succeed. #### \033[0m"
			echo -e "\033[32m ####################################### \033[0m"
			fahda_fn_install_hadoop_controller
		;;
		9)
			source $PWD/etc/datadircopy.sh
			fahda_loginfo "source $PWD/etc/datadircopy.sh"
			fahda_fn_install_hadoop_controller
		;;
		10)
			exit 1
		;;
		*)
			echo -e "\033[41;37m Please Input Correct Number. \033[0m"
			fahda_fn_install_hadoop_controller
		;;
		esac
	}
	
fahda_fn_install_hadoop_controller	

