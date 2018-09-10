docker_share
	基于docker实现项目在容器中的部署，容器构建完成后会暴露5100~5106端口，同时设置jdk环境变量。更多细节查阅Dockerfile文件。

镜像两种使用用法，
	一、单容器部署
	二、无等待双容器切换部署



######################################### 文件说明  #####################################################
Dockfile
	构建docker容器脚本
	
nodes
	存放运行中的docker容器端口代理配置
	

Shanghai
	解决容器与宿主主机时间相差8小时问题


share（宿主主机与容器挂在的路径）
	config.ini									*容器内容项目配置信息*******
	config.ini.template					配置模板,文件中有各参数说
	baofu_cert									支付证书
	copy_env.sh									拷贝maven项目需要的环境变量			入参:config.ini中节点名称
	copy_projects.sh						拷贝需要运行的项目jar war				入参:config.ini中节点名称
	del_container.sh						容器清楚脚本										入参:config.ini中节点名称
	docker_init.sh							容器启动时执行的脚本						入参:config.ini中节点名称
	projects										存放容器中运行的项目，已config.ini中节点进行容器的区分
	readIni.sh									通过section key的方式读取config.ini中属性信息				入参:config.ini中节点名称、key值
	service_switch.sh						jar服务启动脚本									入参: 服务名称{user|invest|loan|payment...} 操作{start|stop|restart} debug端口 config.ini中节点名称 
	soft												宿主主机与容器共享的软件路径
	start_projects.sh						项目启动脚本										入参:config.ini中节点名称
	
	
soft（存放需要在构建容器是需要嵌入容器中的软件或是文件）
	rinetd.tar.gz								端口代理软件, 安装到宿主主机中，在无等待双容器切换部署的使用场景会使用到此软件做端口代理操作
	

swithch.sh
	无等待测试服务器启动脚本



######################################### 服务状态检查 ######################################################
查看rinetd代理状态
	ps aux|grep rinetd		注意代理指定的配置文件路径吗，文件名称是与容器名称一致的
	
	evelop   63712  0.0  0.0   6316   768 ?        S    Aug27   0:00 rinetd
	evelop  113888  0.0  0.0   6316   868 ?        S    09:06   0:00 /usr/sbin/rinetd -c /xxxx/docker_share/nodes/hk_master
	evelop  152603  0.0  0.0 103320   868 pts/14   S+   11:48   0:00 grep rinetd

查看容器运行状态
	docker ps			注意容器名称，是与rinetd使用的配置文件名称一致
	
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS              PORTS                                                                                                                                                         								NAMES
	f881db64b090        share:v1            "/sbin/my_init --ena   17 minutes ago      Up 17 minutes       0.0.0.0:7011->2181/tcp, 0.0.0.0:33776->5100/tcp, 0.0.0.0:33775->5101/tcp, 0.0.0.0:33774->5102/tcp, 0.0.0.0:33773->5103/tcp, 0.0.0.0:33772->5104/tcp, 0.0.0.0:33771->5105/tcp, 0.0.0.0:33770->5106/tcp, 0.0.0.0:7001->8080/tcp   cxj_master



查看dubbo服务状态
	ps -ef|grep service		注意项目路径

查看tomcat服务状态
	ps -ef|grep tomcat




######################################### 问题排查 ######################################################
问题一
	jenkins构建日志中显示[switch]服务启动失败，尝试连接的地址返回值非200,首先查看项目部署位置是否正确，应该在projects/节点名称/tomcat/webapps
	
问题二
	jenkins构建日志中显示[switch]服务启动成功.但是在浏览器中通过proxy_por访问却是无法连接，那么通过如下命令查看端口代理是否正常。
	首先查看当前容器运行的是config.ini中哪个节点，通过ll nodes/* 查看存在文件名称即表示运行的节点。
	其次执行ps aux|grep rinetd 查看rinetd代理软件是否启动了nodes下指定文件的代理，例如
	root     126256  0.0  0.0   6316   856 ?        S    14:14   0:00 /usr/sbin/rinetd -c /data/www/projects/docker_share/nodes/hk_master
	如果没有说明代理端口有冲突或是配置文件内容有错误，逐一排查
	
问题三
	某些服务服务未启动，在jenkins日志中显示<<<<<<<<!!!!!!!${key}服务启动失败，请进入容器后手动启动!!!!!!!!>>>>>>>>>>>，通过在宿主主机执行ps -ef|grep service查看运行中服务，确定所有服务已经启动，如果有个别服务没有启动，参考start_porjects.sh中服务启动脚本，
	重新启动为运行的服务即可。重启服务需要在容器中进行操作，通过dockert exec -it {容器名称|容器ID} /bin/bash进行登录，进入 /share/下进行相关操作







