
import cassandra
from cassandra.cluster import Cluster
from tabulate import tabulate
import os

def space():
        print("\n\n\n")

# Connect to Cassandra

system_ip = os.environ.get('GET_CONTAINER_IP')
cluster = Cluster([system_ip])
session = cluster.connect('proyecto')

# Execute the query
rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM my_table WHERE "Published Airline" = \'Air Berlin\' AND "Boarding Area" = \'G\' ALLOW FILTERING;')

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


