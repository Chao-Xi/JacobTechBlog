#!/bin/bash

app=$2
port=$3
targetDir=$4

start(){
    cd ${targetDir}
    nohup java -jar ${app} --server.port=${port} >>/dev/null 2>&1& echo $! > service.pid
    cd -
    
}


stop(){
    pid=`cat service.pid`
    if [ -z $pid ]
    then 
        echo "pid"
    else
        kill -9 ${pid}
        kill -9 ${pid}
        kill -9 ${pid}
    fi
}


case $1 in
start)
    start
    ;;
stop)
    stop
    ;;
    
restart)
    stop
    sleep 5
    start
    ;;
*)
    echo "[start|stop|restart]"
    ;;
    
esac
