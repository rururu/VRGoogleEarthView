import time

CMD_PATH = 'resources/public/comm/command.txt'
TIMEOUT = 20

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
    for i in range(TIMEOUT):
        buf = load_file(CMD_PATH)
        if len(buf) < 2 or buf.startswith('R:'):
            save_file(CMD_PATH, '"C:'+cmd+'"')
            for i in range(TIMEOUT):
                buf = load_file(CMD_PATH)
                if buf.startswith('R:'):
                    return buf[2:]
                time.sleep(1)
        else:
            print('Command '+cmd+' waiting result timeout '+str(TIMEOUT))
            return ''
        time.sleep(1)
    print('Command '+cmd+' waiting server timeout '+str(TIMEOUT))
    return ''
