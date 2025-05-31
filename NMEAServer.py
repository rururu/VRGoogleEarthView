from http.server import BaseHTTPRequestHandler
import socketserver
import socket
import argparse
import logging
import os
import datetime
import sys
from nmea_decoder4 import aivdm_parse, gprmc_parse
#from util import save_file, save_list
from Sockets import exe_cmd
from multiprocessing import Process

parser = argparse.ArgumentParser()

parser.add_argument(
    '--bind',
    help='Set the server interface to bind (default 0.0.0.0)')

parser.add_argument(
    '--outport',
    help='Set outbound port base (default 10000)')

parser.add_argument(
    '--port',
    help='Set the HTTP port to bind (default 8081)')

args = parser.parse_args()
HOST = (args.bind if args.bind else '0.0.0.0')
OUTPORT = (int(args.outport) if args.outport else 10000)
PORT = (int(args.port) if args.port else 8081)

#save_file("RACE.txt", "")

connections = dict()
sockets = dict()

class NMEAHandler(BaseHTTPRequestHandler):
    def do_POST(s):
        content_len = int(s.headers.get('Content-Length'))
        post_body = s.rfile.read(content_len)
        race_id = s.path[6:9]
        race = s.path[6:]
        cashe_message(race, post_body+b'\r\n')
        #forward_message(int(race_id), post_body)
        s.send_response(204)
        s.send_header('Access-Control-Allow-Origin', '*')
        s.end_headers()

    def log_message(self, format, *args):
        pass

times = dict()
flags = dict()
bt_info = []
bt_name = []

def ass_list_ord(typ, lst):
    for e in lst:
        e = e.replace(","," ")
        exe_cmd("(assert ("+typ+" "+e+"))")

def cashe_message(race, message):
    global bt_info, bt_name
    
#     if not os.path.exists(race):
#         try:
#             os.mkdir(race)
#         except OSError:
#             print ("Failed to create directory %s" % race)
#         else:
#             print ("The directory %s was successfully created" % race)
#             save_file(race + "/" + "boat_models.fct", "")

    if message.find(b"AIVDM") != -1 :
        if getFlag(race) == "0": # Save and clear lists
            setFlag("1", race)
            #save_list(race + "/" + "BoatInfo.csv", bt_info)
            ass_list_ord("BoatInfo", bt_info)
            #save_list(race + "/" + "BoatName.csv", bt_name)
            ass_list_ord("BoatName", bt_name)
            exe_cmd("(run)")
            #exe_cmd("(facts)")
            bt_info = []
            bt_name = []
        message2 = aivdm_parse(message)
        if message2.startswith(b"1"):
            bt_info.append(message2.decode())
        elif message2.startswith(b"5"):
            bt_name.append(message2.decode())
    else:
        if message.find(b"GPRMC") != -1 :
            setFlag("0", race)
            openf = 'wb'
            btime = message[7:13]
            now = datetime.datetime.now().strftime("%d-%m-%Y %H:%M")
            if race in times:
                if times[race] != btime :
                    print(now,"Updated boats coordinates on", race, "voyage for time", printTime(btime))
                    times[race] = btime
            else:
                print(now,"Boats coordinates on", race, "voyage for time", printTime(btime) , "are obtained")
                times[race] = btime
                exe_cmd('(assert (RACE "'+race+'"))')
                #save_file(RACEP, race)
        else:
            openf = 'ab'
        message2 = gprmc_parse(message)
        if message2 is not None:
            ass_list_ord("MyBoat", [message2.decode()])
#         path = race + "/" + "MyBoat.csv"
#         with open(path, openf) as fdFlag:
#             if message2 is not None:
#                 #print(str(message2))
#                 fdFlag.write(message2)
#                 ass_list_ord("MyBoat", [message2.decode()])

def setFlag(str, race):
    flags[race] = str

def getFlag(race):
    if race in flags: 
         return flags[race]
    else:
        return "0"
        
def printTime(bstr):
    t = bstr.decode()
    return t[0:2] + ":" + t[2:4] + ":" + t[4:6]

def forward_message(conn_id, message):
    conn = find_or_create_connection(conn_id)
    if conn:
        try:
            conn.send(message + '\r\n'.encode('ascii'))
        except Exception:
            print('Connection lost on port ' + str(conn_id) + ', closing.')
            conn.close()
            connections.pop(conn_id, None)


def find_or_create_connection(conn_id):
    if conn_id in connections:
        return connections[conn_id]
    else:
        conn = None
        if conn_id not in sockets:
            sockets[conn_id] = create_socket(conn_id)
        conn = accept_connection(sockets[conn_id])
        if conn:
            connections[conn_id] = conn
        return conn


def create_socket(conn_id):
    logging.info('Creating socket for race ID ' + str(conn_id))
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setblocking(False)
    sock.bind((HOST, OUTPORT + conn_id))
    sock.listen(0)
    return sock


def accept_connection(sock):
    try:
        (conn, address) = sock.accept()
        logging.info('Accepted connection on port '
                     + str(sock.getsockname()[1]))
        return conn
    except IOError:
        return None


def start_NMEAServer():
    logging.basicConfig(level=logging.INFO)

    logging.info("Creating NMEA Server on port " + str(PORT))
    server = None
    try:
        server = socketserver.TCPServer(("", PORT), NMEAHandler)
        logging.info("NMEA Server listening on port " + str(PORT))
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass
    except Exception as e:
        print(f"Error: {e}")  
        try:
            while True:
                pass
        except KeyboardInterrupt:
            print('Ctrl + C')
            sys.exit()
        
    finally:
        if server is not None:
            logging.info('Cleaning up')
            server.server_close()
            logging.info('Stopping httpd')
        logging.info('Exit\n')
        
if __name__ == '__main__':
    start_NMEAServer()
