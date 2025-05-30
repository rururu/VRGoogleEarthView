#!/bin/sh

cd $(dirname $0)

fuser -k 8081/tcp
fuser -k 8448/tcp
fuser -k 8888/tcp

sleep 16s

python3 CLIPSServer.py &

python3 NMEAServer.py &

python3 DisplayServer.py &

python3 -m webbrowser -t "http://localhost:8448/chart" &



