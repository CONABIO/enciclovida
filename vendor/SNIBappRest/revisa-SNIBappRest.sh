
# Nombre del proceso
PROCESS_NAME="RESTenciclovida3"
PROCESS_DIR="/home/enciclovida/buscador/vendor/SNIBappRest/"

# Verifica si el proceso está en ejecución
IS_RUNNING=$(pm2 list | grep -w "$PROCESS_NAME" | grep "online")

# Si el proceso no está en ejecución, iniciarlo
if [ -z "$IS_RUNNING" ]; then
	            echo "El proceso $PROCESS_NAME no está en ejecución. Iniciándolo..."
		    cd $PROCESS_DIR
		    nohup pm2 start app.js -i 3 --name RESTenciclovida3 &
	   else
	            echo "El proceso $PROCESS_NAME ya está en ejecución."
fi
