
pushd "%~dp0"

start python.exe CLIPSServer.py

start python.exe NMEAServer.py

start python.exe DisplayServer.py 

start python.exe -m webbrowser -t "http://localhost:8448/chart"

rem exit

