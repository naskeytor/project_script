#!/bin/bash


# Install docker on debian/ubuntu

echo "Container initialization, please wait........................................"

if [ ! -n "$(command -v docker)" ]; then
	sudo apt update
	sudo apt upgrade -y
	sudo curl -fsSL https://get.docker.com | sh
	sudo systemctl start docker
    	sudo systemctl enable docker
fi

usermod -aG docker ${USER}
echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/docker" | sudo tee -a /etc/sudoers >/dev/null

# Install Cassandra container
docker pull cassandra:latest > /dev/null
docker run -d --name cassandra-container -p 9042:9042 cassandra > /dev/null

# Set variables
export GET_CONTAINER_ID=$(docker ps | grep cassandra-container | awk '{print $1}')
export GET_CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'  ${GET_CONTAINER_ID})
export KEYSPACE_NAME="final_project"

chmod +x get_csv_headers.py set_csv_id.py
python3 set_csv_id.py

export GET_CSV_HEADERS=$(python3 get_csv_headers.py)

cluster_prepair(){
	if time grep -qi "starting listening" <(docker logs -f cassandra-container 2>&1); then
		docker exec -it cassandra-container cqlsh ${GET_CONTAINER_IP} -e "CREATE KEYSPACE final_project WITH replication = {
        		'class': 'SimpleStrategy', 'replication_factor': 1}"
		docker exec -it cassandra-container cqlsh ${GET_CONTAINER_IP} -e "USE final_project; ${GET_CSV_HEADERS}"
		echo ${GET_CSV_HEADERS} > air_traffic.cql
		docker exec -it ${GET_CONTAINER_ID} cqlsh -e "CREATE TABLE --keyspace=final_project -f air_traffic.cql"
		docker cp Air_Traffic_Passenger_Statistics_with_ID.csv ${GET_CONTAINER_ID}:/
		docker exec -it ${GET_CONTAINER_ID} cqlsh -e "COPY final_project.air_traffic (\"id\", \"Activity Period\", \"Operating Airline\", \"Operating Airline IATA Code\", \"Published Airline\", \"Published Airline IATA Code\", \"GEO Summary\", \"GEO Region\", \"Activity Type Code\", \"Price Category Code\", \"Terminal\", \"Boarding Area\", \"Passenger Count\", \"Adjusted Activity Type Code\", \"Adjusted Passenger Count\", \"Year\", \"Month\") FROM 'Air_Traffic_Passenger_Statistics_with_ID.csv' WITH HEADER=TRUE;"
	fi
}
cluster_prepair

cassandra_drivers(){
	if [ ! command -n pip ]; then
        	sudo apt install -y pip
	fi

	if [ ! pip show cassabndra-driver >/dev/null 2>&1 ] && [ ! pip show tabulate >/dev/null 2>&1 ] && [ ! pip show docker >/dev/null 2>&1 ]; then
		pip install cassandra-driver tabulate docker
	fi
}
cassandra_drivers

chmod +x air_china_registers.py air_berlin_registers.py

python3 air_china_registers.py
python3 air_berlin_registers.py
