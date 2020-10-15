#!/bin/bash

usage() {
  cat <<EOF >&2

Usage: $(basename "$0") [-t <name>] [-l <port>]
-t    Alternate name for top level folder (Default: cnode)
-l    Alternate port (Default: 3000)
EOF
  exit 1
}


# Initialize defaults
CNODE_NAME='cnode'
CNODE_HOME='/opt/cardano/'
CNODE_PORT=3000

while getopts ":t:l:" opt; do
  case ${opt} in
    t ) CNODE_NAME=${OPTARG} ;;
    l ) CNODE_PORT=${OPTARG} ;;
    \? ) usage ;;
    esac
done

echo "Port Set ${CNODE_NAME}"
echo "Port Set ${CNODE_PORT}"

CNODE_HOME="/opt/cardano/${CNODE_NAME}"

sudo bash -c "cat << 'EOF' > /etc/systemd/system/$CNODE_NAME.service
[Unit]
Description=Cardano $CNODE_NAME
After=network.target

[Service]
Environment=CNODE_PORT=$CNODE_PORT
Type=simple
Restart=on-failure
RestartSec=5
User=$USER
LimitNOFILE=1048576
WorkingDirectory=$CNODE_HOME/scripts
ExecStart=/bin/bash -l -c \"exec $CNODE_HOME/scripts/cnode.sh\"
ExecStop=/bin/bash -l -c \"exec kill -2 \$(ps -ef | grep [c]ardano-node.*.${CNODE_HOME} | tr -s ' ' | cut -d ' ' -f2)\"
KillSignal=SIGINT
SuccessExitStatus=143
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$CNODE_NAME
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable $CNODE_NAME.service
