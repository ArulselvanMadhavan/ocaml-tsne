import json
import glob

with open("client/dist/out2.json", "r") as f:
    data = json.load(f)

globgen = glob.iglob("client/data/val2017/*")

for i in range(0,500):
    filename = next(globgen)
    data["users"][i] = filename

with open("client/dist/coco.json", "w+") as f:
    json.dump(data, f)
