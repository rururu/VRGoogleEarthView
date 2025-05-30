import time
from datetime import datetime

TIMEOUT = 10

def load_file(path):
    with open(path, "r") as f:
        txt = f.read()
    return txt

def line_list(path):
    with open(path, "r") as f:
        lst = f.readlines()
    return lst

def save_file(path, data):
    with open(path, "w") as f:
        f.write(data)

def save_list(path, lst):
    with open(path, "w") as f:
        f.write("\n".join(lst))
        f.write("\n")

def load_names(path):
    lst = line_list(path)
    bb = [x[:-1] for x in lst]
    return bb

def find_cmd_result(txt):
    lst = txt.split('"')
    if len(lst) > 4:
        return lst[3]
    else:
        return False
    
def empty_file(path):
    return load_file(path) == ''
    
def send_cmd(cmd):
    if cmd == '(exit-CLIPS)':
        TIMEOUT2 = 2
    else:
        TIMEOUT2 = TIMEOUT
    for i in range(TIMEOUT):
        buf = load_file(CMD_PATH)
        if len(buf) < 2:
            save_file(RST_PATH, '')
            save_file(CMD_PATH, '"'+cmd+'"')
            for i in range(TIMEOUT2):
                buf = load_file(RST_PATH)
                if len(buf) > 1:
                    return buf
                time.sleep(1)
        else:
            print('Command '+cmd+' waiting result timeout '+str(TIMEOUT2))
            return ''
        time.sleep(1)
    print('Command '+cmd+' waiting server timeout '+str(TIMEOUT))
    return ''

def after(d1, d2): # date format '2023-02-28 14:30:00+05:30'
    frm = "%Y-%m-%d %H:%M:%S%z"
    do1 = datetime.strptime(d1, frm)
    do2 = datetime.strptime(d2, frm)
    return do1 < do2

# print(after("2025-05-11 20:12:00+00:00", "2025-05-11 20:12:01+00:00"))
# print(after("2025-06-11 20:12:00+00:00", "2025-05-11 20:12:01+00:00"))
    

