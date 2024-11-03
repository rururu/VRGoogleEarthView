#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
from urllib.parse import urlparse, parse_qs
import os
from util import *
import sys
import json
import time

class HttpGetHandler(BaseHTTPRequestHandler):
    """Handler for SSE do_GET."""

    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources/public')

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        if self.path == "/fleet":
            self.send_response(200)
            self.send_header("Content-type", "text/kml")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.mk_kml_fleet(self.root+'/kml/Fleet.kml').encode())
        elif self.path == "/camera":
            self.send_response(200)
            self.send_header("Content-type", "text/kml")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.mk_kml_camera().encode())
        elif self.path == "/fleet":
            self.send_response(200)
            self.send_header("Content-type", "text/kml")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.mk_kml_fleet(self.root+'/kml/Fleet.kml').encode())
        elif path == "/chart-event":
            self.send_response(200)
            self.send_header("Content-type", "text/event-stream")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.mk_event('fleet', self.root+'/chart/fleet.geojson').encode())
        else:
            if path == '/chart':
                filename = self.root+'/LeafletChart.html'
            else:
                filename = self.root+self.path
            self.send_response(200)           
            if filename[-4:] == '.css':
                self.send_header('Content-type', 'text/css')
            elif filename[-5:] == '.json':
                self.send_header('Content-type', 'application/javascript')
            elif filename[-3:] == '.js':
                self.send_header('Content-type', 'application/javascript')
            elif filename[-4:] == '.ico':
                self.send_header('Content-type', 'image/x-icon')
            else:
                self.send_header('Content-type', 'text/html')
            self.end_headers()
            with open(filename, 'rb') as fh:
                html = fh.read()
                #html = bytes(html, 'utf8')
                self.wfile.write(html)

    def log_message(self, format, *args):
        return

    def read_file(self, path):
        with open(path, "r") as f:
            data = f.read()
            f.close()
            return data
            
    def mk_kml_camera(self):
        send_cmd('(step-clock)')
        data = send_cmd('(create-onboard-kml)')
        #print('Camera data '+str(data))
        if len(data) > 0:
            return data
        else:
            return ''

    def mk_kml_fleet(self, path):
        send_cmd('(save-fleet-kml)')
        time.sleep(2)
        data = self.read_file(path)
        print('Update Fleet data ')
        if len(data) > 0:
            return data
        else:
            return ''

    def mk_event(self, kind, path):
        data = self.read_file(path)
        if len(data) > 0:
            return 'event: '+kind+'\ndata: '+data+'\n\n'
        else:
            return ''
        
def run(server_class=HTTPServer, handler_class=HttpGetHandler, port=None):
    global data_path
    server_address = ('127.0.0.1', port)
    httpd = server_class(server_address, handler_class)
    print('Display Server started on port {}..'.format(port))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        httpd.server_close()
    finally:
        if server is not None:
            server.server_close()

race = ''
rpath = 'NMEA_CACHE/RACE.txt'

if not os.path.exists(rpath):
    save_file(rpath, '')
    
while len(race) == 0 or race == 'EOF':
     race = load_file(race_path)
     time.sleep(1)

print("Race "+str(race))

save_file('NMEA_CACHE/'+race+'/AIVDM.txt', '')
save_file('NMEA_CACHE/'+race+'/GPRMC.txt', '')

run(port=8448)



      
    
      
