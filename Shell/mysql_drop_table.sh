#! /bin/bash

path_orig=$(pwd)
path_sql_folder="/home/goksel/Documents/DataPlatform/MySQL"
user="goksel"
password="test123"
database="oltp"

mysql -u $user -p$password $database < $path_sql_folder/drop_table.sql
