#!/bin/bash  

#--------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-15
#filename	:	readIni.sh
#description	:	读取config.ini中文件属性
#--------------------------------------------------------------------

configFile="./config.ini"          

function read()    
{     
	Key=$1  
        Section=$2  
        Configfile=$3  
        ReadINI=`awk -F '=' '/\['$Section'\]/{a=1}a==1&&$1~/'^$Key$'/{print $2;exit}' $Configfile`    
        echo "$ReadINI"    
}   

echo `read "$2" "$1" "$configFile"`
