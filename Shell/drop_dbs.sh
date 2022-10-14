#! /bin/bash

path_orig=$(pwd)
path_shell_folder="Shell"

cd $path_shell_folder
./mysql_drop_table.sh
./psql_drop_db.sh
