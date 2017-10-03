function install-neutron-packages-controller() {
	echo "Instalando NEUTRON en el Controller..."
	sleep 2
	apt-get install neutron-server neutron-plugin-ml2 \
  		neutron-linuxbridge-agent neutron-dhcp-agent \
		haproxy \
  		neutron-metadata-agent python-neutronclient conntrack -y
}

function install-cinder-packages-controller() {
	echo "Instalando CINDER en el Controller..."
	sleep 2
	apt-get install cinder-api cinder-scheduler python-cinderclient -y
}
	
function install-ceilometer-packages-controller() {
	echo "Instalando Ceilometer en el Controller..."
	sleep 2
	apt-get install mongodb-server mongodb-clients python-pymongo -y
	sleep 2
	apt-get install ceilometer-api ceilometer-collector ceilometer-agent-central \
	ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier \
	python-ceilometerclient -y
}

function install-heat-packages-controller() {
	echo "Instalando Heat en el Controller..."
	sleep 2
	apt-get install heat-api heat-api-cfn heat-engine \
  				python-heatclient -y
}

function install-common-packages() {
	echo "Instalando CRUDINI..."
	apt-get install crudini -y
	sleep 3

	echo "Instalando Servidor NTP..."
	sleep 3
	apt-get install chrony -y
	service chrony restart
	
	echo "Añadiendo repositorio de PIKE..."
	sleep 3
	apt-get install software-properties-common -y
	ubuntu_version=`lsb_release -sr`
	if [ "$ubuntu_version" == "17.04" ] || [ "$ubuntu_version" == "16.04" ]
	then
		add-apt-repository cloud-archive:pike
	else
		echo "Pike release supported only on Zesty (17.04) and Xenial (16.04)"
		exit 1;
	fi

	echo "update & upgrade & dist-upgrade del sistema..."
	sleep 3
	apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
	apt-get autoremove -y
	apt-get install python-openstackclient -y
}


function install-controller-packages() {
	echo "Instalando MariaDB y MongoDB..."
	apt-get install mariadb-server python-pymysql -y

	echo "Instalando RabbitMQ..." 
	sleep 3
	apt-get install rabbitmq-server -y
	
	echo "Instalando Keystone..."
	echo "manual" > /etc/init/keystone.override
	sleep 3
	apt-get install keystone apache2 libapache2-mod-wsgi memcached python-memcache -y
	
	echo "Instalando Glance..."
	sleep 2
	apt-get install glance python-glanceclient -y
	
	echo "Instalando Nova en el Controller..."
	sleep 2
	apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy \
	nova-scheduler nova-placement-api python-novaclient -y

	install-neutron-packages-controller
	
	echo "Instalado Horizon..."
	sleep 2
	apt-get install openstack-dashboard -y
	
	#install-cinder-packages-controller 

	#install-ceilometer-pacakges-controller

	#install-heat-pacakges-controller

	echo "Installing Network Node Components..."
	sleep 2
	install-networknode-packages

	echo "Doing autoremove..."
	sleep 2
	apt-get autoremove -y
}

function install-networknode-packages() {
	echo "Instalando servicios de Red..."
	sleep 2
	apt-get install neutron-plugin-ml2 neutron-plugin-linuxbridge-agent \
	neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient conntrack -y
	apt-get autoremove -y
}

function install-compute-packages() {
	echo "Instalando Nova en el Compute"
	sleep 3
	apt-get install nova-compute sysfsutils -y

	echo "Instalando Neutron en el Compute"
	sleep 2
	apt-get install neutron-plugin-linuxbridge-agent conntrack -y
	
	echo "Instalando Ceilometer en el Compute"
	sleep 2
	apt-get install ceilometer-agent-compute -y
	
	apt-get autoremove -y
}

if [ $# -ne 1 ]
	then
		echo "Correct Syntax: $0 [ allinone | controller | compute | networknode ] "
		exit 1;
fi

if [ "$1" == "allinone" ]
	then
		echo "Seleccionado All-in-one. Instalando toda la paqueteria..."
		sleep 5
		install-common-packages
		install-controller-packages
		install-compute-packages
		install-networknode-packages
elif [ "$1" == "controller" ] || [ "$1" == "compute" ] || [ "$1" == "networknode" ]
	then
		install-common-packages
		echo "Instalando paquetería en: "$1
		sleep 5
		install-$1-packages
else
	echo "Correct Syntax: $0 [ allinone | controller | compute | networknode ]"
	exit 1;
fi

echo "********************************************"
echo "SIGUIENTES PASOS:"
echo "** Actualiza lib/config-paramters.sh poniendo los interfaces correctos"
echo "** Ejecuta el comando de abajo en TODOS los nodos:"
echo "       ./configure.sh <controller_ip_address>"
echo "********************************************"
