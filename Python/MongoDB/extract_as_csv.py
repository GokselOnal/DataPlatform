import pandas as pd
from pymongo import MongoClient

myclient = MongoClient("localhost:28017")
db = myclient["mydb"]
cursor = db["catalog"].find()
df =  pd.DataFrame(list(cursor))
df = df[["type", "model", "screen size"]]
df.to_csv('../../data/catalog.csv', index=False)
