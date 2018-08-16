#!/bin/sh

#------------------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-15
#filename	:	start_projects.sh
#description	:	部署zk、启动服务
#
#------------------------------------------------------------------------------

TOMCAT_PATH=/share/projects/$1/tomcat

#config zk
tar -zxvf /share/soft/zookeeper-3.4.9.tar.gz -C /opt/
cp -f /opt/zookeeper-3.4.9/conf/zoo_sample.cfg /opt/zookeeper-3.4.9/conf/zoo.cfg
cd /opt/zookeeper-3.4.9
bash /opt/zookeeper-3.4.9/bin/zkServer.sh restart

#copy pay cert
mkdir -p /data/www
cp -rf /share/baofu_cert /data/www/

#restart services
cd /share
bash service_switch.sh user start 5100 $1
bash service_switch.sh invest start 5101 $1
bash service_switch.sh loan start 5102 $1
bash service_switch.sh payment start 5102 $1
bash service_switch.sh secondary start 5104 $1
cd /share/projects/$1/tomcat/webapps
rm -rf hk-management-services
rm -rf hk-api-services
bash /share/projects/$1/tomcat/bin/shutdown.sh
bash /share/projects/$1/tomcat/bin/startup.sh

tail -f /dev/null
