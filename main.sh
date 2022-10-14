#! /bin/bash

path_orig=$(pwd)
path_shell_folder="Shell"
path_python_folder="Python"
path_mongo_folder="Python/MongoDB"
path_ibmdb2_folder="Python/IBMDB2"



cd $path_shell_folder
./drop_dbs.sh
./download_files.sh
./mysql_create_db.sh
./mysql_dump.sh

cd $path_orig
cd $path_mongo_folder
sudo docker-compose up -d
python create_db.py
python extract_as_csv.py

cd $path_orig
cd $path_python_folder
python transform.py

cd $path_orig
cd $path_shell_folder
./psql_create_db.sh
./psql_import_data.sh
./psql_dimensional_modelling.sh
./psql_core.sh
./psql_export_as_csv.sh


cd $path_orig
cd $path_ibmdb2_folder
python etl.py




