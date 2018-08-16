#!/bin/bash
#------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-15
#filename	:	del_container.sh
#descript	:	停止、删除指定容器
#
#$1		:	容器名称
#
#------------------------------------------------------------------

if [ ! -n "$1" ] ;then
	echo "Error-请输入容器名称"
	exit -1
fi

name=$1
docker stop ${name}
echo "stop the container "${name}
docker rm $1
echo "rm the container "${name}
exit

