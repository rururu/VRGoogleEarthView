
pushd "%~dp0"

cd NMEA_CACHE
start C:\Users\russor\AppData\Local\Programs\Thonny\python.exe ../nmea_cashe3.py --port 8081
cd ..

start C:\Users\russor\AppData\Local\Programs\Thonny\python.exe DisplayServer.py 8448

start C:\Users\russor\AppData\Local\Programs\Thonny\python.exe -m webbrowser -t "http://localhost:8448/chart"

start C:\Users\russor\AppData\Local\Programs\Thonny\python.exe -m streamlit run GUIControl.py

start clips\CLIPSDOS.exe -f clp/run.bat

exit

