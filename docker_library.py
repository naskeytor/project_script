
if [ -n "/usr/bin/pip" ]; then
        echo "Already installed"
else
        sudo apt update
        sudo apt upgrade -y
        sudo apt install -y pip
fi

pip install cassandra-driver tabulate docker
