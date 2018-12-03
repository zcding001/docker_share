#!/bin/sh

#------------------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-15
#filename	:	start_projects.sh
#description	:	部署zk、启动服务
#
#------------------------------------------------------------------------------


CONTAINER_NAME=$1
TOMCAT_PATH=/share/projects/${CONTAINER_NAME}/tomcat

#config zk
tar -zxvf /share/soft/zookeeper-3.4.9.tar.gz -C /opt/
cp -f /opt/zookeeper-3.4.9/conf/zoo_sample.cfg /opt/zookeeper-3.4.9/conf/zoo.cfg
cd /opt/zookeeper-3.4.9
bash /opt/zookeeper-3.4.9/bin/zkServer.sh restart

#copy pay cert
mkdir -p /data/www
cp -rf /share/pay_cert /data/www/

#rm -rf /share/projects/${CONATNER_NAME}/hk-*
#rm -rf /share/projects/${CONATNER_NAME}/finance-*
#cp -rf /share/projects/${CONATNER_NAME}/tmp/ /share/projects/${CONATNER_NAME}/

#restart services
echo "启动user, invest, loan, payment, secondary服务"
cd /share
bash service_switch.sh user start 5100 ${CONTAINER_NAME}
bash service_switch.sh invest start 5101 ${CONTAINER_NAME}
bash service_switch.sh loan start 5102 ${CONTAINER_NAME}
bash service_switch.sh payment start 5103 ${CONTAINER_NAME}
bash service_switch.sh secondary start 5104 ${CONTAINER_NAME}
echo "启动web服务"
cd /share/projects/F${CONTAINER_NAME}/tomcat/webapps
rm -rf hk-*-services

#config tomcat java agent
#sed -i 's/Your_ApplicationName/'${CONTAINER_NAME}'/g' /share/projects/${CONTAINER_NAME}/tomcat/agent/config/agent.config
#sed -i 's/CONTAINER_NAME/'${CONTAINER_NAME}'/g' /share/projects/${CONTAINER_NAME}/tomcat/bin/catalina.sh

bash /share/projects/${CONTAINER_NAME}/tomcat/bin/shutdown.sh
bash /share/projects/${CONTAINER_NAME}/tomcat/bin/startup.sh

tail -f /dev/null
