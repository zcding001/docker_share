#!/bin/bash

#------------------------------------------------------------------------
#author		:	zc.ding
#filename	:	copy_env.sh
#date		:	2018-08-10
#
#-----------------------------------------------------------------------

config_path=`source ./readIni.sh global config_path`
src_path=`source ./readIni.sh "$1" src_path`
env_path=`source ./readIni.sh "$1" env_path`
branch_name=`source ./readIni.sh "$1" branch_name`

cd $env_path

sed -i 's/HKJF-TEST-.*/HKJF-TEST-'$branch_name'-/g' common/env_common.properties

for filename in ` ls env* `
do
    SERVICE_NAME=${filename%%.*}
    SERVICE_NAME=${SERVICE_NAME:4:100}
    TARGET_PATH=$src_path"/finance-$SERVICE_NAME/finance-$SERVICE_NAME-service/src/main/resources/env/"
    rm -rf $TARGET_PATH
    mkdir -p $TARGET_PATH
    cp  -a  $filename $TARGET_PATH
    TARGET_PATH=$src_path"/finance-$SERVICE_NAME/finance-$SERVICE_NAME-service/src/main/resources"
    rm -rf $TARGET_PATH/log4j.properties $TARGET_PATH/log4j.xml
    cp  -a common/log4j.xml  $TARGET_PATH
    TARGET_PATH=$src_path"/env"
    rm -rf $TARGET_PATH
    mkdir -p $TARGET_PATH
    cp  -a common/env_common.properties  $TARGET_PATH/
done 



TARGET_PATH=$src_path"/hk-management-services/src/main/resources/env/"
rm -rf $TARGET_PATH
mkdir -p $TARGET_PATH
cp  -a $env_path/web-conf/management/env_test.properties   $TARGET_PATH
cp -a common/env_common.properties $src_path/hk-management-services/src/main/resources/

TARGET_PATH=$src_path"/hk-api-services/src/main/resources/env/"
rm -rf $TARGET_PATH
mkdir -p $TARGET_PATH
cp  -a $env_path/web-conf/api/env_test.properties   $TARGET_PATH
cp -a common/env_common.properties $src_path/hk-api-services/src/main/resources/    

cd $config_path
exit
