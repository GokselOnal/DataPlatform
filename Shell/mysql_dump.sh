#! /bin/bash

path_mysql_folder="/home/goksel/Documents/DataPlatform/MySQL"
user="goksel"
password="test123"
database="oltp"

mysqldump -u $user -p$password $database sales_data > $path_mysql_folder/sales_data_dump.sql
