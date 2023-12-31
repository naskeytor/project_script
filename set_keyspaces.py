
import docker
import os
from cassandra.cluster import Cluster

client = docker.from_env()

container_id = os.environ.get('${GET_CONTAINER_ID}') 
container_ip = os.environ.get('${GET_CONTAINER_IP}')
print(container_ip)
keyspace = os.environ.get('${KEYSPACE_NAME}')


cluster = Cluster([container_ip])
session = cluster.connect()

keyspace_query = f"""
    CREATE KEYSPACE IF NOT EXISTE {keyspace}
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
"""

session.execute(keyspace_query)

