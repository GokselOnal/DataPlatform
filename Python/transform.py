from datetime import timedelta, datetime
from random import randrange
import pandas as pd
import random

class TotalData:
    def __init__(self):
        self.oltp      = None
        self.customers = None
        self.catalog   = None
        self.total     = None

    def get_data(self):
        self.oltp      = pd.read_csv("../data/oltpdata.csv", header=None)
        self.customers = pd.read_csv("../data/customers.csv")
        self.catalog   = pd.read_csv("../data/catalog.csv")

    def transform(self):
        self.oltp.columns = ["product_id", "customer_id", "price", "quantity", "timestamp"]
        self.oltp = self.oltp[["price", "quantity", "timestamp"]]

        import warnings
        warnings.filterwarnings("ignore")
        self.total = pd.DataFrame()
        for i in range(self.oltp.shape[0]):
            rand_cat = random.randint(0, self.catalog.shape[0] - 1)
            rand_cus = random.randint(0, self.customers.shape[0] - 1)
            data = dict(self.oltp.loc[i])
            data.update(dict(self.catalog.loc[rand_cat]))
            data.update(dict(self.customers.loc[rand_cus]))
            self.total = self.total.append(data, ignore_index=True)

        self.total.rename(columns={
            "price": "unit_price",
            "CustomerID": "customer_id",
            "Age": "age",
            "Genre": "genre",
            "screen size": "screen_size",
            "Annual_Income_(k$)": "annual_income",
            "Spending_Score": "spending_score"
        }, inplace=True)

        def create_random_date(start, end):
            diff = end - start
            int_diff = (diff.days * 24 * 60 * 60) + diff.seconds
            random_second = randrange(int_diff)
            return start + timedelta(seconds=random_second)

        date_start = datetime.strptime("1/1/2021 1:00 AM", "%m/%d/%Y %I:%M %p")
        date_end = datetime.strptime("1/1/2022 1:00 AM", "%m/%d/%Y %I:%M %p")

        self.total["timestamp"] = [create_random_date(date_start, date_end) for _ in range(self.total.shape[0])]

        self.total = self.total[["timestamp", "customer_id", "genre", "age", "annual_income", "spending_score", "type", "model", "screen_size", "quantity", "unit_price"]]

    def save_data(self):
        self.total.to_csv("../data/total_data.csv", index=False)

    def pipeline(self):
        self.get_data()
        self.transform()
        self.save_data()

if __name__ == '__main__':
    total = TotalData()
    total.pipeline()
