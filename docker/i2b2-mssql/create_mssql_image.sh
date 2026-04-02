I2B2_DATA_MSSQL_TAG=$1
I2B2_WILDFLY_HOST="i2b2-core-server"
I2B2_WILDFLY_PORT="8080"

root=/home/runner/work/i2b2-data/i2b2-data/
quickstart_path=/home/runner/work/i2b2-data/i2b2-data/docker/i2b2-mssql/i2b2-quickstart

cd $root

IP=localhost	
DEMO_PASS='Demouser123'	
cd $quickstart_path
BASE=$(pwd)

docker network create i2b2-net
docker images 

docker run -i -e "ACCEPT_EULA=Y"  -e "SA_PASSWORD=<YourStrong@Passw0rd>" -e "TZ=America/New_York" -p 1433:1433 --net i2b2-net --name i2b2-mssql -d mcr.microsoft.com/mssql/server:2019-latest

sleep 50
docker ps
docker exec --user root i2b2-mssql bash -c "apt-get update && apt-get install -yq curl apt-transport-https gnupg && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && curl https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list | tee /etc/apt/sources.list.d/mssql-server-2019.list && apt-get update && apt-get install -y mssql-server-fts mssql-tools unixodbc-dev"

docker exec --user root i2b2-mssql bash -c "echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/bash.bashrc && apt-get clean && rm -rf /var/lib/apt/lists/*"

docker restart i2b2-mssql
sleep 10

docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q  "SELECT FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') AS IsFullTextInstalled;"
sleep 10

docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q 'SELECT name, database_id,create_date FROM sys.databases ;'

docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q "$(sh conf/mssql/create_dbs.sh)"
sleep 20
docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q "$(sh conf/mssql/create_users.sh)"

docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q 'SELECT name, database_id,create_date FROM sys.databases ;'


#install ant in new terminal
# wget https://dlcdn.apache.org//ant/binaries/apache-ant-1.10.14-bin.tar.gz
# tar -zxvf apache-ant-1.10.14-bin.tar.gz
# export PATH=$PATH:~/apache-ant-1.10.14/bin/

/sbin/ip route|awk '/default/ { print $3 }' || true

CELL=i2b2demodata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Crcdata/
cat "$BASE/conf/mssql/db.properties" | sed "s/localhost/172.17.0.1/g" |sed "s/PWD/$DEMO_PASS/g" | sed "s/USER_NAME/$CELL/g"| sed "s/DB_NAME/$CELL/g" > db.properties	
cat db.properties

ant -f data_build.xml create_crcdata_tables_release_1-8
ant -f data_build.xml create_procedures_release_1-8
ant -f data_build.xml db_demodata_load_data

CELL=i2b2hive
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Hivedata
cat "$BASE/conf/mssql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
ant -f data_build.xml create_hivedata_tables_release_1-8
ant -f data_build.xml db_hivedata_load_data

CELL=i2b2metadata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Metadata
cat "$BASE/conf/mssql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
cat db.properties
ant -f data_build.xml create_metadata_tables_release_1-8
ant -f data_build.xml db_metadata_load_data 
#ant -f data_build.xml create_metadata_procedures_release_1-8 #not mentioned in installation document
# ant -f data_build.xml db_metadata_load_identified_data #phi data already executing in db_metadata_load_data
# ant -f data_build.xml db_metadata_run_total_count_sqlserver #issue


CELL=i2b2imdata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Imdata
cat "$BASE/conf/mssql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
cat db.properties
ant -f data_build.xml create_imdata_tables_release_1-8
ant -f data_build.xml db_imdata_load_data 


CELL=i2b2pm
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata
cat "$BASE/conf/mssql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties

echo "Replacing host:port in Pmdata/scripts/demo/pm_access_insert_data.sql.."
sed -i "s/localhost:9090/$I2B2_WILDFLY_HOST:$I2B2_WILDFLY_PORT/g" $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Pmdata/scripts/demo/pm_access_insert_data.sql

ant -f data_build.xml create_pmdata_tables_release_1-8
ant -f data_build.xml create_triggers_release_1-8
ant -f data_build.xml db_pmdata_load_data

CELL=i2b2workdata
cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Workdata
cat "$BASE/conf/mssql/db.properties" | sed "s/localhost/172.17.0.1/"  |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
ant -f data_build.xml create_workdata_tables_release_1-8
ant -f data_build.xml db_workdata_load_data

cd $BASE
# docker exec -i i2b2-mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YourStrong@Passw0rd>" -Q "$(cat $BASE/conf/mssql/pm_access_insert_data.sql);"

sleep 20
df -h
#removing i2b2-data repo to resolve space issues
rm -rf /home/runner/work/i2b2-data/i2b2-data/i2b2-mssql/i2b2-data/edu.harvard.i2b2.data/

df -h
echo "completed data load for i2b2-data-mssql "

docker commit i2b2-mssql $docker_username/$docker_reponame:i2b2-data-mssql_$I2B2_DATA_MSSQL_TAG
docker push $docker_username/$docker_reponame:i2b2-data-mssql_$I2B2_DATA_MSSQL_TAG


# #for act 
# CELL=i2b2metadata
# cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Metadata
# cat "$BASE/conf/mssql/db.properties"  | sed "s/localhost/172.17.0.1/" |sed  "s/PWD/$DEMO_PASS/" | sed "s/USER_NAME/$CELL/"| sed "s/DB_NAME/$CELL/" > db.properties
# cat db.properties
# ant -f data_build.xml create_metadata_tables_release_1-8
# ant -f data_build.xml db_metadata_load_data 
# # ant -f data_build.xml create_metadata_procedures_release_1-8
# # ant -f data_build.xml db_metadata_load_identified_data 


#act
# CELL=i2b2demodata
# cd $root/edu.harvard.i2b2.data/Release_1-8/NewInstall/Crcdata/
# cat "$BASE/conf/mssql/db.properties" | sed "s/localhost/172.17.0.1/g" |sed "s/PWD/$DEMO_PASS/g" | sed "s/USER_NAME/$CELL/g"| sed "s/DB_NAME/$CELL/g" > db.properties	
# cat db.properties
# ant -f data_build.xml create_crcdata_tables_release_1-8 #only 1 executes
# # ant -f data_build.xml create_procedures_release_1-8
# ant -f data_build.xml db_demodata_load_data



#creating i2b2-mssql-vol image
# docker run --rm --volumes-from i2b2-mssql --name i2b2-mssql-vol -v /tmp/job1:/backup ubuntu tar cvf /backup/backup.tar /var/opt/mssql
# sleep 60
# docker run -d -v /tmp/job1:/backup --name i2b2-mssql-vol-backup ubuntu /bin/sh -c "cd / && tar xvf /backup/backup.tar"
# ls 
# sleep 100
# docker commit i2b2-mssql-vol-backup local/i2b2-mssql-vol


# docker tag local/i2b2-mssql-vol host_name/new_repo:i2b2-mssql-vol-$VERSION-$date
# docker push host_name/new_repo:i2b2-mssql-vol-$VERSION-$date
# docker rm -f i2b2-mssql i2b2-mssql-vol-backup
