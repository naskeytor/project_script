#!/bin/bash


# Install docker on debian/ubuntu


if [ -n "$(command -v docker)" ]; then
	echo "Already installed"
else 
	sudo apt update
	sudo apt upgrade -y
	sudo curl -fsSL https://get.docker.com | sh
	sudo systemctl start docker
    	sudo systemctl enable docker
fi

usermod -aG docker ${USER}
echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/docker" | sudo tee -a /etc/sudoers

# Install Cassandra container
docker pull cassandra:latest
docker run -d --name cassandra-container -p 9042:9042 cassandra

#bash
#sleep 3

# Set variables
#GET_CONTAINER_ID=$(docker ps | (while read a b c ; do [ $b = "cassandra" ] && echo $a; done))
export GET_CONTAINER_ID=$(docker ps | grep cassandra-container | awk '{print $1}')
export GET_CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  ${GET_CONTAINER_ID})
export KEYSPACE_NAME="final_project"


# Get csv table headers

#ls -s /usr/bin/python3 /usr/bin/python 
#alias python=python3 >> ~/.bashrc
#source ~/.bashrc
cat <<EOF > get_csv_headers.py

import csv
import os

file_name = os.path.join(os.getcwd(), "Air_Traffic_Passenger_Statistics.csv")

with open(file_name, "r") as f:
    lector_csv = csv.reader(f)
    header_list = next(lector_csv)

text_var = 'text'
int_var = 'int'
l = []
for i in header_list:
    if i == 'Activity Period' or i == 'Passenger Count' or i == 'Adjusted Passenger Count' or i == 'Year':
        l.append('"{}" {} '.format(i, int_var))
    else:
        l.append('"{}" {} '.format(i, text_var))
l.insert(0, '"id" INT PRIMARY KEY')
res = ",".join(l)
print("CREATE TABLE air_traffic ({});".format(res))

EOF

# Set CSV id column
cat <<EOF > set_csv_id.py

import csv

# Specify the input and output file paths
input_file = 'Air_Traffic_Passenger_Statistics.csv'
output_file = 'Air_Traffic_Passenger_Statistics_with_ID.csv'

# Open the input and output files
with open(input_file, 'r') as csv_input, open(output_file, 'w', newline='') as csv_output:
    reader = csv.reader(csv_input)
    writer = csv.writer(csv_output)

    # Read the header row
    header = next(reader)
    header.insert(0, 'id')  # Add 'id' column to the header

    # Write the modified header to the output file
    writer.writerow(header)

    # Initialize the ID counter
    id_counter = 1

    # Process each row in the input file
    for row in reader:
        row.insert(0, id_counter)  # Add the ID value at the beginning of each row
        writer.writerow(row)

        id_counter += 1  # Increment the ID counter for the next row

print("ID column added successfully!")


EOF

chmod +x get_csv_headers.py set_csv_id.py
python3 set_csv_id.py

export GET_CSV_HEADERS=$(python3 get_csv_headers.py)

echo ${GET_CSV_HEADERS}

#bash
# create the keyspace

#docker exec -it ${GET_CONTAINER_ID} /bin/bash

if time grep -qi "starting listening" <(docker logs -f cassandra-container 2>&1); then
	

docker exec -it cassandra-container cqlsh ${GET_CONTAINER_IP} -e "CREATE KEYSPACE final_project WITH replication = {
        'class': 'SimpleStrategy', 'replication_factor': 1}"
docker exec -it cassandra-container cqlsh ${GET_CONTAINER_IP} -e "USE final_project; ${GET_CSV_HEADERS}"
echo ${GET_CSV_HEADERS} > air_traffic.cql
docker exec -it ${GET_CONTAINER_ID} cqlsh -e "CREATE TABLE --keyspace=final_project -f air_traffic.cql"
docker cp Air_Traffic_Passenger_Statistics_with_ID.csv ${GET_CONTAINER_ID}:/
docker exec -it ${GET_CONTAINER_ID} cqlsh -e "COPY final_project.air_traffic (\"id\", \"Activity Period\", \"Operating Airline\", \"Operating Airline IATA Code\", \"Published Airline\", \"Published Airline IATA Code\", \"GEO Summary\", \"GEO Region\", \"Activity Type Code\", \"Price Category Code\", \"Terminal\", \"Boarding Area\", \"Passenger Count\", \"Adjusted Activity Type Code\", \"Adjusted Passenger Count\", \"Year\", \"Month\") FROM 'Air_Traffic_Passenger_Statistics_with_ID.csv' WITH HEADER=TRUE;"
fi

