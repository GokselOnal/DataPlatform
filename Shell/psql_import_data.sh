#! /bin/bash

path_orig=$(pwd)
path_psql_folder="/home/goksel/Documents/DataPlatform/PostgreSQL"
host="46.101.167.19"
port="5432"
database="dataplatform"
table="total"

psql -h $host -U postgres -p $port "$database" -c "\copy $table from ../data/total_data.csv delimiter ',' csv header;"

