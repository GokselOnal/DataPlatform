#! /bin/bash

path_orig=$(pwd)
path_mysql_folder="/home/goksel/Documents/DataPlatform/MySQL"
user="goksel"
password="test123"
database="oltp"

mysql --local-infile=1 -u $user -p$password $database < $path_mysql_folder/create_db.sql

