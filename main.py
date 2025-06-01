from multiprocessing import Process
import time

from CLIPSServer import start_CLIPSServer
from NMEAServer import start_NMEAServer
from DisplayServer import start_DisplayServer
from webbrowser import open

if __name__ == '__main__':
    Process(target=start_CLIPSServer).start()
    time.sleep(2)
    Process(target=start_NMEAServer).start()
    time.sleep(2)
    Process(target=start_DisplayServer).start()
    time.sleep(2)
    Process(target=open, args=("http://localhost:8448/chart",)).start()
