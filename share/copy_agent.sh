#!/bin/bash

#------------------------------------------------------------------------
#author         :       zc.ding
#filename       :       copy_agent.sh
#date           :       2018-11-16
#
#

CONTAINER_NAME=$1
SERVER_NAME=$2
SRC_AGENT_PATH=/share/soft/agent
SERVICE_DIR=/share/projects/${CONTAINER_NAME}/finance-${SERVER_NAME}-service/

if [[ -d ${SRC_AGENT_PATH} ]]
then
	#cp -rf ${SRC_AGENT_PATH} ${SERVICE_DIR}
	#sed -i 's/Your_ApplicationName/'${CONTAINER_NAME}'-'${SERVER_NAME}'/g' ${SERVICE_DIR}/agent/config/agent.config
	echo "copy agent sucess."
fi


