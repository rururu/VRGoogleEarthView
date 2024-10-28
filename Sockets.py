import socket

def socket_send(host, port, mess, bufsize=1024):
    s = socket.create_connection((host, port), timeout=10)
    try:
        mess = mess+"\n"
        s.send(mess.encode())
        data = s.recv(bufsize)
        s.close()
        data = data.decode()
        return data
    except:
        return 'TIMEOUT'

def start_socket_server(host, port, handler, bufsize=1024):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind((host, port))
        s.listen()
        #print(f"Socket server wait on {host}:{port}..")
        while True:
            conn,addr = s.accept()
            #print("Got connection from %s" % str(addr))
            data = conn.recv(bufsize)
            data = data.decode()
            #print("Recived: "+data)
            if data.startswith("STOP"):
                conn.close()
                break
            result = handler(data)
            result = str(result)
            conn.send(result.encode())
            conn.close()
