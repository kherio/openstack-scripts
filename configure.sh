dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Tipo de nodo detectado: $node_type"
echo "Recogiendo los parámetros..."
source $dir_path/lib/config-parameters.sh
echo "Interfaz de Gestion: "$mgmt_interface
echo "Interfaz para PUB/PVT: "$data_interface
echo "Nombre del Host Controller: "$controller_host_name

bash $dir_path/util/backup-restore-config-files.sh backup $dir_path/config_file_backup/
echo "Backed up Config files"
sleep 5

if [ $# -ne 1 ]
then
       	echo "Sintaxis incorrecta: $0 <controller_ip_address>"
	exit 1
fi

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ] 
then
	echo "ACtualizando /etc/hosts en el Controller..."
	sleep 5
	bash $dir_path/util/update-etc-hosts.sh $mgmt_interface $controller_host_name
else
	echo "Actualizando /etc/hosts en el resto de Nodos..."
	sleep 5
	bash $dir_path/util/update-etc-hosts.sh $mgmt_interface $controller_host_name $1
fi

if [ "$node_type" == "allinone" ]
	then
		echo "Configurando paquetería para All-in-one"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller $1
		bash $dir_path/lib/configure-packages.sh networknode
		bash $dir_path/lib/configure-packages.sh compute 
elif [ "$node_type" == "compute" ] || [ "$node_type" == "networknode" ]
	then
		echo "Configurando paquetería para: "$node_type
		sleep 5
		bash $dir_path/lib/configure-packages.sh $node_type 
elif [ "$node_type" == "controller" ] || [ "$node_type" == "controller_networknode" ]
	then
		echo "Configurando paquetería en Controller y Nodo de Red"
		sleep 5
		bash $dir_path/lib/configure-packages.sh controller $1
else
	echo "Tipo de nodo no soportado en $0: $node_type"
	exit 1;
fi

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ]
	then
		echo "************************************"
		echo "** Ejecuta post-config-actions.sh **"
		echo "************************************"
fi
