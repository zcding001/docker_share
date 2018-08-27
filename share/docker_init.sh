#!/bin/bash

#-----------------------------------------------------
#author		:	zc.ding
#Revision	:	1.0
#Date		:	2018-08-15
#Email		:	zhichaoding@hongkun.com
#filename	:	docker_ini.sh
#Description	:	启动doceker,部署项目
#
#$1		:	参数对应config.ini中的节点名称[cxj_develop]
#-----------------------------------------------------

if [ ! -n "$1" ] ;then
        echo "Error-请输入config.ini中指定的节点名称"
        exit -1
fi

mvn_path=`source ./readIni.sh global mvn_path`
config_path=`source ./readIni.sh global config_path`
src_path=`source ./readIni.sh "$1" src_path`
branch_name=`source ./readIni.sh "$1" branch_name`
tomcat_port=`source ./readIni.sh "$1" tomcat_port`
zk_port=`source ./readIni.sh "$1" zk_port`


container_name=$1
cd $src_path

git checkout .
git checkout $branch_name
git pull
#复制环境
cd $config_path
sh $config_path/copy_env.sh $1 
 
#构建项目源码
#/data/www/tools/apache-maven-3.5.3/bin/mvn  clean package resources:resources -Dmaven.test.skip=true  -Penv-test
$mvn_path -f $src_path/pom.xml  clean package resources:resources -Dmaven.test.skip=true  -Penv-test

#拷贝jar、war
sh $config_path/copy_projects.sh $container_name

#清空旧容器&创建新容器
echo "stop container "$container_name
docker stop $container_name
echo "delete container" $container_name
docker rm $container_name

echo "run container "$container_name
docker run -d -p $tomcat_port:8080 -p $zk_port:2181 -it -P -v $config_path:/share --name="$container_name" share:v1 /sbin/my_init --enable-insecure-key -- bash /share/start_projects.sh $container_name

