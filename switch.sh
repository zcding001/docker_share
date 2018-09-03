#!/bin/bash

#--------------------------------------------------------------------------
#author		:	zc.ding
#Filename	:	switch.sh
#Revision	:	1.0
#Date		:	2018-08-14
#Email		:	zhichaoding@hongkun.com
#Description	:	Dynamically switch the docker test environment to achieve no waiting test
#	
#
#--------------------------------------------------------------------------

if [ ! -n "$1" ] ;then
        echo "Error-请输入config.ini中对应的节点名称, 不能以'_switch'结尾"
        exit -1
fi

start_time=`date +%s`

root_path=/data/www/projects/docker_share
nodes_path=${root_path}/nodes/
log_prefix="[switch]"
new_node=$1
old_node=$1"_switch"
rinetd_path="/usr/sbin/rinetd"

cd ${root_path}
echo ${log_prefix}"验证节点启动状态，防止并发"
if [[ -f ${nodes_path}${new_node} && -f ${nodes_path}${old_node} ]]
then
        echo ${log_prefix}"节点"${new_node}","${old_node}"都在启动中，不得重复操作."
        exit -1
fi

#判断node节点对应的文件是否存在
if [[ -f ${nodes_path}${new_node} ]];then
        echo ${log_prefix} ${new_node}"已经存在."
        new_node=$1"_switch"
        old_node=$1
fi

echo ${log_prefix}"需要启动的容器节点-"${new_node}
echo ${log_prefix}"需要停止的容器节点-"${old_node}

cd ${root_path}/share
url=`source ./readIni.sh "$new_node" url`
tomcat_port=`source ./readIni.sh "$new_node" tomcat_port`
proxy_port=`source ./readIni.sh "$new_node" proxy_port`
zk_port=`source ./readIni.sh "$new_node" zk_port`
proxy_zk_port=`source ./readIni.sh "$new_node" proxy_zk_port`


cd ${root_path}
echo ${log_prefix}"创建新节点代理配置文件."
echo -e "0.0.0.0 ${proxy_port} 0.0.0.0 ${tomcat_port} \n0.0.0.0 ${proxy_zk_port} 0.0.0.0 ${zk_port}" > ${nodes_path}${new_node}
chmod 777 ${nodes_path}${new_node}
        
echo ${log_prefix}"启动节点"${new_node}"对应的docker容器."
cd share
sh docker_init.sh ${new_node}

echo ${log_prefix}"容器启动完成, 开始监控服务运行状态."
count=1
while [ ${count} -le 80 ]
do
	echo ${log_prefix}"尝试第"${count}"次连接"${url}
	http_code=$(curl -I -m 10 --connect-timeout 1 -o /dev/null -s -w %{http_code} $url)
	if [ ${http_code} -eq 200 ]
	then
		let count=1000000
	else
		let count++
		sleep 3
	fi
done
echo ${log_prefix}${url}"测试状态码:"${http_code}
state=0
if [ ${http_code} -eq 200 ]
then
	echo ${log_prefix}"服务启动成功."
        echo ${log_prefix}"查找运行中的rinetd代理节点-"${old_node}
	rinted_pid=$(ps -ef|grep rinetd|grep -w ${rinetd_path}' -c '${nodes_path}${old_node}|grep -v 'grep'|awk '{print $2}')
 	echo ${log_prefix}${old_node}"节点代理对应的PID-"${rinted_pid}
	if [ ${rinted_pid} ];then
		echo ${log_prefix}"运行中rinetd代理的PID-"${rinted_pid}", 直接kill掉"
		sudo kill -9 $rinted_pid
	fi
	echo ${log_prefix}"启动新的代理."
	nohup ${rinetd_path} -c ${nodes_path}${new_node} > /dev/null 2>&1 &
                
	echo ${log_prefix}"删除旧的节点标识-"${old_node}
        rm -rf ${nodes_path}${old_node}
        echo ${log_prefix}"删除旧的容器-"${old_node}
        sh del_container.sh ${old_node}       
else    
        echo ${log_prefix}"服务启动失败."
        echo ${log_prefix}"删除启动失败的容器、node节点对应的文件."
                
        sh del_container.sh ${new_node}
        rm -rf ${nodes_path}${new_node}
	state=-1
fi

end_time=`date +%s`
dif_time=$[ end_time - start_time ]
echo ${log_prefix}"耗时["$dif_time "]秒, 运行节点["${new_node}"], 执行状态["${state}"](非0标识启动失败!)"

exit ${state}

