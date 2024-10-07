
pushd "%~dp0"

PORT=8448

cd NMEA_CACHE
python3 ../nmea_cashe2.py --port 8081 &
cd ..

python3 DisplayServer.py 8448 &

python3 -m webbrowser -t "http://localhost:8448/chart" &

python3 -m streamlit run GUIControl.py &

clips\CLIPSIDE.exe

