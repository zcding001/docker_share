#!/bin/bash

content=`docker port $1`
if [ $? -ne 0 ]; then
    echo "0"
else
	if [[ ${content} =~ "->" ]]
	then
		echo "1"
	else
		echo "2"
	fi
fi
