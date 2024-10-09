
pushd "%~dp0"

cd NMEA_CACHE
C:\Users\russor\AppData\Local\Programs\Thonny\python.exe ../nmea_cashe2.py --port 8082 &
cd ..

C:\Users\russor\AppData\Local\Programs\Thonny\python.exe DisplayServer.py 8448 &

rem python3 -m webbrowser -t "http://localhost:${PORT}/chart" &

rem streamlit run GUIControl.py &

clips\CLIPSIDE.exe

