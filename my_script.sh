#!/bin/bash

# Verificar si Docker está instalado
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker no está instalado. Instalando Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
  sudo systemctl start docker
  sudo systemctl enable docker
  echo "Docker ha sido instalado y configurado."
  rm get-docker.sh
fi

# Iniciar un contenedor de Cassandra
docker run -d --name cassandra-container -p 9042:9042 cassandra

# Esperar a que el contenedor de Cassandra esté en funcionamiento
echo "Esperando a que el contenedor de Cassandra esté en funcionamiento..."
until docker exec cassandra-container nodetool status &> /dev/null; do
  sleep 1
done
echo "El contenedor de Cassandra está en funcionamiento."

# Ejecutar el comando DESCRIBE KEYSPACES en el contenedor de Cassandra
docker exec cassandra-container cqlsh -e "DESCRIBE KEYSPACES"

