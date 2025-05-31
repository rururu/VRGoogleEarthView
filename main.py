from multiprocessing import Process

from CLIPSServer import start_CLIPSServer
from NMEAServer import start_NMEAServer
from DisplayServer import start_DisplayServer
from webbrowser import open

if __name__ == '__main__':
    Process(target=start_CLIPSServer).start()
    Process(target=start_NMEAServer).start()
    Process(target=start_DisplayServer).start()
    Process(target=open, args=("http://localhost:8448/chart",)).start()
