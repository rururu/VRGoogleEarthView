#!/bin/sh

cd $(dirname $0)

fuser -k 8081/tcp
fuser -k 8448/tcp
fuser -k 8888/tcp

sleep 8s

