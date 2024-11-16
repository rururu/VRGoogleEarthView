
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
    with open(path, "a") as f:
        f.writelines(lst)
    f.close()





        
