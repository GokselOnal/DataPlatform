#! /bin/bash

path_orig=$(pwd)
path_psql_folder="/home/goksel/Documents/DataPlatform/PostgreSQL"
host="46.101.167.19"
port="5432"
database="dataplatform"

psql -h $host -U postgres -p $port $database < $path_psql_folder/core.sql
