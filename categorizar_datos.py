import subprocess
import pkg_resources
import pandas as pd
from tabulate import tabulate

def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

try:
    pkg_resources.get_distribution('tabulate')
except pkg_resources.DistributionNotFound:
    install('tabulate')

archivo_csv = 'Air_Traffic_Passenger_Statistics.csv'

df = pd.read_csv(archivo_csv)
estructura_datos = []

for columna in df.columns:
    tipo_dato = "Categórico" if df[columna].dtype == 'object' else "Numérico"
    estructura_datos.append([columna, tipo_dato])

print(tabulate(estructura_datos, headers=["Nombre del Campo", "Tipo de Dato"], tablefmt="fancy_grid"))
