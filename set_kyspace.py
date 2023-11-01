
import subprocess
import os

subprocess.run(["docker", "exec", "-it", "8a1a6e397397", "cqlsh", "-e", "CREATE KEYSPACE final_project WITH replication = {
	'class': 'SimpleStrategy', 'replication_factor': 1}"])
print("Subproces creado .........................................................")

