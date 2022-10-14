CREATE TABLE sales_data(
	product_id INTEGER,
	customer_id INTEGER,
	price DECIMAL,
	quantity INTEGER,
	timestamp TIMESTAMP
);

-- import data
LOAD DATA LOCAL INFILE '../data/oltpdata.csv' INTO TABLE sales_data FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'

