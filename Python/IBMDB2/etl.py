from secret import SecretFile
import pandas as pd
import ibm_db


class ETL:
    def __init__(self):
        self.total = None
        self.conn = None

    def extract(self):
        self.total = pd.read_csv("../../data/core_data.csv", delimiter="|")
        self.total = self.total[1:-1]
        self.total = self.total.reset_index().iloc[:, 1:]

    def transform(self):
        self.total.columns = [col.strip() for col in self.total.columns]
        self.total["total_price"] = self.total.quantity * self.total.unit_price
        for i in range(self.total.shape[1]):
            self.total[self.total.columns[i]] = self.total[self.total.columns[i]].astype("i")

    def load(self):
        def connection_with_db2():
            dsn_database = SecretFile.dsn_database
            dsn_uid      = SecretFile.dsn_uid
            dsn_pwd      = SecretFile.dsn_pwd
            dsn_hostname = SecretFile.dsn_hostname
            dsn_port     = "32304"
            dsn_protocol = "TCPIP"
            dsn_driver   = "IBM DB2 ODBC DRIVER"

            dsn = ("DRIVER={{IBM DB2 ODBC DRIVER}};" "DATABASE={0};" "HOSTNAME={1};" "PORT={2};" "PROTOCOL=TCPIP;" "UID={3};" "PWD={4};SECURITY=SSL").format(
                dsn_database, dsn_hostname, dsn_port, dsn_uid, dsn_pwd)
            options = {ibm_db.SQL_ATTR_AUTOCOMMIT: ibm_db.SQL_AUTOCOMMIT_ON}
            self.conn = ibm_db.connect(dsn, "", "", options)

        def import_data_to_db2():
            cols = 'sales_id,date_key,customer_id, product_id, quantity, unit_price, total_price'
            SQL = 'Insert into SALESDATA(' + cols + ') values(?,?,?,?,?,?,?)'
            stmt = ibm_db.prepare(self.conn, SQL)

            for n in range(self.total.shape[0]):
                ibm_db.bind_param(stmt, 1, str(self.total.at[n, 'sales_id']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 2, str(self.total.at[n, 'date_key']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 3, str(self.total.at[n, 'customer_id']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 4, str(self.total.at[n, 'product_id']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 5, str(self.total.at[n, 'quantity']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 6, str(self.total.at[n, 'unit_price']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.bind_param(stmt, 7, str(self.total.at[n, 'total_price']), ibm_db.SQL_PARAM_INPUT, ibm_db.SQL_INTEGER)
                ibm_db.execute(stmt)

        connection_with_db2()
        import_data_to_db2()
        ibm_db.close(self.conn)

    def pipeline(self):
        self.extract()
        self.transform()
        self.load()

if __name__ == '__main__':
    etl = ETL()
    etl.pipeline()
