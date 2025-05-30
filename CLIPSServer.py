import json
from clips_interface import *
from Sockets import start_data_server

BASE_DIR = "clp"

BASE_FILES = [
    "Templates.clp",
    "GlobalFunctions.clp",
    "KMLGeneration.clp",
    "BoatInformation.clp",
    "CommandControl.clp"]

def load_clp_files(clp_dir, clp_files):
    for f in clp_files:
        p = clp_dir+"/"+f
        r = env.eval('(load "'+p+'")')
        print(p+' : '+str(r))
    
def start_clips():
    print("Loading clp files..")
    base = load_clp_files(BASE_DIR, BASE_FILES)
    reset()
    
def data_handler(data):
    if data.startswith("(") or data.startswith("?"):
        r = eval_clips(data)
        return r
    else:
        print("CLIPSServer wrong data: "+data)
        return None

if __name__ == '__main__':
    print("clipspy starts..")
    start_clips()
    print("CLIPS Server starts..")
    start_data_server(data_handler)
