# docker rm -f oracle23

# docker network remove i2b2-net
I2B2_DATA_ORACLE_TAG=$1
I2B2_CORE_SERVER_HOST="i2b2-core-server"
I2B2_CORE_SERVER_PORT="8080"
docker  network create i2b2-net

docker run -d \
  --name oracle23 \
  -p 1521:1521 \
  -e ORACLE_PWD=MyStrongPass123 \
  -v /home/runner/work/i2b2-data/i2b2-data/:/i2b2 \
  --network i2b2-net \
  container-registry.oracle.com/database/free:latest

echo "Waiting for Oracle to be ready..."
sleep 180
docker cp create_users.sql oracle23:/

docker exec oracle23 bash -c " sqlplus -s sys/MyStrongPass123@FREEPDB1 as sysdba @/create_users.sql"


# docker exec -i oracle23 bash -c " sqlplus i2b2demodata/demouser@FREEPDB1"

root=/home/runner/work/i2b2-data/i2b2-data/
cd $root

IP=localhost	
DEMO_PASS='demouser'	
docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')

CELL=i2b2demodata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Crcdata/
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties
cat db.properties

ant -f data_build.xml create_crcdata_tables_release_1-8
ant -f data_build.xml create_procedures_release_1-8
ant -f data_build.xml db_demodata_load_data

CELL=i2b2hive
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Hivedata
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties
ant -f data_build.xml create_hivedata_tables_release_1-8
ant -f data_build.xml db_hivedata_load_data


CELL=i2b2imdata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Imdata
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties
cat db.properties
ant -f data_build.xml create_imdata_tables_release_1-8
ant -f data_build.xml db_imdata_load_data 



CELL=i2b2metadata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Metadata
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties
cat db.properties
ant -f data_build.xml create_metadata_tables_release_1-8
ant -f data_build.xml db_metadata_load_data 
#ant -f data_build.xml create_metadata_procedures_release_1-8 #not mentioned in installation document
# ant -f data_build.xml db_metadata_load_identified_data #phi data already executing in db_metadata_load_data
# ant -f data_build.xml db_metadata_run_total_count_sqlserver #issue



CELL=i2b2pm
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties

echo "Replacing host:port in Pmdata/scripts/demo/pm_access_insert_data.sql.."
sed -i "s/localhost:9090/$I2B2_CORE_SERVER_HOST:$I2B2_CORE_SERVER_PORT/g" $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata/scripts/demo/pm_access_insert_data.sql

ant -f data_build.xml create_pmdata_tables_release_1-8
ant -f data_build.xml create_triggers_release_1-8
ant -f data_build.xml db_pmdata_load_data

CELL=i2b2workdata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Workdata
cat "$root/docker/i2b2-oracle/db.properties"  | sed "s/localhost/$docker_network_gateway_ip/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/" > db.properties
ant -f data_build.xml create_workdata_tables_release_1-8
ant -f data_build.xml db_workdata_load_data

cd $root
df -h
rm -rf .git
rm -rf edu.harvard.i2b2.data
df -h
docker commit oracle23 $I2B2_DATA_ORACLE_TAG 


docker commit oracle23 $docker_username/$docker_reponame:i2b2-data-oracle_$I2B2_DATA_ORACLE_TAG
docker push $docker_username/$docker_reponame:i2b2-data-oracle_$I2B2_DATA_ORACLE_TAG
