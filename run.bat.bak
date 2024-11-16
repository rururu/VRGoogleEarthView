
pushd "%~dp0"

cd NMEA_CACHE
start python.exe ../nmea_cashe2.py --port 8081
cd ..

start python.exe DisplayServer.py 8448

start python.exe -m webbrowser -t "http://localhost:8448/chart"

start python.exe -m streamlit run GUIControl.py

start clips\CLIPSDOS.exe -f clp/run.bat

exit

