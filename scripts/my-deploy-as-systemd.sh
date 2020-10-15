#!/bin/bash
# shellcheck disable=SC2086

usage() {
  cat <<EOF >&2

Usage: $(basename "$0") [-m <mode>]
-m    mode to run
EOF
  exit 1
}


# Initialize defaults
RUN_MODE="create"
CNODE_PORT=3000
NEW_EKG_PORT=12788

while getopts ":m:" opt; do
  case ${opt} in
    m ) RUN_MODE=${OPTARG} ;;
    \? ) usage ;;
    esac
done

echo "Mode active: ${RUN_MODE}"

if [ "${RUN_MODE}" == 'create' ]; then
	for node_name in "producer" "relay1" "relay2"
	do
		echo "./cnode-helper-scripts/deploy-as-systemd.sh -t cnode_${node_name} -l ${CNODE_PORT}"
		./cnode-helper-scripts/deploy-as-systemd.sh -t cnode_${node_name} -l ${CNODE_PORT}
		sed -i "s/CNODE_PORT=6000/CNODE_PORT=${CNODE_PORT}/g" /opt/cardano/cnode_${node_name}/scripts/env
		sed -i "s/#EKG_PORT=12788/EKG_PORT=${NEW_EKG_PORT}/g" /opt/cardano/cnode_${node_name}/scripts/env
		sed -i "s/ekgport=12788/ekgport=${NEW_EKG_PORT}/g" /opt/cardano/cnode_${node_name}/files/config.json
		CNODE_PORT=`expr $CNODE_PORT + 100`
		NEW_EKG_PORT=`expr $NEW_EKG_PORT + 1000`
		echo "Staring service: cnode_${node_name}"
		sudo systemctl start cnode_${node_name}
	done
elif [ "${RUN_MODE}" == 'delete' ]; then
	for servicename in "cnode_producer" "cnode_relay1" "cnode_relay2"
	do
		echo "Removing service: $servicename"
		sudo systemctl stop $servicename
		sudo systemctl disable $servicename
		sudo rm /etc/systemd/system/$servicename.service
		sudo rm /etc/systemd/system/$servicename.service # and symlinks that might be related
		sudo rm /usr/lib/systemd/system/$servicename.service
		sudo rm /usr/lib/systemd/system/$servicename.service # and symlinks that might be related
		sudo systemctl daemon-reload
		sudo systemctl reset-failed;
		echo "done."
	done
elif [ "${RUN_MODE}" == 'start-relays' ]; then
        for servicename in "cnode_relay1" "cnode_relay2"
        do
                echo "Starting service: $servicename"
                sudo systemctl start $servicename
                echo "done."
        done

elif [ "${RUN_MODE}" == 'stop-relays' ]; then
        for servicename in "cnode_relay1" "cnode_relay2"
        do
                echo "Stoping service: $servicename"
                sudo systemctl stop $servicename
                echo "done."
        done
else
	echo "Noting to do!"
fi
