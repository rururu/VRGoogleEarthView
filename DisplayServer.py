from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
from urllib.parse import urlparse, parse_qs
import os
import json
import time
from nmea_decoder4 import aivdm_parse, gprmc_parse
from util import save_file, save_list, load_file
from Sockets import exe_cmd
        
class HttpGetHandler(BaseHTTPRequestHandler):
    """Handler for SSE do_GET."""

    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'resources/public')

    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        if self.path == "/camera":
            self.send_response(200)
            self.send_header("Content-type", "text/kml")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(self.mk_kml_camera(self.root+'/kml/Camera.kml').encode())
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
        elif path == "/command":
            query_components = parse_qs(parsed_path.query)
            kk = list(query_components.keys())
            if len(kk) > 0:
                cmd = kk[0]
                prm = query_components[cmd][0]
                exe_cmd('('+cmd+' "'+prm+'")')
            self.send_response(200)
            self.send_header("Content-type", "text/event-stream")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
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
            
    def mk_kml_camera(self, path):
        exe_cmd("(assert (move all boats))")
        exe_cmd("(run)")
        data = exe_cmd("(create-onboard-kml)")
        if len(data) > 0:
            return data
        else:
            return ''

    def mk_kml_fleet(self, path):
        data = exe_cmd("(create-fleet-kml)")
        print('Update Fleet data ')
        if len(data) > 0:
            return data
        else:
            return ''

    def mk_event(self, kind, path):
        data = exe_cmd("(create-fleet-geojson)")
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

if __name__ == '__main__':
    myb = load_file("MY_BOAT.txt")
    exe_cmd('(assert (MY-BOAT '+myb+'))')
    exe_cmd('(assert (ONB-BOAT '+myb+'))')

    run(port=int(8448))
