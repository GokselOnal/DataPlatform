import json
from pymongo import MongoClient, InsertOne


client = pymongo.MongoClient("localhost:28017")

db = client["mydb"]
col = db["catalog"]


requesting = []
with open(r"../data/catalog.json") as f:
    for json_obj in f:
        dict_ = json.loads(json_obj)
        requesting.append(InsertOne(dict_))

result = col.bulk_write(requesting)

client.close()
