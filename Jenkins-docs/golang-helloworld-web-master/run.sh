#!/bin/bash

cd $GOPATH/src/

mkdir -p /data/log/

go build goweb.go 

./goweb
