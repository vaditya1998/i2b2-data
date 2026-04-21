#!/bin/bash
I2B2_WILDFLY_HOST="i2b2-core-server"
I2B2_WILDFLY_PORT="8080"
PG_USER="postgres"
BASE_DIR="/i2b2"
I2B2_DATA_DIR="$BASE_DIR/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall"
export PGPASSWORD="demouser"

CRCDATA_DIR="$I2B2_DATA_DIR/Crcdata"
HIVEDATA_DIR="$I2B2_DATA_DIR/Hivedata"
PMDATA_DIR="$I2B2_DATA_DIR/Pmdata"
METADATA_DIR="$I2B2_DATA_DIR/Metadata"
WORKDATA_DIR="$I2B2_DATA_DIR/Workdata"
DEMO_PASS='demouser'

I2B2_USER="i2b2"
I2B2_DEMODATA_USER="i2b2demodata"
I2B2_HIVE_USER="i2b2hive"
I2B2_IMDATA_USER="i2b2imdata"
I2B2_METADATA_USER="i2b2metadata"
I2B2_PM_USER="i2b2pm"
I2B2_WORKDATA_USER="i2b2workdata"

echo $BASE_DIR
echo "Creating i2b2 database.."
echo
psql -U $PG_USER -f "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/create-db.sql"
echo 
echo "Creating i2b2 schema.."
echo
psql -U $I2B2_USER -w -f "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/create-schema.sql"
echo

CELL=i2b2demodata
cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Crcdata/
cat "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/db.properties" | sed "s/localhost/172.17.0.1/g" |sed "s/PWD/$DEMO_PASS/g" | sed "s/USER_NAME/$CELL/g"| sed "s/DB_NAME/$CELL/g" > db.properties	
ls
# cat db.properties

ant -f data_build.xml create_crcdata_tables_release_1-8
ant -f data_build.xml create_procedures_release_1-8
ant -f data_build.xml db_demodata_load_data

CELL=i2b2hive
cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Hivedata
cat "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
ant -f data_build.xml create_hivedata_tables_release_1-8
ant -f data_build.xml db_hivedata_load_data

CELL=i2b2metadata
cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Metadata
cat "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
cat db.properties
ant -f data_build.xml create_metadata_tables_release_1-8
ant -f data_build.xml db_metadata_load_data 
ant -f data_build.xml create_metadata_procedures_release_1-8
# ant -f data_build.xml db_metadata_run_total_count_sqlserver #issue

CELL=i2b2pm
cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata
cat "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
ant -f data_build.xml create_pmdata_tables_release_1-8
ant -f data_build.xml create_triggers_release_1-8

echo "Replacing host:port in Pmdata/scripts/demo/pm_access_insert_data.sql.."
sed -i "s/localhost:9090/$I2B2_WILDFLY_HOST:$I2B2_WILDFLY_PORT/g" /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata/scripts/demo/pm_access_insert_data.sql
echo
ant -f data_build.xml db_pmdata_load_data

CELL=i2b2workdata
cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Workdata
cat "$BASE_DIR/i2b2-data/docker/i2b2-pgsql/db.properties" | sed "s/localhost/172.17.0.1/"  |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
ant -f data_build.xml create_workdata_tables_release_1-8
ant -f data_build.xml db_workdata_load_data


echo "Updating db_lookup tables in i2b2hive.."
psql -U $I2B2_HIVE_USER -d i2b2 -w -c "update crc_db_lookup set c_db_fullschema = 'i2b2demodata'"
psql -U $I2B2_HIVE_USER -d i2b2 -w -c "update work_db_lookup set c_db_fullschema = 'i2b2workdata'"
psql -U $I2B2_HIVE_USER -d i2b2 -w -c "update ont_db_lookup set c_db_fullschema = 'i2b2metadata'"
echo 

echo "Updating i2b2 demo data: Fixing hardcoded PUBLIC schema references in i2b2metadata(c_dimcode)"
psql -U $I2B2_METADATA_USER -d i2b2 -w -c "update i2b2metadata.i2b2 Set c_dimcode = REPLACE(c_dimcode, 'PUBLIC.PATIENT_DIMENSION', 'i2b2demodata.patient_dimension') where c_dimcode LIKE '%PUBLIC.PATIENT_DIMENSION%'; "


echo "Demodata inserted successfully."
rm -rf /i2b2/i2b2-data/edu.harvard.i2b2.data/

# # for act 
# CELL=i2b2demodata
# cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Crcdata/
# cat "$BASE_DIR/db.properties" | sed "s/localhost/172.17.0.1/g" |sed "s/PWD/$DEMO_PASS/g" | sed "s/USER_NAME/$CELL/g"| sed "s/DB_NAME/$CELL/g"|sed "s/db.project=demo/db.project=act/g" > db.properties	
# cat db.properties

# #ant -f data_build.xml create_crcdata_tables_release_1-8 
# # ant -f data_build.xml create_procedures_release_1-8
# ant -f data_build.xml db_demodata_load_data


# # for act 
# CELL=i2b2metadata
# cd /i2b2/i2b2-data/edu.harvard.i2b2.data/Release_1-8/NewInstall/Metadata
# cat "$BASE_DIR/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/"|sed "s/db.project=demo/db.project=act/g" > db.properties
# cat db.properties
# ant -f data_build.xml create_metadata_tables_release_1-8
# ant -f data_build.xml db_metadata_load_data 

