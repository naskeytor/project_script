
import subprocess

subprocess.run(["echo", "3526ad503b8c"])
subprocess.run(["docker", "exec", "-it", "3526ad503b8c", "cqlsh", "-e", "DESCRIBE KEYSPACES"])

