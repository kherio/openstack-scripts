echo "Running: $0 $@"
dir_path=$(dirname $0)
node_type=`bash $dir_path/util/detect-nodetype.sh`
echo "Tipo de nodo detectado: $node_type"

if [ "$node_type" == "allinone" ] || [ "$node_type" == "controller" ] 
	then
		echo -n "Quieres acceder a los LOGs desde la consola web? [y/n]: "
		read enable_web_log_view
		if [ "$enable_web_log_view" == "y" ]
		then
			mkdir /var/www/html/oslogs
			chmod a+rx /var/log/nova
			chmod a+rx /var/log/neutron
			chmod a+rx /var/log/apache2
			chmod a+rx /var/log/keystone
			ln -s /var/log/nova /var/www/html/oslogs/nova
			ln -s /var/log/neutron /var/www/html/oslogs/neutron
			ln -s /var/log/apache2 /var/www/html/oslogs/apache2
			ln -s /var/log/keystone /var/www/html/oslogs/keystone
			echo "Visit http://<controller_ip>/oslogs"
		fi
		echo -n "Quieres descargar e implementar la imagen de Cirros? [y/n]: "
		read setup_cirros_image
		if [ "$setup_cirros_image" == "y" ]
		then
			sleep 2
			bash $dir_path/lib/setup-cirros-image.sh Cirros
			sleep 2
		fi
		echo -n "Quieres crear un sabor para iniciar instancias? [y/n]: "
		read setup_flavor
		if [ "$setup_flavor" == "y" ]
		then
			source $dir_path/lib/admin_openrc.sh
			echo "Creando el sabor 'myflavor' con 1 vCPU, 256MB RAM y 500MB disk"
			sleep 1
			openstack flavor create --public myflavor --id auto --ram 256 --disk 1 --vcpus 1 --rxtx-factor 1
			sleep 1

		fi
		echo -n "Quieres crear ya una RED, una SUBRED y un ROUTER? [y/n]: "
		read setup_openstack_network
		if [ "$setup_openstack_network" == "y" ]
		then
			source $dir_path/lib/admin_openrc.sh
			echo "Iniciando la creación de una red básica, etc"
			openstack network create network1
			sleep 2
			openstack subnet create --network network1 --subnet-range 20.20.20.0/24 subnet1
			sleep 2
			openstack network create network2
			sleep 2
			openstack subnet create --network network2 --subnet-range 192.168.150.0/24 subnet2
			echo "Iniciando la creación de un Router y una Subred"
			sleep 2
			openstack router create router1
			sleep 2
			openstack router add subnet router1 subnet1
			sleep 2
			openstack router add subnet router1 subnet2
		fi
else
        echo "Este comando solo funciona en un Controller"
	exit 1
fi

