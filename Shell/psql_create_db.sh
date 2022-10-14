#! /bin/bash

path_orig=$(pwd)
path_psql_folder="/home/goksel/Documents/DataPlatform/PostgreSQL"
host="46.101.167.19"
port="5432"
database="dataplatform"

echo "    *Creating the Database"
createdb -h $host -U postgres -p $port $database
echo ; echo "    *Creating the Table"

psql -h $host -U postgres -p $port $database < $path_psql_folder/create_db.sql
echo ; echo
