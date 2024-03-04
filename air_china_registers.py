
import cassandra
from cassandra.cluster import Cluster
from tabulate import tabulate
import os

def space():
        print("\n\n\n")

system_ip = os.environ.get('GET_CONTAINER_IP')
cluster = Cluster([system_ip])
session = cluster.connect('final_project')

rows = session.execute('SELECT "Published Airline", "Published Airline IATA Code", "Terminal", "Boarding Area", "Passenger Count", "Month", "Year", "GEO Region", "Price Category Code", "Activity Type Code" FROM air_traffic WHERE "Operating Airline" = \'Air China\' ALLOW FILTERING;')

data = [list(row) for row in rows]
columns = rows.column_names
output = tabulate(data, headers=columns, tablefmt="fancy_grid")

space()
print('##############################   Recuperar todos los registros de la aerolínea “Air China”   ##############################')
space()
print(output)
