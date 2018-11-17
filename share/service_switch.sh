#!/bin/sh

#------------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-10
#filename	:	service_swtich
#description	:	启动jar服务
#
#-----------------------------------------------------------------------


export JAVA_HOME=/share/soft/jdk
export JRE_HOME=$JAVA_HOME/jre

## service name
APP_NAME=$1-1.0-SNAPSHOT

SERVICE_DIR=/share/projects/$4/finance-$1-service
SERVICE_NAME=$APP_NAME
JAR_NAME=$1-1.0-SNAPSHOT\.jar
PID=$SERVICE_NAME\.pid

java_agent_path=${SERVICE_DIR}/agent/skywalking-agent.jar
java_agent=''

# config java agent
cd /share
bash copy_agent.sh $4 $1
[ -f ${java_agent_path} ] && java_agent='-javaagent:'${java_agent_path}

cd $SERVICE_DIR
echo "" > $SERVICE_DIR/services.log

case "$2" in

    start)
        #nohup $JRE_HOME/bin/java -Xms1024m -Xmx1024m -Xloggc:./logs/`date +%F_%H-%M-%S`-gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintGCCause -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=5M -Xdebug -Dsun.zip.disableMemoryMapping=true  -jar $SERVICE_DIR/$JAR_NAME >>$SERVICE_DIR/services.log 2>&1 &
	nohup $JRE_HOME/bin/java ${java_agent} -jar -Xms256m -Xmx256m -Xdebug -Dsun.zip.disableMemoryMapping=true  -Xrunjdwp:transport=dt_socket,address=$3,server=y,suspend=n $SERVICE_DIR/$JAR_NAME >>$SERVICE_DIR/services.log 2>&1 &
        echo $! > $SERVICE_DIR/$PID
        echo "=== start $SERVICE_NAME"
        ;;

    stop)
        kill `cat $SERVICE_DIR/$PID`
        rm -rf $SERVICE_DIR/$PID
        echo "=== stop $SERVICE_NAME"

        sleep 5
        P_ID=`ps -ef | grep -w "$SERVICE_NAME" | grep -v "grep" | awk '{print $2}'`
        if [ "$P_ID" == "" ]; then
            echo "=== $SERVICE_NAME process not exists or stop success"
        else
            echo "=== $SERVICE_NAME process pid is:$P_ID"
            echo "=== begin kill $SERVICE_NAME process, pid is:$P_ID"
            kill -9 $P_ID
        fi
        ;;

    restart)
        $0 stop
        sleep 2
        $0 start
        echo "=== restart $SERVICE_NAME"
        ;;

    *)
        ## restart
        $0 stop
        sleep 5
        $0 start
       ;;
esac
exit 0