#echo "############     agter creatre keyspace       ###############################"
	
#sleep 4

#echo "Wating.................................................."
#until docker exec cassandra-container nodetool status &> /dev/null; do
#	sleep 1
#done

#docker exec -it ${GET_CONTAINER_ID} /opt/cassandra/bin/cqlsh "DESCRIBE KEYSPACES;"
# create the table
#docker exec -it ${GET_CONTAINER_ID} cqlsh -e "USE final_project; ${GET_CSV_HEADERS}"
#echo $GET_CSV_HEADERS > air_traffic.cql
#docker exec -it ${GET_CONTAINER_ID} cqlsh -e "--keyspace=final_project -f air_traffic.cql"


# Populate the table
#docker exec -it ${GET_CONTAINER_ID} cqlsh -e "COPY final_project.air_traffic (\"id\", \"Activity Period\", \"Operating Airline\", \"Operating Airline IATA Code\", \"Published Airline\", \"Published Airline IATA Code\", \"GEO Summary\", \"GEO Region\", \"Activity Type Code\", \"Price Category Code\", \"Terminal\", \"Boarding Area\", \"Passenger Count\", \"Adjusted Activity Type Code\", \"Adjusted Passenger Count\", \"Year\", \"Month\") FROM 'Air_Traffic_Passenger_Statistics_with_ID.csv' WITH HEADER=TRUE;"

cat <<EOF > docker_library.py

if [ -n "$(command -v pip)" ]; then
        echo "Already installed"
else
        sudo apt update
        sudo apt upgrade -y
        sudo apt install -y pip
fi

pip install cassandra-driver tabulate docker
EOF

docker cp docker_library.py ${GET_CONTAINER_ID}:/

# Air China registers
cat <<EOF > air_china_registers.py

import cassandra
from cassandra.cluster import Cluster
from tabulate import tabulate
import os

def space():
        print("\n\n\n")

# Connect to Cassandra
system_ip = os.environ.get('GET_CONTAINER_IP')
cluster = Cluster([system_ip])
session = cluster.connect('final_project')

# Execute the query
rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM air_traffic WHERE "Operating Airline" = \'Air China\' ALLOW FILTERING;')

# Convert rows to a list of lists
data = [list(row) for row in rows]

# Get column names
columns = rows.column_names

# Format the output using tabulate
output = tabulate(data, headers=columns, tablefmt="fancy_grid")

# Print the formatted output
space()
print('##############################   Recuperar todos los registros de la aerolínea “Air China”   ##############################')
space()
print(output)
EOF

# Air Berlin registers
cat <<EOF > air_berlin_registers.py

import cassandra
from cassandra.cluster import Cluster
from tabulate import tabulate
import os

def space():
        print("\n\n\n")

# Connect to Cassandra

system_ip = os.environ.get('GET_CONTAINER_IP')
cluster = Cluster([system_ip])
session = cluster.connect('final_project')

# Execute the query
rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM air_traffic WHERE "Published Airline" = \'Air Berlin\' AND "Boarding Area" = \'G\' ALLOW FILTERING;')

# Convert rows to a list of lists
data = [list(row) for row in rows]

# Get column names
columns = rows.column_names

# Format the output using tabulate
output = tabulate(data, headers=columns, tablefmt="fancy_grid")

# Print the formatted output
space()
print('##############################  Recuperar todos los vuelos de la compañía “AirBerlín”embarcados porla puerta “G” ##############################')
space()

print(output)
EOF

#sudo usermod -aG docker:$USER air_china_registers.py air_berlin_registers.py
chmod +x air_china_registers.py air_berlin_registers.py

python3 air_china_registers.py
python3 air_berlin_registers.py

#cat << EOF > testing.py

#import subprocess

#subprocess.run(["echo", "${GET_CONTAINER_ID}"])
#subprocess.run(["docker", "exec", "-it", "${GET_CONTAINER_ID}", "cqlsh", "-e", "DESCRIBE KEYSPACES"])

#EOF
