
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
    cms = ""
    for c in lst:
        cms = cms+c+'\n'
    save_file('path', cms)
    
def load_names(path):
    lst = line_list(path)
    bb = [x[:-1] for x in lst]
    return bb
    