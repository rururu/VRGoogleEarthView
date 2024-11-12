#!/bin/sh

cd $(dirname $0)

PORT=8448

fuser -k 8081/tcp
fuser -k 8448/tcp

sleep 16s

cd NMEA_CACHE
python3 ../nmea_cashe2.py --port 8081 &
cd ..

python3 DisplayServer.py ${PORT} &

python3 -m webbrowser -t "http://localhost:${PORT}/chart" &

python3 -m streamlit run GUIControl.py &

#clips/clips -f clp/run.bat &



