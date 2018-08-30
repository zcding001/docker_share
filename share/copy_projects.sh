#!/bin/sh
#---------------------------------------------------------------------
#author		:	zc.ding
#date		:	2018-08-15
#descript	:	部署war、jar项目
#
#$1		:	config.ini中对应的节点名称	
#---------------------------------------------------------------------


if [ ! -n "$1" ] ;then
        echo "Error-请输入config.ini中指定的节点名称"
        exit -1
fi

config_path=`source ./readIni.sh global config_path`
src_path=`source ./readIni.sh "$1" src_path`
dst_path=`source ./readIni.sh "$1" dst_path`

SRC_DIR=$src_path/
DST_DIR=$dst_path/$1/

mkdir -p $DST_DIR

cd $DST_DIR
rm -rf $DST_DIR/finance-*
mkdir -p finance-invest-service/lib finance-loan-service/lib finance-payment-service/lib finance-secondary-service/lib finance-user-service/lib

cp -rf "$SRC_DIR"finance-invest/finance-invest-service/target/invest-1.0-SNAPSHOT.jar  "$DST_DIR"finance-invest-service/
cp -rf "$SRC_DIR"finance-invest/finance-invest-service/target/lib/*                   "$DST_DIR"finance-invest-service/lib/

cp -rf "$SRC_DIR"finance-user/finance-user-service/target/user-1.0-SNAPSHOT.jar  "$DST_DIR"finance-user-service/
cp -rf "$SRC_DIR"finance-user/finance-user-service/target/lib/*                   "$DST_DIR"finance-user-service/lib/

cp -rf "$SRC_DIR"finance-loan/finance-loan-service/target/loan-1.0-SNAPSHOT.jar  "$DST_DIR"finance-loan-service/
cp -rf "$SRC_DIR"finance-loan/finance-loan-service/target/lib/*                   "$DST_DIR"finance-loan-service/lib/

cp -rf "$SRC_DIR"finance-payment/finance-payment-service/target/payment-1.0-SNAPSHOT.jar  "$DST_DIR"finance-payment-service/
cp -rf "$SRC_DIR"finance-payment/finance-payment-service/target/lib/*                   "$DST_DIR"finance-payment-service/lib/

cp -rf "$SRC_DIR"finance-secondary/finance-secondary-service/target/secondary-1.0-SNAPSHOT.jar  "$DST_DIR"finance-secondary-service/
cp -rf "$SRC_DIR"finance-secondary/finance-secondary-service/target/lib/*                   "$DST_DIR"finance-secondary-service/lib/

# copy tomcat soft
cp -rf $config_path/soft/tomcat $DST_DIR
rm -rf "$DST_DIR"tomcat/webapps/*.war 

# war包
cp -rf "$SRC_DIR"hk-management-services/target/hk-management-services.war "$DST_DIR"tomcat/webapps/
if [[ $1 == *cxj* ]]
then
	cp -rf "$SRC_DIR"hk-api-services/target/hk-api-services.war "$DST_DIR"tomcat/webapps/
fi
if [[ $1 == *hk* ]]
then
	cp -rf "$SRC_DIR"hk-financial-services/target/hk-financial-services.war "$DST_DIR"tomcat/webapps/
fi
cd $config_path
