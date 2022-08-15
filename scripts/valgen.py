import json
import glob
import random

def gen_coco():
    
    with open("client/dist/out2.json", "r") as f:
        data = json.load(f)
    
    globgen = glob.iglob("client/data/val2017/*")
    data["labels"] = [""] * 500
    for i in range(0,500):
        filename = next(globgen)
        data["users"][i] = filename
        parts = filename.split("/")
        data["labels"][i] = parts[len(parts)-1]

    with open("client/dist/coco.json", "w+") as f:
        json.dump(data, f)

def conf_features():
    return [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]

def gen_coco_conf():
    with open("client/dist/coco.json", "r") as f:
        data = json.load(f)
    for i in range(0, len(data["mat"])):
        # conf = conf_features()
        idx = random.randint(0, 99)
        entry = [0]*100
        entry[idx] = 1
        data["mat"][i] = entry
    with open("client/dist/coco_conf.json","w+") as f:
        json.dump(data, f)
            
# def gen_coco_labels():
    
#     with open("client/dist/out2.json", "r") as f:
#         data = json.load(f)

#     with open("client/data/annotations/captions_val2017.json", "r") as f:
#         val_data = json.load(f)

def build_labels(length):
    result = []
    if length <= 4:
        result = [1,0,0,0]
    elif length <= 8:
        result = [0,1,0,0]
    elif length <= 12:
        result = [0,0,1,0]
    else:
        result = [0,0,0,1]
    return result

def gen_states():
    with open("client/dist/states.json", "r") as f:
        data = json.load(f)

    # size_map = {} 
    # for i in range(0, len(data["mat"])):
    #     lbl = data["labels"][i]
    #     result = size_map.get(len(lbl), [])
    #     result.append(lbl)
    #     size_map[len(lbl)] = result

    # print(size_map)
    for i in range(0, len(data["mat"])):
        data["mat"][i] = build_labels(len(data["labels"][i]))

    with open("client/dist/states_conf.json", "w+") as f:
        json.dump(data, f)

# gen_coco()        
# gen_states()    
gen_coco_conf()
