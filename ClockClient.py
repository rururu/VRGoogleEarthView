import socket
import time
import sys

def socket_send(host, port, mess):
    s = socket.create_connection((host, port), timeout=10)
    try:
        mess = mess+"\n"
        s.send(mess.encode())
        data = s.recv()
        s.close()
        data = data.decode()
        return data
    except:
        return 'TIMEOUT'

port = sys.argv[1]

while True:
    socket_send("localhost", port, '(step-clock)')
    time.sleep(1)

